/* Copyright (c) 1994, by Jason Petty.
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
 * Hce_GadTools.c:
 *
 *     Make: Cycle/String/Button/CheckBox and Integer Gadgets.
 *     Note: requires gadtools.library - V36 or higher. (WB 2.0)
 */

#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <exec/memory.h>
#include <libraries/gadtools.h>
#include <intuition/gadgetclass.h>

#include <clib/string.h>
#include <clib/stdio.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_GadTools.h"

#define FGP BACK_PEN    /* (Black?). Used with old button gadgets. */
#define BGP MAIN_PEN    /* (Light-Grey?) */

/* Gadget lists to determin which gadgets will be displayed in 'g_window'.*/
struct Gadget *c_gadlist = NULL;   /* Head of Compiler Gadget list.  */
struct Gadget *o_gadlist = NULL;   /* Head of Optimizer Gadget list. */
struct Gadget *a_gadlist = NULL;   /* Head of Assembler Gadget list. */
struct Gadget *l_gadlist = NULL;   /* Head of Linker Gadget list.    */
struct Gadget *f_gadlist = NULL;   /* Head of Find Gadget list.      */
struct Gadget *r_gadlist = NULL;   /* Head of Replace Gadget list.   */
struct Gadget *j_gadlist = NULL;   /* Head of Jump to, Gadget list.  */
struct Gadget *p_gadlist = NULL;   /* Head of Printer, Gadget list.  */
struct Gadget *prefs_glist = NULL; /* Head of Prefs, Gadget list.    */
struct Gadget *req_glist = NULL;   /* Head of Requester, Gadget list.*/

/* This list gets attached to 'gfx_window' */
chip struct Gadget *gb_gadlist = NULL;  /* Head of Gadget Bar Gadget list.*/

APTR gt_visual=0;                       /* Screen private data for GadTools.*/
extern char *def_LIBS;                  /* Default linker libraries. */

/* Cycle gadget strings. */
char *CycleNames1[] = {"YES","NO", NULL};
char *CycleNames2[] = {"NO","YES", NULL};
char *CycleNames3[] = {"ON","OFF", NULL};
char *CycleNames4[] = {"OFF","ON", NULL};
char *CycleNames5[] = {"32 BIT","16 BIT", NULL};
char *CycleNames6[] = {"16 BIT","32 BIT", NULL};
char *CycleNames7[] = {"FROM-EDITOR","FROM-LIST","FROM-BOTH",NULL};
char *CycleNames8[] = {"FROM-ASSEM","FROM-LIST","FROM-BOTH",NULL};
char *CycleNames9[] = {"WAIT-FOR-DELAY","WAIT-FOR-KEY",NULL};

/* Store Cycle Gadget button states. */
/* These arrays indicate which flags will be sent to the C/O/A and Linker, */
/* and also set the appropriate button states for the various, */
/* cycle/checkbox gadgets. */

int  C_GadBN[CBN_NUM] = 0;
int  O_GadBN[OBN_NUM] = 0;
int  A_GadBN[ABN_NUM] = 0;
int  L_GadBN[LBN_NUM] = 0;
WORD P_GadBN[PBN_NUM] = 0;

/* Store String Gadget Strings. */
/* These buffers store information which will be sent to the */
/* C/O/A and Linker, and are also set or Shown in the appropriate */
/* string gadgets. */

/* Compiler Buffers. */
char C_DefSym[GB_MIN];
char C_UnDefSym[GB_MIN];
char C_IDirList[GB_OTHER];
char C_QuadDev[GB_MIN];
char C_WorkList[GB_LSIZE];
char C_Pattern[GB_MIN];
char C_Debug[GB_TINY];

/* Optimizer Buffers. */
/* None exist as yet!. */

/* Assembler Buffers. */
char A_IncHeader[GB_OTHER];
char A_IDirList[GB_MAX];
char A_CListFile[GB_MIN];
char A_OutPath[GB_MIN];
char A_Debug[GB_MIN];

/* Linker Buffers. */
char L_StartOBJ[GB_MIN];
char L_LinkList[GB_LSIZE];
char L_Libs[GB_EXT];
char L_MathLib[GB_MIN];
char L_OutName[GB_MIN];
char L_Pattern[GB_MIN];
char L_LibOut[GB_MIN];

/* Other Buffers. */
char Search_Name[GB_OTHER];
char Replace_Name[GB_OTHER];
char ReqBuf[GB_OTHER];
int jump_to_num=1;


/* DRAW A GADTOOLS BEVEL BOX. (g_window). */
void bevelbox_A(x,y,w,h,flg)
WORD x,y,w,h,flg;
{
  struct TagItem tg[3];
  tg[0].ti_Tag = GT_VisualInfo;
  tg[0].ti_Data = (ULONG)gt_visual;
 if(flg) {                       /* Draw box with inword effect. */
        tg[1].ti_Tag = GTBB_Recessed;
        tg[1].ti_Data = 1L;
        tg[2].ti_Tag = TAG_DONE;
        tg[2].ti_Data = TAG_DONE;
   }
  else {                         /* Draw box with outword effect.(default)*/
        tg[1].ti_Tag = TAG_DONE;
        tg[1].ti_Data = TAG_DONE;
        }
  DrawBevelBoxA(g_rp,x,y,w,h,tg);
}

/* SLIDER GADGET. */
struct Gadget *MakeSlideGad(name,prevGad,lE,tE,w,h)
UBYTE *name;
struct Gadget *prevGad;
WORD lE,tE,w,h;
{
  struct NewGadget newGad;
  struct Gadget *g;
  struct TagItem tg[3];

/*   tg[0].ti_Tag = GA_Immediate; */
/*   tg[0].ti_Data = 1;           */
     tg[0].ti_Tag = GA_RelVerify;
     tg[0].ti_Data = 1;
     tg[1].ti_Tag = PGA_Freedom;
     tg[1].ti_Data = LORIENT_HORIZ;
     tg[2].ti_Tag = TAG_DONE;
     tg[2].ti_Data = TAG_DONE;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
     newGad.ng_GadgetText = (UBYTE *)name;
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = 0L;
     newGad.ng_Flags = PLACETEXT_LEFT;
     newGad.ng_VisualInfo = (APTR)gt_visual;
     newGad.ng_UserData = NULL;

   if(!(g = (struct Gadget *)
     CreateGadgetA(SLIDER_KIND,prevGad,&newGad,tg)))
     return(NULL);

 return(g);
}

