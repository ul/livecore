typedef struct{
    SPFLOAT smooth;
    SPFLOAT a1, b0, y0, psmooth;
    SPFLOAT onedsr;
}sp_smoother;

int sp_smoother_create(sp_smoother **p);
int sp_smoother_destroy(sp_smoother **p);
int sp_smoother_init(sp_data *sp, sp_smoother *p);
int sp_smoother_compute(sp_data *sp, sp_smoother *p, SPFLOAT *in, SPFLOAT *out);
int sp_smoother_reset(sp_data *sp, sp_smoother *p, SPFLOAT *in);
