#ifndef SK_FMPAIR_H
typedef struct sk_fmpair sk_fmpair;
#endif

typedef struct {
    SPFLOAT amp, freq, car, mod, indx;
    sk_fmpair *fmpair;
} sp_fmpair;

int sp_fmpair_create(sp_fmpair **p);
int sp_fmpair_destroy(sp_fmpair **p);
int sp_fmpair_init(sp_data *sp, sp_fmpair *p, sp_ftbl *ft);
int sp_fmpair_compute(sp_data *sp, sp_fmpair *p,
                      SPFLOAT *in, SPFLOAT *out);
