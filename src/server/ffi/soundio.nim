when defined(linux):
  {.passl: "-Wl,-Bstatic -lsoundio -Wl,-Bdynamic".}
else:
  {.passl: "-lsoundio".}

{.pragma: sio, cdecl, header: "soundio/soundio.h", importc: "soundio_$1".}
{.pragma: cenum, pure, final, size: sizeof(cint).}
{.pragma: siochan, sio, importc: "soundio_channel_layout_$1"}
{.pragma: siodev, sio, importc: "soundio_device_$1"}
{.pragma: sioout, sio, importc: "soundio_outstream_$1"}
{.pragma: sioin, sio, importc: "soundio_instream_$1"}
{.pragma: siorb, sio, importc: "soundio_ring_buffer_$1"}

type
  SoundIoError* {.cenum.} = enum
    ## See also ::soundio_strerror
    None,
    NoMem, ## Out of memory.
    InitAudioBackend, ## The backend does not appear to be active or running.
    SystemResources, ## A system resource other than memory was not available.
    OpeningDevice, ## Attempted to open a device and failed.
    NoSuchDevice,
    Invalid, ## The programmer did not comply with the API.
    BackendUnavailable, ## libsoundio was compiled without support for that backend.
    Streaming, ## An open stream had an error that can only be recovered from by destroying the stream and creating it again.
    IncompatibleDevice, ## Attempted to use a device with parameters it cannot support.
    NoSuchClient, ## When JACK returns `JackNoSuchClient`
    IncompatibleBackend, ## Attempted to use parameters that the backend cannot support.
    BackendDisconnected, ## Backend server shutdown or became inactive.
    Interrupted,
    Underflow, ## Buffer underrun occurred.
    EncodingString ## Unable to convert to or from UTF-8 to the native string format.

type
  SoundIoChannelId* {.cenum.} = enum
    ## Specifies where a channel is physically located.
    Invalid,

    FrontLeft, ##< First of the more commonly supported ids.
    FrontRight,
    FrontCenter,
    Lfe,
    BackLeft,
    BackRight,
    FrontLeftCenter,
    FrontRightCenter,
    BackCenter,
    SideLeft,
    SideRight,
    TopCenter,
    TopFrontLeft,
    TopFrontCenter,
    TopFrontRight,
    TopBackLeft,
    TopBackCenter,
    TopBackRight, ##< Last of the more commonly supported ids.

    BackLeftCenter, ##< First of the less commonly supported ids.
    BackRightCenter,
    FrontLeftWide,
    FrontRightWide,
    FrontLeftHigh,
    FrontCenterHigh,
    FrontRightHigh,
    TopFrontLeftCenter,
    TopFrontRightCenter,
    TopSideLeft,
    TopSideRight,
    LeftLfe,
    RightLfe,
    Lfe2,
    BottomCenter,
    BottomLeftCenter,
    BottomRightCenter,

    ## Mid/side recording
    MsMid,
    MsSide,

    ## first order ambisonic channels
    AmbisonicW,
    AmbisonicX,
    AmbisonicY,
    AmbisonicZ,

    ## X-Y Recording
    XyX,
    XyY,

    HeadphonesLeft, ##< First of the "other" channel ids
    HeadphonesRight,
    ClickTrack,
    ForeignLanguage,
    HearingImpaired,
    Narration,
    Haptic,
    DialogCentricMix, ##< Last of the "other" channel ids

    Aux,
    Aux0,
    Aux1,
    Aux2,
    Aux3,
    Aux4,
    Aux5,
    Aux6,
    Aux7,
    Aux8,
    Aux9,
    Aux10,
    Aux11,
    Aux12,
    Aux13,
    Aux14,
    Aux15


type
  SoundIoChannelLayoutId* {.cenum.} = enum
    ## Built-in channel layouts for convenience.
    SoundIoChannelLayoutIdMono, SoundIoChannelLayoutIdStereo,
    SoundIoChannelLayoutId2Point1, SoundIoChannelLayoutId3Point0,
    SoundIoChannelLayoutId3Point0Back, SoundIoChannelLayoutId3Point1,
    SoundIoChannelLayoutId4Point0, SoundIoChannelLayoutIdQuad,
    SoundIoChannelLayoutIdQuadSide, SoundIoChannelLayoutId4Point1,
    SoundIoChannelLayoutId5Point0Back, SoundIoChannelLayoutId5Point0Side,
    SoundIoChannelLayoutId5Point1, SoundIoChannelLayoutId5Point1Back,
    SoundIoChannelLayoutId6Point0Side, SoundIoChannelLayoutId6Point0Front,
    SoundIoChannelLayoutIdHexagonal, SoundIoChannelLayoutId6Point1,
    SoundIoChannelLayoutId6Point1Back, SoundIoChannelLayoutId6Point1Front,
    SoundIoChannelLayoutId7Point0, SoundIoChannelLayoutId7Point0Front,
    SoundIoChannelLayoutId7Point1, SoundIoChannelLayoutId7Point1Wide,
    SoundIoChannelLayoutId7Point1WideBack, SoundIoChannelLayoutIdOctagonal

type
  SoundIoBackend* {.cenum.} = enum
    None,
    Jack,
    PulseAudio,
    Alsa,
    CoreAudio,
    Wasapi,
    Dummy

type
  SoundIoDeviceAim* {.cenum.} = enum
    Input, ##< capture / recording
    Output ##< playback

type
  SoundIoFormat* {.cenum.} = enum
    ## For your convenience, Native Endian and Foreign Endian constants are defined
    ## which point to the respective SoundIoFormat values.
    Invalid,
    S8,        ##< Signed 8 bit
    U8,        ##< Unsigned 8 bit
    S16LE,     ##< Signed 16 bit Little Endian
    S16BE,     ##< Signed 16 bit Big Endian
    U16LE,     ##< Unsigned 16 bit Little Endian
    U16BE,     ##< Unsigned 16 bit Little Endian
    S24LE,     ##< Signed 24 bit Little Endian using low three bytes in 32-bit word
    S24BE,     ##< Signed 24 bit Big Endian using low three bytes in 32-bit word
    U24LE,     ##< Unsigned 24 bit Little Endian using low three bytes in 32-bit word
    U24BE,     ##< Unsigned 24 bit Big Endian using low three bytes in 32-bit word
    S32LE,     ##< Signed 32 bit Little Endian
    S32BE,     ##< Signed 32 bit Big Endian
    U32LE,     ##< Unsigned 32 bit Little Endian
    U32BE,     ##< Unsigned 32 bit Big Endian
    Float32LE, ##< Float 32 bit Little Endian, Range -1.0 to 1.0
    Float32BE, ##< Float 32 bit Big Endian, Range -1.0 to 1.0
    Float64LE, ##< Float 64 bit Little Endian, Range -1.0 to 1.0
    Float64BE  ##< Float 64 bit Big Endian, Range -1.0 to 1.0

