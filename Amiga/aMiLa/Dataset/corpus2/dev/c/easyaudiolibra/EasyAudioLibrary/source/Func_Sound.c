/* ------------------------------------------------------------------ */
/* $VER: Func_Sound.c 39.01 (12.12.1999)                              */
/*                                                                    */
/* A Set of easy functions to play digitized sound. You simply use    */
/* four functions that will take care of all the work of allocating   */
/* memory, loading the files, opening the ports and reserving the     */
/* sound channels.                                                    */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

/* perhaps only recognized by SAS/C  */
#define __USE_SYSBASE

/* Include some important header files */
#include <exec/types.h>
#include <exec/memory.h>
#include <devices/audio.h> 
#include <stdio.h>
#include "Func_Sound.h"
#include "Funcs.h"

#define CLOCK_CONSTANT 3579545

/* An IOAudio pointer to each sound channel: */
struct IOAudio *IOA[ 4 ] = { NULL, NULL, NULL, NULL };

typedef LONG Fixed;
typedef struct
{
  ULONG  oneShotHiSamples;  /* #samples in the high octave 1-shot part */
  ULONG  repeatHiSamples;   /* #samples in the high octave repeat part */
  ULONG  samplesPerHiCycle; /* #samples/cycle in high octave, else 0   */
  UWORD  samplesPerSec;     /* Data sampling rate */
  UBYTE  ctOctave;          /* Number of octaves of waveforms */
  UBYTE  sCompression;      /* Data compression technique used */
  Fixed  volume;            /* Playback volume from 0 to 0x10000 */
} Voice8Header;


/* Declare the PRIVATE functions we are going to use: */

BOOL EA_PrepareIOA(
  UWORD period,
  UWORD volume,
  UWORD cycles,
  UBYTE channel,
  BYTE priority,
  struct SoundInfo *info,
  ULONG start,
  ULONG time
);

UWORD EA_LoadSound( STRPTR filename, struct SoundInfo *info );

ULONG EA_GetSize( STRPTR filename );

ULONG EA_SizeIFF( STRPTR filename );

UWORD EA_ReadIFF( STRPTR filename, struct SoundInfo *info );

BOOL EA_MoveTo( STRPTR check_string, FILE *file_ptr );



/* ------------------------- */
/* REAL functions start here */
/* ------------------------- */


BOOL __saveds ASM
EA_PlaySound( register __d1 struct SoundInfo *info GNUCREG(d1),
			  register __d2 UWORD volume GNUCREG(d2),
			  register __d3 UBYTE channel GNUCREG(d3),
			  register __d4 BYTE priority GNUCREG(d4),
			  register __d5 WORD delta_rate GNUCREG(d5),
			  register __d5 UWORD times GNUCREG(d6),
			  register __a2 ULONG start GNUCREG(a2),
			  register __a3 ULONG time GNUCREG(a3),
			  register __a4 BOOL wait GNUCREG(a4)
			)
{
  /* Before we may play the sound, we must make sure that the sound is */
  /* not already being played. We will therefore call the function     */
  /* ISStopSound(), in order to stop the sound if it is playing:       */

  EA_StopSound( channel );

  /* Call the PrepareIOA() function that will declare and initialize an */
  /* IOAudio structure:                                 */

  if( EA_PrepareIOA( CLOCK_CONSTANT / info->RecordRate + delta_rate, volume,
				  times, channel, priority, info, start, time ) )
  {
	/* We will now start playing the sound: */
	BeginIO( IOA[ channel ] );

	/* Should we wait for the sound to be completed? */
	if( wait )
	  WaitIO( IOA[ channel ] );

	return( TRUE );  /* OK! */
  }
  else
	return( FALSE ); /* ERROR! */
}



/* -------------------------------------------------------------------- */
/* EA_StopSound() will stop the specified audio channel from continuing */
/* to play the sound. It will also close all devices and ports that     */
/* have been opened, and deallocate some memory that have been          */
/* allocated.                                                           */
/* -------------------------------------------------------------------- */

