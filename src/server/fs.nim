import
  std/[math, os],
  context,
  dll,
  ffi/fswatch

const TARGET_PATH = "./target"
const SESSION_FILTER = "session\\.so\\.[0-9]+$"
const ALL_FILTER = ".*"
const SESSION_GLOB = TARGET_PATH & "/session.so.*"

proc find_newest_session(): string =
  ## Find the newest version of session library.
  for path in walk_files(SESSION_GLOB):
    if result == "" or path.file_newer(result):
      result = path

proc percent(x: float): string =
  $round(100.0 * x, 1) & "%"

proc load_newest_session(ctx: ptr Context) =
  let path = find_newest_session()
  if path != "":
    echo ">", percent(ctx.stats.min), " ", percent(ctx.stats.avg), " ", percent(ctx.stats.max), "<"
    ctx.load_session(path)
    echo "<= ", path.extract_filename

proc watch_session*(ctx: ptr Context) =
  if fsw_init_library() != 0:
    quit "Failed to init FSWatch."

  var fsw = fsw_init_session(0)

  if fsw.fsw_add_path(TARGET_PATH) != 0:
    quit "Failed to add target to watch paths."

  var fsw_filter1 = fsw_cmonitor_filter(text: SESSION_FILTER, filter_type: fsw_filter_type.filter_include, case_sensitive: false, extended: true)
  if fsw.fsw_add_filter(fsw_filter1) != 0:
    quit "Failed to add watch filter."

  var fsw_filter2 = fsw_cmonitor_filter(text: ALL_FILTER, filter_type: fsw_filter_type.filter_exclude, case_sensitive: false, extended: true)
  if fsw.fsw_add_filter(fsw_filter2) != 0:
    quit "Failed to add watch filter."

  ctx.load_newest_session

  proc monitor(event: fsw_cevent, num: cuint) = ctx.load_newest_session

  if fsw.fsw_set_callback(monitor) != 0:
    quit "Failed add target to watch paths"

  discard fsw.fsw_start_monitor()
