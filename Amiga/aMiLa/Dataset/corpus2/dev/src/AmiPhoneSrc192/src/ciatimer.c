#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <exec/io.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <exec/tasks.h>
#include <exec/interrupts.h>
#include <exec/ports.h>
#include <exec/lists.h>
#include <hardware/cia.h>
#include <hardware/intbits.h>
#include <libraries/mathieeesp.h>
#include <clib/mathieeedoubbas_protos.h>

#include <resources/cia.h>

#include <libraries/dos.h>
#include <libraries/delfina.h>
#include <resources/misc.h>
#include <utility/tagitem.h>

#include <pragmas/ahi_pragmas.h>

#include <devices/ahi.h>
#include <clib/alib_protos.h>
#include <clib/ahi_protos.h>
#include <clib/dos_protos.h>
#include <clib/cia_protos.h>
#include <clib/exec_protos.h>
#include <clib/misc_protos.h>

#include "AmiPhoneMsg.h"
#include "AmiPhone.h"
#include "phoneudp.h"
#include "ciatimer.h"
#include "messages.h"
#include "codec.h"
#include "delfph.h"

#include "toccata/include/libraries/toccata.h"
#include "toccata/include/clib/toccata_protos.h"
#include "toccata/include/pragmas/toccata_pragmas.h"

/* Some hardware addresses to sample from */
#define AMIGA_HARDWARE_SAMPLE_ADDRESS 	((UBYTE *) (&pciaa->ciaprb))
#define AURA_SAMPLE_ADDRESS_LEFT  	((UBYTE *) 0xA20000)
#define AURA_SAMPLE_ADDRESS_RIGHT 	((UBYTE *) 0xA20002)

	
/*
 * Structure which will be used to hold all relevant information about
 * the cia timer we manage to allocate.
 *
 */

struct freetimer
{
	struct Library * ciabase;	/* CIA Library Base */
	ULONG  timerbit;		/* timer bit allocated */
	struct CIA *cia;		/* ptr to hardware */
	UBYTE  * ciacr;			/* ptr to control register */
	UBYTE  * cialo;			/* ptr to low byte of timer */
	UBYTE  * ciahi;			/* ptr to high byte of timer */
	struct Interrupt timerint;	/* interrupt structure */
	UBYTE  stopmask;		/* Stop/Setup timer */
	UBYTE  startmask;		/* Start timer */
	BOOL   BUsingCIAB;		/* TRUE if CIAB, FALSE if CIAA */
};


/* function exported to inthandler.a */
void SetTimerCountdown(struct freetimer * ft, UWORD uwMicros);

/* external data */
extern void AHIhookEntry();	    /* hook stub */
extern void Idle();			
extern void InvertIdle();
extern void PerfectIdle();
extern void Record();          /* prototype for assembly interrupt routine */
extern void PerfectRecord();   /* prototype for assembly interrupt routine */

extern BOOL BTransmitting, BSoundOn, BButtonHeld, BSpaceTapped, BTCPBatchXmit, BUserDebug;
extern UBYTE ubSamplerType, ubInputChannel, ubCurrComp, ubInputSource;
extern UBYTE ubCustStart, ubCustStop, ubCustLeft, ubCustRight, ubCustMic, ubCustExt, ubCustDir;
extern UBYTE * pubCustSampleAt;
extern ULONG ulSampleArraySize;
extern ULONG ulBytesPerSecond;
extern ULONG ulLastVolume;
extern ULONG ulTimerDelay;
extern ULONG ulKeyCode;
extern ULONG ulIdleRate;
extern float fPacketDelay;
extern int nHackAmpVol, nAnimFrame, nMinSampleVol, nSampleTechnique, nToggleMode, nMaxSampleRate, nAmpShift;
extern int nPreSendQLen, nPostSendLen;
extern struct AmiPhoneSendBuffer sendBuf;
extern char szProgramName[];
extern struct Task * MainTask;

extern struct Library * AHIBase;
extern struct Library * ToccataBase;
extern struct Library * DelfinaBase;

/* data */
struct IntInfo IntData;
BYTE sighalf=0, sigfull=0;
UBYTE * pubAllocedArray = NULL;
UBYTE * pubRightBuffer  = NULL;
int nLineGainValue=0, nMicGainValue=20;
UBYTE * pubBulkSamplePacket = NULL;
ULONG   ulBulkSamplePacketLen, ulBulkSamplePacketSum, ulAHIAudioMode = 0L;

/* private data */
static ULONG ulAllocedArraySize = 0L;
static ULONG CalcSampleArraySize(ULONG ulBPS, BYTE bComp, float fPackDelay);
static struct MsgPort * ToccataReplyPort;
static struct AHIAudioCtrl * AHIAudioControl = NULL;
static struct freetimer AmiPhoneTimer;
static struct List * PreSendQueue = NULL;
static int nCurrentPreSendQLen;

/* private function prototypes */
static BOOL StartTimer(struct freetimer * ft, UWORD uwMicros, ULONG ulSmallestArraySize);
static BOOL FindFreeTimer(struct freetimer *ft);
static BOOL TryTimer(struct freetimer *ft);
static BOOL AllocSamplingBuffer(ULONG ulSmallestArraySize);
static UWORD BPSToMicros(ULONG ulBPS);
static void IdleSampler(void);
static ULONG AHI_FindFrequency(ULONG ulBPS);
static void FlushPreSendQueue(BOOL BTransmit, BOOL BTCP);
static void UpdatePreSendQueue(struct AmiPhoneSendBuffer * sBuf);
static void FreePreSendNode(struct Node * current);

/* Used by toccata & AHI samplers */
static __geta4 BOOL ToccataSendData(UBYTE * ubData, ULONG ulDataSize);
static __geta4 ULONG AHISendData(struct Hook *hook, struct AHIAudioCtrl * ctrl, struct AHIRecordMessage * msg);
static BOOL StartToccataCapture(BOOL BStart, ULONG ulBPS);
static BOOL StartAHICapture(BOOL BStart, ULONG ulBPS);
static BOOL StartDelfinaCapture(BOOL BStart, ULONG ulBPS);

/* Front-ends to setting the various data direction and control bits on the parallel port */
static void SetDirectionBits(UBYTE ubBitCode);
static void SetParallelBits(int nEvent, UBYTE ubBitCode);
static char * BitsToString(UBYTE ubCode);
static char * RegToString(UBYTE ubReg);

#define EVENT_NONE  0
#define EVENT_START 1
#define EVENT_STOP  2
#define EVENT_LEFT  3
#define EVENT_RIGHT 4
#define EVENT_MIC   5
#define EVENT_EXT   6

char * szEventStrings[] = {
  "",
  "enable sampler",
  "disable sampler",
  "change to left channel",
  "change to right channel",
  "change to mic input",
  "change to external input"};

#define STOPA_AND	(CIACRAF_TODIN | CIACRAF_PBON | CIACRAF_OUTMODE | CIACRAF_SPMODE)

	/*
	;
	; AND mask for use with control register A 
	; (interval timer A on either CIA)
	;
	; STOP -
	; 	START bit 0 == 0 (STOP IMMEDIATELY)
	; 	PBON  bit 1 == same
	; 	OUT   bit 2 == same
	;	RUN   bit 3 == 0 (SET CONTINUOUS MODE)
	;	LOAD  bit 4 == 0 (NO FORCE LOAD)
	;	IN    bit 5 == 0 (COUNTS 02 PULSES)
	;	SP    bit 6 == same
	;	TODIN bit 7 == same (unused on ciacra)
	;
	*/
	
#define STOPB_AND	(CIACRBF_ALARM | CIACRBF_PBON | CIACRBF_OUTMODE)

	/*
	;
	; AND mask for use with control register B 
	; (interval timer B on either CIA)
	;
	; STOP -
	; 	START bit 0 == 0 (STOP IMMEDIATELY)
	; 	PBON  bit 1 == same
	; 	OUT   bit 2 == same
	;	RUN   bit 3 == 0 (SET CONTINUOUS MODE)
	;	LOAD  bit 4 == 0 (NO FORCE LOAD)
	;	IN0   bit 5 == 0 (COUNTS 02 PULSES)
	;	IN1   bit 6 == 0 (COUNDS 02 PULSES)
	;	ALARM bit 7 == same (TOD alarm control bit)
	;
	*/

#define STARTA_OR	CIACRAF_START

	/*
	;
	; OR mask for use with control register A
	; (interval timer A on either CIA)
	;
	; START -
	;
	;	START bit 0 == 1 (START TIMER)
	;
	;	All other bits unaffected.
	;
	*/
	
#define STARTB_OR	CIACRBF_START

	/*
	;
	; OR mask for use with control register B
	; (interval timer A??? on either CIA)
	;
	; START -
	;
	;	START bit 0 == 1 (START TIMER)
	;
	;	All other bits unaffected.
	;
	*/



