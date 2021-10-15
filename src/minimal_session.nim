## Where the creativity blossoms.

import dsp/frame

type State* = object

proc process*(s: var State, cc: var Controls, n: var Notes): Frame {.nimcall, exportc, dynlib.} =
  discard

proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  discard

proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  discard
