## Where the creativity blossoms.

import
  std/[atomics, math, options],
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, sampler, soundpipe, stereo, fft, fir, conv, notes],
  strudel/core/pattern,
  cycler, pool, control

defDelay(300)


proc `*`(x: (int, float), y: float): (int, float) =
  (x[0], x[1]*y)

proc `*`(x: float, y: (int, float)): (int, float) =
  (y[0], x*y[1])

{.experimental: "dotOperators".}
proc `.`(x: int, y: float): Pattern[(int, float)] =
  pure((x, y))

type
  State* = object
    pool: Pool
    cycler: Cycler
    voices: seq[Voice[(int, float)]]

proc control*(s: var State, cc: var Controllers, n: var Notes,
    frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  const o = 0.0
  const x = 1.0

  let O = -1.o

  var p = [
    [1.c5, 1.e5, 1.g5].euclid(12, 8),
    [0.c4, 0.e4].sequence,
    [0.c3, O].sequence,
  ].euclid(3, 8) #.struct([x, x, o, x, o, x, o, x, x])

  p = [
    [
      [1.c5, 1.e5, 1.g5].euclid(9, 8),
      [0.c4, 0.e4].sequence,
      [0.c3, O].sequence,
    ].stack,
    p,
    p.euclid(4, 8),
    [1.e3, O, O, O].euclid(3, 8),
  ].stack

  s.voices = p.voices(s.cycler)

proc audio*(s: var State, cc: var Controllers, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  let cycle_dur = 10.0 # seconds
  s.cycler.tick(60.0 / cycle_dur)

  let atk = 1/32

  let instruments = {
    0: proc(note: Note): float =
      let x = note.value.fm_osc(1/2, 2/3)
      let a = atk.max(0.5*note.duration)
      let d = 0.5*a
      let sus = 0.8
      note.gate
        .adsr(a, d, sus, atk)
        .mul(x)
    ,

    1: proc(note: Note): float =
      let x = note.value.bl_triangle
      let a = atk.max(0.5*note.duration)
      let d = 0.5*a
      let sus = 0.8
      note.gate
        .impulse(a)
        .mul(x)
        .mul(0.5)
        .fb(0.5, 0.4)
    ,
  }

  let choir = s.cycler.sing(s.voices, instruments)

  choir
    .mul(0.1)
    .fb(0.8, 0.25)
    .bqhpf(30, 0.7071)
    .wp_korg35(c7, 0.95, 1.0)
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
