/* AmiPhone!  by Jeremy Friesner - jfriesne@ucsd.edu */

#define INTUI_V36_NAMES_ONLY

#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <time.h>

#include <devices/timer.h>
#include <devices/ahi.h>
#include <dos/dos.h>
#include <dos/dostags.h>
#include <dos/dosextens.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <intuition/gadgetclass.h>
#include <intuition/screens.h>
#include <libraries/gadtools.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/io.h>
#include <exec/libraries.h>
#include <libraries/dos.h>			/* contains RETURN_OK, RETURN_WARN #def's */
#include <graphics/gfxbase.h>
#include <libraries/gadtools.h>
#include <sys/types.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <resources/misc.h>
#include <graphics/text.h>

#include <errno.h>
#include <inetd.h>

#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/wb_protos.h>
#include <clib/icon_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/iffparse_protos.h>

#include <pragmas/ahi_pragmas.h>

#include "toccata/include/libraries/toccata.h"
#include "toccata/include/clib/toccata_protos.h"
#include "toccata/include/pragmas/toccata_pragmas.h"

#include "phonerexx.h"

#include "menuconstants.h"
#include "ciatimer.h"
#include "phoneudp.h"
#include "AmiPhone.h"
#include "messages.h" 
#include "AmiPhoneMsg.h"
#include "AmiPhonePacket.h"
#include "browse.h"
#include "codec.h"
#include "stringrequest.h"
#include "TCPQueue.h"
#include "delfph.h"

#define EWOULDBLOCK     35

#define IMAGE_QUIET	0
#define IMAGE_XMIT1	1
#define IMAGE_XMIT2	2
#define IMAGE_XMIT3	3
#define IMAGE_XMIT4	4
#define IMAGE_NOCONN	5
#define IMAGE_DISABLED	6
#define IMAGE_TAPE      7

#define LEFT_SHIFT	0x60
#define RIGHT_SHIFT	0x61
#define SPACE_BAR	0x40

#define DOTSPACING 4

#define VSPACE	3
#define HSPACE	3

/* defines */
#define SLIDER_WIDTH	90
#define MIC_OFFSET	5	/* offset from nearest window borders */
#define MIC_DEPTH	2
#define MIC_WIDTH	38
#define MIC_HEIGHT	39
#define MIC_ROWS	312
#define MIC_LEFT	(MIC_OFFSET*2)
#define MIC_BYTESPERROW 5 /* 38 + remaining bits, padded out to byte boundary of 40 */
#define MIC_NUMFRAMES	8
#define MIC_FRAMEWORDS  117				/* number of words/anim frame */
#define MIC_PLANEWORDS  (MIC_FRAMEWORDS*MIC_NUMFRAMES)	/* Offset in ushorts to next bitplane */
#define IsInMicButton(x,y) (((x)>=MIC_LEFT)&&((x)<(MIC_LEFT+MIC_WIDTH))&&((y)>=nMicTop)&&((y)<nMicTop+MIC_HEIGHT))

#define WID_TOP		(4+Scr->WBorTop+Scr->Font->ta_YSize)
#define WIDLEFT 	(MIC_WIDTH + MIC_OFFSET + 5)
#define WIDWIDTH	17
#define WIDHEIGHT 	24
#define WIDRECHEIGHT 	14

#define VOLBARLEFT	(MIC_LEFT + MIC_WIDTH + 3)
#define VOLBARTOP	(WID_TOP+1)
#define VOLBARRIGHT	(VOLBARLEFT + 3)

#define WINDOWWIDTH 	350
#define WINDOWHEIGHT 	(MIC_HEIGHT + MIC_OFFSET + WID_TOP)

#define MAXHEIGHT	(nRecGraphBottom-nRecGraphTop)
#define HEIGHT144	(1440*MAXHEIGHT/(ulMaxBandwidth))


#define GTIMERGO 	SetTimer(GraphicTimerIO, 0, 500000)

/* Color codes for the scrolling graph */
#define COLOR_SEND 	    7 
#define COLOR_SEND_ERROR    2
#define COLOR_RECEIVE       6
#define COLOR_RECEIVE_ERROR 3

/* For key equivalents */
#define SMALL_RATE_CHANGE 10
#define LARGE_RATE_CHANGE 50

#define FIRST_CONNECT_TO    6

/* menus */
struct NewMenu nmMenus[] = {
	NM_TITLE, "Project",         NULL,  0L,     	NULL, NULL,
	NM_ITEM,  "About",            "?",  0L,     	NULL, (void *) P_ABOUT,
	NM_ITEM,  NM_BARLABEL,       NULL,  0L,     	NULL, NULL,
	NM_ITEM,  "Quit",             "Q",  0L,     	NULL, (void *) P_QUIT,
	NM_TITLE, "TCP",             NULL,  0L,    	NULL, NULL,
	NM_ITEM,  "Connect To",      NULL,  0L,     	NULL, NULL,
	NM_SUB,   "",   	      "1",  0L,   	NULL, (void *) (T_CONNECTTO+0),
	NM_SUB,   "",		      "2",  0L,   	NULL, (void *) (T_CONNECTTO+1),
	NM_SUB,   "",   	      "3",  0L,   	NULL, (void *) (T_CONNECTTO+2),
	NM_SUB,   "",                 "4",  0L,   	NULL, (void *) (T_CONNECTTO+3),
	NM_SUB,   "",                 "5",  0L,   	NULL, (void *) (T_CONNECTTO+4),
	NM_SUB,   "",                 "6",  0L,   	NULL, (void *) (T_CONNECTTO+5),
	NM_SUB,   "",                 "7",  0L,   	NULL, (void *) (T_CONNECTTO+6),
	NM_SUB,   "",                 "8",  0L,   	NULL, (void *) (T_CONNECTTO+7),
	NM_SUB,   "",                 "9",  0L,   	NULL, (void *) (T_CONNECTTO+8),
	NM_SUB,   "",                 "0",  0L,   	NULL, (void *) (T_CONNECTTO+9),
	NM_ITEM,  "Connect",          "C",  0L,     	NULL, (void *) T_CONNECT,
	NM_ITEM,  "Disconnect",       "D",  0L,     	NULL, (void *) T_DISCONNECT,
	NM_ITEM,   "Show Daemon",     "S",  CHECKIT,    NULL, (void *) T_SHOWDAEMON,
	NM_TITLE, "Messages",	     NULL,  0L,         NULL, NULL,
	NM_ITEM,  "Messages...",      "M",  0L,         NULL, (void *) M_MESSAGES,
	NM_ITEM,  "Play Sound File",  "P",  0L,         NULL, (void *) M_PLAYFILE,
	NM_ITEM,  "Record Memo",      "W",  CHECKIT,    NULL, (void *) M_RECORDMEMO,
	NM_TITLE, "Settings",        NULL,  0L,     	NULL, NULL,
	NM_ITEM,  "Sampler",	     NULL,  0L,         NULL, NULL,
	NM_SUB,   "DSS8",	     NULL,  CHECKIT,    NULL, (void *) S_DSS8,
	NM_SUB,   "PerfectSound",    NULL,  CHECKIT,    NULL, (void *) S_PERFECTSOUND,
	NM_SUB,   "AMAS",	     NULL,  CHECKIT,    NULL, (void *) S_AMAS,
	NM_SUB,   "Sound Magic",     NULL,  CHECKIT,    NULL, (void *) S_SOMAGIC,
	NM_SUB,   "Toccata",         NULL,  CHECKIT,    NULL, (void *) S_TOCCATA,
	NM_SUB,   "Aura PCMCIA",     NULL,  CHECKIT,    NULL, (void *) S_AURA,
	NM_SUB,   "AHI Device",      NULL,  CHECKIT,    NULL, (void *) S_AHI,
	NM_SUB,   "Delfina",         NULL,  CHECKIT,    NULL, (void *) S_DELFINA,
	NM_SUB,   "Custom",	     NULL,  CHECKIT,    NULL, (void *) S_CUSTOM,
	NM_SUB,   "Generic",         NULL,  CHECKIT,    NULL, (void *) S_GENERIC,	
	NM_ITEM,  "Compression",     NULL,  0L,	        NULL, NULL,	
	NM_SUB,   "ADPCM2",           "U",  CHECKIT,    NULL, (void *) S_ADPCM2,
	NM_SUB,   "ADPCM3",           "I",  CHECKIT,    NULL, (void *) S_ADPCM3,
	NM_SUB,   "None",             "O",  CHECKIT,    NULL, (void *) S_NOCOMP,
	NM_ITEM,  "Transmit Enable", NULL,  0L,		NULL, NULL,	
	NM_SUB,   "Toggle",           "T",  CHECKIT,    NULL, (void *) S_TOGGLE,
	NM_SUB,   "Hold to Transmit", "H",  CHECKIT,    NULL, (void *) S_HOLD,
	NM_ITEM,  "Line Gain",       NULL,  0L,		NULL, NULL,	
	NM_SUB,   "Raise",            "]",  0L,    	NULL, (void *) S_RAISELINEGAIN,
	NM_SUB,   "Lower",            "[",  0L,    	NULL, (void *) S_LOWERLINEGAIN,
	NM_ITEM,  "Microphone Gain", NULL,  0L,		NULL, NULL,
	NM_SUB,   "+20 dB",           "}",  CHECKIT,   	NULL, (void *) S_TWENTYMICGAIN,
	NM_SUB,   "+0 dB",            "{",  CHECKIT,   	NULL, (void *) S_ZEROMICGAIN,	
	NM_ITEM,  "Digital Amplify", NULL,  0L,         NULL, NULL,
	NM_SUB,   "1X",	             NULL,  CHECKIT,    NULL, (void *) S_AMPONE,
	NM_SUB,   "2X",	             NULL,  CHECKIT,    NULL, (void *) S_AMPTWO,
	NM_SUB,   "4X",	             NULL,  CHECKIT,    NULL, (void *) S_AMPFOUR,
	NM_ITEM,  "Input Channel",   NULL,  0L,		NULL, NULL,		
	NM_SUB,   "Left",             "L",  CHECKIT,   	NULL, (void *) S_LEFTCHANNEL,
	NM_SUB,   "Right",            "R",  CHECKIT,   	NULL, (void *) S_RIGHTCHANNEL,
	NM_ITEM,  "Input Source",    NULL,  0L,		NULL, NULL,	
	NM_SUB,   "Microphone",       "-",  CHECKIT,   	NULL, (void *) S_INPUTMIC,
	NM_SUB,   "Line",             "=",  CHECKIT,   	NULL, (void *) S_INPUTEXT,
	NM_ITEM,  "Enable on Connect","X",  CHECKIT,    NULL, (void *) S_ENABLEONCONN,
	NM_ITEM,  "Xmit on Play",     "Y",  CHECKIT,    NULL, (void *) S_XMITONPLAY,
	NM_ITEM,  "TCP Batch Xmit",   "B",  CHECKIT,    NULL, (void *) S_TCPBATCHXMIT,
	NM_END,   NULL,		     NULL,  NULL,   	NULL, NULL
};


/* private functions */
char * OpenLibraries(BOOL BOpen);
static void SetPhoneEntry(int nNum, char * szCode);
static void StopSoundPlayer(BOOL BNotifyUser);
static void HandleSoundPort(BOOL BAllowNewPlayers);
static BOOL AllocAHI(BOOL BAlloc);
static void HandleAppWindow(void);
static void GetSliderInfo(int * pnLabelWidth, int * pnValueWidth, int * pnHeight);

/* private functions */
static UBYTE ParseBits(char * szString);
static int CalcWindowHeight(int nFontHeight);
static int CalcWindowWidth(int nLabelWidth, int nValueWidth);

/* private file-global data */
static char [] = VERSION_STRING;
static struct AmiPhoneInfo defMsg;
static char szExitMessage[50] = "Error Initializing";
static int ngExitVal = RETURN_ERROR;
static int argc;
static char ** argv;
static struct DiskObject *AmiPhoneIconDiskObject = NULL;
static char * szPhoneFileName = NULL;
static char szWinTitle[130] = "";
static struct Gadget *glist=NULL, *gad=NULL, *freqslider=NULL, *volslider=NULL, *delayslider=NULL;
static struct NewGadget ng;
static struct MsgPort * AppWindowPort = NULL;
static struct AppWindow * AppWindow = NULL;
static int nRecGraphTop, nRecGraphBottom, nRecGraphRight, nRecGraphLeft, nVolBarBottom;
static BOOL BPropFont = FALSE;

/* global vars */
struct AmiPhoneInfo * daemonInfo = &defMsg;		

/* AHI stuff? */
struct Library    *AHIBase=NULL;
struct MsgPort    *AHImp=NULL;
struct AHIRequest *AHIio=NULL;
BYTE               AHIDevice=-1;

char szVoiceMailDir[300] = "\0";
FILE * fpMemo = NULL;
void   *vi=NULL;
const int Not[2] = {1,0};
struct GfxBase * GfxBase       = NULL;
struct Library * RexxSysBase   = NULL;
struct Library * TimerBase     = NULL;
struct Library * IntuitionBase = NULL;
struct Library * SocketBase    = NULL;
struct Library * GraphicsBase  = NULL;
struct Library * GadToolsBase  = NULL;
struct Library * IconBase      = NULL;
struct Library * ToccataBase   = NULL;
struct Library * WorkbenchBase = NULL;
struct Library * DiskFontBase  = NULL;
extern struct Library * DelfinaBase;

struct Library * MiscBase      = NULL;	/* this one not alloced with the others... */

struct Screen *Scr = NULL;
struct Window *PhoneWindow = NULL;
struct Menu * Menu = NULL;
struct AmiPhoneGraphicsInfo GraphInfo;
struct Process * GraphicDaemonProcess = NULL;
struct RexxHost * rexxHost = NULL;

BOOL BNetConnect = FALSE, BTransmitting = FALSE, BStartedFromWB = FALSE, BSoundOn=FALSE;
BOOL BGraphicsDaemon=FALSE, BButtonHeld = FALSE, BSpaceTapped = FALSE;
BOOL BEnableOnConnect = FALSE, BXmitOnPlay = FALSE, BTCPBatchXmit = FALSE;
BOOL BWasSamplingBefore = FALSE, BBrowserIsRunning = FALSE, BInvertSamples = FALSE;
BOOL BUserDebug = FALSE;

struct BitMap MicBitMap;	/* For the kewl transmit button */
int nAnimFrame=0;

ULONG ulDebug = 0L;
ULONG ulBytesSentSince = 0L;
ULONG ulTimerDelay = 0L;
ULONG ulMilliSecondsTaken;

struct timerequest *GraphicTimerIO  = NULL;
struct MsgPort	   *GraphicTimerMP  = NULL;
struct Message	   *GraphicTimerMSG = NULL;
struct Task * MainTask = NULL, *SoundPlayerTask = NULL, *FileReqTask = NULL;
struct TextFont * fontdata = NULL;	/* The font's bits */

/* Here's where all data is compressed to and sent from */
struct AmiPhoneSendBuffer	sendBuf;
struct MsgPort *PhonePort = NULL, *SoundTaskPort = NULL;

