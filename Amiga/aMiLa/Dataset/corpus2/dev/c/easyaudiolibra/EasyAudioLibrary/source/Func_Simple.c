/* ------------------------------------------------------------------ */
/* $VER: Func_simple.c 39.01 (12.12.1999)                             */
/*                                                                    */
/* Easy functions for easyaudio.library, this is just the short stuff */
/* anything more compilcated gets its own file (lucky them).          */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

/* perhaps only recognized by SAS/C  */
#define __USE_SYSBASE

/* Size of the phonetic string buffer. */
#define PHONETIC_BUFFER_SIZE 400

/* The audio channels: */
/* Values: */
#define LEFT0B   0
#define RIGHT0B  1
#define RIGHT1B  2
#define LEFT1B   3
/* Bit fields: */
#define LEFT0F   (1<<LEFT0B)
#define RIGHT0F  (1<<RIGHT0B)
#define RIGHT1F  (1<<RIGHT1B)
#define LEFT1F   (1<<LEFT1B)

/* system includes */
#include <exec/types.h>
#include <exec/memory.h>
#include <devices/narrator.h>
#include <devices/audio.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <graphics/gfxbase.h>

/* all important prototypes & pointers to used libraries */
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/utility.h>
#include <proto/graphics.h>
#include <proto/alib.h>
#include <proto/translator.h>


/* my prototypes to stop the sky falling down */
void clean_up(void);
int alloc_speech(char phonetic_string[PHONETIC_BUFFER_SIZE]);
void killaudio(void);

/* ansi includes */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* diffrent compiler support */
#include "compiler.h"
#include "Funcs.h"

/* Declare a pointer to our reply port: */
struct MsgPort *replymp = NULL;

/* Declare a pointer to our narrator request block: */
struct narrator_rb *narrator_req = NULL;

/* beep stuff */
struct IOAudio *AudioIO;   /* the I/O block for I/O commands */
struct MsgPort *AudioMP;   /* a port so the device can reply */
struct Message *AudioMSG;  /* the reply message */
ULONG  device;
BYTE   *waveptr;           /* Pointer to the sample bytes */
LONG   frequency;          /* Frequency of the tone desired */
LONG   duration;           /* Duration in seconds */
LONG   clock = 3546895;    /* Clock constant PAL */
LONG   samples   = 2;      /* Number of sample bytes */
LONG   samcyc    = 1;      /* Number of cycles in the sample */


 /* ------------------ */
 /* START OF FUNCTIONS */
 /* ------------------ */


ULONG __saveds ASM EA_Request( register __d1 UBYTE *title_d1 GNUCREG(d1),
							   register __d2 UBYTE *body GNUCREG(d2),
							   register __d3 UBYTE *gadgets GNUCREG(d3))
{
 /* -------------------------------------------------------------------- */
 /* Will pop an easy request with the number of gadgets & texts you want */
 /* -------------------------------------------------------------------- */

 UBYTE *title = title_d1;

 struct EasyStruct __aligned estr;

 estr.es_StructSize   = sizeof(struct EasyStruct);
 estr.es_Flags        = NULL;
 estr.es_Title        = title;
 estr.es_TextFormat   = body;
 estr.es_GadgetFormat = gadgets;

 return( (ULONG) EasyRequestArgs(NULL, &estr, NULL, NULL));
}



ULONG __saveds ASM EA_Speech( register __d1 char *temp_string GNUCREG(d1) )