when cpuEndian == bigEndian:
  const
    SoundIoFormatS16NE* = SoundIoFormat.S16BE
    SoundIoFormatU16NE* = SoundIoFormat.U16BE
    SoundIoFormatS24NE* = SoundIoFormat.S24BE
    SoundIoFormatU24NE* = SoundIoFormat.U24BE
    SoundIoFormatS32NE* = SoundIoFormat.S32BE
    SoundIoFormatU32NE* = SoundIoFormat.U32BE
    SoundIoFormatFloat32NE* = SoundIoFormat.Float32BE
    SoundIoFormatFloat64NE* = SoundIoFormat.Float64BE
    SoundIoFormatS16FE* = SoundIo.FormatS16LE
    SoundIoFormatU16FE* = SoundIo.FormatU16LE
    SoundIoFormatS24FE* = SoundIo.FormatS24LE
    SoundIoFormatU24FE* = SoundIo.FormatU24LE
    SoundIoFormatS32FE* = SoundIo.FormatS32LE
    SoundIoFormatU32FE* = SoundIo.FormatU32LE
    SoundIoFormatFloat32FE* = SoundIoFormat.Float32LE
    SoundIoFormatFloat64FE* = SoundIoFormat.Float64LE
else:
  const
    SoundIoFormatS16NE* = SoundIoFormat.S16LE
    SoundIoFormatU16NE* = SoundIoFormat.U16LE
    SoundIoFormatS24NE* = SoundIoFormat.S24LE
    SoundIoFormatU24NE* = SoundIoFormat.U24LE
    SoundIoFormatS32NE* = SoundIoFormat.S32LE
    SoundIoFormatU32NE* = SoundIoFormat.U32LE
    SoundIoFormatFloat32NE* = SoundIoFormat.Float32LE
    SoundIoFormatFloat64NE* = SoundIoFormat.Float64LE
    SoundIoFormatS16FE* = SoundIoFormat.S16BE
    SoundIoFormatU16FE* = SoundIoFormat.U16BE
    SoundIoFormatS24FE* = SoundIoFormat.S24BE
    SoundIoFormatU24FE* = SoundIoFormat.U24BE
    SoundIoFormatS32FE* = SoundIoFormat.S32BE
    SoundIoFormatU32FE* = SoundIoFormat.U32BE
    SoundIoFormatFloat32FE* = SoundIoFormat.Float32BE
    SoundIoFormatFloat64FE* = SoundIoFormat.Float64BE

const SOUNDIO_MAX_CHANNELS* = 24

type
  SoundIoChannelLayout* {.pure, final.} = object
    ## The size of this struct is OK to use.
    name*: cstring
    channel_count*: cint
    channels*: array[SOUNDIO_MAX_CHANNELS, SoundIoChannelId]

type
  SoundIoSampleRateRange* {.pure, final.} = object
    ## The size of this struct is OK to use.
    min*: cint
    max*: cint

type
  SoundIoChannelArea* {.pure, final.} = object
    ## The size of this struct is OK to use.
    #`ptr`*: cstring            ## Base address of buffer.
    pointer*: pointer            ## Base address of buffer.
    ## How many bytes it takes to get from the beginning of one sample to
    ## the beginning of the next sample.
    step*: cint

type
  SoundIo* {.pure, final.} = object
    ## The size of this struct is not part of the API or ABI.
    userdata*: pointer ## Optional. Put whatever you want here. Defaults to NULL.
    ## Optional callback. Called when the list of devices change. Only called
    ## during a call to ::soundio_flush_events or ::soundio_wait_events.
    on_devices_change*: proc (a2: ptr SoundIo) {.cdecl.}
    ## Optional callback. Called when the backend disconnects. For example,
    ## when the JACK server shuts down. When this happens, listing devices
    ## and opening streams will always fail with
    ## SoundIoErrorBackendDisconnected. This callback is only called during a
    ## call to ::soundio_flush_events or ::soundio_wait_events.
    ## If you do not supply a callback, the default will crash your program
    ## with an error message. This callback is also called when the thread
    ## that retrieves device information runs into an unrecoverable condition
    ## such as running out of memory.
    ##
    ## Possible errors:
    ## * #SoundIoErrorBackendDisconnected
    ## * #SoundIoErrorNoMem
    ## * #SoundIoErrorSystemResources
    ## * #SoundIoErrorOpeningDevice - unexpected problem accessing device
    ##   information
    on_backend_disconnect*: proc (a2: ptr SoundIo; err: cint) {.cdecl.}
    ## Optional callback. Called from an unknown thread that you should not use
    ## to call any soundio functions. You may use this to signal a condition
    ## variable to wake up. Called when ::soundio_wait_events would be woken up.
    on_events_signal*: proc (a2: ptr SoundIo) {.cdecl.}
    ## Read-only. After calling ::soundio_connect or ::soundio_connect_backend,
    ## this field tells which backend is currently connected.
    current_backend*: SoundIoBackend
    ## Optional: Application name.
    ## PulseAudio uses this for "application name".
    ## JACK uses this for `client_name`.
    ## Must not contain a colon (":").
    app_name*: cstring
    ## Optional: Real time priority warning.
    ## This callback is fired when making thread real-time priority failed. By
    ## default, it will print to stderr only the first time it is called
    ## a message instructing the user how to configure their system to allow
    ## real-time priority threads. This must be set to a function not NULL.
    ## To silence the warning, assign this to a function that does nothing.
    emit_rtprio_warning*: proc () {.cdecl.}
    ## Optional: JACK info callback.
    ## By default, libsoundio sets this to an empty function in order to
    ## silence stdio messages from JACK. You may override the behavior by
    ## setting this to `NULL` or providing your own function. This is
    ## registered with JACK regardless of whether ::soundio_connect_backend
    ## succeeds.
    jack_info_callback*: proc (msg: cstring) {.cdecl.}
    ## Optional: JACK error callback.
    ## See SoundIo::jack_info_callback
    jack_error_callback*: proc (msg: cstring) {.cdecl.}

