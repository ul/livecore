## Where the creativity blossoms.

import
  dsp/[ frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, soundpipe, stereo ],
  math, pool

proc choose(xs: openArray[float], t: float): float =
  xs[white_noise().sh(t).mul(xs.len.float).int]

proc maytrig(t, p: float): float =
  if unlikely(t != 0.0):
    if white_noise() < p:
      return t
  return 0.0
lift2(maytrig)

proc decim(x, p: float): float =
  if white_noise() < p: 0.0 else: x
lift2(decim)

type Conv = array[2, float]

proc conv(x: float, kernel: array[3, float], s: var Conv): float =
  result = kernel[0] * s[0] + kernel[1] * s[1] + kernel[2] * x
  s[0] = s[1]
  s[1] = x

proc conv(x: Frame, kernel: array[3, Frame], s: var array[CHANNELS, Conv]): Frame =
  for i in 0..<CHANNELS:
    result[i] = conv(x[i], [kernel[0][i], kernel[1][i], kernel[2][i]], s[i])

type
  State* = object
    pool: Pool
    cnv: array[2, Conv]

proc process*(s: var State): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init
  let clk = [0.5, 1.0, 2.0].choose(20.dmetro).bpm2freq.saw
  template bt(n: float): float = clk.phsclk(n)
  let
    t1 = [39.0, 42, 45, 48, 51].choose(bt(30.0))
      .tline(0.05)
      .fm(3/2, 3/4) *
      bt(20.0)
      .maygate(0.5)
      .adsr(0.05, 0.2, 0.6, 0.5)
    t2 = [69.0, 81.0, 93].choose(bt(30.0))
      .tline(0.05)
      .sub(24)
      .midi2freq
      .bltriangle
      .mul(bt(40.0).maytrig(0.5).gaussian(0.1, 1.osc.biscale(0.1, 0.2)))
      .decim(0.001)
      .fb((1/12).tri.biscale(1/11, 1/10), 0.5)
      .long_fb(20, 0.7071)
      .wpkorg35(5.osc.biscale(@54, @69), 2.osc.biscale(0.5, 1.0), 0.0)
      .conv([0.1, 0.0, -0.1], s.cnv)
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
