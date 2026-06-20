#define DICE_C

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <exec/types.h>
#include <exec/io.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <devices/audio.h>
#include <libraries/dos.h>			/* contains RETURN_OK, RETURN_WARN #def's */
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <dos/var.h>
#include <dos/exall.h>
#include <graphics/gfxbase.h>		/* to determine if we are on a PAL or NTSC Amiga */
#include <intuition/intuition.h>
#include <libraries/gadtools.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/icon_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>

#include <errno.h>
#include <inetd.h>
#include <sys/types.h>

#include <proto/socket.h>
#include <sys/errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/syslog.h>
#include <netdb.h>

#include <pragmas/socket_pragmas.h>
#include <inetd.h>

#include "AmiPhoned.h"
#include "AmiPhoneMsg.h"
#include "AmiPhonePacket.h"
#include "codec.h"
#include "StringRequest.h"
#include "TCPQueue.h"

#define MIN_CHIP_MEMORY	 50000
#define CLIENT_TCP_QUEUE 10

#define OPTION_DENY		0
#define OPTION_TWOWAY		1
#define OPTION_LISTEN		2
#define OPTION_TAKEMESSAGE	3

#define P_LAUNCH	100
#define P_INCREMENT	101
#define P_DECREMENT	102
#define P_RECORD	103
#define P_FLUSHBUFFER   104
#define P_HIDEWINDOW    105
#define P_ABOUT 	106
#define P_QUIT		107

#define R_ADDRELAY	200
#define R_RELAY		250

#define EXTRA_WINDOW_WIDTH 65

#ifdef DEBUG_FLAG
FILE * fpDebug = NULL;
#define DEBUG(X)  {fprintf(fpDebug,X); fflush(fpDebug);}
#endif

#ifndef DEBUG_FLAG
#define DEBUG(X)  {};
#endif

/* Why does this come out as 18 unless I define it explicitely here?  Weird! */
#define EWOULDBLOCK 35

/* private functions */
static int UserReceiveOption(BOOL BCanTakeMessage, char * szMessage);

/* vars shared with codec.c */
char * szMessageDir = NULL;
ULONG ulByteTicker, ulMilliSecondsTaken = 0L;

/* Offset to first relay-add entry--MUST BE CHANGED WHENEVER MeNU ITEMS ARE ADDED! */
#define ADD_RELAY_BASE 9

/* menus */
struct NewMenu nmMenus[] = {
	NM_TITLE, "Project",         NULL,  0L,     	NULL, NULL,
	NM_ITEM,  "Start Client",     "S",  0L,		NULL, (void *) P_LAUNCH,
	NM_ITEM,  "Startup Delay",   NULL,  0L,		NULL, NULL,
	NM_SUB,   "Increase",	      "]",  0L,		NULL, (void *) P_INCREMENT,
	NM_SUB,   "Decrease",	      "[",  0L,		NULL, (void *) P_DECREMENT,
	NM_ITEM,  "Record",  	      "R",  CHECKIT,    NULL, (void *) P_RECORD,
	NM_ITEM,  "Flush Buffer",     "F",  0L,         NULL, (void *) P_FLUSHBUFFER,
	NM_ITEM,  "Hide",             "H",  0L,         NULL, (void *) P_HIDEWINDOW,
	NM_ITEM,  "About",            "?",  0L,     	NULL, (void *) P_ABOUT,
	NM_ITEM,  NM_BARLABEL,       NULL,  0L,     	NULL, NULL,
	NM_ITEM,  "Quit",             "Q",  0L,     	NULL, (void *) P_QUIT,
	NM_TITLE, "Relay",           NULL,  0L,    	NULL, NULL,
	NM_ITEM,  "--------------",   "1",  0L, 	NULL, (void *) (R_ADDRELAY),
	NM_ITEM,  "--------------",   "2",  0L, 	NULL, (void *) (R_ADDRELAY+1),
	NM_ITEM,  "--------------",   "3",  0L, 	NULL, (void *) (R_ADDRELAY+2),
	NM_ITEM,  "--------------",   "4",  0L, 	NULL, (void *) (R_ADDRELAY+3),
	NM_ITEM,  "--------------",   "5",  0L, 	NULL, (void *) (R_ADDRELAY+4),
	NM_ITEM,  "--------------",   "6",  0L, 	NULL, (void *) (R_ADDRELAY+5),
	NM_ITEM,  "--------------",   "7",  0L, 	NULL, (void *) (R_ADDRELAY+6),
	NM_ITEM,  "--------------",   "8",  0L, 	NULL, (void *) (R_ADDRELAY+7),
	NM_ITEM,  "--------------",   "9",  0L, 	NULL, (void *) (R_ADDRELAY+8),
	NM_ITEM,  "--------------",   "0",  0L, 	NULL, (void *) (R_ADDRELAY+9),
	NM_END,   NULL,		     NULL,  NULL,   	NULL, NULL
};

#define MAXRELAYNAMELEN 14

#define QMODE_EMPTY 0	/* Queue is filling--don't play packets yet */
#define QMODE_FLUSH 1	/* Queue is flushing--play packets until empty */

/* private vars for this module */
static char [] = VERSION_STRING;
static char * szRelayName[10] = {NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
static LONG   sRelayUDPSocket[10]= {-1  ,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1};
struct sockaddr_in saRelayTCPAddress[10];
struct sockaddr_in saRelayUDPAddress[10];

static USHORT port;
LONG   sRelayTCPSocket[10]= {-1  ,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1};
static LONG   sTCPSocket=-1,sUDPSocket=-1;
static UBYTE  *uQ=NULL;
static BOOL   BNoReq = FALSE, BLocalAmiPhoneNotified = FALSE, BNetConnect = FALSE, BRecordMessage = FALSE, BImARelay = FALSE, BSendWarningBack = FALSE;
static struct AmiPhoneInfo MyInfo;		/* shared mem for communicating with local AmiPhone */
static struct AmiPhoneSendBuffer recBuffer;	/* buffer to receive incoming data from remote AmiPhone */

static char szExitMessage[100] = "All Done";
static int  ngExitVal = RETURN_OK;
static int  nWindowWidth=0;

static int nRelayToAdd = 0, nQMode = QMODE_EMPTY;
static int nQLength = 0, nQLengthMS = 0, nPri = 0, nMaxVoiceMailDirSize = 2048, nMaxMessageSize = -1;
static char * szProgPath;
static LONG lPlayUpTo = -1L;
static ULONG ulLowIndex = 0L;		/* packets numbered lower than this var will not be added, or played */
static ULONG ulPhonedMask, ulSignalMessageFree = 0L;
static BDone = FALSE, BOpenWindow = FALSE, BAudioAvail=FALSE;
static BOOL BNoClient = TRUE;
static ULONG ulKeyCode = 0L;
static char szShortPeerName[20]="";
static char szAwayVar[35] = "";		/* name of ENV var to look for to decide if user is away or not */
static FILE * fpOut = NULL;		/* save output to... */

static struct sockaddr_in saTCPSocket;	/* this is the socket we send/receive commands over */
static struct sockaddr_in saUDPSocket;	/* this is the socket we set up and receive data on */
static struct List * PacketList;
static struct Window * AmiPhonedWindow = NULL;
static struct Screen * AmiPhonedScreen = NULL;
static struct Menu * Menu = NULL;

static char targethost[100]="";

static time_t tTimeConnected;

/* user prefs */
int windowtop = -1, windowleft = -1;	/* default: top, centered. */

/* global variables for audio output */
struct IOAudio	*AIOptr1=NULL, *AIOptr2=NULL;
struct MsgPort	*port1=NULL, *port2=NULL;

/* The number of milliseconds of audio that must be in the queue before 
   AmiPhoned will start playing them.  Raise this to prevent skipping, 
   lower it to reduce the sample-til-play delay */
int nMinReserve = 800;

struct GfxBase	*GfxBase = NULL;

BYTE 	bStatus[2] = {STATUS_INVALID, STATUS_INVALID};		/* status of each audio buffer */
#define AUDIO_EMPTY	((bStatus[0]==STATUS_INVALID)&&(bStatus[1]==STATUS_INVALID))
#define AUDIO_HALF	(bStatus[0]!=bStatus[1])
#define AUDIO_FULL	((bStatus[0]==STATUS_PLAYING)&&(bStatus[1]==STATUS_PLAYING))

/* These WERE main()'s locals in AUDIO */
ULONG  SystemClock;	/* PAL/NTSC clock constant */
ULONG  length[2];	/* sample lengths */
ULONG  speed;		/* playback rate */
BYTE   *psample[2];	/* pointers to samples */

/* global vars */
struct Library * IntuitionBase = NULL;
struct Library * SocketBase    = NULL;
struct Library * IconBase      = NULL;
struct Library * GadToolsBase  = NULL;

const static BOOL Not[2] = {TRUE,FALSE};



BOOL SetAsyncMode(BOOL BAsynch, int sCurrSocket)
{
	LONG lNonBlockCode = BAsynch;
		
	if (IoctlSocket(sCurrSocket, FIONBIO, (char *)&lNonBlockCode) < 0) return(FALSE); 
	return(TRUE);
}





/* Tries to copy the name of whoever is at the other end of our
   TCP socket into sBuffer, whose length is nBufLen.  */
void GetPhonePeerName(char *sBuffer, int nBufLen)
{
	LONG lLength = sizeof(struct sockaddr_in);
	struct hostent *hePeer = NULL;
	struct sockaddr_in saTempAdd;
	
    	UNLESS(SocketBase) 
    	{
		*sBuffer = '\0';	/* Can't do much w/o AmiTCP running */
		return;
	}
	
	if (getpeername(sTCPSocket, &saTempAdd, &lLength) < 0) 
	{
		sprintf(sBuffer,"gpn err %i",errno);
		DMakeReq(NULL,sBuffer,NULL);
	}	
	else hePeer = gethostbyaddr((caddr_t)&saTempAdd.sin_addr, sizeof(saTempAdd.sin_addr), AF_INET);
	
	Strncpy(sBuffer, hePeer? hePeer->h_name : "(unknown)", nBufLen);
	return;
}	
	


/* This function does the accepting of the socket from inetd. */	
BOOL AcceptTCPSocket(struct DaemonMessage *dm)
{
	LONG ulTrue = TRUE;	/* gotta pass it by reference, la la */
 	LONG ulAddrSize = sizeof(struct sockaddr_in);
	 	
	/* This function is called when we were started by inetd.  It hooks
	   us up with the calling program! */
	if ((dm == NULL)||(SocketBase == NULL)) return(FALSE);

	sTCPSocket = ObtainSocket((LONG)dm->dm_Id,(LONG) dm->dm_Family,(LONG) dm->dm_Type, 0L);
	if (sTCPSocket < 0) EXIT("ObtainSocket() failed.",RETURN_ERROR);
	
	/* Get the user init data and address */
	PhonedWait(0L);		/* Wait for connect packet */
	
	UNLESS(BNetConnect) EXIT("Couldn't get connection info!\n(Are you and the caller using\nthe latest version of AmiPhone?)",RETURN_ERROR)

	if (SafePutToPort(NULL,AmiPhonePortName()))
	{
		BNoReq = TRUE;
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"Port found: [%s]\n",AmiPhonePortName()); fflush(fpDebug);
		#endif
	}
	else 
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"Port not found: [%s]\n",AmiPhonePortName()); fflush(fpDebug);
		#endif
	}
	return(TRUE); 	
}


