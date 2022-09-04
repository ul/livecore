/* This code is placed in the public domain. */

#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"

int sp_expon_create(sp_expon **p)
{
    *p = malloc(sizeof(sp_expon));
    return SP_OK;
}

int sp_expon_destroy(sp_expon **p)
{
    free(*p);
    return SP_OK;
}

static void expon_reinit(sp_data *sp, sp_expon *p)
{
    SPFLOAT onedsr;
    p->stime = 0;
    p->sdur = p->dur * sp->sr;
    onedsr = 1.0 / sp->sr;

    if ((p->a * p->b) > 0.0) {
        p->incr = pow((SPFLOAT)(p->b / p->a), onedsr / p->dur);
    } else {
        p->incr = 1;
        p->val = p->a;
    }

    p->val = p->a;
}

int sp_expon_init(sp_data *sp, sp_expon *p)
{
    p->a = 0.000001;
    p->b = 1;
    p->dur = 1;
    expon_reinit(sp, p);
    p->init = 1;
    return SP_OK;
}

int sp_expon_compute(sp_data *sp, sp_expon *p, SPFLOAT *in, SPFLOAT *out)
{
    if (*in) {
        expon_reinit(sp, p);
        p->init = 0;
    }

    if (p->init) {
        *out = 0;
        return SP_OK;
    }

    if (p->stime < p->sdur) {
        SPFLOAT val = p->val;
        p->val *= p->incr;
        p->stime++;
        *out = val;
    } else {
        *out = p->b;
    }

    return SP_OK;
}
