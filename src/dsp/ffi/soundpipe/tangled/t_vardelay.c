#line 18 "vardelay.org"
#include <math.h>
#include <stdlib.h>
#define SK_VARDELAY_PRIV
#include "t_vardelay.h"
#line 57 "vardelay.org"
void sk_vardelay_init(sk_vardelay *vd, int sr, SKFLT *buf, unsigned long sz) {
#line 92 "vardelay.org"
  vd->sr = sr;
#line 112 "vardelay.org"
  if (sz < 4) {
    vd->buf = NULL;
    vd->buf = 0;
  } else {
    vd->buf = buf;
    vd->sz = sz;
  }
#line 135 "vardelay.org"
  vd->prev = 0;
#line 156 "vardelay.org"
  vd->writepos = 0;
#line 185 "vardelay.org"
  sk_vardelay_delay(vd, ((SKFLT)sz / sr) * 0.5);
#line 213 "vardelay.org"
  sk_vardelay_feedback(vd, 0);
#line 61 "vardelay.org"
}
#line 169 "vardelay.org"
void sk_vardelay_delay(sk_vardelay *vd, SKFLT delay) { vd->delay = delay; }
#line 198 "vardelay.org"
void sk_vardelay_feedback(sk_vardelay *vd, SKFLT feedback) {
  vd->feedback = feedback;
}
#line 225 "vardelay.org"
SKFLT sk_vardelay_tick(sk_vardelay *vd, SKFLT in) {
  SKFLT out;
  SKFLT dels;
  SKFLT f;
  long i;
  SKFLT s[4];
  unsigned long n[4];
  SKFLT a, b, c, d;

  out = 0;
#line 254 "vardelay.org"
  if (vd->buf == NULL || vd->sz == 0)
    return 0;
#line 225 "vardelay.org"
#line 261 "vardelay.org"
  vd->buf[vd->writepos] = in + vd->prev * vd->feedback;
#line 225 "vardelay.org"
#line 274 "vardelay.org"
  dels = vd->delay * vd->sr;
  i = floor(dels);
  f = i - dels;
  i = vd->writepos - i;
#line 225 "vardelay.org"
#line 299 "vardelay.org"
  if ((f < 0.0) || (i < 0)) {
    /* flip fractional component */
    f = f + 1.0;
    /* go backwards one sample */
    i = i - 1;
    while (i < 0)
      i += vd->sz;
  } else
    while (i >= vd->sz)
      i -= vd->sz;
#line 225 "vardelay.org"
#line 313 "vardelay.org"
  /* x(n) */
  n[1] = i;

  /* x(n + 1) */
  if (i == (vd->sz - 1))
    n[2] = 0;
  else
    n[2] = n[1] + 1;

  /* x(n - 1) */
  if (i == 0)
    n[0] = vd->sz - 1;
  else
    n[0] = i - 1;

  if (n[2] == vd->sz - 1)
    n[3] = 0;
  else
    n[3] = n[2] + 1;

  {
    int j;
    for (j = 0; j < 4; j++)
      s[j] = vd->buf[n[j]];
  }
#line 225 "vardelay.org"
#line 338 "vardelay.org"
  {
    SKFLT tmp[2];

    d = ((f * f) - 1) * 0.1666666667;
    tmp[0] = (f + 1.0) * 0.5;
    tmp[1] = 3.0 * d;
    a = tmp[0] - 1.0 - d;
    c = tmp[0] - tmp[1];
    b = tmp[1] - f;
  }
#line 225 "vardelay.org"
#line 358 "vardelay.org"
  out = (a * s[0] + b * s[1] + c * s[2] + d * s[3]) * f + s[1];
#line 225 "vardelay.org"
#line 366 "vardelay.org"
  vd->writepos++;
  if (vd->writepos == vd->sz)
    vd->writepos = 0;
#line 225 "vardelay.org"
#line 375 "vardelay.org"
  vd->prev = out;
#line 245 "vardelay.org"

  return out;
}
#line 18 "vardelay.org"
