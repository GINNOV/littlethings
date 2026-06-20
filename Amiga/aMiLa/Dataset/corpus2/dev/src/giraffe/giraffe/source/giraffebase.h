/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: giraffebase.h                           */
/*    |< |      created: June 14, 1995                        */
/*    \_/|     version 2                                      */
/*------------------------------------------------------------*/
/* HELOO LUKE!! MOST OF THIS SEEMS OBSOLETE!!! */

#include <exec/types.h>
#include <exec/lists.h>
#include <exec/libraries.h>


/* library data structures
 *
 * Note that the library base begins with a library node
 */

struct	GiraffeBase {
  struct	Library	LibNode;
  UBYTE	Flags;
  UBYTE	pad;
  /* We are now longword aligned */
  ULONG	SysLib;
  ULONG	DosLib;
  ULONG	SegList;

  struct MinList *resources[GT_TOTAL];
  struct MinList *inuse[GT_TOTAL];
};


#define	GIRAFFENAME	"giraffe.library"

