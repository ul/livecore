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

import lo_types

## *
##  \file lo_serverthread.h The liblo headerfile declaring thread-related functions.
##
## *
##  \brief Create a new server thread to handle incoming OSC
##  messages.
##
##  Server threads take care of the message reception and dispatch by
##  transparently creating a system thread to handle incoming messages.
##  Use this if you do not want to handle the threading yourself.
##
##  \param port If NULL is passed then an unused port will be chosen by the
##  system, its number may be retrieved with lo_server_thread_get_port()
##  so it can be passed to clients. Otherwise a decimal port number, service
##  name or UNIX domain socket path may be passed.
##  \param err_h A function that will be called in the event of an error being
##  raised. The function prototype is defined in lo_types.h
##

proc lo_server_thread_new*(port: cstring;
    err_h: lo_err_handler): lo_server_thread {.
    cdecl, importc: "lo_server_thread_new", dynlib: soname.}
## *
##  \brief Create a new server thread to handle incoming OSC
##  messages, and join a UDP multicast group.
##
##  Server threads take care of the message reception and dispatch by
##  transparently creating a system thread to handle incoming messages.
##  Use this if you do not want to handle the threading yourself.
##
##  \param group The multicast group to join.  See documentation on IP
##  multicast for the acceptable address range; e.g., http://tldp.org/HOWTO/Multicast-HOWTO-2.html
##  \param port If NULL is passed then an unused port will be chosen by the
##  system, its number may be retrieved with lo_server_thread_get_port()
##  so it can be passed to clients. Otherwise a decimal port number, service
##  name or UNIX domain socket path may be passed.
##  \param err_h A function that will be called in the event of an error being
##  raised. The function prototype is defined in lo_types.h
##

proc lo_server_thread_new_multicast*(group: cstring; port: cstring;
                                    err_h: lo_err_handler): lo_server_thread {.
    cdecl, importc: "lo_server_thread_new_multicast", dynlib: soname.}
## *
##  \brief Create a new server thread to handle incoming OSC
##  messages, specifying protocol.
##
##  Server threads take care of the message reception and dispatch by
##  transparently creating a system thread to handle incoming messages.
##  Use this if you do not want to handle the threading yourself.
##
##  \param port If NULL is passed then an unused port will be chosen by the
##  system, its number may be retrieved with lo_server_thread_get_port()
##  so it can be passed to clients. Otherwise a decimal port number, service
##  name or UNIX domain socket path may be passed.
##  \param proto The protocol to use, should be one of LO_UDP, LO_TCP or LO_UNIX.
##  \param err_h A function that will be called in the event of an error being
##  raised. The function prototype is defined in lo_types.h
##

proc lo_server_thread_new_with_proto*(port: cstring; proto: cint;
                                     err_h: lo_err_handler): lo_server_thread {.
    cdecl, importc: "lo_server_thread_new_with_proto", dynlib: soname.}
## *
##  \brief Create a new server thread, taking port and the optional
##  multicast group IP from an URL string.
##
##  \param url The URL to specify the server parameters.
##  \param err_h An error callback function that will be called if there is an
##  error in messge reception or server creation. Pass NULL if you do not want
##  error handling.
##  \return A new lo_server_thread instance.
##

proc lo_server_thread_new_from_url*(url: cstring;
    err_h: lo_err_handler): lo_server_thread {.
    cdecl, importc: "lo_server_thread_new_from_url", dynlib: soname.}
## *
##  \brief Free memory taken by a server thread
##
##  Frees the memory, and, if currently running will stop the associated thread.
##

proc lo_server_thread_free*(st: lo_server_thread) {.cdecl,
    importc: "lo_server_thread_free", dynlib: soname.}
## *
##  \brief Add an OSC method to the specifed server thread.
##
##  \param st The server thread the method is to be added to.
##  \param path The OSC path to register the method to. If NULL is passed the
##  method will match all paths.
##  \param typespec The typespec the method accepts. Incoming messages with
##  similar typespecs (e.g. ones with numerical types in the same position) will
##  be coerced to the typespec given here.
##  \param h The method handler callback function that will be called it a
##  matching message is received
##  \param user_data A value that will be passed to the callback function, h,
##  when its invoked matching from this method.
##

