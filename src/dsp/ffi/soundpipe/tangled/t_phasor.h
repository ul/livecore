#line 32 "phasor.org"
#ifndef SK_PHASOR_H
#define SK_PHASOR_H

#ifndef SKFLT
#define SKFLT float
#endif

#line 60 "phasor.org"
typedef struct sk_phasor sk_phasor;
#line 32 "phasor.org"
#line 79 "phasor.org"
void sk_phasor_init(sk_phasor *ph, int sr, SKFLT iphs);
#line 97 "phasor.org"
void sk_phasor_freq(sk_phasor *ph, SKFLT freq);
#line 113 "phasor.org"
SKFLT sk_phasor_tick(sk_phasor *ph);
#line 159 "phasor.org"
void sk_phasor_reset(sk_phasor *phs, SKFLT val);
#line 41 "phasor.org"
#ifdef SK_PHASOR_PRIV
#line 70 "phasor.org"
struct sk_phasor {
    SKFLT freq;
    SKFLT phs;
    SKFLT onedsr;
};
#line 43 "phasor.org"
#endif
#endif