extern struct CIA ciaa;
extern struct CIA ciab;

struct CIA *pciaa = &ciaa;
struct CIA *pciab = &ciab;	

/* Safe conversion function */
static UWORD BPSToMicros(ULONG ulBPS) 
{
	UWORD uwMaxWord = ((UWORD)(-1));
	ULONG ulTemp = 715820L / (ulBPS ? ulBPS : 1L);

	if (ulTemp > uwMaxWord) ulTemp = uwMaxWord;
	
	return((UWORD) ulTemp);
}



/* If the argument is FALSE, records the current state of the
   digitizer.  If it is TRUE, resets the digitizer to the state
   that was previously recorded. */
void ResetDigitizer(BOOL BReset)
{
	static int PrevSource = 9999;
	BOOL BWasInput;

	if (BReset == FALSE)
	{
		/* Other items may be added later */
		switch(ubSamplerType)
		{
			case SAMPLER_SOMAGIC:
				BWasInput = ((pciab->ciaddra & CIAF_PRTRBUSY) == 0);
		     		pciab->ciaddra &= ~(CIAF_PRTRBUSY); /* set this line to input so we can read it */
				PrevSource = (pciab->ciapra & CIAF_PRTRBUSY) ? INPUT_SOURCE_EXT : INPUT_SOURCE_MIC;
				UNLESS(BWasInput) pciab->ciaddra |= CIAF_PRTRBUSY;	/* put it back to original state */
				break;
		}
	}
	else
	{
		switch(ubSamplerType)
		{
			case SAMPLER_SOMAGIC:
				BWasInput = ((pciab->ciaddra & CIAF_PRTRBUSY) == 0);
				pciab->ciaddra |= CIAF_PRTRBUSY;
				ChangeInputSource(PrevSource,FALSE);	/* don't want this to be reflected in the menus! */
				UNLESS (BWasInput) pciab->ciaddra |= CIAF_PRTRBUSY;
				break;
		}
	}
}

void ChangeSamplerType(int nNewSamplerType)
{	
	BOOL BWasTransmitting = BTransmitting;
	
	if ((nNewSamplerType < 0)||(nNewSamplerType >= SAMPLER_MAX)) return;
	if ((nNewSamplerType == SAMPLER_DELFINA)&&(!DelfinaBase)) return;
	if ((nNewSamplerType == SAMPLER_TOCCATA)&&(!ToccataBase)) return;
	if ((nNewSamplerType == SAMPLER_AHI)&&(!AHIBase)) return;
	
	if (BWasTransmitting) ToggleMicButton(CODE_OFF);
	
	ubSamplerType = nNewSamplerType;
	ChangeInputChannel(ubInputChannel);
	ChangeInputSource(ubInputSource,TRUE);

	if (BWasTransmitting) ToggleMicButton(CODE_ON);
}


	
void ChangeInputSource(int nNewSource, BOOL BMakeCurrentMode)
{
	struct TagItem taglist[3];
	
	if (BMakeCurrentMode) ubInputSource = nNewSource;
	
	switch(ubSamplerType)
	{
		case SAMPLER_TOCCATA:
			taglist[0].ti_Tag  = PAT_Input;        
			switch (ubInputSource)
			{
				case INPUT_SOURCE_MIC: taglist[0].ti_Data = TINPUT_Mic;  break;
				case INPUT_SOURCE_EXT: taglist[0].ti_Data = TINPUT_Line; break;
			}
			taglist[1].ti_Tag  = TAG_DONE;	taglist[1].ti_Data = NULL;
			T_SetPart(taglist);
			break;
		
		case SAMPLER_SOMAGIC:
			switch(nNewSource)
			{
				case INPUT_SOURCE_MIC: SetParallelBits(EVENT_NONE, SAMPBIT_BUSYCLR); break;
				case INPUT_SOURCE_EXT: SetParallelBits(EVENT_NONE, SAMPBIT_BUSYSET); break;
			}
			break;
	
		case SAMPLER_DELFINA:
			taglist[0].ti_Tag = DA_MicIn;	taglist[0].ti_Data = (nNewSource == INPUT_SOURCE_MIC);
			taglist[1].ti_Tag = DA_LineIn;	taglist[1].ti_Data = (nNewSource == INPUT_SOURCE_EXT);
			taglist[2].ti_Tag = TAG_DONE;	taglist[2].ti_Data = NULL;
			Delf_SetAttrsA(taglist);
			break;
				
		case SAMPLER_CUSTOM:
			switch(ubInputSource)
			{
				case INPUT_SOURCE_MIC: SetParallelBits(EVENT_MIC,ubCustMic); break;
				case INPUT_SOURCE_EXT: SetParallelBits(EVENT_EXT,ubCustExt); break;
			}
	}
}


void ChangeInputChannel(int nNewChannel)
{
	if (nNewChannel == INPUT_JACK_LEFT) 
	{
		switch (ubSamplerType)
		{
			case SAMPLER_TOCCATA:
				 break;
						
			case SAMPLER_GVPDSS8: 	/* this verified to work by JAF */
				 SetParallelBits(EVENT_NONE,SAMPBIT_SELSET);
			  	 break;		
				 
			case SAMPLER_SOMAGIC:
				 SetParallelBits(EVENT_NONE,SAMPBIT_POUTCLR | SAMPBIT_SELSET);
			 	 break;

			case SAMPLER_AURA:
				 IntData.pubSampleAt = AURA_SAMPLE_ADDRESS_LEFT;
				 break;
				 
			case SAMPLER_CUSTOM:
				 SetParallelBits(EVENT_LEFT,ubCustLeft);
				 if (pubCustSampleAt) IntData.pubSampleAt = pubCustSampleAt;
				 break;		
			
			case SAMPLER_DELFINA:
				 if (StartSampling(CHECK_STATUS,0) == TRUE) 
				 {
					ubInputChannel = INPUT_JACK_LEFT;	/* must be set BEFORE the StartSampling pair! */
					BTransmitting = StartSampling(FALSE,0);
					BTransmitting = StartSampling(TRUE,ulBytesPerSecond);
				 }
				 break;
				 					 
			default: case SAMPLER_PERFECT: case SAMPLER_AMAS: 
				 /* as described by Marcel Offermans & AGMSRecordSound author */
				 SetParallelBits(EVENT_NONE,SAMPBIT_SELCLR);
				 break;
		}
	}
	else if (nNewChannel == INPUT_JACK_RIGHT) 
	{
		switch (ubSamplerType)
		{
			case SAMPLER_TOCCATA:
				 break;
			
			case SAMPLER_DELFINA:
				 if (StartSampling(CHECK_STATUS,0) == TRUE) 
				 {
					ubInputChannel = INPUT_JACK_RIGHT;	/* must be set BEFORE the StartSampling pair! */
					BTransmitting = StartSampling(FALSE,0);
					BTransmitting = StartSampling(TRUE,ulBytesPerSecond);
				 }
				 break;	 					 

			case SAMPLER_GVPDSS8: 
				 SetParallelBits(EVENT_NONE, SAMPBIT_SELCLR);
				 break;
			
			case SAMPLER_SOMAGIC:
				 SetParallelBits(EVENT_NONE, SAMPBIT_SELCLR | SAMPBIT_POUTSET);
				 break;

			case SAMPLER_AURA:
				 IntData.pubSampleAt = AURA_SAMPLE_ADDRESS_RIGHT;
				 break;				 

			case SAMPLER_CUSTOM:
				 SetParallelBits(EVENT_RIGHT, ubCustRight);
				 if (pubCustSampleAt) IntData.pubSampleAt = pubCustSampleAt;
				 break;
				 				 
			default: case SAMPLER_PERFECT: case SAMPLER_AMAS: 
				 SetParallelBits(EVENT_NONE, SAMPBIT_POUTCLR | SAMPBIT_SELSET);
				 break;
		}
	}
	ubInputChannel = nNewChannel;
}

