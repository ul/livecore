## Where the creativity blossoms.

import
  std/[atomics, math, options],
  dsp/[frame, delays, effects, envelopes, events, filters, metro, modules,
        noise, osc, sampler, soundpipe, stereo, fft, fir, conv, notes],
  strudel/core/pattern,
  cycler, pool, control

defDelay(300)

type
  State* = object
    pool: Pool
    cycler: Cycler
    notes: seq[FastHap]
    melody: Frame

proc control*(s: var State, cc: var Controllers, n: var Notes,
    frame_count: int) {.nimcall, exportc, dynlib.} =
  ## This is called each block before the audio is rendered.

  let o = !0.0

  s.notes = ([
    [[[!g3, b3, o, d3, o, g4, ].sequence,
    [!b4, d4].stack.euclid(3, 8), ].stack,
    [!g5, a5, g3, b3].euclid(5, 12), ].stack,

    [[[!g3, o, b3, o, d3].sequence,
    [!g4, b4, d4].stack.euclid(2, 7), ].stack,
    [!g2, a2, g3, b3].euclid(3, 8), ].stack,
  ].poly).fast_haps(s.cycler)

proc audio*(s: var State, cc: var Controllers, n: var Notes,
    input: Frame): Frame {.nimcall, exportc, dynlib.} =
  ## This is called each frame to render the audio.

  s.pool.init
  s.cycler.tick(5.0)

  var melody = 0.0
  var bass = 0.0

  for note in s.notes:
    let note_on = note.gate(s.cycler)
    let dur = note.duration(s.cycler)
    let melody_env = note_on.adsr(0.01, 0.2, 0.8, 5.0)
    let bass_env = note_on.adsr(1.5, 0.0, 0.9, 3.5)
    melody += note.value.fm_bltriangle(1/2, 2/3).mul(0.5) * melody_env
    bass += note.value.mul(0.5).fm_fast_osc(1/2, 2/3).mul(0.5).delay(dur) * bass_env

  let sig = (melody + bass).zitarev
  sig
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
