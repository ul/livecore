#line 32 "modalres.org"
#ifndef SK_MODALRES_H
#define SK_MODALRES_H

#ifndef SKFLT
#define SKFLT float
#endif

#line 68 "modalres.org"
typedef struct sk_modalres sk_modalres;
#line 32 "modalres.org"
#line 53 "modalres.org"
void sk_modalres_init(sk_modalres *mr, int sr);
#line 148 "modalres.org"
void sk_modalres_freq(sk_modalres *mr, SKFLT freq);
#line 180 "modalres.org"
void sk_modalres_q(sk_modalres *mr, SKFLT q);
#line 212 "modalres.org"
SKFLT sk_modalres_tick(sk_modalres *mr, SKFLT in);
#line 41 "modalres.org"

#ifdef SK_MODALRES_PRIV
#line 73 "modalres.org"
struct sk_modalres {
#line 86 "modalres.org"
SKFLT x;
SKFLT y[2];
#line 103 "modalres.org"
SKFLT b1;
SKFLT a1;
SKFLT a2;
#line 120 "modalres.org"
int sr;
#line 135 "modalres.org"
SKFLT s;
#line 161 "modalres.org"
SKFLT freq;
SKFLT pfreq;
#line 198 "modalres.org"
SKFLT q;
SKFLT pq;
#line 75 "modalres.org"
};
#line 44 "modalres.org"
#endif
#endif
