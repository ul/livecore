/* this file is placed in the public domain */

#include <math.h>
#include <stdlib.h>
#define SK_VARDELAY_PRIV
#include "tangled/t_vardelay.h"
#include "soundpipe.h"

int sp_vardelay_create(sp_vardelay **p)
{
    *p = malloc(sizeof(sp_vardelay));
    return SP_OK;
}

int sp_vardelay_destroy(sp_vardelay **p)
{
    sp_vardelay *pp;
    pp = *p;
    free(pp->v);
    free(pp->buf);
    free(*p);
    return SP_OK;
}

int sp_vardelay_init(sp_data *sp, sp_vardelay *p, SPFLOAT maxdel)
{
    unsigned long sz;

    sz = floor(maxdel * sp->sr) + 1;
    p->v = malloc(sizeof(sk_vardelay));
    p->buf = calloc(1, sz * sizeof(SPFLOAT));

    sk_vardelay_init(p->v, sp->sr, p->buf, sz);
    p->feedback = 0;
    p->del = maxdel * 0.5;

    sk_vardelay_delay(p->v, p->del);
    sk_vardelay_feedback(p->v, p->feedback);
    return SP_OK;
}

int sp_vardelay_compute(sp_data *sp,
                       sp_vardelay *p,
                       SPFLOAT *in,
                       SPFLOAT *out)
{
    sk_vardelay_delay(p->v, p->del);
    sk_vardelay_feedback(p->v, p->feedback);
    *out = sk_vardelay_tick(p->v, *in);
    return SP_OK;
}