type
  SoundIoDevice* {.pure, final.} = object
    ## The size of this struct is not part of the API or ABI.
    soundio*: ptr SoundIo
    ## Read-only. Set automatically.
    ## A string of bytes that uniquely identifies this device.
    ## If the same physical device supports both input and output, that makes
    ## one SoundIoDevice for the input and one SoundIoDevice for the output.
    ## In this case, the id of each SoundIoDevice will be the same, and
    ## SoundIoDevice::aim will be different. Additionally, if the device
    ## supports raw mode, there may be up to four devices with the same id:
    ## one for each value of SoundIoDevice::is_raw and one for each value of
    ## SoundIoDevice::aim.
    id*: cstring
    ## User-friendly UTF-8 encoded text to describe the device.
    name*: cstring
    ## Tells whether this device is an input device or an output device.
    aim*: SoundIoDeviceAim
    ## Channel layouts are handled similarly to SoundIoDevice::formats.
    ## If this information is missing due to a SoundIoDevice::probe_error,
    ## layouts will be NULL. It's OK to modify this data, for example calling
    ## ::soundio_sort_channel_layouts on it.
    ## Devices are guaranteed to have at least 1 channel layout.
    layouts*: ptr SoundIoChannelLayout
    layout_count*: cint
    ## See SoundIoDevice::current_format
    current_layout*: SoundIoChannelLayout
    ## List of formats this device supports. See also
    ## SoundIoDevice::current_format.
    formats*: ptr SoundIoFormat
    ## How many formats are available in SoundIoDevice::formats.
    format_count*: cint
    ## A device is either a raw device or it is a virtual device that is
    ## provided by a software mixing service such as dmix or PulseAudio (see
    ## SoundIoDevice::is_raw). If it is a raw device,
    ## current_format is meaningless;
    ## the device has no current format until you open it. On the other hand,
    ## if it is a virtual device, current_format describes the
    ## destination sample format that your audio will be converted to. Or,
    ## if you're the lucky first application to open the device, you might
    ## cause the current_format to change to your format.
    ## Generally, you want to ignore current_format and use
    ## whatever format is most convenient
    ## for you which is supported by the device, because when you are the only
    ## application left, the mixer might decide to switch
    ## current_format to yours. You can learn the supported formats via
    ## formats and SoundIoDevice::format_count. If this information is missing
    ## due to a probe error, formats will be `NULL`. If current_format is
    ## unavailable, it will be set to #SoundIoFormatInvalid.
    ## Devices are guaranteed to have at least 1 format available.
    current_format*: SoundIoFormat
    ## Sample rate is the number of frames per second.
    ## Sample rate is handled very similar to SoundIoDevice::formats.
    ## If sample rate information is missing due to a probe error, the field
    ## will be set to NULL.
    ## Devices which have SoundIoDevice::probe_error set to #SoundIoErrorNone are
    ## guaranteed to have at least 1 sample rate available.
    sample_rates*: ptr SoundIoSampleRateRange
    ## How many sample rate ranges are available in
    ## SoundIoDevice::sample_rates. 0 if sample rate information is missing
    ## due to a probe error.
    sample_rate_count*: cint
    ## See SoundIoDevice::current_format
    ## 0 if sample rate information is missing due to a probe error.
    sample_rate_current*: cint
    ## Software latency minimum in seconds. If this value is unknown or
    ## irrelevant, it is set to 0.0.
    ## For PulseAudio and WASAPI this value is unknown until you open a
    ## stream.
    software_latency_min*: cdouble
    ## Software latency maximum in seconds. If this value is unknown or
    ## irrelevant, it is set to 0.0.
    ## For PulseAudio and WASAPI this value is unknown until you open a
    ## stream.
    software_latency_max*: cdouble
    ## Software latency in seconds. If this value is unknown or
    ## irrelevant, it is set to 0.0.
    ## For PulseAudio and WASAPI this value is unknown until you open a
    ## stream.
    ## See SoundIoDevice::current_format
    software_latency_current*: cdouble
    ## Raw means that you are directly opening the hardware device and not
    ## going through a proxy such as dmix, PulseAudio, or JACK. When you open a
    ## raw device, other applications on the computer are not able to
    ## simultaneously access the device. Raw devices do not perform automatic
    ## resampling and thus tend to have fewer formats available.
    is_raw*: bool
    ## Devices are reference counted. See ::soundio_device_ref and
    ## ::soundio_device_unref.
    ref_count*: cint
    ## This is set to a SoundIoError representing the result of the device
    ## probe. Ideally this will be SoundIoErrorNone in which case all the
    ## fields of the device will be populated. If there is an error code here
    ## then information about formats, sample rates, and channel layouts might
    ## be missing.
    ##
    ## Possible errors:
    ## * #SoundIoErrorOpeningDevice
    ## * #SoundIoErrorNoMem
    probe_error*: cint

