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
  let clk = 1.bpm2freq.saw
  template bt(n: float): float = clk.phsclk(n)
  let
    t1 = [39.0, 42, 45, 48, 51][white_noise().sh(bt(30.0)).mul(5).int]
      .tline(0.05)
      .fm(3/2, 3/4) *
      bt(20.0)
      .maygate(0.5)
      .adsr(0.05, 0.2, 0.6, 0.5)
    t2 = [69.0, 81.0, 93][white_noise().sh(bt(30.0)).mul(3).int]
      .tline(0.05)
      .sub(24)
      .midi2freq
      .bltriangle
      .mul(bt(40.0).gaussian(0.1, 1.osc.biscale(0.1, 0.2)))
      .fb((1/12).tri.biscale(1/11, 1/10), 0.5)
      .long_fb(20, 0.7071)
      .wpkorg35(5.osc.biscale(@54, @69), 2.osc.biscale(0.5, 1.0), 0.0)
    mix = 0.0*t1.zitarev(level= -10) + 0.3*t2
  mix.bqhpf(30.0, 0.7071).compressor(200.0, -12.0, 0.1, 0.1).simple_saturator

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
