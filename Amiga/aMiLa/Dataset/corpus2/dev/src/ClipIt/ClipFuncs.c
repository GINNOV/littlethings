/****h *ClipFuncs.c *************************************************
**
** NAME
**    ClipFuncs.c
**
** NOTES
**    Entered from RKM Devices manual, pgs. 50-56.  Provide 
**    standard clipboard device interface routines such as
**    Open, Close, Post, Read, Write, etc.
**
**    These functions are useful for writing & reading simple
**    FTXT.  Writing & reading complex FTXT, ILBM, etc., requires
**    more work & usage of the iffparse.library.
**
** FUNCTIONAL INTERFACE:
**
**   PUBLIC char *CBGetIFFError( int errornum );
**
**   PUBLIC struct IOClipReq *CBOpen( ULONG unit );
**
**   PUBLIC char *FillCBData( struct IOClipReq *ior, ULONG size );
**   PUBLIC char *CBReadCHRS( struct IOClipReq *ior );
**
**   PUBLIC int   FTXTFileToClip( char *filename, int clipnumber );
**   PUBLIC int   ILBMFileToClip( char *filename, int clipnumber );
**
**   PUBLIC int   FileToFTXT( int clipunitnum, char *filename );
**
**   PUBLIC int   ClipToFile( int clipnumber,  char *filename );
**   PUBLIC int   FTXTToFile( int clipunitnum, char *filename );
**
**   PUBLIC int   WriteFTXTHeader( struct IOClipReq *ior, int textlength );
**
**   PUBLIC void  CBClose(     struct IOClipReq *ior );
**   PUBLIC int   ReadLong(    struct IOClipReq *ior, ULONG *ldata );
**   PUBLIC int   CBWriteFTXT( struct IOClipReq *ior, char *string );
**   PUBLIC void  CBReadDone(  struct IOClipReq *ior );
**   PUBLIC int   CBQueryFTXT( struct IOClipReq *ior );
**   PUBLIC int   CBUpdate(    struct IOClipReq *ior );
**   PUBLIC void  CBFreeBuf(   char *buf             );
**
**   PUBLIC ULONG FindCurrentWriteID( void );
**   PUBLIC ULONG FindCurrentReadID( void );
**
**   PUBLIC int   PostFTXTClip( int unitnum, char *buffer );
**
**   PUBLIC struct IOClipReq 
**          *OpenHookedCB( LONG unit,  
**                         ULONG(*hookfunc)( struct Hook *, 
**                                           void *, 
**                                           void * 
**                                         )
**                       );
**
**   PUBLIC void CloseHookedCB( struct IOClipReq *clipIO );
**
**   PRIVATE void ClearBuffer( char *buffer, int length );
**   PRIVATE int  WriteLong( struct IOClipReq *ior, long  *ldata );
**
**   PRIVATE ULONG __asm hookEntry( register __a0 struct Hook *h, 
**                                  register __a2 void *obj, 
**                                  register __a1 void *msg
**                                );
**
**   PRIVATE void InitHook( struct Hook *h, 
**                          ULONG (*func)( struct Hook *, 
**                                         void *, 
**                                         void *
**                                       ), 
**                          void *data
**                        );
**
*********************************************************************
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>          // level 1 access flags.

#include <exec/types.h>
#include <exec/ports.h>
#include <exec/io.h>
#include <exec/memory.h>

#include <dos/dos.h>

#include <AmigaDOSErrs.h>

#include <devices/clipboard.h>

#include <libraries/dos.h>
#include <libraries/iffparse.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/iffparse_protos.h>
#include <clib/alib_protos.h>

#define CLIPFUNCS_C 
# include "cb.h"        // Still needed.
#undef  CLIPFUNCS_C

PRIVATE char Version[] = "$VER: ClipFuncs 1.0 (01/20/1999) by J.T. Steichen";


IMPORT ULONG SysBase, DOSBase; // ???????????

struct Library *IFFParseBase = NULL;

// Disable Ctrl-C checking in the SAS startup code:

PUBLIC int CXBRK( void )    { return 0; }
PUBLIC int chkabort( void ) { return 0; }

/****h *CBGetIFFError() ------------------------------------------
**
** NAME
**    CBGetIFFError()
**
** DESCRIPTION
**    Return an error message for the given error number.
** ---------------------------------------------------------------
*/

PUBLIC char *CBGetIFFError( int errornum )
{
   return( CBErrMsgs[ -errornum - 1 ] );
}

/****i *ClipFuncs.c/ClearBuffer() --------------------------------
**
** SYNOPSIS
**     void ClearBuffer( char *buffer, int buffer_length );
**
** ---------------------------------------------------------------
*/

PRIVATE void ClearBuffer( char *buffer, int length )
{
   int i;
   
   for (i = 0; i < length; i++)
      *(buffer + i) = '\0';

   return;
}

/****i *ClipFuncs/CBClose() ---------------------------------------
**
** SYNOPSIS
**   void CBClose( struct IOClipReq *ior )
**
** DESCRIPTION
**   Close the clipboard device unit which was opened via
**   CBOpen().
** ---------------------------------------------------------------- 
*/

#ifndef USE_IFFPARSE

