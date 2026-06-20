/*

 CircleSquared from Sept. '86 Scientific American "Computer Recreations"
 column produces wildly colorful but mathematically precise patterns on
 your Amiga display.  There is also a treatment of this topic in the
 Oct. '86 issue of Computer Language in their "Theory & Practice" column.
 It doesn't take nearly as long as the generation of a Mandelbrot either.

 The program is controlled thru standard intuition menus, gadgets,
 and requesters.  Most of the important operating parameters, i.e. corna,
 cornb, side, and modval, are modifiable thru these gadgets, requesters,
 menues and such.

   corna  - the X coordinate of the upper left hand corner of the window
   cornb  - the Y coordinate of the upper left hand corner of the window
   side   - the length of the side of the square
   modval - the modulus value that determines the color of the pixel at
            the point(i, j)

 The following calculations are made for each point plotted on the display.
 Note that this routine, PlotPoints(), was written using the Motorola
 Fast Floating Point library.

   x = corna + side * i/linesize
   y = cornb + side * j/linesize
   z = x * x + y * y
   c = z MOD modval

 The point at coordinates (i,j) is colored with color "c".  Note that
 the palette of colors is also modifiable thru another requester
 containing sixteen color selection gadgets.  Three proportional
 gadgets allow the modification the Red, Green, and Blue components
 of the selected color.

 The CLOSEWINDOW gadget causes the program to exit.

 Also note that there is a Hi-Res mode of operation.  Instead of invoking
 the program (from the CLI) as "CSquared" include a runtime parameter of
 "-h" such that the new invocation becomes "CSquared -h".  Lo-Res is the
 default mode of operation.

 I freely admit that this program is a hack and was strictly done for
 my own personal entertainment.  I am new to C so if you see any wretched
 code perhaps you will be understanding.  (I'm also new to the Amiga.)
 I am placing this program into the public domain although if you make use
 of major portions of the code please give credit where credit is due.
 (I'd like to see my name up in lights, too.)  Have fun!

 This program compiles cleanly under Lattice C version 3.03.  No other
 external routines are required except for some of those found in Lattice's
 LC.LIB and, of course, AMIGA.LIB.  The standard c.o startup code is also
 used as well.

 Author:      Bill DuPree (with many thanks to Rob Peck)  
 Date:        09/23/86

 Address BIX mail to bdupree.
 Address written correspondence to:

      Bill DuPree
      434 W. Wellington #505
      Chicago, IL. 60657
*/

/* DEFINES ********************************************************** */

/* Gadget ID's - Note ID's 1 - 16 are used by color gadgets in palette */

#define RCONTROL 17
#define GCONTROL 18
#define BCONTROL 19
#define NEWMOD   20
#define NEWSIDE  21
#define NEWCORNA 22
#define NEWCORNB 23
#define RESUME   24

/* Screen and Window parameters */

#define XMIN 2
#define YMIN 10
#define DEPTH  4

#define INTUITION_MESSAGE (1<<intuitionMsgBit)

#define CloseConsole(x) CloseDevice(x)

/* INCLUDES ********************************************************** */

#include "lattice/math.h"
#include "exec/types.h"
#include "exec/io.h"
#include "exec/memory.h"

#include "graphics/gfx.h"
#include "hardware/dmabits.h"
#include "hardware/custom.h"
#include "hardware/blit.h"
#include "graphics/gfxmacros.h"
#include "graphics/copper.h"
#include "graphics/view.h"
#include "graphics/gels.h"
#include "graphics/regions.h"
#include "graphics/clip.h"
#include "exec/exec.h"
#include "graphics/text.h"
#include "graphics/gfxbase.h"

#include "devices/console.h"
#include "devices/keymap.h"

#include "libraries/dos.h"
#include "graphics/text.h"
#include "libraries/diskfont.h"
#include "intuition/intuition.h"
 
/* EXTERNALS ***************************************************** */

extern struct Window *OpenWindow();
extern struct Screen *OpenScreen();
extern struct MsgPort *CreatePort();
extern struct IOStdReq *CreateStdIO();
extern int SPFlt(), SPFieee(), SPAdd(), SPMul(), SPDiv(), SPFix();

/* GLOBALS ****************************************************** */

union kludge {    /* can't use float directly for FFP because C */
   float num;     /* convert float to double in expressions and */
   int   i;       /* when passing parameters.                   */
} side, corna, cornb;

USHORT class;       /* values obtained from IntuiMessages */
USHORT code;
USHORT qualifier;
USHORT mode;
APTR address;       /* address of the gadget which we hit */

char Title[32];
USHORT CurrentColor; /* currently selected color gadget */
int modval;          /* modulus value used to determine number of colors */
int sideval;         /* length of side */

int NotDone, TimeToStop, wakeupmask, intuitionMsgBit, MaxHeight, MaxWidth;

long IntuitionBase=0;
long GfxBase=0;
long MathBase=0;
long MathTransBase=0;

struct Gadget ColorGadg[16];              /* the color selection gadgets */
struct Image  ColorImage[16], AltImage[16];   /* and their images */

struct IBitPlane {
   USHORT IData[8];     /* Image data structures */
};

struct IBitPlane NullOne = {
   { 0 }
};

struct IBitPlane SelectedOne = {
   0x0000,
   0x7f80,
   0x7f80,
   0x7f80,
   0x7f80,
   0x7f80,
   0x7f80,
   0x0000
};

struct MyImageData {
   struct IBitPlane Plane[4];      /* Image data for a color gadget */
} *PlanePtr;

/* Gadgets, Menuitems, Requesters, etc. */

