##
## Low-level bindings for RtMidi
## 
## This module provides bindings for the C API of RtMidi. All types and functions
## defined in "rtmidi_c.h" are provided here with the same exact name.
## 
## You can use this module instead of the high-level API, or even alongside it.
## 
## See https://www.music.mcgill.ca/~gary/rtmidi/group__C-interface.html for
## documentation.
##

import private/vendor

type
  RtMidiWrapper* = object
    `ptr`*: pointer
    data*: pointer
    ok*: bool
    msg*: cstring
  
  RtMidiPtr* = ptr RtMidiWrapper
  RtMidiInPtr* = ptr RtMidiWrapper
  RtMidiOutPtr* = ptr RtMidiWrapper

  RtMidiApi* {. size: sizeof(cint) .} = enum
    RTMIDI_API_UNSPECIFIED
    RTMIDI_API_MACOSX_CORE
    RTMIDI_API_LINUX_ALSA
    RTMIDI_API_UNIX_JACK
    RTMIDI_API_WINDOWS_MM
    RTMIDI_API_RTMIDI_DUMMY
    RTMIDI_API_WEB_MIDI_API
    RTMIDI_API_WINDOWS_UWP
    RTMIDI_API_ANDROID
    RTMIDI_API_NUM
  
  RtMidiErrorType* {. size: sizeof(cint) .} = enum
    RTMIDI_ERROR_WARNING
    RTMIDI_ERROR_DEBUG_WARNING
    RTMIDI_ERROR_UNSPECIFIED
    RTMIDI_ERROR_NO_DEVICES_FOUND
    RTMIDI_ERROR_INVALID_DEVICE
    RTMIDI_ERROR_MEMORY_ERROR
    RTMIDI_ERROR_INVALID_PARAMETER
    RTMIDI_ERROR_INVALID_USE
    RTMIDI_ERROR_DRIVER_ERROR
    RTMIDI_ERROR_SYSTEM_ERROR
    RTMIDI_ERROR_THREAD_ERROR

  RtMidiCCallback* = proc(timestamp: float64; msg: ptr UncheckedArray[byte];
                          msgSize: csize_t; userData: pointer) {.noconv.}

when defined(rtmidiUseDll):
  {. pragma: rtmidi, dynlib: rtmidiDll .}
else:
  {. pragma: rtmidi .}


{. push importc, noconv .} # ==================================================

# general
proc rtmidi_get_version*(): cstring
  {.rtmidi.}
proc rtmidi_get_compiled_api*(apis: ptr RtMidiApi; len: cuint): cint
  {.rtmidi.}
proc rtmidi_api_name*(api: RtMidiApi): cstring
  {.rtmidi.}
proc rtmidi_api_display_name*(api: RtMidiApi): cstring
  {.rtmidi.}
proc rtmidi_compiled_api_by_name*(name: cstring): RtMidiApi
  {.rtmidi.}
proc rtmidi_error*(ty: RtMidiErrorType; msg: cstring)
  {.rtmidi.}

# in/out
proc rtmidi_open_port*(device: RtMidiPtr; portNum: cuint; portName: cstring)
  {.rtmidi.}
proc rtmidi_open_virtual_port*(device: RtMidiPtr; portName: cstring)
  {.rtmidi.}
proc rtmidi_close_port*(device: RtMidiPtr)
  {.rtmidi.}
proc rtmidi_get_port_count*(device: RtMidiPtr): cuint
  {.rtmidi.}
proc rtmidi_get_port_name*(device: RtMidiPtr; portNum: cuint; bufOut: cstring,
                           bufLen: ptr cint): cint
  {.rtmidi.}

# in
proc rtmidi_in_create_default*(): RtMidiInPtr
  {.rtmidi.}
proc rtmidi_in_create*(api: RtMidiApi; clientName: cstring;
                       queueSizeLimit: cuint): RtMidiInPtr
  {.rtmidi.}
proc rtmidi_in_free*(device: RtMidiInPtr)
  {.rtmidi.}
proc rtmidi_in_get_current_api*(device: RtMidiInPtr): RtMidiApi
  {.rtmidi.}
proc rtmidi_in_set_callback*(device: RtMidiInPtr; callback: RtMidiCCallback;
                             data: pointer)
  {.rtmidi.}
proc rtmidi_in_cancel_callback*(device: RtMidiInPtr)
  {.rtmidi.}
proc rtmidi_in_ignore_types*(device: RtMidiInPtr; midiSysex, midiTime,
                             midiSense: bool; ) 
  {.rtmidi.}
proc rtmidi_in_get_message*(device: RtMidiInPtr; message: ptr byte;
                            size: ptr csize_t): float64
  {.rtmidi.}

# out
proc rtmidi_out_create_default*(): RtMidiOutPtr
  {.rtmidi.}
proc rtmidi_out_create*(api: RtMidiApi; clientName: cstring): RtMidiOutPtr
  {.rtmidi.}
proc rtmidi_out_free*(dev: RtMidiOutPtr)
  {.rtmidi.}
proc rtmidi_out_get_current_api*(dev: RtMidiOutPtr): RtMidiApi
  {.rtmidi.}
proc rtmidi_out_send_message*(dev: RtMidiOutPtr; msg: ptr byte; len: cint
                             ): cint
  {.rtmidi.}

{. pop .} # ===================================================================
