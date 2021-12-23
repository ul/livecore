##
## * Copyright (C) 1999-2016 Erik de Castro Lopo <erikd@mega-nerd.com>
## *
## * This program is free software; you can redistribute it and/or modify
## * it under the terms of the GNU Lesser General Public License as published by
## * the Free Software Foundation; either version 2.1 of the License, or
## * (at your option) any later version.
## *
## * This program is distributed in the hope that it will be useful,
## * but WITHOUT ANY WARRANTY; without even the implied warranty of
## * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## * GNU Lesser General Public License for more details.
## *
## * You should have received a copy of the GNU Lesser General Public License
## * along with this program; if not, write to the Free Software
## * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
##
##
## * sndfile.h -- system-wide definitions
## *
## * API documentation is in the doc/ directory of the source code tarball
## * and at http://www.mega-nerd.com/libsndfile/api.html.
##

when defined(linux):
  {.passl: "-Wl,-Bstatic -lsndfile -Wl,-Bdynamic".}
else:
  {.passl: "-lsndfile".}

##  This is the version 1.0.X header file.

const
  SNDFILE_1* = true

##  The following file types can be read and written.
## * A file type would consist of a major type (ie SF_FORMAT_WAV) bitwise
## * ORed with a minor type (ie SF_FORMAT_PCM). SF_FORMAT_TYPEMASK and
## * SF_FORMAT_SUBMASK can be used to separate the major and minor file
## * types.
##

const                               ##  Major formats.
  SF_FORMAT_WAV* = 0x00010000       ##  Microsoft WAV format (little endian default).
  SF_FORMAT_AIFF* = 0x00020000      ##  Apple/SGI AIFF format (big endian).
  SF_FORMAT_AU* = 0x00030000        ##  Sun/NeXT AU format (big endian).
  SF_FORMAT_RAW* = 0x00040000       ##  RAW PCM data.
  SF_FORMAT_PAF* = 0x00050000       ##  Ensoniq PARIS file format.
  SF_FORMAT_SVX* = 0x00060000       ##  Amiga IFF / SVX8 / SV16 format.
  SF_FORMAT_NIST* = 0x00070000      ##  Sphere NIST format.
  SF_FORMAT_VOC* = 0x00080000       ##  VOC files.
  SF_FORMAT_IRCAM* = 0x000A0000     ##  Berkeley/IRCAM/CARL
  SF_FORMAT_W64* = 0x000B0000       ##  Sonic Foundry's 64 bit RIFF/WAV
  SF_FORMAT_MAT4* = 0x000C0000      ##  Matlab (tm) V4.2 / GNU Octave 2.0
  SF_FORMAT_MAT5* = 0x000D0000      ##  Matlab (tm) V5.0 / GNU Octave 2.1
  SF_FORMAT_PVF* = 0x000E0000       ##  Portable Voice Format
  SF_FORMAT_XI* = 0x000F0000        ##  Fasttracker 2 Extended Instrument
  SF_FORMAT_HTK* = 0x00100000       ##  HMM Tool Kit format
  SF_FORMAT_SDS* = 0x00110000       ##  Midi Sample Dump Standard
  SF_FORMAT_AVR* = 0x00120000       ##  Audio Visual Research
  SF_FORMAT_WAVEX* = 0x00130000     ##  MS WAVE with WAVEFORMATEX
  SF_FORMAT_SD2* = 0x00160000       ##  Sound Designer 2
  SF_FORMAT_FLAC* = 0x00170000      ##  FLAC lossless file format
  SF_FORMAT_CAF* = 0x00180000       ##  Core Audio File format
  SF_FORMAT_WVE* = 0x00190000       ##  Psion WVE format
  SF_FORMAT_OGG* = 0x00200000       ##  Xiph OGG container
  SF_FORMAT_MPC2K* = 0x00210000     ##  Akai MPC 2000 sampler
  SF_FORMAT_RF64* = 0x00220000      ##  RF64 WAV file
                                    ##  Subtypes from here on.
  SF_FORMAT_PCM_S8* = 0x00000001    ##  Signed 8 bit data
  SF_FORMAT_PCM_16* = 0x00000002    ##  Signed 16 bit data
  SF_FORMAT_PCM_24* = 0x00000003    ##  Signed 24 bit data
  SF_FORMAT_PCM_32* = 0x00000004    ##  Signed 32 bit data
  SF_FORMAT_PCM_U8* = 0x00000005    ##  Unsigned 8 bit data (WAV and RAW only)
  SF_FORMAT_FLOAT* = 0x00000006     ##  32 bit float data
  SF_FORMAT_DOUBLE* = 0x00000007    ##  64 bit float data
  SF_FORMAT_ULAW* = 0x00000010      ##  U-Law encoded.
  SF_FORMAT_ALAW* = 0x00000011      ##  A-Law encoded.
  SF_FORMAT_IMA_ADPCM* = 0x00000012 ##  IMA ADPCM.
  SF_FORMAT_MS_ADPCM* = 0x00000013  ##  Microsoft ADPCM.
  SF_FORMAT_GSM610* = 0x00000020    ##  GSM 6.10 encoding.
  SF_FORMAT_VOX_ADPCM* = 0x00000021 ##  OKI / Dialogix ADPCM
  SF_FORMAT_G721_32* = 0x00000030   ##  32kbs G721 ADPCM encoding.
  SF_FORMAT_G723_24* = 0x00000031   ##  24kbs G723 ADPCM encoding.
  SF_FORMAT_G723_40* = 0x00000032   ##  40kbs G723 ADPCM encoding.
  SF_FORMAT_DWVW_12* = 0x00000040   ##  12 bit Delta Width Variable Word encoding.
  SF_FORMAT_DWVW_16* = 0x00000041   ##  16 bit Delta Width Variable Word encoding.
  SF_FORMAT_DWVW_24* = 0x00000042   ##  24 bit Delta Width Variable Word encoding.
  SF_FORMAT_DWVW_N* = 0x00000043    ##  N bit Delta Width Variable Word encoding.
  SF_FORMAT_DPCM_8* = 0x00000050    ##  8 bit differential PCM (XI only)
  SF_FORMAT_DPCM_16* = 0x00000051   ##  16 bit differential PCM (XI only)
  SF_FORMAT_VORBIS* = 0x00000060    ##  Xiph Vorbis encoding.
  SF_FORMAT_ALAC_16* = 0x00000070   ##  Apple Lossless Audio Codec (16 bit).
  SF_FORMAT_ALAC_20* = 0x00000071   ##  Apple Lossless Audio Codec (20 bit).
  SF_FORMAT_ALAC_24* = 0x00000072   ##  Apple Lossless Audio Codec (24 bit).
  SF_FORMAT_ALAC_32* = 0x00000073   ##  Apple Lossless Audio Codec (32 bit).
                                    ##  Endian-ness options.
  SF_ENDIAN_FILE* = 0x00000000      ##  Default file endian-ness.
  SF_ENDIAN_LITTLE* = 0x10000000    ##  Force little endian-ness.
  SF_ENDIAN_BIG* = 0x20000000       ##  Force big endian-ness.
  SF_ENDIAN_CPU* = 0x30000000       ##  Force CPU endian-ness.
  SF_FORMAT_SUBMASK* = 0x0000FFFF
  SF_FORMAT_TYPEMASK* = 0x0FFF0000
  SF_FORMAT_ENDMASK* = 0x30000000