struct IntuiText ResumeMsg = {
   2,1,                 /* FrontPen, BackPen */
   JAM2,                /* DrawMode */
   8,                   /* LeftEdge */
   4,                   /* TopEdge */
   NULL,                /* ITextFont */
   "Resume",            /* IText */
   NULL                 /* NextText */
};

SHORT BGCoord[10] = { 0,0, 62,0, 62,14, 0,14, 0,0 };

struct Border BGBdr = {
   1,1,                 /* LeftEdge, TopEdge */
   3,2,JAM1,            /* FrontPen, BackPen, DrawMode */
   5,                   /* Count */
   &BGCoord[0],         /* XY */
   NULL                 /* Next Border */
};

struct Gadget Resume = {
   NULL,                /*  NextGadget */
   -74,-20,64,16,       /* LeftEdge, TopEdge, Width, Height */
   GADGHCOMP |
   GRELBOTTOM |
   GRELRIGHT,           /* Flags */
   ENDGADGET |
   RELVERIFY,           /* Activation */
   BOOLGADGET |
   REQGADGET,           /* GadgetType */
   (APTR) &BGBdr,       /* GadgetRender */
   NULL,                /* SelectRender */
   &ResumeMsg,          /* GadgetText */
   0,                   /* MutualExclude */
   NULL,                /* SpecialInfo */
   RESUME,              /* GadgetID */
   NULL                 /* UserData */
};

struct PropInfo BPropInfo = {
   AUTOKNOB | FREEHORIZ,  /* Flags */
   0, 0,            /* Pots:  Horiz, Vert: both start at 0 */
   0x0fff, 0x0fff,  /* Bodies: Horiz is 1/16, Vert is 1/16 */
   0, 0, 0, 0, 0, 0 /* System usage stuff */
};

struct Image Dmy1, Dmy2, Dmy3;

struct Gadget BGadget = {
   &ColorGadg[0],             /* pointer to NextGadget */
   20, 40, 192, 10,           /* Select Box L T W H */
   GADGHCOMP | GADGIMAGE,     /* Flags */
   RELVERIFY,                 /* Activation flags */
   PROPGADGET | REQGADGET,    /* Type */
   (APTR) &Dmy3, /* GadgetRender */
   NULL,       /* no pointer to SelectRender */
   NULL,       /* no pointer to GadgetText */
   0,          /* no MutualExclude */
   (APTR) &BPropInfo, /* SpecialInfo */
   BCONTROL,          /* no ID */
   NULL        /* no pointer to special data */
};

struct PropInfo GPropInfo = {
   AUTOKNOB | FREEHORIZ,  /* Flags */
   0, 0,            /* Pots:  Horiz, Vert: both start at 0 */
   0x0fff, 0x0fff,  /* Bodies: Horiz is 1/16, Vert is 1/16 */
   0, 0, 0, 0, 0, 0 /* System usage stuff */
};

struct Gadget GGadget = {
   &BGadget,                  /* pointer to NextGadget */
   20, 22, 192, 10,           /* Select Box L T W H */
   GADGHCOMP | GADGIMAGE,     /* Flags */
   RELVERIFY,                 /* Activation flags */
   PROPGADGET | REQGADGET,    /* Type */
   (APTR) &Dmy2, /* GadgetRender */
   NULL,       /* no pointer to SelectRender */
   NULL,       /* no pointer to GadgetText */
   0,          /* no MutualExclude */
   (APTR) &GPropInfo, /* SpecialInfo */
   GCONTROL,          /* no ID */
   NULL        /* no pointer to special data */
};

struct PropInfo RPropInfo = {
   AUTOKNOB | FREEHORIZ,  /* Flags */
   0, 0,            /* Pots:  Horiz, Vert: both start at 0 */
   0x0fff, 0x0fff,  /* Bodies: Horiz is 1/16, Vert is 1/16 */
   0, 0, 0, 0, 0, 0 /* System usage stuff */
};

struct Gadget RGadget = {
   &GGadget,                  /* pointer to NextGadget */
   20, 04, 192, 10,           /* Select Box L T W H */
   GADGHCOMP | GADGIMAGE,     /* Flags */
   RELVERIFY,                 /* Activation flags */
   PROPGADGET | REQGADGET,    /* Type */
   (APTR) &Dmy1, /* GadgetRender */
   NULL,       /* no pointer to SelectRender */
   NULL,       /* no pointer to GadgetText */
   0,          /* no MutualExclude */
   (APTR) &RPropInfo, /* SpecialInfo */
   RCONTROL,          /* no ID */
   NULL        /* no pointer to special data */
};

struct IntuiText Prompt7 = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   28, 82,           /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "to modify.",     /* IText */
   NULL              /* NextText */
};

struct IntuiText Prompt6 = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   4, 72,            /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Select the color", /* IText */
   &Prompt7          /* NextText */
};

struct IntuiText Prompt5 = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   4, 40,            /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "B",              /* IText */
   &Prompt6          /* NextText */
};

struct IntuiText Prompt4 = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   4, 22,            /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "G",              /* IText */
   &Prompt5          /* NextText */
};

struct IntuiText Prompt3 = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   4, 4,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "R",              /* IText */
   &Prompt4          /* NextText */
};

SHORT RCoords2[10] = { 0,0,  194,0,  194,12,  0,12,  0,0 };

struct Border ColorsBord = {
   12, 54,        /* LeftEdge, TopEdge */
   0, 1, JAM1,    /* FrontPen, BackPen, DrawMode */
   5,             /* Count */
   &RCoords2[0],  /* XY */
   NULL           /* NextBorder */
};

SHORT RCoords1[10] = { 0,0,  217,0,  217,99,  0,99,  0,0 };

