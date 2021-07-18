{.compile: "kiss_fftr.c".}

type
  kiss_fft_scalar* = cfloat

  kiss_fft_cpx* {.final, pure.} = object
    r*: kiss_fft_scalar
    i*: kiss_fft_scalar

  kiss_fftr_state* {.final, pure, incompleteStruct.} = object

  kiss_fftr_cfg* = ptr kiss_fftr_state

proc kiss_fftr_alloc*(nfft: cint; inverse_fft: cint; mem: pointer; lenmem: ptr csize_t): kiss_fftr_cfg {.importc, header: "kiss_fftr.h".}
proc kiss_fftr*(cfg: kiss_fftr_cfg; timedata: ptr kiss_fft_scalar; freqdata: ptr kiss_fft_cpx) {.importc, header: "kiss_fftr.h".}
proc kiss_fftri*(cfg: kiss_fftr_cfg; freqdata: ptr kiss_fft_cpx; timedata: ptr kiss_fft_scalar) {.importc, header: "kiss_fftr.h".}
proc kiss_fftr_free*(p: pointer) {.importc: "free", header: "<stdlib.h>".}
