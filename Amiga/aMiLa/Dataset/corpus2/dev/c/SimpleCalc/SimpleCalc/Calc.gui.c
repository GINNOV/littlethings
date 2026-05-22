/* ------------------------------------------------------------------
 $VER: calc.gui.c 1.01 (28.01.1999)

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

#include "Calc.h"

struct Screen         *Scr = NULL;
UBYTE                 *PubScreenName = NULL;
APTR                   VisualInfo = NULL;
struct Window         *CalcWnd = NULL;
struct Window         *GraphWnd = NULL;
struct Gadget         *CalcGList = NULL;
struct Menu           *CalcMenus = NULL;
struct IntuiMessage    CalcMsg;
struct IntuiMessage    GraphMsg;
struct Gadget         *CalcGadgets[24];
UWORD                  CalcLeft = 0;
UWORD                  CalcTop = 10;
UWORD                  CalcWidth = 188;
UWORD                  CalcHeight = 95;
UWORD                  GraphLeft = 185;
UWORD                  GraphTop = 10;
UWORD                  GraphWidth = 274;
UWORD                  GraphHeight = 105;
UBYTE                 *CalcWdt = (UBYTE *)"Calculator";
UBYTE                 *GraphWdt = (UBYTE *)"Graph Window";
struct TextAttr       *Font, Attr;
UWORD                  FontX, FontY;
UWORD                  OffX, OffY;
struct TextFont       *CalcFont = NULL;
struct TextFont       *GraphFont = NULL;

UBYTE *Gadget2300Labels[] = {
    (UBYTE *)"DEC",
    (UBYTE *)"FLT",
    (UBYTE *)"HEX",
    (UBYTE *)"OCT",
    (UBYTE *)"BIN",
    (UBYTE *)"EXPO",
    NULL };

struct NewMenu CalcNewMenu[] = {
    NM_TITLE, (STRPTR)"Project", NULL, 0, NULL, NULL,
    NM_ITEM, (STRPTR)"About", (STRPTR)"?", 0, 0L, (APTR)CalcItem0,
    NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
    NM_ITEM, (STRPTR)"Quit", (STRPTR)"Q", 0, 0L, (APTR)CalcItem1,
    NM_TITLE, (STRPTR)"Edit", NULL, 0, NULL, NULL,
    NM_ITEM, (STRPTR)"Cut", (STRPTR)"X", 0, 0L, (APTR)CalcItem2,
    NM_ITEM, (STRPTR)"Copy", (STRPTR)"C", 0, 0L, (APTR)CalcItem3,
    NM_ITEM, (STRPTR)"Paste", (STRPTR)"V", 0, 0L, (APTR)CalcItem4,
    NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
    NM_ITEM, (STRPTR)"Erase", (STRPTR)"D", 0, 0L, (APTR)CalcItem5,
    NM_TITLE, (STRPTR)"Windows", NULL, 0, NULL, NULL,
    NM_ITEM, (STRPTR)"Show Tape", (STRPTR)"T", CHECKIT|CHECKED, 0L, (APTR)CalcItem6,
    NM_ITEM, (STRPTR)"Show Graphic", (STRPTR)"G", CHECKIT, 0L, (APTR)CalcItem7,
    NM_END, NULL, NULL, 0, 0L, NULL };

UWORD CalcGTypes[] = {
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    CYCLE_KIND
};

struct NewGadget CalcNGad[] = {
    4, 39, 33, 12, (UBYTE *)"1", NULL, GD_Gadget00, PLACETEXT_IN, NULL, (APTR)Gadget00Clicked,
    41, 39, 33, 12, (UBYTE *)"2", NULL, GD_Gadget10, PLACETEXT_IN, NULL, (APTR)Gadget10Clicked,
    78, 39, 33, 12, (UBYTE *)"3", NULL, GD_Gadget20, PLACETEXT_IN, NULL, (APTR)Gadget20Clicked,
    4, 53, 33, 12, (UBYTE *)"4", NULL, GD_Gadget30, PLACETEXT_IN, NULL, (APTR)Gadget30Clicked,
    41, 53, 33, 12, (UBYTE *)"5", NULL, GD_Gadget40, PLACETEXT_IN, NULL, (APTR)Gadget40Clicked,
    78, 53, 33, 12, (UBYTE *)"6", NULL, GD_Gadget50, PLACETEXT_IN, NULL, (APTR)Gadget50Clicked,
    4, 67, 33, 12, (UBYTE *)"7", NULL, GD_Gadget60, PLACETEXT_IN, NULL, (APTR)Gadget60Clicked,
    41, 67, 33, 12, (UBYTE *)"8", NULL, GD_Gadget70, PLACETEXT_IN, NULL, (APTR)Gadget70Clicked,
    78, 67, 33, 12, (UBYTE *)"9", NULL, GD_Gadget80, PLACETEXT_IN, NULL, (APTR)Gadget80Clicked,
    4, 81, 33, 12, (UBYTE *)"0", NULL, GD_Gadget90, PLACETEXT_IN, NULL, (APTR)Gadget90Clicked,
    4, 25, 33, 12, (UBYTE *)"MR", NULL, GD_Gadget100, PLACETEXT_IN, NULL, (APTR)Gadget100Clicked,
    41, 25, 33, 12, (UBYTE *)"Min", NULL, GD_Gadget110, PLACETEXT_IN, NULL, (APTR)Gadget110Clicked,
    78, 25, 33, 12, (UBYTE *)"CA", NULL, GD_Gadget120, PLACETEXT_IN, NULL, (APTR)Gadget120Clicked,
    41, 81, 33, 12, (UBYTE *)".", NULL, GD_Gadget130, PLACETEXT_IN, NULL, (APTR)Gadget130Clicked,
    78, 81, 33, 12, (UBYTE *)"<", NULL, GD_Gadget140, PLACETEXT_IN, NULL, (APTR)Gadget140Clicked,
    115, 53, 33, 12, (UBYTE *)"*", NULL, GD_Gadget150, PLACETEXT_IN, NULL, (APTR)Gadget150Clicked,
    152, 53, 33, 12, (UBYTE *)"/", NULL, GD_Gadget160, PLACETEXT_IN, NULL, (APTR)Gadget160Clicked,
    115, 67, 33, 12, (UBYTE *)"+", NULL, GD_Gadget170, PLACETEXT_IN, NULL, (APTR)Gadget170Clicked,
    152, 67, 33, 12, (UBYTE *)"-", NULL, GD_Gadget180, PLACETEXT_IN, NULL, (APTR)Gadget180Clicked,
    115, 81, 33, 12, (UBYTE *)"-/+", NULL, GD_Gadget190, PLACETEXT_IN, NULL, (APTR)Gadget190Clicked,
    152, 81, 33, 12, (UBYTE *)"=", NULL, GD_Gadget200, PLACETEXT_IN, NULL, (APTR)Gadget200Clicked,
    115, 39, 33, 12, (UBYTE *)"(", NULL, GD_Gadget210, PLACETEXT_IN, NULL, (APTR)Gadget210Clicked,
    152, 39, 33, 12, (UBYTE *)")", NULL, GD_Gadget220, PLACETEXT_IN, NULL, (APTR)Gadget220Clicked,
    115, 25, 70, 12, NULL, NULL, GD_Gadget230, 0, NULL, (APTR)Gadget230Clicked
};

ULONG CalcGTags[] = {
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (GTCY_Labels), (ULONG)&Gadget2300Labels[ 0 ], (GTCY_Active), 1, (TAG_DONE)
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

void CalcRender( void )
{
    ComputeFont( CalcWidth, CalcHeight );

    DrawBevelBox( CalcWnd->RPort, OffX + ComputeX( 3 ),
                    OffY + ComputeY( 1 ),
                    ComputeX( 182 ),
                    ComputeY( 22 ),
                    GT_VisualInfo, VisualInfo, GTBB_Recessed, TRUE, TAG_DONE );
}

int HandleCalcIDCMP( void )
{
    struct IntuiMessage *m;
    struct MenuItem     *n;
    int         (*func)();
    BOOL            running = TRUE;

    /* wait if no inputs (i.e de-selected) */
    Wait( 1 << CalcWnd->UserPort->mp_SigBit );

    while( m = GT_GetIMsg( CalcWnd->UserPort )) {

        CopyMem(( char * )m, ( char * )&CalcMsg, (long)sizeof( struct IntuiMessage ));

        GT_ReplyIMsg( m );

        switch ( CalcMsg.Class ) {

            case    IDCMP_REFRESHWINDOW:
                GT_BeginRefresh( CalcWnd );
                CalcRender();
                GT_EndRefresh( CalcWnd, TRUE );
                break;

            case    IDCMP_CLOSEWINDOW:
                running = CalcCloseWindow();
                break;

            case    IDCMP_VANILLAKEY:
                running = CalcVanillaKey();
                break;

            case    IDCMP_RAWKEY:
                running = CalcRawKey();
                break;

            case    IDCMP_GADGETUP:
                func = ( void * )(( struct Gadget * )CalcMsg.IAddress )->UserData;
                running = func();
                break;

            case    IDCMP_MENUPICK:
                while( CalcMsg.Code != MENUNULL ) {
                    n = ItemAddress( CalcMenus, CalcMsg.Code );
                    func = (void *)(GTMENUITEM_USERDATA( n ));
                    running = func();
                    CalcMsg.Code = n->NextSelect;
                }
                break;
        }
    }
    return( running );
}

