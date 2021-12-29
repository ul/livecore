## Patterns inspired by SuperCollider.

from random import rand

type Pattern* {.inheritable.} = object

proc step*[T: Pattern](t: float; p: var T): float =
  if unlikely(t > 0.0):
    p.next
  p.value

const max_list_length = 256

type
  PList = object of Pattern
    index: int
    list_len: int
    list: array[max_list_length, float]

proc init*(list: openArray[float]; p: var PList) =
  for (i, x) in list.pairs:
    p.list[i] = x
  p.list_len = list.len

proc reset*(p: var PList) =
  p.index = 0

proc value*(p: PList): float =
  p.list[p.index]

type PSeq* = object of PList

proc next*(p: var PSeq) =
  p.index += 1
  if unlikely(p.index >= p.list_len):
    p.index = 0

proc prev*(p: var PSeq) =
  p.index -= 1
  if unlikely(p.index < 0):
    p.index = p.list_len - 1

type PRand* = object of PList

proc next*(p: var PRand) =
  p.index = rand(p.list_len-1)

type PXRand* = object of PList

proc next*(p: var PXRand) =
  if unlikely(p.list_len < 2):
    return
  let index = p.index
  while p.index == index:
    p.index = rand(p.list_len-1)

type PShuf* = object of PSeq

proc init*(list: openArray[float]; p: var PShuf) =
  for (i, x) in list.pairs:
    p.list[i] = x
  p.list_len = list.len
  for i in countdown(p.list_len-1, 1):
    let j = rand(i)
    swap(p.list[i], p.list[j])

type PWRand* = object of PList
  weights_len: int
  weights: array[max_list_length, float]

proc init*(list, weights: openArray[float]; p: var PWRand) =
  for (i, x) in list.pairs:
    p.list[i] = x
  p.list_len = list.len
  var s = 0.0
  for (i, x) in weights.pairs:
    s += x
    p.weights[i] = s
  p.weights_len = weights.len
  for i in 0..<p.weights_len:
    p.weights[i] /= s

proc next*(p: var PWRand) =
  let x = rand(1.0)
  var index = 0
  while (index < p.weights_len) and (p.weights[index] < x):
    index += 1
  p.index = index