struct Border ReqBord1 = {
   1, 1,          /* LeftEdge, TopEdge */
   0, 1, JAM1,    /* FrontPen, BackPen, DrawMode */
   5,             /* Count */
   &RCoords1[0],  /* XY */
   &ColorsBord    /* NextBorder */
};

struct Requester ColorParms = {
   NULL,          /* OlderRequest */
   2, 12,         /* LeftEdge, TopEdge */
   220, 102,      /* Width, Height */
   0, 0,          /* RelLeft, RelTop */
   &RGadget,      /* ReqGadget */
   &ReqBord1,     /* ReqBorder */
   &Prompt3,      /* ReqText */
   0,             /* Flags */
   1,             /* BackFill */
   NULL,          /* ReqLayer */
   {NULL},        /* Pad */
   NULL,          /* ImageBmap */
   NULL,          /* RWindow (system) */
   {NULL}         /* Pad */
};

UBYTE NCBString[6], NCBUndo[6];

struct StringInfo NCBStr = {
   &NCBString[0],        /* Buffer */
   &NCBUndo[0],          /* UndoBuffer */
   0,                   /* BufferPos */
   6,                   /* MaxChars */
   0, 0, 0, 0,          /* DispPos, UndoPos, NumChars, DispCount */
   0, 0,                /* CLeft, CTop */
   NULL,                /* LayerPtr */
   0,                   /* LongInt */
   NULL                 /* AltKeyMap */
};

struct Gadget NewCornb = {
   &Resume,             /* NextGadget */
   15,76,40,8,          /* LeftEdge, TopEdge, Width, Height */
   GADGHCOMP,           /* Flags */
   LONGINT,             /* Activation */
   STRGADGET |
   REQGADGET,           /* GadgetType */
   NULL,                /* GadgetRender */
   NULL,                /* SelectRender */
   NULL,                /* GadgetText */
   0,                   /* MutualExclude */
   (APTR) &NCBStr,      /* SpecialInfo */
   NEWCORNB,            /* GadgetID */
   NULL                 /* UserData */
};

UBYTE NCAString[6], NCAUndo[6];

struct StringInfo NCAStr = {
   &NCAString[0],        /* Buffer */
   &NCAUndo[0],          /* UndoBuffer */
   0,                   /* BufferPos */
   6,                   /* MaxChars */
   0, 0, 0, 0,          /* DispPos, UndoPos, NumChars, DispCount */
   0, 0,                /* CLeft, CTop */
   NULL,                /* LayerPtr */
   0,                   /* LongInt */
   NULL                 /* AltKeyMap */
};

struct Gadget NewCorna = {
   &NewCornb,            /* NextGadget */
   15,56,40,8,          /* LeftEdge, TopEdge, Width, Height */
   GADGHCOMP,           /* Flags */
   LONGINT,             /* Activation */
   STRGADGET |
   REQGADGET,           /* GadgetType */
   NULL,                /* GadgetRender */
   NULL,                /* SelectRender */
   NULL,                /* GadgetText */
   0,                   /* MutualExclude */
   (APTR) &NCAStr,      /* SpecialInfo */
   NEWCORNA,            /* GadgetID */
   NULL                 /* UserData */
};

UBYTE NSString[6], NSUndo[6];

struct StringInfo NSStr = {
   &NSString[0],        /* Buffer */
   &NSUndo[0],          /* UndoBuffer */
   0,                   /* BufferPos */
   6,                   /* MaxChars */
   0, 0, 0, 0,          /* DispPos, UndoPos, NumChars, DispCount */
   0, 0,                /* CLeft, CTop */
   NULL,                /* LayerPtr */
   0,                   /* LongInt */
   NULL                 /* AltKeyMap */
};

struct Gadget NewSide = {
   &NewCorna,           /* NextGadget */
   15,36,40,8,          /* LeftEdge, TopEdge, Width, Height */
   GADGHCOMP,           /* Flags */
   LONGINT,             /* Activation */
   STRGADGET |
   REQGADGET,           /* GadgetType */
   NULL,                /* GadgetRender */
   NULL,                /* SelectRender */
   NULL,                /* GadgetText */
   0,                   /* MutualExclude */
   (APTR) &NSStr,       /* SpecialInfo */
   NEWSIDE,             /* GadgetID */
   NULL                 /* UserData */
};

UBYTE NMString[4], NMUndo[4];

struct StringInfo NMStr = {
   &NMString[0],        /* Buffer */
   &NMUndo[0],          /* UndoBuffer */
   0,                   /* BufferPos */
   4,                   /* MaxChars */
   0, 0, 0, 0,          /* DispPos, UndoPos, NumChars, DispCount */
   0, 0,                /* CLeft, CTop */
   NULL,                /* LayerPtr */
   0,                   /* LongInt */
   NULL                 /* AltKeyMap */
};

struct Gadget NewModulus = {
   &NewSide,            /* NextGadget */
   15,16,24,8,          /* LeftEdge, TopEdge, Width, Height */
   GADGHCOMP,           /* Flags */
   LONGINT,             /* Activation */
   STRGADGET |
   REQGADGET,           /* GadgetType */
   NULL,                /* GadgetRender */
   NULL,                /* SelectRender */
   NULL,                /* GadgetText */
   0,                   /* MutualExclude */
   (APTR) &NMStr,       /* SpecialInfo */
   NEWMOD,              /* GadgetID */
   NULL                 /* UserData */
};

struct IntuiText NCBTxt = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   8, 66,            /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Initial Y coordinate", /* IText */
   NULL              /* NextText */
};

struct IntuiText NCATxt = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   8, 46,            /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Initial X coordinate", /* IText */
   &NCBTxt           /* NextText */
};

