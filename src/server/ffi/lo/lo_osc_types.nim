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
##  \file lo_osc_types.h A liblo header defining OSC-related types and
##  constants.
##

type
  uint8_t* = uint8
  uint16_t* = uint16
  uint32_t* = uint32
  uint64_t* = uint64
  int8_t* = int8
  int16_t* = int16
  int32_t* = int32
  int64_t* = int64
  va_list* = pointer
  ssize_t* = int64

## *
##  \addtogroup liblo
##  @{
##
## *
##  \brief A structure to store OSC TimeTag values.
##

type
  lo_timetag* {.bycopy.} = object
    sec*: uint32_t ## * The number of seconds since Jan 1st 1900 in the UTC timezone.
 ## * The fractions of a second offset from above, expressed as 1/2^32nds
 ##  of a second
    frac*: uint32_t


## *
##  \brief An enumeration of bundle element types liblo can handle.
##
##  The element of a bundle can either be a message or an other bundle.
##

type ## * bundle element is a message
  lo_element_type* {.size: sizeof(cint).} = enum
    LO_ELEMENT_MESSAGE = 1, ## * bundle element is a bundle
    LO_ELEMENT_BUNDLE = 2


## *
##  \brief An enumeration of the OSC types liblo can send and receive.
##
##  The value of the enumeration is the typechar used to tag messages and to
##  specify arguments with lo_send().
##

type ##  basic OSC types
  lo_type* {.size: sizeof(cint).} = enum
    LO_FALSE = 'F',    ## * Sybol representing the value False.
    LO_INFINITUM = 'I' ## * Sybol representing the value Infinitum.
    LO_NIL = 'N',      ## * Sybol representing the value Nil.
    LO_SYMBOL = 'S',  ## * Standard C, NULL terminated, string. Used in systems which distinguish strings and symbols.
    LO_TRUE = 'T',     ## * Sybol representing the value True.
    LO_BLOB = 'b',  ## * OSC binary blob type. Accessed using the lo_blob_*() functions. ##  extended OSC types
    LO_CHAR = 'c',     ## * Standard C, 8 bit, char variable.
    LO_DOUBLE = 'd',   ## * 64 bit IEEE-754 double.
    LO_FLOAT = 'f',    ## * 32 bit IEEE-754 float.
    LO_INT64 = 'h',    ## * 64 bit signed integer.
    LO_INT32 = 'i',    ## * 32 bit signed integer.
    LO_MIDI = 'm',     ## * A 4 byte MIDI packet.
    LO_STRING = 's',   ## * Standard C, NULL terminated string.
    LO_TIMETAG = 't',  ## * OSC TimeTag type, represented by the lo_timetag structure.


## *
##  \brief Union used to read values from incoming messages.
##
##  Types can generally be read using argv[n]->t where n is the argument number
##  and t is the type character, with the exception of strings and symbols which
##  must be read with &argv[n]->t.
##

type
  lo_arg_blob* {.bycopy.} = object
    size*: int32_t
    data*: char

  lo_arg* {.bycopy, union.} = object
    i*: int32_t           ## * 32 bit signed integer.
    i32*: int32_t         ## * 32 bit signed integer.
    h*: int64_t           ## * 64 bit signed integer.
    i64*: int64_t         ## * 64 bit signed integer.
    f*: cfloat            ## * 32 bit IEEE-754 float.
    f32*: cfloat          ## * 32 bit IEEE-754 float.
    d*: cdouble           ## * 64 bit IEEE-754 double.
    f64*: cdouble         ## * 64 bit IEEE-754 double.
    s*: char              ## * Standard C, NULL terminated string.
    S*: char ## * Standard C, NULL terminated, string. Used in systems which distinguish strings and symbols.
    c*: char              ## * Standard C, 8 bit, char.
    m*: array[4, uint8_t] ## * A 4 byte MIDI packet.
    t*: lo_timetag        ## * OSC TimeTag value.
    blob*: lo_arg_blob    ## * Blob *


##  Note: No struct literals in MSVC

## * \brief A timetag constant representing "now".

## * @}
