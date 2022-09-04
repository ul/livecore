#include <stdlib.h>
#include "math.h"
#include "soundpipe.h"

int sp_tread_create(sp_tread **p)
{
    *p = malloc(sizeof(sp_tread));
    return SP_OK;
}

int sp_tread_destroy(sp_tread **p)
{
    free(*p);
    return SP_OK;
}

int sp_tread_init(sp_data *sp, sp_tread *p, sp_ftbl *ft, int mode)
{
    p->ft = ft;
    p->mode = mode;
    p->offset = 0;
    p->wrap = 0;
    return SP_OK;
}

int sp_tread_compute(sp_data *sp, sp_tread *p, SPFLOAT *in, SPFLOAT *out)
{
    int ipos;
    SPFLOAT *tbl = p->ft->tbl;
    SPFLOAT mul, tmp, fpos;
    SPFLOAT x1, x2;
    size_t len;

    mul = 1;

    if (p->mode) {
        mul = p->ft->size;
    }else {
        p->mul = 1;
    }

    tmp = (p->index + p->offset) * mul;
    ipos = floor(tmp);
    fpos = tmp - ipos;

    len = p->ft->size;
    if (p->wrap) {
        int32_t mask = (int)p->ft->size - 1;
        if ((mask ? 0 : 1)) {
            while (ipos >= len) ipos -= len;
            while (ipos < 0) ipos += len;
        } else ipos &= mask;
    } else {
        if (ipos >= len) ipos = len - 1;
        else if (ipos < 0) ipos = 0;
    }

    x1 = tbl[ipos];
    x2 = tbl[ipos + 1];

    *out = x1 + (x2 - x1) * fpos;
    return SP_OK;
}
