/* AmiPhone!  by Jeremy Friesner - jfriesne@ucsd.edu */

#define INTUI_V36_NAMES_ONLY

#include <stdio.h>
#include <stdlib.h> 
#include <string.h>

#include <dos/dos.h>
#include <dos/dostags.h>
#include <devices/audio.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <intuition/gadgetclass.h>
#include <intuition/screens.h>
#include <libraries/gadtools.h>
#include <dos/dosextens.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/io.h>
#include <exec/libraries.h>
#include <libraries/dos.h>			/* contains RETURN_OK, RETURN_WARN #def's */
#include <graphics/gfxbase.h>
#include <libraries/gadtools.h>
#include <libraries/iffparse.h>
#include <sys/types.h>

#include <errno.h>
#include <inetd.h>

#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/iffparse_protos.h>

#include "toccata/include/libraries/toccata.h"
#include "toccata/include/clib/toccata_protos.h"
#include "toccata/include/pragmas/toccata_pragmas.h"

#include "AmiPhone.h"
#include "AmiPhonePacket.h"
#include "asl.h"
#include "codec.h"
#include "messages.h"
#include "browse.h"

#define MAGIC_WORD "APHN"
#define PLAYBUFSIZE (MAXTRANSBUFSIZE*4)

#define AMIPHONE_FILE_RATE  -1
#define UNKNOWN_FILE_RATE    0

/* `VHDR' header format. */
struct Voice8Header
{
        ULONG   oneShotHiSamples,       /* # samples in the high octave 1-shot part */
                repeatHiSamples,        /* # samples in the high octave repeat part */
                samplesPerHiCycle;      /* # samples/cycle in high octave, else 0 */
        UWORD   samplesPerSec;          /* data sampling rate */
        UBYTE   ctOctave,               /* # of octaves of waveforms */
                sCompression;           /* data compression technique used */
        LONG    volume;                 /* playback nominal volume from 0 to Unity
                                         * (full volume). Map this value into
                                         * the output hardware's dynamic range.
                                         */
};


/* private functions */
static int LoadBuffer(struct MsgPort * STReplyPort, UBYTE * pBuf, int nBufNum, UBYTE * pubPlayBuf, struct AmiPhonePacketHeader * pHeader, FILE * fpIn, struct IFFHandle * Handle);
static BOOL PlayBuffer(int nAudioNum, UBYTE * pubData, struct AmiPhonePacketHeader * pHeader);
static struct IFFHandle * Init8SVXLoad(char * szFileName);

extern UBYTE ubCurrComp;
extern ULONG ulSampleArraySize;
extern ULONG ulBytesPerSecond;

/* vars used by AllocAudio, etc. */
extern struct GfxBase * GfxBase;
struct MsgPort *port1, *port2;
struct IOAudio *AIOptr1=NULL, *AIOptr2=NULL;
extern struct Task * MainTask;
extern BOOL BNetConnect, BXmitOnPlay;
extern struct MsgPort * SoundTaskPort;
extern char szVoiceMailDir[];

ULONG SystemClock;
struct AmiPhonePacketHeader * TransferPacket;

__geta4 void SoundPlayerMain(void);

/* private vars */
static char * szDefDir = NULL;
static char * szFileToPlay = NULL;
struct Library * AslBase = NULL; 

/* IFF parsing state */
struct Library * IFFParseBase 			= NULL; 
static int nPlaybackRate;

/* Should only be called by AmiPhone.c! */
/* That we can make sure only one is running at one time */
struct Task * LaunchPlayer(char * szFile)
{
	int nLen = strlen(szFile)+1;
	struct Task * player;
	
	if (szFileToPlay != NULL) 
	{
		printf("LaunchPlayer(): Error--szFileToPlay in use!\n");
		return(NULL);	/* panic--someone else is playing?? */
	}
	
	UNLESS(szFileToPlay = AllocMem(nLen, MEMF_ANY)) return(NULL);
	Strncpy(szFileToPlay,szFile,nLen);

	UNLESS(player = CreateNewProcTags(
		NP_Entry,	SoundPlayerMain,
		NP_Name,	"AmiPhone Message Player",
		NP_Priority,	0,
		NP_Output,	stdout,
		NP_CloseOutput, FALSE,
		NP_Cli,		TRUE,
		TAG_END)) 
	{
		printf("LaunchPlayer failed.\n");
		FreeMem(szFileToPlay,nLen);
		szFileToPlay = NULL;	
	}
	return(player);
}



