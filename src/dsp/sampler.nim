## Interpolating table reader/writer.

import frame, math

type Sampler*[N: static[Natural]] = object
  cursor, length*: int
  table: array[N, float]

proc read_table*[N: static[Natural]](index: float, s: var Sampler[N]): float =
  ## index [0, 1)
  let
    L = s.length
    norm_index = if index >= 0: index mod 1.0 else: 1.0 - (index mod 1.0)
    z = (norm_index * L.float).split_decimal
    f = z[1]
    n_1 = z[0].int
    n_0 = if unlikely(n_1 == 0): L - 1 else: n_1 - 1
    n_2 = if unlikely(n_1 == L - 1): 0 else: n_1 + 1
    n_3 = if unlikely(n_2 == L - 1): 0 else: n_2 + 1
    x_0 = s.table[n_0]
    x_1 = s.table[n_1]
    x_2 = s.table[n_2]
    x_3 = s.table[n_3]
    d = (f*f - 1.0) * 0.1666666666666667
    tmp_0 = (f + 1.0) * 0.5
    tmp_1 = 3.0 * d
    a = tmp_0 - 1.0 - d
    c = tmp_0 - tmp_1
    b = tmp_1 - f
  result = (a*x_0 + b*x_1 + c*x_2 + d*x_3) * f + x_1

proc read_table_stereo*[N: static[Natural]](index: Frame, s: var array[CHANNELS, Sampler[N]]): Frame =
  for i in 0..<CHANNELS:
    result[i] = read_table[N](index[i], s[i])

proc write_table*[N: static[Natural]](x, trigger: float, s: var Sampler[N]): float =
  result = x
  if unlikely(trigger > 0.0):
    s.cursor = 0
  if s.cursor < s.length:
    s.table[s.cursor] = x
    s.cursor += 1

proc write_table_stereo*[N: static[Natural]](x, trigger: Frame, s: var array[CHANNELS, Sampler[N]]): Frame =
  for i in 0..<CHANNELS:
    result[i] = write_table[N](x[i], trigger[i], s[i])
