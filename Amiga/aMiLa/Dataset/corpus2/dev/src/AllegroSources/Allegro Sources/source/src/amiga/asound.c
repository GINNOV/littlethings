/*         ______   ___    ___
 *        /\  _  \ /\_ \  /\_ \ 
 *        \ \ \L\ \\//\ \ \//\ \      __     __   _ __   ___ 
 *         \ \  __ \ \ \ \  \ \ \   /'__`\ /'_ `\/\`'__\/ __`\
 *          \ \ \/\ \ \_\ \_ \_\ \_/\  __//\ \L\ \ \ \//\ \L\ \
 *           \ \_\ \_\/\____\/\____\ \____\ \____ \ \_\\ \____/
 *            \/_/\/_/\/____/\/____/\/____/\/___L\ \/_/ \/___/
 *                                           /\____/
 *                                           \_/__/
 *
 *      Amiga OS sound module.
 *
 *      By Hitman/Code HQ.
 *
 *      See readme.txt for copyright information.
 */

#include "allegro.h"
#include "allegro/internal/aintern.h"
#include <proto/ahi.h>
#include <proto/exec.h>
#include "athread.h"

// TODO: CAW - Why does reserve_voices() stop things from working?

/* Messagse that can be sent to the sound thread */

enum EMessage
{
	EM_InitVoice = 1, EM_ReleaseVoice, EM_StartVoice, EM_StopVoice
};

/* Each voice that can be played is represented by an isntance of this structure */

struct Voice
{
	char					*v_Sample;			/* Ptr to sign converted 8 bit sample, if any */
	int						v_Frequency;		/* Frequency at which to play the voice */
	int						v_LengthSamples;	/* Length of the sample in samples */
	int						v_Looping;			/* 1 if the sample is looping */
	int						v_Playing;			/* # of the currently playing sample */
	int						v_Position;			/* Current playback offset in bytes */
	int						v_Started;			/* 1 if the playback has started */
	Fixed					v_Volume;			/* Volume between 0 (min) and 0x10000 (max) in fixed point */
	Fixed					v_Panning;			/* Panning position between 0 (left) and 0x1000 (right) */
	struct AHISampleInfo	v_SampleInfos;		/* Information representing the two halves of the */
	struct AHISampleInfo	v_SampleInfos2;		/* Sample to be played */
};

AL_VAR(DIGI_DRIVER, digi_amiga);

struct Library *AHIBase;					/* AHI library base */
struct AHIIFace *IAHI;						/* AHI library interface */

static BYTE gAHIDevice = -1;				/* Instance of AHI device to use */
static BYTE gPlayerSigBit = -1;				/* Signal bit to use for signalling the player thread */
static int gPlaybackStarted;				/* 1 if playback has started with AHI_ControlAudio() */
static struct AHIRequest *gIORequest;		/* IO Request structure to communicate with ahi.device */
struct AmiThread gSoundThread;				/* Thread used for sound updates */
static struct MsgPort *gMsgPort;			/* Message port used by AHI */
static struct Process *gPlayerProcess;		/* Ptr to the player thread's process */
static struct Voice *gVoices;				/* Ptr to array of structures representing all voices */
static struct AHIAudioCtrl *gAudioCtrl;		/* Structure used for controlling audio playback */
static struct Hook gSoundFuncHook;			/* Hook representing the AHI sound function */

/* Temporary global variables used for passing parameters to the sound thread */

static int gNumVoices;						/* Total # of voices to use */
static int gVoice;							/* # of the voice to start, stop etc */
static AL_CONST SAMPLE *gSample;			/* Sample information for use by EM_InitVoice */

static unsigned long sound_func(struct Hook *aHook, struct AHIAudioCtrl *aAudioCtrl, struct AHISoundMessage *aSoundMessage);

static void switch_samples(int aVoice);

static void sound_thread_exit();

static void thread_stop_voice(int aVoice);

static unsigned long sound_func(struct Hook *aHook, struct AHIAudioCtrl *aAudioCtrl, struct AHISoundMessage *aSoundMessage)
{
	(void) aHook;
	(void) aAudioCtrl;

	/* Rather than switch samples here, signal the player thread to do it to ensure no variables are accessed in */
	/* the interrupt context while they are being accessed by the player thread */

	// TODO: CAW - This is temporary until I come up with a way to signal the bits.  If I don't then get rid
	//             of gPlayerProcess, gPlayerSigBit and the handling code in sound_thread_func()
	//IExec->Signal((struct Task *) gPlayerProcess, (1 << gPlayerSigBit));
	switch_samples(aSoundMessage->ahism_Channel);

	return(0);
}

