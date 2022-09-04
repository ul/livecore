#ifndef SK_PHASEWARP_H
typedef struct sk_phasewarp sk_phasewarp;
#endif

typedef struct {
    SPFLOAT amount;
} sp_phasewarp;

int sp_phasewarp_create(sp_phasewarp **p);
int sp_phasewarp_destroy(sp_phasewarp **p);
int sp_phasewarp_init(sp_data *sp, sp_phasewarp *p);
int sp_phasewarp_compute(sp_data *sp, sp_phasewarp *p,
                      SPFLOAT *in, SPFLOAT *out);
