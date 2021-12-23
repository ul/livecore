## Sugar for external control.

import dsp/frame, atomics, pool

proc `/`*(cc: var Controls, idx: int): float {.inline.} =
  ## Within the process with the global memory pool allows sugar like `cc/0x36`
  ## for a smoothed out control value.
  cc[idx].load.tline(0.001)
