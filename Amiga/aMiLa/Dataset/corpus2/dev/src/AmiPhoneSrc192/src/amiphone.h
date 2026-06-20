/* AmiPhone.h */

#ifndef AMIPHONE_H
#define AMIPHONE_H

#define ALL_OF_BUFFER -1
#define MAXPEERNAMELENGTH 100

#define CODE_ON		1
#define CODE_OFF	2
#define CODE_TOGGLE	3

/* different samplers - GENERIC should work for most, but... */
#define SAMPLER_GENERIC 0
#define SAMPLER_GVPDSS8 1
#define SAMPLER_PERFECT 2
#define SAMPLER_TOCCATA 3
#define SAMPLER_AMAS    4
#define SAMPLER_SOMAGIC 5
#define SAMPLER_AURA    6
#define SAMPLER_DELFINA 7
#define SAMPLER_CUSTOM  8
#define SAMPLER_AHI     9
#define SAMPLER_MAX    10	/* invalid!  Used for bounds checking, etc. */

/* Bit positions for the custom settings */
#define SAMPBIT_POUTCLR   (1<<0)
#define SAMPBIT_POUTSET   (1<<1)
#define SAMPBIT_SELCLR    (1<<2)
#define SAMPBIT_SELSET    (1<<3)
#define SAMPBIT_BUSYCLR   (1<<4)
#define SAMPBIT_BUSYSET   (1<<5)

/* Specify an input channel */
#define INPUT_JACK_LEFT  1
#define INPUT_JACK_RIGHT 2

/* Specify an input source */
#define INPUT_SOURCE_MIC 0
#define INPUT_SOURCE_EXT 1

/* different methods of selecting sampling */
#define TOGGLE_TOGGLE   0
#define TOGGLE_HOLD	1

/* different methods of sample timing */
#define TECHNIQUE_SOFTINT	1	
#define TECHNIQUE_HARDINT       2

/* macros */
#define UNLESS(x)    if(!(x))
#define UNTIL(x)  while(!(x))
#define EXIT(m,n) {SetExitMessage(m,n);exit(n);}

/* Function prototypes */
void SetExitMessage(char*,int);
void CleanExit(void);
void UserError(char * message);	
void SetWindowTitle(char *sString);
void SetMenuValues(void);
void UpperCase(char *sOldString);
void LowerCase(char *sOldString);
void DrawMicButton(int nOptImage);
void ToggleMicButton(int nCode);
void ChangeTransmitMode(int nNewMode);
void ProcessReply(void);
void ConnectionEstablished(UBYTE ubType, int nNewPort, ULONG ulKBytesAvail);
void ConnectionClosed(char * szMessage);
void DrawWidthButton(int nWhich, BOOL BPressed, BOOL BReceive);
void DrawHitBox(int nLeft, int nTop, int nRight, int nBottom, int nBackColor,  BOOL BPressed);
void DrawWidthButtons();
void SetTimer(struct timerequest * tio, int nSecs, int nMics);
void UpdateReceiveDisplays();
void ParseArgs(BOOL BStartedFromCLIButParseIconAnyway);
void SetupGraphicsInfo(struct AmiPhoneGraphicsInfo * inf);
void SubCleanExit(int nReturn);
void CreateGraphicsDaemon(struct AmiPhoneGraphicsInfo * ginfo);
void debug(int nSec);
void DrawWindowBoxes(void);
void SignalAllDaemons(void);
void AddPhonePort(BOOL BAdd);
void GetSamplerType(char * szWriteParam, UBYTE ubType);
void GetSamplerState(char * szWriteParam);
void GraphicUpdate(ULONG ulSignals);
void ChangeVolumeThreshold(int nNewPercentage);

__geta4 void GraphicsTaskMain(void);

/* Functions in the graphics subtask */
void SubCleanExit(int nReturn);

BOOL StartRecording(BOOL BStart, char * szOptFileName);
BOOL GetPhoneArg(char * szArg, int * nParam, char **szParam);
BOOL GetCLIArg(char *szArg, int *nParam, char **szParam);
BOOL SetupToolTypeArg(char *szOptFileName);
BOOL GetToolTypeArg(char *szArg, int *nParam, char **szParam);
BOOL IsKeyword(char * szWord);
BOOL CreatePhoneMenus(BOOL BCreate);
BOOL SafePutToPort(struct Message * message, char * portname);
BOOL CanAdjustLineGain(void);
BOOL CanAdjustMicGain(void);
BOOL CanAdjustInputChannel(void);
BOOL CanAdjustInputSource(void);
BOOL CanAmplify(void);
BOOL CanMeasureVolume(void);
BOOL UsesInvertedSamples(void);
BOOL UsesCIAInterrupt(void);
BOOL StartSoundPlayer(char * szFileName);
BOOL HandleIDCMP(struct IntuiMessage * fakeMessage);
BOOL FakeIDCMPMessage(ULONG class, ULONG code, ULONG qual);


UBYTE ParseCompMode(char * szString);
UBYTE ParseSamplerType(char * szParam);
UBYTE ParseInputChannel(char * szParam);

int main(int largc, char *largv[]);

LONG ChopValue(LONG ulVal, LONG ulLow, LONG ulHigh);

int MakeReq(char *sTitle, char *sText, char *sGadgets);

#endif
