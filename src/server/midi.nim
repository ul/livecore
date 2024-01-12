import std/[atomics, strutils]
import context
import rtmidi/rtmidi

var the_ctx: ptr Context
var devices: seq[MidiIn]

proc midi_in_callback(timestamp: float64; m: openArray[byte]) =
  let n = the_ctx.notes.len
  case m[0]
  of 0xB0: # cc
    the_ctx.controllers[m[1]].store(m[2].float / 0x7F)
    echo  "cc/0x", m[1].to_hex, " = ", m[2].float / 0x7F
  # notes are encoded as uint16 to atomically update both pitch and velocity
  # lower byte is pitch, and higher one is velocity
  of 0x90: # note on
    the_ctx.notes[the_ctx.note_cursor].store(m[1].uint16 + 0x100*m[2].uint16)
    the_ctx.note_cursor = (the_ctx.note_cursor + 1) mod n
  of 0x80: # note off
    for i in 1..n:
      # we'd like to disable the most recent note with the same pitch
      let j = (n + the_ctx.note_cursor - i) mod n
      if (the_ctx.notes[j].load and 0x00FF) == m[1]:
        the_ctx.notes[j].store(m[1].uint16)
        break
  else: discard
  # TODO log into file to be committed as a part of session
  echo "0x", m[0].to_hex, " 0x", m[1].to_hex, " 0x", m[2].to_hex

proc start_midi*(ctx: ptr Context) =
  the_ctx = ctx
  for api in get_compiled_apis():
    devices.add(init_midi_in(api))
    echo "\nMIDI API: ", devices[^1].api().display_name()
    for i in 0..<devices[^1].port_count():
      echo "├ Input Port #", i, ": ", devices[^1].port_name(i)
      echo ""
      devices[^1].open_port(i, "")
      devices[^1].set_callback(midi_in_callback)
