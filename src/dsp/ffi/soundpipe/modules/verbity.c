/*
 * Verbity
 *
 * This is a self-contained ANSI-C soundpipe port of the
 * Verbity
 * VST plugin by Chris Johnson of AirWindows:
 *
 * http://www.airwindows.com/verbity/
 *
 * In addition to the C++->C rewrites, a few notable
 * adjustments have been made to the
 * algorithm. Wet/Dry control has been removed in favor
 * of 100% wet (balance can be done externally).
 * The dithering has been taken out as well (empirically,
 * this seemed to be a CPU hog).
 *
 * The original C++ code is under an MIT license
 * (same license as Soundpipe), Copyright 2021 Chris
 * Johnson.
 *
 * If you like this plugin, please please please consider
 * supporting Chris and AirWindows via Patreon:
 * https://www.patreon.com/airwindows
 *
 */

#include <stdint.h>
#include <stdlib.h>
#include <math.h>

#include "soundpipe.h"

int sp_verbity_create(sp_verbity **p)
{
    *p = malloc(sizeof(sp_verbity));
    return SP_OK;
}

int sp_verbity_destroy(sp_verbity **p)
{
    free(*p);
    return SP_OK;
}

void sp_verbity_reset(sp_verbity *v, int sr)
{
    int count;

    v->sr = sr;

    v->bigness = 0.25;
    v->longness = 0.0;
    v->darkness = 0.25;

    v->iirAL = 0.0;
    v->iirAR = 0.0;

    v->iirBL = 0.0;
    v->iirBR = 0.0;

    for (count = 0; count < 6479; count++) {
        v->aIL[count] = 0.0;
        v->aIR[count] = 0.0;
    }

    for (count = 0; count < 3659; count++) {
        v->aJL[count] = 0.0;
        v->aJR[count] = 0.0;
    }

    for (count = 0; count < 1719; count++) {
        v->aKL[count] = 0.0;
        v->aKR[count] = 0.0;
    }

    for (count = 0; count < 679; count++) {
        v->aLL[count] = 0.0;
        v->aLR[count] = 0.0;
    }

    for (count = 0; count < 9699; count++) {
        v->aAL[count] = 0.0;
        v->aAR[count] = 0.0;
    }

    for (count = 0; count < 5999; count++) {
        v->aBL[count] = 0.0;
        v->aBR[count] = 0.0;
    }

    for (count = 0; count < 2319; count++) {
        v->aCL[count] = 0.0;
        v->aCR[count] = 0.0;
    }

    for (count = 0; count < 939; count++) {
        v->aDL[count] = 0.0;
        v->aDR[count] = 0.0;
    }

    for (count = 0; count < 15219; count++) {
        v->aEL[count] = 0.0;
        v->aER[count] = 0.0;
    }

    for (count = 0; count < 8459; count++) {
        v->aFL[count] = 0.0;
        v->aFR[count] = 0.0;
    }

    for (count = 0; count < 4539; count++) {
        v->aGL[count] = 0.0;
        v->aGR[count] = 0.0;
    }

    for (count = 0; count < 3199; count++) {
        v->aHL[count] = 0.0;
        v->aHR[count] = 0.0;
    }

    v->feedbackAL = 0.0; v->feedbackAR = 0.0;
    v->feedbackBL = 0.0; v->feedbackBR = 0.0;
    v->feedbackCL = 0.0; v->feedbackCR = 0.0;
    v->feedbackDL = 0.0; v->feedbackDR = 0.0;
    v->previousAL = 0.0; v->previousAR = 0.0;
    v->previousBL = 0.0; v->previousBR = 0.0;
    v->previousCL = 0.0; v->previousCR = 0.0;
    v->previousDL = 0.0; v->previousDR = 0.0;

    for (count = 0; count < 6; count++) {
        v->lastRefL[count] = 0.0;
        v->lastRefR[count] = 0.0;
    }

    v->thunderL = 0;
    v->thunderR = 0;

    v->countI = 1;
    v->countJ = 1;
    v->countK = 1;
    v->countL = 1;

    v->countA = 1;
    v->countB = 1;
    v->countC = 1;
    v->countD = 1;

    v->countE = 1;
    v->countF = 1;
    v->countG = 1;
    v->countH = 1;
    v->cycle = 0;

    v->psize = -1;
    v->onedsr = 1.0 / sr;
}

