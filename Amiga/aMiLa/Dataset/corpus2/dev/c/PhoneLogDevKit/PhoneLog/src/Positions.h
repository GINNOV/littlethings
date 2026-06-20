#ifndef yyPositions
#define yyPositions

/* $Id: Positions.h,v 1.0 1992/08/07 14:31:43 grosch rel $ */

/* $Log: Positions.h,v $
 * Revision 1.0  1992/08/07  14:31:43  grosch
 * Initial revision
 *
 */

/* Ich, Doktor Josef Grosch, Informatiker, Juli 1992 */


#include <stdio.h>


typedef struct {unsigned short Line, Column;} tPosition;


extern tPosition NoPosition;
/* A default position (0, 0). */


int Compare(tPosition Position1, tPosition Position2);
/* Returns -1 if Position1 < Position2. */
/* Returns  0 if Position1 = Position2. */
/* Returns  1 if Position1 > Position2. */

void WritePosition(FILE *File, tPosition Position);
/* The 'Position' is printed on the 'File'. */

#endif