static void switch_samples(int aVoice)
{
	struct Voice *Voice;

	/* Cache a ptr to the voice that is to have its samples switched */
	
	Voice = &gVoices[aVoice];

	/* Save the position for use by get_position().  Remember that this function gets called at */
	/* the *start* of playback of a sample and that we break an Allegro sample in two for double */
	/* buffering and streaming, so we can use this to determine our position */

	Voice->v_Position = (Voice->v_Playing == 0) ? 0 : Voice->v_LengthSamples;

	/* Indicate that the other sample is now playing and queue it into AHI for playback */

	Voice->v_Playing = (1 - Voice->v_Playing);

	/* If the next sample to be played is the first one then check the looping flag.  If it is */
	/* not set then we need to stop playback and the end of the current sample */

	if ((Voice->v_Playing == 0) && (!(Voice->v_Looping)))
	{
		IAHI->AHI_SetSound(aVoice, AHI_NOSOUND, 0, 0, gAudioCtrl, 0);

		/* And indicate that the voice has stopped */

		Voice->v_Started = 0;
	}

	/* Otherwise set the next sound to be played, taking into account that the sounds are divided */
	/* into two banks, given that there are twice as many sounds as voices */

	else
	{
		IAHI->AHI_SetSound(aVoice, (aVoice + (Voice->v_Playing * gNumVoices)), 0, 0, gAudioCtrl, 0);
	}
}

static void thread_init_voice(int aVoice, AL_CONST SAMPLE *aSample)
{
	unsigned char *Sample;
	int BytesLength1, Length1, Length2, Type;
	struct Voice *Voice;

	/* Cache a ptr to the voice to be initialised */

	Voice = &gVoices[aVoice];

	/* Stop the playback of the current voice, if it is already under way */

	thread_stop_voice(aVoice);

	/* Decide on an appropriate AHI mode to use for playback */

	if (aSample->bits == 16)
	{
		Type = (aSample->stereo) ? AHIST_S16S : AHIST_M16S;
	}
	else
	{
		Type = (aSample->stereo) ? AHIST_S8S : AHIST_M8S;
	}

	/* Calculate the length of the two sounds representing the first and second half of the sample, */
	/* taking into account that the total length of the sample may be an odd number of samples */

	Length1 = (aSample->len / 2);
	Length2 = (aSample->len - Length1);

	/* Convert the length of the first sound into bytes, taking into account mono/stereo and # of */
	/* bits per sample */

	BytesLength1 = (Length1 * (((aSample->stereo) ? 2 : 1) * ((aSample->bits == 16) ? 2 : 1)));

	/* Save the length if the first sound, for the get_position() routine */

	Voice->v_LengthSamples = Length1;

	/* Save the frequency for l8r use when starting the sample */

	Voice->v_Frequency = aSample->freq;

	/* By default set the volume to full and the panning to centre */

	Voice->v_Volume = 0x10000;
	Voice->v_Panning = 0x8000;

	/* Initialise the structures used for loading the two sounds that will playback the */
	/* two halves of the sample for this voice */

	Sample = aSample->data;
	gVoices[aVoice].v_SampleInfos.ahisi_Type = Type;
	gVoices[aVoice].v_SampleInfos.ahisi_Address = Sample;
	gVoices[aVoice].v_SampleInfos.ahisi_Length = Length1;

	gVoices[aVoice].v_SampleInfos2.ahisi_Type = Type;
	gVoices[aVoice].v_SampleInfos2.ahisi_Address = (Sample + BytesLength1);
	gVoices[aVoice].v_SampleInfos2.ahisi_Length = Length2;

	/* And load the samples into AHI */

	// TODO: CAW - What if either of these fail?
	if (IAHI->AHI_LoadSound(aVoice, AHIST_DYNAMICSAMPLE, &gVoices[aVoice].v_SampleInfos, gAudioCtrl) == AHIE_OK)
	{
		/* Load the second sound, taking into account that the sounds are divided into two banks, */
		/* given that there are twice as many sounds as voices */

		if (IAHI->AHI_LoadSound((aVoice + gNumVoices), AHIST_DYNAMICSAMPLE, &gVoices[aVoice].v_SampleInfos2, gAudioCtrl) == AHIE_OK)
		{
			/* And initialise other fields of the voice to their defaults */

			Voice->v_Looping = Voice->v_Playing = Voice->v_Position = Voice->v_Started = 0;
		}
	}
}

