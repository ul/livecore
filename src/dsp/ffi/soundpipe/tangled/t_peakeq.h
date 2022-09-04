#line 80 "peakeq.org"
#ifndef SK_PEAKEQ_H
#define SK_PEAKEQ_H

#ifndef SKFLT
#define SKFLT float
#endif

#line 100 "peakeq.org"
typedef struct sk_peakeq sk_peakeq;
#line 80 "peakeq.org"
#line 115 "peakeq.org"
void sk_peakeq_init(sk_peakeq *eq, int sr);
#line 177 "peakeq.org"
void sk_peakeq_freq(sk_peakeq *eq, SKFLT freq);
#line 211 "peakeq.org"
void sk_peakeq_bandwidth(sk_peakeq *eq, SKFLT bw);
#line 245 "peakeq.org"
void sk_peakeq_gain(sk_peakeq *eq, SKFLT gain);
#line 270 "peakeq.org"
SKFLT sk_peakeq_tick(sk_peakeq *eq, SKFLT in);
#line 89 "peakeq.org"

#ifdef SK_PEAKEQ_PRIV
#line 105 "peakeq.org"
struct sk_peakeq {
#line 134 "peakeq.org"
SKFLT v[2];
#line 148 "peakeq.org"
SKFLT a;
SKFLT b;
#line 163 "peakeq.org"
int sr;
#line 193 "peakeq.org"
SKFLT freq;
SKFLT pfreq;
#line 227 "peakeq.org"
SKFLT bw;
SKFLT pbw;
#line 258 "peakeq.org"
SKFLT gain;
#line 107 "peakeq.org"
};
#line 92 "peakeq.org"
#endif
#endif
