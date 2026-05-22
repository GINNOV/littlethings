/* Name: FileWindow.c


  FFFFF III L     EEEEE     W     W III N   N DDD    OOO  W     W
  F      I  L     E         W     W  I  NN  N D  D  O   O W     W
  FFFF   I  L     EEE       W  W  W  I  N N N D   D O   O W  W  W
  F      I  L     E          W W W   I  N  NN D  D  O   O  W W W
  F     III LLLLL EEEEE       W W   III N   N DDD    OOO    W W


  
  FILE WINDOW   VERSION 1.20   90-01-30

  Yet another program dedicated to Sioe-Lin Kwik.
  

  FILE WINDOW was created by Anders Bjerin, and is distributed as
  public domain with NO RIGHTS RESERVED. That means that you can do
  what ever you want with the program.
  
  You may use FILE WINDOW in your own programs, commercial or not, and 
  do not even need to mention that you have used it. You may alter the
  source code to fit your needs, and you may spread it to anyone.
  
  
  
  
  The reason why I created FILE WINDOW was that I never more wanted to
  see that old stupid "Please type in filename:" prompt. It is a disgrace
  for any program to use it, and VERY annoying for the user.
  
  REMEMBER, one of the first things the user will see of your program is
  the file requester. If you want your program to make a good impression,
  and look solid, I would recommend you to use a good file requester.
  
  FILE WINDOW is written to be as easy as possible to use, and is fully
  amigaized. It is similar to other good file requesters, but has several
  advantages:
  
   1. FILE WINDOW dynamically allocates memory for each file. That means
      that there is no memory wasted as it would have been if you had
      statically allocated the filenames in arrays. It also means that the 
      memory is the only limitation on how many files the program can
      display.

   2. While FILE WINDOW is reading the directories, it is still obeying
      your commands. You may change directory, type in the file name
      yourself etc etc while the program still is working. All of us know
      how irritating it is to see the little Zzz pointer in a program
      while the disk is examined. This is especially annoying when you know
      the filename, and only want to type it in.

   3. FILE WINDOW was written for the Amiga. It uses boolean, string and
      proportional gadgets, and is using them as recommended. For example,
      the proportional gadget's knob changes size corresponding to how
      many files/directories there are. (It is strange that there are
      several file requesters using a static small knob instead. That
      makes it much harder for the user to see how many files there are in
      the directory.)

   4. There are three boolean gadgets which allows the user to quickly 
      select df0:, df1: and dh0:.

      5. FILE WINDOW has a boolean gadget "<" which steps back one directory
      each time it is pressed. (Same as "/ Parent dir")

   6. You can specify a file-extension, and only the files with that
      extension will be displayed. (Directories are always showed.)
      The user can also change the extension since it is a string gadget.
      (If there are any characters in the string gadget, the text "Ext:"
      will be highlighted to tell the user that EXTENSION MODE is on.)

   7. The files/directories are automatically sorted alphabetically while
      they are taken from the disk. Directories first, highlighted with the
      ending (Dir), and then the files.

   8. FILE WINDOW deallocates all memory allocated, and is fool proof. If
      something goes wrong (not enough memory, wrong directory name etc),
      the program will open a requester and tell the user what the 
      problem is.

   9. The source code is distributed with the program so you can alter it
      to fit your needs.

  10. FILE WINDOW is not as a normal file requester, since it uses a
      (surprise, surprise) window instead of a requester to display the
      files on. That means that the calling program does not need to
      have a window itself, to be able to use FILE WINDOW. (A normal
      requester always needs a pointer to a window.)

  11. There are no Image structures in the code, so FILE WINDOW does not
      need to be in the CHIP memory.

  12. The width of the window is 320, which means that any program can use
      it, both in High as well as Low resolution.

  13. When FILE WINDOW has examined all files in the directory, the
      program is put to sleep. That will speed up other programs, and 
      will not use unnecessary processing time.

  14. Fast updating of the display.

  15. FILE WINDOW was created by Anders Bjerin.



  FILE WINDOW is very easy to install in your program, and I have even
  done an example on how to use it. The source code is full of comments
  to make it easier for you to change something in the program, but
  if you would have any problems, feel free to contact me. I can even
  make small changes for you personally if you have problems with
  understanding the code, and it will not cost you anything.

  If you have any questions, ideas, programs (PD or your own) etc etc,
  or just want to say hello, PLEASE WRITE TO ME:

  Anders Bjerin
  39 Sydney Road
  Richmond
  Surrey  TW9 1UB
  ENGLAND

  After Feb 1990:
  Tulevagen 22
  181 41  LIDINGO
  SWEDEN



  FILE WINDOW will look something like this when you run it:

  -----------------------------------
  |#| TITLE                   |==|==|
  |---------------------------------|
  | df0: | df1: | dh0: | Ext:XXXXXX |
  |---------------------------------|
  | Drawer: XXXXXXXXXXXXXXXXXXXX |<<|
  |---------------------------------|
  |                              |XX|
  |        FILE DISPLAY          |XX|
  |                              |XX|
  |                              |XX|
  |                              |XX|
  |                              |OO|
  |                              |OO|
  |                              |OO|
  |---------------------------------|
  | File: XXXXXXXXXXXXXXXXXXXXXXXXX |
  |---------------------------------|
  | LOAD | SAVE | DELETE | CANCEL | |
  -----------------------------------








  FFFFF III L     EEEEE     W     W III N   N DDD    OOO  W     W
  F      I  L     E         W     W  I  NN  N D  D  O   O W     W
  FFFF   I  L     EEE       W  W  W  I  N N N D   D O   O W  W  W
  F      I  L     E          W W W   I  N  NN D  D  O   O  W W W
  F     III LLLLL EEEEE       W W   III N   N DDD    OOO    W W

  III N   N FFFFF  OOO  RRRR  M   M  AAA  TTTTTTT III  OOO  N   N
   I  NN  N F     O   O R   R MM MM A   A    T     I  O   O NN  N
   I  N N N FFF   O   O RRRR  M M M AAAAA    T     I  O   O N N N
   I  N  NN F     O   O R  R  M   M A   A    T     I  O   O N  NN
  III N   N F      OOO  R   R M   M A   A    T    III  OOO  N   N




  HOW TO USE IT:


  operation=FileWindow( title, extension, x, y, screen, file );
       
  
  operation: a variable which will contain the "flags" FILE WINDOW
             returned.
  title:     string containing the name of the FILE WINDOW.
  extension: string to be used as a file extension.
  x:         x position of the FILE WINDOW.
  y:         y position of the FILE WINDOW.
  screen:    pointer to a screen if there exist one.
  file:      a string which will contain the file name together with
             the entire path. (For example: "df0:letters/payments.doc"



  Title is a string which will appear on the drag gadget. Write NULL if
  you do not want any string there.

  Extension is a 7 character long string. 6 letters and the NULL ('\0')
  sign. If you give FILE WINDOW a string, the program will only display
  the files which endings match with your string. (Directories will always
  be displayed.) If you do not want to use a file extension you simply
  write NULL.
  
  The width of the window is 320 pixels which means that if you are using
  a low resolution display (320 pixels) x should be initialized to be 0.
  If you are using a high resolution display (640 pixels) x can be
  between 0 and 320.

  On a NTSC screen (200 lines) y can be between 0 and 37. On a PAL screen
  (256 lines) between 0 and 93.
  
  If your program is using a CUSTOM SCREEN you should give FILE WINDOW a
  pointer to your screen. Otherwise, if you are using a WBENCH SCREEN you
  simply write NULL.
  
  Name is a string which can already contain a file name with path if
  you want. If the string is empty, FILE WINDOW will start to display the
  current directory. When the user has selected the file to LOAD or SAVE it
  is here you should look for the file name with path.
  


  For examples:
    
    1. operation=FileWindow( NULL, NULL, 0, 0, NULL, file);

       operation has been declared as: USHORT operation;
       file has been declared as     : UBYTE file[TOTAL_LENGTH];
    

    2. operation=FileWindow(title, ext, x, y, my_screen, file);
       
       operation has been declared as: USHORT operation;
       title           -"-           : UBYTE title[ANY_LENGTH];
       ext             -"-           : UBYTE ext[7];
       x, y            -"-           : SHORT x, y;
       my_screen       -"-           : struct Screen *my_screen;
       file            -"-           : UBYTE file[TOTAL_LENGTH];


  Remember to "include" the file "FileWindow.h"!
  ex: #include "FileWindow.h"


  Program:                 FileWindow
  Version:                 1.20
  Programmer:              Anders Bjerin
  Language:                C (100%)
  Compiler:                Lattice C Compiler, V5.02
  Linker:                  Blink, V5.02
  AmigaDOS:                V1.2 and V1.3
  Ref. nr:                 3A-146-1
 
  Amiga is a registered trademark of Commodore-Amiga, Inc.
  AmigaDOS is a registered trademark of Commodore-Amiga, Inc.
  Lattice is a registered trademark of Lattice, Inc.


  For more information see the file "Example.c".

  ENJOY YOUR AMIGA, AND MAKE EVERYONE ELSE ENJOY IT TOO!

  Anders Bjerin
  
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/ports.h>
#include <exec/interrupts.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <intuition/intuition.h>
#include <string.h>

#include "FileWindow.h"



/* Declare the functions we are going to use: */
USHORT FileWindow();
STRPTR right_pos();
APTR save_file_info();
BOOL file_comp();
BOOL directory();
BOOL last_check();
BOOL new_drawer();
BOOL pick_file();
BOOL request_ask();
void put_in();
void deallocate_file_info();
void change_device();
void parent();
void request_ok();
void display_list();
void connect_dir_file();
void adjust_string_gadgets();
void delete_file_dir();



