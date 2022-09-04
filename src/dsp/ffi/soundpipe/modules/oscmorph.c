/* This code is placed in the public domain */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#define MAXLEN    0x1000000L
#define PHASEMASK 0x0FFFFFFL

int sp_oscmorph_create(sp_oscmorph **p)
{
    *p = malloc(sizeof(sp_oscmorph));
    return SP_OK;
}

int sp_oscmorph_destroy(sp_oscmorph **p)
{
    free(*p);
    return SP_OK;
}

int sp_oscmorph_init(sp_data *sp,
                     sp_oscmorph *osc,
                     sp_ftbl **ft,
                     int nft,
                     SPFLOAT iphs)
{
    int i;
    uint32_t tmp;
    uint32_t prev;

    osc->freq = 440.0;
    osc->amp = 0.2;
    osc->tbl = ft;
    osc->iphs = fabs(iphs);
    osc->inc = 0;
    osc->lphs = ((int32_t)(osc->iphs * MAXLEN)) & PHASEMASK;
    osc->wtpos = 0.0;
    osc->nft = nft;
    prev = (uint32_t)ft[0]->size;

    for (i = 0; i < nft; i++) {
        if (prev != ft[i]->size) {
            fprintf(stderr, "sp_oscmorph: size mismatch\n");
            return SP_NOT_OK;
        }
        prev = (uint32_t)ft[i]->size;
    }

    /* set up constants */

    tmp = MAXLEN / ft[0]->size;

    osc->nlb = 0;
    while (tmp >>= 1) osc->nlb++;

    osc->mask = (1 << osc->nlb) - 1;
    osc->inlb = 1.0 / (1 << osc->nlb);
    osc->maxlens = 1.0 * MAXLEN / sp->sr;
    return SP_OK;
}

int sp_oscmorph_compute(sp_data *sp,
                        sp_oscmorph *osc,
                        SPFLOAT *in,
                        SPFLOAT *out)
{
    sp_ftbl *ftp1;
    SPFLOAT amp, cps, fract, v1, v2;
    SPFLOAT *ft1, *ft2;
    int32_t phs, pos;
    SPFLOAT findex;
    int index;
    SPFLOAT wtfrac;

    /* Use only the fractional part of the position or 1 */
    if (osc->wtpos > 1.0) {
        osc->wtpos -= (int)osc->wtpos;
    }

    findex = osc->wtpos * (osc->nft - 1);
    index = floor(findex);
    wtfrac = findex - index;

    amp = osc->amp;
    cps = osc->freq;
    phs = osc->lphs;
    ftp1 = osc->tbl[index];
    ft1 = osc->tbl[index]->tbl;

    if (index >= osc->nft - 1) {
        ft2 = ft1;
    } else {
        ft2 = osc->tbl[index + 1]->tbl;
    }

    osc->inc = (int32_t)lrintf(cps * osc->maxlens);

    fract = (phs & osc->mask) * osc->inlb;

    pos = phs >> osc->nlb;

    v1 = (1 - wtfrac) * ft1[pos] + wtfrac * ft2[pos];
    v2 = (1 - wtfrac) *
        ft1[(pos + 1) % ftp1->size] +
        wtfrac *
        ft2[(pos + 1) % ftp1->size];

    *out = (v1 + (v2 - v1) * fract) * amp;

    phs += osc->inc;
    phs &= PHASEMASK;

    osc->lphs = phs;
    return SP_OK;
}
