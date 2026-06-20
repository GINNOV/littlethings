#ifndef CIATIMER_H
#define CIATIMER_H

/* Send this to StartSampling() if you just want to check the timer status */
/* or to AllocParallel(), to see if parallel is available */
#define CHECK_STATUS	2

/* timeslice is 46911 intervals.  Each interval is 1.397 microseconds,
 * this should correspond to a timing interval of 65536 microseconds */
#define CIA_TIME_SLICE ((unsigned short) 46911)
#define CIATIMER_INTERRUPT_NAME "AmiPhone Sampling Timer"
#define SILENCE (UsesInvertedSamples() ? -1L : 0L)


struct IntInfo {
	UBYTE	    * pubIndex;		/* 0 - pointer to next open spot */
	UBYTE 	    * pubArray;		/* 4 - pointer to beginning of array */
	UBYTE	    * pubSampleAt;	/* 8 - byte address to sample at */
	UBYTE	    * pubHalfIndex;	/* 12 - pointer to halfway point */
	UBYTE	    * pubEndIndex;	/* 16 - pointer to end of array */
	struct Task * stTask;		/* 20 - pointer to task to signal when a buffer is ready */
	ULONG	      ulHalfSignal;	/* 24 - signal mask for left buffer */
	ULONG	      ulFullSignal;	/* 28 - signal mask for right buffer */
	ULONG 	      ulShiftLeft;	/* 32 - number of positions to shift each sample left by */
	ULONG	      ulByteSum;	/* 36 - Current sum of all bytes */
	ULONG	      ulSaveByteSum;	/* 40 - Sum of all bytes in last packet */
	ULONG	      ulThreshhold;	/* 44 - minimum value to raise sampling rate */
	UBYTE       * pubCiahi;	        /* 52 - address of high CIA countdown byte */
	UBYTE       * pubCialo;		/* 56 - address of low CIA countdown byte */
	ULONG	      uwCiavals; 	/* 60 - values to put in hi & low cia bytes */
	ULONG	      uwClearCode;	/* 64 - Value to put in intreq(A0) to signal interrupt handled */
	ULONG	      BIdle;		/* 68 - Boolean showing whether or not we are currently idle */
	ULONG	      ulDebug1;		/* 72 - debug output field 1 */
	ULONG	      ulDebug2;		/* 76 - debug output field 2 */
};


/* Function prototypes */
BOOL AllocParallel(BOOL BAlloc, BOOL BGrab);
BOOL StartSampling(BOOL BStart, ULONG ulBytesPerSec);
BOOL AllocSignals (BOOL BAlloc);
ULONG ChangeSampleSpeed(ULONG ulNewBPS, UBYTE bComp);
BOOL TellOtherAmiPhoneToLetGo(char * szOtherPhoneName);
BOOL SetupPreSendQueue(BOOL BSetup);

ULONG ProcessToccataBuffer(UBYTE * pubData, ULONG ulDataLen);
ULONG ProcessAHIBuffer(UBYTE * pubData, ULONG * ulDataLen, ULONG ulType);

void TransmitData(UBYTE * pubStart, int ulLength, int bTransmitMode);
void ChangeInputChannel(int nNewChannel);
void ChangeSamplerType(int nNewSamplerType);
void ChangeInputSource(int nNewSource, BOOL BMakePermanent);
void ChangeCompressMode(UBYTE ubNewMode);
void SetToccataInputSpecs(void);
void ResetDigitizer(BOOL BReset);

void RaiseLineGain(int nSteps);
void SetMicGain(int nNewValue);

int CalcVolumePercentage(ULONG ulVolume);


#endif