/* Attempts to start or stop sampling, based on BStart. */
/* Returns the (new) current state of the sampling timer.  TRUE=going, FALSE=stopped */
BOOL StartSampling(BOOL BStart, ULONG ulBPS)
{
	static BOOL BTimerStarted = FALSE, BFirstTime = TRUE;
	static struct Interrupt SoftInt;
	UBYTE * pubPartialSend;
	int nPartialSendLength;

	/* case where user just wants to check, case where user is already in desired state */	
	if ((BStart == CHECK_STATUS)||(BStart == BTimerStarted)) return(BTimerStarted);

	/* Make sure our queue is empty */
	FlushPreSendQueue(FALSE,FALSE);
			
	/* For the toccata board, we do something totally different */
	if (ubSamplerType == SAMPLER_TOCCATA) return(BTimerStarted = StartToccataCapture(BStart, ulBPS));
	
	/* Not to mention for the AHI system, it's completely different as well */
	if (ubSamplerType == SAMPLER_AHI) return(BTimerStarted = StartAHICapture(BStart, ulBPS));
	
	if (ubSamplerType == SAMPLER_DELFINA) return(BTimerStarted = StartDelfinaCapture(BStart, ulBPS));
	
	/* set up data which will be passed to interrupt */
	if (BStart == TRUE)
	{	
		if (AllocParallel(TRUE,TRUE) == FALSE) return(FALSE);

		if (BFirstTime == TRUE)
		{
			ResetDigitizer(FALSE);	/* record state */
			BFirstTime = FALSE;	
		}
		
		/* Might as well make sure the settings are correct! */
		ChangeInputChannel(ubInputChannel);
		ChangeInputSource(ubInputSource,FALSE);
		
		/* Prepare freetimer structure: setup hardware interrupt */
		AmiPhoneTimer.timerint.is_Node.ln_Type = NT_INTERRUPT;
		AmiPhoneTimer.timerint.is_Node.ln_Pri  = 0;
		AmiPhoneTimer.timerint.is_Node.ln_Name = "AmiPhone Sample Timer";
		AmiPhoneTimer.timerint.is_Data	       = (APTR) &IntData;
		AmiPhoneTimer.timerint.is_Code	       = (ubSamplerType == SAMPLER_PERFECT) ? PerfectIdle : ((UsesInvertedSamples()) ? InvertIdle : Idle);
		
		/* Call function to find a free CIA interval timer
		 * with flag indicating that we prefer a CIA timer A.
		 */
		if (FindFreeTimer(&AmiPhoneTimer))
		{
			/* use BPS to figure out # of microseconds to delay between samples */
			ulTimerDelay = BPSToMicros(ulBPS);
			
			/* Start it up! */
			UNLESS(BTimerStarted = StartTimer(&AmiPhoneTimer, ulTimerDelay, ulSampleArraySize))
			{
				AllocParallel(FALSE,FALSE);
				UserError("Couldn't start CIA Timer");
			}
		}
		else 
		{
			SetWindowTitle("Error: no CIA timers available.");
			AllocParallel(FALSE,FALSE);
		}
	}
	else
	{
		/* Turn off CIA interrupt if we were using it */
		if ((nSampleTechnique == TECHNIQUE_SOFTINT)||(nSampleTechnique == TECHNIQUE_HARDINT))
			RemICRVector(AmiPhoneTimer.ciabase, AmiPhoneTimer.timerbit, &AmiPhoneTimer.timerint);

		/* If the user wants to do something on disable, here's where! */
		if (ubSamplerType == SAMPLER_CUSTOM) SetParallelBits(EVENT_STOP, ubCustStop);
		
		/* Reset to initial state */
		ResetDigitizer(TRUE);

		/* Deallocate parallel port */
		AllocParallel(FALSE,FALSE);
		BTimerStarted = FALSE;

		/* Send what we have of the current packet, if we were sending */
		pubPartialSend     = (IntData.pubIndex >= IntData.pubHalfIndex) ? IntData.pubHalfIndex : IntData.pubArray;
		nPartialSendLength = (int) (IntData.pubIndex-pubPartialSend);
		if (nPartialSendLength == 0) nPartialSendLength = 1;
				
		/* pro-rate the partial sample's volume to represent the full range */
		IntData.ulSaveByteSum = ((ULONG) (IntData.ulByteSum * ((ULONG)(IntData.pubHalfIndex-IntData.pubArray)))) / ((ULONG) nPartialSendLength);
		TransmitData(pubPartialSend, nPartialSendLength, ubCurrComp);			    
		
		/* Deallocate any RAM that was previously allocated */
		AllocSamplingBuffer(0L);
	
		ulLastVolume = SILENCE;
	}
	return(BTimerStarted);
};





static BOOL StartAHICapture(BOOL BStart, ULONG ulBPS)
{
	struct TagItem taglist[15];
	static struct Hook RecordFuncHook;
	ULONG ulAHIVolume,ulAHIRecord,ulAHIRealtime,ulAHIBits,ulAHIFrequencies,
	      ulAHIIndex,ulAHIMaxRecordSamples,ulBestAudioMode, ulError;
	char szDriverName[200] = "szDriverName",
	     szModeName[200]   = "szModeName",
	     szAuthorName[200] = "szAuthorName",
	     szVersionName[200]= "szVersionName";
	
	if (BStart)
	{
		printf("StartAHICapture():  Setting up capture....\n");
		
		taglist[0].ti_Tag = AHIDB_Record; taglist[0].ti_Data = TRUE;
		taglist[1].ti_Tag = AHIDB_Bits;   taglist[1].ti_Data = 8;
		taglist[2].ti_Tag = TAG_DONE;	  taglist[2].ti_Data = NULL;
		ulBestAudioMode = AHI_BestAudioIDA(taglist);
		
		printf("ulBestAudioMode is 0x%X\n",ulBestAudioMode);
		if (ulBestAudioMode == AHI_INVALID_ID) printf("Warning, INVALID ID!\n");
		
		taglist[0].ti_Tag  = AHIDB_Volume; 	taglist[0].ti_Data  = &ulAHIVolume;
		taglist[1].ti_Tag  = AHIDB_Record; 	taglist[1].ti_Data  = &ulAHIRecord;
		taglist[2].ti_Tag  = AHIDB_Realtime; 	taglist[2].ti_Data  = &ulAHIRealtime;
		taglist[3].ti_Tag  = AHIDB_Bits; 	taglist[3].ti_Data  = &ulAHIBits;
		taglist[4].ti_Tag  = AHIDB_Frequencies; taglist[4].ti_Data  = &ulAHIFrequencies;
		taglist[5].ti_Tag  = AHIDB_Index; 	taglist[5].ti_Data  = &ulAHIIndex;
		taglist[6].ti_Tag  = AHIDB_IndexArg; 	taglist[6].ti_Data  = ulBPS;
		taglist[7].ti_Tag  = AHIDB_MaxRecordSamples; taglist[7].ti_Data = &ulAHIMaxRecordSamples;
		taglist[8].ti_Tag  = AHIDB_BufferLen;   taglist[8].ti_Data  = sizeof(szDriverName);
		taglist[9].ti_Tag  = AHIDB_Driver; 	taglist[9].ti_Data  = szDriverName;
		taglist[10].ti_Tag = AHIDB_Name; 	taglist[10].ti_Data = szModeName;
		taglist[11].ti_Tag = AHIDB_Author; 	taglist[11].ti_Data = szAuthorName;
		taglist[12].ti_Tag = AHIDB_Version;	taglist[12].ti_Data = szVersionName;
		taglist[13].ti_Tag = TAG_DONE; 		taglist[13].ti_Data = NULL;
		UNLESS(AHI_GetAudioAttrsA(ulBestAudioMode, NULL, taglist))
		{
			printf("AHI_GetAudioAttrsA failed!\n");
			return(FALSE);
		}

		printf("---------AHI_GetAudioAttrs reports:\n");
		printf("VolumeAdjustable = %lu\n",ulAHIVolume);
		printf("CanRecord        = %lu\n",ulAHIRecord);
		printf("Realtime         = %lu\n",ulAHIRealtime);
		printf("BitsPerSample    = %lu\n",ulAHIBits);
		printf("NumFrequencies   = %lu\n",ulAHIFrequencies);
		printf("IndexOf(f=%lu)   = %lu\n",ulBPS,ulAHIIndex);
		printf("MaxRecordSamples = %lu\n",ulAHIMaxRecordSamples);
		printf("szDriverName  = [%s]\n",szDriverName);
		printf("szModeName    = [%s]\n",szModeName);
		printf("szAuthorName  = [%s]\n",szAuthorName);
		printf("szVersionName = [%s]\n",szVersionName);
		printf("---------End AHI_GetAudioAttrs\n");

		/* Setup our Hook! */
		RecordFuncHook.h_Entry    = (ULONG (*) ()) AHIhookEntry;
		RecordFuncHook.h_SubEntry = AHISendData;
		RecordFuncHook.h_Data	  = NULL;	/* Should there be something here? */
		
		/* Now start the capture */
		taglist[0].ti_Tag = AHIA_AudioID; 	taglist[0].ti_Data = ulBestAudioMode;
		taglist[1].ti_Tag = AHIA_Channels;	taglist[1].ti_Data = 0;	/* Is zero channels okay since we won't be playing any sounds?? */
		taglist[2].ti_Tag = AHIA_Sounds;  	taglist[2].ti_Data = 0;	/* What is this arg, anyway??? */
		taglist[3].ti_Tag = AHIA_RecordFunc;	taglist[3].ti_Data = &RecordFuncHook;
		taglist[4].ti_Tag = TAG_DONE;	  	taglist[4].ti_Data = NULL;
		UNLESS(AHIAudioControl = AHI_AllocAudioA(taglist))
		{
			SetWindowTitle("AHI_AllocAudioA failed!");
			return(FALSE);
		}
		ulAHIAudioMode = ulBestAudioMode;
		
		taglist[0].ti_Tag = AHIC_Play; 		taglist[0].ti_Data = FALSE;
		taglist[1].ti_Tag = AHIC_Record;	taglist[1].ti_Data = TRUE;
		taglist[2].ti_Tag = AHIA_RecordFunc;	taglist[2].ti_Data = &RecordFuncHook;
		taglist[3].ti_Tag = TAG_DONE;	  	taglist[3].ti_Data = NULL;
		if (ulError = AHI_ControlAudioA(AHIAudioControl, taglist))
		{
			printf("AHI_ControlAudioA failed, error %lu\n",ulError);
			AHI_FreeAudio(AHIAudioControl); AHIAudioControl = NULL;
			return(FALSE);
		}
		return(TRUE);
	}
	else
	{
		printf("StartAHICapture():  Ending capture....\n");
		if (AHIAudioControl)
		{
			taglist[0].ti_Tag = AHIC_Play; 		taglist[0].ti_Data = FALSE;
			taglist[1].ti_Tag = AHIC_Record;	taglist[1].ti_Data = FALSE;
			taglist[2].ti_Tag = TAG_DONE;	  	taglist[2].ti_Data = NULL;
			if (ulError = AHI_ControlAudioA(AHIAudioControl, taglist))
				printf("AHI_ControlAudioA failed on stop, error %lu\n",ulError);
			AHI_FreeAudio(AHIAudioControl); 
			AHIAudioControl = NULL;
		}
		else printf("Um, AHIAudioControl was like, NULL or something\n");

		ulLastVolume = SILENCE;
		return(FALSE);
	}
}


