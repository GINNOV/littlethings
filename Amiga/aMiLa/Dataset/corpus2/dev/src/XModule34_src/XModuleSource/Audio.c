/*
**	Audio.c
**
**	Copyright (C) 1994,95 by Bernardo Innocenti
**
**	audio.device interface routines.
**
**
**	A separate Process gets the AudioMsg messages from its pr_MsgPort
**	and dialogues with audio.device.  Once executed, the AudioMsg's are
**	replied to the AudioReply port, and the main program frees them.
**	Each IOAudio request has a special USERDATA field which points back
**	to the original AudioMsg structure.  This way it is possible to easly
**	track the status of each command being executed.
**
**	+------------+                +-------------+               +------------+
**	|Main Process|<-->AudioMsg<-->|Audio Process|<-->IOAudio<-->|audio.device|
**	+------------+                +-------------+               +------------+
*/

#include <devices/audio.h>
#include <dos/dos.h>
#include <dos/dostags.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>

#include "XModule.h"
#include "Gui.h"

/* This is the (maximum) size of sample chunks sent to the audio.device */

#define SAMPBUFSIZE		16768
#define MAXAUDIOSIZE	65534

/* Get/store pointer to original AudioMsg into an extended IOAudio structure */

#define AUDIOUSERDATA(ioa) (*((struct AudioMsg **)(((UBYTE *)ioa) + sizeof (struct IOAudio))))


struct AudioMsg
{
	struct Message am_Message;
	void *am_Data;
	UBYTE am_Command;
	UBYTE am_Error;
	UWORD am_Status;
	ULONG am_Len;
	ULONG am_Actual;
	UWORD am_Per;
	UWORD am_Vol;
	BYTE *am_TmpBuf[2];
	struct IOAudio *am_IOA[2];
};


/* Values for AudioMsg->am_Command */
#define ACMD_PLAY_SAMPLE	1	/* am_Data points to 8 bit sample data			*/
#define ACMD_PLAY_INSTR		1	/* am_Data points to an Instrument structure	*/



/* Local functions prototypes */

static void		ReplyAudioMsg	(struct AudioMsg *am);
static void		_PlaySample		(struct AudioMsg *am);
static UWORD	FindFreeChannel (void);
static ULONG	AllocChannels	(void);
static void		FreeChannels	(void);



ULONG AudioSig = 0;
struct MsgPort *AudioReply = NULL;


/* Local data */

static struct Process *AudioTask = NULL;
/* Audio IO requests.  Two for each channel (double buffer). */
static struct IOAudio *AudioReq[4][2] = { 0 };




