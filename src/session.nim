## Where the creativity blossoms.

import
  std/[atomics, math, options],
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, sampler, soundpipe, stereo, fft, fir, conv, notes],
  strudel/core/pattern,
  cycler, pool, control

defDelay(300)

type
  State* = object
    pool: Pool
    cycler: Cycler
    looong: Delay300

proc inst1(event: Controls, s: var State): Frame {.nimcall.} =
  let x = event.note.get(silence).osc
  let a = 0.05.min(0.2*event.duration.max(1/64))
  let d = 2*a
  let sus = 0.5
  event.gate
    .adsr(a, d, sus, d)
    .mul(x)
    .mul(event.gain.get(1))

proc inst2(event: Controls, s: var State): Frame {.nimcall.} =
  let x = event.note.get(silence).bl_triangle
  let a = 0.05.min(0.2*event.duration.max(1/64))
  let d = 2*a
  let sus = 0.5
  event.gate
    .adsr(a, d, sus, d)
    .mul(x)
    .mul(event.gain.get(1))

proc control*(s: var State, cc: var Controllers, n: var Notes, frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  let p = //[
    (//[!c4, e4, g4]).note.euclid(3, 8) >> gain([0.25, 0.1]),
    (//[!c3, c4]).note.euclid(7, 8) >> gain([0.15, 0.2]),
    [!e4, g4, c3].note.euclid(2, 8) >> gain([0.2, 0.3])
  ] >> sound(//[! ^inst1, [nil, ^inst2]])

  s.cycler.schedule(p, frame_count.to_seconds, 1.0)

proc audio*(s: var State, cc: var Controllers, n: var Notes, input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  s.cycler.tick((1/120).osc.biscale(0.1, 0.5))

  let choir = s.cycler.process(^s)

  choir
    .long_ff(1.0, 0.5)
    .zita_rev(level=0)
    .simple_saturator
    .dc_block

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
