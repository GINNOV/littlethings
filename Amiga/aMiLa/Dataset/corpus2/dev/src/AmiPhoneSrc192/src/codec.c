#ifndef CODEC_C
#define CODEC_C

/* codec.c : routines shared by AmiPhone AND AmiPhoned--govern audio
   	     compression, decompression, and playing */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/ports.h>
#include <devices/audio.h>
#include <libraries/dos.h>		/* contains RETURN_OK, RETURN_WARN #def's */
#include <graphics/gfxbase.h>		/* to determine if we are on a PAL or NTSC Amiga */

#include <clib/intuition_protos.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/socket_protos.h>

#include <pragmas/socket_pragmas.h>

#ifndef AMIPHONE
#include "AmiPhoned.h"
#else
#include "AmiPhone.h"
#endif

#include "AmiPhoneMsg.h"
#include "AmiPhonePacket.h"
#include "compress/ADPCM.h"
#include "codec.h"
#include "TCPQueue.h"

char szLastMemoFile[200];

#ifndef CONV_UTIL

extern struct Library * SocketBase;

/* These all need to be defined elsewhere in the code for AllocAudio to work. */
extern struct GfxBase * GfxBase;
extern struct MsgPort *port1, *port2;
extern struct IOAudio *AIOptr1, *AIOptr2;
extern ULONG SystemClock;
extern ULONG ulMilliSecondsTaken;

/* These go with AmiPhoned.h only */
#ifndef AMIPHONE
extern char * szMessageDir;
extern ULONG ulByteTicker;
extern FILE * fpDebug;
extern LONG sRelayTCPSocket[];
#endif

static ULONG ulBytesWritten = 0L;




/* Read and collect bytes from the TCP stream.  If there
   are enough to make a full packet, return a pointer to
   the packet, otherwise return NULL. */
struct AmiPhoneSendBuffer * GetTCPPacket(LONG sReceiveTCPSocket)
{
	static UBYTE ubData[sizeof(struct AmiPhoneSendBuffer)];
	static UBYTE * pubNext    = ubData;
	static int nLeftToRead    = sizeof(struct AmiPhonePacketHeader);
	static BOOL BGotHeader    = FALSE;
	int nBytesRead;
#ifndef AMIPHONE
	int i;
#endif

	/* If we're already good to go, don't read any more! */
	if (nLeftToRead == 0) 
	{
		BGotHeader  = FALSE;
		nLeftToRead = sizeof(struct AmiPhonePacketHeader);
		pubNext     = ubData;
		return(ubData);
	}
	
	/* Else grab as much as we can from the stream */
	nBytesRead = recv(sReceiveTCPSocket, pubNext, nLeftToRead, 0L);
	if (nBytesRead <= 0) return(NULL);  /* error == no data */

#ifndef AMIPHONE
	/* If we have any relay children, forward the data to them too. */
	for (i=0;i<10;i++)
		if (sRelayTCPSocket[i] != -1) AttemptTCPSend(sRelayTCPSocket[i], i, pubNext, nBytesRead);
#endif

	if (nBytesRead == nLeftToRead)
	{
		/* Okay, we got either the full header or the full data! */
		if (BGotHeader)
		{
			/* We already had the header, so now we must have the data too */
			/* Restart for the next time, and return the data */
			BGotHeader  = FALSE;
			nLeftToRead = sizeof(struct AmiPhonePacketHeader);
			pubNext     = ubData;
			
			return(ubData);
		}
		else
		{
			struct AmiPhonePacketHeader * pHead = (struct AmiPhonePacketHeader *) ubData;
			
			/* Okay, we just got the header.  Now setup to get the data. */
			BGotHeader  = TRUE;
			nLeftToRead = (int) pHead->ulDataLen;
			pubNext = ubData + sizeof(struct AmiPhonePacketHeader);
			
			if (nLeftToRead > (sizeof(ubData)-sizeof(struct AmiPhonePacketHeader)))
			{
				nLeftToRead = sizeof(ubData)-sizeof(struct AmiPhonePacketHeader);
			}
						
			/* Now try to read the rest if we can */
			return(GetTCPPacket(sReceiveTCPSocket));
		}
	}
	else
	{
		/* Got >0 bytes, but not all we needed.  Mark our place for next time. */
		nLeftToRead -= nBytesRead;
		pubNext     += nBytesRead;
		return(NULL);
	}
}







/* Give TRUE, allocates the audio hardware and inits info.  Give, FALSE,
   cleans up. */  
