import
  std/[options],
  dsp/[frame, osc],
  strudel/core/pattern

type FastTimeSpan* = object
  begin*: float
  `end`*: float

type FastHap* = object
  span*: FastTimeSpan
  value*: Controls

# TODO Support multicycle patterns.
type Cycler* = object
  cps: float # cycles per second
  phase: float # state for the saw oscillator that maintains the clock
  clock: float # current time in the cycle — not wall-clock time!
  pending_events_cursor: int
  pending_events: array[0x100, FastHap] # TODO warn on overflow

converter to_fast_timespan*(span: TimeSpan): FastTimeSpan =
  FastTimeSpan(
    begin: span.begin.to_float,
    `end`: span.`end`.to_float
  )

converter to_fast_hap*(hap: Hap[Controls]): FastHap =
  FastHap(
    span: hap.whole.get.to_fast_timespan,
    value: hap.value
  )

proc tick*(s: var Cycler, cps: float = 0.5) =
  s.cps = cps
  s.clock = cps.saw(s.phase).uni

proc cycle_duration*(s: var Cycler): float = s.cps.recip

proc cycle_time*(s: var Cycler): float = s.clock * s.cycle_duration

proc duration*(span: FastTimeSpan): float = span.`end` - span.begin
proc duration*(e: FastHap): float = e.span.duration
proc duration*[T](e: Hap[T], s: var Cycler): float = e.duration.to_float * s.cycle_duration
proc duration*(e: FastHap, s: var Cycler): float = e.duration * s.cycle_duration

proc gate*(span: TimeSpan, s: var Cycler): float =
  if span.begin.to_float <= s.clock and s.clock < span.`end`.to_float:
    1.0
  else:
    0.0

proc gate*[T](e: Hap[T], s: var Cycler): float = e.whole.get.gate(s)

proc gate*(span: FastTimeSpan, s: var Cycler): float =
  if span.begin <= s.clock and s.clock < span.`end`:
    1.0
  else:
    0.0

proc gate*(e: FastHap, s: var Cycler): float = e.span.gate(s)

proc schedule*(s: var Cycler, p: Pattern[Controls]) =
  s.pending_events_cursor = 0
  for hap in p.query(timespan(0, 1)):
    let fast_hap = hap.to_fast_hap
    s.pending_events[s.pending_events_cursor] = fast_hap
    s.pending_events_cursor.inc

# TODO Need a way to short-circuit instruments so they don't waste cycles.
# Just returning silence on gate off doesn't work due to release and other effects.
# Might do some kind of managed limited polyphony? E.g. a pool of 0x10 FIFO voices per instrument.
proc process*(s: var Cycler, state: pointer): Frame =
  for i in 0..(s.pending_events_cursor - 1):
    var e = s.pending_events[i]
    if e.value.sound.is_none or e.value.sound.get.is_nil:
      continue
    e.value.duration = e.duration(s)
    e.value.gate = e.gate(s)
    let f = cast[proc(event: Controls, state: pointer): Frame {.nimcall.}](e.value.sound.get)
    result = result + f(e.value, state)