/* Used to send playing messages */
extern struct AmiPhonePacketHeader * TransferPacket;

/* user defaults */
char szProgramName[30];
static int nOldSendPri = 9999;	/* obviously invalid */
UBYTE ubSamplerType = SAMPLER_GENERIC;
char * pszCallNames[] = {NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
char * pszCallIPs[]   = {NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
int windowtop=-1, windowleft=-1, nSendPri = 999, nReceivePri = 1, nToggleMode = TOGGLE_TOGGLE, nSampleTechnique = TECHNIQUE_HARDINT;
ULONG ulSampleArraySize; 
ULONG ulKeyCode = 0L, ulRexxReceiveAve = 0L, ulRexxSendAve = 0L; 
ULONG ulIdleRate = 500L;
ULONG ulBytesPerSecond = 5600L, ulLastVolume, ulMaxBandwidth = 2880;
float fPacketDelay = 0.2;	/* number of seconds between each packet */
int nHackAmpVol = 1000;
int nMinSampleVol = 7, nMaxSampleRate = DEFAULT_MAX_SAMPLE_RATE, nAmpShift = 0, nMaxDelay = MAX_PACKET_INTERVAL * 1000;
UBYTE ubCurrComp = COMPRESS_ADPCM2, ubInputChannel = INPUT_JACK_LEFT, ubInputSource = INPUT_SOURCE_MIC;
UBYTE ubCustStart=0, ubCustStop=0, ubCustLeft=0, ubCustRight=0, ubCustMic=0, ubCustExt=0, ubCustDir=SAMPBIT_SELSET | SAMPBIT_POUTSET | SAMPBIT_BUSYSET;
UBYTE * pubCustSampleAt = NULL;
BOOL BZoomed = FALSE, BProgramDone = FALSE;
int nFontSize = 0, nMicTop = 0, nPostSendLen = 1, nPreSendQLen = 0;	/* 0 = default */
char szFont[100]			= "";
char szPubScreenName[100] 		= "";
char szPeerName[MAXPEERNAMELENGTH]      = "";

const char szSliderLabel1[] = "Sampling Rate";
const char szSliderLabel2[] = "Transmit Delay";
const char szSliderLabel3[] = "Silence Filter";

const char szSliderValue1[] = "88888Hz";
const char szSliderValue2[] = "999ms";
const char szSliderValue3[] = "88%";

/* external data */
extern struct IntInfo IntData;
extern BYTE sighalf, sigfull;
extern __chip unsigned short microphone_image[];
extern UBYTE * pubAllocedArray, * pubRightBuffer;
extern struct AmiPhonePacketHeader * TransmitPacket[2];
extern LONG sTCPSocket;
extern char szLastMemoFile[200] = "(unset)";
extern int delfsig, nMicGainValue;

/* Data to use after we get a CTRL-F from the Toccata Capture interrupt */
extern UBYTE * pubBulkSamplePacket;
extern ULONG ulBulkSamplePacketSum;

void debug(int nSec)
{
	printf("Waiting at debug point: [%i]\n",nSec);
	Delay(20);
}

void GraphicUpdate(ULONG ulSignals)
{
	if (GraphicDaemonProcess) 
	{
		Forbid(); GraphInfo.ubCommand |= ulSignals; Permit();
		Signal((struct Task *)GraphicDaemonProcess,SIGBREAKF_CTRL_F);
	}
}

BOOL UsesInvertedSamples(void)
{
	BOOL BResult = (ubSamplerType == SAMPLER_GVPDSS8);
	
	if (BInvertSamples) BResult = Not[BResult];	
	return(BResult);
}

BOOL UsesCIAInterrupt(void)
{
	return((ubSamplerType != SAMPLER_DELFINA) &&
	       (ubSamplerType != SAMPLER_AHI) &&
	       (ubSamplerType != SAMPLER_TOCCATA));
}

BOOL CanAmplify(void)
{
	return(TRUE);
}

BOOL CanAdjustLineGain(void)
{
	return((ubSamplerType == SAMPLER_PERFECT) ||
	       (ubSamplerType == SAMPLER_TOCCATA) ||
	       (ubSamplerType == SAMPLER_DELFINA) ||
	       (ubSamplerType == SAMPLER_GVPDSS8));
}

BOOL CanAdjustMicGain(void)
{
	return((ubSamplerType == SAMPLER_TOCCATA) ||
	       (ubSamplerType == SAMPLER_DELFINA));
}

BOOL CanAdjustInputSource(void)
{
	return((ubSamplerType == SAMPLER_SOMAGIC) ||
	       (ubSamplerType == SAMPLER_CUSTOM)  ||
	       (ubSamplerType == SAMPLER_DELFINA) ||
	       (ubSamplerType == SAMPLER_TOCCATA));
}


BOOL CanAdjustInputChannel(void)
{
	return(ubSamplerType != SAMPLER_TOCCATA);
}



BOOL AllocSliders(BOOL BAlloc)
{	
	if (BAlloc == TRUE)
	{		
		static struct TextAttr font;
		static char szLevelString1[30],szLevelString2[30],szLevelString3[30];
		int nLabelWidth, nValueWidth, nHeight, nSpacing;
	
		if (strlen(szFont) > 0) 
		{
			font.ta_Name  = szFont;
			if (nFontSize == 0) font.ta_Flags |= FPF_DESIGNED;
			font.ta_YSize = nFontSize;
			
			UNLESS(fontdata = OpenDiskFont(&font))
			{
				printf("Warning: Couldn't load font %s/%i\n",szFont,nFontSize);
				AskFont(&Scr->RastPort, &font);
			}
		}
		else AskFont(&Scr->RastPort, &font);

		BPropFont = ((font.ta_Flags & FPF_PROPORTIONAL) != 0);
		
		GetSliderInfo(&nLabelWidth, &nValueWidth, &nHeight);	
		if (font.ta_YSize == 0) font.ta_YSize = nHeight;

		nSpacing = ((CalcWindowHeight(nHeight)-WID_TOP-Scr->WBorBottom-(nHeight*3))/3) + nHeight;
		
		UNLESS(vi = GetVisualInfo(Scr,TAG_END)) return(FALSE);
		gad = CreateContext(&glist);

		/* setup sampling frequency slider */
		ng.ng_TextAttr   = &font;
		ng.ng_VisualInfo = vi;
		ng.ng_GadgetText = szSliderLabel1;
		ng.ng_LeftEdge   = MIC_LEFT+MIC_WIDTH+(VOLBARRIGHT-VOLBARLEFT)+(HSPACE*3)+nLabelWidth;
		ng.ng_TopEdge    = WID_TOP;
		ng.ng_Height     = nHeight;
		ng.ng_Width      = SLIDER_WIDTH;
		ng.ng_GadgetID   = FREQ_SLIDER;
		ng.ng_Flags      = PLACETEXT_LEFT;
		sprintf(szLevelString1,"%%%iluHz%s", 4+(nMaxSampleRate>=10000), BPropFont?"  ":"");		
		freqslider = gad = CreateGadget(SLIDER_KIND, gad, &ng,
			GTSL_Min,		(WORD)MIN_SAMPLE_RATE,
			GTSL_Max,		(WORD)nMaxSampleRate,
			GTSL_Level,		(WORD)ulBytesPerSecond,
			GTSL_LevelFormat, 	szLevelString1,
			GTSL_LevelPlace,	PLACETEXT_RIGHT,
			GTSL_MaxLevelLen,	7+(nMaxSampleRate >= 10000)+(BPropFont*2),
			GA_RelVerify,		TRUE,
			TAG_END);


		/* setup send delay slider */
		ng.ng_TopEdge    += nSpacing;
		ng.ng_GadgetText = szSliderLabel2;
		ng.ng_GadgetID   = DELAY_SLIDER;
		sprintf(szLevelString2,"%%%ilums%s", 3, BPropFont?"  ":"");		
		delayslider = gad = CreateGadget(SLIDER_KIND, gad, &ng,
			GTSL_Min,		(WORD)(MIN_PACKET_INTERVAL*1000.0),	/* .09 seconds */
			GTSL_Max,		(WORD)(nMaxDelay),	/* 700 mS or as specified by user */
			GTSL_Level,		(WORD)(fPacketDelay*1000.0),		/* in milliseconds */
			GTSL_LevelFormat, 	szLevelString2,
			GTSL_LevelPlace,	PLACETEXT_RIGHT,
			GTSL_MaxLevelLen,	6+(BPropFont*2),
			GA_RelVerify,		TRUE,
			TAG_END);

		/* setup minimum volume slider */
		ng.ng_TopEdge    += nSpacing;
		ng.ng_GadgetText = szSliderLabel3;
		ng.ng_GadgetID   = VOLUME_SLIDER;
		sprintf(szLevelString3,"%%%ilu%%%%%s", 2, BPropFont?"  ":"");
		volslider = gad = CreateGadget(SLIDER_KIND, gad, &ng,
			GTSL_Min,		(WORD)0,
			GTSL_Max,		(WORD)99,
			GTSL_Level,		(WORD)nMinSampleVol,
			GTSL_LevelFormat, 	szLevelString3,
			GTSL_LevelPlace,	PLACETEXT_RIGHT,
			GTSL_MaxLevelLen,	4+(BPropFont*2),
			GA_RelVerify,		TRUE,
			TAG_END);
	}
	else
	{
		if (fontdata) {CloseFont(fontdata); fontdata = NULL;}
		if (glist) {FreeGadgets(glist); glist = NULL;}
		if (vi)    {FreeVisualInfo(vi); vi    = NULL;}
	}	
	return(TRUE);
}


void InitMicButton(void)
{
	int i;
	
	InitBitMap(&MicBitMap, MIC_DEPTH, MIC_WIDTH, MIC_ROWS);

	for (i=0;i<MicBitMap.Depth;i++)
	{
		MicBitMap.Planes[i]   = 
			(PLANEPTR) &microphone_image[i*MIC_PLANEWORDS];	
	}
	return;
}

/* given a string, return the COMPRESS_MODE of it */
UBYTE ParseCompMode(char * szParam)
{
	UpperCase(szParam);
	
	if (strcmp(szParam,"ADPCM2") == 0) return(COMPRESS_ADPCM2);
	if (strcmp(szParam,"ADPCM3") == 0) return(COMPRESS_ADPCM3);
	if (strcmp(szParam,"NONE")   == 0) return(COMPRESS_NONE);

	/* default */
	return(COMPRESS_ADPCM2);
}




/* given a string, return the SAMPLER_TYPE of it */
UBYTE ParseSamplerType(char * szParam)	
{
	UpperCase(szParam);
	
	/* The GVP DSS8 digitizer.  What I have :) */
	if ((strncmp(szParam,"DSS",3) == 0)  ||
	    (strncmp(szParam,"GVP",3) == 0)) return(SAMPLER_GVPDSS8);

	/* The custom digitizer.  i.e. do whatever the user says to do */
	if (strncmp(szParam,"CUSTOM",6) == 0) return(SAMPLER_CUSTOM);
	
	/* The Perfect Sound digitizer (no distinction currently made 
	   for different versions thereof) */
	if (strncmp(szParam,"PERFECT",7) == 0) return(SAMPLER_PERFECT);
	    
	/* The Tocatta 8/16 bit Zorro II based digitizer/sound card.  
	   For sampling only, in 8 bit mode.
	   Only recognize this ToolType if toccata.library is available. */
	if ((ToccataBase)&&(strncmp(szParam,"TOC",3) == 0)) return(SAMPLER_TOCCATA);
	
	/* AMAS.  Untested.  */
	if (strcmp(szParam,"AMAS") == 0)    return(SAMPLER_AMAS);
	
	/* Generic.  AmiPhone makes few assumptions about the digitizer.
	   This is the default.  */
	if (strcmp(szParam,"GENERIC") == 0) return(SAMPLER_GENERIC);

	/* Sound magic. */
	if (strncmp(szParam,"SO",2) == 0)   return(SAMPLER_SOMAGIC);

	/* Aura 12-bit PCMCIA. */
	if (strcmp(szParam,"AURA") == 0)    return(SAMPLER_AURA);

	/* Delfina board. */
	if ((DelfinaBase)&&(strcmp(szParam,"DELFINA") == 0)) return(SAMPLER_DELFINA);

	/* The AHI Device sound API */
	if ((AHIBase)&&(strncmp(szParam,"AHI",3) == 0))  return(SAMPLER_AHI);
		
	/* default */
	return(SAMPLER_GENERIC);
}


/* given a ubType, write the correct string into szWriteParam (max length: 20) */
void GetSamplerType(char * szWriteParam, UBYTE ubType)	
{
	char * szType = "????";
	
	switch(ubType)
	{
		case SAMPLER_GVPDSS8:	szType = "GVPDSS8"; break;
		case SAMPLER_CUSTOM:	szType = "CUSTOM";  break;
		case SAMPLER_PERFECT:	szType = "PERFECTSOUND"; break;
		case SAMPLER_TOCCATA:	szType = "TOCCATA"; break;
		case SAMPLER_AMAS:	szType = "AMAS";    break;
		case SAMPLER_GENERIC:	szType = "GENERIC"; break;
		case SAMPLER_SOMAGIC:	szType = "SOUNDMAGIC"; break;
		case SAMPLER_AURA:	szType = "AURA";    break;
		case SAMPLER_DELFINA:	szType = "DELFINA"; break;
		case SAMPLER_AHI:	szType = "AHI";	    break;
	}
	Strncpy(szWriteParam, szType, 20);
}

/* given a ubType, write the correct string into szWriteParam (max length: 20) */
void GetSamplerState(char * szWriteParam)	
{
	char * szType = "????";
	
	switch(GraphInfo.nImageTop)
	{
		case IMAGE_QUIET: szType = "QUIET"; break;
		
		case IMAGE_NOCONN:szType = "NOCONN"; break;
		
		case IMAGE_DISABLED:szType = "DISABLED"; break;
		
		case IMAGE_XMIT1: case IMAGE_XMIT2: 
		case IMAGE_XMIT3: case IMAGE_XMIT4:	
		case IMAGE_TAPE:
				  szType = "XMITTING"; 
				  break;
	}
	Strncpy(szWriteParam, szType, 20);
}



void DrawMicButton(int nOptImage)
{
	int nImage = 0;

	if (PhoneWindow == NULL) return;

	if (nOptImage >= 0) nImage = nOptImage;	/* override */
	else
	{
		/* default logic */
		if (BTransmitting == TRUE) 	nImage = (nAnimFrame+1);
		if (BSoundOn == FALSE) 		nImage = IMAGE_QUIET;
		if (BTransmitting == FALSE)	nImage = IMAGE_DISABLED;
		if ((fpMemo == NULL)&&(BNetConnect == FALSE)) 	nImage = IMAGE_NOCONN;	
		if ((SoundPlayerTask)&&(BXmitOnPlay)&&(BNetConnect)) nImage = IMAGE_TAPE;
	}
	GraphInfo.nImageTop = nImage;
	GraphicUpdate(MSG_CONTROL_DOANIM);
}




void DrawHitBox(int nLeft, int nTop, int nRight, int nBottom, int nBackCol, BOOL BPressed)
{
	struct RastPort * rp = PhoneWindow->RPort;

	/* First draw the background color */
	SetAPen(rp, nBackCol);

	RectFill(rp, nLeft, nTop, nRight, nBottom);
		
	/* Now draw the "press" lines */
	if (BPressed == TRUE) SetAPen(rp, 1); /* black */
			 else SetAPen(rp, 2); /* white */
			 
	/* Draw top press line */
	Move(rp, nLeft+1, nTop);	Draw(rp, nRight-1, nTop);

	/* Draw left press line */
	Move(rp, nLeft, nTop+1); 	Draw(rp, nLeft, nBottom-1);
	
	if (BPressed == FALSE) SetAPen(rp, 1); /* black */
			  else SetAPen(rp, 2); /* white */
	
	/* Draw bottom press line */
	Move(rp, nLeft+1, nBottom);	Draw(rp, nRight-1, nBottom);

	/* Draw right press line */
	Move(rp, nRight, nTop+1); 	Draw(rp, nRight, nBottom-1);
}






/* Code = CODE_ON, CODE_OFF, CODE_TOGGLE */
void ToggleMicButton(int nCode)
{
	BOOL BOldState = BTransmitting;

	if (nCode == CODE_TOGGLE)
	{
		if (BOldState == TRUE)  nCode = CODE_OFF;
		if (BOldState == FALSE) nCode = CODE_ON;
	}
	
	/* Avoid donothing cases--just refresh the button is all */
	if (((nCode == CODE_ON) &&(BTransmitting           == TRUE))  ||
            ((nCode == CODE_ON) &&(SoundPlayerTask != NULL)&&(BXmitOnPlay == TRUE))  ||
	    ((nCode == CODE_OFF)&&(BTransmitting           == FALSE)) || 
	    ((BNetConnect == FALSE)&&(fpMemo == NULL)&&(nCode == CODE_ON)))
	{
		DrawMicButton(-1);
		return;
	}

	/* toggle the sampler */
	BTransmitting = StartSampling(Not[BTransmitting], ulBytesPerSecond);

	/* If we're stopping the sound, tell the daemon to flush his buffer */
	if ((nCode == CODE_OFF)&&(BNetConnect == TRUE)) SendCommandPacket(PHONECOMMAND_FLUSH,0,0L);
	if (nCode == CODE_ON) BSoundOn = FALSE;	/* assume no sound until proven otherwise */
	
	if (BTransmitting != BOldState)
	{
		if (BTransmitting == TRUE) SetWindowTitle("Sampler Enabled.");
				      else SetWindowTitle("Sampler Disabled.");
	}
	DrawMicButton(-1);
}



void DisplayAbout(void)
{	
	char szMessage[300]="";
	BOOL BWasOn = BTransmitting;
	
	if (BWasOn == TRUE) ToggleMicButton(CODE_OFF);
	sprintf(szMessage,"AmiPhone v%i.%i%s\nby Jeremy Friesner\njfriesne@ucsd.edu\nCompiled: %s",
				VERSION_NUMBER/100, VERSION_NUMBER%100,
				#ifdef DEBUG_FLAG
				"D",
				#else
				"",
				#endif
				__DATE__);
	MakeReq(NULL,szMessage,"Groovy");
	if (BWasOn == TRUE) ToggleMicButton(CODE_ON);
				
}





void UserError(char * message)
{
	MakeReq("AmiPhone Error", message, NULL);
}



#define NUM_WEIGHTS 5
void UpdateReceiveDisplays(void)
{
	static ULONG ulWeightsR[NUM_WEIGHTS], ulWeightsS[NUM_WEIGHTS];
	static BYTE bNext = -1;
	ULONG ulSizeR = daemonInfo->ulLastPacketSize, ulSizeS = ulBytesSentSince;
	ULONG ulTotalR = 0L, ulTotalS = 0L, ulTemp;
	
	if (bNext == -1)
	{
		/* First time through here--initialize */
		for (ulTemp=0;ulTemp<NUM_WEIGHTS;ulTemp++) 
			ulWeightsR[ulTemp] = ulWeightsS[ulTemp] = 0L;
	}
	
	bNext = (bNext + 1) % NUM_WEIGHTS;
	ulWeightsR[bNext] = ulSizeR;
	ulWeightsS[bNext] = ulSizeS;
	
	/* calculate averages */
	for (ulTemp=0; ulTemp<NUM_WEIGHTS; ulTemp++) 
	{
		ulTotalR += ulWeightsR[ulTemp];
		ulTotalS += ulWeightsS[ulTemp];
	}

	ulRexxReceiveAve = ulTotalR/NUM_WEIGHTS << 1;
	ulRexxSendAve    = ulTotalS/NUM_WEIGHTS << 1;

	Forbid(); 
	GraphInfo.BErrorR     |= daemonInfo->BErrorR;
	GraphInfo.nBarHeightR  = ulRexxReceiveAve * MAXHEIGHT / ulMaxBandwidth;
	GraphInfo.nBarHeightS  = ulRexxSendAve    * MAXHEIGHT / ulMaxBandwidth + GraphInfo.nBarHeightR;
	Permit();

	GraphicUpdate(MSG_CONTROL_DOGRAPH);

	/* Reset LastPacketSize, etc. */
	daemonInfo->ulLastPacketSize = 0L;
	daemonInfo->BErrorR	     = FALSE;
	ulBytesSentSince	     = 0L;	
}








BOOL CreatePhoneMenus(BOOL BCreate)
{   
	void * VisualInfo = NULL;

	if (BCreate == FALSE) 
	{
		if (Menu) {FreeMenus(Menu); Menu = NULL;}
		return(TRUE);
	}

	/* Create menus */
	UNLESS(Menu = CreateMenus(nmMenus, TAG_DONE))
	{
		UserError("Couldn't Create Menus!");
		return(FALSE);
	}
	
	UNLESS(VisualInfo = GetVisualInfo(Scr, TAG_END))
	{
		UserError("Couldn't get visual info for menus!");
		return(FALSE);
	}
	
	if (LayoutMenus(Menu, VisualInfo, TAG_DONE))
	{
		SetMenuStrip(PhoneWindow, Menu);
	}
	else
	{
		FreeVisualInfo(VisualInfo);
		UserError("Couldn't LayoutMenus!");
		return(FALSE);
	}
	FreeVisualInfo(VisualInfo);
	return(TRUE);
}



/* Custom set window title function */
void SetWindowTitle(char * szOptNewMessage)
{
	static char szLastMessage[100] = "";
	char szShortPeerName[11];
	char szPacketString[11] = "";
	char * pcTemp;
	int nTCPQLenMS;
	
	if (szOptNewMessage) Strncpy(szLastMessage, szOptNewMessage, sizeof(szLastMessage));
	
	Strncpy(szShortPeerName, szPeerName, sizeof(szShortPeerName));
	if (pcTemp = strchr(szShortPeerName,'.')) *pcTemp='\0';

	/* Estimate the milliseconds of audio in the queue! */
	if (nTCPQLenMS = (1000*TCPQueueBytes(0))/ulBytesPerSecond)
	{
		switch(ubCurrComp)
		{
			case COMPRESS_ADPCM3:	nTCPQLenMS = nTCPQLenMS * 8 / 3;	break;
			case COMPRESS_ADPCM2:	nTCPQLenMS *= 4;			break;
		}
		sprintf(szPacketString, "[%i.%is] ", nTCPQLenMS/1000, (nTCPQLenMS%1000)/100);
	}
	
	sprintf(szWinTitle,"%s%s%s %s%s",
		(BNetConnect ? "(" : ""),
		(BNetConnect ? szShortPeerName : ""),
		(BNetConnect ? ")" : ""),
		szPacketString,
		szLastMessage);

	if (PhoneWindow) 
	{
		/* Do this from the graphic update process if possible, to avoid blocking */
		if (BGraphicsDaemon) GraphicUpdate(MSG_CONTROL_DOTITLE);
	                else SetWindowTitles(PhoneWindow, szWinTitle, (char *) ~0);
	}
}




	

void UpperCase(char *sOldString)
{
	char *i = sOldString;
	const int diff = 'a' - 'A';

	UNLESS(sOldString) return();
	
	while (*i != '\0')
	{
        	if ((*i >= 'a')&&(*i <= 'z')) *i = *i - diff;
        	i++;
 	}
 	return;
}


void LowerCase(char *sOldString)
{
	char *i = sOldString;
	const int diff = 'a' - 'A';

	UNLESS(sOldString) return();
	while (*i != '\0')
 	{
        	if ((*i >= 'A')&&(*i <= 'Z')) *i += diff;
        	i++;
 	}
 	return;
}


/* useful defines for menu controls */
void SetMenuValues(void)
{
	struct Menu *currentMenu = Menu;
	struct MenuItem *currentItem, *currentSub;
	int i;
	
 	UNLESS(currentMenu) return;
 	
 	DrawMicButton(-1);
 	   
	if (PhoneWindow) ClearMenuStrip(PhoneWindow);

	/* Project Menu */
	/* Do Nothing for now */
	
	/* TCP Menu/Connect */
	NEXTMENU; if (SocketBase) ENABLEMENU; else DISABLEMENU;
	FIRSTITEM;if (BNetConnect) DISABLEITEM; else ENABLEITEM;
	FIRSTSUB;
	for (i=0;i<10;i++) 
	{
		if (pszCallIPs[i]) ENABLESUB; else DISABLESUB;
		NEXTSUB;
	}
	NEXTITEM; if (BNetConnect) DISABLEITEM; else ENABLEITEM;

 	NEXTITEM; if (BNetConnect) ENABLEITEM; else DISABLEITEM; 
	NEXTITEM; if (daemonInfo->daemonTask) ENABLEITEM; else DISABLEITEM;
		  if (daemonInfo->BWindowIsOpen) CHECKITEM; else UNCHECKITEM;

	/* Messages Menu */
	NEXTMENU;
	FIRSTITEM; if ((strlen(szVoiceMailDir) == 0)||(BBrowserIsRunning)) DISABLEITEM; else ENABLEITEM;
	NEXTITEM;  if (FileReqTask) DISABLEITEM; else ENABLEITEM;
	NEXTITEM;  if (strlen(szVoiceMailDir) == 0) DISABLEITEM; else ENABLEITEM;
		   if (fpMemo != NULL) CHECKITEM; else UNCHECKITEM;
	
	/* Settings Menu/Sampler/DSS8 */
	NEXTMENU; FIRSTITEM; 
	FIRSTSUB; if (ubSamplerType == SAMPLER_GVPDSS8) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ubSamplerType == SAMPLER_PERFECT) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ubSamplerType == SAMPLER_AMAS)    CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ubSamplerType == SAMPLER_SOMAGIC) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ToccataBase) 
		  {
		  	ENABLESUB; 
		  	if (ubSamplerType == SAMPLER_TOCCATA) CHECKSUB; else UNCHECKSUB;
		  }
		  else
		  {
		  	DISABLESUB;
		  	UNCHECKSUB;
		  }
	NEXTSUB;  if (ubSamplerType == SAMPLER_AURA) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (AHIBase)
		  {
		  	ENABLESUB;
		  	if (ubSamplerType == SAMPLER_AHI) CHECKSUB; else UNCHECKSUB;
		  }
		  else
		  {
		  	DISABLESUB;
		  	UNCHECKSUB;
		  }
	NEXTSUB;  if (DelfinaBase)
		  {
		  	ENABLESUB;
		  	if (ubSamplerType == SAMPLER_DELFINA) CHECKSUB; else UNCHECKSUB;
		  }
		  else
		  {
		  	DISABLESUB;
		  	UNCHECKSUB;
		  }
	NEXTSUB;  if (ubSamplerType == SAMPLER_CUSTOM)  CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ubSamplerType == SAMPLER_GENERIC) CHECKSUB; else UNCHECKSUB;

	/* compression submenu */
	NEXTITEM; 
	FIRSTSUB; if (ubCurrComp == COMPRESS_ADPCM2) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ubCurrComp == COMPRESS_ADPCM3) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ubCurrComp == COMPRESS_NONE)   CHECKSUB; else UNCHECKSUB;

	/* Hold/toggle submenu */
	NEXTITEM; 
	FIRSTSUB; if (nToggleMode == TOGGLE_TOGGLE) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (nToggleMode == TOGGLE_HOLD)   CHECKSUB; else UNCHECKSUB;

	/* Line Gain submenu */
	NEXTITEM; if (CanAdjustLineGain()) ENABLEITEM; else DISABLEITEM;
	
	/* Mic Gain submenu */
	NEXTITEM; if (CanAdjustMicGain()) ENABLEITEM; else DISABLEITEM;
	FIRSTSUB; if (nMicGainValue == 20) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (nMicGainValue == 0)  CHECKSUB; else UNCHECKSUB;

	/* Amplify submenu */
	NEXTITEM; if (CanAmplify()) ENABLEITEM; else DISABLEITEM;
	FIRSTSUB; if (nAmpShift == 0) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (nAmpShift == 1) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (nAmpShift == 2) CHECKSUB; else UNCHECKSUB;
	
	/* Input channel submenu */
	NEXTITEM; if (CanAdjustInputChannel()) ENABLEITEM; else DISABLEITEM;
	FIRSTSUB; if (ubInputChannel == INPUT_JACK_LEFT)  CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ubInputChannel == INPUT_JACK_RIGHT) CHECKSUB; else UNCHECKSUB;

	/* Input source submenu */
	NEXTITEM; if (CanAdjustInputSource()) ENABLEITEM; else DISABLEITEM;
	FIRSTSUB; if (ubInputSource == INPUT_SOURCE_MIC) CHECKSUB; else UNCHECKSUB;
	NEXTSUB;  if (ubInputSource == INPUT_SOURCE_EXT) CHECKSUB; else UNCHECKSUB;
	
	/* Xmit on connect */
	NEXTITEM; if (BEnableOnConnect == FALSE)  UNCHECKITEM; else CHECKITEM;
	          if (nToggleMode == TOGGLE_HOLD) DISABLEITEM; else ENABLEITEM;	 
	
	/* Xmit on play */
	NEXTITEM; if (BXmitOnPlay == TRUE) CHECKITEM; else UNCHECKITEM;

	/* TCP Batch Xmit */
	NEXTITEM; if (BTCPBatchXmit == TRUE) CHECKITEM; else UNCHECKITEM;
		
	if (PhoneWindow) ResetMenuStrip(PhoneWindow,Menu);	

	/* If we are using a board that does not support volume
	   detection, disable the volume threshold
	   slider */
	GT_SetGadgetAttrs(volslider,PhoneWindow,NULL, GA_Disabled, 
				Not[CanMeasureVolume()], TAG_END);
}