/* Closes sTCPSocket and sUDPSocket, and if BSendDisconnect is TRUE, it will
   tell the remote socket about it with a PHONECOMMAND_DISCONNECT packet */
BOOL ClosePhonedConnection(BOOL BSendDisconnect)
{
	struct sockaddr_in saNullAddress;
	
        if (SocketBase == NULL) return(FALSE);

	/* Tell our peer we're outta here, if he didn't disconnect first */
	if (BSendDisconnect == TRUE) 
	{
		#ifdef DEBUG_FLAG
			DEBUG("Sending disconnect packet...\n")
		#endif
		
		SendCommandPacket(PHONECOMMAND_DISCONNECT, 0, 0L);
	}
	if (sUDPSocket >= 0)
	{
		saNullAddress.sin_family = AF_UNSPEC;	/* to cause a disconnect */
		connect(sUDPSocket, &saNullAddress, sizeof(saNullAddress));
		CloseSocket(sUDPSocket);
		sUDPSocket = -1;
	}
	if (sTCPSocket >= 0)
	{
		CloseSocket(sTCPSocket);
		sTCPSocket = -1;
	}
	BNetConnect = FALSE;
	return(TRUE);
}




/* Creates and sets up a the UDP socket that we will be receiving
   data packets over.  */
LONG CreateUDPSocket(void)
{
	LONG sNewSocket;
	BOOL BDone = FALSE;
	int nPortNum;
	
	if ((sNewSocket = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
	{
		DMakeReq(NULL,"Couldn't create UDP socket",NULL);
		return(sNewSocket);
	}
	
	/* a new socket... */        
    	bzero(&saUDPSocket, sizeof(saUDPSocket));

	/* set it up... */	    	
	saUDPSocket.sin_family = AF_INET;
	saUDPSocket.sin_addr.s_addr = htonl(INADDR_ANY);
	
    	/* associate it with the socket we just made */ 
	for (nPortNum = IPPORT_USERRESERVED+1; nPortNum < (IPPORT_USERRESERVED+200); nPortNum++)
	{
	  	saUDPSocket.sin_port = htons(nPortNum);
		if (bind(sNewSocket, (struct sockaddr *) &saUDPSocket, sizeof(saUDPSocket)) == 0)
		{
			SetAsyncMode(TRUE, sNewSocket);
			return(sNewSocket);
		}
		#ifdef DEBUG_FLAG
			fprintf(fpDebug,"port %i: bind failed, errno=%i\n",nPortNum,errno);
			fflush(fpDebug);
		#endif
	}

	#ifdef DEBUG_FLAG
		fprintf(fpDebug,"CreateUDPSocket failed, errno = %i\n",errno);
		fflush(fpDebug);
	#endif
	
	return(-1);	/* failure */
}


/* Creates the UDP data reception socket, and sends a command to tell 
   the client where it is. */
BOOL CreateUDPConnection(UBYTE ubReplyType)
{
	/* Create and bind our new socket to a local port */
	sUDPSocket = CreateUDPSocket();

	if (sUDPSocket == -1) return(FALSE);
		
	/* This should fill out the local half of the deal */
	if (SendCommandPacket(PHONECOMMAND_REPLY, ubReplyType, saUDPSocket.sin_port) == FALSE)
	{
		#ifdef DEBUG_FLAG
			fprintf(fpDebug,"CreateUDPConnection: send REPLY failed, errno = %i\n",errno);
			fflush(fpDebug);
		#endif
		return(FALSE);
	}
	
	/* If we can't take a message, no point in continuing... */
	if (ubReplyType == PCREPLY_CANTLEAVEMESSAGE) EXIT("Couldn't accept incoming voice mail",RETURN_OK)
	if (ubReplyType == PCREPLY_LEAVEMESSAGE) BRecordMessage = TRUE;	

	return(TRUE);
}


/* This function sends a command/header packet back to the AmiPhone client.  */
BOOL SendCommandPacket(UBYTE ubCommand, UBYTE ubType, ULONG ulData)
{
	struct AmiPhonePacketHeader sendme;

	UNLESS((BNetConnect)&&(SocketBase)) return(FALSE);

	/* initialize our packet structure */
	sendme.ubCommand = ubCommand;
	sendme.ubType    = ubType;
	sendme.ulBPS	 = ulData;
	sendme.ulDataLen = 0L;			/* we only send this header */

	/* a nasty hack--I want to send the number of kbytes available for
	   a message, so I'm putting it in ulJoinCode. */
	if (ulSignalMessageFree > 0L) 
	{
		sendme.ulJoinCode= ulSignalMessageFree;
		ulSignalMessageFree = 0;
	}
	
	AttemptTCPSend(sTCPSocket, CLIENT_TCP_QUEUE, (UBYTE *)&sendme, sizeof(sendme));
	return(TRUE);
}


int DMakeReq(char *sTitle, char *sText, char *sGadgets)
{
	struct EasyStruct myreq;
	LONG number = 0L;
	int nResult;

	if (sTitle == NULL) sTitle = "AmiPhoned Message";
	if (sText == NULL) sText = "Hey, something's up!";
	if (sGadgets == NULL) sGadgets = "OK";

	myreq.es_TextFormat   = sText;
	myreq.es_Title        = sTitle;
	myreq.es_GadgetFormat = sGadgets;

	nResult = EasyRequest(NULL, &myreq, NULL, NULL, number);
	return(nResult);
}

void SetExitMessage(char * message, int nExitVal)
{
	Strncpy(szExitMessage,message,sizeof(szExitMessage));
	ngExitVal = nExitVal;
}


void FinalizeOutFile(void)
{
	ULONG ulSecondsTaken = ulMilliSecondsTaken / 1000;
	
	if (fpOut)
	{	
		fclose(fpOut);
		/* set a file note if we can */
		SetMessageNote(tTimeConnected, targethost, szMessageDir, ulSecondsTaken ? ulSecondsTaken : 1L);
		fpOut = NULL;	
	}
}

void CleanExit(void)
{
	ULONG ulLength=sizeof(struct sockaddr_in);
	char szBuf[25];
	int i;
		
	FinalizeOutFile();
	
	if (szMessageDir) FreeMem(szMessageDir,strlen(szMessageDir));
	
	if (AmiPhonedWindow) CloseTitleBar(&ulPhonedMask);
	if (AmiPhonedScreen) UnlockPubScreen(NULL, AmiPhonedScreen);

	/* Close the relays */
	for (i=0;i<10;i++) RemoveRelay(i,TRUE);
	
	#ifdef DEBUG_FLAG
		fprintf(fpDebug,"Closing sockets, %s\n", BNetConnect ? "with sending packet" : "no packet will be sent");
		fflush(fpDebug);
	#endif
		
	/* close connect socket if it's open */
	ClosePhonedConnection(BNetConnect);

	/* Give the PHONECOMMAND_DISCONNECT time to be received before we
	   tell the local client we're done--this way, when we're connected
	   to ourself, we don't cause the client to sent a DISCONNECT back
	   to us after we've closed the socket */
	Delay(15);
	
	/* Tell AmiPhone we're outta here */
	if (BLocalAmiPhoneNotified == TRUE)
	{
		MyInfo.daemonTask = NULL;
		SendMessageToClient(MSG_CONTROL_BYE);
	}
	
	AllocPacketList(FALSE);
	if (BAudioAvail == TRUE) 
	{
		ulPhonedMask &= ~((1L << port1->mp_SigBit) | (1L << port2->mp_SigBit));
		AllocAudio(FALSE);
		BAudioAvail = FALSE;
	}
		 	
	if (ngExitVal > RETURN_OK)
	{
		printf("CleanExit: [%s] (exit code %i)\n", szExitMessage, ngExitVal);	
	
	#ifdef DEBUG_FLAG
		if (fpDebug) 
		{
			fprintf(fpDebug,"CleanExit: [%s] (exit code %i)\n", szExitMessage, ngExitVal);	
			fflush(fpDebug);
		}
	#endif
	}

	SetupTCPQueue(CLIENT_TCP_QUEUE, FALSE);
			
	if ((IntuitionBase)&&(ngExitVal > RETURN_WARN))
	{
		sprintf(szBuf,"Exit (Code %i)", ngExitVal);
		DMakeReq(NULL,szExitMessage, szBuf);
	}

	OpenLibraries(FALSE);		/* close all libraries */
		
#ifdef DEBUG_FLAG
	if (ngExitVal > RETURN_OK) Delay(100);	/* so we can read the error */
	if (fpDebug != NULL) fclose(fpDebug);
#endif
}


char * OpenLibraries(BOOL BOpen)
{
	static char szError[30]="";
	
	if (BOpen == TRUE)
	{
		if ((GfxBase       = OpenLibrary("graphics.library",0L))  == NULL) return("graphics");
		if ((IntuitionBase = OpenLibrary("intuition.library",37)) == NULL) return("intuition");
		if ((SocketBase    = OpenLibrary("bsdsocket.library", 2)) == NULL) return("bsdsocket");
		if ((IconBase      = OpenLibrary("icon.library", 33))     == NULL) return("icon");
		if ((GadToolsBase  = OpenLibrary("gadtools.library", 36)) == NULL) return("gadtools");
			
		/* success */
		return(NULL);
	}
	else
	{
		if (GadToolsBase  != NULL) CloseLibrary(GadToolsBase);
		if (IconBase      != NULL) CloseLibrary(IconBase);
		if (IntuitionBase != NULL) CloseLibrary(IntuitionBase);
		if (SocketBase 	  != NULL) CloseLibrary(SocketBase);
		if (GfxBase	  != NULL) CloseLibrary((struct Library *)GfxBase);
		return(NULL);
	}

	return(NULL);
}

void debug(int i)
{
	#ifdef DEBUG_FLAG
		fprintf(fpDebug,"Waiting at debug point: [%i]\n",i);
		fflush(fpDebug);
		Delay(20);
	#endif
}


/* returns true if a data packet was received, else false. */
BOOL ReceiveUDPPacket(struct AmiPhoneSendBuffer * pPack)
{
	LONG ulAddressSize = sizeof(struct sockaddr_in);
	LONG ulBytesRead;
	int i;
	
	#ifdef DEBUG_FLAG
		if (pPack == NULL) DEBUG("ReceiveUDPPacket:  NULL packet!\n")
	#endif

	ulBytesRead = recvfrom(sUDPSocket,(UBYTE *)pPack,sizeof(struct AmiPhoneSendBuffer), 0L, &saUDPSocket, &ulAddressSize);
	if (ulBytesRead == (sizeof(struct AmiPhonePacketHeader) + pPack->header.ulDataLen))
	{
		MyInfo.ulLastPacketSize += pPack->header.ulDataLen;

		if (pPack->header.ubCommand == PHONECOMMAND_DATA) 
		{
			lPlayUpTo = -1L;		/* No waiting if we've got UDP! */
			QueueData(&pPack->header,pPack->ubData);
		}
		else
		{
			/* Tell AmiPhone client we saw an error */
			MyInfo.BErrorR |= TRUE;

			#ifdef DEBUG_FLAG
				fprintf(fpDebug,"ReceiveUDPPacket:  unacceptable (non-data) UDP packet, type %i %c\n",pPack->header.ubCommand,pPack->header.ubCommand);
				fflush(fpDebug);
			#endif
			return(FALSE);
		}	
	
		/* If we have any relay children, forward the packet to them too */
		for (i=0;i<10;i++)
		{
			if (sRelayUDPSocket[i] != -1) 
			{
				#ifdef DEBUG_FLAG
				fprintf(fpDebug,"Relaying UDP packet %i ('%c') to child %i [%s]\n",pPack->header.lSeqNum, pPack->header.ubCommand, i, szRelayName[i]); fflush(fpDebug);
				#endif
				send(sRelayUDPSocket[i], (UBYTE *)pPack, (sizeof(struct AmiPhonePacketHeader) + pPack->header.ulDataLen), 0L);
			}
		}
	}
	if (AUDIO_EMPTY) SetWindowTitle(NULL);
	return(TRUE);
}	


/* Recv() in, parse, and act on the new command data */
BOOL ReceiveTCPPacket(void)
{
	struct AmiPhoneSendBuffer * packet;
	struct AmiPhonePacketHeader * cph;
	
	UNLESS(packet = GetTCPPacket(sTCPSocket)) return(FALSE);
	switch(packet->header.ubCommand)
	{
		case PHONECOMMAND_DISCONNECT:
			UNLESS(BNetConnect) return(FALSE);
			BNetConnect = FALSE;
			BDone = TRUE;	/* Get us outta here! */
			break;

		case PHONECOMMAND_VWARN:
			CheckVersions(BImARelay ? "AmiPhoned relay server" : "AmiPhone client", packet->header.ulBPS, UserHere());
			break;

		case PHONECOMMAND_FLUSH:
			nQMode = QMODE_FLUSH;	/* Start playback now */
			lPlayUpTo = ((PacketList->lh_Tail) && 
			    	     (cph = (struct AmiPhonePacketHeader *) PacketList->lh_Tail->ln_Name))
			    			? cph->lSeqNum : -1L;
			PlayNextPacket();
			break;
		
		case PHONECOMMAND_CONNECT:
			if (BNetConnect) return(FALSE);
			
			/* If we're a relay, here's where we store that info */
			if (packet->header.ubType == PCCONNECT_RELAY) BImARelay = TRUE;

			#ifdef DEBUG_FLAG
			fprintf(fpDebug,"Connecting party is using client v%i.%i, server is v%i.%i\n",
				packet->header.ulJoinCode/100,packet->header.ulJoinCode%100,VERSION_NUMBER/100,VERSION_NUMBER%100); fflush(fpDebug);
			#endif
			
			if (CheckVersions(BImARelay ? "AmiPhoned relay server" : "AmiPhone client", packet->header.ulJoinCode, UserHere())) BSendWarningBack = TRUE;
								
			ulKeyCode = packet->header.ulBPS;
			BNetConnect = TRUE;
			break;
			
		case PHONECOMMAND_DATA:
			/* We're receiving reliable/batch data.  Queue it, 
			   but don't start playing it until we receive the 
			   "go ahead" FLUSH packet. */
			if (lPlayUpTo == -1L) lPlayUpTo = (packet->header.lSeqNum > 0L) ? (packet->header.lSeqNum-1) : 0L;
			QueueData(&packet->header, packet->ubData);
			SetWindowTitle(NULL);
			MyInfo.ulLastPacketSize += packet->header.ulDataLen;
			break;
			
		default:
			#ifdef DEBUG_FLAG
			fprintf(fpDebug,"ReceiveTCPPacket:  unknown command type %i [%c]\n",packet->header.ubCommand,packet->header.ubCommand);
			fflush(fpDebug);
			#endif
			return(FALSE);
			break;	
	}	
	return(TRUE);
}









void QueueData(struct AmiPhonePacketHeader * pHead, UBYTE * ubData)
{		
	struct AmiPhonePacketHeader * newPacket;
	ULONG ulDecompSize;
	static ULONG ulLastPacketSeqNum = 0L;
	
	#ifdef DEBUG_FLAG
		if (pHead  == NULL) DEBUG("QueueData:  NULL pHead!\n")
		if (ubData == NULL) DEBUG("QueueData:  NULL ubData!\n")
	#endif
	
	/* tell AmiPhone what kind of compression we're seeing */
	MyInfo.ubCurrComp = pHead->ubType;
	
	/* If we've got an outdated packet, we're closing down, or our queue is full, no sense in adding it */
	if (pHead->lSeqNum <= ulLowIndex)
	{		
		/* Tell AmiPhone client we saw an error */
		MyInfo.BErrorR |= TRUE;	
		return;	
	}
	UNLESS(BNetConnect) return;
	
	/* Figure out how much memory we'll need for the decompression,
	   based on the algorithm we're using. */
	switch(pHead->ubType)
	{
		case COMPRESS_NONE:	ulDecompSize = pHead->ulDataLen; 	break;	/* 1:1 decompression  */
		case COMPRESS_ADPCM2:	ulDecompSize = (pHead->ulDataLen*4);	break;	/* 1:4 decompression  */
		case COMPRESS_ADPCM3:	ulDecompSize = (pHead->ulDataLen*8/3); 	break;	/* 3:8 decompression  */
		default:		DEBUG("QueueData:  bad algorithm\n")
					return;
					break;
	}
	
	/* make the size of the data even, so the audio hardware will like it better */
	if (ulDecompSize % 2) ulDecompSize++;
	
	newPacket = AllocMem(sizeof(struct AmiPhonePacketHeader)+ulDecompSize, MEMF_CHIP);
	if (newPacket == NULL) 
	{
		#ifdef DEBUG_FLAG
		DEBUG("QueueData: Couldn't get memory!\n")
		#endif
		return;
	}
	
	/* copy over the header */
	memcpy(newPacket, pHead, sizeof(struct AmiPhonePacketHeader));
	
	/* If we are saving this data to disk, do so now */
	if (BRecordMessage) 
	{
		UNLESS(fpOut) fpOut = OpenMessageFile(tTimeConnected, szMessageDir);
		SavePacket(pHead,fpOut);
	}
	
	/* Now decompress the data and set the length field to reflect the new size */
	newPacket->ulDataLen = DecompressData(
				(UBYTE *) (((UBYTE *)pHead) + sizeof(struct AmiPhonePacketHeader)),
				(UBYTE *) (((UBYTE *)newPacket) + sizeof(struct AmiPhonePacketHeader)),
				pHead->ubType, pHead->ulDataLen,
				pHead->ulJoinCode);

	AddPacket((struct AmiPhoneSendBuffer *)newPacket);

	ulLastPacketSeqNum = pHead->lSeqNum;
	
	/* try to avoid an overflow if we're storing a large stream w/o playing! */
	if ((AUDIO_EMPTY)&&(AvailMem(MEMF_CHIP) < MIN_CHIP_MEMORY)) PlayNextPacket();
}


/* Replace all cFrom's in szString with cTo's */
void ReplaceChars(char * szString, char cFrom, char cTo)
{
	char * pcTemp;
	
	while(pcTemp = strchr(szString,cFrom)) *pcTemp = cTo;
}



BOOL SafePutToPort(struct Message * message, char * portname)
{	
	struct MsgPort * dport;
	
	Forbid();		
	dport = FindPort(portname);
	
	/* Only put a message if we have one--that way, we can pass in
	   NULL just to see if the port exists */
	if ((dport)&&(message)) PutMsg(dport, message);
	
	Permit();
	
	return(dport ? TRUE : FALSE);
}


char * AmiPhonePortName(void)
{
	static char szPortName[30];
	
	/* Open a local message port as something AmiPhoned can find */
	sprintf(szPortName,"AmiPhone_%ld",ulKeyCode);
	
	#ifdef DEBUG_FLAG
	fprintf(fpDebug,"Looking for port: [%s]\n",szPortName);
	fflush(fpDebug);
	#endif
	
	return(szPortName);
}

BOOL CreatePhonedMenus(BOOL BCreate)
{   
	void * VisualInfo = NULL;
	int i;
	
	if (BCreate == FALSE) 
	{
		if (Menu != NULL) 
		{
			FreeMenus(Menu);
			Menu = NULL;
		}
		return(TRUE);
	}

	UNLESS((AmiPhonedScreen)&&(AmiPhonedWindow)) return(FALSE);	

	/* Create menus */	
	UNLESS(Menu = CreateMenus(nmMenus, TAG_DONE)) return(FALSE);
	UNLESS(VisualInfo = GetVisualInfo(AmiPhonedScreen, TAG_END))
	{
		FreeMenus(Menu); Menu = NULL;
		return(FALSE);
	}
	
	if (LayoutMenus(Menu, VisualInfo, TAG_DONE))
	{
		/* Update the menus */
		for (i=0;i<10;i++) ReplaceMenuString(i);

		SetMenuStrip(AmiPhonedWindow, Menu);
	}
	else
	{
		FreeVisualInfo(VisualInfo);
		FreeMenus(Menu); Menu = NULL;
		return(FALSE);
	}
	FreeVisualInfo(VisualInfo);
	
	SetMenuValues();
	return(TRUE);
}

void LowerCase(char *sOldString)
{
	char *i = sOldString;
	const int diff = 'a' - 'A';

	if (sOldString == NULL) return();
 	while (*i != '\0')
 	{
       		if ((*i >= 'A')&&(*i <= 'Z')) *i += diff;
       	 	i++;
 	}
 	return;
}


void AddRelay(char * szOptIPName, int nWhich)
{
	char szTemp[100];
	char * szNewString = NULL;
	
	UNLESS(AmiPhonedWindow) return;
	UNLESS(Menu) return;
	UNLESS(SetupTCPQueue(nWhich, TRUE)) return;
	
	*szTemp = '\0';
		
	if (szOptIPName) Strncpy(szTemp, szOptIPName, sizeof(szTemp));
		    else UNLESS(GetUserString(AmiPhonedScreen, AmiPhonedWindow, szTemp, "Add a Relay IP", "Enter the Name of the site to relay to", sizeof(szTemp))) return;

	if (strlen(szTemp) < 1) return;

	/* must be lower case */
	LowerCase(szTemp);

	/* ignore any user@'s */
	szNewString = strrchr(szTemp,'@');
	if (szNewString == NULL) szNewString = szTemp; else szNewString++;

	/* translate "localhost" to our actual name--I get problems otherwise :( */
	if (strcmp(szNewString,"localhost") == 0) 
	{
		if (gethostname(szTemp,sizeof(szTemp)) < 0) return;
		szNewString = szTemp;
	}
	
	ConnectRelay(szNewString, nWhich);
	
	/* Update the menus */
	ReplaceMenuString(nWhich);
	
	/* Restore original title */
	SetWindowTitle(NULL);
}


/* Based on current socket info, replaces the given item in the Relay
   menu with what it should be. */
void ReplaceMenuString(int nWhich)
{
	char * pcOldString, * pcTemp;
		
	UNLESS((Menu)&&(AmiPhonedWindow)) return;	

	ClearMenuStrip(AmiPhonedWindow);
	UNLESS(pcOldString = ((struct IntuiText *)(GetRelayItem(nWhich)->ItemFill))->IText) 
	{
		#ifdef DEBUG_FLAG
			fprintf(fpDebug,"ReplaceMenuString:  Menu String %i not found!\n"); fflush(fpDebug);
		#endif
		return;
	}
	
	if (sRelayTCPSocket[nWhich] == -1)
	{
		if (nWhich == 9) nWhich = -1;
		sprintf(pcOldString,"-Add Relay #%i-", nWhich+1);
	}
	else
	{
		if (sRelayUDPSocket[nWhich] != -1)
		{
			Strncpy(pcOldString,szRelayName[nWhich],MAXRELAYNAMELEN);				
			/* cut it off at the first '.' */
			if (pcOldString = strchr(pcOldString,'.')) *pcOldString = '\0';	
		}
		else
		{
			*pcOldString = '(';
			Strncpy(pcOldString+1,szRelayName[nWhich],MAXRELAYNAMELEN-2);
			/* cut it off at the first '.' */
			if (pcTemp = strchr(pcOldString,'.')) *pcTemp = '\0';	
			strncat(pcOldString,")",MAXRELAYNAMELEN-1);
		}		
	}
	ResetMenuStrip(AmiPhonedWindow,Menu);
}


void RemoveRelay(int nWhich, BOOL BSendDisconnect)
{
	struct sockaddr_in saNullAddress;

	/* If there is no TCP socket, there's nothing to remove! */
	if (sRelayTCPSocket[nWhich] == -1) return;

	if (BSendDisconnect)
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"RemoveRelay: Sending disconnect to socket %i (nWhich==%i)\n",sRelayTCPSocket[nWhich],nWhich);
		fflush(fpDebug);
		#endif

		UNLESS(SendRelayCommandPacket(PHONECOMMAND_DISCONNECT, 0, 0L, nWhich))
		{
			#ifdef DEBUG_FLAG
			fprintf(fpDebug,"RemoveRelay:  Couldn't send disconnect packet to socket %i.\n",nWhich); fflush(fpDebug);
			#endif
		}
	}

	/* Close the data socket if it's open */
	if (sRelayUDPSocket[nWhich] != -1)
	{
		saNullAddress.sin_family = AF_UNSPEC;	/* to cause a disconnect */
		connect(sRelayUDPSocket[nWhich], &saNullAddress, sizeof(saNullAddress));
		CloseSocket(sRelayUDPSocket[nWhich]);
		sRelayUDPSocket[nWhich] = -1;
	}

	/* Get rid of buffers */
	SetupTCPQueue(nWhich, FALSE);
	
	/* Close the TCP socket */
	CloseSocket(sRelayTCPSocket[nWhich]);
	sRelayTCPSocket[nWhich] = -1;

	/* Get back our memory for the internal IP name string */
	FreeMem(szRelayName[nWhich],strlen(szRelayName[nWhich])+1);
	szRelayName[nWhich] = NULL;
		
	/* Update Menus */
	ReplaceMenuString(nWhich);
}


