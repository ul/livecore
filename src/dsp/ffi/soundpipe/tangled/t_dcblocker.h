#line 50 "dcblocker.org"
#ifndef SK_DCBLOCKER_H
#define SK_DCBLOCKER_H
#ifndef SKFLT
#define SKFLT float
#endif
#line 71 "dcblocker.org"
typedef struct sk_dcblocker sk_dcblocker;
#line 56 "dcblocker.org"
#ifdef SK_DCBLOCKER_PRIV
#line 75 "dcblocker.org"
struct sk_dcblocker {
    SKFLT x, y, R;
};
#line 58 "dcblocker.org"
#endif
#line 87 "dcblocker.org"
void sk_dcblocker_init(sk_dcblocker *dcblk);
#line 107 "dcblocker.org"
SKFLT sk_dcblocker_tick(sk_dcblocker *dcblk, SKFLT in);
#line 60 "dcblocker.org"
#endif
