import
  context,
  dll,
  ffi/fswatch,
  os

const TARGET_PATH = "./target"
const SESSION_FILTER = "session\\.so\\.[0-9]+$"
const ALL_FILTER = ".*"
const SESSION_GLOB = TARGET_PATH & "/session.so.*"

proc watch_session*(ctx: ptr Context) =
  if fsw_init_library() != 0:
    quit "Failed to init FSWatch."

  var fsw = fsw_init_session(0)

  if fsw.fsw_add_path(TARGET_PATH) != 0:
    quit "Failed to add target to watch paths."

  var fsw_filter1 = fsw_cmonitor_filter(text: SESSION_FILTER,
      filter_type: fsw_filter_type.filter_include, case_sensitive: false,
      extended: true)
  if fsw.fsw_add_filter(fsw_filter1) != 0:
    quit "Failed to add watch filter."

  var fsw_filter2 = fsw_cmonitor_filter(text: ALL_FILTER,
      filter_type: fsw_filter_type.filter_exclude, case_sensitive: false,
      extended: true)
  if fsw.fsw_add_filter(fsw_filter2) != 0:
    quit "Failed to add watch filter."

  var initial_path = ""
  # Find the newest version of session library.
  for path in walk_files(SESSION_GLOB):
    if initial_path == "" or path.file_newer(initial_path):
      if initial_path != "":
        discard initial_path.try_remove_file
      initial_path = path

  if initial_path != "":
    ctx.load_session(initial_path)
    echo "<= ", initial_path.extract_filename

  proc monitor(event: fsw_cevent, num: cuint) =
    for i in 0..<event.flags_num:
      let flag = cast[ptr fsw_event_flag](cast[int](event.flags) + cast[int](
          i) * fsw_event_flag.sizeof)[]
      if flag == fsw_event_flag.Removed:
        return
    let path = relative_path($event.path, ".")
    ctx.load_session(path)
    echo "<= ", path.extract_filename

  if fsw.fsw_set_callback(monitor) != 0:
    quit "Failed add target to watch paths"

  discard fsw.fsw_start_monitor()
