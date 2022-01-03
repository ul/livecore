## Feedback delay lines.

import frame, math

proc prime*(x: float, s: var float): float =
  result = s
  s = x
lift1(prime, float)

template defDelay(max_duration: static[Natural]) =
  ## Nim's array generics are PITA as they don't play nice with type inference
  ## and templates. `defDelay` avoids these problems for the cost of producing
  ## family of types instead of a single generic type.

  const N = max_duration.seconds

  type
    Delay = object
      cursor: int
      feedback: float
      buffer: array[N, float]
    `Delay max_duration`* {.inject.} = Delay

  proc delay*(x, dt: float, s: var Delay): float =
    ## https://pbat.ch/sndkit/vardelay/
    s.buffer[s.cursor] = x
    let
      dts = dt * SAMPLE_RATE
      dtsi = dts.floor
    var
      f = dtsi - dts
      i = s.cursor - dtsi.int
    if f < 0.0 or i < 0:
      f += 1.0
      i.dec
      while i < 0:
        i += N
    else:
      while i >= N:
        i -= N
    let
      n_1 = i
      n_0 = if unlikely(n_1 == 0): N - 1 else: n_1 - 1
      n_2 = if unlikely(n_1 == N - 1): 0 else: n_1 + 1
      n_3 = if unlikely(n_2 == N - 1): 0 else: n_2 + 1
      x_0 = s.buffer[n_0]
      x_1 = s.buffer[n_1]
      x_2 = s.buffer[n_2]
      x_3 = s.buffer[n_3]
      d = (f*f - 1.0) * 0.1666666666666667
      tmp_0 = (f + 1.0) * 0.5
      tmp_1 = 3.0 * d
      a = tmp_0 - 1.0 - d
      c = tmp_0 - tmp_1
      b = tmp_1 - f
    result = (a*x_0 + b*x_1 + c*x_2 + d*x_3) * f + x_1
    s.cursor.inc
    if unlikely(s.cursor >= N):
      s.cursor = 0

  lift2(delay, Delay)

  proc fb*(x, dt, k: float, s: var Delay): float =
    result = delay(x + k*s.feedback, dt, s)
    s.feedback = result

  lift3(fb, Delay)

defDelay(1)
defDelay(30)