extern struct IntuitionBase *IntuitionBase;

struct Window *file_window;
struct IntuiMessage *my_gadget_message;



/* We will allocate memory, using this structure, for every file/    */
/* directory we find. They will be linked to each otherer, in such a */
/* way that all directories will come first (sorted alphabetically), */
/* and after them will the files come (also sorted alphabetically).  */
struct file_info
{
  BYTE name[28];          /* Name of the file/directory, 27 characters. */
  BOOL directory;         /* If it is a directory.                      */
  struct file_info *next; /* Pointer to the next file_info structure.   */
};


struct FileInfoBlock *file_info;
struct FileLock *lock, *Lock();


BOOL file_lock;  /* Have we locked a file?       */
BOOL more_files; /* More files in the directory? */
BOOL first_file; /* First file?                  */


struct file_info *first_pointer; /* Pointing to the first structure. */


/* The program will use a ROM-font, 80 characters wide (40 LOWRES). */
/* This is to make sure that all the text will fit in nicely in the */
/* window, even if the calling program is using another font.       */
struct TextAttr my_font=
{
  "topaz.font", /* Font Name */
  TOPAZ_EIGHTY, /* Font Height */
  FS_NORMAL,    /* Style */
  FPF_ROMFONT   /* Preferences */
};





/* ********************************************************************* */
/* * IntuiText structures for the requesters                           * */
/* ********************************************************************* */


struct IntuiText text_request=
{
  0, 2,                        /* FrontPen, BackPen */
  JAM1,                        /* DrawMode */
  15, 5,                       /* LewftEdge, TopEdge */
  &my_font,                    /* *ITextFont */
  NULL,                        /* *IText */
  NULL                         /* *NextText */
};


struct IntuiText ok_request=
{
  0, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  6, 3,     /* LewftEdge, TopEdge */
  &my_font, /* *ITextFont */
  "OK",     /* *IText */
  NULL      /* *NextText */
};


struct IntuiText option1_request=
{
  0, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  6, 3,     /* LewftEdge, TopEdge */
  &my_font, /* *ITextFont */
  NULL,     /* *IText */
  NULL      /* *NextText */
};


struct IntuiText option2_request=
{
  0, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  6, 3,     /* LewftEdge, TopEdge */
  &my_font, /* *ITextFont */
  NULL,     /* *IText */
  NULL      /* *NextText */
};






/* Values for a 4-letter box: */
SHORT points4[]=
{
   0,  0,
  44,  0,
  44, 14,
   0, 14,
   0,  0
};


/* Values for a 6-letter box: */
SHORT points6[]=
{
   0,  0,
  60,  0,
  60, 14,
   0, 14,
   0,  0
};


/* A border for a 4-letter box: */
struct Border border_text4=
{
  0, 0,         /* LeftEdge, TopEdge */
  1, 2, JAM1,   /* FrontPen, BackPen, DrawMode */
  5,            /* Count */
  points4,      /* *XY */
  NULL          /* *NextBorder */
};


/* A border for a 6-letter box: */
struct Border border_text6=
{
  0, 0,         /* LeftEdge, TopEdge */
  1, 2, JAM1,   /* FrontPen, BackPen, DrawMode */
  5,            /* Count */
  points6,      /* *XY */
  NULL          /* *NextBorder */
};



/* ********************************************************************* */
/* * Information for the proportional gadget                           * */
/* ********************************************************************* */

/* Since we are using the auto-knob we set GadgetRender to point to an   */
/* Image. In this case we do not need to initialize the Image structure: */
struct Image image_prop;

/* This is the special data required by the proportional gadget: */
struct PropInfo prop_info=
{
  AUTOKNOB| /* We want to use the auto-knob. */
  FREEVERT, /* The knob should move vertically. */
  0,0,      /* HorizPot, VertPot: will be initialized later. */
  0,        /* HorizBody                 -"-                 */
  0xFFFF,   /* VertBody: No data to show, maximum. */
  
  0,0,0,0,0,0 /* Intuition sets and maintains these variables. */
};

struct Gadget gadget_proportional=
{
  NULL,                     /* *NextGadget */
  290, 50, 21, 72,          /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,                /* Flags */
  GADGIMMEDIATE|FOLLOWMOUSE|RELVERIFY, /* Activation */
  PROPGADGET,               /* GadgetType */
  (APTR) &image_prop,       /* GadgetRender */
  NULL,                     /* SelectRender */
  NULL,                     /* *GadgetText */
  NULL,                     /* MutualExclude */
  (APTR) &prop_info,        /* SpecialInfo */
  NULL,                     /* GadgetID */
  NULL                      /* UserData */
};



/* UndoBuffer for the string gadgets: */
UBYTE name_backup[DRAWER_LENGTH];



/* ********************************************************************* */
/* * Information for the string gadget "Drawer:"                       * */
/* ********************************************************************* */

UBYTE drawer_name[DRAWER_LENGTH];

/* Values for a 28-letter string box: */
SHORT points28s[]=
{
   -7, -4,
  200, -4,
  200, 11,
   -7, 11,
   -7, -4
};


/* A border for a 28-letter string box: */
struct Border border_text28s=
{
  0, 0,         /* LeftEdge, TopEdge */
  1, 2, JAM1,   /* FrontPen, BackPen, DrawMode */
  5,            /* Count */
  points28s,    /* *XY */
  NULL          /* *NextBorder */
};


struct IntuiText text_drawer=
{
  1, 2,       /* FrontPen, BackPen */
  JAM1,       /* DrawMode */
  -69, 0,     /* LewftEdge, TopEdge */
  &my_font,   /* *ITextFont */
  "Drawer:",  /* *IText */
  NULL        /* *NextText */
};


struct StringInfo string_drawer=
{
  drawer_name,        /* *Buffer */
  name_backup,        /* *UndoBuffer */
  0,                  /* BufferPos */
  70,                 /* MaxChars (Including NULL) */
  0,                  /* DispPos */

  /* Intuition initializes and maintains these variables for you: */
  0,                 /* UndoPos */
  0, 0,              /* CLeft, CTop */
  NULL,              /* *LayerPtr */
  NULL,              /* LongInt */
  NULL,              /* *AltKeyMap */
};


struct Gadget gadget_drawer=
{
  &gadget_proportional,    /* *NextGadget */
  83, 35, 198, 8,          /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,               /* Flags */
  RELVERIFY,               /* Activation */
  STRGADGET,               /* GadgetType */
  (APTR) &border_text28s,  /* GadgetRender */
  NULL,                    /* SelectRender */
  &text_drawer,            /* *GadgetText */
  NULL,                    /* MutualExclude */
  (APTR) &string_drawer,   /* SpecialInfo */
  NULL,                    /* GadgetID */
  NULL                     /* UserData */
};



