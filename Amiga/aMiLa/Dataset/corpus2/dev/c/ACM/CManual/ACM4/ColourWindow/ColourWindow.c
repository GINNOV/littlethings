/* Name: ColourWindow.c

   CCC                                W     W
  C   C                               W     W
  C      OOO  L      OOO  U   U RRRR  W     W III N   N DDD    OOO  W     W
  C     O   O L     O   O U   U R   R W     W  I  NN  N D  D  O   O W     W
  C     O   O L     O   O U   U RRRR  W  W  W  I  N N N D   D O   O W  W  W
  C   C O   O L     O   O U   U R  R   W W W   I  N  NN D  D  O   O  W W W
   CCC   OOO  LLLLL  OOO   UUU  R   R   W W   III N   N DDD    OOO    W W


  COLOUR WINDOW   VERSION 1.00   90-07-22

  Yet another program dedicated to Sioe-Lin Kwik.
  

  COLOUR WINDOW was created by Anders Bjerin, and is distributed as
  public domain with NO RIGHTS RESERVED. That means that you can do
  what ever you want with the program.
  
  You may use COLOUR WINDOW in your own programs, commercial or not,
  and do not even need to mention that you have used it. You may
  alter the source code to fit your needs, and you may spread it to
  anyone.
  
    
  
  COLOUR WINDOW is written to be as easy as possible to use, and is
  fully amigaized. COLOUR WINDOW is very easy to install in your
  program, and I have even done an example on how to use it. The
  source code is full of comments to make it easier for you to change
  something in the program. If you would have any problems, feel
  free to contact me.

  If you have any questions, ideas, programs (PD or your own) etc etc,
  or just want to say hello, PLEASE WRITE TO ME:

  Anders Bjerin
  Amiga C Club (ACC)
  Tulevagen 22
  181 41  LIDINGO
  SWEDEN



  III N   N FFFFF  OOO  RRRR  M   M  AAA  TTTTTTT III  OOO  N   N
   I  NN  N F     O   O R   R MM MM A   A    T     I  O   O NN  N
   I  N N N FFF   O   O RRRR  M M M AAAAA    T     I  O   O N N N
   I  N  NN F     O   O R  R  M   M A   A    T     I  O   O N  NN
  III N   N F      OOO  R   R M   M A   A    T    III  OOO  N   N

  ColourWindow is the first and only true colour requester in the
  Public Domain. It adjust itself to any depth (2, 4, 8, 16 or 32
  colours), and can be used with high- as well as low resolution
  screens. Everything is done by the rules, and this program will
  return everything it has taken, and use a minimum of processing
  time. It is yet another program releaced from the Amiga C Club! 

  result = ColourWindow( screen, title, x, y );

  result:    (UBYTE) ColourWindow will return a flag which tells
             your program what has happened:
               OK      The user selected the OK gadget.
               CANCEL  The user selected the CANCEL gadget.
               QUIT    The user closed the window.
               ERROR   Something went wrong. (Not enough memory,
                       or the x, y coordinates were too big so
                       the window could not fit on the screen.)

  screen:    (struct Screen *) Pointer to the screen ColourWindow
             should be connected to. If you want that the user
             should be able to change the colour of the Workbench
             screen, set the pointer to NULL. (REMEMBER! The
             Workbench screen's colours should normally only
             be changed with Preferences!)
              
  title:     (STRPTR) Pointer to a string containing the title of
             Colour Window, or NULL if you do not want any title.

  x:         (SHORT) X position of Colour Window.

  y:         (SHORT) Y position of Colour Window.


  Remember to include the file "ColourWindow.h"!



  Program:                 ColourWindow
  Version:                 1.00
  Programmer:              Anders Bjerin
  Language:                C (100%)
  Compiler:                Lattice C Compiler, V5.04
  Linker:                  Blink, V5.04
  AmigaDOS:                V1.2 and V1.3
  Ref. nr:                 4A-636-2B
 
  Amiga is a registered trademark of Commodore-Amiga, Inc.
  AmigaDOS is a registered trademark of Commodore-Amiga, Inc.
  Lattice is a registered trademark of Lattice, Inc.



  ENJOY YOUR AMIGA, AND MAKE EVERYONE ELSE ENJOY IT TOO!

  Anders Bjerin

*/



#include <intuition/intuition.h>
#include "ColourWindow.h"



/* The Intuition and Graphics library must be opened before a program */
/* may call teh ColourWindow() function:                              */
extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;



/* Sprite Data for the three pointers we will use: */

/* 1. Pointer data: "TO" */
USHORT chip pointer_to_data[36]=
{
  0x0000, 0x0000,

  0x0000, 0xfc00,
  0x7c00, 0xfe00,
  0x7c00, 0x8600,
  0x7800, 0x8c00,
  0x7c00, 0x8600,
  0x6e00, 0x9300,
  0x0700, 0x6980,
  0x0380, 0x04c0,
  0x01c0, 0x0260,
  0x0080, 0x0140,
  0x0000, 0x0080,
  0x3e70, 0x0108,
  0x0888, 0x0444,
  0x0888, 0x0444,
  0x0888, 0x0444,
  0x0870, 0x0408,

  0x0000, 0x0000
};

