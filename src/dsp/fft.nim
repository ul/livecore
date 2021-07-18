## Primitives for fft-based effects.

import math, ffi/kissfft/kissfft

type
  InputBuffer[W: static[Natural]] = object
    cursor: int
    buffer: array[W, float]

  OutputBuffer[W, H: static[Natural]] = object
    read_cursor, write_cursor: int
    buffer: array[W+H, float]

  Window*[W, H: static[Natural]] = object
    hop_cursor: int
    input: InputBuffer[W]
    output: OutputBuffer[W, H]

proc write_input[N: static[Natural]](s: var InputBuffer[N], x: float) =
  s.buffer[s.cursor] = x
  s.cursor += 1
  if unlikely(s.cursor >= N):
    s.cursor = 0

proc read_input[N: static[Natural]](s: InputBuffer[N]): array[N, float] =
  var j = s.cursor
  for i in 0..<N:
    result[i] = s.buffer[j]
    j += 1
    if unlikely(j >= N):
      j = 0

proc write_output[W, H: static[Natural]](s: var OutputBuffer[W, H], output: array[W, float]) =
  const N = W+H
  var cursor = s.write_cursor
  for x in output:
    # s.buffer[cursor] = x
    s.buffer[cursor] += x
    cursor += 1
    if unlikely(cursor >= N):
      cursor = 0
  s.write_cursor = (s.write_cursor + H) mod N

proc read_output[W, H: static[Natural]](s: var OutputBuffer[W, H]): float =
  const N = W+H
  result = s.buffer[s.read_cursor]
  s.buffer[s.read_cursor] = 0.0
  s.read_cursor += 1
  if unlikely(s.read_cursor >= N):
    s.read_cursor = 0

# Caller is responsible for handling lifecycle (and transforming input on hop) as we don't want to mess with closures.
# w.write(x)
# if w.hop:
#   w.update(f(w.window))
# w.read

proc write*[W, H: static[Natural]](s: var Window[W, H], x: float) =
  write_input[W](s.input, x)
  s.hop_cursor += 1
  if unlikely(s.hop_cursor >= H):
    s.hop_cursor = 0

proc read*[W, H: static[Natural]](s: var Window[W, H]): float = read_output[W, H](s.output)
proc hop*[W, H: static[Natural]](s: Window[W, H]): bool = s.hop_cursor == 0
proc window*[W, H: static[Natural]](s: Window[W, H]): array[W, float] = read_input[W](s.input)
proc update*[W, H: static[Natural]](s: var Window[W, H], output: array[W, float]) = write_output[W, H](s.output, output)

type
  Complex* = kiss_fft_cpx
  # N must be even
  FFT*[N: static[Natural]] = object
    ready: bool
    cfg: kiss_fftr_cfg
    icfg: kiss_fftr_cfg
    mem: array[6*N + 72, uint64] # TODO Make a better guess.
    imem: array[6*N + 72, uint64]

proc init*[N: static[Natural]](s: var FFT[N]) =
  if not s.ready:
    var lenmem = cast[csize_t](s.mem.sizeof)
    var ilenmem = cast[csize_t](s.imem.sizeof)
    s.cfg = kiss_fftr_alloc(N, 0, s.mem.addr, lenmem.addr)
    s.icfg = kiss_fftr_alloc(N, 1, s.imem.addr, ilenmem.addr)
    s.ready = true

proc fft*[N: static[Natural]](s: var FFT[N], timedata: array[N, float]): array[(N div 2) + 1, Complex] =
  var t: array[N, kiss_fft_scalar]
  for i in 0..<N:
    t[i] = timedata[i]
  kiss_fftr(s.cfg, cast[ptr kiss_fft_scalar](t.addr), cast[ptr kiss_fft_cpx](result.addr))

proc ifft*[N: static[Natural]](s: var FFT[N], freqdata: var array[(N div 2) + 1, Complex]): array[N, float] =
  var t: array[N, kiss_fft_scalar]
  kiss_fftri(s.icfg, cast[ptr kiss_fft_cpx](freqdata.addr), cast[ptr kiss_fft_scalar](t.addr))
  const norm = 1.0 / N.toFloat
  for i in 0..<N:
    result[i] = norm * t[i]
