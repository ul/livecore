/* This code is placed in the public domain. */

#include <string.h>
#include <stdlib.h>
#include "soundpipe.h"

int sp_reverse_create(sp_reverse **p)
{
    *p = malloc(sizeof(sp_reverse));
    return SP_OK;
}

int sp_reverse_destroy(sp_reverse **p)
{
    free((*p)->buf);
    free(*p);
    return SP_OK;
}

int sp_reverse_init(sp_data *sp, sp_reverse *p, SPFLOAT delay)
{
    size_t size = delay * sp->sr * sizeof(SPFLOAT) * 2;
    p->bufpos = 0;
    p->buf = calloc(1, size);
    p->bufsize = (uint32_t)size / sizeof(SPFLOAT);
    return SP_OK;
}

int sp_reverse_compute(sp_data *sp, sp_reverse *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT *buf = p->buf;
    *out = buf[p->bufpos];
    buf[(p->bufsize - 1) - p->bufpos] = *in;
    p->bufpos = (p->bufpos + 1) % p->bufsize;
    return SP_OK;
}