int sp_verbity_init(sp_data *sp, sp_verbity *v)
{
    sp_verbity_reset(v, sp->sr);
    return SP_OK;
}

int sp_verbity_compute(sp_data *sp,
                       sp_verbity *v,
                       SPFLOAT *inL, SPFLOAT *inR,
                       SPFLOAT *outL, SPFLOAT *outR)
{
    SPFLOAT overallscale;
    int cycleEnd;
    SPFLOAT size;
    SPFLOAT regen;
    SPFLOAT lowpass;
    SPFLOAT interpolate;
    SPFLOAT thunderAmount;
    SPFLOAT inputSampleL;
    SPFLOAT inputSampleR;

    overallscale = 1.0;
    overallscale *= v->onedsr;
    overallscale *= v->sr;

    cycleEnd = floor(overallscale);
    if (cycleEnd < 1) cycleEnd = 1;
    if (cycleEnd > 4) cycleEnd = 4;

    /* this is going to be 2 for 88.1 or 96k,
     * 3 for silly people, 4 for 176 or 192k
     */

    /* sanity check */
    if (v->cycle > cycleEnd-1) v->cycle = cycleEnd-1;

    size = (v->bigness*1.77)+0.1;
    regen = 0.0625+(v->longness*0.03125); /* 0.09375 max; */
    lowpass = (1.0-pow(v->darkness,2.0))/sqrt(overallscale);
    interpolate = pow(v->darkness,2.0)*0.618033988749894848204586; /* has IIRlike qualities */
    thunderAmount = (0.3-(v->longness*0.22))*v->darkness*0.1;

    if (size != v->psize) {
        v->psize = size;
        v->delayI = 3407.0*size;
        v->delayJ = 1823.0*size;
        v->delayK = 859.0*size;
        v->delayL = 331.0*size;

        v->delayA = 4801.0*size;
        v->delayB = 2909.0*size;
        v->delayC = 1153.0*size;
        v->delayD = 461.0*size;

        v->delayE = 7607.0*size;
        v->delayF = 4217.0*size;
        v->delayG = 2269.0*size;
        v->delayH = 1597.0*size;
    }

    inputSampleL = *inL;
    inputSampleR = *inR;

    if (fabs(v->iirAL)<1.18e-37) v->iirAL = 0.0;
    v->iirAL =
        (v->iirAL*(1.0-lowpass)) +
        (inputSampleL*lowpass);
    inputSampleL = v->iirAL;

    if (fabs(v->iirAR)<1.18e-37) v->iirAR = 0.0;
    v->iirAR =
        (v->iirAR*(1.0-lowpass))+
        (inputSampleR*lowpass);
    inputSampleR = v->iirAR;

    /* initial filter */

    v->cycle++;
    if (v->cycle == cycleEnd) {
        /* hit the end point and we do a reverb sample */
        SPFLOAT ainterp = 1.0 - interpolate;
        v->feedbackAL = (v->feedbackAL*(ainterp))+
            (v->previousAL*interpolate);
        v->previousAL = v->feedbackAL;
        v->feedbackBL = (v->feedbackBL*(ainterp))+
            (v->previousBL*interpolate);
        v->previousBL = v->feedbackBL;
        v->feedbackCL = (v->feedbackCL*(ainterp))+
            (v->previousCL*interpolate);
        v->previousCL = v->feedbackCL;
        v->feedbackDL = (v->feedbackDL*(ainterp))+
            (v->previousDL*interpolate);
        v->previousDL = v->feedbackDL;
        v->feedbackAR = (v->feedbackAR*(ainterp))+
            (v->previousAR*interpolate);
        v->previousAR = v->feedbackAR;

        v->feedbackBR = (v->feedbackBR*(ainterp))+
            (v->previousBR*interpolate);
        v->previousBR = v->feedbackBR;
        v->feedbackCR = (v->feedbackCR*(ainterp))+
            (v->previousCR*interpolate);
        v->previousCR = v->feedbackCR;
        v->feedbackDR = (v->feedbackDR*(ainterp))+
            (v->previousDR*interpolate);
        v->previousDR = v->feedbackDR;

        v->thunderL =
            (v->thunderL*0.99)-(v->feedbackAL*thunderAmount);
        v->thunderR =
            (v->thunderR*0.99)-(v->feedbackAR*thunderAmount);

        v->aIL[v->countI] = inputSampleL +
            ((v->feedbackAL+v->thunderL) * regen);
        v->aJL[v->countJ] = inputSampleL +
            (v->feedbackBL * regen);
        v->aKL[v->countK] = inputSampleL +
            (v->feedbackCL * regen);
        v->aLL[v->countL] = inputSampleL +
            (v->feedbackDL * regen);
        v->aIR[v->countI] = inputSampleR +
            ((v->feedbackAR+v->thunderR) * regen);

        v->aJR[v->countJ] = inputSampleR +
            (v->feedbackBR * regen);
        v->aKR[v->countK] = inputSampleR +
            (v->feedbackCR * regen);
        v->aLR[v->countL] = inputSampleR +
            (v->feedbackDR * regen);

        v->countI++;
        if (v->countI < 0 || v->countI > v->delayI) v->countI = 0;

        v->countJ++;
        if (v->countJ < 0 || v->countJ > v->delayJ) v->countJ = 0;

        v->countK++;
        if (v->countK < 0 || v->countK > v->delayK) v->countK = 0;

        v->countL++;
        if (v->countL < 0 || v->countL > v->delayL) v->countL = 0;

        {
            SPFLOAT outIL = v->aIL[v->countI-((v->countI > v->delayI)?v->delayI+1:0)];
            SPFLOAT outJL = v->aJL[v->countJ-((v->countJ > v->delayJ)?v->delayJ+1:0)];
            SPFLOAT outKL = v->aKL[v->countK-((v->countK > v->delayK)?v->delayK+1:0)];
            SPFLOAT outLL = v->aLL[v->countL-((v->countL > v->delayL)?v->delayL+1:0)];
            SPFLOAT outIR = v->aIR[v->countI-((v->countI > v->delayI)?v->delayI+1:0)];
            SPFLOAT outJR = v->aJR[v->countJ-((v->countJ > v->delayJ)?v->delayJ+1:0)];
            SPFLOAT outKR = v->aKR[v->countK-((v->countK > v->delayK)?v->delayK+1:0)];
            SPFLOAT outLR = v->aLR[v->countL-((v->countL > v->delayL)?v->delayL+1:0)];
            /* first block: now we have four outputs */

            v->aAL[v->countA] = (outIL - (outJL + outKL + outLL));
            v->aBL[v->countB] = (outJL - (outIL + outKL + outLL));
            v->aCL[v->countC] = (outKL - (outIL + outJL + outLL));
            v->aDL[v->countD] = (outLL - (outIL + outJL + outKL));
            v->aAR[v->countA] = (outIR - (outJR + outKR + outLR));
            v->aBR[v->countB] = (outJR - (outIR + outKR + outLR));
            v->aCR[v->countC] = (outKR - (outIR + outJR + outLR));
            v->aDR[v->countD] = (outLR - (outIR + outJR + outKR));
        }

        v->countA++;
        if (v->countA < 0 || v->countA > v->delayA) v->countA = 0;
        v->countB++;
        if (v->countB < 0 || v->countB > v->delayB) v->countB = 0;
        v->countC++;
        if (v->countC < 0 || v->countC > v->delayC) v->countC = 0;
        v->countD++;
        if (v->countD < 0 || v->countD > v->delayD) v->countD = 0;

        {
            SPFLOAT outAL = v->aAL[v->countA-((v->countA > v->delayA)?v->delayA+1:0)];
            SPFLOAT outBL = v->aBL[v->countB-((v->countB > v->delayB)?v->delayB+1:0)];
            SPFLOAT outCL = v->aCL[v->countC-((v->countC > v->delayC)?v->delayC+1:0)];
            SPFLOAT outDL = v->aDL[v->countD-((v->countD > v->delayD)?v->delayD+1:0)];
            SPFLOAT outAR = v->aAR[v->countA-((v->countA > v->delayA)?v->delayA+1:0)];
            SPFLOAT outBR = v->aBR[v->countB-((v->countB > v->delayB)?v->delayB+1:0)];
            SPFLOAT outCR = v->aCR[v->countC-((v->countC > v->delayC)?v->delayC+1:0)];
            SPFLOAT outDR = v->aDR[v->countD-((v->countD > v->delayD)?v->delayD+1:0)];

            /* second block: four more outputs */

            v->aEL[v->countE] = (outAL - (outBL + outCL + outDL));
            v->aFL[v->countF] = (outBL - (outAL + outCL + outDL));
            v->aGL[v->countG] = (outCL - (outAL + outBL + outDL));
            v->aHL[v->countH] = (outDL - (outAL + outBL + outCL));
            v->aER[v->countE] = (outAR - (outBR + outCR + outDR));
            v->aFR[v->countF] = (outBR - (outAR + outCR + outDR));
            v->aGR[v->countG] = (outCR - (outAR + outBR + outDR));
            v->aHR[v->countH] = (outDR - (outAR + outBR + outCR));
        }

        v->countE++;
        if (v->countE < 0 || v->countE > v->delayE) v->countE = 0;

        v->countF++;
        if (v->countF < 0 || v->countF > v->delayF) v->countF = 0;

        v->countG++;
        if (v->countG < 0 || v->countG > v->delayG) v->countG = 0;

        v->countH++;
        if (v->countH < 0 || v->countH > v->delayH) v->countH = 0;

        {
            SPFLOAT outEL = v->aEL[v->countE-((v->countE > v->delayE)?v->delayE+1:0)];
            SPFLOAT outFL = v->aFL[v->countF-((v->countF > v->delayF)?v->delayF+1:0)];
            SPFLOAT outGL = v->aGL[v->countG-((v->countG > v->delayG)?v->delayG+1:0)];
            SPFLOAT outHL = v->aHL[v->countH-((v->countH > v->delayH)?v->delayH+1:0)];
            SPFLOAT outER = v->aER[v->countE-((v->countE > v->delayE)?v->delayE+1:0)];
            SPFLOAT outFR = v->aFR[v->countF-((v->countF > v->delayF)?v->delayF+1:0)];
            SPFLOAT outGR = v->aGR[v->countG-((v->countG > v->delayG)?v->delayG+1:0)];
            SPFLOAT outHR = v->aHR[v->countH-((v->countH > v->delayH)?v->delayH+1:0)];
            /* third block: final outputs */

            v->feedbackAL = (outEL - (outFL + outGL + outHL));
            v->feedbackBL = (outFL - (outEL + outGL + outHL));
            v->feedbackCL = (outGL - (outEL + outFL + outHL));
            v->feedbackDL = (outHL - (outEL + outFL + outGL));
            v->feedbackAR = (outER - (outFR + outGR + outHR));
            v->feedbackBR = (outFR - (outER + outGR + outHR));
            v->feedbackCR = (outGR - (outER + outFR + outHR));
            v->feedbackDR = (outHR - (outER + outFR + outGR));

            /* which we need to feed back into the input again, a bit */

            inputSampleL = (outEL + outFL + outGL + outHL) * 0.125;
            inputSampleR = (outER + outFR + outGR + outHR) * 0.125;
        }

        /* and take the final combined sum of outputs */
        if (cycleEnd == 4) {
            /* start from previous last */
            v->lastRefL[0] = v->lastRefL[4];

            /* half */
            v->lastRefL[2] = (v->lastRefL[0] + inputSampleL) * 0.5;

            /* one quarter */
            v->lastRefL[1] = (v->lastRefL[0] + v->lastRefL[2]) * 0.5;

            /* three quarters */
            v->lastRefL[3] = (v->lastRefL[2] + inputSampleL) * 0.5;

            /* full */
            v->lastRefL[4] = inputSampleL;

            /* start from previous last */
            v->lastRefR[0] = v->lastRefR[4];

            /* half */
            v->lastRefR[2] = (v->lastRefR[0] + inputSampleR) * 0.5;

            /* one quarter */
            v->lastRefR[1] = (v->lastRefR[0] + v->lastRefR[2]) * 0.5;
            /* three quarters */
            v->lastRefR[3] = (v->lastRefR[2] + inputSampleR) * 0.5;
            /* full */
            v->lastRefR[4] = inputSampleR;
        }
        if (cycleEnd == 3) {
            /* start from previous last */
            v->lastRefL[0] = v->lastRefL[3];
            /* third */
            v->lastRefL[2] = (v->lastRefL[0]+v->lastRefL[0]+inputSampleL) * 0.33333;
            /* two thirds */
            v->lastRefL[1] = (v->lastRefL[0]+inputSampleL+inputSampleL) * 0.33333;
            /* full */
            v->lastRefL[3] = inputSampleL;
            /* start from previous last */
            v->lastRefR[0] = v->lastRefR[3];

            /* third */
            v->lastRefR[2] = (v->lastRefR[0]+v->lastRefR[0]+inputSampleR) * 0.33333;
            /* two thirds */
            v->lastRefR[1] = (v->lastRefR[0]+inputSampleR+inputSampleR) * 0.33333;

            /* full */
            v->lastRefR[3] = inputSampleR;
        }

        if (cycleEnd == 2) {
            /* start from previous last */
            v->lastRefL[0] = v->lastRefL[2];
            /* half */
            v->lastRefL[1] = (v->lastRefL[0] + inputSampleL) * 0.5;
            /* full */
            v->lastRefL[2] = inputSampleL;

            /* start from previous last */
            v->lastRefR[0] = v->lastRefR[2];

            /* half */
            v->lastRefR[1] = (v->lastRefR[0] + inputSampleR) * 0.5;

            /* full */
            v->lastRefR[2] = inputSampleR;
        }
        v->cycle = 0; /* reset */
    } else {
        inputSampleL = v->lastRefL[v->cycle];
        inputSampleR = v->lastRefR[v->cycle];
        /* we are going through our references now */
    }

    if (fabs(v->iirBL)<1.18e-37) v->iirBL = 0.0;
    v->iirBL = (v->iirBL*(1.0-lowpass))+(inputSampleL*lowpass);
    inputSampleL = v->iirBL;
    if (fabs(v->iirBR)<1.18e-37) v->iirBR = 0.0;
    v->iirBR = (v->iirBR*(1.0-lowpass))+(inputSampleR*lowpass);
    inputSampleR = v->iirBR;

    *outL = inputSampleL;
    *outR = inputSampleR;

    return SP_OK;
}

void sp_verbity_bigness(sp_verbity *c, SPFLOAT bigness)
{
    c->bigness = bigness;
}

void sp_verbity_longness(sp_verbity *c, SPFLOAT longness)
{
    c->longness = longness;
}

void sp_verbity_darkness(sp_verbity *c, SPFLOAT darkness)
{
    c->darkness = darkness;
}
