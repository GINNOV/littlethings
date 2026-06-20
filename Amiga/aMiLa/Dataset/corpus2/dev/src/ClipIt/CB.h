/****h *CB.h ***********************************************************
**
** NAME
**    CB.h  -  Used by ClipFuncs.c
************************************************************************
*/

#ifndef  CB_H
# define CB_H  1

# ifndef MAKE_ID
#  define MAKE_ID(a,b,c,d) ((a << 24L) | (b << 16L) | (c << 8L) | d)
# endif
 
# ifndef ID_FORM
#  define ID_FORM   MAKE_ID('F', 'O', 'R', 'M')
# endif

# define ID_FTXT   MAKE_ID('F', 'T', 'X', 'T')
# define ID_CHRS   MAKE_ID('C', 'H', 'R', 'S')

# ifndef ID_ILBM
#  define ID_ILBM   MAKE_ID('I', 'L', 'B', 'M')
# endif

# ifdef CLIPFUNCS_C

/*
** Text error messages for possible IFFERR_#? returns from various
** IFF routines.  To get the index into this array, take your IFFERR code,
** negate it, and subtract one.
** example: 
**
**   idx = -error - 1;
**   fprintf( stderr, "IFF ERROR:  %s", errormsgs[ idx ] );
*/

PUBLIC char *CBErrMsgs[] = {

   "End of file (not an error).",
   "End of context (not an error).",
   "No lexical scope.",
   "Insufficient memory.",
   "Stream read error.",
   "Stream write error.",
   "Stream seek error.",
   "File is corrupt.",
   "IFF syntax error.",
   "Not an IFF file.",
   "Required call-back hook missing.",
   "Return to client.  You should never see this."
};

# else

IMPORT char *CBErrMsgs[];

# endif

IMPORT char *CBGetIFFError( int errnum );

IMPORT struct IOClipReq *CBOpen( ULONG unit );

IMPORT char *CBReadCHRS( struct IOClipReq *ior               );
IMPORT char *FillCBData( struct IOClipReq *ior, ULONG size   );
IMPORT int   ReadLong(   struct IOClipReq *ior, ULONG *ldata );

IMPORT int   FileToClip( char *filename,  int   clipnumber );
IMPORT int   FileToFTXT( int clipunitnum, char *filename   );

IMPORT int   ClipToFile( int clipnumber,  char *filename );
IMPORT int   FTXTToFile( int clipunitnum, char *filename );

IMPORT int   WriteFTXTHeader( struct IOClipReq *ior, int textlength );

IMPORT void  CBClose(     struct IOClipReq *ior );
IMPORT int   CBWriteFTXT( struct IOClipReq *ior, char *string );
IMPORT void  CBReadDone(  struct IOClipReq *ior );
IMPORT int   CBQueryFTXT( struct IOClipReq *ior );
IMPORT int   CBUpdate(    struct IOClipReq *ior );

IMPORT void  CBFreeBuf(   char *buf );

IMPORT ULONG FindCurrentWriteID( void );
IMPORT ULONG FindCurrentReadID(  void );

IMPORT int   PostFTXTClip( int unitnum, char *buffer );

IMPORT struct IOClipReq *OpenHookedCB( LONG unit,  
                                       ULONG(*hookfunc)( struct Hook *, 
                                                         void *, 
                                                         void * 
                                                       )
                                     );

IMPORT void CloseHookedCB( struct IOClipReq *clipIO );

#endif

/* ------------------ END of CB.h file! --------------------------- */
