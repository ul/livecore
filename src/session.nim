## Where the creativity blossoms.

import
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        nanotidal, noise, osc, sampler, soundpipe, stereo, fft, patterns, fir,
        conv],
  atomics, math, pool, control

defDelay(300)

type
  State* = object
    pool: Pool
    events: EventPool
    notes: PXRand
    durations: PXRand
    looong_delay: array[CHANNELS, Delay300]

proc process*(s: var State, cc: var Controls, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  s.pool.init

  let event_speed = (1/80).osc
    .add((1/130).osc)
    .add((1/210).osc)
    .add((1/340).osc)
    .mul(1/2)
    .biscale(1/256, 1.0)
  s.events.tick(event_speed)

  s.events[0].repeat: s.durations.step
  let t = s.events[0].trigger

  let dur = s.durations.value
  let dur_slide = dur.tline(dur/4).max(1/4)

  # let lfo = dur.mul(1).recip.osc.biscale(0.75, 0.99)
  let root = 27.5.mul(
    [1.0, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 4]
    .choose(t))
  let freq = t.step(s.notes).mul(root)
  let freq_slide = freq.tquad(dur).max(27.5)
  let sig = dur_slide.mul(1/3).recip.tri.mul(freq).fm_saw(3/2, 1/3)
  let x = 0.05 / event_speed
  let env = t.adsr(x, 2*x, 0.7071, 8*x)
  let lfo = freq_slide.mul(1/64).osc.biscale(0.75, 0.99)

  sig
    .mul(0.1)
    .mul(env)
    .diode(freq_slide.mul(16.0), 0.0)
    .mono_width(2.0)
    .long_fb(freq.recip, lfo)
    .bqhpf(80.0, 0.7071)
    .pan((1/12).osc.mul(0.8))
    .long_fb(dur_slide.mul(3).recip.tri.biscale(dur/2, 2*dur), 1/3)
    .fb([4.0, 5.0, 6.0, 7.0].choose(t).mul(dur.tquad(dur/64).max(1/4)), 0.7071,
        s.looong_delay)
    .diode(freq_slide.mul(32.0), 0.0)
    #.compressor(10.0, -25.0, 0.01, 0.01)
    #.compressor(10.0, -20.0, 0.01, 0.01)
    #.compressor(10.0, -15.0, 0.1, 0.1)
    #.compressor(10.0, -10.0, 0.1, 0.1)
    #.compressor(10.0, -5.0, 0.1, 0.1)
    #.compressor(10.0, -3.0, 0.1, 0.1)
    .zitarev(mix = 0.3, level = -3.0)
    .bqhpf_bw(150.0, 2.0)
    .peakeq(315.0, 0.5, -6.0)
    .peakeq(640.0, 1.0, -3.0)
    .peakeq(6126.3, 2.0, 1.5)
    .bqlpf_bw(2*6126.3, 2.0)
    .mul(3.0)
    .simple_saturator
    .dc_block

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()
  nanotidal_create()

  [1/1, 2/1, 3/1, 5/1, 3/2, 5/2, 5/3].init(s.notes)
  [1/4, 1/2, 3/4, 3/4, 1, 1, 1, 1, 2, 2, 4, 8, 16].init(s.durations)

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `process`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  discard
  # sp_destroy()
  # nanotidal_destroy()
