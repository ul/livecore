/* This code is placed in the public domain. */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"
#include "openlpc.h"

int sp_lpc_create(sp_lpc **lpc)
{
    *lpc = malloc(sizeof(sp_lpc));
    return SP_OK;
}

int sp_lpc_destroy(sp_lpc **lpc)
{
    sp_lpc *plpc;
    plpc = *lpc;
    free(plpc->e);
    free(plpc->d);
    free(plpc->out);
    free(plpc->in);
    free(*lpc);
    return SP_OK;
}

int sp_lpc_init(sp_data *sp, sp_lpc *lpc, int framesize)
{
    int i;
    lpc->counter = 0;
    lpc->clock = 0;
    lpc->block = 4;
    lpc->samp = 0;
    lpc->mode = 0;
    lpc->framesize = framesize;
    openlpc_sr(sp->sr / lpc->block);

    lpc->d = calloc(1, openlpc_get_decoder_state_size());
    lpc->e = calloc(1, openlpc_get_encoder_state_size());

    lpc->in = calloc(1, sizeof(short) * framesize);
    lpc->out = calloc(1, sizeof(short) * framesize);

    init_openlpc_decoder_state(lpc->d, framesize);
    init_openlpc_encoder_state(lpc->e, framesize);

    for (i = 0; i < framesize; i++) {
        lpc->in[i] = 0;
        lpc->out[i] = 0;
        if(i < 7) lpc->data[i] = 0;
    }
    return SP_OK;
}

int sp_lpc_compute(sp_data *sp, sp_lpc *lpc, SPFLOAT *in, SPFLOAT *out)
{
    int i;

    if (lpc->clock == 0) {
        if (lpc->counter == 0) {
            if (lpc->mode == 0) {
                openlpc_encode(lpc->in, lpc->data, lpc->e);
            } else {
                for (i = 0; i < 7; i++) {
                    lpc->y[i] =
                        lpc->smooth*lpc->y[i] +
                        (1-lpc->smooth)*lpc->ft->tbl[i];
                    lpc->data[i] = 255 * lpc->y[i];
                }
            }
            openlpc_decode(sp, lpc->data, lpc->out, lpc->d);
        }

        if (lpc->mode == 0) lpc->in[lpc->counter] = *in * 32767;
        lpc->samp = lpc->out[lpc->counter] / 32767.0;

        lpc->counter = (lpc->counter + 1) % lpc->framesize;
    }


    lpc->clock = (lpc->clock + 1) % lpc->block;
    *out = lpc->samp;

    return SP_OK;
}

int sp_lpc_synth(sp_data *sp, sp_lpc *lpc, sp_ftbl *ft)
{
    int i;
    int sr;
    sr = sp->sr;

    sr = sr / 4;
    sr = sr / lpc->framesize;
    lpc->ft = ft;
    lpc->mode = 1;
    for (i = 0; i < 7; i++) lpc->y[i] = 0;
    lpc->smooth = exp(-1.0 / (0.01 * sr));
    return SP_OK;
}
