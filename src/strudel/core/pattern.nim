import std/[options, sequtils, sugar]
import state, controls, hap, euclid
export hap, controls

type Query*[T] = State -> seq[Hap[T]]

type Pattern*[T] = object
  query*: Query[T]

func pattern[T](query: Query[T]): Pattern[T] =
  ## Create a pattern. As an end user, you will most likely not create a Pattern
  ## directly.
  result.query = query

func silence[T](): Pattern[T] =
  ## A pattern that produces no events.
  result.query = proc(s: State): seq[Hap[T]] =
    @[]

func with_value[T, U](p: Pattern[T], f: T -> U): Pattern[U] =
  ## Returns a new pattern, with the function applied to the value of each hap.
  ## It has alias `fmap`.
  result.query = proc(s: State): seq[Hap[U]] =
    p.query(s).map_it(it.with_value(f))

func fmap[T, U](p: Pattern[T], f: T -> U): Pattern[U] = with_value(p, f)

func with_query_span[T](p: Pattern[T], f: TimeSpan -> TimeSpan): Pattern[T] =
  ## Returns a new pattern, where the given function is applied to the query
  ## timespan before passing it to the original pattern.
  result.query = proc(s: State): seq[Hap[T]] =
    p.query(s.with_span(f))

func with_query_span_maybe[T](p: Pattern[T], f: TimeSpan -> Option[TimeSpan]): Pattern[T] =
  result.query = proc(s: State): seq[Hap[T]] =
    let new_span = f(s.span)
    if new_span.is_some:
      let new_state = s.set_span(new_span.get)
      p.query(new_state)
    else:
      @[]

func with_hap[T](p: Pattern[T], f: Hap[T] -> Hap[T]): Pattern[T] =
  ## Returns a new pattern, where the given function is applied to each hap.
  result.query = proc(s: State): seq[Hap[T]] =
    p.query(s).map(f)

func with_hap_span[T](p: Pattern[T], f: TimeSpan -> TimeSpan): Pattern[T] =
  ## Similar to `with_query_span`, but the function is applied to the timespans
  ## of all haps returned by pattern queries (both `part` timespans, and where
  ## present, `whole` timespans).
  result.query = proc(s: State): seq[Hap[T]] =
    p.query(s).map_it(it.with_span(f))

func with_hap_time[T](p: Pattern[T], f: Fraction -> Fraction): Pattern[T] =
  ## As with `with_hap_span`, but the function is applied to both the
  ## begin and end time of the hap timespans.
  p.with_hap_span(span => span.with_time(f))

func with_query_time[T](p: Pattern[T], f: Fraction -> Fraction): Pattern[T] =
  ## As with `with_query_span`, but the function is applied to both the
  ## begin and end time of the query timespan.
  result.query = proc(s: State): seq[Hap[T]] =
    p.query(s.with_span(span => span.with_time(f)))

func flatten[T](seqs: varargs[seq[T]]): seq[T] = concat(seqs)

func split_queries[T](p: Pattern[T]): Pattern[T] =
  ## Returns a new pattern, with queries split at cycle boundaries. This makes
  ## some calculations easier to express, as all haps are then constrained to
  ## happen within a cycle.
  result.query = proc(s: State): seq[Hap[T]] =
    flatten(s.span.span_cycles.map_it(p.query(s.set_span(it))))

func early*[T](p: Pattern[T], offset: Fraction): Pattern[T] =
  ## Nudge a pattern to start earlier in time. Equivalent of Tidal's <~ operator.
  p.with_query_time(t => t + offset).with_hap_time(t => t - offset)

func late*[T](p: Pattern[T], offset: Fraction): Pattern[T] =
  ## Nudge a pattern to start later in time. Equivalent of Tidal's ~> operator.
  p.early(-offset)