/* This tasks opens a file requester and if a file is selected, sends
   a MESSAGE_PLAY_FILE to the SoundPort. */
__geta4 void FileReqMain(void)
{
	char szFile[300];
	struct MsgPort * FileReplyPort;
	static BOOL BFirstTime = TRUE;
		
	AslBase = OpenLibrary("asl.library",37L);
	if (FileReplyPort = CreatePort(0,0))
	{
		/* REQUEST A FILE--ONLY ALLOW ONE OF THESE REQUESTERS OPEN AT ONCE! */
		if ((AslBase)&&(FileRequest("Select a sound file to play", szFile, NULL, BFirstTime ? szVoiceMailDir : NULL, NULL, FALSE)))
		{
			StopPlayer(FileReplyPort);
			SendPlayerMessage(MESSAGE_CONTROLMAIN_PLAYFILE, (void *)szFile, 0L, FileReplyPort);
			BFirstTime = FALSE;
		}

		/* Get main to reenable our menu option */
		SendPlayerMessage(MESSAGE_CONTROLMAIN_REQCLOSED, NULL, 0L, FileReplyPort);

		/* Remove the port */
		RemovePortSafely(FileReplyPort);
	}
	if (AslBase) {CloseLibrary(AslBase); AslBase = NULL;}
}




void RemovePortSafely(struct MsgPort * RemoveMe)
{
	Forbid();
	while(GetMsg(RemoveMe)) {}
	DeletePort(RemoveMe);
	Permit();
}

struct Task * LaunchFileReq(char * szDir)
{
	return(CreateNewProcTags(
		NP_Entry,	FileReqMain,
		NP_Name,	"AmiPhone File Requester",
		NP_Priority,	0,
		NP_Output,	stdout,
		NP_CloseOutput, FALSE,
		NP_Arguments,   szDir,
		NP_Cli,		TRUE,
		TAG_END));
}




/* Play a file in the given format.  This function will start a new
   process to play the given sound, and may be stopped by sending it
   a control-C or a MESSAGE_DIE */