/* ********************************************************************* */
/* * Information for the string gadget "File:"                         * */
/* ********************************************************************* */


UBYTE file_name[FILE_LENGTH];


/* Values for a 30-letter string box: */
SHORT points30s[]=
{
   -7, -4,
  244, -4,
  244, 11,
   -7, 11,
   -7, -4
};


/* A border for a 30-letter string box: */
struct Border border_text30s=
{
  0, 0,         /* LeftEdge, TopEdge */
  1, 2, JAM1,   /* FrontPen, BackPen, DrawMode */
  5,            /* Count */
  points30s,    /* *XY */
  NULL          /* *NextBorder */
};


struct IntuiText text_file=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  -53, 0,   /* LewftEdge, TopEdge */
  &my_font, /* *ITextFont */
  "File:",  /* *IText */
  NULL      /* *NextText */
};


struct StringInfo string_file=
{
  file_name,         /* *Buffer */
  name_backup,       /* *UndoBuffer */
  0,                 /* BufferPos */
  40,                /* MaxChars (Including NULL) */
  0,                 /* DispPos */
  
  /* Intuition initializes and maintains these variables for you: */
  0,                 /* UndoPos */
  0, 0,              /* CLeft, CTop */
  NULL,              /* *LayerPtr */
  NULL,              /* LongInt */
  NULL,              /* *AltKeyMap */
};


struct Gadget gadget_file=
{
  &gadget_drawer,         /* *NextGadget */
  66, 129, 240, 8,        /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  NULL,                   /* Activation */
  STRGADGET,              /* GadgetType */
  (APTR) &border_text30s, /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_file,             /* *GadgetText */
  NULL,                   /* MutualExclude */
  (APTR) &string_file,    /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



/* ********************************************************************* */
/* * Information for the string gadget "Extension"                     * */
/* ********************************************************************* */


UBYTE extension_name[7]; /* 7 characters including NULL. */


/* Values for a 6-letter string box: */
SHORT points6s[]=
{
  -7, -4,
  57, -4,
  57, 10,
  -7, 10,
  -7, -4
};


/* A border for a 6-letter string box: */
struct Border border_text6s=
{
  0, 0,         /* LeftEdge, TopEdge */
  1, 2, JAM1,   /* FrontPen, BackPen, DrawMode */
  5,            /* Count */
  points6s,     /* *XY */
  NULL          /* *NextBorder */
};


struct IntuiText text_extension=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  -45, 0,   /* LewftEdge, TopEdge */
  &my_font, /* *ITextFont */
  "Ext:",   /* *IText */
  NULL      /* *NextText */
};


struct StringInfo string_extension=
{
  extension_name,    /* *Buffer */
  name_backup,       /* *UndoBuffer */
  0,                 /* BufferPos */
  7,                 /* MaxChars (Including NULL) */
  0,                 /* DispPos */
  
  /* Intuition initializes and maintains these variables for you: */
  0,                 /* UndoPos */
  0, 0,              /* CLeft, CTop */
  NULL,              /* *LayerPtr */
  NULL,              /* LongInt */
  NULL,              /* *AltKeyMap */
};


struct Gadget gadget_extension=
{
  &gadget_file,             /* *NextGadget */
  253, 17, 59, 8,           /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,                /* Flags */
  RELVERIFY,                /* Activation */
  STRGADGET,                /* GadgetType */
  (APTR) &border_text6s,    /* GadgetRender */
  NULL,                     /* SelectRender */
  &text_extension,          /* *GadgetText */
  NULL,                     /* MutualExclude */
  (APTR) &string_extension, /* SpecialInfo */
  NULL,                     /* GadgetID */
  NULL                      /* UserData */
};



/* ********************************************************************* */
/* * Information for the boolean gadget parent "<"                     * */
/* ********************************************************************* */


/* Values for a 1-letter box: */
SHORT points1[]=
{
   0,  0,
  20,  0,
  20, 15,
   0, 15,
   0,  0
};


/* A border for a 1-letter box: */
struct Border border_text1=
{
  0, 0,         /* LeftEdge, TopEdge */
  1, 2, JAM1,   /* FrontPen, BackPen, DrawMode */
  5,            /* Count */
  points1,      /* *XY */
  NULL          /* *NextBorder */
};


struct IntuiText text_parent=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  7,4,      /* LeftEdge, TopEdge */
  &my_font, /* *ITextFont, (Topaz, 80) */
  "<",      /* *IText */
  NULL      /* *NextText */
};


struct Gadget gadget_parent=
{
  &gadget_extension,      /* *NextGadget */
  290, 31, 21, 16,        /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  RELVERIFY,              /* Activation */
  BOOLGADGET,             /* GadgetType */
  (APTR) &border_text1,   /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_parent,           /* *GadgetText */
  NULL,                   /* MutualExclude */
  NULL,                   /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



/* ********************************************************************* */
/* * Information for the boolean gadget "dh0:"                         * */
/* ********************************************************************* */


struct IntuiText text_dh0=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  7,4,      /* LeftEdge, TopEdge */
  &my_font, /* *ITextFont, (Topaz, 80) */
  "dh0:",   /* *IText */
  NULL      /* *NextText */
};


struct Gadget gadget_dh0=
{
  &gadget_parent,         /* *NextGadget */
  110, 13, 45, 15,        /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  RELVERIFY,              /* Activation */
  BOOLGADGET,             /* GadgetType */
  (APTR) &border_text4,   /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_dh0,              /* *GadgetText */
  NULL,                   /* MutualExclude */
  NULL,                   /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



/* ********************************************************************* */
/* * Information for the boolean gadget "df1:"                         * */
/* ********************************************************************* */


struct IntuiText text_df1=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  7,4,      /* LeftEdge, TopEdge */
  &my_font, /* *ITextFont, (Topaz, 80) */
  "df1:",   /* *IText */
  NULL      /* *NextText */
};


struct Gadget gadget_df1=
{
  &gadget_dh0,            /* *NextGadget */
  59, 13, 45, 15,         /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  RELVERIFY,              /* Activation */
  BOOLGADGET,             /* GadgetType */
  (APTR) &border_text4,   /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_df1,              /* *GadgetText */
  NULL,                   /* MutualExclude */
  NULL,                   /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



/* ********************************************************************* */
/* * Information for the boolean gadget "df0:"                         * */
/* ********************************************************************* */


struct IntuiText text_df0=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  7,4,      /* LeftEdge, TopEdge */
  &my_font, /* *ITextFont, (Topaz, 80) */
  "df0:",   /* *IText */
  NULL      /* *NextText */
};


struct Gadget gadget_df0=
{
  &gadget_df1,            /* *NextGadget */
  8, 13, 45, 15,          /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  RELVERIFY,              /* Activation */
  BOOLGADGET,             /* GadgetType */
  (APTR) &border_text4,   /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_df0,              /* *GadgetText */
  NULL,                   /* MutualExclude */
  NULL,                   /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



/* ********************************************************************* */
/* * Information for the boolean gadget "CANCEL"                       * */
/* ********************************************************************* */


struct IntuiText text_cancel=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  7,4,      /* LeftEdge, TopEdge */
  &my_font, /* *ITextFont, (Topaz, 80) */
  "CANCEL", /* *IText */
  NULL      /* *NextText */
};


struct Gadget gadget_cancel=
{
  &gadget_df0,            /* *NextGadget */
  177, 144, 61, 15,       /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  RELVERIFY,              /* Activation */
  BOOLGADGET,             /* GadgetType */
  (APTR) &border_text6,   /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_cancel,           /* *GadgetText */
  NULL,                   /* MutualExclude */
  NULL,                   /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



/* ********************************************************************* */
/* * Information for the boolean gadget "DELETE"                       * */
/* ********************************************************************* */


struct IntuiText text_delete=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  7,4,      /* LeftEdge, TopEdge */
  &my_font, /* *ITextFont, (Topaz, 80) */
  "DELETE", /* *IText */
  NULL      /* *NextText */
};