static void __asm __saveds AudioProcess (void)
{
	ULONG audiosig, cmdsig, recsig, signals, err;
	LONG i, j;
	struct IOAudio *ioa;
	struct AudioMsg *am;
	struct MsgPort *AudioPort;	/* Audio reply port */


	struct Process *thistask = (struct Process *)FindTask (NULL);

	if (AudioPort = CreateMsgPort())
	{
		/* Create IOAudio requests */

		for (i = 0; i < 4 ; i++)
			for (j = 0; j < 2; j++)
				if (!(AudioReq[i][j] = (struct IOAudio *)CreateIORequest (AudioPort, sizeof (struct IOAudio) + 4)))
					err = ERROR_NO_FREE_STORE;

		if (!err)
		{
			/* Open audio.device */
			if (!(err = OpenDevice ("audio.device", 0, (struct IORequest *)AudioReq[0][0], 0)))
				err = AllocChannels();
		}
	}
	else err = ERROR_NO_FREE_STORE;


	/* Wait for startup message */

	WaitPort (&thistask->pr_MsgPort);
	am = (struct AudioMsg *) GetMsg (&thistask->pr_MsgPort);

	/* Reply startup message */
	am->am_Error = err;
	ReplyMsg ((struct Message *)am);

	if (err)
	{
		Wait (SIGBREAKF_CTRL_C);
		goto exit;
	}

	cmdsig = 1 << thistask->pr_MsgPort.mp_SigBit;
	audiosig = 1 << AudioPort->mp_SigBit;

	signals = cmdsig | audiosig | SIGBREAKF_CTRL_C;

	do
	{
		recsig = Wait (signals);

		if (recsig & audiosig)
		{
			/* Collect previously sent requests */
			while (ioa = (struct IOAudio *) GetMsg (AudioPort))
			{
				if (am = AUDIOUSERDATA (ioa))
				{
					if (am->am_Actual < am->am_Len)
					{
						BYTE *samp;
						ULONG len;

						if (am->am_TmpBuf[am->am_Status])
						{
							len = min (SAMPBUFSIZE, am->am_Len - am->am_Actual);
							samp = am->am_TmpBuf[am->am_Status];
							CopyMem (((BYTE *)am->am_Data) + am->am_Actual, samp, len);
						}
						else
						{
							samp = ((BYTE *)am->am_Data) + am->am_Actual;
							len = min (MAXAUDIOSIZE, am->am_Len - am->am_Actual);
						}

						/**/ioa->io_Command = CMD_WRITE;
						/**/ioa->io_Flags = ADIOF_PERVOL;
						ioa->ioa_Data = samp;
						ioa->ioa_Length = len;
						/**/ioa->ioa_Period = am->am_Per;
						/**/ioa->ioa_Volume = am->am_Vol;
						/**/ioa->ioa_Cycles = 1;

						BeginIO ((struct IORequest *)ioa);
						am->am_Actual += len;
						am->am_Status ^= 1;
					}
					else
					{
						am = AUDIOUSERDATA(ioa);
						AUDIOUSERDATA(am->am_IOA[0]) = NULL;
						AUDIOUSERDATA(am->am_IOA[1]) = NULL;
						ReplyAudioMsg (am);
					}
				}
			}
		}


		if (recsig & cmdsig)
		{
			/* Get Command and execute it */
			while (am = (struct AudioMsg *)GetMsg (&thistask->pr_MsgPort))
			{
				switch (am->am_Command)
				{
					case ACMD_PLAY_SAMPLE:
						_PlaySample (am);
						break;

					default:
						break;
				}
			}
		}
	}
	while (!(recsig & SIGBREAKF_CTRL_C));



exit:

	if (AudioPort)
	{
		FreeChannels();

		for (i = 3; i >= 0 ; i--)
			for (j = 1; j >= 0; j--)
				if (AudioReq[i][j])
				{
					if ((j == 0) && (AudioReq[i][j]->io_Device))
					{
						if (am = AUDIOUSERDATA(AudioReq[i][j]))
							ReplyAudioMsg (am);

						if (i == 0)
							CloseDevice ((struct IORequest *)AudioReq[0][0]);
					}
					DeleteIORequest ((struct IORequest *)AudioReq[i][j]); AudioReq[i][j] = NULL;
				}

		DeleteMsgPort (AudioPort);
	}

	/* Signal that we are done.
	 * We Forbid() here to avoid being unloaded until exit.
	 */
	Forbid();
	Signal ((struct Task *)ThisTask, SIGF_SINGLE);
}



static void ReplyAudioMsg (struct AudioMsg *am)
{
	FreeVec (am->am_TmpBuf[0]);
	FreeVec (am->am_TmpBuf[1]);
	AUDIOUSERDATA(am->am_IOA[0]) = NULL;
	AUDIOUSERDATA(am->am_IOA[1]) = NULL;
	ReplyMsg ((struct Message *)am);
}



