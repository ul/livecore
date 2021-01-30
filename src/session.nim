## Where the creativity blossoms.

import
  dsp/[ frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, soundpipe, stereo ],
  math, pool

proc choose[T](xs: openArray[T], t: float): T =
  xs[white_noise().sh(t).mul(xs.len.float).int]

proc choose[T](xs: openArray[T], t: float, ps: openArray[float]): T =
  var r = white_noise().sh(t) 
  var z = 0.0
  for p in ps: z += p
  var i = 0
  while i < xs.len and i < ps.len:
    let p = ps[i] / z
    if p < r: return xs[i]
    i += 1
    r -= p
  xs[xs.high]

type Osc = proc(freq: float): float  

template ooo(body): Osc = (proc(freq {.inject.}: float): float = body)

proc maytrig(t, p: float): float =
  if unlikely(t > 0.0):
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
    cnv2: array[2, Conv]

proc process*(s: var State): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init
  let clk = 2.0.bpm2freq.saw
  template bt(n: float): float = clk.phsclk(n)
  let
    e = bt(40.0).maytrig(0.5).gaussian(0.05, 55.osc.biscale(0.05, 0.1))
    f = [4.0, 5.0, 6.0].choose(bt(30.0))
      .tline(0.005)
      .mul([0.25, 0.5, 1.0].choose(bt(30.0)))
      .mul(@45)
    t2 = [
      ooo(freq.blsaw.bi),
      ooo(freq.bltriangle.bi),
      ooo(freq.osc)
      ].choose(5.dmetro, [1.0, 2.0, 3.0])(f)
      # ...and waveshaping here
      # .circle.sin
      # .mul(f.osc)
      .mul(e)
      .pan((1/60).osc.mul(1/4))
      .conv([white_noise().lpf(1/20)*0.2, white_noise().lpf(1/20)*0.3, 0.5], s.cnv)
      .fb(1/2,  0.5)
      .bqnotch((1/8).osc.biscale(22, 33).osc.biscale(@33, @69), 1.osc.biscale(0.5, 1.5))
      # .long_fb(20.0, 0.7071)
      .zitarev(level=0)
      # .long_fb(30.0, 0.5)
      .wpkorg35(10000.0, 1.0, 0.0)
      .conv([white_noise().lpf(1/20)*0.1, white_noise().lpf(1/20)*0.2, 0.7], s.cnv2)
    mix = 0.3*t2
  # mix.bqhpf(30.0, 0.7071).compressor(200.0, -12.0, 0.1, 0.1).simple_saturator
  0.1 * 220.osc

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