/* PALETTE GADGET. */
struct Gadget *MakePalGad(prevGad,lE,tE,w,h)
struct Gadget *prevGad;
WORD lE,tE,w,h;
{
  struct NewGadget newGad;
  struct Gadget *g;
  struct TagItem tg[3];

     tg[0].ti_Tag = GTPA_Depth;
     tg[0].ti_Data = 3;
     tg[1].ti_Tag = GTPA_IndicatorHeight;
     tg[1].ti_Data = 5;
     tg[2].ti_Tag = TAG_DONE;
     tg[2].ti_Data = TAG_DONE;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
     newGad.ng_GadgetText = NULL;   /* (UBYTE *)name */
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = 0L;
     newGad.ng_Flags = NULL;        /* PLACETEXT_LEFT|NG_HIGHLABEL */
     newGad.ng_VisualInfo = (APTR)gt_visual;
     newGad.ng_UserData = NULL;

   if(!(g = (struct Gadget *)
     CreateGadgetA(PALETTE_KIND,prevGad,&newGad,tg)))
     return(NULL);

 return(g);
}

/* BUTTON GADGET. */
struct Gadget *MakeButtonGad(name,prevGad,lE,tE,w,h)
UBYTE *name;
struct Gadget *prevGad;
WORD lE,tE,w,h;
{
 struct Gadget *g;
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
     newGad.ng_Flags = PLACETEXT_IN;  /* NG_HIGHLABEL */
     newGad.ng_VisualInfo = (APTR)gt_visual;
     newGad.ng_UserData = NULL;

   if(!(g = (struct Gadget *)
     CreateGadgetA(BUTTON_KIND,prevGad,&newGad,NULL))) /* No tags needed. */
     return(NULL);

 return(g);
}

/* CHECKBOX GADGET. */
struct Gadget *MakeCBoxGad(name,prevGad,ch_state,lE,tE,w,h)
UBYTE *name;
struct Gadget *prevGad;
WORD ch_state,lE,tE,w,h;
{
 struct Gadget *g;
 struct NewGadget newGad;
 struct TagItem tg[2];

     tg[0].ti_Tag = GTCB_Checked;     /* True/False state of checkbox. */
     tg[0].ti_Data = (ULONG)ch_state;
     tg[1].ti_Tag = TAG_DONE;
     tg[1].ti_Data = TAG_DONE;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
     newGad.ng_GadgetText = (UBYTE *)name;
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = 0L;
     newGad.ng_Flags = PLACETEXT_LEFT;  /* NG_HIGHLABEL */
     newGad.ng_VisualInfo = (APTR)gt_visual;
     newGad.ng_UserData = NULL;

   if(!(g = (struct Gadget *)
     CreateGadgetA(CHECKBOX_KIND,prevGad,&newGad,tg)))
     return(NULL);

 return(g);
}

/* Modify CheckBox Gadget to checked or unchecked.*/
/* Requires pointer to head of gad list,gadget number, and True/False,1/0*/
void mod_CBoxGad(gl,num,checked)
struct Gadget *gl;
WORD num,checked;
{
  struct Gadget *g;
  struct TagItem tg[2];

  g = find_GAD(gl,num);

  tg[0].ti_Tag = GTCB_Checked;
  tg[0].ti_Data = (ULONG)checked;
  tg[1].ti_Tag = TAG_DONE;
  tg[1].ti_Data = TAG_DONE;

  GT_SetGadgetAttrsA(g,g_window,NULL,tg);
}

