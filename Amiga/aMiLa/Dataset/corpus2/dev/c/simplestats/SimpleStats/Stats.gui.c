/* ------------------------------------------------------------------
 $VER: stats.gui.c 1.01 (12.01.1999)

 gadtools support & gui functions

 (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.
 amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------------ */

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>
#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <string.h>
#include <clib/diskfont_protos.h>

#include <pragmas/exec_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/utility_pragmas.h>

#include "Stats.h"

struct Screen         *Scr = NULL;
UBYTE                 *PubScreenName = "Workbench";
APTR                   VisualInfo = NULL;
struct Window         *StatsWnd = NULL;
struct Gadget         *StatsGList = NULL;
struct IntuiMessage    StatsMsg;
struct Gadget         *StatsGadgets[8];
UWORD                  StatsLeft = 3;
UWORD                  StatsTop = 15;
UWORD                  StatsWidth = 416;
UWORD                  StatsHeight = 98;
UBYTE                 *StatsWdt = (UBYTE *)"Stats - © Matthew J Fletcher 1999-2000";
struct TextAttr       *Font, Attr;
UWORD                  FontX, FontY;
UWORD                  OffX, OffY;
struct TextFont       *StatsFont = NULL;

UWORD StatsGTypes[] = {
    TEXT_KIND,
    TEXT_KIND,
    TEXT_KIND,
    TEXT_KIND,
    TEXT_KIND,
    TEXT_KIND,
    BUTTON_KIND,
    TEXT_KIND
};

struct NewGadget StatsNGad[] = {
    10, 14, 184, 11, (UBYTE *)"Chip Memory", NULL, GD_Gadget00, PLACETEXT_ABOVE, NULL, NULL,
    10, 25, 184, 11, NULL, NULL, GD_Gadget10, 0, NULL, NULL,
    206, 14, 184, 11, (UBYTE *)"Fast Memory", NULL, GD_Gadget20, PLACETEXT_ABOVE, NULL, NULL,
    206, 25, 184, 11, NULL, NULL, GD_Gadget30, 0, NULL, NULL,
    6, 53, 184, 11, (UBYTE *)"Total Memory", NULL, GD_Gadget40, PLACETEXT_ABOVE, NULL, NULL,
    6, 64, 184, 11, NULL, NULL, GD_Gadget50, 0, NULL, NULL,
    164, 79, 75, 16, (UBYTE *)"Reboot", NULL, GD_Reboot, PLACETEXT_IN, NULL, (APTR)RebootClicked,
    194, 53, 205, 13, (UBYTE *)"System Time", NULL, GD_Time, PLACETEXT_ABOVE, NULL, NULL
};

ULONG StatsGTags[] = {
    (GTTX_Border), TRUE, (TAG_DONE),
    (GTTX_Border), TRUE, (TAG_DONE),
    (GTTX_Border), TRUE, (TAG_DONE),
    (GTTX_Border), TRUE, (TAG_DONE),
    (GTTX_Border), TRUE, (TAG_DONE),
    (GTTX_Border), TRUE, (TAG_DONE),
    (TAG_DONE),
    (GTTX_Border), TRUE, (TAG_DONE)
};

static UWORD ComputeX( UWORD value )
{
    return(( UWORD )((( FontX * value ) + 3 ) / 7 ));
}

static UWORD ComputeY( UWORD value )
{
    return(( UWORD )((( FontY * value ) + 3 ) / 7 ));
}

static void ComputeFont( UWORD width, UWORD height )
{
    Forbid();
    Font = &Attr;
    Font->ta_Name = (STRPTR)GfxBase->DefaultFont->tf_Message.mn_Node.ln_Name;
    Font->ta_YSize = FontY = GfxBase->DefaultFont->tf_YSize;
    FontX = GfxBase->DefaultFont->tf_XSize;
    Permit();

    OffX = Scr->WBorLeft;
    OffY = Scr->RastPort.TxHeight + Scr->WBorTop + 1;

    if ( width && height ) {
        if (( ComputeX( width ) + OffX + Scr->WBorRight ) > Scr->Width )
            goto UseTopaz;
        if (( ComputeY( height ) + OffY + Scr->WBorBottom ) > Scr->Height )
            goto UseTopaz;
    }
    return;

UseTopaz:
    Font->ta_Name = (STRPTR)"topaz.font";
    FontX = FontY = Font->ta_YSize = 8;
}

int SetupScreen( void )
{
    if ( ! ( Scr = LockPubScreen( PubScreenName )))
        return( 1L );

    ComputeFont( 0, 0 );

    if ( ! ( VisualInfo = GetVisualInfo( Scr, TAG_DONE )))
        return( 2L );

    return( 0L );
}

void CloseDownScreen( void )
{
    if ( VisualInfo ) {
        FreeVisualInfo( VisualInfo );
        VisualInfo = NULL;
    }

    if ( Scr        ) {
        UnlockPubScreen( NULL, Scr );
        Scr = NULL;
    }
}

