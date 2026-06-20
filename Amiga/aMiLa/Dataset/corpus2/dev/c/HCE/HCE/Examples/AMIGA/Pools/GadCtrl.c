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
 *     GadControl.c:
 *
 *     This file decides what happens after a gadget is pressed/depressed.
 *
 */

#include <exec/types.h>
#include <clib/stdio.h>
#include <intuition/intuition.h>

#ifndef GRAPHICS_GFXBASE_H
#include <graphics/gfxbase.h>
#endif

#include <libraries/gadtools.h>
#include "pools.h"

extern struct Screen *my_screen;      /* Only screen. */
extern struct Window *gfx_window;     /* Graphics window. (Shared window).*/
extern struct Window *g_window;       /* Options window. (Shared window). */
extern struct NewWindow g_new_window;

extern struct Gadget *gt_gadlist;     /* Head of league gadget list.    */
extern struct Gadget *sl_gadlist;     /* Head of select league gad list.*/
extern int coupon_c;                  /* Current pools coupon number.   */

static char *gt_sptr;                 /* Pointer to string gadget strings.*/


int Open_GWind(name)   /* Open g_window, and add BOOL 'League' gadgets. */
char *name;
{
        g_new_window.FirstGadget = gt_gadlist;
        g_new_window.TopEdge = 1;
        g_new_window.Height = 255;  /* Do not lower this. */
   if(name)
        g_new_window.Title = (UBYTE *)name;
      else
        g_new_window.Title = NULL;

  if(!(g_window = (struct Window *) OpenWindow( &g_new_window )))
        return(NULL);

   GT_RefreshWindow(g_window);
return(1);
}

void Refresh_GWind()  /* Refresh gadgets in 'g_window'. */
{
   GT_RefreshWindow(g_window);
}

void Close_GWind()  /* Close g_window. (General purpose Window). */
{
  if(g_window)
   CloseWindow(g_window);
   g_window = NULL;
}

long Get_GMsgs()  /* Return Gadget selected ,window close(1000) or, */
{                 /* -1 if nothing has happened. (g_window).        */
  ULONG class;
  APTR address;
  LONG retval = -1;
  int gnum;

  struct Gadget *agad = NULL;
  struct StringInfo *astr;
  struct IntuiMessage *imsg;

  imsg = (struct IntuiMessage *) GT_GetIMsg( g_window->UserPort );

  if(imsg)
    {
      class = imsg->Class;
      address = (APTR)imsg->IAddress;

      GT_ReplyIMsg( imsg );

      switch( class )
      {
        case IDCMP_CLOSEWINDOW:            /* Close window gadget! */
               retval = 1000;
               break;                          
        case IDCMP_GADGETUP:
              agad = (struct Gadget *)gt_gadlist;

           if(!agad)      /* ?. */
              return(-1);

              agad = agad->NextGadget;        /* Get past dummy gad. */
              gnum = 0;

              if(agad)  /* Get Gadget num & string if string gadget. */
                {
                    do {
                     if(address == (APTR)agad) {       /* Find gad num. */
                             retval = (LONG)gnum;
                          if(agad->SpecialInfo) {      /* Is string gad?. */
                             astr = (struct StringInfo *)agad->SpecialInfo;
                             gt_sptr = (char *)astr->Buffer; /* Get str!.*/
                             coupon_c = (int)astr->LongInt;
                             }
                         }
                           gnum++;
                          agad = agad->NextGadget;
                       } while(agad && gnum < 36);
                 }
        break;
        }
    }
return(retval);
}

long Get_GMsgs2()  /* Return Gadget selected ,window close(1000) or, */
{                  /* -1 if nothing has happened.  (gfx_window).     */
  ULONG class;
  APTR address;
  LONG retval = -1;
  int gnum;

  struct Gadget *agad = NULL;
  struct StringInfo *astr;
  struct IntuiMessage *imsg;

  imsg = (struct IntuiMessage *) GT_GetIMsg( gfx_window->UserPort );

  if(imsg)
    {
      class = imsg->Class;
      address = (APTR)imsg->IAddress;

      GT_ReplyIMsg( imsg );

      switch( class )
      {
        case IDCMP_CLOSEWINDOW:            /* Close window gadget! */
               retval = 1000;
               break;                          
        case IDCMP_GADGETUP:
              agad = (struct Gadget *)sl_gadlist;

           if(!agad)      /* ?. */
              return(-1);

              agad = agad->NextGadget;        /* Get past dummy gad. */
              gnum = 0;

              if(agad)  /* Get Gadget num & string if string gadget. */
                {
                    do {
                     if(address == (APTR)agad) {       /* Find gad num. */
                             retval = (LONG)gnum;
                          if(agad->SpecialInfo) {      /* Is string gad?. */
                             astr = (struct StringInfo *)agad->SpecialInfo;
                             gt_sptr = (char *)astr->Buffer; /* Get str!.*/
                             }
                         }
                           gnum++;
                          agad = agad->NextGadget;
                       } while(agad && gnum < 35);
                 }
        break;
        }
    }
return(retval);
}