struct IntuiText NSRange = {
   2, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   56, 36,           /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "side > 0", /* IText */
   &NCATxt           /* NextText */
};

struct IntuiText NSTxt = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   8, 26,            /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Enter a new side value", /* IText */
   &NSRange          /* NextText */
};

struct IntuiText ModRange = {
   2, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   56, 16,           /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "(2 <= modulus <= 16)", /* IText */
   &NSTxt            /* NextText */
};

struct IntuiText ModPrompt = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   8, 6,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Enter a new modulus value", /* IText */
   &ModRange         /* NextText */
};

SHORT NumCoords[10] = { 0,0,  217,0,  217,97,  0,97,  0,0 };

struct Border NumReqBord = {
   1, 1,          /* LeftEdge, TopEdge */
   0, 1, JAM1,    /* FrontPen, BackPen, DrawMode */
   5,             /* Count */
   &NumCoords[0], /* XY */
   NULL           /* NextBorder */
};

struct Requester NumericParms = {
   NULL,          /* OlderRequest */
   2, 12,         /* LeftEdge, TopEdge */
   220, 100,      /* Width, Height */
   0, 0,          /* RelLeft, RelTop */
   &NewModulus,   /* ReqGadget */
   &NumReqBord,   /* ReqBorder */
   &ModPrompt,    /* ReqText */
   0,             /* Flags */
   1,             /* BackFill */
   NULL,          /* ReqLayer */
   {NULL},        /* Pad */
   NULL,          /* ImageBmap */
   NULL,          /* RWindow (system) */
   {NULL}         /* Pad */
};

SHORT RCoord2[10] = { 0,0,  247,0,  247,47,  0,47,  0,0 };

struct Border ReqBord2 = {
   1, 1,          /* LeftEdge, TopEdge */
   0, 1, JAM1,    /* FrontPen, BackPen, DrawMode */
   5,             /* Count */
   &RCoord2[0],   /* XY */
   NULL           /* NextBorder */
};

struct IntuiText BadValMsg2 = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   6, 14,            /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Value was not changed", /* IText */
   NULL              /* NextText */
};

UBYTE ValMsg[32];

struct IntuiText BadValMsg = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   6, 4,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   &ValMsg[0],       /* IText */
   &BadValMsg2       /* NextText */
};

struct Requester BadNum = {
   NULL,          /* OlderRequest */
   35, 20,        /* LeftEdge, TopEdge */
   250, 50,       /* Width, Height */
   0, 0,          /* RelLeft, RelTop */
   &Resume,       /* ReqGadget */
   &ReqBord2,     /* ReqBorder */
   &BadValMsg,    /* ReqText */
   0,             /* Flags */
   1,             /* BackFill */
   NULL,          /* ReqLayer */
   {NULL},        /* Pad */
   NULL,          /* ImageBmap */
   NULL,          /* RWindow (system) */
   {NULL}         /* Pad */
};

struct IntuiText PaletteText = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   0, 0,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Palette   ",     /* IText */
   NULL              /* NextText */
};

struct IntuiText NumericText = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   0, 0,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Numeric   ",     /* IText */
   NULL              /* NextText */
};

struct IntuiText ParmText = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   0, 0,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Parameters",     /* IText */
   NULL              /* NextText */
};

struct IntuiText NewText = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   0, 0,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "New       ",     /* IText */
   NULL              /* NextText */
};

struct IntuiText StopText = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   0, 0,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Stop      ",     /* IText */
   NULL              /* NextText */
};

struct IntuiText StartText = {
   0, 1,             /* FrontPen, BackPen */
   JAM2,             /* DrawMode */
   0, 0,             /* LeftEdge, TopEdge */
   NULL,             /* ITextFont */
   "Start     ",     /* IText */
   NULL              /* NextText */
};

struct MenuItem PaletteItem = {
   NULL,              /* NextItem */
   79, 12, 80, 8,     /* LeftEdge, TopEdge, Width, Height */
   ITEMTEXT |
   ITEMENABLED |
   HIGHCOMP,         /* Flags */
   0,                /* MutualExclude */
   (APTR) &PaletteText, /* ItemFill */
   NULL,             /* SelectFill */
   0,                /* Command */
   NULL,             /* SubItem */
   0                 /* NextSelect */
};

struct MenuItem NumItem = {
   &PaletteItem,     /* NextItem */
   79, 2, 80, 8,     /* LeftEdge, TopEdge, Width, Height */
   ITEMTEXT |
   ITEMENABLED |
   HIGHCOMP,         /* Flags */
   0,                /* MutualExclude */
   (APTR) &NumericText, /* ItemFill */
   NULL,             /* SelectFill */
   0,                /* Command */
   NULL,             /* SubItem */
   0                 /* NextSelect */
};

struct MenuItem ParmItem = {
   NULL,             /* NextItem */
   0, 30, 80, 8,     /* LeftEdge, TopEdge, Width, Height */
   ITEMTEXT |
   ITEMENABLED |
   HIGHCOMP,         /* Flags */
   0,                /* MutualExclude */
   (APTR) &ParmText, /* ItemFill */
   NULL,             /* SelectFill */
   0,                /* Command */
   &NumItem,             /* SubItem */
   0                 /* NextSelect */
};

struct MenuItem NewItem = {
   &ParmItem,        /* NextItem */
   0, 20, 80, 8,     /* LeftEdge, TopEdge, Width, Height */
   ITEMTEXT |
   ITEMENABLED |
   HIGHCOMP,         /* Flags */
   0,                /* MutualExclude */
   (APTR) &NewText,  /* ItemFill */
   NULL,             /* SelectFill */
   0,                /* Command */
   NULL,             /* SubItem */
   0                 /* NextSelect */
};

