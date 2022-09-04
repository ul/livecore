#ifndef SOUNDPIPE_H
#define SOUNDPIPE_H
#include <stdint.h>
#include <stdio.h>

#define SP_BUFSIZE 4096
#ifndef SPFLOAT
#define SPFLOAT float
#endif
#define SP_OK 1
#define SP_NOT_OK 0

#define SP_RANDMAX 2147483648

typedef unsigned long sp_frame;

typedef struct sp_data {
    SPFLOAT *out;
    int sr;
    int nchan;
    unsigned long len;
    unsigned long pos;
    char filename[200];
    uint32_t rand;
} sp_data;

typedef struct {
    char state;
    SPFLOAT val;
} sp_param;

int sp_create(sp_data **spp);
int sp_createn(sp_data **spp, int nchan);

int sp_destroy(sp_data **spp);
int sp_process(sp_data *sp, void *ud, void (*callback)(sp_data *, void *));
int sp_process_raw(sp_data *sp, void *ud, void (*callback)(sp_data *, void *));
int sp_process_plot(sp_data *sp, void *ud, void (*callback)(sp_data *, void *));
int sp_process_spa(sp_data *sp, void *ud, void (*callback)(sp_data *, void *));

SPFLOAT sp_midi2cps(SPFLOAT nn);

int sp_set(sp_param *p, SPFLOAT val);

int sp_out(sp_data *sp, uint32_t chan, SPFLOAT val);

uint32_t sp_rand(sp_data *sp);
void sp_srand(sp_data *sp, uint32_t val);


typedef struct {
    SPFLOAT *utbl;
    int16_t *BRLow;
    int16_t *BRLowCpx;
} sp_fft;

void sp_fft_create(sp_fft **fft);
void sp_fft_init(sp_fft *fft, int M);
void sp_fftr(sp_fft *fft, SPFLOAT *buf, int FFTsize);
void sp_fft_cpx(sp_fft *fft, SPFLOAT *buf, int FFTsize);
void sp_ifftr(sp_fft *fft, SPFLOAT *buf, int FFTsize);
void sp_fft_destroy(sp_fft *fft);
#ifndef kiss_fft_scalar
#define kiss_fft_scalar SPFLOAT
#endif
typedef struct {
    kiss_fft_scalar r;
    kiss_fft_scalar i;
}kiss_fft_cpx;

typedef struct kiss_fft_state* kiss_fft_cfg;
typedef struct kiss_fftr_state* kiss_fftr_cfg;

/* SPA: Soundpipe Audio */

enum { SPA_READ, SPA_WRITE, SPA_NULL };

typedef struct {
    char magic;
    char nchan;
    uint16_t sr;
    uint32_t len;
} spa_header;

typedef struct {
    spa_header header;
    size_t offset;
    int mode;
    FILE *fp;
    uint32_t pos;
} sp_audio;
#define SP_FT_MAXLEN 0x1000000L
#define SP_FT_PHMASK 0x0FFFFFFL

typedef struct sp_ftbl{
    size_t size;
    SPFLOAT *tbl;
    unsigned char del;
} sp_ftbl;

int sp_ftbl_create(sp_data *sp, sp_ftbl **ft, size_t size);
int sp_ftbl_bind(sp_data *sp, sp_ftbl **ft, SPFLOAT *tbl, size_t size);
int sp_ftbl_destroy(sp_ftbl **ft);
int sp_ftbl_loadfile(sp_data *sp, sp_ftbl **ft, const char *filename);
int sp_ftbl_loadspa(sp_data *sp, sp_ftbl **ft, const char *filename);
int sp_gen_vals(sp_data *sp, sp_ftbl *ft, const char *string);
int sp_gen_sine(sp_data *sp, sp_ftbl *ft);
void sp_gen_triangle(sp_data *sp, sp_ftbl *ft);
void sp_gen_composite(sp_data *sp, sp_ftbl *ft, const char *argstring);
void sp_gen_sinesum(sp_data *sp, sp_ftbl *ft, const char *argstring);
void sp_ftbl_fftcut(sp_ftbl *ft, int cut);
void sp_ftbl_mags(sp_ftbl *ft, sp_ftbl **out);
typedef struct {
    SPFLOAT atk;
    SPFLOAT dec;
    SPFLOAT sus;
    SPFLOAT rel;
    uint32_t timer;
    uint32_t atk_time;
    SPFLOAT a;
    SPFLOAT b;
    SPFLOAT y;
    SPFLOAT x;
    SPFLOAT prev;
    int mode;
} sp_adsr;

int sp_adsr_create(sp_adsr **p);
int sp_adsr_destroy(sp_adsr **p);
int sp_adsr_init(sp_data *sp, sp_adsr *p);
int sp_adsr_compute(sp_data *sp, sp_adsr *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *faust;
    int argpos;
    SPFLOAT *args[3];
    SPFLOAT *level;
    SPFLOAT *wah;
    SPFLOAT *mix;
} sp_autowah;

int sp_autowah_create(sp_autowah **p);
int sp_autowah_destroy(sp_autowah **p);
int sp_autowah_init(sp_data *sp, sp_autowah *p);
int sp_autowah_compute(sp_data *sp, sp_autowah *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT min, max;
} sp_biscale;

int sp_biscale_create(sp_biscale **p);
int sp_biscale_destroy(sp_biscale **p);
int sp_biscale_init(sp_data *sp, sp_biscale *p);
int sp_biscale_compute(sp_data *sp, sp_biscale *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *ud;
    int argpos;
    SPFLOAT *args[2];
    SPFLOAT *freq;
    SPFLOAT *amp;
} sp_blsaw;

int sp_blsaw_create(sp_blsaw **p);
int sp_blsaw_destroy(sp_blsaw **p);
int sp_blsaw_init(sp_data *sp, sp_blsaw *p);
int sp_blsaw_compute(sp_data *sp, sp_blsaw *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *ud;
    int argpos;
    SPFLOAT *args[3];
    SPFLOAT *freq;
    SPFLOAT *amp;
    SPFLOAT *width;
} sp_blsquare;

int sp_blsquare_create(sp_blsquare **p);
int sp_blsquare_destroy(sp_blsquare **p);
int sp_blsquare_init(sp_data *sp, sp_blsquare *p);
int sp_blsquare_compute(sp_data *sp, sp_blsquare *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *ud;
    int argpos;
    SPFLOAT *args[2];
    SPFLOAT *freq;
    SPFLOAT *amp;
} sp_bltriangle;

