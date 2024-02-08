import std/[options, sequtils, tables]
import dsp/[frame, metro, osc]
import strudel/core/pattern

const cycle* = timespan(0, 1)

type Cycler* = object
  cpm: float
  phase: float
  clock: float

type FastTimeSpan* = object
  begin*: float
  `end`*: float

type FastHap*[T] = object
  span*: FastTimeSpan
  value*: T

type Voice*[T] = object
  spans*: seq[FastTimeSpan]
  value*: T

type Note*[T] = object
  value*: T
  gate*: float
  duration*: float

converter to_fast_timespan*(span: TimeSpan): FastTimeSpan =
  FastTimeSpan(
    begin: span.begin.to_float,
    `end`: span.`end`.to_float
  )

converter to_fast_hap*[T](hap: Hap[T]): FastHap[T] =
  FastHap(
    span: hap.whole.get.to_fast_timespan,
    value: hap.value
  )

proc tick*(s: var Cycler, cpm: float = 60.0) =
  s.cpm = cpm
  s.clock = cpm.bpm2freq.saw(s.phase).uni

proc cycle_duration*(s: var Cycler): float = s.cpm.bpm2delta

proc cycle_time*(s: var Cycler): float = s.clock * s.cycle_duration

proc haps*[T](p: Pattern[T], s: var Cycler): seq[Hap[T]] = p.query(cycle)

proc fast_haps*(p: Pattern[float], s: var Cycler): seq[FastHap] =
  p.haps(s).map_it(it.to_fast_hap)

proc voices*[T](p: Pattern[T], s: var Cycler): seq[Voice[T]] =
  var index = init_table[T, Voice[T]]()
  for hap in p.haps(s):
    let value = hap.value
    if not index.has_key(value):
      index[value] = Voice[T](spans: @[], value: value)
    index[value].spans.add(hap.whole.get.to_fast_timespan)
  index.values.to_seq

proc current_span*(e: Voice, s: var Cycler): FastTimeSpan =
  for span in e.spans:
    if span.begin <= s.clock and s.clock < span.`end`:
      return span
  return FastTimeSpan(begin: 0.0, `end`: 0.0)

proc last_span*(e: Voice, s: var Cycler): FastTimeSpan =
  result = FastTimeSpan(begin: 0.0, `end`: 0.0)
  for span in e.spans:
    if span.begin > s.clock:
      return
    result = span

proc duration*(span: FastTimeSpan): float = span.`end` - span.begin

proc duration*(e: FastHap): float = e.span.duration

proc duration*[T](e: Hap[T], s: var Cycler): float =
  e.duration.to_float * s.cycle_duration

proc duration*(e: FastHap, s: var Cycler): float = e.duration * s.cycle_duration

proc duration*(e: Voice, s: var Cycler): float =
  e.last_span(s).duration * s.cycle_duration

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

proc gate*(e: Voice, s: var Cycler): float = e.current_span(s).gate(s)

proc note*[I, V](e: Voice[tuple[i: I, v: V]], s: var Cycler): Note[V] =
  Note[V](
    value: e.value[1],
    gate: e.gate(s),
    duration: e.duration(s)
  )

proc sing*[I, V](s: var Cycler, voices: seq[Voice[tuple[i: I, v: V]]], instruments: openArray[(I, proc(n: Note[V]): float)]): float =
  for voice in voices:
    for (i, f) in instruments:
      if voice.value[0] == i:
        result += voice.note(s).f
