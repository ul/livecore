## Composite processors.
## This module needs a better name.

import frame, envelopes, events, metro, noise

type
  RLine* = object
    metro: Metro
    sh: float
    line: Transition
  FadeOut* = object
    watch: float
    last: float

proc rline*(dt: float, s: var RLine): float =
  white_noise().sh(dt.dmetro(s.metro), s.sh).tline(dt, s.line)
lift1(rline, RLine)

proc rquad*(dt: float, s: var RLine): float =
  white_noise().sh(dt.dmetro(s.metro), s.sh).tquad(dt, s.line)
lift1(rquad, RLine)

proc fadeout*(x: float, trig: float, dt: float, s: var FadeOut): float =
  let k = trig.stopwatch(s.watch)/dt
  if k < 1.0:
    result = k*x + (1.0 - k)*s.last
  else:
    result = x
  s.last = result
lift3(fadeout, FadeOut)