/* Tries to start recording if BStart is TRUE, else stops */
/* sets fpMemo */
BOOL StartRecording(BOOL BStart, char * szOptFileName)
{
	static time_t tStartTime;
	ULONG ulSecondsTaken = ulMilliSecondsTaken / 1000;
	
	if (BStart == (fpMemo != NULL)) return(FALSE);	/* is it already doing what we want? */
	if (BStart == TRUE)
	{
		tStartTime = time(NULL);
		if (fpMemo = szOptFileName ? fopen(szOptFileName,"wb")
		  	 	           : OpenMessageFile(tStartTime,szVoiceMailDir))
		{
			if (szOptFileName) Strncpy(szLastMemoFile, szOptFileName, sizeof(szLastMemoFile));
			ulMilliSecondsTaken = 0L;
			SetWindowTitle("Ready to record memo.");
			DrawMicButton(-1);
			return(TRUE);
		}
		SetWindowTitle("Error opening memo file.");
		return(FALSE);
	}
	else
	{
		BTransmitting = StartSampling(FALSE, ulBytesPerSecond);
		fclose(fpMemo);
		/* If no bytes were written, remove the file */
		UNLESS(ResetByteCounter()) RemoveMessageFile(tStartTime,szVoiceMailDir);
		fpMemo = NULL;
		if (ulSecondsTaken == 0L) ulSecondsTaken = 1L;
		SetMessageNote(tStartTime, "(Memo)", szVoiceMailDir, ulSecondsTaken);
		SetWindowTitle("Memo recording finished.");
		DrawMicButton(-1);
		return(TRUE);
	}
}