PUBLIC void CBClose( struct IOClipReq *ior )
{
   struct MsgPort *mp;   

   if (ior == NULL)
      return;

   mp = ior->io_Message.mn_ReplyPort;
   
   CloseDevice( (struct IORequest *) ior );
   DeleteExtIO( (struct IORequest *) ior );
   DeletePort( mp );
   return;
}

#else

PRIVATE struct IFFHandle *CB_IFF = NULL;

PUBLIC void CBCloseIFF( struct IFFHandle *iffh )
{
   if (iffh != NULL)
      {
      CloseIFF( iffh );

      if (iffh->iff_Stream)
         CloseClipboard( (struct ClipboardHandle *) iffh->iff_Stream );

      FreeIFF( iffh );

      iffh = NULL;
      }

   if (IFFParseBase != NULL)
      {
      CloseLibrary( IFFParseBase );
      IFFParseBase = NULL;
      }

   return;
}

#endif


/****i *ClipFuncs/CBOpen() ---------------------------------------
**
** SYNOPSIS
**
**     ior = (struct IOClipReq *) CBOpen( ULONG unit )
**
** DESCRIPTION
**     Open the clipboard device.  A clipboard unit number must
**     be given.  By default, the unit number should be 0.  Valid
**     range is 0 to 255.
** ---------------------------------------------------------------
*/

#ifndef USE_IFFPARSE

PUBLIC struct IOClipReq *CBOpen( ULONG unit )
{
   struct MsgPort  *mp  = NULL;
   struct IOStdReq *ior = NULL;

   if (unit > 255 || unit < 0)
      return( NULL );
      
   if ((mp = CreatePort( 0L, 0L )) == NULL)
      return( NULL );
      
   if ((ior = CreateExtIO( mp, sizeof( struct IOClipReq ) )) == NULL)
      {
      DeletePort( mp );
      return( NULL );
      }

   if (OpenDevice( "clipboard.device", unit, 
                   (struct IORequest *) ior, 0L ) != 0)
      {
      DeleteExtIO( (struct IORequest *) ior );
      DeletePort( mp );
      return( NULL );
      }
   else
      return( (struct IOClipReq *) ior );
}

#else

PUBLIC int CBOpenIFF( ULONG unit, int RWFlag )
{
   struct IFFHandle *iff  = NULL;
   int               rval = 0, error = 0;
        
   if ((IFFParseBase = OpenLibrary( "iffparse.library", 0L )) == NULL)
      return( rval );

   if ((iff = AllocIFF()) == NULL)
      {
      CloseLibrary( IFFParseBase );
      return( rval );
      }

   /* * Set up IFF_File for Clipboard I/O. */
   if ((iff->iff_Stream = (ULONG) OpenClipboard( unitnumber )) == NULL)
      {
      FreeIFF( iff );
      CloseLibrary( IFFParseBase );
      return( rval );
      }

   InitIFFasClip( iff );

   if ((error = OpenIFF( iff, RWFlag )) != 0)
      {
      if (iff->iff_Stream)
         CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );

      FreeIFF( iff );
      CloseLibrary( IFFParseBase );

      return( rval = error );
      }

   CB_IFF = iff;
   
   return( rval );
}

PUBLIC int CBWriteFTXT_IFF( ULONG unit, char *text )
{
   int rval = 0;
   
   if (CBOpenIFF( unit, IFFF_WRITE ) != 0) 
      {
      return( rval = -1 );
      }

   if ((rval = PushChunk( CB_IFF, ID_FTXT, ID_FORM, IFFSIZE_UNKNOWN )) == 0)
      {
      if ((rval = PushChunk( CB_IFF, 0, ID_CHRS, IFFSIZE_UNKNOWN )) == 0)
         {
         int textlen = strlen( text );

         if (WriteChunkBytes( CB_IFF, text, textlen ) != textlen)
            {
            rval = IFFERR_WRITE;
            }
         }

      if (rval == 0)
         rval = PopChunk( CB_IFF );
      }

   if (rval == 0)
      rval = PopChunk( CB_IFF );

   return( rval );
}

PUBLIC int CBReadFTXT_IFF( ULONG unit, char *buffer, int readsize )
{
   struct ContextNode *cn   = NULL;
   int                 rval = 0;
   
   if (CBOpenIFF( unit, IFFF_READ ) != 0) 
      {
      return( rval = -1 );
      }

   if ((rval = StopChunk( CB_IFF, ID_FTXT, ID_CHRS )) != 0)
      {
      return( rval );
      }

   /* Find all of the FTXT CHRS chunks */
   while (1)
      {
      rval = ParseIFF( CB_IFF, IFFPARSE_SCAN );
 
      if (rval == IFFERR_EOC)
         continue;            /* enter next context */
      else if (rval != 0)
         break;

      /* We only asked to stop at FTXT CHRS chunks If no error 
      ** we've hit a stop chunk Read the CHRS chunk data 
      */
      cn = CurrentChunk( CB_IFF );

      if ((cn) && (cn->cn_Type == ID_FTXT) && (cn->cn_ID == ID_CHRS))
         {
         int rlen = 0;
         
         // printf( "CHRS chunk contains:\n" );

         while ((rlen = ReadChunkBytes( CB_IFF, buffer, readsize )) > 0)
            buffer += readsize;

         if (rlen < 0)
            rval = rlen;
         }
      }

   if (rval == IFFERR_EOF)
      rval = 0;
      
   return( rval );
}

