## FFT convolution of two inputs.

import
  atomics,
  locks,
  ffi/mufft/fft

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
      inputs_fdl: array[2*sub_filters, FrequencyData]
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
        copy_mem(s.windows[n][0].addr, s.windows[n][block_size].addr, block_size * cfloat.sizeof)
        copy_mem(s.windows[n][block_size].addr, s.inputs[n].buffer[0].addr, block_size * cfloat.sizeof)

      move_mem(s.inputs_fdl[2].addr, s.inputs_fdl[0].addr, 2 * (sub_filters-1) * FrequencyData.sizeof)

      mufft_execute_plan_1d(s.plan, s.inputs_fdl[0].addr, s.windows[0].addr)
      mufft_execute_plan_1d(s.plan, s.inputs_fdl[1].addr, s.windows[1].addr)

      var fd: FrequencyData
      for i in 0..<fft_size:
        for j in 0..<sub_filters:
          fd[i] += s.inputs_fdl[2*j][i] * s.inputs_fdl[2*j+1][i]

      var td: TimeData
      mufft_execute_plan_1d(s.iplan, td.addr, fd.addr)

      for i in 0..<block_size:
        s.output.buffer[i] = norm * td[i + block_size]

    read_output_sample(s.output)


template defConvParallel*(block_size, sub_filters: static[Natural]) =
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
      inputs_fdl: array[2*sub_filters, FrequencyData]
      outputs: array[2, Output]
      active_output: Atomic[int]
      fft_thread: Thread[ptr Conv]
      fft_cond: Cond
      fft_lock: Lock
      is_ready: bool

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

  proc fft_process(s: ptr Conv) {.thread, nimcall.} =
    while true:
      s.fft_cond.wait(s.fft_lock)

      move_mem(s.inputs_fdl[2].addr, s.inputs_fdl[0].addr, 2 * (sub_filters-1) * FrequencyData.sizeof)

      mufft_execute_plan_1d(s.plan, s.inputs_fdl[0].addr, s.windows[0].addr)
      mufft_execute_plan_1d(s.plan, s.inputs_fdl[1].addr, s.windows[1].addr)

      var fd: FrequencyData
      for i in 0..<fft_size:
        for j in 0..<sub_filters:
          fd[i] += s.inputs_fdl[2*j][i] * s.inputs_fdl[2*j+1][i]

      var td: TimeData
      mufft_execute_plan_1d(s.iplan, td.addr, fd.addr)

      let inactive_output = 1 - s.active_output.load
      for i in 0..<block_size:
        s.outputs[inactive_output].buffer[i] = norm * td[i + block_size]


  proc init*(s: var Conv) =
    mufft_free_plan_1d(s.plan)
    mufft_free_plan_1d(s.iplan)
    s.plan = mufft_create_plan_1d_r2c(window_size, 0)
    s.iplan = mufft_create_plan_1d_c2r(window_size, 0)
    # TODO ensure threads and other resources don't leak
    # introduce deinit?
    if not s.is_ready:
      s.fft_cond.init_cond
      s.fft_lock.init_lock
      s.fft_thread.create_thread(fft_process, cast[ptr Conv](s.addr))
      s.is_ready = true

  proc process*(x, y: float, s: var Conv): float =
    write_input_sample(s.inputs[0], x)
    write_input_sample(s.inputs[1], y)

    let active_output = s.active_output.load
    if unlikely(s.outputs[active_output].cursor == 0):
      s.active_output.store(1 - active_output)

      for n in 0..1:
        copy_mem(s.windows[n][0].addr, s.windows[n][block_size].addr, block_size * cfloat.sizeof)
        copy_mem(s.windows[n][block_size].addr, s.inputs[n].buffer[0].addr, block_size * cfloat.sizeof)

      s.fft_cond.signal

    read_output_sample(s.outputs[s.active_output.load])


defConv(128, 64)
defConv(256, 64)
defConvParallel(512, 64)
defConvParallel(1024, 64)
defConvParallel(2048, 64)
defConvParallel(4096, 64)
defConvParallel(8192, 64)
defConvParallel(16384, 64)
defConvParallel(32768, 64)