void StatsRender( void )
{
    ComputeFont( StatsWidth, StatsHeight );

    DrawBevelBox( StatsWnd->RPort, OffX + ComputeX( 2 ),
                    OffY + ComputeY( 1 ),
                    ComputeX( 397 ),
                    ComputeY( 39 ),
                    GT_VisualInfo, VisualInfo, GTBB_Recessed, TRUE, TAG_DONE );
}

int HandleStatsIDCMP( void )
{
    struct IntuiMessage *m;
    int         (*func)();
    BOOL            running = TRUE;

    /* wait if no inputs (i.e de-selected) */
    Wait( 1 << StatsWnd->UserPort->mp_SigBit );

    while( m = GT_GetIMsg( StatsWnd->UserPort )) {

        CopyMem(( char * )m, ( char * )&StatsMsg, (long)sizeof( struct IntuiMessage ));

        GT_ReplyIMsg( m );

        switch ( StatsMsg.Class ) {

            case    IDCMP_REFRESHWINDOW:
                GT_BeginRefresh( StatsWnd );
                StatsRender();
                GT_EndRefresh( StatsWnd, TRUE );
                break;

            case    IDCMP_CLOSEWINDOW:
                running = StatsCloseWindow();
                break;

            case    IDCMP_ACTIVEWINDOW:
                running = StatsActiveWindow();
                break;

            case    IDCMP_INACTIVEWINDOW:
                running = StatsInActiveWindow();
                break;

            case    IDCMP_IDCMPUPDATE:
                running = StatsIDCMPUpdate();
                break;

            case    IDCMP_GADGETUP:
                func = ( void * )(( struct Gadget * )StatsMsg.IAddress )->UserData;
                running = func();
                break;
        }
    }
    return( running );
}

int OpenStatsWindow( void )
{
    struct NewGadget    ng;
    struct Gadget   *g;
    UWORD       lc, tc;
    UWORD       wleft = StatsLeft, wtop = StatsTop, ww, wh;

    ComputeFont( StatsWidth, StatsHeight );

    ww = ComputeX( StatsWidth );
    wh = ComputeY( StatsHeight );

    if (( wleft + ww + OffX + Scr->WBorRight ) > Scr->Width ) wleft = Scr->Width - ww;
    if (( wtop + wh + OffY + Scr->WBorBottom ) > Scr->Height ) wtop = Scr->Height - wh;

    if ( ! ( StatsFont = OpenDiskFont( Font )))
        return( 5L );

    if ( ! ( g = CreateContext( &StatsGList )))
        return( 1L );

    for( lc = 0, tc = 0; lc < Stats_CNT; lc++ ) {

        CopyMem((char * )&StatsNGad[ lc ], (char * )&ng, (long)sizeof( struct NewGadget ));

        ng.ng_VisualInfo = VisualInfo;
        ng.ng_TextAttr   = Font;
        ng.ng_LeftEdge   = OffX + ComputeX( ng.ng_LeftEdge );
        ng.ng_TopEdge    = OffY + ComputeY( ng.ng_TopEdge );
        ng.ng_Width      = ComputeX( ng.ng_Width );
        ng.ng_Height     = ComputeY( ng.ng_Height);

        StatsGadgets[ lc ] = g = CreateGadgetA((ULONG)StatsGTypes[ lc ], g, &ng, ( struct TagItem * )&StatsGTags[ tc ] );

        while( StatsGTags[ tc ] ) tc += 2;
        tc++;

        if ( NOT g )
            return( 2L );
    }

    if ( ! ( StatsWnd = OpenWindowTags( NULL,
                WA_Left,    wleft,
                WA_Top,     wtop,
                WA_Width,   ww + OffX + Scr->WBorRight,
                WA_Height,  wh + OffY + Scr->WBorBottom,
                WA_IDCMP,   TEXTIDCMP|BUTTONIDCMP|IDCMP_INTUITICKS|IDCMP_CLOSEWINDOW|IDCMP_ACTIVEWINDOW|IDCMP_INACTIVEWINDOW|IDCMP_IDCMPUPDATE|IDCMP_REFRESHWINDOW,
                WA_Flags,   WFLG_SIZEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
                WA_Gadgets, StatsGList,
                WA_Title,   StatsWdt,
                WA_ScreenTitle, "Stats - © Matthew J Fletcher 1999-2000",
                WA_MinWidth,    67,
                WA_MinHeight,   21,
                WA_MaxWidth,    640,
                WA_MaxHeight,   256,
                TAG_DONE )))
    return( 4L );

    GT_RefreshWindow( StatsWnd, NULL );

    StatsRender();

    return( 0L );
}

void CloseStatsWindow( void )
{
    if ( StatsWnd        ) {
        CloseWindow( StatsWnd );
        StatsWnd = NULL;
    }

    if ( StatsGList      ) {
        FreeGadgets( StatsGList );
        StatsGList = NULL;
    }

    if ( StatsFont ) {
        CloseFont( StatsFont );
        StatsFont = NULL;
    }
}

