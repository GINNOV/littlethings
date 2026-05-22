#ifndef	EARTH_LIBRARIES_H
#define	EARTH_LIBRARIES_H

/* $VER: earth_earthbase_i 1.0 (20.08.92) */

#include "exec/types.h"
#include "exec/libraries.h"
#include "libraries/dos.h"

/*============================
 * Standard Library structure
 *============================
 */

struct StdLibrary
{
  struct Library	stl_Library;	/* Exec library header */
  UWORD			stl_Reserved1;	/* For future expansion */
  BPTR			stl_SegList;	/* Library segment list */
  struct Library	*stl_SysBase;	/* Base of "exec.library" */
  struct Library	*stl_DOSBase;	/* Base of "dos.library" */
  struct Library	*stl_IntuiBase;	/* Base of "intuition.library" */
};

typedef char LVO[1];	/* Use extern LVO to refer to LVO constants */

#endif