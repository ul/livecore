/* This code is placed in the public domain. */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_bitcrush_create(sp_bitcrush **p)
{
    *p = malloc(sizeof(sp_bitcrush));
    return SP_OK;
}

int sp_bitcrush_destroy(sp_bitcrush **p)
{
    free(*p);
    return SP_OK;
}

int sp_bitcrush_init(sp_data *sp, sp_bitcrush *p)
{
    p->bitdepth = 8;
    p->srate = 10000;

    p->incr = 1000;
    p->sample_index = 0;
    p->index = 0.0;
    p->value = 0.0;
    return SP_OK;
}

int sp_bitcrush_compute(sp_data *sp, sp_bitcrush *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT bits = pow(2, floor(p->bitdepth));
    SPFLOAT foldamt = sp->sr / p->srate;
    SPFLOAT sig;
    *out = *in * 65536.0;
    *out += 32768;
    *out *= (bits / 65536.0);
    *out = floor(*out);
    *out = *out * (65536.0 / bits) - 32768;
    sig = *out;
    p->incr = foldamt;

    /* apply downsampling */
    if (p->index < (SPFLOAT)p->sample_index) {
        p->index += p->incr;
        p->value = sig;
    }

    *out = p->value;

    p->sample_index++;

    *out /= 65536.0;
    return SP_OK;
}