static void _PlaySample (struct AudioMsg *am)
{
	BYTE *samp = am->am_Data;
	ULONG len = am->am_Len;
	ULONG ch = FindFreeChannel ();
	BOOL multi = FALSE, transfer = FALSE;

	am->am_TmpBuf[0] = NULL;
	am->am_TmpBuf[1] = NULL;
	am->am_Status = 0;
	am->am_IOA[0] = AudioReq[ch][0];
	am->am_IOA[1] = AudioReq[ch][1];

	if (!(TypeOfMem (samp) & MEMF_CHIP))
		transfer = TRUE;

	if (am->am_Len > MAXAUDIOSIZE)
	{
		multi = TRUE;
		if (transfer)
			len = SAMPBUFSIZE;
		else
			len = MAXAUDIOSIZE;
	}

	if (transfer)
		if (am->am_TmpBuf[0] = AllocVec (len, MEMF_CHIP))
		{
			CopyMem (samp, am->am_TmpBuf[0], len);
			samp = am->am_TmpBuf[0];
		}
		else return;

	am->am_IOA[0]->io_Command = CMD_WRITE;
	am->am_IOA[0]->io_Flags = ADIOF_PERVOL;
	am->am_IOA[0]->ioa_Data = samp;
	am->am_IOA[0]->ioa_Length = len;
	am->am_IOA[0]->ioa_Period = am->am_Per;
	am->am_IOA[0]->ioa_Volume = am->am_Vol;
	am->am_IOA[0]->ioa_Cycles = 1;
	AUDIOUSERDATA(am->am_IOA[0]) = am;

	BeginIO ((struct IORequest *)am->am_IOA[0]);
	am->am_Actual = len;

	if (multi)
	{
		samp += len;

		if (transfer)
		{
			len = min(SAMPBUFSIZE, am->am_Len - SAMPBUFSIZE);

			if (am->am_TmpBuf[1] = AllocVec (len, MEMF_CHIP))
			{
				CopyMem (samp, am->am_TmpBuf[1], len);
				samp = am->am_TmpBuf[1];
			}
			else return;
		}
		else len = min (MAXAUDIOSIZE, am->am_Len - MAXAUDIOSIZE);

		am->am_IOA[1]->io_Command = CMD_WRITE;
		am->am_IOA[1]->io_Flags = ADIOF_PERVOL;
		am->am_IOA[1]->ioa_Data = samp;
		am->am_IOA[1]->ioa_Length = len;
		am->am_IOA[1]->ioa_Period = am->am_Per;
		am->am_IOA[1]->ioa_Volume = am->am_Vol;
		am->am_IOA[1]->ioa_Cycles = 1;
		AUDIOUSERDATA(am->am_IOA[1]) = am;

		BeginIO ((struct IORequest *)am->am_IOA[1]);
		am->am_Actual += len;
	}
}



void HandleAudio (void)
{
	struct Message *msg;

	while (msg = GetMsg (AudioReply))
		FreeMem (msg, sizeof (struct AudioMsg));
}



void PlaySample (BYTE *samp, ULONG len, UWORD vol, UWORD per)
{
	struct AudioMsg *am;

	if (!samp) return;

	if (!AudioTask)
		if (SetupAudio()) return;

	if (!(am = AllocMem (sizeof (struct AudioMsg), MEMF_PUBLIC)))
		return;

	am->am_Message.mn_ReplyPort = AudioReply;
	am->am_Command = ACMD_PLAY_SAMPLE;

	am->am_Data = samp;
	am->am_Len = len;
	am->am_Vol = vol;
	am->am_Per = per;

	PutMsg (&AudioTask->pr_MsgPort, (struct Message *)am);
}



static UWORD FindFreeChannel (void)
{
	UWORD ch;

	for (ch = 0; ch < 4 ; ch++)
		if (CheckIO ((struct IORequest *)AudioReq[ch][0]) &&
			CheckIO ((struct IORequest *)AudioReq[ch][1]))
			return ch;

	{
		struct AudioMsg *am;

		AbortIO ((struct IORequest *)AudioReq[0][0]);
		AbortIO ((struct IORequest *)AudioReq[0][1]);
		WaitIO ((struct IORequest *)AudioReq[0][0]);
		WaitIO ((struct IORequest *)AudioReq[0][1]);

		if (am = AUDIOUSERDATA(AudioReq[0][0]))
		{
			ReplyAudioMsg (am);
			AUDIOUSERDATA(AudioReq[0][0]) = NULL;
			AUDIOUSERDATA(AudioReq[0][1]) = NULL;
		}
	}

	return 0;
}


