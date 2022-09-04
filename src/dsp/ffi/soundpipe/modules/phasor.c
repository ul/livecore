/*
 * Phasor
 *
 * A phasor produces a non-bandlimited sawtooth wave,
 * normalized to be in range 0-1. Phasors are most
 * frequently used to create table-lookup oscillators.
 *
 * This code is placed in the public domain.
 */

#include <stdlib.h>
#define SK_PHASOR_PRIV
#include "tangled/t_phasor.h"
#include "soundpipe.h"

int sp_phasor_create(sp_phasor **p)
{
    *p = malloc(sizeof(sp_phasor));
    return SP_OK;
}

int sp_phasor_destroy(sp_phasor **p)
{
    sp_phasor *pp;
    pp = *p;
    free(pp->phasor);
    free(*p);
    return SP_OK;
}

int sp_phasor_init(sp_data *sp, sp_phasor *p, SPFLOAT iphs)
{
    p->phasor = malloc(sizeof(sk_phasor));
    p->freq = 440;
    sk_phasor_init(p->phasor, sp->sr, iphs);
    sk_phasor_freq(p->phasor, p->freq);
    return SP_OK;
}

int sp_phasor_compute(sp_data *sp, sp_phasor *p, SPFLOAT *in, SPFLOAT *out)
{
    sk_phasor_freq(p->phasor, p->freq);
    *out = sk_phasor_tick(p->phasor);
    return SP_OK;
}

int sp_phasor_reset(sp_data *sp, sp_phasor *p, SPFLOAT iphs)
{
    sk_phasor_reset(p->phasor, iphs);
    return SP_OK;
}
