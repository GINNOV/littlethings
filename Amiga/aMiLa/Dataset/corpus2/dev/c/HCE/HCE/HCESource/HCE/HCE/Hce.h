#ifndef HCE_H
#define HCE_H 1

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
 * Defines and Prototypes for 'Hce.c' and other 'Hce_' files. 
 * 
 */

/*
 * NOTE :  '(CH)'  below = value can be changed.
 *      :  '(H/D)'       = short for 'Highlight/DeHighlight'.
 */

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef PROTO_ALL_H
#include <proto/all.h>
#endif

#define T_MAXLINE  2000    /* Max lines per file. (CH) */
#define T_LINELEN  86      /* Max line length. (CH)    */
#define T_MAXSTR   250     /* Max string length. (general use)(CH) */

#define ADD       0        /* Add to.          (CH)  */
#define SUB       1        /* Subtract from.   (CH)  */
#define ABS       2        /* Absoloute value. (CH)  */
#define STD_DELAY 180      /* Standard delay time.(pauses status msg)(CH)*/
#define MIN_DELAY 60       /* Minimum delay time. (CH) */
#define FLASHTIME 286823   /* Turn Curs On/Off every 1/2 sec`ish. (CH) */

/* Cursor Directions. */
#define UP        1
#define DOWN      2
#define RIGHT     3
#define LEFT      4
#define KEYPRESS  5        /* Not used. */

/* Defines used by HD_LINE(). (marking out). */
#define ALL_LINE  6        /* Affects hole line. */
#define ALL_UP    7        /* (H/D). cur/prev line. (Up arrow key)    */
#define ALL_DOWN  8        /* (H/D). cur/next line. (Down arrow key)  */
#define ALL_LUP   9        /* (H/D). cur/prev line. (Left arrow key)  */
#define ALL_RDOWN 10       /* (H/D). cur/next line. (Right arrow key) */

/* Flags for undeletion of a line. (CH) */
#define UD_NONE  0         /* Nothing to undelete.   */
#define UD_ALL   1         /* Undelete entire line.  */
#define UD_PART  2         /* Undelete part of line. */

/* Used for undeletion of a line. */
struct U_del {
               char ud_buff[T_LINELEN]; /* Copy of deleted line.        */
               int ud_line;             /* Line No. copy was taken from.*/
               WORD ud_flag;            /* See above for flags.         */
};

extern char LINE[T_MAXLINE][T_LINELEN]; /* Actual text Buffer.            */
extern char PR_BUF[T_MAXSTR];           /* Temp buffer for general use.   */
extern char PR_OTHER[T_MAXSTR];         /* Used if 'PR_BUF' is unavailable*/
extern int LINE_X;                      /* X pos in 'LINE[][x]'           */
extern int LINE_Y;                      /* Y pos in 'LINE[y][]'           */
extern int CURS_Y;                      /* Y pos in wind. 0 to Win Height.*/
extern int TXT_CHANGED;                 /* Monitor text changes.          */
extern struct U_del udel;               /* Used for undeletion of a line. */

/***************** PROTOTYPES FROM HERE *****************/

/* Hce.c */
void setup(), main(), rem_CHAR(), Do_155(), Do_SpecialKey(), Do_Ctrl();

/* Hce_MenuCtrl.c */
int MenuEvents(), ME_Menu0();
void ME_Menu1(), ME_Menu2() ,ME_Menu3(), ME_Menu4();
void ME_Menu5(), ME_Menu6(), ME_Menu7();

/* Hce_KeyCtrl.c */
void Do_UP(), Do_DOWN(), Do_RIGHT(), Do_LEFT(), Do_RETURN(), Do_BACKSPACE();
void Do_DELETE(), Do_KEYPRESS(),Do_FuncKey();

/* Hce_Mouse.c */
WORD Get_X_MOUSE(), Get_Y_MOUSE(), Mouse_DIF(), Mouse_LEGAL();
WORD Get_WY_MAX();
void Mouse_MARK(), Mouse_CUP(), Mouse_CDOWN(), Mouse_CRIGHT();
void Mouse_CLEFT(), Place_MCURS();

/* Hce_Func.c */
int AC_to_PL(), AN_to_CL(), Get_SLEN(), GetYN();
int Search_LINE(), Replace_JOB(), Do_Search(), c_comp();
void ClearTextBuf(), Clear_Carray(),ACX_to_NL(), Curs_TEOL();
void Print_LINE(), Reset_VARS(), FixDisplay();
void curs_to_boF(), curs_to_eoF(), curs_to_boL();
void curs_to_eoL(), Curs_to_BEF(), Curs_to_BEL();
void Do_Replacement();

/* Hce_Menu.c */
struct Menu *AttachMenu();
void NewItem(), NewSubItem(), NewMenu(), LoseMenu(); 
void FreeSubs(), FreeItems(), FreeMenus();

/* Hce_Command.c */
void Fix_RAMDISK(), Add_Slash(), Add_Suff(), Fix_SCREEN(), check_ARGLIST();
char *PROCESS_1(), *PROCESS_2(), *Fix_PATH();
int PROCESS_3(), Do_LINKER(), Do_QuickY(), dup_ARGLIST(), L_undefsym();
char *Do_OPTIMIZER(), *Do_ASSEMBLER(), *com_ARG();
long cli_SHOP();

/* Hce_Fd.c */
char *get_StubName(), *fd_getline();
int get_FdMem(), open_StubFile(), open_FdFile(), open_FdLib();
int open_TempLib(),max_fdfile(),fd_append(),fd_appendV2(),FD_TO_LIB();
void free_FdMem(),fd_error(),fd_warn(),FD_FuncToAsm(),DO_FDTOLIB();

/* main.c - NOTE: main.c belongs to hcc not hce. */
char *Do_Compile();
void Show_FstERR(), Show_FstWARN();

/* Intuition.library V36 functions. */
long EasyRequestArgs();

/* Dos.library V36 functions. */
long SystemTagList();

/* Asl.library V36 functions. */
APTR AllocAslRequest();
int AslRequest();
void FreeAslRequest();

/* Gadtools.library V36 functions. */
struct Gadget *CreateContext();
struct Gadget *CreateGadgetA();
void FreeGadgets();
struct IntuiMessage *GT_GetIMsg();
void GT_RefreshWindow();
void GT_ReplyMsg();
void FreeVisualInfo();
APTR GetVisualInfoA();

#endif