__geta4 void SoundPlayerMain(void)
{
	char szBuf[5] = "\0\0\0\0\0";
	UBYTE * playbuf1 = NULL, * playbuf2 = NULL, * pSendBuf = NULL;
	BOOL BDone = FALSE, BAudioAlloced = FALSE;
	struct AmiPhonePacketHeader header1, header2;
	int nBufNum = 1, nErrors = 0;
	FILE * fpIn;
	ULONG ulWaitMask = 0L, signals;
	struct MsgPort *SoundTaskReplyPort = NULL;
	struct IFFHandle *Handle = NULL;

	/* default = raw file */
	nPlaybackRate = UNKNOWN_FILE_RATE;
	
	UNLESS(szFileToPlay) goto Cleanup;
	UNLESS(SoundTaskReplyPort = CreatePort(0,0)) 
	{
		printf("ERROR: Couldn't open Browser reply port!\n");
		goto Cleanup;
	}
	
	if (SetSignal(0L,0L) & SIGBREAKF_CTRL_C) goto Cleanup;
	
	UNLESS(fpIn = fopen(szFileToPlay,"rb"))
	{
		printf("PlayFile:  couldn't open file [%s]\n",szFileToPlay);
		goto Cleanup;
	}
	fread(szBuf,4,1,fpIn);
	if (strncmp(szBuf,MAGIC_WORD,4) == 0) nPlaybackRate = AMIPHONE_FILE_RATE;
	else
	{
		fclose(fpIn); fpIn = NULL;
		UNLESS(Handle = Init8SVXLoad(szFileToPlay)) 
		{
			/* last resort--reopen file as raw audio and play
			   back at the current sampling rate. */
			nPlaybackRate = UNKNOWN_FILE_RATE;
			UNLESS(fpIn = fopen(szFileToPlay,"rb")) goto Cleanup;
		}
	}
	UNLESS(BAudioAlloced = AllocAudio(TRUE))
	{
		printf("PlayFile: couldn't Allocate Audio channel\n");
		goto Cleanup;
	}
	/* Autoallocate initial load area if needed */
	UNLESS(pSendBuf = AllocMem(sizeof(struct AmiPhoneSendBuffer), MEMF_ANY))
	{
		printf("SoundPlayer:  Couldn't allocate load space\n");
		goto Cleanup;
	}	
	/* allocate playing buffers */
	playbuf1 = AllocMem(PLAYBUFSIZE, MEMF_CHIP|MEMF_CLEAR);
	if (playbuf1 == NULL)
	{
		printf("PlayFile:  couldn't allocate buffer 1\n");		
		goto Cleanup;
	}
	playbuf2 = AllocMem(PLAYBUFSIZE, MEMF_CHIP|MEMF_CLEAR);	
	if (playbuf2 == NULL)
	{
		printf("PlayFile:  couldn't allocate buffer 2\n");
		goto Cleanup;
	}

	/* set up our signals to wait on */
	ulWaitMask |= (1<<port1->mp_SigBit) | (1<<port2->mp_SigBit) | SIGBREAKF_CTRL_C;

	if (SetSignal(0L,0L) & SIGBREAKF_CTRL_C) goto Cleanup;

	/* load both buffers to start out with */
	nErrors += LoadBuffer(SoundTaskReplyPort, pSendBuf, nBufNum++, playbuf1, &header1, fpIn, Handle);
	nErrors += LoadBuffer(SoundTaskReplyPort, pSendBuf, nBufNum++, playbuf2, &header2, fpIn, Handle);

	/* start by playing the first buffer */
	PlayBuffer(1, playbuf1, &header1);  

	if (SetSignal(0L,0L) & SIGBREAKF_CTRL_C) goto Cleanup;
	
	/* play loop: a simple double-buffered load scheme */
	while (nErrors < 2)
	{
		signals = Wait(ulWaitMask);
		
		if (signals & (1<<port1->mp_SigBit))	/* buffer 1 done playing? */
		{
			if (nErrors < 1) PlayBuffer(2, playbuf2, &header2);
			nErrors += LoadBuffer(SoundTaskReplyPort, pSendBuf, nBufNum++, playbuf1, &header1, fpIn, Handle);
		}
		if (signals & (1<<port2->mp_SigBit))    /* buffer 2 done playing? */
		{
			if (nErrors < 1) PlayBuffer(1, playbuf1, &header1);
			nErrors += LoadBuffer(SoundTaskReplyPort, pSendBuf, nBufNum++, playbuf2, &header2, fpIn, Handle);
		}
		
		if (signals & SIGBREAKF_CTRL_C) nErrors=2;	/* Someone wants us dead */
	}
	
/* clean up */
Cleanup:
     	if (Handle != NULL) 
     	{
     		CloseIFF(Handle);
		if (Handle->iff_Stream) Close(Handle->iff_Stream);
		FreeIFF(Handle); 
	}
	if (IFFParseBase) {CloseLibrary(IFFParseBase); IFFParseBase = NULL;}
	if (BAudioAlloced) AllocAudio(FALSE);
	if (playbuf2 != NULL) {FreeMem(playbuf2, PLAYBUFSIZE);}
	if (playbuf1 != NULL) {FreeMem(playbuf1, PLAYBUFSIZE);}
	if (pSendBuf != NULL) {FreeMem(pSendBuf,sizeof(struct AmiPhoneSendBuffer));}
	if (fpIn != NULL) fclose(fpIn);

	/* Free memory allocated in LaunchPlayer--hope this is legal! */
	if (szFileToPlay) 
	{
		FreeMem(szFileToPlay,strlen(szFileToPlay));
		szFileToPlay = NULL;
	}

	/* Tell main program we're done--If SoundTaskReplyPort is NULL, we won't expect a reply */
	/* It's very important that this message be sent, or main can't quit! */
	SendPlayerMessage(MESSAGE_CONTROLMAIN_IMLEAVING, NULL, 0L, SoundTaskReplyPort);	

	/* Cleanup any remaining messages and close the port */
	if (SoundTaskReplyPort) RemovePortSafely(SoundTaskReplyPort);
}



/* Loads the next chunk of sound into sendbuf and pubPlayBuf.
   Will compress/decompress the sound as necessary.
   
   Also copies the header into pHeader.  Returns 0 on success, 1
   on failure.  pHeader->ulDataLen is set to the length of the decompressed
   bytes in pubPlayBuf.  */
