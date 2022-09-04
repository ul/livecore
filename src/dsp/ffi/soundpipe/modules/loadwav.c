/* This code is placed in the public domain. */

#include <stdlib.h>
#include "soundpipe.h"
#include "lib/dr_wav/sp_dr_wav.h"

int sp_ftbl_loadwav(sp_data *sp, sp_ftbl **ft, const char *filename)
{
    drwav *wav;
    size_t size;
    SPFLOAT *tbl;
    sp_ftbl *ftp;

    wav = calloc(1, sp_drwav_size());
    if (!sp_drwav_init_file(wav, filename)) return SP_NOT_OK;

    size = sp_drwav_sampcount(wav);

    sp_ftbl_create(sp, ft, size);

    ftp = *ft;

    tbl = ftp->tbl;

    sp_drwav_read_f32(wav, size, tbl);
    sp_drwav_uninit(wav);
    free(wav);
    return SP_OK;
}
