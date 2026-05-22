/* Name: Example.c


  FFFFF III L     EEEEE     W     W III N   N DDD    OOO  W     W
  F      I  L     E         W     W  I  NN  N D  D  O   O W     W
  FFFF   I  L     EEE       W  W  W  I  N N N D   D O   O W  W  W
  F      I  L     E          W W W   I  N  NN D  D  O   O  W W W
  F     III LLLLL EEEEE       W W   III N   N DDD    OOO    W W

  
              EEEEE X   X  AAA  M   M PPPP  L     EEEEE
              E      X X  A   A MM MM P   P L     E
              EEEE    X   AAAAA M M M PPPP  L     EEEE
              E      X X  A   A M   M P     L     E
              EEEEE X   X A   A M   M P     LLLLL EEEEE


  
  FILE WINDOW EXAMPLE   VERSION 1.20   90-01-30

  Yet another program dedicated to Sioe-Lin Kwik.


  FILE WINDOW was created by Anders Bjerin, and is distributed as
  public domain with NO RIGHTS RESERVED. That means that you can do
  what ever you want with the program.
  
  You may use FILE WINDOW in your own programs, commercial or not, and 
  do not even need to mention that you have used it. You may alter the
  source code to fit your needs, and you may spread it to anyone.



  This is an example on how to call FileWindow(). For more information 
  please read the file "FileWindow.c".




  ENJOY YOUR AMIGA, AND MAKE EVERYONE ELSE ENJOY IT TOO!

  Anders Bjerin  

*/





/* ********************************************************************* */
/* * FILE WINDOW   EXAMPLE    Version 1.20    Anders Bjerin   90-01-30 * */
/* ********************************************************************* */


#include <intuition/intuition.h>
#include <string.h>

/* Remember to include this file if you use FileWindow(): */
#include "FileWindow.h"



/* Declare what FileWindow will return: */
extern USHORT FileWindow();



/* Declare the functions: */
void _main();
USHORT press_continue();
void quit();



struct IntuitionBase *IntuitionBase;
struct IntuiMessage *your_message;
struct Window *your_window;


/* 80-Characters ROM font: */
struct TextAttr your_font=
{
  "topaz.font", /* Font Name */
  TOPAZ_EIGHTY, /* Font Height */
  FS_NORMAL,    /* Style */
  FPF_ROMFONT   /* Preferences */
};





/* ********************************************************************* */
/* * Information for the boolean gadget "CONTINUE"                     * */
/* ********************************************************************* */


/* Values for a 8-letter box: */
SHORT points8[]=
{
   0,  0,
  76,  0,
  76, 14,
   0, 14,
   0,  0
};


/* A border for a 8-letter box: */
struct Border border8=
{
  0, 0,         /* LeftEdge, TopEdge */
  1, 2, JAM1,   /* FrontPen, BackPen, DrawMode */
  5,            /* Count */
  points8,      /* *XY */
  NULL          /* *NextBorder */
};


struct IntuiText text_continue=
{
  3, 0,       /* FrontPen, BackPen */
  JAM1,       /* DrawMode */
  7,4,        /* LeftEdge, TopEdge */
  &your_font, /* *ITextFont, (Topaz, 80) */
  "CONTINUE", /* *IText */
  NULL        /* *NextText */
};


struct Gadget gadget_continue=
{
  NULL,            /* *NextGadget */
  16, 177, 78, 15, /* LeftEdge, TopEdge, Width, Height */
  GADGHNONE,       /* Flags */
  GADGIMMEDIATE,   /* Activation */
  BOOLGADGET,      /* GadgetType */
  (APTR) &border8, /* GadgetRender */
  NULL,            /* SelectRender */
  &text_continue,  /* *GadgetText */
  NULL,            /* MutualExclude */
  NULL,            /* SpecialInfo */
  NULL,            /* GadgetID */
  NULL             /* UserData */
};





/* ********************************************************************* */
/* * YOUR WINDOW                                                       * */
/* ********************************************************************* */


struct NewWindow your_new_window=
{
  0,0,              /* LeftEdge, TopEdge */
  640, 200,         /* Width, Height */
  0,1,              /* DetailPen, BlockPen */

  CLOSEWINDOW|      /* IDCMPFlags */
  GADGETDOWN,

  ACTIVATE|         /* Flags */
  WINDOWDEPTH|
  WINDOWDRAG|
  WINDOWCLOSE|
  SMART_REFRESH,

  &gadget_continue,        /* *FirstGadget */
  NULL,                    /* *CheckMark */
  (STRPTR) "YOUR PROGRAM", /* *Title */
  NULL,                    /* *Screen */
  NULL,                    /* *BitMap */
  0,0,                     /* MinWidth, MinHeight */
  0,0,                     /* MaxWidth, MaxHeight */
  WBENCHSCREEN             /* Type */
};





/* ********************************************************************* */
/* * TEXT:                                                             * */
/* ********************************************************************* */


struct IntuiText int_text=
{
  1, 0,       /* FrontPen, BackPen */
  JAM2,       /* DrawMode */
  16, 9,      /* LewftEdge, TopEdge */
  &your_font, /* *ITextFont */
  NULL,       /* *IText */
  NULL        /* *NextText */
};


