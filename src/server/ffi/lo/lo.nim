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

## *
##  \file lo.h The liblo main headerfile and high-level API functions.
##

when defined(windows):
  const soname = "lo.dll"
elif defined(macosx):
  const soname = "liblo.dylib"
else:
  const soname = "liblo.so"

import
  lo_endian, lo_types, lo_osc_types, lo_errors, lo_lowlevel, lo_serverthread

## *
##  \defgroup liblo High-level OSC API
##
##  Defines the high-level API functions necessary to implement OSC support.
##  Should be adequate for most applications, but if you require lower level
##  control you can use the functions defined in lo_lowlevel.h
##  @{
##
## *
##  \brief Declare an OSC destination, given IP address and port number.
##  Same as lo_address_new_with_proto(), but using UDP.
##
##  \param host An IP address or number, or NULL for the local machine.
##  \param port a decimal port number or service name.
##
##  The lo_address object may be used as the target of OSC messages.
##
##  Note: if you wish to receive replies from the target of this
##  address, you must first create a lo_server_thread or lo_server
##  object which will receive the replies. The last lo_server(_thread)
##  object craeted will be the receiver.
##

proc lo_address_new*(host: cstring; port: cstring): lo_address {.cdecl,
    importc: "lo_address_new", dynlib: soname.}
## *
##  \brief Declare an OSC destination, given IP address and port number,
##  specifying protocol.
##
##  \param proto The protocol to use, must be one of LO_UDP, LO_TCP or LO_UNIX.
##  \param host An IP address or number, or NULL for the local machine.
##  \param port a decimal port number or service name.
##
##  The lo_address object may be used as the target of OSC messages.
##
##  Note: if you wish to receive replies from the target of this
##  address, you must first create a lo_server_thread or lo_server
##  object which will receive the replies. The last lo_server(_thread)
##  object created will be the receiver.
##

proc lo_address_new_with_proto*(proto: cint; host: cstring; port: cstring): lo_address {.
    cdecl, importc: "lo_address_new_with_proto", dynlib: soname.}
## *
##  \brief Create a lo_address object from an OSC URL.
##
##  example: \c "osc.udp://localhost:4444/my/path/"
##

proc lo_address_new_from_url*(url: cstring): lo_address {.cdecl,
    importc: "lo_address_new_from_url", dynlib: soname.}
## *
##  \brief Free the memory used by the lo_address object
##

proc lo_address_free*(t: lo_address) {.cdecl, importc: "lo_address_free",
                                    dynlib: soname.}
## *
##  \brief Set the Time-to-Live value for a given target address.
##
##  This is required for sending multicast UDP messages.  A value of 1
##  (the usual case) keeps the message within the subnet, while 255
##  means a global, unrestricted scope.
##
##  \param t An OSC address.
##  \param ttl An integer specifying the scope of a multicast UDP message.
##

proc lo_address_set_ttl*(t: lo_address; ttl: cint) {.cdecl,
    importc: "lo_address_set_ttl", dynlib: soname.}
## *
##  \brief Get the Time-to-Live value for a given target address.
##
##  \param t An OSC address.
##  \return An integer specifying the scope of a multicast UDP message.
##

proc lo_address_get_ttl*(t: lo_address): cint {.cdecl, importc: "lo_address_get_ttl",
    dynlib: soname.}
## *
##  \brief Send a OSC formatted message to the address specified.
##
##  \param targ The target OSC address
##  \param path The OSC path the message will be delivered to
##  \param type The types of the data items in the message, types are defined in
##  lo_osc_types.h
##  \param ... The data values to be transmitted. The types of the arguments
##  passed here must agree with the types specified in the type parameter.
##
##  example:
##  \code
##  lo_send(t, "/foo/bar", "ff", 0.1f, 23.0f);
##  \endcode
##
##  \return -1 on failure.
##

proc lo_send*(targ: lo_address; path: cstring; `type`: cstring): cint {.varargs, cdecl,
    importc: "lo_send", dynlib: soname.}
## *
##  \brief Send a OSC formatted message to the address specified,
##  from the same socket as the specified server.
##
##  \param targ The target OSC address
##  \param from The server to send message from   (can be NULL to use new socket)
##  \param ts   The OSC timetag timestamp at which the message will be processed
##  (can be LO_TT_IMMEDIATE if you don't want to attach a timetag)
##  \param path The OSC path the message will be delivered to
##  \param type The types of the data items in the message, types are defined in
##  lo_osc_types.h
##  \param ... The data values to be transmitted. The types of the arguments
##  passed here must agree with the types specified in the type parameter.
##
##  example:
##  \code
##  serv = lo_server_new(NULL, err);
##  lo_server_add_method(serv, "/reply", "ss", reply_handler, NULL);
##  lo_send_from(t, serv, LO_TT_IMMEDIATE, "/foo/bar", "ff", 0.1f, 23.0f);
##  \endcode
##
##  \return on success, the number of bytes sent, or -1 on failure.
##

