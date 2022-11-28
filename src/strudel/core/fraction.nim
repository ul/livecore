import std/[math, rationals]
export rationals

type Fraction* = Rational[int]

func floor*(x: Fraction): Fraction =
  ## Smallest integer not greater than `x`.
  floor_div(x.num, x.den).to_rational

func sam*(x: Fraction): Fraction =
  ## Returns the start of the cycle.
  floor_div(x.num, x.den).to_rational

func next_sam*(x: Fraction): Fraction =
  ## Returns the start of the next cycle.
  x.sam + 1

func cycle_pos*(x: Fraction): Fraction =
  ## The position of a time value relative to the start of its cycle.
  x - x.sam

converter to_fraction*(x: int): Fraction = x.to_rational
converter to_fraction*(x: float): Fraction = x.to_rational

when isMainModule:
  import std/unittest
  suite "Fraction":
    test "convert int to fraction":
      check 1 == 1.to_rational
    test "floor":
      check floor(3//2) == 1
    test "sam":
      check sam(3//2) == 1
    test "next_sam":
      check next_sam(3//2) == 2
    test "cycle_pos":
      check cycle_pos(3//2) == 1//2
