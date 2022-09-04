#ifndef SK_PHASOR_H
typedef struct sk_phasor sk_phasor;
#endif

typedef struct sp_phasor{
    sk_phasor *phasor;
    SPFLOAT freq;
} sp_phasor;

int sp_phasor_create(sp_phasor **p);
int sp_phasor_destroy(sp_phasor **p);
int sp_phasor_init(sp_data *sp, sp_phasor *p, SPFLOAT iphs);
int sp_phasor_compute(sp_data *sp, sp_phasor *p, SPFLOAT *in, SPFLOAT *out);
int sp_phasor_reset(sp_data *sp, sp_phasor *p, SPFLOAT iphs);