type
  SoundIoOutStream* {.pure, final.} = object
    ## The size of this struct is not part of the API or ABI.
    device*: ptr SoundIoDevice
    ## Populated automatically when you call ::soundio_outstream_create.
    ## Defaults to #SoundIoFormatFloat32NE, followed by the first one
    ## supported.
    format*: SoundIoFormat
    ## Sample rate is the number of frames per second.
    ## Defaults to 48000 (and then clamped into range).
    sample_rate*: cint
    ## Defaults to Stereo, if available, followed by the first layout
    ## supported.
    layout*: SoundIoChannelLayout
    ## Ignoring hardware latency, this is the number of seconds it takes for
    ## the last sample in a full buffer to be played.
    ## After you call ::soundio_outstream_open, this value is replaced with the
    ## actual software latency, as near to this value as possible.
    ## On systems that support clearing the buffer, this defaults to a large
    ## latency, potentially upwards of 2 seconds, with the understanding that
    ## you will call ::soundio_outstream_clear_buffer when you want to reduce
    ## the latency to 0. On systems that do not support clearing the buffer,
    ## this defaults to a reasonable lower latency value.
    ##
    ## On backends with high latencies (such as 2 seconds), `frame_count_min`
    ## will be 0, meaning you don't have to fill the entire buffer. In this
    ## case, the large buffer is there if you want it; you only have to fill
    ## as much as you want. On backends like JACK, `frame_count_min` will be
    ## equal to `frame_count_max` and if you don't fill that many frames, you
    ## will get glitches.
    ##
    ## If the device has unknown software latency min and max values, you may
    ## still set this, but you might not get the value you requested.
    ## For PulseAudio, if you set this value to non-default, it sets
    ## `PA_STREAM_ADJUST_LATENCY` and is the value used for `maxlength` and
    ## `tlength`.
    ##
    ## For JACK, this value is always equal to
    ## SoundIoDevice::software_latency_current of the device.
    software_latency*: cdouble
    ## Core Audio and WASAPI only: current output Audio Unit volume. Float, 0.0-1.0.
    volume*: cfloat
    ## Defaults to NULL. Put whatever you want here.
    userdata*: pointer
    ## In this callback, you call ::soundio_outstream_begin_write and
    ## ::soundio_outstream_end_write as many times as necessary to write
    ## at minimum `frame_count_min` frames and at maximum `frame_count_max`
    ## frames. `frame_count_max` will always be greater than 0. Note that you
    ## should write as many frames as you can; `frame_count_min` might be 0 and
    ## you can still get a buffer underflow if you always write
    ## `frame_count_min` frames.
    ##
    ## For Dummy, ALSA, and PulseAudio, `frame_count_min` will be 0. For JACK
    ## and CoreAudio `frame_count_min` will be equal to `frame_count_max`.
    ##
    ## The code in the supplied function must be suitable for real-time
    ## execution. That means that it cannot call functions that might block
    ## for a long time. This includes all I/O functions (disk, TTY, network),
    ## malloc, free, printf, pthread_mutex_lock, sleep, wait, poll, select,
    ## pthread_join, pthread_cond_wait, etc.
    write_callback*: proc (a2: ptr SoundIoOutStream; frame_count_min: cint;
                         frame_count_max: cint) {.cdecl.}
    ## This optional callback happens when the sound device runs out of
    ## buffered audio data to play. After this occurs, the outstream waits
    ## until the buffer is full to resume playback.
    ## This is called from the SoundIoOutStream::write_callback thread context.
    underflow_callback*: proc (a2: ptr SoundIoOutStream) {.cdecl.}
    ## Optional callback. `err` is always SoundIoErrorStreaming.
    ## SoundIoErrorStreaming is an unrecoverable error. The stream is in an
    ## invalid state and must be destroyed.
    ## If you do not supply error_callback, the default callback will print
    ## a message to stderr and then call `abort`.
    ## This is called from the SoundIoOutStream::write_callback thread context.
    error_callback*: proc (a2: ptr SoundIoOutStream; err: cint) {.cdecl.}
    ## Optional: Name of the stream. Defaults to "SoundIoOutStream"
    ## PulseAudio uses this for the stream name.
    ## JACK uses this for the client name of the client that connects when you
    ## open the stream.
    ## WASAPI uses this for the session display name.
    ## Must not contain a colon (":").
    name*: cstring
    ## Optional: Hint that this output stream is nonterminal. This is used by
    ## JACK and it means that the output stream data originates from an input
    ## stream. Defaults to `false`.
    non_terminal_hint*: bool
    ## computed automatically when you call ::soundio_outstream_open
    bytes_per_frame*: cint
    ## computed automatically when you call ::soundio_outstream_open
    bytes_per_sample*: cint
    ## If setting the channel layout fails for some reason, this field is set
    ## to an error code. Possible error codes are:
    ## * #SoundIoErrorIncompatibleDevice
    layout_error*: cint

type
  SoundIoInStream* {.pure, final.} = object
    ## The size of this struct is not part of the API or ABI.
    device*: ptr SoundIoDevice
    ## Populated automatically when you call ::soundio_outstream_create.
    ## Defaults to #SoundIoFormatFloat32NE, followed by the first one
    ## supported.
    format*: SoundIoFormat
    ## Sample rate is the number of frames per second.
    ## Defaults to max(sample_rate_min, min(sample_rate_max, 48000))
    sample_rate*: cint
    ## Defaults to Stereo, if available, followed by the first layout
    ## supported.
    layout*: SoundIoChannelLayout
    ## Ignoring hardware latency, this is the number of seconds it takes for a
    ## captured sample to become available for reading.
    ## After you call ::soundio_instream_open, this value is replaced with the
    ## actual software latency, as near to this value as possible.
    ## A higher value means less CPU usage. Defaults to a large value,
    ## potentially upwards of 2 seconds.
    ## If the device has unknown software latency min and max values, you may
    ## still set this, but you might not get the value you requested.
    ## For PulseAudio, if you set this value to non-default, it sets
    ## `PA_STREAM_ADJUST_LATENCY` and is the value used for `fragsize`.
    ## For JACK, this value is always equal to
    ## SoundIoDevice::software_latency_current
    software_latency*: cdouble
    ## Defaults to NULL. Put whatever you want here.
    userdata*: pointer
    ## In this function call ::soundio_instream_begin_read and
    ## ::soundio_instream_end_read as many times as necessary to read at
    ## minimum `frame_count_min` frames and at maximum `frame_count_max`
    ## frames. If you return from read_callback without having read
    ## `frame_count_min`, the frames will be dropped. `frame_count_max` is how
    ## many frames are available to read.
    ##
    ## The code in the supplied function must be suitable for real-time
    ## execution. That means that it cannot call functions that might block
    ## for a long time. This includes all I/O functions (disk, TTY, network),
    ## malloc, free, printf, pthread_mutex_lock, sleep, wait, poll, select,
    ## pthread_join, pthread_cond_wait, etc.
    read_callback*: proc (a2: ptr SoundIoInStream; frame_count_min: cint;
                        frame_count_max: cint) {.cdecl.}
    ## This optional callback happens when the sound device buffer is full,
    ## yet there is more captured audio to put in it.
    ## This is never fired for PulseAudio.
    ## This is called from the SoundIoInStream::read_callback thread context.
    overflow_callback*: proc (a2: ptr SoundIoInStream) {.cdecl.}
    ## Optional callback. `err` is always SoundIoErrorStreaming.
    ## SoundIoErrorStreaming is an unrecoverable error. The stream is in an
    ## invalid state and must be destroyed.
    ## If you do not supply `error_callback`, the default callback will print
    ## a message to stderr and then abort().
    ## This is called from the SoundIoInStream::read_callback thread context.
    error_callback*: proc (a2: ptr SoundIoInStream; err: cint) {.cdecl.}
    ## Optional: Name of the stream. Defaults to "SoundIoInStream";
    ## PulseAudio uses this for the stream name.
    ## JACK uses this for the client name of the client that connects when you
    ## open the stream.
    ## WASAPI uses this for the session display name.
    ## Must not contain a colon (":").
    name*: cstring
    ## Optional: Hint that this input stream is nonterminal. This is used by
    ## JACK and it means that the data received by the stream will be
    ## passed on or made available to another stream. Defaults to `false`.
    non_terminal_hint*: bool
    ## computed automatically when you call ::soundio_instream_open
    bytes_per_frame*: cint
    ## computed automatically when you call ::soundio_instream_open
    bytes_per_sample*: cint
    ## If setting the channel layout fails for some reason, this field is set
    ## to an error code. Possible error codes are: #SoundIoErrorIncompatibleDevice
    layout_error*: cint