struct MenuItem StopItem = {
   &NewItem,         /* NextItem */
   0, 10, 80, 8,     /* LeftEdge, TopEdge, Width, Height */
   ITEMTEXT |
   ITEMENABLED |
   HIGHCOMP,         /* Flags */
   0,                /* MutualExclude */
   (APTR) &StopText, /* ItemFill */
   NULL,             /* SelectFill */
   0,                /* Command */
   NULL,             /* SubItem */
   0                 /* NextSelect */
};

struct MenuItem StartItem = {
   &StopItem,        /* NextItem */
   0, 0, 80, 8,      /* LeftEdge, TopEdge, Width, Height */
   ITEMTEXT |
   HIGHCOMP,         /* Flags */
   0,                /* MutualExclude */
   (APTR) &StartText, /* ItemFill */
   NULL,             /* SelectFill */
   0,                /* Command */
   NULL,             /* SubItem */
   0                 /* NextSelect */
};

struct Menu CCMenu = {
   NULL,             /* NextMenu */
   16, 0, 56, 0,     /* LeftEdge, TopEdge, Width, Height */
   MENUENABLED,      /* Flags */
   "Options",        /* MenuName */
   &StartItem        /* FirstItem */
};

struct NewWindow nwGraphics = {
      0, 0,             /* start position */
      0, 0,             /* width, height are filled in later */
      0, 1,             /* detail pen, block pen */
      MENUPICK | GADGETUP |
      CLOSEWINDOW,      /* IDCMP flags */
      WINDOWCLOSE | SMART_REFRESH | NOCAREREFRESH |
      ACTIVATE,         /* window flags */
      NULL,             /* pointer to first user gadget */
      NULL,             /* pointer to user checkmark  */ 
      "",               /* window title */
      NULL,             /* pointer to screen    (later) */
      NULL,             /* pointer to superbitmap */
      50,40,0,0,        /* sizing limits min and max */
      CUSTOMSCREEN      /* type of screen in which to open */
      };

struct NewScreen Any_Res_Screen = {
   0, 0,                      /* LeftEdge, TopEdge */
   0, 0,                      /* Width, Height are filled in later */
   DEPTH,                     /* Depth */
   0, 1,                      /* DetailPen, BlockPen */
   0,                         /* ViewModes */
   CUSTOMSCREEN,              /* Type */
   NULL,                      /* Font */
   "",                        /* DefaultTitle */
   NULL,                      /* Gadgets */
   NULL                       /* CustomBitMap */
};

struct RastPort *rpG;               /* rastport at which to render */
struct IntuiMessage *message;       /* the message the IDCMP sends us */
struct Screen *sG;
struct Window *wG;

UWORD colortable[] = { 0x000, 0xfff,        /* black, white */
                       0xf00, 0xf70,        /* ruby, orange */
                       0xff0, 0x7f0,        /* yellow, lime */
                       0x0f0, 0x0f7,        /* green, aqua */
                       0x0ff, 0x07f,        /* turquoise, blue-green */
                       0x00f, 0x70f,        /* blue, maroon */
                       0xf0f, 0x707,        /* purple, deep purple */
                       0xa84, 0x888 };      /* brown, gray */

