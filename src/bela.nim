import
  atomics,
  ffi/Bela,
  dsp/frame,
  session

type
  RenderState = object
    arena: State
    controls: Controls
    notes: Notes

var render_state: ptr RenderState

proc livecore_cc_write*(idx: cint, value: cfloat) {.exportc.} =
  render_state.controls[idx].store(value)

proc livecore_setup*(context: ptr BelaContext; user_data: pointer): bool {.exportc.} =
  render_state = cast[ptr RenderState](RenderState.sizeof.alloc0)
  render_state.arena.load
  return true

proc livecore_render*(context: ptr BelaContext; user_data: pointer) {.exportc.} =
  for n in 0..<context.audioFrames.int:
    let frame = process(render_state.arena, render_state.controls, render_state.notes)
    for channel in 0..<CHANNELS:
      audioWrite(context, n.cint, channel.cint, frame[channel])

proc livecore_cleanup*(context: ptr BelaContext; user_data: pointer) {.exportc.} =
  render_state.arena.unload
  render_state.dealloc
