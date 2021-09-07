## Pooling makes state management easier when you don't need to micromanage state
## continuity.

import
  dsp/[
    frame, delays, envelopes, events, filters, metro, modules, noise, osc, soundpipe
  ]

const
  large_pool = 0x80
  medium_pool = 0x40
  small_pool = 0x10

type
  Data = object
    adsr: array[medium_pool, ADSR]
    autowah: array[medium_pool, AutoWah]
    bigverb: array[medium_pool, BigVerb]
    biquad: array[medium_pool, BiQuad]
    bitcrush: array[medium_pool, BitCrush]
    blsaw: array[medium_pool, BlSaw]
    blsquare: array[medium_pool, BlSquare]
    bltriangle: array[medium_pool, BlTriangle]
    brown_noise: array[medium_pool, BrownNoise]
    chaos_noise: array[medium_pool, ChaosNoise]
    choose: array[medium_pool, Choose]
    clock: array[medium_pool, Clock]
    compressor: array[medium_pool, Compressor]
    conv: array[medium_pool, Conv]
    delay: array[medium_pool, Delay1]
    diode: array[medium_pool, Diode]
    hpf: array[medium_pool, HPF]
    fms: array[medium_pool, array[2, float]]
    fm_blsaw: array[medium_pool, array[2, BlSaw]]
    fm_bltriangle: array[medium_pool, array[2, BlTriangle]]
    fm_blsquare: array[medium_pool, array[2, BlSquare]]
    jcrev: array[medium_pool, JCRev]
    long_delay: array[small_pool, Delay30]
    maygate: array[medium_pool, MayGate]
    metro: array[medium_pool, Metro]
    peaklim: array[medium_pool, PeakLimiter]
    phaser: array[medium_pool, Phaser]
    pink_noise: array[medium_pool, PinkNoise]
    pshift: array[medium_pool, PShift]
    rline: array[medium_pool, RLine]
    sample: array[large_pool, float]
    saturator: array[medium_pool, Saturator]
    sequence: array[medium_pool, int]
    transition: array[medium_pool, Transition]
    wpkorg35: array[medium_pool, WPKorg35]
    zitarev: array[medium_pool, ZitaRev]
  Index = object
    sample,
      adsr,
      autowah,
      bigverb,
      biquad,
      bitcrush,
      blsaw,
      blsquare,
      bltriangle,
      brown_noise,
      chaos_noise,
      choose,
      clock,
      compressor,
      conv,
      delay,
      diode,
      hpf,
      fms,
      fm_blsaw,
      fm_bltriangle,
      fm_blsquare,
      jcrev,
      long_delay,
      maygate,
      metro,
      peaklim,
      phaser,
      pink_noise,
      pshift,
      rline,
      saturator,
      sequence,
      transition,
      wpkorg35,
      zitarev: int
  Pool* = object
    data: Data
    index: Index

var pool: ptr Pool

proc init*(s: var Pool) =
  pool = s.addr
  pool.index.addr.zero_mem(Index.size_of)

template def0(op, t) =
  proc op*(): float =
    result = op(pool.data.t[pool.index.t])
    pool.index.t += 1
  lift0(op)

template def0(op) = def0(op, op)

template def1(op, t) =
  proc op*(a: float): float =
    result = op(a, pool.data.t[pool.index.t])
    pool.index.t += 1
  lift1(op)

template def1(op) = def1(op, op)

template def2(op, t) =
  proc op*(a, b: float): float =
    result = op(a, b, pool.data.t[pool.index.t])
    pool.index.t += 1
  lift2(op)

template def2(op) = def2(op, op)

template def3(op, t) =
  proc op*(a, b, c: float): float =
    result = op(a, b, c, pool.data.t[pool.index.t])
    pool.index.t += 1
  lift3(op)

template def3(op) = def3(op, op)

template def4(op) =
  proc op*(a, b, c, d: float): float =
    result = op(a, b, c, d, pool.data.op[pool.index.op])
    pool.index.op += 1
  lift4(op)

template def5(op) =
  proc op*(a, b, c, d, e: float): float =
    result = op(a, b, c, d, e, pool.data.op[pool.index.op])
    pool.index.op += 1
  lift5(op)

