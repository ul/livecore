## Various effects which didn't make to other modules.

import frame, math, random

proc simple_saturator*(x: float): float = x / (1.0 + x*x).sqrt
lift1(simple_saturator)

proc decim*(x, p: float): float =
  if rand(1.0) < p: 0.0 else: x
lift2(decim)

type Conv* = array[2, float]

proc conv*(x, k0, k1, k2: float, s: var Conv): float =
  result = k0 * s[0] + k1 * s[1] + k2 * x
  s[0] = s[1]
  s[1] = x
lift4(conv, Conv)

proc gaussian_kernel*[N: static[Natural]](): array[N, float] =
  var s = 0.0
  for i in 0..<N:
    let k = exp(-0.5 * (i^2).float)
    s += k
    result[i] = k
  for i in 0..<N:
    result[i] /= s

proc conv*[N: static[Natural]](x : float, kernel: array[N, float], s: var array[N, float]): float =
  for i in 1..<N:
    s[i] = s[i-1]
  s[0] = x
  for i in 0..<N:
    result += kernel[i] * s[i]