proc lo_server_thread_add_method*(st: lo_server_thread; path: cstring;
                                 typespec: cstring; h: lo_method_handler;
                                 user_data: pointer): lo_method {.cdecl,
    importc: "lo_server_thread_add_method", dynlib: soname.}
## *
##  \brief Delete an OSC method from the specifed server thread.
##
##  \param st The server thread the method is to be removed from.
##  \param path The OSC path of the method to delete. If NULL is passed the
##  method will match the generic handler.
##  \param typespec The typespec the method accepts.
##

proc lo_server_thread_del_method*(st: lo_server_thread; path: cstring;
                                 typespec: cstring) {.cdecl,
    importc: "lo_server_thread_del_method", dynlib: soname.}
## *
##  \brief Delete an OSC method from the specified server thread.
##
##  \param s The server thread the method is to be removed from.
##  \param m The lo_method identifier returned from lo_server_add_method for
##           the method to delete from the server.
##  \return Non-zero if it was not found in the list of methods for the server.
##

proc lo_server_thread_del_lo_method*(st: lo_server_thread;
    m: lo_method): cint {.
    cdecl, importc: "lo_server_thread_del_lo_method", dynlib: soname.}
## *
##  \brief Set an init and/or a cleanup function to the specifed server thread.
##
##  To have any effect, it must be called before the server thread is started.
##
##  \param st The server thread to which the method is to be added.
##  \param init The init function to be called just after thread start.
##              May be NULL.
##  \param cleanup The cleanup function to be called just before thread
##                 exit.  May be NULL.
##  \param user_data A value that will be passed to the callback functions.
##

proc lo_server_thread_set_callbacks*(st: lo_server_thread;
                                    init: lo_server_thread_init_callback;
                                    cleanup: lo_server_thread_cleanup_callback;
                                    user_data: pointer) {.cdecl,
    importc: "lo_server_thread_set_callbacks", dynlib: soname.}
## *
##  \brief Start the server thread
##
##  \param st the server thread to start.
##  \return Less than 0 on failure, 0 on success.
##

proc lo_server_thread_start*(st: lo_server_thread): cint {.cdecl,
    importc: "lo_server_thread_start", dynlib: soname.}
## *
##  \brief Stop the server thread
##
##  \param st the server thread to start.
##  \return Less than 0 on failure, 0 on success.
##

proc lo_server_thread_stop*(st: lo_server_thread): cint {.cdecl,
    importc: "lo_server_thread_stop", dynlib: soname.}
## *
##  \brief Return the port number that the server thread has bound to.
##

proc lo_server_thread_get_port*(st: lo_server_thread): cint {.cdecl,
    importc: "lo_server_thread_get_port", dynlib: soname.}
## *
##  \brief Return a URL describing the address of the server thread.
##
##  Return value must be free()'d to reclaim memory.
##

proc lo_server_thread_get_url*(st: lo_server_thread): cstring {.cdecl,
    importc: "lo_server_thread_get_url", dynlib: soname.}
## *
##  \brief Return the lo_server for a lo_server_thread
##
##  This function is useful for passing a thread's lo_server
##  to lo_send_from().
##

proc lo_server_thread_get_server*(st: lo_server_thread): lo_server {.cdecl,
    importc: "lo_server_thread_get_server", dynlib: soname.}
## * \brief Return true if there are scheduled events (eg. from bundles) waiting
##  to be dispatched by the thread

proc lo_server_thread_events_pending*(st: lo_server_thread): cint {.cdecl,
    importc: "lo_server_thread_events_pending", dynlib: soname.}
proc lo_server_thread_set_error_context*(st: lo_server_thread;
    user_data: pointer) {.
    cdecl, importc: "lo_server_thread_set_error_context", dynlib: soname.}
## * \brief Pretty-print a lo_server_thread object.

proc lo_server_thread_pp*(st: lo_server_thread) {.cdecl,
    importc: "lo_server_thread_pp", dynlib: soname.}
