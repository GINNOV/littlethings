/*
 * Copyright (c) 1994. Author: Jason Petty.
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *
 *     GadTools.c:
 *
 *     GadTool functions. (gadtools.library, V36 or higher)
 */

#include <exec/types.h>
#include <clib/stdio.h>
#include <intuition/intuition.h>
#include <libraries/gadtools.h>

#ifndef STRING_H
#include <clib/string.h>
#endif

#include "pools.h"

extern struct Screen *my_screen;   /* Screen all windows are attached to. */
struct Gadget *gt_gadlist=0;       /* Head of leagues Gadget list.        */
struct Gadget *sl_gadlist=0;       /* Head of choose league Gadget list.  */
struct TagItem up_cycleTags1[2];

APTR gt_visual=0;                  /* Screen private data for GadTools.   */

char *CycleNames1[] = {"YES","NO", NULL}; /* Cycle gadget names. */
char *CycleNames2[] = {"NO","YES", NULL};
char *CycleNames3[] = {"ON","OFF", NULL};
char *CycleNames4[] = {"OFF","ON", NULL};
char *CycleNames5[] = {"32 BIT","16 BIT", NULL};
char *CycleNames6[] = {"16 BIT","32 BIT", NULL};


/* BUTTON GADGET FUNCTIONS. */
struct Gadget *MakeButtonGad(name,prevGad,vis,lE,tE,w,h)
UBYTE *name;
struct Gadget *prevGad;
APTR vis;
WORD lE,tE,w,h;
{
 struct Gadget *mcgad;
 chip struct NewGadget newGad;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
   if(name)
     newGad.ng_GadgetText = (UBYTE *)name;
   else
     newGad.ng_GadgetText = NULL;
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = 0L;
     newGad.ng_Flags = PLACETEXT_IN|NG_HIGHLABEL;
     newGad.ng_VisualInfo = vis;
     newGad.ng_UserData = NULL;

   if(!(mcgad = (struct Gadget *)
     CreateGadgetA(BUTTON_KIND,prevGad,&newGad,NULL))) /* No tags needed. */
     return(NULL);

 return(mcgad);
}

/* CYCLE GADGET FUNCTIONS. */
void SetCycleTags(sc_tags,sc_type)   /* Set Tags for Cycle Gadget. */
struct TagItem sc_tags[2];
int sc_type;
{
   sc_tags[0].ti_Tag = GTCY_Labels;

   switch(sc_type)  /* Set cycle Messages. */
    {
      case YES_NO: sc_tags[0].ti_Data = (ULONG)CycleNames1;
                   break;
      case NO_YES: sc_tags[0].ti_Data = (ULONG)CycleNames2;
                   break;
      case ON_OFF: sc_tags[0].ti_Data = (ULONG)CycleNames3;
                   break;
      case OFF_ON: sc_tags[0].ti_Data = (ULONG)CycleNames4;
                   break;
      case BIT32_BIT16: sc_tags[0].ti_Data = (ULONG)CycleNames5;
                   break;
      case BIT16_BIT32: sc_tags[0].ti_Data = (ULONG)CycleNames6;
                   break;
      default:     sc_tags[0].ti_Data = (ULONG)CycleNames1;
                   break;
     }
   sc_tags[1].ti_Tag = TAG_DONE;
  sc_tags[1].ti_Data = TAG_DONE;
}

struct Gadget *MakeCycleGad(name,prevGad,CTags,vis,lE,tE,w,h)
UBYTE *name;
struct Gadget *prevGad;
struct TagItem CTags[2];
APTR vis;
WORD lE,tE,w,h;
{
 struct Gadget *mcgad;
 struct NewGadget newGad;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
     newGad.ng_GadgetText = (UBYTE *)name;
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = 0L;
     newGad.ng_Flags = PLACETEXT_LEFT|NG_HIGHLABEL;
     newGad.ng_VisualInfo = vis;
     newGad.ng_UserData = NULL;

   if(!(mcgad = (struct Gadget *)
     CreateGadgetA(CYCLE_KIND,prevGad,&newGad,CTags)))
     return(NULL);

 return(mcgad);
}


