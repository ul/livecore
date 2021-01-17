## (Cross-)channel manipulation.

import frame, math

proc pan*(x, c: Frame): Frame =
  let l = x[0]
  let r = x[1]
  let c = c[0]
  result[0] = min(1.0, 1.0-c).sqrt * l + max(0.0,  -c).sqrt * r
  result[1] = max(0.0,     c).sqrt * l + min(1.0, 1+c).sqrt * r

proc left*(x: Frame): Frame =
  result[0] = x[0]

proc right*(x: Frame): Frame =
  result[1] = x[1]

proc flip*(x: Frame): Frame =
  result[0] = x[1]
  result[1] = x[0]
