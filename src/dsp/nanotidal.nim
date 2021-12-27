## A pattern composition module inspired by TidalCycles.
##
## NOTE Due to the pattern's memory management, *do not* hold on them outside of
## `session/process`. For example, *do not* try to optimise performance by
## creating patterns in `session/load` and then using them in `session/process`.

import strformat

const arena_capacity = 0x100 # chunks
const chunk_capacity = 0x100 # tiles

type
  Arc* = tuple
    start: float
    stop: float

  Tile* = tuple
    arc: Arc
    color: float

  Pattern* = object
    first: ptr Chunk
    last: ptr Chunk

  Chunk = object
    len: int
    next: ptr Chunk
    tiles: array[chunk_capacity, Tile]

  Arena = object
    idx: int
    data: array[arena_capacity, Chunk]

var arena: ptr Arena

proc new_chunk(a: ptr Arena): ptr Chunk =
  result = cast[ptr Chunk](a.data[a.idx].addr)
  result.len = 0
  result.next = nil
  a.idx = (a.idx + 1) mod arena_capacity

iterator items(p: Pattern): Tile =
  var chunk = p.first
  while not chunk.is_nil:
    for i in 0..<chunk.len:
      yield chunk.tiles[i]
    chunk = chunk.next

proc add(c: ptr Chunk, t: Tile) =
  c.tiles[c.len] = t
  c.len.inc

proc add(p: var Pattern, t: Tile) =
  if p.last.is_nil:
    var chunk = arena.new_chunk
    chunk.add(t)
    p.first = chunk
    p.last = chunk
  elif p.last.len < chunk_capacity:
    p.last.add(t)
  else:
    var chunk = arena.new_chunk
    chunk.add(t)
    p.last.next = chunk
    p.last = chunk

proc `[]`*(p: Pattern, idx: int): Tile =
  var chunk = p.first
  var i = 0
  while not chunk.is_nil:
    for j in 0..<chunk.len:
      if i == idx:
        return chunk.tiles[j]
      i.inc
    chunk = chunk.next

converter to_float*(t: Tile): float = t.color

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

proc sequence*(patterns: openArray[Pattern]): Pattern =
  let n = patterns.len
  for i, pattern in patterns:
    for tile in pattern:
      result.add((arc: (tile.arc + i) / n, color: tile.color))

proc parallel*(patterns: openArray[Pattern]): Pattern =
  for tiles in patterns:
    for tile in tiles:
      result.add(tile)

proc to_pattern*(colors: openArray[float]): Pattern =
  let n = colors.len.float
  for i, color in colors:
    result.add(((i.float / n, (i + 1).float / n), color))

proc sample*(pattern: Pattern, time: float): Pattern =
  for tile in pattern:
    if tile.arc.start <= time and time < tile.arc.stop:
      result.add(tile)

proc sample_one*(pattern: Pattern, time: float): float =
  for tile in pattern:
    if tile.arc.start <= time and time < tile.arc.stop:
      return tile.color

let `@!`* = toPattern
let `@~`* = sequence
let `@|`* = parallel

proc `$`*(a: Arc): string = fmt"[{a.start}-{a.stop})"
proc `$`*(t: Tile): string = fmt"<{t.arc} {t.color}>"

proc nanotidal_create*() =
  arena = cast[ptr Arena](Arena.sizeof.alloc0)

proc nanotidal_destroy*() =
  arena.dealloc
