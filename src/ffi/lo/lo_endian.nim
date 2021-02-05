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

template lo_swap16*(x: untyped): untyped =
  htons(x)

template lo_swap32*(x: untyped): untyped =
  htonl(x)

type uint32_t = uint32
type uint64_t = uint64

type
  INNER_C_STRUCT_378856124* {.bycopy.} = object
    a*: uint32_t
    b*: uint32_t

  lo_split64* {.bycopy.} = object {.union.}
    all*: uint64_t
    part*: INNER_C_STRUCT_378856124


##  #ifdef _MSC_VER
##  #define LO_INLINE __inline
##  #else
##  #define LO_INLINE inline
##  #endif
##  static LO_INLINE uint64_t lo_swap64(uint64_t x)
##  {
##      lo_split64 in, out;
##      in.all = x;
##      out.part.a = lo_swap32(in.part.b);
##      out.part.b = lo_swap32(in.part.a);
##      return out.all;
##  }
##  #undef LO_INLINE
##  When compiling for an Apple universal build, allow compile-time
##  macros to override autoconf endianness settings.

when defined(LO_BIGENDIAN):
  const
    LO_BIGENDIAN* = 0
##  Host to OSC and OSC to Host conversion macros

when defined(LO_BIGENDIAN):
  template lo_htoo16*(x: untyped): untyped =
    (x)

  template lo_htoo32*(x: untyped): untyped =
    (x)

  template lo_htoo64*(x: untyped): untyped =
    (x)

  template lo_otoh16*(x: untyped): untyped =
    (x)

  template lo_otoh32*(x: untyped): untyped =
    (x)

  template lo_otoh64*(x: untyped): untyped =
    (x)

else:
  # const
  #   lo_htoo16* = lo_swap16
  #   lo_htoo32* = lo_swap32
  #   lo_htoo64* = lo_swap64
  #   lo_otoh16* = lo_swap16
  #   lo_otoh32* = lo_swap32
  #   lo_otoh64* = lo_swap64
  template lo_htoo16*(x: untyped): untyped =
    lo_swap16(x)

  template lo_htoo32*(x: untyped): untyped =
    lo_swap32(x)

  template lo_htoo64*(x: untyped): untyped =
    lo_swap64(x)

  template lo_otoh16*(x: untyped): untyped =
    lo_swap16(x)

  template lo_otoh32*(x: untyped): untyped =
    lo_swap32(x)

  template lo_otoh64*(x: untyped): untyped =
    lo_swap64(x)

##  vi:set ts=8 sts=4 sw=4:
