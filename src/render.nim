import math, parseopt, session, strutils, times, dsp/frame, ffi/sndfile

let t0 = epoch_time()

var
  arg = 0
  duration: int
  path: string

for kind, key, val in getopt():
  case kind
  of cmdArgument:
    case arg
    of 0: duration = key.parse_int
    of 1: path = key
    else: discard
    arg += 1
  of cmdLongOption, cmdShortOption: discard
  of cmdEnd: assert(false) # cannot happen

if arg < 2:
  quit "Usage: ./render <duration in seconds> <path/to/output.wav>"

let frames = duration * SAMPLE_RATE_INT
var info = cast[ptr SF_INFO](SF_INFO.sizeof.alloc)
info.frames = frames
info.samplerate = SAMPLE_RATE_INT
info.channels = CHANNELS
info.format = SF_FORMAT_WAV or SF_FORMAT_PCM_16

let h = path.sf_open(SFM_WRITE, info)
if h.is_nil:
  quit "Failed to create " & path

var state = cast[ptr State](State.sizeof.alloc)[]
state.load

# Write at most one minute at a time to not hog the memory.
const frames_chunk = 60 * SAMPLE_RATE_INT
let buffer = alloc(frames_chunk * CHANNELS * cdouble.sizeof)

var frames_left = frames
const bar_len = 40
stdout.write("[" & " ".repeat(bar_len) & "]")
stdout.flushFile
while frames_left > 0:
  var frames_to_write = min(frames_left, frames_chunk)
  for frame in 0..<frames_to_write:
    let data = state.process()
    for channel in 0..<CHANNELS:
      let i = (channel + frame * CHANNELS).int
      let offset = cast[int](buffer) + i * cdouble.sizeof
      cast[ptr cdouble](offset)[] = data[channel]
    if frame mod SAMPLE_RATE_INT == 0:
      let left = (bar_len*(frames_left-frame)/frames).ceil.int
      stdout.write("\r[" & "#".repeat(bar_len-left) & ">" & " ".repeat(left-1) & "]")
      stdout.flushFile
  discard h.sf_writef_double(cast[ptr cdouble](buffer), frames_to_write)
  frames_left -= frames_to_write
stdout.write("\r[" & "#".repeat(bar_len) & "]")
stdout.flushFile

discard h.sf_close
state.unload
state.addr.dealloc
buffer.dealloc
info.dealloc

echo "\nDone at ", (duration.float / (epoch_time() - t0)).int , "x speed."
