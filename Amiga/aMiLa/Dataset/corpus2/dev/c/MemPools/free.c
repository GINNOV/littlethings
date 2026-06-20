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
***  This file contains the malloc() replacement.
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




/*
    Include files and compiler specific stuff
*/
#include <stdlib.h>
#include <string.h>
#include <exec/types.h>
#if defined(__SASC)
#include "my_alib_protos.h"
#else
#include <clib/alib_protos.h>
#endif
#include <proto/exec.h>

#include "mempools.h"



#ifdef DEBUG
#define ADDSIZE (sizeof(memBlock)+sizeof(memBlockEnd))
#else
#define ADDSIZE (sizeof(memBlock))
#endif
 

void free(void *block)

{
    memBlock *ptr;

    if ((ptr = block)) {
	size_t size;

	ptr = ptr - 1;
	size = ptr->size;
#ifdef DEBUG
	{
	    memBlockEnd *eptr;

	    eptr = (memBlockEnd *) (((char *)(ptr+1))+size);

	    if (ptr->realSize != size + ADDSIZE                         ||
		memcmp(ptr->lowerBoundary, meatBeaf, sizeof(meatBeaf))  ||
		memcmp(eptr->upperBoundary, meatBeaf, sizeof(meatBeaf))) {
		extern void kprintf(const char *, ...);

		kprintf("Danger: Memory destroyed at %08lx.\n", ptr+1);
		exit(0);
	    }

	    memset(ptr->lowerBoundary, '\0', sizeof(meatBeaf));
	    memset(eptr->upperBoundary, '\0', sizeof(meatBeaf));
	}
	Remove((struct Node *) ptr);
#endif
	LibFreePooled(__MemPool, ptr, (ULONG)size + ADDSIZE);
    }
}