#endif

/****i *ClipFuncs/CBUpdate() ---------------------------------------
**
** SYNOPSIS
**   int success = CBUpdate( struct IOClipReq *ior )
**
** DESCRIPTION
**   Send a CMD_UPDATE command to the clipboard device.
** -------------------------------------------------------------------- 
*/

PUBLIC int CBUpdate( struct IOClipReq *ior )
{
   int success = FALSE;

   if (ior == NULL)
      return( success );  // Just in case.
      
   ior->io_Command = CMD_UPDATE;

   DoIO( (struct IORequest *) ior );

   success = ior->io_Error ? FALSE : TRUE;      

   return( success );
}

// Write a 4-byte string to the Clipboard:

PRIVATE int WriteLong( struct IOClipReq *ior, long *ldata )
{
   ior->io_Data    = (STRPTR) ldata;
   ior->io_Length  = 4L;
   ior->io_Command = CMD_WRITE;

   DoIO( (struct IORequest *) ior );
   
   if (ior->io_Actual == 4)
      return( ior->io_Error ? FALSE : TRUE );

   return( FALSE );
}

/****i *ClipFuncs/WriteFTXTHeader() -----------------------------------
**
** SYNOPSIS
**   int success = WriteFTXTHeader( struct IOClipReq *ior, int textlen )
**
** DESCRIPTION
**   Write the IFF identification header to the clipboard.
** -------------------------------------------------------------------- 
*/

PUBLIC int WriteFTXTHeader( struct IOClipReq *ior, int textlength )
{
   LONG length  = 0L;
   BOOL odd     = (textlength & 1);

   length  = (odd != 0) ? textlength + 1 : textlength;

   length += 12L;  // Header size += 'FORM' + 'FTXT' + 'CHRS'.

   if (WriteLong( ior, (long *) "FORM" ) == FALSE)
      return( -1 );
      
   if (WriteLong( ior, &length ) == FALSE)
      return( -2 );

   if (WriteLong( ior, (long *) "FTXT" ) == FALSE)
      return( -3 );
      
   if (WriteLong( ior, (long *) "CHRS" ) == FALSE)
      return( -4 );
      
   if (WriteLong( ior, (long *) &textlength ) == FALSE)
      return( -5 );

   return( 0 );
}

/****i *ClipFuncs/CBWriteFTXT() ---------------------------------------
**
** SYNOPSIS
**   int success = CBWriteFTXT( struct IOClipReq *ior, char *string )
**
** DESCRIPTION
**   Write a NULL-terminated string of text to the clipboard.
**   The string will be written in simple FTXT format.  Note that
**   this function pads odd length strings automatically to
**   conform to the IFF standard.
** -------------------------------------------------------------------- 
*/

PUBLIC int CBWriteFTXT( struct IOClipReq *ior, char *string )
{
   LONG slen = strlen( string );
   BOOL odd  = (slen & 1);

   ior->io_Offset = 0;
   ior->io_Error  = 0;
   ior->io_ClipID = 0;

   if (WriteFTXTHeader( ior, slen ) < 0)
      return( FALSE );
      
   ior->io_Data    = (STRPTR) string;
   ior->io_Length  = slen;
   ior->io_Command = CMD_WRITE;

   DoIO( (struct IORequest *) ior );

   if (odd)
      {
      // Send out a pad byte:
      ior->io_Data   = (STRPTR) "";
      ior->io_Length = 1;
      DoIO( (struct IORequest *) ior );
      }

   ior->io_Command = CMD_UPDATE;

   DoIO( (struct IORequest *) ior );

   return( (ior->io_Error != 0) ? FALSE : TRUE );
}

/****i *ClipFuncs/CBReadDone() ----------------------------------------
**
** SYNOPSIS
**   void CBReadDone( struct IOClipReq *ior )
**
** DESCRIPTION
**   Reads the clipboard file until io_Actual is zero.
**
**   THIS TELLS THE CLIPBOARD THAT WE ARE DONE READING!
** 
** SEE ALSO
**   CBQueryFTXT()
** -------------------------------------------------------------------- 
*/

PUBLIC void CBReadDone( struct IOClipReq *ior )
{
   char buffer[256];
   
   ior->io_Command = CMD_READ;
   ior->io_Data    = (STRPTR) buffer;
   ior->io_Length  = 254;

   while (ior->io_Actual > 0)
      {
      if (DoIO( (struct IORequest *) ior ))
         break;
      }

   return;
}

/****i *ClipFuncs/CBQueryFTXT() ---------------------------------------
**
** SYNOPSIS
**   int result = CBQueryFTXT( struct IOClipReq *ior )
**
** DESCRIPTION
**   Check to see if the clipboard contains FTXT.  If so, call
**   CBReadCHRS() one or more times until all CHRS chunks have
**   been read.
** -------------------------------------------------------------------- 
*/

