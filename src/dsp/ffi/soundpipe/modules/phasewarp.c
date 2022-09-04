/* this file is placed in the public domain */

#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include "tangled/t_phasewarp.h"
#include "soundpipe.h"

int sp_phasewarp_create(sp_phasewarp **p)
{
    *p = malloc(sizeof(sp_phasewarp));
    return SP_OK;
}

int sp_phasewarp_destroy(sp_phasewarp **p)
{
    free(*p);
    return SP_OK;
}

int sp_phasewarp_init(sp_data *sp, sp_phasewarp *p)
{
    return SP_OK;
}

int sp_phasewarp_compute(sp_data *sp, sp_phasewarp *p,
                         SPFLOAT *in, SPFLOAT *out)
{
    *out = sk_phasewarp_tick(*in, p->amount);
    return SP_OK;
}
