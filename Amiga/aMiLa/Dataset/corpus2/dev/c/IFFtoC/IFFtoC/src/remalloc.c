/** RemAlloc.c **************************************************************/
/*  ChipAlloc(), ExtAlloc(), RemAlloc(), RemFree().                         */
/*  ALLOCators which REMember the size allocated, for simpler freeing.      */
/*                                                                          */
/* Date      Who Changes                                                    */
/* --------- --- -----------------------------------------------------------*/
/* 16-Jan-86 sss Created from DPaint/DAlloc.c                               */
/* 23-Jan-86 jhm Include Compiler.h, check for size > 0 in RemAlloc.        */
/* 25-Jan-86 sss Added ChipNoClearAlloc,ExtNoClearAlloc                     */
/*                                                                          */
/* By Jerry Morrison and Steve Shaw, Electronic Arts.                       */
/* This software is in the public domain.                                   */
/*                                                                          */
/* This version for the Commodore-Amiga computer.                           */
/*                                                                          */
/****************************************************************************/
#ifndef COMPILER_H
#include "iff/compiler.h"
#endif

#include "exec/nodes.h"
#include "exec/memory.h"
#include "iff/remalloc.h"

/** RemAlloc ****************************************************************/
UBYTE *RemAlloc(size,flags) LONG size, flags; {
    register LONG *p = NULL;    /* (LONG *) for the sake of p++, below */
    register LONG asize = size+4;
    if (size > 0)
        p = (LONG *)AllocMem(asize,flags);
    if (p != NULL)
        *p++ = asize;   /* post-bump p to point at clients area*/
    return((UBYTE *)p);
    }

/** ChipAlloc ***************************************************************/
UBYTE *ChipAlloc(size) LONG size; {
    return(RemAlloc(size, MEMF_CLEAR|MEMF_PUBLIC|MEMF_CHIP));
    }
    
/** ChipNoClearAlloc ********************************************************/
UBYTE *ChipNoClearAlloc(size) LONG size; {
    return(RemAlloc(size, MEMF_PUBLIC|MEMF_CHIP));
    }
    
/** ExtAlloc ****************************************************************/
UBYTE *ExtAlloc(size) LONG size; {
    return(RemAlloc(size, MEMF_CLEAR|MEMF_PUBLIC));
    }

/** ExtNoClearAlloc *********************************************************/
UBYTE *ExtNoClearAlloc(size) LONG size; {
    return(RemAlloc(size, MEMF_PUBLIC));
    }

/** RemFree *****************************************************************/
UBYTE *RemFree(p) UBYTE *p; {
    if (p != NULL) {
        p -= 4;
        FreeMem(p, *((LONG *)p));
        }
    return(NULL);
    }

