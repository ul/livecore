#line 48 "rline.org"
#ifndef SK_RLINE_H
#define SK_RLINE_H

#ifndef SKFLT
#define SKFLT float
#endif

#line 68 "rline.org"
typedef struct sk_rline sk_rline;
#line 48 "rline.org"
#line 226 "rline.org"
void sk_rline_init(sk_rline *rl, int sr, int seed);
#line 242 "rline.org"
void sk_rline_min(sk_rline *rl, SKFLT min);
#line 269 "rline.org"
void sk_rline_max(sk_rline *rl, SKFLT max);
#line 296 "rline.org"
void sk_rline_rate(sk_rline *rl, SKFLT rate);
#line 323 "rline.org"
SKFLT sk_rline_tick(sk_rline *rl);
#line 57 "rline.org"

#ifdef SK_RLINE_PRIV
#line 73 "rline.org"
struct sk_rline {
#line 85 "rline.org"
SKFLT rngscale;
#line 98 "rline.org"
int rng;
#line 126 "rline.org"
SKFLT maxlens;
#line 140 "rline.org"
unsigned long phasepos;
SKFLT scale;
#line 166 "rline.org"
SKFLT start;
SKFLT end;
#line 255 "rline.org"
SKFLT min;
#line 282 "rline.org"
SKFLT max;
#line 309 "rline.org"
SKFLT rate;
#line 75 "rline.org"
};
#line 60 "rline.org"
#endif
#endif
