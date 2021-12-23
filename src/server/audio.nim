import
  atomics,
  context,
  ../dsp/frame,
  ffi/soundio,
  strformat

proc write_callback(out_stream: ptr SoundIoOutStream, frame_count_min: cint, frame_count_max: cint) {.cdecl.} =
  let ctx = cast[ptr Context](out_stream.userdata)
  ctx.in_process.store(true)

  let arena = ctx.arena
  let process = ctx.process.load
  let input = ctx.input
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

      let samples = process(arena, ctx.controls, ctx.notes, input_frame)
      for channel in 0..<channel_count:
        let ptr_area = cast[ptr SoundIoChannelArea](ptr_areas + channel*SoundIoChannelArea.sizeof)
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

  ctx.in_process.store(false)

proc read_callback(in_stream: ptr SoundIoInStream, frame_count_min: cint, frame_count_max: cint) {.cdecl.} =
  let ctx = cast[ptr Context](in_stream.userdata)
  let input = ctx.input
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
        let ptr_area = cast[ptr SoundIoChannelArea](ptr_areas + channel*SoundIoChannelArea.sizeof)
        var ptr_sample = cast[ptr float32](cast[int](ptr_area.pointer) + frame*ptr_area.step)
        ptr_input_sample[] = ptr_sample[].float

    input.advance_write_ptr(cast[cint](frame_count*CHANNELS*(sizeof float)))

    err = in_stream.end_read
    if err > 0 and err != cint(SoundIoError.Underflow):
      quit "Unrecoverable input stream end error: " & $soundio.strerror(err)

    frames_left -= frame_count
    if frames_left <= 0:
      break

proc start_audio*(ctx: ptr Context, param_dac_id, param_adc_id: int) =
  var dac_id = param_dac_id
  var adc_id = param_adc_id
  let sio = soundio_create()
  if sio.is_nil:
    quit "Out of memory."

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
    quit "Output device it not found."

  let output_device = sio.get_output_device(dac_id.cint)
  if output_device.is_nil:
    quit "Out of memory."

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
    quit "Device doesn't support float32 format."

  let output_stream = output_device.out_stream_create
  if output_stream.is_nil:
    quit "Out of memory."

  output_stream.write_callback = write_callback
  output_stream.userdata = ctx
  output_stream.format = SoundIoFormatFloat32NE

  err = output_stream.open
  if err > 0:
    quit "Unable to open device."

  if output_stream.layout_error > 0:
    quit "Unable to set channel layout."

  err = output_stream.start
  if err > 0:
    quit "Unable to start stream."


  # Open input device
  var input_device: ptr SoundIoDevice
  var input_stream: ptr SoundIoInStream
  if adc_id >= 0:

    input_device = sio.get_input_device(adc_id.cint)
    if input_device.is_nil:
      quit "Out of memory."

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
      quit "Device doesn't support float32 format."

    input_stream = input_device.in_stream_create
    if input_stream.is_nil:
      quit "Out of memory."

    ctx.input = sio.ring_buffer_create(cast[cint](4 * (
      max(input_stream.software_latency, output_stream.software_latency) * SAMPLE_RATE *
      (CHANNELS * (sizeof float)).float
    ).int))

    input_stream.read_callback = read_callback
    input_stream.userdata = ctx
    input_stream.format = SoundIoFormatFloat32NE

    err = input_stream.open
    if err > 0:
      quit "Unable to open device."

    if input_stream.layout_error > 0:
      quit "Unable to set channel layout."

    err = input_stream.start
    if err > 0:
      quit "Unable to start stream."

  sio.flush_events
