## A pattern composition module inspired by TidalCycles.

import rationals, sequtils, strformat

type
  Arc* = tuple
    start: Rational[int]
    stop: Rational[int]

  Tile*[T] = tuple
    arc: Arc
    color: T

  Pattern*[T] = seq[Tile[T]]

template arc_op(op) =
  proc op*(a: Arc, b: Arc): Arc = (op(a[0], b[0]), op(a[1], b[1]))
  proc op*(a: Arc, b: Rational[int]): Arc = (op(a[0], b), op(a[1], b))
  proc op*(a: Rational[int], b: Arc): Arc = (op(a, b[0]), op(a, b[1]))
  proc op*(a: Arc, b: int): Arc = (op(a[0], b), op(a[1], b))
  proc op*(a: int, b: Arc): Arc = (op(a, b[0]), op(a, b[1]))

arc_op(`+`)
arc_op(`-`)
arc_op(`*`)
arc_op(`/`)

proc sequence*[T](patterns: openArray[Pattern[T]]): Pattern[T] =
  let n = patterns.len
  for i, pattern in patterns:
    for tile in pattern:
       result.add((arc: (tile.arc + i) / n, color: tile.color))

proc parallel*[T](patterns: openArray[Pattern[T]]): Pattern[T] =
  for tiles in patterns:
    result.add(tiles)

proc toPattern*[T](colors: openArray[T]): Pattern[T] =
  let n = colors.len
  for i, color in colors:
    result.add(((i // n, (i + 1) // n), color))

proc sample*[T](pattern: Pattern[T], time: float): seq[T] =
  for tile in pattern:
    if tile.arc.start.toFloat <= time and time < tile.arc.stop.toFloat:
      result.add(tile.color)

proc `@!`*[T](colors: openArray[T]): Pattern[T] = colors.toPattern
proc `@~`*[T](patterns: openArray[Pattern[T]]): Pattern[T] = patterns.sequence
proc `@|`*[T](patterns: openArray[Pattern[T]]): Pattern[T] = patterns.parallel

proc `$`*(a: Arc): string = fmt"[{a.start}-{a.stop})"
proc `$`*[T](t: Tile[T]): string = fmt"<{t.arc} {t.color}>"