func fast_gap[T](p: Pattern[T], factor: Fraction): Pattern[T] =
  proc qf(span: TimeSpan): Option[TimeSpan] =
    # Maybe it's better without this fallback..
    # if (factor < 1) {
    #     // there is no gap.. so maybe revert to _fast?
    #     return this._fast(factor)
    # }
    # A bit fiddly, to drop zero-width queries at the start of the next cycle
    let cycle = span.begin.sam
    let bpos = ((span.begin - cycle) * factor).min(1.to_fraction)
    let epos = ((span.`end` - cycle) * factor).min(1.to_fraction)
    if bpos >= 1.to_fraction:
      return none[TimeSpan]()
    some(TimeSpan(begin: bpos + cycle, `end`: epos + cycle))

  proc ef(hap: Hap[T]): Hap[T] =
    # Also fiddly, to maintain the right 'whole' relative to the part
    let begin = hap.part.begin
    let `end` = hap.part.`end`
    let cycle = begin.sam
    let begin_pos = ((begin - cycle) / factor).min(1.to_fraction)
    let end_pos = ((`end` - cycle) / factor).min(1.to_fraction)
    let new_part = TimeSpan(begin: begin_pos + cycle, `end`: end_pos + cycle)
    let new_whole = hap.whole.map(it => TimeSpan(
      begin: new_part.begin - (begin - it.begin) / factor,
      `end`: new_part.`end` + (it.`end` - `end`) / factor
    ))
    Hap[T](whole: new_whole, part: new_part, value: hap.value)

  p.with_query_span_maybe(qf).with_hap(ef).split_queries

func compress[T](p: Pattern[T], b, e: Fraction): Pattern[T] =
  ## Compress each cycle into the given timespan, leaving a gap.
  if b > e or b > 1 or e > 1 or b < 0 or e < 0:
    return silence[T]()
  p.fast_gap(1.to_fraction / (e - b)).late(b)

func fast*[T](p: Pattern[T], factor: Fraction): Pattern[T] =
  ## Speed up a pattern by the given factor. Used by "*" in mini notation.
  let fast_query = p.with_query_time(t => t * factor)
  fast_query.with_hap_time(t => t / factor)

func slow*[T](p: Pattern[T], factor: Fraction): Pattern[T] =
  p.fast(1 / factor)

func slowcat*[T](ps: openArray[Pattern[T]]): Pattern[T] =
  ## Concatenation: combines a list of patterns, switching between them
  ## successively, one per cycle.
  ## Synonyms: `cat`.
  let pats = ps.to_seq
  let query = proc(s: State): seq[Hap[T]] =
    let span = s.span
    let pat_n = span.begin.sam.mod(pats.len).to_int
    # pat_n can be negative, if the span is in the past
    if pat_n < 0:
      return @[]
    let pat = pats[pat_n]
    ## A bit of maths to make sure that cycles from constituent patterns aren't
    ## skipped. For example if three patterns are slowcat-ed, the fourth cycle
    ## of the result should be the second (rather than fourth) cycle from the
    ## first pattern.
    let offset = span.begin.floor - (span.begin / pats.len).floor
    pat
      .with_hap_time(t => t + offset)
      .query(s.set_span(span.with_time(t => t - offset)))

  pattern(query).split_queries

func cat*[T](ps: openArray[Pattern[T]]): Pattern[T] = slowcat(ps)

func fastcat*[T](pats: openArray[Pattern[T]]): Pattern[T] =
  ## Concatenation: as with `slowcat`, but squashes a cycle from each pattern
  ## into one cycle.
  ## Synonyms：`sequence`.
  slowcat(pats).fast(pats.len)

func sequence*[T](pats: openArray[Pattern[T]]): Pattern[T] = fastcat(pats)

func pure*[T](value: T): Pattern[T] =
  ## A discrete value that repeats once per cycle.
  result.query = proc(s: State): seq[Hap[T]] =
    s.span.span_cycles.map_it(Hap[T](whole: some(it.begin.whole_cycle), part: it, value: value))

func stack*[T](ps: openArray[Pattern[T]]): Pattern[T] =
  let pats = ps.to_seq
  ## The given items are played at the same time at the same length.
  result.query = proc(s: State): seq[Hap[T]] =
    flatten(pats.map_it(it.query(s)))

func polyrhythm*[T](ps: openArray[Pattern[T]]): Pattern[T] = stack(ps)
func poly*[T](ps: openArray[Pattern[T]]): Pattern[T] = stack(ps)

func time_cat*[T](ps: openArray[(Fraction, Pattern[T])]): Pattern[T] =
  ## Like `sequence` but each step has a length, relative to the whole.
  let total = ps.map_it(it[0]).foldr(a + b)
  var pats: seq[Pattern[T]] = @[]
  var begin = 0.to_fraction
  for (time, pat) in ps:
    let `end` = begin + time
    pats.add(pat.compress(begin / total, `end` / total))
    begin = `end`
  stack(pats)

func cat*[T](ps: openArray[(Fraction, Pattern[T])]): Pattern[T] = time_cat(ps)

