import std/options

type
  Controls* = object
    sound*: Option[pointer]
    note*: Option[float]
    gain*: Option[float]
    attack*: Option[float]
    # Using Option[Controls] + filtering instead of a flag might be a better solution.
    rest*: bool
    # These two are not optional as they are always set by the cycler before calling the sound function.
    duration*: float
    gate*: float

func `or`*[T](x: Option[T], y: Option[T]): Option[T] =
  if x.is_some: x
  else: y

func right_merge*(a, b: Controls): Controls =
  Controls(
    sound: b.sound or a.sound,
    note: b.note or a.note,
    gain: b.gain or a.gain,
    attack: b.attack or a.attack,
    rest: b.rest # or a.rest,
  )
