#line 43 "dcblocker.org"
#define SK_DCBLOCKER_PRIV
#include "t_dcblocker.h"
#line 92 "dcblocker.org"
void sk_dcblocker_init(sk_dcblocker *dcblk) {
  dcblk->x = 0;
  dcblk->y = 0;
  dcblk->R = 0.99; /* quite reasonable, indeed! */
}
#line 112 "dcblocker.org"
SKFLT sk_dcblocker_tick(sk_dcblocker *dcblk, SKFLT in) {
  dcblk->y = in - dcblk->x + dcblk->R * dcblk->y;
  dcblk->x = in;
  return dcblk->y;
}
#line 43 "dcblocker.org"