# FIXME T = Controls at the moment
func struct*[T](p: Pattern[T], s: Pattern[int]): Pattern[T] =
  ## Apply the given structure to the pattern.
  ## `s` must consist of 0s and 1s only.
  result.query = proc(st: State): seq[Hap[T]] =
    for s_hap in s.query(st):
      for p_hap in p.query(st.set_span(s_hap.whole_or_part)):
        let new_whole = s_hap.whole
        let new_part = p_hap.part.intersection(s_hap.part)
        if new_part.is_some:
          let new_value = if s_hap.value > 0: p_hap.value else: Controls(rest: true)
          result.add(Hap[T](whole: new_whole, part: new_part.get, value: new_value))

converter to_pattern*(value: float): Pattern[float] = pure(value)
func to_pattern*(xs: openArray[float]): Pattern[float] = xs.map(pure).sequence

converter to_pattern*(value: pointer): Pattern[pointer] = pure(value)
func to_pattern*(xs: openArray[pointer]): Pattern[pointer] = xs.map(pure).sequence

# These symbols are available in Nim for operators.
# We can use them as the alternative to Strudel's mini notation.
# Most will go with `@` prefix to signal that they work with sequences.
# =     +     -     *     /     <     >
# @     $     ~     &     %     |
# !     ?     ^     .     :     \

func `!`*[T](x: T): Pattern[T] = pure(x)
func `--`*[T](x: T): Pattern[T] = pure(x)

func `--`*[T](xs: openArray[Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..1, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..2, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..3, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..4, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..5, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..6, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..7, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..8, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..9, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..10, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..11, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..12, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..13, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..14, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..15, Pattern[T]]): Pattern[T] = xs.sequence
converter `--`*[T](xs: array[0..16, Pattern[T]]): Pattern[T] = xs.sequence

func `--`*(xs: openArray[float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..1, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..2, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..3, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..4, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..5, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..6, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..7, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..8, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..9, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..10, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..11, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..12, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..13, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..14, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..15, float]): Pattern[float] = xs.to_pattern
converter `--`*(xs: array[0..16, float]): Pattern[float] = xs.to_pattern

func `--`*(xs: openArray[pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..1, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..2, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..3, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..4, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..5, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..6, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..7, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..8, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..9, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..10, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..11, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..12, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..13, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..14, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..15, pointer]): Pattern[pointer] = xs.to_pattern
converter `--`*(xs: array[0..16, pointer]): Pattern[pointer] = xs.to_pattern

func `*`*[T](p: Pattern[T], factor: Fraction): Pattern[T] = p.fast(factor)
func `/`*[T](p: Pattern[T], factor: Fraction): Pattern[T] = p.slow(factor)
func `<>`*[T](xs: openArray[Pattern[T]]): Pattern[T] = xs.slowcat
func `//`*[T](xs: openArray[Pattern[T]]): Pattern[T] = xs.stack
func `@@`*[T](xs: openArray[(Fraction, Pattern[T])]): Pattern[T] = xs.time_cat

# For elongation just use time_cat directly.
# Converters should help to keep syntax light for simple cases:
# @@[(2//1, !1.0), 2.0, 3.0] == [!1.0, 1.0, 2.0, 3.0]

converter to_weighted_pattern*[T](p: Pattern[T]): (Fraction, Pattern[T]) =
  (1.to_fraction, p)

converter to_weighted_pattern*(x: float): (Fraction, Pattern[float]) =
  (1.to_fraction, pure(x))

func replicate*[T](p: Pattern[T], factor: Fraction): (Fraction, Pattern[T]) =
  (factor, p * factor)

func `!`*[T](p: Pattern[T], factor: Fraction): (Fraction, Pattern[T]) =
  p.replicate(factor)

