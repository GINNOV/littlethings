/***************************************
  $Header: /home/amb/cxref/cpp/RCS/config.h 1.3 1997/04/25 18:33:00 amb Exp $

  System configuration header file config.h.
  ******************/ /******************
  Written by Andrew M. Bishop

  This file consists of parts taken from GNU CC.

  GNU CC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2, or (at your option)
  any later version.
  ***************************************/


#ifndef CONFIG_H
#define CONFIG_H    /*+ To stop multiple inclusions. +*/

/****************************************************************************/

#if defined(__SASC) && defined(AMIGA)	/* olsen */
#define USE_PROTOTYPES 1
#define STDC_HEADERS 1
#define HAVE_FCNTL_H 1
#define HAVE_STDLIB_H 1
#define HAVE_SYS_TIME_H 1
#define HAVE_UNISTD_H 1
#define HAVE_VPRINTF 1
#define LOCAL_INCLUDE_DIR "sc:include"
#define TOOL_INCLUDE_DIR LOCAL_INCLUDE_DIR
#define GCC_INCLUDE_DIR LOCAL_INCLUDE_DIR
#define GPLUSPLUS_INCLUDE_DIR "."
#define CPP_PREDEFINES "-D_AMIGA=1 -D_M68000=1 -D__SASC=1 -D__SASC_60=1 -D__SASC_650=1 -D__VERSION__=6 -D__REVISION__=50 -DAMIGA=1 -DLATTICE=1 -DLATTICE_50=1"

extern void * alloca(unsigned int );

#define HOST_BITS_PER_LONG 32
#define HOST_BITS_PER_INT 32
#endif /* defined(__SASC) && defined(AMIGA) */

/****************************************************************************/

/* This describes the machine the compiler is hosted on.  */

#if defined(dsp1600) || defined(__H8300__)
#define HOST_BITS_PER_INT 16
#else
#define HOST_BITS_PER_INT 32
#endif

#if defined(__alpha)
#define HOST_BITS_PER_LONG 64
#elif defined(mips) && (_MIPS_SZINT==64 || defined(__mips64))
#define HOST_BITS_PER_LONG 64
#else
#define HOST_BITS_PER_LONG 32
#endif


/* Target machine dependencies. */

#include "tm.h"


/* Use System V memory functions (if needed). */

#if NEED_SVR4_STRINGS

#define bcmp(a,b,c)  memcmp(a,b,c)
#define bcopy(a,b,c) memcpy(b,a,c)
#define bzero(a,b)   memset(a,0,b)

#define index  strchr
#define rindex strrchr

#define USG
#define BSTRING

#endif


/* Exit codes. */

#ifndef FATAL_EXIT_CODE
#define FATAL_EXIT_CODE 33	/* gnu cc command understands this */
#endif

#ifndef SUCCESS_EXIT_CODE
#define SUCCESS_EXIT_CODE 0	/* 0 means success on Unix.  */
#endif

#endif /* CONFIG_H */
