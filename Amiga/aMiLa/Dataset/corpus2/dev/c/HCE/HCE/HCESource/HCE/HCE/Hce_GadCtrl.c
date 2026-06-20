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
 * Hce_GadCtrl.c:
 *
 *    This file contains functions which decide what happens after a Gadget
 *    is pressed either in the console window (my_window) or the graphics
 *    window (gfx_window).
 */

#include <exec/types.h>
#include <clib/stdio.h>
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <libraries/gadtools.h>

#include "Hce.h"
#include "Hce_Gfx.h"
#include "Hce_Con.h"
#include "Hce_GadTools.h"
#include "Hce_InOut.h"
#include "Hce_Block.h"

extern char *a_templist[56];     /* Hold file names to be assembled.*/
extern char *l_templist[56];     /* Hold file names to be linked.   */

char *WinNames[] = {"HCC Options","TOP Options","A68K Options",
                    "BLINK Options","Enter - Search String...",
                    "Find/Replace...", "Enter - Line Number...",
                    "Print...","Prefs/Config..."};

struct any_RGB pref_t[8];        /* Copy of palette for cancels. */
UBYTE  penshop_t[3];             /* Copy of pen/paper colours for cancels*/

static struct Gadget *sel_gad=0; /* Holds a pointer to next string gad.  */
                                 /* Used to select next gad in list.     */
static struct StringInfo *pstr;  /* Temp string info pointer.            */
static int cur_colour=1;         /* Current colour selected in palette.  */
static WORD holdval[2];          /* Hold different values for cancels.   */
int c_sensitive = FALSE;         /* Case sensitive flag for find/replace.*/

int Open_GWind() /* Open g_window. (General purpose shared Window).*/
{                /* Used below. */
  if(!(g_window = (struct Window *) OpenWindow( &g_new_window )))
        return(NULL);

 return(1);
}

void Close_GWind()  /* Close g_window and free any GadTools gads attached. */
{
   if(g_window != NULL) {
      CloseWindow(g_window);
      Free_GT_Gadgets(); 
      g_window = NULL;
      }
}

int Open_C_Wind()  /* Open g_window, and add 'comp' gadgets. */
{
    if (!(Alloc_C_Gadgets()))
        return(NULL);

        g_new_window.FirstGadget = c_gadlist;
        g_new_window.Height = 229;
        g_new_window.Title = (UBYTE *)WinNames[0];

     if(!(Open_GWind()))
        return(NULL);

   gw_Wactive();                       /* Wait for window to become active.*/
   bevelbox_A((WORD)13,(WORD)15,(WORD)614,(WORD)205,(WORD)0);   /* Border. */
   GT_RefreshWindow(g_window);
                                       /* Activate Compile List gadget. */
   MakeGadActive(c_gadlist,10);
return(1);
}

int Open_O_Wind()  /* Open g_window and add 'opt' gadgets. */
{
 if(!(Alloc_O_Gadgets()))
    return(NULL);

    g_new_window.FirstGadget = o_gadlist;
    g_new_window.Height = 210;
    g_new_window.Title = (UBYTE *)WinNames[1];

 if(!(Open_GWind()))
    return(NULL);
    bevelbox_A((WORD)13,(WORD)15,(WORD)614,(WORD)188,(WORD)0);  /* Border. */
    GT_RefreshWindow(g_window);
return(1);
}

int Open_A_Wind()  /* Open g_window and add 'assem' gadgets. */
{
 if(!(Alloc_A_Gadgets()))
    return(NULL);

    g_new_window.FirstGadget = a_gadlist;
    g_new_window.Height = 226;
    g_new_window.Title = (UBYTE *)WinNames[2];

 if(!(Open_GWind()))
    return(NULL);
    bevelbox_A((WORD)13,(WORD)15,(WORD)614,(WORD)204,(WORD)0);  /* Border. */
    GT_RefreshWindow(g_window);
    MakeGadActive(a_gadlist,4);
return(1);
}

int Open_L_Wind()  /* Open g_window and add 'linker' gadgets. */
{
  if(!(Alloc_L_Gadgets()))
     return(NULL);

     g_new_window.FirstGadget = l_gadlist;
     g_new_window.Height = 250;
     g_new_window.Title = (UBYTE *)WinNames[3];

  if(!(Open_GWind()))
     return(NULL);

     gw_Wactive();
     bevelbox_A((WORD)13,(WORD)15,(WORD)614,(WORD)226,(WORD)0);  /* Border*/
     GT_RefreshWindow(g_window);
     MakeGadActive(l_gadlist,10);
return(1);
}

int Open_F_Wind()  /* Open g_window and add 'find' gadgets. */
{
    if(!(Alloc_F_Gadgets()))
       return(NULL);

      g_new_window.FirstGadget = f_gadlist;
      g_new_window.Height = 29;
      g_new_window.Title = (UBYTE *)WinNames[4];

    if(!(Open_GWind()))
        return(NULL);

       gw_Wactive();
       GT_RefreshWindow(g_window);
       MakeGadActive(f_gadlist,1);
return(1);
}

