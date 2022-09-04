/* this file is placed in the public domain */

#include <stdlib.h>
#include "tangled/t_bigverb.h"
#include "soundpipe.h"

int sp_bigverb_create(sp_bigverb **p)
{
    *p = malloc(sizeof(sp_bigverb));
    return SP_OK;
}

int sp_bigverb_destroy(sp_bigverb **p)
{
    sp_bigverb *bv;
    bv = *p;
    sk_bigverb_del(bv->bv);
    free(*p);
    return SP_OK;
}

int sp_bigverb_init(sp_data *sp, sp_bigverb *p)
{
    p->feedback = 0.97;
    p->lpfreq = 10000;
    p->bv = sk_bigverb_new(sp->sr);

    sk_bigverb_size(p->bv, p->feedback);
    sk_bigverb_cutoff(p->bv, p->lpfreq);
    return SP_OK;
}

int sp_bigverb_compute(sp_data *sp,
                       sp_bigverb *p,
                       SPFLOAT *in1,
                       SPFLOAT *in2,
                       SPFLOAT *out1,
                       SPFLOAT *out2)
{
    sk_bigverb_size(p->bv, p->feedback);
    sk_bigverb_cutoff(p->bv, p->lpfreq);
    sk_bigverb_tick(p->bv, *in1, *in2, out1, out2);
    return SP_OK;
}
