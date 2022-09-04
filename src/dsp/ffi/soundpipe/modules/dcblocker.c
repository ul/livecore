/* this file is placed in the public domain */

#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#define SK_DCBLOCKER_PRIV
#include "tangled/t_dcblocker.h"
#include "soundpipe.h"

int sp_dcblocker_create(sp_dcblocker **p)
{
    *p = malloc(sizeof(sp_dcblocker));
    return SP_OK;
}

int sp_dcblocker_destroy(sp_dcblocker **p)
{
    sp_dcblocker *pp;
    pp = *p;
    free(pp->dcblocker);
    free(*p);
    return SP_OK;
}

int sp_dcblocker_init(sp_data *sp, sp_dcblocker *p)
{
    p->dcblocker = malloc(sizeof(sk_dcblocker));
    sk_dcblocker_init(p->dcblocker);
    return SP_OK;
}

int sp_dcblocker_compute(sp_data *sp, sp_dcblocker *p,
                         SPFLOAT *in, SPFLOAT *out)
{
    *out = sk_dcblocker_tick(p->dcblocker, *in);
    return SP_OK;
}
