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

{.experimental: "dotOperators".}
proc `.`(x: int, y: float): Pattern[(int, float)] =
  pure((x, y))

type
  State* = object
    pool: Pool
    cycler: Cycler
    voices: seq[Voice[(int, float)]]
    micro_cycler: Cycler
    parampat: seq[Voice[float]]
    looong: Delay300

proc control*(s: var State, cc: var Controllers, n: var Notes, frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  const o = 0.0
  const x = 1.0

  let O = -1.o

  let ch1 = //[0.c4, --[O, 0.e4], --[O, O, 0.g4]]
  let ch2 = //[2.e4, --[O, 2.g4], --[O, O, 2.c5]]

  let p = //[
    --[ch1, O/23, ch2, O/23],
    --[3.c2, 1.c6, 3.e2, 1.e6, 3.g2, 1.c6, 3.e2, 1.e6] * 6
  ]

  let micro_pat = [!(1/2), 1/3, 2/3].euclid(3, 4)

  s.voices = p.voices(s.cycler)
  s.parampat = micro_pat.voices(s.micro_cycler)

proc audio*(s: var State, cc: var Controllers, n: var Notes, input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  let cycle_dur = 20.0 * 8.pow(cc/0x1B) # seconds
  s.cycler.tick(60.0 / cycle_dur)
  let micro_cycle_dur = 1/32 * cycle_dur * 16.pow(cc/0x13) # seconds
  s.micro_cycler.tick(60.0 / micro_cycle_dur)

  var ppp: float = 0.0
  for v in s.parampat:
    if v.gate(s.micro_cycler) > 0:
      ppp = v.value.tline(1/128)
      break

  let atk = 4.0/pow(256, cc/0x17)

  let instruments = {
    0: proc(note: Note[float]): float =
    let x = note.value.fm_osc(ppp, 1/5) + pink_noise().mul(0.1)
    let a = atk.min(0.2*note.duration.max(1/64))
    let d = 2*a
    let sus = 0.5
    note.gate
      .adsr(a, d, sus, d)
      .mul(x)
      .mul(1.0)
  ,

    1: proc(note: Note[float]): float =
    let a = atk.min(0.5*note.duration.max(1/64)).min(1/32)
    let x = white_noise().bqhpf(note.value, 0.7071).ff(0.5*a, 0.2).bqlpf(2*note.value, 0.7071)
    note.gate
      .impulse(a)
      .mul(x)
      .mul(0.8)
  ,

    2: proc(note: Note[float]): float =
    let x = note.value.fm_bl_triangle(ppp, 1/5) + pink_noise().mul(0.1)
    let a = atk.min(0.2*note.duration.max(1/64))
    let d = 2*a
    let sus = 0.5
    note.gate
      .adsr(a, d, sus, d)
      .mul(x)
      .mul(1.0)
  ,

    3: proc(note: Note[float]): float =
    let a = atk.min(0.5*note.duration.max(1/64)).min(1/4)
    let x = white_noise().mul(note.value.osc).bqlpf(2*note.value, 0.7071).ff(0.5*a, 0.25).sin
    note.gate
      .impulse(a)
      .mul(x)
      .mul(2.4)
  ,
  }

  let choir = s.cycler.sing(s.voices, instruments)

  choir
    .add(choir.delay((8/cycle_dur).osc.biscale(0.0, cycle_dur/32)).bitcrush(8, SAMPLE_RATE / 16).mul(0.1))
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
