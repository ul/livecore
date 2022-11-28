## Where the creativity blossoms.

import
  std/[atomics, math, options],
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, sampler, soundpipe, stereo, fft, fir, conv],
  strudel/core/pattern,
  cycler, pool, control

defDelay(300)

type
  State* = object
    pool: Pool
    cycler: Cycler
    notes: seq[Hap]
    looong_delay: array[CHANNELS, Delay300]

proc control*(s: var State, cc: var Controllers, n: var Notes,
    frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  s.notes = (--[
    //[!1/1, 3/2, 5/3],
    @@[(1//2, !1/1), (1//3, !3/2), (1//5, !5/3)],
    //[
      <>[!1/1, 0.0, 3/2, 0.0, 5/3],
      <>[!1/1, 3/2, 5/3]
    ],
    //[!1/1, 3/2],
    //[!3/2, 5/3],
    //[!1/1, 5/3],
  ]).haps(s.cycler)

proc audio*(s: var State, cc: var Controllers, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  s.cycler.tick(0.05.osc.biscale(5.0, 10.0))

  var x = 0.0
  for note in s.notes:
    let t = note.gate(s.cycler).zero_cross_up
    let dur = note.duration(s.cycler)
    let env = t.impulse(dur / 5)
    x += note.value
      .mul(220.0)
      .fm_bltriangle(1/2, 3/4)
      .mul(env)

  let sig = x + x.mono_width(0.5).fb((1/60).tri.biscale(5.0, 60.0), 0.2,
      s.looong_delay).mul(0.5)

  sig
    .mul(0.1)
    .simple_saturator
    .dc_block

# A place for heavy init logic, like reading tables from the disk.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc load*(s: var State) {.nimcall, exportc, dynlib.} =
  const MB = 1024^2
  echo "State: ", int(State.size_of/MB), "MB / Pool: ", int(Pool.size_of/MB), "MB"
  # s.pool.addr.zero_mem(Pool.size_of)
  # s.addr.zero_mem(State.size_of)
  sp_create()

# Clean up any garbage allocated outside of the State arena.
# Beware access to the state is not guarded and may happen simultaneously with `control` or `audio`.
proc unload*(s: var State) {.nimcall, exportc, dynlib.} =
  sp_destroy()
