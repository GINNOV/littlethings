/****h* ClipItReq.c [2.0] **********************************************
*
* NAME
*    ClipItReq.c
*
* DESCRIPTION
*    ClipItReq.c is a GUI for the ClipIt! program.
*
* SYNOPSIS
*    int clipNum = GetClipNumber( int CurrentClipNumber );
*
* RETURNS
*    The clip Number the user entered or ERROR_ON_OPENING_WINDOW
*    if the GUI could NOT be opened for some reason.
*
* HISTORY
*    02-Nov-2005 - Created this file.
*
* COPYRIGHT
*    ClipItReq.c 02-Nov-2005(C) by J.T. Steichen
*
* NOTES
*    Program set up to compile with gcc & AmigaOS4 also.
*
*    $VER: ClipItReq.c 2.0 (02-Nov-2005) by J.T. Steichen
************************************************************************
*
*/

#include <stdio.h>
#include <string.h>

#include <exec/types.h>

#include <AmigaDOSErrs.h>

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>

#include <libraries/gadtools.h>

#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>

#ifndef __amigaos4__

# include <proto/locale.h>

# include <clib/exec_protos.h>
# include <clib/intuition_protos.h>
# include <clib/gadtools_protos.h>
# include <clib/graphics_protos.h>
# include <clib/utility_protos.h>
# include <clib/diskfont_protos.h>

#else

# define __USE_INLINE__

# include <proto/exec.h>
# include <proto/dos.h>
# include <proto/intuition.h>
# include <proto/gadtools.h>
# include <proto/graphics.h>
# include <proto/utility.h>
# include <proto/diskfont.h>
# include <proto/locale.h>

#endif

IMPORT struct Catalog *catalog;

#define   CATCOMP_ARRAY    1
#include "ClipItLocale.h"

#define  MY_LANGUAGE "english"

#include "CPGM:GlobalObjects/CommonFuncs.h"

#define ID_CN 	        0
#define ID_OkayBt 	1
#define ID_CancelBt 	2
#define ID_LUTxt 	3

#define CR_CNT 		4

#define ClipNumberGad CRGadgets[ ID_CN ]
#define ClipNumberTxt CRGadgets[ ID_LUTxt ]

// ----------------------------------------------------

#ifndef __amigaos4__

IMPORT struct IntuitionBase *IntuitionBase;
IMPORT struct GfxBase       *GfxBase;
IMPORT struct Library       *GadToolsBase;
IMPORT struct LocaleBase    *LocaleBase;

#else

IMPORT struct Library *SysBase;
IMPORT struct Library *DOSBase;
IMPORT struct Library *IntuitionBase;
IMPORT struct Library *GfxBase;
IMPORT struct Library *UtilityBase;
IMPORT struct Library *DiskfontBase;
IMPORT struct Library *LocaleBase;
IMPORT struct Library *GadToolsBase;

IMPORT struct ExecIFace      *IExec;
IMPORT struct DOSIFace       *IDOS;
IMPORT struct IntuitionIFace *IIntuition;
IMPORT struct GraphicsIFace  *IGraphics;
IMPORT struct UtilityIFace   *IUtility;
IMPORT struct DiskfontIFace  *IDiskfont;
IMPORT struct LocaleIFace    *ILocale;
IMPORT struct GadToolsIFace  *IGadTools;

#endif

// ----------------------------------------------------

IMPORT UBYTE           *ErrMsg;
IMPORT UBYTE           *PubScreenName;

IMPORT struct Screen   *DBCScr;
IMPORT struct TextFont *DBCFont;
IMPORT struct TextAttr *Font;
IMPORT struct CompFont  CFont;
IMPORT struct TextAttr  Helvetica13;
// IMPORT struct TextAttr  topaz8;

IMPORT APTR             VisualInfo;

// ----------------------------------------------------

PRIVATE struct Window       *CRWnd   = NULL;
PRIVATE struct Gadget       *CRGList = NULL;
PRIVATE struct Gadget       *CRGadgets[ CR_CNT ] = { 0, };

