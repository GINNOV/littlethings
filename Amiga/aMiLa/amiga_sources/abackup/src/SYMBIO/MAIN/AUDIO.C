/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    audio.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 18-Oct-93
    Modified: 02-Aug-94
    _______________________________________________________________________
*/

#include "headers.h"

#define AUDIO_FREQ	440	/* Frequency of the tone desired   */
#define AUDIO_DURATION	4	/* Duration in 1/seconds	   */
#define AUDIO_SAMPLES	2	/* Number of sample bytes	   */
#define AUDIO_SAMCYC	1	/* Number of cycles in the sample  */

/*************************************************************************/

/*
 * The whichannel array is used when we allocate a channel.
 * It tells the audio device which channel we want. The code is 1 =channel0,
 * 2 =channel1, 4 =channel2, 8 =channel3.
 * If you want more than one channel, add the codes up.
 * This array says "Give me channel 0. If it's not available then try channel 1,
 * then try channel 2 and then channel 3
 */

static UBYTE whichannel[] = { 1, 2, 4, 8 } ;

static BYTE *pWave = NULL ;			/* Pointer to the sample bytes */
static LONG Clock  = 3579545 ;			/* Clock constant, 3546895 for PAL */

static struct IOAudio *AudioIO	= NULL ;	/* Pointer to the I/O block for I/O commands */
static struct MsgPort *AudioMP	= NULL ;	/* Pointer to a port so the device can reply */
static struct Message *AudioMSG = NULL ;	/* Pointer for the reply message */

/*************************************************************************/

void CleanupAudio( void )

/* $DOC
 * FUNCTION
 *	Free ressources for audio access
 * $END
 */

{
  if ( pWave ) MyFreeMem( pWave ) ;
  if ( HasAudio() ) CloseDevice( (struct IORequest *)AudioIO ) ;
  if ( AudioMP ) DeletePort( AudioMP ) ;
  if ( AudioIO ) MyFreeMem( AudioIO ) ;

  pWave = NULL ;
  AudioMP = NULL ;
  AudioIO = NULL ;
  ClearPrgFlag( PF_AUDIO ) ;
}

/*************************************************************************/

BOOL SetupAudio( void )

/* $DOC
 * FUNCTION
 *	Init ressources for audio access
 * OUTPUTS
 *	Result = success/failure
 * $END
 */

{
  /* Ask the system if it is PAL or NTSC and set Clock constant accordingly */

  if ( GfxBase ) Clock = ( GfxBase->DisplayFlags & PAL ) ? 3546895 : 3579545 ;

  /* Create an audio I/O block so we can send commands to the audio device */

  AudioIO = (struct IOAudio *)MyAllocMem( sizeof(struct IOAudio) , NULL ) ;
  if ( ! AudioIO ) goto _failed ;

  /* Create a reply port so the audio device can reply to our commands */

  AudioMP = CreatePort( NULL , 0 ) ;
  if ( ! AudioMP ) goto _failed ;

  /*
   * Set up the audio I/O block for channel allocation:
   * - ioa_Request.io_Message.mn_ReplyPort is the address of a reply port.
   * - ioa_Request.io_Message.mn_Node.ln_Pri sets the precedence (priority)
   *   of our use of the audio device. Any tasks asking to use the audio
   *   device that have a higher precedence will steal the channel from us.
   * - ioa_Request.io_Command is the command field for I/O.
   * - ioa_Request.io_Flags is used for the I/O flags.
   * - ioa_AllocKey will be filled in by the audio device if the allocation
   *   succeeds. We must use the key it gives for all other commands sent.
   * - ioa_Data is a pointer to the array listing the channels we want.
   * - ioa_Length tells how long our list of channels is.
   */

  AudioIO->ioa_Request.io_Message.mn_ReplyPort	 = AudioMP ;
  AudioIO->ioa_Request.io_Message.mn_Node.ln_Pri = 0 ;
  AudioIO->ioa_Request.io_Command		 = ADCMD_ALLOCATE ;
  AudioIO->ioa_Request.io_Flags 		 = ADIOF_NOWAIT ;
  AudioIO->ioa_AllocKey 			 = 0 ;
  AudioIO->ioa_Data				 = whichannel ;
  AudioIO->ioa_Length				 = sizeof(whichannel) ;

  /* Create a very simple audio sample in memory. */

  pWave = (BYTE *)MyAllocMem( AUDIO_SAMPLES , MEMF_CHIP ) ;
  if ( ! pWave ) goto _failed ;
  pWave[0] =  127;
  pWave[1] = -127;

  /* Open the audio device and allocate a channel */

  if ( OpenDevice( AUDIONAME , 0L , (struct IORequest *)AudioIO , 0L )) goto _failed ;

  SetPrgFlag( PF_AUDIO ) ;
  return( TRUE ) ;

_failed:

  CleanupAudio() ;
  return( FALSE ) ;
}

/*************************************************************************/

void PlayBeep( void )           /* Send a sound */

{
  if ( ! HasAudio() ) return ;

  /*
   * Set up audio I/O block to play a sample using CMD_WRITE.
   * - io_Flags are set to ADIOF_PERVOL so we can set the
   *   period (speed) and volume
   * - ioa_Data points to the sample
   * - ioa_Length gives the length
   * - ioa_Cycles tells how many times to repeat the sample
   */

  AudioIO->ioa_Request.io_Message.mn_ReplyPort	= AudioMP ;
  AudioIO->ioa_Request.io_Command	= CMD_WRITE ;
  AudioIO->ioa_Request.io_Flags 	= ADIOF_PERVOL ;
  AudioIO->ioa_Data			= pWave ;
  AudioIO->ioa_Length			= AUDIO_SAMPLES ;
  AudioIO->ioa_Period			= ( Clock * AUDIO_SAMCYC ) / ( AUDIO_SAMPLES * AUDIO_FREQ ) ;
  AudioIO->ioa_Volume			= 64 ;
  AudioIO->ioa_Cycles			= AUDIO_FREQ / ( AUDIO_SAMCYC * AUDIO_DURATION ) ;

  /*
   * Send the command to start a sound using BeginIO()
   * Go to sleep and wait for the sound to finish with
   * WaitPort().  When we wake-up we have to get the reply
   */

  BeginIO( (struct IORequest *)AudioIO ) ;
  WaitPort( AudioMP ) ;
  AudioMSG = GetMsg( AudioMP ) ;
}