/* Returns current state of the delfina sampler after operation attempted! */
static BOOL StartDelfinaCapture(BOOL BStart, ULONG ulBPS)
{
	int compmode;
	
	if (BStart)
	{
		UNLESS(DelfinaBase) return(FALSE);

		ulSampleArraySize = ((CalcSampleArraySize(ulBPS, ubCurrComp, fPacketDelay) >> 4)+1)<<3;

		switch(ubCurrComp)
		{
			case COMPRESS_ADPCM2:	compmode = 1; break;
			case COMPRESS_ADPCM3:	compmode = 2; break;
			default:				compmode = 0; break;
		}
		/* Now allocate a buffer for us.  The >>3 is due to warts in AllocSamplingBuffer (read its header for more info) */
		UNLESS(AllocSamplingBuffer(ulSampleArraySize>>3))
		{
			printf("StartDelfinaCapture():  Couldn't allocate sampling buffer!\n");
			return(FALSE);
		}
		UNLESS(StartDelfina(ulBPS, ulSampleArraySize, compmode, (ubInputChannel == INPUT_JACK_RIGHT)))
		{
			printf("StartDelfinaCapture(): StartDelfina() failed!\n");
			AllocSamplingBuffer(0);
			return(FALSE);
		}
		return(TRUE);
	}
	else
	{
		StopDelfina();
		AllocSamplingBuffer(0);	/* Free the mem we were using */
		return(FALSE);
	}	
}


/* BSTart controls whether to start or stop capture.  ulBPS is, of course,
   the sampling rate (for the Toccata, this should be set to one of the
   acceptable values--see toccata.doc) */
static BOOL StartToccataCapture(BOOL BStart, ULONG ulBPS)
{
	static struct TagItem taglist[7];
	ULONG ulTocArraySize;

	if (BStart)
	{
		UNLESS(ToccataBase) return(FALSE);

		/* Just to make sure... toccata docs say this is safe to call
		   even when we're not capturing */
		T_Stop(TSF_DONTSAVECACHE);
				
		pubBulkSamplePacket = NULL; 
		UNLESS(ToccataReplyPort = CreatePort(0,0)) return(FALSE);

		/* Deallocate any RAM that was previously allocated */
		/* We won't be using our buffer... toccata.library will provide one */
		AllocSamplingBuffer(0L);

		/* check to see if hardware is really there! */
		UNLESS(((struct ToccataBase *)ToccataBase)->tb_HardInfo)
		{
			SetWindowTitle("Error: No Toccata Hardware");
			return(FALSE);
		}

		/* We will allocate space for ulSmallestArraySize samples, @ 8 bits/sample */
		/* The cool bit shifts and add are to round it up to the nearest 512-byte boundary */
		/* The reason for >>10 instead of >>9 is to divide by two, as this represents only */
		/* one of the two buffers that we would have had if we were using AmiPhone's double-buffer */
		/* scheme */
		ulTocArraySize = ((CalcSampleArraySize(ulBPS, ubCurrComp, fPacketDelay) >> 10)+1)<<9;

		/* Prepare taglist to send to T_Capture */
		taglist[0].ti_Tag  = TT_BufferSize; taglist[0].ti_Data = ulTocArraySize;
		taglist[1].ti_Tag  = TT_Save;	    taglist[1].ti_Data = ToccataSendData;
		taglist[2].ti_Tag  = TT_Mode;	    taglist[2].ti_Data = TMODE_LINEAR_8;
		taglist[3].ti_Tag  = TT_Frequency;  taglist[3].ti_Data = ulBPS;
		taglist[4].ti_Tag  = TT_ErrorTask;  taglist[4].ti_Data = MainTask;
		taglist[5].ti_Tag  = TT_ErrorMask;  taglist[5].ti_Data = SIGBREAKF_CTRL_D;
		taglist[6].ti_Tag  = TAG_DONE;	    taglist[6].ti_Data = NULL;

		/* and off it goes! */
		UNLESS(T_Capture(taglist))
		{
			printf("StartToccataCapture: T_Capture failed, errno=%i\n",T_IoErr());
			return(FALSE);
		}
		return(TRUE);
	}
	else
	{
		/* stop ze capture! */
		T_Stop(TSF_DONTSAVECACHE);
		pubBulkSamplePacket = NULL; 
		RemovePortSafely(ToccataReplyPort); ToccataReplyPort = NULL;
		ulLastVolume = SILENCE;
		return(FALSE);	/* FALSE because we are returning the STATE of the sampler, not success/failure. */
	}
}



/* Called by AHI whenever data is to be xmitted */	
static __geta4 ULONG AHISendData(struct Hook *hook, struct AHIAudioCtrl * ctrl, struct AHIRecordMessage * msg)
{
	pubBulkSamplePacket   = msg->ahirm_Buffer; 
	ulSampleArraySize     = msg->ahirm_Length;

	ulBulkSamplePacketSum = ProcessAHIBuffer(pubBulkSamplePacket, &ulSampleArraySize, msg->ahirm_Type);
	Signal(MainTask, SIGBREAKF_CTRL_F);
	return(1);
}


/* called by the Toccata library whenever we need to send the data */
static __geta4 BOOL ToccataSendData(UBYTE * pubData, ULONG ulDataSize)
{	
	pubBulkSamplePacket   = pubData;
	ulSampleArraySize     = ulDataSize;

	ulBulkSamplePacketSum = ProcessToccataBuffer(pubData, ulDataSize);
	Signal(MainTask, SIGBREAKF_CTRL_F);
	return(TRUE);
}




/*
 * This function attempts to raise the input gain by nSteps steps.
 */
