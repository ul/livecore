##
## Vendored rtmidi source
## 
## When static linking, the vendored source code for rtmidi is compiled and
## linked by this module.
## 
## The linking of rtmidi's dependencies are also handled here.
## 
## You do not need to import this module as it is imported by the bindings
## module.
##

{.used.}

import std/os

func cdefine(def: string): string =
  const definePrefix = when defined(vcc): "/D" else: "-D"
  definePrefix & def

func cinclude(incl: string): string =
  const includePrefix = when defined(vcc): "/I" else: "-I"
  includePrefix & incl

when defined(rtmidiUseDll):
  const rtmidiDll* {.strdefine.} = block:
    when defined(linux):
      "librtmidi.so"
    elif defined(macosx):
      "librtmidi.dylib"
    else:
      "rtmidi.dll"
else:
  const
    apiDefine = block:
      when defined(linux):
        "__LINUX_ALSA__"
      elif defined(macosx):
        "__MACOSX_CORE__"
      elif defined(windows):
        "__WINDOWS_MM__"
      else:
        {. error: "unsupported operating system" .}
    rtmidiPassc = block:
      var args: seq[string]
      args.add cdefine(apiDefine)
      when defined(vcc):
        args.add "/EHsc"
      when defined(rtmidiUseJack):
        when defined(windows):
          {. error: "Cannot use JACK on windows" .}
        args.add cdefine("__UNIX_JACK__")
      quoteShellCommand args

  {. compile("rtmidi_c.cpp", rtmidiPassc) .}
  {. compile("RtMidi.cpp", rtmidiPassc) .}

{. passc: quoteShell(cinclude(currentSourcePath().parentDir())) .}

# external libraries.
#  - Linux: ALSA, pthreads
#  - MacOS: CoreMIDI, CoreAudio, CoreFoundation
#  - Windows: Windows multimedia library (winmm)
when defined(linux):
  {. passl: "-lasound -lpthread -lstdc++" .}
elif defined(macosx):
  {. passl: "-framework CoreMIDI -framework CoreAudio -framework CoreFoundation -lstdc++" .}
elif defined(windows):
  when defined(vcc):
    {. passl: "winmm.lib" .}
  else:
    {. passl: "-lwinmm" .}

when defined(rtmidiUseJack):
  {. passl: "-ljack" .}

