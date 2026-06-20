#ifndef HCE_CON_H
#define HCE_CON_H

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
 *    Defines and Prototypes for Hce_Con.c 
 *
 */

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef LIBRARIES_ASL_H
#include <libraries/asl.h>
#endif

#define CloseConsole(x) CloseDevice(x)

extern UBYTE penshop[3];            /* Con pen/paper and marking colours. */
extern WORD font_width,font_height; /* For GfxBase default font sizes.    */
extern char TRep[10];               /* Store ANSI commands for console.   */
extern char TBuf[10];               /* Used when `TRep' unavailable.      */
extern char *got_env;               /* Env string or NULL if prob.        */
extern int prt_num[2];              /* From and to Lines for printing.    */
extern struct FileRequester *TxFileReq; /* Asl.lib file requester.        */

/************** PROTOTYPES *************/

BYTE DO_PrtText();
struct Window *start();
int OpenConsole(), CheckTL();
long checkinput();
ULONG TotalMemB(), TotalMemK();
int c_ConRows(), c_ConCols(), c_LEGAL_RX(), c_LEGAL_LX(), c_LEGAL_TY();
int c_LEGAL_BY();
void finish(), closeall(), QueueRead(), Prt_LINE(), writechar();
void print(), nprint(), c_Command(), c_PlaceCURS(), c_MoveCURS();
void c_CursOff(), c_CursOn(), c_FPen(), c_BPen(), c_WindColor();
void c_NewConPens(), c_SGR1(), c_SGR2(), PrtError();

#endif