PUBLIC int CBQueryFTXT( struct IOClipReq *ior )
{
   ULONG cbuff[4];
   
   ior->io_Offset  = 0;
   ior->io_Error   = 0;
   ior->io_ClipID  = 0;
   ior->io_Command = CMD_READ;
   ior->io_Data    = (STRPTR) cbuff;
   ior->io_Length  = 12;

   DoIO( (struct IORequest *) ior );
      
   if (ior->io_Actual == 12L)
      {
      if (cbuff[0] == ID_FORM)
         {
         if (cbuff[2] == ID_FTXT)
            {
            return TRUE;
            }
         }
      }

   CBReadDone( ior );

   return FALSE;
}

/****i *ClipFuncs/ReadLong() -----------------------------------------
**
** DESCRIPTION
**   Read a 4-byte string from the Clipboard: 
** -------------------------------------------------------------------
*/

PUBLIC int ReadLong( struct IOClipReq *ior, ULONG *ldata )
{
   ior->io_Command = CMD_READ;
   ior->io_Data    = (STRPTR) ldata;
   ior->io_Length  = 4L;

   DoIO( (struct IORequest *) ior );

   if (ior->io_Actual == 4)
      return( (ior->io_Error != 0) ? FALSE : TRUE );

   return( FALSE );
}

/****i *ClipFuncs/FillCBData() ---------------------------------------
**
** SYNOPSIS
**   char *FillCBData( struct IOClipReq *ior, ULONG size )
** ------------------------------------------------------------------- 
*/

PUBLIC char *FillCBData( struct IOClipReq *ior, ULONG size )
{
   
   register UBYTE *to, *from;
   register ULONG i;
   
   char  *buf = NULL, *success = NULL;
   ULONG  length;

   if ((size & 1) != 0)
      length = size + 1; // length has to be even!
   else
      length = size;

   if ((buf = (char *) AllocVec( length, 
                                 MEMF_PUBLIC | MEMF_CLEAR )) == NULL)
      {
      return( NULL );
      }

   ior->io_Command = CMD_READ;
   ior->io_Data    = (STRPTR) buf;
   ior->io_Length  = length;

   to              = buf; // might be yanked out later.

   if (DoIO( (struct IORequest *) ior ) != 0)
      {
      if (buf != NULL)
         {
         FreeVec( buf );
         buf = NULL;
         }

      return( buf );
      }
   else
      success = buf;

/*
   if (DoIO( (struct IORequest *) ior ) == 0)
      {
      if (ior->io_Actual == length)
         {
         success = buf;
               
         for (i = 0, from = buf; i < size; i++)
            {
            *to = *from;
            to++;
            from++;
            }

         *to = '\0';
         }
      }
*/
   if (success == NULL)
      {
      if (buf != NULL)
         {
         FreeVec( buf );
         buf = NULL;
         }
      }

   return( success );
}

/****i *ClipFuncs/CBReadCHRS() --------------------------------------
**
** SYNOPSIS
**   char *CBReadCHRS( struct IOClipReq *ior )
**
** DESCRIPTION
**   Read & return the text in the next CHRS chunk (if any)
**   from the clipboard.  Allocates memory to hold data in the
**   next CHRS chunk.
**
** NOTES
**
**  The caller MUST free the returned buffer when done with the
**  data by calling CBFreeBuf().
** ------------------------------------------------------------------ 
*/

PUBLIC char *CBReadCHRS( struct IOClipReq *ior )
{
   char  *buf = NULL;
   ULONG  chunk, size;
   int    looking = TRUE;
   
   while (looking == TRUE)
      {
      looking = FALSE;

      if (ReadLong( ior, &chunk ))
         {
         if (chunk == ID_CHRS)
            {
            if (ReadLong( ior, &size ))
               if (size != 0)
                  buf = FillCBData( ior, size ); // + 12 ???
            }
         else
            {
            if (ReadLong( ior, &size ))
               {
               looking = TRUE;
               if (size & 1)
                  size++;        /* pad odd length */

               ior->io_Offset += size;
               }
            }
         }
      }

   if (buf == NULL)
      CBReadDone( ior );

   return( buf );
}

/****i *ClipFuncs/CBFreeBuf() ---------------------------------------
**
** SYNOPSIS
**   void CBFreeBuf( char *buf )
**
** DESCRIPTION
**   Frees a buffer allocated by CBReadCHRS().
** ------------------------------------------------------------------ 
*/

PUBLIC void CBFreeBuf( char *buf )
{
   if (buf != NULL)
      {
      FreeVec( buf );
      buf = NULL;
      }

   return;
}

/****i *ClipFuncs/FindCurrentWriteID() ------------------------------
**
** SYNOPSIS
**   ULONG FindCurrentWriteID( void )
**
** ------------------------------------------------------------------ 
*/

PUBLIC ULONG FindCurrentWriteID( void )
{
   struct IOClipReq  *ior = NULL;
   
   ior->io_Command = CBD_CURRENTWRITEID;
   DoIO( (struct IORequest *) ior );

   return( (ULONG) ior->io_ClipID );
}

/****i *ClipFuncs/FindCurrentReadID() -------------------------------
**
** SYNOPSIS
**   ULONG FindCurrentReadID( void )
**
** ------------------------------------------------------------------ 
*/

