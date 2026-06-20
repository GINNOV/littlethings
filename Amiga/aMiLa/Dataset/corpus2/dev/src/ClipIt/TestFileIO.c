/****h *TestFileIO.c **************************************************
** 
** NAME
**    TestFileIO.c
**
** DESCRIPTION
**    Check the operation of various level 1 & 2 file functions.
**
** HISTORY
**    02/02/99 - Created the file.
**
***********************************************************************
*/

#include <stdio.h>
#include <string.h>
#include <fcntl.h>         // for level 1 modes (O_RDONLY, etc).
#include <error.h>         // for errno values.

#include <exec/types.h>
#include <exec/io.h>

#include <AmigaDOSErrs.h>

#include <devices/clipboard.h>

#include <dos/exall.h>
#include <dos.h>           // system-independent IO.

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include "CB.h"


PRIVATE char Ver[] = "\0$VER: TestFileIO 1.0 (02/02/1999) by J.T. Steichen";

PRIVATE int TranslateToFile( int ClipNum, char *filename )
{
   if (strlen( filename ) < 1)   
      {
      return( -1 );
      }

   if (FTXTToFile( ClipNum, filename ) < 0)
      {
      return( -2 );
      } 

   return( 0 );
}

PRIVATE int TranslateToClip( int ClipNum, char *filename )
{
   if (strlen( filename ) < 1)   
      {
      return( -1 );
      }

   if (FileToFTXT( ClipNum, filename ) < 0)
      {
      return( -2 );
      }
      
   return( 0 );
}

// ------------------------------------------------------------------

PUBLIC int main( int argc, char **argv )
{
   int clipnumber;
   
   if (argc != 3)
      {
      fprintf( stderr, "USAGE:  %s clip# filename\n", argv[0] );
      return( RETURN_FAIL );
      }

   clipnumber = atoi( argv[1] );

   if (clipnumber < 0 || clipnumber > 255)
      clipnumber = 0;
  
   if (TranslateToClip( clipnumber, argv[2] ) < 0)
      {
      fprintf( stderr, "TranslateToClip() failed!\n" );
      }
               
   if (TranslateToFile( clipnumber, argv[2] ) < 0)
      {
      fprintf( stderr, "TranslateToFile() failed!\n" );
      }
   
   return( RETURN_OK );  
}

/* ----------------- END of TestFileIO.c file! ---------------------- */
