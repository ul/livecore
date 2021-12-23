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

##  macros that have to be defined after function signatures

##  \brief Left for backward-compatibility.  See
##  LO_DEFAULT_MAX_MSG_SIZE below, and lo_server_max_msg_size().
##

const
  LO_MAX_MSG_SIZE* = 32768

##  \brief Maximum length of incoming UDP messages in bytes.
##

const
  LO_MAX_UDP_MSG_SIZE* = 65535

##  \brief Default maximum length of incoming messages in bytes,
##  corresponds to max UDP message size.
##

const
  LO_DEFAULT_MAX_MSG_SIZE* = LO_MAX_UDP_MSG_SIZE

##  \brief A set of macros to represent different communications transports
##

const
  LO_DEFAULT* = 0x00000000
  LO_UDP* = 0x00000001
  LO_UNIX* = 0x00000002
  LO_TCP* = 0x00000004

##  an internal value, ignored in transmission but check against LO_MARKER in the
##  argument list. Used to do primitive bounds checking

const
  LO_MARKER_A* = cast[pointer](0xDEADBEEFDEADBEEF'i64)
  LO_MARKER_B* = cast[pointer](0xF00BAA23F00BAA23'i64)

template lo_message_add_varargs*(msg, types, list: untyped): untyped =
  lo_message_add_varargs_internal(msg, types, list, "", "")