##
## * The following are the valid command numbers for the sf_command()
## * interface.  The use of these commands is documented in the file
## * command.html in the doc directory of the source code distribution.
##

const
  SFC_GET_LIB_VERSION* = 0x00001000
  SFC_GET_LOG_INFO* = 0x00001001
  SFC_GET_CURRENT_SF_INFO* = 0x00001002
  SFC_GET_NORM_DOUBLE* = 0x00001010
  SFC_GET_NORM_FLOAT* = 0x00001011
  SFC_SET_NORM_DOUBLE* = 0x00001012
  SFC_SET_NORM_FLOAT* = 0x00001013
  SFC_SET_SCALE_FLOAT_INT_READ* = 0x00001014
  SFC_SET_SCALE_INT_FLOAT_WRITE* = 0x00001015
  SFC_GET_SIMPLE_FORMAT_COUNT* = 0x00001020
  SFC_GET_SIMPLE_FORMAT* = 0x00001021
  SFC_GET_FORMAT_INFO* = 0x00001028
  SFC_GET_FORMAT_MAJOR_COUNT* = 0x00001030
  SFC_GET_FORMAT_MAJOR* = 0x00001031
  SFC_GET_FORMAT_SUBTYPE_COUNT* = 0x00001032
  SFC_GET_FORMAT_SUBTYPE* = 0x00001033
  SFC_CALC_SIGNAL_MAX* = 0x00001040
  SFC_CALC_NORM_SIGNAL_MAX* = 0x00001041
  SFC_CALC_MAX_ALL_CHANNELS* = 0x00001042
  SFC_CALC_NORM_MAX_ALL_CHANNELS* = 0x00001043
  SFC_GET_SIGNAL_MAX* = 0x00001044
  SFC_GET_MAX_ALL_CHANNELS* = 0x00001045
  SFC_SET_ADD_PEAK_CHUNK* = 0x00001050
  SFC_SET_ADD_HEADER_PAD_CHUNK* = 0x00001051
  SFC_UPDATE_HEADER_NOW* = 0x00001060
  SFC_SET_UPDATE_HEADER_AUTO* = 0x00001061
  SFC_FILE_TRUNCATE* = 0x00001080
  SFC_SET_RAW_START_OFFSET* = 0x00001090
  SFC_SET_DITHER_ON_WRITE* = 0x000010A0
  SFC_SET_DITHER_ON_READ* = 0x000010A1
  SFC_GET_DITHER_INFO_COUNT* = 0x000010A2
  SFC_GET_DITHER_INFO* = 0x000010A3
  SFC_GET_EMBED_FILE_INFO* = 0x000010B0
  SFC_SET_CLIPPING* = 0x000010C0
  SFC_GET_CLIPPING* = 0x000010C1
  SFC_GET_CUE_COUNT* = 0x000010CD
  SFC_GET_CUE* = 0x000010CE
  SFC_SET_CUE* = 0x000010CF
  SFC_GET_INSTRUMENT* = 0x000010D0
  SFC_SET_INSTRUMENT* = 0x000010D1
  SFC_GET_LOOP_INFO* = 0x000010E0
  SFC_GET_BROADCAST_INFO* = 0x000010F0
  SFC_SET_BROADCAST_INFO* = 0x000010F1
  SFC_GET_CHANNEL_MAP_INFO* = 0x00001100
  SFC_SET_CHANNEL_MAP_INFO* = 0x00001101
  SFC_RAW_DATA_NEEDS_ENDSWAP* = 0x00001110  ##  Support for Wavex Ambisonics Format
  SFC_WAVEX_SET_AMBISONIC* = 0x00001200
  SFC_WAVEX_GET_AMBISONIC* = 0x00001201     ##
                                          ## * RF64 files can be set so that on-close, writable files that have less
                                          ## * than 4GB of data in them are converted to RIFF/WAV, as per EBU
                                            ## * recommendations.
                                            ##
  SFC_RF64_AUTO_DOWNGRADE* = 0x00001210
  SFC_SET_VBR_ENCODING_QUALITY* = 0x00001300
  SFC_SET_COMPRESSION_LEVEL* = 0x00001301   ##  Cart Chunk support
  SFC_SET_CART_INFO* = 0x00001400
  SFC_GET_CART_INFO* = 0x00001401           ##  Following commands for testing only.
  SFC_TEST_IEEE_FLOAT_REPLACE* = 0x00006001 ##
                                            ## * SFC_SET_ADD_* values are deprecated and will disappear at some
                                            ## * time in the future. They are guaranteed to be here up to and
                                            ## * including version 1.0.8 to avoid breakage of existing software.
                                            ## * They currently do nothing and will continue to do nothing.
                                            ##
  SFC_SET_ADD_DITHER_ON_WRITE* = 0x00001070
  SFC_SET_ADD_DITHER_ON_READ* = 0x00001071

