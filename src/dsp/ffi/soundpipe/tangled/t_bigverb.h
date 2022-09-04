#line 109 "bigverb.org"
#ifndef SK_BIGVERB_H
#define SK_BIGVERB_H

#ifndef SKFLT
#define SKFLT float
#endif
#line 128 "bigverb.org"
typedef struct sk_bigverb sk_bigverb;
#line 502 "bigverb.org"
typedef struct sk_bigverb_delay sk_bigverb_delay;
#line 109 "bigverb.org"
#line 146 "bigverb.org"
sk_bigverb * sk_bigverb_new(int sr);
#line 170 "bigverb.org"
void sk_bigverb_del(sk_bigverb *bv);
#line 193 "bigverb.org"
void sk_bigverb_size(sk_bigverb *bv, SKFLT size);
#line 225 "bigverb.org"
void sk_bigverb_cutoff(sk_bigverb *bv, SKFLT cutoff);
#line 292 "bigverb.org"
void sk_bigverb_tick(sk_bigverb *bv,
                     SKFLT inL, SKFLT inR,
                     SKFLT *outL, SKFLT *outR);
#line 117 "bigverb.org"

#ifdef SK_BIGVERB_PRIV
#line 128 "bigverb.org"
#line 507 "bigverb.org"
struct sk_bigverb_delay {
#line 538 "bigverb.org"
SKFLT *buf;
size_t sz;
#line 552 "bigverb.org"
int wpos;
#line 567 "bigverb.org"
int irpos;
int frpos;
#line 576 "bigverb.org"
int rng;
#line 886 "bigverb.org"
int inc;
int counter;
#line 938 "bigverb.org"
int maxcount;
#line 976 "bigverb.org"
SKFLT dels;
#line 986 "bigverb.org"
SKFLT drift;
#line 1037 "bigverb.org"
SKFLT y;
#line 509 "bigverb.org"
};
#line 134 "bigverb.org"
struct sk_bigverb {
    int sr;
#line 205 "bigverb.org"
SKFLT size;
#line 249 "bigverb.org"
SKFLT cutoff;
SKFLT pcutoff;
#line 270 "bigverb.org"
SKFLT filt;
#line 400 "bigverb.org"
SKFLT *buf;
#line 474 "bigverb.org"
sk_bigverb_delay delay[8];
#line 137 "bigverb.org"
};
#line 120 "bigverb.org"
#endif
#endif