/* 2. Pointer data: "TWO" */
USHORT chip pointer_two_data[36]=
{
  0x0000, 0x0000,

  0x0000, 0x0c30,
  0x0810, 0x1c38,
  0x1818, 0x2fec,
  0x3ffc, 0x47e6,
  0x7ffe, 0x8003,
  0x3ffc, 0x4002,
  0x1818, 0x27e4,
  0x0810, 0x1428,
  0x0000, 0x0c30,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,

  0x0000, 0x0000
};

/* 3. Pointer data: "NORMAL" */
USHORT chip pointer_normal_data[36]=
{
  0x0000, 0x0000,

  0x0000, 0xfc00,
  0x7c00, 0xfe00,
  0x7c00, 0x8600,
  0x7800, 0x8c00,
  0x7c00, 0x8600,
  0x6e00, 0x9300,
  0x0700, 0x6980,
  0x0380, 0x04c0,
  0x01c0, 0x0260,
  0x0080, 0x0140,
  0x0000, 0x0080,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,

  0x0000, 0x0000
};



/* Normal Topaz font, 80 characters/line, ROM: */
struct TextAttr rom_font=
{
  "topaz.font", /* The name of the font. */
  TOPAZ_EIGHTY, /* 80 characters/line. */
  FS_NORMAL,    /* Normal (plain) style. */
  FPF_ROMFONT   /* ROM font. */
};



/* PROPORTIONAL GADGET: RED */

struct IntuiText red_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  -10, 2,     /* LeftEdge */
  &rom_font,  /* ITextFont */
  "R",        /* IText */
  NULL,       /* NextText */
};

struct Image red_knob;

struct PropInfo red_info=
{
  AUTOKNOB|        /* Flatgs */
  FREEHORIZ,
  0,               /* HorizPot */
  0,               /* VertPot */
  MAXBODY/16,      /* HorizBody */
  0,               /* VertBody */
  0, 0, 0, 0, 0, 0 /* Initialized and maintained by Intuition. */
};

struct Gadget red_gadget=
{
  NULL,             /* NextGadget */
  15,               /* LeftEdge */
  11,               /* TopEdge */
  153,              /* Width */
  11,               /* Height */
  GADGHCOMP,        /* Flags */
  GADGIMMEDIATE|    /* Activation */
  RELVERIFY|
  FOLLOWMOUSE,
  PROPGADGET,       /* GadgetType */
  (APTR) &red_knob, /* GadgetRender */
  NULL,             /* SelectRender */
  &red_text,        /* GadgetText */
  0,                /* MutualExclude */
  (APTR) &red_info, /* SpecialInfo */
  0,                /* GadgetID */
  NULL              /* UserData */
};



/* PROPORTIONAL GADGET: GREEN */

struct IntuiText green_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  -10, 2,     /* LeftEdge */
  &rom_font,  /* ITextFont */
  "G",        /* IText */
  NULL,       /* NextText */
};

struct Image green_knob;

struct PropInfo green_info=
{
  AUTOKNOB|        /* Flatgs */
  FREEHORIZ,
  0,               /* HorizPot */
  0,               /* VertPot */
  MAXBODY/16,      /* HorizBody */
  0,               /* VertBody */
  0, 0, 0, 0, 0, 0 /* Initialized and maintained by Intuition. */
};

struct Gadget green_gadget=
{
  &red_gadget,        /* NextGadget */
  15,                 /* LeftEdge */
  23,                 /* TopEdge */
  153,                /* Width */
  11,                 /* Height */
  GADGHCOMP,          /* Flags */
  GADGIMMEDIATE|      /* Activation */
  RELVERIFY|
  FOLLOWMOUSE,
  PROPGADGET,         /* GadgetType */
  (APTR) &green_knob, /* GadgetRender */
  NULL,               /* SelectRender */
  &green_text,        /* GadgetText */
  0,                  /* MutualExclude */
  (APTR) &green_info, /* SpecialInfo */
  0,                  /* GadgetID */
  NULL                /* UserData */
};



/* PROPORTIONAL GADGET: BLUE */

struct IntuiText blue_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  -10, 2,     /* LeftEdge */
  &rom_font,  /* ITextFont */
  "B",        /* IText */
  NULL,       /* NextText */
};

struct Image blue_knob;

struct PropInfo blue_info=
{
  AUTOKNOB|        /* Flatgs */
  FREEHORIZ,
  0,               /* HorizPot */
  0,               /* VertPot */
  MAXBODY/16,      /* HorizBody */
  0,               /* VertBody */
  0, 0, 0, 0, 0, 0 /* Initialized and maintained by Intuition. */
};

