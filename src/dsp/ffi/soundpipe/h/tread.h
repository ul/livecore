typedef struct {
    SPFLOAT index, offset, wrap;
    int mode;
    SPFLOAT mul;
    sp_ftbl *ft;
} sp_tread;

int sp_tread_create(sp_tread **p);
int sp_tread_destroy(sp_tread **p);
int sp_tread_init(sp_data *sp, sp_tread *p, sp_ftbl *ft, int mode);
int sp_tread_compute(sp_data *sp, sp_tread *p, SPFLOAT *in, SPFLOAT *out);
