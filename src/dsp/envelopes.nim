## Envelope generators.

import frame, math, events

type
  Transition* = object
    previous_value: float
    current_value: float
    next_value: float
    start: int
    frame: int

template transition(name; curve: proc(a, dx: float): float) =
  proc name*(x, delta: float; s: var Transition): float =
    if unlikely(x != s.next_value):
      s.previous_value = s.current_value
      s.next_value = x
      s.start = s.frame
    let dt = (s.frame - s.start).float * SAMPLE_PERIOD
    if delta > 0.0 and dt < delta:
      result = s.previous_value + curve(dt / delta, x - s.previous_value)
    else:
      result = x
    s.current_value = result
    s.frame += 1
  lift2(name, Transition)

proc linear_curve(a, dx: float): float =
  a * dx

proc quadratic_curve(a, dx: float): float =
  a.pow(4.0) * dx

transition(tline, linear_curve)
transition(tquad, quadratic_curve)

proc impulse*(trigger, apex: float; s: var float): float =
  let h = trigger.stopwatch(s) / apex
  h * exp(1.0 - h)
lift2(impulse, float)

proc gaussian*(trigger, apex, deviation: float; s: var float): float =
  let delta = trigger.stopwatch(s) - apex
  result = exp(-0.5 * delta * delta / deviation)
lift3(gaussian, float)

type
  ADSRState = enum
    # We declare Release first so it has value 0 as we rely on alloc0 for memory
    # initialization rather setting initial state explicitly.
    Release, Attack, Decay, Sustain
  ADSR* = object
    time: float
    state: ADSRState

proc adsr*(t, a, d, s, r: float; p: var ADSR): float =
  case p.state
  of ADSRState.Attack:
    if p.time < a:
      result = p.time / a
      p.time += SAMPLE_PERIOD
    else:
      p.time = 0.0
      p.state = ADSRState.Decay
      result = 1.0
  of ADSRState.Decay:
    if p.time < d:
      result = 1.0 - (1.0 - s) * p.time / d
      p.time += SAMPLE_PERIOD
    else:
      p.time = 0.0
      p.state = ADSRState.Sustain
      result = s
  of ADSRState.Sustain:
    result = s
    if t <= 0.0:
      p.time = 0.0
      p.state = ADSRState.Release
  of ADSRState.Release:
    if p.time < r:
      result = s * (1.0 - p.time / r)
      p.time += SAMPLE_PERIOD
    else:
      result = 0.0
      if t > 0.0:
        p.time = 0.0
        p.state = ADSRState.Attack
lift5(adsr, ADSR)