# A thirteenth century Persian rhythm called Khafif-e-ramal.
# note("c3").euclid(2,5)
# The archetypal pattern of the Cumbia from Colombia, as well as a Calypso rhythm from Trinidad.
# note("c3").euclid(3,4)
# Another thirteenth century Persian rhythm by the name of Khafif-e-ramal, as well as a Rumanian folk-dance rhythm.
# note("c3").euclid(3,5,2)
# A Ruchenitza rhythm used in a Bulgarian folk-dance.
# note("c3").euclid(3,7)
# The Cuban tresillo pattern.
# note("c3").euclid(3,8)
# Another Ruchenitza Bulgarian folk-dance rhythm.
# note("c3").euclid(4,7)
# The Aksak rhythm of Turkey.
# note("c3").euclid(4,9)
# The metric pattern used by Frank Zappa in his piece titled Outside Now.
# note("c3").euclid(4,11)
# Yields the York-Samai pattern, a popular Arab rhythm.
# note("c3").euclid(5,6)
# The Nawakhat pattern, another popular Arab rhythm.
# note("c3").euclid(5,7)
# The Cuban cinquillo pattern.
# note("c3").euclid(5,8)
# A popular Arab rhythm called Agsag-Samai.
# note("c3").euclid(5,9)
# The metric pattern used by Moussorgsky in Pictures at an Exhibition.
# note("c3").euclid(5,11)
# The Venda clapping pattern of a South African children’s song.
# note("c3").euclid(5,12)
# The Bossa-Nova rhythm necklace of Brazil.
# note("c3").euclid(5,16)
# A typical rhythm played on the Bendir (frame drum).
# note("c3").euclid(7,8)
# A common West African bell pattern.
# note("c3").euclid(7,12)
# A Samba rhythm necklace from Brazil.
# note("c3").euclid(7,16,14)
# A rhythm necklace used in the Central African Republic.
# note("c3").euclid(9,16)
# A rhythm necklace of the Aka Pygmies of Central Africa.
# note("c3").euclid(11,24,14)
# Another rhythm necklace of the Aka Pygmies of the upper Sangha.
# note("c3").euclid(13,24,5)

# TODO euclid_legato
func euclid*[T](p: Pattern[T], pulses, steps: int, rotation: int = 0): Pattern[T] =
  ## Changes the structure of the pattern to form an euclidean rhythm.
  ## Euclidian rhythms are rhythms obtained using the greatest common divisor of two numbers.
  ## They were described in 2004 by Godfried Toussaint, a canadian computer scientist.
  ## Euclidian rhythms are really useful for computer/algorithmic music because they can accurately
  ## describe a large number of rhythms used in the most important music world traditions.
  p.struct(euclid.euclid(pulses, steps, rotation).map_it(it.pure).sequence)

func query_values*[T](p: Pattern[T], s: State): seq[T] =
  p.query(s).map_it(it.value)

func `>>`*(left: Pattern[Controls], right: Pattern[Controls]): Pattern[Controls] =
  ## Take the structure from the left pattern, and merge controls from the left to right.
  result.query = proc(st: State): seq[Hap[Controls]] =
    for hap_left in left.query(st):
      for hap_right in right.query(st.set_span(hap_left.whole_or_part)):
        let new_whole = hap_left.whole
        let new_part = hap_left.part.intersection(hap_right.part)
        if new_part.is_some:
          let new_value = hap_left.value.right_merge(hap_right.value)
          result.add(Hap[Controls](whole: new_whole, part: new_part.get, value: new_value))

func `<<`*(left: Pattern[Controls], right: Pattern[Controls]): Pattern[Controls] =
  ## Take the structure from the right pattern, and merge controls from the left to right.
  ## Note that we can't express it as right >> left due to the value merge direction.
  result.query = proc(st: State): seq[Hap[Controls]] =
    for hap_right in right.query(st):
      for hap_left in left.query(st.set_span(hap_right.whole_or_part)):
        let new_whole = hap_right.whole
        let new_part = hap_right.part.intersection(hap_left.part)
        if new_part.is_some:
          let new_value = hap_left.value.right_merge(hap_right.value)
          result.add(Hap[Controls](whole: new_whole, part: new_part.get, value: new_value))

func `><`*(left: Pattern[Controls], right: Pattern[Controls]): Pattern[Controls] =
  ## Take the structure from both patterns, and merge controls from the left to right.
  result.query = proc(st: State): seq[Hap[Controls]] =
    for hap_left in left.query(st):
      for hap_right in right.query(st):
        let new_part = hap_left.part.intersection(hap_right.part)
        if hap_left.whole.is_some and hap_right.whole.is_some and new_part.is_some:
          let new_whole = hap_left.whole.get.intersection(hap_right.whole.get)
          let new_value = hap_left.value.right_merge(hap_right.value)
          result.add(Hap[Controls](whole: new_whole, part: new_part.get, value: new_value))

template ctrl(attr: untyped, T: typedesc) =
  func attr*(p: Pattern[T]): Pattern[Controls] =
    p.with_value(func(x: T): Controls = Controls(attr: some(x)))

