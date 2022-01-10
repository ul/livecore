## OLS FFT transform.

import math, ffi/mufft/fft

type Complex* = mufft_cpx

proc magnitude*(x: Complex): float = sqrt(x.r^2 + x.i^2)
proc phase*(x: Complex): float = arctan2(x.i, x.r)
proc polarize*(magnitude, phase: float): Complex = Complex(r: magnitude*cos(
    phase), i: magnitude*sin(phase))

proc hann*(N: static[Natural]): array[N, float] =
  let k = PI / N.float
  for n in 0..<N:
    let x = sin(k * n.float)
    result[n] = x * x

proc fft_bins*(N: static[Natural]): array[N, float] =
  let k = TAU / N.float
  for n in 0..<N:
    result[n] = k * n.float

proc wrap_phase(x: float): float =
  let p = copy_sign(PI, x)
  ((x + p) mod (2 * p)) - p

template defFFT*(window_size: static[Natural]) =
  ## `window_size` must be a power of two.
  ## Generated type will be `FFT_{window_size}` with `init`, `resynth` and `process` "methods" available.
  ## Hop size is 1/16 of window size.
  ## Applies Hann window to the input before passing to forward FFT.
  ##
  ## Nim's array generics are PITA as they don't play nice with type inference
  ## and templates. `defFFT` avoids these problems for the cost of producing
  ## family of types instead of a single generic type.

  const
    overlap_factor = 16 # How many times to transform within a window?
    hop_size = window_size div overlap_factor
    # Lower half of the spectrum. The upper half is just
    # the complex conjugate and does not contain any unique information.
    fft_size = (window_size div 2) + 1
    # To keep amplitude the same during resynth we should compensate for window loss and overlap gain.
    hann_window_scale_factor = 2.0
    overlap_scale_factor = 1.0 / overlap_factor.float
    # TODO: figure out why do we need 1.5 to even amplitude with the source!
    output_scale_factor = 1.5 * hann_window_scale_factor * overlap_scale_factor
    output_buffer_size = 16 * window_size # Minimum is window_size + hop_size but let's have some leeway.
    norm = sqrt(1.0 / window_size.float) # muFFT returns non-normalized from both forward and inverse transformations.
    window = hann(window_size)
    bin_frequencies = fft_bins(window_size)

  type
    TimeData = array[window_size, cfloat]
    FrequencyData = array[fft_size, Complex]
    ReSynthData = array[fft_size, float]

    Input = object
      cursor: int
      buffer: TimeData

    Output = object
      read_cursor, write_cursor: int
      buffer: array[output_buffer_size, float]

    FFT = object
      ready: bool
      plan: ptr mufft_plan_1d
      iplan: ptr mufft_plan_1d
      hop_cursor: int
      input: Input
      output: Output
      last_input_phases: ReSynthData
      last_output_phases: ReSynthData

    `FFT window_size`* {.inject.} = FFT

  proc write_input_sample(s: var Input, x: float) {.inline.} =
    s.buffer[s.cursor] = x
    s.cursor.inc
    if unlikely(s.cursor >= window_size):
      s.cursor = 0

  proc read_input_window(s: Input): TimeData {.inline.} =
    var j = s.cursor
    for i in 0..<window_size:
      result[i] = window[i] * s.buffer[j]
      j.inc
      if unlikely(j >= window_size):
        j = 0

  proc write_output_window(s: var Output, a: TimeData) {.inline.} =
    var cursor = s.write_cursor
    for i in 0..<window_size:
      s.buffer[cursor] += window[i] * a[i]
      cursor.inc
      if unlikely(cursor >= output_buffer_size):
        cursor = 0
    s.write_cursor = (s.write_cursor + hop_size) mod output_buffer_size

  proc read_output_sample(s: var Output): float {.inline.} =
    result = s.buffer[s.read_cursor] * output_scale_factor
    s.buffer[s.read_cursor] = 0.0
    s.read_cursor.inc
    if unlikely(s.read_cursor >= output_buffer_size):
      s.read_cursor = 0

  proc init*(s: var FFT) =
    mufft_free_plan_1d(s.plan)
    mufft_free_plan_1d(s.iplan)
    s.plan = mufft_create_plan_1d_r2c(window_size, 0)
    s.iplan = mufft_create_plan_1d_c2r(window_size, 0)
    if not s.ready:
      s.output.write_cursor = hop_size
      for n in 0..<fft_size:
        s.last_input_phases[n] = 0.0
        s.last_output_phases[n] = 0.0
      s.ready = true

  proc fft(s: var FFT, timedata: var TimeData): FrequencyData =
    mufft_execute_plan_1d(s.plan, result.addr, timedata.addr)
    for i in 0..<window_size:
      result[i] *= norm

  proc ifft(s: var FFT, freqdata: var FrequencyData): TimeData =
    mufft_execute_plan_1d(s.iplan, result.addr, freqdata.addr)
    for i in 0..<window_size:
      result[i] *= norm

  template resynth*(x: float, s: var FFT; body: untyped): float =
    block:
      write_input_sample(s.input, x)

      s.hop_cursor.inc
      if unlikely(s.hop_cursor >= hop_size):
        s.hop_cursor = 0
        var w = read_input_window(s.input)
        var f = fft(s, w)
        var analysis_frequencies {.inject.},
          analysis_magnitudes {.inject.},
          synthesis_frequencies {.inject.},
          synthesis_magnitudes {.inject.}: ReSynthData
        for n in 0..<fft_size:
          let amplitude = f[n].magnitude
          let phase = f[n].phase
          # Calculate the phase difference in this bin between the last
          # hop and this one, which will indirectly give us the exact frequency.
          var phase_diff = phase - s.last_input_phases[n]
          # Subtract the amount of phase increment we'd expect to see based
          # on the centre frequency of this bin (2*pi*n/window_size) for this
          # hop size, then wrap to the range -pi to pi.
          phase_diff = wrap_phase(phase_diff - bin_frequencies[n] *
              hop_size.float)
          # Find deviation from the centre frequency.
          let frequency_deviation = phase_diff / hop_size.float
          # Add the original bin number to get the fractional bin where this partial belongs.
          analysis_frequencies[n] = bin_frequencies[n] + frequency_deviation
          analysis_magnitudes[n] = amplitude
          s.last_input_phases[n] = phase

        copy_mem(synthesis_frequencies.addr, analysis_frequencies.addr, ReSynthData.sizeof)
        copy_mem(synthesis_magnitudes.addr, analysis_magnitudes.addr, ReSynthData.sizeof)

        body

        for n in 0..<fft_size:
          let phase_diff = synthesis_frequencies[n] * hop_size.float
          let out_phase = wrap_phase(s.last_output_phases[n] + phase_diff)
          f[n] = polarize(synthesis_magnitudes[n], out_phase)
          s.last_output_phases[n] = out_phase

        var t = ifft(s, f)
        write_output_window(s.output, t)

      read_output_sample(s.output)

  template process*(x: float, s: var FFT; body: untyped): float =
    block:
      write_input_sample(s.input, x)

      s.hop_cursor.inc
      if unlikely(s.hop_cursor >= hop_size):
        s.hop_cursor = 0
        var w = read_input_window(s.input)
        var frequency_data {.inject.} = fft(s, w)
        body
        var t = ifft(s, frequency_data)
        write_output_window(s.output, t)

      read_output_sample(s.output)


defFFT(128)
defFFT(256)
defFFT(512)
defFFT(1024)
defFFT(2048)
defFFT(4096)
defFFT(8192)
defFFT(16384)
defFFT(32768)