{
/* ----------------------------------------------------- */
/* uses the synth speech to "say" whatever you pass it,. */
/* ----------------------------------------------------- */

/* __Code Starts Here__ */

int char_translated; /* Number of translated characters, or zero if all*/
char phonetic_string[PHONETIC_BUFFER_SIZE]; /* The phonetic string: */
char original_string[1000];


	/* Open the translator library: */
	TranslatorBase = (struct TranslatorBase *)
		OpenLibrary( "translator.library", 0); /* any version */

		if(!TranslatorBase) /* if not found */
		{ EA_Request("Error !!", "Could not open the translator library!", "Ok");
		  clean_up();
		} /* quits */

	/* get some speech */
	strcpy(original_string,temp_string);

	/* convert speech to phonetic's */
	char_translated = Translate (original_string,
								 strlen(original_string),
								 phonetic_string,
								 PHONETIC_BUFFER_SIZE);

	if(char_translated < 0) /* negative if it broke */  
	{   
		if (debug==1)/* check if it worked */
		EA_Request("Error !!", "Only translated some characters!", "Ok");

		return(1); /* quit with error */
	}
	/* else go on */

	if (alloc_speech(phonetic_string) == 0) /* sends to device */
	   return(0);  /* IT WORKED */
	   /* will error internally */
	else
	   return(1); /* IT BROKE */

	/* Close the translator library: */
	if( TranslatorBase )
		CloseLibrary( TranslatorBase );

} /* end of EXF_Speech */


int alloc_speech(char phonetic_string[PHONETIC_BUFFER_SIZE])
{ /* sys friendly,.. so lots of error checks, be paitent */
BYTE error; /* Store error values here: */

/* The text should be read in stereo: */
UBYTE allocation_array[]=
{
  LEFT0F|RIGHT0F, /* First left and first right channel.   */
  LEFT0F|RIGHT1F, /* First left and second right channel.  */
  LEFT1F|RIGHT0F, /* Second left and first right channel.  */
  LEFT1F|RIGHT1F  /* Second left and second right channel. */
};
	/* ------------------------------------------ */
	/* FIRST check we have all the stuff we NEED  */
	/* ------------------------------------------ */

	/* Get a reply port: (No name, priority 0) */
	replymp = (struct MsgPort *)
	CreatePort( NULL, 0);
	if(!replymp) /* if could not get it */
		{ if (debug==1)
		  EA_Request("Error !!", "Could not create the reply port!", "Ok");

		  clean_up(); /* quits */
		  return(1);
		}

	/* Allocate and preinitialize a narrator request block: */
	narrator_req = (struct narrator_rb *)
	CreateExtIO( replymp, sizeof(struct narrator_rb) );
	if(!narrator_req) /* if we could not get it */
		{ if (debug==1)
		  EA_Request("Error !!", "Not enough memory for the narrator request!", "Ok");

		  clean_up();
		  return(1);
		} /* quits */

	/* Open the Narrator Device: */
	error = OpenDevice("narrator.device", 0, narrator_req, 0);
	if(error) /* i.e if something broke */
		{ /* Clear the "io_Device" flag, cos we did'nt open it */
		narrator_req->message.io_Device = NULL;

		if (debug==1)
		EA_Request("Error !!", "Could not open the Narrator Device!", "What the f**k ?");

		clean_up();
		return(1);
		} /* Quit */


	/* ------------------------------------------ */
	/* SECOND check we have all the stuff we WANT */
	/* ------------------------------------------ */

	/* Set the length of the phonetic string: */
	narrator_req->message.io_Length = strlen( phonetic_string);

	/* Give it a pointer to the phonetic string: */
	narrator_req->message.io_Data = (APTR) phonetic_string;

	/* Send (write) the text to the device: */
	narrator_req->message.io_Command = CMD_WRITE;

	/* Desired channel combinations: */
	narrator_req->ch_masks = allocation_array;

	/* Size of the allocation array: */
	narrator_req->nm_masks = sizeof(allocation_array);


	/* --------------------------------------- */
	/* THEN to what we have to, i.e SPEAK.!!!! */
	/* --------------------------------------- */

	/* Start to read: */
	SendIO(narrator_req);

	/* Wait for the narrator to finish reading the text: */
	error = WaitIO(narrator_req);

	/* Were there any errors? */
	if(error)
	{ if (debug==1)/* did any of the above break */
		 EA_Request("Error !!", "Error while reading text !", "Ok");
	clean_up();
	return(1);
	}

	/* Clean up and quit: */
	clean_up();
	return(0);
} /* end of alloc_speech */


