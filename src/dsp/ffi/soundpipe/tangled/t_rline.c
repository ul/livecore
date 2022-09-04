#line 35 "rline.org"
#include <math.h>
#define SK_RLINE_PRIV
#include "t_rline.h"
#line 114 "rline.org"
#define SK_RLINE_PHSLEN 0x1000000L
#define SK_RLINE_PHSMSK 0xFFFFFFL
#line 202 "rline.org"
#define LCG(y) (y * 0x343fd + 0x269ec3)
#line 215 "rline.org"
#define RNG(y) ((y >> 1) & 0x7fffffff)
#line 35 "rline.org"
#line 231 "rline.org"
void sk_rline_init(sk_rline *rl, int sr, int seed) {
#line 103 "rline.org"
  rl->rng = seed;
#line 90 "rline.org"
  rl->rngscale = 1.0 / ((1L << 31) - 1);
#line 103 "rline.org"
#line 172 "rline.org"
  rl->rng = LCG(rl->rng);
  rl->start = RNG(rl->rng) * rl->rngscale;
  rl->rng = LCG(rl->rng);
  rl->end = RNG(rl->rng) * rl->rngscale;
#line 156 "rline.org"
  rl->scale = (rl->end - rl->start) / SK_RLINE_PHSLEN;
#line 172 "rline.org"
#line 103 "rline.org"
#line 131 "rline.org"
  rl->maxlens = (SKFLT)SK_RLINE_PHSLEN / sr;
#line 146 "rline.org"
  rl->phasepos = 0;
#line 262 "rline.org"
  sk_rline_min(rl, 0);
#line 289 "rline.org"
  sk_rline_max(rl, 1);
#line 316 "rline.org"
  sk_rline_rate(rl, 1);
#line 234 "rline.org"
}
#line 247 "rline.org"
void sk_rline_min(sk_rline *rl, SKFLT min) { rl->min = min; }
#line 274 "rline.org"
void sk_rline_max(sk_rline *rl, SKFLT max) { rl->max = max; }
#line 301 "rline.org"
void sk_rline_rate(sk_rline *rl, SKFLT rate) { rl->rate = rate; }
#line 328 "rline.org"
SKFLT sk_rline_tick(sk_rline *rl) {
  SKFLT out;

  out = 0;

#line 361 "rline.org"
  out = rl->start + rl->phasepos * rl->scale;
  out = out * (rl->max - rl->min) + rl->min;
#line 328 "rline.org"
#line 374 "rline.org"
  rl->phasepos += floor(rl->rate * rl->maxlens);
#line 328 "rline.org"
#line 396 "rline.org"
  if (rl->phasepos >= SK_RLINE_PHSLEN) {
    rl->phasepos &= SK_RLINE_PHSMSK;
    rl->start = rl->end;
    rl->rng = LCG(rl->rng);
    rl->end = RNG(rl->rng) * rl->rngscale;
    rl->scale = (rl->end - rl->start) / SK_RLINE_PHSLEN;
  }
#line 337 "rline.org"

  return out;
}
#line 35 "rline.org"