struct MenuItem * GetRelayItem(int nWhich)
{
	struct MenuItem * currentItem;
	
	UNLESS(Menu) return(NULL);
	
	currentItem = ((struct Menu *)(Menu->NextMenu))->FirstItem;
		
	/* Find the nWhich'thd item of the Relay menu */
	while (nWhich--) currentItem = currentItem->NextItem;

	return currentItem;
}


/* Sends out a "CONNECT_RELAY" packet */ 
int ConnectRelay(char * szIPName, int nWhich)
{
	int nTemp;
	LONG lTrue = TRUE;
	struct servent * sp;
	struct hostent * hp;
	const char szConnectType[] = "tcp";
	char szMessage[100];
	
	#ifdef DEBUG_FLAG
	if (szRelayName[nWhich]) 
	{
		fprintf(fpDebug,"ConnectRelay:  Warning!  Overwriting #%i, [%s]\n",nWhich,szRelayName[nWhich]);
		fflush(fpDebug);
	}
	#endif

	/* Record the IP of this relay */	
	nTemp = strlen(szIPName)+1;
	UNLESS(szRelayName[nWhich] = AllocMem(nTemp,MEMF_ANY)) return(FALSE);
	Strncpy(szRelayName[nWhich],szIPName,nTemp);	
	
    	SetErrnoPtr(&errno, sizeof(errno));
			sp = getservbyname("AmiPhone",szConnectType);
	if (sp == NULL) sp = getservbyname("Amiphone",szConnectType);	/* Try almost all lowercase then! */	
	if (sp == NULL) sp = getservbyname("amiPhone",szConnectType);	/* Try almost all lowercase then! */	
	if (sp == NULL) sp = getservbyname("amiphone",szConnectType);	/* Try all lowercase then! */	
	if (sp == NULL)
	{
		DEBUG("Couldn't find AmiPhone service.\n")
		return(FALSE);
	}
	port = sp->s_port;
	
	sprintf(szMessage,"Finding [%s]",szIPName);
	SetWindowTitle(szMessage);
	
	if ((hp = gethostbyname(szIPName)) == NULL)
	{
		DEBUG("gethostbyname() failed.\n")
		return(FALSE);
	}
	bzero(&saRelayTCPAddress[nWhich], sizeof(struct sockaddr_in));
	bzero(&saRelayUDPAddress[nWhich], sizeof(struct sockaddr_in));

    	bcopy(hp->h_addr, (char *)&(saRelayTCPAddress[nWhich].sin_addr), hp->h_length);
    	bcopy(hp->h_addr, (char *)&(saRelayUDPAddress[nWhich].sin_addr), hp->h_length);

	saRelayTCPAddress[nWhich].sin_family = hp->h_addrtype;
	saRelayUDPAddress[nWhich].sin_family = hp->h_addrtype;

	saRelayTCPAddress[nWhich].sin_port   = htons(port);	
	/* UDP address to be discovered later */
	
	sRelayTCPSocket[nWhich] = socket(hp->h_addrtype,SOCK_STREAM,0);
	if (sRelayTCPSocket[nWhich] < 0)
	{
		SetWindowTitle("Socket(TCP) failed.");
		return(FALSE);
	}
	sRelayUDPSocket[nWhich] = socket(hp->h_addrtype,SOCK_DGRAM,0);
	if (sRelayUDPSocket[nWhich] < 0)
	{
		SetWindowTitle("Socket(UDP) failed.");
		return(FALSE);
	}

	sprintf(szMessage,"Contacting [%s]",szIPName);
	SetWindowTitle(szMessage);
	
	if (connect(sRelayTCPSocket[nWhich], (struct sockaddr *) &saRelayTCPAddress[nWhich], sizeof(struct sockaddr_in)) < 0)
	{
		SetWindowTitle("Relay connect refused.");
		return(FALSE);
	}
	
	/* Set socket to non-blocking */
	IoctlSocket(sRelayTCPSocket[nWhich], FIONBIO, (char*)&lTrue);

	if (SendRelayCommandPacket(PHONECOMMAND_CONNECT, PCCONNECT_RELAY, 0L, nWhich) == FALSE)
	{
		SetWindowTitle("Relay init failed.");
		return(FALSE);
	}	
	return(TRUE);
}