BOOL CanMeasureVolume(void)
{
	return(TRUE);
}


VOID wbmain(struct WBStartup *wbargv)
{
	BStartedFromWB = TRUE;
	main(0,(char **)wbargv);
}


BOOL FakeIDCMPMessage(ULONG class, ULONG code, ULONG qual)
{
	struct IntuiMessage fake;
	
	fake.Class      = class;
	fake.Code       = code;
	fake.Qualifier  = qual;
	
	return(HandleIDCMP(&fake));
}


void ChangeVolumeThreshold(int nNewPercentage)
{
	nMinSampleVol = nNewPercentage;	  /* set the new volume to what the slider indicates */
	GT_SetGadgetAttrs(volslider, PhoneWindow, NULL, GTSL_Level, nMinSampleVol, TAG_END);
	IntData.ulThreshhold  = (nPreSendQLen == 0) ? ((nMinSampleVol*255)/100) : 0L;
	DrawMicButton(-1);
}



/* Handler for window events */
/* If fakeMessage is non-NULL, we'll use that as a parameter from our
   own code, and not reply it to Intuition */
BOOL HandleIDCMP(struct IntuiMessage * fakeMessage)
{
	struct IntuiMessage * message;
	ULONG class, code, qual, ulItemCode, ulNewFreq;
	struct MenuItem * mItem;
	struct Gadget * gad;
	static LONG lCode;
		
	/* Get the first message from the queue, or use the fake one if we have it*/
	message = fakeMessage ? fakeMessage : ((struct IntuiMessage *) GT_GetIMsg(PhoneWindow->UserPort));

	/* Examine pending messages */	
	while (message)
	{
		class = message->Class;		/* extract needed info from message */
		code  = message->Code;
		qual  = message->Qualifier;
		gad   = (struct Gadget *) message->IAddress;

		/* If the message came from Intuition, tell them we got it */
		if (message != fakeMessage) GT_ReplyIMsg(message);

		/* see what events occured, take correct action */
		switch(class)
		{	
			case IDCMP_MOUSEMOVE:
				/* this is here because of the slider gadget--no need to do anything, though */
				break;
				
			case IDCMP_GADGETUP:
				switch((message == fakeMessage) ? qual : gad->GadgetID)
				{
					case FREQ_SLIDER:
						/* everything is done below for us! */
						break;
						
					case DELAY_SLIDER:
						fPacketDelay = ((float) code)/1000.0;	/* set new packet delay */
						if (message == fakeMessage) GT_SetGadgetAttrs(delayslider, PhoneWindow, NULL, GTSL_Level, code, TAG_END);
						code = ulBytesPerSecond;  /* make same as before */
						break;
						
					case VOLUME_SLIDER:
						ChangeVolumeThreshold(code);
						code = ulBytesPerSecond;  /* make same as before */
						break;
				}
				GT_SetGadgetAttrs(freqslider,PhoneWindow,NULL,GTSL_Level, 
				       ChangeSampleSpeed(code,ubCurrComp), TAG_END);
				break;

			case IDCMP_NEWSIZE:
				BZoomed = Not[BZoomed];
				if (!BZoomed) 
				{
					DrawWindowBoxes();
					GraphicUpdate(MSG_CONTROL_DOANIM | MSG_CONTROL_DOGRAPH);
				}
				break;
				
			case IDCMP_REFRESHWINDOW:
				GT_BeginRefresh(PhoneWindow);
				GT_EndRefresh(PhoneWindow, TRUE);
				break;
					
			case IDCMP_CLOSEWINDOW: 
				SetExitMessage("Window Closed",0);
				BProgramDone = TRUE;  
				break;
				
			case IDCMP_VANILLAKEY:
				if (code == ' ')
				{
					     if (nToggleMode == TOGGLE_TOGGLE) ToggleMicButton(CODE_TOGGLE);
					else if (nToggleMode == TOGGLE_HOLD)   
					{
						BSpaceTapped = TRUE;
						BButtonHeld  = TRUE;
						ToggleMicButton(CODE_ON);
					}
				}
						
				if ((code == 'e')||(code == 'E')) 
				{
					ToggleMicButton(CODE_ON);
					if (nToggleMode == TOGGLE_HOLD)
					{
						BSpaceTapped = TRUE;
						BButtonHeld = TRUE;
					}
				}
				if ((code == 'd')||(code == 'D')) ToggleMicButton(CODE_OFF);
				
				if (ubSamplerType == SAMPLER_TOCCATA)
				{
					if ((code == '.')||(code == '>'))
					{
						ulNewFreq = ChangeSampleSpeed(T_NextFrequency(ulBytesPerSecond), ubCurrComp);
						GT_SetGadgetAttrs(freqslider, PhoneWindow, NULL, GTSL_Level, ulNewFreq, TAG_END);	
					}
					if ((code == ',')||(code == '<'))
					{
						 GT_SetGadgetAttrs(freqslider,PhoneWindow,NULL,
							   GTSL_Level, ChangeSampleSpeed(T_FindFrequency(0), ubCurrComp), TAG_END);	
					}
				}
				else
				{
					if (code == ',') GT_SetGadgetAttrs(freqslider,PhoneWindow,NULL,
							   GTSL_Level, ChangeSampleSpeed(ulBytesPerSecond-SMALL_RATE_CHANGE, ubCurrComp), TAG_END);
					if (code == '.') GT_SetGadgetAttrs(freqslider,PhoneWindow,NULL,
							   GTSL_Level, ChangeSampleSpeed(ulBytesPerSecond+SMALL_RATE_CHANGE, ubCurrComp), TAG_END);
					if (code == '<') GT_SetGadgetAttrs(freqslider,PhoneWindow,NULL,
							   GTSL_Level, ChangeSampleSpeed(ulBytesPerSecond-LARGE_RATE_CHANGE, ubCurrComp), TAG_END);
					if (code == '>') GT_SetGadgetAttrs(freqslider,PhoneWindow,NULL,
							   GTSL_Level, ChangeSampleSpeed(ulBytesPerSecond+LARGE_RATE_CHANGE, ubCurrComp), TAG_END);
				}
				break;
				
			case IDCMP_MENUPICK:
				while( code != MENUNULL ) 
				{
					if (message == fakeMessage)
					{
						ulItemCode = code;
					}
					else
					{
						mItem = ItemAddress( Menu, code );
						ulItemCode = (ULONG) GTMENUITEM_USERDATA(mItem);
					}
					switch(ulItemCode)
					{
						case P_ABOUT: 		DisplayAbout(); 				   break;
						case P_QUIT: 		SetExitMessage("You Quit",0); BProgramDone = TRUE; break;
						case T_CONNECT: 	DrawWindowBoxes(); ConnectPhoneSocket(TRUE,szPeerName); break;
						case T_DISCONNECT:	SetWindowTitle("Connection closed."); ClosePhoneSocket(); break;
						case T_SHOWDAEMON:	daemonInfo->BWantWindowOpen = Not[daemonInfo->BWindowIsOpen];  if (daemonInfo->daemonTask) Signal(daemonInfo->daemonTask,SIGBREAKF_CTRL_D); break;
						case M_MESSAGES:	StartBrowser(szVoiceMailDir); 	    break;
						case M_PLAYFILE:	FileReqTask = LaunchFileReq(szVoiceMailDir); break;
						case M_RECORDMEMO:	StartRecording(fpMemo == NULL,NULL);break;
						case S_DSS8:		ChangeSamplerType(SAMPLER_GVPDSS8); break;
						case S_PERFECTSOUND:	ChangeSamplerType(SAMPLER_PERFECT); break;
						case S_AMAS:		ChangeSamplerType(SAMPLER_AMAS);    break;
						case S_TOCCATA:		ChangeSamplerType(SAMPLER_TOCCATA); break;
						case S_CUSTOM:		ChangeSamplerType(SAMPLER_CUSTOM);  break;
						case S_GENERIC:		ChangeSamplerType(SAMPLER_GENERIC); break;
						case S_AURA:		ChangeSamplerType(SAMPLER_AURA);    break;
						case S_AHI:		ChangeSamplerType(SAMPLER_AHI);     break;
						case S_DELFINA:		ChangeSamplerType(SAMPLER_DELFINA); break;
						case S_SOMAGIC:		ChangeSamplerType(SAMPLER_SOMAGIC); break;
						case S_ADPCM2:		ChangeCompressMode(COMPRESS_ADPCM2);break;
						case S_ADPCM3:		ChangeCompressMode(COMPRESS_ADPCM3);break;
						case S_NOCOMP:		ChangeCompressMode(COMPRESS_NONE);  break;
						case S_TOGGLE:		nToggleMode = TOGGLE_TOGGLE;    break;
						case S_HOLD:		nToggleMode = TOGGLE_HOLD; ToggleMicButton(CODE_OFF); break;
						case S_ENABLEONCONN:	BEnableOnConnect = Not[BEnableOnConnect];	   break;
						case S_XMITONPLAY:	BXmitOnPlay      = Not[BXmitOnPlay];	   break;
						case S_TCPBATCHXMIT:	BTCPBatchXmit    = Not[BTCPBatchXmit]; break;
						case S_RAISELINEGAIN:	RaiseLineGain(1);		     break;
						case S_LOWERLINEGAIN:	RaiseLineGain(-1);	   	     break;
						case S_TWENTYMICGAIN:   SetMicGain(20);			     break;
						case S_ZEROMICGAIN:	SetMicGain(0);			     break;
						case S_AMPONE:		nAmpShift = 0; IntData.ulShiftLeft = 0L; break;
						case S_AMPTWO:		nAmpShift = 1; IntData.ulShiftLeft = 1L; break;
						case S_AMPFOUR:		nAmpShift = 2; IntData.ulShiftLeft = 2L; break;
						case S_LEFTCHANNEL:	ChangeInputChannel(INPUT_JACK_LEFT); break;
						case S_RIGHTCHANNEL:	ChangeInputChannel(INPUT_JACK_RIGHT); break;
						case S_INPUTMIC:        ChangeInputSource(INPUT_SOURCE_MIC,TRUE); break;
						case S_INPUTEXT:        ChangeInputSource(INPUT_SOURCE_EXT,TRUE); break;
						default: 		
							if ((ulItemCode >= T_CONNECTTO)&&(ulItemCode <= T_CONNECTTO+9))
							{
								DrawWindowBoxes(); 
								Strncpy(szPeerName,pszCallIPs[ulItemCode-T_CONNECTTO],MAXPEERNAMELENGTH);
								ConnectPhoneSocket(FALSE,szPeerName);
							}
							break;
					}
					code = (message == fakeMessage) ? MENUNULL : mItem->NextSelect;
				}
				SetMenuValues();
				break;
				       
			case IDCMP_MOUSEBUTTONS:
				if (code == SELECTDOWN)
				{
					if (IsInMicButton(message->MouseX,message->MouseY)) 
					{
						BButtonHeld = TRUE;
						ToggleMicButton(CODE_TOGGLE);
					}
				}
				else if ((code == SELECTUP)&&(nToggleMode == TOGGLE_HOLD))
				{
					BButtonHeld = FALSE;
					ToggleMicButton(CODE_OFF);
				}
				break;
				
			default:        printf("handleIDCMP: bad class\n");
					break;
		}
	
		/* Only do the one message if it's a faked message */
		if (message == fakeMessage) return(BProgramDone);

		/* Get next message from the queue */
		message = (struct IntuiMessage *)GT_GetIMsg(PhoneWindow->UserPort);
	}
	return(BProgramDone);
}

	

/* Give param of TRUE to open libraries, param of FALSE to close */
/* returns NULL on success, name of unopened library on failure */
static char * OpenLibraries(BOOL BOpen)
{	
	if (BOpen == TRUE)
	{		
		/* Open critical libraries, or fail! */
		UNLESS(IntuitionBase = OpenLibrary("intuition.library",        37L)) return("intuition");
		UNLESS(GfxBase = GraphicsBase = OpenLibrary("graphics.library",37L)) return("graphics");
		UNLESS(GadToolsBase = OpenLibrary("gadtools.library",          36L)) return("gadtools");
		UNLESS(IconBase = OpenLibrary("icon.library",                  33L)) return("icon");
		UNLESS(DiskFontBase = OpenLibrary("diskfont.library",  	       37L)) return("diskfont");

		/* These libraries are optional--if they aren't opened, that's okay */
		WorkbenchBase = OpenLibrary("workbench.library",  37L);
		SocketBase    = OpenLibrary("bsdsocket.library",   2L);
		ToccataBase   = OpenLibrary("toccata.library",     6L);
		RexxSysBase   = OpenLibrary("rexxsyslib.library", 36L);
		
		InitDelfina();	/* On success of this function, DelfinaBase is set to non-NULL */
		
		AllocAHI(TRUE);
	}
	else
	{
		AllocAHI(FALSE);
		if (DelfinaBase)	 CleanupDelfina();
		if (ToccataBase)	 CloseLibrary(ToccataBase);
		if (WorkbenchBase)	 CloseLibrary(WorkbenchBase);
		if (RexxSysBase)   	 CloseLibrary(RexxSysBase);
		if (IntuitionBase) 	 CloseLibrary(IntuitionBase);
		if (SocketBase) 	 CloseLibrary(SocketBase);
		if (GraphicsBase) 	 CloseLibrary(GraphicsBase);
		if (GadToolsBase) 	 CloseLibrary(GadToolsBase);
		if (DiskFontBase)	 CloseLibrary(DiskFontBase);
		if (IconBase) 		 CloseLibrary(IconBase);
	}
	return(NULL);	/* NULL == success */
}





void SetExitMessage(char * message, int nExitVal)
{
	Strncpy(szExitMessage,message,sizeof(szExitMessage));
	ngExitVal = nExitVal;
}


BOOL StartSoundPlayer(char * szFileName)
{
	if (SoundPlayerTask = LaunchPlayer(szFileName))
	{
		BWasSamplingBefore = BTransmitting;
		if (BXmitOnPlay) ToggleMicButton(CODE_OFF);
		return(TRUE);
	}
	return(FALSE);
}


