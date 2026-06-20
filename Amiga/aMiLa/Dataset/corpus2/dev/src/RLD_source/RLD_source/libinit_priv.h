/*
  $Id: libinit_priv.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $

  $Log: libinit_priv.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#if !defined(LIBINIT_PRIV_H)
#define LIBINIT_PRIV_H

#include <exec/resident.h>
#include <exec/alerts.h>
#include <exec/exec.h>

#include "rexx_gls.h"

/*
 * The blue smoke.
 */

const APTR InitTab[];
const APTR __rgls_functable__[];
const BYTE LibName[];
const BYTE LibIdString[];

/* Prototypes for the standard functions. */

LONG FailOnRun(VOID);
struct Library *LibInit(APTR SegList __asm("a0"),
			struct RexxGLSBase *RglsBase __asm("d0"),
			struct ExecBase *ExecBase __asm("a6"));
struct Library *LibOpen(struct  RexxGLSBase *RglsBase __asm("a6"));
APTR LibClose(struct  RexxGLSBase *RglsBase __asm("a6"));
APTR LibExpunge(struct  RexxGLSBase *RglsBase __asm("a6"));
APTR LibExtFunc(struct  RexxGLSBase *RglsBase __asm("a6"));

/*
 * And for the other entry points.
 */

VOID ArexxMatchPoint(struct RexxMsg * __asm("a1"),
                     struct RexxGLSBase * __asm("a6"));

/*
 * Various constants.
 */

#if !defined (ADATE)
#define ADATE "21.10.97"
#endif

#define REXXGLS_VER 2
#define REXXGLS_REV 14
#define REXXGLS_NAME "rexxlocaldates.library"
#define REXXGLS_VERSTAG "$VER: " ## REXXGLS_NAME ## " 2.14 (" ## ADATE ## ")"

#endif /* LIBINIT_PRIV_H */
