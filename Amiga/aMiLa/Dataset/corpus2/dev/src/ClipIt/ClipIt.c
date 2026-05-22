/****** ClipIt.c ******************************************************
*
* NAME
*    ClipIt.c
*
* DESCRIPTION
*    GUI for dealing with the Clipboard.
*
* HISTORY
*    01/22/99 - Deleted the menus & related code.  Added them in as
*               button gadgets.
*
* NOTES
*    Related files:
*      ClipItReq.c
*      ClipFuncs.c
*      CB.h
*      CPGM:GlobalObjects/CommonFuncs.h
*      CPGM:GlobalObjects/CommonFuncs.o
*      MakeFile
*
*  GUI Designed by : Jim Steichen
**********************************************************************
*
*/

#include <stdio.h>
#include <string.h>
#include <fcntl.h>          // level 1 access flags.

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>

#include <AmigaDOSErrs.h>

#include <devices/clipboard.h>

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>

#include <libraries/gadtools.h>
#include <libraries/asl.h>

#include <dos/dostags.h>
#include <dos/exall.h>
#include <utility/tagitem.h>

#include <dos.h>                   // system-independent IO.

#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>

#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <workbench/icon.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/diskfont_protos.h>

#include "CB.h"

#include "CPGM:GlobalObjects/CommonFuncs.h" // Non-portable.

// ----------------------------------------------------------------

#define FORMSIZE_OFFSET 8

#define StrBfPtr( g ) (((struct StringInfo *)g->SpecialInfo)->Buffer)

#define CB_CNT 18

/* Un-needed button handles are: 
   
   1  - ASL button
   14 - About program Button
*
*/

#define ClipFileName     CBGadgets[ 0  ] // The rest are buttons.
#define ClipListView     CBGadgets[ 4  ]
#define ToolTypeListView CBGadgets[ 5  ]
#define ClipSizeText     CBGadgets[ 6  ]
#define ClipTypeText     CBGadgets[ 7  ]
#define ToolTypeString   CBGadgets[ 8  ]
#define StatusText       CBGadgets[ 11 ]
#define ClipNumber       CBGadgets[ 15 ]

#define VIEWCLIPBt       CBGadgets[ 2  ]
#define MAKECLIPBt       CBGadgets[ 3  ]
#define DELETECLIPBt     CBGadgets[ 9  ]
#define EDITCLIPBt       CBGadgets[ 10 ]
#define LOADCLIPBt       CBGadgets[ 12 ]
#define SAVECLIPBt       CBGadgets[ 13 ]
#define FILE2CLIPBt      CBGadgets[ 16 ]
#define CLIP2FILEBt      CBGadgets[ 17 ]

PRIVATE char Version[] = "$VER: ClipIt! 1.0 (14/12/1999) by J.T. Steichen";

PRIVATE char TempFileName[] = "RAM:TempClip";

// ----------------------------------------------------------------

IMPORT char                  *CBErrMsgs[];

IMPORT struct WBStartup      *_WBenchMsg;
IMPORT struct DosLibraryBase *DOSBase;

// ----------------------------------------------------------------

PUBLIC struct Screen   *Scr           = NULL;
PUBLIC UBYTE           *PubScreenName = "Workbench";
PUBLIC APTR             VisualInfo    = NULL;
PUBLIC struct Window   *CBWnd         = NULL;

PUBLIC struct TextFont *CBFont        = NULL;
PUBLIC struct CompFont  CFont         = { 0, };
PUBLIC struct TextAttr  Attr          = { 0, };
PUBLIC struct TextAttr *Font          = NULL;

// ----------------------------------------------------------------

PUBLIC __far struct IntuitionBase *IntuitionBase;
PUBLIC __far struct GfxBase       *GfxBase;
PUBLIC __far struct Library       *GadToolsBase = NULL;
PUBLIC __far struct Library       *IconBase     = NULL;

PRIVATE struct Library *UtilityBase = NULL;

// TTTTTTTTT ToolTypes: TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT

PRIVATE char ClipPath[]          = "CLIPPATH=";
PRIVATE char TextEditor[]        = "TEXTEDITOR=";
PRIVATE char TextViewer[]        = "TEXTVIEWER=";
PRIVATE char ImageEditor[]       = "IMAGEEDITOR=";
PRIVATE char ImageViewer[]       = "IMAGEVIEWER=";
PRIVATE char ProgramPath[]       = "PROGRAMPATH=";

PRIVATE char DefClipPath[128]    = "Devs:clipboards";
PRIVATE char DefTextEditor[128]  = "C:Ed";
PRIVATE char DefTextViewer[128]  = "MultiView";
PRIVATE char DefImageEditor[128] = "ppaint";
PRIVATE char DefImageViewer[128] = "MultiView";
PRIVATE char DefProgramPath[128] = "ClipIt:";

PRIVATE char *TTClipPath         = &DefClipPath[0];
PRIVATE char *TTTextEditor       = &DefTextEditor[0];
PRIVATE char *TTTextViewer       = &DefTextViewer[0];
PRIVATE char *TTImageEditor      = &DefImageEditor[0];
PRIVATE char *TTImageViewer      = &DefImageViewer[0];
PRIVATE char *TTProgramPath      = &DefProgramPath[0];

// TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT

PRIVATE struct DiskObject   *diskobj = NULL;
PRIVATE char                 m[512] = "", *ErrMsg = &m[0];

// ----------------------------------------------------------------

PRIVATE struct Gadget       *CBGList = NULL;
PRIVATE struct IntuiMessage  CBMsg;
PRIVATE struct Gadget       *CBGadgets[ CB_CNT ];

PRIVATE UWORD CBLeft   = 25;
PRIVATE UWORD CBTop    = 16;
PRIVATE UWORD CBWidth  = 580;
PRIVATE UWORD CBHeight = 310;

PRIVATE UBYTE *CBWdt = (UBYTE *) "ClipIt! ©1999 Clipboard Manager:";
PRIVATE UBYTE *ScrT  = (UBYTE *) "ClipIt! ©1999 by J.T. Steichen";

// ----------------------------------------------------------------

PRIVATE struct TagItem FileTags[] = {

   ASLFR_Window,          (ULONG) NULL,
   ASLFR_TitleText,       (ULONG) "Load Clipboard...",
   ASLFR_InitialHeight,   300,
   ASLFR_InitialWidth,    400,
   ASLFR_InitialTopEdge,  16,
   ASLFR_InitialLeftEdge, 100,
   ASLFR_PositiveText,    (ULONG) " OKAY! ",
   ASLFR_NegativeText,    (ULONG) " CANCEL! ",
   ASLFR_InitialPattern,  (ULONG) "#?",
   ASLFR_InitialFile,     (ULONG) "",
   ASLFR_InitialDrawer,   (ULONG) "CLIPS:",
   ASLFR_Flags1,          FRF_DOPATTERNS,
   ASLFR_Flags2,          FRF_REJECTICONS,
   ASLFR_SleepWindow,     1,
   ASLFR_PrivateIDCMP,    1,
   TAG_END 
};

PRIVATE struct TagItem RunTags[] = { TAG_DONE };

// ----------------------------------------------------------------

#define MAXNODE   6
#define STRLENGTH 256
#define NUMCLIPS  256

PRIVATE struct MinList TTList;

PRIVATE struct Node    TTNode;
PRIVATE struct Node    TTNodes[ MAXNODE ] = { NULL, }; 
PRIVATE UBYTE          TTNodeStrs[ MAXNODE * STRLENGTH ] = "";

PRIVATE struct MinList CLList;

PRIVATE struct Node    CLNode;
PRIVATE struct Node    CLNodes[ NUMCLIPS ] = { NULL, }; 
PRIVATE UBYTE         *CLNodeStrs = NULL;

// ----------------------------------------------------------------
PRIVATE struct IOClipReq *CurrentClip     = NULL;
PRIVATE int               CurrentClipSize = 0;
PRIVATE int               CurrentClipType = 0;
PRIVATE UBYTE             CurrentClipNum  = 0;
PRIVATE BOOL              ClipInMemory    = FALSE;

// ----------------------------------------------------------------

PRIVATE UWORD CBGTypes[] = {

   STRING_KIND,   BUTTON_KIND,   BUTTON_KIND, BUTTON_KIND,
   LISTVIEW_KIND, LISTVIEW_KIND, TEXT_KIND,   TEXT_KIND,
   STRING_KIND,   BUTTON_KIND,   BUTTON_KIND, TEXT_KIND,
   BUTTON_KIND,   BUTTON_KIND,   BUTTON_KIND, STRING_KIND,
   BUTTON_KIND,   BUTTON_KIND
};

