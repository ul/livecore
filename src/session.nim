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
    looong: array[CHANNELS, Delay300]
    atk: float

proc inst0(e: Controls, s: var State): Frame =
  let x = e.note.get.fm_osc(1/3, 1/5) + pink_noise().mul(0.1)
  let a = s.atk.min(0.2*e.duration.max(1/64))
  let d = 2*a
  let sus = 0.5
  e.gate
    .adsr(a, d, sus, d)
    .mul(x)
    .mul(1.0)

proc inst1(e: Controls, s: var State): Frame =
  let a = s.atk.min(0.5*e.duration.max(1/64)).min(1/32)
  let x = white_noise().bqhpf(e.note.get, 0.7071).ff(0.5*a, 0.2).bqlpf(2*e.note.get, 0.7071)
  e.gate
    .impulse(a)
    .mul(x)
    .mul(0.8)

proc inst2(e: Controls, s: var State): Frame =
    let x = e.note.get.fm_bl_triangle(1/3, 1/5) + pink_noise().mul(0.1)
    let a = s.atk.min(0.2*e.duration.max(1/64))
    let d = 2*a
    let sus = 0.5
    e.gate
      .adsr(a, d, sus, d)
      .mul(x)
      .mul(1.0)

proc inst3(e: Controls, s: var State): Frame =
  let a = s.atk.min(0.5*e.duration.max(1/64)).min(1/4)
  let x = white_noise().mul(e.note.get.osc).bqlpf(2*e.note.get, 0.7071).ff(0.5*a, 0.25).sin
  e.gate
    .impulse(a)
    .mul(x)
    .mul(2.4)

proc control*(s: var State, cc: var Controllers, n: var Notes, frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  let rest = sound(nil)

  let ch1 = note(//[!c4, [0.0, e4], [0.0, 0, g4]]) >> sound(^inst0)
  let ch2 = note(//[!e4, [0.0, g4], [0.0, 0, c5]]) >> sound(^inst2)

  let p = //[
    --[ch1, rest/23, ch2, rest/23],
    (note([c2, c6, e2, e6, g2, c6, e2, e6]) >> sound([^inst3, ^inst1]*3)) * 6
  ]

  s.cycler.schedule(p, frame_count.to_seconds, 0.1)

proc audio*(s: var State, cc: var Controllers, n: var Notes, input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init

  let cycle_dur = 20.0 * 8.pow(cc/0x1B) # seconds
  s.cycler.tick(cycle_dur.recip)

  s.atk = 4.0/pow(256, cc/0x17)

  let choir = process[var State](s.cycler, s)

  choir
    .add(choir.delay((8/cycle_dur).osc.biscale(0.0, cycle_dur/32)).mul(0.1))
    .ff(cycle_dur.tline(cycle_dur/8), cc/0x1F, s.looong)
    .wp_korg35(c7 - c7.pow(1 - cc/0x3D), 0.95, 1.0)
    .bqnotch_bw(315.0, 0.5)
    .bqnotch_bw(640.0, 1.0)
    .bqhpf(30 + c7.pow(cc/0x39), 0.7071)
    .zita_rev(level = 0)
    .mul(cc/0x3E)
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