struct Gadget blue_gadget=
{
  &green_gadget,     /* NextGadget */
  15,                /* LeftEdge */
  35,                /* TopEdge */
  153,               /* Width */
  11,                /* Height */
  GADGHCOMP,         /* Flags */
  GADGIMMEDIATE|     /* Activation */
  RELVERIFY|
  FOLLOWMOUSE,
  PROPGADGET,        /* GadgetType */
  (APTR) &blue_knob, /* GadgetRender */
  NULL,              /* SelectRender */
  &blue_text,        /* GadgetText */
  0,                 /* MutualExclude */
  (APTR) &blue_info, /* SpecialInfo */
  0,                 /* GadgetID */
  NULL               /* UserData */
};



/* Data for a six-letter box: */

SHORT points6[10]=
{
  0,   0,
  52,  0,
  52, 10,
  0,  10,
  0,   0
};

struct Border box6=
{
  0,       /* LeftEdge */
  0,       /* TopEdge */
  1,       /* FrontPen */
  0,       /* BackPen */
  JAM1,    /* DrawMode */
  5,       /* Count */
  points6, /* XY */
  NULL     /* NextBorder */
};



/* Data for a four-letter box: */

SHORT points4[10]=
{
  0,   0,
  36,  0,
  36, 10,
  0,  10,
  0,   0
};

struct Border box4=
{
  0,       /* LeftEdge */
  0,       /* TopEdge */
  1,       /* FrontPen */
  0,       /* BackPen */
  JAM1,    /* DrawMode */
  5,       /* Count */
  points4, /* XY */
  NULL     /* NextBorder */
};



/* Data for a two-letter box: */

SHORT points2[10]=
{
  0,   0,
  20,  0,
  20, 10,
  0,  10,
  0,   0
};

struct Border box2=
{
  0,       /* LeftEdge */
  0,       /* TopEdge */
  1,       /* FrontPen */
  0,       /* BackPen */
  JAM1,    /* DrawMode */
  5,       /* Count */
  points2, /* XY */
  NULL     /* NextBorder */
};



/* BOOLEAN GADGET: SPREAD */

struct IntuiText spread_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  3, 2,       /* LeftEdge, TopEdge */
  &rom_font,  /* ITextFont */
  "SPREAD",   /* IText */
  NULL,       /* NextText */
};

struct Gadget spread_gadget=
{
  &blue_gadget, /* NextGadget */
  195,          /* LeftEdge */
  23,           /* TopEdge */
  53,           /* Width */
  11,           /* Height */
  GADGHCOMP,    /* Flags */
  RELVERIFY,    /* Activation */
  BOOLGADGET,   /* GadgetType */
  (APTR) &box6, /* GadgetRender */
  NULL,         /* SelectRender */
  &spread_text, /* GadgetText */
  0,            /* MutualExclude */
  NULL,         /* SpecialInfo */
  0,            /* GadgetID */
  NULL          /* UserData */
};



/* BOOLEAN GADGET: EX */

struct IntuiText ex_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  3, 2,       /* LeftEdge, TopEdge */
  &rom_font,  /* ITextFont */
  "EX",       /* IText */
  NULL,       /* NextText */
};

struct Gadget ex_gadget=
{
  &spread_gadget, /* NextGadget */
  251,            /* LeftEdge */
  23,             /* TopEdge */
  21,             /* Width */
  11,             /* Height */
  GADGHCOMP,      /* Flags */
  RELVERIFY,      /* Activation */
  BOOLGADGET,     /* GadgetType */
  (APTR) &box2,   /* GadgetRender */
  NULL,           /* SelectRender */
  &ex_text,       /* GadgetText */
  0,              /* MutualExclude */
  NULL,           /* SpecialInfo */
  0,              /* GadgetID */
  NULL            /* UserData */
};



/* BOOLEAN GADGET: COPY */

struct IntuiText copy_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  3, 2,       /* LeftEdge, TopEdge */
  &rom_font,  /* ITextFont */
  "COPY",     /* IText */
  NULL,       /* NextText */
};

struct Gadget copy_gadget=
{
  &ex_gadget,   /* NextGadget */
  195,          /* LeftEdge */
  35,           /* TopEdge */
  37,           /* Width */
  11,           /* Height */
  GADGHCOMP,    /* Flags */
  RELVERIFY,    /* Activation */
  BOOLGADGET,   /* GadgetType */
  (APTR) &box4, /* GadgetRender */
  NULL,         /* SelectRender */
  &copy_text,   /* GadgetText */
  0,            /* MutualExclude */
  NULL,         /* SpecialInfo */
  0,            /* GadgetID */
  NULL          /* UserData */
};



/* BOOLEAN GADGET: UNDO */

struct IntuiText undo_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  3, 2,       /* LeftEdge, TopEdge */
  &rom_font,  /* ITextFont */
  "UNDO",     /* IText */
  NULL,       /* NextText */
};

