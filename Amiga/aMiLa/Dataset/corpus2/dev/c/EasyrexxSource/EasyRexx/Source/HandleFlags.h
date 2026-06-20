/*
 *	File:					HandleFlags.h
 *	Description:	A set of functions that handles the input in Main window
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef	HANDLEFLAGS_H
#define	HANDLEFLAGS_H

/*** PROTOTYPES **********************************************************************/
UBYTE *Upper(UBYTE *string);
UBYTE *StripFlags(UBYTE *string);
void PutFlags(struct Node *node);

#endif
