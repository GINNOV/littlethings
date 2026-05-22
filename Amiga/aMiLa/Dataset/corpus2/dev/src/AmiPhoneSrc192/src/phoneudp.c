#define DICE_C

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <time.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>			/* contains RETURN_OK, RETURN_WARN #def's */
#include <dos/dosextens.h>
#include <dos/var.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>

#include <intuition/intuition.h>

#include <graphics/gfxbase.h>
#include <proto/socket.h>
#include <sys/errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/syslog.h>
#include <netdb.h>
#include <amitcp/socketbasetags.h>

#include <pragmas/socket_pragmas.h>
#include <inetd.h>

#include "AmiPhone.h"
#include "AmiPhoneMsg.h"
#include "StringRequest.h"
#include "codec.h"
#include "phoneudp.h"
#include "TCPQueue.h"

/* Why does this come out as 18 unless I define it explicitely here?  Weird! */
#define EWOULDBLOCK 35

/* Prototypes for the compression/decompression asm functions! */
/* extern __asm ULONG CompressADPCM2(
	register __a0 UBYTE *Source, register __d0 ULONG Length,
	register __a1 UBYTE *Destination, register __d1 ULONG JoinCode);

extern __asm ULONG CompressADPCM3(
	register __a0 UBYTE *Source, register __d0 ULONG Length,
	register __a1 UBYTE *Destination,register __d1 ULONG JoinCode);
*/

extern FILE * fpMemo;

static struct sockaddr_in saTCPPeerAddress;
static struct sockaddr_in saUDPPeerAddress;
static struct hostent *hp;
static struct servent *sp;
static LONG lDataSeqNum = 1;

extern BOOL BNetConnect;
extern BOOL BTransmitting;
extern BOOL BTCPBatchXmit;
extern ULONG ulKeyCode;
extern ULONG ulBytesSentSince;
extern struct AmiPhoneGraphicsInfo GraphInfo;
extern struct MsgPort *PhonePort;
extern struct Window * PhoneWindow;
extern struct Screen * Scr;


LONG   sTCPSocket=-1;
static LONG   sUDPSocket=-1;
static USHORT port;

int ClosePhoneSocket(void)
{
	struct sockaddr_in saBadAddress;
	
	saBadAddress.sin_family = AF_UNSPEC;
	
	FlushTCPQueue(0);
	
        UNLESS(SocketBase)return(FALSE);

	/* If we're not recording a memo, there's no reason to use the mic */
	if (fpMemo == NULL) ToggleMicButton(CODE_OFF);

	if (sUDPSocket != -1)
	{
		connect(sUDPSocket,&saBadAddress, sizeof(saBadAddress));
		CloseSocket(sUDPSocket); 
		sUDPSocket = -1;
	}

	if (sTCPSocket != -1) 
	{
		if (BNetConnect == TRUE) SendCommandPacket(PHONECOMMAND_DISCONNECT, 0, 0L);	
		CloseSocket(sTCPSocket); 
		sTCPSocket = -1;
	}

	/* Tell our peer we're outta here */
	BNetConnect = FALSE;		
	
	SetWindowTitle("Connection closed.");			
	SetMenuValues();
	return(TRUE);
}


void ChangeConnectPort(int nPortNum)
{
	int nSuccess;
	
	saUDPPeerAddress.sin_port = htons(nPortNum);
	nSuccess = connect(sUDPSocket, (struct sockaddr *) &saUDPPeerAddress, sizeof(saUDPPeerAddress));
	if (nSuccess < 0) printf("ChangeConnectPort: warning, connect failed: errno=%i\n",errno);
}

BOOL SetAsyncMode(BOOL BAsynch, LONG sSocket)
{
	LONG lNonBlockCode = BAsynch;
	
	if (IoctlSocket(sSocket, FIONBIO, (char *)&lNonBlockCode) < 0) return(FALSE);
	return(TRUE);
}



/* Now connects initially with a TCP socket.  This allows us to
   easily and reliably send commands. When we get a reply, we'll 
   create a udp socket to send the actual data with. */