int Open_R_Wind()  /* Open g_window and add 'replace' gadgets. */
{
 if(!(Alloc_R_Gadgets()))
    return(NULL);

    g_new_window.FirstGadget = r_gadlist;
    g_new_window.Height = 116;
    g_new_window.Title = (UBYTE *)WinNames[5];

 if(!(Open_GWind()))
    return(NULL);

    gw_Wactive();
    bevelbox_A((WORD)13,(WORD)15,(WORD)614,(WORD)94,(WORD)0);  /* Border. */
    GT_RefreshWindow(g_window);
    MakeGadActive(r_gadlist,1);
return(1);
}

int Open_J_Wind()  /* Open g_window and add 'Jump to line' gadgets. */
{
    if(!(Alloc_J_Gadgets()))
       return(NULL);

       g_new_window.FirstGadget = j_gadlist;
       g_new_window.Height = 29;
       g_new_window.Title = (UBYTE *)WinNames[6];

    if(!(Open_GWind()))
        return(NULL);

       gw_Wactive();
       GT_RefreshWindow(g_window);
       MakeGadActive(j_gadlist,1);
return(1);
}

int Open_P_Wind()  /* Open g_window and add 'Printer' gadgets. */
{
 if(!(Alloc_P_Gadgets()))
    return(NULL);

    g_new_window.FirstGadget = p_gadlist;
    g_new_window.Height = 102;
    g_new_window.Title = (UBYTE *)WinNames[7];

 if(!(Open_GWind()))
    return(NULL);

    gw_Wactive();
    bevelbox_A((WORD)13,(WORD)15,(WORD)614,(WORD)80,(WORD)0);  /* Border. */
    GT_RefreshWindow(g_window);
    MakeGadActive(p_gadlist,1);
return(1);
}

int Open_Prefs_W()  /* Open g_window and add 'Preferences' gadgets. */
{
   if(!(Alloc_Pref_Gads()))
      return(NULL);
 
      g_new_window.FirstGadget = prefs_glist;
      g_new_window.Height = 174;
      g_new_window.Title = (UBYTE *)WinNames[8];
      dup_Palette();           /* Keep a copy of palette,  */
      holdval[0] = P_GadBN[0]; /* Waitkey true/false indicator, */
      holdval[1] = P_GadBN[1]; /* and tab stop number, for cancels.*/
      cur_colour = 1;          /* Always start with colour 1. */

    if(!(Open_GWind()))
        return(NULL);

      gw_Wactive();
      GT_RefreshWindow(g_window);
      set_Sliders((WORD)cur_colour); /* Set RGB sliders to selected colour.*/
      bevelbox_A((WORD)13,(WORD)15,(WORD)615,(WORD)154,(WORD)0);  /* Big box*/
      bevelbox_A((WORD)28,(WORD)25,(WORD)270,(WORD)134,(WORD)1);  /* Inner1.*/
      bevelbox_A((WORD)340,(WORD)25,(WORD)270,(WORD)134,(WORD)1); /* Inner2.*/
return(1);
}

int Do_ReqWin(msg)  /* Open g_window add req gadgets then wait for user*/
char *msg;          /* to either enter a string or close the window.   */
{                   /* A return value greater than 0 = got string.     */
   if(!(Alloc_Req_Gads()))
      return(0);
 
      g_new_window.FirstGadget = req_glist;
      g_new_window.Height = 26;
      g_new_window.Width = 251;
      g_new_window.LeftEdge = 180;
      g_new_window.TopEdge = 80;
      g_new_window.Title = (UBYTE *)msg;

    if(!(Open_GWind()))
        return(0);

      gw_Wactive();
      GT_RefreshWindow(g_window);
      MakeGadActive(req_glist,1);
      ReqBuf[0] = '\0';
      Do_GadMsgs();
      g_new_window.LeftEdge = 0;
      g_new_window.TopEdge = 0;
      g_new_window.Width = 640;

   if(ReqBuf[0] == '\0')
      return(0);
return(1);
}

void dup_Palette() /* Duplicate first 8 colours of palette. (0-7)*/
{                  /* Also dup con win pen/paper/markout colours. */
 WORD i=0;

 while(i < 8) {
    pref_t[i].red = (UBYTE)pref_c[i].red;
    pref_t[i].green = (UBYTE)pref_c[i].green;
    pref_t[i].blue = (UBYTE)pref_c[i].blue;
    i++;
    }
    penshop_t[CON_PEN] = penshop[CON_PEN];       /* pen   */
    penshop_t[CON_PAPER] = penshop[CON_PAPER];   /* paper */
    penshop_t[CON_MARKER] = penshop[CON_MARKER]; /* markout */
}