##
## * String types that can be set and read from files. Not all file types
## * support this and even the file types which support one, may not support
## * all string types.
##

const
  SF_STR_TITLE* = 0x00000001
  SF_STR_COPYRIGHT* = 0x00000002
  SF_STR_SOFTWARE* = 0x00000003
  SF_STR_ARTIST* = 0x00000004
  SF_STR_COMMENT* = 0x00000005
  SF_STR_DATE* = 0x00000006
  SF_STR_ALBUM* = 0x00000007
  SF_STR_LICENSE* = 0x00000008
  SF_STR_TRACKNUMBER* = 0x00000009
  SF_STR_GENRE* = 0x00000010

##
## * Use the following as the start and end index when doing metadata
## * transcoding.
##

const
  SF_STR_FIRST* = SF_STR_TITLE
  SF_STR_LAST* = SF_STR_GENRE

const          ##  True and false
  SF_FALSE* = 0
  SF_TRUE* = 1 ##  Modes for opening files.
  SFM_READ* = 0x00000010
  SFM_WRITE* = 0x00000020
  SFM_RDWR* = 0x00000030
  SF_AMBISONIC_NONE* = 0x00000040
  SF_AMBISONIC_B_FORMAT* = 0x00000041

##  Public error values. These are guaranteed to remain unchanged for the duration
## * of the library major version number.
## * There are also a large number of private error numbers which are internal to
## * the library which can change at any time.
##

const
  SF_ERR_NO_ERROR* = 0
  SF_ERR_UNRECOGNISED_FORMAT* = 1
  SF_ERR_SYSTEM* = 2
  SF_ERR_MALFORMED_FILE* = 3
  SF_ERR_UNSUPPORTED_ENCODING* = 4

##  Channel map values (used with SFC_SET/GET_CHANNEL_MAP).
##

