{.compile: "cpu.c".}
{.compile: "kernel.c".}
{.compile: "fft.c".}

type
  mufft_cpx* {.final, pure.} = object
    r*: cfloat
    i*: cfloat

  mufft_plan_1d* {.final, pure, incompleteStruct.} = object

proc mufft_create_plan_1d_r2c*(N, flags: cuint): ptr mufft_plan_1d {.importc, header: "fft.h".}
proc mufft_create_plan_1d_c2r*(N, flags: cuint): ptr mufft_plan_1d {.importc, header: "fft.h".}
proc mufft_execute_plan_1d*(plan: ptr mufft_plan_1d, output: pointer, input: pointer) {.importc, header: "fft.h".}
proc mufft_free_plan_1d*(plan: ptr mufft_plan_1d) {.importc, header: "fft.h".}
