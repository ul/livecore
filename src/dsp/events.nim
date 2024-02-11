## Anything reacting to triggers to produce something discrete/stable.
## This module needs a better name.

import
  std/random,
  delays,
  frame

proc sample_and_hold*(x, t: float, y: var float): float =
  ## Smooth version of sample & hold borrowed from Faust.
  result = (1.0 - t)*y + t*x
  y = result
lift2(sample_and_hold, float)

proc sample_and_hold_sharp*(x, t: float, y: var float): float =
  ## Good ol' sample & hold.
  result = if unlikely(t > 0.0): x else: y
  y = result
lift2(sample_and_hold_sharp, float)

proc sh*(x, t: float, y: var float): float = sample_and_hold(x, t, y)
lift2(sh, float)

proc timer*(s: var float): float =
  result = s
  s += SAMPLE_PERIOD
lift0(timer, float)

proc trig_on_change*(x: float, s: var float): float =
  ## Trigger when `x` changes.
  if unlikely(x != s):
    s = x
    return 1.0
  return 0.0
lift1(trig_on_change, float)

proc stopwatch*(t: float, s: var float): float =
  if unlikely(t > 0.0):
    s = 0.0
  s.timer
lift1(stopwatch, float)

type SH* = array[2, float]

proc zero_cross_up*(x: float, s: var float): float =
  ## Trigger when `x` crosses zero in positive direction.
  if unlikely(x.prime(s) <= 0.0 and x > 0.0): 1.0 else: 0.0
lift1(zero_cross_up, float)

proc sample_and_hold_start*(x, t: float, s: var SH): float =
  ## Sample when trigger crosses zero in positive direction.
  let p = t.prime(s[0])
  result = if unlikely(p <= 0.0 and t > 0.0): x else: s[1]
  s[1] = result
lift2(sample_and_hold_start, SH)

proc sample_and_hold_end*(x, t: float, s: var SH): float =
  ## Sample when trigger crosses zero in negative direction.
  let p = t.prime(s[0])
  result = if unlikely(p > 0.0 and t <= 0.0): x else: s[1]
  s[1] = result
lift2(sample_and_hold_end, SH)

proc sequence*(seq: openArray[float], t: float, s: var int): float =
  if unlikely(t > 0.0):
    s.inc
  if unlikely(s > seq.high):
    s = 0
  result = seq[s]

proc sequence*(seq: openArray[Frame], t: Frame, s: var array[CHANNELS, int]): Frame =
  for ch in 0..<CHANNELS:
    if unlikely(t[ch] > 0.0):
      s[ch].inc
    if unlikely(s[ch] > seq.high):
      s[ch] = 0
    result[ch] = seq[s[ch]][ch]

type Choose* = int

proc choose*[T](xs: openArray[T], t: float, s: var Choose): T =
  if unlikely(t > 0.0):
    s = rand(xs.high)
  xs[s.min(xs.high)]

proc choose*[T](xs: openArray[T], t: float, ps: openArray[float],
    s: var Choose): T =
  if unlikely(t > 0.0):
    var r = rand(1.0)
    var z = 0.0
    for p in ps: z += p
    for i in 0..min(xs.high, ps.high):
      let p = ps[i] / z
      if p < r:
        r -= p
      else:
        s = i
        break
  xs[s.min(xs.high)]

proc maytrig*(t, p: float): float =
  if unlikely(t > 0.0):
    if rand(1.0) < p:
      return t
  return 0.0
lift2(maytrig)

type Event* = object
  trigger*: float
  trigger_time: float
  current_time: float

type EventPool* = array[1024, Event]

proc tick*(e: var Event, step: float = 1) =
  if unlikely(e.trigger > 0.0):
    e.trigger = 0.0
  if unlikely(e.current_time >= e.trigger_time):
    e.trigger = 1.0
  e.current_time += step * SAMPLE_PERIOD

proc tick*(pool: var EventPool, step: float = 1) =
  for e in pool.mitems:
    e.tick(step)

proc triggered*(e: Event): bool = e.trigger > 0.0

proc schedule*(e: var Event, seconds: float) =
  e.trigger_time = e.current_time + seconds

proc schedule*(e: var Event, after: Event, seconds: float) =
  e.trigger_time = after.trigger_time + seconds

template repeat*(e: var Event, body: float) =
  if e.triggered:
    let x = body
    e.schedule(x)