void res_Palette() /* Restore first 8 colours of palette. (0-7)*/
{                  /* Also pen/paper/markout colours. */
 WORD i=0;

 while(i < 8) {
   Set1_RGB4((WORD)i,(WORD)0,(UBYTE)pref_t[i].red);    /* Red  */
   Set1_RGB4((WORD)i,(WORD)1,(UBYTE)pref_t[i].green);  /* Green */
   Set1_RGB4((WORD)i,(WORD)2,(UBYTE)pref_t[i].blue);   /* Blue  */
   i++;
   }
   set_Sliders((WORD)cur_colour);
   penshop[CON_PEN] = penshop_t[CON_PEN];       /* pen   */
   penshop[CON_PAPER] = penshop_t[CON_PAPER];   /* paper */
   penshop[CON_MARKER] = penshop_t[CON_MARKER]; /* markout */

   c_NewConPens(); /* Show con win ,pen changes. */
}

void new_Palette() /* Restore palette after loading new config file. */
{
 WORD i=0;

 while(i < 8) {
   Set1_RGB4((WORD)i,(WORD)0,(UBYTE)pref_c[i].red);    /* Red  */
   Set1_RGB4((WORD)i,(WORD)1,(UBYTE)pref_c[i].green);  /* Green */
   Set1_RGB4((WORD)i,(WORD)2,(UBYTE)pref_c[i].blue);   /* Blue  */
   i++;
   }
   set_Sliders((WORD)cur_colour);
   c_NewConPens(); /* Show con win ,pen changes. */
}

/* Switch selected palette colour. (0-7) */
void set_Palcor(colour)
UBYTE colour;
{
  struct TagItem tg[2];

  tg[0].ti_Tag = GTPA_Color;
  tg[0].ti_Data = (ULONG)colour;
  tg[1].ti_Tag = TAG_DONE;
  tg[1].ti_Data = TAG_DONE;
  GT_SetGadgetAttrsA(prefs_glist->NextGadget,g_window,NULL,tg);
}

/* Set the prefs window RGB slider gadgets to positions which correspond */
/* to the chosen 'colour'. */
void set_Sliders(colour)
WORD colour;
{
  struct Gadget *g;
  struct TagItem tg[2];
  g = prefs_glist->NextGadget; /* Point past dummy. */

  tg[0].ti_Tag = GTSL_Level;
  tg[1].ti_Tag = TAG_DONE;
  tg[1].ti_Data = TAG_DONE;

  g = g->NextGadget;
  g = g->NextGadget;
  tg[0].ti_Data = (ULONG)pref_c[colour].red;
  GT_SetGadgetAttrsA(g,g_window,NULL,tg);      /* Red slider. */

  g = g->NextGadget;
  g = g->NextGadget;
  tg[0].ti_Data = (ULONG)pref_c[colour].green;
  GT_SetGadgetAttrsA(g,g_window,NULL,tg);      /* Green. */

  g = g->NextGadget;
  g = g->NextGadget;
  tg[0].ti_Data = (ULONG)pref_c[colour].blue;
  GT_SetGadgetAttrsA(g,g_window,NULL,tg);      /* Blue. */
}

void gw_Wactive()  /* Return when we receive IDCMP_ACTIVEWINDOW. */
{                  /* 'g_window'. */
  struct IntuiMessage *my_message;
  ULONG class;

 do {
     my_message = (struct IntuiMessage *) GT_GetIMsg( g_window->UserPort );

     if(my_message) {
        class = my_message->Class;
        GT_ReplyIMsg( my_message );
        }
     } while(class != IDCMP_ACTIVEWINDOW);
}

void cw_Wactive()  /* Return when we receive IDCMP_ACTIVEWINDOW. */
{                  /* Console window. 'my_window'. */
  struct IntuiMessage *my_message;
  ULONG class;

 do {
     my_message = (struct IntuiMessage *) GetMsg( my_window->UserPort );

     if(my_message) {
        class = my_message->Class;
        ReplyMsg( my_message );
        }
     } while(class != IDCMP_ACTIVEWINDOW);
}

void ActivateCW()               /* Make console window active. */ 
{
     ActivateWindow(my_window); /* Reactivate Console Window. */
     cw_Wactive();              /* Must wait until active!.   */
     Show_W_STAT(1);            /* Show window Active simble. */
}

/* Find gadget in 'g_list' (using num) and return a pointer to it. */
struct Gadget *find_GAD(g_list,num)
struct Gadget *g_list;
int num;
{
   while(g_list->NextGadget && num--)
         g_list = g_list->NextGadget;
 return(g_list);
}

/* Make string gadget in 'g_list' at 'g_place' the active gadget. */
void MakeGadActive(g_list,g_place)
struct Gadget *g_list;
int g_place;
{
   ActivateGadget(find_GAD(g_list,g_place),g_window,NULL);
}

