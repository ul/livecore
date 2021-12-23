import
  atomics,
  ../dsp/frame,
  dynlib,
  ffi/soundio

type
  Process* = proc(arena: pointer, cc: var Controls, n: var Notes, input: Frame): Frame {.nimcall.}
  Load* = proc(arena: pointer) {.nimcall.}
  Unload* = proc(arena: pointer) {.nimcall.}
  Context* = object
    process*: Atomic[Process]
    arena*: pointer
    controls*: Controls
    notes*: Notes
    note_cursor*: int
    input*: ptr SoundIoRingBuffer
    in_process*: Atomic[bool]
    lib_path*: string
    lib*: LibHandle

proc default_process*(arena: pointer, cc: var Controls, n: var Notes, input: Frame): Frame = 0.0

proc new_context*(arena_mb: int): ptr Context =
  result = cast[ptr Context](Context.sizeof.alloc0)
  result.process.store(default_process)
  result.in_process.store(false)
  result.arena = (arena_mb * 1024 * 1024).alloc0
