#line 23 "scale.org"
#include "t_scale.h"
#line 37 "scale.org"
SKFLT sk_scale(SKFLT in, SKFLT min, SKFLT max) {

  return in * (max - min) + min;
}
#line 54 "scale.org"
SKFLT sk_biscale(SKFLT in, SKFLT min, SKFLT max) {
  return min + (in + 1.0) * 0.5 * (max - min);
}
#line 23 "scale.org"
