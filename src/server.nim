## Sound server. Runs and hot-reloads session code in the audio thread.

import
  atomics,
  dsp/frame,
  dynlib,
  ffi/[fswatch, soundio],
  ffi/lo/[lo_serverthread, lo_types, lo_osc_types],
  os,
  parseopt,
  scope,
  strformat,
  strutils,
  threadpool

var
  dac_id = -1
  adc_id = -1
  osc_addr = "7770"
  run_scope = false

for kind, key, val in getopt():
  case kind
  of cmdArgument: discard
  of cmdLongOption, cmdShortOption:
    case key
    of "dac": dac_id = val.parse_int
    of "adc": adc_id = val.parse_int
    of "osc": osc_addr = val
    of "scope": run_scope = true
    else: discard
  of cmdEnd: assert(false) # cannot happen

var in_process: Atomic[bool]
in_process.store(false)

const
  size_of_arena = 512 * 1024 * 1024 # = 512MB
  size_of_channel_area = sizeof SoundIoChannelArea

type
  Process = proc(arena: pointer, cc: var Controls, n: var Notes, input: Frame, monitor: var Monitor): Frame {.nimcall.}
  Load = proc(arena: pointer) {.nimcall.}
  Unload = proc(arena: pointer) {.nimcall.}
  State = object
    process: Atomic[Process]
    arena: pointer
    controls: Controls
    notes: Notes
    note_cursor: int
    input: ptr SoundIoRingBuffer
    monitor: Monitor

proc default_process(arena: pointer, cc: var Controls, n: var Notes, input: Frame, monitor: var Monitor): Frame = 0.0

proc write_callback(out_stream: ptr SoundIoOutStream, frame_count_min: cint, frame_count_max: cint) {.cdecl.} =
  in_process.store(true)

  let state = cast[ptr State](out_stream.userdata)
  let arena = state.arena
  let process = state.process.load
  let input = state.input
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

    var ptr_input: int
    if not input.is_nil:
      ptr_input = cast[int](input.read_ptr)

    for frame in 0..<frame_count:
      var input_frame: array[CHANNELS, float]
      if not input.is_nil:
        for channel in 0..<CHANNELS:
          input_frame[channel] = cast[ptr float](ptr_input + (frame*CHANNELS + channel)*(sizeof float))[]

      let samples = process(arena, state.controls, state.notes, input_frame, state.monitor)
      for channel in 0..<channel_count:
        let ptr_area = cast[ptr SoundIoChannelArea](ptr_areas + channel*size_of_channel_area)
        var ptr_sample = cast[ptr float32](cast[int](ptr_area.pointer) + frame*ptr_area.step)
        ptr_sample[] = samples[channel].float32.min(1.0).max(-1.0)

    if not input.is_nil:
      input.advance_read_ptr(cast[cint](frame_count*CHANNELS*(sizeof float)))

    err = out_stream.end_write
    if err > 0 and err != cint(SoundIoError.Underflow):
      quit "Unrecoverable out stream end error: " & $soundio.strerror(err)


    frames_left -= frame_count
    if frames_left <= 0:
      break

  in_process.store(false)

proc read_callback(in_stream: ptr SoundIoInStream, frame_count_min: cint, frame_count_max: cint) {.cdecl.} =
  let state = cast[ptr State](in_stream.userdata)
  let input = state.input
  var areas: ptr SoundIoChannelArea
  var frames_left = frame_count_max
  var err: cint

  while true:
    var frame_count = frames_left

    err = in_stream.begin_read(areas.addr, frame_count.addr)
    if err > 0:
      quit "Unrecoverable input stream begin error: " & $soundio.strerror(err)
    if frame_count <= 0:
      break

    let ptr_areas = cast[int](areas)

    let ptr_input: int = cast[int](input.write_ptr)

    for frame in 0..<frame_count:
      for channel in 0..<CHANNELS:
        var ptr_input_sample = cast[ptr float](ptr_input + (frame*CHANNELS + channel)*(sizeof float))
        let ptr_area = cast[ptr SoundIoChannelArea](ptr_areas + channel*size_of_channel_area)
        var ptr_sample = cast[ptr float32](cast[int](ptr_area.pointer) + frame*ptr_area.step)
        ptr_input_sample[] = ptr_sample[].float

    input.advance_write_ptr(cast[cint](frame_count*CHANNELS*(sizeof float)))

    err = in_stream.end_read
    if err > 0 and err != cint(SoundIoError.Underflow):
      quit "Unrecoverable input stream end error: " & $soundio.strerror(err)

    frames_left -= frame_count
    if frames_left <= 0:
      break

let sio = soundio_create()
if sio.is_nil:
  quit "Out of memory"

var err = sio.connect
if err > 0:
   quit "Unable to connect to backend: " & $soundio.strerror(err)

echo "Backend: \t", sio.current_backend.name
sio.flush_events

echo "\nOutput devices (select with --dac:N):"
for i in 0..<sio.output_device_count:
  let device = sio.get_output_device(i)
  echo i, "\t", device.name