/* This function sends the given command packet over the link.  */
BOOL SendRelayCommandPacket(UBYTE ubCommand, UBYTE ubType, ULONG ulData, int nQNum)
{
	struct AmiPhonePacketHeader AmiPack;
	
	AmiPack.ubCommand = ubCommand;
	AmiPack.ubType	  = ubType;
	AmiPack.ulBPS	  = ulData;
	AmiPack.ulDataLen = 0L;

	if (ubCommand == PHONECOMMAND_CONNECT) AmiPack.ulJoinCode = VERSION_NUMBER;	
	AttemptTCPSend(sRelayTCPSocket[nQNum], nQNum, (UBYTE *) (&AmiPack), sizeof(AmiPack));
	return(TRUE);
}


/* Send a packet consisting of the given header, plus ulDataLen bytes
   that are located after it. */
BOOL SendRelayDataPacket(struct AmiPhoneSendBuffer * pPack, ULONG sSocket)
{
	ULONG lSendLen;
	
	if (pPack == NULL) return(FALSE);
	lSendLen = pPack->header.ulDataLen + sizeof(struct AmiPhonePacketHeader);
	return(send(sSocket, (UBYTE *)pPack, lSendLen, 0L) == lSendLen);
}

void IncrementBuildup(int nDelta)
{
	char szTemp[40];
	
	nMinReserve += nDelta;
	if (nMinReserve < 0) nMinReserve = 0;
	
	sprintf(szTemp,"UDP Delay: [%i.%is]",(nMinReserve/1000),(nMinReserve%1000)/100);
	SetWindowTitle(szTemp);
}


void CheckDaemonInfo(void)
{
	/* See if AmiPhone wants us to change priority */
	if (MyInfo.nPri != nPri) 
	{
		nPri = MyInfo.nPri;
		SetTaskPri(FindTask(NULL), nPri);	
	}
	
	/* Also see if AmiPhone wants us to open or close our window */
	if (MyInfo.BWantWindowOpen == TRUE)
	{
		OpenTitleBar(&ulPhonedMask);
	}
	if (MyInfo.BWantWindowOpen == FALSE)
	{
		CloseTitleBar(&ulPhonedMask);
	}
}


