/*****************************************************************************
 *
 * COPYRIGHT: Unless otherwise noted, all files are Copyright (c) 1999-2001
 * strandedUFO Productions.  All rights reserved.
 *
 * DISCLAIMER: This software is provided "as is".  No representations or
 * warranties are made with respect to the accuracy, reliability,
 * performance, currentness, or operation of this software, and all use is at
 * your own risk.  The author will not assume any responsibility or
 * liability whatsoever with respect to your use of this software.
 *
 *****************************************************************************
 * test.c
 * a program to test the waveforms.image BOOPSI class
 * Written by P. Juhasz
 *
 */

#define __USE_SYSBASE        // perhaps only recognized by SAS/C

#include "waveforms.h"
#include "waveformsbase.h"

#include <dos/dos.h>

#include <clib/dos_protos.h>
#include <clib/alib_stdio_protos.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/diskfont.h>
#include <proto/intuition.h>
#include <proto/icon.h>

#include <gadgets/button.h>
#include <graphics/text.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/gadtools_pragmas.h>

#include <workbench/startup.h>
#include <workbench/icon.h>

#include <dos.h>
#include <stdlib.h>
#include <string.h>


#define IDCMP_FLAGS  IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_GADGETUP | IDCMP_GADGETDOWN \
                     | IDCMP_MOUSEMOVE | IDCMP_INTUITICKS | IDCMP_MOUSEBUTTONS | IDCMP_NEWSIZE  \
                     | IDCMP_SIZEVERIFY | IDCMP_CHANGEWINDOW | IDCMP_REFRESHWINDOW

#define GD_Dummy     11
#define GD_WaveSel   12

#define IMAGE_WID    60
#define IMAGE_HGT    60
#define IMAGE_TOP    20
#define GADIMG_WID   27
#define GADIMG_HGT   27

extern struct  ExecBase      *SysBase;
extern struct  DosLibrary    *DOSBase;
extern struct  Library       *DiskfontBase;

struct  IntuitionBase        *IntuitionBase = NULL;

STATIC struct  GfxBase       *GfxBase       = NULL;
STATIC struct  UtilityBase   *UtilityBase   = NULL;
STATIC struct  Library       *GadToolsBase  = NULL,
                             *WorkbenchBase = NULL;

STATIC struct  ClassLibrary  *openclass( STRPTR name, ULONG version );


STATIC ULONG wfimg_RGB32[98] =
{
   0x00200000, /* Record Header */
   0xAAAAAAAA,0xAAAAAAAA,0xAAAAAAAA,
   0x08888888,0x0CCCCCCC,0x0CCCCCCC,
   0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,
   0x45555555,0x6DDDDDDD,0x9EEEEEEE,
   0x5DDDDDDD,0x55555555,0x3DDDDDDD,
   0xD2222222,0xD2222222,0xD2222222,
   0xDBBBBBBB,0x7DDDDDDD,0x41111111,
   0xCAAAAAAA,0x35555555,0xBAAAAAAA,
   0x82222222,0x00000000,0x00000000,
   0xD6666666,0x8AAAAAAA,0x0CCCCCCC,
   0xDFFFFFFF,0xBAAAAAAA,0x45555555,
   0x92222222,0x92222222,0x41111111,
   0x00000000,0x45555555,0x00000000,      /* dark green background */
   0x00000000,0xFBBBBBBB,0x59999999,      /* light green pen */
   0xFFFFFFFF,0xFFFFFFFF,0x14444444,      /* yellow zero line */
   0xC2222222,0x9AAAAAAA,0xC2222222,
   0x20000000,0x00000000,0x20000000,
   0xAEEEEEEE,0xAEEEEEEE,0xF3333333,
   0xBEEEEEEE,0xAAAAAAAA,0x92222222,
   0x59999999,0x10000000,0x5DDDDDDD,
   0x31111111,0x39999999,0x71111111,
   0x59999999,0x49999999,0xB6666666,
   0x8AAAAAAA,0x8AAAAAAA,0x86666666,
   0xAAAAAAAA,0x69999999,0xA2222222,
   0x7DDDDDDD,0x86666666,0xC6666666,
   0x92222222,0x35555555,0x82222222,
   0x75555555,0xE3333333,0xEFFFFFFF,
   0xDFFFFFFF,0x35555555,0x35555555,
   0x00000000,0x45555555,0x9AAAAAAA,
   0x59999999,0xBAAAAAAA,0xB2222222,
   0x24444444,0x24444444,0x1CCCCCCC,
   0x04444444,0x14444444,0x45555555,
   0x00000000  /* Terminator */
};


