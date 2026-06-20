/* -----------------------------------------------------------
  $VER: calc.h 1.01 (28.01.1999)

  headers & defines for calculator project

  (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
  amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
  ------------------------------------------------------------ */

#define GetString( g ) ((( struct StringInfo * )g->SpecialInfo )->Buffer  )
#define GetNumber( g ) ((( struct StringInfo * )g->SpecialInfo )->LongInt )

#define GD_Gadget00                            0
#define GD_Gadget10                            1
#define GD_Gadget20                            2
#define GD_Gadget30                            3
#define GD_Gadget40                            4
#define GD_Gadget50                            5
#define GD_Gadget60                            6
#define GD_Gadget70                            7
#define GD_Gadget80                            8
#define GD_Gadget90                            9
#define GD_Gadget100                           10
#define GD_Gadget110                           11
#define GD_Gadget120                           12
#define GD_Gadget130                           13
#define GD_Gadget140                           14
#define GD_Gadget150                           15
#define GD_Gadget160                           16
#define GD_Gadget170                           17
#define GD_Gadget180                           18
#define GD_Gadget190                           19
#define GD_Gadget200                           20
#define GD_Gadget210                           21
#define GD_Gadget220                           22
#define GD_Gadget230                           23

#define GDX_Gadget00                           0
#define GDX_Gadget10                           1
#define GDX_Gadget20                           2
#define GDX_Gadget30                           3
#define GDX_Gadget40                           4
#define GDX_Gadget50                           5
#define GDX_Gadget60                           6
#define GDX_Gadget70                           7
#define GDX_Gadget80                           8
#define GDX_Gadget90                           9
#define GDX_Gadget100                          10
#define GDX_Gadget110                          11
#define GDX_Gadget120                          12
#define GDX_Gadget130                          13
#define GDX_Gadget140                          14
#define GDX_Gadget150                          15
#define GDX_Gadget160                          16
#define GDX_Gadget170                          17
#define GDX_Gadget180                          18
#define GDX_Gadget190                          19
#define GDX_Gadget200                          20
#define GDX_Gadget210                          21
#define GDX_Gadget220                          22
#define GDX_Gadget230                          23

#define Calc_CNT 24

/* for easy console i/o formating */
#define ITALICS   "\033[3m"
#define BOLD      "\033[1m"
#define UNDERLINE "\033[4m"
#define NORMAL    "\033[0m"

extern struct IntuitionBase *IntuitionBase;
extern struct Library       *GadToolsBase;

extern struct Screen        *Scr;
extern UBYTE                 *PubScreenName;
extern APTR                  VisualInfo;
extern struct Window        *CalcWnd;
extern struct Window        *GraphWnd;
extern struct Gadget        *CalcGList;
extern struct Menu          *CalcMenus;
extern struct IntuiMessage   CalcMsg;
extern struct IntuiMessage   GraphMsg;
extern struct Gadget        *CalcGadgets[24];
extern UWORD                 CalcLeft;
extern UWORD                 CalcTop;
extern UWORD                 CalcWidth;
extern UWORD                 CalcHeight;
extern UWORD                 GraphLeft;
extern UWORD                 GraphTop;
extern UWORD                 GraphWidth;
extern UWORD                 GraphHeight;
extern UBYTE                *CalcWdt;
extern UBYTE                *GraphWdt;
extern struct TextAttr      *Font, Attr;
extern UWORD                 FontX, FontY;
extern UWORD                 OffX, OffY;
extern struct TextFont      *CalcFont;
extern struct TextFont      *GraphFont;
extern struct GfxBase       *GfxBase;
extern struct NewMenu        CalcNewMenu[];
extern UWORD                 CalcGTypes[];
extern struct NewGadget      CalcNGad[];
extern ULONG                 CalcGTags[];

/* display buffer */
extern char buffer[100]; /* 100 chars should be enough */
extern char memory1[100];
/* tape history */
extern int UseTape;
/* maths mode */
extern int mode;

extern int Gadget00Clicked( void );
extern int Gadget10Clicked( void );
extern int Gadget20Clicked( void );
extern int Gadget30Clicked( void );
extern int Gadget40Clicked( void );
extern int Gadget50Clicked( void );
extern int Gadget60Clicked( void );
extern int Gadget70Clicked( void );
extern int Gadget80Clicked( void );
extern int Gadget90Clicked( void );
extern int Gadget100Clicked( void );
extern int Gadget110Clicked( void );
extern int Gadget120Clicked( void );
extern int Gadget130Clicked( void );
extern int Gadget140Clicked( void );
extern int Gadget150Clicked( void );
extern int Gadget160Clicked( void );
extern int Gadget170Clicked( void );
extern int Gadget180Clicked( void );
extern int Gadget190Clicked( void );
extern int Gadget200Clicked( void );
extern int Gadget210Clicked( void );
extern int Gadget220Clicked( void );
extern int Gadget230Clicked( void );
extern int CalcItem0( void );
extern int CalcItem1( void );
extern int CalcItem2( void );
extern int CalcItem3( void );
extern int CalcItem4( void );
extern int CalcItem5( void );
extern int CalcItem6( void );
extern int CalcItem7( void );

extern int SetupScreen( void );
extern void CloseDownScreen( void );
extern void CalcRender( void );
extern int HandleCalcIDCMP( void );
extern int CalcCloseWindow( void );
extern int OpenCalcWindow( void );
extern void CloseCalcWindow( void );
extern int HandleGraphIDCMP( void );
extern int GraphCloseWindow( void );
extern int OpenGraphWindow( void );
extern void CloseGraphWindow( void );
extern int CalcVanillaKey( void );
extern int CalcRawKey( void );

extern void Shutdown( void );
extern int ReadClip( char * );
extern int WriteClip( char * );
extern double do_math( char );
extern int draw_display( char * , int );
extern void clear_display ( void );
extern void clear_buffers ( void );
extern void draw_op( char );
extern int atob( char *);

/* ----------------- */
/* Clipboard Support */
/* ----------------- */

struct cbbuf {
ULONG size;     /* size of memory allocation            */
ULONG count;    /* number of characters after stripping */
UBYTE *mem;     /* pointer to memory containing data    */
};

#define MAKE_ID(a,b,c,d) ((a<<24L) | (b<<16L) | (c<<8L) | d)
#define ID_FORM MAKE_ID('F','O','R','M')
#define ID_FTXT MAKE_ID('F','T','X','T')
#define ID_CHRS MAKE_ID('C','H','R','S')

/* prototypes */

struct IOClipReq        *CBOpen         ( ULONG );
void                    CBClose         (struct IOClipReq *);
int                     CBWriteFTXT     (struct IOClipReq *, char *);
int                     CBQueryFTXT     (struct IOClipReq *);
struct cbbuf            *CBReadCHRS     (struct IOClipReq *);
void                    CBReadDone      (struct IOClipReq *);
void                    CBFreeBuf       (struct cbbuf *);

/* routines which are meant to be used internally  */
int                     WriteLong       (struct IOClipReq *, long *);
int                     ReadLong        (struct IOClipReq *, ULONG *);
struct cbbuf            *FillCBData     (struct IOClipReq *, ULONG);

extern struct IOClipReq *CBOpen         ( ULONG );
extern void             CBClose         (struct IOClipReq *);
extern int              CBWriteFTXT     (struct IOClipReq *, char *);
extern int              CBQueryFTXT     (struct IOClipReq *);
extern struct cbbuf     *CBReadCHRS     (struct IOClipReq *);
extern void             CBReadDone      (struct IOClipReq *);
extern void             CBFreeBuf       (struct cbbuf *);