void __saveds ASM
EA_StopSound( register __d1 UBYTE channel GNUCREG(d1) )
{
  /* Check if the IOAudio structure exist: */
  if( IOA[ channel ] )
  {
	/* 1. Stop the sound: */
	AbortIO( IOA[ channel ] );
   
	/* 2. If there exist a Sound Device, close it: */
	if( IOA[ channel ]->ioa_Request.io_Device )
	CloseDevice( IOA[ channel ] );

	/* 3. If there exist a Message Port, delete it: */
	if( IOA[ channel ]->ioa_Request.io_Message.mn_ReplyPort )
	  DeletePort( IOA[ channel ]->ioa_Request.io_Message.mn_ReplyPort );

	/* 4. Remove the request block: */
	DeleteExtIO( IOA[ channel ], sizeof( struct IOAudio ) );
	
	/* 5. Set the pointer to NULL so we know that this */
	/*    request has now been deleted:                */
	IOA[ channel ] = NULL;
  }
}


/* ---------------------------------------------- */
/* EA_PrepareIOA() - allocates and initializes an */
/* IOAudio structure.                             */
/* ---------------------------------------------- */

BOOL EA_PrepareIOA(
  UWORD period,
  UWORD volume,
  UWORD cycles,
  UBYTE channel,
  BYTE priority,
  struct SoundInfo *info,
  ULONG start,
  ULONG time
)
{
  /* Store error numbers here: */
  BYTE error;

  /* Declare a pointer to a MsgPort structure: */ 
  struct MsgPort *port;



  /* Get a reply port: (No name, normal priority) */
  port = (struct MsgPort *)
	CreatePort( NULL, 0 );
	
  /* Did we get a reply port? */  
  if( !port )
  {
	/* Bad news! We did not get a reply port. */
	if (debug ==1)
	EA_Request("Error !!","Reply prot failed to materialise", "Ok");
	
	/* Return with an error value: */
	return( FALSE );
  }



  /* Create an IOAudio request: */
  IOA[ channel ] = (struct IOAudio *)
	CreateExtIO( port, sizeof( struct IOAudio ) );

  /* Could we allocate enough memory? */
  if( !IOA[ channel ] )
  {
	/* Tough luck! We did not get a request block. */
	if (debug ==1)
	EA_Request("Error !!","Could not find audio request block", "Ok");

	/* Close the reply port: */
	DeletePort( port );
	
	/* Return with an error value: */
	return( FALSE );
  }



  /* Initialize the IOAudion structure: */
	  
  /* Set priority: */
  IOA[ channel ]->ioa_Request.io_Message.mn_Node.ln_Pri = priority;
	
  /* Set channel: (This program tries to reserve one specific */
  /* audio channel. It does not support an allocation array   */
  /* with several options.)                                   */
  info->channel_bit = 1<<channel;

  /* Give the request block a pointer to our simple allocation array: */
  IOA[ channel ]->ioa_Data = &(info->channel_bit);
	
  /* Set the length of our allocation array: */
  IOA[ channel ]->ioa_Length = sizeof( UBYTE );
	
  /* Open Audio Device: */
  error =  OpenDevice( AUDIONAME, 0, IOA[ channel ], 0);

  /* Have wee successfully opened it? */
  if( error )
  {
	/* Hard times! Could not open the device! */
	if (debug ==1)
	EA_Request("Error !!","Could not open audio device !", "I will quit hippoplayer then");

	/* Delete the request block: */
	DeleteExtIO( IOA[ channel ], sizeof(struct IOAudio) );
	
	/* Close the reply port: */
	DeletePort( port );

	/* Set audio pointer to NULL so we know that */
	/* we do not have any request block here:    */
	IOA[ channel ] = NULL;

	/* Return with an error value: */
	return( FALSE ); /* ERROR! */
  }
 
 

  /* We now have a reply port, a request block, one  */
  /* audio channel reserved and the audio device has */
  /* been opened. Prepare to play:                   */ 


 
  /* Initialize the request block with the users requirements: */
  IOA[ channel ]->ioa_Request.io_Flags = ADIOF_PERVOL;

  /* We want to play sound (write data to the audio device): */
  IOA[ channel ]->ioa_Request.io_Command = CMD_WRITE;

  /* Set period value: */
  IOA[ channel ]->ioa_Period = period;

  /* Set volume: */
  IOA[ channel ]->ioa_Volume = volume;

  /* Number of times the sound wave should be played: */
  IOA[ channel ]->ioa_Cycles = cycles;

  /* If the user has specified a play time we use */
  /* it, else we play the complete sound:         */
  if( time )
	IOA[ channel ]->ioa_Length = time;
  else
	IOA[ channel ]->ioa_Length = info->FileLength;

  /* Set start position in the waveform: */
  IOA[ channel ]->ioa_Data = info->SoundBuffer + start;



  /* Everything has been prepared, return with OK: */
  return( TRUE );
}



