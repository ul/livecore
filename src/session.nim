## Where the creativity blossoms.

import
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        nanotidal, noise, osc, sampler, soundpipe, stereo, fft, patterns, fir,
        conv],
  atomics, math, pool, control, random

type
  State* = object
    pool: Pool
    phase1: float
    fft: FFT1024

proc process*(s: var State, cc: var Controls, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init
  var x = 0.0
  for i in 1..5:
    x += 55.0.mul(i.to_float)
    .add(white_noise().lpf(50.0).scale(-5.5, 5.5))
    .blsaw
    .mul((i.to_float/2.0).metro.impulse(0.1))

  let k = 0.2 * pink_noise()

  let z = process(x, s.fft):
    for i in 0..<s.fft.bins:
      s.fft.synthesis_magnitudes[i] = (1.0-k)*s.fft.synthesis_magnitudes[i] + k*s.fft.analysis_magnitudes[i]
      s.fft.synthesis_frequencies[i] = (1.0-k)*s.fft.synthesis_frequencies[i] + k*s.fft.analysis_frequencies[i]
  z
    .simple_saturator

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()
  s.fft.init


# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
