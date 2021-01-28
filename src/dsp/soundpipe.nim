## https://pbat.ch/proj/soundpipe.html

import frame, random, ffi/soundpipe

type SP = soundpipe.data

var sp: ptr SP

proc sp_create*() =
  sp = cast[ptr SP](SP.sizeof.alloc)
  sp.sr = SAMPLE_RATE_INT
  sp.rand = rand(uint32)

proc sp_destroy*() =
  sp.dealloc

template sp_t(name, T) =
  type T* = object
    p: soundpipe.name
    ready: bool

template sp_init(name, s) =
  if unlikely(not s.ready):
    discard `name init`(sp, s.p.addr)
    s.ready = true

template sp_compute(name, s, x) =
  var i, o: cfloat
  i = x
  discard `name compute`(sp, s.p.addr, i.addr, o.addr)
  result = o

template sp_compute(name, s) = sp_compute(name, s, 0.0)

template sp_lift_bi(name, T) =
  ## Lift SP module.
  sp_t(name, T)
  proc name*(s: var T): float =
    sp_init(name, s)
    sp_compute(name, s)
    result = result.bi
  lift0(name, T)

template spi_lift(name, T) =
  ## Lift SP module generated with input expected.
  sp_t(name, T)
  proc name*(x: float, s: var T): float =
    sp_init(name, s)
    sp_compute(name, s, x)
  lift1(name, T)

template spi_lift(name, T, a) =
  ## Lift SP module generated with input expected.
  sp_t(name, T)
  proc name*(x, a: float, s: var T): float =
    sp_init(name, s)
    s.p.a = a
    sp_compute(name, s, x)
  lift2(name, T)

template spi_lift(name, T, a, b) =
  ## Lift SP module generated with input expected.
  sp_t(name, T)
  proc name*(x, a, b: float, s: var T): float =
    sp_init(name, s)
    s.p.a = a
    s.p.b = b
    sp_compute(name, s, x)
  lift3(name, T)

template spi_lift(name, T, a, b, c) =
  ## Lift SP module generated with input expected.
  sp_t(name, T)
  proc name*(x, a, b, c: float, s: var T): float =
    sp_init(name, s)
    s.p.a = a
    s.p.b = b
    s.p.c = c
    sp_compute(name, s, x)
  lift4(name, T)

template spf_lift(name, T, a) =
  ## Lift SP module generated from Faust.
  ## The difference is that parameters are float pointers rather than floats.
  sp_t(name, T)
  proc name*(a: float, s: var T): float =
    sp_init(name, s)
    s.p.a[] = a
    sp_compute(name, s)
  lift1(name, T)

template spf_lift(name, T, a, b) =
  ## Lift SP module generated from Faust.
  ## The difference is that parameters are float pointers rather than floats.
  sp_t(name, T)
  proc name*(a, b: float, s: var T): float =
    sp_init(name, s)
    s.p.a[] = a
    s.p.b[] = b
    sp_compute(name, s)
  lift2(name, T)

template spif_lift(name, T, a, b, c) =
  ## Lift SP module generated from Faust with input expected.
  ## The difference is that parameters are float pointers rather than floats.
  sp_t(name, T)
  proc name*(x, a, b, c: float, s: var T): float =
    sp_init(name, s)
    s.p.a[] = a
    s.p.b[] = b
    s.p.c[] = c
    sp_compute(name, s, x)
  lift4(name, T)

template spif_lift(name, T, a, b, c, d) =
  ## Lift SP module generated from Faust with input expected.
  ## The difference is that parameters are float pointers rather than floats.
  sp_t(name, T)
  proc name*(x, a, b, c, d: float, s: var T): float =
    sp_init(name, s)
    s.p.a[] = a
    s.p.b[] = b
    s.p.c[] = c
    s.p.d[] = d
    sp_compute(name, s, x)
  lift5(name, T)

### SoundPipe modules.

spf_lift(blsaw, BlSaw, freq)
spf_lift(blsquare, BlSquare, freq, width)
spf_lift(bltriangle, BlTriangle, freq)
spif_lift(autowah, AutoWah, wah, mix, level)

# bitdepth 1-16
spi_lift(bitcrush, BitCrush, bitdepth, srate)

# ratio: Ratio to compress with, a value > 1 will compress
# thresh: Threshold (in dB) 0 = max
# atk: Compressor attack, try 0.1
# rel: Compressor release, try 0.1
spif_lift(compressor, Compressor, ratio, thresh, atk, rel)

# input is a trigger
spi_lift(clock, Clock, bpm, subdiv)
sp_lift_bi(pinknoise, PinkNoise)
sp_lift_bi(brown, BrownNoise)
spi_lift(diode, Diode, freq, res)
spi_lift(jcrev, JCRev)
# input is a trigger
spi_lift(maygate, MayGate, prob)

# atk: Attack time, in seconds, try 0.01
# rel: Release time, in seconds, try 0.1
# thresh: Threshold, in dB
spi_lift(peaklim, PeakLimiter, atk, rel, thresh)

# bigverb is one of the rare stereo modules in SP, doesn't warrant template yet

type BigVerb* = object
   p: soundpipe.bigverb
   ready: bool

proc bigverb*(x, feedback, lpfreq: Frame, s: var BigVerb): Frame =
  ## NB Only the left channel of feedback and lpfreq is used.
  ## feedback = 0.97;
  ## lpfreq   = 10000;
  if unlikely(not s.ready):
    discard bigverb_init(sp, s.p.addr)
    s.ready = true
  var i0, i1, o0, o1: cfloat
  i0 = x[0]
  i0 = x[1]
  s.p.feedback = feedback[0]
  s.p.lpfreq = lpfreq[0]
  discard bigverb_compute(sp, s.p.addr, i0.addr, i1.addr, o0.addr, o1.addr)
  result[0] = o0
  result[1] = o1