struct Gadget undo_gadget=
{
  &copy_gadget, /* NextGadget */
  235,          /* LeftEdge */
  35,           /* TopEdge */
  37,           /* Width */
  11,           /* Height */
  GADGHCOMP,    /* Flags */
  RELVERIFY,    /* Activation */
  BOOLGADGET,   /* GadgetType */
  (APTR) &box4, /* GadgetRender */
  NULL,         /* SelectRender */
  &undo_text,   /* GadgetText */
  0,            /* MutualExclude */
  NULL,         /* SpecialInfo */
  0,            /* GadgetID */
  NULL          /* UserData */
};



/* BOOLEAN GADGET: OK */

struct IntuiText ok_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  3, 2,       /* LeftEdge, TopEdge */
  &rom_font,  /* ITextFont */
  "OK",       /* IText */
  NULL,       /* NextText */
};

struct Gadget ok_gadget=
{
  &undo_gadget, /* NextGadget */
  195,          /* LeftEdge */
  65,           /* TopEdge */
  21,           /* Width */
  11,           /* Height */
  GADGHCOMP,    /* Flags */
  RELVERIFY,    /* Activation */
  BOOLGADGET,   /* GadgetType */
  (APTR) &box2, /* GadgetRender */
  NULL,         /* SelectRender */
  &ok_text,     /* GadgetText */
  0,            /* MutualExclude */
  NULL,         /* SpecialInfo */
  0,            /* GadgetID */
  NULL          /* UserData */
};



/* BOOLEAN GADGET: CANCEL */

struct IntuiText cancel_text=
{
  1,          /* FrontPen */
  0,          /* BackPen */
  JAM1,       /* DrawMode */
  3, 2,       /* LeftEdge, TopEdge */
  &rom_font,  /* ITextFont */
  "CANCEL",   /* IText */
  NULL,       /* NextText */
};

struct Gadget cancel_gadget=
{
  &ok_gadget,   /* NextGadget */
  219,          /* LeftEdge */
  65,           /* TopEdge */
  53,           /* Width */
  11,           /* Height */
  GADGHCOMP,    /* Flags */
  RELVERIFY,    /* Activation */
  BOOLGADGET,   /* GadgetType */
  (APTR) &box6, /* GadgetRender */
  NULL,         /* SelectRender */
  &cancel_text, /* GadgetText */
  0,            /* MutualExclude */
  NULL,         /* SpecialInfo */
  0,            /* GadgetID */
  NULL          /* UserData */
};



/* Declare and initialize the ColourWindow data structure: */
struct NewWindow colour_window_data=
{
  0,             /* LeftEdge    x position, will be changed.             */
  0,             /* TopEdge     y position, will be cahnged.             */
  277,           /* Width       277 pixels wide.                         */
  80,            /* Height      80 lines high.                           */
  0,             /* DetailPen   Text should be drawn with col. reg. 0    */
  1,             /* BlockPen    Blocks should be drawn with col. reg. 1  */
  MOUSEMOVE|     /* IDCMPFlags  Report when: 1. The mouse moves          */
  MOUSEBUTTONS|  /*                          2. Buttons are pressed      */
  GADGETDOWN|    /*                          3. Gadgets down             */
  GADGETUP|      /*                          4. Gadgets up               */
  CLOSEWINDOW,   /*                          5. Window is closed.        */
  SMART_REFRESH| /* Flags       Intuition should refresh the window.     */
  WINDOWDRAG|    /*             Special gadgets: Window Drag             */
  WINDOWDEPTH|   /*                              Depth Gadgets           */
  WINDOWCLOSE|   /*                              Close Gadget            */
  ACTIVATE|      /*             The window should be activated.          */
  RMBTRAP,       /*             No menu operations.                      */
  &cancel_gadget,/* FirstGadget Pointer to the first gadget.             */
  NULL,          /* CheckMark   Use Intuition's default CheckMark.       */
  NULL,          /* Title       Title of the window, will be changed.    */
  NULL,          /* Screen      Pointer to the screen, will be changewd. */
  NULL,          /* BitMap      No Custom BitMap.                        */
  0,             /* MinWidth    We do not need to care about these since */
  0,             /* MinHeight   we have not supplied the window with a   */
  0,             /* MaxWidth    Sizing Gadget.                           */
  0,             /* MaxHeight                                            */
  WBENCHSCREEN   /* Type        Connected to the WBS, will be changed.   */
};



/* Declare the functions we are going to use: */
UBYTE ColourWindow();
void Box();
void PrintValues();
void IntToStr2();
void DrawScale();
void DrawColourBoxes();
void SelectColour();
void FixProp();
void Spread();



