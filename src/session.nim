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
  let clk = (1/10).bpm2freq.osc.biscale(1, 1/2).bpm2freq.saw
  template bt(n: float): float = clk.phsclk(n)
  let
    t1 = [45.0, 48, 51][white_noise().sh(bt(30.0)).mul(3).int]
      .tline(0.05)
      .midi2freq
      .fm(7/3, 3/4) *
      bt(20.0)
      .maygate(0.5)
      .adsr(0.1, 0.1, 0.6, 0.25)
    t2 = [69.0, 81.0, 93]
      .sequence(bt(60.0))
      .tline(0.05)
      .midi2freq
      .bltriangle
      .mul(bt(80.0).impulse(0.01))
      .pshift((1/60).osc.mul(2.0), 256, 64)
      .long_fb(20, 0.7071)
    mix = t1.zitarev(level=0.3) + 0.1*t2
  mix.compressor(200.0, -12.0, 0.1, 0.1).simple_saturator

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