proc version_string*(): cstring {.sio.}
  ## See also ::soundio_version_major, ::soundio_version_minor, ::soundio_version_patch

proc version_major*(): cint {.sio.}
  ## See also ::soundio_version_string, ::soundio_version_minor, ::soundio_version_patch

proc version_minor*(): cint {.sio.}
  ## See also ::soundio_version_major, ::soundio_version_string, ::soundio_version_patch

proc version_patch*(): cint {.sio.}
  ## See also ::soundio_version_major, ::soundio_version_minor, ::soundio_version_string

proc soundio_create*(): ptr SoundIo {.sio, importc: "$1".}
  ## Create a SoundIo context. You may create multiple instances of this to
  ## connect to multiple backends. Sets all fields to defaults.
  ## Returns `NULL` if and only if memory could not be allocated.
  ## See also ::soundio_destroy

proc destroy*(soundio: ptr SoundIo) {.sio.}

proc connect*(soundio: ptr SoundIo): cint {.sio.}
  ## Tries ::soundio_connect_backend on all available backends in order.
  ## Possible errors:
  ## * #SoundIoErrorInvalid - already connected
  ## * #SoundIoErrorNoMem
  ## * #SoundIoErrorSystemResources
  ## * #SoundIoErrorNoSuchClient - when JACK returns `JackNoSuchClient`
  ## See also ::soundio_disconnect

proc connect*(soundio: ptr SoundIo; backend: SoundIoBackend):
  cint {.sio, importc: "soundio_connect_backend".}
  ## Instead of calling ::soundio_connect you may call this function to try a
  ## specific backend.
  ## Possible errors:
  ## * #SoundIoErrorInvalid - already connected or invalid backend parameter
  ## * #SoundIoErrorNoMem
  ## * #SoundIoErrorBackendUnavailable - backend was not compiled in
  ## * #SoundIoErrorSystemResources
  ## * #SoundIoErrorNoSuchClient - when JACK returns `JackNoSuchClient`
  ## * #SoundIoErrorInitAudioBackend - requested `backend` is not active
  ## * #SoundIoErrorBackendDisconnected - backend disconnected while connecting
  ## See also ::soundio_disconnect

proc disconnect*(soundio: ptr SoundIo) {.sio.}

proc strerror*(error: cint): cstring {.sio.}
  ## Get a string representation of a #SoundIoError

proc name*(backend: SoundIoBackend): cstring {.sio, importc: "soundio_backend_$1".}
  ## Get a string representation of a #SoundIoBackend

proc backend_count*(soundio: ptr SoundIo): cint {.sio.}
  ## Returns the number of available backends.

proc get_backend*(soundio: ptr SoundIo; index: cint): SoundIoBackend {.sio.}
  ## get the available backend at the specified index
  ## (0 <= index < ::soundio_backend_count)

proc have_backend*(backend: SoundIoBackend): bool {.sio.}
  ## Returns whether libsoundio was compiled with backend.

proc flush_events*(soundio: ptr SoundIo) {.sio.}
  ## Atomically update information for all connected devices. Note that calling
  ## this function merely flips a pointer; the actual work of collecting device
  ## information is done elsewhere. It is performant to call this function many
  ## times per second.
  ##
  ## When you call this, the following callbacks might be called:
  ## * SoundIo::on_devices_change
  ## * SoundIo::on_backend_disconnect
  ## This is the only time those callbacks can be called.
  ##
  ## This must be called from the same thread as the thread in which you call
  ## these functions:
  ## * ::soundio_input_device_count
  ## * ::soundio_output_device_count
  ## * ::soundio_get_input_device
  ## * ::soundio_get_output_device
  ## * ::soundio_default_input_device_index
  ## * ::soundio_default_output_device_index
  ##
  ## Note that if you do not care about learning about updated devices, you
  ## might call this function only once ever and never call
  ## ::soundio_wait_events.

proc wait_events*(soundio: ptr SoundIo) {.sio.}
  ## This function calls ::soundio_flush_events then blocks until another event
  ## is ready or you call ::soundio_wakeup. Be ready for spurious wakeups.

proc wakeup*(soundio: ptr SoundIo) {.sio.}
  ## Makes ::soundio_wait_events stop blocking.

proc force_device_scan*(soundio: ptr SoundIo) {.sio.}
  ## If necessary you can manually trigger a device rescan. Normally you will
  ## not ever have to call this function, as libsoundio listens to system events
  ## for device changes and responds to them by rescanning devices and preparing
  ## the new device information for you to be atomically replaced when you call
  ## ::soundio_flush_events. However you might run into cases where you want to
  ## force trigger a device rescan, for example if an ALSA device has a
  ## SoundIoDevice::probe_error.
  ##
  ## After you call this you still have to use ::soundio_flush_events or
  ## ::soundio_wait_events and then wait for the
  ## SoundIo::on_devices_change callback.
  ##
  ## This can be called from any thread context except for
  ## SoundIoOutStream::write_callback and SoundIoInStream::read_callback

proc equal*(a: ptr SoundIoChannelLayout;
            b: ptr SoundIoChannelLayout): bool {.siochan.}
  ## Channel Layouts
  ## Returns whether the channel count field and each channel id matches in
  ## the supplied channel layouts.

proc get_channel_name*(id: SoundIoChannelId): cstring {.sio.}

proc parse_channel_id*(str: cstring; str_len: cint): SoundIoChannelId {.sio.}
  ## Given UTF-8 encoded text which is the name of a channel such as
  ## "Front Left", "FL", or "front-left", return the corresponding
  ## SoundIoChannelId. Returns SoundIoChannelIdInvalid for no match.

proc builtin_count*(): cint {.siochan.}
  ## Returns the number of builtin channel layouts.

proc get_builtin*(index: cint): ptr SoundIoChannelLayout {.siochan.}
  ## Returns a builtin channel layout. 0 <= `index` < ::soundio_channel_layout_builtin_count
  ##
  ## Although `index` is of type `int`, it should be a valid
  ## #SoundIoChannelLayoutId enum value.

