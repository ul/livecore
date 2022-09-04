#ifndef SK_RLINE_H
typedef struct sk_rline sk_rline;
#endif

typedef struct {
    SPFLOAT min, max, cps;
    sk_rline *rline;
} sp_rline;

int sp_rline_create(sp_rline **p);
int sp_rline_destroy(sp_rline **p);
int sp_rline_init(sp_data *sp, sp_rline *p);
int sp_rline_compute(sp_data *sp, sp_rline *p,
                         SPFLOAT *in, SPFLOAT *out);
