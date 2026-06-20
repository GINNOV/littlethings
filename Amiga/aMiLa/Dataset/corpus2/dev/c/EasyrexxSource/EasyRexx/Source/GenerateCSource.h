/*
 *	File:					GenerateCSource.h
 *	Description:	
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef GENERATECSOURCE_H
#define GENERATECSOURCE_H

/*** PROTOTYPES **********************************************************************/
void WriteCArguments(BPTR fp, struct List *list);
void GenerateCSource(struct List *list, UBYTE *filename);
#endif