PUBLIC ULONG FindCurrentReadID( void )
{
   struct IOClipReq  *ior = NULL;
   
   ior->io_Command = CBD_CURRENTREADID;
   DoIO( (struct IORequest *) ior );

   return( (ULONG) ior->io_ClipID );
}

/****i *FTXTFileToClip() ---------------------------------------------
**
** NAME
**    FTXTFileToClip()
**
** DESCRIPTION
**    Read an FTXT file & send its contents to the clipboard.
** ---------------------------------------------------------------
*/

PUBLIC int FTXTFileToClip( char *filename, int clipnumber )
{
   struct IOClipReq *outclip = NULL;
   char              buffer[ 512 ];
   int               infile = 0;
   int               readsize, rval = 0;
   
   if ((infile = open( filename, O_RDONLY, 0 )) < 0)
      return( IFFERR_READ );

   outclip = CBOpen( clipnumber );

   if (outclip == NULL)
      {
      close( infile );
      return( IFFERR_WRITE );
      }

   readsize = read( infile, buffer, 512 );

   if (readsize > 0)
      {
      int chk = 0;
      
      if (strncmp( buffer, "FORM", 4 ) == 0)
         chk = 0;
      else
         {
         rval = IFFERR_NOTIFF;
         goto ExitFTXTFileToClip;
         }   
      
      if (strncmp( &buffer[8], "FTXT", 4 ) == 0)
         chk = 0;
      else
         {
         rval = IFFERR_NOTIFF;
         goto ExitFTXTFileToClip;
         }   
      
      if (strncmp( &buffer[12], "CHRS", 4 ) == 0)
         chk = 0;
      else
         {
         rval = IFFERR_NOTIFF;
         goto ExitFTXTFileToClip;
         }   
      
      if (chk == 0)
         {
         outclip->io_Data    = (STRPTR) buffer;
         outclip->io_Length  = readsize;
         outclip->io_Command = CMD_WRITE;

         DoIO( (struct IORequest *) outclip );
         }
      }

   // Now, do the rest of the file:

   while ((readsize = read( infile, buffer, 512 )) > 0)
      {
      outclip->io_Data    = (STRPTR) buffer;
      outclip->io_Length  = readsize;
      outclip->io_Command = CMD_WRITE;

      DoIO( (struct IORequest *) outclip );
      }

   outclip->io_Command = CMD_UPDATE;

   DoIO( (struct IORequest *) outclip );

   rval = outclip->io_Error;

ExitFTXTFileToClip:

   close( infile );
   CBClose( outclip );

   return( rval );
}

/****i *ILBMFileToClip() ---------------------------------------------
**
** NAME
**    ILBMFileToClip()
**
** DESCRIPTION
**    Read an ILBM file & send its contents to the clipboard.
** ---------------------------------------------------------------
*/

PUBLIC int ILBMFileToClip( char *filename, int clipnumber )
{
   struct IOClipReq *outclip = NULL;

   char buffer[ 512 ];
   int  infile = 0;
   int  readsize, rval = 0;
   
   if ((infile = open( filename, O_RDONLY, 0 )) < 0)
      return( IFFERR_READ );

   outclip = CBOpen( clipnumber );

   if (outclip == NULL)
      {
      close( infile );
      return( IFFERR_WRITE );
      }

   readsize = read( infile, buffer, 512 );

   if (readsize > 0)
      {
      int chk = 0;
      
      if (strncmp( buffer, "FORM", 4 ) == 0)
         chk = 0;
      else
         {
         rval = IFFERR_NOTIFF;
         goto ExitILBMFileToClip;
         }   
      
      if (strncmp( &buffer[8], "ILBM", 4 ) == 0)
         chk = 0;
      else
         {
         rval = IFFERR_NOTIFF;
         goto ExitILBMFileToClip;
         }   
      
      if (chk == 0)
         {
         outclip->io_Data    = (STRPTR) buffer;
         outclip->io_Length  = readsize;
         outclip->io_Command = CMD_WRITE;

         DoIO( (struct IORequest *) outclip );
         }
      }

   // Now, do the rest of the file:

   while ((readsize = read( infile, buffer, 512 )) > 0)
      {
      outclip->io_Data    = (STRPTR) buffer;
      outclip->io_Length  = readsize;
      outclip->io_Command = CMD_WRITE;

      DoIO( (struct IORequest *) outclip );
      }

   outclip->io_Command = CMD_UPDATE;

   DoIO( (struct IORequest *) outclip );

   rval = outclip->io_Error;

ExitILBMFileToClip:

   close( infile );
   CBClose( outclip );

   return( rval );
}

/****i *ClipToFile() ---------------------------------------------
**
** NAME
**    ClipToFile()
**
** DESCRIPTION
**    Read a clipboard & send its contents to an FTXT file.
** ---------------------------------------------------------------
*/

