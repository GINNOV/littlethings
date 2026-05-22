/*
 *	File:					GenerateModula2Source.h
 *	Description:	
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef GENERATEMODULA2SOURCE_H
#define GENERATEMODULA2SOURCE_H

/*** PROTOTYPES **********************************************************************/
__asm UBYTE *Upper(register __a0 UBYTE *string);
void GenerateModula2Source(struct List *list, UBYTE *filename);
#endif