/* STRING GADGET FUNCTIONS. */
void SetStringTags(ss_tags,ss_msg,slen)   /* Set Tags for String Gadget. */
struct TagItem ss_tags[3];
char *ss_msg;
int slen;
{
      ss_tags[0].ti_Tag = GTST_String;

   if(ss_msg)    /* If Gad message string exists, use it. */
       ss_tags[0].ti_Data = (ULONG)ss_msg;
     else
       ss_tags[0].ti_Data = NULL;

      ss_tags[1].ti_Tag = GTST_MaxChars;
    ss_tags[1].ti_Data = (ULONG)slen;   /* Max typed chars. */
  ss_tags[2].ti_Tag = TAG_DONE;
ss_tags[2].ti_Data = TAG_DONE;
}

struct Gadget *MakeStringGad(name,prevGad,CTags,vis,lE,tE,w,h)
UBYTE *name;
struct Gadget *prevGad;
struct TagItem CTags[3];
APTR vis;
WORD lE,tE,w,h;
{
 struct Gadget *mcgad;
 struct NewGadget newGad;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
     newGad.ng_GadgetText = (UBYTE *)name;
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = 0L;
     newGad.ng_Flags = PLACETEXT_LEFT|NG_HIGHLABEL;
     newGad.ng_VisualInfo = vis;
     newGad.ng_UserData = NULL;

   if(!(mcgad = (struct Gadget *)
     CreateGadgetA(STRING_KIND,prevGad,&newGad,CTags)))
     return(NULL);

 return(mcgad);
}


/* INTEGER GADGET FUNCTIONS. */
struct Gadget *MakeIntegerGad(name,prevGad,vis,lE,tE,w,h)
UBYTE *name;
struct Gadget *prevGad;
APTR vis;
WORD lE,tE,w,h;
{
 struct Gadget *mcgad;
 struct NewGadget newGad;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
   if(name)
     newGad.ng_GadgetText = (UBYTE *)name;
   else
     newGad.ng_GadgetText = NULL;
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = 0L;
     newGad.ng_Flags = PLACETEXT_LEFT;
     newGad.ng_VisualInfo = vis;
     newGad.ng_UserData = NULL;

   if(!(mcgad = (struct Gadget *)
     CreateGadgetA(INTEGER_KIND,prevGad,&newGad,NULL))) /* No tags needed. */
     return(NULL);

 return(mcgad);
}

int Alloc_VisualInfoA() /* Get visual info for gadtools. */
{
  if(!(gt_visual = (APTR)GetVisualInfoA(my_screen, NULL)))
      return(NULL);
  return(1);
}

void Free_VisualInfo() /* Free memory allocated with Alloc_VisualInfoA(). */
{                      /* NOTE: call just before CloseScreen(). */
  if(gt_visual)
   FreeVisualInfo(gt_visual);
}


/* MOST FUNCTIONS FROM HERE ON ,USE THE ABOVE FUNCTIONS!!. */
int Alloc_L_Gadgets()    /* Allocate LEAGUE window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;
  int inn = INN_X;       /* Left row gads start x.  */
  int mid = MID_X;       /* Middle row gads start x.*/
  int out = OUT_X;       /* Right row gads start x. */
  int t = TOP_Y;         /* Start y for all gads.   */
  int g = GAP_Y;         /* Gap between gads in y direction. */
  int h = WID_Y;         /* Height of each gad.     */
 
/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&gt_gadlist)))
        return(NULL);

