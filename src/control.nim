## Sugar for external control.

import
  std/atomics,
  dsp/frame,
  pool

proc `/`*(m: var Midi, idx: int): float {.inline.} =
  ## Within the `audio` with the global memory pool allows sugar like `m/0x36`
  ## for a smoothed out control value.
  m[idx].load.tline(0.001)
