## UPOLS FFT convolution.

import
  atomics,
  locks,
  math,
  ffi/mufft/fft

template defFIR*(name: untyped, block_size: static[Natural], ir_path: static[string]) =
  ## `block_size` must be a power of two.
  ## `ir_path` is the path to the filter impulse response that have to be a binary
  ## array of `cfloat`. Sample rate must match LiveCore's too.
  ##
  ## ffmpeg -i ir.wav -map_channel 0.0.0 -f f32le -ar 48000 -acodec pcm_f32le ir.pcm
  ##
  ## Generated type will be `name` with `init` and `process` "methods" available.
  ## Call `init` in session's `load` and `process` *once* in session's `process`
  ## for each instance of the filter.

  const window_size = 2 * block_size
  const fft_size = block_size + 1
  const norm = 1.0 / window_size.float
  const kernel = ir_path.slurp
  const kernel_samples = kernel.len div cfloat.sizeof
  const sub_filters = (kernel_samples / block_size).ceil.int

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
      is_ready: bool
      plan: ptr mufft_plan_1d
      iplan: ptr mufft_plan_1d
      input: Input
      output: Output
      window: TimeData
      kernel_blocks: Blocks
      input_fdl: Blocks

    name* = Conv

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
    if s.is_ready:
      mufft_free_plan_1d(s.plan)
      mufft_free_plan_1d(s.iplan)
    s.plan = mufft_create_plan_1d_r2c(window_size, 0)
    s.iplan = mufft_create_plan_1d_c2r(window_size, 0)
    if not s.is_ready:
      let plan = mufft_create_plan_1d_r2c(window_size, MUFFT_FLAG_ZERO_PAD_UPPER_HALF)
      let ptr_kernel = cast[int](kernel.cstring)
      var td: TimeData
      for i in 0..<kernel_samples:
        let idx = i mod block_size
        td[idx] = cast[ptr cfloat](ptr_kernel + i * cfloat.sizeof)[]
        if idx == block_size - 1 or idx == kernel_samples - 1:
          mufft_execute_plan_1d(plan, s.kernel_blocks[i div block_size].addr, td.addr)
      mufft_free_plan_1d(plan)
      s.is_ready = true

  proc process*(x: float, s: var Conv): float =
    write_input_sample(s.input, x)

    if unlikely(s.output.cursor == 0):
      copy_mem(s.window[0].addr, s.window[block_size].addr, block_size * cfloat.sizeof)
      copy_mem(s.window[block_size].addr, s.input.buffer[0].addr, block_size * cfloat.sizeof)
      move_mem(s.input_fdl[1].addr, s.input_fdl[0].addr, (sub_filters-1) * FrequencyData.sizeof)

      mufft_execute_plan_1d(s.plan, s.input_fdl[0].addr, s.window.addr)

      var fd: FrequencyData
      for i in 0..<fft_size:
        for j in 0..<sub_filters:
          fd[i] += s.kernel_blocks[j][i] * s.input_fdl[j][i]

      var td: TimeData
      mufft_execute_plan_1d(s.iplan, td.addr, fd.addr)

      for i in 0..<block_size:
        s.output.buffer[i] = norm * td[i + block_size]

    read_output_sample(s.output)

