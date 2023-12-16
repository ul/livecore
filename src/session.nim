## Where the creativity blossoms.

import
  std/[atomics, math, options],
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, sampler, soundpipe, stereo, fft, fir, conv, notes],
  strudel/core/pattern,
  cycler, pool, control

defDelay(300)


type Instrument = enum
  Silence, Sine, Triangle, Square

converter to_pattern*(value: (Instrument, float)): Pattern[(Instrument, float)] = pure(value)

proc `*`(x: (Instrument, float), y: float): (Instrument, float) =
  (x[0], x[1]*y)

proc `*`(x: float, y: (Instrument, float)): (Instrument, float) =
  (y[0], x*y[1])


type
  State* = object
    pool: Pool
    cycler: Cycler
    voices: seq[Voice[(Instrument, float)]]

proc control*(s: var State, cc: var Controllers, n: var Notes,
    frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  const o = 0.0
  const x = 1.0
  const O = (Silence, o)

  const e = 8

  let p = [
    ([(Sine, c4).pure, (Triangle, e4), (Sine, g4)].euclid(3, e) * 6).struct([x, o, x, x, o, o, x, x, x, x, o, o]),
    [(Sine, c3).pure, (Triangle, e3), (Sine, g3)].euclid(3, e) * 2
  ].stack

  s.voices = p.voices(s.cycler)

proc audio*(s: var State, cc: var Controllers, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  s.cycler.tick(20)

  let atk = 1/32

  let instruments = {
    Sine: proc(note: Note): float =
      let x = note.value.fm_osc(1/2, 2/3)
      let a = atk.max(0.5*note.duration)
      let d = 0.5*a
      let sus = 0.8
      note.gate
        .adsr(a, d, sus, atk)
        .mul(x)
    ,

    Triangle: proc(note: Note): float =
      let x = note.value.fm_bltriangle(1/2, 2/3)
      let a = atk.max(0.5*note.duration)
      let d = 0.5*a
      let sus = 0.8
      note.gate
        .adsr(a, d, sus, atk)
        .mul(x)
        .mul(1.2)
    ,

    Square: proc(note: Note): float =
      let x = note.value.blsquare(0.5)
      let a = atk.max(0.5*note.duration)
      let d = 0.5*a
      let sus = 0.8
      note.gate
        .adsr(a, d, sus, atk)
        .mul(x)
        .mul(0.4)
    ,

    Silence: proc(note: Note): float {.closure.} =
      0.0
    ,
  }

  let choir = s.cycler.sing(s.voices, instruments)

  choir
    .mul(0.1)
    # .long_fb(12, 0.5)
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