/* These are: DETAILPEN, BLOCKPEN, TEXTPEN, SHINEPEN, SHADOWPEN, FILLPEN, FILLTEXTPEN,
               BACKGROUNDPEN, HIGHLIGHTTEXTPEN, v39+ --> BARDETAILPEN, BARBLOCKPEN, BARTRIMPEN */

#define        WFI_PENS    12L

STATIC WORD    DriPens[]    = { 2, 0, 3, 2, 1, 5, 1, 0, 7, 6, 4, 5, 12, 13, 14, ~0 };

STATIC WORD    usepen[]     = { 2, 0, 3, 2, 1, 5, 1, 0, 7, 6, 4, 5, 12, 13, 14, ~0 };

STATIC char   *wavelabel[5] = { "Sine", "Triangle", "Ramp-up", "Ramp-down", "Square" };

STATIC BOOL    realosci     = FALSE;



/*__________________________________________________________________________________________
 |                                                                                          |
 |    Create and draw the new waveforms images                                              |
 |__________________________________________________________________________________________*/

STATIC VOID make_waveforms( struct Window *win, struct DrawInfo *DrInfo, struct Image *img_a )
{
   LONG                    type, otype = 0L, outline, ix, wid, hgt, top;
   ULONG                   tstore, zstore, ostore, ozpen = ~0, oopen = ~0;

   /* As we are reusing this image, we need to store some data for later */
   if ( GetAttr( WFI_WaveType, img_a, &tstore ))      otype = (LONG)tstore;
   if ( GetAttr( WFI_OsciPen, img_a, &ostore ))       oopen = (LONG)ostore;
   if ( GetAttr( WFI_ZeroPen, img_a, &zstore ))       ozpen = (LONG)zstore;

   /*  Draw all possible waveforms images in two different sizes */
   for ( ix = 0; ix < 11; ix += 10 ) {

      wid = IMAGE_WID - ix * 4 + 3;
      hgt = IMAGE_HGT - ix * 4 + 3;
      top = IMAGE_TOP + ix * 20;

      for ( outline = WF_SOLID_DISPLAY; outline <= WF_DOTTED_DISPLAY; outline++ ) {

         for ( type = WF_SINE_WAVE; type < WF_ALL_IMAGES; type++ ) {

            if ( SetAttrs( img_a, IA_Width, wid, IA_Height, hgt, WFI_WaveType, type,
                           WFI_Outline, outline, WFI_BoxFrame, TRUE,
                           WFI_ZeroPen, (ix < 10L ) ? ozpen : oopen,
                           TAG_DONE ))

               /* we have just specified a new image, so draw it */
               DrawImageState( win->RPort, img_a,
                                 win->BorderLeft + 20 + ( type * 16 ) + ( type * wid ),
                                 win->BorderTop + top + (( hgt * 3 / 2 ) * outline ),
                                 IDS_NORMAL, DrInfo );
         }
      }
   }
   /* Since we use only one object, it needs resetting to display correctly in our gadget */
   SetAttrs( img_a, IA_Width, GADIMG_WID, IA_Height, GADIMG_HGT, WFI_WaveType, otype,
             WFI_Outline, WF_DOTTED_DISPLAY, WFI_BoxFrame, FALSE, TAG_DONE );
}


/*__________________________________________________________________________________________
 |                                                                                          |
 |    This is the main gui handler                                                          |
 |__________________________________________________________________________________________*/


