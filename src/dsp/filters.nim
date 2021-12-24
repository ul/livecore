## Filters. Nuff said.

import frame, math, delays

proc lpf*(x, freq: float, s: var float): float =
  ## Simple IIR filter from Wikipedia
  let
    k = freq * SAMPLE_ANGULAR_PERIOD
    a = k / (k + 1.0)
  result = s + a*(x - s)
  s = result
lift2(lpf, float)

type HPF* = array[2, float]

proc hpf*(x, freq: float, s: var HPF): float =
  ## Simple IIR filter from Wikipedia
  let
    k = freq * SAMPLE_ANGULAR_PERIOD
    a = 1.0 / (k + 1.0)
  result = a*(s[0] + x - x.prime(s[1]))
  s[0] = result
lift2(hpf, HPF)

# BiQuad filter based on Audio-EQ-Cookbook.txt

type
  BiQuad* = object
    xx, xxx, yy, yyy: float
  BiQuadCoeffs = (float, float, float, float, float, float)

template make_bi_quad(name; make_coefficients: proc(sinω, cosω,
    α: float): BiQuadCoeffs) =
  proc name*(x, freq, Q: float, s: var BiQuad): float =
    let
      xx = x.prime(s.xx)
      xxx = xx.prime(s.xxx)
      ω = freq * SAMPLE_ANGULAR_PERIOD
      sinω = ω.sin
      cosω = ω.cos
      α = sinω / (2.0 * Q)
      (b0, b1, b2, a0, a1, a2) = make_coefficients(sinω, cosω, α)
      y = (b0*x + b1*xx + b2*xxx - a1*s.yy - a2*s.yyy) / a0
    s.yyy = s.yy
    s.yy = y
    y
  lift3(name, BiQuad)

proc make_lpf_coefficients(sinω, cosω, α: float): BiQuadCoeffs =
  let
    b1 = 1.0 - cosω
    b0 = 0.5 * b1
  (b0, b1, b0, 1.0 + α, -2.0*cosω, 1.0 - α)

proc make_hpf_coefficients(sinω, cosω, α: float): BiQuadCoeffs =
  let
    k = 1.0 + cosω
    b0 = 0.5 * k
  (b0, -k, b0, 1.0 + α, -2.0*cosω, 1.0 - α)

proc make_bpf_coefficients(sinω, cosω, α: float): BiQuadCoeffs =
  (α, 0.0, -α, 1.0 + α, -2.0*cosω, 1.0 - α)

proc make_notch_coefficients(sinω, cosω, α: float): BiQuadCoeffs =
  (1.0, -2.0*cosω, 1.0, 1.0 + α, -2.0*cosω, 1.0 - α)

make_bi_quad(bqlpf, make_lpf_coefficients)
make_bi_quad(bqhpf, make_hpf_coefficients)
make_bi_quad(bqbpf, make_bpf_coefficients)
make_bi_quad(bqnotch, make_notch_coefficients)

type Conv* = array[2, float]

proc conv*(x, k0, k1, k2: float, s: var Conv): float =
  result = k0 * s[0] + k1 * s[1] + k2 * x
  s[0] = s[1]
  s[1] = x
lift4(conv, Conv)

proc iir*[NX, NY: static[Natural]](x: float, a: array[NY, float], b: array[NX,
    float], s: var array[NX+NY-1, float]): float =
  for i in countdown(NX-1, 1):
    s[i] = s[i-1]
  s[0] = x
  for i in 0..<NX:
    result += b[i] * s[i]
  for i in 0..<NY:
    result += a[i] * s[NX+i]
  for i in countdown(NX+NY-1, NX+1):
    s[i] = s[i-1]
  s[NX] = result