proc get_default*(channel_count: cint): ptr SoundIoChannelLayout {.siochan.}
  ## Get the default builtin channel layout for the given number of channels.

proc find_channel*(layout: ptr SoundIoChannelLayout;
                   channel: SoundIoChannelId): cint {.siochan.}
  ## Return the index of `channel` in `layout`, or `-1` if not found.

proc detect_builtin*(layout: ptr SoundIoChannelLayout): bool {.siochan.}
  ## Populates the name field of layout if it matches a builtin one.
  ## returns whether it found a match

proc best_matching_channel_layout*(
  preferred_layouts: ptr SoundIoChannelLayout; preferred_layout_count: cint;
  available_layouts: ptr SoundIoChannelLayout; available_layout_count: cint):
  ptr SoundIoChannelLayout {.sio.}
  ## Iterates over preferred_layouts. Returns the first channel layout in
  ## preferred_layouts which matches one of the channel layouts in
  ## available_layouts. Returns NULL if none matches.

proc sort_channel_layouts*(layouts: ptr SoundIoChannelLayout;
                           layout_count: cint) {.sio.}
  ## Sorts by channel count, descending.

proc get_bytes_per_sample*(format: SoundIoFormat): cint {.sio.}
  ## Sample Formats
  ## Returns -1 on invalid format.

proc get_bytes_per_frame*(format: SoundIoFormat; channel_count: cint):
  cint {.inline.} =
  ## A frame is one sample per channel.
  return get_bytes_per_sample(format) * channel_count

proc get_bytes_per_second*(format: SoundIoFormat; channel_count: cint;
                           sample_rate: cint): cint {.inline.} =
  ## Sample rate is the number of frames per second.
  return get_bytes_per_frame(format, channel_count) * sample_rate

proc format_string*(format: SoundIoFormat): cstring {.sio.}
  ## Returns string representation of `format`.

proc input_device_count*(soundio: ptr SoundIo): cint {.sio.}
  ## Devices
  ## When you call ::soundio_flush_events, a snapshot of all device state is
  ## saved and these functions merely access the snapshot data. When you want
  ## to check for new devices, call ::soundio_flush_events. Or you can call
  ## ::soundio_wait_events to block until devices change. If an error occurs
  ## scanning devices in a background thread, SoundIo::on_backend_disconnect is called
  ## with the error code.
  ## Get the number of input devices.
  ## Returns -1 if you never called ::soundio_flush_events.

proc output_device_count*(soundio: ptr SoundIo): cint {.sio.}
  ## Get the number of output devices.
  ## Returns -1 if you never called ::soundio_flush_events.

proc get_input_device*(soundio: ptr SoundIo; index: cint): ptr SoundIoDevice {.sio.}
  ## Always returns a device. Call ::soundio_device_unref when done.
  ## `index` must be 0 <= index < ::soundio_input_device_count
  ## Returns NULL if you never called ::soundio_flush_events or if you provide
  ## invalid parameter values.

proc get_output_device*(soundio: ptr SoundIo; index: cint): ptr SoundIoDevice {.sio.}
  ## Always returns a device. Call ::soundio_device_unref when done.
  ## `index` must be 0 <= index < ::soundio_output_device_count
  ## Returns NULL if you never called ::soundio_flush_events or if you provide
  ## invalid parameter values.

proc default_input_device_index*(soundio: ptr SoundIo): cint {.sio.}
  ## returns the index of the default input device
  ## returns -1 if there are no devices or if you never called
  ## ::soundio_flush_events.

proc default_output_device_index*(soundio: ptr SoundIo): cint {.sio.}
  ## returns the index of the default output device
  ## returns -1 if there are no devices or if you never called
  ## ::soundio_flush_events.

proc `ref`*(device: ptr SoundIoDevice) {.siodev.}
  ## Add 1 to the reference count of `device`.

proc unref*(device: ptr SoundIoDevice) {.siodev.}
  ## Remove 1 to the reference count of `device`. Clean up if it was the last
  ## reference.

proc equal*(a: ptr SoundIoDevice; b: ptr SoundIoDevice): bool {.siodev.}
  ## Return `true` if and only if the devices have the same SoundIoDevice::id,
  ## SoundIoDevice::is_raw, and SoundIoDevice::aim are the same.

proc sort_channel_layouts*(device: ptr SoundIoDevice) {.siodev.}
  ## Sorts channel layouts by channel count, descending.

proc supports_format*(device: ptr SoundIoDevice;
                      format: SoundIoFormat): bool {.siodev.}
  ## Convenience function. Returns whether `format` is included in the device's
  ## supported formats.

proc supports_layout*(device: ptr SoundIoDevice;
                      layout: ptr SoundIoChannelLayout): bool {.siodev.}
  ## Convenience function. Returns whether `layout` is included in the device's
  ## supported channel layouts.

proc supports_sample_rate*(device: ptr SoundIoDevice;
                           sample_rate: cint): bool {.siodev.}
  ## Convenience function. Returns whether `sample_rate` is included in the
  ## device's supported sample rates.

proc nearest_sample_rate*(device: ptr SoundIoDevice;
                          sample_rate: cint): cint {.siodev.}
  ## Convenience function. Returns the available sample rate nearest to
  ## `sample_rate`, rounding up.

proc outstream_create*(device: ptr SoundIoDevice): ptr SoundIoOutStream {.sio.}
  ## Output Streams
  ## Allocates memory and sets defaults. Next you should fill out the struct fields
  ## and then call ::soundio_outstream_open. Sets all fields to defaults.
  ## Returns `NULL` if and only if memory could not be allocated.
  ## See also ::soundio_outstream_destroy

proc destroy*(outstream: ptr SoundIoOutStream) {.sioout.}
  ## You may not call this function from the SoundIoOutStream::write_callback thread context.

proc open*(outstream: ptr SoundIoOutStream): cint {.sioout.}
  ## After you call this function, SoundIoOutStream::software_latency is set to
  ## the correct value.
  ##
  ## The next thing to do is call ::soundio_outstream_start.
  ## If this function returns an error, the outstream is in an invalid state and
  ## you must call ::soundio_outstream_destroy on it.
  ##
  ## Possible errors:
  ## * #SoundIoErrorInvalid
  ##   * SoundIoDevice::aim is not #SoundIoDeviceAimOutput
  ##   * SoundIoOutStream::format is not valid
  ##   * SoundIoOutStream::channel_count is greater than #SOUNDIO_MAX_CHANNELS
  ## * #SoundIoErrorNoMem
  ## * #SoundIoErrorOpeningDevice
  ## * #SoundIoErrorBackendDisconnected
  ## * #SoundIoErrorSystemResources
  ## * #SoundIoErrorNoSuchClient - when JACK returns `JackNoSuchClient`
  ## * #SoundIoErrorOpeningDevice
  ## * #SoundIoErrorIncompatibleBackend - SoundIoOutStream::channel_count is
  ##   greater than the number of channels the backend can handle.
  ## * #SoundIoErrorIncompatibleDevice - stream parameters requested are not
  ##   compatible with the chosen device.