STATIC VOID do_user_loop( struct Window *win, struct DrawInfo *DrInfo, struct Image *img_a,
                          struct Image *img_b, struct Gadget *testGList, struct Gadget *testGad )
{
   struct IntuiMessage    *imsg, Mesg;
   BOOL                    going = TRUE;
   ULONG                   sigr, winmask = 1 << ( win->UserPort->mp_SigBit );
   ULONG                   code, store;
   LONG                    type = WF_SINE_WAVE;

   while( going )
   {
      sigr = Wait( winmask );

      if ( sigr & winmask )                        /* it's our Window  */
      {
         while ( imsg = GT_GetIMsg( win->UserPort ))
         {
            CopyMem(( char *)imsg, ( char *)&Mesg, (LONG)sizeof( struct IntuiMessage ));
            GT_ReplyIMsg( imsg );

            switch ( Mesg.Class )
            {
               case  IDCMP_REFRESHWINDOW:

                  BeginRefresh( win );
                  make_waveforms( win, DrInfo, img_a );
                  EndRefresh( win, TRUE );
                  break;

               case IDCMP_CLOSEWINDOW:
                  going = FALSE;
                  break;

               case IDCMP_VANILLAKEY:

                  switch ( Mesg.Code )
                  {
                     case  27:
                     case 'q':
                     case 'Q':
                       going = FALSE;
                       break;
                     default: break;
                  }
                  break;

               case  IDCMP_IDCMPUPDATE:
                  //testIDCMPUpdate();
                  break;

               case  IDCMP_CHANGEWINDOW:
                  //testChangeWindow();
                  break;

               case  IDCMP_GADGETDOWN:

                  code = (( struct Gadget *)Mesg.IAddress )->GadgetID;

                  switch ( code ) {

                     case GD_Dummy:
                        break;

                     default: break;
                  }
                  break;

               case  IDCMP_GADGETUP:

                  code = (( struct Gadget *)Mesg.IAddress )->GadgetID;

                  switch ( code ) {

                     case GD_WaveSel:

                        if ( GetAttr( WFI_WaveType, img_a, &store ))     type = (LONG)store;

                        /* cycle through the waveforms on each gadgethit */
                        if ( type >= WF_SQUARE_WAVE )       type = WF_SINE_WAVE;
                        else                                type++;

                        SetAttrs( img_a, WFI_WaveType, (ULONG)type, TAG_DONE );

                        /* do the alternate image as well */
                        SetAttrs( img_b, WFI_WaveType, (ULONG)type, TAG_DONE );

                        GT_SetGadgetAttrs( testGad, win, NULL,
                                           GTTX_Text,     (ULONG)wavelabel[type],
                                           GTTX_CopyText, TRUE,
                                           TAG_DONE );
                        RefreshGList( testGList, win, NULL, -1L );
                        break;

                     default: break;
                  }
                  break;

               default: break;

            }
         }
      }
   }
}


/*__________________________________________________________________________________________
 |                                                                                          |
 |    Make a solid or dotted waveform image object with default values                      |
 |__________________________________________________________________________________________*/

STATIC struct Image *makeDefImage( struct DrawInfo *DrInfo, ULONG outl )
{
   return( NewObject( NULL, "waveformiclass",
                      IA_Width,         GADIMG_WID,
                      IA_Height,        GADIMG_HGT,
                      IA_FGPen,         (ULONG)usepen[0L],
                      IA_BGPen,         (ULONG)usepen[4L],
                      IA_Left,          0L,
                      IA_Top,           0L,
                      SYSIA_DrawInfo,   DrInfo,
                      WFI_WaveType,     WF_SINE_WAVE,
                      WFI_WaveShape,    0L,
                      WFI_Outline,      outl,
                      WFI_BoxFrame,     FALSE,
                      WFI_OsciPen,      ( realosci ) ? (ULONG)usepen[12L] : ~0,
                      WFI_WavePen,      ( realosci ) ? (ULONG)usepen[13L] : ~0,
                      WFI_ZeroPen,      ( realosci ) ? (ULONG)usepen[14L] : ~0,
                      TAG_DONE ));

}


