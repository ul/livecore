import std/[options, strformat, sugar]
import fraction
export fraction

type TimeSpan* = object
  begin*: Fraction
  `end`*: Fraction

func timespan*(begin, `end`: Fraction): TimeSpan =
  TimeSpan(begin: begin, `end`: `end`)

func whole_cycle*(x: Fraction): TimeSpan = timespan(x.sam, x.next_sam)

func span_cycles*(t: TimeSpan): seq[TimeSpan] =
  var begin = t.begin
  let end_sam = t.`end`.sam

  while t.`end` > begin:
    # If begin and end are in the same cycle, we're done.
    if begin.sam == end_sam:
      result.add(TimeSpan(begin: begin, `end`: t.`end`))
      break

    # Add a timespan up to the next sam.
    let next_begin = begin.next_sam
    result.add(TimeSpan(begin: begin, `end`: next_begin))

    # Continue with the next cycle.
    begin = next_begin

func duration*(t: TimeSpan): Fraction =
  t.`end` - t.begin

func cycle_arc*(t: TimeSpan): TimeSpan =
  ## Shifts a timespan to one of equal duration that starts within cycle zero.
  ## (Note that the output timespan probably does not start *at* Time 0 -- that
  ## only happens when the input Arc starts at an integral Time.)
  result.begin = t.begin.cycle_pos
  result.`end` = result.begin + t.duration

proc with_time*(t: TimeSpan, f: Fraction -> Fraction): TimeSpan =
  ## Applies given function to both the begin and end time of the timespan.
  result.begin = f(t.begin)
  result.`end` = f(t.`end`)

proc with_end*(t: TimeSpan, f: Fraction -> Fraction): TimeSpan =
  ## Applies given function to the end time of the timespan.
  result.begin = t.begin
  result.`end` = f(t.`end`)

proc with_cycle*(t: TimeSpan, f: Fraction -> Fraction): TimeSpan =
  ## Like `with_time`, but time is relative to relative to the cycle (i.e. the sam
  ## of the start of the timespan)
  let sam = t.begin.sam
  result.begin = sam + f(t.begin - sam)
  result.`end` = sam + f(t.`end` - sam)

func intersection*(t1, t2: TimeSpan): Option[TimeSpan] =
  ## Intersection of two timespans, returns None if they don't intersect.
  let intersect_begin = max(t1.begin, t2.begin)
  let intersect_end = min(t1.`end`, t2.`end`)

  if intersect_begin > intersect_end:
    return none[TimeSpan]()

  if intersect_begin == intersect_end:
    # Zero-width (point) intersection - doesn't intersect if it's at the end of
    # a non-zero-width timespan.
    if intersect_begin == t1.`end` and t1.begin < t1.`end`:
      return none[TimeSpan]()
    if intersect_begin == t2.`end` and t2.begin < t2.`end`:
      return none[TimeSpan]()

  some(TimeSpan(
    begin: intersect_begin,
    `end`: intersect_end
  ))

func intersection_e*(t1, t2: TimeSpan): TimeSpan =
  ## Like `intersection` but raises exception if the timespans don't intersect.
  intersection(t1, t2).get

func midpoint*(t: TimeSpan): Fraction =
  t.begin + (t.duration / 2)

func `==`*(t1, t2: TimeSpan): bool =
  t1.begin == t2.begin and t1.`end` == t2.`end`

func `$`*(t: TimeSpan): string =
  fmt"{t.begin} -> {t.end}"

when isMainModule:
  import std/unittest
  suite "TimeSpan":
    test "timespan":
      let t = timespan(1//2, 3//2)
      check t.begin == 1//2
      check t.`end` == 3//2
    test "whole_cycle":
      let t = whole_cycle(1//2)
      check t.begin == 0
      check t.`end` == 1
    test "span_cycles":
      let t = TimeSpan(begin: 1//2, `end`: 3//2)
      let spans = t.span_cycles
      check spans.len == 2
      check spans[0] == TimeSpan(begin: 1//2, `end`: 1)
      check spans[1] == TimeSpan(begin: 1, `end`: 3//2)
    test "duration":
      let t = TimeSpan(begin: 1//2, `end`: 3//2)
      check t.duration == 1
    test "cycle_arc":
      let t = TimeSpan(begin: 1//2, `end`: 3//2)
      check t.cycle_arc == TimeSpan(begin: 1//2, `end`: 3//2)
      let t2 = TimeSpan(begin: 1, `end`: 3)
      check t2.cycle_arc == TimeSpan(begin: 0, `end`: 2)
    test "with_time":
      let t = TimeSpan(begin: 1//2, `end`: 3//2)
      let t2 = t.with_time(x => x + 1)
      check t2 == TimeSpan(begin: 3//2, `end`: 5//2)
    test "with_end":
      let t = TimeSpan(begin: 1//2, `end`: 3//2)
      let t2 = t.with_end(x => x + 1)
      check t2 == TimeSpan(begin: 1//2, `end`: 5//2)
    test "with_cycle":
      let t = TimeSpan(begin: 3//2, `end`: 3//1)
      let t2 = t.with_cycle(x => x * 2)
      check t2 == TimeSpan(begin: 2, `end`: 5)
    test "intersection":
      let t1 = TimeSpan(begin: 1//2, `end`: 3//2)
      let t2 = TimeSpan(begin: 2, `end`: 3)
      check intersection(t1, t2) == none[TimeSpan]()
      let t3 = TimeSpan(begin: 1//2, `end`: 3//2)
      let t4 = TimeSpan(begin: 1, `end`: 3)
      check intersection(t3, t4) == some(TimeSpan(begin: 1, `end`: 3//2))
    test "intersection_e":
      let t1 = TimeSpan(begin: 1//2, `end`: 3//2)
      let t2 = TimeSpan(begin: 1, `end`: 3)
      check intersection_e(t1, t2) == TimeSpan(begin: 1, `end`: 3//2)
      let t3 = TimeSpan(begin: 1//2, `end`: 3//2)
      let t4 = TimeSpan(begin: 2, `end`: 3)
      expect(UnpackDefect):
        discard intersection_e(t3, t4)
    test "midpoint":
      let t = TimeSpan(begin: 1//2, `end`: 3//2)
      check t.midpoint == 1
    test "eq":
      let t1 = TimeSpan(begin: 1//2, `end`: 3//2)
      let t2 = TimeSpan(begin: 1//2, `end`: 3//2)
      let t3 = TimeSpan(begin: 1//2, `end`: 5//2)
      check t1 == t2
      check t1 != t3
    test "str":
      let t = TimeSpan(begin: 1//2, `end`: 3//2)
      check $t == "1/2 -> 3/2"