void RaiseLineGain(int nSteps)
{
	char szMessage[60];
	struct TagItem taglist[3];
	int i, BRaise = (nSteps > 0);
	
	switch(ubSamplerType)
	{
	   case SAMPLER_DELFINA:
		nLineGainValue = ChopValue(nLineGainValue+nSteps,0,15);
		taglist[0].ti_Tag = DA_InputGain;	taglist[0].ti_Data = (nLineGainValue * 0x10000)/15;
		taglist[1].ti_Tag = TAG_DONE;		taglist[1].ti_Data = NULL;
		Delf_SetAttrsA(taglist);
		break;
		
	   case SAMPLER_TOCCATA:
		nLineGainValue = ChopValue(nLineGainValue+nSteps,0,15);	
		taglist[0].ti_Tag  = PAT_InputVolumeRight; taglist[0].ti_Data = nLineGainValue;
		taglist[1].ti_Tag  = PAT_InputVolumeLeft;  taglist[1].ti_Data = nLineGainValue;
		taglist[2].ti_Tag  = TAG_DONE; 		   taglist[2].ti_Data = NULL;
		T_SetPart(taglist);
		break;
		
	   case SAMPLER_GVPDSS8:
		nLineGainValue = ChopValue(nLineGainValue+nSteps,0,7);
	        pciaa->ciaddrb  = 0xFF;	/* set data direction bits to output */
		SetDirectionBits(SAMPBIT_BUSYSET);	/* busy bit as output */
		SetParallelBits(EVENT_NONE, SAMPBIT_BUSYCLR);
		pciaa->ciaprb = (nLineGainValue+8) | ((nLineGainValue+8) << 4);
		SetParallelBits(EVENT_NONE, SAMPBIT_BUSYSET);
		SetDirectionBits(SAMPBIT_BUSYCLR);
	        pciaa->ciaddrb  = 0x00;	/* data back to input */
		break;
		
	   case SAMPLER_PERFECT:
		/* get absolute value */
		nLineGainValue += nSteps;
		if (nSteps < 0) nSteps *= -1;
		for (i=0; i<nSteps; i++)
		{
			/* Set SEL to 0 for decrease, 1 for increase */
			if (BRaise == TRUE) SetParallelBits(EVENT_NONE,SAMPBIT_SELSET);
				       else SetParallelBits(EVENT_NONE,SAMPBIT_SELCLR);
				
			/* Now toggle PB7 */
		        pciaa->ciaprb  &= ~(0x80);	/* Gain control goes to zero */
			Delay(1);
		        pciaa->ciaprb  |= 0x80;		/* And back to one.  This is the trigger. */
		}
		ChangeInputChannel(ubInputChannel);	
		break;
	}
	sprintf(szMessage,"Line Gain is now %i.", nLineGainValue);
	SetWindowTitle(szMessage);
}


/*
 * This function attempts to set the input gain of the microphone.
 * Note the difference between this and RaiseLineGain.
 *
 */
void SetMicGain(int nNewValue)
{
	char szMessage[40];
	struct TagItem taglist[3];
	
	switch(ubSamplerType)
	{
	   case SAMPLER_DELFINA:
		taglist[0].ti_Tag = DA_MicIsLine;	taglist[0].ti_Data = (nNewValue==0);
		taglist[1].ti_Tag = DA_HighPass;	taglist[1].ti_Data = (nNewValue==20);
		taglist[2].ti_Tag = TAG_DONE;		taglist[2].ti_Data = NULL;
		Delf_SetAttrsA(taglist);
		break;

	   case SAMPLER_TOCCATA:
		taglist[0].ti_Tag  = PAT_MicGain;       taglist[0].ti_Data = (nNewValue > 0);
		taglist[1].ti_Tag  = TAG_DONE; 		taglist[1].ti_Data = NULL;
		T_SetPart(taglist);
		break;
	}
	
	nMicGainValue = nNewValue;
	sprintf(szMessage,"Microphone Gain is now +%idB.",nMicGainValue);
	SetWindowTitle(szMessage);
}



/* 
 * This routine sets up the interval timer we allocated with
 * AddICRVector().  Note that we may have alreay received one, or
 * more interrupts from our timer.  Make no assumptions about the
 * initial state of any of the hardware registers we will be using.
 *
 */
static BOOL StartTimer(struct freetimer * ft, UWORD uwMicros, ULONG ulSmallestArraySize)
{
	register struct CIA * cia;

	/* Set parallel port direction register in CIA-A to "input" */
	switch(ubSamplerType)
	{
		case SAMPLER_PERFECT:
		     pciaa->ciaddrb  = 0xC0;	/* high two bits are output/control bits on the PerfectSound! */
		     pciaa->ciaprb  |= 0xC0;	/* PB6, PB7 both high when sampling? */
		     SetDirectionBits(SAMPBIT_BUSYCLR);	/* per generic.source? */
		     break;
				     
		case SAMPLER_TOCCATA: case SAMPLER_AHI: case SAMPLER_DELFINA:
		     /* Don't call StartTimer() with these sampler types, fruit loop! */
		     return(FALSE);
		     break;
		
		case SAMPLER_SOMAGIC:
		     pciaa->ciaddrb  = 0x00;	/* all bits: input mode */
		     /* for this model, BUSY is used as an output also */
		     SetDirectionBits(SAMPBIT_SELSET | SAMPBIT_POUTSET | SAMPBIT_BUSYSET);
		     break; 
		
		case SAMPLER_CUSTOM:
		     /* Make all data bits input */
		     pciaa->ciaddrb  = 0x00;
		     /* User-customizable set of control direction bits */
		     SetDirectionBits(ubCustDir);
		     /* User-customizable set of control data bits */
		     SetParallelBits(EVENT_START, ubCustStart);
		     break;
	 	
		default:
		     pciaa->ciaddrb  = 0x00;	/* all bits: input mode */
		     SetDirectionBits(SAMPBIT_SELSET | SAMPBIT_POUTSET | SAMPBIT_BUSYCLR);
		     break;
	}

	UNLESS(AllocSamplingBuffer(ulSmallestArraySize)) return(FALSE);
	
	IntData.pubSampleAt   = AMIGA_HARDWARE_SAMPLE_ADDRESS;		/* default = parallel hardware */
	IntData.stTask        = FindTask(NULL);
	IntData.ulHalfSignal  = (1<<sighalf);
	IntData.ulFullSignal  = (1<<sigfull);
	IntData.ulShiftLeft   = (ULONG) nAmpShift;
	IntData.ulByteSum     = 0L;
	IntData.ulSaveByteSum = 0L;
	IntData.ulThreshhold  = (nPreSendQLen == 0) ? ((ULONG) ((nMinSampleVol*255)/100)) : 0L;
	IntData.uwCiavals     = uwMicros;
	IntData.uwClearCode   = (ft->BUsingCIAB) ? INTF_EXTER : INTF_PORTS;
	IntData.BIdle	      = 1L;
	
	ChangeInputChannel(ubInputChannel);	/* select channel for input if possible */

	ulLastVolume = SILENCE;	
	TransmitData(0,0,0);
		
	/* Begin RKM timer startup code */	
	cia = ft->cia;

	/* Note that there are differences between control register A,
	 * and B on each CIA (e.g. the TOD alarm bit, and INMODE bits. 
	 */

	if (ft->timerbit == CIAICRB_TA)
	{
		ft->ciacr = &cia->ciacra;		/* control register A */
		ft->cialo = &cia->ciatalo;		/* low byte counter */
		ft->ciahi = &cia->ciatahi;		/* high byte counter */
		
		ft->stopmask = STOPA_AND;		/* setup mask values */
		ft->startmask = STARTA_OR;		
	}
	else
	{
		ft->ciacr = &cia->ciacrb;		/* control register B */
		ft->cialo = &cia->ciatblo;		/* low byte counter */
		ft->ciahi = &cia->ciatbhi;		/* high byte counter */
		
		ft->stopmask = STOPB_AND;		/* setup mask values */
		ft->startmask = STARTB_OR;		
	}

	IntData.pubCiahi      = ft->ciahi;
	IntData.pubCialo      = ft->cialo;
		
	/* Modify control register within Disable().  This is done to avoid
	 * race conditions since our compiler may generate code such as:
	 *
	 * 	value = Read hardware byte
	 *	AND value with MASK
	 *	Write value to hardware byte
	 *
	 * If we take a task switch in the middle of this sequence, two tasks
	 * trying to modify the same register could trash each others' bits.
	 *
	 * Normally this code would be written in assembly language using atomic
	 * instructions so that Disable() would not be needed.
	 */

	Disable();
	
	/* STOP timer, set 02 pulse countdown mode, set continuous mode */
	
	*ft->ciacr &= ft->stopmask;
	
	Enable();
	
	/* Start the interval timer - we will start the counter after 
	 * writing the low, and high byte counter values 
	 */
	SetTimerCountdown(ft, (UWORD) BPSToMicros(ulIdleRate));
	
	/* Turn on start bit - same bit for both A, and B control regs */
	Disable();
	
	*ft->ciacr |= ft->startmask;

	Enable();
	
	return(TRUE);
}



