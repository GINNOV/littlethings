/*
 *	File:					ProjectIO.h
 *	Description:	Defines the structure of the configuration and events.
 *								Reads and writes the project as an IFF-FORM.
 *
 *	(C) 1995 Ketil Hunn
 *
 */

#ifndef PROJECTIO_H
#define	PROJECTIO_H

/*** PROTOTYPES **********************************************************************/
LONG ReadIFF(struct List *list, UBYTE *file, BYTE append);
LONG WriteIFF(struct List *list, UBYTE *file);

LONG OpenProject(struct List *list, UBYTE *file, BYTE force);
LONG AppendProject(struct List *list, UBYTE *file);
LONG SaveProject(struct List *list, UBYTE *file);
LONG SaveProjectAs(struct List *list, UBYTE *file);
LONG LastSaved(struct List *list, UBYTE *file, BYTE force);

LONG ReadProject(struct List *list, UBYTE *file, BYTE force);
BYTE OverwriteFile(UBYTE *file);

#endif
