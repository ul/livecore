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

import lo_osc_types

## *
##  \file lo_lowlevel.h The liblo headerfile defining the low-level API
##  functions.
##

import lo_types, lo_errors

## *
##  \defgroup liblolowlevel Low-level OSC API
##
##  Use these functions if you require more precise control over OSC message
##  contruction or handling that what is provided in the high-level functions
##  described in liblo.
##  @{
##
## *
##  \brief Type used to represent numerical values in conversions between OSC
##  types.
##

type
  lo_hires* = clongdouble

## *
##  \brief Send a lo_message object to target targ
##
##  This is slightly more efficient than lo_send() if you want to send a lot of
##  similar messages. The messages are constructed with the lo_message_new() and
##  \ref lo_message_add_int32 "lo_message_add*()" functions.
##

proc lo_send_message*(targ: lo_address; path: cstring;
    msg: lo_message): cint {.cdecl, importc: "lo_send_message", dynlib: soname.}
## *
##  \brief Send a lo_message object to target targ from address of serv
##
##  This is slightly more efficient than lo_send() if you want to send a lot of
##  similar messages. The messages are constructed with the lo_message_new() and
##  \ref lo_message_add_int32 "lo_message_add*()" functions.
##
##  \param targ The address to send the message to
##  \param serv The server socket to send the message from
##               (can be NULL to use new socket)
##  \param path The path to send the message to
##  \param msg  The bundle itself
##

proc lo_send_message_from*(targ: lo_address; serv: lo_server; path: cstring;
                          msg: lo_message): cint {.cdecl,
    importc: "lo_send_message_from", dynlib: soname.}
## *
##  \brief Send a lo_bundle object to address targ
##
##  Bundles are constructed with the
##  lo_bundle_new() and lo_bundle_add_message() functions.
##

proc lo_send_bundle*(targ: lo_address; b: lo_bundle): cint {.cdecl,
    importc: "lo_send_bundle", dynlib: soname.}
## *
##  \brief Send a lo_bundle object to address targ from address of serv
##
##  Bundles are constructed with the
##  lo_bundle_new() and lo_bundle_add_message() functions.
##
##  \param targ The address to send the bundle to
##  \param serv The server socket to send the bundle from
##               (can be NULL to use new socket)
##  \param b    The bundle itself
##

proc lo_send_bundle_from*(targ: lo_address; serv: lo_server;
    b: lo_bundle): cint {.
    cdecl, importc: "lo_send_bundle_from", dynlib: soname.}
## *
##  \brief Create a new lo_message object
##

proc lo_message_new*(): lo_message {.cdecl, importc: "lo_message_new",
                                  dynlib: soname.}
## *
##  \brief  Add one to a message's reference count.
##
##  Messages are reference counted. If a message is multiply referenced,
##  the message's counter should be incremented. It is automatically
##  decremented by lo_message_free lo_message_free_recursive, with
##  lo_message_free_recursive being the preferable method.
##

proc lo_message_incref*(m: lo_message) {.cdecl, importc: "lo_message_incref",
                                      dynlib: soname.}
## *
##  \brief Create a new lo_message object by cloning an already existing one
##

proc lo_message_clone*(m: lo_message): lo_message {.cdecl,
    importc: "lo_message_clone", dynlib: soname.}
## *
##  \brief Free memory allocated by lo_message_new() and any subsequent
##  \ref lo_message_add_int32 lo_message_add*() calls.
##

proc lo_message_free*(m: lo_message) {.cdecl, importc: "lo_message_free",
                                    dynlib: soname.}
## *
##  \brief Append a number of arguments to a message.
##
##  The data will be added in OSC byteorder (bigendian).
##
##  \param m The message to be extended.
##  \param types The types of the data items in the message, types are defined in
##  lo_types_common.h
##  \param ... The data values to be transmitted. The types of the arguments
##  passed here must agree with the types specified in the type parameter.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add*(m: lo_message; types: cstring): cint {.varargs, cdecl,
    importc: "lo_message_add", dynlib: soname.}
## * \internal \brief the real message_add function (don't call directly)

proc lo_message_add_internal*(m: lo_message; file: cstring; line: cint;
    types: cstring): cint {.
    varargs, cdecl, importc: "lo_message_add_internal", dynlib: soname.}
## *
##  \brief Append a varargs list to a message.
##
##  The data will be added in OSC byteorder (bigendian).
##  IMPORTANT: args list must be terminated with LO_ARGS_END, or this call will
##  fail.  This is used to do simple error checking on the sizes of parameters
##  passed.
##
##  \param m The message to be extended.
##  \param types The types of the data items in the message, types are defined in
##  lo_types_common.h
##  \param ap The va_list created by a C function declared with an
##  ellipsis (...) argument, and pre-initialised with
##  "va_start(ap)". The types of the arguments passed here must agree
##  with the types specified in the type parameter.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_varargs*(m: lo_message; types: cstring;
    ap: va_list): cint {.cdecl,

importc: "lo_message_add_varargs", dynlib: soname.}
## * \internal \brief the real message_add_varargs function (don't call directly)