static void thread_release_voice(int aVoice)
{
	IAHI->AHI_UnloadSound(aVoice, gAudioCtrl);
	IAHI->AHI_UnloadSound((aVoice + gNumVoices), gAudioCtrl);
}

static void thread_start_voice(int aVoice)
{
	struct Voice *Voice;

	/* Cache a ptr to the voice to be initialised */

	Voice = &gVoices[aVoice];

	/* Put AHI into playing mode, if it is not already */

	if (!(gPlaybackStarted))
	{
		// TODO: CAW - What if this fails?
		if (IAHI->AHI_ControlAudio(gAudioCtrl, AHIC_Play, TRUE, TAG_DONE) == AHIE_OK)
		{
			gPlaybackStarted = 1;
		}
	}

	/* If playback was started successfully, or was already underway, set the volume, frequency and sound */
	/* that is to be played */

	if (gPlaybackStarted)
	{
		IAHI->AHI_SetVol(aVoice, Voice->v_Volume, Voice->v_Panning, gAudioCtrl, AHISF_IMM);
		IAHI->AHI_SetFreq(aVoice, Voice->v_Frequency, gAudioCtrl, AHISF_IMM);

		/* Start only the first sound.  This will cause the SoundFunc to be called by AHI, which will then */
		/* enqueue the second sound for playback and start the streaming process (assuming the sounds are */
		/* not looping) */

		IAHI->AHI_SetSound(aVoice, aVoice, 0, 0, gAudioCtrl, AHISF_IMM);

		/* Indicate that playback has started for this voice */

		Voice->v_Started = 1;
	}
}

static void thread_stop_voice(int aVoice)
{
	struct Voice *Voice;

	/* Cache a ptr to the voice to be initialised */

	Voice = &gVoices[aVoice];

	/* If playback has been started, stop it now by setting its sound to AHI_NOSOUND */

	if (Voice->v_Started)
	{
		IAHI->AHI_SetSound(aVoice, AHI_NOSOUND, 0, 0, gAudioCtrl, AHISF_IMM);

		/* And indicate that the voice has stopped */

		Voice->v_Started = 0;
	}

	/* Free the converted signed 8 bit sample, if it exists.  This is done here rather than above */
	/* to ensure that it is still done if init_voice() is called, but not start_voice() */

	if (Voice->v_Sample)
	{
		_AL_FREE(Voice->v_Sample);
		Voice->v_Sample = NULL;
	}
}