UBYTE ColourWindow( screen, title, x, y )
struct Screen *screen;
STRPTR title;
SHORT x, y;
{
  UBYTE count; /* How many colours: 2, 4, 8, 16 or 32. */
  UBYTE loop;  /* Used in loops.                       */

  UBYTE order = WORKING; /* WORKING, CANCEL, QUIT or OK.     */
  UBYTE mode = NOTHING;  /* NOTHING, COPY, EXCHANGE, SPREAD. */

  /* Intuition message:                                        */
  ULONG class;          /* IDCMP flag.                         */
  USHORT code;          /* Extra information. (SELECTDOWN)     */
  SHORT mousex, mousey; /* Mouse position.                     */
  APTR address;         /* Pointer to the broadcasting gadget. */

  /* Pointer to the message structure: */
  struct IntuiMessage *my_message;

  UBYTE red, green, blue; /* RGB colour values. */

  /* If the prop. gadgets need to be refreshed: */
  BOOL refresh_red = FALSE;
  BOOL refresh_green = FALSE;
  BOOL refresh_blue = FALSE;

  UBYTE rgb1[32][3]; /* Master backup of the colour values.        */
  UBYTE rgb2[32][3]; /* Backup of the colour values. Used by "UNDO". */

  UBYTE colour = 0;     /* Colour register we are working with.  */
  UBYTE old_colour = 0; /* Colour register we worked with.       */
  UWORD *colour_table;  /* Pointer to the screen's colour table. */

  struct Window *colour_window; /* Pointer to the ColourWindow. */



  /* Before we open the window we need to set the last values in the */
  /* colour_window_data structure:                                   */

  if( screen ) /* Check if we are going to use a CUSTOM screen. */
  {
    colour_window_data.Screen = screen;
    colour_window_data.Type = CUSTOMSCREEN;
  }
  
  colour_window_data.Title = title; /* Set the title of the window. */

  colour_window_data.LeftEdge = x; /* Set the x and y position of the */
  colour_window_data.TopEdge = y;  /* ColourWindow.                   */



  /* Open the window: */
  colour_window = (struct Window *) OpenWindow( &colour_window_data );
  
  if(colour_window == NULL)
    return( ERROR ); /* Could NOT open the Window! */



  /* If we do not have a pointer to a screen, we look in the Window */
	/* structure to find the pointer to the Workbench Screen:         */
	if( screen == NULL )
	  screen = colour_window->WScreen; 

  /* Find the colour table: */
  colour_table = (UWORD *) screen->ViewPort.ColorMap->ColorTable;



  /* Change the pointer: "normal" */
  SetPointer( colour_window, pointer_normal_data, 16, 16, -1, -1 );



  /* Update the prop. gadgets values: */
  FixProp( colour_table, colour, colour_window );

  /* Draw the colour boxes: */
  DrawColourBoxes( screen->BitMap.Depth, colour_window->RPort );
  /* Select a colour (colour register 0): */
  SelectColour( screen->BitMap.Depth, colour_window->RPort,
                colour, old_colour );

  /* Prepare the pencisl, and drawing modes: */
  SetAPen( colour_window->RPort, 1 );
  SetBPen( colour_window->RPort, 0 );
  SetDrMd( colour_window->RPort, JAM2 );

  Box( colour_window->RPort, 171, 11, 191, 21 ); /* Box for R's values. */
  Box( colour_window->RPort, 171, 23, 191, 33 ); /* Box for G's values. */
  Box( colour_window->RPort, 171, 35, 191, 45 ); /* Box for B's values. */
  Box( colour_window->RPort, 195, 11, 271, 21 ); /* Box for selected c. */

  /* Draw the scale under the prop. gadget: */
  DrawScale( colour_window->RPort );

  /* Initialize the RGB values, corresponding to the prop. gadgets: */
  red = red_info.HorizPot / (float)MAXPOT * 15 + 0.5;
  green = green_info.HorizPot / (float) MAXPOT * 15 + 0.5;
  blue = blue_info.HorizPot / (float) MAXPOT * 15 + 0.5;

  /* Print the RGB values: */
  PrintValues( colour_window->RPort, red, green, blue );

  /* Calculate how many colours, 2, 4, 8, 16 or 32: */
  count = 1 << screen->BitMap.Depth;

  /* Make a backup and a master back up of the screen's colour table: */
  for( loop = 0; loop < count; loop++ )
  {
    /* Master back up: (Used if the user selects the CANCEL or */
    /* CLOSEWINDOW gadgets)                                    */
    rgb1[ loop ][ 0 ] = (colour_table[ loop ] & 0xF00) >> 8;
    rgb1[ loop ][ 1 ] = (colour_table[ loop ] & 0x0F0) >> 4;
    rgb1[ loop ][ 2 ] = colour_table[ loop ] & 0x00F;

    /* Back up: (Used if the user selects the UNDO gadget. Only the */
    /* last change will be corrected.)                              */
    rgb2[ loop ][ 0 ] = rgb1[ loop ][ 0 ];
    rgb2[ loop ][ 1 ] = rgb1[ loop ][ 1 ];
    rgb2[ loop ][ 2 ] = rgb1[ loop ][ 2 ];
  }



  /* Stay in the while loop until the user has selected the CLOSEWINDOW, */
  /* CANCEL or OK gadget:                                                */
  while( order == WORKING )
  {
    /* Wait until we have recieved a message: */
    /* As long as the user does not work with the Colour Window, the   */
    /* CPU can work undisturbed with other tasks. I wish more programs */
    /* used this function...                                           */
    Wait( 1 << colour_window->UserPort->mp_SigBit );

    /* We have now recieved one or more messages. */

    /* Since we may recieve several messages we stay in the while loop  */
    /* and collect, save, reply and execute the messages until there is */
    /* a pause:                                                         */
    while( my_message = (struct IntuiMessage *)
           GetMsg( colour_window->UserPort) )
    {
      /* Save some important values:                              */
      class = my_message->Class;      /* IDCMP flag.              */
      code = my_message->Code;        /* Extra information.       */
      mousex = my_message->MouseX;    /* X position of the mouse. */
      mousey = my_message->MouseY;    /* Y position of the mouse. */
      address = my_message->IAddress; /* Pointer to the gadget.   */

      /* After we have read the message we reply as fast as possible: */
      /* REMEMBER! Do never try to read a message after you have      */
      /* replied! Some other process has maybe changed it.            */
      ReplyMsg( my_message );

      /* Check which IDCMP flag was sent: */
      switch( class )
      {
        case MOUSEBUTTONS:
          /* The user clicked inside the ColourWindow. */
          
          /* Change the pointer: "normal" */
          SetPointer( colour_window, pointer_normal_data,
                      16, 16, -1, -1 );

          /* Check if the left mouse button was pressed: */
          if( code == SELECTDOWN )
          {
            old_colour = colour;
            colour = ReadPixel( colour_window->RPort, mousex, mousey );
            
            if( colour != old_colour )
            {
              /* A new colour was selected. */
              
              /* Make a backup of the colour table: */
              for( loop = 0; loop < count; loop++ )
              {
                rgb2[ loop ][ 0 ] = (colour_table[ loop ] & 0xF00) >> 8;
                rgb2[ loop ][ 1 ] = (colour_table[ loop ] & 0x0F0) >> 4;
                rgb2[ loop ][ 2 ] = colour_table[ loop ] & 0x00F;
              }
         
              switch( mode )
              {
                case COPY:
                  SetRGB4( &screen->ViewPort, colour, red, green, blue );
                  break;
                  
                case EXCHANGE:
                  SetRGB4( &screen->ViewPort, old_colour,
                         (colour_table[ colour ] & 0xF00) >> 8,
                         (colour_table[ colour ] & 0x0F0) >> 4,
                         colour_table[ colour ] & 0x00F );
                  SetRGB4( &screen->ViewPort, colour, red, green, blue );
                  break;
              
                case SPREAD:
                  Spread( colour, old_colour, colour_table,
                          &screen->ViewPort );
                  break;
              }         
              
              /* Select the new colour: */
              SelectColour( screen->BitMap.Depth,
                            colour_window->RPort,
                            colour, old_colour );

              /* Show the new colour in the colour box: */
              SetAPen( colour_window->RPort, colour );
              RectFill( colour_window->RPort, 196, 12, 270, 20 );
              SetAPen( colour_window->RPort, 1 );

              /* Update the prop. gadgets: */
              FixProp( colour_table, colour, colour_window );
            }
            /* Change mode to NOTHING: */
            mode = NOTHING;
          }
          break;
        
        case GADGETDOWN:
          /* One of the prop. gadgets have been selected. */
          /* Change mode to NOTHING: */
          mode = NOTHING;
          /* Change the pointer: "two arrows" */
          SetPointer( colour_window, pointer_two_data,
                      16, 16, -8, -5 );
          break;
        
        case GADGETUP:
          /* The user has released a gadget. */
          /* Change mode to NOTHING: */
          mode = NOTHING;
          SetPointer( colour_window, pointer_normal_data,
          /* Change the pointer: "normal" */
                    16, 16, -1, -1 );
          
          if( address == (APTR) &red_gadget )
            refresh_red = TRUE;
          
          if( address == (APTR) &green_gadget )
            refresh_green = TRUE;
          
          if( address == (APTR) &blue_gadget )
            refresh_blue = TRUE;
          
          if( address == (APTR) &copy_gadget )
          {
            /* Change the pointer: "TO" */
            SetPointer( colour_window, pointer_to_data,
                        16, 16, -1, -1 );
            
            /* Change mode to COPY: */
            mode = COPY;
          }
          
          if( address == (APTR) &ex_gadget )
          {
            /* Change the pointer: "TO" */
            SetPointer( colour_window, pointer_to_data,
                        16, 16, -1, -1 );
            
            /* Change mode to COPY: */
            mode = EXCHANGE;
          }
          
          if( address == (APTR) &spread_gadget )
          {
            /* Change the pointer: "TO" */
            SetPointer( colour_window, pointer_to_data,
                        16, 16, -1, -1 );
            
            /* Change mode to SPREAD: */
            mode = SPREAD;
          }
          
          if( address == (APTR) &undo_gadget )
          {
            /* Restore the colours. Use the normal backup: */
            for( loop = 0; loop < count; loop++ )
              SetRGB4( &screen->ViewPort, loop, rgb2[ loop ][ 0 ],
                       rgb2[ loop ][ 1 ], rgb2[ loop ][ 2 ] );

            /* Update the prop. gadgets: */
            FixProp( colour_table, colour, colour_window );
          }
          
          if( address == (APTR) &ok_gadget )
            order = OK;
          
          if( address == (APTR) &cancel_gadget )
            order = CANCEL;
          
          break;

        case CLOSEWINDOW:
          /* The user has selected the Close window gadget. */
          order = QUIT;
          break;
      }
    }
    
    /* Calculate the new RGB values with the prop. gadg. values: */
    red = red_info.HorizPot / (float)MAXPOT * 15 + 0.5;
    green = green_info.HorizPot / (float) MAXPOT * 15 + 0.5;
    blue = blue_info.HorizPot / (float) MAXPOT * 15 + 0.5;

    /* Change the colour: */
    SetRGB4( &screen->ViewPort, colour, red, green, blue );
    
    if( refresh_red )
    {
      ModifyProp( &red_gadget, colour_window, NULL, red_info.Flags,
                  (USHORT) (red / (float) 15 * MAXPOT), 0,
                  red_info.HorizBody, 0 );
      refresh_red = FALSE;
    }
    
    if( refresh_green )
    {
      ModifyProp( &green_gadget, colour_window, NULL, green_info.Flags,
                  (USHORT) (green / (float) 15 * MAXPOT), 0,
                  green_info.HorizBody, 0 );
      refresh_green = FALSE;
    }
    
    if( refresh_blue )
    {
      ModifyProp( &blue_gadget, colour_window, NULL, blue_info.Flags,
                  (USHORT) (blue / (float) 15 * MAXPOT), 0,
                  blue_info.HorizBody, 0 );
      refresh_blue = FALSE;
    }
    
    /* Print the new values in the RGB value boxes: */
    PrintValues( colour_window->RPort, red, green, blue );
  }



  /* If the user has selected the CANCEL or CLOSEWINDOW gadget we will */
  /* Restore the colours by using the master backup:                   */
  if( order == QUIT || order == CANCEL )
    for( loop = 0; loop < count; loop++ )
       SetRGB4( &screen->ViewPort, loop, rgb1[ loop ][ 0 ],
                rgb1[ loop ][ 1 ], rgb1[ loop ][ 2 ] );



  /* Close the ColourWindow and return the control to the calling prog: */
  CloseWindow( colour_window );
  return( order );
}



