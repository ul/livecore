#line 26 "phasewarp.org"
#include "t_phasewarp.h"
#line 54 "phasewarp.org"
SKFLT sk_phasewarp_tick(SKFLT in, SKFLT warp) {
  SKFLT out;
  SKFLT wmp;

  out = 0;

#line 71 "phasewarp.org"
  wmp = (warp + 1.0) * 0.5;
#line 54 "phasewarp.org"
#line 80 "phasewarp.org"
  if (in < wmp) {
#line 92 "phasewarp.org"
    if (wmp != 0)
      out = ((SKFLT)0.5 / wmp) * in;
#line 82 "phasewarp.org"
  } else {
#line 101 "phasewarp.org"
    if (wmp != 1.0) {
      out = ((SKFLT)0.5 / (SKFLT)(1.0 - wmp)) * (in - wmp) + 0.5;
    }
#line 84 "phasewarp.org"
  }
#line 63 "phasewarp.org"
  return out;
}
#line 26 "phasewarp.org"
