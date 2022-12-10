import std/options
import dsp/[frame, metro, osc]
import strudel/core/pattern

const cycle* = timespan(0, 1)

type Cycler* = object
  cpm: float
  phase: float
  clock: float

proc tick*(s: var Cycler, cpm: float = 60.0) =
  s.cpm = cpm
  s.clock = cpm.bpm2freq.saw(s.phase).uni

proc cycle_duration*(s: var Cycler): float = s.cpm.bpm2delta

proc cycle_time*(s: var Cycler): float = s.clock * s.cycle_duration

proc gate*(e: Hap[float], s: var Cycler): float =
  let span = e.whole.get
  if span.begin.to_float <= s.clock and s.clock < span.`end`.to_float:
    1.0
  else:
    0.0

proc duration*(e: Hap[float], s: var Cycler): float =
  e.duration.to_float * s.cycle_duration

proc haps*(p: Pattern, s: var Cycler): seq[Hap[float]] = p.query(cycle)