/* Don't return until the sound player has gone bye bye! */
static void StopSoundPlayer(BOOL BNotifyUser)
{
	UNLESS(SoundPlayerTask) return;
	
	if (BNotifyUser) SetWindowTitle("Closing SoundPlayer.");

	Signal(SoundPlayerTask, SIGBREAKF_CTRL_C);

	/* Stop any playing sounds! */
	while (SoundPlayerTask) 
	{
		WaitPort(SoundTaskPort);	   
		HandleSoundPort(FALSE);
	}
}


void CleanExit(void)
{
	char szBuf[30];
	int nWaitIter=0,i;
	BOOL BAbortWait = FALSE;
	struct Message * SMessage;
	
	/* Stop recording any file we may be recording to */
	StartRecording(FALSE,NULL);

	/* Kill off our soundplayer port, and make sure the sound player won't hang waiting for us... */
	if (SoundTaskPort) 
	{
		/* Kill any playing sounds */
		StopSoundPlayer(TRUE);
	
		/* Kill the browser window */
		if (BBrowserIsRunning == TRUE)
		{
			SetWindowTitle("Closing Browser.");
			StopBrowser();			/* basically ctrl-c's it! */
			WaitPort(SoundTaskPort);	/* Wait for the ack */
			SMessage = GetMsg(SoundTaskPort);	/* Remove the ack */
			ReplyMsg((struct Message *)SMessage);	/* Let the guy continue */
		}

		/* If FileRequester is open, wait for it to be closed */
		while(FileReqTask)
		{
			SetWindowTitle("Please Close the File Requester!");
			WaitPort(SoundTaskPort);	   
			HandleSoundPort(FALSE);
		}
	
		/* Get rid of SoundTaskPort! */
		Forbid();
		while(SMessage = GetMsg(SoundTaskPort)) ReplyMsg(SMessage);
		DeleteMsgPort(SoundTaskPort);
		SoundTaskPort = NULL;
		Permit();
	}		
	
	/* Tell server to exit */
	if (BNetConnect) ClosePhoneSocket();
	AddPhonePort(FALSE);
	
	/* Get rid of graphics daemon */
	if (BGraphicsDaemon)
	{
		SetWindowTitle("Closing Graphics Daemon.");
				
		/* Wait for graphics daemon to respond */
		while(BGraphicsDaemon)
		{
			GraphicUpdate(MSG_CONTROL_BYE);
			Delay(1);
		}
	}
	SetWindowTitle("Shutting Down.");

        if (GraphicTimerIO != NULL)
        {
                if (!(CheckIO((struct IORequest *)GraphicTimerIO))) 
                {
                        AbortIO((struct IORequest *)GraphicTimerIO);   /* Ask device to abort any pending requests */
                        WaitIO((struct IORequest *)GraphicTimerIO);    /* proceed when ready */
                }
                CloseDevice((struct IORequest *) GraphicTimerIO);
                DeleteExtIO((struct IORequest *) GraphicTimerIO);
	}
        if (GraphicTimerMP != NULL) DeletePort(GraphicTimerMP);

	if (PhonePort != NULL) 
	{	
		/* Reply any and all pending messages */
		Forbid();
		while (SMessage = GetMsg(PhonePort)) ReplyMsg(SMessage);
		DeleteMsgPort(PhonePort);
		Permit();
	}

	if (ngExitVal > RETURN_WARN)
	{
	     printf("CleanExit: [%s] (exit code %i)\n", szExitMessage, ngExitVal);
	     if (IntuitionBase)
	     {
		sprintf(szBuf,"Exit (Code %i)", ngExitVal);
		MakeReq(NULL,szExitMessage, szBuf);
	     }
	}
			    
	AllocSignals(FALSE);
	
 	if (AppWindow) RemoveAppWindow(AppWindow); 		

	/* throw out any leftover messages */
	if (AppWindowPort)
	{
		struct Message * amsg;
		
		Forbid();
		while(amsg = (struct AppMessage *) GetMsg(AppWindowPort)) ReplyMsg(amsg);
	 	Permit();
 		DeleteMsgPort(AppWindowPort);
 	}
 	
	if (PhoneWindow) CloseWindow(PhoneWindow);
	
	CreatePhoneMenus(FALSE);		
	AllocSliders(FALSE);	
	if (Scr) UnlockPubScreen(NULL,Scr);

	/* If we changed our pri, reset to old one */
	if ((nOldSendPri < 128)&&(MainTask)) SetTaskPri(MainTask, nOldSendPri);

	/* Free all memory allocated for the Connect_To menu */
	for (i=0;i<10;i++)
	{
		if (pszCallNames[i]) FreeMem(pszCallNames[i],strlen(pszCallNames[i])+1);
		if (pszCallIPs[i])   FreeMem(pszCallIPs[i],  strlen(pszCallIPs[i])  +1);

	}

	SetupPreSendQueue(FALSE);	
	SetupTCPQueue(0,FALSE);
	
	if (rexxHost) CloseDownARexxHost(rexxHost);

	OpenLibraries(FALSE);		/* close all libraries */
}


LONG ChopValue(LONG ulVal, LONG ulLow, LONG ulHigh)
{
	if (ulVal < ulLow)  ulVal = ulLow;
	if (ulVal > ulHigh) ulVal = ulHigh;
	return(ulVal);
}


UBYTE ParseInputChannel(char * szParam)
{
	UpperCase(szParam);
	if (strcmp(szParam,"RIGHT") == 0) return(INPUT_JACK_RIGHT);
	if (strcmp(szParam,"LEFT")  == 0) return(INPUT_JACK_LEFT);
	
	/* default */
	return(INPUT_JACK_LEFT);
}


/* Sets all startup options from startup arguments, using ToolTypes if
   BStartedFromWB is TRUE, otherwise from command line */
void ParseArgs(BOOL BFromCLIButParseIconToo)
{
	int nParam,i;
	BOOL BSuccess;
	char *szParam = NULL, *pcTemp;
	static char szIconName[150];
	char szTemp[13];
	
	if ((BStartedFromWB)||(BFromCLIButParseIconToo))
	{
		if (BFromCLIButParseIconToo)
		{
			szPhoneFileName = argv[0];
			*szIconName = '\0';

			if ((szPhoneFileName == NULL)||(strlen(szPhoneFileName) == 0)||(strcmp(szPhoneFileName," ") == 0)) szPhoneFileName = "AmiPhone";
			
			/* Add path, if there isn't a base in the filename */
			pcTemp = strchr(szPhoneFileName,':');
			if (pcTemp == NULL) strcpy(szIconName,"PROGDIR:");		

			/* Add in executable name */
			strncat(szIconName, szPhoneFileName, sizeof(szIconName));

			szPhoneFileName = szIconName;			
		}
				
		if (SetupToolTypeArg(szPhoneFileName) == FALSE) 
		{
        		szPhoneFileName = NULL;
		        if (BFromCLIButParseIconToo) ParseArgs(FALSE);
			return;
		}

	}	/* can't proceed unless we can access the icon! */
	else
	{
		/* Check to see if we want to autoconnect */
		if (argc > 1)
		{
			if ((IsKeyword(argv[1]) == FALSE)&&(SocketBase))
			{
				/* autoconnect! */
				Strncpy(szPeerName, argv[1], sizeof(szPeerName));
			}
		}
	}
	
	GetPhoneArg("TOP", &windowtop, &szParam);
	GetPhoneArg("LEFT", &windowleft, &szParam);
	
	/* Secret command line arg sent by AmiPhoned when it launches us! */
	if (GetPhoneArg("_KEY", &nParam, &szParam))
	{
		if (pcTemp = strchr(szParam,'|'))
		{
			*pcTemp = '\0';
			if (daemonInfo = ((struct AmiPhoneInfo *) atol(&pcTemp[1]))) daemonInfo->nPri = nReceivePri;
		}
		UNLESS(ulKeyCode = atol(szParam)) daemonInfo = NULL;
	}
	
	if (GetPhoneArg("SAMPLETECHNIQUE", &nParam, &szParam))	     
	{
		UpperCase(szParam);
		if (strncmp(szParam,"SOFT",4) == 0)
		{
			nSampleTechnique  = TECHNIQUE_SOFTINT;  
			ulBytesPerSecond /= 2;
		}
		else if (strncmp(szParam,"HARD",4) == 0)
		{
			nSampleTechnique  = TECHNIQUE_HARDINT;
		}
	}
	
	/* Dont do autoconnect from tooltype if we started from CLI!  It's annoying */
	if ((SocketBase)&&(!BFromCLIButParseIconToo)&&(GetPhoneArg("CONNECT", &nParam, &szParam)))
					Strncpy(szPeerName,szParam,sizeof(szPeerName));
					
	if (GetPhoneArg("MAXBANDWIDTH", &nParam, &szParam))  ulMaxBandwidth = ChopValue(nParam,75,100000);
	if (GetPhoneArg("COMPRESS", &nParam, &szParam))      ubCurrComp     = ParseCompMode(szParam);
	
	if (GetPhoneArg("THRESHVOLUME", &nParam, &szParam))  nMinSampleVol  = ChopValue(nParam,0,99);
	if (GetPhoneArg("MINVOLUME", &nParam, &szParam))     nMinSampleVol  = ChopValue(nParam,0,99);
	
	if (GetPhoneArg("ENABLEONCONNECT", &nParam, &szParam)) BEnableOnConnect = TRUE;
	if (GetPhoneArg("XMITONCONNECT", &nParam, &szParam)) BEnableOnConnect = TRUE;
	if (GetPhoneArg("XMITONPLAY", &nParam, &szParam))    BXmitOnPlay      = TRUE;
	if (GetPhoneArg("TCPBATCHXMIT", &nParam, &szParam))  BTCPBatchXmit    = TRUE;
	if (GetPhoneArg("SENDPRI", &nParam, &szParam))       nSendPri         = ChopValue(nParam,-127,127);
	if (GetPhoneArg("RECEIVEPRI", &nParam, &szParam))    nReceivePri      = ChopValue(nParam,-127,127);
	if (GetPhoneArg("HOLDTOTRANSMIT", &nParam, &szParam))nToggleMode      = TOGGLE_HOLD;
	if (GetPhoneArg("MAXSAMPLERATE", &nParam, &szParam)) nMaxSampleRate   = ChopValue(nParam,MIN_SAMPLE_RATE,ABSOLUTE_MAX_SAMPLE_RATE);
	if (GetPhoneArg("SAMPLERATE", &nParam, &szParam))    ulBytesPerSecond = ChopValue(nParam,MIN_SAMPLE_RATE,nMaxSampleRate);
	if (GetPhoneArg("SAMPLER", &nParam, &szParam))       ubSamplerType    = ParseSamplerType(szParam);
	if (GetPhoneArg("INPUTCHANNEL", &nParam, &szParam))  ubInputChannel   = ParseInputChannel(szParam);
	if (GetPhoneArg("VOICEMAILDIR", &nParam, &szParam))  Strncpy(szVoiceMailDir,szParam,sizeof(szVoiceMailDir));
        if (GetPhoneArg("INPUTSOURCE",&nParam,&szParam))
        {
        	if (*szParam == 'M') ubInputSource = INPUT_SOURCE_MIC;
        	if (*szParam == 'L') ubInputSource = INPUT_SOURCE_EXT;
        }
        else if (ubSamplerType == SAMPLER_TOCCATA)
	{
		/* Try to get current input source setting from Toccata prefs */
		struct TagItem taglist[2];
		LONG lInputSource;
		
		taglist[0].ti_Tag = PAT_Input; taglist[0].ti_Data = &lInputSource;
		taglist[1].ti_Tag = TAG_DONE;  taglist[1].ti_Data = NULL;
		T_GetPart(taglist);
		ubInputSource = (lInputSource == TINPUT_Mic) ? INPUT_SOURCE_MIC : INPUT_SOURCE_EXT;
        }
        if (GetPhoneArg("AMPLIFY",&nParam,&szParam))
        {
        	if (*szParam == '1') nAmpShift = 0;
        	if (*szParam == '2') nAmpShift = 1;
        	if (*szParam == '4') nAmpShift = 2;
        }

	BSuccess = GetPhoneArg("PUBSCREEN", &nParam, &szParam);
	if (!BSuccess) BSuccess = GetPhoneArg("PUBLICSCREEN", &nParam, &szParam);
	if (BSuccess) Strncpy(szPubScreenName,szParam,sizeof(szPubScreenName));
	
	if (GetPhoneArg("MAXXMITDELAY",&nParam,&szParam)) nMaxDelay = ChopValue(nParam,(MIN_PACKET_INTERVAL * 1000),999);
	if (GetPhoneArg("LINEGAIN",&nParam,&szParam)) RaiseLineGain(nParam);
	if (GetPhoneArg("MICGAIN",&nParam,&szParam)) SetMicGain(nParam ? 20 : 0);
	else if (ubSamplerType == SAMPLER_TOCCATA)
	{
		/* Try to get current gain settings from Toccata prefs */
		struct TagItem taglist[3];
		LONG lInputGain, lMicGain;
		
		taglist[0].ti_Tag = PAT_InputVolumeLeft; taglist[0].ti_Data = &lInputGain;
		taglist[1].ti_Tag = PAT_MicGain;	 taglist[1].ti_Data = &lMicGain;
		taglist[2].ti_Tag = TAG_DONE;		 taglist[2].ti_Data = NULL;
		T_GetPart(taglist);
		RaiseLineGain(lInputGain);
	}
	if (GetPhoneArg("IDLERATE",&nParam,&szParam)) ulIdleRate = ChopValue(nParam,1,ABSOLUTE_MAX_SAMPLE_RATE);
	if (GetPhoneArg("INVERTWAVEFORM",&nParam,&szParam)) BInvertSamples = TRUE;
	
	/* Custom digitizer control arguments */
	if (GetPhoneArg("PRESEND",	 &nParam, &szParam)) nPreSendQLen = nParam;
	if (GetPhoneArg("POSTSEND",	 &nParam, &szParam)) nPostSendLen = nParam;
	if (GetPhoneArg("CUSTSTARTBITS", &nParam, &szParam)) ubCustStart = ParseBits(szParam);
	if (GetPhoneArg("CUSTSTOPBITS",  &nParam, &szParam)) ubCustStop  = ParseBits(szParam);
	if (GetPhoneArg("CUSTDIRBITS",   &nParam, &szParam)) ubCustDir   = ParseBits(szParam);
	if (GetPhoneArg("CUSTLEFTBITS",  &nParam, &szParam)) ubCustLeft  = ParseBits(szParam);
	if (GetPhoneArg("CUSTRIGHTBITS", &nParam, &szParam)) ubCustRight = ParseBits(szParam);
	if (GetPhoneArg("CUSTEXTBITS",   &nParam, &szParam)) ubCustExt   = ParseBits(szParam);
	if (GetPhoneArg("CUSTMICBITS",   &nParam, &szParam)) ubCustMic   = ParseBits(szParam);
	if (GetPhoneArg("CUSTSAMPLEADDRESS", &nParam, &szParam)) pubCustSampleAt = ((UBYTE *) strtol(szParam, NULL, 16));
	if (GetPhoneArg("FONT", &nParam, &szParam)) 
	{
		strncpy(szFont,szParam,sizeof(szFont));
		LowerCase(szFont);
		UNLESS(strstr(szFont,".font")) strncat(szFont,".font",sizeof(szFont));
	}
	if (GetPhoneArg("FONTSIZE", &nParam, &szParam)) nFontSize = nParam;

	if (GetPhoneArg("DEBUG",	 &nParam, &szParam)) BUserDebug = TRUE;
	if (GetPhoneArg("HACKAMPVOL",	 &nParam, &szParam)) nHackAmpVol = nParam;
	/* Fill out "connect To" menu */
	for (i=0;i<10;i++)
	{
		sprintf(szTemp,"PHONEBOOK%i",i);
		SetPhoneEntry(((i==0) ? 9 : i-1), GetPhoneArg(szTemp, &nParam, &szParam) ? szParam : NULL);
	}

	/* Do this last, as it depends on previous constraints! */
	if (GetPhoneArg("XMITDELAY", &nParam, &szParam)) fPacketDelay = (((float)atoi(szParam))/1000.0);
	if (GetPhoneArg("PACKETINTERVAL", &nParam, &szParam)) fPacketDelay = (((float)atoi(szParam))/1000.0);
	
	/* Make sure the delay isn't too big or small */
	if (fPacketDelay < MIN_PACKET_INTERVAL)  fPacketDelay = MIN_PACKET_INTERVAL;
	if ((fPacketDelay * 1000.0) > nMaxDelay) fPacketDelay = (((float) nMaxDelay+1) / 1000.0);
	
        if (AmiPhoneIconDiskObject != NULL) 
        {
        	FreeDiskObject(AmiPhoneIconDiskObject);
        	AmiPhoneIconDiskObject = NULL;
        	szPhoneFileName = NULL;
        }
        
        /* Last, if we just parsed the icon even though we're running from CLI, */
        /* now we want to parse the command line as well. */
        if (BFromCLIButParseIconToo) ParseArgs(FALSE);

	return;
}


