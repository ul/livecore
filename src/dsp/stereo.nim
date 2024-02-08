## (Cross-)channel manipulation.

import
  std/math,
  delays,
  frame

proc pan*(x: Frame, c: float): Frame =
  let l = x[0]
  let r = x[1]
  result[0] = min(1.0, 1.0-c).sqrt * l + max(0.0, -c).sqrt * r
  result[1] = max(0.0, c).sqrt * l + min(1.0, 1+c).sqrt * r

proc left*(x: Frame): Frame =
  result[0] = x[0]

proc right*(x: Frame): Frame =
  result[1] = x[1]

proc flip*(x: Frame): Frame =
  result[0] = x[1]
  result[1] = x[0]

proc stereo_width*(x: Frame, w: float): Frame =
  let a = 0.5 * (1.0 + w)
  let b = 0.5 * (1.0 - w)
  result[0] = a*x[0] + b*x[1]
  result[1] = b*x[0] + a*x[1]

proc mono_width*(x, w: float, s: var array[2, float]): Frame =
  var f: Frame = x
  f[0] = x.prime(s[0]).prime(s[1])
  stereo_width(f, w)