struct Gadget gadget_delete=
{
  &gadget_cancel,         /* *NextGadget */
  110, 144, 61, 15,       /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  RELVERIFY,              /* Activation */
  BOOLGADGET,             /* GadgetType */
  (APTR) &border_text6,   /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_delete,           /* *GadgetText */
  NULL,                   /* MutualExclude */
  NULL,                   /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



/* ********************************************************************* */
/* * Information for the boolean gadget "SAVE"                         * */
/* ********************************************************************* */


struct IntuiText text_save=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  7,4,      /* LeftEdge, TopEdge */
  &my_font, /* *ITextFont, (Topaz, 80) */
  "SAVE",   /* *IText */
  NULL      /* *NextText */
};


struct Gadget gadget_save=
{
  &gadget_delete,         /* *NextGadget */
  59, 144, 45, 15,        /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  RELVERIFY,              /* Activation */
  BOOLGADGET,             /* GadgetType */
  (APTR) &border_text4,   /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_save,             /* *GadgetText */
  NULL,                   /* MutualExclude */
  NULL,                   /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



/* ********************************************************************* */
/* * Information for the boolean gadget "LOAD"                         * */
/* ********************************************************************* */


struct IntuiText text_load=
{
  1, 2,     /* FrontPen, BackPen */
  JAM1,     /* DrawMode */
  7,4,      /* LeftEdge, TopEdge */
  &my_font, /* *ITextFont, (Topaz, 80) */
  "LOAD",   /* *IText */
  NULL      /* *NextText */
};


struct Gadget gadget_load=
{
  &gadget_save,           /* *NextGadget */
  8, 144, 45, 15,         /* LeftEdge, TopEdge, Width, Height */
  GADGHCOMP,              /* Flags */
  RELVERIFY,              /* Activation */
  BOOLGADGET,             /* GadgetType */
  (APTR) &border_text4,   /* GadgetRender */
  NULL,                   /* SelectRender */
  &text_load,             /* *GadgetText */
  NULL,                   /* MutualExclude */
  NULL,                   /* SpecialInfo */
  NULL,                   /* GadgetID */
  NULL                    /* UserData */
};



UBYTE display_text[8][34];

struct IntuiText text_list[8]=
{
  {
    1, 0,            /* FrontPen, BackPen */
    JAM2,            /* DrawMode */
    0,0,             /* LeftEdge, TopEdge */
    &my_font,        /* *ITextFont */
    display_text[0], /* IText */
    &text_list[1]    /* *NextText */
  },
  {
    1, 0,            /* FrontPen, BackPen */
    JAM2,            /* DrawMode */
    0,8,             /* LeftEdge, TopEdge */
    &my_font,        /* *ITextFont */
    display_text[1], /* IText */
    &text_list[2]    /* *NextText */
  },
  {
    1, 0,            /* FrontPen, BackPen */
    JAM2,            /* DrawMode */
    0,16,            /* LeftEdge, TopEdge */
    &my_font,        /* *ITextFont */
    display_text[2], /* IText */
    &text_list[3]    /* *NextText */
  },
  {
    1, 0,            /* FrontPen, BackPen */
    JAM2,            /* DrawMode */
    0,24,            /* LeftEdge, TopEdge */
    &my_font,        /* *ITextFont */
    display_text[3], /* IText */
    &text_list[4]    /* *NextText */
  },
  {
    1, 0,            /* FrontPen, BackPen */
    JAM2,            /* DrawMode */
    0,32,            /* LeftEdge, TopEdge */
    &my_font,        /* *ITextFont */
    display_text[4], /* IText */
    &text_list[5]    /* *NextText */
  },
  {
    1, 0,            /* FrontPen, BackPen */
    JAM2,            /* DrawMode */
    0,40,            /* LeftEdge, TopEdge */
    &my_font,        /* *ITextFont */
    display_text[5], /* IText */
    &text_list[6]    /* *NextText */
  },
  {
    1, 0,            /* FrontPen, BackPen */
    JAM2,            /* DrawMode */
    0,48,            /* LeftEdge, TopEdge */
    &my_font,        /* *ITextFont */
    display_text[6], /* IText */
    &text_list[7]    /* *NextText */
  },
  {
    1, 0,            /* FrontPen, BackPen */
    JAM2,            /* DrawMode */
    0,56,            /* LeftEdge, TopEdge */
    &my_font,        /* *ITextFont */
    display_text[7], /* IText */
    NULL             /* *NextText */
  }
};



struct Gadget gadget_display[8]=
{
  {
    &gadget_display[1], /* *NextGadget */
    8, 50, 276, 12,     /* LeftEdge, TopEdge, Width, Height */
    GADGHNONE,          /* Flags */
    GADGIMMEDIATE,      /* Activation */
    BOOLGADGET,         /* GadgetType */
    NULL,               /* GadgetRender */
    NULL,               /* SelectRender */
    NULL,               /* *GadgetText */
    NULL,               /* MutualExclude */
    NULL,               /* SpecialInfo */
    NULL,               /* GadgetID */
    NULL                /* UserData */
  },
  {
    &gadget_display[2], /* *NextGadget */
    8, 62, 276, 8,      /* LeftEdge, TopEdge, Width, Height */
    GADGHNONE,          /* Flags */
    GADGIMMEDIATE,      /* Activation */
    BOOLGADGET,         /* GadgetType */
    NULL,               /* GadgetRender */
    NULL,               /* SelectRender */
    NULL,               /* *GadgetText */
    NULL,               /* MutualExclude */
    NULL,               /* SpecialInfo */
    NULL,               /* GadgetID */
    NULL                /* UserData */
  },
  {
    &gadget_display[3], /* *NextGadget */
    8, 70, 276, 8,      /* LeftEdge, TopEdge, Width, Height */
    GADGHNONE,          /* Flags */
    GADGIMMEDIATE,      /* Activation */
    BOOLGADGET,         /* GadgetType */
    NULL,               /* GadgetRender */
    NULL,               /* SelectRender */
    NULL,               /* *GadgetText */
    NULL,               /* MutualExclude */
    NULL,               /* SpecialInfo */
    NULL,               /* GadgetID */
    NULL                /* UserData */
  },
  {
    &gadget_display[4], /* *NextGadget */
    8, 78, 276, 8,      /* LeftEdge, TopEdge, Width, Height */
    GADGHNONE,          /* Flags */
    GADGIMMEDIATE,      /* Activation */
    BOOLGADGET,         /* GadgetType */
    NULL,               /* GadgetRender */
    NULL,               /* SelectRender */
    NULL,               /* *GadgetText */
    NULL,               /* MutualExclude */
    NULL,               /* SpecialInfo */
    NULL,               /* GadgetID */
    NULL                /* UserData */
  },
  {
    &gadget_display[5], /* *NextGadget */
    8, 86, 276, 8,      /* LeftEdge, TopEdge, Width, Height */
    GADGHNONE,          /* Flags */
    GADGIMMEDIATE,      /* Activation */
    BOOLGADGET,         /* GadgetType */
    NULL,               /* GadgetRender */
    NULL,               /* SelectRender */
    NULL,               /* *GadgetText */
    NULL,               /* MutualExclude */
    NULL,               /* SpecialInfo */
    NULL,               /* GadgetID */
    NULL                /* UserData */
  },
  {
    &gadget_display[6], /* *NextGadget */
    8, 94, 276, 8,      /* LeftEdge, TopEdge, Width, Height */
    GADGHNONE,          /* Flags */
    GADGIMMEDIATE,      /* Activation */
    BOOLGADGET,         /* GadgetType */
    NULL,               /* GadgetRender */
    NULL,               /* SelectRender */
    NULL,               /* *GadgetText */
    NULL,               /* MutualExclude */
    NULL,               /* SpecialInfo */
    NULL,               /* GadgetID */
    NULL                /* UserData */
  },
  {
    &gadget_display[7], /* *NextGadget */
    8, 102, 276, 8,      /* LeftEdge, TopEdge, Width, Height */
    GADGHNONE,          /* Flags */
    GADGIMMEDIATE,      /* Activation */
    BOOLGADGET,         /* GadgetType */
    NULL,               /* GadgetRender */
    NULL,               /* SelectRender */
    NULL,               /* *GadgetText */
    NULL,               /* MutualExclude */
    NULL,               /* SpecialInfo */
    NULL,               /* GadgetID */
    NULL                /* UserData */
  },
  {
    &gadget_load,       /* *NextGadget */
    8, 110, 276, 12,    /* LeftEdge, TopEdge, Width, Height */
    GADGHNONE,          /* Flags */
    GADGIMMEDIATE,      /* Activation */
    BOOLGADGET,         /* GadgetType */
    NULL,               /* GadgetRender */
    NULL,               /* SelectRender */
    NULL,               /* *GadgetText */
    NULL,               /* MutualExclude */
    NULL,               /* SpecialInfo */
    NULL,               /* GadgetID */
    NULL                /* UserData */
  }
};



/* ********************************************************************* */
/* * BIG BOX                                                           * */
/* ********************************************************************* */


/* Values for a big box: */
SHORT points_big_box[]=
{
   8, 50,
 283, 50,
 283, 121,
   8, 121,
   8, 50
};


/* A border for a 1-letter box: */
struct Border border_big_box=
{
  0, 0,           /* LeftEdge, TopEdge */
  1, 2, JAM1,     /* FrontPen, BackPen, DrawMode */
  5,              /* Count */
  points_big_box, /* *XY */
  NULL            /* *NextBorder */
};



/* ********************************************************************* */
/* * Information for the window                                          */
/* ********************************************************************* */

struct NewWindow new_file_window=
{
  0,0,              /* LeftEdge, TopEdge */
  320, 163,         /* Width, Height */
  0,1,              /* DetailPen, BlockPen */

