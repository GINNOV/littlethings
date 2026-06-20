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
 * Hce_Menu.c:
 *
 *    Functions to add Intuition Menus to Intuition Windows.
 *    Developed from the PCQ (Pascal) Menu System by Patrick Quiad.
 *
 */

#include <intuition/intuition.h>
#include <exec/memory.h>
#include <clib/string.h>
#include <clib/stdio.h>
#include "Hce.h"
#include "Hce_Gfx.h"

chip struct Menu *MENU_START = NULL;
struct Menu *currentmenu = NULL;
struct MenuItem *currentitem = NULL;
struct MenuItem *currentsub = NULL;

int micheck = 0;        /* Check if first MenuItem ,for current Menu.     */
int sicheck = 0;        /* Check if first SubItem ,for current MenuItem.  */
int MENU_FAIL = FALSE;  /* If True, no more Menus/MenuItens etc are made. */

void NewItem(name, comm)   /* Make a New MenuItem. */
char *name;
char comm;
{
  struct IntuiText *it;
  struct MenuItem *mi;

  if(MENU_FAIL)  return;  /* Previous memory failure. */

  it = (struct IntuiText *)AllocMem(sizeof(struct IntuiText), 
                                         MEMF_CHIP|MEMF_CLEAR);
  if(!it) {
         MENU_FAIL = TRUE;
         return;
   }
  mi = (struct MenuItem *)AllocMem(sizeof(struct MenuItem), 
                                         MEMF_CHIP|MEMF_CLEAR);
  if(!mi) {
         MENU_FAIL = TRUE;
         return;
   }

  it->FrontPen = 2;                /* Set up an IntuiText. */
  it->BackPen = 1;
  it->DrawMode = JAM2;
  it->LeftEdge = MENU_LEFTEDGE;    /* or CHECKWIDTH */
  it->TopEdge = 1;
  it->ITextFont = NULL;
  it->IText = (UBYTE *)name;
  it->NextText = NULL;

  mi->NextItem = NULL;          /* Set up the Menu Item.*/
  mi->LeftEdge = 0;
  mi->TopEdge = 0;
 if(comm != '\0')               /* Add a little Space ,if key Command. */
    mi->Width = ((strlen(name) * 8) + ((MENU_LEFTEDGE * 2) + 48));
 else
    mi->Width = ((strlen(name) * 8) + (MENU_LEFTEDGE * 2));
  mi->Height = 10;
  mi->ItemFill = (APTR)it;
  mi->SelectFill = NULL;
  mi->SubItem = NULL;
  mi->NextSelect = MENUNULL;

  if( micheck == 0)         /* Make the first MenuItem ,for current Menu. */
     {
	if(comm != '\0')    /* Check for key Command. */
           {                /* CHECKIT|CHECKED.       */
           mi->Flags = ITEMTEXT|ITEMENABLED|HIGHCOMP|COMMSEQ;
	   mi->Command = comm;
            }
          else
           {
           mi->Flags = ITEMTEXT|ITEMENABLED|HIGHCOMP;
            }
           mi->MutualExclude = 0xFFFFFFFE;
           currentmenu->FirstItem = mi;          /* Attach FirstItem.    */
           currentitem = currentmenu->FirstItem; /* point at first item. */
      }
   else     /* Next MenuItem. */
     {
            mi->TopEdge = currentitem->TopEdge + 10;
            mi->MutualExclude = 0x00000001;

	if(comm != '\0')
           {
            mi->Flags = ITEMTEXT|ITEMENABLED|HIGHCOMP|COMMSEQ;
	    mi->Command = comm;
            }
          else
           {
            mi->Flags = ITEMTEXT|ITEMENABLED|HIGHCOMP;
            }

         currentitem->NextItem = mi;            /* Next Menu item.    */
         currentitem = currentitem->NextItem;   /* Point at NextItem. */
      }
      sicheck = 0;           /* Reset SubItem Check. */
      micheck++;             /* Inc MenuItem count.  */
}

void NewSubItem(name, comm)   /* Make a New SubItem. */
char *name;
char comm;
{
  struct IntuiText *it;
  struct MenuItem *si;

  if(MENU_FAIL)  return;  /* Previous memory failure. */

  it = (struct IntuiText *)AllocMem(sizeof(struct IntuiText), 
                                        MEMF_CHIP|MEMF_CLEAR);
  if(!it) { 
      MENU_FAIL = TRUE;
      return;
  }
  si = (struct MenuItem *)AllocMem(sizeof(struct MenuItem), 
                                        MEMF_CHIP|MEMF_CLEAR);
  if(!si) {
      MENU_FAIL = TRUE;
      return;
  }

  it->FrontPen = 1;                     /* Set up an IntuiText. */
  it->BackPen = 2;
  it->DrawMode = JAM2;
  it->LeftEdge = MENU_LEFTEDGE;
  it->TopEdge = 1;
  it->ITextFont = NULL;
  it->IText = (UBYTE *)name;
  it->NextText = NULL;

  si->NextItem = NULL;                  /* Set up the SubItem. */
  si->LeftEdge = (currentitem->Width - 24);
  si->TopEdge = 5;

 if(comm != '\0')               /* Add a little Space, if key Command. */
    si->Width = ((strlen(name) * 8) + ((MENU_LEFTEDGE * 2) + 48));
 else
    si->Width = ((strlen(name) * 8) + (MENU_LEFTEDGE * 2));

  si->Height = 10;
  si->ItemFill = (APTR)it;
  si->SelectFill = NULL;
  si->SubItem = NULL;                   /* NULL for now. */ 
  si->NextSelect = MENUNULL;

    if(sicheck == 0)      /* Check for first SubItem. */
          {
 	  if(comm != '\0')
            {
             si->Flags = ITEMTEXT|ITEMENABLED|HIGHCOMP|COMMSEQ;
	     si->Command = comm;
             }
          else
            {
             si->Flags = ITEMTEXT|ITEMENABLED|HIGHCOMP;
             }
            si->MutualExclude = 0xFFFFFFFE;
           currentitem->SubItem = si;
           currentsub = currentitem->SubItem;
           }
      else         /* Next SubItem. */
        {
           si->TopEdge = currentsub->TopEdge + 10;

	if(comm != '\0')
           {
            si->Flags = ITEMTEXT|ITEMENABLED|HIGHCOMP|COMMSEQ;
	    si->Command = comm;
            }
          else
           {
            si->Flags = ITEMTEXT|ITEMENABLED|HIGHCOMP;
            }
            si->MutualExclude = 0x00000001;
            currentsub->NextItem = si;
            currentsub = currentsub->NextItem;
        }
    sicheck++;          /* Inc SubItem Check!. */
}