/* INTUITION BUTTON GADGET. (not gadtools) */
struct Gadget *IT_ButtonGad(bflg,fpen,bpen,name,l_edge,t_edge)
int bflg,fpen,bpen;      /* Makes Intuition Bool gadgets  */
UBYTE *name;             /* Allocates all mem and returns */
WORD l_edge,t_edge;      /* a pointer to new gadget.      */
{
 struct Gadget *rgad;
 struct IntuiText *it;
 struct Border *bp;
 LONG bp_size;
 WORD *p_ptr;
 int len;
 bp_size = (LONG)sizeof(WORD)*10;   /* Border points, array size. */
 len = strlen(name)+1;              /* Gadget length. */
 len *= 8;

  if(!(rgad = (struct Gadget *)AllocMem(sizeof(struct Gadget),
       MEMF_CHIP|MEMF_CLEAR)))
       return(NULL);                  /* No gad Mem.? */
  if(!(it = (struct IntuiText *)AllocMem(sizeof(struct IntuiText),
       MEMF_CHIP|MEMF_CLEAR)))
       return(NULL);                  /* No IntuiText Mem.? */

 if(bflg) /* Use a border.? */
   {
  if(!(bp = (struct Border *)AllocMem(sizeof(struct Border),
       MEMF_CHIP|MEMF_CLEAR)))
       return(NULL);                  /* No Border Mem.? */    
  if(!(p_ptr = (WORD *)AllocMem(bp_size,
       MEMF_CHIP|MEMF_CLEAR)))
       return(NULL);                  /* No Border Points Mem.? */

  /* Border Points. */
       p_ptr[0]=0;  
       p_ptr[1]=0;    /* Start at position (0,0) */ 
       p_ptr[2]=len;
       p_ptr[3]=0;    /* Draw a line to the right to position (len,0) */
       p_ptr[4]=len;
       p_ptr[5]=11;   /* Draw a line down to position (len,11) */
       p_ptr[6]=0;
       p_ptr[7]=11;   /* Draw a line to the right to position (0,11) */
       p_ptr[8]=0;
       p_ptr[9]=0;    /* Finish off by drawing a line up to position (0,0) */ 

  /* Border. */
       bp->LeftEdge=0;
       bp->TopEdge=0;       /* LeftEdge, TopEdge. */
       bp->FrontPen=fpen;   /* FrontPen. */
       bp->BackPen=bpen;    /* BackPen.  */
       bp->DrawMode=JAM2;   /* DrawMode, JAM 2 colors in rastport. */
       bp->Count=5;         /* Count, 5 pair of coordinates in the array. */
       bp->XY = p_ptr,      /* XY, coordinates. */
       bp->NextBorder=NULL; /* NextBorder. */
     }

/* IntuiText. */
  it->FrontPen=fpen;          /* FrontPen. */
  it->BackPen=bpen;           /* BackPen.  */
  it->DrawMode=JAM2;          /* DrawMode.  */
  it->LeftEdge=4;
  it->TopEdge=2;              /* LeftEdge, TopEdge. */
  it->ITextFont=NULL;         /* ITextFont, use default font. */
  it->IText= (UBYTE *)name;   /* IText.   */
  it->NextText=NULL;          /* NextText.*/

/* Actual Gadget. */
  rgad->NextGadget=NULL;
  rgad->LeftEdge=l_edge;
  rgad->TopEdge=t_edge;
  rgad->Width=len;
  rgad->Height=11;
  rgad->Flags=GFLG_GADGHCOMP;
  rgad->Activation=GACT_IMMEDIATE|GACT_RELVERIFY;
  rgad->GadgetType=GTYP_BOOLGADGET;
 if(bflg)
  rgad->GadgetRender = (APTR)bp;    /* BORDER POINTER. */
 else
  rgad->GadgetRender = NULL;
  rgad->SelectRender=NULL;
  rgad->GadgetText = it;            /* INTUITEXT POINTER. */
  rgad->MutualExclude=NULL;
  rgad->SpecialInfo=NULL;
  rgad->GadgetID=0;
  rgad->UserData=NULL;

  return(rgad);
}

/* This is used to evenly space out gadgets on a single line. */
/* See Alloc_G_Gadgets(). */
WORD set_GadX(x1,size,space)
WORD *x1,size,space;
{
   *x1 += (size+space);
   return(*x1);
}

void free_IT_BtnGads(hg)  /* Free gadgets made with IT_ButtonGad(). */
struct Gadget *hg;        /* hg -  must be the head of gadget list. */
{
  struct Gadget *prevG,*nextG;
  struct Border *bp;
  LONG bp_size;
  prevG=hg;                         /* Points to Prev/Current Gadget. */
  nextG=hg;                         /* Points to next Gadget.         */
  bp_size = (LONG)sizeof(WORD)*10;  /* Border points, array size.     */

  do {
          nextG=nextG->NextGadget;  /* Keep Pointing to Next. */

      if(prevG->GadgetRender != NULL) {    /* Free border for this gadget. */
             bp = (struct Border *)prevG->GadgetRender;
         if(bp->XY != NULL) {              /* Free border points.1st */
             FreeMem(bp->XY, bp_size);
             }
           FreeMem(prevG->GadgetRender, sizeof(struct Border));
          }
      if(prevG->GadgetText != NULL) {   /* Free intuitext for this gadget. */
          FreeMem(prevG->GadgetText, sizeof(struct IntuiText));
          }
      if(prevG != NULL) {               /* Free this gadget. */
          FreeMem(prevG, sizeof(struct Gadget));
          }

          prevG=nextG;                 /* Point to current. */
      }
  while(nextG != NULL);
}

/* CYCLE GADGET. */
struct Gadget *MakeCycleGad(name,prevGad,type,lE,tE,w,h)
UBYTE *name;
struct Gadget *prevGad;
int type;
WORD lE,tE,w,h;
{
 struct Gadget *g;
 struct NewGadget newGad;
 struct TagItem tg[3];
 WORD val=0;

    tg[0].ti_Tag = GTCY_Labels;

    switch(type) {
         case  LI_BOTH_ED:         /* Want to use same cycle strings but */
               type = ED_LI_BOTH;  /* change the active one. */
               val=1;
               break;
         case  BOTH_ED_LI:
               type = ED_LI_BOTH;
               val=2;
               break;
         case  LI_BOTH_ASS:
               type = ASS_LI_BOTH;
               val=1;
               break;
         case  BOTH_ASS_LI:
               type = ASS_LI_BOTH;
               val=2;
         case  WAIT_KEY:
               type = WAIT_DELAY;
               val=1;
               break;
      }
   switch(type)  /* Set cycle gad string. */
    {
      case YES_NO:        tg[0].ti_Data = (ULONG)CycleNames1;
                   break;
      case NO_YES:        tg[0].ti_Data = (ULONG)CycleNames2;
                   break;
      case ON_OFF:        tg[0].ti_Data = (ULONG)CycleNames3;
                   break;
      case OFF_ON:        tg[0].ti_Data = (ULONG)CycleNames4;
                   break;
      case BIT32_BIT16:   tg[0].ti_Data = (ULONG)CycleNames5;
                   break;
      case BIT16_BIT32:   tg[0].ti_Data = (ULONG)CycleNames6;
                   break;
      case ED_LI_BOTH:    tg[0].ti_Data = (ULONG)CycleNames7;
                   break;
      case ASS_LI_BOTH:   tg[0].ti_Data = (ULONG)CycleNames8;
                   break;
      case WAIT_DELAY:    tg[0].ti_Data = (ULONG)CycleNames9;
                   break;
      default:            tg[0].ti_Data = (ULONG)CycleNames1;
                   break;
     }

   tg[1].ti_Tag = GTCY_Active;
   tg[1].ti_Data = (ULONG)val; /* CycleNamesN[n]. */
   tg[2].ti_Tag = TAG_DONE;
   tg[2].ti_Data = TAG_DONE;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
     newGad.ng_GadgetText = (UBYTE *)name;
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = 0L;
     newGad.ng_Flags = PLACETEXT_LEFT;
     newGad.ng_VisualInfo = (APTR)gt_visual;
     newGad.ng_UserData = NULL;

   if(!(g = (struct Gadget *)
     CreateGadgetA(CYCLE_KIND,prevGad,&newGad,tg)))
     return(NULL);

 return(g);
}

