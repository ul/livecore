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
  let clk = (1/2).bpm2freq.saw
  template bt(n: float): float = clk.phsclk(n)
  let
    e = bt(40.0).maytrig(0.5).gaussian(0.1, 11.osc.biscale(0.05, 0.15))
    f = [4.0, 5.0, 6.0].choose(bt(30.0))
      .tline(0.025)
      .mul([0.25, 0.5, 1.0].choose(bt(30.0)))
      .mul(@33)
    t1 = [f.blsaw, f.bltriangle, f.osc]
      .choose(7.dmetro, [1.0, 2.0, 3.0])
      .mul(e)
      .pan((1/60).osc.mul(1/4))
      .fb((1/4).tri.biscale(0.04, 0.05), 0.2)
      .conv(white_noise().bi.lpf(1/20)*0.1, white_noise().bi.lpf(1/20)*0.2, 0.9)
      .fb(1/2,  0.5)
      .bqnotch((1/8).osc.biscale(11, 22).osc.biscale(@33, @69), 0.7071)
      .long_fb(7.0, 0.5)
      .long_fb(13.0, 0.5)
      .long_fb(21.0, 0.5)
      .long_fb(30.0, 0.5)
      .wpkorg35(@81, 1.0, 0.0)
      .conv(white_noise().bi.lpf(1/20)*0.1, white_noise().bi.lpf(1/20)*0.2, 0.9)
      .conv(white_noise().bi.lpf(1/20)*0.1, white_noise().bi.lpf(1/20)*0.2, 0.9)
      .fb((1/8).tri.biscale(0.1, 0.2), 0.2)
      .zitarev(level=0)
    mix = 0.3*t1
  mix.bqhpf(30.0, 0.7071).compressor(20.0, -12.0, 0.1, 0.1).simple_saturator

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