PRIVATE struct IntuiMessage  CRMsg = { 0, };

PRIVATE UWORD  CRLeft   = 296;
PRIVATE UWORD  CRTop    = 271;
PRIVATE UWORD  CRWidth  = 360;
PRIVATE UWORD  CRHeight = 165;
PRIVATE UBYTE *CRWdt    = NULL;   // WA_Title

#define CR_TNUM 2

PRIVATE struct IntuiText CRIT[ CR_TNUM ] = {

   2, 0, JAM1,  47,  28, NULL, "Please enter a clipboard number for the function", NULL,
   2, 0, JAM1,  63,  43, NULL, "that you've requested (0 [Default] to 255)", NULL,
};

PRIVATE UWORD CRGTypes[ CR_CNT ] = {

   STRING_KIND, BUTTON_KIND, BUTTON_KIND, TEXT_KIND,
};

PRIVATE int CNClicked(       void );
PRIVATE int OkayBtClicked(   void );
PRIVATE int CancelBtClicked( void );

PRIVATE struct NewGadget CRNGad[ CR_CNT ] = {

    49,  83,  56,  20, "Clip _Number:", NULL,
   ID_CN, PLACETEXT_ABOVE, NULL, (APTR) CNClicked,

    19, 126,  69,  19, "_OKAY ", NULL,
   ID_OkayBt, PLACETEXT_IN, NULL, (APTR) OkayBtClicked,

   243, 126,  72,  19, "_CANCEL  ", NULL,
   ID_CancelBt, PLACETEXT_IN, NULL, (APTR) CancelBtClicked,

   245,  83,  59,  20, "Current #:", NULL,
   ID_LUTxt, PLACETEXT_ABOVE, NULL, (APTR) NULL,
};

PRIVATE ULONG CRGTags[] = {

   GA_TabCycle,           FALSE, 
   GTST_MaxChars,         5, 
   GT_Underscore,         '_', 
   STRINGA_Justification, GTJ_LEFT, 
   TAG_DONE,

   GT_Underscore, '_', TAG_DONE,

   GT_Underscore, '_', TAG_DONE,

   GTTX_Border, TRUE, TAG_DONE,
};

// ----------------------------------------------------

IMPORT STRPTR CMsg( int strIndex, char *defaultString );

/****i* SetupCatalog() [2.0] *****************************************
*
* NAME
*    SetupCatalog()
*
* DESCRIPTION
*    Localize the strings to whatever loanguage the User has a catalog
*    for.
**********************************************************************
*
*/

PRIVATE void SetupCRCatalog( void )
{
   CRWdt = CMsg( MSG_CR_WTITLE, MSG_CR_WTITLE_STR ); // WA_Title

   CRIT[0].IText = (UBYTE *) CMsg( MSG_ITXT_CR0, MSG_ITXT_CR0_STR );
   CRIT[1].IText = (UBYTE *) CMsg( MSG_ITXT_CR1, MSG_ITXT_CR1_STR );

   CRNGad[ 0 ].ng_GadgetText = CMsg( MSG_GAD_CN,       MSG_GAD_CN_STR       );
   CRNGad[ 1 ].ng_GadgetText = CMsg( MSG_GAD_OkayBt,   MSG_GAD_OkayBt_STR   );
   CRNGad[ 2 ].ng_GadgetText = CMsg( MSG_GAD_CancelBt, MSG_GAD_CancelBt_STR );
   CRNGad[ 3 ].ng_GadgetText = CMsg( MSG_GAD_LUTxt,    MSG_GAD_LUTxt_STR    );

   return;
}

// ----------------------------------------------------------------

PRIVATE void CloseCRWindow( void )
{
   if (CRWnd)
      {
      CloseWindow( CRWnd );

      CRWnd = NULL;
      }

   if (CRGList)
      {
      FreeGadgets( CRGList );

      CRGList = NULL;
      }

   return;
}

PRIVATE int CRCloseWindow( void )
{
   CloseCRWindow();

   return( FALSE );
}

