#ifndef SK_FMPAIR_H
#define SK_FMPAIR_H
#ifndef SKFLT
#define SKFLT float
#endif
typedef struct sk_fmpair sk_fmpair;
typedef struct sk_fmpair_fdbk sk_fmpair_fdbk;
void sk_fmpair_init(sk_fmpair *fmp, int sr,
                    SKFLT *ctab, int csz, SKFLT ciphs,
                    SKFLT *mtab, int msz, SKFLT miphs);
void sk_fmpair_freq(sk_fmpair *fmp, SKFLT freq);
void sk_fmpair_modulator(sk_fmpair *fmp, SKFLT mod);
void sk_fmpair_carrier(sk_fmpair *fmp, SKFLT car);
void sk_fmpair_modindex(sk_fmpair *fmp, SKFLT index);
SKFLT sk_fmpair_tick(sk_fmpair *fmp);
void sk_fmpair_fdbk_init(sk_fmpair_fdbk *fmp, int sr,
                         SKFLT *ctab, int csz, SKFLT ciphs,
                         SKFLT *mtab, int msz, SKFLT miphs);
void sk_fmpair_fdbk_amt(sk_fmpair_fdbk *f, SKFLT amt);
SKFLT sk_fmpair_fdbk_tick(sk_fmpair_fdbk *fmp);
#ifdef SK_FMPAIR_PRIV
struct sk_fmpair {
SKFLT *ctab;
int csz;
int clphs;
SKFLT *mtab;
int msz;
int mlphs;
/* carrier constants */
int cnlb;
SKFLT cinlb;
unsigned long cmask;

/* modulator constants */
int mnlb;
SKFLT minlb;
unsigned long mmask;

SKFLT maxlens;
SKFLT freq;
SKFLT car;
SKFLT mod;
SKFLT index;
};
struct sk_fmpair_fdbk {
    sk_fmpair fmpair;
    SKFLT prev;
    SKFLT feedback;
};
#endif
#endif
