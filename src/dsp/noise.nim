## White, pink, brown...

import frame, random

proc white_noise*(): float = rand(0.0..1.0)
lift0(white_noise)

type ChaosNoise* = object
    y: array[2, float]
    phs: float

proc chaos_noise*(rate, chaos: float, s: var ChaosNoise): float =
  ## https://pbat.ch/sndkit/chaosnoise/
  ## Keep `chaos` in [1, 2]
  s.phs += rate * SAMPLE_PERIOD
  if unlikely(s.phs >= 1.0):
    s.phs -= 1.0
    let y = abs(chaos * s.y[0] - s.y[1] - 0.05)
    s.y[1] = s.y[0]
    s.y[0] = y
  result = s.y[0].bi
lift2(chaos_noise, ChaosNoise)
