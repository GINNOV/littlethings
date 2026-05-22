#include <stdio.h>
#include <string.h>

#include <exec/types.h>

#include <exec/lists.h>
#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <errno.h>
#include <inetd.h>
#include <sys/types.h>

#include <proto/socket.h>
#include <sys/errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/syslog.h>
#include <pragmas/socket_pragmas.h>

#include "AmiPhone.h"
#include "TCPQueue.h"

#define MEMORY_RESERVE 30000

extern LONG sTCPSocket;
extern ULONG ulBytesSentSince;

static struct List * TCPQueue[11] = {NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
static int nNumTCPPackets[11], nNumTCPBytes[11];

static struct Node * AllocTCPNode(UBYTE * pubData, ULONG ulDataLen);
static void FreeTCPNode(struct Node * node);

int TCPQueueLength(int nQNum)
{
	return(nNumTCPPackets[nQNum]);
}

int TCPQueueBytes(int nQNum)
{
	return(nNumTCPBytes[nQNum]);
}

/* Sends TCP data, or queues it, as necessary */
/* Returns the number of bytes actually sent over the line */
/* (Bytes queued will be accounted for later!) */
int AttemptTCPSend(LONG sSendSocket, int nQNum, UBYTE * data, ULONG ulDataLen)
{
	int nSendLen, nReduceSent = ReduceTCPQueue(nQNum, sSendSocket);
	
	if (TCPQueueLength(nQNum) == 0)
	{
		/* attempt immediate send */
		nSendLen = send(sSendSocket, data, ulDataLen, 0L);
		if (nSendLen < 0) 	/* unsuccessful send */
		{	
			QueueTCPData(nQNum, data, ulDataLen);
			return(nReduceSent);
		}
		/* successful send */
		if (nSendLen == ulDataLen) return(nSendLen+nReduceSent);

		/* partial send! */
		QueueTCPData(nQNum, data+nSendLen, ulDataLen-nSendLen);
		return(nSendLen+nReduceSent);
	}
	/* Other stuff queued... have to send that before we send this */
	QueueTCPData(nQNum, data, ulDataLen);
	return(nReduceSent);
}


/* Returns success or failure */
BOOL SetupTCPQueue(int nQNum, BOOL BSetup)
{
	if (BSetup == (TCPQueue[nQNum] != NULL)) return(FALSE);	

	if (BSetup)
	{
		UNLESS(TCPQueue[nQNum] = AllocMem(sizeof(struct List),MEMF_CLEAR)) return(FALSE);
		NewList(TCPQueue[nQNum]);
		nNumTCPPackets[nQNum] = 0;
		nNumTCPBytes[nQNum] = 0;
	}
	else
	{
		FlushTCPQueue(nQNum);
		FreeMem(TCPQueue[nQNum], sizeof(struct List));
		TCPQueue[nQNum] = NULL;
	}
	return(TRUE);
}


void FlushTCPQueue(int nQNum)
{
	struct Node * current;
	
	if (TCPQueue[nQNum])
	{
		while(current = RemHead(TCPQueue[nQNum])) FreeTCPNode(current);
		nNumTCPPackets[nQNum] = 0;
		nNumTCPBytes[nQNum] = 0;
	}
}


/* Copy given buffer and store it in our queue */
BOOL QueueTCPData(int nQNum, UBYTE * pubData, ULONG ulLen)
{
	struct Node * pNewNode;
	
	UNLESS(pNewNode = AllocTCPNode(pubData, ulLen)) return(FALSE);
	AddTail(TCPQueue[nQNum], pNewNode);
	nNumTCPPackets[nQNum]++;
	nNumTCPBytes[nQNum] += ulLen;
	return(TRUE);
}



/* Send as much data as we can */
/* Returns the number of bytes sent this time through */
int ReduceTCPQueue(int nQNum, LONG sSendSocket)
{
	struct Node * current, * partial;
	UBYTE * data;
	ULONG ulDataLen;
	int nSent, nReturn = 0;
		
	while(current = RemHead(TCPQueue[nQNum]))
	{
		memcpy(&ulDataLen, current->ln_Name, sizeof(ULONG));

		nNumTCPPackets[nQNum]--;
		nNumTCPBytes[nQNum] -= ulDataLen;
		
		data  = current->ln_Name + sizeof(ULONG);
		nSent = send(sSendSocket, data, ulDataLen, 0L);
		nReturn += (nSent > 0) ? nSent : 0;
		
		if (nSent >= ((int)ulDataLen))
		{
			/* All data sent--okay to get rid of this packet! */
			FreeTCPNode(current);
		}
		else if (nSent <= 0)
		{
			/* oops, we're all full--put this packet back */
			AddHead(TCPQueue[nQNum], current);
			nNumTCPPackets[nQNum]++;
			nNumTCPBytes[nQNum] += ulDataLen;
			return(nReturn);
		}
		else
		{
			/* only part of our data was sent.  Make a new 
			   packet containing the rest and re-queue it. */
			partial = AllocTCPNode(data+nSent, ulDataLen-nSent);
			FreeTCPNode(current);
			if (partial) 
			{
				AddHead(TCPQueue[nQNum], partial);
				nNumTCPPackets[nQNum]++;
				nNumTCPBytes[nQNum] += (ulDataLen-nSent);
			}
			else printf("TCPReduceQueue:  Error:  Couldn't allocate partial node for next send!\n");
			return(nReturn);
		}
	}
}



static struct Node * AllocTCPNode(UBYTE * pubData, ULONG ulDataLen)
{
	UBYTE * pubNewBuffer;
	struct Node * pNewNode;

	if (AvailMem(MEMF_ANY) < MEMORY_RESERVE) return(NULL);
	UNLESS(pNewNode = AllocMem(sizeof(struct Node), MEMF_CLEAR)) return(NULL);
	UNLESS(pubNewBuffer = AllocMem(ulDataLen+sizeof(ULONG), MEMF_ANY))
	{
		FreeMem(pNewNode, sizeof(struct Node));
		return(NULL);
	}
	pNewNode->ln_Name = pubNewBuffer;
	memcpy(pubNewBuffer, &ulDataLen, sizeof(ULONG));
	memcpy(pubNewBuffer+sizeof(ULONG), pubData, ulDataLen);
	return(pNewNode);
}



static void FreeTCPNode(struct Node * node)
{
	UBYTE * data = node->ln_Name;
	ULONG ulDataLen;
	
	memcpy(&ulDataLen, data, sizeof(ULONG));	
	FreeMem(data, ulDataLen + sizeof(ULONG));
	FreeMem(node, sizeof(struct Node));
}