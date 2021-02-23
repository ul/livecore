## Sound server. Runs and hot-reloads session code in the audio thread.

import
  atomics,
  dsp/frame,
  dynlib,
  ffi/[fswatch, soundio],
  ffi/lo/[lo, lo_serverthread, lo_types, lo_osc_types],
  os,
  parseopt,
  strutils

var
  dev_id = -1
  osc_addr = "7770"

for kind, key, val in getopt():
  case kind
  of cmdArgument: discard
  of cmdLongOption, cmdShortOption:
    case key
    of "dac": dev_id = val.parse_int
    of "osc": osc_addr = val
    else: discard
  of cmdEnd: assert(false) # cannot happen

var in_process: Atomic[bool]
in_process.store(false)

const
  size_of_arena = 512 * 1024 * 1024 # = 512MB
  size_of_channel_area = sizeof SoundIoChannelArea

type
  Process = proc(arena: pointer, cc: var Controls, n: var Notes): Frame {.nimcall.}
  Load = proc(arena: pointer) {.nimcall.}
  Unload = proc(arena: pointer) {.nimcall.}
  State = object
    process: Atomic[Process]
    arena: pointer
    controls: Controls
    notes: Notes
    note_cursor: int

proc default_process(arena: pointer, cc: var Controls, n: var Notes): Frame = 0.0

proc write_callback(out_stream: ptr SoundIoOutStream, frame_count_min: cint, frame_count_max: cint) {.cdecl.} =
  in_process.store(true)

  let state = cast[ptr State](out_stream.userdata)
  let arena = state.arena
  let process = state.process.load
  let channel_count = out_stream.layout.channel_count
  var areas: ptr SoundIoChannelArea
  var frames_left = frame_count_max
  var err: cint

  while true:
    var frame_count = frames_left

    err = out_stream.begin_write(areas.addr, frame_count.addr)
    if err > 0:
      quit "Unrecoverable out stream begin error: " & $soundio.strerror(err)
    if frame_count <= 0:
      break

    let ptr_areas = cast[int](areas)

    for frame in 0..<frame_count:
      let samples = process(arena, state.controls, state.notes)
      for channel in 0..<channel_count:
        let ptr_area = cast[ptr SoundIoChannelArea](ptr_areas + channel*size_of_channel_area)
        var ptr_sample = cast[ptr float32](cast[int](ptr_area.pointer) + frame*ptr_area.step)
        ptr_sample[] = samples[channel].float32.min(1.0).max(-1.0)

    err = out_stream.end_write
    if err > 0 and err != cint(SoundIoError.Underflow):
      quit "Unrecoverable out stream end error: " & $soundio.strerror(err)

    frames_left -= frame_count
    if frames_left <= 0:
      break

  in_process.store(false)

let sio = soundio_create()
if sio.is_nil:
  quit "Out of memory"

var err = sio.connect
if err > 0:
   quit "Unable to connect to backend: " & $soundio.strerror(err)

echo "Backend: \t", sio.current_backend.name
sio.flush_events

for i in 0..<sio.output_device_count:
  let device = sio.get_output_device(i)
  echo i, "\t", device.name

if dev_id < 0:
  dev_id = sio.default_output_device_index

if dev_id < 0:
  quit "Output device it not found"

let device = sio.get_output_device(dev_id.cint)
if device.is_nil:
  quit "Out of memory"

echo "Output device:\t", device.name

if device.probe_error > 0:
  quit "Cannot probe device:" & $soundio.strerror(device.probe_error)

if not device.supports_format(SoundIoFormatFloat32NE):
  quit "Device doesn't support float32 format"

let stream = device.out_stream_create
if stream.is_nil:
  quit "Out of memory"

var state = cast[ptr State](State.sizeof.alloc)
state.process.store(default_process)
state.arena = size_of_arena.alloc0

stream.write_callback = write_callback
stream.userdata = state
stream.format = SoundIoFormatFloat32NE

err = stream.open
if err > 0:
  quit "Unable to open device"

if stream.layout_error > 0:
  quit "Unable to set channel layout"

err = stream.start
if err > 0:
  quit "Unable to start stream"

sio.flush_events

proc osc_error(num: cint; msg: cstring; where: cstring) {.cdecl.} =
  echo "liblo server error ", num, " in path ", where, ": ", msg

proc controls_handler(path: cstring; types: cstring; argv: ptr ptr lo_arg; argc: cint; msg: lo_message; user_data: pointer): cint {.cdecl.} =
  let argvi = cast[int](argv)
  let psz = pointer.sizeof
  let arg0 = cast[ptr lo_arg](argv[])
  let arg1 = cast[ptr lo_arg](cast[ptr ptr lo_arg](argvi + psz)[])
  let i = arg0.i
  let x = arg1.f
  let state = cast[ptr State](user_data)
  state.controls[i].store(x)

