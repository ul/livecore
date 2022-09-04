#ifndef SK_PEAKEQ_H
typedef struct sk_peakeq sk_peakeq;
#endif

typedef struct {
    SPFLOAT freq, bw, gain;
    sk_peakeq *peakeq;
} sp_peakeq;

int sp_peakeq_create(sp_peakeq **p);
int sp_peakeq_destroy(sp_peakeq **p);
int sp_peakeq_init(sp_data *sp, sp_peakeq *p);
int sp_peakeq_compute(sp_data *sp, sp_peakeq *p,
                      SPFLOAT *in, SPFLOAT *out);