proc lo_send_from*(targ: lo_address; `from`: lo_server; ts: lo_timetag; path: cstring;
                  `type`: cstring): cint {.varargs, cdecl, importc: "lo_send_from",
                                        dynlib: soname.}
## *
##  \brief Send a OSC formatted message to the address specified, scheduled to
##  be dispatch at some time in the future.
##
##  \param targ The target OSC address
##  \param ts The OSC timetag timestamp at which the message will be processed
##  \param path The OSC path the message will be delivered to
##  \param type The types of the data items in the message, types are defined in
##  lo_osc_types.h
##  \param ... The data values to be transmitted. The types of the arguments
##  passed here must agree with the types specified in the type parameter.
##
##  example:
##  \code
##  lo_timetag now;<br>
##  lo_timetag_now(&now);<br>
##  lo_send_timestamped(t, now, "/foo/bar", "ff", 0.1f, 23.0f);
##  \endcode
##
##  \return on success, the number of bytes sent, or -1 on failure.
##

proc lo_send_timestamped*(targ: lo_address; ts: lo_timetag; path: cstring;
                         `type`: cstring): cint {.varargs, cdecl,
    importc: "lo_send_timestamped", dynlib: soname.}
## *
##  \brief Return the error number from the last failed lo_send() or
##  lo_address_new() call
##

proc lo_address_errno*(a: lo_address): cint {.cdecl, importc: "lo_address_errno",
    dynlib: soname.}
## *
##  \brief Return the error string from the last failed lo_send() or
##  lo_address_new() call
##

proc lo_address_errstr*(a: lo_address): cstring {.cdecl,
    importc: "lo_address_errstr", dynlib: soname.}
## *
##  \brief Create a new OSC blob type.
##
##  \param size The amount of space to allocate in the blob structure.
##  \param data The data that will be used to initialise the blob, should be
##  size bytes long.
##

proc lo_blob_new*(size: int32_t; data: pointer): lo_blob {.cdecl,
    importc: "lo_blob_new", dynlib: soname.}
## *
##  \brief Free the memory taken by a blob
##

proc lo_blob_free*(b: lo_blob) {.cdecl, importc: "lo_blob_free", dynlib: soname.}
## *
##  \brief Return the amount of valid data in a lo_blob object.
##
##  If you want to know the storage size, use lo_arg_size().
##

proc lo_blob_datasize*(b: lo_blob): uint32_t {.cdecl, importc: "lo_blob_datasize",
    dynlib: soname.}
## *
##  \brief Return a pointer to the start of the blob data to allow contents to
##  be changed.
##

proc lo_blob_dataptr*(b: lo_blob): pointer {.cdecl, importc: "lo_blob_dataptr",
    dynlib: soname.}
## *
##  \brief Get information on the version of liblo current in use.
##
##  All parameters are optional and can be given the value of 0 if that
##  information is not desired.  For example, to get just the version
##  as a string, call lo_version(str, size, 0, 0, 0, 0, 0, 0, 0);
##
##  The "lt" fields, called the ABI version, corresponds to libtool's
##  versioning system for binary interface compatibility, and is not
##  related to the library version number.  This information is usually
##  encoded in the filename of the shared library.
##
##  Typically the string returned in 'verstr' should correspond with
##  $major.$minor$extra, e.g., "0.28rc".  If no 'extra' information is
##  present, e.g., "0.28", extra will given the null string.
##
##  \param verstr       A buffer to receive a string describing the
##                      library version.
##  \param verstr_size  Size of the buffer pointed to by string.
##  \param major        Location to receive the library major version.
##  \param minor        Location to receive the library minor version.
##  \param extra        Location to receive the library version extra string.
##  \param extra_size   Size of the buffer pointed to by extra.
##  \param lt_major     Location to receive the ABI major version.
##  \param lt_minor     Location to receive the ABI minor version.
##  \param lt_bug       Location to receive the ABI 'bugfix' version.
##

proc lo_version*(verstr: cstring; verstr_size: cint; major: ptr cint; minor: ptr cint;
                extra: cstring; extra_size: cint; lt_major: ptr cint;
                lt_minor: ptr cint; lt_bug: ptr cint) {.cdecl, importc: "lo_version",
    dynlib: soname.}
## * @}

import lo_macros
