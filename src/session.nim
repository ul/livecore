## Where the creativity blossoms.

import
  dsp/[ frame, delays, effects, envelopes, events, filters, metro, modules,
        nanotidal, noise, osc, sampler, soundpipe, stereo, fft, patterns ],
  atomics, math, pool, control, scope, sequtils

type
  State* = object
    pool: Pool

proc process*(s: var State, cc: var Controls, n: var Notes, input: Frame, m: var Monitor): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init
  let x = 55.osc
  x.write_to_monitor(m, 0)

  
# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB) , "MB / Pool: ", int(Pool.size_of/MB), "MB" 
  sp_create()

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