/* Allocate (or reallocate) the sampling buffer! */
/* Call with ulSize = 0 to free any allocated buffer! */
/* Allocates a buffer of size ulSmallestArraySize*8 bytes! */
/* (Yeah, that doesn't make sense, you're right!  But that's how it works) */
static BOOL AllocSamplingBuffer(ULONG ulSmallestArraySize)
{
	UBYTE * pubOldArray = pubAllocedArray;
	ULONG ulOldAllocedArraySize = ulAllocedArraySize;
	
	if (ulSmallestArraySize)
	{
		ulAllocedArraySize = ulSmallestArraySize<<3;	/* 8 bit recording == times 8 */
		UNLESS(pubAllocedArray = AllocMem(ulAllocedArraySize, MEMF_ANY))
		{
			/* oops--revert back to the old buffer */
			pubAllocedArray = pubOldArray;
			ulAllocedArraySize = ulOldAllocedArraySize;
			
			UserError("Couldn't allocate sampling buffer");
			return(FALSE);
		}
		pubRightBuffer = &pubAllocedArray[ulAllocedArraySize>>1];
	} 
	else  
	{
		/* 0 = de-alloc! */
		ulAllocedArraySize = 0L;
		pubAllocedArray = pubRightBuffer = NULL;
	}

	/* Initialize arg struct for inthandler */
	Disable();
	IntData.pubIndex      = pubAllocedArray;
	IntData.pubArray      = pubAllocedArray;
	if (pubAllocedArray)
	{
		IntData.pubHalfIndex  = &pubAllocedArray[ulAllocedArraySize/2];
		IntData.pubEndIndex   = &pubAllocedArray[ulAllocedArraySize-1];
	}
	else
	{
		IntData.pubHalfIndex  = NULL;
		IntData.pubEndIndex   = NULL;
	}
	Enable();

	/* Deallocate any RAM that was previously allocated */
	if (pubOldArray) FreeMem(pubOldArray, ulOldAllocedArraySize);

	return(TRUE);
}




/* If ft is NULL, use the same freetimer struct we used last time! */
void SetTimerCountdown(struct freetimer * ft, UWORD uwMicros)
{
	static struct freetimer * fLastTime = NULL;
	
	if (ft == NULL)
	{
		if (fLastTime == NULL) return;
		ft = fLastTime;
	} 
	else fLastTime = ft;
	
	Disable();
	*ft->ciahi = ((uwMicros & 0xFF00)>>8);
	*ft->cialo =  (uwMicros & 0x00FF)    ;
	Enable();
}



/*
 * A routine to find a free interval timer.
 *
 * This routine makes no assumptions about which interval timers
 * (if any) are available for use.  Currently there are two interval
 * timers per CIA chip.
 *
 * Because CIA usage may change in the future, you code should use
 * a routine like this to find a free interval timer.
 *
 * This routine will first try to get a timer on CIA-A, because that
 * CIA will not interfere with serial operations.  If that fails, it
 * will try for one on CIA-B.
 *
 */
 
static BOOL FindFreeTimer (struct freetimer *ft)
{
	struct CIABase * ciaabase, *ciabbase;
	
	/* get pointers to both resource bases--this doesn't tie anything up */
	ciaabase = OpenResource(CIAANAME);
	ciabbase = OpenResource(CIABNAME);

	/* Try for CIA-A */
	ft->ciabase = ciaabase;		/* library address for */
	ft->cia	= pciaa;
	ft->BUsingCIAB = FALSE;
	if (TryTimer(ft)) return(TRUE);

	/* Couldn't get CIA-A, try for CIA-B */
	ft->ciabase = ciabbase;
	ft->cia	    = pciab;
	ft->BUsingCIAB = TRUE;
 	return(TryTimer(ft));
}



/*
 * Try to obtain a free interval timer on a CIA.
 */
 
static BOOL TryTimer(struct freetimer * ft)
{
	if (!(AddICRVector(ft->ciabase,CIAICRB_TA,&ft->timerint)))
	{
		ft->timerbit = CIAICRB_TA;
		return(TRUE);
	}
	if (!(AddICRVector(ft->ciabase,CIAICRB_TB,&ft->timerint)))
	{
		ft->timerbit = CIAICRB_TB;
		return(TRUE);
	}
	return(FALSE);
}


/* public functions */
/* returns success, or if BAlloc == CHECK_STATUS, returns TRUE if
   available, FALSE if not */
/* Don't call this manually except to check_status!  StartSampling
   will call it as necessary! */
BOOL AllocParallel(BOOL BAlloc, BOOL BGrab)
{
	char * szCurrentUser;
	char * pcErrType = (BAlloc == CHECK_STATUS) ? "Warning:" : "Error:";
	char szMessage[50];
	static char szAllocName[30];
	
	if ((BAlloc == TRUE)||(BAlloc == CHECK_STATUS))
	{
		sprintf(szAllocName,"AmiPhone_%ld",ulKeyCode);

		szCurrentUser = AllocMiscResource(MR_PARALLELPORT, szAllocName);
		if (szCurrentUser != NULL) 
		{
			/* If another AmiPhone is using the parallel, we'll try to kick them off! */
			if ((BGrab == TRUE)&&(strncmp(szCurrentUser, "AmiPhone", 8) == 0)&&
			    (TellOtherAmiPhoneToLetGo(szCurrentUser) == TRUE)) 
			    {
			    	Delay(5);	/* allow the other guy time to disengage */
			    	return(AllocParallel(TRUE, FALSE));
			    }
			
			sprintf(szMessage,"%s Parallel port in use.",pcErrType);
			SetWindowTitle(szMessage);	
			
			return(FALSE);
		}
		szCurrentUser = AllocMiscResource(MR_PARALLELBITS, szAllocName);
		if (szCurrentUser != NULL) 
		{
			FreeMiscResource(MR_PARALLELPORT);		/* clean up! */
			sprintf(szMessage,"%sParallel bits in use.",pcErrType);
			SetWindowTitle(szMessage);
			return(FALSE);		
		}
	}
	
	if ((BAlloc == FALSE)||(BAlloc == CHECK_STATUS))	
	{		
		FreeMiscResource(MR_PARALLELBITS); 		
		FreeMiscResource(MR_PARALLELPORT);
	}			
	return(TRUE);
}

BOOL TellOtherAmiPhoneToLetGo(char * szOtherPhoneName)
{
	static struct AmiPhoneInfo ReleaseMsg;
	
	ReleaseMsg.ubControl = MSG_CONTROL_RELEASE;
	return(SafePutToPort((struct Message *) &ReleaseMsg, szOtherPhoneName));
}


BOOL AllocSignals(BOOL BAlloc)
{
	if (BAlloc == TRUE)
	{
		if ((sighalf == 0)&&(sigfull == 0))
		{
			/* Try to allocate signal bytes */
			sighalf = AllocSignal(-1);
			if (sighalf == -1) return(FALSE);
			sigfull = AllocSignal(-1);
			if (sigfull == -1) return(FALSE);

		}
		else return(FALSE);
	}
	else
	{
		if (sigfull != 0) {FreeSignal(sigfull);	 sigfull = 0;}
		if (sighalf != 0) {FreeSignal(sighalf);  sighalf = 0;}
	}	
	return(TRUE);	
}


/* Returns the number of bytes that should be in our
   sampling array for this given BPS, compression scheme
   and packet length. */
static ULONG CalcSampleArraySize(ULONG ulBPS, BYTE bComp, float fPacketDelayArg)
{
	ULONG ulTemp;
	float fTemp;
	float fKludge = 0.0f;
	int i;
	
	/* simulate multiply through adding!? */
	/* originally: ulTemp = (ULONG)((((float)ulBPS) * fDelay)/(4.0)); */
	
	fTemp = ((float) ulBPS);	
	for (i=0;i<ulBPS;i++) fKludge += fPacketDelayArg;
	fTemp = fKludge;
	ulTemp = (ULONG) fTemp;
	ulTemp >>= 2;

	/* compression algorithm specific size restrictions implemented here */	
	switch(bComp)
	{
		case COMPRESS_ADPCM2: while (ulTemp % 2) ulTemp++; break;
		case COMPRESS_ADPCM3: while (ulTemp % 3) ulTemp++; break;
		case COMPRESS_NONE:   while (ulTemp % 2) ulTemp++; break;
	}
	return(ulTemp);
}


void ChangeCompressMode(UBYTE ubNewMode)
{
	ubCurrComp = ubNewMode;
	
	/* Force reset! */
	if (ubSamplerType == SAMPLER_DELFINA) ChangeSampleSpeed(ulBytesPerSecond, ubCurrComp);
}



