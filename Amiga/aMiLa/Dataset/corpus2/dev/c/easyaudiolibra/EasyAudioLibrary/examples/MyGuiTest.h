/* ------------------------------------------------------------------ */
/* $VER: MyGuiTest.h 39.01 (12.12.1999)                               */
/*                                                                    */
/* Global headers and external defines                                */
/* Advanced demo program for easyaudio.library                        */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#define GetString( g )      ((( struct StringInfo * )g->SpecialInfo )->Buffer  )
#define GetNumber( g )      ((( struct StringInfo * )g->SpecialInfo )->LongInt )

#define GD_list1                               0
#define GD_button1                             1
#define GD_string1                             2
#define GD_check1                              3
#define GD_check2                              4
#define GD_check3                              5
#define GD_button2                             6
#define GD_button3                             7

#define GDX_list1                              0
#define GDX_button1                            1
#define GDX_string1                            2
#define GDX_check1                             3
#define GDX_check2                             4
#define GDX_check3                             5
#define GDX_button2                            6
#define GDX_button3                            7

#define EasyAudioTest_CNT 8

extern struct IntuitionBase *IntuitionBase;
extern struct Library       *GadToolsBase;

extern struct Screen        *Scr;
extern UBYTE                 *PubScreenName;
extern APTR                  VisualInfo;
extern struct Window        *EasyAudioTestWnd;
extern struct Gadget        *EasyAudioTestGList;
extern struct Menu          *EasyAudioTestMenus;
extern struct IntuiMessage   EasyAudioTestMsg;
extern struct Gadget        *EasyAudioTestGadgets[8];
extern UWORD                 EasyAudioTestLeft;
extern UWORD                 EasyAudioTestTop;
extern UWORD                 EasyAudioTestWidth;
extern UWORD                 EasyAudioTestHeight;
extern UBYTE                *EasyAudioTestWdt;
extern struct TextAttr      *Font, Attr;
extern UWORD                 FontX, FontY;
extern UWORD                 OffX, OffY;
extern struct TextFont      *EasyAudioTestFont;
extern struct GfxBase       *GfxBase;
extern struct MinList        list10List;
extern struct NewMenu        EasyAudioTestNewMenu[];
extern UWORD                 EasyAudioTestGTypes[];
extern struct NewGadget      EasyAudioTestNGad[];
extern ULONG                 EasyAudioTestGTags[];

extern int list1Clicked( void );
extern int button1Clicked( void );
extern int string1Clicked( void );
extern int check1Clicked( void );
extern int check2Clicked( void );
extern int check3Clicked( void );
extern int button2Clicked( void );
extern int button3Clicked( void );
extern int EasyAudioTestItem0( void );
extern int EasyAudioTestItem1( void );

extern int SetupScreen( void );
extern void CloseDownScreen( void );
extern void EasyAudioTestRender( void );
extern int HandleEasyAudioTestIDCMP( void );
extern int EasyAudioTestCloseWindow();
extern int EasyAudioTestIDCMPUpdate();
extern int EasyAudioTestIntuiTicks();
extern int OpenEasyAudioTestWindow( void );
extern void CloseEasyAudioTestWindow( void );
extern STRPTR OpenASL( void );