void PhonedWait(ULONG ulStdMask)
{
	static struct fd_set fsReadSet, fsWriteSet;
	ULONG ulMask;
	UBYTE * ubTemp;
	int nMaxPort = -1,i;
	struct IntuiMessage *msg;
	ULONG ulClass, ulCode, ulItemCode;
	struct MenuItem * mItem;
		
	FD_ZERO(&fsReadSet);  			/* Initialize socket read set */
	FD_ZERO(&fsWriteSet);  			/* Initialize socket read set */
	
	/* reset timer mask */
	ulMask = ulStdMask;
	
	/* FD_SET for each of the sockets in use, and find the Max Socket. */
	if (sTCPSocket != -1) 
	{
		FD_SET(sTCPSocket, &fsReadSet);		
		if (TCPQueueLength(CLIENT_TCP_QUEUE) > 0) FD_SET(sTCPSocket, &fsWriteSet);
		if (sTCPSocket > nMaxPort) nMaxPort = sTCPSocket;
	}
	if (sUDPSocket != -1) 
	{
		FD_SET(sUDPSocket, &fsReadSet);		
		if (sUDPSocket > nMaxPort) nMaxPort = sUDPSocket;
	}
	for (i=0;i<10;i++) 
	{
		if (sRelayTCPSocket[i] != -1) 
		{
			FD_SET(sRelayTCPSocket[i], &fsReadSet);
			if (TCPQueueLength(i) > 0) FD_SET(sRelayTCPSocket[i], &fsWriteSet);
			if (sRelayTCPSocket[i] > nMaxPort) nMaxPort = sRelayTCPSocket[i];
		}
		
		/* Don't need to listen on relay's UDP sockets because
		   they're not allowed to send anything back on those */
	}
	
	/* Wait for Data to come in */
	/*         socket#     read        write        oob  timeout  other */
	WaitSelect(nMaxPort+1, &fsReadSet, &fsWriteSet, NULL, NULL,   &ulMask);
		
	CheckDaemonInfo();

	if (ulMask & SIGBREAKF_CTRL_E)
	{
		/* Toggle window state */
		if (AmiPhonedWindow) CloseTitleBar(&ulPhonedMask);
			        else OpenTitleBar(&ulPhonedMask);
	}	
	
	if ((port1)&&(ulMask & (1<<port1->mp_SigBit))) 
	{
		bStatus[0] = STATUS_INVALID;
		/* Now that the play is done, we can free the memory */	
		ubTemp = (UBYTE *) AIOptr1->ioa_Data;
		ubTemp -= sizeof(struct AmiPhonePacketHeader);
		FreePacket((struct AmiPhonePacketHeader *) ubTemp);
	
		while (GetMsg(port1)) {};	/* Clear the message port */
		PlayNextPacket();
	}
	
	if ((port2)&&(ulMask & (1<<port2->mp_SigBit))) 
	{
		bStatus[1] = STATUS_INVALID;
		/* Now that the play is done, we can free the memory */
		ubTemp = (UBYTE *) AIOptr2->ioa_Data;
		ubTemp -= sizeof(struct AmiPhonePacketHeader);
		FreePacket((struct AmiPhonePacketHeader *) ubTemp);

		while (GetMsg(port2)) {};	/* Clear the message port */
		PlayNextPacket();
	}
	
	if ((AmiPhonedWindow)&&(ulMask & (1<<AmiPhonedWindow->UserPort->mp_SigBit)))
	{
		if (msg = (struct IntuiMessage *) GetMsg(AmiPhonedWindow->UserPort))
		{
			ulClass = msg->Class;
			ulCode  = msg->Code;
			ReplyMsg((struct Message *) msg);
	
			switch(ulClass)
			{
				case IDCMP_CLOSEWINDOW:
					EXIT("User Disconnected",RETURN_OK)
					break;
					
				case IDCMP_MENUPICK:
					while( ulCode != MENUNULL ) 
					{
						mItem = ItemAddress( Menu, ulCode );
						ulItemCode = (ULONG) GTMENUITEM_USERDATA(mItem);
						if ((ulItemCode >= R_ADDRELAY)&&(ulItemCode <= R_ADDRELAY+9))
						{
							if (sRelayTCPSocket[ulItemCode-R_ADDRELAY] == -1) AddRelay(NULL,ulItemCode-R_ADDRELAY);
												    else RemoveRelay(ulItemCode-R_ADDRELAY,TRUE);
						}
						else switch(ulItemCode)
						{
							case P_LAUNCH:		LaunchXMitter(targethost);	break;
							case P_INCREMENT:	IncrementBuildup(100);	break;
							case P_DECREMENT:	IncrementBuildup(-100);	break;
							case P_RECORD:		if (BRecordMessage) FinalizeOutFile();
										BRecordMessage = Not[BRecordMessage];
										break;
							case P_ABOUT: 		DisplayAbout(); 			   break;
							case P_FLUSHBUFFER:	lPlayUpTo = -1L; nQMode = QMODE_FLUSH; PlayNextPacket(); break;
							case P_HIDEWINDOW:	CloseTitleBar(&ulPhonedMask);		   break;
							case P_QUIT:  		EXIT("User Disconnected",RETURN_OK);	   break;
							default: 		printf("Bad Menu Code:  %i\n",ulItemCode); break;
						}
						ulCode = mItem->NextSelect;
					}
					break;
			}
		}
	}

	if (FD_ISSET(sUDPSocket, &fsReadSet))    
	{
		ReceiveUDPPacket(&recBuffer);
		PlayNextPacket();	/* also try to play whenever we get new info */
	}

	if (FD_ISSET(sTCPSocket, &fsWriteSet)) ReduceTCPQueue(CLIENT_TCP_QUEUE, sTCPSocket);
	if (FD_ISSET(sTCPSocket, &fsReadSet))  ReceiveTCPPacket();
	
	for (i=0;i<10;i++) 
	{
		if (FD_ISSET(sRelayTCPSocket[i],&fsReadSet)) HandleRelayResponse(i);
		if (FD_ISSET(sRelayTCPSocket[i],&fsWriteSet)) ReduceTCPQueue(i, sRelayTCPSocket[i]);
	}
	
	if (ulMask & SIGBREAKF_CTRL_C) BDone = TRUE;

	SetMenuValues();
}

/* Update menus... actually this doesn't update the Relay menu, just Project for now */
void SetMenuValues(void)
{
	struct Menu *currentMenu = Menu;
	struct MenuItem *currentItem, *currentSub;

	UNLESS(currentMenu) return;

	if (AmiPhonedWindow) ClearMenuStrip(AmiPhonedWindow);

	/* Project Menu */
	FIRSTITEM;	if (BNoClient) ENABLEITEM; else DISABLEITEM;
	NEXTITEM;	/* Inc/dec submenu */
		FIRSTSUB; 	/* Inc */
		NEXTSUB;	/* Dec */
		if (nMinReserve > 0) ENABLESUB; else DISABLESUB;
	NEXTITEM;	/* Record toggle */
	if (szMessageDir) ENABLEITEM; else DISABLEITEM;
	if (BRecordMessage) CHECKITEM; else UNCHECKITEM;
	NEXTITEM;	/* Flush Buffers */
	if (nQLength > 0) ENABLEITEM; else DISABLEITEM;
	
	if (AmiPhonedWindow) ResetMenuStrip(AmiPhonedWindow,Menu);
}


void PrintSocketState(struct sockaddr_in * psaSock)
{
#ifdef DEBUG_FLAG
	fprintf(fpDebug,"sin_family   =%d\n",psaSock->sin_family);
	fprintf(fpDebug,"sin_port     =%d\n",psaSock->sin_port);
	fprintf(fpDebug,"sin_sin_addr =%d\n",(ULONG)(psaSock->sin_addr));
	fprintf(fpDebug,"sin_zero     = %i %i %i %i %i %i %i %i\n",
			psaSock->sin_zero[0],
			psaSock->sin_zero[1],
			psaSock->sin_zero[2],
			psaSock->sin_zero[3],
			psaSock->sin_zero[4],
			psaSock->sin_zero[5],
			psaSock->sin_zero[6],
			psaSock->sin_zero[7]);
	fflush(fpDebug);
#endif
}


/* Called when we get a response.  Puts us in full-blown relay state! */
/* Changes the port to the final port (The one to use to send data)   */ 
void FinalizeRelay(int nWhich, int nPortNum, UBYTE ubReplyType, ULONG ulDataLen)
{
	int nSuccess;
	char szText[150];
		
	/* Change the conect port for this relay to what was specified */	
	saRelayUDPAddress[nWhich].sin_port = htons(nPortNum);
	nSuccess = connect(sRelayUDPSocket[nWhich], (struct sockaddr *) &saRelayUDPAddress[nWhich], sizeof(struct sockaddr_in));
	if (nSuccess < 0) 
	{	
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"FinalizeRelay: warning, reconnect failed: errno=%i\n",errno);
		fflush(fpDebug);
		#endif
	}
	if (ubReplyType == PCREPLY_CANTLEAVEMESSAGE)
	{
		DMakeReq(NULL,"This relay is not available, and their voice mail box is either full or disabled.",NULL);
		RemoveRelay(nWhich,FALSE);
		return;	
	}
	else if (ubReplyType == PCREPLY_LEAVEMESSAGE)
	{	
		sprintf(szText,"Your relay at %s is not available right now.\nWould you like to relay a message?  (%dk available)", szRelayName[nWhich], ulDataLen);
		UNLESS(DMakeReq(NULL,szText,"Leave Message|Cancel")) 
		{
			RemoveRelay(nWhich, TRUE);
			return;
		}
	}
	SetWindowTitle("Relay established.");
	ReplaceMenuString(nWhich);
}

void HandleRelayResponse(int nWhich)
{
	struct AmiPhonePacketHeader aphTemp;
	LONG ulAddressSize = sizeof(struct sockaddr_in);
	LONG ulBytesRead;

	#ifdef DEBUG_FLAG
		fprintf(fpDebug,"Handling response from Relay %i\n",nWhich); fflush(fpDebug);
	#endif

	/* Note:  Can't use GetTCPPacket() because it only has 1 static buffer... */
	ulBytesRead = recv(sRelayTCPSocket[nWhich],(UBYTE *)&aphTemp,sizeof(struct AmiPhonePacketHeader), 0L);
	if (ulBytesRead == sizeof(struct AmiPhonePacketHeader))
	{	
		switch(aphTemp.ubCommand)
		{			
			case PHONECOMMAND_DISCONNECT:
			case PHONECOMMAND_DENY:
				SetWindowTitle("Relay denied.");
				RemoveRelay(nWhich,FALSE);
				break;

			case PHONECOMMAND_VWARN:
				CheckVersions("AmiPhoned relay client", aphTemp.ulBPS, UserHere());
				break;
				
			case PHONECOMMAND_REPLY:
				FinalizeRelay(nWhich, aphTemp.ulBPS, aphTemp.ubType, aphTemp.ulJoinCode);
				break;

			default:
				#ifdef DEBUG_FLAG
					fprintf(fpDebug,"HandleRelayResponse:  unknown command type %i %c\n",aphTemp.ubCommand,aphTemp.ubCommand);
					fflush(fpDebug);
				#endif
				break;	
		}
	} 
	else 
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"Warning, packet size (ulBytesRead=%d) mismatch (should be %d)\n",
			ulBytesRead, sizeof(struct AmiPhonePacketHeader));
		fflush(fpDebug);
		#endif
	}
}


