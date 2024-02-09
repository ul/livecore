import std/[options, sugar]
import timespan
export timespan

type Hap*[T] = object
  ## Event class, representing a value active during the timespan 'part'. This
  ## might be a fragment of an event, in which case the timespan will be smaller
  ## than the 'whole' timespan, otherwise the two timespans will be the same.
  ## The 'part' must never extend outside of the 'whole'. If the event
  ## represents a continuously changing value then the whole will be returned as
  ## None, in which case the given value will have been sampled from the point
  ## halfway between the start and end of the 'part' timespan.  The context is
  ## to store a list of source code locations causing the event.
  ## The word 'Event' is more or less a reserved word in javascript, hence this
  ## class is named called 'Hap'.

  whole*: Option[TimeSpan]
  part*: TimeSpan
  value*: T

func duration*(e: Hap): Fraction = e.whole.get.duration

func whole_or_part*(e: Hap): TimeSpan =
  if e.whole.is_some: e.whole.get else: e.part

proc with_span*(e: Hap, f: TimeSpan -> TimeSpan): Hap =
  Hap(whole: e.whole.map(f), part: f(e.part), value: e.value)

proc with_value*[T, U](e: Hap[T], f: T -> U): Hap[U] =
  Hap[U](whole: e.whole, part: e.part, value: f(e.value))

when isMainModule:
  import std/unittest
  suite "Hap":
    test "duration":
      let span = TimeSpan(begin: 1//2, `end`: 3//2)
      let e = Hap[float](whole: some(span), part: span, value: 1.0)
      check e.duration == 1
    test "whole_or_part":
      let span = TimeSpan(begin: 1//2, `end`: 3//2)
      let e = Hap[float](whole: some(span), part: span, value: 1.0)
      check e.whole_or_part == span
      let e2 = Hap[float](whole: none[TimeSpan](), part: span, value: 1.0)
      check e2.whole_or_part == span
    test "with_span":
      let span = TimeSpan(begin: 1//2, `end`: 3//2)
      let e = Hap[float](whole: some(span), part: span, value: 1.0)
      let e2 = e.with_span(x => x.with_time(x => x + 1))
      check e2.whole == some(e.whole.get.with_time(x => x + 1))
      check e2.part == e.part.with_time(x => x + 1)
      check e2.value == e.value
      let e3 = Hap[float](whole: none[TimeSpan](), part: span, value: 1.0)
      let e4 = e3.with_span(x => x.with_time(x => x + 1))
      check e4.whole == none[TimeSpan]()
      check e4.part == e3.part.with_time(x => x + 1)
      check e4.value == e3.value
