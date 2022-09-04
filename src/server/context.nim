import
  atomics,
  ../dsp/frame,
  dynlib

type
  Process* = proc(arena: pointer, cc: var Controls, n: var Notes,
      input: Frame): Frame {.nimcall.}
  Load* = proc(arena: pointer) {.nimcall.}
  Unload* = proc(arena: pointer) {.nimcall.}
  Stats* = object
    min*: float
    max*: float
    sum*: float
    n*: int
  Context* = object
    process*: Atomic[Process]
    arena*: pointer
    controls*: Controls
    notes*: Notes
    note_cursor*: int
    in_process*: Atomic[bool]
    lib_path*: string
    lib*: LibHandle
    stats*: Stats

proc default_process*(arena: pointer, cc: var Controls, n: var Notes,
    input: Frame): Frame = 0.0

proc new_context*(arena_mb: int): ptr Context =
  result = cast[ptr Context](Context.sizeof.alloc0)
  result.process.store(default_process)
  result.in_process.store(false)
  result.arena = (arena_mb * 1024 * 1024).alloc0
