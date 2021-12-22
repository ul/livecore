{.compile: "cpu.c".}
{.compile: "kernel.c".}
{.compile: "fft.c".}

type
  mufft_cpx* {.final, pure.} = object
    r*: cfloat
    i*: cfloat

  mufft_plan_1d* {.final, pure, incompleteStruct.} = object
  mufft_plan_conv* {.final, pure, incompleteStruct.} = object

proc mufft_create_plan_1d_r2c*(N, flags: cuint): ptr mufft_plan_1d {.importc, header: "fft.h".}
proc mufft_create_plan_1d_c2r*(N, flags: cuint): ptr mufft_plan_1d {.importc, header: "fft.h".}
proc mufft_execute_plan_1d*(plan: ptr mufft_plan_1d; output, input: pointer) {.importc, header: "fft.h".}
proc mufft_free_plan_1d*(plan: ptr mufft_plan_1d) {.importc, header: "fft.h".}
proc mufft_create_plan_conv*(N, flags, conv_method: cuint): ptr mufft_plan_conv {.importc, header: "fft.h".}
proc mufft_conv_get_transformed_block_size*(plan: ptr mufft_plan_conv): csize_t {.importc, header: "fft.h".}
proc mufft_execute_conv_input*(plan: ptr mufft_plan_conv, block_num: cuint; output, input: pointer) {.importc, header: "fft.h".}
proc mufft_execute_conv_output*(plan: ptr mufft_plan_conv; output, input_first, input_second: pointer) {.importc, header: "fft.h".}
proc mufft_free_plan_conv*(plan: ptr mufft_plan_1d) {.importc, header: "fft.h".}

proc `*=`*(a: var mufft_cpx, b: cfloat) {.inline.} =
  a.r *= b
  a.i *= b

proc `*`*(a, b: mufft_cpx): mufft_cpx {.inline.} =
  result.r = a.r * b.r - a.i * b.i
  result.i = a.r * b.i + b.r * a.i

proc `+=`*(a: var mufft_cpx, b: mufft_cpx) {.inline.} =
  a.r += b.r
  a.i += b.i
