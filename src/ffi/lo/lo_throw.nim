##
##   Copyright (C) 2014 Steve Harris et al. (see AUTHORS)
##
##   This program is free software; you can redistribute it and/or
##   modify it under the terms of the GNU Lesser General Public License
##   as published by the Free Software Foundation; either version 2.1
##   of the License, or (at your option) any later version.
##
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU Lesser General Public License for more details.
##
##   $Id$
##

when defined(windows):
  const soname = "lo.dll"
elif defined(macosx):
  const soname = "liblo.dylib"
else:
  const soname = "liblo.so"

proc lo_throw*(s: lo_server; errnum: cint; message: cstring; path: cstring) {.cdecl,
    importc: "lo_throw", dynlib: soname.}
## ! Since the liblo error handler does not provide a context pointer,
##   it can be provided by associating it with a particular server
##   through this thread-safe API.

proc lo_error_get_context*(): pointer {.cdecl, importc: "lo_error_get_context",
                                     dynlib: soname.}
proc lo_server_set_error_context*(s: lo_server; user_data: pointer) {.cdecl,
    importc: "lo_server_set_error_context", dynlib: soname.}