/* ----------------------------------------------------------------------- */
/* EA_RemoveSound() will stop playing the sound, and deallocate all memory */
/* that was allocated by the PrepareSound() function. Before your program  */
/* terminates, all soundeffects that have been prepared, MUST be removed.  */
/*                                                                         */
/* IMPORTANT! Each channel that is currently playing the sound must be     */
/* stopped before you may remove the sound!!!! (Use the EA_StopSound()     */
/* function.)                                                              */
/* ----------------------------------------------------------------------- */

void __saveds ASM
EA_RemoveSound( register __d1 struct SoundInfo *info GNUCREG(d1) )
{
  /* IMPORTANT! The sound must have been */
  /* stopped before you may remove it!!! */

  /* Have we allocated a SoundInfo structure? */
  if( info )
  {
	/* Deallocate the sound buffer: */
	FreeMem( info->SoundBuffer, info->FileLength );

	/* Deallocate the SoundInfo structure: */
	FreeMem( info, sizeof( struct SoundInfo ) );
	info = NULL;
  }
}



/* ---------------------------------------------------------------------- */
/* EA_PrepareSound() loads a sampled sound file (IFF or FutureSound) into */
/* a buffer that is automatically allocated. All information about the    */
/* sound (record rate, length, buffersize etc) is put into an SoundInfo   */
/* structure. If EA_PrepareSound() has successfully prepared the sound it */
/* returns a pointer to a SoundInfo structure, otherwise it returns       */
/* NULL.                                                                  */
/* ---------------------------------------------------------------------- */

struct SoundInfo __saveds ASM
*EA_PrepareSound( register __d1 STRPTR file GNUCREG(d1) )
{
  /* Declare a pointer to a SoundInfo structure: */
  struct SoundInfo *info;


  /* Allocate memory for a SoundInfo structure: (The memory */
  /* can be of any type, and should be cleared.)            */

  info = (struct SoundInfo *)
	AllocMem( sizeof( struct SoundInfo ), MEMF_CLEAR );

  /* Have we successfully allocated the memory? */
  if( !info )
  {
	/* A black day! Not enough memory. */
	if (debug ==1)
	EA_Request("Error !!","Not enough memory !", "Rubbish i have 32mb free");

	/* Return error value (NULL): */
	return( NULL );
  }

  EA_Request("Hello Again", "I wonder if its going to crash now ?", "I bet it is");

  /* Get the size of the sound file, and store */
  /* it in the SoundInfo structure:            */
  info->FileLength = EA_GetSize( file );
  
  /* ------------------------- */
  /* VERY IMPORTANT THIS WORKS */
  /* ------------------------- */
  EA_Request("eek", "got sound file size", "Ok");

  /* Does the file contain any data? */
  if( info->FileLength == 0 ) 
  {
	/* Not your day! File is empty or we */
	/* have not been able to open it.    */
	if (debug==1)
	EA_Request("Error !!", "Could not open file !", "Ough No");

	/* Deallocate the SoundInfo structure: */
	FreeMem( info, sizeof( struct SoundInfo ) );

	/* Return error value (NULL): */
	return( NULL );
  }



  /* Allocate enough memory for the sampled sound, and store a  */
  /* pointer to the buffer in the SoundInfo structure: (Remeber */
  /* that sound data must be in chip memory.)                   */
  info->SoundBuffer = (BYTE *)
	AllocMem( info->FileLength, MEMF_CHIP|MEMF_CLEAR );

  /* Have we successfully allocated the memory? */
  if( !info->SoundBuffer )
  {
	/* This really &%*£$"! Not enough memory. */
	if (debug ==1)
	EA_Request("Error !!","Could not allocate sample buffer", "Ok");

	/* Deallocate the SoundInfo structure: */
	FreeMem( info, sizeof( struct SoundInfo ) );

	/* Return error value (NULL): */
	return( NULL );
  }



  /* Load the sound, and store the record rate in the SoundInfo  */
  /* structure. If the sound could not be loaded, 0 is returned: */
  info->RecordRate = EA_LoadSound( file, info );
  
  if( info->RecordRate == 0 )
  {
	/* Horrible times! Could not load the sound. */
	if (debug==1)
	EA_Request("Error !!", "Could not load sound", "Ok");

	/* Deallocate the sound data buffer: */
	FreeMem( info->SoundBuffer, info->FileLength );
  
	/* Deallocate the SoundInfo structure: */
	FreeMem( info, sizeof( struct SoundInfo ) );

	/* Return error value (NULL): */
	return( NULL );
  }
  


  /* The sound has now successfully been loaded! */
		  
  /* Old FutureSound files were saved in kHz. If the record rate */
  /* is less than one hundered, we know it is an old FutureSound */
  /* file, and simply multiply the rate with one thousand:       */
  if( info->RecordRate < 100 )
	info->RecordRate *= 1000;


		  
  /* Return a pointer to the SoundInfo structure: */
  return( info );
}



