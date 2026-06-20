#ifndef POOLS_H
#define POOLS_H 1

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef PROTO_ALL_H
#include <proto/all.h>
#endif

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
 *    pools.h:
 *
 *             Definitions and Prototypes used by all files.
 */

#define MAX_TABLE    24     /* Max teams per table.   */
#define MAX_ENTRIES  7      /* Max entries per team.  */
#define MAX_STRING   50     /* Standard string sizes. */
  
struct pools_table {
                    struct pools_table *next;
                    char league[MAX_STRING];
                    char team[MAX_TABLE][MAX_STRING];
                    int table[MAX_TABLE][MAX_ENTRIES];
                    int count;
};

typedef struct pools_table P_TABLE;


/* NOTE: */
/* 'CH', below = Can be Changed. (May have to recompile all files though!)*/

#define s_vp   &my_screen->ViewPort
#define s_rp   &my_screen->RastPort
#define g_rp   g_window->RPort
#define gfx_rp gfx_window->RPort

/* Used to place league gadgets and names on 'g_window'. CH.*/
#define INN_X   70       /* Left side gadgets. */
#define MID_X   260      /* Middle */
#define OUT_X   460      /* Right  */
#define TOP_Y   14       /* Where gadgets Y start position is.  */
#define GAP_Y   2        /* Gap between gadgets in Y direction. */
#define WID_Y   12       /* How tall gadgets are. */

#define RS_Y    182      /* Y. Min y pos allowed in result box. CH */
#define RS_X    60       /* X. Min x pos allowed in result box. CH */

/* Used to place 'choose' league gadgets on 'gfx_window'. CH. */
#define c_OUT_X   180    /* Dist out from left edge. */
#define c_TOP_Y   35     /* or 45.Where gadgets Y start position is. */
#define c_GAP_Y   2      /* Gap between gadgets in Y direction. */
#define c_WID_Y   12     /* How tall gadgets are. */

/* Cycle gadget defines. */
#define YES_NO       0
#define NO_YES       1      /* Show "NO" then change to "YES" */
#define ON_OFF       2      /* Show "ON" then change to "OFF" */
#define OFF_ON       3
#define BIT32_BIT16  4      /* Show "32 BIT" then change to "16 BIT" */
#define BIT16_BIT32  5

/* Pools.c */
void main(), close_shop(), Do_LEAGUE(), Show_LEAGUE(), Show_LEAGUE_N();
void Print_Heading(), Do_Comment();
int Get_Team();

/* GadCtrl.c */
int Open_GWind();
void Close_GWind(), Refresh_GWind();
long Get_GMsgs();
long Get_GMsgs2();

/* GadTools.c */
struct Gadget *MakeButtonGad(), *MakeCycleGad(), *MakeStringGad();
struct Gadget *MakeIntegerGad();
void SetCycleTags(), SetStringTags(), Free_GT_Gadgets();
void Free_VisualInfo();
int Alloc_VisualInfoA(), Alloc_L_Gadgets(), Alloc_D_Gadgets();

/* Gfx.c */
BYTE DO_PrtText();
struct Window *start();
void finish(), PrtError(), Set_Graphics(), gfx_TXT(), gfx_FPEN();
void gfx_BPEN(), g_TXT(), g_FPEN(), g_BPEN(), Clear_RBOX(), Help();
void Draw_RBOX(), RB_Msg();

/* read.c */
void Test_Incode();
char charin();
int readfile(), readtable();
#endif