static int LoadBuffer(struct MsgPort * STReplyPort, UBYTE * pBuf, int nBufNum, UBYTE * pubPlayBuf, struct AmiPhonePacketHeader * pHeader, FILE * fpIn, struct IFFHandle * Handle)
{
	ULONG ulBytesToRead = ulSampleArraySize<<2;
	int nBytesRead;
	static ULONG ulJoinCode;
	
	if (nBufNum == 1) ulJoinCode = 0L;
	
	if (nPlaybackRate == AMIPHONE_FILE_RATE)
	{
		/* load in packet header to get data size */
		if ((fread(pHeader,1,sizeof(struct AmiPhonePacketHeader),fpIn)) < sizeof(struct AmiPhonePacketHeader))
		{
			if (nBufNum == 1) printf("LoadBuffer: Couldn't read file header.\n");
			return(1);
		}
		/* do some sanity checking on our header */
		if (pHeader->ubCommand != PHONECOMMAND_DATA)
		{
			printf("LoadBuffer:  chunk wasn't data! [%i]\n",pHeader->ubCommand);
			return(1);
		}
		if ((pHeader->ubType < COMPRESS_NONE)||(pHeader->ubType >= COMPRESS_MAX))
		{
			printf("LoadBuffer:  Bad compression method! [%i]\n",pHeader->ubType);
			return(1);
		}
		if ((pHeader->ulBPS < MIN_SAMPLE_RATE)||(pHeader->ulBPS > ABSOLUTE_MAX_SAMPLE_RATE))
		{
			printf("LoadBuffer:  Bad sampling rate! [%u]\n",pHeader->ulBPS);
			return(1);
		}

		/* copy the header to our load section */
		memcpy(pBuf,pHeader,sizeof(struct AmiPhonePacketHeader));

		/* load in data to data section of our load buffer */
		if ((nBytesRead = fread(pBuf+sizeof(struct AmiPhonePacketHeader), 1, pHeader->ulDataLen, fpIn)) < pHeader->ulDataLen)
		{
			pHeader->ulDataLen = (nBytesRead > 0) ? nBytesRead : 0;
			return(1);
		}
		
		/* If the main task cares, let it know that this packet should be sent */
		if ((BNetConnect == TRUE)&&(BXmitOnPlay == TRUE)&&(STReplyPort))
			SendPlayerMessage(MESSAGE_CONTROLMAIN_XMITPACKET, (void *)pBuf, 0L, STReplyPort);

		/* pHeader->ulDataLen will now contain # of bytes of raw audio data in pubPlayBuf */
		pHeader->ulDataLen = DecompressData(pBuf+sizeof(struct AmiPhonePacketHeader),
			pubPlayBuf, pHeader->ubType, pHeader->ulDataLen, pHeader->ulJoinCode);
		return(0);
	}
	else
	{
		pHeader->ubCommand  = PHONECOMMAND_DATA;
		pHeader->ubType     = ubCurrComp;
		
		if (nPlaybackRate == UNKNOWN_FILE_RATE) 
		{
			/* Raw data */
			pHeader->ulBPS = ulBytesPerSecond;
			nBytesRead = fread(pubPlayBuf,1,ulBytesToRead,fpIn);
		}
		else
		{	
			/* 8SVX file format */
			pHeader->ulBPS = nPlaybackRate;
			nBytesRead = ReadChunkBytes(Handle,pubPlayBuf,ulBytesToRead);
		}
		if (nBytesRead < 0) {pHeader->ulDataLen = 0; return(1);}
		pHeader->ulDataLen = nBytesRead;
		
		memcpy(pBuf,pHeader,sizeof(struct AmiPhonePacketHeader));

		/* If the main task cares, let it know that this packet should be sent */
		if ((BNetConnect == TRUE)&&(BXmitOnPlay == TRUE)&&(STReplyPort)&&(nBytesRead > 0))
		{
			struct AmiPhonePacketHeader * pCompHeader = (struct AmiPhonePacketHeader *) pBuf;
			
			pHeader->ulJoinCode = pCompHeader->ulJoinCode = ulJoinCode;
			
			pCompHeader->ulDataLen = CompressData(pubPlayBuf, 
				pBuf+sizeof(struct AmiPhonePacketHeader), 
				pHeader->ubType, pHeader->ulDataLen, 
				&ulJoinCode);
			SendPlayerMessage(MESSAGE_CONTROLMAIN_XMITPACKET, (void *)pBuf, 0L, STReplyPort);
		}
		return(nBytesRead < ulBytesToRead);
	}
}


/* Synchronously sends a message to the main program... i.e. this won't
   return until the message is acknowledged.  Returns TRUE if the message
   was successfully sent. */