static ULONG AllocChannels (void)
{
	struct IOAudio *ioa;
	ULONG i;

	/* Allocate channels */

	for (i = 0 ; i < 4; i++)
	{
		static UBYTE channels[] = {1, 2, 4, 8};

		ioa = AudioReq[i][0];

		ioa->ioa_Request.ln_Pri = 1;
		ioa->io_Device = AudioReq[0][0]->io_Device;
		ioa->io_Command = ADCMD_ALLOCATE;
		ioa->io_Flags = ADIOF_NOWAIT | IOF_QUICK;
		ioa->ioa_AllocKey = AudioReq[0][0]->ioa_AllocKey;
		ioa->ioa_Data = channels;
		ioa->ioa_Length = 4;

		/* Using DoIO() here is not possible because the
		 * io_Flags field would be cleared.
		 */
		BeginIO ((struct IORequest *)ioa);
		WaitIO ((struct IORequest *)ioa);

		/* Initailize other request */
		CopyMem (ioa, AudioReq[i][1], sizeof (struct IOAudio));

		if (ioa->io_Error)
			return ioa->io_Error;
	}

	return RETURN_OK;
}



static void FreeChannels (void)
{
	LONG i;

	for (i = 3; i >= 0; i--)
	{
		if (AudioReq[i][0])
		{
			AbortIO ((struct IORequest *)AudioReq[i][0]);
			WaitIO ((struct IORequest *)AudioReq[i][0]);

			if (AudioReq[i][1])
			{
				AbortIO ((struct IORequest *)AudioReq[i][1]);
				WaitIO ((struct IORequest *)AudioReq[i][1]);
			}

			AudioReq[i][0]->io_Command = ADCMD_FREE;
			DoIO ((struct IORequest *)AudioReq[i][0]);
		}
	}
}



ULONG SetupAudio (void)
{
	struct AudioMsg audiomsg;

	if (!(AudioReply = CreateMsgPort ()))
		return ERROR_NO_FREE_STORE;

	AudioSig = 1 << AudioReply->mp_SigBit;
	Signals |= AudioSig;

	/* Create Audio Process */
	if (!(AudioTask = CreateNewProcTags (
		NP_Entry,		AudioProcess,
		NP_Name,		"XModule Audio Process",
		NP_WindowPtr,	ThisTask->pr_WindowPtr,
		NP_Priority,	15,
		NP_CopyVars,	FALSE,
		// NP_Input,	NULL,
		// NP_Output,	NULL,
		// NP_Error,	NULL,
		TAG_DONE)))
	{
		CleanupAudio();
		return ERROR_NO_FREE_STORE;
	}


	/* Send Startup Message */

	audiomsg.am_Message.mn_ReplyPort = AudioReply;
	PutMsg (&(AudioTask->pr_MsgPort), (struct Message *)&audiomsg);
	WaitPort (AudioReply);
	GetMsg (AudioReply);

	if (audiomsg.am_Error)
	{
		CleanupAudio();
		return (audiomsg.am_Error);
	}

	return RETURN_OK;
}



void CleanupAudio (void)
{
	if (AudioTask)
	{
		/* Tell audio task to give up */
		SetSignal (0, SIGF_SINGLE);
		Signal ((struct Task *)AudioTask, SIGBREAKF_CTRL_C);

		/* Wait until the audio task quits */
		Wait (SIGF_SINGLE);
		AudioTask = NULL;
	}

	if (AudioReply)
	{
		struct Message *msg;

		while (msg = GetMsg (AudioReply))
			FreeMem (msg, sizeof (struct AudioMsg));

		DeleteMsgPort (AudioReply); AudioReply = NULL;
		Signals &= ~AudioSig; AudioSig = 0;
	}
}
