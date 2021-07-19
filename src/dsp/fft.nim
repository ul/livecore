## Overlap-add FFT transform.

import math, ffi/kissfft/kissfft

type Complex* = kiss_fft_cpx

proc hann*(N: static[Natural]): array[N, float] =
  let k = PI / N.toFloat
  for n in 0..<N:
    let x = sin(k * n.toFloat)
    result[n] = x * x

template defFFT*(W) =
  ## `W` is window size and must be even.
  ## Generated type will be `FFT_W` with `init` and `process` "methods" available.
  ## Hop size is 1/16 of window size.
  ## Applies Hann window to the input before passing to forward FFT.
  ##
  ## Nim's array generics are PITA as they don't play nice with type inference
  ## and templates. `defFFT` avoids these problems for the cost of producing
  ## family of types instead of a single generic type.

  const
    H = W div 16
    N = W+H
    window = hann(W)

  type
    Input = object
      cursor: int
      buffer: array[W, float]

    Output = object
      read_cursor, write_cursor: int
      buffer: array[W+H, float]

    FFT = object
      ready: bool
      cfg: kiss_fftr_cfg
      icfg: kiss_fftr_cfg
      mem: array[6*W + 72, uint64] # TODO Make a better guess.
      imem: array[6*W + 72, uint64]
      hop_cursor: int
      input: Input
      output: Output

    `FFT W`* {.inject.} = FFT

  proc write_input(s: var Input, x: float) {.inline.} =
    s.buffer[s.cursor] = x
    s.cursor += 1
    if unlikely(s.cursor >= W):
      s.cursor = 0

  proc read_input(s: Input): array[W, float] {.inline.} =
    var j = s.cursor
    for i in 0..<W:
      result[i] = window[i] * s.buffer[j]
      j += 1
      if unlikely(j >= W):
        j = 0

  proc write_output(s: var Output, a: array[W, float]) {.inline.} =
    var cursor = s.write_cursor
    for x in a:
      s.buffer[cursor] += x
      cursor += 1
      if unlikely(cursor >= N):
        cursor = 0
    s.write_cursor = (s.write_cursor + H) mod N

  proc read_output(s: var Output): float {.inline.} =
    result = s.buffer[s.read_cursor]
    s.buffer[s.read_cursor] = 0.0
    s.read_cursor += 1
    if unlikely(s.read_cursor >= N):
      s.read_cursor = 0

  proc init*(s: var FFT) =
    if not s.ready:
      var lenmem = cast[csize_t](s.mem.sizeof)
      var ilenmem = cast[csize_t](s.imem.sizeof)
      s.cfg = kiss_fftr_alloc(W, 0, s.mem.addr, lenmem.addr)
      s.icfg = kiss_fftr_alloc(W, 1, s.imem.addr, ilenmem.addr)
      s.output.write_cursor = H
      s.ready = true

  proc fft(s: var FFT, timedata: array[W, float]): array[(W div 2) + 1, Complex] =
    # Copying via assignment is necessary as apparently array[N, float] and
    # array[N, cfloat] have different memory representation.
    var t: array[W, kiss_fft_scalar]
    for i in 0..<W:
      t[i] = timedata[i]
    kiss_fftr(s.cfg, cast[ptr kiss_fft_scalar](t.addr), cast[ptr kiss_fft_cpx](result.addr))

  proc ifft(s: var FFT, freqdata: var array[(W div 2) + 1, Complex]): array[W, float] =
    # Copying via assignment is necessary as apparently array[N, float] and
    # array[N, cfloat] have different memory representation.
    var t: array[W, kiss_fft_scalar]
    kiss_fftri(s.icfg, cast[ptr kiss_fft_cpx](freqdata.addr), cast[ptr kiss_fft_scalar](t.addr))
    # 8 to compensate overlap
    const norm = 1.0 / (8 * W).toFloat # TODO Double-check that this is correct norm factor.
    for i in 0..<W:
      result[i] = norm * t[i]

  template process*(x: float, s: FFT; f, body: untyped): float =
    block:
      write_input(s.input, x)

      s.hop_cursor += 1
      if unlikely(s.hop_cursor >= H):
        s.hop_cursor = 0
        var w = read_input(s.input)
        var f = fft(s, w)
        body
        var t = ifft(s, f)
        write_output(s.output, t)

      read_output(s.output)

defFFT(128)
defFFT(256)
defFFT(512)
defFFT(1024)
defFFT(2048)
defFFT(4096)
defFFT(8192)
defFFT(16384)
defFFT(32768)