/* This function will draw a box with help of four coordinates: */ 
void Box( rp, x1, y1, x2, y2 )
struct RastPort *rp;
UWORD x1, y1, x2, y2;
{
  Move( rp, x1, y1 );
  Draw( rp, x2, y1 );
  Draw( rp, x2, y2 );
  Draw( rp, x1, y2 );
  Draw( rp, x1, y1 );
}



/* This function will print the RGB values: */
void PrintValues( rp, red, green, blue )
struct RastPort *rp;
UBYTE red, green, blue;
{
  char colour_string[7];

  /* RED: */
  IntToStr2( colour_string, red );
  Move( rp, 174, 19 );
  Text( rp, colour_string, 2 );

  /* GREEN: */
  IntToStr2( colour_string, green );
  Move( rp, 174, 31 );
  Text( rp, colour_string, 2 );

  /* BLUE: */
  IntToStr2( colour_string, blue );
  Move( rp, 174, 43 );
  Text( rp, colour_string, 2 );
}



/* This function will shange a two dig. integer into a string: */
void IntToStr2( string, number )
STRPTR string;
int number;
{
  stci_d( string, number );
  if( number < 10 )
  {
    string[1] = string[0];
    string[0] = ' ';
  }
}



/* This function will draw the scale under the prop. gadgets: */
void DrawScale( rp )
struct RastPort *rp;
{
  int loop;
  
