## Sugar for external control.

import dsp/frame, atomics, pool

proc `/`*(cc: var Controllers, idx: int): float {.inline.} =
  ## Within the `audio` with the global memory pool allows sugar like `cc/0x36`
  ## for a smoothed out control value.
  cc[idx].load.tline(0.001)
