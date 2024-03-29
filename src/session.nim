## Where the creativity blossoms.

import
  std/[atomics, math, options, random],
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
    fdt: int
    fft: array[CHANNELS, FFT4096]

template prolly_echo(p: float, s: varargs[untyped]) =
  if rand(1.0) < p:
    echo s

proc inst0(e: Controls, s: var State): Frame =
  let x = e.note.get(silence).osc * pink_noise().cheb2
  let a = e.attack.get(1/64).tline(0.001).min(0.25*e.duration).max(1/64)
  let d = 2*a
  let sus = 0.5
  e.gate
    .adsr(a, d, sus, d)
    .mul(x)
    .mul(e.gain.get(1.0))

proc inst1(e: Controls, s: var State): Frame =
  let x = e.note.get(silence).fm_osc(1/3, 1/3) * pink_noise().cheb2
  let a = e.attack.get(1/64).tline(0.001).min(0.5*e.duration).max(1/64)
  e.gate
    .impulse(a)
    .mul(x)
    .mul(0.5)
    .mul(e.gain.get(1.0))

proc control*(s: var State, m: var Midi, frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.
  ## Many audio functions can be used here but keep in mind ×frame_count slowdown.

  let a = (frame_count/33).tri.biscale(1/16, 2)
  let b = (frame_count/23).tri.biscale(1/16, 2)
  let c = (frame_count/13).tri.biscale(1/16, 2)

  let insts = [^inst0, ^inst1]

  if rand(1.0) < 0.005:
    s.fdt += 1

  let p1 = [
    note(c4) >> attack(a),
    !Controls(rest: true),
    note([!e4, c5].stack) >> attack(b),
    !Controls(rest: true),
    note([!g4, e5].stack) >> attack(c),
  ]
  let p = p1.euclid(3, 8) >> sound(insts[s.fdt mod insts.len]) >> gain(0.2)
  s.cycler.schedule(p, frame_count.to_seconds, 1.0)

proc audio*(s: var State, m: var Midi, input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.
  s.pool.reset

  let cycle_dur = (1/120).saw.biscale(10.0, 30.0) # seconds
  s.cycler.tick(cycle_dur.recip)

  let k = (m/0x1B)

  let choir = process[var State](s.cycler, s)
    .fadeout(s.fdt.to_float.trig_on_change, 0.01)
    # .wp_korg35(c7, 0.95, 1.0)
    # .bqhpf(100.0, 0.7071)
    # .bqhpf(30.0, 0.7071)
    .ff(( cycle_dur * 4.pow(m/0x13) ).quantize(1/32).tline(1/8), k, s.looong)
    .ff(( cycle_dur * 2 * 4.pow(m/0x17)).quantize(1/16).tline(1/8), k, s.looong) # deliberately reusing delay memory for moar strangeness

  var signal: Frame = choir

  # for i in 0..CHANNELS-1:
  #   signal[i] = choir[i].resynth(s.fft[i]):
  #     for f in synthesis_frequencies.mitems:
  #       f += f.mul(0.5).osc.mul(f/128)
  #     var sum = 0.0
  #     for a in synthesis_magnitudes:
  #       sum += a
  #     prolly_echo(0.001, "sum: ", sum)
  #     if sum > 1000.0:
  #       for a in synthesis_magnitudes.mitems:
  #         a = a.sqrt

  signal
    .wp_korg35(c7, 0.95, 1.0)
    .bqhpf(100.0, 0.7071)
    .bqhpf(30.0, 0.7071)
    .zita_rev(level = 0)
    .simple_saturator
    .dc_block

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  s.pool.init
  sp_create()
  for i in 0..CHANNELS-1:
    s.fft[i].init

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