static int sound_thread_init(struct AmiThread *aAmiThread)
{
	int RetVal;
	ULONG MaxVoices;

	(void) aAmiThread;

	/* Assume failure */

	RetVal = 0;

	/* Create a message port and IO request for use by AHI */

	if ((gMsgPort = IExec->CreateMsgPort()) != NULL)
	{
		if ((gIORequest = (struct AHIRequest *) IExec->CreateIORequest(gMsgPort, sizeof(struct AHIRequest))) != NULL)
		{
			/* Set the lowest version of AHI that we are expecting to use */

			gIORequest->ahir_Version = 5;

			/* Open ahi.device for use */

			if ((gAHIDevice = IExec->OpenDevice(AHINAME, AHI_NO_UNIT, (struct IORequest *) gIORequest, 0)) == 0)
			{
				/* Obtain a ptr to the library base from the AHI device so that we can access it like */
				/* a normal library */

				AHIBase = (struct Library *) gIORequest->ahir_Std.io_Device;

				/* And obtain an interface to the library base */

				if ((IAHI = (struct AHIIFace *) IExec->GetInterface(AHIBase, "main", 1, NULL)) != NULL)
				{
					/* See how many voices AHI can handle, and if it is less than that requested, reduce */
					/* the number of voices available to Allegro */

					if (IAHI->AHI_GetAudioAttrs(AHI_DEFAULT_ID, NULL, AHIDB_MaxChannels, &MaxVoices))
					{
						if (gNumVoices > (int) MaxVoices)
						{
							gNumVoices = MaxVoices;
						}

						gNumVoices = 10; // TODO: CAW + comment this stuff

						/* Allocate an array of Voice structures large enough for all of the voices available */

						if ((gVoices = _AL_MALLOC(sizeof(struct Voice) * gNumVoices)) != NULL)
						{
							memset(gVoices, 0, (sizeof(struct Voice) * gNumVoices));

							digi_amiga.voices = digi_amiga.max_voices = digi_amiga.def_voices = gNumVoices;

							/* Setup the hook structure that will be used for calling the SoundFunc at the start of each sound */

							gSoundFuncHook.h_Entry = (HOOKFUNC) sound_func;
							gSoundFuncHook.h_Data = NULL;

							/* Allocate the audio hardware to play the audio data in the requested format, letting AHI also know */
							/* how many sounds we will allocate and the SoundFunc to call at the start of each sound */

							if ((gAudioCtrl = IAHI->AHI_AllocAudio(AHIA_Channels, gNumVoices, AHIA_SoundFunc, (ULONG) &gSoundFuncHook,
								AHIA_Sounds, (gNumVoices * 2),
								TAG_DONE)) != NULL)
							{
								/* Get a ptr to the player thread's process and allocate a signal bit so that the SoundFunc */
								/* can signal to the player thread when a sample has started playback */

								if ((gPlayerSigBit = IExec->AllocSignal(-1)) != -1 )
								{
									gPlayerProcess = (struct Process *) IExec->FindTask(NULL);

									/* And indicate success */

									RetVal = 1;
								}
							}
						}
					}
				}
			}
		}
	}

	/* If anything failed to be allocated, cleanup whatever was allocated successfully */

	if (!(RetVal))
	{
		sound_thread_exit();
	}

	return(RetVal);
}

static void sound_thread_exit()
{
	int Index;

	/* Iterate through the voices and stop any that are under way */

	for (Index = 0; Index < gNumVoices; ++Index)
	{
		thread_stop_voice(Index);
	}

	/* Free the player signal bit, if it was allocated */

	if (gPlayerSigBit != -1)
	{
		IExec->FreeSignal(gPlayerSigBit);
	}

	/* Free the audio hardware, if it was allocated */

	if (gAudioCtrl)
	{
		IAHI->AHI_FreeAudio(gAudioCtrl);
		gAudioCtrl = NULL;
	}

	/* Free the voices, if they were allocated */

	if (gVoices)
	{
		_AL_FREE(gVoices);
		gVoices = NULL;
	}

	/* Drop the AHI interface, if it exists */

	if (IAHI)
	{
		IExec->DropInterface((struct Interface *) IAHI);
	}

	/* This seems a bit backwards because a gAHIDevice value of 0 indicates that the device has been */
	/* opened.  This is because IExec->OpenDevice() returns 0 on success and we initialise gAHIDevice to */
	/* -1 at startup */

	if (gAHIDevice == 0)
	{
		IExec->CloseDevice((struct IORequest *) gIORequest);
	}

	/* Free the AHI IO request */

	if (gIORequest)
	{
		IExec->DeleteIORequest((struct IORequest *) gIORequest);
	}

	/* And free the message port */

	if (gMsgPort)
	{
		IExec->DeleteMsgPort(gMsgPort);
	}
}

static void sound_thread_func(struct AmiThread *aAmiThread)
{
	ULONG Signal, ThreadSignal, SoundSignal;

	/* Cache the signals on which we have to wait */

	ThreadSignal = (1 << aAmiThread->at_ThreadSignalBit);
	SoundSignal = (1 << gPlayerSigBit);

	/* Loop around and process all signals until we are told to shut down! */

	for ( ; ; )
	{
		Signal = IExec->Wait(ThreadSignal | SoundSignal);

		/* If the Thread signal has been signalled then process the incoming message */

		if (Signal & ThreadSignal)
		{
			/* Zero is always EM_Shutdown */

			if (aAmiThread->at_Message == 0)
			{
				sound_thread_exit();

				break;
			}

			/* Otherwise process the class specific messages */

			else
			{
				if (aAmiThread->at_Message == EM_InitVoice)
				{
					thread_init_voice(gVoice, gSample);
				}
				if (aAmiThread->at_Message == EM_ReleaseVoice)
				{
					thread_release_voice(gVoice);
				}
				else if (aAmiThread->at_Message == EM_StartVoice)
				{
					thread_start_voice(gVoice);
				}
				else if (aAmiThread->at_Message == EM_StopVoice)
				{
					thread_stop_voice(gVoice);
				}

				/* And signal that the message has been processed, as the main thread is waiting */
				/* on this.  Even unknown messages (which we shouldn't get anyway) are acknowledged */

				amithread_reply_message(aAmiThread);
			}
		}

		/* If the voice signal has been signalled then a sample has completed playback so go */
		/* and handle it */

		if (Signal & SoundSignal)
		{
			switch_samples(0);
		}
	}
}

