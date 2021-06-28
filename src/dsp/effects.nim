## Various effects which didn't make to other modules.

import frame, math, random

proc simple_saturator*(x: float): float = x / (1.0 + x*x).sqrt
lift1(simple_saturator)

proc decim*(x, p: float): float =
  if rand(1.0) < p: 0.0 else: x
lift2(decim)