main(argc, argv)
int argc;
char *argv[];
{
      int problem;
      struct ColorMap *oldcmap;
 
      /* Let's initialize some stuff first */

      PlanePtr =   /* get some chip RAM for gadget image data */
         (struct MyImageData *) AllocMem(16 * sizeof(struct MyImageData),
         MEMF_CHIP | MEMF_CLEAR);

      if (PlanePtr == 0) {
         printf("Memory allocation error\n");
         exit(20);
      }

      strcpy(NSString,"160");  /* set initial side value */
      strcpy(NCAString,"-15"); /* set initial corner values */
      strcpy(NCBString,"-20");
      strcpy(NMString,"2");    /* set initial modulus value */

      InitGadgetList();        /* Put together palette gadgets */

      if ((argc == 2) &&
         ((strcmp(argv[1],"-h") == 0) || (strcmp(argv[1],"-H") == 0))) {
         MaxHeight = 400;
         MaxWidth  = 640;
         Any_Res_Screen.ViewModes = LACE | HIRES;
      }
      else {
         MaxHeight = 200;
         MaxWidth = 320;
      }

      /* Initialize any dynamic screen and window parameters */

      Any_Res_Screen.Width = MaxWidth;
      Any_Res_Screen.Height = MaxHeight;
      nwGraphics.Width = MaxWidth;
      nwGraphics.Height = MaxHeight;
      nwGraphics.MaxWidth = MaxWidth;
      nwGraphics.MaxHeight = MaxHeight;

   /* Open all necessary libraries */

      if ((MathBase = OpenLibrary("mathffp.library",0)) < 1) {
         printf("mathffp library open failed\n");
         problem = 100;
         goto cleanup0;
      }

      if ((MathTransBase = OpenLibrary("mathtrans.library",0)) < 1) {
         printf("mathtrans library open failed\n");
         problem = 200;
         goto cleanup0;
      }

      GfxBase = OpenLibrary("graphics.library", 0);
      if (GfxBase == NULL)
      {
            printf("graphics library open failed\n");
            problem = 1;
            goto cleanup1;
      }
      IntuitionBase = OpenLibrary("intuition.library", 0);
      if (IntuitionBase == NULL)
      {
            printf("intuition library open failed\n");
            problem = 2;
            goto cleanup1;
      }

   /* We need a custom screen for this stuff */

      sG = OpenScreen(&Any_Res_Screen);
      if ( sG == NULL) {
            printf("open screen failed\n");
            problem = 3;
            goto cleanup1a;
      }

   /* Let's substitute our own color map */

      oldcmap = sG->ViewPort.ColorMap;
      sG->ViewPort.ColorMap = (struct ColorMap *) GetColorMap(16);
      LoadRGB4(&(sG->ViewPort), colortable, 16);
      nwGraphics.Screen = sG;

      wG = OpenWindow(&nwGraphics); /* open a window for graphics*/
      if ( wG == NULL ) {
            printf ("open window failed\n");
            problem = 4;
            goto cleanup2;
      }

      rpG = wG->RPort;            /* set a rastport pointer */
      SetNumericValues();         /* Set window title, initialize values */
      SetMenuStrip(wG, &CCMenu);  /* Attach a menu to the window */

/* find out which signals to wait for.... Intuition allocates a signal bit
 for an IDCMP */

      intuitionMsgBit = wG->UserPort->mp_SigBit;

/* This code assumes that the only events we expect to wake up for are
   messages from intuition arriving at the IDCMP */

      TimeToStop = FALSE;
      NotDone = TRUE;
      do {

            message = NULL;   /* no messages yet */

            if ((TimeToStop) ||
               (NotDone = PlotPoints())) { /* display graphics rendition */

               ClearMenuStrip(wG);         /* Enable start MenuItem */
               StartItem.Flags |= ITEMENABLED;
               StopItem.Flags &= ~ITEMENABLED;
               SetMenuStrip(wG, &CCMenu);

               wakeupmask = Wait(INTUITION_MESSAGE); /* Clear signal */
     
               if (message == NULL)
                  message = (struct IntuiMessage *) GetMsg(wG->UserPort);

               do {
                   /* empty the port then try to handle the event */
                   class = message->Class;
                   code =      message->Code;
                   qualifier = message->Qualifier;
                   address = message->IAddress;
                   ReplyMsg(message);
                   if ((NotDone = HandleEvent()) == FALSE) break;
               }
               while( (message = (struct IntuiMessage *)
                      GetMsg(wG->UserPort) ) != NULL);
            }

      } while (NotDone);      /* keep going until done */

   problem = 0;

   cleanup3:
      ClearMenuStrip(wG);
      CloseWindow(wG);
   cleanup2:
      FreeColorMap(sG->ViewPort.ColorMap);
      sG->ViewPort.ColorMap = oldcmap;
      CloseScreen(sG);
   cleanup1a:
      if (GfxBase != NULL) CloseLibrary(GfxBase);
   cleanup1:
      if (IntuitionBase != NULL) CloseLibrary(IntuitionBase);
   cleanup0:
      if (MathTransBase != NULL) {
         RemLibrary(MathTransBase);    /* allow library to be expunged */
         CloseLibrary(MathTransBase);
      }
      if (MathBase != NULL) {
         CloseLibrary(MathBase);
      }

      FreeMem(PlanePtr, 16 * sizeof(struct MyImageData));

      if(problem > 0) 
            exit(problem+1000);
      else
            return(0);
}

/* This routine does the actual plotting of the points */

int PlotPoints()
{
   int c, ExitFlag;
   register int i, j;
   union kludge x, y, z, point5, linesize;

   /* Initialize some parameters. */

   point5.num = 0.5;
   point5.i = SPFieee(point5.i);  /* used for rounding */

   linesize.i = MaxHeight - 3 - YMIN;
   linesize.i = SPFlt(linesize.i);

   for (i = XMIN; i <= MaxWidth-3; i++) { /* one iteration per vert. line */

      for (j = YMIN; j <= MaxHeight-3; j++) {  /* one iteration per pixel */

        /* Compute: x = corna + side * i/linesize
                    y = cornb + side * j/linesize
                    z = x * x + y * y
                    c = z MOD modval               */

         x.i = SPAdd(corna.i, SPMul(side.i, SPDiv(linesize.i, SPFlt(i))));
         y.i = SPAdd(cornb.i, SPMul(side.i, SPDiv(linesize.i, SPFlt(j))));
         z.i = SPAdd(SPMul(x.i, x.i), SPMul(y.i, y.i));
         c = SPFix(SPAdd(z.i, point5.i));
         c %= modval;

         SetAPen(rpG, c);           /* Set new color for rendering pixel */
         WritePixel(rpG, i, j);
      }

      /* we poll?!!! for a message at the end of each vertical line   */
      /* It is okay to poll in this case since we have plenty of work */
      /* to do if no message is available                             */

      if ((message = (struct IntuiMessage *) GetMsg(wG->UserPort)) != NULL)
         if (!(ExitFlag = CheckEvent()))
            return(ExitFlag);
         else if (TimeToStop)
            break;
   }
   TimeToStop = TRUE;
   return(TRUE);
}

/* This routine returns FALSE to PlotPoints() is a CLOSEWINDOW event */
/* is detected.  Other events are handled thru an event handler.     */

int CheckEvent()
{
   int bugout;

   /* Note that the following call to Wait() will not put us to sleep
      because there is already a message in the port awaiting Reply().
      The only reason that we call Wait() is to clear the signal. */

   wakeupmask = Wait(INTUITION_MESSAGE);        /* Clear signal */
     
   do {
      /* empty the port then try to handle the event */
      class = message->Class;
      code =      message->Code;
      qualifier = message->Qualifier;
      address = message->IAddress;
      ReplyMsg(message);
      if ((bugout = HandleEvent()) == FALSE) break;
      }
   while((message = (struct IntuiMessage *) GetMsg(wG->UserPort)) != NULL);
   return(bugout);
}

