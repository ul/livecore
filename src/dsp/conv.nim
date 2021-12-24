## FFT convolution of two inputs.

import ffi/mufft/fft

template defConv*(block_size, sub_filters: static[Natural]) =
  ## `block_size` must be a power of two.
  ## `sub_filters` is the number of blocks contributing into convolution as UPOLS subfilters.
  ##
  ## Generated type will be `Conv_{block_size}x{sub_filters}` with `init` and `process` "methods" available.
  ## Call `init` in session's `load` and `process` *once* in session's `process`
  ## for each instance of the filter.

  const window_size = 2 * block_size
  const fft_size = block_size + 1
  const norm = 1.0 / window_size.float

  type
    TimeData = array[window_size, cfloat]
    FrequencyData = array[fft_size, mufft_cpx]
    Blocks = array[sub_filters, FrequencyData]

    Input = object
      cursor: int
      buffer: TimeData

    Output = object
      cursor: int
      buffer: array[block_size, float]

    Conv = object
      plan: ptr mufft_plan_1d
      iplan: ptr mufft_plan_1d
      inputs: array[2, Input]
      windows: array[2, TimeData]
      inputs_fdl: array[2, Blocks]
      output: Output

    `Conv block_size x sub_filters`* {.inject.} = Conv

  proc write_input_sample(s: var Input, x: float) {.inline.} =
    s.buffer[s.cursor] = x
    s.cursor += 1
    if unlikely(s.cursor >= window_size):
      s.cursor = 0

  proc read_output_sample(s: var Output): float {.inline.} =
    result = s.buffer[s.cursor]
    s.cursor += 1
    if unlikely(s.cursor >= block_size):
      s.cursor = 0

  proc init*(s: var Conv) =
    mufft_free_plan_1d(s.plan)
    mufft_free_plan_1d(s.iplan)
    s.plan = mufft_create_plan_1d_r2c(window_size, 0)
    s.iplan = mufft_create_plan_1d_c2r(window_size, 0)

  proc process*(x, y: float, s: var Conv): float =
    write_input_sample(s.inputs[0], x)
    write_input_sample(s.inputs[1], y)

    if unlikely(s.output.cursor == 0):
      for n in 0..1:
        for i in 0..<block_size:
          s.windows[n][i] = s.windows[n][i + block_size]
          s.windows[n][i + block_size] = s.inputs[n].buffer[i]

        for i in countdown(sub_filters-1, 1):
          s.inputs_fdl[n][i] = s.inputs_fdl[n][i-1]

        mufft_execute_plan_1d(s.plan, s.inputs_fdl[n][0].addr, s.windows[n].addr)

      var fd: FrequencyData
      for i in 0..<sub_filters:
        for j in 0..<fft_size:
          # TODO Interleave inputs_fdl to make it cache-friendly?
          fd[j] += s.inputs_fdl[0][i][j] * s.inputs_fdl[1][i][j]

      var td: TimeData
      mufft_execute_plan_1d(s.iplan, td.addr, fd.addr)

      for i in 0..<block_size:
        s.output.buffer[i] = norm * td[i + block_size]

    read_output_sample(s.output)

defConv(128, 64)
defConv(256, 64)
defConv(512, 64)
defConv(1024, 64)
defConv(2048, 64)
defConv(4096, 64)
defConv(8192, 64)
defConv(16384, 64)
defConv(32768, 64)