void ParseArgs(void)
{
	int nParam;
	char *szParam;
	char *pcAmiPhone = getenv("AMIPHONE");
	struct DiskObject *AmiPhoneIconDiskObject;

	if (pcAmiPhone == NULL) pcAmiPhone = "AmiTCP:bin/AmiPhone";	/* default */
	
	AmiPhoneIconDiskObject = GetDiskObject((UBYTE *)pcAmiPhone);
	if (AmiPhoneIconDiskObject == NULL) return;

	if (GetToolTypeArg(AmiPhoneIconDiskObject, "AWAYVAR", &nParam, &szParam)) Strncpy(szAwayVar,szParam,sizeof(szAwayVar));
	if (GetToolTypeArg(AmiPhoneIconDiskObject, "VOICEMAILDIR", &nParam, &szParam)) 
	{
		szMessageDir = AllocMem(strlen(szParam)+1,MEMF_ANY);
		if (szMessageDir != NULL) 
		{
			Strncpy(szMessageDir,szParam,strlen(szParam)+1);
			#ifdef DEBUG_FLAG
			fprintf(fpDebug,"Message Directory: [%s]\n",szParam); fflush(fpDebug);
			#endif
		}
	}
	if (GetToolTypeArg(AmiPhoneIconDiskObject, "DAEMONLEFT", &nParam, &szParam)) windowleft = nParam;
	if (GetToolTypeArg(AmiPhoneIconDiskObject, "DAEMONTOP",  &nParam, &szParam)) windowtop  = nParam;
	if (GetToolTypeArg(AmiPhoneIconDiskObject, "MAXVOICEMAILSIZE", &nParam, &szParam)) nMaxVoiceMailDirSize = nParam;
	if (GetToolTypeArg(AmiPhoneIconDiskObject, "MAXMESSAGESIZE", &nParam, &szParam))   nMaxMessageSize      = nParam;
	if (GetToolTypeArg(AmiPhoneIconDiskObject, "STARTUPDELAY", &nParam, &szParam))   nMinReserve = nParam;
	
	if (GetToolTypeArg(AmiPhoneIconDiskObject, "SHOWDAEMON", &nParam, &szParam))
	{
		if ((*szParam=='n')||(*szParam=='N')) BOpenWindow = FALSE; else BOpenWindow = TRUE;
	}
	if ((AmiPhonedScreen == NULL)&&(GetToolTypeArg(AmiPhoneIconDiskObject, "PUBSCREEN",  &nParam, &szParam)))
		AmiPhonedScreen = LockPubScreen(szParam);
	else if ((AmiPhonedScreen == NULL)&&(GetToolTypeArg(AmiPhoneIconDiskObject, "PUBLICSCREEN",  &nParam, &szParam)))
		AmiPhonedScreen = LockPubScreen(szParam);

       	FreeDiskObject(AmiPhoneIconDiskObject);	
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

BOOL GetToolTypeArg(struct DiskObject * AmiPhoneIconDiskObject, char *szArg, int *nParam, char **szParam)
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



void LaunchXMitter(char * szPeerName)
{
	char szCommand[350];
	ULONG ulResult;
	char * pcAmiPhone = getenv("AMIPHONE");
	char * pcTemp;
	
	if (pcAmiPhone == NULL) pcAmiPhone = "AmiTCP:bin/AmiPhone";
	
	sprintf(szCommand,"run %s %s _KEY=%lu|%lu", pcAmiPhone, szPeerName, ulKeyCode, (ULONG) (&MyInfo));

	/* strip out any EOL chars */
	while (pcTemp = strchr(szCommand,'\r')) *pcTemp = ' ';
	while (pcTemp = strchr(szCommand,'\n')) *pcTemp = ' ';

#ifdef DEBUG_FLAG
	fprintf(fpDebug,"executing: [%s] (MyInfo=%p)\n",szCommand,&MyInfo);
	fflush(fpDebug);
#endif	
	/* and... launch! */
	if ((ulResult = system(szCommand)) != 0)
	{
		#ifdef DEBUG_FLAG
			fprintf(fpDebug,"LaunchXMitter:  warning, client launch returned %d\n",ulResult);
			fflush(fpDebug);
		#endif
	}
	else BNoClient = FALSE;
}



void DisplayAbout(void)
{	
	char szMessage[300]="";

	sprintf(szMessage,"AmiPhoned v%i.%i%s\nby Jeremy Friesner\njfriesne@ucsd.edu\nCompiled: %s",
		VERSION_NUMBER/100, VERSION_NUMBER%100, 
		#ifdef DEBUG_FLAG
		"D",
		#else
		"",
		#endif
		__DATE__);
	DMakeReq(NULL,szMessage,"Okay");				
}


/* This is initialization info only! */
void SetUpLocalAmiPhoneInfo(struct AmiPhoneInfo * inf)
{
	inf->PhoneMsg.mn_Node.ln_Type 	= NT_MESSAGE;
	inf->PhoneMsg.mn_Length 	= sizeof(struct AmiPhoneInfo);
	inf->PhoneMsg.mn_ReplyPort    	= NULL;
	inf->ubControl			= MSG_CONTROL_HI;
	inf->ubCurrComp			= COMPRESS_INVALID;
	inf->ulLastPacketSize		= 0L;
	inf->BErrorR			= FALSE;
	inf->nPri			= nPri;
	inf->BWantWindowOpen		= -1;  /* = no preference */
	inf->daemonTask			= FindTask(NULL);
	inf->BWindowIsOpen		= (AmiPhonedWindow != NULL);
}



/* Allocates the PacketList, or clears and frees it */
BOOL AllocPacketList(BOOL BAlloc)
{	
	if (BAlloc == TRUE)
	{		
		if (PacketList != NULL) return(FALSE);
		UNLESS(PacketList = AllocMem(sizeof(struct List),MEMF_CLEAR)) return(FALSE);
		NewList(PacketList);
	}
	else
	{
		struct Node * current;
		
		UNLESS(PacketList) return(FALSE);
		
		while(current = RemHead(PacketList))
		{
			FreePacket((struct AmiPhonePacketHeader *) current->ln_Name);
			FreeMem(current,sizeof(struct Node));
		}
		FreeMem(PacketList,sizeof(struct List));
		PacketList = NULL;
	}
	return(TRUE);
}


/* Will play the earliest numbered packet that is after ulLowIndex
   and delete any that came before it.  If it did play a (REAL)
   packet, it will increase ulLowIndex to be that packet number */
BOOL PlayNextPacket(void)
{
	struct Node * current;
	struct AmiPhonePacketHeader * cph;
	int nPlayPackets;		/* Number of packets to attempt to play before returning */
	ULONG ulNextIndex;

	if ((lPlayUpTo != -1L) && (PacketList->lh_Head) &&
	    (cph = (struct AmiPhonePacketHeader *) PacketList->lh_Head->ln_Name) &&
	    (cph->lSeqNum > lPlayUpTo)) return(FALSE);
		
	/* Determine how many packets should be set up to play */
	     if (AUDIO_FULL)  return(FALSE);	/* Don't play if both slots are full */
	else if (AUDIO_HALF)  nPlayPackets = 1;	/* Play one packet if one is free    */
	else 		      nPlayPackets = 2; /* Play two packets if two are free  */

	/* If there are no more packets pending, and nobody is playing
	   anything, then free the audio channel! */
	if ((nQLength == 0)&&(nPlayPackets == 2)&&(BAudioAvail == TRUE))
	{
		ulPhonedMask &= ~((1L << port1->mp_SigBit) | (1L << port2->mp_SigBit));
		AllocAudio(FALSE);
		BAudioAvail = FALSE;
	}
			
	/* One more check--if we hit empty, we want to fill back up
	   before we start playing again; at least this will localize
	   the annoyance to one large gap rather than many little ones! */
     	if (nQLengthMS < nMinReserve)
     	{
     		/* If we're empty, we want to save up. */
     		if (nQMode == QMODE_EMPTY) return(FALSE);
     	}
     	else nQMode = QMODE_FLUSH;   /* queue has enough packets, start draining! */
	
	while (current = RemHead(PacketList))			
	{
		nQLength--;
		cph = (struct AmiPhonePacketHeader*) current->ln_Name;
		nQLengthMS -= PacketTime(cph);
		FreeMem(current,sizeof(struct Node));
		/* Refresh window title to reflect the new length */
		SetWindowTitle(NULL);
		
		/* If the queue becomes empty, start storing up again */
		if (nQLength == 0) nQMode = QMODE_EMPTY;

		if (cph->lSeqNum <= ulLowIndex)
		{
			#ifdef DEBUG_FLAG
			fprintf(fpDebug,"PlayNextPacket: Packet (%d) was <= ulLowIndex (%d), killing it. (you should never see this message)\n",cph->lSeqNum, ulLowIndex);
			fflush(fpDebug);
			#endif
			
			/* Tell AmiPhone client we saw an error */
			MyInfo.BErrorR |= TRUE;

			FreePacket(cph);
		}
		else
		{
			/* Found the first higher-than-ulLowIndex item in the list.
			   Since the list is sorted low-to-high, it should be the minimum. 
			   Play it, and set ulLowIndex equal to it, then free it. 
			   Then set the timer for the next piece. */
		
			/* Since PlayAudio may deallocate our packet, get this info now. */
			ulNextIndex = cph->lSeqNum;

			/* If we don't have an audio channel, get one! */
			if (BAudioAvail == FALSE) 
			{
				BAudioAvail = AllocAudio(TRUE);
				
				/* To ensure any half-way allocs are free'd */
				if (BAudioAvail == FALSE) 
				{
					/* Tell AmiPhone client we have an error */
					MyInfo.BErrorR |= TRUE;
		
					AllocAudio(FALSE);
				}
				else
					ulPhonedMask |= ((1L << port1->mp_SigBit) | (1L << port2->mp_SigBit));

			}
	
			/* PlayAudio can handle it if there isn't BAudioAvail */				
			if (PlayAudio((struct AmiPhoneSendBuffer *)cph) == FALSE)
			{
				DEBUG("PlayNextPacket: PlayAudio FAILED.\n")
			}
		
			/* raise the minimum requirement! */
			ulLowIndex = ulNextIndex;

			nPlayPackets--;
			if (nPlayPackets == 0) return(TRUE);
		}
	}
 	return(TRUE);
}


/*  plays the given packet, if it can, changing the status[] appropriately  */
BOOL PlayAudio(struct AmiPhoneSendBuffer * packet)
{
	struct IOAudio * AIOptr;
	
	static LONG lTrackSeq = 0L;
	
	if (packet->header.lSeqNum != (lTrackSeq+1))
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"Warning: packet noncontinuity [%d -> %d]\n",
			lTrackSeq, packet->header.lSeqNum);
		fflush(fpDebug);
		#endif
		
		/* Tell AmiPhone client we saw an error */
		MyInfo.BErrorR |= TRUE;
	}
	lTrackSeq = packet->header.lSeqNum;

	#ifdef DEBUG_FLAG
	fprintf(fpDebug,"Playing packet [%i], length=[%i], BPS=[%i]\n",
		packet->header.lSeqNum,packet->header.ulDataLen,packet->header.ulBPS);
	fflush(fpDebug);
	#endif
	
	if (packet == NULL)
	{
		DEBUG("PlayAudio: NULL packet\n")
		return(FALSE);
	}

	if (BAudioAvail == FALSE)
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"No audio available, throwing away packet %lu\n",packet->header.lSeqNum); fflush(fpDebug);
		#endif
		
		/* since we can't play it, simply throw away this packet */
		FreePacket((struct AmiPhonePacketHeader *)packet);
		return(TRUE);
	}
		
	if (packet->header.ulBPS < MIN_SAMPLE_RATE) 
	{
		#ifdef DEBUG_FLAG
			fprintf(fpDebug,"PlayAudio:  play rate too low [%d]\n",packet->header.ulBPS);
		#endif	
		return(FALSE);
	}
	if (packet->header.ulDataLen < 1L) 
	{
		DEBUG("PlayAudio:  empty packet\n")			
		return(FALSE);
	}
	
	if (bStatus[0] == STATUS_INVALID) 
	{
		AIOptr=AIOptr1;
		bStatus[0] = STATUS_PLAYING;
	}
	else if (bStatus[1] == STATUS_INVALID)
	{
		AIOptr=AIOptr2;
		bStatus[1] = STATUS_PLAYING;
	}
	else 
	{
		DEBUG("PlayAudio:  no free channels\n")
		return(FALSE);
	}
	
	/* Fill out sample length, pointer to data, and playback speed */	
	AIOptr->ioa_Length = packet->header.ulDataLen;
	AIOptr->ioa_Data   = packet->ubData;
	AIOptr->ioa_Period = (UWORD) (SystemClock / packet->header.ulBPS);	
	
	BeginIO((struct IORequest *)AIOptr);	/* start playing sample */
	return(TRUE);
}