/* Change cycle gadget position. */
void mod_CycleGad(gl,gnum,newpos)
struct Gadget *gl;
WORD gnum,newpos;
{
  struct Gadget *g;
  struct TagItem tg[2];

  g = find_GAD(gl,gnum);

  tg[0].ti_Tag = GTCY_Active;
  tg[0].ti_Data = (ULONG)newpos;
  tg[1].ti_Tag = TAG_DONE;
  tg[1].ti_Data = TAG_DONE;

  GT_SetGadgetAttrsA(g,g_window,NULL,tg);
}

/* STRING GADGET. */
struct Gadget *MakeStringGad(name,msg,len,prevGad,lE,tE,w,h)
UBYTE *name;
UBYTE *msg;
int len;
struct Gadget *prevGad;
WORD lE,tE,w,h;
{
  struct NewGadget newGad;
  struct Gadget *g;
  struct TagItem tg[3];

     tg[0].ti_Tag = GTST_String;

   if(msg)    /* If Gad message, string exists, so use it. */
       tg[0].ti_Data = (ULONG)msg;
     else
       tg[0].ti_Data = NULL;

     tg[1].ti_Tag = GTST_MaxChars;
     tg[1].ti_Data = (ULONG)len;   /* Max typed chars. */
     tg[2].ti_Tag = TAG_DONE;
     tg[2].ti_Data = TAG_DONE;

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
     newGad.ng_Flags = PLACETEXT_LEFT|NG_HIGHLABEL;
     newGad.ng_VisualInfo = (APTR)gt_visual;
     newGad.ng_UserData = NULL;

   if(!(g = (struct Gadget *)
     CreateGadgetA(STRING_KIND,prevGad,&newGad,tg)))
     return(NULL);

 return(g);
}

/* Modify String Gadget to show new string. */
/* Requires pointer to head of gad list,gadget number, and new string.*/
void mod_StrGad(gl,num,str)
struct Gadget *gl;
WORD num;
char *str;
{
  struct Gadget *g;
  struct TagItem tg[2];

  g = find_GAD(gl,num);

  tg[0].ti_Tag = GTST_String;
  tg[0].ti_Data = (ULONG)str;
  tg[1].ti_Tag = TAG_DONE;
  tg[1].ti_Data = TAG_DONE;

  GT_SetGadgetAttrsA(g,g_window,NULL,tg);
}

/* INTEGER GADGET. */
struct Gadget *MakeIntegerGad(name,num,prevGad,lE,tE,w,h)
UBYTE *name;
int num;
struct Gadget *prevGad;
WORD lE,tE,w,h;
{
 struct NewGadget newGad;
 struct Gadget *g;
 struct TagItem tg[2];

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
     newGad.ng_VisualInfo = (APTR)gt_visual;
     newGad.ng_UserData = NULL;

     tg[0].ti_Tag = GTIN_Number; /* Number to apear in gadget.(def 0).*/
     tg[0].ti_Data = (ULONG)num;
     tg[1].ti_Tag = TAG_DONE;
     tg[1].ti_Data = TAG_DONE;

   if(!(g = (struct Gadget *)
     CreateGadgetA(INTEGER_KIND,prevGad,&newGad,tg)))
     return(NULL);

 return(g);
}

/* Modify Integer Gadget to show new number. */
/* note: requires pointer to head of gad list,and the gadget number. */
void mod_IntGad(gl,gnum,new_num)
struct Gadget *gl;
WORD gnum;
int new_num;
{
  struct Gadget *g=gl;
  struct TagItem tg[2];
  WORD i;

  for(i = 0;(i < gnum) && g;i++) /* find correct gad in list. */
      g = g->NextGadget;

  tg[0].ti_Tag = GTIN_Number;
  tg[0].ti_Data = (ULONG)new_num;
  tg[1].ti_Tag = TAG_DONE;
  tg[1].ti_Data = TAG_DONE;

  GT_SetGadgetAttrsA(g,g_window,NULL,tg);
}


/* MOST FUNCTIONS FROM HERE ON ,USE THE ABOVE FUNCTIONS!!. */

int Alloc_VisualInfoA() /* Get visual info for gadtools. */
{
  if(!(gt_visual = (APTR)GetVisualInfoA(my_screen, NULL)))
      return(NULL);
  return(1);
}

int Alloc_C_Gadgets()  /* Allocate compiler option window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;
  int type;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&c_gadlist)))
        return(NULL);

/* CYCLE GAD1. "Compile"(from). */
  switch( C_GadBN[2] ) {
      case 0:  type=ED_LI_BOTH; break;
      case 1:  type=LI_BOTH_ED; break;
      case 2:  type=BOTH_ED_LI; break;
      }
 if(!(nextGad = MakeCycleGad((UBYTE *)"Compile",
     prevGad,type,175,30,320,14)))
     {
       return(NULL);
      }
/* STRING GAD1. "Debug (a-z)" */
 if(!(prevGad = MakeStringGad((UBYTE *)"Debug (a-z)",C_Debug,GB_TINY-1,
     nextGad,175,44,320,14)))
     {
       return(NULL);
      }
/* STRING GAD2. "Define Symbol" */
 if(!(nextGad = MakeStringGad((UBYTE *)"Define Symbol",C_DefSym,GB_MIN-1,
     prevGad,175,58,320,14)))
     {
       return(NULL);
      }
