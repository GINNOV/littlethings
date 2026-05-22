#ifndef PUTPICT_H
#define PUTPICT_H
/** putpict.h ********************************************************* */
/* PutPict().  Given a BitMap and a color map in RAM on the Amiga,      */
/* outputs as an ILBM.  See /iff/ilbm.h & /iff/ilbmw.c.       23-Jan-86 */
/*                                                                      */ 
/* By Jerry Morrison and Steve Shaw, Electronic Arts.                   */ 
/* This software is in the public domain.                               */ 
/*                                                                      */ 
/* This version for the Commodore-Amiga computer.                       */
/*                                                                      */ 
/************************************************************************/
#ifndef COMPILER_H
#include "iff/compiler.h"
#endif

#ifndef ILBM_H
#include "iff/ilbm.h"
#endif

#ifdef FDwAT

/****** IffErr *************************************************************/
/* Returns the iff error code and resets it to zero                        */
/***************************************************************************/
extern IFFP IffErr(void);

/****** PutPict ************************************************************/
/* Put a picture into an IFF file                                          */
/* Pass in mask == NULL for no mask.                                       */
/*                                                                         */
/* Buffer should be big enough for one packed scan line                    */
/* Buffer used as temporary storage to speed-up writing.                   */
/* A large buffer, say 8KB, is useful for minimizing Write and Seek calls. */
/* (See /iff/gio.h & /iff/gio.c).                                          */
/***************************************************************************/
extern BOOL PutPict(LONG, struct BitMap *, WORD,WORD, WORD *, BYTE *, LONG);
		 /* file, bm,           pageW,pageH,colorMap, buffer,bufsize */

#else /*not FDwAT*/

extern IFFP IffErr();
extern BOOL PutPict();

#endif FDwAT

#endif PUTPICT_H


