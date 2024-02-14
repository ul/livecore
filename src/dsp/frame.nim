## Fundamental audio frame constants, types and operations.

import std/[atomics, math]

const SAMPLE_RATE_INT* = 48000

const
  CHANNELS* = 2
  SAMPLE_RATE* = SAMPLE_RATE_INT.float
  SAMPLE_PERIOD* = 1.0 / SAMPLE_RATE
  SAMPLE_ANGULAR_PERIOD* = TAU * SAMPLE_PERIOD

proc seconds*(t: Natural): Natural =
  t * SAMPLE_RATE_INT

proc seconds*(t: float): float =
  t * SAMPLE_RATE

proc to_seconds*(samples: float): float =
  samples * SAMPLE_PERIOD

proc to_seconds*(samples: Natural): float =
  samples.to_float.to_seconds

type
  Frame* = array[CHANNELS, float]
  Midi* = array[0x100, Atomic[float]]

converter to_frame*(x: float): Frame =
  for i in 0..<CHANNELS:
    result[i] = x

converter to_frames*[N](xs: array[N, float]): array[N, Frame] =
  for i in xs.low..xs.high:
    result[i] = xs[i].to_frame

template lift0*(op) =
  proc `op stereo`*(): Frame =
    for i in 0..<CHANNELS:
      result[i] = op()

template lift1*(op) =
  proc op*(a: Frame): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i])

template lift2*(op) =
  proc op*(a, b: Frame): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i])

template lift3*(op) =
  proc op*(a, b, c: Frame): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i], c[i])

template lift4*(op) =
  proc op*(a, b, c, d: Frame): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i], c[i], d[i])

template lift5*(op) =
  proc op*(a, b, c, d, e: Frame): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i], c[i], d[i], e[i])

template lift1_as*(op, name) =
  proc name*(a: Frame): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i])

template lift2_as*(op, name) =
  proc name*(a, b: Frame): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i])

template lift3_as*(op, name) =
  proc name*(a, b, c: Frame): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i], c[i])

template lift0*(op: untyped, T: typedesc) =
  proc op*(s: var array[CHANNELS, T]): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(s[i])

template lift1*(op: untyped, T: typedesc) =
  proc op*(a: Frame, s: var array[CHANNELS, T]): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], s[i])

template lift2*(op: untyped, T: typedesc) =
  proc op*(a, b: Frame, s: var array[CHANNELS, T]): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i], s[i])

template lift3*(op: untyped, T: typedesc) =
  proc op*(a, b, c: Frame, s: var array[CHANNELS, T]): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i], c[i], s[i])

template lift4*(op: untyped, T: typedesc) =
  proc op*(a, b, c, d: Frame, s: var array[CHANNELS, T]): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i], c[i], d[i], s[i])

template lift5*(op: untyped, T: typedesc) =
  proc op*(a, b, c, d, e: Frame, s: var array[CHANNELS, T]): Frame =
    for i in 0..<CHANNELS:
      result[i] = op(a[i], b[i], c[i], d[i], e[i], s[i])

proc safe_div(a: float, b: float): float =
  if unlikely(b == 0.0):
    result = 0.0
  else:
    result = a / b

proc safe_mod(a: float, b: float): float =
  if unlikely(b == 0.0):
    result = 0.0
  else:
    result = a mod b

proc mul*(a, b: float): float = a * b
proc add*(a, b: float): float = a + b
proc sub*(a, b: float): float = a - b
proc neg*(a: float): float = -a

lift2(`*`)
lift2(mul)

lift2(`+`)
lift2(add)

lift1(`-`)
lift1(neg)
lift2(`-`)
lift2(sub)

lift2_as(safe_div, `/`)
lift2_as(safe_div, `div`)

lift2_as(safe_mod, `%`)
lift2_as(safe_mod, `mod`)

lift1(sin)
lift1(cos)
lift1(tan)
lift1(ceil)
lift1(floor)
lift1(round)
lift1(log2)
lift1(log10)
lift2(pow)
lift1(sqrt)
lift1(exp)