PUBLIC int ClipToFile( int clipnumber, char *filename )
{
   struct IOClipReq *inclip  = NULL;
   int               outfile = -1;
   char              buffer[ 512 ];
   int               rval = 0;
   
   if ((outfile = open( filename, O_WRONLY | O_CREAT, 0 )) < 0)
      return( -1 );

   inclip = CBOpen( clipnumber );

   if (inclip == NULL)
      {
      close( outfile );
      return( -2 );
      }

   inclip->io_Data    = (STRPTR) buffer;
   inclip->io_Length  = 512;
   inclip->io_Command = CMD_READ;

   DoIO( (struct IORequest *) inclip );

   while (inclip->io_Actual > 0)
      {
      rval = write( outfile, buffer, 512 );

      if (rval < 0)
         {
         close(      outfile );
         CBReadDone( inclip  ); // Probably not necessary.
         CBClose(    inclip  );
         return( -3 );
         }

      inclip->io_Data    = (STRPTR) buffer;
      inclip->io_Length  = 512;
      inclip->io_Command = CMD_READ;

      DoIO( (struct IORequest *) inclip );
      }
   
   close(      outfile );
   CBReadDone( inclip  ); // Probably not necessary.
   CBClose(    inclip  );

   return( 0 );   
}

/****i *ClipFuncs/GetFileLength() ------------------------------------
**
** DESCRIPTION
**   Determine the length of a level-1 file (in bytes), then
**   rewind the file.
** -------------------------------------------------------------------
*/

PRIVATE int GetFileLength( int filenumber )
{
   char buffer[512];
   int  rval = 0, size = 0;
   
   while ((size = read( filenumber, buffer, 512 )) > 0)
      rval += size;
      
   (void) lseek( filenumber, -rval, 1 );
   
   return( rval ); 
}

/****i *ClipFuncs/FileToFTXT() --------------------------------------
**
** SYNOPSIS
**   int FileToFTXT( int unitnum, char *filename )
**
** DESCRIPTION
**   Sends ASCII file to the Clipboard as FTXT.  This is basically
**   a means to translate ASCII to a clip.
** ------------------------------------------------------------------ 
*/

PUBLIC int FileToFTXT( int clipunitnum, char *filename )
{
   struct IFFHandle *iff = NULL;
   long              error = 0;
   char              buffer[ 512 ];
   int               infile = 0;
   int               readsize, filelength = 0;
       
   if ((clipunitnum < 0) || (clipunitnum > 255))
      clipunitnum = 0;

   if ((IFFParseBase = OpenLibrary( "iffparse.library", 0L )) == NULL)
      return( -1 );
      
   if ((infile = open( filename, O_RDONLY, 0 )) < 0)
      {
      CloseLibrary( IFFParseBase );
      return( -2 );
      }

   /* * Allocate IFF_File structure. */
   if ((iff = AllocIFF()) == NULL)
      {
      close( infile );
      CloseLibrary( IFFParseBase );
      return( -3 );
      }

   /* * Set up IFF_File for Clipboard I/O. */
   if ((iff->iff_Stream = (ULONG) OpenClipboard( clipunitnum )) == NULL)
      {
      FreeIFF( iff );
      close( infile );
      CloseLibrary( IFFParseBase );
      return( -4 );
      }

   InitIFFasClip( iff );

   /* * Start the IFF transaction. */
   if (error = OpenIFF( iff, IFFF_WRITE ))
      {
      CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
      FreeIFF( iff );
      close( infile );
      CloseLibrary( IFFParseBase );
      return( -5 );
      }

   /* Write our text to the clipboard as CHRS chunk in FORM FTXT
   ** 
   ** First, write the FORM ID (FTXT) 
   */

   if ((error = PushChunk( iff, ID_FTXT, ID_FORM, IFFSIZE_UNKNOWN )) != 0)
      {
      CloseIFF( iff );
      CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
      FreeIFF( iff );
      close( infile );
      CloseLibrary( IFFParseBase );
      return( -6 );
      }

   filelength = GetFileLength( infile );

   /* Now the CHRS chunk ID followed by the chunk data We'll 
   ** just write one CHRS chunk. You could write more chunks. 
   */
   if ((error = PushChunk( iff, 0, ID_CHRS, filelength )) != 0)
      {
      CloseIFF( iff );
      CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
      FreeIFF( iff );
      close( infile );
      CloseLibrary( IFFParseBase );
      return( -7 );
      }

   ClearBuffer( buffer, 512 );

   /* Now the actual data (the text) */
   while ((readsize = read( infile, buffer, 512 )) > 0)
      {
      if (WriteChunkBytes( iff, buffer, readsize ) != readsize)
         {
         error = IFFERR_WRITE;
         CloseIFF( iff );
         CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
         FreeIFF( iff );
         close( infile );
         CloseLibrary( IFFParseBase );
         return( error );
         }

      ClearBuffer( buffer, 512 );
      }

   if (error == 0)
      error = PopChunk( iff );

   if (error == 0)
      error = PopChunk( iff );

   if (error != 0)
      {
      CloseIFF( iff );
      CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
      FreeIFF( iff );
      close( infile );
      CloseLibrary( IFFParseBase );
      return( error );
      }

   CloseIFF( iff );
   CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
   FreeIFF( iff );
   close( infile );
   CloseLibrary( IFFParseBase );

   return( 0 );
}