int HandleEvent()    /* Process events */
{
   switch(class)
   {
      case CLOSEWINDOW:
            return(FALSE);
            break;
      case MENUPICK:
            MenuEvent();      /* process menu events */
            break;
   }
   class = 0;
   code = 0;
   qualifier = 0;
   address = 0;
   return(TRUE);
}

#define OPTIONS  0
#define START      0
#define STOP       1
#define NEW        2
#define PARAMETERS 3
#define NUMERIC      0
#define PALETTE      1

/* All menu events are funneled into this routine and processed here */

MenuEvent()
{
   USHORT MenuNumber, fnMenu, fnItem, fnSubItem;
   struct MenuItem *ItemAddress(), *Item;

   MenuNumber = code;
   while (MenuNumber != MENUNULL) {
      Item = ItemAddress(&CCMenu, MenuNumber);
      fnMenu = MENUNUM(MenuNumber);
      fnItem = ITEMNUM(MenuNumber);
      fnSubItem = SUBNUM(MenuNumber);
      switch(fnMenu)
      {
         case OPTIONS:
            switch(fnItem)
            {
               case START:             /* Start PlotPoints() plotting */
                  ClearMenuStrip(wG);
                  StartItem.Flags &= ~ITEMENABLED;
                  StopItem.Flags |= ITEMENABLED;
                  SetMenuStrip(wG, &CCMenu);
                  TimeToStop = FALSE;
                  break;
               case STOP:              /* stop plotting */
                  TimeToStop = TRUE;
                  break;
               case NEW:               /* Clear screen and stop plotting */
                  TimeToStop = TRUE;
                  SetAPen(rpG, 0);
                  SetOPen(rpG, 0);
                  RectFill(rpG, XMIN, YMIN, MaxWidth-2, MaxHeight-2);
                  break;
               case PARAMETERS:        /* process parameter subitems */
                  switch(fnSubItem)
                  {
                     case NUMERIC:     /* modify numeric parms */
                        ParmReq(&NumericParms);
                        SetNumericValues();
                        break;
                     case PALETTE:     /* modify palette */
                        ParmReq(&ColorParms);
                        break;
                  }
                  break;
            }
            break;
      }
      MenuNumber = Item->NextSelect;
   }
}

/* This routine clones the 16 color gadgets for the palette requester */

InitGadgetList()
{
   SHORT i, j, k;
   struct Gadget *CGadg;
   struct Image  *CImage, *AImage;
   struct MyImageData *PPtr;

   CGadg = ColorGadg;
   CImage = ColorImage;
   AImage = AltImage;
   PPtr = PlanePtr;

   for(i = 0; i <= 15; i++) {

      /* Initialize each color selection gadget */

      CGadg->NextGadget = CGadg + 1;   /* chain them together */
      CGadg->LeftEdge = i * 12 + 14;
      CGadg->TopEdge  = 56;
      CGadg->Width    = 10;
      CGadg->Height   = 8;
      CGadg->Flags    = GADGIMAGE | GADGHIMAGE;
      CGadg->Activation = RELVERIFY | TOGGLESELECT;
      CGadg->GadgetType = BOOLGADGET | REQGADGET;
      CGadg->GadgetRender = (APTR) &ColorImage[i];
      CGadg->SelectRender = (APTR) &AltImage[i];
      CGadg->GadgetText   = NULL;
      CGadg->MutualExclude = 0;
      CGadg->SpecialInfo   = NULL;
      CGadg->GadgetID      = (USHORT) i + 1;
      CGadg->UserData      = NULL;

   /* Images for unselected gadgets are colored rectangles */

      CImage->LeftEdge     = 0;
      CImage->TopEdge      = 0;
      CImage->Width        = 10;
      CImage->Height       = 8;
      CImage->Depth        = 0;
      CImage->ImageData    = NULL;
      CImage->PlanePick    = 0;
      CImage->PlaneOnOff   = (UBYTE) i;
      CImage->NextImage    = NULL;

   /* Alternate (selected) images are bordered colored rectangles */

      AImage->LeftEdge     = 0;
      AImage->TopEdge      = 0;
      AImage->Width        = 10;
      AImage->Height       = 8;
      AImage->Depth        = 4;
      AImage->ImageData    = (SHORT *) PPtr;
      AImage->PlanePick    = 0xf;
      AImage->PlaneOnOff   = 0;
      AImage->NextImage    = NULL;

      /* Construct image data area in CHIP RAM for each gadget */

      for (k = 1, j = 0; j <= 3; j++) {
         if ((k & i) != 0)
            PPtr->Plane[j] = SelectedOne;
         else
            PPtr->Plane[j] = NullOne;
         k <<= 1;
      }

      CGadg++;       /* bump pointers */
      CImage++;
      AImage++;
      PPtr++;
   }
   CGadg--;              /* tidy up first and last gadgets in the chain */
   CGadg->NextGadget = &Resume;
   ColorGadg[0].Flags |= SELECTED;
   CurrentColor = 0;
   SetRGBGadgets(CurrentColor);
}

/* This routine handles the requester processing.  Note that the */
/* requester is passed as a parameter.                           */

ParmReq(ReqPtr)
struct Requester *ReqPtr;
{
   Request(ReqPtr, wG);

   do {
      wakeupmask = Wait(INTUITION_MESSAGE);
     
      while((message = (struct IntuiMessage *)
            GetMsg(wG->UserPort)) != NULL) {

         /* empty the port then try to handle the event */

         class = message->Class;
         code =      message->Code;
         qualifier = message->Qualifier;
         address = message->IAddress;
         ReplyMsg(message);

      /* we do not need to go to the standard event handler since */
      /* while the requester is up all we will receive are gadget */
      /* events from the IDCMP.  Therefore we go to a special     */
      /* gadget event handler.                                    */

         if (GadgetEvent() == TRUE) return(0);
      }
   } while (1);
}

