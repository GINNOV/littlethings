/****h* ReadCapacity.c [2.0] ******************************************************
*
* NAME
*    ReadCapacity.c 
* 
* DESCRIPTION
*    Read a drive's capacity using HD_SCSICMD
*
* COPYRIGHT
*    Copyright (C) 1990 by Ralph Babel, Falkenweg 3, D-6204 Taunusstein, FRG
*    all rights reserved - alle Rechte vorbehalten
*
* HISTORY
*    02-Jun-1990 - created
*    31-Oct-1995 - Modified to use stdio & to accept user TID as argv[1] (JTS).
*    16-Nov-2004 - Ported to AmigaOS4 & gcc (JTS).
***********************************************************************************
*
*/

#include <stdio.h>
#include <stdlib.h>                // For atoi()

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>

#include <AmigaDOSErrs.h>

#include <devices/scsidisk.h>
#include <libraries/dos.h>

#ifndef __amigaos4__

# include <proto/exec.h>
# include <proto/dos.h>

PRIVATE STRPTR v = "\0$VER: ReadCapacity 2.0 " __AMIGADATE__ " by Ralph Babel\0";

#else

# include <clib/exec_protos.h>

# define __USE_INLINE__

# include <proto/exec.h>
# include <proto/dos.h>

IMPORT struct Library *SysBase;
IMPORT struct Library *DOSBase;

IMPORT struct ExecIFace *IExec;
IMPORT struct DOSIFace  *IDOS;

PRIVATE STRPTR v = "\0$VER: ReadCapacity 2.0 " __DATE__ " by Ralph Babel (Ported to AmigaOS4 by J.T. Steichen)\0";

#endif

#define BOARD 0 // controller board (if any)
#define LUN   0 // logical unit

PRIVATE int TID = 1;

#define UNIT   (BOARD * 100 + LUN * 10 + TID)
#define MAXBUF 252

PRIVATE UBYTE           *scsiData  = NULL;
PRIVATE UBYTE           *senseData = NULL;
PRIVATE struct MsgPort  *mp        = NULL;
PRIVATE struct IOStdReq *io        = NULL;

struct CapacityData {

   ULONG HighSector;
   ULONG SectorSize;
};

PRIVATE struct CapacityData *cd = NULL;

PRIVATE void ShutdownProgram( BOOL deviceOpened )
{
   if (deviceOpened)
      CloseDevice( (struct IORequest *) io );

   if (io)
      DeleteStdIO( (struct IORequest *) io );

   if (mp)
      DeletePort( mp );

   if (senseData)
      FreeVec( senseData );

   if (scsiData)
      FreeVec( scsiData );

   if (cd)
      FreeVec( cd );
      
   return;
}

PRIVATE int SetupProgram( STRPTR deviceName, ULONG unitNumber )
{
   int rval = RETURN_OK;

   if (!(cd = AllocVec( sizeof( struct CapacityData ), MEMF_CLEAR | MEMF_SHARED ))) // MEMF_CHIP)) != NULL)
      {
      rval = ERROR_NO_FREE_STORE;

      goto exitSetupProgram;
      } 

   if (!(scsiData = AllocVec( MAXBUF, MEMF_CLEAR | MEMF_SHARED ))) // MEMF_CHIP )))
      {
      rval = ERROR_NO_FREE_STORE;

      ShutdownProgram( FALSE );

      goto exitSetupProgram;
      }

   if (!(senseData = AllocVec( MAXBUF, MEMF_CLEAR | MEMF_SHARED ))) // MEMF_CHIP )))
      {
      rval = ERROR_NO_FREE_STORE;

      ShutdownProgram( FALSE );

      goto exitSetupProgram;
      }

   if (!(mp = CreatePort( NULL, 0 )))
      {
      rval = IoErr();

      ShutdownProgram( FALSE );

      goto exitSetupProgram;
      }

   if (!(io = (struct IOStdReq *) CreateStdIO( mp )))
      {
      rval = IoErr();

      ShutdownProgram( FALSE );

      goto exitSetupProgram;
      }

   if (OpenDevice( deviceName, unitNumber, (struct IORequest *) io, 0 ))
      {
      rval = ERROR_DEVICE_NOT_MOUNTED; // IoErr();

      ShutdownProgram( FALSE );
      }

exitSetupProgram:

   return( rval );
}

PUBLIC int main( int argc, char *argv[] )
{
   struct SCSICmd SC   = { 0, };
   UBYTE          command[10];
   int            rval = RETURN_OK;

   if (argc == 0)
      return( RETURN_ERROR ); // No Workbench support (yet!)
   
   if (argc != 3)
      {
      fprintf( stderr, "USAGE:  %s DEVICENAME/A,UNITNUMBER/N\n", argv[0] );

      return( ERROR_REQUIRED_ARG_MISSING );
      }   

   TID = atoi( argv[2] );
   // Should probably get the User to pass in LUN & Board number as well.
   
   if (SetupProgram( argv[1], UNIT ) != RETURN_OK)
      {
      fprintf( stderr, "Could NOT setup %s program!\n", argv[0] );

      return( RETURN_FAIL );
      }
   else
      {
      io->io_Command      = HD_SCSICMD;
      io->io_Length       = sizeof( struct SCSICmd );
      io->io_Data         = (APTR) &SC;

      SC.scsi_Data        = (UWORD *) cd;
      SC.scsi_Length      = sizeof( struct CapacityData );
      SC.scsi_Command     = command;
      SC.scsi_CmdLength   = 6;

#     ifdef SCSIF_AUTOSENSE
      SC.scsi_Flags       = SCSIF_READ | SCSIF_AUTOSENSE;
      SC.scsi_SenseData   = senseData;
      SC.scsi_SenseLength = MAXBUF;
      SC.scsi_SenseActual = 0;
#     else
      SC.scsi_Flags       = SCSIF_READ;
#     endif

      command[0] = 0x25;       // READ CAPACITY Command
      command[1] = LUN << 5;
      command[2] = 0;
      command[3] = 0;
      command[4] = 0;
      command[5] = 0;
      command[6] = 0;
      command[7] = 0;
      command[8] = 0;
      command[9] = 0;

      (void) DoIO( (struct IORequest *) io );

//      printf( "io_Error         = %d\n", io->io_Error );
//      printf( "scsi_Status      = %d\n", SC.scsi_Status );
//      printf( "scsi_CmdActual   = %d\n", SC.scsi_CmdActual );
//      printf( "scsi_Actual      = %d\n", SC.scsi_Actual );

#     ifdef SCSIF_AUTOSENSE
//      printf( "scsi_SenseActual = %d\n",  SC.scsi_SenseActual );

      if (SC.scsi_SenseActual != 0)
         {
         UWORD i;

         printf( "\nSenseData:" );

         for (i = 0; i < SC.scsi_SenseActual; ++i)
            printf( " 0x%02x", senseData[i] );

         printf( "\n" );
         }
#     endif

      if (io->io_Error == 0)
         {
         printf( "\nHighest Sector = %d\n", cd->HighSector );
         printf( "Sector Size    = %d\n", cd->SectorSize );
         }
      }

   ShutdownProgram( TRUE ); // device was opened or else we would not get here!
         
   return( rval );
}

/* ---------------- END of ReadCapacity.c file! -------------------- */