proc lo_message_add_varargs_internal*(m: lo_message; types: cstring; ap: va_list;
                                     file: cstring; line: cint): cint {.cdecl,
    importc: "lo_message_add_varargs_internal", dynlib: soname.}
## *
##  \brief Append a data item and typechar of the specified type to a message.
##
##  The data will be added in OSC byteorder (bigendian).
##
##  \param m The message to be extended.
##  \param a The data item.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_int32*(m: lo_message; a: int32_t): cint {.cdecl,
    importc: "lo_message_add_int32", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_float*(m: lo_message; a: cfloat): cint {.cdecl,
    importc: "lo_message_add_float", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_string*(m: lo_message; a: cstring): cint {.cdecl,
    importc: "lo_message_add_string", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_blob*(m: lo_message; a: lo_blob): cint {.cdecl,
    importc: "lo_message_add_blob", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_int64*(m: lo_message; a: int64_t): cint {.cdecl,
    importc: "lo_message_add_int64", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_timetag*(m: lo_message; a: lo_timetag): cint {.cdecl,
    importc: "lo_message_add_timetag", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_double*(m: lo_message; a: cdouble): cint {.cdecl,
    importc: "lo_message_add_double", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_symbol*(m: lo_message; a: cstring): cint {.cdecl,
    importc: "lo_message_add_symbol", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_char*(m: lo_message; a: char): cint {.cdecl,
    importc: "lo_message_add_char", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_midi*(m: lo_message; a: array[4, uint8_t]): cint {.cdecl,
    importc: "lo_message_add_midi", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_true*(m: lo_message): cint {.cdecl,
    importc: "lo_message_add_true", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_false*(m: lo_message): cint {.cdecl,
    importc: "lo_message_add_false", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_nil*(m: lo_message): cint {.cdecl,
    importc: "lo_message_add_nil", dynlib: soname.}
## *
##  \brief  Append a data item and typechar of the specified type to a message.
##  See lo_message_add_int32() for details.
##
##  \return Less than 0 on failure, 0 on success.
##

proc lo_message_add_infinitum*(m: lo_message): cint {.cdecl,
    importc: "lo_message_add_infinitum", dynlib: soname.}
## *
##  \brief  Returns the source (lo_address) of an incoming message.
##
##  Returns NULL if the message is outgoing. Do not free the returned address.
##

proc lo_message_get_source*(m: lo_message): lo_address {.cdecl,
    importc: "lo_message_get_source", dynlib: soname.}
## *
##  \brief  Returns the timestamp (lo_timetag *) of a bundled incoming message.
##
##  Returns LO_TT_IMMEDIATE if the message is outgoing, or did not arrive
##  contained in a bundle. Do not free the returned timetag.
##

proc lo_message_get_timestamp*(m: lo_message): lo_timetag {.cdecl,
    importc: "lo_message_get_timestamp", dynlib: soname.}
## *
##  \brief  Return the message type tag string.
##
##  The result is valid until further data is added with lo_message_add*().
##

proc lo_message_get_types*(m: lo_message): cstring {.cdecl,
    importc: "lo_message_get_types", dynlib: soname.}
## *
##  \brief  Return the message argument count.
##
##  The result is valid until further data is added with lo_message_add*().
##

proc lo_message_get_argc*(m: lo_message): cint {.cdecl,
    importc: "lo_message_get_argc", dynlib: soname.}
## *
##  \brief  Return the message arguments. Do not free the returned data.
##
##  The result is valid until further data is added with lo_message_add*().
##

proc lo_message_get_argv*(m: lo_message): ptr ptr lo_arg {.cdecl,
    importc: "lo_message_get_argv", dynlib: soname.}
## *
##  \brief  Return the length of a message in bytes.
##
##  \param m The message to be sized
##  \param path The path the message will be sent to
##

proc lo_message_length*(m: lo_message; path: cstring): csize_t {.cdecl,
    importc: "lo_message_length", dynlib: soname.}
## *
##  \brief  Serialise the lo_message object to an area of memory and return a
##  pointer to the serialised form.  Opposite of lo_message_deserialise().
##
##  \param m The message to be serialised
##  \param path The path the message will be sent to
##  \param to The address to serialise to, memory will be allocated if to is
##  NULL.
##  \param size If this pointer is non-NULL the size of the memory area
##  will be written here
##
##  The returned form is suitable to be sent over a low level OSC transport,
##  having the correct endianess and bit-packed structure.
##

proc lo_message_serialise*(m: lo_message; path: cstring; to: pointer;
    size: ptr csize_t): pointer {.
    cdecl, importc: "lo_message_serialise", dynlib: soname.}
## *
##  \brief  Deserialise a raw OSC message and return a new lo_message object.
##  Opposite of lo_message_serialise().
##
##  \param data Pointer to the raw OSC message data in network transmission form
##  (network byte order where appropriate).
##  \param size The size of data in bytes
##  \param result If this pointer is non-NULL, the result or error code will
##  be written here.
##
##  Returns a new lo_message, or NULL if deserialisation fails.
##  Use lo_message_free() to free the resulting object.
##

proc lo_message_deserialise*(data: pointer; size: csize_t;
    result: ptr cint): lo_message {.
    cdecl, importc: "lo_message_deserialise", dynlib: soname.}
## *
##  \brief  Dispatch a raw block of memory containing an OSC message.
##
##  This is useful when a raw block of memory is available that is
##  structured as OSC, and you wish to use liblo to dispatch the
##  message to a handler function as if it had been received over the
##  network.
##
##  \param s The lo_server to use for dispatching.
##  \param data Pointer to the raw OSC message data in network transmission form
##  (network byte order where appropriate).
##  \param size The size of data in bytes
##
##  Returns the number of bytes used if successful, or less than 0 otherwise.
##

proc lo_server_dispatch_data*(s: lo_server; data: pointer;
    size: csize_t): cint {.cdecl,

importc: "lo_server_dispatch_data", dynlib: soname.}
## *
##  \brief  Return the hostname of a lo_address object
##
##  Returned value must not be modified or free'd. Value will be a dotted quad,
##  colon'd IPV6 address, or resolvable name.
##

proc lo_address_get_hostname*(a: lo_address): cstring {.cdecl,
    importc: "lo_address_get_hostname", dynlib: soname.}
## *
##  \brief  Return the port/service name of a lo_address object
##
##  Returned value must not be modified or free'd. Value will be a service name
##  or ASCII representation of the port number.
##

proc lo_address_get_port*(a: lo_address): cstring {.cdecl,
    importc: "lo_address_get_port", dynlib: soname.}
## *
##  \brief  Return the protocol of a lo_address object
##
##  Returned value will be one of LO_UDP, LO_TCP or LO_UNIX.
##

proc lo_address_get_protocol*(a: lo_address): cint {.cdecl,
    importc: "lo_address_get_protocol", dynlib: soname.}
## *
##  \brief  Return a URL representing an OSC address
##
##  Returned value must be free'd.
##

proc lo_address_get_url*(a: lo_address): cstring {.cdecl,
    importc: "lo_address_get_url", dynlib: soname.}
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

proc lo_address_get_ttl*(t: lo_address): cint {.cdecl,
    importc: "lo_address_get_ttl", dynlib: soname.}
## *
##  \brief Set the network interface to use for a given target address.
##
##  The caller should specify either the iface or ip variable.  The IP,
##  if specified, should match the same network family as the OSC
##  address.  (That is, should correctly correspond to IPv4 or IPv6.)
##  Typically the assigned network interface will only be used in the
##  case of sending multicast messages.  It is recommended to use the
##  if_nameindex POSIX function to get a list of network interface
##  names.
##
##  \param t An OSC address.
##  \param iface The name of a network interface on the local system.
##  \param ip The IP address of a network interface on the local system.
##  \return 0 if the interface was successfully identified, or non-zero
##          otherwise.
##

proc lo_address_set_iface*(t: lo_address; iface: cstring;
    ip: cstring): cint {.cdecl,

importc: "lo_address_set_iface", dynlib: soname.}
## *
##  \brief  Get the name of the network interface assigned to an OSC address.
##
##  \param t An OSC address.
##  \return A string pointer or 0 if no interface has been assigned.
##          Caller should not modify the provided string.  It is a
##          legal pointer until the next call to lo_address_set_iface
##          or lo_address_free.
##

proc lo_address_get_iface*(t: lo_address): cstring {.cdecl,
    importc: "lo_address_get_iface", dynlib: soname.}
## *
##  \brief Set the TCP_NODELAY flag on outgoing TCP connections.
##  \param t The address to set this flag for.
##  \param enable Non-zero to set the flag, zero to unset it.
##  \return the previous value of this flag.
##

proc lo_address_set_tcp_nodelay*(t: lo_address; enable: cint): cint {.cdecl,
    importc: "lo_address_set_tcp_nodelay", dynlib: soname.}
## *
##  \brief Set outgoing stream connections (e.g., TCP) to be
##         transmitted using the SLIP packetizing protocol.
##  \param t The address to set this flag for.
##  \param enable Non-zero to set the flag, zero to unset it.
##  \return the previous value of this flag.
##

proc lo_address_set_stream_slip*(t: lo_address; enable: cint): cint {.cdecl,
    importc: "lo_address_set_stream_slip", dynlib: soname.}
## *
##  \brief  Create a new bundle object.
##
##  OSC Bundles encapsulate one or more OSC messages and may include a timestamp
##  indicating when the bundle should be dispatched.
##
##  \param tt The timestamp when the bundle should be handled by the receiver.
##            Pass LO_TT_IMMEDIATE if you want the receiving server to dispatch
##            the bundle as soon as it receives it.
##

proc lo_bundle_new*(tt: lo_timetag): lo_bundle {.cdecl,
    importc: "lo_bundle_new", dynlib: soname.}
## *
##  \brief  Add one to a bundle's reference count.
##
##  Bundles are reference counted. If a bundle is multiply referenced,
##  the bundle's counter should be incremented. It is automatically
##  decremented by lo_bundle_free lo_bundle_free_recursive, with
##  lo_bundle_free_recursive being the preferable method.
##

proc lo_bundle_incref*(b: lo_bundle) {.cdecl, importc: "lo_bundle_incref",
                                    dynlib: soname.}
## *
##  \brief  Adds an OSC message to an existing bundle.
##
##  The message passed is appended to the list of messages in the bundle to be
##  dispatched to 'path'.
##
##  \return 0 if successful, less than 0 otherwise.
##

proc lo_bundle_add_message*(b: lo_bundle; path: cstring;
    m: lo_message): cint {.cdecl,

importc: "lo_bundle_add_message", dynlib: soname.}
## *
##  \brief  Adds an OSC bundle to an existing bundle.
##
##  The child bundle passed is appended to the list of child bundles|messages in the parent bundle to be
##  dispatched.
##
##  \return 0 if successful, less than 0 otherwise.
##

proc lo_bundle_add_bundle*(b: lo_bundle; n: lo_bundle): cint {.cdecl,
    importc: "lo_bundle_add_bundle", dynlib: soname.}
## *
##  \brief  Return the length of a bundle in bytes.
##
##  Includes the marker and typetag length.
##
##  \param b The bundle to be sized
##

proc lo_bundle_length*(b: lo_bundle): csize_t {.cdecl,
    importc: "lo_bundle_length", dynlib: soname.}
## *
##  \brief  Return the number of top-level elements in a bundle.
##
##  \param b The bundle to be counted.
##

proc lo_bundle_count*(b: lo_bundle): cuint {.cdecl, importc: "lo_bundle_count",
    dynlib: soname.}
## *
##  \brief  Gets the element type contained within a bundle.
##
##  Returns a lo_element_type at a given index within a bundle.
##
##  \return The requested lo_element_type if successful, otherwise 0.
##

proc lo_bundle_get_type*(b: lo_bundle; index: cint): lo_element_type {.cdecl,
    importc: "lo_bundle_get_type", dynlib: soname.}
## *
##  \brief  Gets a nested bundle contained within a bundle.
##
##  Returns a lo_bundle at a given index within a bundle.
##
##  \return The requested lo_bundle if successful, otherwise 0.
##

proc lo_bundle_get_bundle*(b: lo_bundle; index: cint): lo_bundle {.cdecl,
    importc: "lo_bundle_get_bundle", dynlib: soname.}
## *
##  \brief  Gets a message contained within a bundle.
##
##  Returns a lo_message at a given index within a bundle, and
##  optionally the path associated with that message.
##
##  \return The requested lo_message if successful, otherwise 0.
##

proc lo_bundle_get_message*(b: lo_bundle; index: cint;
    path: cstringArray): lo_message {.
    cdecl, importc: "lo_bundle_get_message", dynlib: soname.}
## *
##  \brief  Get the timestamp associated with a bundle.
##
##  \param b The bundle for which the timestamp should be returned.
##
##  \return The timestamp of the bundle as a lo_timetag.
##

proc lo_bundle_get_timestamp*(b: lo_bundle): lo_timetag {.cdecl,
    importc: "lo_bundle_get_timestamp", dynlib: soname.}
## *
##  \brief  Serialise the bundle object to an area of memory and return a
##  pointer to the serialised form.
##
##  \param b The bundle to be serialised
##  \param to The address to serialise to, memory will be allocated if to is
##  NULL.
##  \param size If this pointer is non-NULL the size of the memory area
##  will be written here
##
##  The returned form is suitable to be sent over a low level OSC transport,
##  having the correct endianess and bit-packed structure.
##

proc lo_bundle_serialise*(b: lo_bundle; to: pointer;
    size: ptr csize_t): pointer {.cdecl,

importc: "lo_bundle_serialise", dynlib: soname.}
## *
##  \brief  Frees the memory taken by a bundle object.
##
##  \param b The bundle to be freed.
##

proc lo_bundle_free*(b: lo_bundle) {.cdecl, importc: "lo_bundle_free",
                                  dynlib: soname.}
## *
##  \brief  Frees the memory taken by a bundle object and its messages and nested bundles recursively.
##
##  \param b The bundle, which may contain messages and nested bundles, to be freed.
##

proc lo_bundle_free_recursive*(b: lo_bundle) {.cdecl,
    importc: "lo_bundle_free_recursive", dynlib: soname.}
## *
##  \brief  Obsolete, use lo_bundle_free_recursive instead.
##
##  \param b The bundle, which may contain messages and nested bundles, to be freed.
##

proc lo_bundle_free_messages*(b: lo_bundle) {.cdecl,
    importc: "lo_bundle_free_messages", dynlib: soname.}
## *
##  \brief Return true if the type specified has a numerical value, such as
##  LO_INT32, LO_FLOAT etc.
##
##  \param a The type to be tested.
##

proc lo_is_numerical_type*(a: lo_type): cint {.cdecl,
    importc: "lo_is_numerical_type", dynlib: soname.}
## *
##  \brief Return true if the type specified has a textual value, such as
##  LO_STRING or LO_SYMBOL.
##
##  \param a The type to be tested.
##

proc lo_is_string_type*(a: lo_type): cint {.cdecl, importc: "lo_is_string_type",
                                        dynlib: soname.}
## *
##  \brief Attempt to convert one OSC type to another.
##
##  Numerical types (eg LO_INT32, LO_FLOAT etc.) may be converted to other
##  numerical types and string types (LO_STRING and LO_SYMBOL) may be converted
##  to the other type. This is done automatically if a received message matches
##  the path, but not the exact types, and is coercible (ie. all numerical
##  types in numerical positions).
##
##  On failure no translation occurs and false is returned.
##
##  \param type_to   The type of the destination variable.
##  \param to        A pointer to the destination variable.
##  \param type_from The type of the source variable.
##  \param from      A pointer to the source variable.
##

proc lo_coerce*(type_to: lo_type; to: ptr lo_arg; type_from: lo_type;
    `from`: ptr lo_arg): cint {.
    cdecl, importc: "lo_coerce", dynlib: soname.}
## *
##  \brief Return the numerical value of the given argument with the
##  maximum native system precision.
##

proc lo_hires_val*(`type`: lo_type; p: ptr lo_arg): lo_hires {.cdecl,
    importc: "lo_hires_val", dynlib: soname.}
## *
##  \brief Create a new server instance.
##
##  Using lo_server_recv(), lo_servers block until they receive OSC
##  messages.  If you want non-blocking behaviour see
##  lo_server_recv_noblock() or the \ref lo_server_thread_new
##  "lo_server_thread_*" functions.
##
##  \param port If NULL is passed then an unused UDP port will be chosen by the
##  system, its number may be retrieved with lo_server_thread_get_port()
##  so it can be passed to clients. Otherwise a decimal port number, service
##  name or UNIX domain socket path may be passed.
##  \param err_h An error callback function that will be called if there is an
##  error in messge reception or server creation. Pass NULL if you do not want
##  error handling.
##

proc lo_server_new*(port: cstring; err_h: lo_err_handler): lo_server {.cdecl,
    importc: "lo_server_new", dynlib: soname.}
## *
##  \brief Create a new server instance, specifying protocol.
##
##  Using lo_server_recv(), lo_servers block until they receive OSC
##  messages.  If you want non-blocking behaviour see
##  lo_server_recv_noblock() or the \ref lo_server_thread_new
##  "lo_server_thread_*" functions.
##
##  \param port If using UDP then NULL may be passed to find an unused port.
##  Otherwise a decimal port number orservice name or may be passed.
##  If using UNIX domain sockets then a socket path should be passed here.
##  \param proto The protocol to use, should be one of LO_UDP, LO_TCP or LO_UNIX.
##  \param err_h An error callback function that will be called if there is an
##  error in messge reception or server creation. Pass NULL if you do not want
##  error handling.
##

proc lo_server_new_with_proto*(port: cstring; proto: cint;
    err_h: lo_err_handler): lo_server {.
    cdecl, importc: "lo_server_new_with_proto", dynlib: soname.}
## *
##  \brief Create a new server instance, and join a UDP multicast group.
##
##  \param group The multicast group to join.  See documentation on IP
##  multicast for the acceptable address range; e.g., http://tldp.org/HOWTO/Multicast-HOWTO-2.html
##  \param port If using UDP then NULL may be passed to find an unused port.
##  Otherwise a decimal port number or service name or may be passed.
##  If using UNIX domain sockets then a socket path should be passed here.
##  \param err_h An error callback function that will be called if there is an
##  error in messge reception or server creation. Pass NULL if you do not want
##  error handling.
##

proc lo_server_new_multicast*(group: cstring; port: cstring;
    err_h: lo_err_handler): lo_server {.
    cdecl, importc: "lo_server_new_multicast", dynlib: soname.}
## *
##  \brief Create a new server instance, and join a UDP multicast
##  group, optionally specifying which network interface to use.
##  Note that usually only one of iface or ip are specified.
##
##  \param group The multicast group to join.  See documentation on IP
##  multicast for the acceptable address range; e.g., http://tldp.org/HOWTO/Multicast-HOWTO-2.html
##  \param port If using UDP then NULL may be passed to find an unused port.
##  Otherwise a decimal port number or service name or may be passed.
##  If using UNIX domain sockets then a socket path should be passed here.
##  \param iface A string specifying the name of a network interface to
##  use, or zero if not specified.
##  \param ip A string specifying the IP address of a network interface
##  to use, or zero if not specified.
##  \param err_h An error callback function that will be called if there is an
##  error in messge reception or server creation. Pass NULL if you do not want
##  error handling.
##

proc lo_server_new_multicast_iface*(group: cstring; port: cstring; iface: cstring;
                                   ip: cstring;
                                       err_h: lo_err_handler): lo_server {.
    cdecl, importc: "lo_server_new_multicast_iface", dynlib: soname.}
## *
##  \brief Create a new server instance, taking port and the optional
##  multicast group IP from an URL string.
##
##  \param url The URL to specify the server parameters.
##  \param err_h An error callback function that will be called if there is an
##  error in messge reception or server creation. Pass NULL if you do not want
##  error handling.
##  \return A new lo_server instance.
##

proc lo_server_new_from_url*(url: cstring;
    err_h: lo_err_handler): lo_server {.cdecl,

importc: "lo_server_new_from_url", dynlib: soname.}
## *
##  \brief Enables or disables type coercion during message dispatch.
##  \param server The server to toggle this option for.
##  \param enable Non-zero to enable, or zero to disable type coercion.
##  \return The previous value of this option.
##

proc lo_server_enable_coercion*(server: lo_server; enable: cint): cint {.cdecl,
    importc: "lo_server_enable_coercion", dynlib: soname.}
## *
##  \brief Free up memory used by the lo_server object
##

proc lo_server_free*(s: lo_server) {.cdecl, importc: "lo_server_free",
                                  dynlib: soname.}
## *
##  \brief Wait for an OSC message to be received
##
##  \param s The server to wait for connections on.
##  \param timeout A timeout in milliseconds to wait for the incoming packet.
##  a value of 0 will return immediately.
##
##  The return value is 1 if there is a message waiting or 0 if
##  there is no message. If there is a message waiting you can now
##  call lo_server_recv() to receive that message.
##

proc lo_server_wait*(s: lo_server; timeout: cint): cint {.cdecl,
    importc: "lo_server_wait", dynlib: soname.}
## *
##  \brief Look for an OSC message waiting to be received
##
##  \param s The server to wait for connections on.
##  \param timeout A timeout in milliseconds to wait for the incoming packet.
##  a value of 0 will return immediately.
##
##  The return value is the number of bytes in the received message or 0 if
##  there is no message. The message will be dispatched to a matching method
##  if one is found.
##

proc lo_server_recv_noblock*(s: lo_server; timeout: cint): cint {.cdecl,
    importc: "lo_server_recv_noblock", dynlib: soname.}
## *
##  \brief Block, waiting for an OSC message to be received
##
##  The return value is the number of bytes in the received message. The message
##  will be dispatched to a matching method if one is found.
##

proc lo_server_recv*(s: lo_server): cint {.cdecl, importc: "lo_server_recv",
                                       dynlib: soname.}
## *
##  \brief Add an OSC method to the specifed server.
##
##  \param s The server the method is to be added to.
##  \param path The OSC path to register the method to. If NULL is passed the
##  method will match all paths.
##  \param typespec The typespec the method accepts. Incoming messages with
##  similar typespecs (e.g. ones with numerical types in the same position) will
##  be coerced to the typespec given here.
##  \param h The method handler callback function that will be called if a
##  matching message is received
##  \param user_data A value that will be passed to the callback function, h,
##  when its invoked matching from this method.
##  \return A unique pointer identifying the method.  It should not be freed.
##

proc lo_server_add_method*(s: lo_server; path: cstring; typespec: cstring;
                          h: lo_method_handler;
                              user_data: pointer): lo_method {.
    cdecl, importc: "lo_server_add_method", dynlib: soname.}
## *
##  \brief Delete an OSC method from the specified server.
##
##  \param s The server the method is to be removed from.
##  \param path The OSC path of the method to delete. If NULL is passed the
##  method will match the generic handler.
##  \param typespec The typespec the method accepts.
##

proc lo_server_del_method*(s: lo_server; path: cstring;
    typespec: cstring) {.cdecl,

importc: "lo_server_del_method", dynlib: soname.}
## *
##  \brief Delete a specific OSC method from the specified server.
##
##  \param s The server the method is to be removed from.
##  \param m The lo_method identifier returned from lo_server_add_method for
##           the method to delete from the server.
##  \return Non-zero if it was not found in the list of methods for the server.
##

proc lo_server_del_lo_method*(s: lo_server; m: lo_method): cint {.cdecl,
    importc: "lo_server_del_lo_method", dynlib: soname.}
## *
##  \brief Add bundle notification handlers to the specified server.
##
##  \param s The server the method is to be added to.
##  \param sh The callback function that will be called before the messages
##  of a bundle are dispatched
##  \param eh The callback function that will be called after the messages
##  of a bundle are dispatched
##  \param user_data A value that will be passed to the user_data parameter
##  of both callback functions.
##

proc lo_server_add_bundle_handlers*(s: lo_server; sh: lo_bundle_start_handler;
                                   eh: lo_bundle_end_handler;
                                       user_data: pointer): cint {.
    cdecl, importc: "lo_server_add_bundle_handlers", dynlib: soname.}
## *
##  \brief Return the file descriptor of the server socket.
##
##  If the server protocol supports exposing the server's underlying
##  receive mechanism for monitoring with select() or poll(), this function
##  returns the file descriptor needed, otherwise, it returns -1.
##
##  WARNING: when using this function beware that not all OSC packets that are
##  received are dispatched immediately. lo_server_events_pending() and
##  lo_server_next_event_delay() can be used to tell if there are pending
##  events and how long before you should attempt to receive them.
##

proc lo_server_get_socket_fd*(s: lo_server): cint {.cdecl,
    importc: "lo_server_get_socket_fd", dynlib: soname.}
## *
##  \brief Return the port number that the server has bound to.
##
##  Useful when NULL is passed for the port number and you wish to know how to
##  address the server.
##

proc lo_server_get_port*(s: lo_server): cint {.cdecl,
    importc: "lo_server_get_port", dynlib: soname.}
## *
##  \brief  Return the protocol that the server is using.
##
##  Returned value will be one of LO_UDP, LO_TCP or LO_UNIX.
##

proc lo_server_get_protocol*(s: lo_server): cint {.cdecl,
    importc: "lo_server_get_protocol", dynlib: soname.}
## *
##  \brief Return an OSC URL that can be used to contact the server.
##
##  The return value should be free()'d when it is no longer needed.
##

proc lo_server_get_url*(s: lo_server): cstring {.cdecl,
    importc: "lo_server_get_url", dynlib: soname.}
## *
##  \brief Toggle event queue.
##  If queueing is enabled, timetagged messages that are sent in
##  advance of the current time will be put on an internal queue, and
##  they will be dispatched at the indicated time.  By default,
##  queueing is enabled.  Use this function to disable it, if it is
##  desired to have a server process messages immediately.  In that
##  case, use lo_message_get_timestamp() to get the message timestamp
##  from within a method handler.
##  \param s A liblo server
##  \param queue_enabled Zero to disable queue, non-zero to enable.
##  \param dispatch_remaining If non-zero, previously queued messages
##                            will be immediately dispatched when queue
##                            is disabled.
##  \return The previous state of queue behaviour.  Zero if queueing
##          was previously disabled, non-zero otherwise.
##

proc lo_server_enable_queue*(s: lo_server; queue_enabled: cint;
                            dispatch_remaining: cint): cint {.cdecl,
    importc: "lo_server_enable_queue", dynlib: soname.}
## *
##  \brief Return true if there are scheduled events (eg. from bundles)
##  waiting to be dispatched by the server
##

proc lo_server_events_pending*(s: lo_server): cint {.cdecl,
    importc: "lo_server_events_pending", dynlib: soname.}
## *
##  \brief Return the time in seconds until the next scheduled event.
##
##  If the delay is greater than 100 seconds then it will return 100.0.
##

proc lo_server_next_event_delay*(s: lo_server): cdouble {.cdecl,
    importc: "lo_server_next_event_delay", dynlib: soname.}
## *
##  \brief Set the maximum message size accepted by a server.
##
##  For UDP servers, the maximum message size cannot exceed 64k, due to
##  the UDP transport specifications.  For TCP servers, this number may
##  be larger, but be aware that one or more contiguous blocks of
##  memory of this size may be allocated by liblo.  (At least one per
##  connection.)
##
##  \param s The server on which to operate.
##  \param req_size The new maximum message size to request, 0 if it
##  should not be modified, or -1 if it should be set to unlimited.
##  Note that an unlimited message buffer may make your application
##  open to a denial of service attack.
##  \return The new maximum message size is returned, which may or may
##  not be equal to req_size.  If -1 is returned, maximum size is
##  unlimited.
##

proc lo_server_max_msg_size*(s: lo_server; req_size: cint): cint {.cdecl,
    importc: "lo_server_max_msg_size", dynlib: soname.}
## *
##  \brief Return the protocol portion of an OSC URL, eg. udp, tcp.
##
##  This library uses OSC URLs of the form: osc.prot://hostname:port/path if the
##  prot part is missing, UDP is assumed.
##
##  The return value should be free()'d when it is no longer needed.
##

proc lo_url_get_protocol*(url: cstring): cstring {.cdecl,
    importc: "lo_url_get_protocol", dynlib: soname.}
## *
##  \brief Return the protocol ID of an OSC URL.
##
##  This library uses OSC URLs of the form: osc.prot://hostname:port/path if the
##  prot part is missing, UDP is assumed.
##  Returned value will be one of LO_UDP, LO_TCP, LO_UNIX or -1.
##
##  \return An integer specifying the protocol. Return -1 when the protocol is
##  not supported by liblo.
##
##

proc lo_url_get_protocol_id*(url: cstring): cint {.cdecl,
    importc: "lo_url_get_protocol_id", dynlib: soname.}
## *
##  \brief Return the hostname portion of an OSC URL.
##
##  The return value should be free()'d when it is no longer needed.
##

proc lo_url_get_hostname*(url: cstring): cstring {.cdecl,
    importc: "lo_url_get_hostname", dynlib: soname.}
## *
##  \brief Return the port portion of an OSC URL.
##
##  The return value should be free()'d when it is no longer needed.
##

proc lo_url_get_port*(url: cstring): cstring {.cdecl,
    importc: "lo_url_get_port", dynlib: soname.}
## *
##  \brief Return the path portion of an OSC URL.
##
##  The return value should be free()'d when it is no longer needed.
##

proc lo_url_get_path*(url: cstring): cstring {.cdecl,
    importc: "lo_url_get_path", dynlib: soname.}
##  utility functions
## *
##  \brief A function to calculate the amount of OSC message space required by a
##  C char *.
##
##  Returns the storage size in bytes, which will always be a multiple of four.
##

proc lo_strsize*(s: cstring): cint {.cdecl, importc: "lo_strsize",
    dynlib: soname.}
## *
##  \brief A function to calculate the amount of OSC message space required by a
##  lo_blob object.
##
##  Returns the storage size in bytes, which will always be a multiple of four.
##

proc lo_blobsize*(b: lo_blob): uint32_t {.cdecl, importc: "lo_blobsize",
                                      dynlib: soname.}
## *
##  \brief Test a string against an OSC pattern glob
##
##  \param str The string to test
##  \param p   The pattern to test against
##

proc lo_pattern_match*(str: cstring; p: cstring): cint {.cdecl,
    importc: "lo_pattern_match", dynlib: soname.}
## * \internal \brief the real send function (don't call directly)

proc lo_send_internal*(t: lo_address; file: cstring; line: cint; path: cstring;
                      types: cstring): cint {.varargs, cdecl,
    importc: "lo_send_internal", dynlib: soname.}
## * \internal \brief the real send_timestamped function (don't call directly)

proc lo_send_timestamped_internal*(t: lo_address; file: cstring; line: cint;
                                  ts: lo_timetag; path: cstring;
                                      types: cstring): cint {.
    varargs, cdecl, importc: "lo_send_timestamped_internal", dynlib: soname.}
## * \internal \brief the real lo_send_from() function (don't call directly)

proc lo_send_from_internal*(targ: lo_address; `from`: lo_server; file: cstring;
                           line: cint; ts: lo_timetag; path: cstring;
                               types: cstring): cint {.
    varargs, cdecl, importc: "lo_send_from_internal", dynlib: soname.}
## * \brief Find the time difference between two timetags
##
##  Returns a - b in seconds.
##

proc lo_timetag_diff*(a: lo_timetag; b: lo_timetag): cdouble {.cdecl,
    importc: "lo_timetag_diff", dynlib: soname.}
## * \brief Return a timetag for the current time
##
##  On exit the timetag pointed to by t is filled with the OSC
##  representation of this instant in time.
##

proc lo_timetag_now*(t: ptr lo_timetag) {.cdecl, importc: "lo_timetag_now",
                                      dynlib: soname.}
## *
##  \brief Return the storage size, in bytes, of the given argument.
##

proc lo_arg_size*(`type`: lo_type; data: pointer): csize_t {.cdecl,
    importc: "lo_arg_size", dynlib: soname.}
## *
##  \brief Given a raw OSC message, return the message path.
##
##  \param data      A pointer to the raw OSC message data.
##  \param size      The size of data in bytes (total buffer bytes).
##
##  Returns the message path or NULL if an error occurs.
##  Do not free() the returned pointer.
##

proc lo_get_path*(data: pointer; size: ssize_t): cstring {.cdecl,
    importc: "lo_get_path", dynlib: soname.}
## *
##  \brief Convert the specified argument to host byte order where necessary.
##
##  \param type The OSC type of the data item (eg. LO_FLOAT).
##  \param data A pointer to the data item to be converted. It is changed
##  in-place.
##

proc lo_arg_host_endian*(`type`: lo_type; data: pointer) {.cdecl,
    importc: "lo_arg_host_endian", dynlib: soname.}
## *
##  \brief Convert the specified argument to network byte order where necessary.
##
##  \param type The OSC type of the data item (eg. LO_FLOAT).
##  \param data A pointer to the data item to be converted. It is changed
##  in-place.
##

proc lo_arg_network_endian*(`type`: lo_type; data: pointer) {.cdecl,
    importc: "lo_arg_network_endian", dynlib: soname.}
## * @}
##  prettyprinters
## *
##  \defgroup pp Prettyprinting functions
##
##  These functions all print an ASCII representation of their argument to
##  stdout. Useful for debugging.
##  @{
##
## * \brief Pretty-print a lo_bundle object.

proc lo_bundle_pp*(b: lo_bundle) {.cdecl, importc: "lo_bundle_pp",
    dynlib: soname.}
## * \brief Pretty-print a lo_message object.

proc lo_message_pp*(m: lo_message) {.cdecl, importc: "lo_message_pp",
                                  dynlib: soname.}
## * \brief Pretty-print a set of typed arguments.
##  \param type A type string in the form provided to lo_send().
##  \param data An OSC data pointer, like that provided in the
##  lo_method_handler.
##

proc lo_arg_pp*(`type`: lo_type; data: pointer) {.cdecl, importc: "lo_arg_pp",
    dynlib: soname.}
## * \brief Pretty-print a lo_server object.

proc lo_server_pp*(s: lo_server) {.cdecl, importc: "lo_server_pp",
    dynlib: soname.}
## * \brief Pretty-print a lo_method object.

proc lo_method_pp*(m: lo_method) {.cdecl, importc: "lo_method_pp",
    dynlib: soname.}
## * \brief Pretty-print a lo_method object, but prepend a given prefix
##  to all field names.

proc lo_method_pp_prefix*(m: lo_method; p: cstring) {.cdecl,
    importc: "lo_method_pp_prefix", dynlib: soname.}
## * @}