/* ------------------------------------------------------ */
/* EA_LoadSound() will load sampled sound that was either */
/* saved in IFF or FutureSound format.                    */
/* ------------------------------------------------------ */

UWORD EA_LoadSound( STRPTR filename, struct SoundInfo *info )
{
  FILE  *file_ptr;   /* Pointer to a file. */
  ULONG length;      /* Data Length. */
  UWORD record_rate; /* Record rate. */


  /* Check if it is an IFF File: */
  if( EA_SizeIFF( filename ) )
  {
	/* Yes, it is an IFF file. Read it: */
	return( EA_ReadIFF( filename, info ) );
  }
  else
  {
	/* No, then it is probably a FutureSound file. */
	/* Open the file so we can read it:            */
	if( (file_ptr = fopen( filename, "r" )) == 0 )
	  return( 0 ); /* ERROR! Could not open the file! */

	/* Read the data length: */
	if( fread( (char *) &length, sizeof( ULONG ), 1, file_ptr ) == 0 )
	{
	  /* ERROR! Could not read the data length! */
	  if (debug==1)
	  EA_Request("Error !!", "Could find data length", "Ok");

	  /* Close the file, and return zero:       */
	  fclose( file_ptr );
	  return( 0 );
	}

	/* Read the record rate: */
	if( fread( (char *) &record_rate, sizeof( UWORD ), 1, file_ptr ) == 0 )
	{
	  /* ERROR! Could not read the record rate! */
	  if (debug==1)
	  EA_Request("Error !!", "Could find record rate", "Ok");

	  /* Close the file, and return zero:       */
	  fclose( file_ptr );
	  return( 0 );
	}

	/* Read the sampled sound data into the buffer: */
	if( fread( (char *) info->SoundBuffer, length, 1, file_ptr ) == 0 )
	{
	  /* ERROR! Could not read the data!  */
	  if (debug==1)
	  EA_Request("Error !!", "Could even read data", "Ok");

	  /* Close the file, and return zero: */    
	  fclose( file_ptr );
	  return( 0 );
	}

	/* Close the file: */
	fclose( file_ptr );

	/* Return the record rate: */
	return( record_rate );
  }
}



/* --------------------------------------------------------- */
/* EA_GetSize() returns the size of the file which was saved */
/* in either IFF or FutureSound format.                      */
/* --------------------------------------------------------- */

ULONG EA_GetSize( STRPTR filename )
{
  FILE *file_ptr; /* Pointer to a file. */
  ULONG length;  /* Data length. */


  /* Check if it is an IFF File: */
  if( ( length = EA_SizeIFF( filename ) ) == 0 )
  {
	/* No, then it is probably a FutureSound file. */
	/* Open the file so we can read it:            */
	if( ( file_ptr = fopen( filename, "r" ) ) == 0 )
	  { if (debug ==1)
			EA_Request("Error !!","Could not open file !", "Ok");
	  return( 0 ); /* ERROR! Could not open the file! */
	  }

	/* Read the data length: */
	if( fread( (char *) &length, sizeof( ULONG ), 1, file_ptr ) == 0)
	{
	  /* ERROR! Could not read the data length! */
	  /* Close the file, and return zero:       */
	  fclose( file_ptr );
	  return( 0 );
	}
	
	/* Close the file: */
	fclose( file_ptr );
  }
  return( length );
}



/* ------------------------------------------------------------------ */
/* EA_SizeIFF() returns the size of an IFF file, or zero if something */
/* went wrong (for example, It was not an IFF file).                  */
/* ------------------------------------------------------------------ */