/* nNum = 0 at first entry, 9 at last entry */
static void SetPhoneEntry(int nNum, char * szCode)
{
	char * szIP;

	if ((pszCallNames[nNum])||(pszCallIPs[nNum]))
	{
		/* no sense replacing something with nothing */
		if (szCode == NULL) return;
		
		/* Deallocate old data */
		if (pszCallNames[nNum]) {FreeMem(pszCallNames[nNum],strlen(pszCallNames[nNum])+1); pszCallNames[nNum] = NULL;}
		if (pszCallIPs[nNum])   {FreeMem(pszCallIPs[nNum],  strlen(pszCallIPs[nNum])  +1); pszCallIPs[nNum]   = NULL;}
	}
	
	
	UNLESS(szCode) szCode = "<unused>";

	if (szIP = strchr(szCode,':')) 
	{
		*szIP = '\0'; /* chop the string */
		if (pszCallIPs[nNum] = AllocMem(strlen(szIP+1)+1,MEMF_CLEAR)) strcpy(pszCallIPs[nNum],szIP+1);
	}
	if (pszCallNames[nNum] = AllocMem(strlen(szCode)+1,MEMF_CLEAR)) strcpy(pszCallNames[nNum],szCode);

	if (szIP) *szIP = ':';	/* repair the string */
	nmMenus[nNum+FIRST_CONNECT_TO].nm_Label = pszCallNames[nNum];
}



/* returns the value of szString as an unsigned byte.
   
   szString should look like "+S+P+B"
  
   Where any bits after a + are set, any after a - are cleared.  
*/
static UBYTE ParseBits(char * szString)
{
	UBYTE ubResult = 0;
	char cSign = '+';
	char * pcTemp = szString;
	
	while(*pcTemp)
	{
		switch(*pcTemp)
		{
			case '+': case '-':  cSign = *pcTemp; break;
			
			case 'b': case 'B':
				if (cSign == '+') ubResult |= SAMPBIT_BUSYSET;
					     else ubResult |= SAMPBIT_BUSYCLR;
				break;
				

			case 'p': case 'P':
				if (cSign == '+') ubResult |= SAMPBIT_POUTSET;
					     else ubResult |= SAMPBIT_POUTCLR;
				break;

			case 's': case 'S':
				if (cSign == '+') ubResult |= SAMPBIT_SELSET;
					     else ubResult |= SAMPBIT_SELCLR;
				break;				
		}
		pcTemp++;
	}
	return(ubResult);
}


BOOL IsKeyword(char * szWord)
{
	BOOL BReturn = FALSE;
	char szBuf[30];
	char *pcTemp;
	
	Strncpy(szBuf, szWord, sizeof(szBuf));
	UpperCase(szBuf);
	
	if (pcTemp = strchr(szBuf,'=')) *pcTemp='\0';

	BReturn = ((0==strcmp(szBuf,"TOP"))  		||
		  (0==strcmp(szBuf,"LEFT")) 		||
		  (0==strcmp(szBuf,"KEY"))  		||
	 	  (0==strcmp(szBuf,"PUBSCREEN")) 	||
	 	  (0==strcmp(szBuf,"THRESHVOLUME")) 	||
 	          (0==strcmp(szBuf,"MINVOLUME")) 	||
	 	  (0==strcmp(szBuf,"XMITDELAY")) 	||
	 	  (0==strcmp(szBuf,"PACKETINTERVAL")) 	||
	 	  (0==strcmp(szBuf,"SAMPLERATE")) 	||
	 	  (0==strcmp(szBuf,"ENABLEONCONNECT")) 	||
	 	  (0==strcmp(szBuf,"XMITONCONNECT")) 	||
  	 	  (0==strcmp(szBuf,"XMITONPLAY")) 	||
  	 	  (0==strcmp(szBuf,"TCPBATCHXMIT")) 	||
	 	  (0==strcmp(szBuf,"SENDPRI")) 		||
	 	  (0==strcmp(szBuf,"RECEIVEPRI")) 	||
	 	  (0==strcmp(szBuf,"HOLDTOTRANSMIT")) 	||
	 	  (0==strcmp(szBuf,"COMPRESS")) 	||
	 	  (0==strcmp(szBuf,"MAXBANDWIDTH")) 	||
	 	  (0==strcmp(szBuf,"CONNECT")) 		||
	 	  (0==strcmp(szBuf,"SAMPLETECHNIQUE")) 	||
	 	  (0==strcmp(szBuf,"MAXSAMPLERATE")) 	||
	 	  (0==strcmp(szBuf,"INPUTCHANNEL")) 	||
	 	  (0==strcmp(szBuf,"SAMPLER")) 		||
	 	  (0==strcmp(szBuf,"VOICEMAILDIR")) 	||
	 	  (0==strcmp(szBuf,"INPUTSOURCE"))      ||
	 	  (0==strcmp(szBuf,"AMPLIFY"))          ||
	 	  (0==strcmp(szBuf,"PUBSCREEN"))	||
	 	  (0==strcmp(szBuf,"PUBLICSCREEN"))     ||
	 	  (0==strcmp(szBuf,"CUSTSTARTBITS"))    ||
		  (0==strcmp(szBuf,"CUSTDIRBITS")) 	||
		  (0==strcmp(szBuf,"CUSTLEFTBITS"))	||
		  (0==strcmp(szBuf,"CUSTRIGHTBITS"))	||
		  (0==strcmp(szBuf,"CUSTEXTBITS"))	||
		  (0==strcmp(szBuf,"CUSTSTOPBITS"))	||
		  (0==strcmp(szBuf,"MAXXMITDELAY"))	||
		  (0==strcmp(szBuf,"MICGAIN"))		||
		  (0==strcmp(szBuf,"LINEGAIN"))		||
		  (0==strcmp(szBuf,"IDLERATE"))		||
		  (0==strncmp(szBuf,"PHONEBOOK",9))	||
		  (0==strcmp(szBuf,"CUSTSAMPLEADDRESS"))||
		  (0==strcmp(szBuf,"MAXVOLBYTECOUNT"))  ||
		  (0==strcmp(szBuf,"HACKAMPVOL"))  	||
		  (0==strcmp(szBuf,"DEBUG"))  		||
		  (0==strcmp(szBuf,"FONT"))  		||
		  (0==strcmp(szBuf,"FONTSIZE"))  	||
		  (0==strcmp(szBuf,"PRESEND"))  	||
		  (0==strcmp(szBuf,"POSTSEND"))  	||
		  (0==strcmp(szBuf,"CUSTMICBITS")));

	return(BReturn);
}

BOOL GetPhoneArg(char * szArg, int * nParam, char **szParam)
{
	/* szPhoneFileName is set if we want to force-load another icon file */
	if ((BStartedFromWB == TRUE)||(szPhoneFileName != NULL))
		return(GetToolTypeArg(szArg,nParam,szParam));
	else
		return(GetCLIArg(szArg,nParam,szParam));
}

/* Searches command line arguments for an argument of the form
   ARG, ARG=PARAM, or arguments of the form ARG PARAM
   
   That is, if ARG is found, the next argument will be returned
   as PARAM */
BOOL GetCLIArg(char *szArg, int *nParam, char **szParam)
{
	int i;
	char *pcTemp;
	char szTemp[50];
		
	/* argc, argv must be defined globally! */
	for (i=1;i<argc;i++)
	{
		Strncpy(szTemp,argv[i],sizeof(szTemp));
		UpperCase(szTemp);
		
		pcTemp = strchr(szTemp,'=');
		if (pcTemp != NULL) *pcTemp = '\0';
		
		if (strcmp(szTemp,szArg) == 0)
		{
			/* Found our argument! */
			
			/* Form is ARG=PARAM */
			if (pcTemp != NULL)
			{
				*szParam = strchr(argv[i], '=') + 1;
				*nParam  = atoi(pcTemp+1);
			}
			else
			{
				if (argv[i+1] == NULL)
				{
					*szParam = "";
					*nParam = 0;
				}
				else
				{
					*szParam = argv[i+1];
					*nParam = atoi(argv[i+1]);
				}
			}
			return(TRUE);
		}
	}
	return(FALSE);
}


BOOL SetupToolTypeArg(char * szExecName)
{
	struct WBArg *wb_arg = ((struct WBStartup *) argv)->sm_ArgList;

	/* szExecName is an override for the icon file name */
	if (szExecName)	AmiPhoneIconDiskObject = GetDiskObject((UBYTE *)szExecName);
		   else AmiPhoneIconDiskObject = GetDiskObject((UBYTE *)wb_arg->wa_Name);
		 	   
	return(AmiPhoneIconDiskObject != NULL);
}



/* You must call SetupToolTypeArg before calling this function! */
BOOL GetToolTypeArg(char *szArg, int *nParam, char **szParam)
{
	static char sToolParam[200];
	char **toolarray = (char **) AmiPhoneIconDiskObject->do_ToolTypes;
	char *sTemp;

	/* Clear default string */
	sToolParam[0] = '\0';
	*szParam = sToolParam;	/* Return pointer to it */
			
	if ((toolarray != NULL) &&
	    ((sTemp = (char *) FindToolType(toolarray,szArg)) != NULL))
	{
		*nParam = atoi(sTemp);
		Strncpy(sToolParam,sTemp,sizeof(sToolParam));
		return(TRUE);
	}		 			
 	return(FALSE);
}


void ConnectionEstablished(UBYTE ubType,int nPort, ULONG ulKBytesToRecord)
{
	char * szMessage;
	char szText[200];	
	int ulMaxSeconds;
	
	BNetConnect = TRUE;
	
	switch(ubType)
	{
		case PCREPLY_WILLLISTEN: 	szMessage = "Peer is listening";       	break;
		case PCREPLY_TWOWAY:	 	szMessage = "Connection established";  	break;
		case PCREPLY_LEAVEMESSAGE:	szMessage = "Voice Mail"; 		break;
		case PCREPLY_CANTLEAVEMESSAGE:  szMessage = "No Voice Mail";		break;
		default:		 	szMessage = "Error, bad connect code"; 	break;
	}
	SetWindowTitle(szMessage);

	if (ubType == PCREPLY_CANTLEAVEMESSAGE)
	{
		MakeReq(NULL,"Your party is not available, and their voice mail box is either full or disabled.",NULL);
		ConnectionClosed(szMessage);
		return;
	}
	
	ChangeConnectPort(nPort);

	if (ubType == PCREPLY_LEAVEMESSAGE)
	{
		ulMaxSeconds = ulKBytesToRecord / (ulBytesPerSecond/1024);
		if (ubCurrComp == COMPRESS_ADPCM2) ulMaxSeconds *= 4;
		if (ubCurrComp == COMPRESS_ADPCM3) ulMaxSeconds *= (8/3);
		
		sprintf(szText,"Your party at %s is not available right now.\nWould you like to leave a message?\n(Max message length with current settings is %i seconds)",
			szPeerName, ulMaxSeconds);
		if (MakeReq(NULL,szText,"Leave Message|Cancel") == 1)
		{
			SetWindowTitle("Leave a message now.");
		}
		else
		{
			ClosePhoneSocket();
			SetMenuValues();
			SetWindowTitle("No message left.");
			return;
		}
	}
			
	SetMenuValues();
	if ((BEnableOnConnect == TRUE)&&(nToggleMode == TOGGLE_TOGGLE)) ToggleMicButton(CODE_ON);
}


void ConnectionClosed(char * szReason)
{
	BNetConnect = FALSE;	/* keep us from sending a disconnect packet when the connection is already closed */
	ClosePhoneSocket();
	SetWindowTitle(szReason);
}


void ProcessReply(void)
{	
	struct AmiPhoneSendBuffer * packet;
	
	if (SocketBase == NULL) return;
	errno = 0;	/* errno at a known state--hope there is no asynchronous bs going on here! */
	UNLESS(packet = GetTCPPacket(sTCPSocket)) 
	{
		if ((errno > 0)&&(errno != EWOULDBLOCK))
		{
			char szError[50];			
			sprintf(szError,"Receive Error %i", errno);
			ConnectionClosed(szError);
		}
		return;
	}	
	switch(packet->header.ubCommand)
	{
		case PHONECOMMAND_REPLY:	ConnectionEstablished(packet->header.ubType,packet->header.ulBPS,packet->header.ulJoinCode);  break;
		case PHONECOMMAND_DENY:  	ConnectionClosed("Connection denied.");			 break;
		case PHONECOMMAND_DISCONNECT:	ConnectionClosed("Connection closed.");			 break;
		case PHONECOMMAND_VWARN:	CheckVersions("AmiPhoned server", packet->header.ulBPS, TRUE); break;
		default: printf("ProcessReply: bad command [%c %i]\n",packet->header.ubCommand, packet->header.ubCommand);
	}
}


