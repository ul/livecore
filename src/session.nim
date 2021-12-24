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

proc process*(s: var State, cc: var Controls, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init

  let freq = 2.dmetro.step(s.p1).mul(55.0).tline(0.1)
  let sig = 0.14 * freq.osc
  let env = 0.2.metro.impulse(0.1)
  let x = sig.mul(env)
  let kernel = 110.osc.mul(0.02).mul(0.4.metro.impulse(0.05))
  let kernel2 = 2200.tri.mul(0.02).mul(0.3.metro.impulse(0.07))

  x
    .fb(0.1, 0.2)
    .process(pinknoise().decim(0.95).mul(0.05), s.c1)
    .fb(0.125, 0.2)
    .process(pinknoise().decim(0.95).mul(0.05), s.c2)
    .fb(0.15, 0.2)
    .process(kernel2, s.c3)
    .fb(0.2, 0.2)
    .wpkorg35(880.0, 1.0, 0.0)
    .bigverb(0.9, 10000)
    .simple_saturator

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()

  [1.0, 2.5, 3.0, 3.5, 4.0].init(s.p1)
  s.c1.init
  s.c2.init
  s.c3.init

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