const
  SF_CHANNEL_MAP_INVALID* = 0
  SF_CHANNEL_MAP_MONO* = 1
  SF_CHANNEL_MAP_LEFT* = 2                  ##  Apple calls this 'Left'
  SF_CHANNEL_MAP_RIGHT* = 3                 ##  Apple calls this 'Right'
  SF_CHANNEL_MAP_CENTER* = 4                ##  Apple calls this 'Center'
  SF_CHANNEL_MAP_FRONT_LEFT* = 5
  SF_CHANNEL_MAP_FRONT_RIGHT* = 6
  SF_CHANNEL_MAP_FRONT_CENTER* = 7
  SF_CHANNEL_MAP_REAR_CENTER* = 8 ##  Apple calls this 'Center Surround', Msft calls this 'Back Center'
  SF_CHANNEL_MAP_REAR_LEFT* = 9 ##  Apple calls this 'Left Surround', Msft calls this 'Back Left'
  SF_CHANNEL_MAP_REAR_RIGHT* = 10 ##  Apple calls this 'Right Surround', Msft calls this 'Back Right'
  SF_CHANNEL_MAP_LFE* = 11 ##  Apple calls this 'LFEScreen', Msft calls this 'Low Frequency'
  SF_CHANNEL_MAP_FRONT_LEFT_OF_CENTER* = 12 ##  Apple calls this 'Left Center'
  SF_CHANNEL_MAP_FRONT_RIGHT_OF_CENTER * = 13 ##  Apple calls this 'Right Center
  SF_CHANNEL_MAP_SIDE_LEFT* = 14            ##  Apple calls this 'Left Surround Direct'
  SF_CHANNEL_MAP_SIDE_RIGHT* = 15           ##  Apple calls this 'Right Surround Direct'
  SF_CHANNEL_MAP_TOP_CENTER* = 16           ##  Apple calls this 'Top Center Surround'
  SF_CHANNEL_MAP_TOP_FRONT_LEFT* = 17       ##  Apple calls this 'Vertical Height Left'
  SF_CHANNEL_MAP_TOP_FRONT_RIGHT* = 18      ##  Apple calls this 'Vertical Height Right'
  SF_CHANNEL_MAP_TOP_FRONT_CENTER* = 19     ##  Apple calls this 'Vertical Height Center'
  SF_CHANNEL_MAP_TOP_REAR_LEFT* = 20        ##  Apple and MS call this 'Top Back Left'
  SF_CHANNEL_MAP_TOP_REAR_RIGHT* = 21       ##  Apple and MS call this 'Top Back Right'
  SF_CHANNEL_MAP_TOP_REAR_CENTER* = 22      ##  Apple and MS call this 'Top Back Center'
  SF_CHANNEL_MAP_AMBISONIC_B_W* = 23
  SF_CHANNEL_MAP_AMBISONIC_B_X* = 24
  SF_CHANNEL_MAP_AMBISONIC_B_Y* = 25
  SF_CHANNEL_MAP_AMBISONIC_B_Z* = 26
  SF_CHANNEL_MAP_MAX* = 27

##  A SNDFILE* pointer can be passed around much like stdio.h's FILE* pointer.

type
  SNDFILE* = pointer

##  The following typedef is system specific and is defined when libsndfile is
## * compiled. sf_count_t will be a 64 bit value when the underlying OS allows
## * 64 bit file offsets.
## * On windows, we need to allow the same header file to be compiler by both GCC
## * and the Microsoft compiler.
##

type
  int64_t = int64
  int32_t = int32
  uint32_t = uint32

type
  sf_count_t* = int64_t
const
  SF_COUNT_MAX* = 0x7FFFFFFFFFFFFFFF'i64
 ##  A pointer to a SF_INFO structure is passed to sf_open () and filled in.
 ## * On write, the SF_INFO structure is filled in by the user and passed into
 ## * sf_open ().
 ##

type
  SF_INFO* {.importc: "SF_INFO", header: "sndfile.h", bycopy.} = object
    frames* {.importc: "frames".}: sf_count_t ##  Used to be called samples.  Changed to avoid confusion.
    samplerate* {.importc: "samplerate".}: cint
    channels* {.importc: "channels".}: cint
    format* {.importc: "format".}: cint
    sections* {.importc: "sections".}: cint
    seekable* {.importc: "seekable".}: cint


##  The SF_FORMAT_INFO struct is used to retrieve information about the sound
## * file formats libsndfile supports using the sf_command () interface.
## *
## * Using this interface will allow applications to support new file formats
## * and encoding types when libsndfile is upgraded, without requiring
## * re-compilation of the application.
## *
## * Please consult the libsndfile documentation (particularly the information
## * on the sf_command () interface) for examples of its use.
##

type
  SF_FORMAT_INFO* {.importc: "SF_FORMAT_INFO", header: "sndfile.h",
      bycopy.} = object
    format* {.importc: "format".}: cint
    name* {.importc: "name".}: cstring
    extension* {.importc: "extension".}: cstring


##
## * Enums and typedefs for adding dither on read and write.
## * See the html documentation for sf_command(), SFC_SET_DITHER_ON_WRITE
## * and SFC_SET_DITHER_ON_READ.
##

const
  SFD_DEFAULT_LEVEL* = 0
  SFD_CUSTOM_LEVEL* = 0x40000000
  SFD_NO_DITHER* = 500
  SFD_WHITE* = 501
  SFD_TRIANGULAR_PDF* = 502

type
  SF_DITHER_INFO* {.importc: "SF_DITHER_INFO", header: "sndfile.h",
      bycopy.} = object
    `type`* {.importc: "type".}: cint
    level* {.importc: "level".}: cdouble
    name* {.importc: "name".}: cstring


##  Struct used to retrieve information about a file embedded within a
## * larger file. See SFC_GET_EMBED_FILE_INFO.
##

type
  SF_EMBED_FILE_INFO* {.importc: "SF_EMBED_FILE_INFO", header: "sndfile.h",
      bycopy.} = object
    offset* {.importc: "offset".}: sf_count_t
    length* {.importc: "length".}: sf_count_t


