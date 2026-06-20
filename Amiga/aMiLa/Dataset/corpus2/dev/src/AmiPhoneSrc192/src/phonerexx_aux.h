
#include <time.h>
#include <stdio.h>

#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <intuition/gadgetclass.h>
#include <clib/intuition_protos.h>

#include "menuconstants.h"
#include "AmiPhone.h"
#include "phoneudp.h"
#include "ciatimer.h"
#include "browse.h"
#include "codec.h"
#include "AmiPhoneMsg.h"
#include "AmiPhonePacket.h"

extern char * pszCallIPs[];
extern BOOL BNetConnect;
extern FILE * fpMemo;
extern struct Task * FileReqTask;
extern UBYTE ubSamplerType;
extern UBYTE ubCurrComp, ubInputChannel, ubInputSource;
extern ULONG ulBytesPerSecond, ulBytesSentSince, ulRexxReceiveAve, ulRexxSendAve;
extern int nLineGainValue, nMinSampleVol, nToggleMode, nAmpShift;
extern struct IntInfo IntData;
extern BOOL BEnableOnConnect, BXmitOnPlay, BTCPBatchXmit, BTransmitting, BBrowserIsRunning, BZoomed;
extern char szVoiceMailDir[], szPeerName[], szLastMemoFile[200];
extern struct AmiPhoneInfo * daemonInfo;
extern struct Window * PhoneWindow;
extern float fPacketDelay;