int Do_GadMsgs()          /* Act on messages retrieved by Process_GMsgs().*/
{                         /* Return when Close gadget is pressed or if    */
 struct StringInfo *astr; /* a gadget sets the end condition.(-2)         */
 LONG class;
 UWORD code;
 char *p;
 int gad_id, gact_flg;

 do 
  {
     class = Process_GMsgs(&gad_id, &code);
     gact_flg=0;  /* Activate next gad flag?. */

  if(class != -1)
    {
    switch(gad_id)
     {
      case COMPILER_GAD:
             switch(class)
                {
                 case 0:            /* Select Compile (from). */
                        C_GadBN[2] = (int)code;
                        break;
                 case 1:            /* Debug. */
                        strcpy(C_Debug, pstr->Buffer);
                        gact_flg++;
                        break;
                 case 2:            /* Define Symbol. */
                        strcpy(C_DefSym, pstr->Buffer);
                        gact_flg++;
                        break;
                 case 3:            /* Undefine Symbol. */
                        strcpy(C_UnDefSym, pstr->Buffer);
                        gact_flg++;
                        break;
                 case 4:            /* Include dir list. */
                        strcpy(C_IDirList, pstr->Buffer);
                        Add_Slash(C_IDirList);  /* Adds '/' if required. */
                        gact_flg++;
                        break;
                 case 5:            /* QAUD file device. */
                        strcpy(C_QuadDev, pstr->Buffer);
                        Add_Slash(C_QuadDev);
                        MakeGadActive(c_gadlist,10);
                        break;
                 case 6:            /* Keep Quad files. */
                        C_GadBN[0] = (C_GadBN[0]>0) ? 0 : 1;
                        break;
                 case 7:            /* Int & unsigned ?BIT.*/
                        C_GadBN[1] = (C_GadBN[1]>0) ? 0 : 1;
                        break;
                 case 8:            /* Free-Up */
                        C_GadBN[3] = (C_GadBN[3]>0) ? 0 : 1;
                        break;
                 case 9:            /* Compile List. */
                        strcpy(C_WorkList, pstr->Buffer);
                        MakeGadActive(c_gadlist,15);
                        break;
                 case 10:            /* Duplicate list */
                     if(C_WorkList[0] != '\0') {
                       if(!Do_ReqV2("Please - Confirm!"))
                          break;
                       }
                       if(!(dup_ARGLIST(C_WorkList,L_LinkList,".c")))
                          Do_ReqV1("Unknown duplication error!");
                          mod_StrGad(c_gadlist, (WORD)10, C_WorkList);
                          MakeGadActive(c_gadlist,10);
                        break;
                 case 11:            /* Check list. */
                        check_ARGLIST(C_WorkList, NULL);
                        MakeGadActive(c_gadlist,10);
                        break;
                 case 12:           /* Clear list. */
                     if(C_WorkList[0] != '\0') {
                       if(!Do_ReqV2("Please - Confirm!"))
                          break;
                        }
                        C_WorkList[0] = '\0';
                        mod_StrGad(c_gadlist, (WORD)10, C_WorkList);
                        MakeGadActive(c_gadlist,10);
                        break;
                 case 13:         /* Disk to list. */
                     if(!(Get_IO_NAME(IO_PATH,PR_BUF)))
                        break;
                     if(!(p = (char *)StripFN(PR_BUF))) {
                        p = (char *)malloc(2);
                        p[0] = '\0';
                        }
                     if(p) {
                        DiskToList(p,C_Pattern,C_WorkList,GB_LSIZE-1);
                        free(p);
                        mod_StrGad(c_gadlist, (WORD)10, C_WorkList);
                        MakeGadActive(c_gadlist,10);
                        }
                        break;
                 case 14:           /* Pattern. */
                        strcpy(C_Pattern, pstr->Buffer);
                        MakeGadActive(c_gadlist,2);
                        break;
                 case 15:           /* Load compile list. */
                       if(!(Get_IO_NAME(IO_LOAD,PR_BUF)))
                          break;
                          load_ALIST(PR_BUF,0);
                          mod_StrGad(c_gadlist, (WORD)10, C_WorkList);
                          mod_StrGad(c_gadlist, (WORD)3, C_DefSym);
                          MakeGadActive(c_gadlist,10);
                        break;
                 case 16:            /* Save compile list. */
                       if(!(Get_IO_NAME(IO_SAVE,PR_BUF)))
                          break;
                          save_ALIST(PR_BUF,0);
                          MakeGadActive(c_gadlist,10);
                        break;
                 case 17:           /* Exit. */
                        class = -2;
                        break;
                  }
           break;
      case OPTIMIZER_GAD:
             switch(class)
                {
                 case 0:            /* Debug. */
                        O_GadBN[0] = (O_GadBN[0]>0) ? 0 : 1;
                        break;
                 case 1:            /* Verbose. */
                        O_GadBN[1] = (O_GadBN[1]>0) ? 0 : 1;
                        break;
                 case 2:            /* Branch Reversal. */
                        O_GadBN[2] = (O_GadBN[2]>0) ? 0 : 1;
                        break;
                 case 3:            /* Loop Rotation. */
                        O_GadBN[3] = (O_GadBN[3]>0) ? 0 : 1;
                        break;
                 case 4:            /* Peephole optimization. */
                        O_GadBN[4] = (O_GadBN[4]>0) ? 0 : 1;
                        break;
                 case 5:            /* Variable Registerizing. */
                        O_GadBN[7] = (O_GadBN[7]>0) ? 0 : 1;
                        break;
                 case 6:            /* No change of stack-fixups. */
                        O_GadBN[5] = (O_GadBN[5]>0) ? 0 : 1;
                        break;
                 case 7:            /* Data-Bss to Chip. */
                        O_GadBN[6] = (O_GadBN[6]>0) ? 0 : 1;
                        break;
                 case 8:            /* Exit. */
                        class = -2;
                        break;
                  }
           break;
      case ASSEMBLER_GAD:
             switch(class)
                {
                 case 0:            /* Symbol to obj. */
                        A_GadBN[0] = (A_GadBN[0]>0) ? 0 : 1;
                        break;
                 case 1:            /* Write equate file.*/
                        A_GadBN[1] = (A_GadBN[1]>0) ? 0 : 1;
                        break;
                 case 2:            /* Verbose. */
                        A_GadBN[2] = (A_GadBN[2]>0) ? 0 : 1;
                        break;
                 case 3:            /* Outpath. */
                        strcpy(A_OutPath, pstr->Buffer);
                        Add_Slash(A_OutPath);
                        gact_flg++;
                        break;
                 case 4:            /* Include header file. */
                        strcpy(A_IncHeader, pstr->Buffer);
                        gact_flg++;
                        break;
                 case 5:            /* Include dir list.. */
                        strcpy(A_IDirList, pstr->Buffer);
                        gact_flg++;
                        break;
                 case 6:            /* Create a listing file. */
                        strcpy(A_CListFile, pstr->Buffer);
                        MakeGadActive(a_gadlist,10);
                        break;
                 case 7:            /* Disable Optimization. */
                        A_GadBN[3] = (A_GadBN[3]>0) ? 0 : 1;
                        break;
                 case 8:            /* Display hashing statistics. */
                        A_GadBN[4] = (A_GadBN[4]>0) ? 0 : 1;
                        break;
                 case 9:            /* Debug. */
                        strcpy(A_Debug, pstr->Buffer);
                        MakeGadActive(a_gadlist,4);
                        break;
                 case 10:           /* Exit. */
                        class = -2;
                        break;
                 }
           break;
      case LINKER_GAD:
                if(class == 19)
                   class = 18; /* Same op? */
             switch(class)
                {
                 case 0:            /* Link.(from) */
                        L_GadBN[3] = (int)code;
                        break;
                 case 1:            /* Startup Object. */
                        strcpy(L_StartOBJ, pstr->Buffer);
                        gact_flg++;
                        break;
                 case 2:            /* Maths Library. */
                        strcpy(L_MathLib, pstr->Buffer);
                        MakeGadActive(l_gadlist,5);
                        break;
                 case 3:            /* Use. (Maths Lib) */
                        L_GadBN[4] = (L_GadBN[4]>0) ? 0 : 1;
                        break;
                 case 4:            /* Other Libraries.*/
                        strcpy(L_Libs, pstr->Buffer);
                        gact_flg++;
                        break;
                 case 5:            /* New output file name. */
                        strcpy(L_OutName, pstr->Buffer);
                        MakeGadActive(l_gadlist,10);
                        break;
                 case 6:            /* Verbose. */
                        L_GadBN[0] = (L_GadBN[0]>0) ? 0 : 1;
                        break;
                 case 7:            /* Small_Data. */
                        L_GadBN[1] = (L_GadBN[1]>0) ? 0 : 1;
                        break;
                 case 8:            /* Small_Code. */
                        L_GadBN[2] = (L_GadBN[2]>0) ? 0 : 1;
                        break;
                 case 9:            /* Link List. */
                        strcpy(L_LinkList, pstr->Buffer);
                        MakeGadActive(l_gadlist,15);
                        break;
                 case 10:           /* Duplicate list. */
                     if(L_LinkList[0] != '\0') {
                       if(!Do_ReqV2("Please - Confirm!"))
                          break;
                        }
                       if(!(dup_ARGLIST(L_LinkList,C_WorkList,".o")))
                          Do_ReqV1("Unknown duplication error!");
                          mod_StrGad(l_gadlist, (WORD)10, L_LinkList);
                          MakeGadActive(l_gadlist,10);
                        break;
                 case 11:           /* Check list. */
                        check_ARGLIST(L_LinkList,NULL);
                        MakeGadActive(l_gadlist,10);
                        break;
                 case 12:           /* Clear list. */
                     if(L_LinkList[0] != '\0') {
                       if(!Do_ReqV2("Please - Confirm!"))
                          break;
                        }
                        L_LinkList[0] = '\0';
                        L_OutName[0] = '\0';
                        mod_StrGad(l_gadlist, (WORD)10, L_LinkList);
                        mod_StrGad(l_gadlist, (WORD)6, L_OutName);
                        MakeGadActive(l_gadlist,10);
                        break;
                 case 13:            /* Disk to List */
                     if(!(Get_IO_NAME(IO_PATH,PR_BUF)))
                        break;
                     if(!(p = (char *)StripFN(PR_BUF))) {
                        p = (char *)malloc(2);
                        p[0] = '\0';
                        }
                     if(p) {
                        DiskToList(p,L_Pattern,L_LinkList,GB_LSIZE-1);
                        free(p);
                        mod_StrGad(l_gadlist, (WORD)10, L_LinkList);
                        MakeGadActive(l_gadlist,10);
                        }
                        break;
                 case 14:            /* Pattern. */
                        strcpy(L_Pattern, pstr->Buffer);
                        MakeGadActive(l_gadlist,18);
                        break;
                 case 15:            /* Load Link List. */
                       if(!(Get_IO_NAME(IO_LOAD,PR_BUF)))
                          break;
                          load_ALIST(PR_BUF,1);
                          mod_StrGad(l_gadlist, (WORD)10, L_LinkList);
                          mod_StrGad(l_gadlist, (WORD)6, L_OutName);
                          mod_CBoxGad(l_gadlist,(WORD)4,L_GadBN[4]);
                          MakeGadActive(l_gadlist,10);
                        break;
                 case 16:            /* Save Link List. */
                       if(!(Get_IO_NAME(IO_SAVE,PR_BUF)))
                          break;
                          save_ALIST(PR_BUF,1);
                          MakeGadActive(l_gadlist,10);
                        break;
                 case 17:            /* Library OutName. */
                        strcpy(L_LibOut, pstr->Buffer);
                        MakeGadActive(l_gadlist,2);
                        break;
                 case 18:            /* FD To Lib. */
                      /* Note 'FD_TO_LIB' modifies str gad, 'Link List',*/
                      /* and others. */
                     if(L_LibOut[0] == '\0') {
                        Do_ReqV1("Require library name!");
                        break;
                        }
                        DO_FDTOLIB();
                        break;
                 case 19:            /* List To Lib. */
                        break;
                 case 20:            /* Exit. */
                        class = -2;
                        break;
                  }
           break;
      case FIND_GAD:
                   strcpy(Search_Name, pstr->Buffer);
                   class = -2;
                   break;
      case REPLACE_GAD:
                   switch(class) {
                         case 0:
                                strcpy(Search_Name, pstr->Buffer);
                                gact_flg++;
                                break;
                         case 1:
                                strcpy(Replace_Name, pstr->Buffer);
                                class = -2;
                                break;
                         case 2:    /* Case sensitivity flag. */
                                c_sensitive = (c_sensitive > 0) ? 0 : 1;
                                break;
                         case 3:    /* EXIT. */
                                class = IDCMP_CLOSEWINDOW;
                                break;
                                }
                   break;
      case JUMPTO_GAD:
                   astr = (struct StringInfo *)
                              j_gadlist->NextGadget->SpecialInfo;
                   jump_to_num = (int)astr->LongInt;
                   class = -2;
                   break;
      case PRINTER_GAD:
                         if(prt_num[0] < 0) /* Fix user to/from settings, */
                            prt_num[0] = 0; /* if incorect. */
                         if(prt_num[1] < 0)
                            prt_num[1] = 0;
            switch(class) {
                   case 0: /* Print from Line?. */
                          astr = (struct StringInfo *)
                          p_gadlist->NextGadget->SpecialInfo;
                          prt_num[0] = (int)astr->LongInt-1;
                          gact_flg++;
                          break;
                   case 1: /* Print to Line?. */
                          sel_gad = p_gadlist->NextGadget;
                          astr = (struct StringInfo *)
                          sel_gad->NextGadget->SpecialInfo;
                          prt_num[1] = (int)astr->LongInt-1;
                          ActivateGadget(p_gadlist->NextGadget,g_window,NULL);
                          break;
                   case 2: /* Print within to/from settings. */
                          Prt_LINE(NULL);
                          class = -2;
                          break;
                   case 3: /* Print all. */
                          Prt_LINE(1);
                          class = -2;
                          break;
                   case 4: /* EXIT. */
                          class = -2;
                          break;
                          }
                   break;
      case PREFS_GAD:
            switch(class) {
                   case 0: /* Palette selection colour. */
                          cur_colour = code;
                          set_Sliders(cur_colour);
                          break;
                   case 2: /* Red prop gad. */
                          Set1_RGB4((WORD)cur_colour,(WORD)0,(UBYTE)code);
                          break;
                   case 4: /* Green. */
                          Set1_RGB4((WORD)cur_colour,(WORD)1,(UBYTE)code);
                          break;
                   case 6: /* Blue. */
                          Set1_RGB4((WORD)cur_colour,(WORD)2,(UBYTE)code);
                          break;
                   case 7: /* Set new con win pen colour. */
                          penshop[CON_PEN] = (UBYTE)cur_colour;
                          c_NewConPens(); /* Show change. */
                          break;
                   case 8: /* Set new con win paper colour. */
                          penshop[CON_PAPER] = (UBYTE)cur_colour;
                          c_NewConPens();
                          break;
                   case 9: /* New mark out colour. */
                          penshop[CON_MARKER] = (UBYTE)cur_colour;
                          c_NewConPens();
                          break;
                   case 10: /* Set new tab stop. */
                          sel_gad = find_GAD(prefs_glist,11);
                          astr = (struct StringInfo *)sel_gad->SpecialInfo;
                          P_GadBN[1] = (WORD)astr->LongInt;
                          break;
                   case 11: /* Toggle run exe wait for key option. */
                          P_GadBN[0] = (P_GadBN[0]>0) ? 0 : 1;
                          break;
                   case 12:  /* CANCEL. */
                          res_Palette();           /* Restore palette. */
                          P_GadBN[0] = holdval[0]; /* Restore waitkey. */
                          P_GadBN[1] = holdval[1]; /* Restore tab number.*/
                          mod_CycleGad(prefs_glist,(WORD)12,P_GadBN[0]);
                          mod_IntGad(prefs_glist, (WORD)11, P_GadBN[1]);
                          break;
                   case 13: /* Load Def Config */
                       if(!Do_ReqV2("Please - Confirm!"))
                          break;
                       if(!(read_CONFIG(NULL))) {
                          Do_ReqV1("Could not open Config file!");
                          }
                          new_Palette();
                          mod_IntGad(prefs_glist, (WORD)11, P_GadBN[1]);
                          break;
                   case 14: /* Save Def Config */
                       if(!Do_ReqV2("Please - Confirm!"))
                          break;
                       if(!(write_CONFIG(NULL)))
                          Do_ReqV1("Could not open Config file!");
                          break;
                   case 15: /* Load Other */
                       if(!(Get_IO_NAME(IO_LCONFIG,PR_BUF)))
                          break;
                       if(!(read_CONFIG(PR_BUF)))
                          Do_ReqV1("Could not open Config file!");
                          new_Palette();
                          mod_IntGad(prefs_glist, (WORD)11, P_GadBN[1]);
                          break;
                   case 16: /* Save Other */
                       if(!(Get_IO_NAME(IO_SCONFIG,PR_BUF)))
                          break;
                       if(!(write_CONFIG(PR_BUF)))
                          Do_ReqV1("Could not open Config file!");
                          break;
                   case 17: /* EXIT. */
                          class = -2;
                          break;
                          }
                   break;
        case REQUESTER_GAD:
                        if(class == 0)
                          strcpy(ReqBuf, pstr->Buffer);
                          class = -2;
                   break;
      }
    }
   if(gact_flg)
      ActivateGadget(sel_gad, g_window, NULL);
  }
 while(class != IDCMP_CLOSEWINDOW && class != -2);

 Close_GWind();
 Show_FreeMem();

 if(class != -2)
     return(0); /* Window close gadget. */
   else
     return(1); /* Other Gadget caused close. */
}

