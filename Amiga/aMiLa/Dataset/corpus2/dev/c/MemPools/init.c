/**
***  MemPools:  malloc() replacement using standard Amiga pool functions.
***  Copyright  (C)  1994    Jochen Wiedmann
***    changes       1998    Matthias Andree
***
***  This program is free software; you can redistribute it and/or modify
***  it under the terms of the GNU General Public License as published by
***  the Free Software Foundation; either version 2 of the License, or
***  (at your option) any later version.
***
***  This program is distributed in the hope that it will be useful,
***  but WITHOUT ANY WARRANTY; without even the implied warranty of
***  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
***  GNU General Public License for more details.
***
***  You should have received a copy of the GNU General Public License
***  along with this program; if not, write to the Free Software
***  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
***
***
***  This file contains the initialization stuff.
***
***
***  Computer:  Amiga 4000
***
***  Compilers: gcc 2.7.2
***             SAS/C 6.58
***
***
***  Author:    Jochen Wiedmann
***             Am Eisteich 9
***       72555 Metzingen
***             Germany
***
***             Phone: (0049) 7123 14881
***             Internet: jochen.wiedmann@uni-tuebingen.de
***
***  Bugfixes
***  Updates:   Matthias Andree
***             Stormstr. 14
***             58099 Hagen
***             Germany
***
***             Phone: +49-(0)23 31-96 30 72
***
***             E-Mail: mandree@dosis.uni-dortmund.de
***
**/


/***************************************************************************
***
***  This file uses the auto initialization possibilities of gcc and
***  SAS/C, respectively.
***
***  SAS does this by using names beginning with _STI or _STD, respectively.
***  gcc uses the asm() instruction, to emulate C++ constructors and
***  destructors.
***
***************************************************************************/


/*
    Include files and compiler specific stuff
*/
#include <stdlib.h>
#include <exec/types.h>
#if defined(__SASC)
#include "my_alib_protos.h"
#else
#include <clib/alib_protos.h>
#endif

#include "mempools.h"



#if !defined(__SASC)  &&  !defined(__GNUC__)
#error "Don't know how to handle your compiler."
#endif


#ifdef DEBUG
const char meatBeaf[40] = {
    'M', 'E', 'A', 'T', 'B', 'E', 'A', 'F',
    'M', 'E', 'A', 'T', 'B', 'E', 'A', 'F',
    'M', 'E', 'A', 'T', 'B', 'E', 'A', 'F',
    'M', 'E', 'A', 'T', 'B', 'E', 'A', 'F',
    'M', 'E', 'A', 'T', 'B', 'E', 'A', 'F',
};
struct MinList memList;
#endif

APTR __MemPool;



#ifndef DEBUG
/* STATIC */
#endif
#if defined(__SASC)
__stdargs
#endif
LONG _STI_InitMemFunctions(VOID)

{
#ifdef DEBUG
    NewList((struct List *) &memList);
#endif
    if (!(__MemPool = LibCreatePool(__MemPoolFlags,
				    __MemPoolPuddleSize,
				    __MemPoolThreshSize))) {
#if defined(__SASC)
	return(TRUE);
#elif defined(__GNUC__)
	abort();
#endif
    }

    return(FALSE);
}


#ifndef DEBUG
/* STATIC */
#endif
#if defined(__SASC)
__stdargs
#endif
VOID _STD_TerminateMemFunctions(VOID)

{
#ifdef DEBUG
    /*  Be safe, that all memory blocks are checked by calling  */
    /*  free() on them.                                         */
    static int called = FALSE;  /*  Be reentrant.   */

    if (!called) {
	memBlock *block;

	called = TRUE;
	block = (memBlock *) memList.mlh_Head;
	while (block->node.mln_Succ) {
	    free(block+1);
	}
    }
#endif

    if (__MemPool)
    { LibDeletePool(__MemPool);
      __MemPool = NULL;
    }
}


#if defined(__GNUC__)
__asm ("  .text;  .stabs \"___CTOR_LIST__\",22,0,0,__STIInitMemFunctions");
__asm ("  .text;  .stabs \"___DTOR_LIST__\",22,0,0,__STDTerminateMemFunctions");
#endif