BOOL AllocAudio(BOOL BAlloc)
{
	int c;
	static ULONG device = 1L;
	static UBYTE chan1[]  = { 1 };		/* Audio channel allocation arrays */
	static UBYTE chan2[]  = { 2 };
	static UBYTE chan3[]  = { 4 };
	static UBYTE chan4[]  = { 8 };
	static UBYTE *chans[] = {chan1, chan2, chan3, chan4};
	
	if (BAlloc == TRUE)
	{
		/* ALLOCATE AUDIO HARDWARE */
	
		/* get PAL/NTSC clock constant set */
		if (GfxBase->DisplayFlags & PAL) SystemClock = 3546895L;	/* PAL */
				    	    else SystemClock = 3579545L;	/* NTSC */

		/* Make audio messages ?? */
		UNLESS (AIOptr1 = (struct IOAudio *) AllocMem(sizeof(struct IOAudio), MEMF_PUBLIC | MEMF_CLEAR)) return(FALSE);
		UNLESS (AIOptr2 = (struct IOAudio *) AllocMem(sizeof(struct IOAudio), MEMF_PUBLIC | MEMF_CLEAR)) return(FALSE);

		/* Create our audio ports */
		UNLESS (port1 = CreatePort(0,0)) return(FALSE);
		UNLESS (port2 = CreatePort(0,0)) return(FALSE);

		/* Grab the first free audio channel--OpenDevice returns 0 on success */
		c=0;
		while ((device)&&(c<4))
		{
			AIOptr1->ioa_Request.io_Message.mn_ReplyPort   = port1;
			AIOptr1->ioa_Request.io_Message.mn_Node.ln_Pri = 127;	/* Don't let anyone take it from us! */
			AIOptr1->ioa_AllocKey			       = 0;
			AIOptr1->ioa_Data			       = chans[c];
			AIOptr1->ioa_Length			       = 1;		/* Size of the allocation array--1 channel => 1 */

			device = OpenDevice(AUDIONAME, 0L, (struct IORequest *) AIOptr1, 0L);
			c++;
		}
	
		/* device != 0 then we never got a channel */
		if (device) return(FALSE);

		
		/* Set up Audio IO Blocks for Sample Playing */
		AIOptr1->ioa_Request.io_Command	= CMD_WRITE;
		AIOptr1->ioa_Request.io_Flags	= ADIOF_PERVOL;
		
		/* High volume */
		AIOptr1->ioa_Volume = 60;
	
		/* Set cycles */
		AIOptr1->ioa_Cycles = 1;
	
		*AIOptr2 = *AIOptr1;	/* Make sure we have the same allocation keys */
					/* same channels selected and same flags (but */
					/* different ports...) */

		/* Here's where we differentiate--which signal the reply will buzz */
		AIOptr1->ioa_Request.io_Message.mn_ReplyPort = port1;
		AIOptr2->ioa_Request.io_Message.mn_ReplyPort = port2;
	
		/* THESE pointers point to the beginning of your samples! */
		AIOptr1->ioa_Data = NULL;
		AIOptr2->ioa_Data = NULL;
	
		/* These values are the length of the samples! */
		AIOptr1->ioa_Length = 0L;
		AIOptr2->ioa_Length = 0L;
	}
	else
	{
		/* FREE AUDIO HARDWARE */
		if (device == 0) {CloseDevice((struct IORequest *)AIOptr1); device = 1;} 
		if (port1)	 {DeletePort(port1); port1 = NULL;}
		if (port2)	 {DeletePort(port2); port2 = NULL;}
		if (AIOptr1)	 {FreeMem(AIOptr1, sizeof(struct IOAudio)); AIOptr1 = NULL;}
		if (AIOptr2)	 {FreeMem(AIOptr2, sizeof(struct IOAudio)); AIOptr2 = NULL;}
	}
	return(TRUE);
};


#endif	/* CONV_UTIL */

/* Only use this if we're compiling for the client! */
#ifdef AMIPHONE
ULONG CompressData(UBYTE * ubIn, UBYTE * ubOut, UBYTE bCompType, ULONG ulInBytes, ULONG * pulUpdateJoinCode)
{
	switch(bCompType)
	{
		case COMPRESS_NONE:
			memcpy(ubOut,ubIn,ulInBytes);
			return(ulInBytes);
			break;
			
		case COMPRESS_ADPCM2:
			*pulUpdateJoinCode = CompressADPCM2(ubIn, ulInBytes, ubOut, *pulUpdateJoinCode);
			return((ulInBytes+3)/4);
			break;

		case COMPRESS_ADPCM3:
			*pulUpdateJoinCode = CompressADPCM3(ubIn, ulInBytes, ubOut, *pulUpdateJoinCode);
			return((ulInBytes+7)/8*3);
			break;
	
		default:
			printf("Unknown compression method %i.\n",bCompType);
			return(1L);
			break;
	}
}
#endif

