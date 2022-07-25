## Where the creativity blossoms.

import
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        nanotidal, noise, osc, sampler, soundpipe, stereo, fft, patterns, fir,
        conv],
  atomics, math, pool, control

type
  State* = object
    pool: Pool
    p1: PRand
    events: EventPool
    durations: PRand

proc process*(s: var State, cc: var Controls, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init
  let event_speed = (1/80).osc.biscale(0.5, 5.5)
  s.events.tick(event_speed)

  s.events[0].repeat: s.durations.step

  let freq = s.events[0].trigger.step(s.p1).mul(110.0)
  let sig = 0.2 * freq.osc
  let env = s.events[0].trigger.impulse(0.08 / event_speed)

  sig.mul(env).zitarev(mix = 0.3, level = -3.0).simple_saturator

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()
  nanotidal_create()

  [1.0, 2.5, 3.0, 3.5, 4.0].init(s.p1)
  [1/2, 1/2, 5/8, 3/4, 3/4, 1].init(s.durations)

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  discard
  # sp_destroy()
  # nanotidal_destroy()
