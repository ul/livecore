## Where the creativity blossoms.

import
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        nanotidal, noise, osc, sampler, soundpipe, stereo, fft, patterns, fir,
        conv],
  atomics, math, pool, control

type
  State* = object
    pool: Pool
    p1: PSeq
    c1: Conv1024x64
    c2: Conv8192x64
    c3: Conv8192x64
    c4: Conv8192x64
    eff1: HiliteSdH04Reverb
    eff2: AyotteSdH06Reverb
    eff3: HandDhalReverb

proc process*(s: var State, cc: var Controls, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init

  let freq1 = 2.dmetro.step(s.p1).mul(55.0).tline(0.1)
  let sig = 0.14 * freq1.osc
  let freq2 = (sig.uni * 2).dmetro.step(s.p1).mul(0.1).tline(0.1)
  let freq3 = (sig.uni).dmetro.step(s.p1).mul(55).tline(0.1)
  let env = (sig.uni * 0.2).metro.impulse(0.1)
  let x = sig.mul(env)
  let kernel = freq3.saw.mul(0.02).mul(freq2.dmetro.impulse(0.05))
  let kernel2 = (freq3.tri * 2200.tri.mul(0.02).mul(0.3.metro.impulse(0.07)))
  let patt_a = @![1/4, 1/4, 1/3, 1/3, 1/3, 1/2, 4.0]
  let patt_b = @![1/8, 1/8, 1/8, 1/8, 1/3, 1/3, 1/3, 1/2, 2.0]
  let patt_c = @![1/8, 1/8, 1/8, 1/8, 4.0]
  let patt_d = @![1/16, 1/16, 1/8, 1/16, 1/16, 1/8, 8.0]
  let patt_e = @~[patt_a, patt_b]
  let patt_f = @~[patt_c, patt_e]
  let patt_g = @~[patt_d, patt_f]
  let patt_h = @~[patt_e, patt_f, patt_g, patt_a]
  let patt_i = @~[patt_e, patt_f, patt_g, patt_h]
  let period1 = patt_h.sample((1/32).saw.uni)[0]
  let period2 = patt_g.sample((1/32).saw.uni)[0]
  let period3 = patt_i.sample((1/32).saw.uni)[0]

  let b1 = freq3.osc.mul(0.5).mul(period1.dmetro.impulse(0.003)).process(s.eff1).mul(0.05).bqlpf(5000, 0.9).simple_saturator
  let b2 = pinknoise().bqhpf(3000, 0.98).mul(0.2).mul(period2.dmetro.impulse(0.001)).process(s.eff2).mul(1.5)
  let b3 = whitenoise().bqhpf(4000, 0.89).mul(0.2).mul(period3.dmetro.impulse(period1*period1*0.08)).process(s.eff3)

  let beat = (b1 + b2 + b3).compressor(3.0, -3.0, 0.1, 0.1)

  let texture = x
    .fb(0.1, 0.2)
    .process(kernel, s.c1)
    .fb(0.15, 0.2)
    .process(pinknoise().decim(0.95).mul(0.05), s.c2)
    .fb(0.125, 0.2)
    .process(kernel2, s.c3)
    .fb(0.2, 0.2)
    .wpkorg35(440.0, 0.01.osc.uni*0.5+0.2, 0.0125.osc.uni*0.5+0.5)
    .bigverb(0.75, 10000)
    .simple_saturator

  (texture.mul(0.3) + beat.mul(0.3))
    .compressor(1.7, -3.0, 0.05, 0.05)
    .simple_saturator


# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()
  nanotidal_create()

  [1.0, 2.5, 3.0, 3.5, 4.0].init(s.p1)
  s.c1.init
  s.c2.init
  s.c3.init
  s.c4.init
  s.eff1.init
  s.eff2.init
  s.eff3.init

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
  nanotidal_destroy()
