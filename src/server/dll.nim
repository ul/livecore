import
  atomics,
  context,
  dynlib,
  os

proc load_session*(ctx: ptr Context, new_path: string) =
  let new_lib = new_path.load_lib
  if new_lib.is_nil:
    echo "Failed to load session library."
    return

  let new_process = cast[Process](new_lib.sym_addr("process"))
  if new_process.is_nil:
    echo "Didn't find `process` in session library."
    new_lib.unload_lib
    return

  let onload = cast[Load](new_lib.sym_addr("load"))
  if not onload.is_nil:
    ctx.arena.onload

  ctx.process.store(new_process)
  # Spin-lock to ensure that we don't try to unload old lib in the middle of old
  # `process` call.
  while ctx.in_process.load: discard

  if not ctx.lib.is_nil:
    let onunload = cast[Unload](ctx.lib.sym_addr("unload"))
    if not onunload.is_nil:
      ctx.arena.onunload
    ctx.lib.unload_lib
    # Clean-up to invalidate OS cache.
    discard ctx.lib_path.try_remove_file

  ctx.lib = new_lib
  ctx.lib_path = new_path
