#line 93 "bigverb.org"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#define SK_BIGVERB_PRIV
#include "t_bigverb.h"
#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
#line 56 "bigverb.org"
struct bigverb_paramset {
  int delay;    /* in samples, 44.1 kHz */
  int drift;    /* 1/10 milliseconds */
  int randfreq; /* Hertz * 1000 */
  int seed;
};

static const struct bigverb_paramset params[8] = {
    {0x09a9, 0x0a, 0xc1c, 0x07ae}, {0x0acf, 0x0b, 0xdac, 0x7333},
    {0x0c91, 0x11, 0x456, 0x5999}, {0x0de5, 0x06, 0xf85, 0x2666},
    {0x0f43, 0x0a, 0x925, 0x50a3}, {0x101f, 0x0b, 0x769, 0x5999},
    {0x085f, 0x11, 0x37b, 0x7333}, {0x078d, 0x06, 0xc95, 0x3851}};
#line 93 "bigverb.org"
#line 857 "bigverb.org"
#define FRACSCALE 0x10000000
#line 867 "bigverb.org"
#define FRACMASK 0xFFFFFFF
#line 875 "bigverb.org"
#define FRACNBITS 28
#line 93 "bigverb.org"
#line 437 "bigverb.org"
static int get_delay_size(const struct bigverb_paramset *p, int sr);
#line 514 "bigverb.org"
static void delay_init(sk_bigverb_delay *d, const struct bigverb_paramset *p,
                       SKFLT *buf, size_t sz, int sr);
#line 622 "bigverb.org"
static SKFLT delay_compute(sk_bigverb_delay *d, SKFLT in, SKFLT fdbk,
                           SKFLT filt, int sr);
