#ifndef HCE_BLOCK_H
#define HCE_BLOCK_H

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
 *    Defines and prototypes for Hce_Block.c
 */

#define B_MAXLINE     200   /* Max lines for Block buffer. */

extern char BLOCK[B_MAXLINE][T_LINELEN];  /* Block buffer. */
extern int BLOCK_ON;                      /* Block status. */
extern int MOUSE_MARKED;                  /* Block status. */

/* Block. (keep size/start and end positions) */
extern int blk_SY;
extern int blk_EY;
extern int blk_SX;
extern int blk_EX;

/***************** PROTOTYPES *****************/
int B_Copy(), B_Cut(), Get_BSLEN();
void Clear_Block(), B_Start(), B_End(), Check_MMARK(), Check_KMARK();
void TEXT_UL(), B_Hide(), B_Insert(), B_Print();
void Shift_UPV2(), Shift_DOWNV2(), HL_AllLine(), High_LIGHT(), HD_LINE();
#endif