/* STRING GAD3. "UnDefine Symbol" */
 if(!(prevGad = MakeStringGad((UBYTE *)"UnDefine Symbol",C_UnDefSym,GB_MIN-1,
     nextGad,175,72,320,14)))
     {
       return(NULL);
      }
/* STRING GAD4. "Include Directory List" */
 if(!(nextGad = MakeStringGad("Include Dir List",C_IDirList,GB_MAX-1,
     prevGad,175,86,320,14)))
     {
       return(NULL);
      }
/* STRING GAD5. "Quadfile Device" */
 if(!(prevGad = MakeStringGad((UBYTE *)"Quadfile Device",C_QuadDev,GB_MIN-1,
     nextGad,175,100,120,14)))
     {
       return(NULL);
      }
/* CYCLE GAD2. "Keep Quad" */
  if ( !C_GadBN[0] )
       type=NO_YES;
      else
       type=YES_NO;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Keep Quad",
     prevGad,type,385,100,110,14)))
     {
       return(NULL);
      }
/* CYCLE GAD3. "Int & Unsigned" */
  if ( !C_GadBN[1] )
       type=BIT32_BIT16;
      else
       type=BIT16_BIT32;

 if(!(prevGad = MakeCycleGad((UBYTE *)"Int & Unsigned",
     nextGad,type,175,114,120,14)))
     {
       return(NULL);
      }
/* CYCLE GAD4. "Free-Up". */
  if ( !C_GadBN[3] )
      type=YES_NO;
     else
      type=NO_YES;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Free-Up",
     prevGad,type,385,114,110,14)))
     {
       return(NULL);
      }

/* STRING GAD6. "Compile List" */
 if(!(prevGad = MakeStringGad((UBYTE *)"Compile List",C_WorkList,GB_LSIZE-1,
     nextGad,175,135,320,14)))
     {
       return(NULL);
      }
/* BUTTON GAD1. "Duplicate List" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Dupe List",
     prevGad,175,149,106,14)))
     {
      return(NULL);
      }
/* BUTTON GAD2. "Check List" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Check List",
     nextGad,281,149,106,14)))
     {
      return(NULL);
      }
/* BUTTON GAD3. "Clear List" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Clear List",
     prevGad,387,149,108,14)))
     {
      return(NULL);
      }
/* BUTTON GAD4. "Disk To List" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Disk To List",
     nextGad,175,163,160,14)))
     {
      return(NULL);
      }
/* STRING GAD6. "Pattern" */
 if(C_Pattern[0] == '\0')
    strcpy(C_Pattern,".c");
 if(!(nextGad = MakeStringGad((UBYTE *)"Pattern",C_Pattern,GB_MIN-1,
     prevGad,407,163,88,14)))
     {
       return(NULL);
      }
/* BUTTON GAD7. "Load Compile List" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Load Compile List",
     nextGad,175,177,160,14)))
     {
      return(NULL);
      }
/* BUTTON GAD8. "Save Compile List" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Save Compile List",
     prevGad,335,177,160,14)))
     {
      return(NULL);
      }
/* BUTTON GAD9. "Exit" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Exit",
     nextGad,175,191,320,14)))
     {
      return(NULL);
      }

return(1); /* Ok!!. */
}