int OpenCalcWindow( void )
{
    struct NewGadget    ng;
    struct Gadget   *g;
    UWORD       lc, tc;
    UWORD       wleft = CalcLeft, wtop = CalcTop, ww, wh;

    ComputeFont( CalcWidth, CalcHeight );

    ww = ComputeX( CalcWidth );
    wh = ComputeY( CalcHeight );

    if (( wleft + ww + OffX + Scr->WBorRight ) > Scr->Width ) wleft = Scr->Width - ww;
    if (( wtop + wh + OffY + Scr->WBorBottom ) > Scr->Height ) wtop = Scr->Height - wh;

    if ( ! ( CalcFont = OpenDiskFont( Font )))
        return( 5L );

    if ( ! ( g = CreateContext( &CalcGList )))
        return( 1L );

    for( lc = 0, tc = 0; lc < Calc_CNT; lc++ ) {

        CopyMem((char * )&CalcNGad[ lc ], (char * )&ng, (long)sizeof( struct NewGadget ));

        ng.ng_VisualInfo = VisualInfo;
        ng.ng_TextAttr   = Font;
        ng.ng_LeftEdge   = OffX + ComputeX( ng.ng_LeftEdge );
        ng.ng_TopEdge    = OffY + ComputeY( ng.ng_TopEdge );
        ng.ng_Width      = ComputeX( ng.ng_Width );
        ng.ng_Height     = ComputeY( ng.ng_Height);

        CalcGadgets[ lc ] = g = CreateGadgetA((ULONG)CalcGTypes[ lc ], g, &ng, ( struct TagItem * )&CalcGTags[ tc ] );

        while( CalcGTags[ tc ] ) tc += 2;
        tc++;

        if ( NOT g )
            return( 2L );
    }

    if ( ! ( CalcMenus = CreateMenus( CalcNewMenu, GTMN_FrontPen, 0L, TAG_DONE )))
        return( 3L );

    LayoutMenus( CalcMenus, VisualInfo, TAG_DONE );

    if ( ! ( CalcWnd = OpenWindowTags( NULL,
                WA_Left,    wleft,
                WA_Top,     wtop,
                WA_Width,   ww + OffX + Scr->WBorRight,
                WA_Height,  wh + OffY + Scr->WBorBottom,
                WA_IDCMP,   BUTTONIDCMP|CYCLEIDCMP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_RAWKEY|IDCMP_VANILLAKEY|IDCMP_REFRESHWINDOW,
                WA_Flags,   WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
                WA_Gadgets, CalcGList,
                WA_Title,   CalcWdt,
                WA_ScreenTitle, "Calculator © Matthew J Fletcher 2000",
                WA_PubScreen,   Scr,
                TAG_DONE )))
    return( 4L );

    SetMenuStrip( CalcWnd, CalcMenus );
    GT_RefreshWindow( CalcWnd, NULL );

    CalcRender();

    return( 0L );
}

