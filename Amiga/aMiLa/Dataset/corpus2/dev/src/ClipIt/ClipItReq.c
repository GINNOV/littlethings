/****h *ClipIt!/ClipItReq.c ******************************************
**
** NAME
**    ClipItReq.c
**
** FUNCTIONAL INTERFACE:
**
**    PUBLIC int GetClipNumber( void );
**
**  GUI Designed by : Jim Steichen
**********************************************************************
*/

#include <string.h>

#include <exec/types.h>

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>

#include <libraries/gadtools.h>

#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/diskfont_protos.h>

#include "CPGM:GlobalObjects/CommonFuncs.h"

#define StrBfPtr( g ) (((struct StringInfo *)g->SpecialInfo)->Buffer)

#define CN       0
#define OkayBt   1
#define CancelBt 2
#define LUTxt    3

#define CR_CNT   4

#define ClipNumberGad CRGadgets[ CN    ]
#define CurrentNumber CRGadgets[ LUTxt ]

IMPORT struct IntuitionBase *IntuitionBase;
IMPORT struct Library       *GadToolsBase;

IMPORT struct Screen   *Scr;
IMPORT APTR             VisualInfo;

IMPORT struct TextFont *DBCFont;     // Probably not needed.
IMPORT struct CompFont  CFont;
IMPORT struct TextAttr *Font;

// -------------------------------------------------------------------

PRIVATE struct Window       *CRWnd   = NULL;
PRIVATE struct Gadget       *CRGList = NULL;
PRIVATE struct IntuiMessage  CRMsg;
PRIVATE struct Gadget       *CRGadgets[ CR_CNT ];

PRIVATE UWORD  CRLeft   = 165;
PRIVATE UWORD  CRTop    = 95;
PRIVATE UWORD  CRWidth  = 400;
PRIVATE UWORD  CRHeight = 95;

PRIVATE UBYTE *CRWdt = (UBYTE *) "ClipIt! © needs more information:";

PRIVATE struct IntuiText CRIText[] = {

   2, 0, JAM1,10, 19, NULL, 
   (UBYTE *) "Please enter a clipboard number for the function", NULL,
   
   2, 0, JAM1,40, 29, NULL, 
   (UBYTE *)    "that you've requested (0 [Default] to 255)", NULL 
};

#define CR_TNUM 2

PRIVATE UWORD CRGTypes[] = { 
    
   STRING_KIND, BUTTON_KIND, BUTTON_KIND, TEXT_KIND 
};

PRIVATE int CNClicked(       void );
PRIVATE int OkayBtClicked(   void );
PRIVATE int CancelBtClicked( void );

PRIVATE struct NewGadget CRNGad[] = {

    45, 40, 50, 20, (UBYTE *) "Clip _Number:", NULL,  CN, 
   PLACETEXT_ABOVE, NULL, (APTR) CNClicked,
   
    10, 70, 69, 19, (UBYTE *) " _OKAY ",       NULL,  OkayBt, 
   PLACETEXT_IN, NULL, (APTR) OkayBtClicked,
   
   318, 70, 72, 19, (UBYTE *) " _CANCEL ",     NULL,  CancelBt, 
   PLACETEXT_IN, NULL, (APTR) CancelBtClicked,

   180, 40, 50, 20, (UBYTE *) "Current #:",    NULL,  LUTxt, 
   PLACETEXT_ABOVE, NULL, NULL
};

PRIVATE ULONG CRGTags[] = {

   (GA_TabCycle), FALSE, (GTST_MaxChars), 5, 
   (STRINGA_Justification), (GACT_STRINGCENTER), 
   (GT_Underscore), '_', (TAG_DONE),
   
   (GT_Underscore), '_', (TAG_DONE),
   (GT_Underscore), '_', (TAG_DONE),
   
   (GTTX_Border), TRUE, (TAG_DONE)
};

//  ---------------------------------------------------------------

PRIVATE void CloseCRWindow( void )
{
   if (CRWnd != NULL) 
      {
      CloseWindow( CRWnd );
      CRWnd = NULL;
      }

   if (CRGList != NULL) 
      {
      FreeGadgets( CRGList );
      CRGList = NULL;
      }

   return;
}

PRIVATE int CRCloseWindow( void )
{
   CloseCRWindow();
   return( (int) FALSE );
}

#define GOTCLIPNUMBER 2

PRIVATE TheClipNumber = -1;

PRIVATE int CNClicked( void )
{
   int clipnum = -1;
   
   clipnum = atoi( StrBfPtr( ClipNumberGad ) ); 

   if (clipnum < 0 || clipnum > 255)
      {
      char ErrMsg[256];
      
      sprintf( ErrMsg, 
               "%d is outside the range of valid clip #'s!", clipnum
             );

      clipnum = -1;

      SetReqButtons( "Oops, OKAY!" );

      (void) Handle_Problem( ErrMsg, "User ERROR:", NULL );

      SetReqButtons( "CONTINUE|ABORT" );

      return( (int) TRUE );
      }

   TheClipNumber = clipnum;

   CloseCRWindow();

   return( GOTCLIPNUMBER );
}


PRIVATE int OkayBtClicked( void )
{
   if (TheClipNumber < 0)
      {
      SetReqButtons( "OKAY!" ); 

      (void) Handle_Problem( "Enter a clip number!", "User ERROR:", NULL );

      SetReqButtons( "CONTINUE|ABORT" ); 

      return( (int) TRUE );
      }

   CloseCRWindow();
   return( GOTCLIPNUMBER );
}

