/* This code is placed in the public domain. */

#include <stdlib.h>
#include "soundpipe.h"
#include "tangled/t_scale.h"

int sp_biscale_create(sp_biscale **p)
{
    *p = malloc(sizeof(sp_biscale));
    return SP_OK;
}

int sp_biscale_destroy(sp_biscale **p)
{
    free(*p);
    return SP_OK;
}

int sp_biscale_init(sp_data *sp, sp_biscale *p)
{
    p->min = 0;
    p->max = 1;
    return SP_OK;
}

int sp_biscale_compute(sp_data *sp, sp_biscale *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = sk_biscale(*in, p->min, p->max);
    return SP_OK;
}
