const MAX_PROJECTNAME_LENGTH = 256

type
  int64_t = int64
  int32_t = int32
  uint32_t = uint32
  uint64_t = uint64

type
  BelaContext* {.importc: "BelaContext", header: "Bela.h", bycopy.} = object
    audioIn* {.importc: "audioIn".}: ptr cfloat 
    audioOut* {.importc: "audioOut".}: ptr cfloat
    analogIn* {.importc: "analogIn".}: ptr cfloat
    analogOut* {.importc: "analogOut".}: ptr cfloat
    digital* {.importc: "digital".}: ptr uint32_t
    audioFrames* {.importc: "audioFrames".}: uint32_t
    audioInChannels* {.importc: "audioInChannels".}: uint32_t 
    audioOutChannels* {.importc: "audioOutChannels".}: uint32_t 
    audioSampleRate* {.importc: "audioSampleRate".}: cfloat 
    analogFrames* {.importc: "analogFrames".}: uint32_t
    analogInChannels* {.importc: "analogInChannels".}: uint32_t
    analogOutChannels* {.importc: "analogOutChannels".}: uint32_t
    analogSampleRate* {.importc: "analogSampleRate".}: cfloat
    digitalFrames* {.importc: "digitalFrames".}: uint32_t 
    digitalChannels* {.importc: "digitalChannels".}: uint32_t
    digitalSampleRate* {.importc: "digitalSampleRate".}: cfloat 
    audioFramesElapsed* {.importc: "audioFramesElapsed".}: uint64_t
    multiplexerChannels* {.importc: "multiplexerChannels".}: uint32_t
    multiplexerStartingChannel* {.importc: "multiplexerStartingChannel".}: uint32_t
    multiplexerAnalogIn* {.importc: "multiplexerAnalogIn".}: ptr cfloat
    audioExpanderEnabled* {.importc: "audioExpanderEnabled".}: uint32_t
    flags* {.importc: "flags".}: uint32_t
    projectName* {.importc: "projectName".}: array[MAX_PROJECTNAME_LENGTH, char] 
    underrunCount* {.importc: "underrunCount".}: cuint

proc audioWrite*(context: ptr BelaContext; frame: cint; channel: cint; value: cfloat) {.
    inline, importc: "audioWrite", header: "Bela.h".}
