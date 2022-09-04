/* this file is placed in the public domain */

#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#define SK_RLINE_PRIV
#include "tangled/t_rline.h"
#include "soundpipe.h"

int sp_rline_create(sp_rline **p)
{
    *p = malloc(sizeof(sp_rline));
    return SP_OK;
}

int sp_rline_destroy(sp_rline **p)
{
    sp_rline *pp;
    pp = *p;
    free(pp->rline);
    free(*p);
    return SP_OK;
}

int sp_rline_init(sp_data *sp, sp_rline *p)
{
    p->rline = malloc(sizeof(sk_rline));
    sk_rline_init(p->rline, sp->sr, sp_rand(sp));
    p->min = 0;
    p->max = 1;
    p->cps = 3;

    sk_rline_min(p->rline, p->min);
    sk_rline_max(p->rline, p->max);
    sk_rline_rate(p->rline, p->cps);
    return SP_OK;
}

int sp_rline_compute(sp_data *sp, sp_rline *p,
                         SPFLOAT *in, SPFLOAT *out)
{
    sk_rline_min(p->rline, p->min);
    sk_rline_max(p->rline, p->max);
    sk_rline_rate(p->rline, p->cps);
    *out = sk_rline_tick(p->rline);
    return SP_OK;
}
