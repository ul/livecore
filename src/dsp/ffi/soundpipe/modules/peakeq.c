/* this file is placed in the public domain */

#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#define SK_PEAKEQ_PRIV
#include "tangled/t_peakeq.h"
#include "soundpipe.h"

int sp_peakeq_create(sp_peakeq **p)
{
    *p = malloc(sizeof(sp_peakeq));
    return SP_OK;
}

int sp_peakeq_destroy(sp_peakeq **p)
{
    sp_peakeq *pp;
    pp = *p;
    free(pp->peakeq);
    free(*p);
    return SP_OK;
}

int sp_peakeq_init(sp_data *sp, sp_peakeq *p)
{
    p->peakeq = malloc(sizeof(sk_peakeq));
    sk_peakeq_init(p->peakeq, sp->sr);
    p->freq = 1000;
    p->bw = 125;
    p->gain  = 2;

    sk_peakeq_freq(p->peakeq, p->freq);
    sk_peakeq_bandwidth(p->peakeq, p->bw);
    sk_peakeq_gain(p->peakeq, p->gain);
    return SP_OK;
}

int sp_peakeq_compute(sp_data *sp, sp_peakeq *p,
                         SPFLOAT *in, SPFLOAT *out)
{
    sk_peakeq_freq(p->peakeq, p->freq);
    sk_peakeq_bandwidth(p->peakeq, p->bw);
    sk_peakeq_gain(p->peakeq, p->gain);
    *out = sk_peakeq_tick(p->peakeq, *in);
    return SP_OK;
}
