## Where the creativity blossoms.

import
  dsp/[
    frame, delays, effects, envelopes, events, filters, metro, modules, noise, osc,
    sampler, soundpipe, stereo, fft, fir, conv,
  ],
  atomics,
  math,
  pool,
  control

defDelay(300)

template layer(x, f): float =
  block:
    let it {.inject.} = x
    it.add(f)

type State* = object
  pool: Pool
  convos: array[0x04, Conv8192x64]
  delays: array[0x08, Delay300]

proc sum(xs: openArray[float]): float =
  for x in xs:
    result += x

proc control*(
    s: var State, m: var Midi, frame_count: int
) {.nimcall, exportc, dynlib.} =
  discard

proc audio*(
    s: var State, m: var Midi, input: Frame
): Frame {.nimcall, exportc, dynlib.} =
  s.pool.reset

  template voice(root, fmm, fmi, overtones, durs, cycle): float =
    block:
      template inst(freq: float): float =
        freq
        .fm_osc(fmm, fmi)
        .add(freq.mul(2.0).fm_bltriangle(fmm, fmi).mul(0.05))
        .add(freq.mul(3 / 2).fm_osc(fmm, fmi).mul(0.1))
        .add(freq.mul(4 / 3).fm_osc(fmm, fmi).mul(0.1))
        .add(freq.mul(1 / 2).fm_blsaw(fmm, fmi).mul(0.02))

      var sig = 0.0
      for i, a in overtones:
        sig += a * inst((i + 1).float * root)
      sig /= overtones.sum

      let durc = durs.choose(cycle.dmetro)
      let dm = durc.mul(4.0).dmetro.maytrig(0.5)
      let dur = durc.sh(dm)
      let env = dm.gaussian(0.5 * dur, (1 / 40).saw.mul(1 / 32).osc.biscale(0.05, 0.2))
      sig.mul(env)

  let root = rline(30.0).scale(36.0, 72.0).quantize(4.0)

  let voices = [
    voice(
      @(root + 24.0),
      3 / 2,
      1 / 3,
      [
        1.0,
        (1 / 1).osc.biscale(0.1, 0.5),
        (1 / 2).osc.biscale(0.1, 0.5),
        (1 / 3).osc.biscale(0.1, 0.5),
        (1 / 4).osc.biscale(0.1, 0.5),
        (1 / 5).osc.biscale(0.1, 0.5),
      ],
      [1 / 4, 1, 1 / 4, 1, 1 / 4, 1],
      2,
    )
    .mul(0.1),
    voice(
      @(root + 12.0),
      4 / 3,
      1 / 3,
      [
        1.0,
        (1 / 6).osc.biscale(0.1, 0.5),
        (1 / 7).osc.biscale(0.1, 0.5),
        (1 / 8).osc.biscale(0.1, 0.5),
        (1 / 9).osc.biscale(0.1, 0.5),
        (1 / 10).osc.biscale(0.1, 0.5),
      ],
      [1 / 2, 1, 2, 2, 1, 1 / 2],
      4,
    )
    .mul(0.2),
    voice(
      @root,
      5 / 4,
      1 / 3,
      [
        1.0,
        (1 / 11).osc.biscale(0.1, 0.5),
        (1 / 12).osc.biscale(0.1, 0.5),
        (1 / 13).osc.biscale(0.1, 0.5),
        (1 / 14).osc.biscale(0.1, 0.5),
        (1 / 15).osc.biscale(0.1, 0.5),
      ],
      [4 / 1, 2, 1, 1, 2, 4],
      8,
    )
    .mul(0.3),
  ]

  let k1 = @root
    .tline(1.0).saw
    .mul(whitenoise().scale(1.0, 3.0).dmetro.impulse(0.02))
    .mul(0.001)

  silence
  .add(voices[0])
  .add(voices[1])
  .add(voices[2])
  .mul(0.2)
  .layer(
    it
    .process(pinknoise().decim(0.95).mul(0.05), s.convos[0])
    .process(k1, s.convos[2])
    .mul(0.2)
  )
  .add(
    whitenoise()
    .add(@(root - 12).saw)
    .mul(@(root - 12).osc)
    .bqlpf(@(root - 8), 0.7071)
    .mul(0.30)
    .mul((1 / 120).osc.biscale(4, 32).dmetro.adsr(1 / 16, 0, 1.0, 1 / 8))
    .fb(1 / 16, 0.7071)
    .fb(1 / 2, 0.7071)
  )
  .add(
    whitenoise()
    .bqhpf(@(root + 36), 0.7071)
    .mul(0.5)
    .mul(30.rline.scale(8, 16).dmetro.impulse(0.01))
    .long_fb(30.rline.scale(4, 20), 0.95)
  )
  # .layer(it.fb(root.recip.mul(5).tri.biscale(1, 8), 0.5, s.delays[6]).mul(0.4))
  # .layer(it.fb(root.recip.tri.biscale(1 / 8, 120), 0.5, s.delays[7]).mul(0.5))
  # .ff(13, 0.5, s.delays[4])
  # .mul(0.87)
  # .ff(29, 0.5, s.delays[3])
  # .mul(0.87)
  # .ff(59, 0.5, s.delays[2])
  # .mul(0.87)
  .layer(it.fb(127, 0.5, s.delays[1]).mul(0.5))
  .layer(it.fb(257, 0.5, s.delays[0]).mul(0.5))
  #
  .dc_block
  .bigverb(0.8, @(root + 48.0))
  .wpkorg35(@(root + 36.0), 0.95, 0.5)
  .bqhpf(30.0, 0.7071).saturator

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024 ^ 2
  echo "State: ", int(State.size_of / MB), "MB / Pool: ", int(Pool.size_of / MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  s.pool.init
  sp_create()

  for x in s.convos.mitems:
    x.init

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