PRIVATE int CFNameClicked(      int dummy     );
PRIVATE int ASLClicked(         int dummy     );
PRIVATE int ViewClipClicked(    int dummy     );
PRIVATE int MakeClipClicked(    int dummy     );
PRIVATE int ClipLVClicked(      int whichClip );
PRIVATE int ToolTypesClicked(   int whichTool );
PRIVATE int TTypeStringClicked( int dummy     );
PRIVATE int DeleteClicked(      int dummy     );
PRIVATE int EditClipClicked(    int dummy     );
PRIVATE int LoadClicked(        int dummy     );
PRIVATE int SaveClicked(        int dummy     );
PRIVATE int AboutClicked(       int dummy     );
PRIVATE int ClipNumberClicked(  int dummy     );
PRIVATE int TranslateToFile(    int dummy     );
PRIVATE int TranslateToClip(    int dummy     );

PRIVATE struct NewGadget CBNGad[] = {

   126,   4, 303,  17, (UBYTE *) "Clip FileName:",     NULL, 
   0, PLACETEXT_LEFT, NULL, (APTR) CFNameClicked,
   
   439,   4,  47,  17, (UBYTE *) " ASL ",              NULL, 
   1, PLACETEXT_IN, NULL, (APTR) ASLClicked,
   
   240, 180,  94,  17, (UBYTE *) "_View Clip",         NULL, 
   2, PLACETEXT_IN, NULL, (APTR) ViewClipClicked,
   
   240, 117,  94,  17, (UBYTE *) "_Make Clip",         NULL, 
   3, PLACETEXT_IN, NULL, (APTR) MakeClipClicked,
   
     4,  37, 199, 264, (UBYTE *) "Clip List:",         NULL, 
   4, PLACETEXT_ABOVE, NULL, (APTR) ClipLVClicked,
   
   365,  40, 211, 176, (UBYTE *) "Tool Types:",        NULL, 
   5, PLACETEXT_ABOVE | NG_HIGHLABEL, NULL, 
   (APTR) ToolTypesClicked,
   
   248,  37,  75,  17, (UBYTE *) "Clip Size (bytes):", NULL, 
   6, PLACETEXT_ABOVE, NULL, NULL,
   
   248,  71,  75,  17, (UBYTE *) "Clip Type:",         NULL, 
   7, PLACETEXT_ABOVE, NULL, NULL,
   
   365, 210, 211,  17,                           NULL, NULL, 
   8, 0, NULL, (APTR) TTypeStringClicked,
   
   240, 138,  94,  17, (UBYTE *) "Delete Clip",        NULL, 
   9, PLACETEXT_IN, NULL, (APTR) DeleteClicked,
   
   240, 159,  94,  17, (UBYTE *) "Edit Clip",          NULL, 
   10, PLACETEXT_IN, NULL, (APTR) EditClipClicked,
   
   209, 250, 362,  16, (UBYTE *) "Status:",            NULL, 
   11, PLACETEXT_ABOVE, NULL, NULL,

   240,  96,  94,  17, (UBYTE *) "Load Clip",          NULL, 
   12, PLACETEXT_IN, NULL, (APTR) LoadClicked,
   
   240, 201,  94,  17, (UBYTE *) "Save Clip",          NULL, 
   13, PLACETEXT_IN, NULL, (APTR) SaveClicked,
   
   240, 222,  94,  17, (UBYTE *) "About..  ",          NULL, 
   14, PLACETEXT_IN, NULL, (APTR) AboutClicked,

   340, 270,  50,  17, (UBYTE *) "Clip # (0-255):",    NULL,
   15, PLACETEXT_LEFT, NULL, (APTR) ClipNumberClicked,
   
   400, 270,  110, 17, (UBYTE *) "File -> Clip",       NULL, 
   16, PLACETEXT_IN, NULL, (APTR) TranslateToClip,

   400, 290,  110, 17, (UBYTE *) "Clip -> File",       NULL, 
   17, PLACETEXT_IN, NULL, (APTR) TranslateToFile
};

PRIVATE ULONG CBGTags[] = {

   GTST_MaxChars, 256, STRINGA_Justification, GACT_STRINGCENTER, TAG_DONE,

   TAG_DONE,

   GT_Underscore, '_', TAG_DONE,
   GT_Underscore, '_', TAG_DONE,

   GTLV_ShowSelected, NULL, LAYOUTA_Spacing, 3, TAG_DONE,
   GTLV_ShowSelected, NULL, LAYOUTA_Spacing, 3, TAG_DONE,
   
   GTTX_Border, TRUE, GTTX_Justification, GTJ_CENTER, TAG_DONE,
   GTTX_Border, TRUE, GTTX_Justification, GTJ_CENTER, TAG_DONE,

   GTST_MaxChars, 256, STRINGA_Justification, GACT_STRINGCENTER, TAG_DONE,

   TAG_DONE,
   TAG_DONE,

   GTTX_Border, TRUE,TAG_DONE,

   TAG_DONE,   TAG_DONE,   TAG_DONE,

   GTST_MaxChars, 4, STRINGA_Justification, GACT_STRINGCENTER, TAG_DONE,
   
   TAG_DONE,  // Translation buttons.
   TAG_DONE

};

// ----------------------------------------------------------------

PRIVATE int SetupScreen( void )
{
   Font = &Attr;
   
   if ((Scr = LockPubScreen( PubScreenName )) == NULL)
      return( -1 );

   ComputeFont( Scr, Font, &CFont, 0, 0 );

   if ((VisualInfo = GetVisualInfo( Scr, TAG_DONE )) == NULL)
      return( -2 );

   return( 0 );
}

PRIVATE void CloseDownScreen( void )
{
   if (VisualInfo != NULL)
      {
      FreeVisualInfo( VisualInfo );
      VisualInfo = NULL;
      }

   if (Scr != NULL)
      {
      UnlockPubScreen( NULL, Scr );
      Scr = NULL;
      }

   return;
}

PRIVATE void CloseCBWindow( void )
{
   if (CBWnd != NULL)
      {
      CloseWindow( CBWnd );
      CBWnd = NULL;
      }

   if (CBGList != NULL)
      {
      FreeGadgets( CBGList );
      CBGList = NULL;
      }

   if (CBFont != NULL)
      {
      CloseFont( CBFont );
      CBFont = NULL;
      }

   return;
}

// ----------------------------------------------------------------

PRIVATE void UpdateIcon( void )
{
   char PrgmName[256], **toolArray = NULL;
   BOOL rval = FALSE;
      
   rval = GetProgramName( &PrgmName[0], 255L );
   if (rval != 0)
      {
      int    i;
      
      diskobj = GetDiskObject( &PrgmName[0] );
      if (diskobj == NULL)
         {
         // Flag the user about this problem!
         return;
         }
         
      toolArray = diskobj->do_ToolTypes;
      
      for (i = 0; i < MAXNODE; i++)
         *(toolArray + i) = TTNodes[i].ln_Name;
         
      (void) PutDiskObject( &PrgmName[0], diskobj );   
      }

   return;
}

PRIVATE int CBCloseWindow( void )
{
   if (SanityCheck( "Are you really done?" ) == TRUE)
      {
      // Before closing, write out the ToolTypes to the icon:
      UpdateIcon();

      CloseCBWindow();
      return( (int) FALSE );
      }
   
   return( (int) TRUE );
}

// --------- Gadget functions: ---------------------------------------

PRIVATE char I2A[10];

PUBLIC char *Int2ASCII( int number )
{
   (void) stci_d( &I2A[0], number );

   return( &I2A[0] );
}

// Beyond this point be Dragons (& bugs, lots of them!).

// ----------------------------------------------------------------

