import
  atomics,
  context,
  ffi/lo/[lo_serverthread, lo_types, lo_osc_types],
  strutils

proc osc_error(num: cint; msg: cstring; where: cstring) {.cdecl.} =
  echo "liblo server error ", num, " in path ", where, ": ", msg

proc controls_handler(path: cstring; types: cstring; argv: ptr ptr lo_arg; argc: cint; msg: lo_message; user_data: pointer): cint {.cdecl.} =
  let argvi = cast[int](argv)
  let psz = pointer.sizeof
  let arg0 = cast[ptr lo_arg](argv[])
  let arg1 = cast[ptr lo_arg](cast[ptr ptr lo_arg](argvi + psz)[])
  let i = arg0.i
  let x = arg1.f
  let ctx = cast[ptr Context](user_data)
  ctx.controls[i].store(x)

proc midi2osc_handler(path: cstring; types: cstring; argv: ptr ptr lo_arg; argc: cint; msg: lo_message; user_data: pointer): cint {.cdecl.} =
  let ctx = cast[ptr Context](user_data)
  let n = ctx.notes.len
  let m = cast[ptr lo_arg](argv[]).m
  case m[1]
  of 0xB0: # cc
    ctx.controls[m[2]].store(m[3].float / 0x7F)
  # notes are encoded as uint16 to atomically update both pitch and velocity
  # lower byte is pitch, and higher one is velocity
  of 0x90: # note on
    ctx.notes[ctx.note_cursor].store(m[2].uint16 + 0x100*m[3].uint16)
    ctx.note_cursor = (ctx.note_cursor + 1) mod n
  of 0x80: # note off
    for i in 1..n:
      # we'd like to disable the most recent note with the same pitch
      let j = (n + ctx.note_cursor - i) mod n
      if (ctx.notes[j].load and 0x00FF) == m[2]:
        ctx.notes[j].store(m[2].uint16)
        break
  else: discard
  # TODO log into file to be committed as a part of session
  echo "0x", m[1].to_hex, " 0x", m[2].to_hex, " 0x", m[3].to_hex

proc tidal_triggers_handler(path: cstring; types: cstring; argv: ptr ptr lo_arg; argc: cint; msg: lo_message; user_data: pointer): cint {.cdecl.} =
  let ctx = cast[ptr Context](user_data)
  ctx.controls[argv.i].store(1.0)

proc tidal_notes_handler(path: cstring; types: cstring; argv: ptr ptr lo_arg; argc: cint; msg: lo_message; user_data: pointer): cint {.cdecl.} =
  let ctx = cast[ptr Context](user_data)
  ctx.notes[ctx.note_cursor].store(argv.i.uint16 + (0x100*0xFF).uint16)
  ctx.note_cursor = (ctx.note_cursor + 1) mod ctx.notes.len

proc start_osc*(ctx: ptr Context, osc_addr: string) =
  let osc_server_thread = osc_addr.cstring.lo_server_thread_new(osc_error)
  discard lo_server_thread_add_method(osc_server_thread, "/notes", "m", midi2osc_handler, ctx);
  discard lo_server_thread_add_method(osc_server_thread, "/controls", "if", controls_handler, ctx);
  discard lo_server_thread_add_method(osc_server_thread, "/tidal/triggers", "i", tidal_triggers_handler, ctx);
  discard lo_server_thread_add_method(osc_server_thread, "/tidal/notes", "i", tidal_notes_handler, ctx);
  discard lo_server_thread_add_method(osc_server_thread, "/tidal/controls", "if", controls_handler, ctx);
  discard lo_server_thread_start(osc_server_thread)