long Process_GMsgs(id,code)  /* Process gadget messages. */
int *id;                     /* id = gadget id. */
UWORD *code;
{
  ULONG class;
  APTR address;
  LONG retval = -1;
  int gnum=0;

  struct Gadget *agad = NULL;
  struct IntuiMessage *my_message;

  my_message = (struct IntuiMessage *) GT_GetIMsg( g_window->UserPort );

  if(my_message)
    {
      class = my_message->Class;
      address = my_message->IAddress;
      *code = my_message->Code;
      GT_ReplyIMsg( my_message );
/*
      printf("class = %ld ,code = %d\n", class, *code);
*/
      switch( class )
      {
        case IDCMP_CLOSEWINDOW:
               retval = (LONG)IDCMP_CLOSEWINDOW;
               break;
        case IDCMP_RAWKEY:  /* Escape key. */
            if(*code == 69)
               retval = (LONG)IDCMP_CLOSEWINDOW;
               break;
        case IDCMP_MOUSEMOVE:
               *id = PREFS_GAD;
               agad = prefs_glist->NextGadget; /* Get new slider gad num. */
             do {
                 if(address == (APTR)agad)
                    retval = (LONG)gnum;
                    gnum++;
                    agad = agad->NextGadget;
                 } 
             while(agad && gnum < 15);
               break;
        case IDCMP_GADGETUP:
           if(c_gadlist == g_new_window.FirstGadget) { /* COMPILER opts?. */
              agad = (struct Gadget *)c_gadlist->NextGadget;
              *id = COMPILER_GAD;
             }
           if(o_gadlist == g_new_window.FirstGadget) { /* OPT opts?. */
              agad = (struct Gadget *)o_gadlist->NextGadget;
              *id = OPTIMIZER_GAD;
             } 
           if(a_gadlist == g_new_window.FirstGadget) { /* ASM opts?.  */
              agad = (struct Gadget *)a_gadlist->NextGadget;
              *id = ASSEMBLER_GAD;
             }
           if(l_gadlist == g_new_window.FirstGadget) { /* LINK opts?. */
              agad = (struct Gadget *)l_gadlist->NextGadget;
              *id = LINKER_GAD;
             } 
           if(f_gadlist == g_new_window.FirstGadget) { /* FIND?.    */
              agad = (struct Gadget *)f_gadlist->NextGadget;
              *id = FIND_GAD;
             } 
           if(r_gadlist == g_new_window.FirstGadget) { /* REPLACE?. */
              agad = (struct Gadget *)r_gadlist->NextGadget;
              *id = REPLACE_GAD;
             }
           if(j_gadlist == g_new_window.FirstGadget) { /* JUMPTO?. */
              agad = (struct Gadget *)j_gadlist->NextGadget;
              *id = JUMPTO_GAD;
             }
           if(p_gadlist == g_new_window.FirstGadget) { /* PRINTER?. */
              agad = (struct Gadget *)p_gadlist->NextGadget;
              *id = PRINTER_GAD;
             }
           if(prefs_glist == g_new_window.FirstGadget) { /* PREFS?. */
              agad = (struct Gadget *)prefs_glist->NextGadget;
              *id = PREFS_GAD;
             }
           if(req_glist == g_new_window.FirstGadget) { /* REQUESTER?. */
              agad = (struct Gadget *)req_glist->NextGadget;
              *id = REQUESTER_GAD;
             }

           if(!agad)      /* Not my gadget?. */
              return(-1);

               /* Get Gadget num. */     
                    do {
                      if(address == (APTR)agad) {       /* Find gad num. */
                           retval = (LONG)gnum;
                           sel_gad = agad->NextGadget;  /* get sel gad.*/
                         if(agad->SpecialInfo) {
                            pstr = (struct StringInfo *)agad->SpecialInfo;
                            }
                           }
                           gnum++;
                          agad = agad->NextGadget;
                        } while(agad && gnum < 21);
        break;
        }
    }
return(retval); /* return gadnum ,window-close or -1. */
}