/*__________________________________________________________________________________________
 |                                                                                          |
 |    Test the waveforms images and the newly created waveforms.image class                 |
 |__________________________________________________________________________________________*/

STATIC LONG run_test( struct Window *win, struct DrawInfo *DrInfo, APTR vinfo )
{
   struct WFIBase         *cb;
   struct Image           *img_a, *img_b;
   struct ClassLibrary    *gadLib;
   LONG                    rtc = 0L;

   if ( cb = (struct WFIBase *)AllocMem( sizeof( struct WFIBase ), MEMF_PUBLIC | MEMF_CLEAR )) {

      if ( raiseClass( cb )) {

         /* Make a new image object with default data, we can reuse it any number of times */
         if ( img_a = makeDefImage( DrInfo, WF_DOTTED_DISPLAY )) {

            /* ...and just for the hell of it, make a separate one for our selected gadget */
            /*       using the 'solid' display - looks real cool - doesn't it ?  */
            if ( img_b = makeDefImage( DrInfo, WF_SOLID_DISPLAY )) {

               /* Print all the possible waveform images into the window */
               make_waveforms( win, DrInfo, img_a );

               if ( gadLib = openclass( "gadgets/button.gadget", LIBRARY_VER )) {

                  UWORD                   sequ;
                  struct NewGadget        ng = { 330, 250, GADIMG_WID + 25L, 13L,
                                                 NULL, NULL, GD_Dummy, 0, NULL, NULL };
                  struct Gadget          *g, *testGList = NULL, *testGads[2];

                  if (( g = CreateContext( &testGList ))) {

                     ng.ng_VisualInfo = vinfo;

                     /* Make one gadget for the list - I kept getting hits on exiting when
                           there is just the one BOOPSI button.gadget on its own... */
                     if ( testGads[0] = g = CreateGadget((ULONG)TEXT_KIND, g, &ng, TAG_DONE )) {

                        /* Our display gadget which cycles through all waveforms */
                        if ( testGads[1] = g = NewObject( NULL, "button.gadget",
                                     GA_Previous,        (ULONG)g,
                                     GA_Top,             240L,
                                     GA_Left,            280L,
                                     GA_Width,           GADIMG_WID + 5L,
                                     GA_Height,          GADIMG_HGT + 5L,
                                     GA_DrawInfo,        DrInfo,
                                     GA_ID,              GD_WaveSel,
                                     //GA_Immediate,       TRUE,
                                     GA_RelVerify,       TRUE,
                                     GA_LabelImage,      img_a,
                                     GA_Image,           img_a,
                                     GA_SelectRender,    img_b,
                                     BUTTON_BevelStyle,  BVS_THIN,
                                     TAG_DONE )) {

                           sequ = AddGList( win, testGList, (UWORD)~0, -1, NULL );
                           GT_SetGadgetAttrs( testGads[0], win, NULL,
                                              GTTX_Text,          (ULONG)wavelabel[0],
                                              GTTX_CopyText,      TRUE,
                                              GTTX_FrontPen,      HIGHLIGHTTEXTPEN,
                                              //GTTX_BackPen,       SHADOWPEN,
                                              TAG_DONE );
                           RefreshGList( testGList, win, NULL, -1L );

                           /* From here on the user is in control */

                           do_user_loop( win, DrInfo, img_a, img_b, testGList, testGads[0] );

                           /* User got fed up, closed the window or pressed quit */

                           RemoveGList( win, testGList, -1L );
                           testGads[1]->GadgetRender = testGads[1]->SelectRender = NULL;
                           DisposeObject( testGads[1] );
                           testGads[1] = testGads[0]->NextGadget = NULL;
                        }
                     }
                     FreeGadgets( testGList );
                  }
                  CloseLibrary(( struct Library *)gadLib );
               }
               DisposeObject( img_b );
            }
            DisposeObject( img_a );
         }
         dropClass( cb );
      }
      FreeMem( cb, sizeof( struct WFIBase ));
   } else   rtc = 10L;

   return( rtc );
}


