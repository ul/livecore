#line 30 "vardelay.org"
#ifndef SK_VARDELAY_H
#define SK_VARDELAY_H

#ifndef SKFLT
#define SKFLT float
#endif

#line 71 "vardelay.org"
typedef struct sk_vardelay sk_vardelay;
#line 30 "vardelay.org"
#line 51 "vardelay.org"
void sk_vardelay_init(sk_vardelay *vd, int sr,
                      SKFLT *buf, unsigned long sz);
#line 164 "vardelay.org"
void sk_vardelay_delay(sk_vardelay *vd, SKFLT delay);
#line 193 "vardelay.org"
void sk_vardelay_feedback(sk_vardelay *vd, SKFLT feedback);
#line 220 "vardelay.org"
SKFLT sk_vardelay_tick(sk_vardelay *vd, SKFLT in);
#line 39 "vardelay.org"
#ifdef SK_VARDELAY_PRIV
#line 76 "vardelay.org"
struct sk_vardelay {
#line 87 "vardelay.org"
int sr;
#line 106 "vardelay.org"
SKFLT *buf;
unsigned long sz;
#line 130 "vardelay.org"
SKFLT prev;
#line 151 "vardelay.org"
long writepos;
#line 177 "vardelay.org"
SKFLT delay;
#line 206 "vardelay.org"
SKFLT feedback;
#line 78 "vardelay.org"
};
#line 41 "vardelay.org"
#endif
#endif
