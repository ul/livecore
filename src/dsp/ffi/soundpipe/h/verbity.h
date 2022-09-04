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
