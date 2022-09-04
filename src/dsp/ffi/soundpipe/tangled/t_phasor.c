#line 49 "phasor.org"
#define SK_PHASOR_PRIV
#include "t_phasor.h"
#line 84 "phasor.org"
void sk_phasor_init(sk_phasor *ph, int sr, SKFLT iphs) {
  ph->phs = iphs;
  ph->onedsr = 1.0 / sr;
  sk_phasor_freq(ph, 440);
}
#line 102 "phasor.org"
void sk_phasor_freq(sk_phasor *ph, SKFLT freq) { ph->freq = freq; }
#line 128 "phasor.org"
SKFLT sk_phasor_tick(sk_phasor *ph) {
  SKFLT phs;
  SKFLT incr;
  SKFLT out;

  phs = ph->phs;
  incr = ph->freq * ph->onedsr;

  out = phs;

  phs += incr;

  if (phs >= 1.0) {
    phs -= 1.0;
  } else if (phs < 0.0) {
    phs += 1.0;
  }

  ph->phs = phs;

  return out;
}
#line 164 "phasor.org"
void sk_phasor_reset(sk_phasor *phs, SKFLT val) {
  if (val >= 0)
    phs->phs = val;
  else
    phs->phs = 0;
}
#line 49 "phasor.org"
