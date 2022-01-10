## This module emulates SpectralTransform from sound-garden-0x2
## It's a wrong implementation of spectral transformation but as many other
## buggy things in SoundGarden and LiveCore it's capable of producing
## interesting sounds.

import math, ffi/mufft/fft

template defBadFFT*(window_size: static[Natural], hop_size: static[Natural]) =
  const window = hann(window_size)

  type
    TimeData = array[window_size, Complex]
    FrequencyData = array[window_size, Complex]

    Input = object
      cursor: int
      buffer: TimeData

    FFT = object
      plan: ptr mufft_plan_1d
      iplan: ptr mufft_plan_1d
      hop_cursor: int
      input: Input
      output: TimeData

    `BadFFT window_size`* {.inject.} = FFT

  proc write_sample(s: var Input, x: float) {.inline.} =
    s.buffer[s.cursor] = Complex(r: x, i: 0)
    s.cursor.inc
    if unlikely(s.cursor >= window_size):
      s.cursor = 0

  proc init*(s: var FFT) =
    mufft_free_plan_1d(s.plan)
    mufft_free_plan_1d(s.iplan)
    s.plan = mufft_create_plan_1d_c2c(window_size, MUFFT_FORWARD, 0)
    s.iplan = mufft_create_plan_1d_c2c(window_size, MUFFT_INVERSE, 0)

  proc fft(s: var FFT, timedata: var TimeData): FrequencyData =
    mufft_execute_plan_1d(s.plan, result.addr, timedata.addr)

  proc ifft(s: var FFT, freqdata: var FrequencyData): TimeData =
    mufft_execute_plan_1d(s.iplan, result.addr, freqdata.addr)

  template process*(x: float, s: var FFT; body: untyped): float =
    block:
      write_sample(s.input, x)

      s.hop_cursor.inc
      if unlikely(s.hop_cursor >= hop_size):
        s.hop_cursor = 0
        var w: TimeData
        for i in 0..<window_size:
          w[i] = window[i] * s.input.buffer[(s.input.cursor + i) mod window_size]
        var frequency_data {.inject.} = fft(s, w)
        body
        s.output = ifft(s, frequency_data)

      s.output[window_size - hop_size + s.hop_cursor].r