  CLOSEWINDOW|      /* IDCMPFlags */
  GADGETDOWN|
  MOUSEMOVE|
  GADGETUP,

  ACTIVATE|         /* Flags */
  WINDOWDEPTH|
  WINDOWDRAG|
  WINDOWCLOSE|
  SMART_REFRESH,

  &gadget_display[0], /* *FirstGadget */
  NULL,               /* *CheckMark */
  NULL,               /* *Title */
  NULL,               /* *Screen */
  NULL,               /* *BitMap */
  0,0,                /* MinWidth, MinHeight */
  0,0,                /* MaxWidth, MaxHeight */
  WBENCHSCREEN        /* Type */
};















USHORT FileWindow( title, extension, x, y, screen, total_file_name )
STRPTR title;
STRPTR extension;
SHORT  x,y;
struct Screen *screen;
STRPTR total_file_name;
{
  int temp1; /* Variable used for loops etc. */
  int file_count; /* How many files/directories there are. */

  ULONG class;  /* Saved IntuiMessage: IDCMP flags. */
  USHORT code;  /*        -"-        : Special code. */
  APTR address; /*        -"-        : The address of the object. */

  int position; /* The number of the first file in the display. */

  BOOL working;     /* Wants the user to quit? */
  BOOL fix_display; /* Should we update the file-display? */

  STRPTR string_pointer; /* Pointer to a string. */
  struct file_info *pointer; /* Pointer to a file_info structure. */

  USHORT operation; /* What operation FileWindow will return. */
  

  file_lock=FALSE; /* We have not locked any file/directory. */
  more_files=FALSE; /* Do not list any files yet. */


  /* Make sure the proportional gadget is at the top, showing 100%: */
  prop_info.VertBody=0xFFFF;
  prop_info.HorizBody=0;
  prop_info.VertPot=0;
  prop_info.HorizPot=0;
  

  /* Copy the extension into the string gadget: */
  strcpy(extension_name, extension);

  /* If there is an extension, the text "Ext:" will be highlighted: */
  if(*extension_name != '\0')
    text_extension.FrontPen=3; /* Orange. (Normal WB colour) */
  else
    text_extension.FrontPen=1; /* White. (Normal WB colour) */


  /* Change some values in the new_file_window structure: */
  new_file_window.LeftEdge=x;
  new_file_window.TopEdge=y;
  new_file_window.Title=title;

  /* Does the user want to use on of his own screens? */
  if(screen)
  {
    new_file_window.Screen=screen;
    new_file_window.Type=CUSTOMSCREEN;
  }    


  /* Open the window: */
  if( (file_window = (struct Window *) OpenWindow(&new_file_window)) == NULL )
  {
    /* We could NOT open the window! */
  
    /* Leave: */
    return(PANIC);
  }


  /* Draw the big box around the display: */
  DrawBorder(file_window->RPort, &border_big_box, 0, 0);




  /* Allocate memory for the FileInfoBlock: */
  if((file_info=(struct FileInfoBlock *)
    AllocMem(sizeof(struct FileInfoBlock), MEMF_PUBLIC|MEMF_CLEAR))==NULL)
  {
    /* Could not allocate memory for the FileInfoBlock! */
    /* Inform the user about the problem, and leave. */
    request_ok("NOT enough memory!");
    return(PANIC);
  }


  /* Is the there anything in the total_file_name string? */
  if(*total_file_name != '\0')
  {
    /* Yes! */
    /* Try to "lock" the file/directory: */
    if((lock=Lock(total_file_name, ACCESS_READ))==NULL)
    {
      /* PROBLEMS! */
      /* File/directory/device did NOT exist! */
    }
    else
    {
      /* Could lock the file/directory! */
      file_lock=TRUE;
  
      /* Get some information of the file/directory: */
      if((Examine(lock, file_info))==NULL)
      {
        /* Could NOT examine the object! */
        request_ok("ERROR reading file/directory!");
      }
      else
      {
        /* Is it a directory or a file? */
        if(directory(file_info))
        {
          /* It is a directory! */

          *file_name='\0'; /* Clear file_name string. */
          /* Copy total_file_name into drawer_name string: */
          strcpy(drawer_name, total_file_name);

          /* Since it is a directory, we will look for more files: */
          more_files=TRUE;
        }
        else
        {
          /* It is a file! */
          
          /* Separate the file name from the path: */
          if(string_pointer=right_pos(total_file_name, '/'))
          {
            /* Copy the file name into file_name string: */
            strcpy(file_name, string_pointer+1);
            *string_pointer='\0';
          }
          else
          {
            if(string_pointer=right_pos(total_file_name, ':'))
            {
              /* Copy the file name into file_name string: */
              strcpy(file_name, string_pointer+1);
              *(string_pointer+1)='\0';
            }
            else
            {
              strcpy(file_name, total_file_name);        
              *drawer_name='\0';
              *total_file_name='\0';
            }
          }
          strcpy(drawer_name, total_file_name);

          /* Since it is a file, we will NOT look for more files: */
          /* However, more_files is already FALSE. */

        } /* Is it a directory? */

      } /* Could we examine the object? */

    } /* Could we "lock" the file/directory? */

  } /* Anything in the total_file_name string? */






  /* Since we have messed around with the string gadgets it is best */
  /* to adjust them so the user can see them clearly:               */
  adjust_string_gadgets();


  new_drawer(); /* Start to show us the files. */


  position=0;        /* The display will show the first file. */
  fix_display=FALSE; /* We do not need to fix the display. */
  first_file=TRUE;   /* No files saved. */
  file_count=0;      /* No files saved. */


  working=TRUE;
  do
  {
    /* If we have shown all files in the directory, we put our task */
    /* to sleep. That will speed up other programs, and we will not */
    /* use unnecessary processing time:                             */
    if(more_files==FALSE)
      Wait(1 << file_window->UserPort->mp_SigBit);


    /* Has something has happened with the gadgets in the file_window? */
    while(my_gadget_message = (struct IntuiMessage *)
      GetMsg(file_window->UserPort))
    {
      /* As long as something is happening with the gadgets we will     */
      /* stay in the while loop. This is very handy since we can        */
      /* recieve hundereds of messages if the mouse is moving, and      */
      /* we only want to update the display when the mouse has stopped: */
      
      /* Collect some interesting values: */
      class = my_gadget_message->Class;
      code = my_gadget_message->Code;
      address = my_gadget_message->IAddress;

      /* We have now saved some important values, and can now reply: */
      /* (Do NEVER try to get some values after you have replied!)   */
      ReplyMsg((struct Message *)my_gadget_message);


      /* What has actually happened? */
      switch(class)
      {
        case MOUSEMOVE:
          /* The proportional gadget is selected, and the mouse is  */ 
          /* moving; we must update the file_display when the mouse */
          /* has stopped: */
          fix_display=TRUE;
          break;

        case CLOSEWINDOW:
          /* The user wants to quit. */
          connect_dir_file(total_file_name);
          working=FALSE;
          operation=QUIT;
          break;

        case GADGETDOWN:
           /* A gadget has been pressed down. */
           /* Which gadget has been clicked on? */
           
           /* DISPLAY */
           /* Is the user clicking inside the file display? */
           for(temp1=0; temp1 < 8; temp1++)
           {
             if(address == (APTR)&gadget_display[temp1])
             {
               /* The user wants to select a file/directory: */
               pick_file(temp1+position);
             }
           }
           break;



        case GADGETUP:
           /* A gadget has been released. */
           /* Which gadget has been clicked on? */


           /* LOAD */
           if(address == (APTR)&gadget_load)
           {
             if(last_check(total_file_name))
             {
               working=FALSE;
               operation=LOAD;
             }
             break;
           }


           /* SAVE */
           if(address == (APTR)&gadget_save)
           {
             if(last_check(total_file_name))
             {
               working=FALSE;
               operation=SAVE;
             }
             break;
           }


           /* DELETE */
           if(address == (APTR)&gadget_delete)
           {
             delete_file_dir(total_file_name);
             break;
           }


           /* CANCEL */
           if(address == (APTR)&gadget_cancel)
           {
             connect_dir_file(total_file_name);
             working=FALSE;
             operation=CANCEL;
             break;
           }


           /* df0: */
           if(address == (APTR)&gadget_df0)
           {
             change_device("df0:");
             break;
           }


           /* df1: */
           if(address == (APTR)&gadget_df1)
           {
             change_device("df1:");
             break;
           }


           /* dh0: */
           if(address == (APTR)&gadget_dh0)
           {
             change_device("dh0:");
             break;
           }


           /* DRAWER: */
           if(address == (APTR)&gadget_drawer)
           {
             /* The user has entered something new in the drawer: */
             new_drawer();
             break;
           }


           /* EXTENSION: */
           if(address == (APTR)&gadget_extension)
           {
             /* If there is an extension, the text "Ext:" will be */
             /* highlighted: */
             if(*extension_name != '\0')
               text_extension.FrontPen=3; /* Orange. (Normal WB colour) */
             else
               text_extension.FrontPen=1; /* White. (Normal WB colour) */

             /* Show the user the colour change: */
             RefreshGadgets(&gadget_extension, file_window, NULL);

             /* Start again to diplay the files, using a new extension. */
             new_drawer();
             break;
           }


           /* PARENT: "<" */
           if(address == (APTR)&gadget_parent)
           {
             parent();
             break;
           }


           /* PROPORTIONAL */
           if(address == (APTR)&gadget_proportional)
           {
             /* The user has released the proprtional gadget, update */
             /* the display: */
             fix_display=TRUE;
             break;
           }
      }
    }


    /* Do we need to update the file display? */
    if(fix_display)
    {
      fix_display=FALSE;

      /* Which file should we start to show in the display? */
      if(file_count > 8)
        position=(int) prop_info.VertPot/(float) 0xFFFF*(file_count-8);
      else
        position=0;

      /* List the files: (Starting with position) */
      display_list(position);
    }


    if(more_files)
    {
      /* Are there more files/dirtectories left to be collected? */    
      if(ExNext(lock, file_info))
      {
        /* List the file/directory if it is: */
        /* 1. A file which has the right extension. */
        /* 2. A directory. */
        if(stricmp(extension_name, (file_info->fib_FileName+
           strlen(file_info->fib_FileName)-strlen(extension_name)))==0 ||
           directory(file_info) )
        {
          /* Is this the first file/directory? */
          if(first_file)
          {
            /* first_pointer will point at the first file in our list: */
            first_pointer=(struct file_info *) save_file_info(file_info);
            
            if(first_pointer != NULL)
            {
              /* There are no more elements (for the moment) in our list: */ 
              first_pointer->next=NULL; 
              first_file=FALSE;
            }
            file_count=1;
            position=1;
          }
          else
          {
            /* save_file_info will return a pointer to the allocated */
            /* structure: */
            pointer=(struct file_info *) save_file_info(file_info);
            
            /* If we have been able to allocate space for the file we */
            /* put it into our list: */
            if(pointer !=NULL)
            {
              /* Put the new structure into the list: */
              put_in(first_pointer, pointer);       
              file_count++;
            }
          }
        
          /* If tehre are more than eight files/directories we modify */
          /* the proportional gadget: */
          if(file_count > 8)
          {
            ModifyProp
            (
              &gadget_proportional,       /* PropGadget */
              file_window,                /* Pointer */
              NULL,                       /* Requester */
              prop_info.Flags,            /* Flags */
              0,                          /* HorizPot */
              prop_info.VertPot,          /* VertPot */
              0,                          /* HorizBody */
              (ULONG) 0xFFFF*8/file_count /* VerBody */
            );            
            position=(int) prop_info.VertPot/(float) 0xFFFF*(file_count-8);
          }
          else
           position=0;


          /* List all the files: */
          display_list(position);
        }
      }
      else
      {
        /* ExNext() failed: */
        
        more_files=FALSE; /* Do not try to list any more files. */

        /* Check what went wrong: */
        /* If the error message is NOT "ERROR_NO_MORE_ENTRIES" something */
        /* went terrible wrong while reading: */
        if(IoErr() != ERROR_NO_MORE_ENTRIES)
        {
          request_ok("ERROR reading file/directory!");
        }
      }
    }
  } while(working);

  /* Clean up and leave: */


  /* This will clear the IDCMP port: */
  while( (my_gadget_message = (struct IntuiMessage *)
           GetMsg(file_window->UserPort)) )
  {
    ReplyMsg((struct Message *)my_gadget_message);
  }


  /* Deallocate the memory we have dynamically allocated: */ 
  deallocate_file_info();


  /* If we have "locked" a file/directory, "unlock" it: */
  if(file_lock)
  {
    UnLock(lock);
    file_lock=FALSE;
  }
  
  
  /* Deallocate FileInfoBlock: */
  if(file_info) FreeMem(file_info, sizeof(struct FileInfoBlock));


  /* If we have successfully opened the file_window, we close it: */
  if(file_window)
    CloseWindow(file_window);
  
  /* Leave with a message: */
  return(operation);
}



/* Deallocate the memory we have dynamically allocated: */ 
void deallocate_file_info()
{
  struct file_info *pointer, *temp_pointer;

  /* Does the first pointer point to an allocated structure? */   
  if(first_pointer)
  {
    /* Save the address of the next structure: */
    pointer=first_pointer->next;
    
    /* Deallocate the first structure: */
    FreeMem( first_pointer, sizeof(struct file_info));

    /* As long as pointer points to an allocated structure: */
    while(pointer)
    {
      /* Save the address of the next structure: */    
      temp_pointer=pointer->next;
      
      FreeMem( pointer, sizeof(struct file_info));
      pointer=temp_pointer;
    }
  }
  
  /* Clear first_pointer: */
  first_pointer=NULL;

  /* Next time we try to list the files, we start with the first_file: */
  first_file=TRUE;
}



/* Allocate memory for the new file/directory, and fills the structure */
/* with information. (name of the object, and if it is a directory.)   */
/* Returns a memory pointer to the allocated structure, or NULL.       */
APTR save_file_info(info)
struct FileInfoBlock *info;
{
  struct file_info *pointer;