template defFIRParallel*(name: untyped, block_size: static[Natural], ir_path: static[string]) =
  ## `block_size` must be a power of two.
  ## `ir_path` is the path to the filter impulse response that have to be a binary
  ## array of `cfloat`. Sample rate must match LiveCore's too.
  ##
  ## ffmpeg -i ir.wav -map_channel 0.0.0 -f f32le -ar 48000 -acodec pcm_f32le ir.pcm
  ##
  ## Generated type will be `name` with `init` and `process` "methods" available.
  ## Call `init` in session's `load` and `process` *once* in session's `process`
  ## for each instance of the filter.

  const window_size = 2 * block_size
  const fft_size = block_size + 1
  const norm = 1.0 / window_size.float
  const kernel = ir_path.slurp
  const kernel_samples = kernel.len div cfloat.sizeof
  const sub_filters = (kernel_samples / block_size).ceil.int

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
      is_ready: bool
      plan: ptr mufft_plan_1d
      iplan: ptr mufft_plan_1d
      input: Input
      outputs: array[2, Output]
      window: TimeData
      kernel_blocks: Blocks
      input_fdl: Blocks
      active_output: Atomic[int]
      fft_thread: Thread[ptr Conv]
      fft_cond: Cond
      fft_lock: Lock

    name* = Conv

  proc fft_process(s: ptr Conv) {.thread, nimcall.} =
    while true:
      s.fft_cond.wait(s.fft_lock)

      move_mem(s.input_fdl[1].addr, s.input_fdl[0].addr, (sub_filters-1) * FrequencyData.sizeof)

      mufft_execute_plan_1d(s.plan, s.input_fdl[0].addr, s.window.addr)

      var fd: FrequencyData
      for i in 0..<fft_size:
        for j in 0..<sub_filters:
          fd[i] += s.kernel_blocks[j][i] * s.input_fdl[j][i]

      var td: TimeData
      mufft_execute_plan_1d(s.iplan, td.addr, fd.addr)

      let inactive_output = 1 - s.active_output.load
      for i in 0..<block_size:
        s.outputs[inactive_output].buffer[i] = norm * td[i + block_size]

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
    if not s.is_ready:
      let plan = mufft_create_plan_1d_r2c(window_size, MUFFT_FLAG_ZERO_PAD_UPPER_HALF)
      let ptr_kernel = cast[int](kernel.cstring)
      var td: TimeData
      for i in 0..<kernel_samples:
        let idx = i mod block_size
        td[idx] = cast[ptr cfloat](ptr_kernel + i * cfloat.sizeof)[]
        if idx == block_size - 1 or idx == kernel_samples - 1:
          mufft_execute_plan_1d(plan, s.kernel_blocks[i div block_size].addr, td.addr)
      mufft_free_plan_1d(plan)
      s.fft_cond.init_cond
      s.fft_lock.init_lock
      s.fft_thread.create_thread(fft_process, cast[ptr Conv](s.addr))
      s.is_ready = true

  proc process*(x: float, s: var Conv): float =
    write_input_sample(s.input, x)

    let active_output = s.active_output.load
    if unlikely(s.outputs[active_output].cursor == 0):
      s.active_output.store(1 - active_output)

      copy_mem(s.window[0].addr, s.window[block_size].addr, block_size * cfloat.sizeof)
      copy_mem(s.window[block_size].addr, s.input.buffer[0].addr, block_size * cfloat.sizeof)

      s.fft_cond.signal

    read_output_sample(s.outputs[s.active_output.load])

defFIRParallel(SpringReverb, 1024, "reverb/SpringReverbIR.pcm")
defFIRParallel(ChandaReverb, 1024, "reverb/Chanda2048.pcm")
defFIRParallel(ChurhSchellingwoudeReverb, 1024, "reverb/Church Schellingwoude.pcm")
defFIRParallel(HandDhalReverb, 1024, "reverb/Hand-Dhal-1.pcm")
defFIRParallel(SmallPrehistoricCaveReverb, 1024, "reverb/SmallPrehistoricCave.pcm")
defFIRParallel(StNicolaesChurchReverb, 1024, "reverb/StNicolaesChurch.pcm")
defFIRParallel(AyotteSdH06Reverb, 1024, "reverb/cAyotte Sd H06  x.pcm")
defFIRParallel(HiliteSdH04Reverb, 1024, "reverb/cHilite Sd H04  x.pcm")
defFIRParallel(SonorTomR05Reverb, 1024, "reverb/cSonor Tom 2 R05.pcm")
defFIRParallel(HamiltonMausoleumReverb, 1024, "reverb/hamilton_mausoleum.pcm")
defFIRParallel(RissetDrumReverb, 1024, "reverb/risset_drum.pcm")
defFIRParallel(SineSweepReverb, 1024, "reverb/sine_sweep.pcm")
