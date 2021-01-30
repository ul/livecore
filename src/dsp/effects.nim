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
