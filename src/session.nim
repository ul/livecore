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

proc control*(s: var State, cc: var Controllers, n: var Notes,
    frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  const o = 0.0
  const x = 1.0

  let O = -1.o

  let p = [
    [ 0.c4, O, 2.c5, O, 0.e4, O, 2.e5, O, 0.g4].sequence,
    [ 1.c3, 1.e3, 1.g3 ].struct([o, x, x, x])
  ].poly

  let micro_pat = [!(1/2), 1/4, 1/3, 1/5, 1/4, 1/3].euclid(3, 8)

  s.voices = p.voices(s.cycler)
  s.parampat = micro_pat.voices(s.micro_cycler)

proc audio*(s: var State, cc: var Controllers, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  let cycle_dur = 30.0 * (1.0 + (cc/0x1B)) # seconds
  s.cycler.tick(60.0 / cycle_dur)
  let micro_cycle_dur = 0.01 + 4.0 * (cc/0x13)  # seconds
  s.micro_cycler.tick(60.0 / micro_cycle_dur)

  var ppp: float = 0.0
  for v in s.parampat:
    if v.gate(s.micro_cycler) > 0:
      ppp = v.value.tline(1/128)
      break

  let atk = 1/128 + cc/0x17

  let instruments = {
    0: proc(note: Note): float =
      let x = note.value.fm_osc(1/5, ppp)
      let a = atk.max(0.5*note.duration)
      let d = 0.5*a
      let sus = 0.8
      note.gate
        .adsr(a, d, sus, atk)
        .mul(x)
        .mul(0.7071)
    ,

    1: proc(note: Note): float =
      let x = note.value.osc * note.value.saw
      let a = atk.max(0.5*note.duration)
      note.gate
        .impulse(a)
        .mul(x)
        .mul(2)
    ,

    2: proc(note: Note): float =
      let x = note.value.fm_bl_triangle(1/5, ppp)
      let a = atk.max(0.5*note.duration)
      let d = 0.5*a
      let sus = 0.8
      note.gate
        .adsr(a, d, sus, atk)
        .mul(x)
        .mul(0.7071)
    ,
  }

  let choir = s.cycler.sing(s.voices, instruments)

  choir
    .mul(0.2)
    .fb(cycle_dur.tline(cycle_dur / 16), cc/0x1F, s.looong)
    .bqhpf(30 + c7*(cc/0x39), 0.7071)
    .wp_korg35(c7*(cc/0x3D), 0.95, 1.0)
    .zita_rev(level=0)
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
