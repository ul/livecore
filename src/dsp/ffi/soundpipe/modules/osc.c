/* this file is placed in the public domain */

#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#define SK_OSC_PRIV
#include "tangled/t_osc.h"
#include "soundpipe.h"

int sp_osc_create(sp_osc **osc)
{
    *osc = malloc(sizeof(sp_osc));
    return SP_OK;
}

int sp_osc_destroy(sp_osc **osc)
{
    sp_osc *o;
    o = *osc;
    free(o->osc);
    free(*osc);
    return SP_OK;
}

int sp_osc_init(sp_data *sp, sp_osc *osc, sp_ftbl *ft, SPFLOAT iphs)
{
    osc->freq = 440.0;
    osc->amp = 0.2;
    osc->osc = malloc(sizeof(sk_osc));
    sk_osc_init(osc->osc, sp->sr, ft->tbl, ft->size, iphs);
    return SP_OK;
}

int sp_osc_compute(sp_data *sp, sp_osc *osc, SPFLOAT *in, SPFLOAT *out)
{
    sk_osc_freq(osc->osc, osc->freq);
    sk_osc_amp(osc->osc, osc->amp);
    *out = sk_osc_tick(osc->osc);
    return SP_OK;
}