  for( loop=0; loop < 17; loop++ )
  {
    Move( rp, 19 + loop * 9, 48 );
    Draw( rp, 19 + loop * 9, 50 + (loop % 2 ? 0 : 2) );
  }
}



/* This function will draw the colour boxes at the bottom of the window: */
void DrawColourBoxes( depth, rp )
UBYTE depth;
struct RastPort *rp;
{
  int loop1, loop2;
  
  switch( depth )
  {
    case 5: for( loop1 = 0; loop1 < 2; loop1++ )
              for( loop2 = 0; loop2 < 16; loop2++ )
              {
                SetAPen( rp, loop1*16+loop2 );
                RectFill( rp, 6+11*loop2, 57+10*loop1,
                              15+11*loop2, 65+10*loop1 );
              }
              break;
              
    case 4: for( loop1 = 0; loop1 < 16; loop1++ )
            {
              SetAPen( rp, loop1 );
              RectFill( rp, 6+11*loop1, 57,
                            15+11*loop1, 75 );
            }
            break;
            
    case 3: for( loop1 = 0; loop1 < 8; loop1++ )
            {
              SetAPen( rp, loop1 );
              RectFill( rp, 6+22*loop1, 57,
                            26+22*loop1, 75 );
            }
            break;
            
    case 2: for( loop1 = 0; loop1 < 4; loop1++ )
            {
              SetAPen( rp, loop1 );
              RectFill( rp, 6+44*loop1, 57,
                            48+44*loop1, 75 );
            }
            break;
            
    case 1: for( loop1 = 0; loop1 < 2; loop1++ )
            {
              SetAPen( rp, loop1 );
              RectFill( rp, 6+88*loop1, 57,
                            92+88*loop1, 75 );
            }
  }
}