// ----------------------------------------------------------------

#define GOTCLIPNUMBER 2

PRIVATE TheClipNumber = -1;

PRIVATE int CNClicked( void )
{
   int clipnum = -1;
   
   clipnum = atoi( StrBfPtr( ClipNumberGad ) ); 

   if (clipnum < 0 || clipnum > 255)
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_BAD_CLIPNUM, MSG_FMT_BAD_CLIPNUM_STR ), clipnum );

      clipnum = -1;

      SetReqButtons( CMsg( MSG_OOPS_BUTTON, MSG_OOPS_BUTTON_STR ) );

      UserInfo( ErrMsg, CMsg( MSG_USER_ERROR, MSG_USER_ERROR_STR ) );

      SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

      return( TRUE );
      }

   TheClipNumber = clipnum;

   CloseCRWindow();

   return( GOTCLIPNUMBER );
}

PRIVATE int OkayBtClicked( void )
{
   if (TheClipNumber < 0)
      {
      SetReqButtons( CMsg( MSG_WELL_OKAY_BUTTON, MSG_WELL_OKAY_BUTTON_STR ) ); 

      UserInfo( CMsg( MSG_ENTER_CLIPNUM, MSG_ENTER_CLIPNUM_STR ),
                CMsg( MSG_USER_ERROR, MSG_USER_ERROR_STR )
              );

      SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

      return( TRUE );
      }

   CloseCRWindow();

   return( GOTCLIPNUMBER );
}

PRIVATE int CancelBtClicked( void )
{
   return( CRCloseWindow() );
}

// ----------------------------------------------------------------

PRIVATE void IntuiTextRender( void )
{
  struct IntuiText it;
  UWORD            cnt;

  ComputeFont( DBCScr, Font, &CFont, CRWidth, CRHeight );

  for (cnt = 0; cnt < CR_TNUM; cnt++)
     {
     CopyMem( (char *) &CRIT[ cnt ], (char *) &it,
              (long) sizeof( struct IntuiText )
            );

     it.ITextFont = &Helvetica13;

     it.TopEdge   = CFont.OffY + ComputeY( CFont.FontY, it.TopEdge )
                    - (Font->ta_YSize >> 1);

     PrintIText( CRWnd->RPort, &it, 0, 0 );
     }

  return;
}

PRIVATE int OpenCRWindow( void )
{
   struct NewGadget  ng;
   struct Gadget    *g;
   UWORD             lc, tc;
   UWORD             wleft, wtop, ww, wh;

   ComputeFont( DBCScr, Font, &CFont, CRWidth, CRHeight );

   ww = ComputeX( CFont.FontX, CRWidth  );
   wh = ComputeY( CFont.FontY, CRHeight );

   wleft = (DBCScr->Width  - CRWidth ) / 2;
   wtop  = (DBCScr->Height - CRHeight) / 2;

   if (!(g = CreateContext( &CRGList )))
      return( ERROR_NO_FREE_STORE );

   for (lc = 0, tc = 0; lc < CR_CNT; lc++)
      {
      CopyMem( (char *) &CRNGad[ lc ], (char *) &ng,
               (long) sizeof( struct NewGadget )
             );

      ng.ng_VisualInfo = VisualInfo;
      ng.ng_TextAttr   = &Helvetica13;
      ng.ng_LeftEdge   = CFont.OffX + ComputeX( CFont.FontX, ng.ng_LeftEdge );
      ng.ng_TopEdge    = CFont.OffY + ComputeY( CFont.FontY, ng.ng_TopEdge );

      CRGadgets[ lc ] = g
                      = CreateGadgetA( (ULONG) CRGTypes[ lc ],
                                       g,
                                       &ng,
                                       (struct TagItem *) &CRGTags[ tc ]
                                     );

      while (CRGTags[ tc ] != TAG_DONE)
         tc += 2;

      tc++;

      if (!g)
         return( ERROR_NO_FREE_STORE );
      }

   if (!(CRWnd = OpenWindowTags( NULL,

         WA_Left,          wleft,
         WA_Top,           wtop,
         WA_Width,         ww + CFont.OffX + DBCScr->WBorRight,
         WA_Height,        wh + CFont.OffY + DBCScr->WBorBottom,

         WA_IDCMP,        STRINGIDCMP | BUTTONIDCMP | TEXTIDCMP | 
           IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_REFRESHWINDOW,

         WA_Flags,         WFLG_ACTIVATE | WFLG_DRAGBAR | WFLG_RMBTRAP,

         WA_NewLookMenus,  TRUE,
         WA_Gadgets,       CRGList,
         WA_Title,         CRWdt,
         WA_CustomScreen,  DBCScr,
         TAG_DONE )))
      {
      return( ERROR_ON_OPENING_WINDOW );
      }

   IntuiTextRender();

   GT_RefreshWindow( CRWnd, NULL );

   return( RETURN_OK );
}