static int detect(int aInput)
{
	int RetVal;
	BYTE AHIDevice;
	struct AHIRequest *IORequest;
	struct MsgPort *MsgPort;

	(void) aInput;

	/* Assume failure */

	RetVal = 0;

	/* Create a message port and IO request for use by AHI */

	if ((MsgPort = IExec->CreateMsgPort()) != NULL)
	{
		if ((IORequest = (struct AHIRequest *) IExec->CreateIORequest(MsgPort, sizeof(struct AHIRequest))) != NULL)
		{
			/* Set the lowest version of AHI that we are expecting to use */

			IORequest->ahir_Version = 5;

			if ((AHIDevice = IExec->OpenDevice(AHINAME, AHI_NO_UNIT, (struct IORequest *) IORequest, 0)) == 0)
			{
				/* Indicate that sound support is available */

				RetVal = 1;

				/* And close the device, which is no longer required */

				IExec->CloseDevice((struct IORequest *) IORequest);
			}

			IExec->DeleteIORequest((struct IORequest *) IORequest);
		}

		IExec->DeleteMsgPort(MsgPort);
	}

	return(RetVal);
}

static int sound_init(int aInput, int aVoices)
{
	int RetVal;

	(void) aInput;

	/* Assume failure */

	RetVal = 1;

	/* Save the parameters and create a thread to handle the sound playback */

	gNumVoices = aVoices;

	/* And indicate to Allegro that it should convert all samples to signed format */

	_sound_signed_samples = 1;

	if (amithread_create(&gSoundThread, sound_thread_init, sound_thread_func, NULL))
	{
		RetVal = 0;
	}

	return(RetVal);
}

static void sound_exit(int aInput)
{
	(void) aInput;

	/* Destroy the thread that is handling the sound playback */

	amithread_destroy(&gSoundThread);
}

static void init_voice(int aVoice, AL_CONST SAMPLE *aSample)
{
	/* Save the parameters and send the EM_InitVoice message to the thread */

	gVoice = aVoice;
	gSample = aSample;
	amithread_send_message(&gSoundThread, EM_InitVoice);
}

static void sound_release_voice(int aVoice)
{
	(void) aVoice;

	gVoice = aVoice;
	amithread_send_message(&gSoundThread, EM_ReleaseVoice);
}

static void start_voice(int aVoice)
{
	/* Save the parameters and send the EM_StartVoice message to the thread */

	gVoice = aVoice;
	amithread_send_message(&gSoundThread, EM_StartVoice);
}

static void stop_voice(int aVoice)
{
	/* Save the parameters and send the EM_StopVoice message to the thread */

	gVoice = aVoice;
	amithread_send_message(&gSoundThread, EM_StopVoice);
}

static void loop_voice(int aVoice, int aPlaymode)
{
	gVoices[aVoice].v_Looping = (aPlaymode == PLAYMODE_LOOP) ? 1 : 0;
}

static int get_position(int aVoice)
{
	int RetVal;
	struct Voice *Voice;

	/* Cache a ptr to the voice to be examined */

	Voice = &gVoices[aVoice];

	/* The calculations for the current playback position are quite crude as they do not */
	/* alter as the voice is played back, due to the AHI level interface.  Instead, the */
	/* granulatity of the playback position is limited to indicating that we are playing */
	/* either the first or the second of our two samples.  At least this means that we */
	/* are locked to AHI and are not having to guess using timers */

	if (Voice->v_Started)
	{
		RetVal = Voice->v_Position;
	}

	/* If the voice is not playing then indicate this */

	else
	{
		RetVal = -1;
	}

	return(RetVal);
}

