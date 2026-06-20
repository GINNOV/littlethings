#ifndef COMPILER_H
#define COMPILER_H
/*** compiler.h *********************************************************/
/*  Steve Shaw							1/29/86 */
/*  Portability file to handle compiler idiosyncrasies.			*/
/*  Version: Lattice 3.03 cross-compiler for the Amiga from the IBM PC. */
/*                                                                      */ 
/* This software is in the public domain.                               */ 
/*                                                                      */ 
/************************************************************************/

#ifndef EXEC_TYPES_H
#include "exec/types.h"
#endif


/* NOTE  --  NOTE  --  NOTE  --  NOTE  --  NOTE
 * Some C compilers can handle Function Declarations with Argument Types
 * (FDwAT) like this:
 *     extern LONG Seek(BPTR, LONG, LONG)
 * while others choke unless you just say
 *     extern LONG Seek()
 *
 * Comment out the #define FDwAT if you have a compiler that chokes. */



/* #define FDwAT 	COMMENTED OUT BECAUSE GREENHILLS CANT TAKE IT */


#endif COMPILER_H