PRIVATE int CRVanillaKey( int whichKey )
{
   int rval = TRUE;

   switch (whichKey)
      {
      case 'q':
      case 'Q':
      case 'c':
      case 'C':
         rval = CancelBtClicked();
         break;

      case 'n':
      case 'N': // Clip _Number
         rval = CNClicked();
	 break;

      case 'o':
      case 'O': // _OKAY
         rval = OkayBtClicked();
	 break;

      default:
         break;
      }

   return( rval );
}

PRIVATE int HandleCRIDCMP( void )
{
   struct IntuiMessage *m;
   int                (*func)( void );
   BOOL                 running = TRUE;

   while (running == TRUE)
      {
      if (!(m = GT_GetIMsg( CRWnd->UserPort )))
         {
         (void) Wait( 1L << CRWnd->UserPort->mp_SigBit );

         continue;
         }

      CopyMem( (char *) m, (char *) &CRMsg, 
               (long) sizeof( struct IntuiMessage )
             );

      GT_ReplyIMsg( m );

      switch (CRMsg.Class)
         {
         case IDCMP_CLOSEWINDOW:
            running = CRCloseWindow();
            break;

         case IDCMP_GADGETUP:
            if ((func = (int (*)( void )) ((struct Gadget *) CRMsg.IAddress)->UserData))
               running = func();

            break;

         case IDCMP_VANILLAKEY:
            running = CRVanillaKey( CRMsg.Code );
            break;

         case IDCMP_REFRESHWINDOW:
            GT_BeginRefresh( CRWnd );

               IntuiTextRender();

            GT_EndRefresh( CRWnd, TRUE );
            break;
         }
      }

   return( running );
}

// ----------------------------------------------------------------

PUBLIC int GetClipNumber( int CurrentClipNumber )
{
   IMPORT char *Int2ASCII( int number ); // In ClipIt.c file
   
   int rval = RETURN_OK, clipnum = -1;
   
   if ((rval = OpenCRWindow()) != RETURN_OK)
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_NOGUI_ERR, MSG_FMT_NOGUI_ERR_STR ), 
                       CMsg( MSG_REQ_NAME, MSG_REQ_NAME_STR ), rval 
	     );
      
      SetReqButtons( CMsg( MSG_WELL_OKAY_BUTTON, MSG_WELL_OKAY_BUTTON_STR ) ); 

      UserInfo( ErrMsg, CMsg( MSG_SYSTEM_PROBLEM, MSG_SYSTEM_PROBLEM_STR ) );

      SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

      return( ERROR_ON_OPENING_WINDOW );
      }

   SetupCRCatalog();
   
   GT_SetGadgetAttrs( ClipNumberTxt, CRWnd, NULL,
                      GTTX_Text, (STRPTR) Int2ASCII( CurrentClipNumber ), 
                      TAG_END
                    );

   SetNotifyWindow( CRWnd );
      
   rval = HandleCRIDCMP();

   if (rval == GOTCLIPNUMBER)
      clipnum = TheClipNumber;
      
   return( clipnum );
}

/* --------------- END of ClipItReq.c file! ------------------ */