PRIVATE int GetClipSizeType( int unitnumber )
{
   ULONG SizeTypeBuf[4] = { 0, 0, 0, 0 };
   
   CurrentClip = CBOpen( unitnumber );

   if (CurrentClip == NULL)
      {
      (void) Handle_Problem( "Couldn't open the clipboard!", 
                             "Out of Memory??", NULL
                           );

      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, "Couldn't open clipboard!", 
                         TAG_END 
                       );

      return( -1 );
      }

   CurrentClip->io_Offset  = 0;
   CurrentClip->io_Error   = 0;
   CurrentClip->io_ClipID  = 0;
   CurrentClip->io_Command = CMD_READ;
   CurrentClip->io_Data    = (STRPTR) &SizeTypeBuf[0];
   CurrentClip->io_Length  = 16; // Just read the header info.

   DoIO( (struct IORequest *) CurrentClip );

   if (CurrentClip->io_Actual == 16)
      {
      if (SizeTypeBuf[0] == ID_FORM)
         {
         if (SizeTypeBuf[2] == ID_FTXT)
            {
            CurrentClipType = 0; 
            GT_SetGadgetAttrs( ClipTypeText, CBWnd, NULL,
                               GTTX_Text, (STRPTR) "FTXT", TAG_END
                             );

            CurrentClipSize = (int) SizeTypeBuf[1];
            }
         else // ILBM??
            {
            CurrentClipType = 1; 
            GT_SetGadgetAttrs( ClipTypeText, CBWnd, NULL,
                               GTTX_Text, (STRPTR) "ILBM", TAG_END
                             );
            }

         CurrentClipSize = (int) SizeTypeBuf[1];


         GT_SetGadgetAttrs( ClipSizeText, CBWnd, NULL,
                            GTTX_Text, 
                            (STRPTR) Int2ASCII( (int) SizeTypeBuf[1] ), 
                            TAG_END
                          );
         }
      }
   else // Didn't read the header in:
      {
      CurrentClipType = 0; 
      GT_SetGadgetAttrs( ClipTypeText, CBWnd, NULL,
                         GTTX_Text, (STRPTR) "FTXT", TAG_END
                       );

      CurrentClipSize = 0;
      GT_SetGadgetAttrs( ClipSizeText, CBWnd, NULL,
                         GTTX_Text, 
                         (STRPTR) "0", TAG_END
                       );

      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, 
                         (STRPTR) "Didn't read the clip info!", TAG_END 
                       );
      }

   CBReadDone( CurrentClip );
   CBClose( CurrentClip );

   return( 0 );
}

/****i* DisplayText() ---------------------------------------------
*
* NAME
*    DisplayText() 
*
* NOTES
*    Incredibubble!  This function worked right from the start!
*******************************************************************
*
*/

PRIVATE void DisplayText( char *text, int size )
{
   struct ProcID   disp_proc = { 0, };
   struct FORKENV  disp_env  = { 0, };

   FILE           *tfile = NULL;
   char            ch;
   int             i, rval = 0;
      
   if ((tfile = fopen( TempFileName, "w" )) == NULL)
      return;
   
   i = 0;

   /* CurrentClipSize is gathered from the FTXT size field.  It does NOT
   ** reflect the fact that there is a string for FORM & a long value
   ** for the size field.  This means that we have to adjust the 
   ** output by FORMSIZE_OFFSET in order to compensate for this:
   */

   while (i < (size)) // + FORMSIZE_OFFSET))
      {
      ch = *(text + i);
      (void) fputc( (int) ch, tfile );
      i++;
      }


   if (CurrentClipType == 0)
      {
      i = 0;

      while (i < FORMSIZE_OFFSET)
         {
         (void) fputc( 0, tfile );
         i++;
         }
      }   

   fclose( tfile );
   
   rval = forkl( TTTextViewer, TTTextViewer, 
                 TempFileName, NULL, &disp_env, &disp_proc
               );

   (void) wait( &disp_proc ); // wait for the viewer to exit.

   return;
}

/****i* DisplayImage() --------------------------------------------
*
* NAME
*    DisplayImage() 
*
* NOTES
*    Incredibubble!  This function worked right from the start!
*******************************************************************
*
*/

PRIVATE void DisplayImage( char *text, int size )
{
   struct ProcID   disp_proc = { 0, };
   struct FORKENV  disp_env  = { 0, };

   FILE           *tfile = NULL;
   char            ch;
   int             i, rval = 0;
      
   if ((tfile = fopen( TempFileName, "w" )) == NULL)
      return;
   
   i = 0;

   /* CurrentClipSize is gathered from the FTXT size field.  It does NOT
   ** reflect the fact that there is a string for FORM & a long value
   ** for the size field.  This means that we have to adjust the 
   ** output by FORMSIZE_OFFSET in order to compensate for this:
   */

   while (i < (size)) //  + FORMSIZE_OFFSET))
      {
      ch = *(text + i);
      (void) fputc( (int) ch, tfile );
      i++;
      }

   if (CurrentClipType == 1)
      {
      i = 0;
   
      while (i < FORMSIZE_OFFSET)
         {
         (void) fputc( 0, tfile );
         i++;
         }
      }

   fclose( tfile );
   
   rval = forkl( TTImageViewer, TTImageViewer, 
                 TempFileName, NULL, &disp_env, &disp_proc
               );

   (void) wait( &disp_proc ); // wait for the viewer to exit.

   return;
}

PRIVATE int ViewClip( int cliptype )
{
   char *clipdata = NULL;

   if (ClipInMemory == FALSE)
      (void) LoadClicked( 0 );

   CurrentClip = CBOpen( CurrentClipNum );

   if (CurrentClip == NULL)
      {
      sprintf( ErrMsg, "Couldn't open clip # %3d!", CurrentClipNum );

      (void) Handle_Problem( ErrMsg, "Out of Memory??", NULL );

      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, (STRPTR) ErrMsg,
                         TAG_END 
                       );

      return( -1 );
      }

   // GetClipSizeType( CurrentClipNum );

   clipdata = FillCBData( CurrentClip, CurrentClipSize );

   if (cliptype == 0)
      DisplayText( clipdata, CurrentClipSize );
   else
      DisplayImage( clipdata, CurrentClipSize );

   CBFreeBuf( clipdata );

   CBReadDone( CurrentClip );
   CBClose(    CurrentClip );

   return( 0 );
}

// -----------------------------------------------------------------

PRIVATE int CBTextEdit( void )
{
   char command[256];

   if (strlen( StrBfPtr( ClipFileName ) ) < 1)   
      {
      SetReqButtons( "Oops, OKAY!" );

      (void) Handle_Problem( "Enter a Clip FileName first!", 
                             "User ERROR:", NULL
                           );

      SetReqButtons( "CONTINUE|ABORT" );

      return( (int) TRUE );
      }

   strcpy( &command[0], TTTextEditor );
   strcat( &command[0], " " );
   strcat( &command[0], StrBfPtr( ClipFileName ) ); // has path also.
   
   if (System( &command[0], RunTags ) < 0)
      {
      sprintf( ErrMsg, 
               "%s couldn't be run by the System,\ncheck your spelling!",
               TTTextEditor
             );

      (void) Handle_Problem( ErrMsg, "Invalid ToolType?", NULL );
      }

   return( (int) TRUE );
}

PRIVATE int CBImageEdit( void )
{
   char command[256];

   if (strlen( StrBfPtr( ClipFileName ) ) < 1)   
      {
      SetReqButtons( "Oops, OKAY!" );

      (void) Handle_Problem( "Enter a Clip FileName first!", 
                             "User ERROR:", NULL
                           );

      SetReqButtons( "CONTINUE|ABORT" );

      return( (int) TRUE );
      }

   strcpy( &command[0], TTImageEditor );
   strcat( &command[0], " " );
   strcat( &command[0], StrBfPtr( ClipFileName ) ); // has path also.
   
   if (System( &command[0], RunTags ) < 0)
      {
      sprintf( ErrMsg, 
               "%s couldn't be run by the System,\ncheck your spelling!",
               TTImageEditor
             );

      (void) Handle_Problem( ErrMsg, "Invalid ToolType?", NULL );
      }

   return( (int) TRUE );
}

/* GetClipSizeType() doesn't get the proper header information from a
** stored clip file.
*/

PRIVATE int GetFileSizeType( char *filename )
{
   ULONG SizeTypeBuf[4] = { 0, 0, 0, 0 };

   int   infile = 0, readsize = 0, rval = 0;
      
   if ((infile = open( filename, O_RDONLY, 0 )) < 0)
      return( IFFERR_READ );

   readsize = read( infile, &SizeTypeBuf[0], 16 );

   if (readsize > 0)
      {
      if (SizeTypeBuf[0] == ID_FORM)
         {
         if (SizeTypeBuf[2] == ID_FTXT)
            {
            CurrentClipType = 0; 
            GT_SetGadgetAttrs( ClipTypeText, CBWnd, NULL,
                               GTTX_Text, (STRPTR) "FTXT", TAG_END
                             );
            }
         else // ILBM??
            {
            CurrentClipType = 1; 
            GT_SetGadgetAttrs( ClipTypeText, CBWnd, NULL,
                               GTTX_Text, (STRPTR) "ILBM", TAG_END
                             );
            }

         CurrentClipSize = (int) SizeTypeBuf[1];

         GT_SetGadgetAttrs( ClipSizeText, CBWnd, NULL,
                            GTTX_Text, 
                            (STRPTR) Int2ASCII( (int) SizeTypeBuf[1] ), 
                            TAG_END
                          );
         }
      }
   else // Didn't read the header in:
      {
      CurrentClipType = 0; 
      GT_SetGadgetAttrs( ClipTypeText, CBWnd, NULL,
                         GTTX_Text, (STRPTR) "FTXT", TAG_END
                       );

      CurrentClipSize = 0;
      GT_SetGadgetAttrs( ClipSizeText, CBWnd, NULL,
                         GTTX_Text, 
                         (STRPTR) "0", TAG_END
                       );

      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, 
                         (STRPTR) "Didn't read the clip info!", TAG_END 
                       );
      rval = -1;
      }

   close( infile );

   return( rval );
}