ctrl(sound, pointer)
ctrl(note, float)
ctrl(gain, float)

when isMainModule:
  import std/unittest
  suite "Pattern":
    test "pure":
      let p = pure(1.0)
      let s = State(span: timespan(0, 1//2))
      check p.query(s) == @[
        Hap[float](whole: some(timespan(0, 1)), part: timespan(0, 1//2), value: 1.0)]
    test "slowcat":
      let p1 = pure(1)
      let p2 = pure(2)
      let p3 = pure(3)
      let p = slowcat(@[p1, p2, p3])
      let s = State(span: timespan(0, 3))
      let haps = p.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(0, 1)), part: timespan(0, 1), value: 1),
        Hap[int](whole: some(timespan(1, 2)), part: timespan(1, 2), value: 2),
        Hap[int](whole: some(timespan(2, 3)), part: timespan(2, 3), value: 3)]
    test "fastcat":
      let p1 = pure(1)
      let p2 = pure(2)
      let p3 = pure(3)
      let p = fastcat(@[p1, p2, p3])
      let s = State(span: timespan(0, 1))
      let haps = p.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(0, 1//3)), part: timespan(0, 1//3),
            value: 1),
        Hap[int](whole: some(timespan(1//3, 2//3)), part: timespan(1//3,
            2//3), value: 2),
        Hap[int](whole: some(timespan(2//3, 1)), part: timespan(2//3, 1), value: 3)]
    test "with_value":
      let p = pure(1)
      let p2 = p.with_value(v => v * 2)
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(0, 1)), part: timespan(0, 1), value: 2)]
    test "with_query_span":
      let p = pure(1)
      let p2 = p.with_query_span(span => span.with_time(t => t + 2))
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(2, 3)), part: timespan(2, 3), value: 1),
      ]
    test "with_query_span_maybe":
      let p = pure(1)
      let p2 = p.with_query_span_maybe(span => some(span.with_time(t => t + 2)))
      let s = State(span: timespan(0, 1))
      check p2.query(s) == @[
        Hap[int](whole: some(timespan(2, 3)), part: timespan(2, 3), value: 1),
      ]
      let p3 = p.with_query_span_maybe(span => none[TimeSpan]())
      let empty: seq[Hap[int]] = @[]
      check p3.query(s) == empty
    test "with_hap":
      let p = pure(1)
      let p2 = p.with_hap(hap => hap.with_value(proc(v: int): int = v * 2))
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(0, 1)), part: timespan(0, 1), value: 2),
      ]
    test "with_hap_span":
      let p = pure(1)
      let p2 = p.with_hap_span(span => span.with_time(t => t + 2))
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(2, 3)), part: timespan(2, 3), value: 1)]
    test "with_hap_time":
      let p = pure(1)
      let p2 = p.with_hap_time(t => t + 2)
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(2, 3)), part: timespan(2, 3), value: 1)]
    test "with_query_time":
      let p = pure(1)
      let p2 = p.with_query_time(t => t + 2)
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(2, 3)), part: timespan(2, 3), value: 1)]
    test "split_queries":
      let p = pure(1)
      let p2 = p.split_queries
      let s = State(span: timespan(0, 2))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(0, 1)), part: timespan(0, 1), value: 1),
        Hap[int](whole: some(timespan(1, 2)), part: timespan(1, 2), value: 1),
      ]
    test "early":
      let p = pure(1)
      let p2 = p.early(1/3)
      let s = State(span: timespan(1, 2))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(2//3, 5//3)), part: timespan(1, 5//3),
            value: 1),
        Hap[int](whole: some(timespan(5//3, 8//3)), part: timespan(5//3, 2),
            value: 1),
      ]
    test "late":
      let p = pure(1)
      let p2 = p.late(1/3)
      let s = State(span: timespan(1, 2))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(1//3, 4//3)), part: timespan(1//1,
            4//3), value: 1),
        Hap[int](whole: some(timespan(4//3, 7//3)), part: timespan(4//3, 2),
            value: 1),
      ]
    test "fast_gap":
      # TODO cover more
      let p = pure(1)
      let p2 = p.fast_gap(3)
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(0, 1//3)), part: timespan(0, 1//3),
            value: 1),
      ]
    test "compress":
      let p = pure(1)
      let p2 = p.compress(1/3, 1/2)
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(1//3, 1//2)), part: timespan(1//3,
            1//2), value: 1),
      ]
    test "fast":
      let p = pure(1)
      let p2 = p.fast(2)
      let s = State(span: timespan(0, 1))
      let haps = p2.query(s)
      check haps == @[
        Hap[int](whole: some(timespan(0, 1//2)), part: timespan(0, 1//2),
            value: 1),
        Hap[int](whole: some(timespan(1//2, 1)), part: timespan(1//2, 1),
            value: 1),
      ]
    test "sequence":
      let p = --[!1.0, --[2.0, 3.0]]
      let s = State(span: timespan(0, 1))
      let haps = p.query(s)
      check haps == @[
        Hap[float](whole: some(timespan(0, 1//2)), part: timespan(0, 1//2),
            value: 1),
        Hap[float](whole: some(timespan(1//2, 3//4)), part: timespan(1//2,
            3//4), value: 2),
        Hap[float](whole: some(timespan(3//4, 1)), part: timespan(3//4, 1),
            value: 3),
      ]
    test "query_values":
      let p = --[!1.0, --[2.0, 3.0]]
      let s = State(span: timespan(0, 1))
      let values = p.query_values(s)
      check values == @[1.0, 2.0, 3.0]
    test "stack":
      let p = stack([!1.0, 2.0, 3.0])
      let s = State(span: timespan(0, 1))
      let haps = p.query(s)
      check haps == @[
        Hap[float](whole: some(timespan(0, 1)), part: timespan(0, 1),
            value: 1.0),
        Hap[float](whole: some(timespan(0, 1)), part: timespan(0, 1),
            value: 2.0),
        Hap[float](whole: some(timespan(0, 1)), part: timespan(0, 1),
            value: 3.0),
      ]
    test "time_cat":
      let p = time_cat([(3//1, !1.0), (2//1, !2.0), (1//1, !3.0)])
      let s = State(span: timespan(0, 1))
      let haps = p.query(s)
      check haps == @[
        Hap[float](whole: some(timespan(0, 1//2)), part: timespan(0, 1//2),
            value: 1.0),
        Hap[float](whole: some(timespan(1//2, 5//6)), part: timespan(1//2,
            5//6), value: 2.0),
        Hap[float](whole: some(timespan(5//6, 1)), part: timespan(5//6, 1),
            value: 3.0),
      ]
    test "replicate":
      let p = time_cat([replicate(!1.0, 3//1), (1//1, !2.0)])
      let s = State(span: timespan(0, 1))
      let haps = p.query(s)
      check haps == @[
        Hap[float](whole: some(timespan(0, 1//4)), part: timespan(0, 1//4),
            value: 1.0),
        Hap[float](whole: some(timespan(1//4, 2//4)), part: timespan(1//4,
            2//4), value: 1.0),
        Hap[float](whole: some(timespan(2//4, 3//4)), part: timespan(2//4,
            3//4), value: 1.0),
        Hap[float](whole: some(timespan(3//4, 1)), part: timespan(3//4, 1),
            value: 2.0),
      ]
    test "struct":
      let p = struct([!1.0, 2.0, 3.0], [!1.0, 0.0, 1.0])
      let s = State(span: timespan(0, 1))
      let haps = p.query(s)
      check haps == @[
        Hap[float](whole: some(timespan(0, 1//3)), part: timespan(0, 1//3),
            value: 1.0),
        Hap[float](whole: some(timespan(1//3, 2//3)), part: timespan(1//3,
            2//3), value: 0.0),
        Hap[float](whole: some(timespan(2//3, 1)), part: timespan(2//3, 1),
            value: 3.0),
      ]
    test "euclid":
      let p = (!1.0).euclid(3, 5)
      let s = State(span: timespan(0, 1))
      let haps = p.query(s)
      check haps == @[
        Hap[float](whole: some(timespan(0, 1//5)), part: timespan(0, 1//5),
            value: 1.0),
        Hap[float](whole: some(timespan(1//5, 2//5)), part: timespan(1//5,
            2//5), value: 0.0),
        Hap[float](whole: some(timespan(2//5, 3//5)), part: timespan(2//5,
            3//5), value: 1.0),
        Hap[float](whole: some(timespan(3//5, 4//5)), part: timespan(3//5,
            4//5), value: 0.0),
        Hap[float](whole: some(timespan(4//5, 1)), part: timespan(4//5, 1),
            value: 1.0),
      ]