int Alloc_O_Gadgets()  /* Allocate Optimizer option window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;
  int type;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&o_gadlist)))
        return(NULL);

/* CYCLE GAD1. "Debug" */
 if( !O_GadBN[0] )
     type=OFF_ON;
  else
     type=ON_OFF;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Debug",
     prevGad,type,285,30,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD2. "Verbose". */
 if( !O_GadBN[1] )
     type=OFF_ON;
    else
     type=ON_OFF;

 if(!(prevGad = MakeCycleGad((UBYTE *)"Verbose",
     nextGad,type,285,48,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD3. "Branch Reversal". */
 if( !O_GadBN[2] )
      type=ON_OFF;
     else
      type=OFF_ON;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Branch Reversal",
     prevGad,type,285,66,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD4. "Loop Rotation". */
 if( !O_GadBN[3] )
     type=ON_OFF;
   else
     type=OFF_ON;

 if(!(prevGad = MakeCycleGad((UBYTE *)"Loop Rotation",
     nextGad,type,285,84,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD5. "Peephole Optimization". */
 if( !O_GadBN[4] )
      type=ON_OFF;
   else
      type=OFF_ON;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Peephole Optimization",
     prevGad,type,285,102,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD6. "Variable Registerizing". */
 if( !O_GadBN[7] )
      type=ON_OFF;
   else
      type=OFF_ON;

 if(!(prevGad = MakeCycleGad((UBYTE *)"Variable Registerizing",
     nextGad,type,285,120,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD7. "No change of stack-fixups". */
 if( !O_GadBN[5] )
      type=OFF_ON;
    else
      type=ON_OFF;

 if(!(nextGad = MakeCycleGad((UBYTE *)"No change of Stack-Fixups",
     prevGad,type,285,138,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD8. "Data-Bss to Chip". */
 if( O_GadBN[6] == 2) /* Flag was set during compile. (see hcc - main.c). */
     O_GadBN[6] = 0;
 if( !O_GadBN[6] )
     type=OFF_ON;
  else
     type=ON_OFF;

 if(!(prevGad = MakeCycleGad((UBYTE *)"Data-Bss to Chip",
     nextGad,type,285,156,80,14)))
     {
       return(NULL);
      }
/* BUTTON GAD1. "EXIT" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"EXIT",
     prevGad,285,174,80,14)))
     {
      return(NULL);
      }
return(1); /* OK!!. */
}

int Alloc_A_Gadgets()  /* Allocate Assembler option window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;
  int type;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&a_gadlist)))
        return(NULL);

/* CYCLE GAD1. "Symbol table to object" */
  if( !A_GadBN[0] )
     type=NO_YES;
   else
     type=YES_NO;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Symbol table to Object",
     prevGad,type,250,30,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD2. "Write equate file". */
  if( !A_GadBN[1] )
     type=NO_YES;
  else
     type=YES_NO;

 if(!(prevGad = MakeCycleGad((UBYTE *)"Write Equate File",
     nextGad,type,250,46,80,14)))
     {
       return(NULL);
      }

/* CYCLE GAD3. "Verbose". */
  if( !A_GadBN[2] )
     type=OFF_ON;
   else
     type=ON_OFF;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Verbose",
     prevGad,type,250,62,80,14)))
     {
       return(NULL);
      }
/* STRING GAD1. "OutPath" */
 if(!(prevGad = MakeStringGad((UBYTE *)"Outpath",A_OutPath,GB_MIN-1,
     nextGad,250,78,320,14)))
     {
       return(NULL);
      }
/* STRING GAD2. "Include header file" */
 if(!(nextGad = MakeStringGad("Include Header File",A_IncHeader,GB_OTHER-1,
     prevGad,250,94,320,14)))
     {
       return(NULL);
      }
/* STRING GAD3. "Include directory list" */
 if(!(prevGad = MakeStringGad("Include Directory List",A_IDirList,GB_MAX-1,
     nextGad,250,110,320,14)))
     {
       return(NULL);
      }
/* STRING GAD4. "Create listing file" */
 if(!(nextGad = MakeStringGad("Create Listing File",A_CListFile,GB_MIN-1,
     prevGad,250,126,200,14)))
     {
       return(NULL);
      }
/* CYCLE GAD4. "Disable Optimization". */
  if( !A_GadBN[3] )
     type=NO_YES;
    else
     type=YES_NO;

 if(!(prevGad = MakeCycleGad((UBYTE *)"Disable Optimization",
     nextGad,type,250,142,80,14)))
     {
       return(NULL);
      }
/* CYCLE GAD5. "Display Hashing Stats". */
  if( !A_GadBN[4] )
     type=NO_YES;
   else
     type=YES_NO;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Display Hashing Stats",
     prevGad,type,250,158,80,14)))
     {
       return(NULL);
      }
/* STRING GAD5. "Debug" */
 if(!(prevGad = MakeStringGad((UBYTE *)"Debug",A_Debug,GB_MIN-1,
     nextGad,250,174,200,14)))
     {
       return(NULL);
      }
/* BUTTON GAD1. "EXIT" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"EXIT",
     prevGad,250,190,80,14)))
     {
      return(NULL);
      }
return(1); /* Ok!! */
}

int Alloc_L_Gadgets()  /* Allocate Linker option window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;
  int type;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&l_gadlist)))
        return(NULL);

/* CYCLE GAD1. "Link".(from) */
  switch( L_GadBN[3] ) {
      case 0:  type=ASS_LI_BOTH; break;
      case 1:  type=LI_BOTH_ASS; break;
      case 2:  type=BOTH_ASS_LI; break;
      }
 if(!(nextGad = MakeCycleGad((UBYTE *)"Link",
     prevGad,type,170,30,320,14)))
     {
       return(NULL);
      }

/* STRING GAD1. "Startup Object" */
 if(L_StartOBJ[0] == '\0')
   strcpy(L_StartOBJ,"LIB:begin.o");

 if(!(prevGad = MakeStringGad((UBYTE *)"Startup Object",L_StartOBJ,GB_MIN-1,
     nextGad,170,44,320,14)))
     {
       return(NULL);
      }
/* STRING GAD2. "Maths Library" */
 if(L_MathLib[0] == '\0')    /* default. */
     strcpy(L_MathLib, "LIB:Math.lib");

 if(!(nextGad = MakeStringGad((UBYTE *)"Maths Library",L_MathLib,GB_MIN-1,
     prevGad,170,58,255,14)))
     {
       return(NULL);
      }
/* CHECBOX GAD1. "Use" */
 if(!(prevGad = MakeCBoxGad((UBYTE *)"Use",
     nextGad,L_GadBN[4],463,59,27,14)))
     {
       return(NULL);
      }
/* STRING GAD3. "Other Libraries" */
 if(L_Libs[0] == '\0')    /* default. */
     strcpy(L_Libs, def_LIBS);

 if(!(nextGad = MakeStringGad((UBYTE *)"Other Libraries",L_Libs,GB_EXT-1,
     prevGad,170,72,320,14)))
     {
       return(NULL);
      }
/* STRING GAD4. "OutName" */
 if(!(prevGad = MakeStringGad((UBYTE *)"OutName",L_OutName,GB_MIN-1,
     nextGad,170,86,320,14)))
     {
       return(NULL);
      }
/* CHECBOX GAD2. "Verbose" */
 if(!(nextGad = MakeCBoxGad((UBYTE *)"Verbose",
     prevGad,L_GadBN[0],170,100,27,14)))
     {
       return(NULL);
      }
/* CHECKBOX GAD3. "Small-Data" */
 if(!(prevGad = MakeCBoxGad((UBYTE *)"Small-Data",
     nextGad,L_GadBN[1],318,100,27,14)))
     {
       return(NULL);
      }
/* CHECHBOX GAD4. "Small-Code". */
 if(!(nextGad = MakeCBoxGad((UBYTE *)"Small-Code",
     prevGad,L_GadBN[2],463,100,27,14)))
     {
       return(NULL);
      }

/* STRING GAD5. "Link List" */
 if(!(prevGad = MakeStringGad((UBYTE *)"Link List",L_LinkList,GB_LSIZE-1,
     nextGad,170,121,320,14)))
     {
       return(NULL);
      }
/* BUTTON GAD1. "Duplicate List" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Dupe List",
     prevGad,170,135,106,14)))
     {
      return(NULL);
      }
/* BUTTON GAD2. "Check List" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Check List",
     nextGad,276,135,106,14)))
     {
      return(NULL);
      }
/* BUTTON GAD3. "Clear List" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Clear List",
     prevGad,382,135,108,14)))
     {
      return(NULL);
      }
/* BUTTON GAD4. "Disk To List" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Disk To List",
     nextGad,170,149,160,14)))
     {
      return(NULL);
      }
/* STRING GAD6. "Pattern" */
 if(L_Pattern[0] == '\0')
    strcpy(L_Pattern,".o");
 if(!(nextGad = MakeStringGad((UBYTE *)"Pattern",L_Pattern,GB_MIN-1,
     prevGad,402,149,88,14)))
     {
       return(NULL);
      }
/* BUTTON GAD5. "Load Link List" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Load Link List",
     nextGad,170,163,160,14)))
     {
      return(NULL);
      }
/* BUTTON GAD6. "Save Link List" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Save Link List",
     prevGad,330,163,160,14)))
     {
      return(NULL);
      }

/* STRING GAD7. "Library OutName" */
 if(L_LibOut[0] == '\0')
    strcpy(L_LibOut,"RAM:Amiga.lib");
 if(!(prevGad = MakeStringGad((UBYTE *)"Library Name",L_LibOut,GB_MIN-1,
     nextGad,170,184,320,14)))
     {
       return(NULL);
      }
/* BUTTON GAD7. "FD to Lib" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"FD To Lib",
     prevGad,170,198,160,14)))
     {
      return(NULL);
      }
/* BUTTON GAD8. "List to Lib" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"List To Lib",
     nextGad,330,198,160,14)))
     {
      return(NULL);
      }

/* BUTTON GAD6. "Exit" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Exit",
     prevGad,170,212,320,14)))
     {
      return(NULL);
      }

return(1); /* OK!! */
}

int Alloc_F_Gadgets()  /* Allocate option window find gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&f_gadlist)))
        return(NULL);

/* STRING GAD1. "Find" */
 if(!(nextGad = MakeStringGad(NULL,Search_Name,GB_OTHER-1,
     prevGad,1,11,639,16)))
     {
       return(NULL);
      }

return(1); /* OK!! */
}

int Alloc_R_Gadgets()  /* Allocate option window replace gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;
  int type;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&r_gadlist)))
        return(NULL);

/* STRING GAD1. "Search string" */
 if(!(nextGad = MakeStringGad("Enter search string",Search_Name,GB_OTHER-1,
     prevGad,196,30,320,14)))
     {
       return(NULL);
      }
/* STRING GAD2. "Replacement" */
 if(!(prevGad = MakeStringGad("Replacement string",Replace_Name,GB_OTHER-1,
     nextGad,196,55,320,14)))
     {
       return(NULL);
      }
/* CYCLE GAD1. "Case Sensitive". */
 if(c_sensitive)
     type=YES_NO;
    else
     type=NO_YES;

 if(!(nextGad = MakeCycleGad((UBYTE *)"Case Sensitive",
     prevGad,type,196,80,80,14)))
     {
       return(NULL);
      }
/* BUTTON GAD1. "EXIT" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"EXIT",
     nextGad,286,80,80,14)))
     {
      return(NULL);
      }
return(1); /* OK!! */
}

int Alloc_J_Gadgets()  /* Allocate option window Jump to line ,gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&j_gadlist)))
        return(NULL);

/* INT GAD1. "Jump To" */

 if(!(nextGad = MakeIntegerGad(NULL,jump_to_num,
     prevGad,1,11,639,16)))
     {
      return(NULL);
      }
return(1); /* OK!! */
}

