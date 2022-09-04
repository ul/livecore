/* this file is placed in the public domain */

#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#define SK_MODALRES_PRIV
#include "tangled/t_modalres.h"
#include "soundpipe.h"

int sp_modalres_create(sp_modalres **p)
{
    *p = malloc(sizeof(sp_modalres));
    return SP_OK;
}

int sp_modalres_destroy(sp_modalres **p)
{
    sp_modalres *pp;
    pp = *p;
    free(pp->modalres);
    free(*p);
    return SP_OK;
}

int sp_modalres_init(sp_data *sp, sp_modalres *p)
{
    p->modalres = malloc(sizeof(sk_modalres));
    sk_modalres_init(p->modalres, sp->sr);
    p->freq = 500;
    p->q = 50;

    sk_modalres_freq(p->modalres, p->freq);
    sk_modalres_q(p->modalres, p->q);
    return SP_OK;
}

int sp_modalres_compute(sp_data *sp, sp_modalres *p,
                         SPFLOAT *in, SPFLOAT *out)
{
    sk_modalres_freq(p->modalres, p->freq);
    sk_modalres_q(p->modalres, p->q);
    *out = sk_modalres_tick(p->modalres, *in);
    return SP_OK;
}
