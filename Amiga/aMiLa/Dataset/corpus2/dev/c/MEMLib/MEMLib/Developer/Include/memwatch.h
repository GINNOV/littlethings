/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* |_o_o|\\ Copyright (c) 1989 The Software Distillery.                    *
* |. o.| ||          All Rights Reserved                                  *
* | .  | ||          Written by Doug Walker                               *
* | o  | ||          The Software Distillery                              *
* |  . |//           235 Trillingham Lane                                 *
* ======             Cary, NC 27513                                       *
*                    BBS:(919)-471-6436                                   *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef D_MEMWATCH_H
#define D_MEMWATCH_H

#include <exec/types.h>
#include <exec/memory.h>

/* The following files are included so you won't get an error if */
/* you include them AFTER this file.                             */
#include <stdlib.h>   /* Get prototype for malloc() */
#include <dos/dos.h>      /* Get prototype for getcwd() and getenv() */
#include <string.h>   /* Get prototype for strdup() */

/* Flags for MWInit */
#define MWF_NOCHECK   0x00000000 /* (compatibility - do not use)         */
#define MWF_NOLOG     0x00000002 /* No debug messages                    */
#define MWF_CHECK     0x00000004 /* Check mem whenever mem rtns called   */
#define MWF_NOFREE    0x00000008 /* Don't free nonfreed memory           */
#define MWF_NOFTRASH  0x00000010 /* Don't trash memory upon free         */
#define MWF_NOATRASH  0x00000020 /* Don't trash memory upon alloc        */
#define MWF_NOFKEEP   0x00000040 /* Don't keep memory after free         */
#define MWF_MALLOCWRN 0x00000080 /* Warn about malloc'd mem not freed    */
#define MWF_SERIAL    0x00000100 /* Use serial port for output           */

#define MWF_ACTIVE   0x80000000 /* PRIVATE - MemWatch is active          */
#define MWF_ERROR    0x40000000 /* PRIVATE - Error discovered, terminate */

/* PRIVATE. Flags for the INTERNAL argument to MWAllocMem.               */
#define MWI_MALLOC   0x00000001  /* Memory allocated with malloc         */
#define MWI_VEC      0x00000002  /* Memory allocated with AllocVec       */
#define MWI_ANY      (MWI_MALLOC|MWI_VEC)

/* Flags to tell MWReport how much to report */
#define MWR_NONE 0   /* Don't report anything; just return    */
#define MWR_SUM  1   /* Report current and total usage        */
#define MWR_FULL 2   /* Report on all outstanding allocations */

#ifdef MWDEBUG

#ifdef AllocMem
#undef AllocMem
#endif
#ifdef FreeMem
#undef FreeMem
#endif
#ifdef AllocVec
#undef AllocVec
#endif
#ifdef FreeVec
#undef FreeVec
#endif
#ifdef malloc
#undef malloc
#endif
#ifdef halloc
#undef halloc
#endif
#ifdef calloc
#undef calloc
#endif
#ifdef realloc
#undef realloc
#endif
#ifdef free
#undef free
#endif
#ifdef strdup
#undef strdup
#endif
#ifdef getcwd
#undef getcwd
#endif
#ifdef getenv
#undef getenv
#endif


#define AllocMem(size,flags) MWAllocMem((long)(size), flags, 0, __FILE__, __LINE__)
#define FreeMem(mem,size)    MWFreeMem(mem, (long)(size), 0, __FILE__, __LINE__)
#define AllocVec(size,flags) MWAllocMem((long)(size), flags, MWI_VEC, __FILE__, __LINE__)
#define FreeVec(mem)         MWFreeMem(mem, -1, MWI_VEC, __FILE__, __LINE__)
#define malloc(size)         MWAllocMem((long)(size), 0, MWI_MALLOC, __FILE__, __LINE__)
#define halloc(size)         malloc(size)
#define calloc(nelt,esize)   MWAllocMem((long)((nelt)*(esize)), MEMF_CLEAR, MWI_MALLOC, __FILE__, __LINE__)
#define realloc(mem,size)    MWrealloc(mem,(long)(size),__FILE__,__LINE__)
#define free(mem)            MWFreeMem(mem, -1, MWI_MALLOC, __FILE__, __LINE__)

#define strdup(str)          MWStrDup(str, __FILE__, __LINE__)
#define getcwd(b,size)       MWGetCWD(b,size,__FILE__,__LINE__)
#define getenv(name)         MWGetEnv(name, __FILE__, __LINE__)

void MWInit      (LONG, LONG, char *);
void MWTerm      (void);
void *MWAllocMem (long, long, long, char *, long);
void MWFreeMem   (void *, long, long, char *, long);
void MWCheck     (void);
void MWReport    (char *, long);
void MWLimit     (LONG, LONG);
void *MWrealloc  (void *, long, char *, long);

char *MWStrDup   (const char *, char *, long);
char *MWGetEnv   (const char *, char *, long);
char *MWGetCWD   (char *, int, char *, long);

#else /* MWDEBUG */

/* No memory debugging - make everything go away */

#define MWInit(a,b,c)
#define MWTerm()
#define MWCheck()
#define MWReport(a,b)
#define MWLimit(a,b)

#endif /* MWDEBUG */
#endif /* D_MEMWATCH_H */
