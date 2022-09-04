#ifndef SK_BIGVERB_H
typedef struct sk_bigverb sk_bigverb;
#endif

typedef struct {
    SPFLOAT feedback, lpfreq;
    sk_bigverb *bv;
} sp_bigverb;

int sp_bigverb_create(sp_bigverb **p);
int sp_bigverb_destroy(sp_bigverb **p);
int sp_bigverb_init(sp_data *sp, sp_bigverb *p);
int sp_bigverb_compute(sp_data *sp,
                       sp_bigverb *p,
                       SPFLOAT *in1,
                       SPFLOAT *in2,
                       SPFLOAT *out1,
                       SPFLOAT *out2);
