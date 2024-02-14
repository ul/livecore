## Where the creativity blossoms.

import
  std/[atomics, math, options, random],
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, sampler, soundpipe, stereo, fft, fir, conv, notes],
  strudel/core/pattern,
  cycler, pool, control

defDelay(300)

type
  State* = object
    pool: Pool
    cycler: Cycler
    looong: array[CHANNELS, Delay300]
    atk: float
    fdt: int

template prolly_echo(p: float, s: untyped) =
  if rand(1.0) < p:
    echo s

proc inst0(e: Controls, s: var State): Frame =
  let x = e.note.get(silence).osc
  let a = e.attack.get(1/64).min(0.2*e.duration).max(1/64)
  let d = 2*a
  let sus = 0.5
  e.gate
    .adsr(a, d, sus, d)
    .mul(x)
    .mul(e.gain.get(1.0))

proc inst1(e: Controls, s: var State): Frame =
  let x = e.note.get(silence).bl_triangle * white_noise()
  let a = e.attack.get(1/64).min(0.2*e.duration).max(1/64)
  e.gate
    .impulse(a)
    .mul(x)
    .mul(e.gain.get(1.0))

proc control*(s: var State, m: Midi, frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.
  ## Many audio functions can be used here but keep in mind ×frame_count slowdown.

  let a = (frame_count/33).osc.biscale(1/32, 1)
  let b = (frame_count/23).osc.biscale(1/32, 1)
  let c = (frame_count/13).osc.biscale(1/32, 1)

  let insts = [^inst0, ^inst1]

  if rand(1.0) < 0.005:
    s.fdt += 1

  let p1 = [
    note(c4) >> attack(a),
    note([e4, e5]) >> attack(b),
    note(g4) >> attack(c),
  ]
  let p = [p1.euclid(3, 8), p1.stack.euclid(3, 9)].stack >> sound(insts[s.fdt mod insts.len]) >> gain(0.8)
  s.cycler.schedule(p, frame_count.to_seconds, 1.0)

proc audio*(s: var State, m: Midi, input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.
  s.pool.reset

  let cycle_dur = (1/60).tri.biscale(2.0, 10.0) # seconds
  s.cycler.tick(cycle_dur.recip)

  let choir = process[var State](s.cycler, s).fadeout(s.fdt.to_float.trig_on_change, 0.01)

  choir
    .ff(cycle_dur * 1.5, 0.5, s.looong)
    .wp_korg35(c7, 0.95, 1.0)
    .bqnotch_bw(315.0, 0.5)
    .bqnotch_bw(640.0, 1.0)
    .bqhpf(30.0, 0.7071)
    .zita_rev(level = 0)
    .simple_saturator
    .dc_block

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  s.pool.init
  sp_create()

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
