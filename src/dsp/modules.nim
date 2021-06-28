## Composite processors.
## This module needs a better name.

import frame, envelopes, events, metro, noise

type
  RLine* = object
    metro: Metro
    sh: float
    line: Transition

proc rline*(dt: float, s: var RLine): float =
  white_noise().sh(dt.dmetro(s.metro), s.sh).tline(dt, s.line)
lift1(rline, RLine)

proc rquad*(dt: float, s: var RLine): float =
  white_noise().sh(dt.dmetro(s.metro), s.sh).tquad(dt, s.line)
lift1(rquad, RLine)
