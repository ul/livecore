## Sound server. Runs and hot-reloads session code in the audio thread.

import
  server/[audio, context, fs, midi, params, osc]

let p = get_params()
var ctx = new_context(p.arena_mb)

ctx.start_audio(p.dac_id, p.adc_id)
ctx.start_osc(p.osc_addr)
ctx.start_midi
ctx.watch_session
