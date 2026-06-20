//************************************************************************
//
//                         AGA COPPER LIST EXAMPLE
//
//************************************************************************
//
//  This listing explains how to code a smashing AGA copper list using C
//  language. Originally it has been written for Emanuele Mainini.
//  Mainini's learning Amiga C and asked me how it's possible to write a
//  full AGA rainbow effect in C or assembly or even in Amos.
//  He had quite a good experience in Amos but never found infos on copper
//  AGA in Rom Kernel and other sources. This is because honestly RKM
//  still refers to ECS programming and Amos does not support AGA chips!
//  Well the question sounds like this: Is it possible write a smooth color
//  range using AGA in C or in Amos Professional ? Is it possible only in
//  assembly ?
//  Answer: Sure things, that's a really simple task in C (or asm!), about
//  Amos, I think it is possible, just poke BPLCON3 and use the normal
//  copper instruction provided by Amos, so you can have copper AGA
//  backgrounds even in ECS-Amos.
//
//  How this is possible: Well, copper hasn't changed a lot from ECS, so
//  registers are word sized and only a bit in BPLCON3 allows you shifting
//  from MSB (default) to LSB.
//  24-bits color is a 8-bits per gun entity, so RGB with 8 bits per component,
//  pure white is FFFFFF, pure red's FF0000, yellow FFFF00 and blue 0000FF.
//  For compatibility purposes, color registers have been split in 2 words:
//  the MSB and the LSB, so the four colors above in the same order will
//  be FFF-FFF, F00-F00, FF0-FF0, 00F-00F, that's, the same 12-bits colors
//  seem to be repeated twice! Well, this it's always TRUE for 12-bits
//  colors but almost never for 24-bits ones.
//  This expedient improves compatibility for an ECS machine will get
//  pure red as F00 while an AGA as F00-F00 (that's FF0000), if you
//  specified a different AGA red, F90000 the AGA will get it as
//  F00-900 (RGB-RGB) while ECS-mode as F00, so, as you can note, for every
//  monochrome ECS coordinate, AGA's can resolve 16 internal levels!
//  So to specify a 24-bits color you have to write 2 words, first the MSB
//  and then the LSB, note that the order it's very important 'coz Amiga
//  automatically duplicates the MSB content into LSB for compatibility.
//  The task is writing a twice long copper list, with doubled MOVE
//  instructions, and between them poking BPLCON3 register.
//  Building a copper list in C it's quite simple for the useful macros
//  ready-made, in Amos I think there are no problems at all, the only
//  thing to do, it's poking to 1 bit 9 in BPLCON3, when this bit's on
//  an access to a normal color register will be on LSB, on the other hand
//  when bit 9 is unset, (default) every color access will be on MSB,
//  so old programs continue to work normaly with 12-bits colors!
//  The correct procedure is:
//  ---------------------------------------------------------
//  ·copper-WAIT for beam coordinates
//  ·unset bit 9 of BPLCON3
//  ·copper-MOVE the 12-bits MSB-RGB into color word register
//  ·set bit 9 of BPLCON3
//  ·copper-MOVE the 12-bits LSB-RGB into color word register
//  ---------------------------------------------------------
//
//  Stefano Peruzzi
//  Medicine Dept.
//  Padova University - Italy
//  email: peru@maya.dei.unipd.it
//
//  PS) Let's support Amiga in scientific world, we need a lot of programs
//      math, physics, molecular biology, genetics ....etc. in spare time
//      I hope I will code something to fill up the gap.
//      Thanx to the author of CPK modeller, go on developing.
//
//  Bye, Steve.
//--------------------------------------------------------------------------

//----------  turn off SAS break control ----------
  int CXBRK(void) {return(0);}
  void chkabort(void) {return;}
//---------- Standard Output ----------
  char __stdiowin[]="CON:0/0/300/100/";
  char __stdiov37[]="/AUTO/CLOSE/WAIT";