##
## *	Struct used to retrieve cue marker information from a file
##

type
  SF_CUE_POINT* {.importc: "SF_CUE_POINT", header: "sndfile.h",
      bycopy.} = object
    indx* {.importc: "indx".}: int32_t
    position* {.importc: "position".}: uint32_t
    fcc_chunk* {.importc: "fcc_chunk".}: int32_t
    chunk_start* {.importc: "chunk_start".}: int32_t
    block_start* {.importc: "block_start".}: int32_t
    sample_offset* {.importc: "sample_offset".}: uint32_t
    name* {.importc: "name".}: array[256, char]


##
## *	Structs used to retrieve music sample information from a file.
##

const ##
      ## *	The loop mode field in SF_INSTRUMENT will be one of the following.
      ##
  SF_LOOP_NONE* = 800
  SF_LOOP_FORWARD* = 801
  SF_LOOP_BACKWARD* = 802
  SF_LOOP_ALTERNATING* = 803

type
  INNER_C_STRUCT_3943598867* {.importc: "no_name", header: "sndfile.h",
      bycopy.} = object
    mode* {.importc: "mode".}: cint
    start* {.importc: "start".}: uint32_t
    `end`* {.importc: "end".}: uint32_t
    count* {.importc: "count".}: uint32_t

  SF_INSTRUMENT* {.importc: "SF_INSTRUMENT", header: "sndfile.h",
      bycopy.} = object
    gain* {.importc: "gain".}: cint
    basenote* {.importc: "basenote".}: char
    detune* {.importc: "detune".}: char
    velocity_lo* {.importc: "velocity_lo".}: char
    velocity_hi* {.importc: "velocity_hi".}: char
    key_lo* {.importc: "key_lo".}: char
    key_hi* {.importc: "key_hi".}: char
    loop_count* {.importc: "loop_count".}: cint
    loops* {.importc: "loops".}: array[16,
        INNER_C_STRUCT_3943598867] ##  make variable in a sensible way


##  Struct used to retrieve loop information from a file.

type
  SF_LOOP_INFO* {.importc: "SF_LOOP_INFO", header: "sndfile.h",
      bycopy.} = object
    time_sig_num* {.importc: "time_sig_num".}: cshort ##  any positive integer    > 0
    time_sig_den* {.importc: "time_sig_den".}: cshort ##  any positive power of 2 > 0
    loop_mode* {.importc: "loop_mode".}: cint ##  see SF_LOOP enum
    num_beats* {.importc: "num_beats".}: cint ##  this is NOT the amount of quarter notes !!!
                                              ##  a full bar of 4/4 is 4 beats
                                              ##  a full bar of 7/8 is 7 beats
    bpm* {.importc: "bpm".}: cfloat ##  suggestion, as it can be calculated using other fields:
                                      ##  file's length, file's sampleRate and our time_sig_den
                                      ##  -> bpms are always the amount of _quarter notes_ per minute
    root_key* {.importc: "root_key".}: cint   ##  MIDI note, or -1 for None
    future* {.importc: "future".}: array[6, cint]

  SF_CART_TIMER* {.importc: "SF_CART_TIMER", header: "sndfile.h",
      bycopy.} = object
    usage* {.importc: "usage".}: array[4, char]
    value* {.importc: "value".}: int32_t


## 	Virtual I/O functionality.

type
  sf_vio_get_filelen* = proc (user_data: pointer): sf_count_t
  sf_vio_seek* = proc (offset: sf_count_t; whence: cint;
      user_data: pointer): sf_count_t
  sf_vio_read* = proc (`ptr`: pointer; count: sf_count_t;
      user_data: pointer): sf_count_t
  sf_vio_write* = proc (`ptr`: pointer; count: sf_count_t;
      user_data: pointer): sf_count_t
  sf_vio_tell* = proc (user_data: pointer): sf_count_t
  SF_VIRTUAL_IO* {.importc: "SF_VIRTUAL_IO", header: "sndfile.h",
      bycopy.} = object
    get_filelen* {.importc: "get_filelen".}: sf_vio_get_filelen
    seek* {.importc: "seek".}: sf_vio_seek
    read* {.importc: "read".}: sf_vio_read
    write* {.importc: "write".}: sf_vio_write
    tell* {.importc: "tell".}: sf_vio_tell


##  Open the specified file for read, write or both. On error, this will
## * return a NULL pointer. To find the error number, pass a NULL SNDFILE
## * to sf_strerror ().
## * All calls to sf_open() should be matched with a call to sf_close().
##

proc sf_open*(path: cstring; mode: cint; sfinfo: ptr SF_INFO): ptr SNDFILE {.
    importc: "sf_open", header: "sndfile.h".}
##  Use the existing file descriptor to create a SNDFILE object. If close_desc
## * is TRUE, the file descriptor will be closed when sf_close() is called. If
## * it is FALSE, the descriptor will not be closed.
## * When passed a descriptor like this, the library will assume that the start
## * of file header is at the current file offset. This allows sound files within
## * larger container files to be read and/or written.
## * On error, this will return a NULL pointer. To find the error number, pass a
## * NULL SNDFILE to sf_strerror ().
## * All calls to sf_open_fd() should be matched with a call to sf_close().
##
##

