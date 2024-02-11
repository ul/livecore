import
  std/[algorithm, options, tables],
  dsp/[frame, osc],
  strudel/core/pattern

type FastTimeSpan = object
  begin*: float
  `end`*: float

type FastHap = object
  span*: FastTimeSpan
  value*: Controls

type Cycler* = object
  cps: float # cycles per second
  phase: float # state for the saw oscillator that maintains the clock
  clock: float # current time in the cycle — not wall-clock time!
  pending_events: seq[FastHap]

converter to_fast_timespan(span: TimeSpan): FastTimeSpan =
  FastTimeSpan(
    begin: span.begin.to_float,
    `end`: span.`end`.to_float
  )

converter to_fast_hap(hap: Hap[Controls]): FastHap =
  FastHap(
    span: hap.whole.get.to_fast_timespan,
    value: hap.value
  )

proc cycle_duration*(s: var Cycler): float = s.cps.recip

proc cycle_time*(s: var Cycler): float = s.clock * s.cycle_duration

proc duration(span: FastTimeSpan): float = span.`end` - span.begin
proc duration(e: FastHap): float = e.span.duration
proc duration[T](e: Hap[T], s: var Cycler): float = e.duration.to_float * s.cycle_duration
proc duration(e: FastHap, s: var Cycler): float = e.duration * s.cycle_duration

proc gate(span: TimeSpan, s: var Cycler): float =
  if span.begin.to_float <= s.clock and s.clock < span.`end`.to_float:
    1.0
  else:
    0.0

proc gate[T](e: Hap[T], s: var Cycler): float = e.whole.get.gate(s)

proc gate(span: FastTimeSpan, s: var Cycler): float =
  if span.begin <= s.clock and s.clock < span.`end`:
    1.0
  else:
    0.0

proc gate(e: FastHap, s: var Cycler): float = e.span.gate(s)

proc tick*(s: var Cycler, cps: float = 0.5) =
  s.cps = cps
  s.clock = cps.saw(s.phase).uni

# TODO Support multicycle patterns.
proc schedule*(s: var Cycler, p: Pattern[Controls], Δt: float, max_cps: float = 10.0, poly: int = 0x20) =
  var voices = init_table[pointer, seq[FastHap]]()
  for hap in p.query(timespan(0, 1)):
    let k = hap.value.sound.get(nil)
    if k.is_nil:
      continue
    if not voices.has_key(k):
      voices[k] = @[]
    voices[k].add(hap.to_fast_hap)

  let clock = s.clock
  # Events that begin during current block must be scheduled first.
  let critical_zone = Δt * max_cps

  func cw_distance(x: float): float =
    let d = x - clock
    if d < 0: d+1 else: d

  func ccw_distance(x: float): float =
    let d = clock - x
    if d < 0: d+1 else: d

  func by_begin(a, b: FastHap): int = cmp(a.span.begin, b.span.begin)
  func by_end_distance(a, b: FastHap): int = cmp(a.span.`end`.ccw_distance, b.span.`end`.ccw_distance)

  s.pending_events.set_len(0)
  for voice in voices.values:
    var selected, candidates: seq[FastHap]
    for e in voice:
      if e.span.begin.cw_distance <= critical_zone:
        selected.add(e)
      elif selected.len < poly:
        candidates.add(e)
    candidates.sort(by_end_distance)
    candidates.set_len(poly - selected.len)
    selected.add(candidates)
    # Less disruption to the pool indexing.
    selected.sort(by_begin)
    s.pending_events.add(selected)

proc process*[T](s: var Cycler, state: T): Frame =
  for e in s.pending_events.mitems:
    if e.value.sound.is_none or e.value.sound.get.is_nil:
      continue
    e.value.duration = e.duration(s)
    e.value.gate = e.gate(s)
    let f = cast[proc(event: Controls, state: T): Frame {.nimcall.}](e.value.sound.get)
    result = result + f(e.value, state)