void SetTimer(struct timerequest * tio, int nSecs, int nMicros)
{
 	/* First make sure there is no previous timer pending */
        if (!(CheckIO((struct IORequest *) tio)))
        {
            AbortIO((struct IORequest *) tio);
            WaitIO((struct IORequest *) tio);
        }
               
        tio->tr_time.tv_secs  = nSecs;                                        
        tio->tr_time.tv_micro = nMicros;
        
        /* Start ze timer */
        SendIO((struct IORequest *)tio);
}


void SetupGraphicsInfo(struct AmiPhoneGraphicsInfo * inf)
{
	inf->GraphMessage.mn_Node.ln_Type 	= NT_MESSAGE;
	inf->GraphMessage.mn_Length 		= sizeof(struct AmiPhoneGraphicsInfo);
	inf->GraphMessage.mn_ReplyPort    	= NULL;
	
	inf->ubCommand		= MSG_CONTROL_HI | MSG_CONTROL_DOANIM;
	inf->nImageTop		= IMAGE_NOCONN;
	inf->ubCurrLocalComp	= COMPRESS_NONE;
	inf->ubCurrRemoteComp	= COMPRESS_NONE;
	inf->nBarHeightR	= 0;
	inf->nBarHeightS	= 0;
	inf->BErrorR		= FALSE;
	inf->BErrorS		= FALSE;
}

BOOL SafePutToPort(struct Message * message, char * portname)
{
        struct MsgPort * dport;

        Forbid();
        dport = FindPort(portname);
        if (dport) PutMsg(dport, message);
        Permit();
	
        return(dport ? TRUE : FALSE);
}

void CreateGraphicsDaemon(struct AmiPhoneGraphicsInfo * ginfo)
{	
	if (ginfo != NULL)
	{
		SetupGraphicsInfo(ginfo);
		UNLESS (GraphicDaemonProcess = CreateNewProcTags(
			NP_Entry, 	GraphicsTaskMain, 
			NP_Name,  	"AmiPhone Graphics Update",
			NP_Priority,	-6, 
			TAG_END)) 
		  EXIT("Couldn't create graphics daemon",RETURN_ERROR)
	}
}	




