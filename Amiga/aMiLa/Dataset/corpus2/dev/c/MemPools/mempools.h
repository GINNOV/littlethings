/**
***  MemPools:  malloc() replacement using standard Amiga pool functions.
***  Copyright  (C)  1994    Jochen Wiedmann
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
***  Common include file; for internal use of the library only.
***
***
***  Computer:  Amiga 1200
***
***  Compilers: Dice 3.01
***             SAS/C 6.50
***             gcc 2.6.3
***
***
***  Author:    Jochen Wiedmann
***             Am Eisteich 9
***       72555 Metzingen
***             Germany
***
***             Phone: (0049) 7123 14881
***             Internet: jochen.wiedmann@uni-tuebingen.de
**/


#ifndef _MEMPOOLS_H
#define _MEMPOOLS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EXEC_LISTS_H
#include <exec/lists.h>
#endif


/**
***  Any allocated block of memory is preceded by the following
***  structure:
**/
typedef struct {
#ifdef DEBUG
    struct MinNode node;
    size_t realSize;
    char lowerBoundary[40]; /*  5 times the word "MEATBEAF"     */
#endif
    size_t size;
} memBlock;

/**
***  ... and followed by the following structure:
**/
typedef struct {
    char upperBoundary[40]; /*  5 times the word "MEATBEAF"     */
} memBlockEnd;

#ifdef DEBUG
extern const char meatBeaf[40];
extern struct MinList memList;
#endif

extern APTR __MemPool;
extern ULONG __MemPoolPuddleSize;
extern ULONG __MemPoolThreshSize;
extern ULONG __MemPoolFlags;  

#endif