ULONG EA_SizeIFF( STRPTR filename )
{
  FILE  *file_ptr;              /* Pointer to a file. */
  STRPTR empty_string = "    "; /* Four spaces. */ 
  LONG dummy;                   /* A dummy variable. */
  Voice8Header Header;          /* Voice8Header structure. */


  /* Try to open the file: */
  if( file_ptr = fopen( filename, "r" ) )
  {
	fread( (char *) empty_string, 4, 1, file_ptr );
	if( strcmp( empty_string, "FORM" ) == 0)
	{
	  /* Read twice: */
	  fread( (char *) empty_string, 4, 1, file_ptr );
	  fread( (char *) empty_string, 4, 1, file_ptr );

	  /* Check if it is a "8SVX" file, or not: */
	  if( strcmp( empty_string, "8SVX" ) == 0 )
	  {
		EA_MoveTo( "VHDR", file_ptr );
		fread( (char *) &dummy, sizeof( LONG ), 1, file_ptr );
		fread( (char *) &Header, sizeof( Header ), 1, file_ptr );

		/* Close the file, and return the length: */
		fclose( file_ptr );
		return( Header.oneShotHiSamples + Header.repeatHiSamples );
	  }
	}
	/* Close the file: */
	fclose( file_ptr );
  }
  /* Return zero: (ERROR) */
  if (debug ==1)
	  EA_Request("Error !!","Sample not valid IFF data","Ok");

  return( 0 );
}


// /* --------------------------------------------------- */
// /* EA_ReadIFF() reads an IFF file into the buffer, and */
// /* returns the record rate.                            */                                     */
// /* --------------------------------------------------- */

UWORD EA_ReadIFF( STRPTR filename, struct SoundInfo *info )
{
  FILE  *file_ptr;              /* Pointer to a file. */
  STRPTR empty_string = "    "; /* Four spaces. */ 
  LONG dummy;                   /* A dummy variable. */
  Voice8Header Header;          /* Voice8Header structure. */


  /* Try to open the file: */
  if( file_ptr = fopen( filename, "r" ) )
  {
	fread( (char *) empty_string, 4, 1, file_ptr );
	if( strcmp( empty_string, "FORM" ) == 0 )
	{
	  /* Read twice: */
	  fread( (char *) empty_string, 4, 1, file_ptr );
	  fread( (char *) empty_string, 4, 1, file_ptr );

	  /* Check if it is a "8SVX" file, or not: */
	  if( strcmp( empty_string, "8SVX" ) == 0 )
	  {
		EA_MoveTo( "VHDR", file_ptr );
		fread( (char *) &dummy, sizeof( LONG ), 1, file_ptr );
		fread( (char *) &Header, sizeof( Header ), 1, file_ptr );

		EA_MoveTo( "BODY", file_ptr );
		fread( (char *) &dummy, sizeof( LONG ), 1, file_ptr );
		fread( (char *) info->SoundBuffer, Header.oneShotHiSamples +
								 Header.repeatHiSamples, 1, file_ptr );

		/* Close the file, and return the record rate: */
		fclose( file_ptr );
		return( Header.samplesPerSec );
	  }
	}
	/* Close the file: */
	fclose( file_ptr );
  }
  /* Return zero: (ERROR) */
  if (debug ==1)
  EA_Request("Error !!","Could not find sample data","Ok");
  return( 0 );
} 

/* ------------------------------------------------------------ */
/* EA_MoveTo() walks through an IFF file, and looks for chunks. */
/* ------------------------------------------------------------ */

BOOL EA_MoveTo( STRPTR check_string, FILE *file_ptr )
{
  STRPTR empty_string = "    "; /* Four spaces. */ 
  int skip, loop;               /* How much data should be skiped. */
  LONG dummy;                   /* A dummy variable. */


  /* As long as we have not reached the EOF, continue: */
  while( !feof( file_ptr ) )
  {
	fread( (char *) empty_string, 4, 1, file_ptr);

	/* Have we found the right chunk? */    
	if( strcmp( check_string, empty_string ) ==0 )
	  return( 0 ); /* YEA_! Return nothing. */

	/* Move foreward: */
	fread( (char *) &skip, sizeof( LONG ), 1, file_ptr );
	for( loop = 0; loop < skip; loop++ )
	  fread( (char *) &dummy, 1, 1, file_ptr);
  }
}