char *text_string[19]=
{
  "                                                                     ",
  "FILE WINDOW EXAMPLE   VERSION 1.20   90-01-30",
  "",
  "FILE WINDOW was created by Anders Bjerin, and is distributed as",
  "public domain with NO RIGHTS RESERVED. That means that you can do",
  "what ever you want with the program.",
  "",
  "You may use FILE WINDOW in your own programs, commercial or not, and",
  "do not even need to mention that you have used it. You may alter the",
  "source code to fit your needs, and you may spread it to anyone.",
  "",
  "If you have any questions, ideas, programs (PD or your own) etc etc,",
  "or just want to say hello, PLEASE WRITE TO ME:",
  "",
  "AMIGA C CLUB (ACC)",
  "Anders Bjerin",
  "Tulevagen 22",
  "181 41  LIDINGO",
  "SWEDEN"
};





void _main()
{
  USHORT operation;
  UBYTE file[TOTAL_LENGTH];
  int temp;



  /* Open IntuitionBase: */
  if( (IntuitionBase=(struct IntuitionBase *)
      OpenLibrary("intuition.library", 33))==NULL )
  {
    /* Could NOT open IntuitionBase! */
    exit();
  }



  /* Open your window: */
  if( (your_window = (struct Window *) 
    OpenWindow(&your_new_window)) == NULL )
  {
    /* Could NOT open the window! */

    /* Close IntuitionBase: */
    CloseLibrary((struct Library *) IntuitionBase);

    exit();
  }



  /* Copy some text into file. This is optional, but very handy if you   */
  /* want the FileWindow() to start to look in a specific directory, or  */
  /* device:                                                             */
  /* (If there is a file name in the string it will automatically appear */
  /* in the "File:" gadget, and the path in the "Drawer:" gadget.)       */
  strcpy(file, "df0:");



  /* Fill your_window with text: */
  for(temp=1; temp < 19; temp++)
  {
    int_text.IText=text_string[temp];
    PrintIText(your_window->RPort, &int_text, 0, temp*8);
  }
    


  /* Wait: */
  press_continue();



  /* Clicking on the CLOSE WINDOW gadget to leave the while loop: */
  while(TRUE)
  {
    /* Clear your_window: */
    int_text.IText=text_string[0];
    for(temp=1; temp < 23; temp++)
      PrintIText(your_window->RPort, &int_text, 0, temp*8);



    /* FILE WINDOW!!! */
    operation=FileWindow
              (
                "FILE WINDOW  V1.20", /* Title            */
                NULL,                 /* Extension (none) */
                0, 0,                 /* x, y position    */
                NULL,                 /* Screen    (none) */
                file                  /* file with path.  */
              );




    int_text.IText="File name plus path:";
    int_text.FrontPen=1; /* Normal colour. */
    PrintIText(your_window->RPort, &int_text, 0, 8 );




    /* Write the filename and the path: */
    int_text.IText=file; /* file name and path. */
    int_text.FrontPen=3; /* Highlighted. */
    PrintIText(your_window->RPort, &int_text, 16, 16 );
  
  

    int_text.IText="Operation:";
    int_text.FrontPen=1; /* Normal colour. */
    PrintIText(your_window->RPort, &int_text, 0, 24 );
      


    switch(operation)
    {
      case LOAD:   int_text.IText="LOAD"; break;
      case SAVE:   int_text.IText="SAVE"; break;
      case CANCEL: int_text.IText="CANCEL"; break;
      case QUIT:   int_text.IText="QUIT"; break;
      case PANIC:  int_text.IText="PANIC"; break;
      default:     int_text.IText="Something went terrible WRONG!";
    }
    int_text.FrontPen=3; /* Highlighted. */
    PrintIText(your_window->RPort, &int_text, 16, 32 );
  


    /* Draw the gadget again: */
    RefreshGadgets(&gadget_continue, your_window, NULL);



    /* Wait: */
    press_continue();
  }
}



/* Clean up before we leave: */
void quit()
{
  /* Close the window: */
  if(your_window)
    CloseWindow(your_window);



  /* Close IntuitionBase: */
  if(IntuitionBase)
    CloseLibrary((struct Library *) IntuitionBase);



  exit();
}



/* This function simply waits for someone to click on the CONTINUE */
/* or CLOSEWINDOW gadget: */
USHORT press_continue()
{
  ULONG class;
  


  while(TRUE)
  {
    Wait(1 << your_window->UserPort->mp_SigBit);
  
    if(your_message = (struct IntuiMessage *)
      GetMsg(your_window->UserPort))
    {
      /* Collect some interesting values: */
      class = your_message->Class;

      /* We have now saved some important values, and can now reply: */
      /* (Do NEVER try to get some values after you have replied!) */
      ReplyMsg((struct Message *)your_message);



      /* What has actually happened? */
      switch(class)
      {
        case CLOSEWINDOW:
               quit();    /* CLOSEWINDOW */
               
        case GADGETDOWN:
               return(1); /* CONTINUE */
      
      }
    }
  }
}
