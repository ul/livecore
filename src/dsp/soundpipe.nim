## https://pbat.ch/proj/soundpipe.html

import
  std/random,
  frame,
  ffi/soundpipe

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
    is_ready: bool

template sp_init(name, s) =
  if unlikely(not s.is_ready):
    discard `name init`(sp, s.p.addr)
    s.is_ready = true

template sp_compute(name, s, x) =
  var i, o: cfloat
  i = x
  discard `name compute`(sp, s.p.addr, i.addr, o.addr)
  result = o

template sp_compute_stereo(name, s, x) =
  var i0, i1, o0, o1: cfloat
  i0 = x[0]
  i1 = x[1]
  discard `name compute`(sp, s.p.addr, i0.addr, i1.addr, o0.addr, o1.addr)
  result[0] = o0
  result[1] = o1

template sp_compute(name, s) = sp_compute(name, s, 0.0)

template sp_lift(name, T) =
  ## Lift SP module.
  sp_t(name, T)
  proc name*(s: var T): float =
    sp_init(name, s)
    sp_compute(name, s)
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

sp_lift(pinknoise, PinkNoise)
sp_lift(brown, BrownNoise)

spi_lift(diode, Diode, freq, res)
spi_lift(jcrev, JCRev)

# input is a trigger
spi_lift(maygate, MayGate, prob)

# atk: Attack time, in seconds, try 0.01
# rel: Release time, in seconds, try 0.1
# thresh: Threshold, in dB
spi_lift(peaklim, PeakLimiter, atk, rel, thresh)

spi_lift(peakeq, PeakEq, freq, bw, gain)

# shift: Pitch shift (in semitones), range -24/24.
# window: Window size (in samples), max 10000, try 1000
# xfade: Crossfade (in samples), max 10000, try 10
spif_lift(pshift, PShift, shift, window, xfade)

spi_lift(saturator, Saturator)

spi_lift(wpkorg35, WPKorg35, cutoff, res, saturation)

# Stereo modules.

sp_t(bigverb, BigVerb)
proc bigverb*(x: Frame, feedback, lpfreq: float, s: var BigVerb): Frame =
  ## feedback = 0.97;
  ## lpfreq   = 10000;
  sp_init(bigverb, s)
  s.p.feedback = feedback
  s.p.lpfreq = lpfreq
  sp_compute_stereo(bigverb, s, x)

sp_t(phaser, Phaser)
proc phaser*(
  x: Frame,
  MaxNotch1Freq, # 800, [20, 10000]
  MinNotch1Freq, # 100, [20, 5000]
  Notch_width, # 1000, [10, 5000]
  NotchFreq, # 1.5, [1.1, 4]
  VibratoMode, # 1, {0, 1}
  depth, # 1, [0, 1]
  feedback_gain, # 0, [0, 1]
  invert, # 0, {0, 1}
  level, # 0, [-60, 10] dB
  lfobpm: float, # 30, [24, 360]
  s: var Phaser): Frame =
  sp_init(phaser, s)
  s.p.MaxNotch1Freq[] = MaxNotch1Freq
  s.p.MinNotch1Freq[] = MinNotch1Freq
  s.p.Notch_width[] = Notch_width
  s.p.NotchFreq[] = NotchFreq
  s.p.VibratoMode[] = VibratoMode
  s.p.depth[] = depth
  s.p.feedback_gain[] = feedback_gain
  s.p.invert[] = invert
  s.p.level[] = level
  s.p.lfobpm[] = lfobpm
  sp_compute_stereo(phaser, s, x)

sp_t(zitarev, ZitaRev)
proc zitarev*(
  x: Frame,
  in_delay, # 60 ms
  lf_x, # 200 Hz
  rt60_low, # 3 s
  rt60_mid, # 2 s
  hf_damping, # 6000 Hz
  eq1_freq, # 315 Hz
  eq1_level, # 0 dB
  eq2_freq, # 1500 Hz
  eq2_level, # 0 dB
  mix, # 1, dry [0..1] wet
  level: float, # -20 dB
  s: var ZitaRev): Frame =
  sp_init(zitarev, s)
  s.p.in_delay[] = in_delay
  s.p.lf_x[] = lf_x
  s.p.rt60_low[] = rt60_low
  s.p.rt60_mid[] = rt60_mid
  s.p.hf_damping[] = hf_damping
  s.p.eq1_freq[] = eq1_freq
  s.p.eq1_level[] = eq1_level
  s.p.eq2_freq[] = eq2_freq
  s.p.eq2_level[] = eq2_level
  s.p.mix[] = mix
  s.p.level[] = level
  sp_compute_stereo(zitarev, s, x)