/* Returns the number of bytes decompressed to ubOut */
ULONG DecompressData(UBYTE * ubIn, UBYTE * ubOut, UBYTE ubCompMode, ULONG ulLen, ULONG ulJoinCode)
{
	switch(ubCompMode)
	{
		case COMPRESS_NONE:
			memcpy(ubOut, ubIn, ulLen);
			return(ulLen);
			break;

		case COMPRESS_ADPCM2: 
			(void) DecompressADPCM2(ubIn, ulLen, ubOut, ulJoinCode);
			return(ulLen*4);		
			break;  
			
		case COMPRESS_ADPCM3: 
			(void) DecompressADPCM3(ubIn, ulLen, ubOut, ulJoinCode);
			return(ulLen*8/3);
			break; 
			
		default:	
			#ifndef AMIPHONE
			 #ifdef DEBUG_FLAG
			  fprintf(fpDebug,"DecompressData: unknown mode %i\n",ubCompMode);
			 #endif
			#endif
			return(0);
	}
}


#ifndef CONV_UTIL

/* Returns TRUE if a VWARN packet should be sent, FALSE if not. */
BOOL CheckVersions(char * szRemoteSoftwareName, ULONG ulRemoteVersionNumber, BOOL BOkToShowReq)
{
	char szBuf[500];
	ULONG ulRemoteMajor = ulRemoteVersionNumber/10;
	ULONG ulLocalMajor  = VERSION_NUMBER/10;
	
	if (ulRemoteMajor == ulLocalMajor) 
	{
		return(FALSE);
	}
	else if ((ulRemoteMajor < 17)||(ulRemoteMajor > 100))
    	{
 	    	sprintf(szBuf,"Warning:  The %s you are\nconnected to is using a pre-v1.7\nversion of AmiPhone.  To minimize\ncompatibility problems, you should\ntell your party to upgrade to the\nlatest version of AmiPhone.",
 	     		    szRemoteSoftwareName);
	}
	else if (ulRemoteMajor < ulLocalMajor) 
	{
		return(TRUE);
	}
	else sprintf(szBuf,"Warning:  The %s you are\nconnected to is using AmiPhone\nversion %i.%i.  To minimize compatibility\nproblems, you should upgrade your\nAmiPhone software to that version.",szRemoteSoftwareName,ulRemoteVersionNumber/100,ulRemoteVersionNumber%100);
	
	if (BOkToShowReq) 
	{
		#ifdef AMIPHONE
		MakeReq("AmiPhone Version Warning", szBuf, NULL);
		#else
		DMakeReq("AmiPhoned Version Warning", szBuf, NULL);
		#endif
	}
	return(FALSE);
}


void PrintPacketHeader(FILE * fpOut, struct AmiPhonePacketHeader * header)
{
	fprintf(fpOut,"Command = %c\n",header->ubCommand);
	fprintf(fpOut,"Type    = %i\n",header->ubType);
	fprintf(fpOut,"Seqnum  = %d\n",header->lSeqNum);
	fprintf(fpOut,"Dta/BPS = %d\n",header->ulBPS);
	fprintf(fpOut,"DataLen = %d\n",header->ulDataLen);	
	fprintf(fpOut,"JoinCode= %d\n",header->ulJoinCode);	
	fflush(fpOut);
}


FILE * OpenMessageFile(time_t tTime, char * szMessageDir)
{
	char szFileName[500];
	
	/* generate filename */
	UNLESS(GetMessageFileName(tTime, szMessageDir, szFileName,sizeof(szFileName))) return(NULL);
	Strncpy(szLastMemoFile, szFileName, sizeof(szLastMemoFile));
	return(fopen(szFileName,"ab"));
}

void RemoveMessageFile(time_t tTime, char * szMessageDir)
{
	char szFileName[500];
	
	/* generate filename */
	UNLESS(GetMessageFileName(tTime, szMessageDir, szFileName,sizeof(szFileName))) return;
	
	remove(szFileName);
}


/* Generate a succinct timestamp */
char * TimeStamp(time_t * optTime)
{
	static char szReturn[36];
	const char * szDays[] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
	struct tm * time_tm = localtime(optTime);
	
	sprintf(szReturn,"%02d:%02d:%02d on %s %02d/%02d/%02d",
		time_tm->tm_hour,
		time_tm->tm_min,
		time_tm->tm_sec,
		szDays[time_tm->tm_wday],
		time_tm->tm_mon+1,
		time_tm->tm_mday,
		time_tm->tm_year);
		
	return(szReturn);
}

/* resets the bytes written counter.  Returns TRUE if
   the counter was non-zero, else FALSE */
