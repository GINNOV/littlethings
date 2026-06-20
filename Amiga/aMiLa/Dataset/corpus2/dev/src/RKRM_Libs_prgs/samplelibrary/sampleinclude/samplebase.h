/* samplebase.h -- C include file defining sample.library base


Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

#ifndef SAMPLE_BASE_H
#define SAMPLE_BASE_H

#ifndef  EXEC_TYPES_H
#include  <exec/types.h>
#endif   EXEC_TYPES_H

#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif   EXEC_LIBRARIES_H

/* library data structures-- Note that the library base begins with a library node */

struct SampleBase {
   struct Library LibNode;
   UBYTE  Flags;
   UBYTE  pad;
   /* We are now longword aligned */
   ULONG  SysLib;
   ULONG  DosLib;
   ULONG  SegList;
   };

#define SAMPLENAME   "sample.library"

#endif  /* SAMPLE_BASE_H */