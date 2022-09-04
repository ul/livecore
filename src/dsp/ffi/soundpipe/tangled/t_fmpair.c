#include <math.h>
#define SK_FMPAIR_PRIV
#include "t_fmpair.h"
#define SK_FMPAIR_MAXLEN 0x1000000L
#define SK_FMPAIR_PHASEMASK 0x0FFFFFFL
void sk_fmpair_init(sk_fmpair *fmp, int sr, SKFLT *ctab, int csz, SKFLT ciphs,
                    SKFLT *mtab, int msz, SKFLT miphs) {
  fmp->ctab = ctab;
  fmp->csz = msz;
  fmp->mtab = mtab;
  fmp->msz = msz;
  fmp->clphs = floor(ciphs * SK_FMPAIR_MAXLEN);
  fmp->mlphs = floor(miphs * SK_FMPAIR_MAXLEN);
  {
    int tmp;

    /* carrier */
    tmp = SK_FMPAIR_MAXLEN / csz;
    fmp->cnlb = 0;
    while (tmp >>= 1)
      fmp->cnlb++;

    /* modulator */
    tmp = SK_FMPAIR_MAXLEN / msz;
    fmp->mnlb = 0;
    while (tmp >>= 1)
      fmp->mnlb++;
  }

  /* phase mask for dividing lower/upper bits */

  fmp->cmask = (1 << fmp->cnlb) - 1;
  fmp->mmask = (1 << fmp->mnlb) - 1;

  /* constant used to convert to floating point */

  fmp->cinlb = 1.0 / (1 << fmp->cnlb);
  fmp->minlb = 1.0 / (1 << fmp->mnlb);

  /* max table length in seconds */
  /* used to convert cycles-per-second units to cycles */

  fmp->maxlens = 1.0 * SK_FMPAIR_MAXLEN / sr;
  sk_fmpair_freq(fmp, 440);
  sk_fmpair_carrier(fmp, 1);
  sk_fmpair_modulator(fmp, 1);
  sk_fmpair_modindex(fmp, 1);
}
void sk_fmpair_freq(sk_fmpair *fmp, SKFLT freq) { fmp->freq = freq; }
void sk_fmpair_modulator(sk_fmpair *fmp, SKFLT mod) { fmp->mod = mod; }

void sk_fmpair_carrier(sk_fmpair *fmp, SKFLT car) { fmp->car = car; }
void sk_fmpair_modindex(sk_fmpair *fmp, SKFLT index) { fmp->index = index; }
SKFLT sk_fmpair_tick(sk_fmpair *fmp) {
  SKFLT out;
  SKFLT cfreq, mfreq;
  SKFLT modout;
  int ipos;
  SKFLT frac;
  SKFLT x[2];
  out = 0;
  cfreq = fmp->freq * fmp->car;
  mfreq = fmp->freq * fmp->mod;
  fmp->mlphs &= SK_FMPAIR_PHASEMASK;
  ipos = fmp->mlphs >> fmp->mnlb;
  x[0] = fmp->mtab[ipos];

  if (ipos == fmp->msz - 1) {
    x[1] = fmp->mtab[0];
  } else {
    x[1] = fmp->mtab[ipos + 1];
  }

  frac = (fmp->mlphs & fmp->mmask) * fmp->minlb;
  modout = (x[0] + (x[1] - x[0]) * frac);
  modout *= mfreq * fmp->index;
  cfreq += modout;
  fmp->clphs &= SK_FMPAIR_PHASEMASK;
  ipos = (fmp->clphs) >> fmp->cnlb;
  x[0] = fmp->ctab[ipos];

  if (ipos == fmp->csz - 1) {
    x[1] = fmp->ctab[0];
  } else {
    x[1] = fmp->ctab[ipos + 1];
  }

  frac = (fmp->clphs & fmp->cmask) * fmp->cinlb;
  out = (x[0] + (x[1] - x[0]) * frac);
  fmp->clphs += floor(cfreq * fmp->maxlens);
  fmp->mlphs += floor(mfreq * fmp->maxlens);
  return out;
}
void sk_fmpair_fdbk_init(sk_fmpair_fdbk *fmp, int sr, SKFLT *ctab, int csz,
                         SKFLT ciphs, SKFLT *mtab, int msz, SKFLT miphs) {
  sk_fmpair_init(&fmp->fmpair, sr, ctab, csz, ciphs, mtab, msz, miphs);
  fmp->prev = 0;
  fmp->feedback = 0;
}
void sk_fmpair_fdbk_amt(sk_fmpair_fdbk *f, SKFLT amt) { f->feedback = amt; }
SKFLT sk_fmpair_fdbk_tick(sk_fmpair_fdbk *f) {
  SKFLT out;
  SKFLT cfreq, mfreq;
  SKFLT modout;
  int ipos;
  SKFLT frac;
  SKFLT x[2];
  sk_fmpair *fmp;
  out = 0;
  fmp = &f->fmpair;

  cfreq = fmp->freq * fmp->car;
  mfreq = fmp->freq * fmp->mod;
  fmp->mlphs &= SK_FMPAIR_PHASEMASK;
  ipos = fmp->mlphs >> fmp->mnlb;
  x[0] = fmp->mtab[ipos];

  if (ipos == fmp->msz - 1) {
    x[1] = fmp->mtab[0];
  } else {
    x[1] = fmp->mtab[ipos + 1];
  }

  frac = (fmp->mlphs & fmp->mmask) * fmp->minlb;
  modout = (x[0] + (x[1] - x[0]) * frac);

  /* feedback-oscillator specific */
  modout += f->prev * f->feedback;
  f->prev = modout;

  modout *= mfreq * fmp->index;

  cfreq += modout;
  fmp->clphs &= SK_FMPAIR_PHASEMASK;
  ipos = (fmp->clphs) >> fmp->cnlb;
  x[0] = fmp->ctab[ipos];

  if (ipos == fmp->csz - 1) {
    x[1] = fmp->ctab[0];
  } else {
    x[1] = fmp->ctab[ipos + 1];
  }

  frac = (fmp->clphs & fmp->cmask) * fmp->cinlb;
  out = (x[0] + (x[1] - x[0]) * frac);
  fmp->clphs += floor(cfreq * fmp->maxlens);
  fmp->mlphs += floor(mfreq * fmp->maxlens);
  return out;
}
