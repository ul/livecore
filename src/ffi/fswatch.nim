import system

{.pragma: cenum, pure, final, size: sizeof(cint).}

const libName =
  when defined(windows):
    "libfswatch.dll"
  elif defined(macosx):
    "libfswatch.dylib"
  else:
    "libfswatch.so"


type
  fsw_handle* = ptr object
  fsw_event_flag* {.size: sizeof(cint).} = enum
    NoOp = 0 # No event has occurred
    PlatformSpecific = 1 shl 0 # Platform-specific placeholder for event type that cannot currently be mapped
    Created = 1 shl 1 # An object was created
    Updated = 1 shl 2 # An object was updated
    Removed = 1 shl 3 # An object was removed
    Renamed = 1 shl 4 # An object was renamed
    OwnerModified = 1 shl 5 #The owner of an object was modified
    AttributeModified = 1 shl 6 # The attributes of an object were modified
    MovedFrom = 1 shl 7 # An object was moved from this location
    MovedTo = 1 shl 8 # An object was moved to this location
    IsFile = 1 shl 9 # The object is a file
    IsDir = 1 shl 10 # The object is a directory
    IsSymLink = 1 shl 11 # The object is a symbolic link
    Link = 1 shl 12 # The link count of an object has changed
    Overflow = 1 shl 13 #The event queue has overflowed. */
  fsw_cevent* = object
    path*: cstring
    time_t*: cint
    flags*: ptr fsw_event_flag
    flags_num*: cuint
  fsw_event_type_filter* = object
    flag*: fsw_event_flag
  fsw_filter_type* {.cenum.} = enum
    filter_include,
    filter_exclude
  fsw_cmonitor_filter* {.pure, final.} = object
    text*: cstring
    filter_type*: fsw_filter_type
    case_sensitive*: bool
    extended*: bool


proc fsw_init_library*(): cint {.importc, dynlib: libName.}

proc fsw_init_session*(monitor_type: cint): ptr fsw_handle {.importc, dynlib: libName.}

proc fsw_add_path*(handle: ptr fsw_handle, path: cstring): cint {.importc, dynlib: libName.}

proc fsw_add_property*(handle: ptr fsw_handle, name: string, value: string): cint {.importc, dynlib: libName.}

proc fsw_set_allow_overflow*(handle: ptr fsw_handle, allow_overflow: bool): cint {.importc, dynlib: libName.}

proc fsw_set_callback*(handle: ptr fsw_handle, callback: proc(events: fsw_cevent, event_num: cuint)): cint {.importc, dynlib: libName.}

proc fsw_set_latency*(handle: ptr fsw_handle, latency: cdouble): cint {.importc, dynlib: libName.}

proc fsw_set_recursive*(handle: ptr fsw_handle, recursive: bool): cint {.importc, dynlib: libName.}

proc fsw_set_directory_only*(handle: ptr fsw_handle, directory_only: bool): cint {.importc, dynlib: libName.}

proc fsw_set_follow_symlinks*(handle: ptr fsw_handle, follow_symlinks: bool): cint {.importc, dynlib: libName.}

proc fsw_add_event_type_filter*(handle: ptr fsw_handle, event_type: fsw_event_type_filter): cint {.importc, dynlib: libName.}

proc fsw_add_filter*(handle: ptr fsw_handle, filter: fsw_cmonitor_filter): cint {.importc, dynlib: libName.}

proc fsw_start_monitor*(handle: ptr fsw_handle): cint {.importc, dynlib: libName.}

proc fsw_stop_monitor*(handle: ptr fsw_handle): cint {.importc, dynlib: libName.}

proc fsw_is_running*(handle: ptr fsw_handle): bool {.importc, dynlib: libName.}

proc fsw_destroy_session*(handle: ptr fsw_handle): cint {.importc, dynlib: libName.}

proc fsw_last_error*(): cint {.importc, dynlib: libName.}

proc fsw_is_verbose*(): bool {.importc, dynlib: libName.}

proc fsw_set_verbose*(verbose: bool) {.importc, dynlib: libName.}