/****i *ClipFuncs/FTXTToFile() --------------------------------------
**
** SYNOPSIS
**   int FTXTToFile( int unitnum, char *filename )
**
** DESCRIPTION
**   Sends the FTXT in the Clipboard to an ASCII file.  This is
**   a means to translate an FTXT Clip to ASCII.
** 
** WARNING
**   This function assumes that there is only one simple CHRS-type
**   chunk in the clip.
** ------------------------------------------------------------------ 
*/

PUBLIC int FTXTToFile( int clipunitnum, char *filename )
{
   struct IFFHandle   *iff = NULL;
   struct ContextNode *cn  = NULL;

   long                error = 0, rlen = 0;
   char                buffer[ 512 ];
   int                 outfile = 0;
   int                 rval = 0;
   
   if ((clipunitnum < 0) || (clipunitnum > 255))
      clipunitnum = 0;
      
   if ((IFFParseBase = OpenLibrary( "iffparse.library", 0L )) == NULL)
      {
      return( -1 );
      }

   if ((outfile = open( filename, O_WRONLY | O_CREAT, 0 )) < 0)
      {
      CloseLibrary( IFFParseBase );
      return( -2 );
      }

   /* * Allocate IFF_File structure. */
   if ((iff = AllocIFF()) == NULL)
      {
      close( outfile );
      CloseLibrary( IFFParseBase );
      return( -3 );
      }

   if ((iff->iff_Stream = (ULONG) OpenClipboard( clipunitnum )) == NULL)
      {
      FreeIFF( iff );
      close( outfile );
      CloseLibrary( IFFParseBase );
      return( -4 );
      }

   InitIFFasClip( iff );

   if ((error = OpenIFF( iff, IFFF_READ )) != 0)
      {
      CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
      FreeIFF( iff );
      close( outfile );
      CloseLibrary( IFFParseBase );
      return( error );
      }

   /* Tell iffparse we want to stop on FTXT CHRS chunks */
   if ((error = StopChunk( iff, ID_FTXT, ID_CHRS )) != 0)
      {
      CloseIFF( iff );
      CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
      FreeIFF( iff );
      close( outfile );
      CloseLibrary( IFFParseBase );
      return( error );
      }


   while (1)
      {
      /* Find all of the FTXT CHRS chunks */      
      
      error = ParseIFF( iff, IFFPARSE_SCAN );
 
      if (error == IFFERR_EOC)
         continue;   /* enter next context */

      else if (error != 0)
         break;

      /* We only asked to stop at FTXT CHRS chunks.  If no error,
      ** we've hit a stop chunk.  Read the CHRS chunk data:
      */
      cn = CurrentChunk( iff );

      if ((cn != NULL) && (cn->cn_Type == ID_FTXT) 
                       && (cn->cn_ID == ID_CHRS))
         {
         ClearBuffer( buffer, 512 );

         while ((rlen = ReadChunkBytes( iff, buffer, 512 )) > 0)
            {
            rval = write( outfile, buffer, rlen );

            if (rval < 0)
               {
               CloseIFF( iff );

               CloseClipboard( (struct ClipboardHandle *) 
                               iff->iff_Stream 
                             );

               FreeIFF( iff );
               close( outfile );
               CloseLibrary( IFFParseBase );
               return( -7 );
               }

            ClearBuffer( buffer, 512 );
            }

         if (rlen < 0)
            error = rlen;
         }
      }

   rval = 0; 
   if ((error != 0) && (error != IFFERR_EOF))
      rval = error;

   CloseIFF( iff );
   CloseClipboard( (struct ClipboardHandle *) iff->iff_Stream );
   FreeIFF( iff );
   close( outfile );
   CloseLibrary( IFFParseBase );

   return( rval );
}

/****i *ClipFuncs/PostFTXTClip() ----------------------------------------
**
** SYNOPSIS
**   int PostFTXTClip( int unitnum, char *buffer )
**
** DESCRIPTION
**   Sends an FTXT to the Clipboard & waits for a SatisfyMsg.
** ------------------------------------------------------------------ 
*/

PUBLIC int PostFTXTClip( int unitnum, char *buffer )
{
   struct MsgPort    *satisfy = NULL;
   struct SatisfyMsg *sm      = NULL;
   struct IOClipReq  *ior     = NULL;
   int               mustwrite;
   ULONG             postID, writeID;
   
   if (buffer == NULL)
      return( -1 );

   if ((satisfy = CreatePort( 0L, 0L )) == NULL)
      return( -2 );
      
   if ((ior = CBOpen( (LONG) unitnum )) == NULL)
      {
      DeletePort( satisfy );
      return( -3 );
      }

   mustwrite       = FALSE;
   ior->io_Data    = (STRPTR) satisfy;
   ior->io_ClipID  = 0L;
   ior->io_Command = CBD_POST;

   DoIO( (struct IORequest *) ior );

   postID = ior->io_ClipID;

   Wait( SIGBREAKF_CTRL_C | (1L << satisfy->mp_SigBit) );
        
   if (sm = (struct SatisfyMsg *) GetMsg( satisfy ))
      mustwrite = TRUE;
   else
      {
      writeID = FindCurrentWriteID();

      if (postID >= writeID)
         mustwrite = TRUE;
      }

   if (mustwrite == TRUE)
      {
      if (CBWriteFTXT( ior, buffer ) == FALSE)
         {
         CBClose( ior );
         DeletePort( satisfy );
         return( -4 );
         }
      }

   CBClose( ior );
   DeletePort( satisfy );

   return( 0 );
}