ULONG ChangeSampleSpeed(ULONG ulNewBPS, UBYTE bComp)
{
	/* If we're sampling with the Toccata board, change it to the nearest rate we can handle */
	if ((ToccataBase)&&(ubSamplerType == SAMPLER_TOCCATA)) 
	{
		ulNewBPS = T_FindFrequency(ulNewBPS);
		if ((ulNewBPS == 0)||(ulNewBPS > nMaxSampleRate)) ulNewBPS = T_FindFrequency(0);
	}
	if (ubSamplerType == SAMPLER_DELFINA) ulNewBPS = GetClosestDelfRate(ulNewBPS, NULL, NULL);
	if ((ubSamplerType == SAMPLER_AHI)&&(ulAHIAudioMode)) ulNewBPS = AHI_FindFrequency(ulNewBPS);

	/* make sure our sampling isn't too fast or too slow */
	if (UsesCIAInterrupt())
	    	ulNewBPS = ChopValue(ulNewBPS, MIN_SAMPLE_RATE, nMaxSampleRate);

	/* make sure our packets aren't too small  */
	if (fPacketDelay < MIN_PACKET_INTERVAL) fPacketDelay = MIN_PACKET_INTERVAL;

	/* To keep a particular speed, add this:         */
	/* if (bComp == COMPRESS_SDP1) ulNewBPS = 6000L; */

	/* Calculate array size based on samples/sec and packet delay */
	ulSampleArraySize = CalcSampleArraySize(ulNewBPS, bComp, fPacketDelay);

	if (StartSampling(CHECK_STATUS,0) == TRUE)
	{
		if (UsesCIAInterrupt())
		{
			/* With the CIA, we can change rates on the fly! */
			ulTimerDelay = BPSToMicros(ulNewBPS);
			UNLESS(AllocSamplingBuffer(ulSampleArraySize)) return(FALSE);
			
			Disable();
			IntData.uwCiavals     = ulTimerDelay;
			IntData.ulThreshhold  = (ULONG) (nMinSampleVol*255)/100;
			UNLESS(IntData.BIdle) SetTimerCountdown(NULL,ulTimerDelay);
			Enable();
			
			ulLastVolume = SILENCE;
		}
		else
		{
			/* Make no assumptions--stop & restart other boards */
			BTransmitting = StartSampling(FALSE,0);
			BTransmitting = StartSampling(TRUE,ulNewBPS);
		}
	}
	return(ulBytesPerSecond = ulNewBPS);
}



/* Go through and make the bytes in the buffer unsigned,
   and add up their total and return it as well */
ULONG ProcessToccataBuffer(UBYTE * pubData, ULONG ulDataLen)
{
	register ULONG ulSum = 0L;
	register UBYTE ubTemp;
	register UBYTE * pubCurrent = pubData;
	register ULONG ulLeft = ulDataLen;
		
	while(ulLeft--)
	{
		ubTemp = ((*pubCurrent)-128)<<nAmpShift;
		*pubCurrent = ubTemp;
		ulSum += ubTemp; pubCurrent++;
	}
	return(ulSum);
}


/* Turn the words in the buffer into bytes.  Note that the
   ulDataLen parameter is the length of the buffer in BYTES,
   and when the function returns, only the first half of
   the buffer will be valid. */
/* Returns the sample sum, just like ProcessToccataBuffer() */

/* pubData    - pointer to the sampled buffer */
/* ulDataLen  - in/out variable, sends in length of buffer at current
		bit-width, etc... returns out the length of buffer 
		in 8-bit mono */
/* ulType     - The data type as given by AHI */
ULONG ProcessAHIBuffer(UBYTE * pubData, ULONG * ulDataLen, ULONG ulType)
{
	register ULONG ulSum = 0L;
	register UBYTE ubTemp, ubReadDiff;
	register UBYTE * pubCurrentRead  = pubData;
	register UBYTE * pubCurrentWrite = pubData;
	register ULONG ulLeft;
	
	switch(ulType)
	{
		case AHIST_M8S:   /* Mono, 8 bit signed (BYTE) */
			ubReadDiff = 1;
			break;
								
		case AHIST_M8U:   /* Mono, 8 bit unsigned (UBYTE) */
			ubReadDiff = 1;
			break;
			
		case AHIST_M16S:  /* Mono, 16 bit signed (WORD) */
			ubReadDiff = 2;
			break;
			
		case AHIST_S16S:  /* Stereo 16 bit signed (2×WORD) */
			ubReadDiff = 4;
			if (ubInputChannel == INPUT_JACK_RIGHT) pubCurrentRead += 2;
			break;
	
		default:	  /* error! */
			return(1L);
			break;
	}
	
	*ulDataLen = ulLeft = (*ulDataLen)/ubReadDiff;
	
	while(ulLeft--)
	{
		ubTemp = ((*pubCurrentRead)-128)<<nAmpShift;
		ulSum += ubTemp;
		*pubCurrentWrite = ubTemp;
		pubCurrentRead += ubReadDiff; pubCurrentWrite++;
	}
	return(ulSum);
}


/* Given a byte-count, returns a volume percentage between 0 and 100. */
/* Note that, if the CIA Interrupt is used, that ulSampleArraySize is
   the size of BOTH buffers, and we want to use the size of just one,
   so we divide ulSampleArraySize by 2. */
int CalcVolumePercentage(ULONG ulVolume)
{ 
	ULONG ulVol, ulMaxArrayCount;
	int nResult;
	
	if (UsesCIAInterrupt())
	{
		ulMaxArrayCount = ulSampleArraySize << 6;
		ulVolume >>= 4;	/* It's still a mystery to me why this is 16 times too big! */
	}
	else
	{
		ulMaxArrayCount = ulSampleArraySize << 7;
	}
	
	if (UsesInvertedSamples())
	{
		ulVol = ((ulMaxArrayCount > ulVolume) ? (ulMaxArrayCount-ulVolume) : 0L);
	}
	else
	{
		ulVol = ulVolume;
	}

	/* Per-sampler, hacky stuff.  Ewww! */
	switch(ubSamplerType)
	{
		case SAMPLER_GVPDSS8:	ulVol <<= 1; break;
		case SAMPLER_TOCCATA:   ulVol <<= 2; break;
	}
	
	if (nHackAmpVol != 1000) ulVol = (ulVol * nHackAmpVol)/1000;
	nResult = (ulVol*100)/ulMaxArrayCount;

	if (BUserDebug)
	{
		printf("Vol Percent=%i%% (ulVol=%lu (orig.%lu), ulMaxCount=%lu (BufSize=%lu) (st=%i)\n", 
			nResult, ulVol, ulVolume, ulMaxArrayCount, ulSampleArraySize, ubSamplerType);
	}

	return(nResult);
}


/* If nBytes == ALL_OF_BUFFER, transmit the whole buffer section.
   Otherwise, transmit the first nBytes of the indicated buffer. */   
void TransmitData(UBYTE * pubStart, int nBytes, int bComp)
{
	ULONG ulLength;
	BOOL BSoundWasOnBefore = BSoundOn;
	static ULONG ulSaveJoin = 0L, ulJoinCode = 0L;
	static int nPostGracePeriod = nPostSendLen;
			
	if (nBytes == 0)
	{
		IdleSampler();
		nPostGracePeriod = 0;
		BSoundOn = FALSE;
		return;
	}

	/* Was there enough sound there to transmit? */
	if (ubSamplerType == SAMPLER_DELFINA)
		ulLastVolume = IntData.ulSaveByteSum = DelfPacket(sendBuf.ubData, nBytes, &ulSaveJoin);
	   else ulLastVolume = IntData.ulSaveByteSum;
	   
	if (CalcVolumePercentage(ulLastVolume) < nMinSampleVol)
	{
		/* This section entered if the current buffer is too quiet */
		if (nPostGracePeriod > 0) 
		     nPostGracePeriod--; /* time is running out to hear something! */
		else BSoundOn = FALSE;	 /* time's up!  Shut off the transmission! */
	}
	else 
	{
		/* This section entered if the current buffer is loud enough */
		nPostGracePeriod = nPostSendLen;
		BSoundOn = TRUE;
	}
	
	UNLESS(BSoundOn)
	{
		IdleSampler();
		
		/* and tell the daemon to flush the buffers */
		if (BSoundWasOnBefore == TRUE) SendCommandPacket(PHONECOMMAND_FLUSH,0,0L);
	}
	
	ulLength = (nBytes == ALL_OF_BUFFER) ? (ulAllocedArraySize>>1) : nBytes;
		
	/* prepare the bytes if they are loud enough and we're enabled to xmit,
	   or we need them to be queued.  */
	if (((BSoundOn)&&(BTransmitting))||(nPreSendQLen > 0))
	{
		/* Prepare/compress the packet */
		sendBuf.header.ubCommand  = PHONECOMMAND_DATA;
		sendBuf.header.ubType     = bComp;
		sendBuf.header.ulBPS	  = ulBytesPerSecond;
		sendBuf.header.ulJoinCode = ulJoinCode;

		if (ubSamplerType == SAMPLER_DELFINA)
		{
			/* Compression was done by the Delfina's DSP, 
			   all we need to do here is get the next ulJoinCode */
			sendBuf.header.ulDataLen = nBytes;
		}
		else
		{
			/* Do the compression ourselves! */
			sendBuf.header.ulDataLen  = CompressData(pubStart,sendBuf.ubData,bComp,ulLength,&ulJoinCode);
		}	
	}

	/* Now either send if we got something, or queue if we don't
	   (and we are set to queue!) */
	if ((BSoundOn)&&(BTransmitting))
	{
		/* Send the data out */
		if (nPreSendQLen > 0) FlushPreSendQueue(TRUE, BTCPBatchXmit);
		(void)SendPacket(&sendBuf,BTCPBatchXmit);
	}
	else if (nPreSendQLen > 0)
	{
		/* Pack up the packet to go, and queue it */
		UpdatePreSendQueue(&sendBuf);
	}	

	/* For Delfina:  *Now* update ulJoinCode, AFTER we've set sendBuf.header.ulJoinCode */
	if (ubSamplerType == SAMPLER_DELFINA) ulJoinCode = ulSaveJoin;

	/* If we're doing hold-to-transmit and button is no longer being held, turn sampler off */
	if ((nToggleMode == TOGGLE_HOLD)&&(BButtonHeld == FALSE)) ToggleMicButton(CODE_OFF);

	/* Don't let one space tap cause more than one packet to be sampled */
	if (BSpaceTapped == TRUE) BSpaceTapped = BButtonHeld = FALSE;
		
	/* update MicButton image */
	nAnimFrame = (nAnimFrame+1)%4;
	DrawMicButton(-1);
}