/****i* LoadThefile() ---------------------------------------------
*
* NAME
*    LoadThefile()
*******************************************************************
*
*/

PRIVATE int LoadTheFile( char *filename, int clipnumber )
{
   int errchk = 0;

   sprintf( ErrMsg, "Loading '%s' Clip...", filename );
   
   GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                      GTTX_Text, ErrMsg, TAG_END 
                    );

   GetFileSizeType( filename );

   if (CurrentClipType == 1)
      {
      // The file is an ILBM picture:
      if ((errchk = ILBMFileToClip( filename, clipnumber )) < 0)
         {
         sprintf( ErrMsg, "ERROR:  %ld - %s\nFile NOT loaded!", 
                  errchk, CBGetIFFError( errchk ) 
                );

         SetReqButtons( "Aaarrggghhh!!!" );
      
         (void) Handle_Problem( ErrMsg,
                                "File Problem:", NULL
                              );

         SetReqButtons( "CONTINUE|ABORT" );
         
         GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                            GTTX_Text, "Transfer Problem.", TAG_END 
                          );
         return( -1 );
         }

      GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                         GA_DISABLED, TRUE, TAG_DONE 
                       );

      goto ExitLoadTheFile;
      }
   else
      {
      // Here is where we read in the file. 
      if ((errchk = FTXTFileToClip( filename, clipnumber )) < 0)
         {
         int ans = 0;

         SetReqButtons( "USE ASCII METHOD|ABORT!" );
         
         ans = Handle_Problem( "Couldn't transfer the file to clipboard!\n"
                               "File might not be in IFF format.\n"
                               "Want to try ASCII method?",
                               "File Problem:", NULL
                             );

         SetReqButtons( "CONTINUE|ABORT" );

         if (ans == 0)
            {
            if ((errchk = FileToFTXT( clipnumber, filename )) < 0)
               {
               sprintf( ErrMsg, 
                        "ERROR:  %ld - %s\nFile not ASCII either?", 
                        errchk, CBGetIFFError( errchk ) 
                      );

               SetReqButtons( "Aaarrggghhh!!!" );
      
               (void) Handle_Problem( ErrMsg,
                                      "File Problem:", NULL
                                    );

               SetReqButtons( "CONTINUE|ABORT" );
         
               GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                                  GTTX_Text, "Transfer Problem.", TAG_END 
                                );
               return( -1 );
               }
         
            GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                               GTTX_Text, "Transfer Complete.", TAG_END 
                             );
            return( 0 );
            }
         else 
            GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                               GTTX_Text, "Transfer Problem.", TAG_END 
                             );
         return( -1 );
         } 
      }

ExitLoadTheFile:

   GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                      GA_DISABLED, TRUE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                      GTTX_Text, "Transfer Complete.", TAG_END 
                    );
   return( 0 );
}

/****i* LoadClicked() ------------------------------------------
*
* NAME
*    LoadClicked()
*
* NOTES
*    The user might think that they're loading a clip but in
*    reality, this function just reads a file, since loading
*    from a real clip in memory is performed with the 
*    ClipNumber Gadget handler.  This function will have to be
*    changed so that it will read a file, instead of using
*    CBOpen(), etc.
*
****************************************************************
*
*/

PRIVATE int LoadClicked( int dummy )
{
   char UserClipName[ STRLENGTH ];
   int  answer = 0;

   if ((CurrentClipNum = GetClipNumber( CurrentClipNum )) < 0)
      CurrentClipNum = 0; // Use default clip number = 0.

   GT_SetGadgetAttrs( ClipNumber, CBWnd, NULL,
                      GTST_String, (STRPTR) Int2ASCII( CurrentClipNum ),
                      TAG_END
                    );
    
   if (strlen( StrBfPtr( ClipFileName ) ) < 1)
      {
      // need an input filename:
      SetTagItem( &FileTags[0], ASLFR_Window, (ULONG) CBWnd );
      SetTagItem( &FileTags[0], ASLFR_InitialDrawer, 
                  (ULONG) &TTClipPath[0]
                );

      answer = FileReq( UserClipName, &FileTags[0] );

      if (answer > 1)
         {
         strcpy( StrBfPtr( ClipFileName ), UserClipName );
         sprintf( ErrMsg, "%s/%s", TTClipPath, StrBfPtr( ClipFileName ) );

         strcpy( &UserClipName[0], ErrMsg );

         GT_SetGadgetAttrs( ClipFileName, CBWnd, NULL,
                            GTST_String, (STRPTR) ErrMsg, TAG_END 
                          );
         }
      else
         return( (int) TRUE ); // No filename, abort operation.
      }

   if (LoadTheFile( StrBfPtr( ClipFileName ), CurrentClipNum ) < 0)
      return( (int) TRUE );

   if (GetFileSizeType( StrBfPtr( ClipFileName ) ) != 0)
      return( (int) TRUE );

   ClipInMemory = TRUE;

   SetReqButtons( "VIEW CLIP|EDIT CLIP|ABORT" );

   answer = GetUserResponse( "Select what to do with the clip:",
                             "Help me, User:", NULL
                           );

   SetReqButtons( "CONTINUE|ABORT" );
      
   if (answer == 1)              // User wants to View Clip:
      {
      if (CurrentClipType == 0)
         (void) ViewClip( 0 );
      else   
         (void) ViewClip( 1 );
      }
   else if (answer == 2)         // User wants to Edit Clip:
      {
      if (CurrentClipType == 0)
         (void) CBTextEdit();
      else   
         (void) CBImageEdit();
      }
                                 // else User selected Abort.

   GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                      GTTX_Text, "Waiting for User input.", TAG_END 
                    );

   GT_SetGadgetAttrs( VIEWCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( DELETECLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( EDITCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                      GA_Disabled, TRUE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   return( (int) TRUE );
}

/****i* SaveClicked() ---------------------------------------------
*
* NAME
*    SaveClicked()
*******************************************************************
*
*/

PRIVATE int SaveClicked( int dummy )
{
   char UserClipName[ STRLENGTH ];
   int  answer = 0;
   
   if ((CurrentClipNum = GetClipNumber( CurrentClipNum )) < 0)
      CurrentClipNum = 0; // Use default clip number = 0.

   GT_SetGadgetAttrs( ClipNumber, CBWnd, NULL,
                      GTST_String, (STRPTR) Int2ASCII( CurrentClipNum ),
                      TAG_END
                    );
    
   if (strlen( StrBfPtr( ClipFileName ) ) < 1)
      {
      // need an output filename:
      char title[] = "Save clip to file...";

      SetTagItem( &FileTags[0], ASLFR_Window, (ULONG) CBWnd );

      SetTagItem( &FileTags[0], ASLFR_InitialDrawer, 
                  (ULONG) &TTClipPath[0]
                );

      SetTagItem( &FileTags[0], ASLFR_TitleText, 
                  (ULONG) &title[0] 
                );

      answer = FileReq( UserClipName, &FileTags[0] );

      if (answer > 1)
         {
         strcpy( StrBfPtr( ClipFileName ), UserClipName );
         sprintf( ErrMsg, "%s/%s", TTClipPath, StrBfPtr( ClipFileName ) );

         strcpy( &UserClipName[0], ErrMsg );

         GT_SetGadgetAttrs( ClipFileName, CBWnd, NULL,
                            GTST_String, (STRPTR) ErrMsg, TAG_END 
                          );
         }
      else
         return( (int) TRUE ); // No filename, abort operation.
      }

   if (GetFileSizeType( UserClipName ) != 0)
      return( (int) TRUE );

   sprintf( ErrMsg, "Write Clip #%d to %s,\nAre you sure about this?",
            CurrentClipNum, StrBfPtr( ClipFileName ) 
          );

   if (SanityCheck( ErrMsg ) == FALSE)
      {
      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, "User came to his senses.", TAG_END 
                       );

      return( (int) TRUE );
      }
   
   if (ClipToFile( CurrentClipNum, StrBfPtr( ClipFileName ) ) < 0)
      {
      SetReqButtons( "Well, okay!" );

      (void) Handle_Problem( "Couldn't transfer the clipboard to file!",
                             "System Problem:", NULL
                           );

      SetReqButtons( "CONTINUE|ABORT" );

      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, "Transfer Problem.", TAG_END 
                       );

      ClipInMemory = FALSE;
      return( (int) TRUE );
      }

   GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                      GTTX_Text, "Clip written to file!", TAG_END 
                    );

   GT_SetGadgetAttrs( VIEWCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( DELETECLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( EDITCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   return( (int) TRUE );
}

/****i* AboutClicked() -------------------------------------------
*
* NAME
*    AboutClicked() - Show the user some info on the program.
******************************************************************
*
*/

PRIVATE int AboutClicked( int dummy )
{
   strcpy( ErrMsg, "This program (ClipIt!) was written by" );
   strcat( ErrMsg, "\nJ.T. Steichen using SAS C V6.58 on" );
   strcat( ErrMsg, "\na A4000T 68040 system." );
   strcat( ErrMsg, "\nIt is designed to make using the" );
   strcat( ErrMsg, "\nClipboard system easier & more powerful." );

   SetReqButtons( "OKAY!" );
   (void) GetUserResponse( ErrMsg, "About ClipIt!:", NULL );
   SetReqButtons( "CONTINUE|ABORT" );
   
   GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                      GTTX_Text, "Waiting for User input.", TAG_END 
                    );

   return( (int) TRUE );
}

/****i* CFNameClicked() -----------------------------------------
*
* NAME
*    CFNameClicked()
*****************************************************************
*
*/

PRIVATE int CFNameClicked( int dummy )
{
   return( (int) TRUE );
}

PRIVATE int ASLClicked( int dummy )
{
   char title[] = "Set the clip file name..."; 
   char UserClipName[ STRLENGTH ];

   SetTagItem( &FileTags[0], ASLFR_Window, (ULONG) CBWnd );

   SetTagItem( &FileTags[0], ASLFR_InitialDrawer, 
               (ULONG) &TTClipPath[0]
             );

   SetTagItem( &FileTags[0], ASLFR_TitleText, 
               (ULONG) &title[0]
             );

   if (FileReq( UserClipName, &FileTags[0] ) > 1)
      {
      sprintf( ErrMsg, "%s", &UserClipName[0] );
      
      GT_SetGadgetAttrs( ClipFileName, CBWnd, NULL,
                         GTST_String, (STRPTR) ErrMsg, TAG_END 
                       );

      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, "Waiting for User input.", TAG_END 
                       );
      }

   return( (int) TRUE );
}

