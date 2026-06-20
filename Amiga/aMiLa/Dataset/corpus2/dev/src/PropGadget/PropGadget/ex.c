/*  The ill-timed truth we might have kept,
    who knows how sharply it pierced and stung?
    The works we had not the sense to say,
    who knows how grandly they'd have rung?		Milton Sills
*/
/*          Jerry J. Trantow                                                  */
/*          1560 A East Irving Place                                          */
/*          Milwaukee, Wi 53202-1460                                          */
/*   The purpose of this program is to illustrate how to calculate the body   */
/*   and pot values in the PropGadget structure.  Many examples I have seen   */
/*   either overflow the LONG variable or don't use all the resolution        */
/*   available.  If your proportional gadgets act funny when you use values   */
/*   greater than 64K you are probably overflowing. One solution is to use    */
/*   floating point for the calculations. I prefer to stay with fixed point   */
/*   math.  Note it would be easy to convert this to assembly, but this is    */
/*   meant to be an easy to understand example.                               */

/* 4 Dec 88 Started Example program to illustrate use of proportional Gadgets */
/* 6 Dec 88 Proportional, arrow, and OK gadgetry all set up                   */
/* 7 Dec 88 Added the Calculated IntuiText                                    */
/* 2 Jan 89 Explicitly declared Font to be Topaz, overrides setfont           */
/* 2 Jan 89 Decided to remove Vertical Scroll Gadget for simplicity           */
/* 4 Jan 89 Started Implementation of Reverse Calculation		      */
/* 4 Jan 89 Deleted Cancel Gadget                                             */
/* 4 Jan 89 Essentially Finished                                              */
/* 5 Jan 89 Note that I rely on the UserData pointing to the Scroll Gadget    */
/* 8 Jan 89 Decided that a 32x32=64 Multiply was really required              */
/* 12 Jan 89 Also added a 64/32=64 bit Divide                                 */
/* 22 Jan 89 Finished Lucas board, back to programming                        */
/* 24 Jan 89 Added Limit checking for illegal values                          */
/* 29 Jan 89 Changed Dynamic Gadgets to statics for demo purposes             */
/* 30 Jan 89 Cleaned up the Gadgetry and comments                             */
/* 30 Jan 89 Added an 020 QuadMult routine for added performance              */
/* 30 Jan 89 Added Code and IDCMP flags to do calculations on MouseMovements  */
/*  1 Feb 89 Changed variable names to be closer to Harriet Tolly's article   */
/*  4 Feb 89 Compiles under either Lattice or Aztec with minimal Warnings     */
/*  -------------------------- Submitted to Amazing Computing --------------- */
/* 18 Feb 89 looks for 020/881 in the inline version		              */

#include <exec/types.h>
#include <exec/devices.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>

#ifdef AZTEC_C
  #include <functions.h>
  #define min(x,y) ((x)<(y) ? (x) : (y))
  ULONG  Prop_Gad_Reverse();
  USHORT Prop_Gad_Calculate();
  void   CleanUp();
  void   GadgetUpHandler();
  void   QuadMult020();
  void   QuadDiv020();
  void   QuadAdd();
  void   QuadMult68000();
  void   QuadDiv68000();
  #define FAST register
#endif
#ifdef LATTICE
  #include <stdio.h>
  #include <stdlib.h>
  #include <proto/all.h>
  ULONG  Prop_Gad_Reverse(ULONG,ULONG,ULONG);
  USHORT Prop_Gad_Calculate(ULONG,ULONG,ULONG,ULONG *,ULONG *);
  void   CleanUp(TEXT *);
  void   GadgetUpHandler(struct IntuiMessage *);
  void   QuadMult020(ULONG,ULONG,ULONG *);
  void   QuadDiv020(ULONG *,ULONG);
  void   QuadAdd(ULONG,ULONG *);
  void   QuadMult68000(ULONG,ULONG,ULONG *);
  void   QuadDiv68000(ULONG *,ULONG);
  #define FAST 		 	/* supposedly Lattice knows better */
#endif
				
#define  LEFTARROWGAD      (1)		/*  Definitions for Gadget ID */ 
#define  RIGHTARROWGAD     (2)
#define  HORIZSCROLLGAD    (3)

#define GAD_OK          (100)
#define GAD_Total	(102)		/* these are string gadgets */
#define GAD_First	(103)
#define GAD_Visible	(104)
    
#define MAXBUF  15
#include "prop.inc" 		/* this could be compiled individually but */
#include "clean2.inc"           /* this is easier for the novice to follow */
#include "struct.inc"		

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct ExecBase *ExecBase;

void main()
{      
  FAST struct Window *WPtr;  /* Points to the Window where everything happens */
  FAST struct RastPort *RPtr;
  FAST struct IntuiMessage *MyIntuiMessage;
  FAST struct Gadget *GPtr;

  ULONG GHBody,GHPot;
  FAST SHORT MouseFlag,CLOSEFlag;

  IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0L);
  if (IntuitionBase==NULL) CleanUp("Can not open Intuition.library.");
  GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0L);
  if (GfxBase==NULL) CleanUp("Can not open graphics library.");
  ExecBase=(struct ExecBase *)OpenLibrary("exec.library",0L);
  if (ExecBase==NULL) CleanUp("Can not open Exec Library.");

#ifdef machine=MC68020
  if ((ExecBase->AttnFlags&(UWORD)(AFB_68020))!=AFB_68020)
    CleanUp("020 needed for this .version!!\n");