static void set_position(int aVoice, int aPosition)
{
	(void) aVoice;
	(void) aPosition;

	/* We don't support setting the position as AHI doesn't seem to allow it, but this function is */
	/* required as Allegro doesn't check whether DIGI_DRIVER.set_position is valid or not. So just */
	/* assert of anyone calls us */

	ASSERT(0);
}

static int sound_get_volume(int aVoice)
{
	struct Voice *Voice;

	/* Cache a ptr to the voice to be examined */

	Voice = &gVoices[aVoice];

	/* Convert the volume from AHI's range back to Allegro's range and return it, unless the voice */
	/* is not being played, in which case return -1 */

	return((Voice->v_Started) ? (Voice->v_Volume / 256) : -1);
}

static void sound_set_volume(int aVoice, int aVolume)
{
	struct Voice *Voice;

	/* Cache a ptr to the voice to be examined */

	Voice = &gVoices[aVoice];

	/* Convert the volume from Allegro's range (0 - 255) to AHI's fixed point range (0 - 0x10000). */
	/* We can easily do this by multiplying by 256, although this will never achieve maximum */
	/* volume (but it will get close) */

	Voice->v_Volume = (aVolume * 256);

	/* And let AHI know the new value, respecting the panning position as well */

	IAHI->AHI_SetVol(aVoice, Voice->v_Volume, Voice->v_Panning, gAudioCtrl, AHISF_IMM);
}

static void set_frequency(int aVoice, int aFrequency)
{
	IAHI->AHI_SetFreq(aVoice, aFrequency, gAudioCtrl, AHISF_IMM);
}

static void set_pan(int aVoice, int aPan)
{
	struct Voice *Voice;

	/* Cache a ptr to the voice to be examined */

	Voice = &gVoices[aVoice];

	/* Convert the panning from Allegro's range (0 - 255) to AHI's fixed point range (0 - 0x10000). */
	/* We can easily do this by multiplying by 256, although this will never achieve maximum */
	/* right panning (but it will get close) */

	Voice->v_Panning = (aPan * 256);

	/* And let AHI know the new value, respecting the volume as well */

	IAHI->AHI_SetVol(aVoice, Voice->v_Volume, Voice->v_Panning, gAudioCtrl, AHISF_IMM);
}

DIGI_DRIVER digi_amiga =
{
/*                   id */ DIGI_AMIGA,
/*                 name */ empty_string,
/*                 desc */ empty_string,
/*           ascii_name */ "amigaosdigi",
/*               voices */ 0,
/*            basevoice */ 0,
/*           max_voices */ 0,
/*           def_voices */ 0,
/*               detect */ detect,
/*                 init */ sound_init,
/*                 exit */ sound_exit,
/*     set_mixer_volume */ NULL,
/*     get_mixer_volume */ NULL,
/*           lock_voice */ NULL,
/*         unlock_voice */ NULL,
/*          buffer_size */ NULL,
/*           init_voice */ init_voice,
/*        release_voice */ sound_release_voice,
/*          start_voice */ start_voice,
/*           stop_voice */ stop_voice,
/*           loop_voice */ loop_voice,
/*         get_position */ get_position,
/*         set_position */ set_position,
/*           get_volume */ sound_get_volume,
/*           set_volume */ sound_set_volume,
/*          ramp_volume */ NULL,
/*     stop_volume_ramp */ NULL,
/*        get_frequency */ NULL,
/*        set_frequency */ set_frequency,
/*      sweep_frequency */ NULL,
/* stop_frequency_sweep */ NULL,
/*              get_pan */ NULL,
/*              set_pan */ set_pan,
/*            sweep_pan */ NULL,
/*       stop_pan_sweep */ NULL,
/*             set_echo */ NULL,
/*          set_tremolo */ NULL,
/*          set_vibrato */ NULL,
/*         rec_cap_bits */ 0,
/*       rec_cap_stereo */ 0,
/*         rec_cap_rate */ NULL,
/*         rec_cap_parm */ NULL,
/*           rec_source */ NULL,
/*            rec_start */ NULL,
/*             rec_stop */ NULL,
/*             rec_read */ NULL
};

_DRIVER_INFO _digi_driver_list[] =
{
	{  DIGI_AMIGA, &digi_amiga, TRUE  },
	{  0,          NULL,        0     }
};