int ConnectPhoneSocket(BOOL BShowRequester, char * szPeerName)
{
	int nSuccess;
	char sBuffer[MAXPEERNAMELENGTH+30], *sTemp = sBuffer;   
	char szTemp[20];
	ULONG sec, mic;
	BOOL BGenerateKey = (ulKeyCode == 0L);
	static char szPortName[100];
	const char szConnectionType[] = "tcp";
	
	UNLESS(SocketBase) return(FALSE);
	
	Strncpy(sBuffer,szPeerName,MAXPEERNAMELENGTH);	
	
	if ((BShowRequester == TRUE) && (GetUserString(Scr, PhoneWindow, sBuffer,"AmiPhone Connect","Enter Name of Remote Amiga",MAXPEERNAMELENGTH) == FALSE))
	{
		SetWindowTitle("Connect cancelled.");	
		return(FALSE);
	}
	
	/* If the user tries to put in a user account name, ignore it. */
	if (strchr(sBuffer,'@') != NULL) sTemp = strchr(sBuffer,'@')+1;

	Strncpy(szPeerName, sTemp, MAXPEERNAMELENGTH);
	LowerCase(szPeerName);

	if (strlen(szPeerName) == 0)
	{
		SetWindowTitle("Connect cancelled.");
		return(FALSE);
	}

	if (strcmp(szPeerName,"localhost") == 0)
	{
		if (gethostname(szPeerName,MAXPEERNAMELENGTH) < 0) 
		{
			SetWindowTitle("localhost's name is unavailable.");
			return(FALSE);
		}
	}
		
	sprintf(sBuffer,"Looking up %s",szPeerName);
	SetWindowTitle(sBuffer);
	
    	SetErrnoPtr(&errno, sizeof(errno));
	
			sp = getservbyname("AmiPhone",szConnectionType);
	if (sp == NULL) sp = getservbyname("Amiphone",szConnectionType);	/* Try almost all lowercase then! */	
	if (sp == NULL) sp = getservbyname("amiPhone",szConnectionType);	/* Try almost all lowercase then! */	
	if (sp == NULL) sp = getservbyname("amiphone",szConnectionType);	/* Try all lowercase then! */	
	if (sp == NULL)
	{
		MakeReq(NULL,"Couldn't find tcp service entry for AmiPhone!","Better go check amitcp:db/services");
		SetWindowTitle("Connect Failed.");
		return(FALSE);
	}
	port = sp->s_port;

	hp = gethostbyname(szPeerName);
	if (hp == NULL)
	{
		SetWindowTitle("Name lookup failed.");
		return(FALSE);
	}

	bzero(&saTCPPeerAddress, sizeof(saTCPPeerAddress));
	bzero(&saUDPPeerAddress, sizeof(saUDPPeerAddress));
	
    	bcopy(hp->h_addr, (char *)&saTCPPeerAddress.sin_addr, hp->h_length);
    	bcopy(hp->h_addr, (char *)&saUDPPeerAddress.sin_addr, hp->h_length);
    	
	saTCPPeerAddress.sin_family = hp->h_addrtype;
	saUDPPeerAddress.sin_family = hp->h_addrtype;
	
	saTCPPeerAddress.sin_port   = htons(port);	
	/* UDP port will be set later, in ChangeConnectPort() */
	
	if ((sUDPSocket = socket(hp->h_addrtype,SOCK_DGRAM,0)) < 0)
	{
		SetWindowTitle("Connect Failed. (Couldn't get UDP socket)");
		return(FALSE);
	}
	if ((sTCPSocket = socket(hp->h_addrtype,SOCK_STREAM,0)) < 0)
	{
		SetWindowTitle("Connect Failed. (Couldn't get TCP socket)");
		return(FALSE);
	}
		
	sprintf(sBuffer,"Connecting to %s",szPeerName);
	SetWindowTitle(sBuffer);
	nSuccess = connect(sTCPSocket, (struct sockaddr *) &saTCPPeerAddress, sizeof(saTCPPeerAddress));
	if (nSuccess < 0)
	{
		SetWindowTitle("Connect Failed.");
		return(FALSE);
	}

	SetAsyncMode(TRUE, sTCPSocket);

	/* If we already have a key, send it, else generate one at random */
	if (BGenerateKey == TRUE)
	{
		/* seed the randomizer */
		CurrentTime(&sec, &mic);
		srand(mic);

		/* get a random keyvalue */
		ulKeyCode = rand();
		
		/* Don't let it be zero though */
		if (ulKeyCode == 0L) ulKeyCode++;
	}

	BNetConnect = TRUE;	/* must be before SendCommandPacket(), so send isn't suppressed! */
	if (SendCommandPacket(PHONECOMMAND_CONNECT, 0, ulKeyCode) == FALSE)
	{
		BNetConnect = FALSE;
		SetWindowTitle("Couldn't send connect info");
		return(FALSE);
	}
	
	/* and since we might have a return call, use a port name AmiPhoned can find */
	sprintf(szTemp,"%d",ulKeyCode);

	/* Open a local messaage port as something AmiPhoned can find */
	sprintf(szPortName,"AmiPhone_%ld",ulKeyCode);
		
	/* Setup message port for talking to AmiPhoned */
	PhonePort->mp_Node.ln_Name = szPortName;
	PhonePort->mp_Node.ln_Pri  = 3;
	AddPhonePort(TRUE);
	
	return(TRUE);
}