proc sinc*(x: float): float =
  if unlikely(x == 0.0): 1.0 else: sin(x)/x

lift1(sinc)

proc project*(x, a, b, c, d: float): float = (d - c) * (x - a) / (b - a) + c
proc scale*(x, a, b: float): float = x.project(0.0, 1.0, a, b)
proc biscale*(x, a, b: float): float = x.project(-1.0, 1.0, a, b)
proc circle*(x: float): float = x.biscale(-PI, PI)
proc uni*(x: float): float = x.biscale(0.0, 1.0)
proc bi*(x: float): float = x.scale(-1.0, 1.0)

proc db2amp*(x: float): float = 20.0 * x.log10
proc amp2db*(x: float): float = 10.0.pow(x / 20.0)

proc freq2midi*(x: float): float = 69.0 + 12.0 * log2(x / 440.0)
proc midi2freq*(x: float): float = 440.0 * 2.0.pow((x - 69.0) / 12.0)

proc quantize*(x, step: float): float = (x / step).round * step
proc step*(x, step: float): float = x.quantize(step)

proc recip*(x: float): float = 1.0 / x

lift5(project)
lift3(scale)
lift3(biscale)
lift1(circle)
lift1(uni)
lift1(bi)
lift1(db2amp)
lift1(amp2db)
lift1(freq2midi)
lift1(midi2freq)
lift2(quantize)
lift2(step)
lift1(recip)

proc `@`*(x: float): float = midi2freq(x)
lift1(`@`)

proc `%%`*(x, y: float): float = quantize(x, y)
lift2(`%%`)

const silence* = 0.0

func hush*(x: float): float = 0.0
lift1(hush)

template `^`*(x: untyped): pointer =
  cast[pointer](x)

func cheb2*(x: float): float =
  ## T_2(x) = 2x^2 - 1
  2.0*x*x - 1.0

func cheb3*(x: float): float =
  ## T_3(x) = 4x^3 - 3x
  4.0*x*x*x - 3.0*x

func cheb4*(x: float): float =
  ## T_4(x) = 8x^4 - 8x^2 + 1
  8.0*x*x * (x*x - 1.0) + 1.0

func cheb5*(x: float): float =
  ## T_5(x) = 16x^5 - 20x^3 + 5x
  let x2 = x*x
  let x3 = x2*x
  16.0*x3*x2 - 20.0*x3 + 5.0*x

func cheb6*(x: float): float =
  ## T_6(x) = 32x^6 - 48x^4 + 18x^2 - 1
  let x2 = x*x
  let x4 = x2*x2
  32.0*x4*x2 - 48.0*x4 + 18.0*x2 - 1.0

func cheb7*(x: float): float =
  ## T_7(x) = 64x^7 - 112x^5 + 56x^3 - 7x
  let x2 = x*x
  let x3 = x2*x
  let x5 = x3*x2
  let x7 = x5*x2
  64.0*x7 - 112.0*x5 + 56.0*x3 - 7.0*x

func cheb8*(x: float): float =
  ## T_8(x) = 128x^8 - 256x^6 + 160x^4 - 32x^2 + 1
  let x2 = x*x
  let x4 = x2*x2
  let x6 = x4*x2
  let x8 = x4*x4
  128.0*x8 - 256.0*x6 + 160.0*x4 - 32.0*x2 + 1.0

func cheb9*(x: float): float =
  ## T_9(x) = 256x^9 - 576x^7 + 432x^5 - 120x^3 + 9x
  let x2 = x*x
  let x3 = x2*x
  let x5 = x3*x2
  let x7 = x5*x2
  let x9 = x7*x2
  256.0*x9 - 576.0*x7 + 432.0*x5 - 120.0*x3 + 9.0*x

lift1(cheb2)
lift1(cheb3)
lift1(cheb4)
lift1(cheb5)
lift1(cheb6)
lift1(cheb7)
lift1(cheb8)
lift1(cheb9)