/* Deallocates memory for the given packet AND its associated data chunk */
void FreePacket(struct AmiPhonePacketHeader * cph)
{	
	#ifdef DEBUG_FLAG
	if (cph == NULL) 
	{	
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"FreePacket: NULL pointer!\n");
		#endif
		return;
	}
	#endif

	FreeMem(cph,sizeof(struct AmiPhonePacketHeader) + cph->ulDataLen);
}



#ifdef DEBUG_FLAG
void PrintPacketList(void)
{
	struct Node * current = PacketList->lh_Head;
	struct AmiPhonePacketHeader * aph;
	
	fprintf(fpDebug,"Packet List: nQLength = %i\n",nQLength);
	
	while (current->ln_Succ)
	{
		aph = (struct AmiPhonePacketHeader *)(current->ln_Name);
		if (aph == NULL) DEBUG("NULL NODE!!!")
		else
		fprintf(fpDebug,"Node: lSeq = %d, lLen = %d, lCom = %d lType = %d\n",
			aph->lSeqNum, aph->ulDataLen, aph->ubCommand, aph->ubType);
		current = current->ln_Succ;
	}
}
#endif


/* Will add the packet to the list, based on its SeqNum */
/* If the index is lower than ulLowIndex, we will cheerfully delete
   it and return TRUE anyway.  That we at least packets are never
   played out of order!  */
BOOL AddPacket(struct AmiPhoneSendBuffer * ubPacket)
{
	struct Node * newNode;
	struct Node *current=PacketList->lh_Head, *past;
	struct AmiPhonePacketHeader * nph, * cph;
	static LONG lHighestSeqNum = 0L;
	
	if (ubPacket->header.lSeqNum <= ulLowIndex) 
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"AddPacket: Packet %d was below ulLowIndex %d, killing it.\n",ubPacket->header.lSeqNum, ulLowIndex);
		fflush(fpDebug);
		#endif
		
		/* Tell AmiPhone client we saw an error */
		MyInfo.BErrorR |= TRUE;

		FreePacket((struct AmiPhonePacketHeader *)ubPacket);
		return(TRUE);
	}
	
	if ((newNode = AllocMem(sizeof(struct Node), MEMF_CLEAR)) == NULL) return(FALSE);
	newNode->ln_Name = (char *) ubPacket;

	past = NULL;
	nph = (struct AmiPhonePacketHeader*) newNode->ln_Name;	

	/* Only do things the expensive way if the new packet isn't in order! */
	if (nph->lSeqNum < lHighestSeqNum)
	{
		/* Add the packet into the correct place in the list, based
		   on its sequence number. */
		while (current->ln_Succ)
		{
			cph = (struct AmiPhonePacketHeader*) (current->ln_Name);
		
			if (cph->lSeqNum > nph->lSeqNum)
			{
				Insert(PacketList, newNode, past);	/* and put it back in after current */
				nQLength++;
				nQLengthMS += PacketTime((struct AmiPhonePacketHeader *)ubPacket);
				return(TRUE);
			}
			past = current;				/* step to next in list */
			current = current->ln_Succ;
		}
	}
	else
	{
		/* Otherwise add the packet directly to the end! */
		lHighestSeqNum = nph->lSeqNum;
		AddTail(PacketList,newNode);		/* If we've got to the end without returning, add it to the end */
		nQLength++;	
		nQLengthMS += PacketTime((struct AmiPhonePacketHeader *)ubPacket);
	}
	return(TRUE);
}



/* Opens a little title bar to give listening status, and to let the
   user close it if he wants to disconnect. */
void OpenTitleBar(ULONG * pulMask)
{
	char * pcTemp;
	char szTemp[100];
	
	if (AmiPhonedWindow != NULL) return;
		
	/* Get default pub screen if we don't already have one */
	if (AmiPhonedScreen == NULL) AmiPhonedScreen = LockPubScreen(NULL);
	if (AmiPhonedScreen == NULL) return;

	Strncpy(szShortPeerName, targethost, sizeof(szShortPeerName));
	if (pcTemp = strchr(szShortPeerName,'.')) *pcTemp = '\0';

	sprintf(szTemp,"AmiPhoned:[%s] [88.8s] +",szShortPeerName);
	nWindowWidth = TextLength(&AmiPhonedScreen->RastPort, szTemp, strlen(szTemp))+EXTRA_WINDOW_WIDTH;
	
	if (windowtop == -1)  windowtop    = 0;	
	if (windowleft == -1) windowleft   = (AmiPhonedScreen->Width - nWindowWidth)/2;
	
        if (AmiPhonedWindow = OpenWindowTags( NULL,
		WA_Left,        windowleft,
        	WA_Top,         windowtop,
               	WA_Width,       nWindowWidth,
	        WA_Height,      AmiPhonedScreen->Font->ta_YSize+3,
	        WA_PubScreen,	AmiPhonedScreen,
	        WA_IDCMP,       IDCMP_CLOSEWINDOW|IDCMP_MENUPICK,
	        WA_Flags,       WFLG_SMART_REFRESH|WFLG_ACTIVATE|WFLG_CLOSEGADGET|
	        				WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_NEWLOOKMENUS,
	       	WA_DepthGadget, TRUE,
	       	WA_CloseGadget, TRUE,
	       	WA_DragBar,	TRUE,
	       	WA_AutoAdjust,  TRUE,
	       	WA_Activate,    FALSE,
		TAG_DONE )) *pulMask |= 1L<<(AmiPhonedWindow->UserPort->mp_SigBit);

	SetWindowTitle(NULL);
	CreatePhonedMenus(TRUE);
	
	MyInfo.BWindowIsOpen = TRUE;
	MyInfo.BWantWindowOpen = -1;
	SendMessageToClient(MSG_CONTROL_UPDATE);
}


/* Sends a message and wait for reply */
BOOL SendMessageToClient(UBYTE ubMessage)
{
	char * szPortName = AmiPhonePortName();
	struct MsgPort * WaitForReplyAt = CreatePort(0,0);
	BOOL BMessageSent = FALSE;
	
	UNLESS(WaitForReplyAt) return(FALSE);
	
	MyInfo.PhoneMsg.mn_Node.ln_Type = NT_MESSAGE;
	MyInfo.PhoneMsg.mn_Length       = sizeof(struct AmiPhoneInfo);
	MyInfo.PhoneMsg.mn_ReplyPort    = WaitForReplyAt;
		
	MyInfo.ubControl = ubMessage;
	
	if (SafePutToPort((struct Message *)&MyInfo, szPortName)) 
	{
		BMessageSent = TRUE;
		WaitPort(WaitForReplyAt);
		BNoClient = FALSE;
	}
	else BNoClient = TRUE;	/* sniff--we must be all awone... */
	
	/* Okay to just straight-out delete this port because */
	/* we know that it is only going to be used for one reply msg */
	DeletePort(WaitForReplyAt);
	
	return(BMessageSent);
}



/* Closes the little title bar */
void CloseTitleBar(ULONG * pulMask)
{
	if (AmiPhonedWindow == NULL) return;

	windowtop  = AmiPhonedWindow->TopEdge;
	windowleft = AmiPhonedWindow->LeftEdge;
	
	*pulMask &= ~(1L<<(AmiPhonedWindow->UserPort->mp_SigBit));
	CloseWindow(AmiPhonedWindow);
	
	CreatePhonedMenus(FALSE);
	
	AmiPhonedWindow = NULL;
	MyInfo.BWindowIsOpen = FALSE;
	
	MyInfo.BWantWindowOpen = -1;
	SendMessageToClient(MSG_CONTROL_UPDATE);
}



/* returns TRUE if user is not marked away, FALSE if he is */
BOOL UserHere(void)
{
	char *szAway = NULL;
	
	if (szAwayVar) szAway = getenv(szAwayVar);
	
	#ifdef DEBUG_FLAG
	fprintf(fpDebug,"AwayVar: [%s]->[%s]\n",
		(szAwayVar ? szAwayVar : "<NULL"),
		(szAway ? szAway : "<NULL>"));
	#endif
	
	return(szAway == NULL);
}




/* Returns the number of kilobytes of free storage available on
   the disk in which szDirectory resides. */
int FreeSpaceOnDisk(char * szDirectory)
{
	BPTR MyLock = Lock(szDirectory, ACCESS_READ);
	LONG ulBlocksFree;
	__aligned struct InfoData MyData;
	
	if (MyLock == 0)
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"FreeSpaceOnDisk:  Lock of [%s] failed.\n",szDirectory); fflush(fpDebug);
		#endif
		return(0);
	}
	
	Info(MyLock, &MyData);
		
	ulBlocksFree = MyData.id_NumBlocks - MyData.id_NumBlocksUsed;

	UnLock(MyLock);
	return(ulBlocksFree * MyData.id_BytesPerBlock / 1024);
}




/* Returns the amount of disk space we can likely give for the incoming message */
int SpaceFreeForMessage(char * szDirectory, int nMaxSize)
{
	int nSpaceUsedInDir, nSpaceFreeOnDisk, nReturn;

	/* no saving if the save directory isn't defined! */
	if (szMessageDir == NULL) 
	{
		DEBUG("SpaceFreeForMessage: No VoiceMailDir specified\n");
		return(0);	
	}

	/* no saving if we have an error reading the dir! */
	if ((nSpaceUsedInDir = SpaceUsedInDir(szDirectory)) < 0) 
	{
		DEBUG("SpaceFreeForMessage: SpaceUsedInDir() returned error\n");
		return(0);
	}
		
	/* initial estimate:  maxsize - sizeof(all files) */
	nReturn = nMaxSize - nSpaceUsedInDir;

	/* No space in directory, per user? */	
	if (nReturn <= 0) 
	{
		DEBUG("SpaceFreeForMessage: Directory full.\n");
		return(0);
	}
		
	/* chop that to the amount of free space on disk */
	nSpaceFreeOnDisk = FreeSpaceOnDisk(szDirectory);
	if (nReturn >= nSpaceFreeOnDisk) nReturn = nSpaceFreeOnDisk-1;

	/* chop that to the maximum message size */
	if (nReturn > nMaxMessageSize) nReturn = nMaxMessageSize;
	
	/* no bloody negative values either */
	if (nReturn < 0) 
	{
		DEBUG("SpaceFreeForMessage: Return was less than zero.\n");
		nReturn = 0;
	}
	
	return(nReturn);
}



