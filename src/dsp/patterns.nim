## Patterns inspired by SuperCollider.

type Pattern* {.inheritable.} = object

proc step*[T: Pattern](t: float; p: var T): float =
  if unlikely(t > 0.0):
    p.next
  p.value

template defPSeq(max_length: static[Natural]) =
  type
    PSeq = object of Pattern
      index: int
      length: int
      list: array[max_length, float]
    `PSeq max_length`* {.inject.} = PSeq

  proc init*(list: openArray[float]; p: var PSeq) =
    for (i, x) in list.pairs:
      p.list[i] = x
    p.length = list.len

  proc reset*(p: var PSeq) =
    p.index = 0

  proc next*(p: var PSeq) =
    p.index += 1
    if unlikely(p.index >= p.length):
      p.index = 0

  proc value*(p: PSeq): float =
    p.list[p.index]

defPSeq(16)