/*__________________________________________________________________________________________
 |                                                                                          |
 |    Get some BOOPSI gadgets and open a window to display them.                            |
 |__________________________________________________________________________________________*/

STATIC VOID gui_setup( struct Screen *scr, LONG ownscreen )
{
   struct Window          *win;
   struct DrawInfo        *DrInfo = NULL;
   APTR                    vinfo;

   if ( GadToolsBase = OpenLibrary( "gadtools.library", LIBRARY_VER )) {

      if ( DrInfo = GetScreenDrawInfo( scr )) {

         if ( vinfo = GetVisualInfo( scr, TAG_DONE )) {

            ULONG          wintag = ( ownscreen ) ? WA_CustomScreen : WA_PubScreen;
            UWORD          wleft = 180, wtop = 75, WWidth = 440, WHeight = 320;

            if ( win = OpenWindowTags( NULL,
                                    WA_Title,             "waveforms.image Test",
                                    WA_Left,              wleft,
                                    WA_Top,               wtop,
                                    WA_Width,             WWidth,
                                    WA_Height,            WHeight,
                                    WA_IDCMP,             IDCMP_FLAGS,
                                    WA_DragBar,           TRUE,
                                    WA_DepthGadget,       TRUE,
                                    WA_CloseGadget,       TRUE,
                                    WA_SimpleRefresh,     TRUE,
                                    WA_SmartRefresh,      TRUE,
                                    //WA_NoCareRefresh,     TRUE,
                                    WA_Activate,          TRUE,
                                    wintag,               scr,
                                    WA_AutoAdjust,        TRUE,
                                    WA_PubScreenFallBack, TRUE,
                                    TAG_DONE )) {

               GT_RefreshWindow( win, NULL );

               // Screen and window are open, all ready for the big event...
                                                      // shout if something went wrong
               if ( run_test( win, DrInfo, vinfo ))      DisplayBeep( scr );

               CloseWindow( win );
            }
            FreeVisualInfo( vinfo );
         }
         FreeScreenDrawInfo( scr, DrInfo );
      }
      CloseLibrary( GadToolsBase );
   }
}


/*__________________________________________________________________________________________
 |                                                                                          |
 |    Open a custom or public screen and allocate pens if latter.                           |
 |__________________________________________________________________________________________*/

STATIC VOID intui_setup( LONG ownscreen )
{
   struct Screen          *scr;
   LONG                    ix = WFI_PENS, iy;
   ULONG                   red, blue, green;
   ULONG                   lokpen[16] = { 0 };

   if ( IntuitionBase = (struct IntuitionBase *)OpenLibrary( "intuition.library", LIBRARY_VER )) {

      if ( GfxBase = (struct GfxBase *)OpenLibrary( "graphics.library", LIBRARY_VER )) {

         if ( ownscreen ) {

            scr = OpenScreenTags( NULL,
                                  SA_Left,          0,
                                  SA_Top,           0,
                                  SA_Width,         800,
                                  SA_Height,        600,
                                  SA_Depth,         5,
                                  SA_LikeWorkbench, TRUE,
                                  SA_Type,          CUSTOMSCREEN,
                                  SA_AutoScroll,    TRUE,
                                  SA_Pens,          usepen,
                                  SA_SysFont,       TRUE,
                                  SA_Colors32,      wfimg_RGB32,
                                  SA_FullPalette,   TRUE,
                                  SA_SharePens,     TRUE,
                                  SA_Title,         "WaveForms image test",
                                  TAG_DONE );

         } else {

            if ( scr = LockPubScreen( "Workbench" )) {

               while (( usepen[ix] != -1L ) && ( ix < 15 )) {

                  iy    = (LONG)DriPens[ix];
                  red   = wfimg_RGB32[ iy * 3 + 1 ];
                  green = wfimg_RGB32[ iy * 3 + 2 ];
                  blue  = wfimg_RGB32[ iy * 3 + 3 ];

                  usepen[ix] = (( lokpen[ix] = (ULONG)ObtainBestPen( scr->ViewPort.ColorMap,
                                                                    red, green, blue,
                                                                    TAG_DONE )) == ~0 )
                     ? DriPens[ix] : (WORD)lokpen[ix];

                  ix++;
               }
            }
         }

         if ( scr ) {

            gui_setup( scr, ownscreen );

            if ( ownscreen )        CloseScreen( scr );
            else {
               for ( ix = WFI_PENS; ix < 15; ix++ )
                  ReleasePen( scr->ViewPort.ColorMap, lokpen[ix] );
               UnlockPubScreen( NULL, scr );
            }
         }
         CloseLibrary((struct Library *)GfxBase );
      }
      CloseLibrary((struct Library *)IntuitionBase );
   }
}


