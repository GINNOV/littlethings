/* ------------------------------------------------------------------
 $VER: stats.h 1.01 (12.01.1999)

 headers / defines and other stuff

 (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.
 amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------------ */

#define GetString( g )      ((( struct StringInfo * )g->SpecialInfo )->Buffer  )
#define GetNumber( g )      ((( struct StringInfo * )g->SpecialInfo )->LongInt )

#define GD_Gadget00                            0
#define GD_Gadget10                            1
#define GD_Gadget20                            2
#define GD_Gadget30                            3
#define GD_Gadget40                            4
#define GD_Gadget50                            5
#define GD_Reboot                              6
#define GD_Time                                7

#define GDX_Gadget00                           0
#define GDX_Gadget10                           1
#define GDX_Gadget20                           2
#define GDX_Gadget30                           3
#define GDX_Gadget40                           4
#define GDX_Gadget50                           5
#define GDX_Reboot                             6
#define GDX_Time                               7

#define Stats_CNT 8

extern struct IntuitionBase *IntuitionBase;
extern struct Library       *GadToolsBase;

extern struct Screen        *Scr;
extern UBYTE                 *PubScreenName;
extern APTR                  VisualInfo;
extern struct Window        *StatsWnd;
extern struct Gadget        *StatsGList;
extern struct IntuiMessage   StatsMsg;
extern struct Gadget        *StatsGadgets[8];
extern UWORD                 StatsLeft;
extern UWORD                 StatsTop;
extern UWORD                 StatsWidth;
extern UWORD                 StatsHeight;
extern UBYTE                *StatsWdt;
extern struct TextAttr      *Font, Attr;
extern UWORD                 FontX, FontY;
extern UWORD                 OffX, OffY;
extern struct TextFont      *StatsFont;
extern struct GfxBase       *GfxBase;
extern UWORD                 StatsGTypes[];
extern struct NewGadget      StatsNGad[];
extern ULONG                 StatsGTags[];

extern int RebootClicked(void);
extern int SetupScreen(void);
extern void CloseDownScreen(void);
extern void StatsRender(void);
extern int HandleStatsIDCMP(void );
extern int StatsCloseWindow(void);
extern int StatsActiveWindow(void);
extern int StatsInActiveWindow(void);
extern int StatsIDCMPUpdate(void);
extern int OpenStatsWindow(void);
extern void CloseStatsWindow(void);
extern int comp_stats(void);
extern void comp_time(void);
extern void Shutdown(void);
