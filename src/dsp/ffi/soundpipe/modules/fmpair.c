/* this file is placed in the public domain */

#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#define SK_FMPAIR_PRIV
#include "tangled/t_fmpair.h"
#include "soundpipe.h"

int sp_fmpair_create(sp_fmpair **p)
{
    *p = malloc(sizeof(sp_fmpair));
    return SP_OK;
}

int sp_fmpair_destroy(sp_fmpair **p)
{
    sp_fmpair *pp;
    pp = *p;
    free(pp->fmpair);
    free(*p);
    return SP_OK;
}

int sp_fmpair_init(sp_data *sp, sp_fmpair *p, sp_ftbl *ft)
{
    p->fmpair = malloc(sizeof(sk_fmpair));
    sk_fmpair_init(p->fmpair, sp->sr,
                   ft->tbl, ft->size, 0,
                   ft->tbl, ft->size, 0);

    p->mod = 1.0;
    p->car = 1.0;
    p->indx = 1.0;
    p->amp = 0.4;
    p->freq = 440;

    sk_fmpair_freq(p->fmpair, p->freq);
    sk_fmpair_modulator(p->fmpair, p->mod);
    sk_fmpair_carrier(p->fmpair, p->car);
    sk_fmpair_modindex(p->fmpair, p->indx);
    return SP_OK;
}

int sp_fmpair_compute(sp_data *sp, sp_fmpair *p,
                      SPFLOAT *in, SPFLOAT *out)
{
    sk_fmpair_freq(p->fmpair, p->freq);
    sk_fmpair_modulator(p->fmpair, p->mod);
    sk_fmpair_carrier(p->fmpair, p->car);
    sk_fmpair_modindex(p->fmpair, p->indx);
    *out = sk_fmpair_tick(p->fmpair) * p->amp;
    return SP_OK;
}