echo "\nInput devices (select with --adc:N):"
for i in 0..<sio.input_device_count:
  let device = sio.get_input_device(i)
  echo i, "\t", device.name

# Open output device

if dac_id < 0:
  dac_id = sio.default_output_device_index

if dac_id < 0:
  quit "Output device it not found"

let output_device = sio.get_output_device(dac_id.cint)
if output_device.is_nil:
  quit "Out of memory"

let layout = output_device.current_layout
let chans = layout.channel_count
let sr = output_device.sample_rate_current
echo fmt"{'\n'}Output device:{'\t'}{output_device.name} ({chans}ch @ {sr/1000}kHz)"

if chans < CHANNELS:
  echo fmt"Device has less channels ({chans}) than defined by CHANNELS ({CHANNELS})."
  quit "Please either try another device or update CHANNELS in src/dsp/frames.nim"

if sr != SAMPLE_RATE_INT:
  echo fmt"Device sample rate ({sr}) differs from SAMPLE_RATE_INT ({SAMPLE_RATE_INT})"
  quit "Please either try another device or update SAMPLE_RATE_INT in src/dsp/frames.nim"

if output_device.probe_error > 0:
  quit "Cannot probe device:" & $soundio.strerror(output_device.probe_error)

if not output_device.supports_format(SoundIoFormatFloat32NE):
  quit "Device doesn't support float32 format"

let output_stream = output_device.out_stream_create
if output_stream.is_nil:
  quit "Out of memory"

var state = cast[ptr State](State.sizeof.alloc0)
state.process.store(default_process)
state.arena = size_of_arena.alloc0

output_stream.write_callback = write_callback
output_stream.userdata = state
output_stream.format = SoundIoFormatFloat32NE

err = output_stream.open
if err > 0:
  quit "Unable to open device"

if output_stream.layout_error > 0:
  quit "Unable to set channel layout"

err = output_stream.start
if err > 0:
  quit "Unable to start stream"


# Open input device
var input_device: ptr SoundIoDevice
var input_stream: ptr SoundIoInStream
if adc_id >= 0:

  input_device = sio.get_input_device(adc_id.cint)
  if input_device.is_nil:
    quit "Out of memory"

  let layout = input_device.current_layout
  let chans = layout.channel_count
  let sr = input_device.sample_rate_current
  echo fmt"{'\n'}Input device:{'\t'}{input_device.name} ({chans}ch @ {sr/1000}kHz)"

  if chans < CHANNELS:
    echo fmt"Device has less channels ({chans}) than defined by CHANNELS ({CHANNELS})."
    quit "Please either try another device or update CHANNELS in src/dsp/frames.nim"

  if sr != SAMPLE_RATE_INT:
    echo fmt"Device sample rate ({sr}) differs from SAMPLE_RATE_INT ({SAMPLE_RATE_INT})"
    quit "Please either try another device or update SAMPLE_RATE_INT in src/dsp/frames.nim"

  if input_device.probe_error > 0:
    quit "Cannot probe device:" & $soundio.strerror(input_device.probe_error)

  if not input_device.supports_format(SoundIoFormatFloat32NE):
    quit "Device doesn't support float32 format"

  input_stream = input_device.in_stream_create
  if input_stream.is_nil:
    quit "Out of memory"

  state.input = sio.ring_buffer_create(cast[cint](4 * (
    max(input_stream.software_latency, output_stream.software_latency) * SAMPLE_RATE *
    (CHANNELS * (sizeof float)).to_float
  ).to_int))

  input_stream.read_callback = read_callback
  input_stream.userdata = state
  input_stream.format = SoundIoFormatFloat32NE

  err = input_stream.open
  if err > 0:
    quit "Unable to open device"

  if input_stream.layout_error > 0:
    quit "Unable to set channel layout"

  err = input_stream.start
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
    state.controls[m[2]].store(m[3].float / 0x7F)
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

let osc_server_thread = osc_addr.cstring.lo_server_thread_new(osc_error)
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

proc fs_monitor(event: fsw_cevent, num: cuint) =
  for i in 0..<event.flags_num:
    let flag = cast[ptr fsw_event_flag](cast[int](event.flags) + cast[int](i) * fsw_event_flag.sizeof)[]
    if flag == fsw_event_flag.Removed:
      return
  load(relative_path($event.path, "."))

if fsw.fsw_set_callback(fs_monitor) != 0:
  quit "Failed add target to watch paths"

proc start_fs_monitor() {.gcsafe.} =
  discard fsw.fsw_start_monitor()

spawn start_fs_monitor()


var scope_app: Scope
if run_scope:
  scope_app = Scope(window: nil, renderer: nil, monitor: state.monitor.addr)
  scope_app.start


if run_scope:
  scope_app.exit
osc_server_thread.lo_server_thread_free
if not input_stream.is_nil:
  input_stream.destroy
if not input_device.is_nil:
  input_device.unref
output_stream.destroy
output_device.unref
sio.destroy
if not state.input.is_nil:
  state.input.destroy
state.arena.dealloc
state.dealloc