#endif
 
  sprintf(TotalGadBuffer, "%ld",TotalString.LongInt);	/* Initialize Buffers */
  sprintf(VisibleGadBuffer, "%ld",VisibleString.LongInt);
  sprintf(FirstGadBuffer,"%ld",FirstString.LongInt);
  sprintf(GadUndoBuffer,  "0");

  WPtr=(struct Window *)OpenWindow((struct NewWindow *)&NewWindow);
  if (WPtr==NULL) CleanUp("Can not open Window.");

  RPtr=WPtr->RPort;
  CLOSEFlag=FALSE;

  Prop_Gad_Calculate(VisibleString.LongInt,FirstString.LongInt,TotalString.LongInt,&GHBody,&GHPot);
  sprintf(HBufferBody,"Body Value %04lx",GHBody);
  sprintf(HBufferPot, "Pot Value  %04lx",GHPot);
  PrintIText(RPtr,(struct IntuiText *)&HorizText,120L,75L);

  ModifyProp(&ScrollGadget,WPtr,NULL,(LONG)AUTOKNOB|FREEHORIZ,GHPot,0L,GHBody,0L);
	     
  while (CLOSEFlag==FALSE)
  { 
    MouseFlag=FALSE;
    Wait((LONG)(1L<<(LONG)WPtr->UserPort->mp_SigBit));
    while (MyIntuiMessage=(struct IntuiMessage *)GetMsg((struct MsgPort *)WPtr->UserPort))
    { 
      switch (MyIntuiMessage->Class)
      {
        case CLOSEWINDOW:		/* close a project */
          CLOSEFlag=TRUE;		/* don't close until messages answered */
          ReplyMsg((struct Message *)MyIntuiMessage);	
          break;
        case MOUSEMOVE:		/* accumulate Mouse Movements */
          MouseFlag=TRUE;
          ReplyMsg((struct Message *)MyIntuiMessage);	
          break;
        case GADGETUP:		/* adjust the cursors to the scroll gadget */
          MouseFlag=FALSE;
          GPtr=(struct Gadget *)MyIntuiMessage->IAddress;
          switch (GPtr->GadgetID)
          {
           case HORIZSCROLLGAD:		/* reverse calculation */
             FirstString.LongInt=(ULONG)Prop_Gad_Reverse(TotalString.LongInt,VisibleString.LongInt,(ULONG)ScrollPropInfo.HorizPot);
             sprintf(FirstGadBuffer,"%lu",FirstString.LongInt);
             break;
           case LEFTARROWGAD:		/* move ONE SAMPLE */
             if (FirstString.LongInt>0L)
               FirstString.LongInt-=1L;
             else
               FirstString.LongInt=0L;
             sprintf(FirstGadBuffer,"%ld",FirstString.LongInt);
             break;
           case RIGHTARROWGAD:		/* move ONE SAMPLE */
             if (VisibleString.LongInt+FirstString.LongInt<TotalString.LongInt)
               FirstString.LongInt+=1L;
             else 
               FirstString.LongInt=TotalString.LongInt-VisibleString.LongInt;
             sprintf(FirstGadBuffer,"%ld",FirstString.LongInt);
             break;
           case GAD_Total:
           case GAD_First:
           case GAD_Visible:
           case GAD_OK:
             VisibleString.LongInt=min(VisibleString.LongInt,TotalString.LongInt);
             sprintf(VisibleGadBuffer,"%ld",VisibleString.LongInt);
             FirstString.LongInt=min(FirstString.LongInt,TotalString.LongInt-VisibleString.LongInt);
             sprintf(FirstGadBuffer,"%ld",FirstString.LongInt);
             break;
/*           default:
             CleanUp("GadgetPtr->GadgetID was invalid\n");
             break; */	/* this break is only for consistancy */
          }

          if (GPtr->UserData!=NULL)	/* catches OK,Arrow, and Scroll Gads */
          {
            Prop_Gad_Calculate(VisibleString.LongInt,FirstString.LongInt,TotalString.LongInt,&GHBody,&GHPot);
            sprintf(HBufferBody,"Body Value %04lx",GHBody);
            sprintf(HBufferPot, "Pot Value  %04lx",GHPot);   
            ModifyProp((struct Gadget *)GPtr->UserData,WPtr,NULL,(LONG)AUTOKNOB|FREEHORIZ,GHPot,0L,GHBody,0L);
            PrintIText(RPtr,(struct IntuiText *)&HorizText,120L,75L);
          }
          ReplyMsg((struct Message *)MyIntuiMessage);
          break;
/*        default:			
            CleanUp("Unknown IntuiMessage in switch(Class)");
  	    break;	 */
      } /* switch (Class) */
    }   /* end of IntuiMessages */
    if (MouseFlag==TRUE)
    {
      FirstString.LongInt=(ULONG)Prop_Gad_Reverse(TotalString.LongInt,VisibleString.LongInt,(ULONG)ScrollPropInfo.HorizPot);
      sprintf(FirstGadBuffer,"%lu",FirstString.LongInt);
      sprintf(HBufferPot, "Pot Value  %04x",(USHORT)ScrollPropInfo.HorizPot);  
      PrintIText(RPtr,(struct IntuiText *)&HorizText,120L,75L);
      RefreshGadgets(&FirstGadget,WPtr,NULL);
      MouseFlag=FALSE;
    }
  }   
  CloseWindow(WPtr);
  CleanUp("Clean Finish");
}
