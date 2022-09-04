#ifndef SK_MODALRES_H
typedef struct sk_modalres sk_modalres;
#endif

typedef struct {
    SPFLOAT freq, q;
    sk_modalres *modalres;
} sp_modalres;

int sp_modalres_create(sp_modalres **p);
int sp_modalres_destroy(sp_modalres **p);
int sp_modalres_init(sp_data *sp, sp_modalres *p);
int sp_modalres_compute(sp_data *sp, sp_modalres *p,
                      SPFLOAT *in, SPFLOAT *out);
