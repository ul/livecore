#line 27 "osc.org"
#ifndef SK_OSC_H
#define SK_OSC_H
#ifndef SKFLT
#define SKFLT float
#endif
#line 113 "osc.org"
typedef struct sk_osc sk_osc;
#line 33 "osc.org"
#ifdef SK_OSC_PRIV
#line 117 "osc.org"
struct sk_osc {
#line 124 "osc.org"
SKFLT freq, amp;
SKFLT *tab;
int inc;
size_t sz;
uint32_t nlb;
SKFLT inlb;
uint32_t mask;
SKFLT maxlens;
int32_t lphs;
#line 119 "osc.org"
};
#line 35 "osc.org"
#endif
#line 71 "osc.org"
void sk_osc_init(sk_osc *osc, int sr, SKFLT *wt, int sz, SKFLT iphs);
#line 78 "osc.org"
SKFLT sk_osc_tick(sk_osc *osc);
#line 87 "osc.org"
void sk_osc_freq(sk_osc *osc, SKFLT freq);
void sk_osc_amp(sk_osc *osc, SKFLT amp);
#line 37 "osc.org"
#endif