/* BUTTON GAD 1. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"1",
     prevGad,gt_visual,inn,t,24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 2. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"2",
     nextGad,gt_visual,mid,t,24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 3. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"3",
     prevGad,gt_visual,out,t,24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 4. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"4",
     nextGad,gt_visual,inn,t+h+g,24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 5. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"5",
     prevGad,gt_visual,mid,t+h+g,24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 6. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"6",
     nextGad,gt_visual,out,t+h+g,24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 7. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"7",
     prevGad,gt_visual,inn,t+((h+g)*2),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 8. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"8",
     nextGad,gt_visual,mid,t+((h+g)*2),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 9. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"9",
     prevGad,gt_visual,out,t+((h+g)*2),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 10. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"10",
     nextGad,gt_visual,inn,t+((h+g)*3),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 11. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"11",
     prevGad,gt_visual,mid,t+((h+g)*3),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 12. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"12",
     nextGad,gt_visual,out,t+((h+g)*3),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 13. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"13",
     prevGad,gt_visual,inn,t+((h+g)*4),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 14. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"14",
     nextGad,gt_visual,mid,t+((h+g)*4),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 15. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"15",
     prevGad,gt_visual,out,t+((h+g)*4),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 16. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"16",
    nextGad,gt_visual,inn,t+((h+g)*5),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 17. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"17",
     prevGad,gt_visual,mid,t+((h+g)*5),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 18. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"18",
     nextGad,gt_visual,out,t+((h+g)*5),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 19. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"19",
     prevGad,gt_visual,inn,t+((h+g)*6),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 20. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"20",
     nextGad,gt_visual,mid,t+((h+g)*6),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 21. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"21",
     prevGad,gt_visual,out,t+((h+g)*6),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 21. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"22",
     nextGad,gt_visual,inn,t+((h+g)*7),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 23. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"23",
     prevGad,gt_visual,mid,t+((h+g)*7),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 24. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"24",
     nextGad,gt_visual,out,t+((h+g)*7),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 25. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"25",
     prevGad,gt_visual,inn,t+((h+g)*8),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 26. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"26",
     nextGad,gt_visual,mid,t+((h+g)*8),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 27. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"27",
     prevGad,gt_visual,out,t+((h+g)*8),24,h)))
     {
       return(NULL);
      }

/* BUTTON GAD 29. "Help". */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Help",
     nextGad,gt_visual,inn-55,RS_Y-42,42,h)))
     {
       return(NULL);
      }

/* CYCLE GAD1. "Printer" */
     SetCycleTags(up_cycleTags1,OFF_ON);

 if(!(nextGad = MakeCycleGad((UBYTE *)"Printer",
     prevGad,up_cycleTags1,gt_visual,inn+101,RS_Y-42,68,h)))
     {
       return(NULL);
      }

/* BUTTON GAD 28. "Print-Heading". */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Print-Heading",
     nextGad,gt_visual,mid+60,RS_Y-42,114,h)))
     {
       return(NULL);
      }

/* INT GAD1. "Set_Coupon-No" */
 if(!(nextGad = MakeIntegerGad((UBYTE *)"Set_Coupon-No",
     prevGad,gt_visual,out+120,RS_Y-42,42,h)))
     {
      return(NULL);
      }

  if(!(Alloc_D_Gadgets()))  /* Alloc_D_Gadgets while we are on. */
      return(NULL);

return(1); /* Ok!!. */
}

int Alloc_D_Gadgets()  /* Allocate 'Choose LEAGUE' gfx_window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;
  int out = c_OUT_X;     /* right row gads start x. */
  int t = c_TOP_Y;       /* start y for all gads.   */
  int g = c_GAP_Y;       /* gap between gads in y direction. */
  int h = c_WID_Y;       /* Height of each gad.     */
 
/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&sl_gadlist)))
        return(NULL);

/* BUTTON GAD 1. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"1",
     prevGad,gt_visual,out,t,24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 2. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"2",
     nextGad,gt_visual,out,t+h+g,24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 3. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"3",
     prevGad,gt_visual,out,t+((h+g)*2),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 4. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"4",
     nextGad,gt_visual,out,t+((h+g)*3),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 5. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"5",
     prevGad,gt_visual,out,t+((h+g)*4),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 6. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"6",
     nextGad,gt_visual,out,t+((h+g)*5),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 7. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"7",
     prevGad,gt_visual,out,t+((h+g)*6),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 8. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"8",
     nextGad,gt_visual,out,t+((h+g)*7),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 9. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"9",
     prevGad,gt_visual,out,t+((h+g)*8),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 10. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"10",
     nextGad,gt_visual,out,t+((h+g)*9),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 11. */
 if(!(nextGad = MakeButtonGad((UBYTE *)"11",
     prevGad,gt_visual,out,t+((h+g)*10),24,h)))
     {
       return(NULL);
      }
/* BUTTON GAD 12. */
 if(!(prevGad = MakeButtonGad((UBYTE *)"12",
     nextGad,gt_visual,out,t+((h+g)*11),24,h)))
     {
       return(NULL);
      }

return(1); /* OK!! */
}

void Free_GT_Gadgets() /* Free all GadTools gadget memory. */
{                      /* NOTE: g_window must be closed before this call.*/
   if(gt_gadlist)
           FreeGadgets(gt_gadlist);  /* League gadgets. */
   if(sl_gadlist)
           FreeGadgets(sl_gadlist);  /* choose league gadgets. */
}

