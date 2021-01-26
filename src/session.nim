## Where the creativity blossoms.

import
  dsp/[ frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, soundpipe, stereo ],
  math, pool

type
  State* = object
    pool: Pool

proc process*(s: var State): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init
  let
    clk = 48.rline.to(6, 24).recip.saw
    f1 = [57.0, 63.0, 69.0].sequence(clk.phsclk(5.5)).midi2freq
    f2 = [60.0, 66.0, 72.0].sequence(clk.phsclk(4.5)).midi2freq
    f3 = [66.0, 72.0, 78.0].sequence(clk.phsclk(3.5)).midi2freq
    x = f1.fm(7/3, 1/3) * clk.phsclk(3.0).gaussian(0.35, 0.1)
    y = f2.fm(7/3, 1/3) * clk.phsclk(4.0).gaussian(0.3, 0.1)
    z = f3.fm(7/3, 1/3) * clk.phsclk(5.0).gaussian(0.25, 0.1)
    mix = x + 0.7*y + 0.5*z + 0.15 * @33.blsquare(1.osc.to(0.25, 0.5))
  mix
    .add(0.05 * pink_noise())
    .bigverb(110.tri.mul(1760).osc.to(0.85, 0.95), 10000.0)
    .bqlpf(@93, 0.7071)
    .fb(1/16, 0.5)
    .pan(clk.mul(PI).sin * 0.25)
    .bqhpf(30.0, 0.7071)
    .mul(0.5)
    .saturator

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB) , "MB / Pool: ", int(Pool.size_of/MB), "MB" 
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
