## Where the creativity blossoms.

import
  std/[atomics, math, options],
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, sampler, soundpipe, stereo, fft, fir, conv, notes],
  strudel/core/pattern,
  cycler, pool, control

defDelay(300)

proc adsr*(note: Note, a, d, s: float): float =
  note.value * note.gate.adsr(a, d, s, note.duration - a - d)

type
  State* = object
    pool: Pool
    cycler: Cycler
    sines: seq[Voice]
    triangles: seq[Voice]
    squares: seq[Voice]

proc control*(s: var State, cc: var Controllers, n: var Notes,
    frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  const o = 0.0
  const x = 1.0

  const e = 8

  let sines = [
    [g3.euclid(9, e), o, o, o].sequence,
    [c4.euclid(12, e), o, o, o, o],
  ].sequence

  let triangles = [[
    [c3.euclid(3, e), o].sequence,
    [e3.euclid(4, e), o, o],
  ].sequence, sines].sequence

  let squares = [[
    g5.euclid(2, e),
    c5.euclid(3, e),
  ].sequence, triangles].sequence

  s.sines = [sines, squares].stack.voices(s.cycler)
  s.triangles = [triangles, sines].stack.voices(s.cycler)
  s.squares = squares.voices(s.cycler)

proc audio*(s: var State, cc: var Controllers, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  s.cycler.tick(6)

  let atk = 1/128

  let sines = s.cycler.sing(s.sines):
    let x = note.with_value:
      it.fm_osc(1/2, 2/3)
    x.adsr(atk, atk, 1/2)

  let triangles = s.cycler.sing(s.triangles):
    let x = note.with_value:
      it.fm_bltriangle(1/2, 2/3)
    x.adsr(atk, atk, 1/2)

  let squares = s.cycler.sing(s.squares):
    let x = note.with_value:
      it.blsquare(0.5)
    x.adsr(atk, atk, 1/2)

  let choir =
    sines.fb(0.2, 0.4) +
    1.2*triangles.fb(0.3, 0.3) +
    0.4*squares.wp_korg35(c6, 0.95, 1.0).fb(0.4, 0.6)

  choir
    .mul(0.5)
    .long_fb(12, 0.5)
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
