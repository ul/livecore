/* This code is placed in the public domain. */

#include <stdlib.h>
#include "soundpipe.h"
#include "tangled/t_scale.h"

int sp_scale_create(sp_scale **p)
{
    *p = malloc(sizeof(sp_scale));
    return SP_OK;
}

int sp_scale_destroy(sp_scale **p)
{
    free(*p);
    return SP_OK;
}

int sp_scale_init(sp_data *sp, sp_scale *p)
{
    p->min = -1;
    p->max = 1;
    return SP_OK;
}

int sp_scale_compute(sp_data *sp, sp_scale *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = sk_scale(*in, p->min, p->max);
    return SP_OK;
}
