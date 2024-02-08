{.compile: "soundpipe/modules/adsr.c".}
{.compile: "soundpipe/modules/autowah.c".}
{.compile: "soundpipe/modules/base.c".}
{.compile: "soundpipe/modules/bigverb.c".}
{.compile: "soundpipe/modules/biscale.c".}
{.compile: "soundpipe/modules/bitcrush.c".}
{.compile: "soundpipe/modules/blsaw.c".}
{.compile: "soundpipe/modules/blsquare.c".}
{.compile: "soundpipe/modules/bltriangle.c".}
{.compile: "soundpipe/modules/brown.c".}
{.compile: "soundpipe/modules/butbp.c".}
{.compile: "soundpipe/modules/butbr.c".}
{.compile: "soundpipe/modules/buthp.c".}
{.compile: "soundpipe/modules/butlp.c".}
{.compile: "soundpipe/modules/clamp.c".}
{.compile: "soundpipe/modules/clock.c".}
{.compile: "soundpipe/modules/compressor.c".}
{.compile: "soundpipe/modules/count.c".}
{.compile: "soundpipe/modules/crossfade.c".}
{.compile: "soundpipe/modules/dcblocker.c".}
{.compile: "soundpipe/modules/delay.c".}
{.compile: "soundpipe/modules/diode.c".}
{.compile: "soundpipe/modules/dmetro.c".}
{.compile: "soundpipe/modules/dtrig.c".}
{.compile: "soundpipe/modules/expon.c".}
{.compile: "soundpipe/modules/fmpair.c".}
{.compile: "soundpipe/modules/in.c".}
{.compile: "soundpipe/modules/incr.c".}
{.compile: "soundpipe/modules/jcrev.c".}
{.compile: "soundpipe/modules/line.c".}
{.compile: "soundpipe/modules/maygate.c".}
{.compile: "soundpipe/modules/metro.c".}
{.compile: "soundpipe/modules/modalres.c".}
{.compile: "soundpipe/modules/noise.c".}
{.compile: "soundpipe/modules/osc.c".}
{.compile: "soundpipe/modules/oscmorph.c".}
{.compile: "soundpipe/modules/peakeq.c".}
{.compile: "soundpipe/modules/peaklim.c".}
{.compile: "soundpipe/modules/phaser.c".}
{.compile: "soundpipe/modules/phasewarp.c".}
{.compile: "soundpipe/modules/phasor.c".}
{.compile: "soundpipe/modules/pinknoise.c".}
{.compile: "soundpipe/modules/prop.c".}
{.compile: "soundpipe/modules/pshift.c".}
{.compile: "soundpipe/modules/randh.c".}
{.compile: "soundpipe/modules/randmt.c".}
{.compile: "soundpipe/modules/random.c".}
{.compile: "soundpipe/modules/reverse.c".}
{.compile: "soundpipe/modules/rline.c".}
{.compile: "soundpipe/modules/rpt.c".}
{.compile: "soundpipe/modules/samphold.c".}
{.compile: "soundpipe/modules/saturator.c".}
{.compile: "soundpipe/modules/scale.c".}
{.compile: "soundpipe/modules/sdelay.c".}
{.compile: "soundpipe/modules/slice.c".}
{.compile: "soundpipe/modules/smoothdelay.c".}
{.compile: "soundpipe/modules/smoother.c".}
{.compile: "soundpipe/modules/switch.c".}
{.compile: "soundpipe/modules/tadsr.c".}
{.compile: "soundpipe/modules/talkbox.c".}
{.compile: "soundpipe/modules/tblrec.c".}
{.compile: "soundpipe/modules/tdiv.c".}
{.compile: "soundpipe/modules/tenv.c".}
{.compile: "soundpipe/modules/tenv2.c".}
{.compile: "soundpipe/modules/tenvx.c".}
{.compile: "soundpipe/modules/tgate.c".}
{.compile: "soundpipe/modules/thresh.c".}
{.compile: "soundpipe/modules/timer.c".}
{.compile: "soundpipe/modules/tin.c".}
{.compile: "soundpipe/modules/trand.c".}
{.compile: "soundpipe/modules/tread.c".}
{.compile: "soundpipe/modules/tseg.c".}
{.compile: "soundpipe/modules/tseq.c".}
{.compile: "soundpipe/modules/vardelay.c".}
{.compile: "soundpipe/modules/verbity.c".}
{.compile: "soundpipe/modules/voc.c".}
{.compile: "soundpipe/modules/wpkorg35.c".}
{.compile: "soundpipe/modules/zitarev.c".}
{.compile: "soundpipe/tangled/t_bigverb.c".}
{.compile: "soundpipe/tangled/t_dcblocker.c".}
{.compile: "soundpipe/tangled/t_fmpair.c".}
{.compile: "soundpipe/tangled/t_modalres.c".}
{.compile: "soundpipe/tangled/t_osc.c".}
{.compile: "soundpipe/tangled/t_peakeq.c".}
{.compile: "soundpipe/tangled/t_phasewarp.c".}
{.compile: "soundpipe/tangled/t_phasor.c".}
{.compile: "soundpipe/tangled/t_rline.c".}
{.compile: "soundpipe/tangled/t_scale.c".}
{.compile: "soundpipe/tangled/t_vardelay.c".}

const
  SP_BUFSIZE* = 4096

type
  SPFLOAT* = cfloat
  uint32_t = uint32
  int32_t = int32
  uint16_t = uint16
  int16_t = int16

const
  SP_OK* = 1
  SP_NOT_OK* = 0
  SP_RANDMAX* = 2147483648'i64

type
  frame* = culong
  data* {.importc: "sp_data", header: "soundpipe.h", bycopy.} = object
    `out`* {.importc: "out".}: ptr SPFLOAT
    sr* {.importc: "sr".}: cint
    nchan* {.importc: "nchan".}: cint
    len* {.importc: "len".}: culong
    pos* {.importc: "pos".}: culong
    filename* {.importc: "filename".}: array[200, char]
    rand* {.importc: "rand".}: uint32_t

  param* {.importc: "sp_param", header: "soundpipe.h", bycopy.} = object
    state* {.importc: "state".}: char
    val* {.importc: "val".}: SPFLOAT

proc create*(spp: ptr ptr data): cint {.importc: "sp_create", header: "soundpipe.h".}
proc createn*(spp: ptr ptr data; nchan: cint): cint {.importc: "sp_createn", header: "soundpipe.h".}
proc destroy*(spp: ptr ptr data): cint {.importc: "sp_destroy", header: "soundpipe.h".}
proc process*(sp: ptr data; ud: pointer; callback: proc (a1: ptr data; a2: pointer)): cint {.importc: "sp_process", header: "soundpipe.h".}
proc process_raw*(sp: ptr data; ud: pointer; callback: proc (a1: ptr data; a2: pointer)): cint {.importc: "sp_process_raw", header: "soundpipe.h".}
proc process_plot*(sp: ptr data; ud: pointer; callback: proc (a1: ptr data; a2: pointer)): cint {.importc: "sp_process_plot", header: "soundpipe.h".}
proc process_spa*(sp: ptr data; ud: pointer; callback: proc (a1: ptr data; a2: pointer)): cint {.importc: "sp_process_spa", header: "soundpipe.h".}
proc midi2cps*(nn: SPFLOAT): SPFLOAT {.importc: "sp_midi2cps", header: "soundpipe.h".}
proc set*(p: ptr param; val: SPFLOAT): cint {.importc: "sp_set", header: "soundpipe.h".}
proc `out`*(sp: ptr data; chan: uint32_t; val: SPFLOAT): cint {.importc: "sp_out", header: "soundpipe.h".}
proc rand*(sp: ptr data): uint32_t {.importc: "sp_rand", header: "soundpipe.h".}
proc srand*(sp: ptr data; val: uint32_t) {.importc: "sp_srand", header: "soundpipe.h".}

type
  fft* {.importc: "sp_fft", header: "soundpipe.h", bycopy.} = object
    utbl* {.importc: "utbl".}: ptr SPFLOAT
    BRLow* {.importc: "BRLow".}: ptr int16_t
    BRLowCpx* {.importc: "BRLowCpx".}: ptr int16_t

proc fft_create*(fft: ptr ptr fft) {.importc: "sp_fft_create", header: "soundpipe.h".}
proc fft_init*(fft: ptr fft; M: cint) {.importc: "sp_fft_init", header: "soundpipe.h".}
proc fftr*(fft: ptr fft; buf: ptr SPFLOAT; FFTsize: cint) {.importc: "sp_fftr", header: "soundpipe.h".}
proc fft_cpx*(fft: ptr fft; buf: ptr SPFLOAT; FFTsize: cint) {.importc: "sp_fft_cpx", header: "soundpipe.h".}
proc ifftr*(fft: ptr fft; buf: ptr SPFLOAT; FFTsize: cint) {.importc: "sp_ifftr", header: "soundpipe.h".}
proc fft_destroy*(fft: ptr fft) {.importc: "sp_fft_destroy", header: "soundpipe.h".}

when not defined(kiss_fft_scalar):
  type
    kiss_fft_scalar* = SPFLOAT

type
  kiss_fft_cpx* {.importc: "kiss_fft_cpx", header: "soundpipe.h",
      bycopy.} = object
    r* {.importc: "r".}: kiss_fft_scalar
    i* {.importc: "i".}: kiss_fft_scalar

  # kiss_fft_cfg* = ptr kiss_fft_state
  # kiss_fftr_cfg* = ptr kiss_fftr_state
  kiss_fft_cfg* = pointer
  kiss_fftr_cfg* = pointer

##  SPA: Soundpipe Audio

const
  SPA_READ* = 0
  SPA_WRITE* = 1
  SPA_NULL* = 2

type
  spa_header* {.importc: "spa_header", header: "soundpipe.h", bycopy.} = object
    magic* {.importc: "magic".}: char
    nchan* {.importc: "nchan".}: char
    sr* {.importc: "sr".}: uint16_t
    len* {.importc: "len".}: uint32_t

  audio* {.importc: "sp_audio", header: "soundpipe.h", bycopy.} = object
    header* {.importc: "header".}: spa_header
    offset* {.importc: "offset".}: csize_t
    mode* {.importc: "mode".}: cint
    fp* {.importc: "fp".}: ptr FILE
    pos* {.importc: "pos".}: uint32_t

const
  SP_FT_MAXLEN* = 0x01000000
  SP_FT_PHMASK* = 0x00FFFFFF

type
  ftbl* {.importc: "sp_ftbl", header: "soundpipe.h", bycopy.} = object
    size* {.importc: "size".}: csize_t
    tbl* {.importc: "tbl".}: ptr SPFLOAT

proc ftbl_create*(sp: ptr data; ft: ptr ptr ftbl; size: csize_t): cint {.importc: "sp_ftbl_create", header: "soundpipe.h".}
proc ftbl_init*(sp: ptr data; ft: ptr ftbl; size: csize_t): cint {.importc: "sp_ftbl_init", header: "soundpipe.h".}
proc ftbl_bind*(sp: ptr data; ft: ptr ptr ftbl; tbl: ptr SPFLOAT; size: csize_t): cint {.importc: "sp_ftbl_bind", header: "soundpipe.h".}
proc ftbl_destroy*(ft: ptr ptr ftbl): cint {.importc: "sp_ftbl_destroy", header: "soundpipe.h".}
proc ftbl_loadfile*(sp: ptr data; ft: ptr ptr ftbl; filename: cstring): cint {.importc: "sp_ftbl_loadfile", header: "soundpipe.h".}
proc ftbl_loadspa*(sp: ptr data; ft: ptr ptr ftbl; filename: cstring): cint {.importc: "sp_ftbl_loadspa", header: "soundpipe.h".}
proc gen_vals*(sp: ptr data; ft: ptr ftbl; string: cstring): cint {.importc: "sp_gen_vals", header: "soundpipe.h".}
proc gen_sine*(sp: ptr data; ft: ptr ftbl): cint {.importc: "sp_gen_sine", header: "soundpipe.h".}
proc gen_triangle*(sp: ptr data; ft: ptr ftbl) {.importc: "sp_gen_triangle", header: "soundpipe.h".}
proc gen_composite*(sp: ptr data; ft: ptr ftbl; argstring: cstring) {.importc: "sp_gen_composite", header: "soundpipe.h".}
proc gen_sinesum*(sp: ptr data; ft: ptr ftbl; argstring: cstring) {.importc: "sp_gen_sinesum", header: "soundpipe.h".}
proc ftbl_fftcut*(ft: ptr ftbl; cut: cint) {.importc: "sp_ftbl_fftcut", header: "soundpipe.h".}

