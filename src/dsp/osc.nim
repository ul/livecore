## If it cycles enough, it sounds.

import frame, math

when defined(bela):
  proc sinf_neon(x: cfloat): cfloat {.inline, importc: "sinf_neon", header: "libraries/math_neon/math_neon.h".}

proc saw*(freq: float, phase: var float): float =
  result = phase
  phase += 2.0 * freq * SAMPLE_PERIOD
  if unlikely(phase > 1.0):
    phase -= 2.0
  elif unlikely(phase < -1.0):
    phase += 2.0
lift1(saw, float)

when defined(bela):
  proc osc*(freq: float, phase: var float): float = sinf_neon(PI * freq.saw(phase))
else:
  proc osc*(freq: float, phase: var float): float = sin(PI * freq.saw(phase))

lift1(osc, float)

proc tri*(freq: float, phase: var float): float =
  let x = 2.0 * freq.saw(phase)
  if x > 0.0: 1.0 - x else: 1.0 + x
lift1(tri, float)

proc square*(freq, width: float, phase: var float): float =
  if freq.saw(phase) <= width: 1.0 else: -1.0
lift2(square, float)

type FM* = array[2, float]

template fm*(osc) =
  proc `fm osc`*(c, m, i: float, s: var FM): float =
    (c*m).osc(s[0]).mul(i).add(1.0).mul(c).osc(s[1])
  lift3(`fm osc`, FM)

fm(saw)
fm(tri)
fm(osc)

template detune*(osc) =
  proc `detune osc`*(f, r: float, s: var FM): float =
    ((1.0 + r) * f).osc(s[0]) + ((1.0 - r) * f).osc(s[1])
  lift2(`detune osc`, FM)

detune(saw)
detune(tri)
detune(osc)
