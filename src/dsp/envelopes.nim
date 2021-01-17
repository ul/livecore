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
  proc name*(x, delta: float, s: var Transition): float =
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

proc impulse*(trigger, apex: float, s: var float): float =
  let h = trigger.stopwatch(s) / apex
  h * exp(1.0 - h)
lift2(impulse, float)

proc gaussian*(trigger, apex, deviation: float, s: var float): float =
  let delta = trigger.stopwatch(s) - apex
  result = exp(-0.5 * delta * delta / deviation)
lift3(gaussian, float)

type ADSR* = object
    time: float
    start: SH
    stop: SH

proc adsr*(t, a, d, s, r: float, p: var ADSR): float =
  let time = timer(p.time)
  let start = time.sample_and_hold_start(t, p.start)
  let stop = time.sample_and_hold_end(t, p.stop)
  var delta = time - start

  if delta <= a:
    return delta / a

  delta -= a
  if delta <= d:
    return 1.0 - (1.0 - s) * delta / d

  if start > stop:
    return s

  delta = time - max(start + a + d, stop)

  if delta <= r:
    return s * (1.0 - delta / r)

  return 0.0
lift5(adsr, ADSR)
