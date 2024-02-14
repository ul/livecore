import
  std/[atomics, dynlib],
  ../dsp/frame

type
  Audio* = proc(arena: pointer, m: Midi, input: Frame): Frame {.nimcall.}
  Control* = proc(arena: pointer, m: Midi, frame_count: int) {.nimcall.}
  Load* = proc(arena: pointer) {.nimcall.}
  Unload* = proc(arena: pointer) {.nimcall.}
  Stats* = object
    min*: float
    max*: float
    avg*: float
    n*: int
  Context* = object
    audio*: Atomic[Audio]
    control*: Atomic[Control]
    arena*: pointer
    midi*: Midi
    in_process*: Atomic[bool]
    lib_path*: string
    lib*: LibHandle
    stats*: Stats

proc default_audio*(arena: pointer, m: Midi, input: Frame): Frame = 0.0

proc default_control*(arena: pointer, m: Midi, frame_count: int) =
  discard

proc new_context*(arena_mb: int): ptr Context =
  result = cast[ptr Context](Context.sizeof.alloc0)
  result.audio.store(default_audio)
  result.control.store(default_control)
  result.in_process.store(false)
  result.arena = (arena_mb * 1024 * 1024).alloc0