proc sf_open_fd*(fd: cint; mode: cint; sfinfo: ptr SF_INFO;
    close_desc: cint): ptr SNDFILE {.
    importc: "sf_open_fd", header: "sndfile.h".}
proc sf_open_virtual*(sfvirtual: ptr SF_VIRTUAL_IO; mode: cint; sfinfo: ptr SF_INFO;
                     user_data: pointer): ptr SNDFILE {.importc: "sf_open_virtual",
    header: "sndfile.h".}
##  sf_error () returns a error number which can be translated to a text
## * string using sf_error_number().
##

proc sf_error*(sndfile: ptr SNDFILE): cint {.importc: "sf_error",
    header: "sndfile.h".}
##  sf_strerror () returns to the caller a pointer to the current error message for
## * the given SNDFILE.
##

proc sf_strerror*(sndfile: ptr SNDFILE): cstring {.importc: "sf_strerror",
    header: "sndfile.h".}
##  sf_error_number () allows the retrieval of the error string for each internal
## * error number.
## *
##

proc sf_error_number*(errnum: cint): cstring {.importc: "sf_error_number",
    header: "sndfile.h".}
##  The following two error functions are deprecated but they will remain in the
## * library for the foreseeable future. The function sf_strerror() should be used
## * in their place.
##

proc sf_perror*(sndfile: ptr SNDFILE): cint {.importc: "sf_perror",
    header: "sndfile.h".}
proc sf_error_str*(sndfile: ptr SNDFILE; str: cstring; len: csize_t): cint {.
    importc: "sf_error_str", header: "sndfile.h".}
##  Return TRUE if fields of the SF_INFO struct are a valid combination of values.

proc sf_command*(sndfile: ptr SNDFILE; command: cint; data: pointer;
    datasize: cint): cint {.
    importc: "sf_command", header: "sndfile.h".}
##  Return TRUE if fields of the SF_INFO struct are a valid combination of values.

proc sf_format_check*(info: ptr SF_INFO): cint {.importc: "sf_format_check",
    header: "sndfile.h".}
##  Seek within the waveform data chunk of the SNDFILE. sf_seek () uses
## * the same values for whence (SEEK_SET, SEEK_CUR and SEEK_END) as
## * stdio.h function fseek ().
## * An offset of zero with whence set to SEEK_SET will position the
## * read / write pointer to the first data sample.
## * On success sf_seek returns the current position in (multi-channel)
## * samples from the start of the file.
## * Please see the libsndfile documentation for moving the read pointer
## * separately from the write pointer on files open in mode SFM_RDWR.
## * On error all of these functions return -1.
##

const
  SF_SEEK_SET* = 0
  SF_SEEK_CUR* = 1
  SF_SEEK_END* = 2

proc sf_seek*(sndfile: ptr SNDFILE; frames: sf_count_t;
    whence: cint): sf_count_t {.
    importc: "sf_seek", header: "sndfile.h".}
##  Functions for retrieving and setting string data within sound files.
## * Not all file types support this features; AIFF and WAV do. For both
## * functions, the str_type parameter must be one of the SF_STR_* values
## * defined above.
## * On error, sf_set_string() returns non-zero while sf_get_string()
## * returns NULL.
##

proc sf_set_string*(sndfile: ptr SNDFILE; str_type: cint; str: cstring): cint {.
    importc: "sf_set_string", header: "sndfile.h".}
proc sf_get_string*(sndfile: ptr SNDFILE; str_type: cint): cstring {.
    importc: "sf_get_string", header: "sndfile.h".}
##  Return the library version string.

proc sf_version_string*(): cstring {.importc: "sf_version_string",
                                  header: "sndfile.h".}
##  Return the current byterate at this point in the file. The byte rate in this
## * case is the number of bytes per second of audio data. For instance, for a
## * stereo, 18 bit PCM encoded file with an 16kHz sample rate, the byte rate
## * would be 2 (stereo) * 2 (two bytes per sample) * 16000 => 64000 bytes/sec.
## * For some file formats the returned value will be accurate and exact, for some
## * it will be a close approximation, for some it will be the average bitrate for
## * the whole file and for some it will be a time varying value that was accurate
## * when the file was most recently read or written.
## * To get the bitrate, multiple this value by 8.
## * Returns -1 for unknown.
##

proc sf_current_byterate*(sndfile: ptr SNDFILE): cint {.
    importc: "sf_current_byterate", header: "sndfile.h".}
##  Functions for reading/writing the waveform data of a sound file.
##

proc sf_read_raw*(sndfile: ptr SNDFILE; `ptr`: pointer;
    bytes: sf_count_t): sf_count_t {.
    importc: "sf_read_raw", header: "sndfile.h".}
proc sf_write_raw*(sndfile: ptr SNDFILE; `ptr`: pointer;
    bytes: sf_count_t): sf_count_t {.
    importc: "sf_write_raw", header: "sndfile.h".}