/****i *ChangeHookFunctions ******************************************
**
** NOTES 
**    Modified the ChangeHook_Test.c file from RKM Devices manual,
**    pgs. 48-49.
**
** The DEBUG code will set a hook & wait for the clipboard data to
** change.  You must put something in the clipboard in order for
** it to return.  Run from the CLI only!
**
**********************************************************************
*/

struct CHData  {
   
   struct Task *ch_Task;
   LONG         ch_ClipID;
};


/****i *hookEntry() -------------------------------------------------
**
** NAME
**    hookEntry();
**
** NOTES
**    Register calling convention:
**
**      A0 - pointer to the hook itself.
**      A1 - pointer to the parameter packed ("message")
**      A2 - Hook-specific address data ("object", such as gadget)
**
** ------------------------------------------------------------------
*/

PRIVATE ULONG __asm hookEntry( register __a0 struct Hook *h, 
                               register __a2 void *obj, 
                               register __a1 void *msg
                             )
{
   return( (*h->h_SubEntry)( h, obj, msg ) );
}

/****i *InitHook() --------------------------------------------------
**
** NAME
**    InitHook() - Setup the hook structure.
** ------------------------------------------------------------------
*/

PRIVATE void InitHook( struct Hook *h, 
                       ULONG      (*func)( struct Hook *, void *, void * ),
                       void        *data
                     )
{
   if (h != NULL)
      {
      h->h_Entry    = (ULONG (*)( struct Hook *, 
                                  void *, 
                                  void * )) hookEntry;
      h->h_SubEntry = func;
      h->h_Data     = data;
      }

   return;
}

// Arrrggghhh!!!! Global variables:

PRIVATE struct Hook    hook;
PRIVATE struct CHData  ch;

/****i *OpenHookedCB() -----------------------------------------
**
** NAME
**    OpenHookedCB() - Open the clipboard with a change hook.
** -------------------------------------------------------------
*/

PUBLIC struct IOClipReq *OpenHookedCB( LONG unit,  
                                       ULONG(*hookfunc)( struct Hook *, 
                                                         void *, 
                                                         void * 
                                                       )
                                     )
{
   struct IOClipReq *clipIO;
   
   if (clipIO = CBOpen( unit ))
      {
      clipIO->io_Data    = (char *) &hook;
      clipIO->io_Length  = 1;
      clipIO->io_Command = CBD_CHANGEHOOK;
      
      ch.ch_Task         = FindTask( NULL );
      
      InitHook( &hook, hookfunc, &ch );

      if (DoIO( (struct IORequest *) clipIO ) != 0)
         printf( "Unable to set hook.\n" );
      else
         printf( "hook set.\n" );

      return( clipIO );
      }

   return NULL;
}

/****i *CloseHookedCB() ----------------------------------------------
**
** NAME
**    CloseHookedCB() - Close the clipboard & kill the change hook.
** -------------------------------------------------------------------
*/

PUBLIC void CloseHookedCB( struct IOClipReq *clipIO )
{
   clipIO->io_Data    = (char *) &hook;
   clipIO->io_Length  = 0;
   clipIO->io_Command = CBD_CHANGEHOOK;
   
   if (DoIO( (struct IORequest *) clipIO ) != 0)
      printf( "Unable to stop hook!\n" );
   else
      printf( "Hook stopped.\n" );

   CBClose( clipIO );
   return;
}      


#ifdef DEBUG_HOOK

/****i *clipHook() -------------------------------------------------
**
** NAME
**    clipHook() - where the actual work gets done.
** -----------------------------------------------------------------
*/

PRIVATE ULONG clipHook( struct Hook *h, void *c, struct ClipHookMsg *msg )
{
   struct CHData *ch = (struct CHData *) h->h_Data;

   geta4();   // Make sure that A4 has the Global Data Segment.

   if (ch != NULL)
      {
      ch->ch_ClipID = msg->chm_ClipID;

      Signal( ch->ch_Task, SIGBREAKF_CTRL_E );
      }

   return( 0 );
}


PUBLIC void  main( int argc, char **argv )
{
   struct IOClipReq  *clipIO  = NULL;
   ULONG             sig_rcvd = 0L;

   printf( "%s\n", argv[0] );

   if (clipIO = OpenHookedCB( 0L, clipHook ))
      {
      sig_rcvd = Wait( (SIGBREAKF_CTRL_C | SIGBREAKF_CTRL_E) );

      if (sig_rcvd & SIGBREAKF_CTRL_C)
         printf( "^C received!\n" );

      if (sig_rcvd & SIGBREAKF_CTRL_E)
         printf( "Clipboard change, current ID = %ld\n", ch.ch_ClipID );

      CloseHookedCB( clipIO );
      }

   return;
}

#endif


/* ------------------ END of ClipFuncs.c file! ---------------------- */
