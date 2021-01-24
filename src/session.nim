## Where the creativity blossoms.

import
  dsp/[ frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, soundpipe, stereo ],
  math, pool

type
  State* = object
    pool: Pool

proc process*(s: var State): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init
  let
    f = 120.rline.to(33, 45).quantize(2).add(1).midi2freq
    drone =
      ((f.tri*f.saw).bqlpf(2.0*f, (1/8).osc.to(0.5, 1.5)) *
       60.rline.to(12, 16).round.dmetro.impulse(2))
      .fb(4, 0.6)
    cm = 7/((1/16).osc.to(3, 7).round)
    m = (1/8).osc.to(1/4, 2).dmetro
    base = 8.rline.to(57, 69).round
    e = m.impulse(0.05)
    Q = 2.0.sqrt
    chirp = [
        [base, base+24].sequence(m),
        base+[2.0, 3.0, 4.0].sequence(m),
        base+[3.0, 5.0, 7.0].sequence(m),
        base+12,
      ].sequence(m).midi2freq.fm(cm, 1/2).mul(e)
      .bqnotch(4.osc.to(base, base+24).midi2freq, Q)
      .fb((1/32).rline.to(1/24, 4), 0.25)
      .fb(1/16, 0.2)
      .fb(1/8, 0.2)
      .fb(1/7, 0.2)
      .fb(1/5, 0.2)
      .fb(1/3, 0.2)
      .bqlpf((1/32).osc.to(69, 93).round.midi2freq, Q)
    mix =
      0.25 * drone.pan(0.5 * (1/12).osc) +
      0.4  * chirp.pan(0.5 * (1/8).osc)
  mix.bqhpf(30.0, Q).mul(0.5).saturator

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB) , "MB / Pool: ", int(Pool.size_of/MB), "MB" 
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
