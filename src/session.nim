## Where the creativity blossoms.

import
  dsp/[ frame, delays, effects, envelopes, events, filters, metro, modules,
        nanotidal, noise, osc, sampler, soundpipe, stereo, fft ],
  atomics, math, pool, control

defSampler(10)

type
  State* = object
    pool: Pool
    fft: FFT1024
    table: Sampler10

proc process*(s: var State, cc: var Controls, n: var Notes): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init
  var x = 0.0
  for i in 1..5:
    let m = (i.float/10.0).add(rquad(5.0).scale(-0.1, 0.1)).metro
    x += 55.0.mul(i.float)
    .blsaw
    .mul(m.impulse(0.1 + whitenoise().sh(m).scale(-0.05, 0.05)))

  let k = pink_noise() * pink_noise()

  let z = process(x, s.fft):
    for i in 0..<s.fft.bins:
      s.fft.synthesis_magnitudes[i] = s.fft.analysis_magnitudes[i].fb(0.1*16/1024, 0.65)
      s.fft.synthesis_frequencies[i] = s.fft.analysis_frequencies[i].add(k.mul(0.26))

  discard (z+x.fb(0.1, 0.65)).wti((1/10).saw.add((1/9).osc.mul(0.01)).mul(0.5).uni, s.table)

  discard (0.05 + pink_noise().mul(0.01)).saw.uni.rt(s.table).wti((1/20).osc.uni, s.table)
  0.012.saw.uni.rt(s.table)
    .mul(0.2)
    .zitarev(level=0)
    .simple_saturator

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB) , "MB / Pool: ", int(Pool.size_of/MB), "MB" 
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()
  s.table.length = 10.seconds
  s.fft.init

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