/* This function will draw a box around the selected colour: */
void SelectColour( depth, rp, colour, old_colour )
UBYTE depth;
struct RastPort *rp;
UBYTE colour, old_colour;
{
  switch( depth )
  {
    case 5: SetAPen( rp, 0 );
            if( old_colour < 16 )
              Box( rp, 5+11*old_colour, 56, 16+11*old_colour, 66 );
            else
              Box( rp, 5+11*(old_colour-16), 66,
                       16+11*(old_colour-16), 76 );
            
            SetAPen( rp, 1 );
            if( colour < 16 )
              Box( rp, 5+11*colour, 56, 16+11*colour, 66 );
            else
              Box( rp, 5+11*(colour-16), 66,
                       16+11*(colour-16), 76 );
            break;

    case 4: SetAPen( rp, 0 );
            Box( rp, 5+11*old_colour, 56, 16+11*old_colour, 76 );
            SetAPen( rp, 1 );
            Box( rp, 5+11*colour, 56, 16+11*colour, 76 );
            break;

    case 3: SetAPen( rp, 0 );
            Box( rp, 5+22*old_colour, 56, 27+22*old_colour, 76 );
            SetAPen( rp, 1 );
            Box( rp, 5+22*colour, 56, 27+22*colour, 76 );
            break;

    case 2: SetAPen( rp, 0 );
            Box( rp, 5+44*old_colour, 56, 49+44*old_colour, 76 );
            SetAPen( rp, 1 );
            Box( rp, 5+44*colour, 56, 49+44*colour, 76 );
            break;

    case 1: SetAPen( rp, 0 );
            Box( rp, 5+88*old_colour, 56, 93+88*old_colour, 76 );
            SetAPen( rp, 1 );
            Box( rp, 5+88*colour, 56, 93+88*colour, 76 );
            break;
  }
}



/* This function will update the prop. gadgets: */
void FixProp( colour_table, colour, window )
UWORD *colour_table;
UBYTE colour;
struct Window *window;
{
  UBYTE red, green, blue;

  red = (colour_table[ colour ] & 0xF00) >> 8;
  green = (colour_table[ colour ] & 0x0F0) >> 4;
  blue = colour_table[ colour ] & 0x00F;

  ModifyProp( &red_gadget, window, NULL,
              red_info.Flags,
              (USHORT) (red / (float) 15 * MAXPOT), 0,
              red_info.HorizBody, 0 );
  ModifyProp( &green_gadget, window, NULL,
              green_info.Flags,
              (USHORT) (green / (float) 15 * MAXPOT), 0,
              green_info.HorizBody, 0 );
  ModifyProp( &blue_gadget, window, NULL,
              blue_info.Flags,
              (USHORT) (blue / (float) 15 * MAXPOT), 0,
              blue_info.HorizBody, 0 );
}



/* This function will calculate the colour values between the new and */
/* the old colour reg:                                                */
void Spread( col, old_col, colour_table, vp )
UBYTE col, old_col;
UWORD *colour_table;
struct ViewPort *vp;
{
  UBYTE c1, c2, dif;
  UBYTE r1, g1, b1;
  UBYTE r2, g2, b2;
  float dr, dg, db;
  float fr, fg, fb;
  UBYTE loop;


  c1 = col > old_col ? old_col: col; /* Lowest reg.  */
  c2 = col > old_col ? col: old_col; /* Highest reg. */
  dif = c2 - c1;                     /* Difference.  */
  
  /* Get the RGB values: */
  r1 = (colour_table[ c1 ] & 0xF00) >> 8;
  g1 = (colour_table[ c1 ] & 0x0F0) >> 4;
  b1 = colour_table[ c1 ] & 0x00F;
  
  /* Get the RGB values: */
  r2 = (colour_table[ c2 ] & 0xF00) >> 8;
  g2 = (colour_table[ c2 ] & 0x0F0) >> 4;
  b2 = colour_table[ c2 ] & 0x00F;
  
  /* Calculate the difference between the RGB values: */
  dr = (r2 - r1) / (float) dif;
  dg = (g2 - g1) / (float) dif;
  db = (b2 - b1) / (float) dif;
  
  /* Initialize the float RGB values: */
  fr = r1;
  fg = g1;
  fb = b1;

  for( loop = c1+1; loop < c2; loop++ )
  {
    /* Add the difference: */
    fr += dr;
    fg += dg;
    fb += db;

    /* Round off to the nearest whole number: */
    r1 = fr + 0.5;
    g1 = fg + 0.5;
    b1 = fb + 0.5;
    
    /* Change the colour: */
    SetRGB4( vp, loop, r1, g1, b1 );
  }
}