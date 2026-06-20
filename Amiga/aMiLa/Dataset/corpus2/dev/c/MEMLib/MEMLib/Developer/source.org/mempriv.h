/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* |_o_o|\\ Copyright (c) 1989, 1990, 1991 The Software Distillery.        *
* |. o.| ||          All Rights Reserved                                  *
* | .  | ||          Written by Doug Walker                               *
* | o  | ||          The Software Distillery                              *
* |  . |//           405 B3 Gooseneck Drive                               *
* ======             Cary, NC 27513                                       *
*                                                                         *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */





/**************************************************************************/
/**************************************************************************/
/**************************************************************************/
/*                                                                        */
/* DO NOT INCLUDE THIS FILE IN YOUR PROGRAM.  IT IS FOR MEMLIB'S INTERNAL */
/* USE ONLY.  USE THE FILE "memwatch.h" FOR YOUR PROGRAM FILES.           */
/*                                                                        */
/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

#ifndef D_MEMPRIV_H
#define D_MEMPRIV_H


#include <exec/types.h>
#include <exec/memory.h>
#include <exec/ports.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <string.h>
#include <stdarg.h>

#define MWDEBUG 1   /* MWDEBUG is always defined for the library itself */
#include "memwatch.h"

#define MW_NEWLINE "\n"    /* echo a newline before each error */
                           /* note that this was defined as "\7\n" in the original */

#ifdef AllocMem
#undef AllocMem
#endif

#ifdef FreeMem
#undef FreeMem
#endif

#define MWT_CHIP 0
#define MWT_FAST 1

#define MW_HEADLEN  4  /* Number of bytes for header sentinel */

/* The following string must be >= MW_HEADLEN bytes */
#define MWHEADSTR "HEAD"
                 /*0123*/

#define MW_TRAILLEN 8  /* Number of bytes for trailer sentinel */

/* The following string must be >= MW_TRAILLEN bytes */
#define MWTRAILSTR "\xBB\xBB\xBB\xBB\xBB\xBB\xBB\xBB"

struct MWGlobal
{
   LONG flags;          /* Various MWF_ flags, see memwatch.h           */
   LONG num[2];         /* Current number of allocations, chip and fast */
   LONG sum[2];         /* Current amount allocated, chip and fast      */
   LONG max[2];         /* Max amount allocated, chip and fast          */
   LONG lim[2];         /* Limit on allocations, chip and fast          */
   BPTR dbfh;           /* File to send debug output to                 */
   struct MWAlc *first; /* List of active memory allocations            */
   struct MWAlc *freed; /* List of free memory extents                  */
   struct MWAlc *lfree; /* Last allocation freed with free()            */
   struct Task *task;   /* Pointer to owning task's Task structure      */
   char *dbnm;          /* name of debug log file                       */
   int headlen,         /* Length of header sentinel                    */
       traillen;        /* Length of trailer sentinel                   */
};

struct MWAlc
{
   struct MWAlc *next;  /* Next memory block in chain           */
   LONG size;           /* Size of allocation in bytes          */
   LONG flags;          /* MEMF_ Flags memory was allocated with*/
   LONG internal;       /* internal flags, see MWI_ defines     */
   char *file;          /* Filename containing allocation point */
   LONG line;           /* Line number of allocation            */
   char *ffile;         /* Filename of free point               */
   long fline;         /* Line number of free point            */
   char header[MW_HEADLEN];     /* Header sentinal              */
   char memory[MW_TRAILLEN+3];  /* Actual allocation comes here */
                        /* extra bytes cover trailer sentinal   */
};

/* Defines for use with MWAlc.internal       */
/* if internal&MWI_REPMASK == MWI_REPORTED,  */
/* This alloc already reported as trashed    */
/* Use multiple bits in case 'internal'      */
/* are trashed, odds are better of detecting */
/* If we ever need more myflag bits, just    */
/* define MWI_REPMASK not to include them    */

#define MWI_REPORTED 0xaa55aa50
#define MWI_REPMASK  0xfffffff0


#define MWATRASH     0xaa  /* Trash allocated memory with this           */
#define MWFTRASH     0x55  /* Trash freed memory with this               */

void MWHold   (void);
void MWPurge  (void);
void MWPanic  (char *);
void MWPrintf (char *, ...);
int MWCheckA  (struct MWAlc *);

/* If you want debugging to use the serial port, you must have */
/* Commodore's debug.lib.  If you do, change the #define below */
/* to a 1 and add debug.lib to your link line.                 */
#define USEDEBUGLIB 0
#if USEDEBUGLIB
/* Defined in Commodore's debug.lib */
void __stdargs KPutStr(char *string);
#else
#define KPutStr(x)
#endif

#define MWPrintAlc(mwa) \
   {MWPrintf("0x%08lx length %ld allocated line %ld file \"%s\"\n", \
            (mwa)->memory, (mwa)->size, (mwa)->line, (mwa)->file); \
    if((mwa)->ffile) MWPrintf("Freed line %ld file \"%s\"\n", \
       (mwa)->fline, (mwa)->ffile);}

#define ALCFAMILY(x) ((x) & MWI_MALLOC ? "malloc"    : \
                      (x) & MWI_VEC    ? "AllocVec"  : "AllocMem")

#define FREFAMILY(x) ((x) & MWI_MALLOC ? "free"     : \
                      (x) & MWI_VEC    ? "FreeVec"  : "FreeMem")

#endif /* D_MEMPRIV_H */