PRIVATE int CancelBtClicked( void )
{
   return( CRCloseWindow() );
}


PRIVATE int ProcessKey( int whichkey )
{
   int rval = 0;
   
   switch (whichkey)
      {
      case 'c':
      case 'C':
         rval = CancelBtClicked();
         break;
                
      case 'o':
      case 'O':
         rval = OkayBtClicked();
         break;
               
      case 'n':
      case 'N':    
         rval = CNClicked();
         break;
      } 

   return( rval );
}

// ----------------------------------------------------------------

PRIVATE void CRRender( void )
{
   struct IntuiText it;
   UWORD            cnt;

   ComputeFont( Scr, Font, &CFont, CRWidth, CRHeight );

   for (cnt = 0; cnt < CR_TNUM; cnt++) 
      {
      CopyMem( (char *) &CRIText[ cnt ], (char *) &it, 
               (long) sizeof( struct IntuiText )
             );

      it.ITextFont = Font;
/*
      it.LeftEdge  = CFont.OffX + ComputeX( CFont.FontX, it.LeftEdge ) 
                      - (IntuiTextLength( &it ) >> 1);
      
      it.TopEdge   = CFont.OffY + ComputeY( CFont.FontY, it.TopEdge ) 
                      - (Font->ta_YSize >> 1);
*/
      PrintIText( CRWnd->RPort, &it, 0, 0 );
      }

   return;
}

PRIVATE int OpenCRWindow( void )
{
   struct NewGadget  ng;
   struct Gadget    *g;
   UWORD             lc, tc;
   UWORD             wleft = CRLeft, wtop = CRTop, ww, wh;

   ComputeFont( Scr, Font, &CFont, CRWidth, CRHeight );

   ww = ComputeX( CFont.FontX, CRWidth );
   wh = ComputeY( CFont.FontY, CRHeight );

   if ((wleft + ww + CFont.OffX + Scr->WBorRight) > Scr->Width) 
      wleft = Scr->Width - ww;

   if ((wtop + wh + CFont.OffY + Scr->WBorBottom) > Scr->Height) 
      wtop = Scr->Height - wh;

   if ( !(g = CreateContext( &CRGList )))
      return( -1 );

   for (lc = 0, tc = 0; lc < CR_CNT; lc++) 
      {
      CopyMem( (char *) &CRNGad[ lc ], (char *) &ng, 
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
      ng.ng_Height     = ComputeY( CFont.FontY, ng.ng_Height);

      CRGadgets[ lc ] = g = CreateGadgetA( (ULONG) CRGTypes[ lc ], 
                              g, 
                              &ng, 
                              (struct TagItem *) &CRGTags[ tc ] );

      while (CRGTags[ tc ]) 
         tc += 2;

      tc++;
      if (NOT g)
         return( -2 );
      }

   if ( !(CRWnd = OpenWindowTags( NULL,

                   WA_Left,        wleft,
                   WA_Top,         wtop,
                   WA_Width,       ww + CFont.OffX + Scr->WBorRight,
                   WA_Height,      wh + CFont.OffY + Scr->WBorBottom,
                   
                   WA_IDCMP,       STRINGIDCMP | BUTTONIDCMP 
                     | IDCMP_REFRESHWINDOW | IDCMP_RAWKEY, // | IDCMP_CLOSEWINDOW,
                   
                   WA_Flags,       WFLG_SMART_REFRESH | WFLG_ACTIVATE
                     | WFLG_RMBTRAP,
                   
                   WA_Gadgets,     CRGList,
                   WA_Title,       CRWdt,
                   WA_ScreenTitle, "ClipIt! ©1999 by J.T. Steichen",
                   TAG_DONE )))
      return( -4 );

   GT_RefreshWindow( CRWnd, NULL );
   CRRender();
   return( 0 );
}

PRIVATE int HandleCRIDCMP( void )
{
   struct IntuiMessage *m;
   int                 (*func)( void );
   BOOL                running = TRUE;

   while (running == TRUE)
      {
      if ((m = GT_GetIMsg( CRWnd->UserPort )) == NULL) 
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
         case IDCMP_REFRESHWINDOW:
            GT_BeginRefresh( CRWnd );
            CRRender();
            GT_EndRefresh( CRWnd, TRUE );
            break;

         case IDCMP_RAWKEY:
            running = ProcessKey( (int) CRMsg.Code );
            break;
/*
         case IDCMP_CLOSEWINDOW:
            running = CRCloseWindow();
            break;
*/
         case IDCMP_GADGETUP:
            func = (void *) ((struct Gadget *)CRMsg.IAddress)->UserData;
   
            if (func != NULL)
               running = func();
            break;
         }
      }
   
   return( running );
}

PUBLIC int GetClipNumber( int CurrentClipNumber )
{
   IMPORT char *Int2ASCII( int number );
   
   int rval = 0, clipnum = -1;
   
   if (OpenCRWindow() < 0)
      {
      SetReqButtons( "OKAY!" );

      (void) Handle_Problem( "Couldn't open ClipNumber requester! ", 
                             "System Problem:", NULL 
                           );

      SetReqButtons( "CONTINUE|ABORT" );
      return( -1 );
      }

   GT_SetGadgetAttrs( CurrentNumber, CRWnd, NULL,
                      GTTX_Text, (STRPTR) Int2ASCII( CurrentClipNumber ), 
                      TAG_END
                    );
   
   rval = HandleCRIDCMP();

   if (rval == GOTCLIPNUMBER)
      clipnum = TheClipNumber;
      
   return( clipnum );
}

/* -------------------- END of ClipItReq.c file! ------------------- */
