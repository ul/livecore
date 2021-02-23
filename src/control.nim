## Sugar for external control.

import dsp/frame, atomics, pool

proc `/`*(cc: var Controls, idx: int): float {.inline.} =
  ## Within the process with the global memory pool allows sugar like `cc/0x36`
  ## for a smoothed out control value.
  cc[idx].load.tline(0.001)

proc tidal*(cc: var Controls, idx: int): float {.inline.} =
  ## Interpret controls as triggers. To be used with `t` function from
  ## BootTidal.hs, where pattern elements are control indices. To just set
  ## control values use `i` for indices and `x` for values and read as usual
  ## (e.g. with `/`).
  result = cc[idx].load
  if unlikely(result > 0.0):
    cc[idx].store(0.0)

proc tidal*(n: var Notes): array[0x10, (float, float)] {.inline.} =
  ## Interpret notes as triggered by returing tuples of frequencies and trigger
  ## state for all voices. To be used with `n` function from BootTidal.hs, where
  ## pattern elements are midi pitches.
  for i in 0..n.high:
    let note = n[i].load
    let pitch = note and 0x00FF
    let velocity = note div 0x100
    var trig = 0.0
    if unlikely(velocity > 0):
      trig = 1.0
      n[i].store(pitch)
    result[i] = (pitch.float.midi2freq, trig)
