{.compile: "ffi/audio.c".}

proc audio_enum_devices(dac_idx, adc_idx: cint) {.importc, header: "audio.h".}
proc audio_user_data(device: pointer): pointer {.importc, header: "audio.h".}
proc audio_init(channels, sample_rate, dac_idx, adc_idx: cint,
    data_callback: proc (device, output, input: pointer,
    frame_count: cuint) {.cdecl.}, ctx: pointer
): pointer {.importc, header: "audio.h".}
proc audio_start(device: pointer): int {.importc, header: "audio.h".}

import
  std/[atomics, monotimes],
  ../dsp/frame,
  context

proc now(): float64 = get_mono_time().ticks.float64 / 1e9 # seconds

proc data_callback(device, output, input: pointer,
    frame_count: cuint) {.cdecl.} =
  let start = now()
  let ctx = cast[ptr Context](audio_user_data(device))
  ctx.in_process.store(true)

  let arena = ctx.arena
  let audio = ctx.audio.load
  let control = ctx.control.load

  let ptr_output = cast[int](output)
  let ptr_input = cast[int](input)

  control(arena, ctx.controllers, ctx.notes, cast[int](frame_count))

  for frame in 0..<frame_count.int:
    var input_frame: array[CHANNELS, float]
    if not input.is_nil:
      for channel in 0..<CHANNELS:
        input_frame[channel] = cast[ptr float32](ptr_input + (frame*CHANNELS +
            channel)*(sizeof float32))[]

    let samples = audio(arena, ctx.controllers, ctx.notes, input_frame)
    for channel in 0..<CHANNELS:
      var ptr_sample = cast[ptr float32](ptr_output + (frame*CHANNELS +
          channel)*(sizeof float32))
      ptr_sample[] = samples[channel].float32.min(1.0).max(-1.0)

  let t = (now() - start).seconds / frame_count.float64
  ctx.stats.n.inc
  ctx.stats.avg += (t - ctx.stats.avg) / ctx.stats.n.to_float
  ctx.stats.min = min(ctx.stats.min, t)
  ctx.stats.max = max(ctx.stats.max, t)
  ctx.in_process.store(false)

proc start_audio*(ctx: ptr Context, dac_idx, adc_idx: int) =
  let dac = dac_idx.cint
  let adc = adc_idx.cint

  audio_enum_devices(dac, adc)

  let output_device = audio_init(CHANNELS, SAMPLE_RATE_INT, dac, adc,
      data_callback, ctx)

  # TODO Better error diagnostics.

  if output_device.is_nil:
    quit "Failed to initialise output device."

  if audio_start(output_device) > 0:
    quit "Failed to start output device."
