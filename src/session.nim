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
    notes: seq[Voice]
    melody: Frame

proc control*(s: var State, cc: var Controllers, n: var Notes,
    frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  const o = 0.0
  const x = 1.0

  s.notes = ([
    [
      [c3, e3, f3].struct([x, o, x, x, o, x]),
      [c3, e3, g3].struct([x, x, o, x, o, x]),
      [d3, e3, g3].struct([o, x, o, o, x, o]),
    ].stack,
    [
      [c3, e3, f3].struct([x, o, x, x, o, x]),
      [c3, e3, g3].struct([x, x, o, x, o, x]),
      [d3, e3, g3].struct([o, x, o, o, x, o]),
    ].sequence,
  ].stack).voices(s.cycler)

proc audio*(s: var State, cc: var Controllers, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  s.cycler.tick((1/120).osc.biscale(1/16, 1/4).add((1/30).osc.mul(1/32)))

  var sig = 0.0

  for note in s.notes:
    let note_on = note.gate(s.cycler)
    let dur = note.duration(s.cycler)
    let a = 1/4
    let d = a*2
    let s = 1/5
    let r = dur - a - d
    let env = note_on.adsr(a, d, s, r)
    let n = note.value
    let x = n.fm_bltriangle(
        1/2.add((1/20).osc.mul(1/128)),
        2/3.add((1/30).osc.mul(1/128)),
      )
      .mul(0.7071)
      .add(n.mul(0.5).fm_osc(2/3, 1/2).mul(0.5))
      .add(n.mul(2).fm_osc(1/2, 2/3).mul(0.25))
      .add(n.mul(3).fm_bltriangle(1/2, 2/3).mul(0.2))
      .mul(env)
    let y = x.mul(0.5) + x
      .mul(n.mul(4).bltriangle
      .mul(0.1)
      .mul(env)
      .long_fb((1/30).tri.biscale(4, 16), 0.55))
    sig += y
      .long_fb(1.0 + dur.tline(1.0), 0.5)

  sig
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