void CloseCalcWindow( void )
{
    if ( CalcMenus      ) {
        ClearMenuStrip( CalcWnd );
        FreeMenus( CalcMenus );
        CalcMenus = NULL;   }

    if ( CalcWnd        ) {
        CloseWindow( CalcWnd );
        CalcWnd = NULL;
    }

    if ( CalcGList      ) {
        FreeGadgets( CalcGList );
        CalcGList = NULL;
    }

    if ( CalcFont ) {
        CloseFont( CalcFont );
        CalcFont = NULL;
    }
}

int HandleGraphIDCMP( void )
{
    struct IntuiMessage *m;
    int         (*func)();
    BOOL            running = TRUE;

    /* wait if no inputs (i.e de-selected) */
    Wait( 1 << GraphWnd->UserPort->mp_SigBit );

    while( m = GT_GetIMsg( GraphWnd->UserPort )) {

        CopyMem(( char * )m, ( char * )&GraphMsg, (long)sizeof( struct IntuiMessage ));

        GT_ReplyIMsg( m );

        switch ( GraphMsg.Class ) {

            case    IDCMP_REFRESHWINDOW:
                GT_BeginRefresh( GraphWnd );
                GT_EndRefresh( GraphWnd, TRUE );
                break;

            case    IDCMP_CLOSEWINDOW:
                running = GraphCloseWindow();
                break;

                break;
        }
    }
    return( running );
}