##  Functions for reading and writing the data chunk in terms of frames.
## * The number of items actually read/written = frames * number of channels.
## *     sf_xxxx_raw		read/writes the raw data bytes from/to the file
## *     sf_xxxx_short	passes data in the native short format
## *     sf_xxxx_int		passes data in the native int format
## *     sf_xxxx_float	passes data in the native float format
## *     sf_xxxx_double	passes data in the native double format
## * All of these read/write function return number of frames read/written.
##

proc sf_readf_short*(sndfile: ptr SNDFILE; `ptr`: ptr cshort;
    frames: sf_count_t): sf_count_t {.
    importc: "sf_readf_short", header: "sndfile.h".}
proc sf_writef_short*(sndfile: ptr SNDFILE; `ptr`: ptr cshort;
    frames: sf_count_t): sf_count_t {.
    importc: "sf_writef_short", header: "sndfile.h".}
proc sf_readf_int*(sndfile: ptr SNDFILE; `ptr`: ptr cint;
    frames: sf_count_t): sf_count_t {.
    importc: "sf_readf_int", header: "sndfile.h".}
proc sf_writef_int*(sndfile: ptr SNDFILE; `ptr`: ptr cint;
    frames: sf_count_t): sf_count_t {.
    importc: "sf_writef_int", header: "sndfile.h".}
proc sf_readf_float*(sndfile: ptr SNDFILE; `ptr`: ptr cfloat;
    frames: sf_count_t): sf_count_t {.
    importc: "sf_readf_float", header: "sndfile.h".}
proc sf_writef_float*(sndfile: ptr SNDFILE; `ptr`: ptr cfloat;
    frames: sf_count_t): sf_count_t {.
    importc: "sf_writef_float", header: "sndfile.h".}
proc sf_readf_double*(sndfile: ptr SNDFILE; `ptr`: ptr cdouble;
    frames: sf_count_t): sf_count_t {.
    importc: "sf_readf_double", header: "sndfile.h".}
proc sf_writef_double*(sndfile: ptr SNDFILE; `ptr`: ptr cdouble;
    frames: sf_count_t): sf_count_t {.
    importc: "sf_writef_double", header: "sndfile.h".}
##  Functions for reading and writing the data chunk in terms of items.
## * Otherwise similar to above.
## * All of these read/write function return number of items read/written.
##

proc sf_read_short*(sndfile: ptr SNDFILE; `ptr`: ptr cshort;
    items: sf_count_t): sf_count_t {.
    importc: "sf_read_short", header: "sndfile.h".}
proc sf_write_short*(sndfile: ptr SNDFILE; `ptr`: ptr cshort;
    items: sf_count_t): sf_count_t {.
    importc: "sf_write_short", header: "sndfile.h".}
proc sf_read_int*(sndfile: ptr SNDFILE; `ptr`: ptr cint;
    items: sf_count_t): sf_count_t {.
    importc: "sf_read_int", header: "sndfile.h".}
proc sf_write_int*(sndfile: ptr SNDFILE; `ptr`: ptr cint;
    items: sf_count_t): sf_count_t {.
    importc: "sf_write_int", header: "sndfile.h".}
proc sf_read_float*(sndfile: ptr SNDFILE; `ptr`: ptr cfloat;
    items: sf_count_t): sf_count_t {.
    importc: "sf_read_float", header: "sndfile.h".}
proc sf_write_float*(sndfile: ptr SNDFILE; `ptr`: ptr cfloat;
    items: sf_count_t): sf_count_t {.
    importc: "sf_write_float", header: "sndfile.h".}
proc sf_read_double*(sndfile: ptr SNDFILE; `ptr`: ptr cdouble;
    items: sf_count_t): sf_count_t {.
    importc: "sf_read_double", header: "sndfile.h".}
proc sf_write_double*(sndfile: ptr SNDFILE; `ptr`: ptr cdouble;
    items: sf_count_t): sf_count_t {.
    importc: "sf_write_double", header: "sndfile.h".}
##  Close the SNDFILE and clean up all memory allocations associated with this
## * file.
## * Returns 0 on success, or an error number.
##

proc sf_close*(sndfile: ptr SNDFILE): cint {.importc: "sf_close",
    header: "sndfile.h".}
##  If the file is opened SFM_WRITE or SFM_RDWR, call fsync() on the file
## * to force the writing of data to disk. If the file is opened SFM_READ
## * no action is taken.
##

proc sf_write_sync*(sndfile: ptr SNDFILE) {.importc: "sf_write_sync",
                                        header: "sndfile.h".}
##  The function sf_wchar_open() is Windows Only!
## * Open a file passing in a Windows Unicode filename. Otherwise, this is
## * the same as sf_open().
## *
## * In order for this to work, you need to do the following:
## *
## *		#include <windows.h>
## *		#define ENABLE_SNDFILE_WINDOWS_PROTOTYPES 1
## *		#including <sndfile.h>
##

