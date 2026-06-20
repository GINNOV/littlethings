/***************************************
  $Header: /home/amb/cxref/cpp/RCS/tm.h 1.1 1996/11/02 14:22:40 amb Exp $

  Target machine header file tm.h.
  ******************/ /******************
  Written by Andrew M. Bishop

  This file consists of parts taken from GNU CC.

  GNU CC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2, or (at your option)
  any later version.
  ***************************************/


#ifndef TM_H
#define TM_H    /*+ To stop multiple inclusions. +*/

/* Number of bits in an addressable storage unit */

#define BITS_PER_UNIT 8


/* Width in bits of a "word", which is the contents of a machine register.
   Note that this is not necessarily the width of data type `int';  */

#if defined(dsp1600) || defined(__H8300__)
#define BITS_PER_WORD 16
#elif defined(__alpha) || defined(convex) || defined(elxsi)
#define BITS_PER_WORD 64
#elif defined(mips) && (_MIPS_SZLONG==64 || defined(__mips64))
#define BITS_PER_WORD 64
#elif defined(__sparc__) && defined(__sparc_v9__)
#define BITS_PER_WORD 64
#else
#define BITS_PER_WORD 32
#endif


/* Define results of standard character escape sequences.  */

#if defined(mvs)
#define TARGET_BELL	47
#define TARGET_BS	22
#define TARGET_TAB	5
#define TARGET_NEWLINE	21
#define TARGET_VT	11
#define TARGET_FF	12
#define TARGET_CR	13
#else
#define TARGET_BELL    007
#define TARGET_BS      010
#define TARGET_TAB     011
#define TARGET_NEWLINE 012
#define TARGET_VT      013
#define TARGET_FF      014
#define TARGET_CR      015
#endif


#endif /* TM_H */