proc start*(outstream: ptr SoundIoOutStream): cint {.sioout.}
  ## After you call this function, SoundIoOutStream::write_callback will be called.
  ##
  ## This function might directly call SoundIoOutStream::write_callback.
  ##
  ## Possible errors:
  ## * #SoundIoErrorStreaming
  ## * #SoundIoErrorNoMem
  ## * #SoundIoErrorSystemResources
  ## * #SoundIoErrorBackendDisconnected

proc begin_write*(outstream: ptr SoundIoOutStream;
                  areas: ptr ptr SoundIoChannelArea;
                  frame_count: ptr cint): cint {.sioout.}
  ## Call this function when you are ready to begin writing to the device buffer.
  ##  * `outstream` - (in) The output stream you want to write to.
  ##  * `areas` - (out) The memory addresses you can write data to, one per
  ##    channel. It is OK to modify the pointers if that helps you iterate.
  ##  * `frame_count` - (in/out) Provide the number of frames you want to write.
  ##    Returned will be the number of frames you can actually write, which is
  ##    also the number of frames that will be written when you call
  ##    ::soundio_outstream_end_write. The value returned will always be less
  ##    than or equal to the value provided.
  ## It is your responsibility to call this function exactly as many times as
  ## necessary to meet the `frame_count_min` and `frame_count_max` criteria from
  ## SoundIoOutStream::write_callback.
  ## You must call this function only from the SoundIoOutStream::write_callback thread context.
  ## After calling this function, write data to `areas` and then call
  ## ::soundio_outstream_end_write.
  ## If this function returns an error, do not call ::soundio_outstream_end_write.
  ##
  ## Possible errors:
  ## * #SoundIoErrorInvalid
  ##   * `*frame_count` <= 0
  ##   * `*frame_count` < `frame_count_min` or `*frame_count` > `frame_count_max`
  ##   * function called too many times without respecting `frame_count_max`
  ## * #SoundIoErrorStreaming
  ## * #SoundIoErrorUnderflow - an underflow caused this call to fail. You might
  ##   also get a SoundIoOutStream::underflow_callback, and you might not get
  ##   this error code when an underflow occurs. Unlike #SoundIoErrorStreaming,
  ##   the outstream is still in a valid state and streaming can continue.
  ## * #SoundIoErrorIncompatibleDevice - in rare cases it might just now
  ##   be discovered that the device uses non-byte-aligned access, in which
  ##   case this error code is returned.

proc end_write*(outstream: ptr SoundIoOutStream): cint {.sioout.}
  ## Commits the write that you began with ::soundio_outstream_begin_write.
  ## You must call this function only from the SoundIoOutStream::write_callback thread context.
  ##
  ## Possible errors:
  ## * #SoundIoErrorStreaming
  ## * #SoundIoErrorUnderflow - an underflow caused this call to fail. You might
  ##   also get a SoundIoOutStream::underflow_callback, and you might not get
  ##   this error code when an underflow occurs. Unlike #SoundIoErrorStreaming,
  ##   the outstream is still in a valid state and streaming can continue.

proc clear_buffer*(outstream: ptr SoundIoOutStream): cint {.sioout.}
  ## Clears the output stream buffer.
  ## This function can be called from any thread.
  ## This function can be called regardless of whether the outstream is paused
  ## or not.
  ## Some backends do not support clearing the buffer. On these backends this
  ## function will return SoundIoErrorIncompatibleBackend.
  ## Some devices do not support clearing the buffer. On these devices this
  ## function might return SoundIoErrorIncompatibleDevice.
  ## Possible errors:
  ##
  ## * #SoundIoErrorStreaming
  ## * #SoundIoErrorIncompatibleBackend
  ## * #SoundIoErrorIncompatibleDevice

proc pause*(outstream: ptr SoundIoOutStream; pause: bool): cint {.sioout.}
  ## If the underlying backend and device support pausing, this pauses the
  ## stream. SoundIoOutStream::write_callback may be called a few more times if
  ## the buffer is not full.
  ## Pausing might put the hardware into a low power state which is ideal if your
  ## software is silent for some time.
  ## This function may be called from any thread context, including
  ## SoundIoOutStream::write_callback.
  ## Pausing when already paused or unpausing when already unpaused has no
  ## effect and returns #SoundIoErrorNone.
  ##
  ## Possible errors:
  ## * #SoundIoErrorBackendDisconnected
  ## * #SoundIoErrorStreaming
  ## * #SoundIoErrorIncompatibleDevice - device does not support
  ##   pausing/unpausing. This error code might not be returned even if the
  ##   device does not support pausing/unpausing.
  ## * #SoundIoErrorIncompatibleBackend - backend does not support
  ##   pausing/unpausing.
  ## * #SoundIoErrorInvalid - outstream not opened and started

proc get_latency*(outstream: ptr SoundIoOutStream;
                  out_latency: ptr cdouble): cint {.sioout.}
  ## Obtain the total number of seconds that the next frame written after the
  ## last frame written with ::soundio_outstream_end_write will take to become
  ## audible. This includes both software and hardware latency. In other words,
  ## if you call this function directly after calling ::soundio_outstream_end_write,
  ## this gives you the number of seconds that the next frame written will take
  ## to become audible.
  ##
  ## This function must be called only from within SoundIoOutStream::write_callback.
  ##
  ## Possible errors:
  ## * #SoundIoErrorStreaming

proc instream_create*(device: ptr SoundIoDevice): ptr SoundIoInStream {.sio.}
  ## Input Streams
  ## Allocates memory and sets defaults. Next you should fill out the struct fields
  ## and then call ::soundio_instream_open. Sets all fields to defaults.
  ## Returns `NULL` if and only if memory could not be allocated.
  ## See also ::soundio_instream_destroy

proc destroy*(instream: ptr SoundIoInStream) {.sioin.}
  ## You may not call this function from SoundIoInStream::read_callback.