#line 902 "bigverb.org"
static void generate_next_line(sk_bigverb_delay *d, int sr);
#line 93 "bigverb.org"
#line 151 "bigverb.org"
sk_bigverb *sk_bigverb_new(int sr) {
  sk_bigverb *bv;

  bv = calloc(1, sizeof(sk_bigverb));

  bv->sr = sr;
#line 210 "bigverb.org"
  sk_bigverb_size(bv, 0.93);
#line 236 "bigverb.org"
  sk_bigverb_cutoff(bv, 10000.0);
#line 255 "bigverb.org"
  bv->pcutoff = -1;
#line 275 "bigverb.org"
  bv->filt = 1.0;
#line 405 "bigverb.org"
  bv->buf = NULL;
#line 151 "bigverb.org"
#line 410 "bigverb.org"
  {
    unsigned long total_size;
    int i;
    SKFLT *buf;

    total_size = 0;
    buf = NULL;
#line 452 "bigverb.org"
    for (i = 0; i < 8; i++) {
      total_size += get_delay_size(&params[i], sr);
    }
#line 410 "bigverb.org"
#line 463 "bigverb.org"
    buf = calloc(1, sizeof(SKFLT) * total_size);
    bv->buf = buf;
#line 410 "bigverb.org"
#line 479 "bigverb.org"
    {
      unsigned long bufpos;
      bufpos = 0;
      for (i = 0; i < 8; i++) {
        unsigned int sz;
        sz = get_delay_size(&params[i], sr);

        delay_init(&bv->delay[i], &params[i], &buf[bufpos], sz, sr);
        bufpos += sz;
      }
    }
#line 420 "bigverb.org"
  }
#line 160 "bigverb.org"

  return bv;
}
#line 175 "bigverb.org"
void sk_bigverb_del(sk_bigverb *bv) {
#line 469 "bigverb.org"
  free(bv->buf);
#line 178 "bigverb.org"
  free(bv);
  bv = NULL;
}
#line 215 "bigverb.org"
void sk_bigverb_size(sk_bigverb *bv, SKFLT size) { bv->size = size; }
#line 260 "bigverb.org"
void sk_bigverb_cutoff(sk_bigverb *bv, SKFLT cutoff) { bv->cutoff = cutoff; }
#line 299 "bigverb.org"
void sk_bigverb_tick(sk_bigverb *bv, SKFLT inL, SKFLT inR, SKFLT *outL,
                     SKFLT *outR) {
  /* TODO: implement */
  SKFLT lsum, rsum;

  lsum = 0;
  rsum = 0;

#line 332 "bigverb.org"
  if (bv->pcutoff != bv->cutoff) {
    bv->pcutoff = bv->cutoff;
    bv->filt = 2.0 - cos(bv->pcutoff * 2 * M_PI / bv->sr);
    bv->filt = bv->filt - sqrt(bv->filt * bv->filt - 1.0);
  }
#line 299 "bigverb.org"
#line 347 "bigverb.org"
  {
    int i;
    SKFLT jp;

    jp = 0;

    for (i = 0; i < 8; i++) {
      jp += bv->delay[i].y;
    }

    jp *= 0.25;

    inL = jp + inL;
    inR = jp + inR;
  }
#line 299 "bigverb.org"
#line 373 "bigverb.org"
  {
    int i;
    for (i = 0; i < 8; i++) {
      if (i & 1) {
        rsum += delay_compute(&bv->delay[i], inR, bv->size, bv->filt, bv->sr);
      } else {
        lsum += delay_compute(&bv->delay[i], inL, bv->size, bv->filt, bv->sr);
      }
    }
  }
  rsum *= 0.35f;
  lsum *= 0.35f;
#line 312 "bigverb.org"

  *outL = lsum;
  *outR = rsum;
}
#line 442 "bigverb.org"
static int get_delay_size(const struct bigverb_paramset *p, int sr) {
  SKFLT sz;
  sz = (SKFLT)p->delay / 44100 + (p->drift * 0.0001) * 1.125;
  return floor(16 + sz * sr);
}
#line 523 "bigverb.org"
static void delay_init(sk_bigverb_delay *d, const struct bigverb_paramset *p,
                       SKFLT *buf, size_t sz, int sr) {
  SKFLT readpos;
#line 544 "bigverb.org"
  d->buf = buf;
  d->sz = sz;
#line 557 "bigverb.org"
  d->wpos = 0;
#line 581 "bigverb.org"
  d->rng = p->seed;
#line 595 "bigverb.org"
  readpos = ((SKFLT)p->delay / 44100);
  readpos += d->rng * (p->drift * 0.0001) / 32768.0;
  readpos = sz - (readpos * sr);
  d->irpos = floor(readpos);
  d->frpos = floor((readpos - d->irpos) * FRACSCALE);
#line 581 "bigverb.org"
#line 595 "bigverb.org"
#line 892 "bigverb.org"
  d->inc = 0;
  d->counter = 0;
#line 943 "bigverb.org"
  d->maxcount = floor((sr / ((SKFLT)p->randfreq * 0.001)));
#line 981 "bigverb.org"
  d->dels = p->delay / 44100.0;
#line 991 "bigverb.org"
  d->drift = p->drift;
#line 607 "bigverb.org"
  generate_next_line(d, sr);
#line 1042 "bigverb.org"
  d->y = 0.0;
#line 531 "bigverb.org"
}
#line 631 "bigverb.org"
static SKFLT delay_compute(sk_bigverb_delay *del, SKFLT in, SKFLT fdbk,
                           SKFLT filt, int sr) {
  SKFLT out;
  SKFLT frac_norm;
  SKFLT a, b, c, d;
  SKFLT s[4];
  out = 0;
#line 669 "bigverb.org"
  del->buf[del->wpos] = in - del->y;
#line 631 "bigverb.org"
#line 677 "bigverb.org"
  del->wpos++;
  if (del->wpos >= del->sz)
    del->wpos -= del->sz;
#line 631 "bigverb.org"
#line 689 "bigverb.org"
  if (del->frpos >= FRACSCALE) {
    del->irpos += del->frpos >> FRACNBITS;
    del->frpos &= FRACMASK;
  }
#line 631 "bigverb.org"
#line 699 "bigverb.org"
  if (del->irpos >= del->sz)
    del->irpos -= del->sz;
#line 631 "bigverb.org"
#line 708 "bigverb.org"
  frac_norm = del->frpos / (SKFLT)FRACSCALE;
#line 631 "bigverb.org"
#line 721 "bigverb.org"
  {
    SKFLT tmp[2];
    d = ((frac_norm * frac_norm) - 1) / 6.0;
    tmp[0] = ((frac_norm + 1.0) * 0.5);
    tmp[1] = 3.0 * d;
    a = tmp[0] - 1.0 - d;
    c = tmp[0] - tmp[1];
    b = tmp[1] - frac_norm;
  }
#line 631 "bigverb.org"
#line 740 "bigverb.org"
  {
    int n;
    SKFLT *x;
    n = del->irpos;
    x = del->buf;

    if (n > 0 && n < (del->sz - 2)) {
      s[0] = x[n - 1];
      s[1] = x[n];
      s[2] = x[n + 1];
      s[3] = x[n + 2];
    } else {
      int k;
      n--;
      if (n < 0)
        n += del->sz;
      s[0] = x[n];
      for (k = 0; k < 3; k++) {
        n++;
        if (n >= del->sz)
          n -= del->sz;
        s[k + 1] = x[n];
      }
    }
  }
#line 631 "bigverb.org"
#line 778 "bigverb.org"
  out = (a * s[0] + b * s[1] + c * s[2] + d * s[3]) * frac_norm + s[1];
#line 631 "bigverb.org"
#line 786 "bigverb.org"
  del->frpos += del->inc;
#line 631 "bigverb.org"
#line 796 "bigverb.org"
  out *= fdbk;
  out += (del->y - out) * filt;
  del->y = out;
#line 631 "bigverb.org"
#line 823 "bigverb.org"
  del->counter--;
  if (del->counter <= 0) {
    generate_next_line(del, sr);
  }
#line 653 "bigverb.org"
  return out;
}
#line 1016 "bigverb.org"
static void generate_next_line(sk_bigverb_delay *d, int sr) {
  SKFLT curdel;
  SKFLT nxtdel;
  SKFLT inc;
#line 923 "bigverb.org"
  if (d->rng < 0)
    d->rng += 0x10000;
  /* 5^6 = 15625 */
  d->rng = (1 + d->rng * 0x3d09);
  d->rng &= 0xFFFF;
  if (d->rng >= 0x8000)
    d->rng -= 0x10000;
#line 1016 "bigverb.org"
#line 948 "bigverb.org"
  d->counter = d->maxcount;
#line 1016 "bigverb.org"
#line 958 "bigverb.org"
  curdel = d->wpos - (d->irpos + (d->frpos / (SKFLT)FRACSCALE));
  while (curdel < 0)
    curdel += d->sz;
  curdel /= sr;
#line 969 "bigverb.org"
  nxtdel = (d->rng * (d->drift * 0.0001) / 32768.0) + d->dels;
#line 1016 "bigverb.org"
#line 1002 "bigverb.org"
  inc = ((curdel - nxtdel) / (SKFLT)d->counter) * sr;
  inc += 1;
#line 1016 "bigverb.org"
#line 1011 "bigverb.org"
  d->inc = floor(inc * FRACSCALE);
#line 1026 "bigverb.org"
}
#line 93 "bigverb.org"
