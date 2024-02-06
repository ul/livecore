import
  std/[atomics, dynlib, os],
  context

proc load_session*(ctx: ptr Context, new_path: string) =
  let new_lib = new_path.load_lib
  if new_lib.is_nil:
    echo "Failed to load session library."
    return

  let new_control = cast[Control](new_lib.sym_addr("control"))
  if new_control.is_nil:
    echo "Didn't find `control` in session library."
    new_lib.unload_lib
    return

  let new_audio = cast[Audio](new_lib.sym_addr("audio"))
  if new_audio.is_nil:
    echo "Didn't find `audio` in session library."
    new_lib.unload_lib
    return

  let onload = cast[Load](new_lib.sym_addr("load"))
  if not onload.is_nil:
    ctx.arena.onload

  ctx.audio.store(new_audio)
  ctx.control.store(new_control)
  # Spin-lock to ensure that we don't try to unload old lib in the middle of old
  # `audio` call.
  while ctx.in_process.load: discard

  ctx.stats.avg = 0.0
  ctx.stats.min = Inf
  ctx.stats.max = 0.0
  ctx.stats.n = 0

  if not ctx.lib.is_nil:
    let onunload = cast[Unload](ctx.lib.sym_addr("unload"))
    if not onunload.is_nil:
      ctx.arena.onunload
    ctx.lib.unload_lib
    # Clean-up to invalidate OS cache.
    discard ctx.lib_path.try_remove_file

  ctx.lib = new_lib
  ctx.lib_path = new_path