def0(brown, brown_noise)
def0(pink_noise)
def1(blsaw)
def1(bltriangle)
def1(dmetro, metro)
def1(jcrev)
def1(osc, sample)
def1(metro)
def1(rline)
def1(saturator)
def1(saw, sample)
def1(tri, sample)
def1(square, sample)
def2(blsquare)
def2(chaos_noise)
def2(detune_osc, fms)
def2(detune_tri, fms)
def2(detune_saw, fms)
def2(detune_square, fms)
def2(detune_blsaw, fm_blsaw)
def2(detune_bltriangle, fm_bltriangle)
def2(detune_blsquare, fm_blsquare)
def2(hpf)
def2(impulse, sample)
def2(lpf, sample)
def2(maygate)
def2(phsclk, sample)
def2(sh, sample)
def2(square, sample)
def2(tline, transition)
def2(tquad, transition)
def3(bitcrush)
def3(bqbpf, biquad)
def3(bqhpf, biquad)
def3(bqlpf, biquad)
def3(bqnotch, biquad)
def3(diode)
def3(fm_osc, fms)
def3(fm_tri, fms)
def3(fm_saw, fms)
def3(fm_square, fms)
def3(fm_blsaw)
def3(fm_bltriangle)
def3(fm_blsquare)
def3(gaussian, sample)
def4(autowah)
def4(conv)
def4(peaklim)
def4(pshift)
def4(wpkorg35)
def5(adsr)
def5(compressor)

proc bigverb*(x: Frame, feedback, lpfreq: float): Frame =
  result = bigverb(x, feedback, lpfreq, pool.data.bigverb[pool.index.bigverb])
  pool.index.bigverb += 1

proc delay*(x, dt: float): float =
  result = delay(x, dt, pool.data.delay[pool.index.delay])
  pool.index.delay += 1
lift2(delay)

proc fb*(x, dt, k: float): float =
  result = fb(x, dt, k, pool.data.delay[pool.index.delay])
  pool.index.delay += 1
lift3(fb)

proc long_delay*(x, dt: float): float =
  result = delay(x, dt, pool.data.long_delay[pool.index.long_delay])
  pool.index.long_delay += 1
lift2(long_delay)

proc long_fb*(x, dt, k: float): float =
  result = fb(x, dt, k, pool.data.long_delay[pool.index.long_delay])
  pool.index.long_delay += 1
lift3(long_fb)

proc sequence*(seq: openArray[float], t: float): float =
  result = sequence(seq, t, pool.data.sequence[pool.index.sequence])
  pool.index.sequence += 1

proc sequence*(seq: openArray[Frame], t: Frame): Frame =
  for i in 0..<CHANNELS:
    result[i] = sequence(seq[i], t[i])

proc choose*[T](xs: openArray[T], t: float): T =
  result = choose(xs, t, pool.data.choose[pool.index.choose])
  pool.index.choose += 1

proc choose*[T](xs: openArray[T], t: float, ps: openArray[float]): T =
  result = choose(xs, t, ps, pool.data.choose[pool.index.choose])
  pool.index.choose += 1

proc phaser*(
  x: Frame,
  MaxNotch1Freq: float = 800,
  MinNotch1Freq: float = 100,
  Notch_width: float = 1000,
  NotchFreq: float = 1.5,
  VibratoMode: float = 1,
  depth: float = 1,
  feedback_gain: float = 0,
  invert: float = 0,
  level: float = 0,
  lfobpm: float = 30): Frame =
  result = phaser(
    x,
    MaxNotch1Freq,
    MinNotch1Freq,
    Notch_width,
    NotchFreq,
    VibratoMode,
    depth,
    feedback_gain,
    invert,
    level,
    lfobpm,
    pool.data.phaser[pool.index.phaser])
  pool.index.phaser += 1

proc zitarev*(
  x: Frame,
  in_delay: float = 60,
  lf_x: float = 200,
  rt60_low: float = 3,
  rt60_mid: float = 2,
  hf_damping: float = 6000,
  eq1_freq: float = 315,
  eq1_level: float = 0,
  eq2_freq: float = 1500,
  eq2_level: float = 0,
  mix: float = 1,
  level: float = -20): Frame =
  result = zitarev(
    x,
    in_delay,
    lf_x,
    rt60_low,
    rt60_mid,
    hf_damping,
    eq1_freq,
    eq1_level,
    eq2_freq,
    eq2_level,
    mix,
    level,
    pool.data.zitarev[pool.index.zitarev])
  pool.index.zitarev += 1