/* This is where the Graphics Daemon starts executing at! */
__geta4 void GraphicsTaskMain(void)
{
	/* Global data to be used by the graphics daemon ONLY */
	struct GfxBase * GfxBase = NULL;
	struct Library * IntBase = NULL;
	ULONG ulDMask, signals;
	UBYTE ubCommands;
	int nDot=0;
	int i, nVolHeight, nHeight;
	struct RastPort myRast;
	
	/* Record that we are running */
	BGraphicsDaemon = TRUE;
	
	/* Make our own, local copy of the RastPort */
	memcpy(&myRast,PhoneWindow->RPort, sizeof(myRast));
		
	UNLESS ((GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",37)) &&
	        (IntBase = (struct GfxBase *)OpenLibrary("intuition.library",37))) 
	{
		BGraphicsDaemon     = FALSE;
		GraphInfo.ubCommand = MSG_CONTROL_IMLEAVING; 
		return;
	}

	ulDMask = SIGBREAKF_CTRL_F | SIGBREAKF_CTRL_C;

	/* The event loop */
	while(1)
	{
		signals = Wait(ulDMask);
				
		if (signals & SIGBREAKF_CTRL_C) break;
		if (signals & SIGBREAKF_CTRL_F)
		{	
			/* CRITICAL SECTION */
			Forbid();
			ubCommands = GraphInfo.ubCommand;
			GraphInfo.ubCommand = 0;
			Permit();
			/* END CRITICAL SECTION */

			if (ubCommands & MSG_CONTROL_HI)
			{
				/* um, nothing to do really for now */
			}

			if ((ubCommands & MSG_CONTROL_DOTITLE)&&(PhoneWindow))
				SetWindowTitles(PhoneWindow, szWinTitle, (char *) ~0);
		
			if (ubCommands & MSG_CONTROL_BYE) break;
		
			if ((BZoomed == FALSE)&&(ubCommands & MSG_CONTROL_DOGRAPH))
			{
				if (BNetConnect)
				{
					/* Update graph */
					ScrollRaster(&myRast, 1, 0, nRecGraphLeft, nRecGraphTop, nRecGraphRight, nRecGraphBottom);
					
					SetAPen(&myRast,(GraphInfo.BErrorR ? COLOR_RECEIVE_ERROR : COLOR_RECEIVE));
					GraphInfo.BErrorR = FALSE;
					Move(&myRast,nRecGraphRight,nRecGraphBottom);
					nHeight = nRecGraphBottom-GraphInfo.nBarHeightR;
					if ((nHeight < nRecGraphTop)||(nHeight > nRecGraphBottom)) nHeight = nRecGraphTop;
					if (GraphInfo.nBarHeightR > 0) Draw(&myRast,nRecGraphRight,nHeight);
					SetAPen(&myRast,(GraphInfo.BErrorS ? COLOR_SEND_ERROR : COLOR_SEND));
					GraphInfo.BErrorS = FALSE;
					nHeight = nRecGraphBottom-GraphInfo.nBarHeightS;
					if ((nHeight < nRecGraphTop)||(nHeight > nRecGraphBottom)) nHeight = nRecGraphTop;
					if (GraphInfo.nBarHeightS > 0) Draw(&myRast, nRecGraphRight, nHeight);
	
					/* draw standards lines */
					SetAPen(&myRast, 1);	
					i=0;		
					while (nDot==0)
					{
						i += HEIGHT144;
						if (i > MAXHEIGHT) break;
						WritePixel(&myRast,nRecGraphRight,nRecGraphBottom-i);
					}
					nDot = (nDot+1)%DOTSPACING;
				}
			}
									
			if ((BZoomed == FALSE)&&(ubCommands & MSG_CONTROL_DOANIM))
			{
				/* Draw the microphone image */
				BltBitMapRastPort(&MicBitMap, 0, (GraphInfo.nImageTop)*MIC_HEIGHT,
					&myRast, MIC_LEFT, nMicTop, MIC_WIDTH, MIC_HEIGHT, 0xC0);		
				
				/* Draw the volume indicator */
				nVolHeight = ChopValue((CalcVolumePercentage(ulLastVolume)*MAXHEIGHT)/100, 0, MAXHEIGHT-1);
				SetAPen(&myRast, 0);
				RectFill(&myRast, VOLBARLEFT, VOLBARTOP, VOLBARRIGHT, nVolBarBottom-nVolHeight);
				SetAPen(&myRast, 7);
				if (nVolHeight > 0) RectFill(&myRast, VOLBARLEFT, nVolBarBottom-nVolHeight, VOLBARRIGHT, nVolBarBottom);
				SetAPen(&myRast, 1);
				Move(&myRast, VOLBARLEFT,  nVolBarBottom-(nMinSampleVol * MAXHEIGHT / 99));
				Draw(&myRast, VOLBARRIGHT, nVolBarBottom-(nMinSampleVol * MAXHEIGHT / 99));
			}
		}
	}
	if (IntBase) CloseLibrary(IntBase);
	if (GfxBase) CloseLibrary((struct Library *)GfxBase);
	BGraphicsDaemon = FALSE;
	GraphInfo.ubCommand = MSG_CONTROL_IMLEAVING;
	return;
}


void DrawWindowBoxes(void)
{
	DrawHitBox(nRecGraphLeft-1, nRecGraphTop-1, nRecGraphRight+1, nRecGraphBottom+1, 0, TRUE);
	DrawHitBox(VOLBARLEFT-1, VOLBARTOP-1, VOLBARRIGHT+1, nVolBarBottom+1, 0, TRUE);
}


/* Handles requests to output sound via the asynchronous sound player! */
static void HandleSoundPort(BOOL BAllowNewPlayers)
{
	struct PlayerMessage * PMessage;
	
	/* Reply the message */
	while(PMessage = (struct PlayerMessage *)GetMsg(SoundTaskPort))
	{
		switch(PMessage->ubControl)
		{
			case MESSAGE_CONTROLMAIN_REQCLOSED:
				FileReqTask = NULL;
				break;

			case MESSAGE_CONTROLMAIN_STOPPLAYING:
				if (BAllowNewPlayers) StopSoundPlayer(FALSE);
				break;

			case MESSAGE_CONTROLMAIN_PLAYFILE:
				/* Should only be called from the FileReq and Message Browser processes! */
				if (BAllowNewPlayers) StartSoundPlayer((char *) PMessage->data);
				break;

			case MESSAGE_CONTROLMAIN_IMLEAVING:
				SoundPlayerTask = NULL;
				if (BWasSamplingBefore == TRUE) 
				{
					BWasSamplingBefore = FALSE;
					ToggleMicButton(CODE_ON);
				}
				else DrawMicButton(-1);
				if (BXmitOnPlay) SendCommandPacket(PHONECOMMAND_FLUSH,0,0L);
				break;
					
			case MESSAGE_CONTROLMAIN_XMITPACKET:
				if ((BNetConnect)&&(BXmitOnPlay)&&(BAllowNewPlayers))
					SendPacket((struct AmiPhoneSendBuffer *)PMessage->data, BTCPBatchXmit);
				break;
				
			case MESSAGE_CONTROLMAIN_BROWSEROPEN:
				BBrowserIsRunning = TRUE;
				break;
				
			case MESSAGE_CONTROLMAIN_BROWSERCLOSED:
				BBrowserIsRunning = FALSE;
				break;

			default:
				printf("HandleSoundPort:  Bad PlayerMessage type [%i]\n",PMessage->ubControl);
				break;
		}
		ReplyMsg((struct Message *)PMessage);
	}
}
		

/* Intelligently adds/removes PhonePort */
void AddPhonePort(BOOL BAdd)
{
	static BOOL BAdded = FALSE;
	
	if (BAdd == BAdded) return;
	
	if (BAdd == TRUE) AddPort(PhonePort);
		     else RemPort(PhonePort);

	BAdded = BAdd;
	return;
}

int MakeReq(char *sTitle, char *sText, char *sGadgets)
{
	struct EasyStruct myreq;
	LONG number = 0L;
	int nResult;

	UNLESS(sTitle)   sTitle   = "AmiPhone Message";
	UNLESS(sText)    sText    = "Hey, something's up!";
	UNLESS(sGadgets) sGadgets = "OK";

	myreq.es_TextFormat   = sText;
	myreq.es_Title        = sTitle;
	myreq.es_GadgetFormat = sGadgets;

	nResult = EasyRequest(NULL, &myreq, NULL, NULL, number);

	return(nResult);
}





static BOOL AllocAHI(BOOL BAlloc)
{
  ULONG id=0;
  
  if (BAlloc)
  {  
  	UNLESS
  	 ((AHImp = CreateMsgPort()) && 
  	  (AHIio = (struct AHIRequest *)CreateIORequest(AHImp,sizeof(struct AHIRequest))) &&
  	  (AHIio->ahir_Version = 1) &&
  	  ((AHIDevice = OpenDevice(AHINAME,AHI_NO_UNIT,(struct IORequest *)AHIio,0L)) == 0))
  	{
  		/* Oops, something went awry--clean up and fail! */
  		AllocAHI(FALSE);
  		return(FALSE);
  	}
	AHIBase=(struct Library *)AHIio->ahir_Std.io_Device;
  }
  else
  {	
  	if (!AHIDevice) CloseDevice((struct IORequest *)AHIio); AHIDevice = -1;
  	if (AHIio) DeleteIORequest((struct IORequest *) AHIio); AHIio = NULL;
  	if (AHImp) DeleteMsgPort(AHImp); AHImp = NULL;
  	AHIBase = NULL;
  }
  return(TRUE);
}




static void HandleAppWindow(void)
{	
	BOOL BSoundPlayed = FALSE;
	struct AppMessage * amsg;
	struct WBArg *argptr = NULL;
	char szFilePath[500];
	
	UNLESS(AppWindowPort) return;
	
	while (amsg = (struct AppMessage *) GetMsg(AppWindowPort))
	{
		/* Only start one sound at a time.  Ignore the other messages */
		UNLESS(BSoundPlayed)
		{	
			/* process messages--only 1st file, no point in dropping more than one at a time! */
			if (amsg->am_NumArgs > 0L)
			{
				if (NameFromLock(amsg->am_ArgList[0].wa_Lock, szFilePath, sizeof(szFilePath)))
				{
					AddPart(szFilePath, amsg->am_ArgList[0].wa_Name, sizeof(szFilePath));	
					StopSoundPlayer(FALSE);
					StartSoundPlayer(szFilePath);
					BSoundPlayed = TRUE;
				}
			}
		}
		/* done with message, release it */
		ReplyMsg((struct Message *)amsg);
	}
}


/* Returns info about the Slider's dimensions in the current screen's font */
static void GetSliderInfo(int * pnLabelWidth, int * pnValueWidth, int * pnHeight)
{
	int nMaxLabelWidth = 0, nMaxValueWidth = 0, nTemp;
	struct RastPort * rp = &Scr->RastPort;
	struct RastPort dummyrastport;
	struct TextExtent te;

	if (fontdata)
	{
		InitRastPort(&dummyrastport);
		SetFont(&dummyrastport, fontdata);	
		rp = &dummyrastport;
	}
	
	/* Get font height */
	if (pnHeight)
	{	
		TextExtent(rp, szSliderLabel1, sizeof(szSliderLabel1), &te);
		*pnHeight = te.te_Height;
	}

	/* Get width of widest slider label */
	if (pnLabelWidth)
	{
		if ((nTemp = TextLength(rp, szSliderLabel1, sizeof(szSliderLabel1))) > nMaxLabelWidth) nMaxLabelWidth = nTemp;
		if ((nTemp = TextLength(rp, szSliderLabel2, sizeof(szSliderLabel2))) > nMaxLabelWidth) nMaxLabelWidth = nTemp;
		if ((nTemp = TextLength(rp, szSliderLabel3, sizeof(szSliderLabel3))) > nMaxLabelWidth) nMaxLabelWidth = nTemp;
		UNLESS(BPropFont) nMaxLabelWidth = nMaxLabelWidth * 10 / 9;
		*pnLabelWidth = nMaxLabelWidth;
	}
	/* Get width of widest possible slider value */
	if (pnValueWidth)
	{
		if ((nTemp = TextLength(rp, szSliderValue1, sizeof(szSliderValue1))) > nMaxValueWidth) nMaxValueWidth = nTemp;
		if ((nTemp = TextLength(rp, szSliderValue2, sizeof(szSliderValue2))) > nMaxValueWidth) nMaxValueWidth = nTemp;
		if ((nTemp = TextLength(rp, szSliderValue3, sizeof(szSliderValue3))) > nMaxValueWidth) nMaxValueWidth = nTemp;
		UNLESS(BPropFont) nMaxValueWidth = nMaxValueWidth * 10 / 9;
		*pnValueWidth = nMaxValueWidth;
	}
}


static int CalcWindowHeight(int nFontHeight)
{
	int nHeight = ((Scr->Font->ta_YSize + VSPACE) + (nFontHeight+VSPACE)*3 + VSPACE);
	return ((nHeight < WINDOWHEIGHT) ? WINDOWHEIGHT : nHeight);
}

static int CalcWindowWidth(int nLabelWidth, int nValueWidth)
{
	return ((MIC_LEFT+MIC_WIDTH+HSPACE+(VOLBARRIGHT-VOLBARLEFT)+HSPACE+SLIDER_WIDTH+nLabelWidth+nValueWidth)*6/5);
}


/* main program code */
int main(int largc, char *largv[])
{
	char * szErrorLib;
	char szErrorMessage[100];
	int nSamp=0, nTemp1, nTemp2, nTemp3, nWidth, nHeight;
	ULONG signal;
	ULONG PhoneWinSigMask;
	struct Message * DMessage;
	UWORD wZoomCoords[4];

	/* Put this to a known state of non-allocation! */
	DelfinaBase = NULL;
		
	if ((BStartedFromWB == FALSE)&&(largc == 2)&&(*largv[1] == '?'))
	{
		printf("Template:  AmiPhone PEERNAME/A,TOP/K/N,LEFT/K/N,PUBSCREEN/K,COMPRESS/K,CONNECT/K,THRESHVOLUME/K/N,SAMPLERATE/K/N,XMITDELAY/K/N,MAXBANDWIDTH/K/N,SAMPLETECHNIQUE/K,MAXXMITDELAY/K/N,MAXSAMPLERATE/K/N,SAMPLER/K,VOICEMAILDIR/K,AMPLIFY/K/N,INPUTSOURCE/K,PHONEBOOKx/K,MICGAIN/K/N,IDLERATE/K/N,ENABLEONCONNECT/S,XMITONPLAY/S,HOLDTOTRANSMIT/S,TCPBATCHXMIT/S,INVERTWAVEFORM/S\n");
		exit(0);
	}	
	
	atexit(CleanExit);
	
	/* make startup args global! */
	argc = largc;
	argv = largv;
	
	/* initialize the dummy message */
	defMsg.ubControl		= MSG_CONTROL_INVALID;	
	defMsg.ulLastPacketSize		= 0L;	
	defMsg.daemonTask		= NULL;
	defMsg.BWindowIsOpen		= FALSE;
		
	if (szErrorLib = OpenLibraries(TRUE))
	{
		if (strcmp(szErrorLib,"bsdsocket"))
			sprintf(szErrorMessage,"Couldn't open %s.library", szErrorLib);
		   else sprintf(szErrorMessage,"AmiTCP isn't running!");
		EXIT(szErrorMessage,RETURN_ERROR);
	}
	
	UNLESS(MiscBase = (struct Library *)OpenResource(MISCNAME)) EXIT("Couldn't open misc.resource",RETURN_ERROR)
	UNLESS(SetupPreSendQueue(TRUE))	EXIT("Couldn't setup presend queue", RETURN_ERROR)
	UNLESS(SetupTCPQueue(0,TRUE)) EXIT("Couldn't setup TCP queue", RETURN_ERROR)
	
	/* This reads in all args from command line or tooltypes, and sets global vars */
	ParseArgs(Not[BStartedFromWB]);
	
	/* Now that we've got all of the args, we can calc & set sample speed */
	ChangeSampleSpeed(ulBytesPerSecond,ubCurrComp);
	
	/* Set up our message ports */
	UNLESS (PhonePort = CreateMsgPort()) EXIT("Couldn't create graphics message port",RETURN_ERROR)
	UNLESS (SoundTaskPort = CreateMsgPort()) EXIT("Couldn't create soundtask message port",RETURN_ERROR)

	/* Set up the timer device ports */
	UNLESS (GraphicTimerMP = CreatePort(0,0)) EXIT("Couldn't create graphics timer message port",RETURN_ERROR)
	UNLESS (GraphicTimerIO = (struct timerequest *) CreateExtIO(GraphicTimerMP, (sizeof (struct timerequest))))
	        EXIT("Couldn't create graphics timer IO request",RETURN_ERROR);

	/* Allow access to timer device's library functions */
	TimerBase = (struct Library *) GraphicTimerIO->tr_node.io_Device;

	/* Open the timer.device with UNIT_WAITUNTIL for graphics updates */
	if (OpenDevice(TIMERNAME,UNIT_VBLANK,(struct IORequest *)GraphicTimerIO,0))
	        EXIT("Couldn't open timer.device",RETURN_ERROR);

	GraphicTimerIO->tr_node.io_Message.mn_ReplyPort = GraphicTimerMP;
	GraphicTimerIO->tr_node.io_Command = TR_ADDREQUEST;
	GraphicTimerIO->tr_node.io_Flags = 0;
	GraphicTimerIO->tr_node.io_Error = 0;
	GraphicTimerIO->tr_time.tv_secs  = 0;
	GraphicTimerIO->tr_time.tv_micro = 0; 

	UNLESS(AllocSignals(TRUE)) EXIT("Couldn't allocate signals!",RETURN_ERROR)
	UNLESS(Scr = LockPubScreen((strlen(szPubScreenName)>0) ? szPubScreenName : NULL)) 
	{
		printf("Couldn't open public screen, falling back to default public screen.\n");
		UNLESS (Scr = LockPubScreen(NULL)) EXIT("Couldn't lock the default public screen!",RETURN_ERROR);
	}
	
	/* Default = center window */
	if (windowtop  == -1) windowtop  = (Scr->Height>>1)-(WINDOWHEIGHT>>1);
	if (windowleft == -1) windowleft = (Scr->Width>>1)-(WINDOWWIDTH>>1);

	UNLESS(AllocSliders(TRUE)) EXIT("No slider gadgets",RETURN_ERROR)

	/* Open xmit window */
	sprintf(szErrorMessage,"AmiPhone v%i.%i", VERSION_NUMBER/100,VERSION_NUMBER%100);
	
	GetSliderInfo(&nTemp1, &nTemp2, &nTemp3);
	nHeight = CalcWindowHeight(nTemp3);
	nWidth  = CalcWindowWidth(nTemp1, nTemp2);
		
	if ((nWidth > Scr->Width)||(nHeight >Scr->Height)) EXIT("Couldn't create GUI, font too big for screen",RETURN_FAIL);

	/* specify what we look like when zoomed */
	wZoomCoords[0] = windowleft;
	wZoomCoords[1] = windowtop;
	wZoomCoords[2] = nWidth;
	wZoomCoords[3] = Scr->Font->ta_YSize+3;
	
        UNLESS(PhoneWindow = OpenWindowTags( NULL,
		WA_Left,        windowleft,
        	WA_Top,         windowtop,
		    WA_Width,       nWidth,
	        WA_Height,      nHeight,
	        WA_PubScreen,   Scr,
	        WA_PubScreenFallBack, TRUE,
	        WA_IDCMP,       IDCMP_MENUPICK|IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW|
	        		  		IDCMP_MOUSEBUTTONS|SLIDERIDCMP|IDCMP_VANILLAKEY|IDCMP_NEWSIZE,
	        WA_Flags,       WFLG_SIZEBBOTTOM|WFLG_SMART_REFRESH|WFLG_ACTIVATE|
	        		 		/*WFLG_NEWLOOKMENUS|*/WFLG_CLOSEGADGET|WFLG_DRAGBAR|
	        				WFLG_DEPTHGADGET,
	        WA_Gadgets,	glist,
		WA_Zoom,	wZoomCoords,
		WA_Title,       szErrorMessage,
	       	WA_ScreenTitle, szProgramName,
	       	WA_DepthGadget, TRUE,
	       	WA_CloseGadget, TRUE,
	       	WA_SizeGadget,  FALSE,
	       	WA_DragBar,	TRUE,
	       	WA_AutoAdjust,  TRUE,
	       	WA_Activate,    TRUE,
		TAG_DONE ))
		EXIT("Couldn't open AmiPhone window!",RETURN_ERROR)

	/* Partition out the rest of the space for the graph */
	nRecGraphTop    = WID_TOP+1;
	nVolBarBottom   = nRecGraphBottom = PhoneWindow->Height - Scr->WBorBottom-(VSPACE*2);
	nMicTop		= nRecGraphTop + ((nRecGraphBottom-nRecGraphTop)/2) - (MIC_HEIGHT/2);
	nRecGraphRight  = PhoneWindow->Width - Scr->WBorRight-(HSPACE*2);
	nRecGraphLeft   = nTemp1+nTemp2+SLIDER_WIDTH+MIC_LEFT+MIC_WIDTH+(VOLBARRIGHT-VOLBARLEFT)+(HSPACE*4);

	GT_RefreshWindow(PhoneWindow, NULL);
	UNLESS(CreatePhoneMenus(TRUE)) EXIT("Couldn't Create Menus!",RETURN_ERROR)

	InitMicButton();	
	SetMenuValues();

	/* Draw receive graph outline */
	DrawWindowBoxes();	

	/* Setup the AppWindow stuff */
	if ((WorkbenchBase)&&(AppWindowPort = CreateMsgPort()))
	{
		UNLESS(AppWindow = AddAppWindowA(1, 0, PhoneWindow, AppWindowPort, NULL))
		{
			DeleteMsgPort(AppWindowPort);
			AppWindowPort = NULL;
		}
	}

	/* Setup the ARexx stuff */
	if (RexxSysBase) rexxHost = SetupARexxHost("AMIPHONE", NULL);

	PhoneWinSigMask = ((1L << PhoneWindow->UserPort->mp_SigBit) |
			   (1L<<sighalf)                            | 
			   (1L<<sigfull)                            | 
			   (SIGBREAKF_CTRL_C)                       |
			   (SIGBREAKF_CTRL_D)                       |
			   (SIGBREAKF_CTRL_F)                       |
			   (1L << GraphicTimerMP->mp_SigBit)        |  
			   (1L << PhonePort->mp_SigBit)             | 
			   (1L << SoundTaskPort->mp_SigBit)	    |
		   	   (AppWindowPort ? (1L<<AppWindowPort->mp_SigBit) : 0)  |
			   (rexxHost ? (1L<<rexxHost->port->mp_SigBit) : 0) 	 |
			   (DelfinaBase ? delfsig : 0));

	/* Fill out our message to the graphics daemon */
	CreateGraphicsDaemon(&GraphInfo);

	/* Get our address */
	MainTask = FindTask(NULL);
	
	/* Set our priority to the proper value */
	if (nSendPri < 128) nOldSendPri = SetTaskPri(MainTask, nSendPri);
	
	/* Start the graphics update timer going */
	GTIMERGO;	

	/* This will set the Window title if someone is using our stuff */
	AllocParallel(CHECK_STATUS,FALSE);

	/* Put an initial draw in, just so we don't get that 1/2 second lag... it looks dumb */
	ulLastVolume = SILENCE;
	DrawMicButton(-1);

	SetExitMessage("CTRL-C detected",RETURN_ERROR);

	if ((strlen(szPeerName) > 0)&&(SocketBase))
	{
		ConnectPhoneSocket(FALSE,szPeerName);
		DrawMicButton(-1);
	}

	/* Main loop */
	while (BProgramDone == FALSE) 
	{	
		signal = PhoneWait(PhoneWinSigMask);

		if (signal & (1<<sighalf)) TransmitData(pubAllocedArray, ALL_OF_BUFFER, ubCurrComp);  /* send left buffer */
		if (signal & (1<<sigfull)) TransmitData(pubRightBuffer,  ALL_OF_BUFFER, ubCurrComp);  /* send right buffer */ 

		if ((DelfinaBase)&&(signal & delfsig))
		{
			int nBytesAfterComp = ulSampleArraySize;
			
			if (ubCurrComp == COMPRESS_ADPCM2) nBytesAfterComp >>= 2;
			if (ubCurrComp == COMPRESS_ADPCM3) nBytesAfterComp = (nBytesAfterComp * 3)>>3;

			TransmitData(pubAllocedArray, nBytesAfterComp, ubCurrComp);
		}
				
		if ((signal & SIGBREAKF_CTRL_F)&&((ubSamplerType == SAMPLER_TOCCATA)||(ubSamplerType == SAMPLER_AHI)))
		{
			UBYTE * pubData;
			ULONG ulDataLen;
			
			/* Begin critical section type thing */
			Forbid(); Disable();
			
			/* Grab buffer info */
			pubData   = pubBulkSamplePacket;
			ulDataLen = ulSampleArraySize;
			IntData.ulByteSum = IntData.ulSaveByteSum = ulBulkSamplePacketSum;
			
			/* And don't let this buffer get sent again */
			pubBulkSamplePacket   = NULL;
			ulBulkSamplePacketSum = SILENCE;	/* silent */

			/* OK to continue multitasking now */
			Enable(); Permit();

			if (pubData) TransmitData(pubData, ulDataLen, ubCurrComp);
		}

		if (signal & SIGBREAKF_CTRL_D)
		{	
			ToggleMicButton(CODE_OFF);
			if (ubSamplerType == SAMPLER_TOCCATA) SetWindowTitle("Toccata sampling error?");
							 else printf("(Received CTRL_D)\n");
		}
		
		if (signal & (1L << SoundTaskPort->mp_SigBit)) 
		{
			HandleSoundPort(TRUE);
			SetMenuValues();
		}

		if (signal & (1L << PhonePort->mp_SigBit))
		{
			while (DMessage = GetMsg(PhonePort))
			{
				switch(((struct AmiPhoneInfo *) DMessage)->ubControl)
				{
					case MSG_CONTROL_HI:	daemonInfo = (struct AmiPhoneInfo *) DMessage;
								daemonInfo->nPri = nReceivePri;		/* tell AmiPhoned what pri we want it at */
								SetMenuValues();
								break;
									
					case MSG_CONTROL_BYE:	daemonInfo = &defMsg;	/* No more packets to listen to, go back to fake data */
								ClosePhoneSocket();     /* close off our end of the deal */
								AddPhonePort(FALSE);
								SetMenuValues();
								break;
								
					case MSG_CONTROL_RELEASE:  if (BTransmitting == TRUE) ToggleMicButton(CODE_OFF);
								   break;
					
					case MSG_CONTROL_UPDATE: SetMenuValues();
								 break;
								 
					default: 
						printf("Heard invalid message!!!\n");
						break;
				}
				ReplyMsg(DMessage);
			}
		}

		if (signal & SIGBREAKF_CTRL_C) BProgramDone = TRUE;

		if (signal & (1<<GraphicTimerMP->mp_SigBit)) 
		{
			if (nToggleMode == TOGGLE_HOLD)
			{
				if (BButtonHeld == FALSE) ToggleMicButton(CODE_OFF);
				if (BSpaceTapped == TRUE) BSpaceTapped = BButtonHeld = FALSE;
			}
			
			/* Blank the volume-o-meter if we're not transmitting */
			if (BTransmitting == FALSE) ulLastVolume = SILENCE;
			UpdateReceiveDisplays();
			GTIMERGO;			
		}

		if ((rexxHost)&&(signal & (1L << rexxHost->port->mp_SigBit)))
		{
			ARexxDispatch(rexxHost);
			SetMenuValues();
		}
		
		if ((AppWindowPort)&&(signal & (1L << AppWindowPort->mp_SigBit))) HandleAppWindow();
		if (signal & (1L << PhoneWindow->UserPort->mp_SigBit)) HandleIDCMP(NULL);
		
	}
	EXIT("OK",RETURN_OK);
}