int sp_bltriangle_create(sp_bltriangle **p);
int sp_bltriangle_destroy(sp_bltriangle **p);
int sp_bltriangle_init(sp_data *sp, sp_bltriangle *p);
int sp_bltriangle_compute(sp_data *sp, sp_bltriangle *p, SPFLOAT *in, SPFLOAT *out);
typedef struct  {
    SPFLOAT sr, freq;
    SPFLOAT lfreq;
    SPFLOAT a[7];
    SPFLOAT pidsr;
} sp_butlp;

int sp_butlp_create(sp_butlp **p);
int sp_butlp_destroy(sp_butlp **p);
int sp_butlp_init(sp_data *sp, sp_butlp *p);
int sp_butlp_compute(sp_data *sp, sp_butlp *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT freq, bw;
    SPFLOAT lfreq, lbw;
    SPFLOAT a[7];
    SPFLOAT pidsr, tpidsr;
} sp_butbp;

int sp_butbp_create(sp_butbp **p);
int sp_butbp_destroy(sp_butbp **p);
int sp_butbp_init(sp_data *sp, sp_butbp *p);
int sp_butbp_compute(sp_data *sp, sp_butbp *p, SPFLOAT *in, SPFLOAT *out);
typedef struct  {
    SPFLOAT freq;
    SPFLOAT lfreq;
    SPFLOAT a[7];
    SPFLOAT pidsr;
} sp_buthp;

int sp_buthp_create(sp_buthp **p);
int sp_buthp_destroy(sp_buthp **p);
int sp_buthp_init(sp_data *sp, sp_buthp *p);
int sp_buthp_compute(sp_data *sp, sp_buthp *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT freq, bw;
    SPFLOAT lfreq, lbw;
    SPFLOAT a[7];
    SPFLOAT pidsr, tpidsr;
} sp_butbr;

int sp_butbr_create(sp_butbr **p);
int sp_butbr_destroy(sp_butbr **p);
int sp_butbr_init(sp_data *sp, sp_butbr *p);
int sp_butbr_compute(sp_data *sp, sp_butbr *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT brown;
} sp_brown;

int sp_brown_create(sp_brown **p);
int sp_brown_destroy(sp_brown **p);
int sp_brown_init(sp_data *sp, sp_brown *p);
int sp_brown_compute(sp_data *sp, sp_brown *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT min;
    SPFLOAT max;
} sp_clamp;

int sp_clamp_create(sp_clamp **p);
int sp_clamp_destroy(sp_clamp **p);
int sp_clamp_init(sp_data *sp, sp_clamp *p);
int sp_clamp_compute(sp_data *sp, sp_clamp *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT bpm;
    SPFLOAT subdiv;
    uint32_t counter;
} sp_clock;

int sp_clock_create(sp_clock **p);
int sp_clock_destroy(sp_clock **p);
int sp_clock_init(sp_data *sp, sp_clock *p);
int sp_clock_compute(sp_data *sp, sp_clock *p, SPFLOAT *trig, SPFLOAT *out);
typedef struct {
    void *faust;
    int argpos;
    SPFLOAT *args[4];
    SPFLOAT *ratio;
    SPFLOAT *thresh;
    SPFLOAT *atk;
    SPFLOAT *rel;
} sp_compressor;

