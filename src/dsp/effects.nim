## Various effects which didn't make to other modules.

import frame, math

proc simple_saturator*(x: float): float = x / (1.0 + x*x).sqrt
lift1(simple_saturator)