void clean_up(void)
{ /* If we have a request block and the "io_Device" field  */
  /* is not zero, we know that the device has successfully */
  /* been opened and must now be closed:                   */

  if( narrator_req && narrator_req->message.io_Device )
	CloseDevice( narrator_req );

  /* Empty the reply port: */
  while( GetMsg( replymp ) )

  /* Remove the replyport: */
  if( replymp )
	DeletePort( replymp);

  /* Dealocate the narrator request block: */
  if( narrator_req )
	DeleteExtIO( narrator_req, sizeof( struct narrator_rb ) );

  /* Quit: */
}


/* -------------------------------------------------------------------- */
/*                                                                      */
/* This is what i call open source !                                    */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* -------------------------------------------------------------------- */



ULONG __saveds ASM EA_Beep( register __d1 ULONG frequency GNUCREG(d1),
							register __d2 ULONG duration GNUCREG(d2))

{
 /* ---------------------------------------------------------- */
 /* uses audio to make a beep for time & frequency you require */
 /* ---------------------------------------------------------- */

/*-----------------------------------------------------------*/
/* The whichannel array is used when we allocate a channel.  */
/* It tells the audio device which channel we want. The code */
/* is 1 =channel0, 2 =channel1, 4 =channel2, 8 =channel3.    */
/* If you want more than one channel, add the codes up.      */
/* This array says "Give me channel 0. If it's not available */
/* then try channel 1; then try channel 2 and then channel 3 */
/*-----------------------------------------------------------*/
UBYTE  whichannel[] = { 1,2,4,8 };

if ((frequency > 660) || (frequency < 0))
	if (debug==1)
	   { EA_Request("Error !!","Frequency out of range, must be (650 - 0)","Ok");
		 return(1); /* damn ! */
	   }

if ((duration > 30) || (duration < 0))
	if (debug==1)
	   { EA_Request("Error !!","Duration out of range, must be less than 30secs","Ok");
		 return(1); /* dough ! */
	   }
/* -------------------------------------------------------------- */
/* Ask the system if we are PAL or NTSC and set clock accordingly */
/* -------------------------------------------------------------- */
GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",0L);
if (GfxBase == 0L)
	{ killaudio(); /* cleans up */
		if (debug==1)
			{ EA_Request("Error !!","Seems i could not find graphics.library !!","Ough Shit!");
			}
		goto end;
	} /* gets out */

else if (GfxBase->DisplayFlags & PAL)
		clock = 3546895;        /* PAL clock */
	 else
		clock = 3579545;        /* NTSC clock */

if (GfxBase)
	CloseLibrary((struct Library *) GfxBase);


/* ---------------------------------------------------------------------- */
/* Create an audio I/O block so we can send commands to the audio device  */
/* ---------------------------------------------------------------------- */
AudioIO = (struct IOAudio *)
		   AllocMem( sizeof(struct IOAudio),MEMF_PUBLIC | MEMF_CLEAR);
if (AudioIO == 0)
	{ killaudio();
		if (debug==1)
		   { EA_Request("Error !!", "Could not allocate memory for Audio I/O","Screw you tree hugging hippies");
		   }
		goto end;
	}

/* ------------------------------------------------------------------ */
/* Create a reply port so the audio device can reply to our commands  */
/* ------------------------------------------------------------------ */
AudioMP = CreatePort(0,0);
if (AudioMP == 0)
	{ killaudio();
		if (debug==1)
		   { EA_Request("Error !!", "Could not create Audio reply port","Ok");
		   }
		goto end;
	}

/* --------------------------------------------------------------------- */
/* Set up the audio I/O block for channel allocation:                    */
/*                                                                       */
/* ioa_Request.io_Message.mn_ReplyPort is the address of a reply port.   */
/* ioa_Request.io_Message.mn_Node.ln_Pri sets the precedence (priority)  */
/*   of our use of the audio device. Any tasks asking to use the audio   */
/*   device that have a higher precedence will steal the channel from us.*/
/*                                                                       */
/* ioa_Request.io_Command is the command field for I/O.                  */
/* ioa_Request.io_Flags is used for the I/O flags.                       */
/* ioa_AllocKey will be filled in by the audio device if the allocation  */
/*   succeeds. We must use the key it gives for all other commands sent. */
/*                                                                       */
/* ioa_Data is a pointer to the array listing the channels we want.      */
/* ioa_Length tells how long our list of channels is.                    */
/* --------------------------------------------------------------------- */

AudioIO->ioa_Request.io_Message.mn_ReplyPort   = AudioMP;
AudioIO->ioa_Request.io_Message.mn_Node.ln_Pri = 20; /* high priority */
AudioIO->ioa_Request.io_Command                = ADCMD_ALLOCATE;
AudioIO->ioa_Request.io_Flags                  = ADIOF_NOWAIT;
AudioIO->ioa_AllocKey                          = 0;
AudioIO->ioa_Data                              = whichannel;
AudioIO->ioa_Length                            = sizeof(whichannel);


/* -------------------------------------------- */
/* Open the audio device and allocate a channel */
/* -------------------------------------------- */
device = OpenDevice("audio.device",0L, (struct IORequest *) AudioIO ,0L);
if (device != 0)
	{ killaudio();
		if (debug==1)
		   { EA_Request("Error !!", "Could not open audio device or allocate channel","Assmaster");
		   }
		goto end;
	}


/* --------------------------------------------- */
/* Create a very simple audio sample in memory.  */
/* The sample must be CHIP RAM                   */
/* --------------------------------------------- */
waveptr = (BYTE *)AllocMem( samples , MEMF_CHIP|MEMF_PUBLIC);
if (waveptr == 0)
	{ killaudio();
		if (debug==1)
		   { EA_Request("Error !!", "Could not create sample in memory","Dough !");
		   }
		goto end;
	}

waveptr[0] =  127;
waveptr[1] = -127;


/* ----------------------------------------------------------- */
/* Set up audio I/O block to play a sample using CMD_WRITE.    */
/* The io_Flags are set to ADIOF_PERVOL so we can set the      */
/*    period (speed) and volume with the our sample;           */
/*                                                             */
/* ioa_Data points to the sample; ioa_Length gives the length  */
/* ioa_Cycles tells how many times to repeat the sample        */
/* If you want to play the sample at a given sampling rate,    */
/* set ioa_Period = clock/(given sampling rate)                */
/* ----------------------------------------------------------- */
AudioIO->ioa_Request.io_Message.mn_ReplyPort =AudioMP;
AudioIO->ioa_Request.io_Command              =CMD_WRITE;
AudioIO->ioa_Request.io_Flags                =ADIOF_PERVOL;
AudioIO->ioa_Data                            =(BYTE *)waveptr;
AudioIO->ioa_Length                          =samples;
AudioIO->ioa_Period                          =clock*samcyc/samples*frequency;
AudioIO->ioa_Volume                          =64;
AudioIO->ioa_Cycles                          =frequency*duration/samcyc;


/* ------------------------------------------------------ */
/* Send the command to start a sound using BeginIO()      */
/* Go to sleep and wait for the sound to finish with      */
/* WaitPort().  When we wake-up we have to get the reply  */
/* ------------------------------------------------------ */

BeginIO((struct IORequest *) AudioIO );
WaitPort(AudioMP);
AudioMSG = GetMsg(AudioMP);

/* return sucessfull */
return(0);

/* we jump to here to avaid breaking anything else */
/* this IS A GOOD PLACE for a GOTO !! */
end:
return(1); /* dough ! */

} /* end EXF_Sound */

void killaudio(void)
{ /* begin big clean up */

if (waveptr != 0)
	FreeMem(waveptr, samples);
if (device == 0)
	CloseDevice( (struct IORequest *) AudioIO );
if (AudioMP != 0)
	DeletePort(AudioMP);
if (AudioIO != 0)
	FreeMem( AudioIO,sizeof(struct IOAudio) );

} /* end kill audio */

/* -------------------------------------------------------------------- */
/*                                                                      */
/* i am root/ kneel before me !                                         */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* -------------------------------------------------------------------- */



/* any more procedures ? */