int sp_compressor_create(sp_compressor **p);
int sp_compressor_destroy(sp_compressor **p);
int sp_compressor_init(sp_data *sp, sp_compressor *p);
int sp_compressor_compute(sp_data *sp, sp_compressor *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_count{
    int32_t count, curcount;
    int mode;
} sp_count;

int sp_count_create(sp_count **p);
int sp_count_destroy(sp_count **p);
int sp_count_init(sp_data *sp, sp_count *p);
int sp_count_compute(sp_data *sp, sp_count *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT pos;
} sp_crossfade;

int sp_crossfade_create(sp_crossfade **p);
int sp_crossfade_destroy(sp_crossfade **p);
int sp_crossfade_init(sp_data *sp, sp_crossfade *p);
int sp_crossfade_compute(sp_data *sp, sp_crossfade *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out);
typedef struct {
    SPFLOAT time;
    SPFLOAT feedback;
    SPFLOAT last;
    SPFLOAT *buf;
    uint32_t bufsize;
    uint32_t bufpos;
} sp_delay;

int sp_delay_create(sp_delay **p);
int sp_delay_destroy(sp_delay **p);
int sp_delay_init(sp_data *sp, sp_delay *p, SPFLOAT time);
int sp_delay_compute(sp_data *sp, sp_delay *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    /* 4 one-pole filters */
    SPFLOAT opva_alpha[4];
    SPFLOAT opva_beta[4];
    SPFLOAT opva_gamma[4];
    SPFLOAT opva_delta[4];
    SPFLOAT opva_eps[4];
    SPFLOAT opva_a0[4];
    SPFLOAT opva_fdbk[4];
    SPFLOAT opva_z1[4];
    /* end one-pole filters */

    SPFLOAT SG[4];
    SPFLOAT gamma;
    SPFLOAT freq;
    SPFLOAT K;
    SPFLOAT res;
} sp_diode;

int sp_diode_create(sp_diode **p);
int sp_diode_destroy(sp_diode **p);
int sp_diode_init(sp_data *sp, sp_diode *p);
int sp_diode_compute(sp_data *sp, sp_diode *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT time;
    uint32_t counter;
} sp_dmetro;

int sp_dmetro_create(sp_dmetro **p);
int sp_dmetro_destroy(sp_dmetro **p);
int sp_dmetro_init(sp_data *sp, sp_dmetro *p);
int sp_dmetro_compute(sp_data *sp, sp_dmetro *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_dtrig{
    sp_ftbl *ft;
    uint32_t counter;
    uint32_t pos;
    int running;
    int loop;
    SPFLOAT delay;
    SPFLOAT scale;
} sp_dtrig;

int sp_dtrig_create(sp_dtrig **p);
int sp_dtrig_destroy(sp_dtrig **p);
int sp_dtrig_init(sp_data *sp, sp_dtrig *p, sp_ftbl *ft);
int sp_dtrig_compute(sp_data *sp, sp_dtrig *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT a, dur, b;
    SPFLOAT val, incr;
    uint32_t sdur, stime;
    int init;
} sp_expon;

int sp_expon_create(sp_expon **p);
int sp_expon_destroy(sp_expon **p);
int sp_expon_init(sp_data *sp, sp_expon *p);
int sp_expon_compute(sp_data *sp, sp_expon *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    FILE *fp;
} sp_in;

int sp_in_create(sp_in **p);
int sp_in_destroy(sp_in **p);
int sp_in_init(sp_data *sp, sp_in *p);
int sp_in_compute(sp_data *sp, sp_in *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT step;
    SPFLOAT min;
    SPFLOAT max;
    SPFLOAT val;
} sp_incr;

int sp_incr_create(sp_incr **p);
int sp_incr_destroy(sp_incr **p);
int sp_incr_init(sp_data *sp, sp_incr *p, SPFLOAT val);
int sp_incr_compute(sp_data *sp, sp_incr *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *ud;
} sp_jcrev;

int sp_jcrev_create(sp_jcrev **p);
int sp_jcrev_destroy(sp_jcrev **p);
int sp_jcrev_init(sp_data *sp, sp_jcrev *p);
int sp_jcrev_compute(sp_data *sp, sp_jcrev *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT a, dur, b;
    SPFLOAT val, incr;
    uint32_t sdur, stime;
    int init;
} sp_line;

int sp_line_create(sp_line **p);
int sp_line_destroy(sp_line **p);
int sp_line_init(sp_data *sp, sp_line *p);
int sp_line_compute(sp_data *sp, sp_line *p, SPFLOAT *in, SPFLOAT *out);
int sp_ftbl_loadwav(sp_data *sp, sp_ftbl **ft, const char *filename);
typedef struct {
    struct openlpc_e_state *e;
    struct openlpc_d_state *d;
    int counter;
    short *in;
    short *out;
    unsigned char data[7];
    SPFLOAT y[7];
    SPFLOAT smooth;
    SPFLOAT samp;
    unsigned int clock;
    unsigned int block;
    int framesize;
    int mode;
    sp_ftbl *ft;
} sp_lpc;

int sp_lpc_create(sp_lpc **lpc);
int sp_lpc_destroy(sp_lpc **lpc);
int sp_lpc_init(sp_data *sp, sp_lpc *lpc, int framesize);
int sp_lpc_synth(sp_data *sp, sp_lpc *lpc, sp_ftbl *ft);
int sp_lpc_compute(sp_data *sp, sp_lpc *lpc, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_maygate{
    SPFLOAT prob;
    SPFLOAT gate;
    int mode;
} sp_maygate;

int sp_maygate_create(sp_maygate **p);
int sp_maygate_destroy(sp_maygate **p);
int sp_maygate_init(sp_data *sp, sp_maygate *p);
int sp_maygate_compute(sp_data *sp, sp_maygate *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_metro{
    SPFLOAT freq;
    SPFLOAT phs;
    int init;
    SPFLOAT onedsr;
} sp_metro;

int sp_metro_create(sp_metro **p);
int sp_metro_destroy(sp_metro **p);
int sp_metro_init(sp_data *sp, sp_metro *p);
int sp_metro_compute(sp_data *sp, sp_metro *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
    SPFLOAT amp;
}sp_noise;

int sp_noise_create(sp_noise **ns);
int sp_noise_init(sp_data *sp, sp_noise *ns);
int sp_noise_compute(sp_data *sp, sp_noise *ns, SPFLOAT *in, SPFLOAT *out);
int sp_noise_destroy(sp_noise **ns);
typedef struct nano_entry {
    char name[50];
    uint32_t pos;
    uint32_t size;
    SPFLOAT speed;
    struct nano_entry *next;
} nano_entry;

typedef struct {
    int nval;
    int init;
    nano_entry root;
    nano_entry *last;
} nano_dict;

typedef struct {
    char ini[100];
    SPFLOAT curpos;
    nano_dict dict;
    int selected;
    nano_entry *sample;
    nano_entry **index;
    sp_ftbl *ft;
    int sr;
} nanosamp;

typedef struct {
    nanosamp *smp;
    uint32_t index;
    int triggered;
} sp_nsmp;

int sp_nsmp_create(sp_nsmp **p);
int sp_nsmp_destroy(sp_nsmp **p);
int sp_nsmp_init(sp_data *sp, sp_nsmp *p, sp_ftbl *ft, int sr, const char *ini);
int sp_nsmp_compute(sp_data *sp, sp_nsmp *p, SPFLOAT *in, SPFLOAT *out);

int sp_nsmp_print_index(sp_data *sp, sp_nsmp *p);
#ifndef SK_OSC_H
typedef struct sk_osc sk_osc;
#endif

typedef struct {
    SPFLOAT freq, amp, iphs;
    sk_osc *osc;
} sp_osc;

int sp_osc_create(sp_osc **osc);
int sp_osc_destroy(sp_osc **osc);
int sp_osc_init(sp_data *sp, sp_osc *osc, sp_ftbl *ft, SPFLOAT iphs);
int sp_osc_compute(sp_data *sp, sp_osc *osc, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    uint32_t windowsize;
    uint32_t half_windowsize;
    SPFLOAT stretch;
    SPFLOAT start_pos;
    SPFLOAT displace_pos;
    SPFLOAT *window;
    SPFLOAT *old_windowed_buf;
    SPFLOAT *hinv_buf;
    SPFLOAT *buf;
    SPFLOAT *output;
    sp_ftbl *ft;
    kiss_fftr_cfg fft, ifft;
    kiss_fft_cpx *tmp1, *tmp2;
    uint32_t counter;
    unsigned char wrap;
} sp_paulstretch;

int sp_paulstretch_create(sp_paulstretch **p);
int sp_paulstretch_destroy(sp_paulstretch **p);
int sp_paulstretch_init(sp_data *sp, sp_paulstretch *p, sp_ftbl *ft, SPFLOAT windowsize, SPFLOAT stretch);
int sp_paulstretch_compute(sp_data *sp, sp_paulstretch *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT atk, rel, thresh;
    SPFLOAT patk, prel;
	SPFLOAT b0_r, a1_r, b0_a, a1_a, level;
} sp_peaklim;

int sp_peaklim_create(sp_peaklim **p);
int sp_peaklim_destroy(sp_peaklim **p);
int sp_peaklim_init(sp_data *sp, sp_peaklim *p);
int sp_peaklim_compute(sp_data *sp, sp_peaklim *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *faust;
    int argpos;
    SPFLOAT *args[10];
    SPFLOAT *MaxNotch1Freq;
    SPFLOAT *MinNotch1Freq;
    SPFLOAT *Notch_width;
    SPFLOAT *NotchFreq;
    SPFLOAT *VibratoMode;
    SPFLOAT *depth;
    SPFLOAT *feedback_gain;
    SPFLOAT *invert;
    SPFLOAT *level;
    SPFLOAT *lfobpm;
} sp_phaser;

int sp_phaser_create(sp_phaser **p);
int sp_phaser_destroy(sp_phaser **p);
int sp_phaser_init(sp_data *sp, sp_phaser *p);
int sp_phaser_compute(sp_data *sp, sp_phaser *p,
	SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out1, SPFLOAT *out2);
#ifndef SK_PHASOR_H
typedef struct sk_phasor sk_phasor;
#endif

typedef struct sp_phasor{
    sk_phasor *phasor;
    SPFLOAT freq;
} sp_phasor;

int sp_phasor_create(sp_phasor **p);
int sp_phasor_destroy(sp_phasor **p);
int sp_phasor_init(sp_data *sp, sp_phasor *p, SPFLOAT iphs);
int sp_phasor_compute(sp_data *sp, sp_phasor *p, SPFLOAT *in, SPFLOAT *out);
int sp_phasor_reset(sp_data *sp, sp_phasor *p, SPFLOAT iphs);
typedef struct {
    SPFLOAT amp;
    unsigned int newrand;
    unsigned int prevrand;
    unsigned int k;
    unsigned int seed;
    unsigned int total;
    uint32_t counter;
    unsigned int dice[7];
} sp_pinknoise;

int sp_pinknoise_create(sp_pinknoise **p);
int sp_pinknoise_destroy(sp_pinknoise **p);
int sp_pinknoise_init(sp_data *sp, sp_pinknoise *p);
int sp_pinknoise_compute(sp_data *sp, sp_pinknoise *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    char type;
    uint32_t pos;
    uint32_t val;
    uint32_t cons;
} prop_event;

typedef struct {
    char type;
    void *ud;
} prop_val;

typedef struct prop_entry {
    prop_val val;
    struct prop_entry *next;
} prop_entry;

typedef struct prop_list {
    prop_entry root;
    prop_entry *last;
    uint32_t size;
    uint32_t pos;
    struct prop_list *top;
    uint32_t lvl;
} prop_list;

typedef struct {
    uint32_t stack[16];
    int pos;
} prop_stack;

typedef struct {
    uint32_t mul;
    uint32_t div;
    uint32_t tmp;
    uint32_t cons_mul;
    uint32_t cons_div;
    SPFLOAT scale;
    int mode;
    uint32_t pos;
    prop_list top;
    prop_list *main;
    prop_stack mstack;
    prop_stack cstack;
} prop_data;

typedef struct {
   prop_data *prp;
   prop_event evt;
   uint32_t count;
   SPFLOAT bpm;
   SPFLOAT lbpm;
} sp_prop;

int sp_prop_create(sp_prop **p);
int sp_prop_destroy(sp_prop **p);
int sp_prop_reset(sp_data *sp, sp_prop *p);
int sp_prop_init(sp_data *sp, sp_prop *p, const char *str);
int sp_prop_compute(sp_data *sp, sp_prop *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *faust;
    int argpos;
    SPFLOAT *args[3];
    SPFLOAT *shift;
    SPFLOAT *window;
    SPFLOAT *xfade;
} sp_pshift;

int sp_pshift_create(sp_pshift **p);
int sp_pshift_destroy(sp_pshift **p);
int sp_pshift_init(sp_data *sp, sp_pshift *p);
int sp_pshift_compute(sp_data *sp, sp_pshift *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    int mti;
    /* do not change value 624 */
    uint32_t mt[624];
} sp_randmt;

void sp_randmt_seed(sp_randmt *p,
    const uint32_t *initKey, uint32_t keyLength);

uint32_t sp_randmt_compute(sp_randmt *p);
typedef struct {
    SPFLOAT min;
    SPFLOAT max;
} sp_random;

int sp_random_create(sp_random **p);
int sp_random_destroy(sp_random **p);
int sp_random_init(sp_data *sp, sp_random *p);
int sp_random_compute(sp_data *sp, sp_random *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT freq;
    SPFLOAT min, max;
    SPFLOAT val;
    uint32_t counter, dur;
} sp_randh;

int sp_randh_create(sp_randh **p);
int sp_randh_destroy(sp_randh **p);
int sp_randh_init(sp_data *sp, sp_randh *p);
int sp_randh_compute(sp_data *sp, sp_randh *p, SPFLOAT *in, SPFLOAT *out);
typedef struct  {
    SPFLOAT delay;
    uint32_t bufpos;
    uint32_t bufsize;
    SPFLOAT *buf;
} sp_reverse;

int sp_reverse_create(sp_reverse **p);
int sp_reverse_destroy(sp_reverse **p);
int sp_reverse_init(sp_data *sp, sp_reverse *p, SPFLOAT delay);
int sp_reverse_compute(sp_data *sp, sp_reverse *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_rpt{
    uint32_t playpos;
    uint32_t bufpos;
    int running;
    int count, reps;
    SPFLOAT sr;
    uint32_t size;
    SPFLOAT bpm;
    int div, rep;
    SPFLOAT *buf;
    int rc;
    uint32_t maxlen;
} sp_rpt;

int sp_rpt_create(sp_rpt **p);
int sp_rpt_destroy(sp_rpt **p);
int sp_rpt_init(sp_data *sp, sp_rpt *p, SPFLOAT maxdur);
int sp_rpt_compute(sp_data *sp, sp_rpt *p, SPFLOAT *trig,
        SPFLOAT *in, SPFLOAT *out);
typedef struct
{
    SPFLOAT drive;
    SPFLOAT dcoffset;

    SPFLOAT dcblocker[2][7];

    SPFLOAT ai[6][7];
    SPFLOAT aa[6][7];
} sp_saturator;

int sp_saturator_create(sp_saturator **p);
int sp_saturator_destroy(sp_saturator **p);
int sp_saturator_init(sp_data *sp, sp_saturator *p);
int sp_saturator_compute(sp_data *sp, sp_saturator *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT val;
} sp_samphold;

int sp_samphold_create(sp_samphold **p);
int sp_samphold_destroy(sp_samphold **p);
int sp_samphold_init(sp_data *sp, sp_samphold *p);
int sp_samphold_compute(sp_data *sp, sp_samphold *p, SPFLOAT *trig, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT min, max;
} sp_scale;

int sp_scale_create(sp_scale **p);
int sp_scale_destroy(sp_scale **p);
int sp_scale_init(sp_data *sp, sp_scale *p);
int sp_scale_compute(sp_data *sp, sp_scale *p, SPFLOAT *in, SPFLOAT *out);
int sp_gen_scrambler(sp_data *sp, sp_ftbl *src, sp_ftbl **dest);
typedef struct {
    int size, pos;
    SPFLOAT *buf;
} sp_sdelay;

int sp_sdelay_create(sp_sdelay **p);
int sp_sdelay_destroy(sp_sdelay **p);
int sp_sdelay_init(sp_data *sp, sp_sdelay *p, int size);
int sp_sdelay_compute(sp_data *sp, sp_sdelay *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    sp_ftbl *vals;
    sp_ftbl *buf;
    uint32_t id;
    uint32_t pos;
    uint32_t nextpos;
} sp_slice;

int sp_slice_create(sp_slice **p);
int sp_slice_destroy(sp_slice **p);
int sp_slice_init(sp_data *sp, sp_slice *p, sp_ftbl *vals, sp_ftbl *buf);
int sp_slice_compute(sp_data *sp, sp_slice *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT del, maxdel, pdel;
    SPFLOAT sr;
    SPFLOAT feedback;

    int counter;
    int maxcount;

    uint32_t maxbuf;

    SPFLOAT *buf1;
    uint32_t bufpos1;
    uint32_t deltime1;

    SPFLOAT *buf2;
    uint32_t bufpos2;
    uint32_t deltime2;
    int curbuf;
} sp_smoothdelay;

int sp_smoothdelay_create(sp_smoothdelay **p);
int sp_smoothdelay_destroy(sp_smoothdelay **p);
int sp_smoothdelay_init(sp_data *sp, sp_smoothdelay *p,
        SPFLOAT maxdel, uint32_t interp);
int sp_smoothdelay_compute(sp_data *sp, sp_smoothdelay *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
    SPFLOAT smooth;
    SPFLOAT a1, b0, y0, psmooth;
    SPFLOAT onedsr;
}sp_smoother;

int sp_smoother_create(sp_smoother **p);
int sp_smoother_destroy(sp_smoother **p);
int sp_smoother_init(sp_data *sp, sp_smoother *p);
int sp_smoother_compute(sp_data *sp, sp_smoother *p, SPFLOAT *in, SPFLOAT *out);
int sp_smoother_reset(sp_data *sp, sp_smoother *p, SPFLOAT *in);
typedef struct {
    SPFLOAT *buf;
    uint32_t pos;
    uint32_t bufsize;
    sp_audio spa;
} sp_spa;

int sp_spa_create(sp_spa **p);
int sp_spa_destroy(sp_spa **p);
int sp_spa_init(sp_data *sp, sp_spa *p, const char *filename);
int sp_spa_compute(sp_data *sp, sp_spa *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT *buf;
    uint32_t pos;
    uint32_t bufsize;
    sp_audio spa;
} sp_sparec;

int sp_sparec_create(sp_sparec **p);
int sp_sparec_destroy(sp_sparec **p);
int sp_sparec_init(sp_data *sp, sp_sparec *p, const char *filename);
int sp_sparec_compute(sp_data *sp, sp_sparec *p, SPFLOAT *in, SPFLOAT *out);
int sp_sparec_close(sp_data *sp, sp_sparec *p);
typedef struct {
    SPFLOAT mode;
} sp_switch;

int sp_switch_create(sp_switch **p);
int sp_switch_destroy(sp_switch **p);
int sp_switch_init(sp_data *sp, sp_switch *p);
int sp_switch_compute(sp_data *sp, sp_switch *p, SPFLOAT *trig,
    SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out);
typedef struct {
    SPFLOAT value;
    SPFLOAT target;
    SPFLOAT rate;
    int state;
    SPFLOAT attackRate;
    SPFLOAT decayRate;
    SPFLOAT sustainLevel;
    SPFLOAT releaseRate;
    SPFLOAT atk;
    SPFLOAT rel;
    SPFLOAT sus;
    SPFLOAT dec;
    int mode;
} sp_tadsr;

int sp_tadsr_create(sp_tadsr **p);
int sp_tadsr_destroy(sp_tadsr **p);
int sp_tadsr_init(sp_data *sp, sp_tadsr *p);
int sp_tadsr_compute(sp_data *sp, sp_tadsr *p, SPFLOAT *trig, SPFLOAT *out);

#ifndef SP_TALKBOX_BUFMAX
#define SP_TALKBOX_BUFMAX 1600
#endif

typedef struct {
    SPFLOAT quality;
    SPFLOAT d0, d1, d2, d3, d4;
    SPFLOAT u0, u1, u2, u3, u4;
    SPFLOAT FX;
    SPFLOAT emphasis;
    SPFLOAT car0[SP_TALKBOX_BUFMAX];
    SPFLOAT car1[SP_TALKBOX_BUFMAX];
    SPFLOAT window[SP_TALKBOX_BUFMAX];
    SPFLOAT buf0[SP_TALKBOX_BUFMAX];
    SPFLOAT buf1[SP_TALKBOX_BUFMAX];
    uint32_t K, N, O, pos;
} sp_talkbox;

int sp_talkbox_create(sp_talkbox **p);
int sp_talkbox_destroy(sp_talkbox **p);
int sp_talkbox_init(sp_data *sp, sp_talkbox *p);
int sp_talkbox_compute(sp_data *sp, sp_talkbox *p, SPFLOAT *src, SPFLOAT *exc, SPFLOAT *out);
typedef struct {
    sp_ftbl *ft;
    uint32_t index;
    int record;
} sp_tblrec;

int sp_tblrec_create(sp_tblrec **p);
int sp_tblrec_destroy(sp_tblrec **p);
int sp_tblrec_init(sp_data *sp, sp_tblrec *p, sp_ftbl *ft);
int sp_tblrec_compute(sp_data *sp, sp_tblrec *p, SPFLOAT *in, SPFLOAT *trig, SPFLOAT *out);
typedef struct {
    uint32_t num, counter, offset;
} sp_tdiv;

int sp_tdiv_create(sp_tdiv **p);
int sp_tdiv_destroy(sp_tdiv **p);
int sp_tdiv_init(sp_data *sp, sp_tdiv *p);
int sp_tdiv_compute(sp_data *sp, sp_tdiv *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_tenv{
    uint32_t pos, atk_end, rel_start, sr, totaldur;
    SPFLOAT atk, rel, hold;
    SPFLOAT atk_slp, rel_slp;
    SPFLOAT last;
    int sigmode;
    SPFLOAT input;
    int started;
} sp_tenv;

int sp_tenv_create(sp_tenv **p);
int sp_tenv_destroy(sp_tenv **p);
int sp_tenv_init(sp_data *sp, sp_tenv *p);
int sp_tenv_compute(sp_data *sp, sp_tenv *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    int state;
    SPFLOAT atk, rel;
    uint32_t totaltime;
    uint32_t timer;
    SPFLOAT slope;
    SPFLOAT last;
} sp_tenv2;

int sp_tenv2_create(sp_tenv2 **p);
int sp_tenv2_destroy(sp_tenv2 **p);
int sp_tenv2_init(sp_data *sp, sp_tenv2 *p);
int sp_tenv2_compute(sp_data *sp, sp_tenv2 *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_tenvx{
    SPFLOAT atk, rel, hold;
    SPFLOAT patk, prel;
    uint32_t count;
    SPFLOAT a_a, b_a;
    SPFLOAT a_r, b_r;
    SPFLOAT y;
} sp_tenvx;

int sp_tenvx_create(sp_tenvx **p);
int sp_tenvx_destroy(sp_tenvx **p);
int sp_tenvx_init(sp_data *sp, sp_tenvx *p);
int sp_tenvx_compute(sp_data *sp, sp_tenvx *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT time;
    uint32_t timer;
} sp_tgate;

int sp_tgate_create(sp_tgate **p);
int sp_tgate_destroy(sp_tgate **p);
int sp_tgate_init(sp_data *sp, sp_tgate *p);
int sp_tgate_compute(sp_data *sp, sp_tgate *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    int init;
    SPFLOAT prev, thresh, mode;
} sp_thresh;

int sp_thresh_create(sp_thresh **p);
int sp_thresh_destroy(sp_thresh **p);
int sp_thresh_init(sp_data *sp, sp_thresh *p);
int sp_thresh_compute(sp_data *sp, sp_thresh *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    int mode;
    uint32_t pos;
    SPFLOAT time;
} sp_timer;

int sp_timer_create(sp_timer **p);
int sp_timer_destroy(sp_timer **p);
int sp_timer_init(sp_data *sp, sp_timer *p);
int sp_timer_compute(sp_data *sp, sp_timer *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    FILE *fp;
    SPFLOAT val;
} sp_tin;

int sp_tin_create(sp_tin **p);
int sp_tin_destroy(sp_tin **p);
int sp_tin_init(sp_data *sp, sp_tin *p);
int sp_tin_compute(sp_data *sp, sp_tin *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT min, max, val;
} sp_trand;

int sp_trand_create(sp_trand **p);
int sp_trand_destroy(sp_trand **p);
int sp_trand_init(sp_data *sp, sp_trand *p);
int sp_trand_compute(sp_data *sp, sp_trand *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT beg,dur,end;
    uint32_t steps;
    uint32_t count;
    SPFLOAT val;
    SPFLOAT type;
    SPFLOAT slope;
    SPFLOAT tdivnsteps;
} sp_tseg;

int sp_tseg_create(sp_tseg **p);
int sp_tseg_destroy(sp_tseg **p);
int sp_tseg_init(sp_data *sp, sp_tseg *p, SPFLOAT ibeg);
int sp_tseg_compute(sp_data *sp, sp_tseg *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_tseq {
    sp_ftbl *ft;
    SPFLOAT val;
    int32_t pos;
    int shuf;
} sp_tseq;

int sp_tseq_create(sp_tseq **p);
int sp_tseq_destroy(sp_tseq **p);
int sp_tseq_init(sp_data *sp, sp_tseq *p, sp_ftbl *ft);
int sp_tseq_compute(sp_data *sp, sp_tseq *p, SPFLOAT *trig, SPFLOAT *val);

#ifndef SP_VOC
#define SP_VOC
typedef struct sp_voc sp_voc;

int sp_voc_create(sp_voc **voc);
int sp_voc_destroy(sp_voc **voc);
int sp_voc_init(sp_data *sp, sp_voc *voc);
int sp_voc_compute(sp_data *sp, sp_voc *voc, SPFLOAT *out);
int sp_voc_tract_compute(sp_data *sp, sp_voc *voc, SPFLOAT *in, SPFLOAT *out);

void sp_voc_set_frequency(sp_voc *voc, SPFLOAT freq);
SPFLOAT * sp_voc_get_frequency_ptr(sp_voc *voc);

SPFLOAT* sp_voc_get_tract_diameters(sp_voc *voc);
SPFLOAT* sp_voc_get_current_tract_diameters(sp_voc *voc);
int sp_voc_get_tract_size(sp_voc *voc);
SPFLOAT* sp_voc_get_nose_diameters(sp_voc *voc);
int sp_voc_get_nose_size(sp_voc *voc);
void sp_voc_set_tongue_shape(sp_voc *voc,
    SPFLOAT tongue_index,
    SPFLOAT tongue_diameter);
void sp_voc_set_tenseness(sp_voc *voc, SPFLOAT breathiness);
SPFLOAT * sp_voc_get_tenseness_ptr(sp_voc *voc);
void sp_voc_set_velum(sp_voc *voc, SPFLOAT velum);
SPFLOAT * sp_voc_get_velum_ptr(sp_voc *voc);

void sp_voc_set_diameters(sp_voc *voc,
    int blade_start,
    int lip_start,
    int tip_start,
    SPFLOAT tongue_index,
    SPFLOAT tongue_diameter,
    SPFLOAT *diameters);

int sp_voc_get_counter(sp_voc *voc);


#endif
typedef struct sp_wavin sp_wavin;
int sp_wavin_create(sp_wavin **p);
int sp_wavin_destroy(sp_wavin **p);
int sp_wavin_init(sp_data *sp, sp_wavin *p, const char *filename);
int sp_wavin_compute(sp_data *sp, sp_wavin *p, SPFLOAT *in, SPFLOAT *out);
int sp_wavin_get_sample(sp_data *sp, sp_wavin *p, SPFLOAT *out, SPFLOAT pos);
int sp_wavin_reset_to_start(sp_data *sp, sp_wavin *p);
int sp_wavin_seek(sp_data *sp, sp_wavin *p, unsigned long sample);
typedef struct sp_wavout sp_wavout;
int sp_wavout_create(sp_wavout **p);
int sp_wavout_destroy(sp_wavout **p);
int sp_wavout_init(sp_data *sp, sp_wavout *p, const char *filename);
int sp_wavout_compute(sp_data *sp, sp_wavout *p, SPFLOAT *in, SPFLOAT *out);
int sp_wavouts_init(sp_data *sp, sp_wavout *p, const char *filename);
int sp_wavouts_compute(sp_data *sp, sp_wavout *p,
                       SPFLOAT *inL, SPFLOAT *inR,
                       SPFLOAT *outL, SPFLOAT *outR);
typedef struct {
    /* LPF1 */
    SPFLOAT lpf1_a;
    SPFLOAT lpf1_z;

    /* LPF2 */
    SPFLOAT lpf2_a;
    SPFLOAT lpf2_b;
    SPFLOAT lpf2_z;

    /* HPF */
    SPFLOAT hpf_a;
    SPFLOAT hpf_b;
    SPFLOAT hpf_z;

    SPFLOAT alpha;

    SPFLOAT cutoff;
    SPFLOAT res;
    SPFLOAT saturation;

    SPFLOAT pcutoff;
    SPFLOAT pres;

    uint32_t nonlinear;
} sp_wpkorg35;

int sp_wpkorg35_create(sp_wpkorg35 **p);
int sp_wpkorg35_destroy(sp_wpkorg35 **p);
int sp_wpkorg35_init(sp_data *sp, sp_wpkorg35 *p);
int sp_wpkorg35_compute(sp_data *sp, sp_wpkorg35 *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *faust;
    int argpos;
    SPFLOAT *args[11];
    SPFLOAT *in_delay;
    SPFLOAT *lf_x;
    SPFLOAT *rt60_low;
    SPFLOAT *rt60_mid;
    SPFLOAT *hf_damping;
    SPFLOAT *eq1_freq;
    SPFLOAT *eq1_level;
    SPFLOAT *eq2_freq;
    SPFLOAT *eq2_level;
    SPFLOAT *mix;
    SPFLOAT *level;
} sp_zitarev;

int sp_zitarev_create(sp_zitarev **p);
int sp_zitarev_destroy(sp_zitarev **p);
int sp_zitarev_init(sp_data *sp, sp_zitarev *p);
int sp_zitarev_compute(sp_data *sp, sp_zitarev *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out1, SPFLOAT *out2);
typedef struct {
    SPFLOAT bitdepth;
    SPFLOAT srate;

    SPFLOAT incr;
    SPFLOAT index;
    int32_t sample_index;
    SPFLOAT value;
} sp_bitcrush;

int sp_bitcrush_create(sp_bitcrush **p);
int sp_bitcrush_destroy(sp_bitcrush **p);
int sp_bitcrush_init(sp_data *sp, sp_bitcrush *p);
int sp_bitcrush_compute(sp_data *sp, sp_bitcrush *p, SPFLOAT *in, SPFLOAT *out);
#ifndef SK_BIGVERB_H
typedef struct sk_bigverb sk_bigverb;
#endif

typedef struct {
    SPFLOAT feedback, lpfreq;
    sk_bigverb *bv;
} sp_bigverb;

int sp_bigverb_create(sp_bigverb **p);
int sp_bigverb_destroy(sp_bigverb **p);
int sp_bigverb_init(sp_data *sp, sp_bigverb *p);
int sp_bigverb_compute(sp_data *sp,
                       sp_bigverb *p,
                       SPFLOAT *in1,
                       SPFLOAT *in2,
                       SPFLOAT *out1,
                       SPFLOAT *out2);
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
#ifndef SK_FMPAIR_H
typedef struct sk_fmpair sk_fmpair;
#endif

typedef struct {
    SPFLOAT amp, freq, car, mod, indx;
    sk_fmpair *fmpair;
} sp_fmpair;

int sp_fmpair_create(sp_fmpair **p);
int sp_fmpair_destroy(sp_fmpair **p);
int sp_fmpair_init(sp_data *sp, sp_fmpair *p, sp_ftbl *ft);
int sp_fmpair_compute(sp_data *sp, sp_fmpair *p,
                      SPFLOAT *in, SPFLOAT *out);
#ifndef SK_RLINE_H
typedef struct sk_rline sk_rline;
#endif

typedef struct {
    SPFLOAT min, max, cps;
    sk_rline *rline;
} sp_rline;

int sp_rline_create(sp_rline **p);
int sp_rline_destroy(sp_rline **p);
int sp_rline_init(sp_data *sp, sp_rline *p);
int sp_rline_compute(sp_data *sp, sp_rline *p,
                         SPFLOAT *in, SPFLOAT *out);
#ifndef SK_VARDELAY_H
typedef struct sk_vardelay sk_vardelay;
#endif

typedef struct {
    SPFLOAT del, maxdel;
    SPFLOAT feedback;
    sk_vardelay *v;
    SPFLOAT *buf;
} sp_vardelay;

int sp_vardelay_create(sp_vardelay **p);
int sp_vardelay_destroy(sp_vardelay **p);
int sp_vardelay_init(sp_data *sp, sp_vardelay *p, SPFLOAT maxdel);
int sp_vardelay_compute(sp_data *sp,
                       sp_vardelay *p,
                       SPFLOAT *in,
                       SPFLOAT *out);
#ifndef SK_PEAKEQ_H
typedef struct sk_peakeq sk_peakeq;
#endif

typedef struct {
    SPFLOAT freq, bw, gain;
    sk_peakeq *peakeq;
} sp_peakeq;

int sp_peakeq_create(sp_peakeq **p);
int sp_peakeq_destroy(sp_peakeq **p);
int sp_peakeq_init(sp_data *sp, sp_peakeq *p);
int sp_peakeq_compute(sp_data *sp, sp_peakeq *p,
                      SPFLOAT *in, SPFLOAT *out);
#ifndef SK_MODALRES_H
typedef struct sk_modalres sk_modalres;
#endif

typedef struct {
    SPFLOAT freq, q;
    sk_modalres *modalres;
} sp_modalres;

int sp_modalres_create(sp_modalres **p);
int sp_modalres_destroy(sp_modalres **p);
int sp_modalres_init(sp_data *sp, sp_modalres *p);
int sp_modalres_compute(sp_data *sp, sp_modalres *p,
                      SPFLOAT *in, SPFLOAT *out);
#ifndef SK_PHASEWARP_H
typedef struct sk_phasewarp sk_phasewarp;
#endif

typedef struct {
    SPFLOAT amount;
} sp_phasewarp;

int sp_phasewarp_create(sp_phasewarp **p);
int sp_phasewarp_destroy(sp_phasewarp **p);
int sp_phasewarp_init(sp_data *sp, sp_phasewarp *p);
int sp_phasewarp_compute(sp_data *sp, sp_phasewarp *p,
                      SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT index, offset, wrap;
    int mode;
    SPFLOAT mul;
    sp_ftbl *ft;
} sp_tread;

int sp_tread_create(sp_tread **p);
int sp_tread_destroy(sp_tread **p);
int sp_tread_init(sp_data *sp, sp_tread *p, sp_ftbl *ft, int mode);
int sp_tread_compute(sp_data *sp, sp_tread *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT freq, amp, iphs;
    int32_t lphs;
    sp_ftbl **tbl;

    /* magic constants */
    uint32_t nlb;
    SPFLOAT inlb;
    uint32_t mask;
    SPFLOAT maxlens;

    int inc;
    SPFLOAT wtpos;
    int nft;
} sp_oscmorph;

int sp_oscmorph_create(sp_oscmorph **p);
int sp_oscmorph_destroy(sp_oscmorph **p);
int sp_oscmorph_init(sp_data *sp,
                     sp_oscmorph *osc,
                     sp_ftbl **ft,
                     int nft,
                     SPFLOAT iphs);
int sp_oscmorph_compute(sp_data *sp,
                        sp_oscmorph *p,
                        SPFLOAT *in,
                        SPFLOAT *out);
typedef struct {
    SPFLOAT bigness;
    SPFLOAT longness;
    SPFLOAT darkness;

	SPFLOAT iirAL;
	SPFLOAT iirBL;

	SPFLOAT aIL[6480];
	SPFLOAT aJL[3660];
	SPFLOAT aKL[1720];
	SPFLOAT aLL[680];

	SPFLOAT aAL[9700];
	SPFLOAT aBL[6000];
	SPFLOAT aCL[2320];
	SPFLOAT aDL[940];

	SPFLOAT aEL[15220];
	SPFLOAT aFL[8460];
	SPFLOAT aGL[4540];
	SPFLOAT aHL[3200];

	SPFLOAT feedbackAL;
	SPFLOAT feedbackBL;
	SPFLOAT feedbackCL;
	SPFLOAT feedbackDL;
	SPFLOAT previousAL;
	SPFLOAT previousBL;
	SPFLOAT previousCL;
	SPFLOAT previousDL;

	SPFLOAT lastRefL[7];
	SPFLOAT thunderL;

	SPFLOAT iirAR;
	SPFLOAT iirBR;

	SPFLOAT aIR[6480];
	SPFLOAT aJR[3660];
	SPFLOAT aKR[1720];
	SPFLOAT aLR[680];

	SPFLOAT aAR[9700];
	SPFLOAT aBR[6000];
	SPFLOAT aCR[2320];
	SPFLOAT aDR[940];

	SPFLOAT aER[15220];
	SPFLOAT aFR[8460];
	SPFLOAT aGR[4540];
	SPFLOAT aHR[3200];

	SPFLOAT feedbackAR;
	SPFLOAT feedbackBR;
	SPFLOAT feedbackCR;
	SPFLOAT feedbackDR;
	SPFLOAT previousAR;
	SPFLOAT previousBR;
	SPFLOAT previousCR;
	SPFLOAT previousDR;

	SPFLOAT lastRefR[7];
	SPFLOAT thunderR;

	int countA, delayA;
	int countB, delayB;
	int countC, delayC;
	int countD, delayD;
	int countE, delayE;
	int countF, delayF;
	int countG, delayG;
	int countH, delayH;
	int countI, delayI;
	int countJ, delayJ;
	int countK, delayK;
	int countL, delayL;
	int cycle;

    int sr;

    SPFLOAT psize;
    SPFLOAT onedsr;
} sp_verbity;

int sp_verbity_create(sp_verbity **v);
int sp_verbity_destroy(sp_verbity **v);
int sp_verbity_init(sp_data *sp, sp_verbity *v);
int sp_verbity_compute(sp_data *sp,
                       sp_verbity *v,
                       SPFLOAT *inL, SPFLOAT *inR,
                       SPFLOAT *outL, SPFLOAT *outR);
void sp_verbity_bigness(sp_verbity *c, SPFLOAT bigness);
void sp_verbity_longness(sp_verbity *c, SPFLOAT longness);
void sp_verbity_darkness(sp_verbity *c, SPFLOAT darkness);
void sp_verbity_reset(sp_verbity *v, int sr);
#ifdef USE_FFTW3
#include <fftw3.h>
#endif

#define fftw_real double
#define rfftw_plan fftw_plan

typedef struct FFTFREQS {
    int size;
    SPFLOAT *s,*c;
} FFTFREQS;

typedef struct {
    int fftsize;
#ifdef USE_FFTW3
    fftw_real *tmpfftdata1, *tmpfftdata2;
    rfftw_plan planfftw,planfftw_inv;
#else
    kiss_fftr_cfg fft, ifft;
    kiss_fft_cpx *tmp1, *tmp2;
#endif
} FFTwrapper;

void FFTwrapper_create(FFTwrapper **fw, int fftsize);
void FFTwrapper_destroy(FFTwrapper **fw);

void newFFTFREQS(FFTFREQS *f, int size);
void deleteFFTFREQS(FFTFREQS *f);

void smps2freqs(FFTwrapper *ft, SPFLOAT *smps, FFTFREQS *freqs);
void freqs2smps(FFTwrapper *ft, FFTFREQS *freqs, SPFLOAT *smps);
typedef struct sp_padsynth {
    SPFLOAT cps;
    SPFLOAT bw;
    sp_ftbl *amps;
} sp_padsynth;

int sp_gen_padsynth(sp_data *sp, sp_ftbl *ps, sp_ftbl *amps, SPFLOAT f, SPFLOAT bw);

SPFLOAT sp_padsynth_profile(SPFLOAT fi, SPFLOAT bwi);

int sp_padsynth_ifft(int N, SPFLOAT *freq_amp,
        SPFLOAT *freq_phase, SPFLOAT *smp);

int sp_padsynth_normalize(int N, SPFLOAT *smp);
/* This file is placed in the public domain */
#ifndef SPA_H
#define SPA_H
int spa_open(sp_data *sp, sp_audio *spa, const char *name, int mode);
size_t spa_write_buf(sp_data *sp, sp_audio *spa, SPFLOAT *buf, uint32_t size);
size_t spa_read_buf(sp_data *sp, sp_audio *spa, SPFLOAT *buf, uint32_t size);
int spa_close(sp_audio *spa);
#endif
#endif