type
  adsr* {.importc: "sp_adsr", header: "soundpipe.h", bycopy.} = object
    atk* {.importc: "atk".}: SPFLOAT
    dec* {.importc: "dec".}: SPFLOAT
    sus* {.importc: "sus".}: SPFLOAT
    rel* {.importc: "rel".}: SPFLOAT
    timer* {.importc: "timer".}: uint32_t
    atk_time* {.importc: "atk_time".}: uint32_t
    a* {.importc: "a".}: SPFLOAT
    b* {.importc: "b".}: SPFLOAT
    y* {.importc: "y".}: SPFLOAT
    x* {.importc: "x".}: SPFLOAT
    prev* {.importc: "prev".}: SPFLOAT
    mode* {.importc: "mode".}: cint

proc adsr_create*(p: ptr ptr adsr): cint {.importc: "sp_adsr_create", header: "soundpipe.h".}
proc adsr_destroy*(p: ptr ptr adsr): cint {.importc: "sp_adsr_destroy", header: "soundpipe.h".}
proc adsr_init*(sp: ptr data; p: ptr adsr): cint {.importc: "sp_adsr_init", header: "soundpipe.h".}
proc adsr_compute*(sp: ptr data; p: ptr adsr; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_adsr_compute", header: "soundpipe.h".}

type
  autowah* {.importc: "sp_autowah", header: "soundpipe.h", bycopy.} = object
    faust* {.importc: "faust".}: pointer
    argpos* {.importc: "argpos".}: cint
    args* {.importc: "args".}: array[3, ptr SPFLOAT]
    level* {.importc: "level".}: ptr SPFLOAT
    wah* {.importc: "wah".}: ptr SPFLOAT
    mix* {.importc: "mix".}: ptr SPFLOAT

proc autowah_create*(p: ptr ptr autowah): cint {.importc: "sp_autowah_create", header: "soundpipe.h".}
proc autowah_destroy*(p: ptr ptr autowah): cint {.importc: "sp_autowah_destroy", header: "soundpipe.h".}
proc autowah_init*(sp: ptr data; p: ptr autowah): cint {.importc: "sp_autowah_init", header: "soundpipe.h".}
proc autowah_compute*(sp: ptr data; p: ptr autowah; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_autowah_compute", header: "soundpipe.h".}

type
  biscale* {.importc: "sp_biscale", header: "soundpipe.h", bycopy.} = object
    min* {.importc: "min".}: SPFLOAT
    max* {.importc: "max".}: SPFLOAT

proc biscale_create*(p: ptr ptr biscale): cint {.importc: "sp_biscale_create", header: "soundpipe.h".}
proc biscale_destroy*(p: ptr ptr biscale): cint {.importc: "sp_biscale_destroy", header: "soundpipe.h".}
proc biscale_init*(sp: ptr data; p: ptr biscale): cint {.importc: "sp_biscale_init", header: "soundpipe.h".}
proc biscale_compute*(sp: ptr data; p: ptr biscale; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_biscale_compute", header: "soundpipe.h".}

type
  blsaw* {.importc: "sp_blsaw", header: "soundpipe.h", bycopy.} = object
    ud* {.importc: "ud".}: pointer
    argpos* {.importc: "argpos".}: cint
    args* {.importc: "args".}: array[2, ptr SPFLOAT]
    freq* {.importc: "freq".}: ptr SPFLOAT
    amp* {.importc: "amp".}: ptr SPFLOAT

proc blsaw_create*(p: ptr ptr blsaw): cint {.importc: "sp_blsaw_create", header: "soundpipe.h".}
proc blsaw_destroy*(p: ptr ptr blsaw): cint {.importc: "sp_blsaw_destroy", header: "soundpipe.h".}
proc blsaw_init*(sp: ptr data; p: ptr blsaw): cint {.importc: "sp_blsaw_init", header: "soundpipe.h".}
proc blsaw_compute*(sp: ptr data; p: ptr blsaw; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_blsaw_compute", header: "soundpipe.h".}

type
  blsquare* {.importc: "sp_blsquare", header: "soundpipe.h", bycopy.} = object
    ud* {.importc: "ud".}: pointer
    argpos* {.importc: "argpos".}: cint
    args* {.importc: "args".}: array[3, ptr SPFLOAT]
    freq* {.importc: "freq".}: ptr SPFLOAT
    amp* {.importc: "amp".}: ptr SPFLOAT
    width* {.importc: "width".}: ptr SPFLOAT

proc blsquare_create*(p: ptr ptr blsquare): cint {.importc: "sp_blsquare_create", header: "soundpipe.h".}
proc blsquare_destroy*(p: ptr ptr blsquare): cint {.importc: "sp_blsquare_destroy", header: "soundpipe.h".}
proc blsquare_init*(sp: ptr data; p: ptr blsquare): cint {.importc: "sp_blsquare_init", header: "soundpipe.h".}
proc blsquare_compute*(sp: ptr data; p: ptr blsquare; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_blsquare_compute", header: "soundpipe.h".}

type
  bltriangle* {.importc: "sp_bltriangle", header: "soundpipe.h",
      bycopy.} = object
    ud* {.importc: "ud".}: pointer
    argpos* {.importc: "argpos".}: cint
    args* {.importc: "args".}: array[2, ptr SPFLOAT]
    freq* {.importc: "freq".}: ptr SPFLOAT
    amp* {.importc: "amp".}: ptr SPFLOAT

proc bltriangle_create*(p: ptr ptr bltriangle): cint {.importc: "sp_bltriangle_create", header: "soundpipe.h".}
proc bltriangle_destroy*(p: ptr ptr bltriangle): cint {.importc: "sp_bltriangle_destroy", header: "soundpipe.h".}
proc bltriangle_init*(sp: ptr data; p: ptr bltriangle): cint {.importc: "sp_bltriangle_init", header: "soundpipe.h".}
proc bltriangle_compute*(sp: ptr data; p: ptr bltriangle; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_bltriangle_compute", header: "soundpipe.h".}

type
  butlp* {.importc: "sp_butlp", header: "soundpipe.h", bycopy.} = object
    sr* {.importc: "sr".}: SPFLOAT
    freq* {.importc: "freq".}: SPFLOAT
    lfreq* {.importc: "lfreq".}: SPFLOAT
    a* {.importc: "a".}: array[7, SPFLOAT]
    pidsr* {.importc: "pidsr".}: SPFLOAT

proc butlp_create*(p: ptr ptr butlp): cint {.importc: "sp_butlp_create", header: "soundpipe.h".}
proc butlp_destroy*(p: ptr ptr butlp): cint {.importc: "sp_butlp_destroy", header: "soundpipe.h".}
proc butlp_init*(sp: ptr data; p: ptr butlp): cint {.importc: "sp_butlp_init", header: "soundpipe.h".}
proc butlp_compute*(sp: ptr data; p: ptr butlp; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_butlp_compute", header: "soundpipe.h".}

type
  butbp* {.importc: "sp_butbp", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    bw* {.importc: "bw".}: SPFLOAT
    lfreq* {.importc: "lfreq".}: SPFLOAT
    lbw* {.importc: "lbw".}: SPFLOAT
    a* {.importc: "a".}: array[7, SPFLOAT]
    pidsr* {.importc: "pidsr".}: SPFLOAT
    tpidsr* {.importc: "tpidsr".}: SPFLOAT

proc butbp_create*(p: ptr ptr butbp): cint {.importc: "sp_butbp_create", header: "soundpipe.h".}
proc butbp_destroy*(p: ptr ptr butbp): cint {.importc: "sp_butbp_destroy", header: "soundpipe.h".}
proc butbp_init*(sp: ptr data; p: ptr butbp): cint {.importc: "sp_butbp_init", header: "soundpipe.h".}
proc butbp_compute*(sp: ptr data; p: ptr butbp; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_butbp_compute", header: "soundpipe.h".}

type
  buthp* {.importc: "sp_buthp", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    lfreq* {.importc: "lfreq".}: SPFLOAT
    a* {.importc: "a".}: array[7, SPFLOAT]
    pidsr* {.importc: "pidsr".}: SPFLOAT

proc buthp_create*(p: ptr ptr buthp): cint {.importc: "sp_buthp_create", header: "soundpipe.h".}
proc buthp_destroy*(p: ptr ptr buthp): cint {.importc: "sp_buthp_destroy", header: "soundpipe.h".}
proc buthp_init*(sp: ptr data; p: ptr buthp): cint {.importc: "sp_buthp_init", header: "soundpipe.h".}
proc buthp_compute*(sp: ptr data; p: ptr buthp; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_buthp_compute", header: "soundpipe.h".}

type
  butbr* {.importc: "sp_butbr", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    bw* {.importc: "bw".}: SPFLOAT
    lfreq* {.importc: "lfreq".}: SPFLOAT
    lbw* {.importc: "lbw".}: SPFLOAT
    a* {.importc: "a".}: array[7, SPFLOAT]
    pidsr* {.importc: "pidsr".}: SPFLOAT
    tpidsr* {.importc: "tpidsr".}: SPFLOAT

proc butbr_create*(p: ptr ptr butbr): cint {.importc: "sp_butbr_create", header: "soundpipe.h".}
proc butbr_destroy*(p: ptr ptr butbr): cint {.importc: "sp_butbr_destroy", header: "soundpipe.h".}
proc butbr_init*(sp: ptr data; p: ptr butbr): cint {.importc: "sp_butbr_init", header: "soundpipe.h".}
proc butbr_compute*(sp: ptr data; p: ptr butbr; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_butbr_compute", header: "soundpipe.h".}

type
  brown* {.importc: "sp_brown", header: "soundpipe.h", bycopy.} = object
    brown* {.importc: "brown".}: SPFLOAT

proc brown_create*(p: ptr ptr brown): cint {.importc: "sp_brown_create", header: "soundpipe.h".}
proc brown_destroy*(p: ptr ptr brown): cint {.importc: "sp_brown_destroy", header: "soundpipe.h".}
proc brown_init*(sp: ptr data; p: ptr brown): cint {.importc: "sp_brown_init", header: "soundpipe.h".}
proc brown_compute*(sp: ptr data; p: ptr brown; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_brown_compute", header: "soundpipe.h".}

type
  clamp* {.importc: "sp_clamp", header: "soundpipe.h", bycopy.} = object
    min* {.importc: "min".}: SPFLOAT
    max* {.importc: "max".}: SPFLOAT

proc clamp_create*(p: ptr ptr clamp): cint {.importc: "sp_clamp_create", header: "soundpipe.h".}
proc clamp_destroy*(p: ptr ptr clamp): cint {.importc: "sp_clamp_destroy", header: "soundpipe.h".}
proc clamp_init*(sp: ptr data; p: ptr clamp): cint {.importc: "sp_clamp_init", header: "soundpipe.h".}
proc clamp_compute*(sp: ptr data; p: ptr clamp; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_clamp_compute", header: "soundpipe.h".}

type
  clock* {.importc: "sp_clock", header: "soundpipe.h", bycopy.} = object
    bpm* {.importc: "bpm".}: SPFLOAT
    subdiv* {.importc: "subdiv".}: SPFLOAT
    counter* {.importc: "counter".}: uint32_t

proc clock_create*(p: ptr ptr clock): cint {.importc: "sp_clock_create", header: "soundpipe.h".}
proc clock_destroy*(p: ptr ptr clock): cint {.importc: "sp_clock_destroy", header: "soundpipe.h".}
proc clock_init*(sp: ptr data; p: ptr clock): cint {.importc: "sp_clock_init", header: "soundpipe.h".}
proc clock_compute*(sp: ptr data; p: ptr clock; trig: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_clock_compute", header: "soundpipe.h".}

type
  compressor* {.importc: "sp_compressor", header: "soundpipe.h",
      bycopy.} = object
    faust* {.importc: "faust".}: pointer
    argpos* {.importc: "argpos".}: cint
    args* {.importc: "args".}: array[4, ptr SPFLOAT]
    ratio* {.importc: "ratio".}: ptr SPFLOAT
    thresh* {.importc: "thresh".}: ptr SPFLOAT
    atk* {.importc: "atk".}: ptr SPFLOAT
    rel* {.importc: "rel".}: ptr SPFLOAT

proc compressor_create*(p: ptr ptr compressor): cint {.importc: "sp_compressor_create", header: "soundpipe.h".}
proc compressor_destroy*(p: ptr ptr compressor): cint {.importc: "sp_compressor_destroy", header: "soundpipe.h".}
proc compressor_init*(sp: ptr data; p: ptr compressor): cint {.importc: "sp_compressor_init", header: "soundpipe.h".}
proc compressor_compute*(sp: ptr data; p: ptr compressor; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_compressor_compute", header: "soundpipe.h".}

type
  count* {.importc: "sp_count", header: "soundpipe.h", bycopy.} = object
    count* {.importc: "count".}: int32_t
    curcount* {.importc: "curcount".}: int32_t
    mode* {.importc: "mode".}: cint

proc count_create*(p: ptr ptr count): cint {.importc: "sp_count_create", header: "soundpipe.h".}
proc count_destroy*(p: ptr ptr count): cint {.importc: "sp_count_destroy", header: "soundpipe.h".}
proc count_init*(sp: ptr data; p: ptr count): cint {.importc: "sp_count_init", header: "soundpipe.h".}
proc count_compute*(sp: ptr data; p: ptr count; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_count_compute", header: "soundpipe.h".}

type
  crossfade* {.importc: "sp_crossfade", header: "soundpipe.h", bycopy.} = object
    pos* {.importc: "pos".}: SPFLOAT

proc crossfade_create*(p: ptr ptr crossfade): cint {.importc: "sp_crossfade_create", header: "soundpipe.h".}
proc crossfade_destroy*(p: ptr ptr crossfade): cint {.importc: "sp_crossfade_destroy", header: "soundpipe.h".}
proc crossfade_init*(sp: ptr data; p: ptr crossfade): cint {.importc: "sp_crossfade_init", header: "soundpipe.h".}
proc crossfade_compute*(sp: ptr data; p: ptr crossfade; in1: ptr SPFLOAT; in2: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_crossfade_compute", header: "soundpipe.h".}

type
  delay* {.importc: "sp_delay", header: "soundpipe.h", bycopy.} = object
    time* {.importc: "time".}: SPFLOAT
    feedback* {.importc: "feedback".}: SPFLOAT
    last* {.importc: "last".}: SPFLOAT
    buf* {.importc: "buf".}: ptr SPFLOAT
    bufsize* {.importc: "bufsize".}: uint32_t
    bufpos* {.importc: "bufpos".}: uint32_t

proc delay_create*(p: ptr ptr delay): cint {.importc: "sp_delay_create", header: "soundpipe.h".}
proc delay_destroy*(p: ptr ptr delay): cint {.importc: "sp_delay_destroy", header: "soundpipe.h".}
proc delay_init*(sp: ptr data; p: ptr delay; time: SPFLOAT): cint {.importc: "sp_delay_init", header: "soundpipe.h".}
proc delay_compute*(sp: ptr data; p: ptr delay; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_delay_compute", header: "soundpipe.h".}

type
  diode* {.importc: "sp_diode", header: "soundpipe.h", bycopy.} = object
    opva_alpha* {.importc: "opva_alpha".}: array[4, SPFLOAT] ##  4 one-pole filters
    opva_beta* {.importc: "opva_beta".}: array[4, SPFLOAT]
    opva_gamma* {.importc: "opva_gamma".}: array[4, SPFLOAT]
    opva_delta* {.importc: "opva_delta".}: array[4, SPFLOAT]
    opva_eps* {.importc: "opva_eps".}: array[4, SPFLOAT]
    opva_a0* {.importc: "opva_a0".}: array[4, SPFLOAT]
    opva_fdbk* {.importc: "opva_fdbk".}: array[4, SPFLOAT]
    opva_z1* {.importc: "opva_z1".}: array[4, SPFLOAT]       ##  end one-pole filters
    SG* {.importc: "SG".}: array[4, SPFLOAT]
    gamma* {.importc: "gamma".}: SPFLOAT
    freq* {.importc: "freq".}: SPFLOAT
    K* {.importc: "K".}: SPFLOAT
    res* {.importc: "res".}: SPFLOAT

proc diode_create*(p: ptr ptr diode): cint {.importc: "sp_diode_create", header: "soundpipe.h".}
proc diode_destroy*(p: ptr ptr diode): cint {.importc: "sp_diode_destroy", header: "soundpipe.h".}
proc diode_init*(sp: ptr data; p: ptr diode): cint {.importc: "sp_diode_init", header: "soundpipe.h".}
proc diode_compute*(sp: ptr data; p: ptr diode; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_diode_compute", header: "soundpipe.h".}

type
  dmetro* {.importc: "sp_dmetro", header: "soundpipe.h", bycopy.} = object
    time* {.importc: "time".}: SPFLOAT
    counter* {.importc: "counter".}: uint32_t

proc dmetro_create*(p: ptr ptr dmetro): cint {.importc: "sp_dmetro_create", header: "soundpipe.h".}
proc dmetro_destroy*(p: ptr ptr dmetro): cint {.importc: "sp_dmetro_destroy", header: "soundpipe.h".}
proc dmetro_init*(sp: ptr data; p: ptr dmetro): cint {.importc: "sp_dmetro_init", header: "soundpipe.h".}
proc dmetro_compute*(sp: ptr data; p: ptr dmetro; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_dmetro_compute", header: "soundpipe.h".}

type
  dtrig* {.importc: "sp_dtrig", header: "soundpipe.h", bycopy.} = object
    ft* {.importc: "ft".}: ptr ftbl
    counter* {.importc: "counter".}: uint32_t
    pos* {.importc: "pos".}: uint32_t
    running* {.importc: "running".}: cint
    loop* {.importc: "loop".}: cint
    delay* {.importc: "delay".}: SPFLOAT
    scale* {.importc: "scale".}: SPFLOAT

proc dtrig_create*(p: ptr ptr dtrig): cint {.importc: "sp_dtrig_create", header: "soundpipe.h".}
proc dtrig_destroy*(p: ptr ptr dtrig): cint {.importc: "sp_dtrig_destroy", header: "soundpipe.h".}
proc dtrig_init*(sp: ptr data; p: ptr dtrig; ft: ptr ftbl): cint {.importc: "sp_dtrig_init", header: "soundpipe.h".}
proc dtrig_compute*(sp: ptr data; p: ptr dtrig; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_dtrig_compute", header: "soundpipe.h".}

type
  expon* {.importc: "sp_expon", header: "soundpipe.h", bycopy.} = object
    a* {.importc: "a".}: SPFLOAT
    dur* {.importc: "dur".}: SPFLOAT
    b* {.importc: "b".}: SPFLOAT
    val* {.importc: "val".}: SPFLOAT
    incr* {.importc: "incr".}: SPFLOAT
    sdur* {.importc: "sdur".}: uint32_t
    stime* {.importc: "stime".}: uint32_t
    init* {.importc: "init".}: cint

proc expon_create*(p: ptr ptr expon): cint {.importc: "sp_expon_create", header: "soundpipe.h".}
proc expon_destroy*(p: ptr ptr expon): cint {.importc: "sp_expon_destroy", header: "soundpipe.h".}
proc expon_init*(sp: ptr data; p: ptr expon): cint {.importc: "sp_expon_init", header: "soundpipe.h".}
proc expon_compute*(sp: ptr data; p: ptr expon; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_expon_compute", header: "soundpipe.h".}

type
  `in`* {.importc: "sp_in", header: "soundpipe.h", bycopy.} = object
    fp* {.importc: "fp".}: ptr FILE

proc in_create*(p: ptr ptr `in`): cint {.importc: "sp_in_create", header: "soundpipe.h".}
proc in_destroy*(p: ptr ptr `in`): cint {.importc: "sp_in_destroy", header: "soundpipe.h".}
proc in_init*(sp: ptr data; p: ptr `in`): cint {.importc: "sp_in_init", header: "soundpipe.h".}
proc in_compute*(sp: ptr data; p: ptr `in`; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_in_compute", header: "soundpipe.h".}

type
  incr* {.importc: "sp_incr", header: "soundpipe.h", bycopy.} = object
    step* {.importc: "step".}: SPFLOAT
    min* {.importc: "min".}: SPFLOAT
    max* {.importc: "max".}: SPFLOAT
    val* {.importc: "val".}: SPFLOAT

proc incr_create*(p: ptr ptr incr): cint {.importc: "sp_incr_create", header: "soundpipe.h".}
proc incr_destroy*(p: ptr ptr incr): cint {.importc: "sp_incr_destroy", header: "soundpipe.h".}
proc incr_init*(sp: ptr data; p: ptr incr; val: SPFLOAT): cint {.importc: "sp_incr_init", header: "soundpipe.h".}
proc incr_compute*(sp: ptr data; p: ptr incr; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_incr_compute", header: "soundpipe.h".}

type
  jcrev* {.importc: "sp_jcrev", header: "soundpipe.h", bycopy.} = object
    ud* {.importc: "ud".}: pointer

proc jcrev_create*(p: ptr ptr jcrev): cint {.importc: "sp_jcrev_create", header: "soundpipe.h".}
proc jcrev_destroy*(p: ptr ptr jcrev): cint {.importc: "sp_jcrev_destroy", header: "soundpipe.h".}
proc jcrev_init*(sp: ptr data; p: ptr jcrev): cint {.importc: "sp_jcrev_init", header: "soundpipe.h".}
proc jcrev_compute*(sp: ptr data; p: ptr jcrev; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_jcrev_compute", header: "soundpipe.h".}

type
  line* {.importc: "sp_line", header: "soundpipe.h", bycopy.} = object
    a* {.importc: "a".}: SPFLOAT
    dur* {.importc: "dur".}: SPFLOAT
    b* {.importc: "b".}: SPFLOAT
    val* {.importc: "val".}: SPFLOAT
    incr* {.importc: "incr".}: SPFLOAT
    sdur* {.importc: "sdur".}: uint32_t
    stime* {.importc: "stime".}: uint32_t
    init* {.importc: "init".}: cint

proc line_create*(p: ptr ptr line): cint {.importc: "sp_line_create", header: "soundpipe.h".}
proc line_destroy*(p: ptr ptr line): cint {.importc: "sp_line_destroy", header: "soundpipe.h".}
proc line_init*(sp: ptr data; p: ptr line): cint {.importc: "sp_line_init", header: "soundpipe.h".}
proc line_compute*(sp: ptr data; p: ptr line; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_line_compute", header: "soundpipe.h".}
proc ftbl_loadwav*(sp: ptr data; ft: ptr ptr ftbl; filename: cstring): cint {.importc: "sp_ftbl_loadwav", header: "soundpipe.h".}

type
  lpc* {.importc: "sp_lpc", header: "soundpipe.h", bycopy.} = object
    # e* {.importc: "e".}: ptr openlpc_e_state
    e* {.importc: "e".}: pointer
    # d* {.importc: "d".}: ptr openlpc_d_state
    d* {.importc: "d".}: pointer
    counter* {.importc: "counter".}: cint
    `in`* {.importc: "in".}: ptr cshort
    `out`* {.importc: "out".}: ptr cshort
    data* {.importc: "data".}: array[7, uint8]
    y* {.importc: "y".}: array[7, SPFLOAT]
    smooth* {.importc: "smooth".}: SPFLOAT
    samp* {.importc: "samp".}: SPFLOAT
    clock* {.importc: "clock".}: cuint
    `block`* {.importc: "block".}: cuint
    framesize* {.importc: "framesize".}: cint
    mode* {.importc: "mode".}: cint
    ft* {.importc: "ft".}: ptr ftbl

proc lpc_create*(lpc: ptr ptr lpc): cint {.importc: "sp_lpc_create", header: "soundpipe.h".}
proc lpc_destroy*(lpc: ptr ptr lpc): cint {.importc: "sp_lpc_destroy", header: "soundpipe.h".}
proc lpc_init*(sp: ptr data; lpc: ptr lpc; framesize: cint): cint {.importc: "sp_lpc_init", header: "soundpipe.h".}
proc lpc_synth*(sp: ptr data; lpc: ptr lpc; ft: ptr ftbl): cint {.importc: "sp_lpc_synth", header: "soundpipe.h".}
proc lpc_compute*(sp: ptr data; lpc: ptr lpc; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_lpc_compute", header: "soundpipe.h".}

type
  maygate* {.importc: "sp_maygate", header: "soundpipe.h", bycopy.} = object
    prob* {.importc: "prob".}: SPFLOAT
    gate* {.importc: "gate".}: SPFLOAT
    mode* {.importc: "mode".}: cint

proc maygate_create*(p: ptr ptr maygate): cint {.importc: "sp_maygate_create", header: "soundpipe.h".}
proc maygate_destroy*(p: ptr ptr maygate): cint {.importc: "sp_maygate_destroy", header: "soundpipe.h".}
proc maygate_init*(sp: ptr data; p: ptr maygate): cint {.importc: "sp_maygate_init", header: "soundpipe.h".}
proc maygate_compute*(sp: ptr data; p: ptr maygate; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_maygate_compute", header: "soundpipe.h".}

type
  metro* {.importc: "sp_metro", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    phs* {.importc: "phs".}: SPFLOAT
    init* {.importc: "init".}: cint
    onedsr* {.importc: "onedsr".}: SPFLOAT

proc metro_create*(p: ptr ptr metro): cint {.importc: "sp_metro_create", header: "soundpipe.h".}
proc metro_destroy*(p: ptr ptr metro): cint {.importc: "sp_metro_destroy", header: "soundpipe.h".}
proc metro_init*(sp: ptr data; p: ptr metro): cint {.importc: "sp_metro_init", header: "soundpipe.h".}
proc metro_compute*(sp: ptr data; p: ptr metro; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_metro_compute", header: "soundpipe.h".}

type
  noise* {.importc: "sp_noise", header: "soundpipe.h", bycopy.} = object
    amp* {.importc: "amp".}: SPFLOAT

proc noise_create*(ns: ptr ptr noise): cint {.importc: "sp_noise_create", header: "soundpipe.h".}
proc noise_init*(sp: ptr data; ns: ptr noise): cint {.importc: "sp_noise_init", header: "soundpipe.h".}
proc noise_compute*(sp: ptr data; ns: ptr noise; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_noise_compute", header: "soundpipe.h".}
proc noise_destroy*(ns: ptr ptr noise): cint {.importc: "sp_noise_destroy", header: "soundpipe.h".}

type
  nano_entry* {.importc: "nano_entry", header: "soundpipe.h", bycopy.} = object
    name* {.importc: "name".}: array[50, char]
    pos* {.importc: "pos".}: uint32_t
    size* {.importc: "size".}: uint32_t
    speed* {.importc: "speed".}: SPFLOAT
    next* {.importc: "next".}: ptr nano_entry

  nano_dict* {.importc: "nano_dict", header: "soundpipe.h", bycopy.} = object
    nval* {.importc: "nval".}: cint
    init* {.importc: "init".}: cint
    root* {.importc: "root".}: nano_entry
    last* {.importc: "last".}: ptr nano_entry

  nanosamp* {.importc: "nanosamp", header: "soundpipe.h", bycopy.} = object
    ini* {.importc: "ini".}: array[100, char]
    curpos* {.importc: "curpos".}: SPFLOAT
    dict* {.importc: "dict".}: nano_dict
    selected* {.importc: "selected".}: cint
    sample* {.importc: "sample".}: ptr nano_entry
    index* {.importc: "index".}: ptr ptr nano_entry
    ft* {.importc: "ft".}: ptr ftbl
    sr* {.importc: "sr".}: cint

  nsmp* {.importc: "sp_nsmp", header: "soundpipe.h", bycopy.} = object
    smp* {.importc: "smp".}: ptr nanosamp
    index* {.importc: "index".}: uint32_t
    triggered* {.importc: "triggered".}: cint

proc nsmp_create*(p: ptr ptr nsmp): cint {.importc: "sp_nsmp_create", header: "soundpipe.h".}
proc nsmp_destroy*(p: ptr ptr nsmp): cint {.importc: "sp_nsmp_destroy", header: "soundpipe.h".}
proc nsmp_init*(sp: ptr data; p: ptr nsmp; ft: ptr ftbl; sr: cint; ini: cstring): cint {.importc: "sp_nsmp_init", header: "soundpipe.h".}
proc nsmp_compute*(sp: ptr data; p: ptr nsmp; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_nsmp_compute", header: "soundpipe.h".}
proc nsmp_print_index*(sp: ptr data; p: ptr nsmp): cint {.importc: "sp_nsmp_print_index", header: "soundpipe.h".}

type
  osc* {.importc: "sp_osc", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    amp* {.importc: "amp".}: SPFLOAT
    iphs* {.importc: "iphs".}: SPFLOAT
    # osc* {.importc: "osc".}: ptr sk_osc
    osc* {.importc: "osc".}: pointer

proc osc_create*(osc: ptr ptr osc): cint {.importc: "sp_osc_create", header: "soundpipe.h".}
proc osc_destroy*(osc: ptr ptr osc): cint {.importc: "sp_osc_destroy", header: "soundpipe.h".}
proc osc_init*(sp: ptr data; osc: ptr osc; ft: ptr ftbl; iphs: SPFLOAT): cint {.importc: "sp_osc_init", header: "soundpipe.h".}
proc osc_compute*(sp: ptr data; osc: ptr osc; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_osc_compute", header: "soundpipe.h".}

type
  paulstretch* {.importc: "sp_paulstretch", header: "soundpipe.h",
      bycopy.} = object
    windowsize* {.importc: "windowsize".}: uint32_t
    half_windowsize* {.importc: "half_windowsize".}: uint32_t
    stretch* {.importc: "stretch".}: SPFLOAT
    start_pos* {.importc: "start_pos".}: SPFLOAT
    displace_pos* {.importc: "displace_pos".}: SPFLOAT
    window* {.importc: "window".}: ptr SPFLOAT
    old_windowed_buf* {.importc: "old_windowed_buf".}: ptr SPFLOAT
    hinv_buf* {.importc: "hinv_buf".}: ptr SPFLOAT
    buf* {.importc: "buf".}: ptr SPFLOAT
    output* {.importc: "output".}: ptr SPFLOAT
    ft* {.importc: "ft".}: ptr ftbl
    fft* {.importc: "fft".}: kiss_fftr_cfg
    ifft* {.importc: "ifft".}: kiss_fftr_cfg
    tmp1* {.importc: "tmp1".}: ptr kiss_fft_cpx
    tmp2* {.importc: "tmp2".}: ptr kiss_fft_cpx
    counter* {.importc: "counter".}: uint32_t
    wrap* {.importc: "wrap".}: uint8

proc paulstretch_create*(p: ptr ptr paulstretch): cint {.importc: "sp_paulstretch_create", header: "soundpipe.h".}
proc paulstretch_destroy*(p: ptr ptr paulstretch): cint {.importc: "sp_paulstretch_destroy", header: "soundpipe.h".}
proc paulstretch_init*(sp: ptr data; p: ptr paulstretch; ft: ptr ftbl; windowsize: SPFLOAT; stretch: SPFLOAT): cint {.importc: "sp_paulstretch_init", header: "soundpipe.h".}
proc paulstretch_compute*(sp: ptr data; p: ptr paulstretch; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_paulstretch_compute", header: "soundpipe.h".}

type
  peaklim* {.importc: "sp_peaklim", header: "soundpipe.h", bycopy.} = object
    atk* {.importc: "atk".}: SPFLOAT
    rel* {.importc: "rel".}: SPFLOAT
    thresh* {.importc: "thresh".}: SPFLOAT
    patk* {.importc: "patk".}: SPFLOAT
    prel* {.importc: "prel".}: SPFLOAT
    b0_r* {.importc: "b0_r".}: SPFLOAT
    a1_r* {.importc: "a1_r".}: SPFLOAT
    b0_a* {.importc: "b0_a".}: SPFLOAT
    a1_a* {.importc: "a1_a".}: SPFLOAT
    level* {.importc: "level".}: SPFLOAT

proc peaklim_create*(p: ptr ptr peaklim): cint {.importc: "sp_peaklim_create", header: "soundpipe.h".}
proc peaklim_destroy*(p: ptr ptr peaklim): cint {.importc: "sp_peaklim_destroy", header: "soundpipe.h".}
proc peaklim_init*(sp: ptr data; p: ptr peaklim): cint {.importc: "sp_peaklim_init", header: "soundpipe.h".}
proc peaklim_compute*(sp: ptr data; p: ptr peaklim; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_peaklim_compute", header: "soundpipe.h".}

type
  phaser* {.importc: "sp_phaser", header: "soundpipe.h", bycopy.} = object
    faust* {.importc: "faust".}: pointer
    argpos* {.importc: "argpos".}: cint
    args* {.importc: "args".}: array[10, ptr SPFLOAT]
    MaxNotch1Freq* {.importc: "MaxNotch1Freq".}: ptr SPFLOAT
    MinNotch1Freq* {.importc: "MinNotch1Freq".}: ptr SPFLOAT
    Notch_width* {.importc: "Notch_width".}: ptr SPFLOAT
    NotchFreq* {.importc: "NotchFreq".}: ptr SPFLOAT
    VibratoMode* {.importc: "VibratoMode".}: ptr SPFLOAT
    depth* {.importc: "depth".}: ptr SPFLOAT
    feedback_gain* {.importc: "feedback_gain".}: ptr SPFLOAT
    invert* {.importc: "invert".}: ptr SPFLOAT
    level* {.importc: "level".}: ptr SPFLOAT
    lfobpm* {.importc: "lfobpm".}: ptr SPFLOAT

proc phaser_create*(p: ptr ptr phaser): cint {.importc: "sp_phaser_create", header: "soundpipe.h".}
proc phaser_destroy*(p: ptr ptr phaser): cint {.importc: "sp_phaser_destroy", header: "soundpipe.h".}
proc phaser_init*(sp: ptr data; p: ptr phaser): cint {.importc: "sp_phaser_init", header: "soundpipe.h".}
proc phaser_compute*(sp: ptr data; p: ptr phaser; in1: ptr SPFLOAT; in2: ptr SPFLOAT; out1: ptr SPFLOAT; out2: ptr SPFLOAT): cint {.importc: "sp_phaser_compute", header: "soundpipe.h".}

type
  phasor* {.importc: "sp_phasor", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    phs* {.importc: "phs".}: SPFLOAT
    onedsr* {.importc: "onedsr".}: SPFLOAT

proc phasor_create*(p: ptr ptr phasor): cint {.importc: "sp_phasor_create", header: "soundpipe.h".}
proc phasor_destroy*(p: ptr ptr phasor): cint {.importc: "sp_phasor_destroy", header: "soundpipe.h".}
proc phasor_init*(sp: ptr data; p: ptr phasor; iphs: SPFLOAT): cint {.importc: "sp_phasor_init", header: "soundpipe.h".}
proc phasor_compute*(sp: ptr data; p: ptr phasor; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_phasor_compute", header: "soundpipe.h".}

type
  pinknoise* {.importc: "sp_pinknoise", header: "soundpipe.h", bycopy.} = object
    amp* {.importc: "amp".}: SPFLOAT
    newrand* {.importc: "newrand".}: cuint
    prevrand* {.importc: "prevrand".}: cuint
    k* {.importc: "k".}: cuint
    seed* {.importc: "seed".}: cuint
    total* {.importc: "total".}: cuint
    counter* {.importc: "counter".}: uint32_t
    dice* {.importc: "dice".}: array[7, cuint]

proc pinknoise_create*(p: ptr ptr pinknoise): cint {.importc: "sp_pinknoise_create", header: "soundpipe.h".}
proc pinknoise_destroy*(p: ptr ptr pinknoise): cint {.importc: "sp_pinknoise_destroy", header: "soundpipe.h".}
proc pinknoise_init*(sp: ptr data; p: ptr pinknoise): cint {.importc: "sp_pinknoise_init", header: "soundpipe.h".}
proc pinknoise_compute*(sp: ptr data; p: ptr pinknoise; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_pinknoise_compute", header: "soundpipe.h".}

type
  prop_event* {.importc: "prop_event", header: "soundpipe.h", bycopy.} = object

    `type`* {.importc: "type".}: char
    pos* {.importc: "pos".}: uint32_t
    val* {.importc: "val".}: uint32_t
    cons* {.importc: "cons".}: uint32_t

  prop_val* {.importc: "prop_val", header: "soundpipe.h", bycopy.} = object

    `type`* {.importc: "type".}: char
    ud* {.importc: "ud".}: pointer

  prop_entry* {.importc: "prop_entry", header: "soundpipe.h", bycopy.} = object
    val* {.importc: "val".}: prop_val
    next* {.importc: "next".}: ptr prop_entry

  prop_list* {.importc: "prop_list", header: "soundpipe.h", bycopy.} = object
    root* {.importc: "root".}: prop_entry
    last* {.importc: "last".}: ptr prop_entry
    size* {.importc: "size".}: uint32_t
    pos* {.importc: "pos".}: uint32_t
    top* {.importc: "top".}: ptr prop_list
    lvl* {.importc: "lvl".}: uint32_t

  prop_stack* {.importc: "prop_stack", header: "soundpipe.h", bycopy.} = object
    stack* {.importc: "stack".}: array[16, uint32_t]
    pos* {.importc: "pos".}: cint

  prop_data* {.importc: "prop_data", header: "soundpipe.h", bycopy.} = object
    mul* {.importc: "mul".}: uint32_t
    `div`* {.importc: "div".}: uint32_t
    tmp* {.importc: "tmp".}: uint32_t
    cons_mul* {.importc: "cons_mul".}: uint32_t
    cons_div* {.importc: "cons_div".}: uint32_t
    scale* {.importc: "scale".}: SPFLOAT
    mode* {.importc: "mode".}: cint
    pos* {.importc: "pos".}: uint32_t
    top* {.importc: "top".}: prop_list
    main* {.importc: "main".}: ptr prop_list
    mstack* {.importc: "mstack".}: prop_stack
    cstack* {.importc: "cstack".}: prop_stack

  prop* {.importc: "sp_prop", header: "soundpipe.h", bycopy.} = object
    prp* {.importc: "prp".}: ptr prop_data
    evt* {.importc: "evt".}: prop_event
    count* {.importc: "count".}: uint32_t
    bpm* {.importc: "bpm".}: SPFLOAT
    lbpm* {.importc: "lbpm".}: SPFLOAT

proc prop_create*(p: ptr ptr prop): cint {.importc: "sp_prop_create", header: "soundpipe.h".}
proc prop_destroy*(p: ptr ptr prop): cint {.importc: "sp_prop_destroy", header: "soundpipe.h".}
proc prop_reset*(sp: ptr data; p: ptr prop): cint {.importc: "sp_prop_reset", header: "soundpipe.h".}
proc prop_init*(sp: ptr data; p: ptr prop; str: cstring): cint {.importc: "sp_prop_init", header: "soundpipe.h".}
proc prop_compute*(sp: ptr data; p: ptr prop; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_prop_compute", header: "soundpipe.h".}

type
  pshift* {.importc: "sp_pshift", header: "soundpipe.h", bycopy.} = object
    faust* {.importc: "faust".}: pointer
    argpos* {.importc: "argpos".}: cint
    args* {.importc: "args".}: array[3, ptr SPFLOAT]
    shift* {.importc: "shift".}: ptr SPFLOAT
    window* {.importc: "window".}: ptr SPFLOAT
    xfade* {.importc: "xfade".}: ptr SPFLOAT

proc pshift_create*(p: ptr ptr pshift): cint {.importc: "sp_pshift_create", header: "soundpipe.h".}
proc pshift_destroy*(p: ptr ptr pshift): cint {.importc: "sp_pshift_destroy", header: "soundpipe.h".}
proc pshift_init*(sp: ptr data; p: ptr pshift): cint {.importc: "sp_pshift_init", header: "soundpipe.h".}
proc pshift_compute*(sp: ptr data; p: ptr pshift; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_pshift_compute", header: "soundpipe.h".}

type
  randmt* {.importc: "sp_randmt", header: "soundpipe.h", bycopy.} = object
    mti* {.importc: "mti".}: cint ##  do not change value 624
    mt* {.importc: "mt".}: array[624, uint32_t]

proc randmt_seed*(p: ptr randmt; initKey: ptr uint32_t; keyLength: uint32_t) {.importc: "sp_randmt_seed", header: "soundpipe.h".}
proc randmt_compute*(p: ptr randmt): uint32_t {.importc: "sp_randmt_compute", header: "soundpipe.h".}

type
  random* {.importc: "sp_random", header: "soundpipe.h", bycopy.} = object
    min* {.importc: "min".}: SPFLOAT
    max* {.importc: "max".}: SPFLOAT

proc random_create*(p: ptr ptr random): cint {.importc: "sp_random_create", header: "soundpipe.h".}
proc random_destroy*(p: ptr ptr random): cint {.importc: "sp_random_destroy", header: "soundpipe.h".}
proc random_init*(sp: ptr data; p: ptr random): cint {.importc: "sp_random_init", header: "soundpipe.h".}
proc random_compute*(sp: ptr data; p: ptr random; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_random_compute", header: "soundpipe.h".}

type
  randh* {.importc: "sp_randh", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    min* {.importc: "min".}: SPFLOAT
    max* {.importc: "max".}: SPFLOAT
    val* {.importc: "val".}: SPFLOAT
    counter* {.importc: "counter".}: uint32_t
    dur* {.importc: "dur".}: uint32_t

proc randh_create*(p: ptr ptr randh): cint {.importc: "sp_randh_create", header: "soundpipe.h".}
proc randh_destroy*(p: ptr ptr randh): cint {.importc: "sp_randh_destroy", header: "soundpipe.h".}
proc randh_init*(sp: ptr data; p: ptr randh): cint {.importc: "sp_randh_init", header: "soundpipe.h".}
proc randh_compute*(sp: ptr data; p: ptr randh; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_randh_compute", header: "soundpipe.h".}

type
  reverse* {.importc: "sp_reverse", header: "soundpipe.h", bycopy.} = object
    delay* {.importc: "delay".}: SPFLOAT
    bufpos* {.importc: "bufpos".}: uint32_t
    bufsize* {.importc: "bufsize".}: uint32_t
    buf* {.importc: "buf".}: ptr SPFLOAT

proc reverse_create*(p: ptr ptr reverse): cint {.importc: "sp_reverse_create", header: "soundpipe.h".}
proc reverse_destroy*(p: ptr ptr reverse): cint {.importc: "sp_reverse_destroy", header: "soundpipe.h".}
proc reverse_init*(sp: ptr data; p: ptr reverse; delay: SPFLOAT): cint {.importc: "sp_reverse_init", header: "soundpipe.h".}
proc reverse_compute*(sp: ptr data; p: ptr reverse; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_reverse_compute", header: "soundpipe.h".}

type
  rpt* {.importc: "sp_rpt", header: "soundpipe.h", bycopy.} = object
    playpos* {.importc: "playpos".}: uint32_t
    bufpos* {.importc: "bufpos".}: uint32_t
    running* {.importc: "running".}: cint
    count* {.importc: "count".}: cint
    reps* {.importc: "reps".}: cint
    sr* {.importc: "sr".}: SPFLOAT
    size* {.importc: "size".}: uint32_t
    bpm* {.importc: "bpm".}: SPFLOAT
    `div`* {.importc: "div".}: cint
    rep* {.importc: "rep".}: cint
    buf* {.importc: "buf".}: ptr SPFLOAT
    rc* {.importc: "rc".}: cint
    maxlen* {.importc: "maxlen".}: uint32_t

proc rpt_create*(p: ptr ptr rpt): cint {.importc: "sp_rpt_create", header: "soundpipe.h".}
proc rpt_destroy*(p: ptr ptr rpt): cint {.importc: "sp_rpt_destroy", header: "soundpipe.h".}
proc rpt_init*(sp: ptr data; p: ptr rpt; maxdur: SPFLOAT): cint {.importc: "sp_rpt_init", header: "soundpipe.h".}
proc rpt_compute*(sp: ptr data; p: ptr rpt; trig: ptr SPFLOAT; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_rpt_compute", header: "soundpipe.h".}

type
  saturator* {.importc: "sp_saturator", header: "soundpipe.h", bycopy.} = object
    drive* {.importc: "drive".}: SPFLOAT
    dcoffset* {.importc: "dcoffset".}: SPFLOAT
    dcblocker* {.importc: "dcblocker".}: array[2, array[7, SPFLOAT]]
    ai* {.importc: "ai".}: array[6, array[7, SPFLOAT]]
    aa* {.importc: "aa".}: array[6, array[7, SPFLOAT]]

proc saturator_create*(p: ptr ptr saturator): cint {.importc: "sp_saturator_create", header: "soundpipe.h".}
proc saturator_destroy*(p: ptr ptr saturator): cint {.importc: "sp_saturator_destroy", header: "soundpipe.h".}
proc saturator_init*(sp: ptr data; p: ptr saturator): cint {.importc: "sp_saturator_init", header: "soundpipe.h".}
proc saturator_compute*(sp: ptr data; p: ptr saturator; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_saturator_compute", header: "soundpipe.h".}

type
  samphold* {.importc: "sp_samphold", header: "soundpipe.h", bycopy.} = object
    val* {.importc: "val".}: SPFLOAT

proc samphold_create*(p: ptr ptr samphold): cint {.importc: "sp_samphold_create", header: "soundpipe.h".}
proc samphold_destroy*(p: ptr ptr samphold): cint {.importc: "sp_samphold_destroy", header: "soundpipe.h".}
proc samphold_init*(sp: ptr data; p: ptr samphold): cint {.importc: "sp_samphold_init", header: "soundpipe.h".}
proc samphold_compute*(sp: ptr data; p: ptr samphold; trig: ptr SPFLOAT; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_samphold_compute", header: "soundpipe.h".}

type
  scale* {.importc: "sp_scale", header: "soundpipe.h", bycopy.} = object
    min* {.importc: "min".}: SPFLOAT
    max* {.importc: "max".}: SPFLOAT

proc scale_create*(p: ptr ptr scale): cint {.importc: "sp_scale_create", header: "soundpipe.h".}
proc scale_destroy*(p: ptr ptr scale): cint {.importc: "sp_scale_destroy", header: "soundpipe.h".}
proc scale_init*(sp: ptr data; p: ptr scale): cint {.importc: "sp_scale_init", header: "soundpipe.h".}
proc scale_compute*(sp: ptr data; p: ptr scale; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_scale_compute", header: "soundpipe.h".}
proc gen_scrambler*(sp: ptr data; src: ptr ftbl; dest: ptr ptr ftbl): cint {.importc: "sp_gen_scrambler", header: "soundpipe.h".}

type
  sdelay* {.importc: "sp_sdelay", header: "soundpipe.h", bycopy.} = object
    size* {.importc: "size".}: cint
    pos* {.importc: "pos".}: cint
    buf* {.importc: "buf".}: ptr SPFLOAT

proc sdelay_create*(p: ptr ptr sdelay): cint {.importc: "sp_sdelay_create", header: "soundpipe.h".}
proc sdelay_destroy*(p: ptr ptr sdelay): cint {.importc: "sp_sdelay_destroy", header: "soundpipe.h".}
proc sdelay_init*(sp: ptr data; p: ptr sdelay; size: cint): cint {.importc: "sp_sdelay_init", header: "soundpipe.h".}
proc sdelay_compute*(sp: ptr data; p: ptr sdelay; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_sdelay_compute", header: "soundpipe.h".}

type
  slice* {.importc: "sp_slice", header: "soundpipe.h", bycopy.} = object
    vals* {.importc: "vals".}: ptr ftbl
    buf* {.importc: "buf".}: ptr ftbl
    id* {.importc: "id".}: uint32_t
    pos* {.importc: "pos".}: uint32_t
    nextpos* {.importc: "nextpos".}: uint32_t

proc slice_create*(p: ptr ptr slice): cint {.importc: "sp_slice_create", header: "soundpipe.h".}
proc slice_destroy*(p: ptr ptr slice): cint {.importc: "sp_slice_destroy", header: "soundpipe.h".}
proc slice_init*(sp: ptr data; p: ptr slice; vals: ptr ftbl; buf: ptr ftbl): cint {.importc: "sp_slice_init", header: "soundpipe.h".}
proc slice_compute*(sp: ptr data; p: ptr slice; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_slice_compute", header: "soundpipe.h".}

type
  smoothdelay* {.importc: "sp_smoothdelay", header: "soundpipe.h",
      bycopy.} = object
    del* {.importc: "del".}: SPFLOAT
    maxdel* {.importc: "maxdel".}: SPFLOAT
    pdel* {.importc: "pdel".}: SPFLOAT
    sr* {.importc: "sr".}: SPFLOAT
    feedback* {.importc: "feedback".}: SPFLOAT
    counter* {.importc: "counter".}: cint
    maxcount* {.importc: "maxcount".}: cint
    maxbuf* {.importc: "maxbuf".}: uint32_t
    buf1* {.importc: "buf1".}: ptr SPFLOAT
    bufpos1* {.importc: "bufpos1".}: uint32_t
    deltime1* {.importc: "deltime1".}: uint32_t
    buf2* {.importc: "buf2".}: ptr SPFLOAT
    bufpos2* {.importc: "bufpos2".}: uint32_t
    deltime2* {.importc: "deltime2".}: uint32_t
    curbuf* {.importc: "curbuf".}: cint

proc smoothdelay_create*(p: ptr ptr smoothdelay): cint {.importc: "sp_smoothdelay_create", header: "soundpipe.h".}
proc smoothdelay_destroy*(p: ptr ptr smoothdelay): cint {.importc: "sp_smoothdelay_destroy", header: "soundpipe.h".}
proc smoothdelay_init*(sp: ptr data; p: ptr smoothdelay; maxdel: SPFLOAT; interp: uint32_t): cint {.importc: "sp_smoothdelay_init", header: "soundpipe.h".}
proc smoothdelay_compute*(sp: ptr data; p: ptr smoothdelay; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_smoothdelay_compute", header: "soundpipe.h".}

type
  smoother* {.importc: "sp_smoother", header: "soundpipe.h", bycopy.} = object
    smooth* {.importc: "smooth".}: SPFLOAT
    a1* {.importc: "a1".}: SPFLOAT
    b0* {.importc: "b0".}: SPFLOAT
    y0* {.importc: "y0".}: SPFLOAT
    psmooth* {.importc: "psmooth".}: SPFLOAT
    onedsr* {.importc: "onedsr".}: SPFLOAT

proc smoother_create*(p: ptr ptr smoother): cint {.importc: "sp_smoother_create", header: "soundpipe.h".}
proc smoother_destroy*(p: ptr ptr smoother): cint {.importc: "sp_smoother_destroy", header: "soundpipe.h".}
proc smoother_init*(sp: ptr data; p: ptr smoother): cint {.importc: "sp_smoother_init", header: "soundpipe.h".}
proc smoother_compute*(sp: ptr data; p: ptr smoother; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_smoother_compute", header: "soundpipe.h".}
proc smoother_reset*(sp: ptr data; p: ptr smoother; `in`: ptr SPFLOAT): cint {.importc: "sp_smoother_reset", header: "soundpipe.h".}

type
  spa* {.importc: "sp_spa", header: "soundpipe.h", bycopy.} = object
    buf* {.importc: "buf".}: ptr SPFLOAT
    pos* {.importc: "pos".}: uint32_t
    bufsize* {.importc: "bufsize".}: uint32_t
    spa* {.importc: "spa".}: audio

proc spa_create*(p: ptr ptr spa): cint {.importc: "sp_spa_create", header: "soundpipe.h".}
proc spa_destroy*(p: ptr ptr spa): cint {.importc: "sp_spa_destroy", header: "soundpipe.h".}
proc spa_init*(sp: ptr data; p: ptr spa; filename: cstring): cint {.importc: "sp_spa_init", header: "soundpipe.h".}
proc spa_compute*(sp: ptr data; p: ptr spa; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_spa_compute", header: "soundpipe.h".}

type
  sparec* {.importc: "sp_sparec", header: "soundpipe.h", bycopy.} = object
    buf* {.importc: "buf".}: ptr SPFLOAT
    pos* {.importc: "pos".}: uint32_t
    bufsize* {.importc: "bufsize".}: uint32_t
    spa* {.importc: "spa".}: audio

proc sparec_create*(p: ptr ptr sparec): cint {.importc: "sp_sparec_create", header: "soundpipe.h".}
proc sparec_destroy*(p: ptr ptr sparec): cint {.importc: "sp_sparec_destroy", header: "soundpipe.h".}
proc sparec_init*(sp: ptr data; p: ptr sparec; filename: cstring): cint {.importc: "sp_sparec_init", header: "soundpipe.h".}
proc sparec_compute*(sp: ptr data; p: ptr sparec; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_sparec_compute", header: "soundpipe.h".}
proc sparec_close*(sp: ptr data; p: ptr sparec): cint {.importc: "sp_sparec_close", header: "soundpipe.h".}

type
  switch* {.importc: "sp_switch", header: "soundpipe.h", bycopy.} = object
    mode* {.importc: "mode".}: SPFLOAT

proc switch_create*(p: ptr ptr switch): cint {.importc: "sp_switch_create", header: "soundpipe.h".}
proc switch_destroy*(p: ptr ptr switch): cint {.importc: "sp_switch_destroy", header: "soundpipe.h".}
proc switch_init*(sp: ptr data; p: ptr switch): cint {.importc: "sp_switch_init", header: "soundpipe.h".}
proc switch_compute*(sp: ptr data; p: ptr switch; trig: ptr SPFLOAT; in1: ptr SPFLOAT; in2: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_switch_compute", header: "soundpipe.h".}

type
  tadsr* {.importc: "sp_tadsr", header: "soundpipe.h", bycopy.} = object
    value* {.importc: "value".}: SPFLOAT
    target* {.importc: "target".}: SPFLOAT
    rate* {.importc: "rate".}: SPFLOAT
    state* {.importc: "state".}: cint
    attackRate* {.importc: "attackRate".}: SPFLOAT
    decayRate* {.importc: "decayRate".}: SPFLOAT
    sustainLevel* {.importc: "sustainLevel".}: SPFLOAT
    releaseRate* {.importc: "releaseRate".}: SPFLOAT
    atk* {.importc: "atk".}: SPFLOAT
    rel* {.importc: "rel".}: SPFLOAT
    sus* {.importc: "sus".}: SPFLOAT
    dec* {.importc: "dec".}: SPFLOAT
    mode* {.importc: "mode".}: cint

proc tadsr_create*(p: ptr ptr tadsr): cint {.importc: "sp_tadsr_create", header: "soundpipe.h".}
proc tadsr_destroy*(p: ptr ptr tadsr): cint {.importc: "sp_tadsr_destroy", header: "soundpipe.h".}
proc tadsr_init*(sp: ptr data; p: ptr tadsr): cint {.importc: "sp_tadsr_init", header: "soundpipe.h".}
proc tadsr_compute*(sp: ptr data; p: ptr tadsr; trig: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tadsr_compute", header: "soundpipe.h".}
when not defined(SP_TALKBOX_BUFMAX):
  const
    SP_TALKBOX_BUFMAX* = 1600

type
  talkbox* {.importc: "sp_talkbox", header: "soundpipe.h", bycopy.} = object
    quality* {.importc: "quality".}: SPFLOAT
    d0* {.importc: "d0".}: SPFLOAT
    d1* {.importc: "d1".}: SPFLOAT
    d2* {.importc: "d2".}: SPFLOAT
    d3* {.importc: "d3".}: SPFLOAT
    d4* {.importc: "d4".}: SPFLOAT
    u0* {.importc: "u0".}: SPFLOAT
    u1* {.importc: "u1".}: SPFLOAT
    u2* {.importc: "u2".}: SPFLOAT
    u3* {.importc: "u3".}: SPFLOAT
    u4* {.importc: "u4".}: SPFLOAT
    FX* {.importc: "FX".}: SPFLOAT
    emphasis* {.importc: "emphasis".}: SPFLOAT
    car0* {.importc: "car0".}: array[SP_TALKBOX_BUFMAX, SPFLOAT]
    car1* {.importc: "car1".}: array[SP_TALKBOX_BUFMAX, SPFLOAT]
    window* {.importc: "window".}: array[SP_TALKBOX_BUFMAX, SPFLOAT]
    buf0* {.importc: "buf0".}: array[SP_TALKBOX_BUFMAX, SPFLOAT]
    buf1* {.importc: "buf1".}: array[SP_TALKBOX_BUFMAX, SPFLOAT]
    K* {.importc: "K".}: uint32_t
    N* {.importc: "N".}: uint32_t
    O* {.importc: "O".}: uint32_t
    pos* {.importc: "pos".}: uint32_t

proc talkbox_create*(p: ptr ptr talkbox): cint {.importc: "sp_talkbox_create", header: "soundpipe.h".}
proc talkbox_destroy*(p: ptr ptr talkbox): cint {.importc: "sp_talkbox_destroy", header: "soundpipe.h".}
proc talkbox_init*(sp: ptr data; p: ptr talkbox): cint {.importc: "sp_talkbox_init", header: "soundpipe.h".}
proc talkbox_compute*(sp: ptr data; p: ptr talkbox; src: ptr SPFLOAT; exc: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_talkbox_compute", header: "soundpipe.h".}

type
  tblrec* {.importc: "sp_tblrec", header: "soundpipe.h", bycopy.} = object
    ft* {.importc: "ft".}: ptr ftbl
    index* {.importc: "index".}: uint32_t
    record* {.importc: "record".}: cint

proc tblrec_create*(p: ptr ptr tblrec): cint {.importc: "sp_tblrec_create", header: "soundpipe.h".}
proc tblrec_destroy*(p: ptr ptr tblrec): cint {.importc: "sp_tblrec_destroy", header: "soundpipe.h".}
proc tblrec_init*(sp: ptr data; p: ptr tblrec; ft: ptr ftbl): cint {.importc: "sp_tblrec_init", header: "soundpipe.h".}
proc tblrec_compute*(sp: ptr data; p: ptr tblrec; `in`: ptr SPFLOAT; trig: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tblrec_compute", header: "soundpipe.h".}

type
  tdiv* {.importc: "sp_tdiv", header: "soundpipe.h", bycopy.} = object
    num* {.importc: "num".}: uint32_t
    counter* {.importc: "counter".}: uint32_t
    offset* {.importc: "offset".}: uint32_t

proc tdiv_create*(p: ptr ptr tdiv): cint {.importc: "sp_tdiv_create", header: "soundpipe.h".}
proc tdiv_destroy*(p: ptr ptr tdiv): cint {.importc: "sp_tdiv_destroy", header: "soundpipe.h".}
proc tdiv_init*(sp: ptr data; p: ptr tdiv): cint {.importc: "sp_tdiv_init", header: "soundpipe.h".}
proc tdiv_compute*(sp: ptr data; p: ptr tdiv; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tdiv_compute", header: "soundpipe.h".}

type
  tenv* {.importc: "sp_tenv", header: "soundpipe.h", bycopy.} = object
    pos* {.importc: "pos".}: uint32_t
    atk_end* {.importc: "atk_end".}: uint32_t
    rel_start* {.importc: "rel_start".}: uint32_t
    sr* {.importc: "sr".}: uint32_t
    totaldur* {.importc: "totaldur".}: uint32_t
    atk* {.importc: "atk".}: SPFLOAT
    rel* {.importc: "rel".}: SPFLOAT
    hold* {.importc: "hold".}: SPFLOAT
    atk_slp* {.importc: "atk_slp".}: SPFLOAT
    rel_slp* {.importc: "rel_slp".}: SPFLOAT
    last* {.importc: "last".}: SPFLOAT
    sigmode* {.importc: "sigmode".}: cint
    input* {.importc: "input".}: SPFLOAT
    started* {.importc: "started".}: cint

proc tenv_create*(p: ptr ptr tenv): cint {.importc: "sp_tenv_create", header: "soundpipe.h".}
proc tenv_destroy*(p: ptr ptr tenv): cint {.importc: "sp_tenv_destroy", header: "soundpipe.h".}
proc tenv_init*(sp: ptr data; p: ptr tenv): cint {.importc: "sp_tenv_init", header: "soundpipe.h".}
proc tenv_compute*(sp: ptr data; p: ptr tenv; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tenv_compute", header: "soundpipe.h".}

type
  tenv2* {.importc: "sp_tenv2", header: "soundpipe.h", bycopy.} = object
    state* {.importc: "state".}: cint
    atk* {.importc: "atk".}: SPFLOAT
    rel* {.importc: "rel".}: SPFLOAT
    totaltime* {.importc: "totaltime".}: uint32_t
    timer* {.importc: "timer".}: uint32_t
    slope* {.importc: "slope".}: SPFLOAT
    last* {.importc: "last".}: SPFLOAT

proc tenv2_create*(p: ptr ptr tenv2): cint {.importc: "sp_tenv2_create", header: "soundpipe.h".}
proc tenv2_destroy*(p: ptr ptr tenv2): cint {.importc: "sp_tenv2_destroy", header: "soundpipe.h".}
proc tenv2_init*(sp: ptr data; p: ptr tenv2): cint {.importc: "sp_tenv2_init", header: "soundpipe.h".}
proc tenv2_compute*(sp: ptr data; p: ptr tenv2; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tenv2_compute", header: "soundpipe.h".}

type
  tenvx* {.importc: "sp_tenvx", header: "soundpipe.h", bycopy.} = object
    atk* {.importc: "atk".}: SPFLOAT
    rel* {.importc: "rel".}: SPFLOAT
    hold* {.importc: "hold".}: SPFLOAT
    patk* {.importc: "patk".}: SPFLOAT
    prel* {.importc: "prel".}: SPFLOAT
    count* {.importc: "count".}: uint32_t
    a_a* {.importc: "a_a".}: SPFLOAT
    b_a* {.importc: "b_a".}: SPFLOAT
    a_r* {.importc: "a_r".}: SPFLOAT
    b_r* {.importc: "b_r".}: SPFLOAT
    y* {.importc: "y".}: SPFLOAT

proc tenvx_create*(p: ptr ptr tenvx): cint {.importc: "sp_tenvx_create", header: "soundpipe.h".}
proc tenvx_destroy*(p: ptr ptr tenvx): cint {.importc: "sp_tenvx_destroy", header: "soundpipe.h".}
proc tenvx_init*(sp: ptr data; p: ptr tenvx): cint {.importc: "sp_tenvx_init", header: "soundpipe.h".}
proc tenvx_compute*(sp: ptr data; p: ptr tenvx; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tenvx_compute", header: "soundpipe.h".}

type
  tgate* {.importc: "sp_tgate", header: "soundpipe.h", bycopy.} = object
    time* {.importc: "time".}: SPFLOAT
    timer* {.importc: "timer".}: uint32_t

proc tgate_create*(p: ptr ptr tgate): cint {.importc: "sp_tgate_create", header: "soundpipe.h".}
proc tgate_destroy*(p: ptr ptr tgate): cint {.importc: "sp_tgate_destroy", header: "soundpipe.h".}
proc tgate_init*(sp: ptr data; p: ptr tgate): cint {.importc: "sp_tgate_init", header: "soundpipe.h".}
proc tgate_compute*(sp: ptr data; p: ptr tgate; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tgate_compute", header: "soundpipe.h".}

type
  thresh* {.importc: "sp_thresh", header: "soundpipe.h", bycopy.} = object
    init* {.importc: "init".}: cint
    prev* {.importc: "prev".}: SPFLOAT
    thresh* {.importc: "thresh".}: SPFLOAT
    mode* {.importc: "mode".}: SPFLOAT

proc thresh_create*(p: ptr ptr thresh): cint {.importc: "sp_thresh_create", header: "soundpipe.h".}
proc thresh_destroy*(p: ptr ptr thresh): cint {.importc: "sp_thresh_destroy", header: "soundpipe.h".}
proc thresh_init*(sp: ptr data; p: ptr thresh): cint {.importc: "sp_thresh_init", header: "soundpipe.h".}
proc thresh_compute*(sp: ptr data; p: ptr thresh; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_thresh_compute", header: "soundpipe.h".}

type
  timer* {.importc: "sp_timer", header: "soundpipe.h", bycopy.} = object
    mode* {.importc: "mode".}: cint
    pos* {.importc: "pos".}: uint32_t
    time* {.importc: "time".}: SPFLOAT

proc timer_create*(p: ptr ptr timer): cint {.importc: "sp_timer_create", header: "soundpipe.h".}
proc timer_destroy*(p: ptr ptr timer): cint {.importc: "sp_timer_destroy", header: "soundpipe.h".}
proc timer_init*(sp: ptr data; p: ptr timer): cint {.importc: "sp_timer_init", header: "soundpipe.h".}
proc timer_compute*(sp: ptr data; p: ptr timer; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_timer_compute", header: "soundpipe.h".}

type
  tin* {.importc: "sp_tin", header: "soundpipe.h", bycopy.} = object
    fp* {.importc: "fp".}: ptr FILE
    val* {.importc: "val".}: SPFLOAT

proc tin_create*(p: ptr ptr tin): cint {.importc: "sp_tin_create", header: "soundpipe.h".}
proc tin_destroy*(p: ptr ptr tin): cint {.importc: "sp_tin_destroy", header: "soundpipe.h".}
proc tin_init*(sp: ptr data; p: ptr tin): cint {.importc: "sp_tin_init", header: "soundpipe.h".}
proc tin_compute*(sp: ptr data; p: ptr tin; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tin_compute", header: "soundpipe.h".}

type
  trand* {.importc: "sp_trand", header: "soundpipe.h", bycopy.} = object
    min* {.importc: "min".}: SPFLOAT
    max* {.importc: "max".}: SPFLOAT
    val* {.importc: "val".}: SPFLOAT

proc trand_create*(p: ptr ptr trand): cint {.importc: "sp_trand_create", header: "soundpipe.h".}
proc trand_destroy*(p: ptr ptr trand): cint {.importc: "sp_trand_destroy", header: "soundpipe.h".}
proc trand_init*(sp: ptr data; p: ptr trand): cint {.importc: "sp_trand_init", header: "soundpipe.h".}
proc trand_compute*(sp: ptr data; p: ptr trand; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_trand_compute", header: "soundpipe.h".}

type
  tseg* {.importc: "sp_tseg", header: "soundpipe.h", bycopy.} = object
    beg* {.importc: "beg".}: SPFLOAT
    dur* {.importc: "dur".}: SPFLOAT
    `end`* {.importc: "end".}: SPFLOAT
    steps* {.importc: "steps".}: uint32_t
    count* {.importc: "count".}: uint32_t
    val* {.importc: "val".}: SPFLOAT

    `type`* {.importc: "type".}: SPFLOAT
    slope* {.importc: "slope".}: SPFLOAT
    tdivnsteps* {.importc: "tdivnsteps".}: SPFLOAT

proc tseg_create*(p: ptr ptr tseg): cint {.importc: "sp_tseg_create", header: "soundpipe.h".}
proc tseg_destroy*(p: ptr ptr tseg): cint {.importc: "sp_tseg_destroy", header: "soundpipe.h".}
proc tseg_init*(sp: ptr data; p: ptr tseg; ibeg: SPFLOAT): cint {.importc: "sp_tseg_init", header: "soundpipe.h".}
proc tseg_compute*(sp: ptr data; p: ptr tseg; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tseg_compute", header: "soundpipe.h".}

type
  tseq* {.importc: "sp_tseq", header: "soundpipe.h", bycopy.} = object
    ft* {.importc: "ft".}: ptr ftbl
    val* {.importc: "val".}: SPFLOAT
    pos* {.importc: "pos".}: int32_t
    shuf* {.importc: "shuf".}: cint

proc tseq_create*(p: ptr ptr tseq): cint {.importc: "sp_tseq_create", header: "soundpipe.h".}
proc tseq_destroy*(p: ptr ptr tseq): cint {.importc: "sp_tseq_destroy", header: "soundpipe.h".}
proc tseq_init*(sp: ptr data; p: ptr tseq; ft: ptr ftbl): cint {.importc: "sp_tseq_init", header: "soundpipe.h".}
proc tseq_compute*(sp: ptr data; p: ptr tseq; trig: ptr SPFLOAT; val: ptr SPFLOAT): cint {.importc: "sp_tseq_compute", header: "soundpipe.h".}

type
  wpkorg35* {.importc: "sp_wpkorg35", header: "soundpipe.h", bycopy.} = object
    lpf1_a* {.importc: "lpf1_a".}: SPFLOAT ##  LPF1
    lpf1_z* {.importc: "lpf1_z".}: SPFLOAT ##  LPF2
    lpf2_a* {.importc: "lpf2_a".}: SPFLOAT
    lpf2_b* {.importc: "lpf2_b".}: SPFLOAT
    lpf2_z* {.importc: "lpf2_z".}: SPFLOAT ##  HPF
    hpf_a* {.importc: "hpf_a".}: SPFLOAT
    hpf_b* {.importc: "hpf_b".}: SPFLOAT
    hpf_z* {.importc: "hpf_z".}: SPFLOAT
    alpha* {.importc: "alpha".}: SPFLOAT
    cutoff* {.importc: "cutoff".}: SPFLOAT
    res* {.importc: "res".}: SPFLOAT
    saturation* {.importc: "saturation".}: SPFLOAT
    pcutoff* {.importc: "pcutoff".}: SPFLOAT
    pres* {.importc: "pres".}: SPFLOAT
    nonlinear* {.importc: "nonlinear".}: uint32_t

proc wpkorg35_create*(p: ptr ptr wpkorg35): cint {.importc: "sp_wpkorg35_create", header: "soundpipe.h".}
proc wpkorg35_destroy*(p: ptr ptr wpkorg35): cint {.importc: "sp_wpkorg35_destroy", header: "soundpipe.h".}
proc wpkorg35_init*(sp: ptr data; p: ptr wpkorg35): cint {.importc: "sp_wpkorg35_init", header: "soundpipe.h".}
proc wpkorg35_compute*(sp: ptr data; p: ptr wpkorg35; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_wpkorg35_compute", header: "soundpipe.h".}

type
  zitarev* {.importc: "sp_zitarev", header: "soundpipe.h", bycopy.} = object
    faust* {.importc: "faust".}: pointer
    argpos* {.importc: "argpos".}: cint
    args* {.importc: "args".}: array[11, ptr SPFLOAT]
    in_delay* {.importc: "in_delay".}: ptr SPFLOAT
    lf_x* {.importc: "lf_x".}: ptr SPFLOAT
    rt60_low* {.importc: "rt60_low".}: ptr SPFLOAT
    rt60_mid* {.importc: "rt60_mid".}: ptr SPFLOAT
    hf_damping* {.importc: "hf_damping".}: ptr SPFLOAT
    eq1_freq* {.importc: "eq1_freq".}: ptr SPFLOAT
    eq1_level* {.importc: "eq1_level".}: ptr SPFLOAT
    eq2_freq* {.importc: "eq2_freq".}: ptr SPFLOAT
    eq2_level* {.importc: "eq2_level".}: ptr SPFLOAT
    mix* {.importc: "mix".}: ptr SPFLOAT
    level* {.importc: "level".}: ptr SPFLOAT

proc zitarev_create*(p: ptr ptr zitarev): cint {.importc: "sp_zitarev_create", header: "soundpipe.h".}
proc zitarev_destroy*(p: ptr ptr zitarev): cint {.importc: "sp_zitarev_destroy", header: "soundpipe.h".}
proc zitarev_init*(sp: ptr data; p: ptr zitarev): cint {.importc: "sp_zitarev_init", header: "soundpipe.h".}
proc zitarev_compute*(sp: ptr data; p: ptr zitarev; in1: ptr SPFLOAT; in2: ptr SPFLOAT; out1: ptr SPFLOAT; out2: ptr SPFLOAT): cint {.importc: "sp_zitarev_compute", header: "soundpipe.h".}

type
  bitcrush* {.importc: "sp_bitcrush", header: "soundpipe.h", bycopy.} = object
    bitdepth* {.importc: "bitdepth".}: SPFLOAT
    srate* {.importc: "srate".}: SPFLOAT
    incr* {.importc: "incr".}: SPFLOAT
    index* {.importc: "index".}: SPFLOAT
    sample_index* {.importc: "sample_index".}: int32_t
    value* {.importc: "value".}: SPFLOAT

proc bitcrush_create*(p: ptr ptr bitcrush): cint {.importc: "sp_bitcrush_create", header: "soundpipe.h".}
proc bitcrush_destroy*(p: ptr ptr bitcrush): cint {.importc: "sp_bitcrush_destroy", header: "soundpipe.h".}
proc bitcrush_init*(sp: ptr data; p: ptr bitcrush): cint {.importc: "sp_bitcrush_init", header: "soundpipe.h".}
proc bitcrush_compute*(sp: ptr data; p: ptr bitcrush; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_bitcrush_compute", header: "soundpipe.h".}

type
  bigverb* {.importc: "sp_bigverb", header: "soundpipe.h", bycopy.} = object
    feedback* {.importc: "feedback".}: SPFLOAT
    lpfreq* {.importc: "lpfreq".}: SPFLOAT
    # bv* {.importc: "bv".}: ptr sk_bigverb
    bv* {.importc: "bv".}: pointer

proc bigverb_create*(p: ptr ptr bigverb): cint {.importc: "sp_bigverb_create", header: "soundpipe.h".}
proc bigverb_destroy*(p: ptr ptr bigverb): cint {.importc: "sp_bigverb_destroy", header: "soundpipe.h".}
proc bigverb_init*(sp: ptr data; p: ptr bigverb): cint {.importc: "sp_bigverb_init", header: "soundpipe.h".}
proc bigverb_compute*(sp: ptr data; p: ptr bigverb; in1: ptr SPFLOAT; in2: ptr SPFLOAT; out1: ptr SPFLOAT; out2: ptr SPFLOAT): cint {.importc: "sp_bigverb_compute", header: "soundpipe.h".}

type
  dcblocker* {.importc: "sp_dcblocker", header: "soundpipe.h", bycopy.} = object
    # dcblocker* {.importc: "dcblocker".}: ptr sk_dcblocker
    dcblocker* {.importc: "dcblocker".}: pointer

proc dcblocker_create*(p: ptr ptr dcblocker): cint {.importc: "sp_dcblocker_create", header: "soundpipe.h".}
proc dcblocker_destroy*(p: ptr ptr dcblocker): cint {.importc: "sp_dcblocker_destroy", header: "soundpipe.h".}
proc dcblocker_init*(sp: ptr data; p: ptr dcblocker): cint {.importc: "sp_dcblocker_init", header: "soundpipe.h".}
proc dcblocker_compute*(sp: ptr data; p: ptr dcblocker; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_dcblocker_compute", header: "soundpipe.h".}

type
  fmpair* {.importc: "sp_fmpair", header: "soundpipe.h", bycopy.} = object
    amp* {.importc: "amp".}: SPFLOAT
    freq* {.importc: "freq".}: SPFLOAT
    car* {.importc: "car".}: SPFLOAT
    `mod`* {.importc: "mod".}: SPFLOAT
    indx* {.importc: "indx".}: SPFLOAT
    # fmpair* {.importc: "fmpair".}: ptr sk_fmpair
    fmpair* {.importc: "fmpair".}: pointer

proc fmpair_create*(p: ptr ptr fmpair): cint {.importc: "sp_fmpair_create", header: "soundpipe.h".}
proc fmpair_destroy*(p: ptr ptr fmpair): cint {.importc: "sp_fmpair_destroy", header: "soundpipe.h".}
proc fmpair_init*(sp: ptr data; p: ptr fmpair; ft: ptr ftbl): cint {.importc: "sp_fmpair_init", header: "soundpipe.h".}
proc fmpair_compute*(sp: ptr data; p: ptr fmpair; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_fmpair_compute", header: "soundpipe.h".}

type
  rline* {.importc: "sp_rline", header: "soundpipe.h", bycopy.} = object
    min* {.importc: "min".}: SPFLOAT
    max* {.importc: "max".}: SPFLOAT
    cps* {.importc: "cps".}: SPFLOAT
    # rline* {.importc: "rline".}: ptr sk_rline
    rline* {.importc: "rline".}: pointer

proc rline_create*(p: ptr ptr rline): cint {.importc: "sp_rline_create", header: "soundpipe.h".}
proc rline_destroy*(p: ptr ptr rline): cint {.importc: "sp_rline_destroy", header: "soundpipe.h".}
proc rline_init*(sp: ptr data; p: ptr rline): cint {.importc: "sp_rline_init", header: "soundpipe.h".}
proc rline_compute*(sp: ptr data; p: ptr rline; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_rline_compute", header: "soundpipe.h".}

type
  vardelay* {.importc: "sp_vardelay", header: "soundpipe.h", bycopy.} = object
    del* {.importc: "del".}: SPFLOAT
    maxdel* {.importc: "maxdel".}: SPFLOAT
    feedback* {.importc: "feedback".}: SPFLOAT
    # v* {.importc: "v".}: ptr sk_vardelay
    v* {.importc: "v".}: pointer
    buf* {.importc: "buf".}: ptr SPFLOAT

proc vardelay_create*(p: ptr ptr vardelay): cint {.importc: "sp_vardelay_create", header: "soundpipe.h".}
proc vardelay_destroy*(p: ptr ptr vardelay): cint {.importc: "sp_vardelay_destroy", header: "soundpipe.h".}
proc vardelay_init*(sp: ptr data; p: ptr vardelay; maxdel: SPFLOAT): cint {.importc: "sp_vardelay_init", header: "soundpipe.h".}
proc vardelay_compute*(sp: ptr data; p: ptr vardelay; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_vardelay_compute", header: "soundpipe.h".}

type
  peakeq* {.importc: "sp_peakeq", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    bw* {.importc: "bw".}: SPFLOAT
    gain* {.importc: "gain".}: SPFLOAT
    # peakeq* {.importc: "peakeq".}: ptr sk_peakeq
    peakeq* {.importc: "peakeq".}: pointer

proc peakeq_create*(p: ptr ptr peakeq): cint {.importc: "sp_peakeq_create", header: "soundpipe.h".}
proc peakeq_destroy*(p: ptr ptr peakeq): cint {.importc: "sp_peakeq_destroy", header: "soundpipe.h".}
proc peakeq_init*(sp: ptr data; p: ptr peakeq): cint {.importc: "sp_peakeq_init", header: "soundpipe.h".}
proc peakeq_compute*(sp: ptr data; p: ptr peakeq; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_peakeq_compute", header: "soundpipe.h".}

type
  modalres* {.importc: "sp_modalres", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    q* {.importc: "q".}: SPFLOAT
    # modalres* {.importc: "modalres".}: ptr sk_modalres
    modalres* {.importc: "modalres".}: pointer

proc modalres_create*(p: ptr ptr modalres): cint {.importc: "sp_modalres_create", header: "soundpipe.h".}
proc modalres_destroy*(p: ptr ptr modalres): cint {.importc: "sp_modalres_destroy", header: "soundpipe.h".}
proc modalres_init*(sp: ptr data; p: ptr modalres): cint {.importc: "sp_modalres_init", header: "soundpipe.h".}
proc modalres_compute*(sp: ptr data; p: ptr modalres; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_modalres_compute", header: "soundpipe.h".}

type
  phasewarp* {.importc: "sp_phasewarp", header: "soundpipe.h", bycopy.} = object
    amount* {.importc: "amount".}: SPFLOAT

proc phasewarp_create*(p: ptr ptr phasewarp): cint {.importc: "sp_phasewarp_create", header: "soundpipe.h".}
proc phasewarp_destroy*(p: ptr ptr phasewarp): cint {.importc: "sp_phasewarp_destroy", header: "soundpipe.h".}
proc phasewarp_init*(sp: ptr data; p: ptr phasewarp): cint {.importc: "sp_phasewarp_init", header: "soundpipe.h".}
proc phasewarp_compute*(sp: ptr data; p: ptr phasewarp; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_phasewarp_compute", header: "soundpipe.h".}

type
  tread* {.importc: "sp_tread", header: "soundpipe.h", bycopy.} = object
    index* {.importc: "index".}: SPFLOAT
    offset* {.importc: "offset".}: SPFLOAT
    wrap* {.importc: "wrap".}: SPFLOAT
    mode* {.importc: "mode".}: cint
    mul* {.importc: "mul".}: SPFLOAT
    ft* {.importc: "ft".}: ptr ftbl

proc tread_create*(p: ptr ptr tread): cint {.importc: "sp_tread_create", header: "soundpipe.h".}
proc tread_destroy*(p: ptr ptr tread): cint {.importc: "sp_tread_destroy", header: "soundpipe.h".}
proc tread_init*(sp: ptr data; p: ptr tread; ft: ptr ftbl; mode: cint): cint {.importc: "sp_tread_init", header: "soundpipe.h".}
proc tread_compute*(sp: ptr data; p: ptr tread; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_tread_compute", header: "soundpipe.h".}

type
  oscmorph* {.importc: "sp_oscmorph", header: "soundpipe.h", bycopy.} = object
    freq* {.importc: "freq".}: SPFLOAT
    amp* {.importc: "amp".}: SPFLOAT
    iphs* {.importc: "iphs".}: SPFLOAT
    lphs* {.importc: "lphs".}: int32_t
    tbl* {.importc: "tbl".}: ptr ptr ftbl ##  magic constants
    nlb* {.importc: "nlb".}: uint32_t
    inlb* {.importc: "inlb".}: SPFLOAT
    mask* {.importc: "mask".}: uint32_t
    maxlens* {.importc: "maxlens".}: SPFLOAT
    inc* {.importc: "inc".}: cint
    wtpos* {.importc: "wtpos".}: SPFLOAT
    nft* {.importc: "nft".}: cint

proc oscmorph_create*(p: ptr ptr oscmorph): cint {.importc: "sp_oscmorph_create", header: "soundpipe.h".}
proc oscmorph_destroy*(p: ptr ptr oscmorph): cint {.importc: "sp_oscmorph_destroy", header: "soundpipe.h".}
proc oscmorph_init*(sp: ptr data; osc: ptr oscmorph; ft: ptr ptr ftbl; nft: cint; iphs: SPFLOAT): cint {.importc: "sp_oscmorph_init", header: "soundpipe.h".}
proc oscmorph_compute*(sp: ptr data; p: ptr oscmorph; `in`: ptr SPFLOAT; `out`: ptr SPFLOAT): cint {.importc: "sp_oscmorph_compute", header: "soundpipe.h".}

type
  fftw_real* = cdouble
  # rfftw_plan* = fftw_plan
  rfftw_plan* = pointer

type
  FFTFREQS* {.importc: "FFTFREQS", header: "soundpipe.h", bycopy.} = object
    size* {.importc: "size".}: cint
    s* {.importc: "s".}: ptr SPFLOAT
    c* {.importc: "c".}: ptr SPFLOAT

  FFTwrapper* {.importc: "FFTwrapper", header: "soundpipe.h", bycopy.} = object
    fftsize* {.importc: "fftsize".}: cint
    when defined(USE_FFTW3):
      tmpfftdata1* {.importc: "tmpfftdata1".}: ptr fftw_real
      tmpfftdata2* {.importc: "tmpfftdata2".}: ptr fftw_real
      planfftw* {.importc: "planfftw".}: rfftw_plan
      planfftw_inv* {.importc: "planfftw_inv".}: rfftw_plan
    else:
      fft* {.importc: "fft".}: kiss_fftr_cfg
      ifft* {.importc: "ifft".}: kiss_fftr_cfg
      tmp1* {.importc: "tmp1".}: ptr kiss_fft_cpx
      tmp2* {.importc: "tmp2".}: ptr kiss_fft_cpx

proc FFTwrapper_create*(fw: ptr ptr FFTwrapper; fftsize: cint) {.importc: "FFTwrapper_create", header: "soundpipe.h".}
proc FFTwrapper_destroy*(fw: ptr ptr FFTwrapper) {.importc: "FFTwrapper_destroy", header: "soundpipe.h".}
proc newFFTFREQS*(f: ptr FFTFREQS; size: cint) {.importc: "newFFTFREQS", header: "soundpipe.h".}
proc deleteFFTFREQS*(f: ptr FFTFREQS) {.importc: "deleteFFTFREQS", header: "soundpipe.h".}
proc smps2freqs*(ft: ptr FFTwrapper; smps: ptr SPFLOAT; freqs: ptr FFTFREQS) {.importc: "smps2freqs", header: "soundpipe.h".}
proc freqs2smps*(ft: ptr FFTwrapper; freqs: ptr FFTFREQS; smps: ptr SPFLOAT) {.importc: "freqs2smps", header: "soundpipe.h".}

type
  padsynth* {.importc: "sp_padsynth", header: "soundpipe.h", bycopy.} = object
    cps* {.importc: "cps".}: SPFLOAT
    bw* {.importc: "bw".}: SPFLOAT
    amps* {.importc: "amps".}: ptr ftbl

proc gen_padsynth*(sp: ptr data; ps: ptr ftbl; amps: ptr ftbl; f: SPFLOAT; bw: SPFLOAT): cint {.importc: "sp_gen_padsynth", header: "soundpipe.h".}
proc padsynth_profile*(fi: SPFLOAT; bwi: SPFLOAT): SPFLOAT {.importc: "sp_padsynth_profile", header: "soundpipe.h".}
proc padsynth_ifft*(N: cint; freq_amp: ptr SPFLOAT; freq_phase: ptr SPFLOAT; smp: ptr SPFLOAT): cint {.importc: "sp_padsynth_ifft", header: "soundpipe.h".}
proc padsynth_normalize*(N: cint; smp: ptr SPFLOAT): cint {.importc: "sp_padsynth_normalize", header: "soundpipe.h".}
##  This file is placed in the public domain

proc spa_open*(sp: ptr data; spa: ptr audio; name: cstring; mode: cint): cint {.importc: "spa_open", header: "soundpipe.h".}
proc spa_write_buf*(sp: ptr data; spa: ptr audio; buf: ptr SPFLOAT; size: uint32_t): csize_t {.importc: "spa_write_buf", header: "soundpipe.h".}
proc spa_read_buf*(sp: ptr data; spa: ptr audio; buf: ptr SPFLOAT; size: uint32_t): csize_t {.importc: "spa_read_buf", header: "soundpipe.h".}
proc spa_close*(spa: ptr audio): cint {.importc: "spa_close", header: "soundpipe.h".}
