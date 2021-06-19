import
  atomics,
  dsp/frame,
  session

type
  State = object
    arena: session.State
    controls: Controls
    notes: Notes

var state: ptr State

proc livecore_cc_write*(idx: cint, value: cfloat) {.exportc.} =
  state.controls[idx].store(value)

proc livecore_setup*() {.exportc.} =
  state = cast[ptr State](State.sizeof.alloc0)
  state.arena.load

proc livecore_render*(frame: var array[CHANNELS, cfloat]) {.exportc.} =
  let xs = process(state.arena, state.controls, state.notes)
  for i in 0..<CHANNELS:
    frame[i] = xs[i]

proc livecore_cleanup*() {.exportc.} =
  state.arena.unload
  state.dealloc