proc open*(instream: ptr SoundIoInStream): cint {.sioin.}
  ## After you call this function, SoundIoInStream::software_latency is set to the correct
  ## value.
  ## The next thing to do is call ::soundio_instream_start.
  ## If this function returns an error, the instream is in an invalid state and
  ## you must call ::soundio_instream_destroy on it.
  ##
  ## Possible errors:
  ## * #SoundIoErrorInvalid
  ##   * device aim is not #SoundIoDeviceAimInput
  ##   * format is not valid
  ##   * requested layout channel count > #SOUNDIO_MAX_CHANNELS
  ## * #SoundIoErrorOpeningDevice
  ## * #SoundIoErrorNoMem
  ## * #SoundIoErrorBackendDisconnected
  ## * #SoundIoErrorSystemResources
  ## * #SoundIoErrorNoSuchClient
  ## * #SoundIoErrorIncompatibleBackend
  ## * #SoundIoErrorIncompatibleDevice

proc start*(instream: ptr SoundIoInStream): cint {.sioin.}
  ## After you call this function, SoundIoInStream::read_callback will be called.
  ##
  ## Possible errors:
  ## * #SoundIoErrorBackendDisconnected
  ## * #SoundIoErrorStreaming
  ## * #SoundIoErrorOpeningDevice
  ## * #SoundIoErrorSystemResources

proc begin_read*(instream: ptr SoundIoInStream;
                 areas: ptr ptr SoundIoChannelArea;
                 frame_count: ptr cint): cint {.sioin.}
  ## Call this function when you are ready to begin reading from the device
  ## buffer.
  ## * `instream` - (in) The input stream you want to read from.
  ## * `areas` - (out) The memory addresses you can read data from. It is OK
  ##   to modify the pointers if that helps you iterate. There might be a "hole"
  ##   in the buffer. To indicate this, `areas` will be `NULL` and `frame_count`
  ##   tells how big the hole is in frames.
  ## * `frame_count` - (in/out) - Provide the number of frames you want to read;
  ##   returns the number of frames you can actually read. The returned value
  ##   will always be less than or equal to the provided value. If the provided
  ##   value is less than `frame_count_min` from SoundIoInStream::read_callback this function
  ##   returns with #SoundIoErrorInvalid.
  ## It is your responsibility to call this function no more and no fewer than the
  ## correct number of times according to the `frame_count_min` and
  ## `frame_count_max` criteria from SoundIoInStream::read_callback.
  ## You must call this function only from the SoundIoInStream::read_callback thread context.
  ## After calling this function, read data from `areas` and then use
  ## ::soundio_instream_end_read` to actually remove the data from the buffer
  ## and move the read index forward. ::soundio_instream_end_read should not be
  ## called if the buffer is empty (`frame_count` == 0), but it should be called
  ## if there is a hole.
  ##
  ## Possible errors:
  ## * #SoundIoErrorInvalid
  ##   * `*frame_count` < `frame_count_min` or `*frame_count` > `frame_count_max`
  ## * #SoundIoErrorStreaming
  ## * #SoundIoErrorIncompatibleDevice - in rare cases it might just now
  ##   be discovered that the device uses non-byte-aligned access, in which
  ##   case this error code is returned.

proc end_read*(instream: ptr SoundIoInStream): cint {.sioin.}
  ## This will drop all of the frames from when you called
  ## ::soundio_instream_begin_read.
  ## You must call this function only from the SoundIoInStream::read_callback thread context.
  ## You must call this function only after a successful call to
  ## ::soundio_instream_begin_read.
  ##
  ## Possible errors:
  ## * #SoundIoErrorStreaming

proc pause*(instream: ptr SoundIoInStream; pause: bool): cint {.sioin.}
  ## If the underyling device supports pausing, this pauses the stream and
  ## prevents SoundIoInStream::read_callback from being called. Otherwise this returns
  ## #SoundIoErrorIncompatibleDevice.
  ## This function may be called from any thread.
  ## Pausing when already paused or unpausing when already unpaused has no
  ## effect and always returns #SoundIoErrorNone.
  ##
  ## Possible errors:
  ## * #SoundIoErrorBackendDisconnected
  ## * #SoundIoErrorStreaming
  ## * #SoundIoErrorIncompatibleDevice - device does not support pausing/unpausing

proc get_latency*(instream: ptr SoundIoInStream;
                  out_latency: ptr cdouble): cint {.sioin.}
  ## Obtain the number of seconds that the next frame of sound being
  ## captured will take to arrive in the buffer, plus the amount of time that is
  ## represented in the buffer. This includes both software and hardware latency.
  ##
  ## This function must be called only from within SoundIoInStream::read_callback.
  ##
  ## Possible errors:
  ## * #SoundIoErrorStreaming

type
  SoundIoRingBuffer* {.pure, final.} = object

proc ring_buffer_create*(soundio: ptr SoundIo; requested_capacity: cint):
  ptr SoundIoRingBuffer {.sio.}
  ## `requested_capacity` in bytes.
  ## Returns `NULL` if and only if memory could not be allocated.
  ## Use ::soundio_ring_buffer_capacity to get the actual capacity, which might
  ## be greater for alignment purposes.
  ## See also ::soundio_ring_buffer_destroy

proc destroy*(ring_buffer: ptr SoundIoRingBuffer) {.siorb.}

proc capacity*(ring_buffer: ptr SoundIoRingBuffer): cint {.siorb.}
  ## When you create a ring buffer, capacity might be more than the requested
  ## capacity for alignment purposes. This function returns the actual capacity.

proc write_ptr*(ring_buffer: ptr SoundIoRingBuffer): pointer {.siorb.}
  ## Do not write more than capacity.

proc advance_write_ptr*(ring_buffer: ptr SoundIoRingBuffer;
                        count: cint) {.siorb.}
  ## `count` in bytes.

proc read_ptr*(ring_buffer: ptr SoundIoRingBuffer): pointer {.siorb.}
  ## Do not read more than capacity.

proc advance_read_ptr*(ring_buffer: ptr SoundIoRingBuffer;
                       count: cint) {.siorb.}
  ## `count` in bytes.

proc fill_count*(ring_buffer: ptr SoundIoRingBuffer): cint {.siorb.}
  ## Returns how many bytes of the buffer is used, ready for reading.

proc free_count*(ring_buffer: ptr SoundIoRingBuffer): cint {.siorb.}
  ## Returns how many bytes of the buffer is free, ready for writing.

proc clear*(ring_buffer: ptr SoundIoRingBuffer) {.siorb.}
  ## Must be called by the writer.