when defined(ENABLE_SNDFILE_WINDOWS_PROTOTYPES):
  proc sf_wchar_open*(wpath: LPCWSTR; mode: cint;
      sfinfo: ptr SF_INFO): ptr SNDFILE {.
      importc: "sf_wchar_open", header: "sndfile.h".}
##  Getting and setting of chunks from within a sound file.
## *
## * These functions allow the getting and setting of chunks within a sound file
## * (for those formats which allow it).
## *
## * These functions fail safely. Specifically, they will not allow you to overwrite
## * existing chunks or add extra versions of format specific reserved chunks but
## * should allow you to retrieve any and all chunks (may not be implemented for
## * all chunks or all file formats).
##

type
  SF_CHUNK_INFO* {.importc: "SF_CHUNK_INFO", header: "sndfile.h",
      bycopy.} = object
    id* {.importc: "id".}: array[64, char] ##  The chunk identifier.
    id_size* {.importc: "id_size".}: cuint ##  The size of the chunk identifier.
    datalen* {.importc: "datalen".}: cuint ##  The size of that data.
    data* {.importc: "data".}: pointer     ##  Pointer to the data.


##  Set the specified chunk info (must be done before any audio data is written
## * to the file). This will fail for format specific reserved chunks.
## * The chunk_info->data pointer must be valid until the file is closed.
## * Returns SF_ERR_NO_ERROR on success or non-zero on failure.
##

proc sf_set_chunk*(sndfile: ptr SNDFILE; chunk_info: ptr SF_CHUNK_INFO): cint {.
    importc: "sf_set_chunk", header: "sndfile.h".}
##
## * An opaque structure to an iterator over the all chunks of a given id
##


##  Get an iterator for all chunks matching chunk_info.
## * The iterator will point to the first chunk matching chunk_info.
## * Chunks are matching, if (chunk_info->id) matches the first
## *     (chunk_info->id_size) bytes of a chunk found in the SNDFILE* handle.
## * If chunk_info is NULL, an iterator to all chunks in the SNDFILE* handle
## *     is returned.
## * The values of chunk_info->datalen and chunk_info->data are ignored.
## * If no matching chunks are found in the sndfile, NULL is returned.
## * The returned iterator will stay valid until one of the following occurs:
## *     a) The sndfile is closed.
## *     b) A new chunk is added using sf_set_chunk().
## *     c) Another chunk iterator function is called on the same SNDFILE* handle
## *        that causes the iterator to be modified.
## * The memory for the iterator belongs to the SNDFILE* handle and is freed when
## * sf_close() is called.
##

type SF_CHUNK_ITERATOR = pointer

proc sf_get_chunk_iterator*(sndfile: ptr SNDFILE;
    chunk_info: ptr SF_CHUNK_INFO): ptr SF_CHUNK_ITERATOR {.
    importc: "sf_get_chunk_iterator", header: "sndfile.h".}
##  Iterate through chunks by incrementing the iterator.
## * Increments the iterator and returns a handle to the new one.
## * After this call, iterator will no longer be valid, and you must use the
## *      newly returned handle from now on.
## * The returned handle can be used to access the next chunk matching
## *      the criteria as defined in sf_get_chunk_iterator().
## * If iterator points to the last chunk, this will free all resources
## *      associated with iterator and return NULL.
## * The returned iterator will stay valid until sf_get_chunk_iterator_next
## *      is called again, the sndfile is closed or a new chunk us added.
##

proc sf_next_chunk_iterator*(`iterator`: ptr SF_CHUNK_ITERATOR): ptr SF_CHUNK_ITERATOR {.
    importc: "sf_next_chunk_iterator", header: "sndfile.h".}
##  Get the size of the specified chunk.
## * If the specified chunk exists, the size will be returned in the
## *      datalen field of the SF_CHUNK_INFO struct.
## *      Additionally, the id of the chunk will be copied to the id
## *      field of the SF_CHUNK_INFO struct and it's id_size field will
## *      be updated accordingly.
## * If the chunk doesn't exist chunk_info->datalen will be zero, and the
## *      id and id_size fields will be undefined.
## * The function will return SF_ERR_NO_ERROR on success or non-zero on
## * failure.
##

proc sf_get_chunk_size*(it: ptr SF_CHUNK_ITERATOR;
    chunk_info: ptr SF_CHUNK_INFO): cint {.
    importc: "sf_get_chunk_size", header: "sndfile.h".}
##  Get the specified chunk data.
## * If the specified chunk exists, up to chunk_info->datalen bytes of
## *      the chunk data will be copied into the chunk_info->data buffer
## *      (allocated by the caller) and the chunk_info->datalen field
## *      updated to reflect the size of the data. The id and id_size
## *      field will be updated according to the retrieved chunk
## * If the chunk doesn't exist chunk_info->datalen will be zero, and the
## *      id and id_size fields will be undefined.
## * The function will return SF_ERR_NO_ERROR on success or non-zero on
## * failure.
##

proc sf_get_chunk_data*(it: ptr SF_CHUNK_ITERATOR;
    chunk_info: ptr SF_CHUNK_INFO): cint {.
    importc: "sf_get_chunk_data", header: "sndfile.h".}
