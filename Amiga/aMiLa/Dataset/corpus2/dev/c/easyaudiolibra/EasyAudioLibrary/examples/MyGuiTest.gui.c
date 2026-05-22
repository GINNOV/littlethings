/* ------------------------------------------------------------------ */
/* $VER: MyGuiTest.gui.c 39.01 (12.12.1999)                           */
/*                                                                    */
/* GUI handeling / start-up / shutdown procedures                     */
/* Advanced demo program for easyaudio.library                        */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */


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

#include "MyGuiTest.h"

struct Screen         *Scr = NULL;
UBYTE                 *PubScreenName = "Workbench";
APTR                   VisualInfo = NULL;
struct Window         *EasyAudioTestWnd = NULL;
struct Gadget         *EasyAudioTestGList = NULL;
struct Menu           *EasyAudioTestMenus = NULL;
struct IntuiMessage    EasyAudioTestMsg;
struct Gadget         *EasyAudioTestGadgets[8];
UWORD                  EasyAudioTestLeft = 0;
UWORD                  EasyAudioTestTop = 63;
UWORD                  EasyAudioTestWidth = 392;
UWORD                  EasyAudioTestHeight = 73;
UBYTE                 *EasyAudioTestWdt = (UBYTE *)"EasyAudio Test - © Matthew J Fletcher 1999-2000";
struct TextAttr       *Font, Attr;
UWORD                  FontX, FontY;
UWORD                  OffX, OffY;
struct TextFont       *EasyAudioTestFont = NULL;

extern struct MinList list10List;

struct Node list10Nodes[] = {
    &list10Nodes[1], ( struct Node * )&list10List.mlh_Head, 0, 0, "1",
    &list10Nodes[2], &list10Nodes[0], 0, 0, "2",
    &list10Nodes[3], &list10Nodes[1], 0, 0, "3",
    ( struct Node * )&list10List.mlh_Tail, &list10Nodes[2], 0, 0, "4" };

struct MinList list10List = {
    ( struct MinNode * )&list10Nodes[0], ( struct MinNode * )NULL, ( struct MinNode * )&list10Nodes[3] };

struct NewMenu EasyAudioTestNewMenu[] = {
    NM_TITLE, (STRPTR)"Program", NULL, 0, NULL, NULL,
    NM_ITEM, (STRPTR)"About", (STRPTR)"a", 0, 0L, (APTR)EasyAudioTestItem0,
    NM_ITEM, (STRPTR)NM_BARLABEL, NULL, 0, 0L, NULL,
    NM_ITEM, (STRPTR)"Quit", (STRPTR)"q", 0, 0L, (APTR)EasyAudioTestItem1,
    NM_END, NULL, NULL, 0, 0L, NULL };

UWORD EasyAudioTestGTypes[] = {
    LISTVIEW_KIND,
    BUTTON_KIND,
    STRING_KIND,
    CHECKBOX_KIND,
    CHECKBOX_KIND,
    CHECKBOX_KIND,
    BUTTON_KIND,
    BUTTON_KIND
};

struct NewGadget EasyAudioTestNGad[] = {
    4, 2, 221, 56, NULL, NULL, GD_list1, 0, NULL, (APTR)list1Clicked,
    4, 58, 60, 14, (UBYTE *)"Speak !", NULL, GD_button1, PLACETEXT_IN, NULL, (APTR)button1Clicked,
    67, 58, 322, 14, NULL, NULL, GD_string1, 0, NULL, (APTR)string1Clicked,
    233, 4, 26, 11, (UBYTE *)"Stereo", NULL, GD_check1, PLACETEXT_RIGHT, NULL, (APTR)check1Clicked,
    233, 17, 26, 11, (UBYTE *)"AHI Calibrated", NULL, GD_check2, PLACETEXT_RIGHT, NULL, (APTR)check2Clicked,
    233, 30, 26, 11, (UBYTE *)"14 Bit Calibrated", NULL, GD_check3, PLACETEXT_RIGHT, NULL, (APTR)check3Clicked,
    230, 45, 79, 10, (UBYTE *)"Get File", NULL, GD_button2, PLACETEXT_IN, NULL, (APTR)button2Clicked,
    313, 45, 75, 10, (UBYTE *)"Play !", NULL, GD_button3, PLACETEXT_IN, NULL, (APTR)button3Clicked
};