// If you can, use GST file, and compilation will speed up!
#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <graphics/copper.h>
#include <graphics/videocontrol.h>
#include <intuition/intuition.h>
#include <intuition/preferences.h>
#include <hardware/custom.h>
#include <libraries/dos.h>
#include <stdlib.h>
#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>

// With "extern" I only declare libraries pointers, so SAS-C automagically
// will open every library and will close on exit!
extern  long  __oslibversion=39;
extern struct GfxBase        *GfxBase;
extern struct IntuitionBase  *IntuitionBase;

extern struct Custom far custom;
struct Screen *screen=NULL;
struct ViewPort *viewport;

void main(void);
WORD Copper(void);

void main(void)
{
  // A simple screen ...
  if(screen=OpenScreenTags(NULL,
                           SA_Title,"That's Amiga Copper!",
                           SA_LikeWorkbench,TRUE,
                           TAG_DONE));
    if(Copper())
    {
      // Let's wait a while ...
      Delay(500);

      // OK, we leave ...
      viewport=&screen->ViewPort;
      if (NULL!=viewport->UCopIns)
      {
        FreeVPortCopLists(viewport);
        RemakeDisplay();
      }
    }
    CloseScreen(screen);
}

WORD Copper(void)
{
// To build a 256 lines copper we need a pseudo 512 slots copper list,
// 2 copper-MOVE's per color!
#define NUMCOLORS 512

// A useful mask for bit 9 of BPLCON3
UWORD loct=1<<9;

register USHORT i;
WORD     ret=TRUE;
struct   UCopList *uCopList=NULL;
struct   TagItem  uCopTags[] ={{ VTAG_USERCLIP_SET,NULL},
                               { VTAG_END_CM,NULL}};

// This color list has been generated automatically by Chroma.
UWORD spectrum[]= {0xfff, 0xfff,
                   0xfff, 0xffe,
                   0xfff, 0xffd,
                   0xfff, 0xffc,
                   0xfff, 0xffb,
                   0xfff, 0xffa,
                   0xfff, 0xff9,
                   0xfff, 0xff8,
                   0xfff, 0xff7,
                   0xfff, 0xff6,
                   0xfff, 0xff5,
                   0xfff, 0xff4,
                   0xfff, 0xff3,
                   0xfff, 0xff2,
                   0xfff, 0xff1,
                   0xfff, 0xff0,

                   0xffe, 0xfff,
                   0xffe, 0xffe,
                   0xffe, 0xffd,
                   0xffe, 0xffc,
                   0xffe, 0xffb,
                   0xffe, 0xffa,
                   0xffe, 0xff9,
                   0xffe, 0xff8,
                   0xffe, 0xff7,
                   0xffe, 0xff6,
                   0xffe, 0xff5,
                   0xffe, 0xff4,
                   0xffe, 0xff3,
                   0xffe, 0xff2,
                   0xffe, 0xff1,
                   0xffe, 0xff0,

                   0xffd, 0xfff,
                   0xffd, 0xffe,
                   0xffd, 0xffd,
                   0xffd, 0xffc,
                   0xffd, 0xffb,
                   0xffd, 0xffa,
                   0xffd, 0xff9,
                   0xffd, 0xff8,
                   0xffd, 0xff7,
                   0xffd, 0xff6,
                   0xffd, 0xff5,
                   0xffd, 0xff4,
                   0xffd, 0xff3,
                   0xffd, 0xff2,
                   0xffd, 0xff1,
                   0xffd, 0xff0,

                   0xffc, 0xfff,
                   0xffc, 0xffe,
                   0xffc, 0xffd,
                   0xffc, 0xffc,
                   0xffc, 0xffb,
                   0xffc, 0xffa,
                   0xffc, 0xff9,
                   0xffc, 0xff8,
                   0xffc, 0xff7,
                   0xffc, 0xff6,
                   0xffc, 0xff5,
                   0xffc, 0xff4,
                   0xffc, 0xff3,
                   0xffc, 0xff2,
                   0xffc, 0xff1,
                   0xffc, 0xff0,

                   0xffb, 0xfff,
                   0xffb, 0xffe,
                   0xffb, 0xffd,
                   0xffb, 0xffc,
                   0xffb, 0xffb,
                   0xffb, 0xffa,
                   0xffb, 0xff9,
                   0xffb, 0xff8,
                   0xffb, 0xff7,
                   0xffb, 0xff6,
                   0xffb, 0xff5,
                   0xffb, 0xff4,
                   0xffb, 0xff3,
                   0xffb, 0xff2,
                   0xffb, 0xff1,
                   0xffb, 0xff0,

                   0xffa, 0xfff,
                   0xffa, 0xffe,
                   0xffa, 0xffd,
                   0xffa, 0xffc,
                   0xffa, 0xffb,
                   0xffa, 0xffa,
                   0xffa, 0xff9,
                   0xffa, 0xff8,
                   0xffa, 0xff7,
                   0xffa, 0xff6,
                   0xffa, 0xff5,
                   0xffa, 0xff4,
                   0xffa, 0xff3,
                   0xffa, 0xff2,
                   0xffa, 0xff1,
                   0xffa, 0xff0,

                   0xff9, 0xfff,
                   0xff9, 0xffe,
                   0xff9, 0xffd,
                   0xff9, 0xffc,
                   0xff9, 0xffb,
                   0xff9, 0xffa,
                   0xff9, 0xff9,
                   0xff9, 0xff8,
                   0xff9, 0xff7,
                   0xff9, 0xff6,
                   0xff9, 0xff5,
                   0xff9, 0xff4,
                   0xff9, 0xff3,
                   0xff9, 0xff2,
                   0xff9, 0xff1,
                   0xff9, 0xff0,

                   0xff8, 0xfff,
                   0xff8, 0xffe,
                   0xff8, 0xffd,
                   0xff8, 0xffc,
                   0xff8, 0xffb,
                   0xff8, 0xffa,
                   0xff8, 0xff9,
                   0xff8, 0xff8,
                   0xff8, 0xff7,
                   0xff8, 0xff6,
                   0xff8, 0xff5,
                   0xff8, 0xff4,
                   0xff8, 0xff3,
                   0xff8, 0xff2,
                   0xff8, 0xff1,
                   0xff8, 0xff0,

                   0xff7, 0xfff,
                   0xff7, 0xffe,
                   0xff7, 0xffd,
                   0xff7, 0xffc,
                   0xff7, 0xffb,
                   0xff7, 0xffa,
                   0xff7, 0xff9,
                   0xff7, 0xff8,
                   0xff7, 0xff7,
                   0xff7, 0xff6,
                   0xff7, 0xff5,
                   0xff7, 0xff4,
                   0xff7, 0xff3,
                   0xff7, 0xff2,
                   0xff7, 0xff1,
                   0xff7, 0xff0,
                   
                   0xff6, 0xfff,
                   0xff6, 0xffe,
                   0xff6, 0xffd,
                   0xff6, 0xffc,
                   0xff6, 0xffb,
                   0xff6, 0xffa,
                   0xff6, 0xff9,
                   0xff6, 0xff8,
                   0xff6, 0xff7,
                   0xff6, 0xff6,
                   0xff6, 0xff5,
                   0xff6, 0xff4,
                   0xff6, 0xff3,
                   0xff6, 0xff2,
                   0xff6, 0xff1,
                   0xff6, 0xff0,

                   0xff5, 0xfff,
                   0xff5, 0xffe,
                   0xff5, 0xffd,
                   0xff5, 0xffc,
                   0xff5, 0xffb,
                   0xff5, 0xffa,
                   0xff5, 0xff9,
                   0xff5, 0xff8,
                   0xff5, 0xff7,
                   0xff5, 0xff6,
                   0xff5, 0xff5,
                   0xff5, 0xff4,
                   0xff5, 0xff3,
                   0xff5, 0xff2,
                   0xff5, 0xff1,
                   0xff5, 0xff0,

                   0xff4, 0xfff,
                   0xff4, 0xffe,
                   0xff4, 0xffd,
                   0xff4, 0xffc,
                   0xff4, 0xffb,
                   0xff4, 0xffa,
                   0xff4, 0xff9,
                   0xff4, 0xff8,
                   0xff4, 0xff7,
                   0xff4, 0xff6,
                   0xff4, 0xff5,
                   0xff4, 0xff4,
                   0xff4, 0xff3,
                   0xff4, 0xff2,
                   0xff4, 0xff1,
                   0xff4, 0xff0,

                   0xff3, 0xfff,
                   0xff3, 0xffe,
                   0xff3, 0xffd,
                   0xff3, 0xffc,
                   0xff3, 0xffb,
                   0xff3, 0xffa,
                   0xff3, 0xff9,
                   0xff3, 0xff8,
                   0xff3, 0xff7,
                   0xff3, 0xff6,
                   0xff3, 0xff5,
                   0xff3, 0xff4,
                   0xff3, 0xff3,
                   0xff3, 0xff2,
                   0xff3, 0xff1,
                   0xff3, 0xff0,

                   0xff2, 0xfff,
                   0xff2, 0xffe,
                   0xff2, 0xffd,
                   0xff2, 0xffc,
                   0xff2, 0xffb,
                   0xff2, 0xffa,
                   0xff2, 0xff9,
                   0xff2, 0xff8,
                   0xff2, 0xff7,
                   0xff2, 0xff6,
                   0xff2, 0xff5,
                   0xff2, 0xff4,
                   0xff2, 0xff3,
                   0xff2, 0xff2,
                   0xff2, 0xff1,
                   0xff2, 0xff0,

                   0xff1, 0xfff,
                   0xff1, 0xffe,
                   0xff1, 0xffd,
                   0xff1, 0xffc,
                   0xff1, 0xffb,
                   0xff1, 0xffa,
                   0xff1, 0xff9,
                   0xff1, 0xff8,
                   0xff1, 0xff7,
                   0xff1, 0xff6,
                   0xff1, 0xff5,
                   0xff1, 0xff4,
                   0xff1, 0xff3,
                   0xff1, 0xff2,
                   0xff1, 0xff1,
                   0xff1, 0xff0,

                   0xff0, 0xfff,
                   0xff0, 0xffe,
                   0xff0, 0xffd,
                   0xff0, 0xffc,
                   0xff0, 0xffb,
                   0xff0, 0xffa,
                   0xff0, 0xff9,
                   0xff0, 0xff8,
                   0xff0, 0xff7,
                   0xff0, 0xff6,
                   0xff0, 0xff5,
                   0xff0, 0xff4,
                   0xff0, 0xff3,
                   0xff0, 0xff2,
                   0xff0, 0xff1,
                   0xff0, 0xff0};

  uCopList=(struct UCopList *)
    AllocMem(sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CLEAR);

  if (NULL == uCopList)
     ret=NULL;
  else
  {
    CINIT(uCopList, NUMCOLORS);
    
    // The core: copper list generation!
    for (i=0; i<NUMCOLORS; i++)
      {
      // copper-WAIT for beam Y coordinate
      CWAIT(uCopList,i,0);
      // unset LOCT bit using copper
      CMOVE(uCopList,custom.bplcon3,0);
      // set 12-bits MSB in color register 0
      CMOVE(uCopList,custom.color[0],spectrum[i]);
      // set LOCT bit in BPLCON3
      CMOVE(uCopList,custom.bplcon3,loct);
      // set 12-bits LSB in color register 0
      CMOVE(uCopList,custom.color[0],spectrum[++i]);
      }
    // that's enough
    CEND(uCopList);

    viewport=&screen->ViewPort;
    // Better forbid a while ...
    Forbid();
    viewport->UCopIns=uCopList;
    Permit();
    // We're to go!
    (void) VideoControl(viewport->ColorMap,uCopTags);
    RethinkDisplay();

    return(ret);
  }
}

