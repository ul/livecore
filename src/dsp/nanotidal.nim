## A pattern composition module inspired by TidalCycles.

import strformat

type
  Arc* = tuple
    start: float
    stop: float

  Tile*[T] = tuple
    arc: Arc
    color: T

  Pattern*[T] = seq[Tile[T]]

template arc_op(op) =
  proc op*(a: Arc, b: Arc): Arc = (op(a[0], b[0]), op(a[1], b[1]))
  proc op*(a: Arc, b: float): Arc = (op(a[0], b), op(a[1], b))
  proc op*(a: float, b: Arc): Arc = (op(a, b[0]), op(a, b[1]))
  proc op*(a: Arc, b: int): Arc = (op(a[0], b.float), op(a[1], b.float))
  proc op*(a: int, b: Arc): Arc = (op(a.float, b[0]), op(a.float, b[1]))

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
  let n = colors.len.float
  for i, color in colors:
    result.add(((i.float / n, (i + 1).float / n), color))

proc sample*[T](pattern: Pattern[T], time: float): seq[T] =
  for tile in pattern:
    if tile.arc.start <= time and time < tile.arc.stop:
      result.add(tile.color)

proc sample_one*[T](pattern: Pattern[T], time: float): T =
  for tile in pattern:
    if tile.arc.start <= time and time < tile.arc.stop:
      return tile.color

proc `@!`*[T](colors: openArray[T]): Pattern[T] = colors.toPattern
proc `@~`*[T](patterns: openArray[Pattern[T]]): Pattern[T] = patterns.sequence
proc `@|`*[T](patterns: openArray[Pattern[T]]): Pattern[T] = patterns.parallel

proc `$`*(a: Arc): string = fmt"[{a.start}-{a.stop})"
proc `$`*[T](t: Tile[T]): string = fmt"<{t.arc} {t.color}>"