/* This function sends the given packet header over the TCP link.  */
BOOL SendCommandPacket(UBYTE ubCommand, UBYTE ubType, ULONG ulData)
{
	struct AmiPhonePacketHeader AmiPack;
	
	/* Don't send anything if there's no AmiTCP! */
	UNLESS(SocketBase&&BNetConnect) return(FALSE);
	
	AmiPack.ubCommand = ubCommand;
	AmiPack.ubType	  = ubType;
	AmiPack.ulBPS	  = ulData;
	AmiPack.lSeqNum   = -1;
	AmiPack.ulDataLen = 0L;

	/* if we're beginning a new session, reset packet sequence number */
	if (ubCommand == PHONECOMMAND_CONNECT) {lDataSeqNum = 1L; AmiPack.ulJoinCode = VERSION_NUMBER;}

	ulBytesSentSince += AttemptTCPSend(sTCPSocket, 0, (UBYTE *) &AmiPack, sizeof(struct AmiPhonePacketHeader));
	return(TRUE);
}




/* Send a packet consisting of the given header, plus ulLen bytes
   that are located after it. */
/* Sending it a null pPack will only increase the Data sequencing number */
BOOL SendPacket(struct AmiPhoneSendBuffer * pPack, BOOL BUseTCP)
{
	ULONG lSendLen;
	int nBytesSent;
	
	if (pPack == NULL) 
	{
		lDataSeqNum++;
		return;
	}

	lSendLen = pPack->header.ulDataLen + sizeof(struct AmiPhonePacketHeader);
	
	if ((fpMemo == NULL)&&((BNetConnect == FALSE)||(SocketBase == NULL))) return(FALSE);
	
	/* keep a counter to ensure orderly playing of data */
	pPack->header.lSeqNum = lDataSeqNum++;

	if ((SocketBase)&&(BNetConnect))
	{
		if (BUseTCP) nBytesSent = AttemptTCPSend(sTCPSocket, 0, (UBYTE *)pPack, lSendLen);
			else nBytesSent = send(sUDPSocket, (UBYTE *)pPack, lSendLen, 0L);
		SetWindowTitle(NULL);
	}
	else nBytesSent = lSendLen;	/* Only going to disk--fake okay send */

	ulBytesSentSince += ((nBytesSent > 0) ? nBytesSent : 0);

	/* If we're recording a memo, save the data to disk too */
	if ((pPack->header.ubCommand == PHONECOMMAND_DATA)&&(fpMemo != NULL)) SavePacket(&pPack->header, fpMemo);

	/* If all of our bytes weren't sent, this will cause the 
	   scrolling graph to indicate as such.  */
	if (nBytesSent < 0)
	{
		GraphInfo.BErrorS |= TRUE;
		return(FALSE);
	}	 	
	return(TRUE);
}


ULONG PhoneWait(ULONG Mask)
{
	static struct fd_set fsReadSet, fsWriteSet;
	int nMaxSocket = -1;
	
	if (sTCPSocket > nMaxSocket) nMaxSocket = sTCPSocket;
	if (sUDPSocket > nMaxSocket) nMaxSocket = sUDPSocket;
	
	if (SocketBase)
	{
		FD_ZERO(&fsReadSet);  			/* Initialize socket read set */
		FD_ZERO(&fsWriteSet);
		
		if (sTCPSocket != -1) 
		{
			FD_SET(sTCPSocket, &fsReadSet);
			if (TCPQueueLength(0) > 0) FD_SET(sTCPSocket, &fsWriteSet);
		}
	
		WaitSelect(nMaxSocket+1, &fsReadSet, &fsWriteSet, NULL, NULL, &Mask);
			
		if (FD_ISSET(sTCPSocket, &fsReadSet)) ProcessReply();
		if (FD_ISSET(sTCPSocket, &fsWriteSet)) 
		{
			ulBytesSentSince += ReduceTCPQueue(0,sTCPSocket);
			SetWindowTitle(NULL);
		}
		
		return(Mask);
	}
	else return(Wait(Mask));
}