proc midi2osc_handler(path: cstring; types: cstring; argv: ptr ptr lo_arg; argc: cint; msg: lo_message; user_data: pointer): cint {.cdecl.} =
  let n = state.notes.len
  let m = cast[ptr lo_arg](argv[]).m
  let state = cast[ptr State](user_data)
  case m[1]
  of 0xB0: # cc
    state.controls[m[2]].store(m[3].float / 0x80)
  # notes are encoded as uint16 to atomically update both pitch and velocity
  # lower byte is pitch, and higher one is velocity
  of 0x90: # note on
    state.notes[state.note_cursor].store(m[2].uint16 + 0x100*m[3].uint16)
    state.note_cursor = (state.note_cursor + 1) mod n
  of 0x80: # note off
    for i in 1..n:
      # we'd like to disable the most recent note with the same pitch
      let j = (n + state.note_cursor - i) mod n
      if (state.notes[j].load and 0x00FF) == m[2]:
        state.notes[j].store(m[2].uint16)
        break
  else: discard
  # TODO log into file to be committed as a part of session 
  echo "0x", m[1].to_hex, " 0x", m[2].to_hex, " 0x", m[3].to_hex

proc tidal_triggers_handler(path: cstring; types: cstring; argv: ptr ptr lo_arg; argc: cint; msg: lo_message; user_data: pointer): cint {.cdecl.} =
  let state = cast[ptr State](user_data)
  state.controls[argv.i].store(1.0)

proc tidal_notes_handler(path: cstring; types: cstring; argv: ptr ptr lo_arg; argc: cint; msg: lo_message; user_data: pointer): cint {.cdecl.} =
  let state = cast[ptr State](user_data)
  state.notes[state.note_cursor].store(argv.i.uint16 + (0x100*0xFF).uint16)
  state.note_cursor = (state.note_cursor + 1) mod state.notes.len

let osc_server_thread = osc_addr.lo_server_thread_new(osc_error)
discard lo_server_thread_add_method(osc_server_thread, "/notes", "m", midi2osc_handler, state);
discard lo_server_thread_add_method(osc_server_thread, "/controls", "if", controls_handler, state);
discard lo_server_thread_add_method(osc_server_thread, "/tidal/triggers", "i", tidal_triggers_handler, state);
discard lo_server_thread_add_method(osc_server_thread, "/tidal/notes", "i", tidal_notes_handler, state);
discard lo_server_thread_add_method(osc_server_thread, "/tidal/controls", "if", controls_handler, state);
discard lo_server_thread_start(osc_server_thread)

if fsw_init_library() != 0:
  quit "Failed to init FSWatch"

var fsw = fsw_init_session(0)

if fsw.fsw_add_path("./target") != 0:
  quit "Failed to add target to watch paths"

var fsw_filter1 = fsw_cmonitor_filter(text: "session\\.so\\.[0-9]+$", filter_type: fsw_filter_type.filter_include, case_sensitive: false, extended: true)
if fsw.fsw_add_filter(fsw_filter1) != 0:
  quit "Failed to add watch filter"

var fsw_filter2 = fsw_cmonitor_filter(text: ".*", filter_type: fsw_filter_type.filter_exclude, case_sensitive: false, extended: true)
if fsw.fsw_add_filter(fsw_filter2) != 0:
  quit "Failed to add watch filter"

var old_path: string
var old_lib: LibHandle

proc load(new_path: string) =
  let new_lib = new_path.load_lib
  if new_lib.is_nil:
    echo "Error loading library"
    new_lib.unload_lib
    return

  let new_process = cast[Process](new_lib.sym_addr("process"))
  if new_process.is_nil:
    echo "Error looking up process"
    new_lib.unload_lib
    return

  let onload = cast[Load](new_lib.sym_addr("load"))
  state.arena.onload

  while in_process.load: discard
  state.process.store(new_process)
  while in_process.load: discard

  if not old_lib.is_nil:
    let onunload = cast[Unload](old_lib.sym_addr("unload"))
    state.arena.onunload
    old_lib.unload_lib
    discard old_path.try_remove_file

  old_path = new_path
  old_lib = new_lib

  echo "<= ", new_path

var initial_path = ""
for path in walk_files("target/session.so.*"):
  if initial_path == "" or path.file_newer(initial_path):
    if initial_path != "":
      discard initial_path.try_remove_file
    initial_path = path

if initial_path != "":
  load(initial_path)

proc monitor(event: fsw_cevent, num: cuint) =
  for i in 0..<event.flags_num:
    let flag = cast[ptr fsw_event_flag](cast[int](event.flags) + cast[int](i) * fsw_event_flag.sizeof)[]
    if flag == fsw_event_flag.Removed:
      return
  load(relative_path($event.path, "."))

if fsw.fsw_set_callback(monitor) != 0:
  quit "Failed add target to watch paths"

discard fsw.fsw_start_monitor()

osc_server_thread.lo_server_thread_free
stream.destroy
device.unref
sio.destroy
state.arena.dealloc
state.dealloc
