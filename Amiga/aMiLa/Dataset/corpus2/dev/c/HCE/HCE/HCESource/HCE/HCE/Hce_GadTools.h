#ifndef HCE_GADTOOLS_H
#define HCE_GADTOOLS_H

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
 *    Defines and Prototypes for Hce_GadTools.c and Hce_GadCtrl.c 
 */

/*
 * NOTE:  '(CH)'  below = value can be changed.
 */

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

/* The first 5 defines below are used to specify C/O/A and Linker buffer */
/* sizes, and are also used with gadget routines. (CH) */
#define GB_MAX     128      /* Max. */
#define GB_MIN     30       /* Min. */
#define GB_TINY    2        /* Absoloute Min. */
#define GB_OTHER   45       /* Other. */
#define GB_EXT     384      /* Extended Max. (3 * GB_MAX) */
#define GB_LSIZE   1024     /* General size used with File List buffers. */

#define CBN_NUM    4        /* Number of compiler cycle gads. */
#define OBN_NUM    8        /* Opt.    */
#define ABN_NUM    6        /* Assem.  */
#define LBN_NUM    5        /* Linker. */
#define PBN_NUM    2        /* Number of prefs cycle/checkbox/Int gads. */

#define COMPILER_GAD   0    /* ID. Used to find out which gadgets, */
#define OPTIMIZER_GAD  1    /* have been selected. (CH) */
#define ASSEMBLER_GAD  2
#define LINKER_GAD     3
#define FIND_GAD       4
#define REPLACE_GAD    5
#define JUMPTO_GAD     6
#define PRINTER_GAD    7
#define PREFS_GAD      8
#define REQUESTER_GAD  9

/* Cycle gadget options. */
#define YES_NO       0
#define NO_YES       1      /* Show "NO" then change to "YES" */
#define ON_OFF       2      /* Show "ON" then change to "OFF" */
#define OFF_ON       3
#define BIT32_BIT16  4      /* Show "32 BIT" then change to "16 BIT"  */
#define BIT16_BIT32  5
#define ED_LI_BOTH   6      /* Show "FROM EDITOR", "..LIST", "..BOTH" */
#define LI_BOTH_ED   7
#define BOTH_ED_LI   8
#define ASS_LI_BOTH  9      /* Show "FROM ASSEM", "..LIST", "..BOTH" */
#define LI_BOTH_ASS  10
#define BOTH_ASS_LI  11
#define WAIT_DELAY   12     /* Show "WAIT-FOR-DELAY", "WAIT-FOR-KEY" */
#define WAIT_KEY     13     /* Show "WAIT-FOR-KEY", "WAIT-FOR-DELAY" */

/* Screen private data for gadtools. */
extern APTR gt_visual;

/* Heads to all gadget lists. */ 
extern struct Gadget *c_gadlist;
extern struct Gadget *o_gadlist;
extern struct Gadget *a_gadlist;
extern struct Gadget *l_gadlist;
extern struct Gadget *f_gadlist;
extern struct Gadget *r_gadlist;
extern struct Gadget *j_gadlist;
extern struct Gadget *gb_gadlist;
extern struct Gadget *p_gadlist;
extern struct Gadget *prefs_glist;
extern struct Gadget *req_glist;

/* Cycle/Checkbox Gadget button states. */
extern int  C_GadBN[CBN_NUM];
extern int  O_GadBN[OBN_NUM];
extern int  A_GadBN[ABN_NUM];
extern int  L_GadBN[LBN_NUM];
extern WORD P_GadBN[PBN_NUM];

/* Compiler Buffers. */
extern char C_DefSym[GB_MIN];
extern char C_UnDefSym[GB_MIN];
extern char C_IDirList[GB_OTHER];
extern char C_QuadDev[GB_MIN];
extern char C_WorkList[GB_LSIZE];
extern char C_Pattern[GB_MIN];
extern char C_Debug[GB_TINY];

/* Optimizer Buffers. */
/* None. */

/* Assembler Buffers. */
extern char A_IncHeader[GB_OTHER];
extern char A_IDirList[GB_MAX];
extern char A_CListFile[GB_MIN];
extern char A_OutPath[GB_MIN];
extern char A_Debug[GB_MIN];

/* Linker Buffers. */
extern char L_StartOBJ[GB_MIN];
extern char L_LinkList[GB_LSIZE];
extern char L_Libs[GB_EXT];
extern char L_MathLib[GB_MIN];
extern char L_OutName[GB_MIN];
extern char L_Pattern[GB_MIN];
extern char L_LibOut[GB_MIN];

/* Other Buffers or Flags. */
extern char Search_Name[GB_OTHER];
extern char Replace_Name[GB_OTHER];
extern char ReqBuf[GB_OTHER];
extern int jump_to_num;
extern int c_sensitive;

/*********************** PROTOTYPES **************************/

/* Hce_GadCtrl.c */
struct Gadget *find_GAD();
int Open_GWind(), Open_C_Wind(),Open_O_Wind(),Open_A_Wind();
int Open_F_Wind(),Open_R_Wind(), Open_J_Wind(), Open_P_Wind();
int Open_Prefs_W(), Do_ReqWin(), Do_GadMsgs(), chk_ESC();
long Process_GMsgs();
void dup_Palette(), res_Palette(), new_Palette(), set_Palcor();
void set_Sliders(), Close_GWind(), gw_Wactive(), cw_Wactive();
void gfx_chinput(), MakeGadActive(),ActivateCW();

/* Hce_GadTools.c */
struct Gadget *MakePalGad();
struct Gadget *MakeButtonGad();
struct Gadget *MakeCBoxGad();
struct Gadget *MakeCycleGad();
struct Gadget *MakeStringGad();
struct Gadget *MakeIntegerGad();
struct Gadget *IT_ButtonGad();
WORD set_GadX();
void bevelbox_A(),free_IT_BtnGads(),mod_StrGad(),mod_IntGad();
void mod_CBoxGad(),mod_CycleGad();

/* These use the above GadTools Functions.  */
int Alloc_VisualInfoA(), Alloc_C_Gadgets(), Alloc_O_Gadgets();
int Alloc_A_Gadgets(), Alloc_L_Gadgets();
int Alloc_F_Gadgets(), Alloc_R_Gadgets(), Alloc_J_Gadgets();
int Alloc_G_Gadgets(),Alloc_P_Gadgets(), Alloc_Pref_Gads();
int Alloc_Req_Gads();
void Free_GT_Gadgets(), Free_VisualInfo(), FREE_MiscGads();

#endif