void gfx_chinput() /* Check 'gfx_windows' gadgets for messages, */
{                  /* and call the appropriate routine.         */
 struct IntuiMessage *message; 
 char *strdup();
 APTR address;
 int class,code;
 WORD gnum = -1;
 WORD count = 0;
 struct Gadget *agad = gb_gadlist;

 if (message=(struct IntuiMessage *)GetMsg (gfx_window->UserPort))
   {
     class=message->Class;
     code=message->Code;
     address = message->IAddress;
     ReplyMsg (message);

    if(class==IDCMP_GADGETUP)
      {
         do {
           if(address == (APTR)agad)   /* Find gad num. */
               gnum = count;
               count++;
               agad = agad->NextGadget;
             } 
          while(agad && count < 7);

        if(gnum != -1)      /* Call required routine from here.*/
           {
         if(gnum != 0) {    /* Don`t clear block if Test.       */
            Check_MMARK();  /* Check not in mouse marked state. */
            Check_KMARK();  /* Check not in key marked state.   */
            }
          switch(gnum) {
                     case 0:                /* Test. */
                            ME_Menu2(0);
                            break;
                     case 1:                /* Comp + Opt + Assem. */
                            ME_Menu2(2);
                            break;
                     case 2:                /* Comp + O + A + Link. */
                            ME_Menu2(4);
                            break;
                     case 3:                /* Link. */
                            ME_Menu4(0);
                            break;
                     case 4:                /* Run-Linked. */
                            ME_Menu5(0);
                            Show_FreeMem();
                            break;
                     case 5:                /* Esc. */
                            break;
                     case 6:                /* Cleanup. */
                            count = 0;
                     while(a_templist[count] != NULL) { /* Del asm files */
                           if(DeleteFile(a_templist[count])) {
                              Show_StatV3("Deleted - %s",a_templist[count]);
                              Delay(15);
                              }
                            count++;
                            }
                            count = 0;
                     while(l_templist[count] != NULL) { /* Del linker files*/
                           if(DeleteFile(l_templist[count])) {
                              Show_StatV3("Deleted - %s",l_templist[count]);
                              Delay(15);
                              }
                            count++;
                            }
                            free_AsmList();
                            free_LinkList();
                            break;
                     default:
                            break;
                       }
           }
          ActivateCW();               /* Reactivate console window. */
        }
    }
}

int chk_ESC()  /* Check if user pressed the escape gadget. */
{              /* 1=yes, 0=no. */
 struct IntuiMessage *message; 
 APTR address;
 int class,code;
 short count=0;
 struct Gadget *agad;
 agad = find_GAD(gb_gadlist,5); /* Point to esc gad. */

 while(message=(struct IntuiMessage *)GetMsg (gfx_window->UserPort))
   {
     class=message->Class;
     code=message->Code;
     address = message->IAddress;

     ReplyMsg (message);

    if(class==IDCMP_GADGETUP)
      {
       if(address == (APTR)agad)   /* Is esc? */
          count++;
       }
    }
 if(count) {
    Show_Status("Esc!!");
    return(1);
    }
return(NULL);
}