ULONG EasyAudioTestGTags[] = {
    (GTLV_Labels), (ULONG)&list10List, (GTLV_ShowSelected), NULL, (GT_Underscore), '_', (TAG_DONE),
    (TAG_DONE),
    (GTST_MaxChars), 256, (TAG_DONE),
    (TAG_DONE),
    (GA_Disabled), TRUE, (TAG_DONE),
    (GA_Disabled), TRUE, (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE)
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

void EasyAudioTestRender( void )
{
    ComputeFont( EasyAudioTestWidth, EasyAudioTestHeight );

    DrawBevelBox( EasyAudioTestWnd->RPort, OffX + ComputeX( 228 ),
                    OffY + ComputeY( 2 ),
                    ComputeX( 160 ),
                    ComputeY( 42 ),
                    GT_VisualInfo, VisualInfo, GTBB_Recessed, TRUE, TAG_DONE );
}

int HandleEasyAudioTestIDCMP( void )
{
    struct IntuiMessage *m;
    struct MenuItem     *n;
    int    (*func)();
    int    running = 0;

    while( m = GT_GetIMsg( EasyAudioTestWnd->UserPort )) {

        CopyMem(( char * )m, ( char * )&EasyAudioTestMsg, (long)sizeof( struct IntuiMessage ));

        GT_ReplyIMsg( m );

        switch ( EasyAudioTestMsg.Class ) {

            case    IDCMP_REFRESHWINDOW:
                GT_BeginRefresh( EasyAudioTestWnd );
                EasyAudioTestRender();
                GT_EndRefresh( EasyAudioTestWnd, TRUE );
                break;

            case    IDCMP_CLOSEWINDOW:
                running = EasyAudioTestCloseWindow();
                break;

            case    IDCMP_IDCMPUPDATE:
                running = EasyAudioTestIDCMPUpdate();
                break;

            case    IDCMP_INTUITICKS:
                running = EasyAudioTestIntuiTicks();
                break;

            case    IDCMP_GADGETUP:
            case    IDCMP_GADGETDOWN:
                func = ( void * )(( struct Gadget * )EasyAudioTestMsg.IAddress )->UserData;
                running = func();
                break;

            case    IDCMP_MENUPICK:
                while( EasyAudioTestMsg.Code != MENUNULL ) {
                    n = ItemAddress( EasyAudioTestMenus, EasyAudioTestMsg.Code );
                    func = (void *)(GTMENUITEM_USERDATA( n ));
                    running = func();
                    EasyAudioTestMsg.Code = n->NextSelect;
                }
                break;
        }
    }
    return( running );
}

int OpenEasyAudioTestWindow( void )
{
    struct NewGadget    ng;
    struct Gadget   *g;
    UWORD       lc, tc;
    UWORD       wleft = EasyAudioTestLeft, wtop = EasyAudioTestTop, ww, wh;

    ComputeFont( EasyAudioTestWidth, EasyAudioTestHeight );

    ww = ComputeX( EasyAudioTestWidth );
    wh = ComputeY( EasyAudioTestHeight );

    if (( wleft + ww + OffX + Scr->WBorRight ) > Scr->Width ) wleft = Scr->Width - ww;
    if (( wtop + wh + OffY + Scr->WBorBottom ) > Scr->Height ) wtop = Scr->Height - wh;

    if ( ! ( EasyAudioTestFont = OpenDiskFont( Font )))
        return( 5L );

    if ( ! ( g = CreateContext( &EasyAudioTestGList )))
        return( 1L );

    for( lc = 0, tc = 0; lc < EasyAudioTest_CNT; lc++ ) {

        CopyMem((char * )&EasyAudioTestNGad[ lc ], (char * )&ng, (long)sizeof( struct NewGadget ));

        ng.ng_VisualInfo = VisualInfo;
        ng.ng_TextAttr   = Font;
        ng.ng_LeftEdge   = OffX + ComputeX( ng.ng_LeftEdge );
        ng.ng_TopEdge    = OffY + ComputeY( ng.ng_TopEdge );
        ng.ng_Width      = ComputeX( ng.ng_Width );
        ng.ng_Height     = ComputeY( ng.ng_Height);

        EasyAudioTestGadgets[ lc ] = g = CreateGadgetA((ULONG)EasyAudioTestGTypes[ lc ], g, &ng, ( struct TagItem * )&EasyAudioTestGTags[ tc ] );

        while( EasyAudioTestGTags[ tc ] ) tc += 2;
        tc++;

        if ( NOT g )
            return( 2L );
    }

    if ( ! ( EasyAudioTestMenus = CreateMenus( EasyAudioTestNewMenu, GTMN_FrontPen, 0L, TAG_DONE )))
        return( 3L );

    LayoutMenus( EasyAudioTestMenus, VisualInfo, TAG_DONE );

    if ( ! ( EasyAudioTestWnd = OpenWindowTags( NULL,
                WA_Left,    wleft,
                WA_Top,     wtop,
                WA_Width,   ww + OffX + Scr->WBorRight,
                WA_Height,  wh + OffY + Scr->WBorBottom,
                WA_IDCMP,   LISTVIEWIDCMP|BUTTONIDCMP|STRINGIDCMP|CHECKBOXIDCMP|IDCMP_MENUPICK|IDCMP_CLOSEWINDOW|IDCMP_IDCMPUPDATE|IDCMP_REFRESHWINDOW,
                WA_Flags,   WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_SIZEBRIGHT|WFLG_SMART_REFRESH|WFLG_ACTIVATE,
                WA_Gadgets, EasyAudioTestGList,
                WA_Title,   EasyAudioTestWdt,
                WA_ScreenTitle, "EasyAudio Test - © Matthew J Fletcher 1999-2000",
                TAG_DONE )))
    return( 4L );

    SetMenuStrip( EasyAudioTestWnd, EasyAudioTestMenus );
    GT_RefreshWindow( EasyAudioTestWnd, NULL );

    EasyAudioTestRender();

    return( 0L );
}

void CloseEasyAudioTestWindow( void )
{
    if ( EasyAudioTestMenus      ) {
        ClearMenuStrip( EasyAudioTestWnd );
        FreeMenus( EasyAudioTestMenus );
        EasyAudioTestMenus = NULL;  }

    if ( EasyAudioTestWnd        ) {
        CloseWindow( EasyAudioTestWnd );
        EasyAudioTestWnd = NULL;
    }

    if ( EasyAudioTestGList      ) {
        FreeGadgets( EasyAudioTestGList );
        EasyAudioTestGList = NULL;
    }

    if ( EasyAudioTestFont ) {
        CloseFont( EasyAudioTestFont );
        EasyAudioTestFont = NULL;
    }
}