int Alloc_G_Gadgets()  /* Allocate 'Gadget Bar' gfx_window gadgets. */
{                      /* Not GadTools!. (note borders set in gfx.c */
 struct Gadget *prevGad,*nextGad;
 WORD sx = GADBAR_SX;

/* BUTTON GAD 1. "Test"*/
 if(!(gb_gadlist = IT_ButtonGad(NULL,FGP,BGP,"Test",sx,GADBAR_Y+3)))
      return(NULL);
      nextGad=gb_gadlist;


/* BUTTON GAD 2. "Compile+Assemble"*/
  if(!(prevGad = IT_ButtonGad(NULL,FGP,BGP,"Compile+Optimize+Assemble",
                              set_GadX(&sx,32,14),GADBAR_Y+3)))
      return(NULL);
      nextGad->NextGadget=prevGad;
      nextGad=nextGad->NextGadget;

/* BUTTON GAD 3. "Comp+Assem + Link"*/
  if(!(prevGad = IT_ButtonGad(NULL,FGP,BGP,"Compile+O+A+Link",
                              set_GadX(&sx,200,14),GADBAR_Y+3)))
      return(NULL);
      nextGad->NextGadget=prevGad;
      nextGad=nextGad->NextGadget;

/* BUTTON GAD 4. "Link"*/
 if(!(prevGad = IT_ButtonGad(NULL,FGP,BGP,"Link",
                             set_GadX(&sx,128,14),GADBAR_Y+3)))
      return(NULL);
      nextGad->NextGadget=prevGad;
      nextGad=nextGad->NextGadget;

/* BUTTON GAD 5. "Run"*/
  if(!(prevGad = IT_ButtonGad(NULL,FGP,BGP,"Run",
                              set_GadX(&sx,32,14),GADBAR_Y+3)))
      return(NULL);
      nextGad->NextGadget=prevGad;
      nextGad=nextGad->NextGadget;

/* BUTTON GAD 6. "Esc"*/
  if(!(prevGad = IT_ButtonGad(NULL,FGP,BGP,"Esc",
                              set_GadX(&sx,24,14),GADBAR_Y+3)))
      return(NULL);
      nextGad->NextGadget=prevGad;
      nextGad=nextGad->NextGadget;

/* BUTTON GAD 7. "Esc"*/
  if(!(prevGad = IT_ButtonGad(NULL,FGP,BGP,"Cleanup",
                              set_GadX(&sx,24,14),GADBAR_Y+3)))
      return(NULL);
      nextGad->NextGadget=prevGad;

return(1); /* OK!! */
}