/* Returns STATE of the PreSend queue! */
BOOL SetupPreSendQueue(BOOL BSetup)
{
	if (BSetup)
	{
		UNLESS(PreSendQueue = AllocMem(sizeof(struct List), MEMF_ANY)) return(FALSE);
		NewList(PreSendQueue);
		nCurrentPreSendQLen = 0;
		return(TRUE);
	}
	else
	{
		if (PreSendQueue)
		{
			FlushPreSendQueue(FALSE, FALSE);
			FreeMem(PreSendQueue, sizeof(struct List));
			PreSendQueue = NULL;
		}
		return(FALSE);	
	}
}

/* Empty the presend queue, either with or without transmitting packets */
void FlushPreSendQueue(BOOL BTransmit, BOOL BTCP)
{	
	struct Node * current;
	
	while(current = RemHead(PreSendQueue))
	{
		if (BTransmit) SendPacket((struct AmiPhoneSendBuffer *)current->ln_Name, BTCP);
		FreePreSendNode(current);
	}
}

void FreePreSendNode(struct Node * current)
{
	struct AmiPhoneSendBuffer * packet = current->ln_Name;

	FreeMem(packet, sizeof(struct AmiPhonePacketHeader)+packet->header.ulDataLen);
	FreeMem(current, sizeof(struct Node));	
	nCurrentPreSendQLen--;
}

void UpdatePreSendQueue(struct AmiPhoneSendBuffer * sBuf)
{
	struct AmiPhoneSendBuffer * newPacket;
	struct Node * newnode;
	ULONG ulPacketLen;

	if (nPreSendQLen == 0) return;	/* 0 == no queueing done */
	
	ulPacketLen = sBuf->header.ulDataLen + sizeof(struct AmiPhonePacketHeader);
	
	/* First, remove and free items from the queue until the
	   queue is below the maximum size */
	while (nCurrentPreSendQLen >= nPreSendQLen)
		FreePreSendNode(RemHead(PreSendQueue));

	/* Now make a copy of sBuf and append it to the queue */
	UNLESS(newnode = AllocMem(sizeof(struct Node), MEMF_CLEAR)) return;
	UNLESS(newPacket = AllocMem(ulPacketLen, MEMF_ANY))
	{
		FreeMem(newnode, sizeof(struct Node));
		return;
	}
	
	memcpy(newPacket, sBuf, ulPacketLen);
	newnode->ln_Name = newPacket;
	AddTail(PreSendQueue, newnode);
	nCurrentPreSendQLen++;
}



static void IdleSampler(void)
{
	/* Back to idle mode */
	if (UsesCIAInterrupt())
	{
		Disable();
		IntData.BIdle = 1L;
		SetTimerCountdown(NULL, BPSToMicros(ulIdleRate));
		Enable();
	}
}



/* Sets the values of the POUT, SEL, and BUSY bits as given by the
   code ubBitCode. */
#define SETCIA(x) (pciab->ciapra|=(x))
#define CLRCIA(x) (pciab->ciapra&=~(x))
static void SetParallelBits(int nEvent, UBYTE ubBitCode)
{
	if (ubBitCode == 0) return;
	if (ubBitCode & SAMPBIT_POUTCLR) CLRCIA(CIAF_PRTRPOUT);
	if (ubBitCode & SAMPBIT_POUTSET) SETCIA(CIAF_PRTRPOUT);
	
	if (ubBitCode & SAMPBIT_SELCLR)  CLRCIA(CIAF_PRTRSEL);
	if (ubBitCode & SAMPBIT_SELSET)  SETCIA(CIAF_PRTRSEL);
	
	if (ubBitCode & SAMPBIT_BUSYCLR) CLRCIA(CIAF_PRTRBUSY);
	if (ubBitCode & SAMPBIT_BUSYSET) SETCIA(CIAF_PRTRBUSY);
	
	if (nEvent > EVENT_NONE) printf("SetParallelBits: (%s) Executed code %s, control bits are now %s.\n",
	   szEventStrings[nEvent], BitsToString(ubBitCode), RegToString(pciab->ciapra));
}

/* Sets the values of the POUT, SEL, and BUSY bits for the data
   direction register, as given by the code ubBitCode. */
#define SETDCIA(x) (pciab->ciaddra|=(x))
#define CLRDCIA(x) (pciab->ciaddra&=~(x))
static void SetDirectionBits(UBYTE ubBitCode)
{
	if (ubBitCode == 0) return;
	if (ubBitCode & SAMPBIT_POUTCLR) CLRDCIA(CIAF_PRTRPOUT);
	if (ubBitCode & SAMPBIT_POUTSET) SETDCIA(CIAF_PRTRPOUT);
	
	if (ubBitCode & SAMPBIT_SELCLR)  CLRDCIA(CIAF_PRTRSEL);
	if (ubBitCode & SAMPBIT_SELSET)  SETDCIA(CIAF_PRTRSEL);
	
	if (ubBitCode & SAMPBIT_BUSYCLR) CLRDCIA(CIAF_PRTRBUSY);
	if (ubBitCode & SAMPBIT_BUSYSET) SETDCIA(CIAF_PRTRBUSY);

	if ((ubSamplerType == SAMPLER_CUSTOM)&&
	    (ubBitCode != (SAMPBIT_POUTSET | SAMPBIT_SELSET | SAMPBIT_BUSYSET))) printf("SetDirectionBits:  Executed %s, direction bits are now %s\n",BitsToString(ubBitCode),RegToString(pciab->ciaddra));
}

/* Returns the changes a given byte code will do/has done. */
static char * BitsToString(UBYTE ubCode)
{
	static char szResult[13];
	
	memset(szResult,0,sizeof(szResult));
	if (ubCode & SAMPBIT_POUTCLR) strcat(szResult,"-P");
	if (ubCode & SAMPBIT_POUTSET) strcat(szResult,"+P");
	if (ubCode & SAMPBIT_SELCLR)  strcat(szResult,"-S");
	if (ubCode & SAMPBIT_SELSET)  strcat(szResult,"+S");
	if (ubCode & SAMPBIT_BUSYCLR) strcat(szResult,"-B");
	if (ubCode & SAMPBIT_BUSYSET) strcat(szResult,"+B");
	return(szResult);
}

/* Returns the state of the register. */
static char * RegToString(UBYTE ubReg)
{
	static char szResult[25];
	
	sprintf(szResult,"P=%i,B=%i,S=%i",
		(ubReg & CIAF_PRTRPOUT) != 0,
		(ubReg & CIAF_PRTRBUSY) != 0,
		(ubReg & CIAF_PRTRSEL)  != 0);
	
	return(szResult);
}


/* Should work much like Toccata's T_FindFrequency function ... */
static ULONG AHI_FindFrequency(ULONG ulBPS)
{
	ULONG ulIndex=0, ulFreq=0;
	struct TagItem taglist[3];

	taglist[0].ti_Tag  = AHIDB_Index; 	taglist[0].ti_Data  = &ulIndex;
	taglist[1].ti_Tag  = AHIDB_IndexArg; 	taglist[1].ti_Data  = ulBPS;
	taglist[2].ti_Tag  = TAG_DONE;		taglist[2].ti_Data  = NULL;
	if (AHI_GetAudioAttrsA(ulAHIAudioMode, NULL, taglist))
	{
		printf("AHI_FindFrequency: Nearest index = %lu\n",ulIndex);
		taglist[0].ti_Tag  = AHIDB_Frequency; 	taglist[0].ti_Data  = &ulFreq;
		taglist[1].ti_Tag  = AHIDB_FrequencyArg;taglist[1].ti_Data  = ulIndex;
		if (AHI_GetAudioAttrsA(ulAHIAudioMode, NULL, taglist))
		{
			printf("AHI_FindFrequency: Frequency to use:  %lu\n",ulFreq);
			return(ulFreq);
		}
	}
	return(1L);
}