/*__________________________________________________________________________________________
 |                                                                                          |
 |    Open libraries, open a screen and a window on it, then run the classtest              |
 |__________________________________________________________________________________________*/

int main( int argc, char **argv )
{
   struct WBArg            wbArg = { NULL, NULL };
   struct WBStartup       *wbs;
   LONG                    ownscreen = 0L;

   if ( UtilityBase = (struct UtilityBase *)OpenLibrary( "utility.library", LIBRARY_VER )) {

      if ( WorkbenchBase = OpenLibrary( "workbench.library", LIBRARY_VER )) {

         if ( argc ) {                       // Are we running from CLI...

            wbArg.wa_Lock = GetProgramDir();
            wbArg.wa_Name = argv[0];

            if ( wbs = AllocMem( sizeof( struct WBStartup ), MEMF_PUBLIC | MEMF_CLEAR ))
               wbs->sm_ArgList = &wbArg;

         } else                              // ...or invoked via workbench ?

            wbs = ( struct WBStartup *)argv;

         if ( wbs ) {

            char                   *typevalue = NULL;
            LONG                    localdir = CurrentDir( wbs->sm_ArgList[0].wa_Lock );
            struct DiskObject      *DiskObj = NULL;
            struct Library         *IconsBase = NULL;

            if ( IconsBase = OpenLibrary( ICONNAME, LIBRARY_VER )) {

               if ( DiskObj = GetDiskObject( wbs->sm_ArgList[0].wa_Name )) {
                  if ( DiskObj->do_ToolTypes ) {
                     if ( typevalue = FindToolType( DiskObj->do_ToolTypes, "OWNSCREEN" )) {
                        ownscreen = ( Stricmp( typevalue, "YES" ) == 0 ) ? 1 : 0;
                     }
                     if ( typevalue = FindToolType( DiskObj->do_ToolTypes, "REALOSCI" )) {
                        realosci = ( Stricmp( typevalue, "YES" ) == 0 ) ? TRUE : FALSE;
                     }
                  }
                  FreeDiskObject( DiskObj );
                  DiskObj = NULL;
               }
               if ( localdir != -1L )
               {
                  CurrentDir( localdir );
                  localdir = NULL;
               }

               CloseLibrary( IconsBase );
            }
            if ( argc && wbs )      FreeMem( wbs, sizeof( struct WBStartup ));
         }

         intui_setup( ownscreen );                 // All okay, so carry on...

         CloseLibrary( WorkbenchBase );
      }
      CloseLibrary((struct Library *)UtilityBase );
   }
   return( EXIT_SUCCESS );
}


/*__________________________________________________________________________________________
 |                                                                                          |
 |    Try opening the class library from a number of common places                          |
 |__________________________________________________________________________________________*/

STATIC struct ClassLibrary *openclass( STRPTR name, ULONG version )
{
   struct Library   *retval;
   UBYTE             buffer[256];

   if (( retval = OpenLibrary( name, version )) == NULL )
   {
      sprintf( buffer, "classes/%s", name );
      if (( retval = OpenLibrary( buffer, version )) == NULL )
      {
         sprintf( buffer, "Sys:classes/%s", name );
         retval = OpenLibrary( buffer, version );
      }
   }
   return((struct ClassLibrary *)retval );
}