int OpenGraphWindow( void )
{
    struct NewGadget    ng;
    struct Gadget   *g;
    UWORD       lc, tc;
    UWORD       wleft = GraphLeft, wtop = GraphTop, ww, wh;

    ComputeFont( GraphWidth, GraphHeight );

    ww = ComputeX( GraphWidth );
    wh = ComputeY( GraphHeight );

    if (( wleft + ww + OffX + Scr->WBorRight ) > Scr->Width ) wleft = Scr->Width - ww;
    if (( wtop + wh + OffY + Scr->WBorBottom ) > Scr->Height ) wtop = Scr->Height - wh;

    if ( ! ( GraphFont = OpenDiskFont( Font )))
        return( 5L );

    if ( ! ( GraphWnd = OpenWindowTags( NULL,
                WA_Left,    wleft,
                WA_Top,     wtop,
                WA_Width,   ww + OffX + Scr->WBorRight,
                WA_Height,  wh + OffY + Scr->WBorBottom,
                WA_IDCMP,   IDCMP_INTUITICKS|IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW,
                WA_Flags,   WFLG_SIZEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
                WA_Title,   GraphWdt,
                WA_ScreenTitle, "Calculator © Matthew J Fletcher 2000",
                WA_PubScreen,   Scr,
                WA_MinWidth,    67,
                WA_MinHeight,   21,
                WA_MaxWidth,    640,
                WA_MaxHeight,   256,
                TAG_DONE )))
    return( 4L );

    GT_RefreshWindow( GraphWnd, NULL );

    return( 0L );
}

void CloseGraphWindow( void )
{
    if ( GraphWnd        ) {
        CloseWindow( GraphWnd );
        GraphWnd = NULL;
    }

    if ( GraphFont ) {
        CloseFont( GraphFont );
        GraphFont = NULL;
    }
}