void NewMenu(mflg,name)       /* Make an Intuition Menu. */
int mflg;
char *name;
{
   struct Menu *m;

   if(MENU_FAIL)  return;  /* Previous memory failure. */

   if(mflg)                /* New Menu System. Probably new Window. */
      MENU_START = NULL;

   m = (struct Menu *)AllocMem(sizeof(struct Menu), 
                                               MEMF_CHIP|MEMF_CLEAR);
   if(!m) {
       MENU_FAIL = TRUE;
       return;
   }  
   micheck = 0;                    /* Set MenuItem check. */
   sicheck = 0;                    /* Set SubItem check.  */

   m->NextMenu = NULL;
   m->LeftEdge = 0;
   m->TopEdge = 0;
   m->Width = (strlen(name) * 10);
   m->Height = 0;
   m->Flags = MENUENABLED;
   m->MenuName = name;
   m->FirstItem = NULL;

  if( MENU_START == NULL ) {         /* Get first Menu. */
       MENU_START = m;
       currentmenu = m;
    }
   else                            /* Next Menu. */
     {
       m->LeftEdge = currentmenu->LeftEdge + 
                     ((strlen(currentmenu->MenuName) * 10) + 16);
       currentmenu->NextMenu = m;
       currentmenu = currentmenu->NextMenu;
       }
}

struct Menu *AttachMenu(w)       /* Attach the Menu to the Users Window.*/
struct Window *w;
{
 if(MENU_FAIL)  return(NULL);         /* Previous memory failure. */
 if(!(SetMenuStrip( w, MENU_START ))) /* Add menu system to wind. */
     return (NULL);
   else
     return(MENU_START);
}

void LoseMenu(w, m)              /* Clear Menu from Users Window. */
struct Window *w;
struct Menu *m;
{
  if(MENU_FAIL != TRUE)
     ClearMenuStrip( w );

     FreeMenus(m);               /* Free all Menu Memory. */
}

void FreeSubs(mi)                /* Free all SubItems for MenuItem mi. */
struct MenuItem *mi;
{
  struct MenuItem *csub, *sub;   /* SubItem pointers. */
  sub = mi->SubItem;

  if(sub == NULL) return;        /* No subItem. */

             /* Free all SubItems. */
   do {
       csub = sub->NextItem;      /* Get next. */
       if(sub->ItemFill != NULL)
           FreeMem(sub->ItemFill, sizeof(struct IntuiText));
           FreeMem(sub, sizeof(struct MenuItem));
       sub = csub;               /* Point to next. */
       }
   while(sub != NULL);
}

void FreeItems(mi)          /* Free all MenuItems starting from mi. */
struct MenuItem *mi;
{
  struct MenuItem *fmi, *cmi;
  fmi = mi;                 /* Point to FirstItem. */

  if(mi == NULL) return;    /* NoItems.            */

 do {
     FreeSubs(fmi);         /* Free all SubItems for each  MenuItem. */

     cmi = fmi->NextItem;   /* Get Next.      */

    if(fmi != NULL) {       /* Free MenuItem + Itext. */
       if(fmi->ItemFill != NULL)
           FreeMem(fmi->ItemFill, sizeof(struct IntuiText));
           FreeMem(fmi, sizeof(struct MenuItem));
       }
     fmi = cmi;             /* Point to next. */
     }
 while (fmi != NULL);
}

void FreeMenus(m)  /* Free Menu 'm' plus all other Menus in list, */
struct Menu *m;    /* MenuItem+SubItem Memory for each Menu is also Freed. */
{
  struct Menu *cm;

  if(m == NULL) return;          /* No Menu to Free. */


        /* Loop Until No Menus left in List. */
  do {
       FreeItems(m->FirstItem); /* Free all MenuItems/SubItems. */

       cm = m->NextMenu;        /* Get NextMenu. */

       if(m != NULL) {
          FreeMem(m, sizeof(struct Menu));  /* Free Menu struct. */
        }
       m = cm;                  /* Point at next. */
      } 
  while(m != NULL); 
}
