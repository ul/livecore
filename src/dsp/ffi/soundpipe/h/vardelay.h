#ifndef SK_VARDELAY_H
typedef struct sk_vardelay sk_vardelay;
#endif

typedef struct {
    SPFLOAT del, maxdel;
    SPFLOAT feedback;
    sk_vardelay *v;
    SPFLOAT *buf;
} sp_vardelay;

int sp_vardelay_create(sp_vardelay **p);
int sp_vardelay_destroy(sp_vardelay **p);
int sp_vardelay_init(sp_data *sp, sp_vardelay *p, SPFLOAT maxdel);
int sp_vardelay_compute(sp_data *sp,
                       sp_vardelay *p,
                       SPFLOAT *in,
                       SPFLOAT *out);
