import std/algorithm

func bjorklund(slots, pulses: int): seq[int] =
  var
    pattern: seq[int] = @[]
    count: seq[int] = @[]
    remainder: seq[int] = @[pulses]
    divisor: int = slots - pulses
    level: int = 0

  func build_pattern(lv: int) =
    if lv == -1:
      pattern.add(0)
    elif lv == -2:
      pattern.add(1)
    else:
      for x in 0..<count[lv]:
        build_pattern(lv-1)
      if remainder[lv] > 0:
        build_pattern(lv-2)

  while remainder[level] > 1:
    count.add(divisor div remainder[level])
    remainder.add(divisor mod remainder[level])
    divisor = remainder[level]
    level.inc

  count.add(divisor)

  build_pattern(level)

  pattern.reverse
  pattern

func bjork*(m, k: int): seq[int] =
  if m > k:
    bjorklund(m, k)
  else:
    bjorklund(k, m)

func euclid*(pulses, steps: int, rotation = 0): seq[int] =
  result = bjork(steps, pulses)
  result.rotateLeft(rotation)

when isMainModule:
  import std/unittest
  suite "bjork":
    test "E(3,5)":
      check bjork(3, 5) == @[1, 0, 1, 0, 1]
    test "E(4,7)":
      check bjork(4, 7) == @[1, 0, 1, 0, 1, 0, 1]
    test "E(5,7)":
      check bjork(5, 7) == @[1, 0, 1, 1, 0, 1, 1]
    test "E(2,8)":
      check bjork(2, 8) == @[1, 0, 0, 0, 1, 0, 0, 0]
    test "E(3,8)":
      check bjork(3, 8) == @[1, 0, 0, 1, 0, 0, 1, 0]
    test "E(4,8)":
      check bjork(4, 8) == @[1, 0, 1, 0, 1, 0, 1, 0]
    test "E(5,8)":
      check bjork(5, 8) == @[0, 1, 1, 0, 1, 1, 0, 1]
    test "E(7,8)":
      check bjork(7, 8) == @[0, 1, 1, 1, 1, 1, 1, 1]
    test "E(5,9)":
      check bjork(5, 9) == @[1, 0, 1, 0, 1, 0, 1, 0, 1]
    test "E(5,12)":
      check bjork(5, 12) == @[1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0]
    test "E(5,16)":
      check bjork(5, 16) == @[0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]
    test "E(7,16)":
      check bjork(7, 16) == @[1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0]
    test "E(9,16)":
      check bjork(9, 16) == @[0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1]
    test "E(10,16)":
      check bjork(10, 16) == @[0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1]
  suite "euclid":
    test "E(3,5)":
      check euclid(3, 5) == @[1, 0, 1, 0, 1]
      check euclid(3, 5, 1) == @[0, 1, 0, 1, 1]
