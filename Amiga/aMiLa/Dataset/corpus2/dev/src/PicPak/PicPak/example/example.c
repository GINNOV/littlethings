/***********************************************************
*                                                          *
* example.c                                                *
*                                                          *
* example of use of the picpak picture viewer              *
*                                                          *
* I have added a sample picture called 'doggy.iff', which  *
* is automatically loaded if you supply no arguments       *
*                                                          *
* I have also given you two ways to compile the file :     *
*    WAY1 - uses source code, and compiles to example1     *
*    WAY2 - uses object code, and compiles to example2     *
*                                                          *
* This file created by Mark Carter 23.10.95 from original  *
* source in picpak.doc                                     *
*                                                          *
***********************************************************/




/* this image viewer supports SHAM-format images too */


#include <graphics/gfxmacros.h>
#include <intuition/intuitionbase.h>
#include <exec/interrupts.h> /* define Interrupt() and List functions */
#include <exec/memory.h>  /* defines MEMF_CLEAR etc. */
#include <hardware/intbits.h> /* defines INTB_VERTB */
#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>



#include "/picpak/picpak.h"

/* two valid ways of compiling : */
#ifndef WAY2              /* i.e. we use WAY1 */
   #include "/picpak/picpak.c"
#endif
/* WAY2 is implemented via the dmakefile */


extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;

struct NewScreen ns;

main(argc, argv)
int argc;
char *argv[];
{
   struct Screen *screen;
   struct Pic *pic;

   /* open up the ROM libs */
   GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0L);
   IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0L);


   /* attempt to load the Picture */
   /* if no args supplied, load a default file called doggy.iff -
      else load specified file */
   if(argc<2)
      pic=LoadPic("doggy.iff",MEMTYPE_CHIP);
   else
      pic = LoadPic(argv[1], MEMTYPE_CHIP);
   
   if (!pic)
   {
      CloseLibrary((struct Library *)IntuitionBase);
      CloseLibrary((struct Library *)GfxBase);
      puts("Couldn't open picture.");
      exit(1);
   }


   /* clear out and initialize the NewScreen from the Pic data */
   setmem(&ns, sizeof(struct NewScreen), 0L);
   ns.Width = pic->Width;
   ns.Height = pic->Height;
   ns.Depth = pic->Depth;
   ns.ViewModes = (UWORD)pic->ViewModes;
   ns.Type = CUSTOMSCREEN | CUSTOMBITMAP | SCREENQUIET | SCREENBEHIND;
   ns.CustomBitMap = &pic->BitMap;

   screen = OpenScreen(&ns);
   if (screen)
   {
      ClearViewPortColors(&screen->ViewPort, pic->Colors);

      /* SHAM pics must be on top when initialized with InitSHAM() */
      ScreenToFront(screen);

      /* test for special image types */
      if (pic->Type == PICTYPE_SHAM)
         InitSHAM(&screen->ViewPort, pic);   /* can't fade SHAMs (yet) */
      else
         FadeViewPortIn(&screen->ViewPort, &pic->Colormap[0], pic->Colors);

      /* NOTE: SetViewPortPicColors(&screen->ViewPort, pic);
          will accomplish the above test and color palette initialization */

      ScreenToFront(screen);

      Delay(500);                   /* ... pause.... */

      if (pic->Type != PICTYPE_SHAM)         /* can't fade a SHAMs (yet) */
         FadeViewPortOut(&screen->ViewPort, pic->Colors);

      ScreenToBack(screen);
      CloseScreen(screen);          /* close up the Screen */
   }
   if (pic) FreePic(pic);           /* free up the Pic */

   CloseLibrary((struct Library *)IntuitionBase);
   CloseLibrary((struct Library *)GfxBase);
}