/* This routine handles the requester gadgets and their events */

GadgetEvent()
{
   USHORT GadgID;

   GadgID = ((struct Gadget *) address)->GadgetID;
   switch(class)
   {
      case GADGETUP:
            switch(GadgID)
            {
               case RESUME:
                  return(TRUE);
                  break;
               case NEWMOD:
                  break;
               case RCONTROL:
               case GCONTROL:
               case BCONTROL:
                  SetColorRegs(CurrentColor);
                  break;
               case 1:
               case 2:
               case 3:
               case 4:
               case 5:
               case 6:
               case 7:
               case 8:  /* (I'm sure there are better ways of doing this) */
               case 9:
               case 10:
               case 11:
               case 12:
               case 13:
               case 14:
               case 15:
               case 16:
                  CurrentColor = GadgID - 1;
                  SetRGBGadgets(CurrentColor);
                  ClearColorSel();
                  ColorGadg[CurrentColor].Flags |= SELECTED;
                  RefreshGadgets(&RGadget, wG, &ColorParms);
                  break;
            }
            break;
   }
   class = 0;
   code = 0;
   qualifier = 0;
   address = 0;
   return(FALSE);
}

/* This routine manages all three proportional gadgets and sets them */
/* up to reflect the currently selected color.                       */

SetRGBGadgets(Color)
USHORT Color;
{
   int rval, gval, bval;
   struct PropInfo *PIPtr;

   /* Isolate component values of selected color */

   rval = (colortable[Color] >> 8) & 0x000f;
   gval = (colortable[Color] >> 4) & 0x000f;
   bval = colortable[Color] & 0x000f;

   /* Initialize proportional gadgets to reflect the color values */

   PIPtr = (struct PropInfo *) RGadget.SpecialInfo;
   PIPtr->HorizPot = PIPtr->VertPot = (USHORT) rval * 0x0fff;

   PIPtr = (struct PropInfo *) GGadget.SpecialInfo;
   PIPtr->HorizPot = PIPtr->VertPot = (USHORT) gval * 0x0fff;

   PIPtr = (struct PropInfo *) BGadget.SpecialInfo;
   PIPtr->HorizPot = PIPtr->VertPot = (USHORT) bval * 0x0fff;
}

/* Routine clears selection flag from all color gadgets. */
/* This is used before re-rendering gadgets.             */

ClearColorSel()
{
   int i;
   struct Gadget *CGadg;

   CGadg = ColorGadg;
   for (i = 0; i <= 15; i++) {
      CGadg->Flags &= ~SELECTED;
      CGadg++;
   }
}

/* This routine reads the values off of the proportional gadgets and */
/* sets that value into the selected color register.  The modified   */
/* color table is then loaded.                                       */

SetColorRegs(Color)
USHORT Color;
{
   LONG rval, gval, bval;
   struct PropInfo *PIPtr;
   
   PIPtr = (struct PropInfo *) RGadget.SpecialInfo;
   rval = (((PIPtr->HorizPot + 1) * 15) + 0x8000) >> 16;

   PIPtr = (struct PropInfo *) GGadget.SpecialInfo;
   gval = (((PIPtr->HorizPot + 1) * 15) + 0x8000) >> 16;

   PIPtr = (struct PropInfo *) BGadget.SpecialInfo;
   bval = (((PIPtr->HorizPot + 1) * 15) + 0x8000) >> 16;

   colortable[Color] = (UWORD) ((rval << 8) | (gval << 4) | bval);
   LoadRGB4(&(sG->ViewPort), colortable, 16);
}

/* Routine provides initialization and edit checking for the numeric */
/* parameters.  It also constructs the and sets the window title.    */

SetNumericValues()
{
   int newmod, newside, SPFlt();
   char cvt[10];

   stcd_i(NSString, &newside);      /* convert parameters to integers */
   stcd_i(NCAString, &corna.i);     /* or perhaps FFP FLOATs          */
   strcpy(NCAUndo, NCAString);
   corna.i = SPFlt(corna.i);
   stcd_i(NCBString, &cornb.i);
   strcpy(NCBUndo, NCBString);
   cornb.i = SPFlt(cornb.i);
   stcd_i(NMString, &newmod);

   /* now let's do a little judicious editting */

   if ((newmod >= 2) && (newmod <= 16)) {
      strcpy(NMUndo, NMString);
      modval = newmod;
      strcpy(Title, "CircleSquared - Modulus: ");
      strcat(Title, NMString);
      SetWindowTitles(wG, Title, -1);
   }
   else {                     /* whoops! - modulus value is out of range */
      stci_d(cvt, modval, 10);
      strcpy(NMString, cvt);
      strcpy(NMUndo, NMString);
      strcpy(ValMsg, "Modulus value was out of range");
      Request(&BadNum, wG);
      wakeupmask = Wait(INTUITION_MESSAGE);
      while((message = (struct IntuiMessage *) GetMsg(wG->UserPort)) != NULL)
         ReplyMsg(message);
   }

  if (newside <= 0) {          /* make sure that side value is positive */
      stci_d(cvt, sideval, 10);
      strcpy(NSString, cvt);
      strcpy(NSUndo, NMString);
      strcpy(ValMsg, "Side value was out of range");
      Request(&BadNum, wG);
      wakeupmask = Wait(INTUITION_MESSAGE);
      while((message = (struct IntuiMessage *) GetMsg(wG->UserPort)) != NULL)
         ReplyMsg(message);
   }
   else {
      strcpy(NSUndo, NSString);
      sideval = newside;
      side.i = SPFlt(sideval);
   }
}