BOOL SendPlayerMessage(UBYTE ubControl, void * data, ULONG ulData2, struct MsgPort * WaitForReplyAt)
{	
	struct PlayerMessage * SoundTaskMessage = (struct PlayerMessage *) AllocMem(sizeof(struct PlayerMessage), MEMF_PUBLIC|MEMF_CLEAR);
	BOOL BMessageSent;
	
	UNLESS((SoundTaskMessage)&&(WaitForReplyAt)) return(FALSE);
	
	/* Initialize our message struct */
	SoundTaskMessage->Message.mn_Node.ln_Type = NT_MESSAGE;
	SoundTaskMessage->Message.mn_Length       = sizeof(struct PlayerMessage);
	SoundTaskMessage->Message.mn_ReplyPort    = WaitForReplyAt;
	
	/* Set data in message */
	SoundTaskMessage->ubControl = ubControl;
	SoundTaskMessage->data = data;
	SoundTaskMessage->ulData2 = ulData2;
	
	/* Send it the message */
	BMessageSent = FALSE;
	Forbid();
	if (SoundTaskPort)
	{
		PutMsg(SoundTaskPort, (struct Message *)SoundTaskMessage);
		BMessageSent = TRUE;
	}
	Permit();
			
	if (BMessageSent == TRUE)
	{
		/* Wait for reply */
		WaitPort(WaitForReplyAt);
		GetMsg(WaitForReplyAt);
	}

	/* deallocate memory */
	FreeMem(SoundTaskMessage, sizeof(struct PlayerMessage));
	
	return(BMessageSent);
}


/*  starts the given buffer playing */
static BOOL PlayBuffer(int nAudioNum, UBYTE * pubData, struct AmiPhonePacketHeader * pHeader)
{
	struct IOAudio * AIOptr;

	if (pHeader->ulBPS < MIN_SAMPLE_RATE) 
	{
		printf("PlayBuffer:  play rate too low [%d]\n",pHeader->ulBPS);
		return(FALSE);
	}
	if (pHeader->ulDataLen < 1L) return(FALSE);

	
	     if (nAudioNum == 1) AIOptr = AIOptr1; 
	else if (nAudioNum == 2) AIOptr = AIOptr2;
	else return(FALSE);

	
	/* Fill out sample length, pointer to data, and playback speed */	
	AIOptr->ioa_Length = pHeader->ulDataLen;
	AIOptr->ioa_Data   = pubData;
	AIOptr->ioa_Period = (UWORD) (SystemClock / pHeader->ulBPS);	
	
	BeginIO((struct IORequest *)AIOptr);	/* start playing sample */
	return(TRUE);
}



/* Returns a valid IFFHandle if the 8SVX file can be read, or NULL on failure. */
static struct IFFHandle * Init8SVXLoad(char * szFileName)
{
	struct StoredProperty *Prop		= NULL;
	struct Voice8Header   *VoiceHeader	= NULL;
	struct IFFHandle      *Handle		= NULL;
	struct ContextNode    *ContextNode	= NULL;

	UNLESS(IFFParseBase = OpenLibrary("iffparse.library",37L)) return(NULL);

	/* Allocate an IFF handle. */
	UNLESS(Handle = AllocIFF()) goto Init8SVXFail;

	/* Open the sound file for reading. */
	UNLESS(Handle->iff_Stream = (ULONG) Open(szFileName,MODE_OLDFILE)) goto Init8SVXFail;

	InitIFFasDOS(Handle);
		
	/* Open the file for reading.  Zero return value == success */
	if (OpenIFF(Handle,IFFF_READ)) goto Init8SVXFail;
	    
	/* Remember the voice header chunk if encountered.  zero == success */
	if (PropChunk(Handle,'8SVX','VHDR')) goto Init8SVXFail;
	
	/* Stop in front of the data body chunk. */
	if (StopChunk(Handle,'8SVX','BODY')) goto Init8SVXFail;
		  
	/* Scan the file... */
	if (ParseIFF(Handle, IFFPARSE_SCAN)) goto Init8SVXFail;
	
	/* Try to find the voice header chunk. */
	UNLESS(Prop = FindProp(Handle,'8SVX','VHDR')) goto Init8SVXFail;
	VoiceHeader = (struct Voice8Header *)Prop -> sp_Data;
	
	/* No compression and only a single octave, please! */		   
	if (VoiceHeader->sCompression)
	{
		printf("PlaySound:  Sorry, compressed 8SVX isn't implemented!  :(\n");
		goto Init8SVXFail;
	}	
	/* Get information on the current chunk. */
	UNLESS(ContextNode = CurrentChunk(Handle)) goto Init8SVXFail;
	nPlaybackRate = VoiceHeader->samplesPerSec;
	return(Handle);

Init8SVXFail:
	if (Handle) 
	{
		CloseIFF(Handle);
		if (Handle->iff_Stream) Close(Handle->iff_Stream);
		FreeIFF(Handle); Handle = NULL;
	}
	return(NULL);
}

