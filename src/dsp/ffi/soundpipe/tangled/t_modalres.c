#line 19 "modalres.org"
#include <math.h>
#define SK_MODALRES_PRIV
#include "t_modalres.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#line 58 "modalres.org"
void sk_modalres_init(sk_modalres *mr, int sr) {
#line 92 "modalres.org"
  mr->x = 0;
  mr->y[0] = 0;
  mr->y[1] = 0;
#line 110 "modalres.org"
  mr->b1 = 0;
  mr->a1 = 0;
  mr->a2 = 0;
#line 125 "modalres.org"
  mr->sr = sr;
#line 140 "modalres.org"
  mr->s = 0;
#line 172 "modalres.org"
  sk_modalres_freq(mr, 1000);
  mr->pfreq = -1;
#line 204 "modalres.org"
  sk_modalres_q(mr, 1);
  mr->pq = -1;
#line 61 "modalres.org"
}
#line 153 "modalres.org"
void sk_modalres_freq(sk_modalres *mr, SKFLT freq) { mr->freq = freq; }
#line 185 "modalres.org"
void sk_modalres_q(sk_modalres *mr, SKFLT q) { mr->q = q; }
#line 217 "modalres.org"
SKFLT sk_modalres_tick(sk_modalres *mr, SKFLT in) {
  SKFLT out;

  out = 0;
#line 246 "modalres.org"
  if (mr->freq != mr->pfreq || mr->q != mr->pq) {
    SKFLT w;
    SKFLT a, b, d;

    w = mr->freq * 2.0 * M_PI;

    a = mr->sr / w;
    b = a * a;
    d = 0.5 * a;

    mr->pfreq = mr->freq;
    mr->pq = mr->q;

    mr->b1 = 1.0 / (b + d / mr->q);
    mr->a1 = (1.0 - 2.0 * b) * mr->b1;
    mr->a2 = (b - d / mr->q) * mr->b1;
    mr->s = d;
  }
#line 217 "modalres.org"
#line 285 "modalres.org"
  out = mr->b1 * mr->x - mr->a1 * mr->y[0] - mr->a2 * mr->y[1];
#line 217 "modalres.org"
#line 295 "modalres.org"
  mr->y[1] = mr->y[0];
  mr->y[0] = out;
  mr->x = in;
#line 217 "modalres.org"
#line 305 "modalres.org"
  out *= mr->s;
#line 226 "modalres.org"
  return out;
}
#line 19 "modalres.org"
