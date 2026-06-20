/****h* ReadSector.c [2.0] ********************************************************
*
* NAME
*    ReadSector.c
*
* SYNOPSIS
*    int rval = ReadSector deviceName unitNumber sectorNumber
*
* DESCRIPTION
*    Read a sector using User-supplied parameters.
*
* COPYRIGHT
*    Copyright (C) 1990 by Ralph Babel, Falkenweg 3, D-6204 Taunusstein, FRG
*    all rights reserved - alle Rechte vorbehalten
*
* HISTORY
*    03-Jun-1990 - created
*    31-Oct-1995 - Modified to use stdio & to accept user paramenters.
*    17-Nov-2004 - Ported to AmigaOS4 & gcc.
***********************************************************************************
*
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <exec/types.h>
#include <exec/memory.h>

#include <AmigaDOSErrs.h>

#include <devices/trackdisk.h>
#include <libraries/dos.h>

#ifndef __amigaos4__

# include <proto/exec.h>
# include <proto/dos.h>

PRIVATE STRPTR v = "\0$VER: ReadSector 2.0 " __AMIGADATE__ " by Ralph Babel\0";

#else

# include <clib/exec_protos.h>

# define __USE_INLINE__

# include <proto/exec.h>
# include <proto/dos.h>

IMPORT struct Library *SysBase;
IMPORT struct Library *DOSBase;

IMPORT struct ExecIFace *IExec;
IMPORT struct DOSIFace  *IDOS;

PRIVATE STRPTR v = "\0$VER: ReadSector 2.0 " __DATE__ " by Ralph Babel (Ported to AmigaOS4 by J.T. Steichen)\0";

#endif

#define BOARD 0 /* controller board */
#define LUN   0 /* logical unit */

PRIVATE int     TID   = 1;

#define UNIT  (BOARD * 100 + LUN * 10 + TID)

PRIVATE UBYTE           *data = NULL;
PRIVATE struct MsgPort  *mp   = NULL;
PRIVATE struct IOStdReq *io   = NULL;

PRIVATE void ShutdownProgram( BOOL deviceOpened )
{
   if (deviceOpened)
      CloseDevice( (struct IORequest *) io );

   if (io)
      DeleteStdIO( (struct IORequest *) io );

   if (mp)
      DeletePort( mp );

   if (data)
      FreeVec( data );

   return;
}

PRIVATE int SetupProgram( STRPTR deviceName, ULONG unitNumber )
{
   int rval = RETURN_OK;

   if (!(data = AllocVec( TD_SECTOR, MEMF_CLEAR | MEMF_SHARED ))) // MEMF_CHIP )))
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
   char  *s = NULL;
   UBYTE *p = NULL;
   UWORD  i, j, secnum = 0;
   UBYTE  d;
   char   buffer[80] = "";
   int    rval       = RETURN_OK;
   
   if (argc == 0)
      return( RETURN_ERROR ); // No Workbench support (yet!)
   
   if (argc == 3)
      TID = atoi( argv[2] );
   else if (argc == 4)
      {
      TID    = atoi( argv[2] );
      secnum = atoi( argv[3] );
      }   
   else
      {
      fprintf( stderr, "USAGE:  %s DEVICENAME/A,UNITNUMBER/N,SECTORNUMBER/K\n", argv[0] );

      return( ERROR_REQUIRED_ARG_MISSING );
      }

   // Should probably get the User to pass in LUN & Board number as well.
   
   if (SetupProgram( argv[1], UNIT ) != RETURN_OK)
      {
      fprintf( stderr, "Could NOT setup %s program!\n", argv[0] );

      return( RETURN_FAIL );
      }
   else
      {
      io->io_Command = CMD_READ;
      io->io_Length  = TD_SECTOR;
      io->io_Data    = (APTR) data;
      io->io_Offset  = TD_SECTOR * secnum; // sector offset

      (void) DoIO( (struct IORequest *) io );

      printf( "io_Error = %d\n", io->io_Error );
      printf( "Sector #%d:\n", secnum );

      if (io->io_Error == 0)
         {
         printf( "\n" );
         buffer[70] = '\0';

         for (p = data, i = 0; i < TD_SECTOR; i += 16)
            {
            sprintf( buffer, "%03x:", i );

            (void) memset( buffer + 4, ' ', 66 );

            for (s = buffer + 4, j = 0; j < 16; s += 3, ++j)
               {
               sprintf( s, " %02x", d = *p++ );

               buffer[53 + j] = d >= 32 && d <= 126 || d >= 160 ? d : '.';
               }

            *s = ' ';

            printf( "%s\n", buffer );
            }
         }

      // ALWAYS make sure the motor is turned off!

      io->io_Command = TD_MOTOR;
      io->io_Length  = 0;

      (void) DoIO( (struct IORequest *) io );
      }

   ShutdownProgram( TRUE ); // device was opened or else we would not get here!
         
   return( rval );
}

/* --------------------------- END of ReadSector.c file! ------------------------ */