BOOL ResetByteCounter(void)
{
	BOOL BRet = (ulBytesWritten > 0);

	ulBytesWritten = 0L;	
	return(BRet);
}

/* save the given packet to file fpOutFile. */
void SavePacket(struct AmiPhonePacketHeader * packet, FILE * fpOutFile)
{
	static char ulMagicWord[] = "APHN";
	ULONG ulPacketSize;

#ifndef AMIPHONE
	ULONG ulDiskBytesFree = FreeSpaceOnDisk(szMessageDir) * 1024;
	
	/* cut us down if the disk free gets lower than our count makes it
	   out to be... this could happen if someone else saves a file for instance */
	if (ulByteTicker >= ulDiskBytesFree) 
	{
		#ifdef DEBUG_FLAG
		fprintf(fpDebug,"SavePacket: Uh-oh, only %i kbytes of disk space left!\n",ulDiskBytesFree);
		fflush(fpDebug);
		#endif
		
		ulByteTicker = ulDiskBytesFree;
	}
#endif

	if ((packet == NULL)||(fpOutFile == NULL)) 
	{
		#ifndef AMIPHONE
		EXIT("Couldn't write packet to disk",RETURN_OK)
		#else
		return;
		#endif
	}

	ulPacketSize = packet->ulDataLen + sizeof(struct AmiPhonePacketHeader);

#ifndef AMIPHONE
	/* are we full up? */
	if (ulByteTicker < ulPacketSize) EXIT("Message length limit reached or Disk full",RETURN_OK)
#endif

	/* Write header? */
	if (ulBytesWritten == 0L) 
	{
		#ifndef AMIPHONE
		ulByteTicker -= 
		#endif
		fwrite(ulMagicWord,4,1,fpOutFile);
	}
	if (fwrite(packet, 1, ulPacketSize, fpOutFile) < ulPacketSize) 
	{
		#ifndef AMIPHONE
		EXIT("Couldn't write packet to disk", RETURN_OK)
		#else
		printf("SavePacket:  Error, couldn't write packet to disk.\n");
		return;
		#endif
	}

	ulBytesWritten += ulPacketSize;
	ulMilliSecondsTaken += MilliSecondDuration(packet);
#ifndef AMIPHONE
	ulByteTicker -= ulPacketSize;
#endif
}


/* returns the duration, in milliseconds, that the packet will play for */
ULONG MilliSecondDuration(struct AmiPhonePacketHeader * packet)
{
	ULONG ulBytesOfSound = packet->ulDataLen;

	/* Now multiply by 1000 so we get milliseconds below*/
	ulBytesOfSound *= 1000;
		
	/* Figure how many bytes we'll have when uncompressed */
	switch(packet->ubType)
	{
		case COMPRESS_ADPCM2: ulBytesOfSound *= 4;     break;
		case COMPRESS_ADPCM3: ulBytesOfSound *= (8/3); break;
	}
	
	/* Now divide by the bytes per second to get the millseconds */
	ulBytesOfSound /= (packet->ulBPS ? packet->ulBPS : 1);
	
	return(ulBytesOfSound);
}


/* set a file note if we can. Note that the file must already have
   been closed...  */
void SetMessageNote(time_t tStartTime, char * szFrom, char * szMessageDir, ULONG ulSecondsTaken)
{
	char szBuf[500], szBuf2[120];
		
	if (GetMessageFileName(tStartTime, szMessageDir, szBuf, sizeof(szBuf)))
	{
		sprintf(szBuf2,"N %-25.25s%3u sec%s at %s", 
			szFrom, ulSecondsTaken, (ulSecondsTaken == 1) ? " " : "s", TimeStamp(&tStartTime));
		SetComment(szBuf, szBuf2);
	}
}


/* Copies the file to save to into szBuf, and returns TRUE on success,
   FALSE on failure. */
BOOL GetMessageFileName(time_t tTime, char * szMessageDir, char *szBuf, int nBufLength)
{
	char szBuf2[50];

	if (szMessageDir == NULL) return(FALSE);

	/* start with our path */
	strncpy(szBuf, szMessageDir, nBufLength);
	
	/* and we'll need a filename */
	sprintf(szBuf2, "AmiPhoneMessage.%u", tTime);
	
	/* Add them together... */
	UNLESS(AddPart(szBuf, szBuf2, nBufLength)) return(FALSE);

	return(TRUE);
}


#endif /* CONV_UTIL */

/* Just like strncpy, only it will guarantee that the string
   will be terminated */
char * Strncpy(char * s1, char * s2, int n)
{
	strncpy(s1,s2,n);
	s1[n-1]='\0';
	return(s1);
}


#endif