  if((pointer=(struct file_info *)
    AllocMem(sizeof(struct file_info), MEMF_PUBLIC|MEMF_CLEAR))==NULL)
  {
    /* We could NOT allocate memory for the structure! */
    request_ok("NOT enough memory!"); /* Inform the user. */
    more_files=FALSE; /* Do not list any more files/directories. */
    return(NULL);
  }
  else
  {
    /* If the file/directory name is not too long, we copy it into the */
    /* new stucture: */
    if(strlen(info->fib_FileName) < 28)
      strcpy(pointer->name, info->fib_FileName);
    else
    {
      /* The file/directory name is too long! */
      /* Inform the user: */
      
      if( directory(info))
        request_ok("Directory name too long!"); /* It is a directory. */
      else    
        request_ok("File name too long!"); /* It is a file. */

      /* Deallocate the structure: */
      FreeMem( pointer, sizeof(struct file_info));
      return(NULL);
    }

    /* Is it a file or a directory? */
    if( directory(info))
      pointer->directory=TRUE; /* It is a directory. */
    else    
      pointer->directory=FALSE; /* It is a file. */
  }
  
  /* Return the address of the allocated structure: */
  return( (APTR) pointer);
}



/* Will check a FileInfoBlock if it is a file or a directory. */
/* Return TRUE if it is a directory, FALSE if it is a file.   */
BOOL directory(info)
struct FileInfoBlock *info;
{
  if(info->fib_DirEntryType < 0)
    return(FALSE);
  else
    return(TRUE);
}



/* Put the new structure into the dynamically allocated list at the */
/* right place (sorted alphabetically, directories first):          */
void put_in(a_pointer, pointer)
struct file_info *a_pointer, *pointer;
{
  struct file_info *old_pointer=NULL;

