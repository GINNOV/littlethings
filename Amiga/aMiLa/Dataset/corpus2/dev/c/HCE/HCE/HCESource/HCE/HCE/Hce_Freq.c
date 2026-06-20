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
 *    Make file requestor, similar to the asl file requestor.
 *
 *    note: requires gadtools.library - V36 or higher. (WB 2.0)
 */

#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <exec/memory.h>
#include <libraries/gadtools.h>
#include <intuition/gadgetclass.h>
#include <libraries/dos.h>

#include <clib/string.h>
#include <clib/stdio.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_GadTools.h"

/******************** GLOBALS *******************/ 

char F_Drawer[GB_MAX];  /* Draw string gadget buffer. */
char F_File[GB_OTHER];  /* File string gadget buffer. */

/******************* STRUCTURES *****************/

/* Requestor window. */
struct NewWindow new_filewin =
{
  0,0,                /* LeftEdge, TopEdge */
  400, 179,           /* Width, Height */
  0,1,                /* DetailPen, BlockPen */
  IDCMP_CLOSEWINDOW|IDCMP_GADGETDOWN|IDCMP_MOUSEMOVE|IDCMP_GADGETUP,
  WFLG_ACTIVATE|WFLG_DEPTHGADGET|WFLG_DRAGBAR|
  WFLG_CLOSEGADGET|WFLG_SMART_REFRESH,
  NULL,               /* &gadget_display[0], FirstGadget */
  NULL,               /* *CheckMark */
  NULL,               /* *Title */
  NULL,               /* *Screen */
  NULL,               /* *BitMap */
  0,0,                /* MinWidth, MinHeight */
  0,0,                /* MaxWidth, MaxHeight */
  CUSTOMSCREEN        /* Type */
};

struct Window *FileWin;           /* Pointer to window. */
struct Gadget *file_glist = NULL; /* Head of file requestor gadget list. */
static struct Gadget *lv_gadptr;  /* Keep pointer to List View Gadget. */

typedef struct Node *IO_NP;
struct List IO_HEAD;

/***************** FUNCTIONS ***********************/

/* Make Gadtools, list view gadget. */
struct Gadget *MakeListView(prevGad,strGad,lE,tE,w,h)
struct Gadget *prevGad,*strGad;
WORD lE,tE,w,h;
{
 struct Gadget *g;
 struct NewGadget newGad;
 struct TagItem tg[2];

     tg[0].ti_Tag = GTLV_ShowSelected;
     tg[0].ti_Data = (ULONG)strGad;
     tg[1].ti_Tag = TAG_DONE;
     tg[1].ti_Data = TAG_DONE;

     newGad.ng_LeftEdge = lE;
     newGad.ng_TopEdge = tE;
     newGad.ng_Width = w;
     newGad.ng_Height = h;
     newGad.ng_GadgetText = NULL;
     newGad.ng_TextAttr = NULL;
     newGad.ng_GadgetID = NULL;
     newGad.ng_Flags = PLACETEXT_IN;
     newGad.ng_VisualInfo = (APTR)gt_visual;
     newGad.ng_UserData = NULL;

   if(!(g = (struct Gadget *)
     CreateGadgetA(LISTVIEW_KIND,prevGad,&newGad,tg)))
     return(NULL);
 return(g);
}

/* Show new file list, or clear old. */
void ModListView(lv_gad,lv_list,how)
struct Gadget *lv_gad;
struct List *lv_list;
int how;
{
  struct TagItem tg[2];

     tg[0].ti_Tag = GTLV_Labels;

  if(!how) {   /* Show new list. */
     tg[0].ti_Data = (ULONG)lv_list;
    else       /* or clear current list so you can modify it. */
     tg[0].ti_Data = NULL;

     tg[1].ti_Tag = TAG_DONE;
     tg[1].ti_Data = TAG_DONE;

     GT_SetGadgetAttrsA(lv_gad,FileWin,NULL,tg);
}

/* Free the current list and also clear it in the file requestor. */
void free_LVL(lv_list)
struct List *lv_list;
{
  IO_NP np,next;

       ModListView(lv_gadptr,lv_list,1);  /* Clear list in requestor. */

       np = lv_list->lh_Head;
  while(np) {                   /* Free the list */
    if(np->ln_name)
       free(np->ln_name);
       next = np->ln_Succ;
       free(np);
       np = next;
   }
}

/* Put list into alphabetical order ,then show it. */
void Sort_LVL(lv_list)
struct List *lv_list;
{
}

/* Add a file or directory to a list. */
/* For building list from disk before show. */
void add_LVL(lv_list,lv_str)
struct List *lv_list;
char *lv_str;
{
}

/* Clear old 'List', get new, put into alphabetical order, then show it. */
void ShowNewDir(path)
char *path;
{
}

int Alloc_fglist() /* Allocate all filerequestor gadgets */
{
  struct Gadget *prevGad;
  struct Gadget *nextGad;

/* MAKE CONTEXT GADGET. */
 if(!(prevGad = (struct Gadget *)CreateContext(&file_glist)))
        return(NULL);
}