/* Returns the sum of the filesizes of each file in a directory. */
/* returns -1 on error */
int SpaceUsedInDir(char * szDirectory)
{
	BPTR MyLock = Lock(szDirectory, ACCESS_READ);
	LONG ulBytesUsed = 0;
	BOOL BMore;
	struct ExAllControl * eac;
	struct ExAllData * ead;
	__aligned UBYTE EAData[sizeof(struct ExAllData)*30];
	
	if (MyLock == 0) 
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug, "SpaceUsedInDir: Lock of [%s] failed.\n",szDirectory); fflush(fpDebug);
		#endif
		return(-1);
	}
	
	eac = AllocDosObject(DOS_EXALLCONTROL,NULL);
	if (eac == NULL)
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug, "SpaceUsedInDir: AllocDosObject failed.\n"); fflush(fpDebug);
		#endif
		UnLock(MyLock);
		return(-1);	
	}
	
	eac->eac_LastKey = 0;	/* very important! */
	
	do 
	{
		BMore = ExAll(MyLock, (struct ExAllData *) EAData, sizeof(EAData), ED_SIZE, eac);
		if ((!BMore)&&(IoErr() != ERROR_NO_MORE_ENTRIES)) 
		{
			#ifdef DEBUG_FLAG
			fprintf(fpDebug, "SpaceUsedInDir: ExAll terminated abnormally.\n"); fflush(fpDebug);
			#endif
			break;
		}
		if (eac->eac_Entries == 0)
		{
			/* ExAll has no more entries? */
			continue;	/* more is *usually* zero */
		}
		
		ead = (struct ExAllData *) EAData;
		do {
			ulBytesUsed += ead->ed_Size;
			ead = ead->ed_Next;
		} while (ead);
	} while (BMore);
	
	FreeDosObject(DOS_EXALLCONTROL, eac);	
	UnLock(MyLock);
	return(ulBytesUsed / 1024);
}

/* Presents an EasyRequest() and */
/* returns one of the OPTION_ defines, depending on what the user chooses */
static int UserReceiveOption(BOOL BCanTakeMessage, char * szMessage)
{
	char szOptions[100] = "\0";
	char szTitle[100];	
	int nResults[4];
	int nNext = 1;
	
	/* We can do a two-way IFF we're not a Relay */
	UNLESS(BImARelay)
	{
		strcat(szOptions,"Receive & XMit|");
		nResults[nNext++] = OPTION_TWOWAY;
	}
	
	/* We can always just receive */
	strcat(szOptions,"Receive Only|");
	nResults[nNext++] = OPTION_LISTEN;

	/* We can take a message if the arg says so */
	if (BCanTakeMessage)
	{
		strcat(szOptions,"Take Message|");
		nResults[nNext++] = OPTION_TAKEMESSAGE;
	}

	/* And we can always deny */
	strcat(szOptions,"Deny");
	nResults[0] = OPTION_DENY;
	
	sprintf(szTitle,"AmiPhone Connection Request [Key %lu]",ulKeyCode);
	return(nResults[DMakeReq(szTitle, szMessage, szOptions)]);
}



/* a NULL == Do default info */
#define BLINK(x) (BBlink ? x : ' ')
void SetWindowTitle(char * szOptTitle)
{
	static char szIntWinTitle[100];
	static BOOL BBlink = FALSE;
	char cBlinkChar;
	
	if (MyInfo.BErrorR) cBlinkChar = 'X';
	else
	{
		switch(nQMode)
		{
			case QMODE_EMPTY: cBlinkChar = '+'; break;
			case QMODE_FLUSH: cBlinkChar = '-'; break;
		}
	}

	if (szOptTitle) Strncpy(szIntWinTitle, szOptTitle, sizeof(szIntWinTitle));
	else 
	{
		char szNum[20];

		sprintf(szNum,"%i.%is",nQLengthMS/1000,(nQLengthMS%1000)/100);
		sprintf(szIntWinTitle, "AmiPhoned:[%s] [%s] %c", szShortPeerName, szNum, BLINK(cBlinkChar));
	}

	if (AmiPhonedWindow) 
	{
		int nCheckWidth = TextLength(&AmiPhonedScreen->RastPort, szIntWinTitle, strlen(szIntWinTitle))+EXTRA_WINDOW_WIDTH;
		if (nCheckWidth > nWindowWidth)
		{
			SizeWindow(AmiPhonedWindow, (nCheckWidth-nWindowWidth)+3, 0);
			nWindowWidth = nCheckWidth+3;
		}
		SetWindowTitles(AmiPhonedWindow, szIntWinTitle, (char *) ~0);
	}
	
	/* Well, 'e won't clear it for us, so we gotta! */
	if (BNoClient == TRUE) MyInfo.BErrorR = FALSE;

	BBlink = Not[BBlink];
}


/* Returns the number of milliseconds this packet will take to play */
/* The packet must be already decompressed to get the right result. */
int PacketTime(struct AmiPhonePacketHeader * ubPacket)
{
	return((ubPacket->ulDataLen*1000)/ubPacket->ulBPS);
}



/* Main program */
int main(int argc, char ** argv)
{
#ifdef DEBUG_FLAG
	char szDebugWindowTitle[100];
#endif
	char szErrorMessage[80];
	char * szCurrentUser;
	struct Process * me;
	struct DaemonMessage * dm;
	char cTemp;
	const char szNoUDPPort[] = "Couldn't set up the UDP socket";

	atexit(CleanExit);

	/* make a note of what time it is now */
	tTimeConnected = time(NULL);

	if ((szCurrentUser = OpenLibraries(TRUE)) != NULL)
	{
		sprintf(szErrorMessage,"Couldn't open %s.library", szCurrentUser);
		EXIT(szErrorMessage,RETURN_ERROR);
	}

  	SetErrnoPtr(&errno, sizeof(errno));

#ifdef DEBUG_FLAG
	/* Setup debugging output window */
	sprintf(szDebugWindowTitle,"con:////AmiPhoned_Debug_Window");
	UNLESS (fpDebug = fopen(szDebugWindowTitle,"w")) EXIT("Couldn't open debugging console",RETURN_ERROR)
#endif

	/* Find our inner self */	
	me = (struct Process *) FindTask(NULL);	
	
	/* raise our priority */
	SetTaskPri((struct Task *)me, nPri);

	/* Get any relevant info from the AmiPhone icon */
	ParseArgs();

	/* no argument for nMaxMessageSize == same as nMaxVoiceMailDirSize */
	if (nMaxMessageSize < 0) nMaxMessageSize = nMaxVoiceMailDirSize;
	
	DEBUG("AmiPhone daemon starting\n")

	UNLESS (dm = (struct DaemonMessage *)me->pr_ExitData) EXIT("AmiPhoned may only be started by inetd",RETURN_ERROR)
	UNLESS (AcceptTCPSocket(dm))       EXIT("Accept socket failed", RETURN_OK)

	GetPhonePeerName(targethost, sizeof(targethost));
	sprintf(szErrorMessage, "AmiPhone %sconnection requested by\n[%s]",BImARelay?"relay ":"",targethost);

	UNLESS(SetupTCPQueue(CLIENT_TCP_QUEUE, TRUE)) EXIT("Couldn't setup TCP queue", RETURN_ERROR)
		
	#ifdef DEBUG_FLAG
	fprintf(fpDebug,"connection from [%s] (BNoReq = %i)\n",targethost,BNoReq);
	fflush(fpDebug);
	#endif

	/* Calculate maximum length the message can be */
	ulSignalMessageFree = SpaceFreeForMessage(szMessageDir, nMaxVoiceMailDirSize);	/* max value set by user for whole dir */
	ulByteTicker = 1024 * ulSignalMessageFree; 	/* and in bytes */

	#ifdef DEBUG_FLAG
	fprintf(fpDebug,"There are %i kbytes free for a message\n",ulSignalMessageFree); fflush(fpDebug);
	#endif

	if ((BNoReq)||(UserHere() == FALSE))
	{
		cTemp = PCREPLY_WILLLISTEN;
		if (UserHere() == FALSE) 
		{
			cTemp = (ulSignalMessageFree > 0) ? PCREPLY_LEAVEMESSAGE : PCREPLY_CANTLEAVEMESSAGE;
		}
		UNLESS(CreateUDPConnection(cTemp)) EXIT(szNoUDPPort,RETURN_ERROR)
	}
	else
	{
 		switch (UserReceiveOption((ulSignalMessageFree > 0), szErrorMessage))
 		{	
		 	case OPTION_DENY: 
		 		SendCommandPacket(PHONECOMMAND_DENY,0,0L);
		 		EXIT("Connection denied",RETURN_OK)
		 		break;
		 		
			case OPTION_TWOWAY: 
				LaunchXMitter(targethost); 
				UNLESS(CreateUDPConnection(PCREPLY_TWOWAY)) EXIT(szNoUDPPort,RETURN_ERROR)
				break;

			case OPTION_LISTEN:	
				BOpenWindow = TRUE;
				UNLESS(CreateUDPConnection(PCREPLY_WILLLISTEN)) EXIT(szNoUDPPort,RETURN_ERROR)
				break;
				
			case OPTION_TAKEMESSAGE:
				BOpenWindow |= BImARelay;
				UNLESS(CreateUDPConnection(PCREPLY_LEAVEMESSAGE)) EXIT(szNoUDPPort,RETURN_ERROR)
				break;
		}
	}

	if (AllocPacketList(TRUE) == FALSE) 
		EXIT("AllocPacketList failed",RETURN_ERROR);
				
	/* Set up our message for the local AmiPhone */
	SetUpLocalAmiPhoneInfo(&MyInfo);

	/* CTRL_C causes exit, CTRL_D causes break of Wait(), and thus re-read of info, CTRL_E causes window open/close */
	ulPhonedMask = (SIGBREAKF_CTRL_C|SIGBREAKF_CTRL_D|SIGBREAKF_CTRL_E);

	/* Second, if we haven't already notified the client of our info, tell him now */
	UNLESS(BLocalAmiPhoneNotified) BLocalAmiPhoneNotified = SendMessageToClient(MSG_CONTROL_HI);
	
	/* Open window, if necessary */
	if (BOpenWindow) OpenTitleBar(&ulPhonedMask);
		
	/* Let the client know if his version is out-of-date */
	if (BSendWarningBack) SendCommandPacket(PHONECOMMAND_VWARN,0,VERSION_NUMBER);

	/* Spend the rest of our life, waiting... how tragic */
	while (BDone == FALSE) PhonedWait(ulPhonedMask);
	EXIT("Client disconnected",RETURN_OK);
}