// User wants to view the CurrentClipNum: 

PRIVATE int ViewClipClicked( int dummy )
{
   if (ClipInMemory == FALSE)
      {
      if ((CurrentClipNum = GetClipNumber( CurrentClipNum )) < 0)
         CurrentClipNum = 0; // Use default clip number = 0.

      GT_SetGadgetAttrs( ClipNumber, CBWnd, NULL,
                         GTST_String, 
                         (STRPTR) Int2ASCII( CurrentClipNum ),
                         TAG_END
                       );

      ClipInMemory = TRUE;
      }

   // This should work, check & see:
   // (void) GetClipSizeType( CurrentClipNum );

   (void) ViewClip( CurrentClipType );

   GT_SetGadgetAttrs( DELETECLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( EDITCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   return( (int) TRUE );
}

// Just call the appropriate Editor:

PRIVATE int MakeClipClicked( int dummy )
{
   int cliptype = -1;
   
   if ((CurrentClipNum = GetClipNumber( CurrentClipNum )) < 0)
      CurrentClipNum = 0; // Use default clip number = 0.

   GT_SetGadgetAttrs( ClipNumber, CBWnd, NULL,
                      GTST_String, (STRPTR) Int2ASCII( CurrentClipNum ),
                      TAG_END
                    );
    
   SetReqButtons( "IMAGE|TEXT" );
   
   cliptype = Handle_Problem( "What type of clip are you making?",
                              "User, help me out here:", NULL 
                            );
   
   SetReqButtons( "CONTINUE|ABORT" );
   
   if (cliptype == 0)
      (void) CBTextEdit();
   else   
      (void) CBImageEdit();

   GT_SetGadgetAttrs( VIEWCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( DELETECLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( EDITCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   return( (int) TRUE );
}

/****i* ClipLVClicked() ------------------------------------------
*
* NAME
*    ClipLVClicked()
*
* NOTES
*    This function is now working correctly.
******************************************************************
*
*/

PRIVATE int ClipLVClicked( int whichClip )
{
   char *clipname = (char *) CLNodes[ whichClip ].ln_Name;

   sprintf( ErrMsg, "%s/%s", TTClipPath, clipname );

   GT_SetGadgetAttrs( ClipFileName, CBWnd, NULL,
                      GTST_String, (STRPTR) ErrMsg, TAG_END 
                    );

   return( (int) TRUE );
}

/****i* ToolTypesClicked() ---------------------------------------
*
* NAME
*    ToolTypesClicked()
*
* NOTES
*    This function is now working correctly.
******************************************************************
*
*/

PRIVATE int ToolTypesClicked( int whichTool )
{
   char *toolname = (char *) TTNodes[ whichTool ].ln_Name;

   GT_SetGadgetAttrs( ToolTypeString, CBWnd, NULL,
                      GTST_String, (STRPTR) toolname, TAG_END 
                    );

   return( (int) TRUE );
}

/****i* TranslateToFile() -----------------------------------------
*
* NAME
*    TranslateToFile() 
*
*******************************************************************
*
*/

PRIVATE int TranslateToFile( int dummy )
{
   int err = 0;
   
   if (strlen( StrBfPtr( ClipFileName ) ) < 1)   
      {
      SetReqButtons( "Oops, OKAY!" );

      (void) Handle_Problem( "Enter a FileName first!", 
                             "User ERROR:", NULL
                           );

      SetReqButtons( "CONTINUE|ABORT" );

      return( (int) TRUE );
      }

   if ((CurrentClipNum = GetClipNumber( CurrentClipNum )) < 0)
      CurrentClipNum = 0; // Use default clip number = 0.


   if ((err = FTXTToFile( CurrentClipNum, 
                          StrBfPtr( ClipFileName ))) != 0)
      {
      SetReqButtons( "Arrggghh!" );

      sprintf( ErrMsg, 
               "Couldn't Translate Clip #%d to:\n%s file!  ERROR:\n", 
               CurrentClipNum, StrBfPtr( ClipFileName )
             );

      strcat( ErrMsg, CBErrMsgs[ -err - 1 ] );

      (void) Handle_Problem( ErrMsg, "System Problem?", NULL );

      SetReqButtons( "CONTINUE|ABORT" );

      return( (int) TRUE );
      } 

   SetReqButtons( "OKAY!" );

   sprintf( ErrMsg, "Clip #%d sent to:\n\n%s file!", 
                    CurrentClipNum, StrBfPtr( ClipFileName )
          );

   (void) Handle_Problem( ErrMsg, "User Information:", NULL );

   SetReqButtons( "CONTINUE|ABORT" );

   GT_SetGadgetAttrs( VIEWCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( DELETECLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( EDITCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   return( (int) TRUE );
}

/****i* TranslateToClip() -----------------------------------------
*
* NAME
*    TrnanslateToClip() 
*
*******************************************************************
*
*/

PRIVATE int TranslateToClip( int dummy )
{
   int err = 0;
   
   if (strlen( StrBfPtr( ClipFileName ) ) < 1)   
      {
      SetReqButtons( "Oops, OKAY!" );

      (void) Handle_Problem( "Enter a FileName first!", 
                             "User ERROR:", NULL
                           );

      SetReqButtons( "CONTINUE|ABORT" );

      return( (int) TRUE );
      }

   if ((CurrentClipNum = GetClipNumber( CurrentClipNum )) < 0)
      CurrentClipNum = 0; // Use default clip number = 0.


   if ((err = FileToFTXT( CurrentClipNum, StrBfPtr( ClipFileName ))) != 0)
      {
      SetReqButtons( "Arrggghh!" );

      sprintf( ErrMsg, 
               "Couldn't Translate file %s to:\nClip #%d!  ERROR:\n", 
               StrBfPtr( ClipFileName ), CurrentClipNum
             );

      strcat( ErrMsg, CBErrMsgs[ -err - 1 ] );

      (void) Handle_Problem( ErrMsg, "System Problem?", NULL );

      SetReqButtons( "CONTINUE|ABORT" );

      return( (int) TRUE );
      }
      
   SetReqButtons( "OKAY!" );

   sprintf( ErrMsg, "File %s sent to:\n\nClip #%d!", 
                    StrBfPtr( ClipFileName ), CurrentClipNum 
          );

   (void) Handle_Problem( ErrMsg, "User Information:", NULL );

   SetReqButtons( "CONTINUE|ABORT" );

   GT_SetGadgetAttrs( VIEWCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( DELETECLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( EDITCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   return( (int) TRUE );
}


// --------------------------------------------------------------

PRIVATE void StringToUpper( char *dest, char *src )
{
   int i = 0, len = strlen( src );
   
   while ((i < len) && (*(src + i) != '\0'))
      {
      if (*(src + i) < 'a' || *(src + i) > 'z')
         *(dest + i) = *(src + i);
      else
         *(dest + i) = *(src + i) - 0x20;

      i++;
      }

   return;
}

// FindToolNodePtr() called by ResetToolType() only.

PRIVATE struct Node *FindToolNodePtr( char *tool, int len )
{
   struct Node *rval = NULL; 
   int          i    = 0;
   
   while (i < MAXNODE)
      {
      if (strncmp( TTNodes[i].ln_Name, tool, len ) == 0)
         {
         rval = &TTNodes[i];
         break;
         }

      i++;
      }

   return( rval );
}

/****i* ResetToolType() -------------------------------------------
*
* NAME
*    ResetToolType()
*
* NOTES
*    Function works.
*******************************************************************
*
*/

PRIVATE void ResetToolType( char *toolstr, int len )
{
   struct Node *modTool = NULL;
   char         temp[256];

   StringToUpper( &temp[0], toolstr );

   if (strncmp( &temp[0], &ClipPath[0], len ) == 0)
      {
      modTool = FindToolNodePtr( &ClipPath[0], len );
      strcpy( TTClipPath, &toolstr[len + 1] );
      }
   else if (strncmp( &temp[0], &TextEditor[0], len ) == 0)
      {
      modTool = FindToolNodePtr( &TextEditor[0], len );
      strcpy( TTTextEditor, &toolstr[len + 1] );
      }
   else if (strncmp( &temp[0], &TextViewer[0], len ) == 0)
      {
      modTool = FindToolNodePtr( &TextViewer[0], len );
      strcpy( TTTextViewer, &toolstr[len + 1] );
      }
   else if (strncmp( &temp[0], &ImageEditor[0], len ) == 0)
      {
      modTool = FindToolNodePtr( &ImageEditor[0], len );
      strcpy( TTImageEditor, &toolstr[len + 1] );
      }
   else if (strncmp( &temp[0], &ImageViewer[0], len ) == 0)
      {
      modTool = FindToolNodePtr( &ImageViewer[0], len );
      strcpy( TTImageViewer, &toolstr[len + 1] );
      }
   else if (strncmp( &temp[0], &ProgramPath[0], len ) == 0)
      {
      modTool = FindToolNodePtr( &ProgramPath[0], len );
      strcpy( TTProgramPath, &toolstr[len + 1] );
      }

   if (modTool != NULL)
      {
      GT_SetGadgetAttrs( ToolTypeListView, CBWnd, NULL,
                         GTLV_Labels, ~0,
                         TAG_DONE
                       );

      strcpy( modTool->ln_Name, toolstr );

      GT_SetGadgetAttrs( ToolTypeListView, CBWnd, NULL,
                         GTLV_Labels,       (struct List *) &TTList,
                         GTLV_ShowSelected, ToolTypeString,
                         GTLV_Selected,     TRUE,
                         GTLV_MaxPen,       255,
                         GTLV_ItemHeight,   12,
                         TAG_DONE
                       );
      }

   return;
}

// ----------------------------------------------------------------

PRIVATE int TTypeStringClicked( int dummy )
{
   int   tool_len  = 0;
   char *equal_loc = NULL;

   if (strlen( StrBfPtr( ToolTypeString ) ) < 1)
      return( (int) TRUE );

   equal_loc = strchr( StrBfPtr( ToolTypeString ), '=' );

   if (equal_loc == NULL)
      return( (int) TRUE ); // User typed in junk!
      
   tool_len = (int) (equal_loc - StrBfPtr( ToolTypeString ));

   ResetToolType( StrBfPtr( ToolTypeString ), tool_len );
      
   return( (int) TRUE );
}

// ----------------------------------------------------------------

PRIVATE void KillClipList( void ); // Forward declarations.
PRIVATE int  MakeClipList( void );

PRIVATE int DeleteClicked( int dummy )
{
   BOOL answer = FALSE;
   
   sprintf( ErrMsg, "Are you sure you want %s DELETED?", 
            StrBfPtr( ClipFileName )
          );

   answer = SanityCheck( ErrMsg );

   if (answer == TRUE)
      {
      (void) DeleteFile( StrBfPtr( ClipFileName ) );

      KillClipList(); // Re-make the Clip ListView.
      MakeClipList();
      GT_SetGadgetAttrs( ClipFileName, CBWnd, NULL,
                         GTST_String, (STRPTR) "", TAG_END 
                       );

      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, (STRPTR) "Clip File Deleted!",
                         TAG_END 
                       );

      GT_SetGadgetAttrs( VIEWCLIPBt, CBWnd, NULL, 
                         GA_Disabled, FALSE, TAG_DONE 
                       );

      GT_SetGadgetAttrs( EDITCLIPBt, CBWnd, NULL, 
                         GA_Disabled, FALSE, TAG_DONE 
                       );

      GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                         GA_Disabled, FALSE, TAG_DONE 
                       );

      GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                         GA_Disabled, FALSE, TAG_DONE 
                       );
      }

   return( (int) TRUE );
}

// ----------------------------------------------------------------

PRIVATE int EditClipClicked( int dummy )
{
   if (ClipInMemory == FALSE)
      (void) LoadClicked( 0 );

   GT_SetGadgetAttrs( VIEWCLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( DELETECLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                      GA_Disabled, FALSE, TAG_DONE 
                    );

   (void) GetClipSizeType( CurrentClipNum );

   if (CurrentClipType == 0)
      (void) CBTextEdit();
   else   
      (void) CBImageEdit();

   return( (int) TRUE );
}

// ----------------------------------------------------------------

PRIVATE int ClipNumberClicked( int dummy )
{
   ULONG SizeTypeBuf[4] = { 0, 0, 0, 0 };
   int   clipnumber     = atoi( StrBfPtr( ClipNumber ) );
   
   if (clipnumber < 0 || clipnumber > 255)
      clipnumber = 0;

   CurrentClipNum = (UBYTE) clipnumber;

   GT_SetGadgetAttrs( ClipNumber, CBWnd, NULL,
                      GTST_String, (STRPTR) Int2ASCII( clipnumber ),
                      TAG_END
                    );

   CurrentClip = CBOpen( clipnumber );

   if (CurrentClip == NULL)
      {
      sprintf( ErrMsg, "Couldn't open clip # %3d!", clipnumber );

      (void) Handle_Problem( ErrMsg, "Out of Memory??", NULL );

      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, (STRPTR) ErrMsg,
                         TAG_END 
                       );

      return( -1 );
      }

   CurrentClip->io_Offset  = 0;
   CurrentClip->io_Error   = 0;
   CurrentClip->io_ClipID  = 0;
   CurrentClip->io_Command = CMD_READ;
   CurrentClip->io_Data    = (STRPTR) &SizeTypeBuf[0];
   CurrentClip->io_Length  = 16;

   DoIO( (struct IORequest *) CurrentClip );
      
   if (CurrentClip->io_Actual == 16)
      {
      if (SizeTypeBuf[0] == ID_FORM)
         {
         if (SizeTypeBuf[2] == ID_FTXT)
            {
            CurrentClipType = 0; 
            GT_SetGadgetAttrs( ClipTypeText, CBWnd, NULL,
                               GTTX_Text, (STRPTR) "FTXT", TAG_END
                             );
            }
         else
            {
            CurrentClipType = 1; 
            GT_SetGadgetAttrs( ClipTypeText, CBWnd, NULL,
                               GTTX_Text, (STRPTR) "ILBM", TAG_END
                             );
            }

         CurrentClipSize = (int) SizeTypeBuf[1];

         GT_SetGadgetAttrs( ClipSizeText, CBWnd, NULL,
                            GTTX_Text, 
                            (STRPTR) Int2ASCII( (int) SizeTypeBuf[1] ), 
                            TAG_END
                          );
         }
      }
   else
      {
      sprintf( ErrMsg, "No Clip data for %d!", CurrentClipNum );
      GT_SetGadgetAttrs( StatusText, CBWnd, NULL,
                         GTTX_Text, 
                         (STRPTR) ErrMsg, TAG_END 
                       );
      }

   CBReadDone( CurrentClip );
   CBClose( CurrentClip );

   return( (int) TRUE );
}

// ----------------- END of Gadget Code. ------------------------------

PRIVATE int OpenCBWindow( void )
{
   struct NewGadget  ng;
   struct Gadget    *g;
   UWORD             lc, tc;
   UWORD             wleft = CBLeft, wtop = CBTop, ww, wh;

   ComputeFont( Scr, Font, &CFont, CBWidth, CBHeight );

   ww = ComputeX( CFont.FontX, CBWidth );
   wh = ComputeY( CFont.FontY, CBHeight );

   if ((wleft + ww + CFont.OffX + Scr->WBorRight) > Scr->Width)
      wleft = Scr->Width - ww;

   if ((wtop + wh + CFont.OffY + Scr->WBorBottom) > Scr->Height)
      wtop = Scr->Height - wh;

   if ( !(CBFont = OpenDiskFont( Font )))
      return( -5 );

   if ( !(g = CreateContext( &CBGList )))
      return( -1 );

   for (lc = 0, tc = 0; lc < CB_CNT; lc++)
      {
      CopyMem( (char *) &CBNGad[lc], (char *) &ng, 
               (long) sizeof( struct NewGadget )
             );

      ng.ng_VisualInfo = VisualInfo;
      ng.ng_TextAttr   = Font;
      ng.ng_LeftEdge   = CFont.OffX + ComputeX( CFont.FontX,
                                                ng.ng_LeftEdge
                                              );

      ng.ng_TopEdge    = CFont.OffY + ComputeY( CFont.FontY,
                                                ng.ng_TopEdge
                                              );

      ng.ng_Width      = ComputeX( CFont.FontX, ng.ng_Width );
      ng.ng_Height     = ComputeY( CFont.FontX, ng.ng_Height );

      CBGadgets[lc] = g = CreateGadgetA( (ULONG) CBGTypes[lc], 
                             g, 
                             &ng, 
                             (struct TagItem *) &CBGTags[tc] );

      while (CBGTags[tc] != NULL)
         tc += 2;

      tc++; // skip over TAG_END value.

      if (NOT g)
         return( -2 );
      }

   if (!(CBWnd = OpenWindowTags( NULL,
         
                   WA_Left,        wleft,
                   WA_Top,         wtop,
                   WA_Width,       ww + CFont.OffX + Scr->WBorRight,
                   WA_Height,      wh + CFont.OffY + Scr->WBorBottom,

                   WA_IDCMP,       STRINGIDCMP | BUTTONIDCMP 
                     | LISTVIEWIDCMP | TEXTIDCMP
                     | IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW
                     | IDCMP_VANILLAKEY,

                   WA_Flags,       WFLG_DRAGBAR | WFLG_DEPTHGADGET 
                     | WFLG_CLOSEGADGET | WFLG_SMART_REFRESH 
                     | WFLG_ACTIVATE | WFLG_RMBTRAP,
                   
                   WA_Gadgets,     CBGList,
                   WA_Title,       CBWdt,
                   WA_ScreenTitle, ScrT,
                   TAG_DONE ))
      )
      return( -4 );

   GT_RefreshWindow( CBWnd, NULL );

   return( 0 );
}

PRIVATE BOOL CBVanillaKey( int whichKey )
{
   BOOL rval = TRUE;
   
   switch (whichKey)
      {
      case 'q':   // Quit program:
      case 'Q':
         rval = FALSE;
         break;

      case 'v':   // View Clip:
      case 'V':
         (void) ViewClipClicked( 0 );
         break;
         
      case 'm':   // Make Clip:
      case 'M':
         (void) MakeClipClicked( 0 );
         break;
         
      default:
         break;   
      }

   return( rval );   
}

PRIVATE int HandleCBIDCMP( void )
{
   struct IntuiMessage *m;
   int                 (*func)( int code );
   BOOL                running = TRUE;

   while (running == TRUE)
      {
      if ((m = GT_GetIMsg( CBWnd->UserPort )) == NULL) 
         {
         (void) Wait( 1L << CBWnd->UserPort->mp_SigBit );
         continue;
         }

      CopyMem( (char *) m, (char *) &CBMsg, 
               (long) sizeof( struct IntuiMessage )
             );

      GT_ReplyIMsg( m );

      switch ( CBMsg.Class )
         {
         case IDCMP_REFRESHWINDOW:
            GT_BeginRefresh( CBWnd );
            GT_EndRefresh( CBWnd, TRUE );
            break;

         case IDCMP_CLOSEWINDOW:
            running = CBCloseWindow();
            break;

         case IDCMP_VANILLAKEY:
            running = CBVanillaKey( CBMsg.Code );
            break;

         case IDCMP_GADGETUP:
         case IDCMP_GADGETDOWN:
            func = (void *) ((struct Gadget *)CBMsg.IAddress)->UserData;
            
            if (func != NULL)
               running = func( CBMsg.Code );
            
            break;
         }
      }

   return( running );
}

PRIVATE void MakeToolTypeList( void )
{
   int i = 0;

   TTNode.ln_Succ = (struct Node *) TTList.mlh_Tail;
   TTNode.ln_Pred = (struct Node *) TTList.mlh_Head;
   TTNode.ln_Type = NT_USER;

   TTNodes[0]     = TTNode;
       
   TTNodes[0].ln_Name = &TTNodeStrs[ 0 ];
   TTNodes[0].ln_Pri  = MAXNODE;

   for (i = 1; i < MAXNODE; i++)
      {
      TTNodes[i].ln_Name = &TTNodeStrs[ i * STRLENGTH ];
      TTNodes[i].ln_Pri  = MAXNODE - i;
      TTNodes[i].ln_Type = NT_USER;
      }

   sprintf( &TTNodeStrs[0],           "%s%s",ClipPath,    TTClipPath    );
   sprintf( &TTNodeStrs[STRLENGTH],   "%s%s",TextEditor,  TTTextEditor  );
   sprintf( &TTNodeStrs[2*STRLENGTH], "%s%s",TextViewer,  TTTextViewer  );
   sprintf( &TTNodeStrs[3*STRLENGTH], "%s%s",ImageEditor, TTImageEditor );
   sprintf( &TTNodeStrs[4*STRLENGTH], "%s%s",ImageViewer, TTImageViewer );
   sprintf( &TTNodeStrs[5*STRLENGTH], "%s%s",ProgramPath, TTProgramPath );

   NewList( (struct List *) &TTList );

   for (i = 0; i < MAXNODE; i++)
      Enqueue( (struct List *) &TTList, &TTNodes[i] );

   GT_SetGadgetAttrs( ToolTypeListView, CBWnd, NULL,
                      GTLV_Labels,       (struct List *) &TTList,
                      GTLV_ShowSelected, ToolTypeString,
                      GTLV_Selected,     TRUE,
                      GTLV_MaxPen,       255,
                      GTLV_ItemHeight,   12,
                      TAG_DONE
                    );
   return;
}

// ------------------------------------------------------------------

PRIVATE void KillClipList( void )
{
   if (CLNodeStrs != NULL)
      {
      FreeMem( CLNodeStrs, NUMCLIPS * 100 );
      CLNodeStrs = NULL;
      }

   return;
}

// ------------------------------------------------------------------

PRIVATE void SetupClipLV( void )
{
   int i = 0;

   CLNode.ln_Succ = (struct Node *) CLList.mlh_Tail;
   CLNode.ln_Pred = (struct Node *) CLList.mlh_Head;
   CLNode.ln_Type = NT_USER;

   CLNodes[0]         = CLNode;
   CLNodes[0].ln_Name = &CLNodeStrs[ 0 ];
   CLNodes[0].ln_Pri  = NUMCLIPS - 129;   // change to signed char range.

   for (i = 1; i < NUMCLIPS; i++)
      {
      CLNodes[i].ln_Name = &CLNodeStrs[ i * 100 ];
      CLNodes[i].ln_Pri  = NUMCLIPS - i - 129;
      CLNodes[i].ln_Type = NT_USER;
      }

   NewList( (struct List *) &CLList );

   for (i = 0; i < NUMCLIPS; i++)
      Enqueue( (struct List *) &CLList, &CLNodes[i] );

   return;
}

PRIVATE int MakeClipList( void )
{
   struct FileInfoBlock *clip_fib = NULL;
   BPTR                  clipdirlock = Lock( TTClipPath, ACCESS_READ );
   int  i = 0;
   
   CLNodeStrs = (UBYTE *) AllocMem( NUMCLIPS * 100, 
                                    MEMF_CLEAR | MEMF_ANY
                                  );

   if (CLNodeStrs == NULL)
      return( -1 );

   if (clipdirlock == NULL)
      {
      KillClipList();
      return( -2 );
      }

   clip_fib = (struct FileInfoBlock *) AllocDosObject( DOS_FIB, NULL );

   if (clip_fib == NULL)
      {
      UnLock( clipdirlock );
      KillClipList();
      return( -3 );
      }

   SetupClipLV();

   // Disable Clip listview:
   GT_SetGadgetAttrs( ClipListView, CBWnd, NULL,
                      GTLV_Labels, ~0,
                      TAG_DONE
                    );

   if (Examine( clipdirlock, clip_fib  ) != 0)
      {
      while ((ExNext( clipdirlock, clip_fib ) != 0) && (i < NUMCLIPS))
         {
         if (clip_fib->fib_DirEntryType < 0)
            {
            // Got a file:
            strcpy( CLNodes[i].ln_Name, clip_fib->fib_FileName );
            strcpy( &CLNodeStrs[i * 100], clip_fib->fib_FileName );
            }
         i++;
         }
      }

   GT_SetGadgetAttrs( ClipListView, CBWnd, NULL,
                      GTLV_Labels,       (struct List *) &CLList,
                      GTLV_ShowSelected, ClipFileName,
                      GTLV_Selected,     TRUE,
                      GTLV_MaxPen,       255,
                      GTLV_ItemHeight,   12,
                      TAG_DONE
                    );

   FreeDosObject( DOS_FIB, (void *) clip_fib );
   UnLock( clipdirlock );
   return( 0 );
}

// ------------------------------------------------------------------

PRIVATE void ShutdownCBlipper( void )
{
   KillClipList(); // Deallocate the clip list memory.

   CloseCBWindow();
   CloseDownScreen();

   if (UtilityBase != NULL)
      CloseLibrary( (struct Library *) UtilityBase );

   if (IconBase != NULL)
      CloseLibrary( IconBase );

   if (DOSBase != NULL)
      CloseLibrary( (struct Library *) DOSBase );

   CloseLibs();

   // Delete any Temporary file left behind:

   sprintf( ErrMsg, "delete %s QUIET\n", TempFileName );
   (void) System( ErrMsg, TAG_DONE );

   return;
}

// ------------------------------------------------------------------

PRIVATE int SetupCBlipper( void )
{
   if (OpenLibs() < 0)
      return( -1 );
      
   if ((UtilityBase = OpenLibrary( "utility.library", 39 )) == NULL)
      {
      CloseLibs();
      return( -2 );
      }

   if ((IconBase = OpenLibrary( "icon.library", 37L )) == NULL)
      {
      CloseLibs();
      CloseLibrary( UtilityBase );
      return( -3 );
      }

   if ((DOSBase = (struct DosLibraryBase *) 
                  OpenLibrary( "dos.library", 37L )) == NULL)
      {
      CloseLibs();
      CloseLibrary( UtilityBase );
      CloseLibrary( IconBase );
      return( -4 );
      }

   if (SetupScreen() < 0)
      {
      CloseLibs();
      CloseLibrary( UtilityBase );
      CloseLibrary( IconBase );
      return( -5 );
      }   

   if (OpenCBWindow() < 0)
      {
      ShutdownCBlipper();
      return( -6 );
      }   

   if (MakeClipList() < 0)
      {
      // We're out of memory!
      ShutdownCBlipper();
      return( -7 );
      }

   MakeToolTypeList();
   return( 0 );   
}

// ------------------------------------------------------------------

PRIVATE void *processToolTypes( char **toolptr )
{
   if (toolptr == NULL)
      return( NULL );

   TTClipPath    = GetToolStr( toolptr, "CLIPPATH",    DefClipPath    );
   TTTextEditor  = GetToolStr( toolptr, "TEXTEDITOR",  DefTextEditor  );
   TTTextViewer  = GetToolStr( toolptr, "TEXTVIEWER",  DefTextViewer  );
   TTImageEditor = GetToolStr( toolptr, "IMAGEEDITOR", DefImageEditor );
   TTImageViewer = GetToolStr( toolptr, "IMAGEVIEWER", DefImageViewer );
   TTProgramPath = GetToolStr( toolptr, "PROGRAMPATH", DefProgramPath );

   return( NULL );
}

PRIVATE void UpdateToolTypeList( void )
{
   GT_SetGadgetAttrs( ToolTypeListView, CBWnd, NULL,
                      GTLV_Labels, ~0,
                      TAG_DONE
                    );

   sprintf( &TTNodeStrs[0],           "%s%s", ClipPath,    TTClipPath    );
   sprintf( &TTNodeStrs[STRLENGTH],   "%s%s", TextEditor,  TTTextEditor  );
   sprintf( &TTNodeStrs[2*STRLENGTH], "%s%s", TextViewer,  TTTextViewer  );
   sprintf( &TTNodeStrs[3*STRLENGTH], "%s%s", ImageEditor, TTImageEditor );
   sprintf( &TTNodeStrs[4*STRLENGTH], "%s%s", ImageViewer, TTImageViewer );
   sprintf( &TTNodeStrs[5*STRLENGTH], "%s%s", ProgramPath, TTProgramPath );

   GT_SetGadgetAttrs( ToolTypeListView, CBWnd, NULL,
                      GTLV_Labels,       (struct List *) &TTList,
                      GTLV_ShowSelected, ToolTypeString,
                      GTLV_Selected,     TRUE,
                      GTLV_MaxPen,       255,
                      GTLV_ItemHeight,   12,
                      TAG_DONE
                    );

   GT_RefreshWindow( CBWnd, NULL );
   return;
}

/****i* SetupButtonGadgets() ----------------------------------------
*
* NAME
*    SetupButtonGadgets()
*
* DESCRIPTION
*    Some buttons can't be used before the user has loaded a clip
*    into the program, so they're disabled by this function.
*********************************************************************
*
*/

PRIVATE void SetupButtonGadgets( void )
{
   GT_SetGadgetAttrs( VIEWCLIPBt, CBWnd, NULL, 
                      GA_Disabled, TRUE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( DELETECLIPBt, CBWnd, NULL, 
                      GA_Disabled, TRUE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( EDITCLIPBt, CBWnd, NULL, 
                      GA_Disabled, TRUE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( FILE2CLIPBt, CBWnd, NULL, 
                      GA_Disabled, TRUE, TAG_DONE 
                    );

   GT_SetGadgetAttrs( CLIP2FILEBt, CBWnd, NULL, 
                      GA_Disabled, TRUE, TAG_DONE 
                    );

   return;
}

// ------------------------------------------------------------------

PUBLIC int main( int argc, char **argv )
{
   /* These two symbols, _WBArgc and _WBArgv, are initialized if     */
   /* the program was invoked from WorkBench.  They look like normal */
   /* C (argc, argv) parameters.  The parameters are gathered as     */
   /* follows:                                                       */

   /*   Name of the program                                          */
   /*   Any tooltypes specified in the ToolTypes array               */
   /*   Any icons supplied as arguments (with SHIFT-CLICK)           */

   /* Defined in the link libraries: */

   // extern int _WBArgc;
   // extern char **_WBArgv;
   
   struct WBArg  *wbarg;
   char         **toolptr = NULL;

   if (SetupCBlipper() < 0)
      {
      ShutdownCBlipper();
      return( RETURN_FAIL );
      }
   
   if (argc > 0)    /* from CLI:       */
      {
      // We prefer to use the ToolTypes: 
      (void) FindIcon( &processToolTypes, diskobj, argv[0] );
      }
   else             /* from Workbench: */
      {
      // argc = _WBArgc;
      // argv = _WBArgv;
      
      wbarg   = &(_WBenchMsg->sm_ArgList[ _WBenchMsg->sm_NumArgs - 1 ]);
      toolptr = FindTools( diskobj, wbarg->wa_Name, wbarg->wa_Lock );

      processToolTypes( toolptr );
      }

   UpdateToolTypeList(); // Reflect the Icon tooltypes -> listview.
   
   SetNotifyWindow( CBWnd ); // For GetUserResponse().

   SetupButtonGadgets();
      
   (void) HandleCBIDCMP();

   FreeDiskObject( diskobj );

   ShutdownCBlipper();

   return( RETURN_OK );  
}

/* ------------------- END of ClipIt.c file! ------------------------- */