  /* Move slowly down the list and try to fit in the structure: */
  while( a_pointer && file_comp(a_pointer->name, pointer->name) )
  {
    old_pointer=a_pointer;
    a_pointer=a_pointer->next;
  }

  if(a_pointer)
  {
    if(old_pointer)
    {
      /* Put the structure into the list: */
      pointer->next=old_pointer->next;
      old_pointer->next=pointer;
    }
    else
    {
      /* First in the list! */
      pointer->next=first_pointer;
      first_pointer=pointer;
    }
  }
  else
  {
    /* Last int the list: */
    old_pointer->next=pointer;
    pointer->next=NULL;
  }
}



/* This function will return TRUE if the first pointer (a_pointer) */
/* points to a file structure which should come before the second  */
/* pointers file structure.                                        */
/* ORDER: */
/* 1. DIRECTORIES sorted alphabetically. */
/* 2. FILES       sorted alphabetically. */

BOOL file_comp(a_pointer, pointer)
struct file_info *a_pointer, *pointer;
{
  if(a_pointer->directory == FALSE && pointer->directory)
    return(FALSE);
    
  if(a_pointer->directory == pointer->directory)
  {
    if(stricmp(a_pointer->name, pointer->name) <= 0 )
      return(TRUE);
    else
      return(FALSE);
  } 
  return(TRUE);
}



/* Give this function a string and a character, and it will return a */
/* pointer to the right most occurance character in you string which */
/* match your character.                                             */
STRPTR right_pos(string, sign)
STRPTR string;
char sign;
{
  STRPTR start_pos;
  
  start_pos=string;
  
  /* Go to the end: */
  while(*string != '\0')
    string++;

  /* Start to go backwards and check teh string: */
  while(*string != sign && string > start_pos)
    string--;
    
  if(*string==sign)
    return(string); /* We have found a matching character. */

  return(NULL); /* We could not find a matching character. */
}



/* This function will change to a new device, for example df0:. */
/* Does not return anything.                                    */
void change_device(device)
STRPTR device;
{
  strcpy(drawer_name, device); /* Change the drawer string. */

  adjust_string_gadgets(); /* Adjust the string gadgets. */

  new_drawer(); /* Start to show us the new files/directories */
}



/* When the user or the program has changet the drawer string, this      */
/* function is called, and will do what is necessary to start to collect */
/* the new files/directories from the disk.                              */
/* Returns TRUE if everything is OK, and FALSE if something went wrong.  */
BOOL new_drawer()
{
  STRPTR string_pointer;

  /* Unlock: */
  if(file_lock)
  {
    UnLock(lock);
    file_lock=FALSE;
  }

  /* Deallocate the memory we have dynamically allocated: */ 
  deallocate_file_info();

  /* Change the proportianal gadget: */
  ModifyProp
  (
    &gadget_proportional, /* PropGadget */
    file_window,          /* Pointer */
    NULL,                 /* Requester */
    prop_info.Flags,      /* Flags */
    0,                    /* HorizPot */
    0,                    /* VertPot */
    0,                    /* HorizBody */
    (ULONG) 0xFFFF        /* VerBody */
  );

  /* Clear the display: */
  display_list(0);

  more_files=FALSE;

  /* Try to "lock" the file/directory: */
  if((lock=Lock(drawer_name, ACCESS_READ))==NULL)
  {
    /* We could NOT lock the file/directory/device! */
    /* Inform the user: */
    string_pointer=drawer_name+strlen(drawer_name)-1;
    if(*string_pointer==':')
      request_ok("Device NOT found!");
    else
      request_ok("Device/Directory NOT found!");

    return(FALSE); /* ERROR */
  }
  else
  {
    /* We "locked" the file/directory! */
    file_lock=TRUE;
  }

  /* Now try to get some information from the file/directory: */
  if((Examine(lock, file_info))==NULL)
  {
    /* We could NOT examine the file/directory! */

    request_ok("ERROR reading file/directory!"); /* Inform the user. */

    return(FALSE); /* ERROR */
  }

  /* Is it a directory or a file? */
  if(directory(file_info))
  {
    /* It is a directory! */

    /* Since it is a directory, we will look for more files: */
    more_files=TRUE;
  }
  else
  {
    /* It is a file! */
    request_ok("NOT a valid directory name!"); /* Inform the user. */
    return(FALSE);
  }  
  return(TRUE);
}



/* The function parent() will try to go backwards one step in the */
/* directory path.                                                */
/* Does not return anything.                                      */
void parent()
{
  STRPTR string_pointer;

  /* Separate the last directory from the path: */
  if(string_pointer=right_pos(drawer_name, '/'))
  {
    /* Take away the last directory: */
    *string_pointer='\0';
  }
  else
  {
    if(string_pointer=right_pos(drawer_name, ':'))
    {
      /* Take away the last directory: */
      /* Only the device ("df0:" for example) left: */
      *(string_pointer+1)='\0';
    }
    else
    {
      /* Strange drawer_name, clear it: */
      *drawer_name='\0';
    }
  }

  /* Since we have messed around with the string gadgets, adjust them: */
  adjust_string_gadgets();
  
  /* Start to show the user the files etc in the new directory: */
  new_drawer();
}



/* You give this function a pointer to an error string, and it will open */
/* a simple requester displaying the message. The requester will go away */
/* first when the user has selected the button "OK".                     */
/* Does not return anything.                                             */
void request_ok(message)
STRPTR message;
{
  text_request.IText=message;
  
  AutoRequest
  (
    file_window,   /* Window */
    &text_request, /* BodyText */
    NULL,          /* PositiveText nothing */
    &ok_request,   /* NegativeText OK */
    NULL,          /* PositiveFlags */
    NULL,          /* NegativeFlags */
    320,           /* Width */
    72             /* Height */
  );
}



/* This function will also open a simple requester, but will instead      */
/* ask the user to make a choice between option1 or option2               */
/* If the user selects option1 the function returns TRUE, else it returns */
/* FALSE.                                                                 */
BOOL request_ask(message, option1, option2)
STRPTR message, option1, option2;
{
  text_request.IText=message;
  option1_request.IText=option1;
  option2_request.IText=option2;
  
  
  return( (BOOL) AutoRequest
  (
    file_window,       /* Window */
    &text_request,     /* BodyText */
    &option1_request,  /* PositiveText, TRUE */
    &option2_request,  /* NegativeText, FALSE */
    NULL,              /* PositiveFlags */
    NULL,              /* NegativeFlags */
    320,               /* Width */
    72                 /* Height */
  ));
}



/* This function will display the files etc which are inside the */
/* directory, starting with the file number start_pos.           */
/* Does not return anything.                                     */
void display_list(start_pos)
int start_pos;
{
  struct file_info *pointer;
  int pos, temp1;
                  /* 123456789012345678901234567890123 */
  char empty_name[]="                                 ";
  STRPTR string_pointer;
  BOOL clear;
  
  pos=0;
  
  /* Does it exist any files at all? */
  if(first_pointer)
  {
    pointer=first_pointer;

    /* Go through the list until you have found the file/directory */
    /* which should be shown first:                                */
    while(pointer && pos < start_pos)
    {
      pos++;
      pointer=pointer->next;
    }
    
    /* Try to show the eight files: */
    pos=0;
    while(pointer && pos < 8)
    {
      strcpy(display_text[pos], pointer->name);
      
      clear=FALSE;
      temp1=0;
      string_pointer=display_text[pos];

      if(pointer->directory)
      {
        /* It is a directory: */
        text_list[pos].FrontPen=3; /* Highlight it. */

        /* Clear everything after the name, and add the string "(Dir)". */
        while(temp1 < 28)
        {
          if(*string_pointer=='\0')
            clear=TRUE;
          if(clear)
            *string_pointer=' ';
          string_pointer++;
          temp1++;
        }
        *string_pointer='\0';
        strcat(display_text[pos], "(Dir)");
      }
      else
      {
        /* It is a file: */
        text_list[pos].FrontPen=1; /* Normal colour. */

        /* Clear everything after the name: */
        while(temp1 < 33)
        {
          if(*string_pointer=='\0')
            clear=TRUE;
          if(clear)
            *string_pointer=' ';
          string_pointer++;
          temp1++;
        }
        *string_pointer='\0';
      }      
      pos++;
      pointer=pointer->next; /* Next. */
    }
  }

  /* If there are less than eight files, show clear the rest of the */
  /* display: */
  while(pos < 8)
  {
    strcpy(display_text[pos], empty_name);
    pos++;
  }
  
  /* Show the user the new display: */
  PrintIText(file_window->RPort, text_list, 13+3, 53+1);
}



/* The user has selected a file or a directory. If it is a file put it */
/* into the file string, otherwise put it into the drawer string.      */
/* Returns TRUE if everything went OK, FALSE if there was a problem.   */
BOOL pick_file(file_pos)
int file_pos;
{
  struct file_info *pointer=NULL;
  STRPTR string_pointer;
  int pos=0;
  
  /* Go through the allocated list untill we find the file/directory: */
  if(first_pointer)
  {
    pointer=first_pointer;
    
    while(pointer && pos < file_pos)
    {
      pos++;
      pointer=pointer->next;
    }
  }

  /* Have we found the file/directory? */
  if(pointer)
  {
    if(pointer->directory)
    {
      /* It is a directory! */
      
      /* Is the drawer_name string long enough? */
      /* (+2: 1 for the NULL ('\0') character, 1 for the '\' character) */
      if((strlen(pointer->name)+strlen(drawer_name)+2) <= DRAWER_LENGTH)
      {
        /* YES!, there is enough room for it. */
        string_pointer=drawer_name+strlen(drawer_name)-1;
        if(*string_pointer==':'  || *string_pointer=='\0' )
          strcat(drawer_name, pointer->name);
        else
        {
          /* We need to add a '/' before we can add the directory. */
          strcat(drawer_name, "/");
          strcat(drawer_name, pointer->name);
        }
        
        /* Adjust the string gadgets: */
        adjust_string_gadgets();
      }
      else
      {
        /* The drawer_name is NOT big enough! */
        request_ok("Too long drawer string"); /* Inform the user. */
        return(FALSE); /* ERROR */
      }
      new_drawer();
      return(TRUE); /* OK */
    }
    else
    {
      /* It is a File! */
      /* Is the file_name string long enough? */
      /* (+1 for the NULL ('\0') character.) */
      if((strlen(pointer->name)+1) <= FILE_LENGTH)
      {
        strcpy(file_name, pointer->name);
        adjust_string_gadgets();
      }
      else
      {
        /* The file_name is NOT big enough! */
        request_ok("File name too long!"); /* Inform the user. */
        return(FALSE); /* ERROR */
      }
      return(TRUE); /* OK */
    }
  }
}



/* Adjust the string gadgets, so the user can */
/* at least see the last 28/22 characters.    */
/* Does not return anything.                  */
void adjust_string_gadgets()
{
  int length;

  length=strlen(file_name);        

  if(length > 28)
    string_file.DispPos=length-28;
  else
    string_file.DispPos=0;

  string_file.BufferPos=string_file.DispPos;
  

  length=strlen(drawer_name);        

  if(length > 22)
    string_drawer.DispPos=length-22;
  else
    string_drawer.DispPos=0;

  string_drawer.BufferPos=string_drawer.DispPos;

  /* Display the changes. */
  RefreshGadgets(&gadget_file, file_window, NULL);
}



/* Returns TRUE if there exist a file name, otherwise FALSE. */
BOOL last_check(name)
STRPTR name;
{
  if(*file_name == '\0')
  {
    /* No file name! */
    request_ok("NO filename selected!"); /* Inform the user. */
    return(FALSE);
  }
  else
  {
    /* Change the total_file_name. Drawer + File. */
    connect_dir_file(name);
  }
  return(TRUE);
}



/* This function will connect the drawer string with the file string. */
/* Does not return anything.                                          */
void connect_dir_file(name)
STRPTR name;
{
  STRPTR string_pointer;
  
       
  strcpy(name, drawer_name); /* Copy the drawer string into name. */

  /* Does it exist a file name? */
  if(*file_name != '\0')
  {
    /* Yes! */
    string_pointer=drawer_name+strlen(drawer_name)-1;
    if(*string_pointer==':'  || *string_pointer=='\0' )
    {
      strcat(name, file_name); /* Add the file name. */
    }
    else
    {
      strcat(name, "/"); /* Add a '\'. */
      strcat(name, file_name); /* Add the file name. */
    }
  }
}



/* Does not return anything. */
void delete_file_dir(total_file_name)
STRPTR total_file_name;
{
  BOOL delete_it;

  /* Presume the user do not want to deleta the file/dir: */
  delete_it=FALSE;
  
  if(*file_name == '\0' && *drawer_name != '\0')
  {
    /* There is no filename string, but there is something */
    /* in the drawer string. The user wants to delete a */
    /* directory: */
                 
    /* Is it a device or a directory? */
    if( *(drawer_name+strlen(drawer_name)-1) ==':')
    {
      /* The user wants to delete a device: */
      /* Not a very good idea! */
      request_ok("You can NOT delete a device!");
    }
    else
    {
      /* The user wants to delete a directory: */
                   
      /* However, it is important to check that the user */
      /* realy wants to delete it:                       */
      delete_it=request_ask("OK to delete directory?","DELETE","CANCEL");
                   
      if(delete_it)
      {
        /* YES! The user wanted to delete the directory.  */
        /* Before we try to delete it we must "unlock" it */
        if(file_lock)
        {
          UnLock(lock);
          file_lock=FALSE;
        }
      }
    }
  }
  else
  {
    if(*file_name != '\0')
    {
      /* There is something in the file_name string. The user */
      /* wants to delete a file: */
      
      /* We will here again give the user a last chance to */
      /* make up his/her mind: */
      delete_it=request_ask("OK to delete file?","DELETE","CANCEL");
    }
    else
    {
      /* Nothing in the drawer string, nor in the file string. */
      /* The user wants to delete something, but has NOT       */
      /* declared which file/directory he/she wants to delete: */
      request_ok("NO file/directory selected!");
    }
  }
  
  /* Should we delete the file/directory? */
  if(delete_it)
  {
    /* Yes! */
    
    /* Put the drawer name together with the file name: */
    connect_dir_file(total_file_name);
    
    /* We try to delete the file/directory: */
    if(DeleteFile(total_file_name))
    {
      /* We have deleted the file/directory successfully: */
              if(*file_name != '\0')
      {
        /* A file was deleted: */
        *file_name='\0'; /* Take away the file name. */
        adjust_string_gadgets(); /* Adjust the string gadgets. */
        new_drawer(); /* Show the user the remaining files. */
      }
      else
      {
        /* A directory was deleted: */
        parent(); /* Go back one directory. */  
      }
    }
    else
    {
      /* Something went wrong: */
      if(*file_name != '\0')
        request_ok("Could NOT delete the file!");
      else
        request_ok("Could NOT delete directory!");
      
      /* Since we have unlocked the directory/file we have */
      /* to lock it again, and clean up the display: */
      new_drawer();
    }
  }
}

/* THE END */