int Alloc_P_Gadgets()  /* Allocate printer window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&p_gadlist)))
        return(NULL);

/* INT GAD1. "From line" */
 if(!(nextGad = MakeIntegerGad((UBYTE *)"From line",1,
     prevGad,210,30,50,16)))
     {
      return(NULL);
      }
/* INT GAD2. "To line" */
 if(!(prevGad = MakeIntegerGad((UBYTE *)"To line",2,
     nextGad,210,47,50,16)))
     {
      return(NULL);
      }
/* BUTTON GAD1. "Print" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Print",
     prevGad,262,30,184,16)))
     {
      return(NULL);
      }
/* BUTTON GAD2. "Print-All" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Print-All",
     nextGad,262,47,184,16)))
     {
      return(NULL);
      }
/* BUTTON GAD3. "Exit" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Exit",
     prevGad,210,64,236,16)))
     {
      return(NULL);
      }

return(1); /* OK!! */
}

int Alloc_Pref_Gads() /* Allocate preferences window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;
  WORD type=0;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&prefs_glist)))
        return(NULL);

/* PAL GAD1. Palette. */
 if(!(nextGad = MakePalGad(prevGad,88,37,160,14)))
      return(NULL);

/* SLIDER GAD1. "Red" */
 if(!(prevGad = MakeSlideGad("Red",nextGad,88,51,158,10)))
      return(NULL);
/* SLIDER GAD2. "Green" */
 if(!(nextGad = MakeSlideGad("Green",prevGad,88,61,158,10)))
      return(NULL);
/* SLIDER GAD3. "Blue" */
 if(!(prevGad = MakeSlideGad("Blue",nextGad,88,71,158,10)))
      return(NULL);
/* BUTTON GAD1. "Set Pen Colour" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Set Pen Colour",
     prevGad,88,81,158,10)))
     {
      return(NULL);
      }
/* BUTTON GAD2. "Set Paper Colour" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Set Paper Colour",
     nextGad,88,91,158,10)))
     {
      return(NULL);
      }
/* BUTTON GAD3. "Set Mark Colour" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Set Mark Colour",
     prevGad,88,101,158,10)))
     {
      return(NULL);
      }
/* INT GAD1. "Tab Stop" */
 if(!(prevGad = MakeIntegerGad("Tab",P_GadBN[1],
     nextGad,88,111,158,10)))
     {
      return(NULL);
      }
/* CYCLE GAD1. "Wait"(For-Delay/Key). */
  switch( P_GadBN[0] ) {
      case 0:  type=WAIT_DELAY; break;
      case 1:  type=WAIT_KEY; break;
      }
 if(!(nextGad = MakeCycleGad((UBYTE *)"Run",
     prevGad,type,88,121,158,14)))
     {
       return(NULL);
      }
/* BUTTON GAD4. "CANCEL" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"CANCEL",
     nextGad,88,135,158,10)))
     {
      return(NULL);
      }
/* BUTTON GAD5. "Load Default Config" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Load Default Config",
     prevGad,380,37,190,27)))
     {
      return(NULL);
      }
/* BUTTON GAD6. "Save Default Config" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Save Default Config",
     nextGad,380,64,190,27)))
     {
      return(NULL);
      }
/* BUTTON GAD7. "Load Other" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"Load Other",
     prevGad,380,91,190,27)))
     {
      return(NULL);
      }
/* BUTTON GAD8. "Save Other" */
 if(!(prevGad = MakeButtonGad((UBYTE *)"Save Other",
     nextGad,380,118,190,27)))
     {
      return(NULL);
      }
/* BUTTON GAD9. "EXIT" */
 if(!(nextGad = MakeButtonGad((UBYTE *)"EXIT",
     prevGad,298,80,42,14)))
     {
      return(NULL);
      }

return(1);
}

int Alloc_Req_Gads()   /* Allocate requester window gadgets. */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&req_glist)))
        return(NULL);

/* STRING GAD1. no message. */
 if(!(nextGad = MakeStringGad(NULL,NULL,GB_OTHER-1,
     prevGad,1,11,250,14)))
     {
       return(NULL);
      }

/* BUTTON GAD1. "EXIT"
 if(!(prevGad = MakeButtonGad((UBYTE *)"EXIT",
     nextGad,102,44,42,14)))
     {
      return(NULL);
      }
*/
}

void Free_GT_Gadgets() /* Free all GadTools gadgets/memory. */
{                      /* NOTE: g_window must be closed before this call.*/
   if(c_gadlist)
           FreeGadgets(c_gadlist);  /* Compilier option Gadgets. */
           c_gadlist=NULL;
   if(o_gadlist)
           FreeGadgets(o_gadlist);  /* Optimizer. */           
           o_gadlist=NULL;
   if(a_gadlist)
           FreeGadgets(a_gadlist);  /* Assembler. */
           a_gadlist=NULL;
   if(l_gadlist)
           FreeGadgets(l_gadlist);  /* Linker. */
           l_gadlist=NULL;
   if(f_gadlist)
           FreeGadgets(f_gadlist);  /* Find. */
           f_gadlist=NULL;
   if(r_gadlist)
           FreeGadgets(r_gadlist);  /* Replace. */
           r_gadlist=NULL;
   if(j_gadlist)
           FreeGadgets(j_gadlist);  /* Jump to. */
           j_gadlist=NULL;
   if(p_gadlist)
           FreeGadgets(p_gadlist);  /* Printer. */
           p_gadlist=NULL;
   if(prefs_glist)
           FreeGadgets(prefs_glist); /* Palette. */
           prefs_glist=NULL;
   if(req_glist)
           FreeGadgets(req_glist);   /* Requester. */
           req_glist=NULL;
}

void FREE_MiscGads() /* Free gadgets - not GadTools. */
{
   if(gb_gadlist)
           free_IT_BtnGads(gb_gadlist);
}


void Free_VisualInfo() /* Free memory allocated with Alloc_VisualInfoA(). */
{                      /* NOTE: call just before CloseScreen(). */
  if(gt_visual)
   FreeVisualInfo(gt_visual);
}
