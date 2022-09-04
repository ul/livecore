#ifndef SK_DCBLOCKER_H
typedef struct sk_dcblocker sk_dcblocker;
#endif

typedef struct {
    sk_dcblocker *dcblocker;
} sp_dcblocker;

int sp_dcblocker_create(sp_dcblocker **p);
int sp_dcblocker_destroy(sp_dcblocker **p);
int sp_dcblocker_init(sp_data *sp, sp_dcblocker *p);
int sp_dcblocker_compute(sp_data *sp, sp_dcblocker *p,
                         SPFLOAT *in, SPFLOAT *out);
