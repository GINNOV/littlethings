#ifndef LIBRARIES_OWNDEVUNIT_H
#define LIBRARIES_OWNDEVUNIT_H

/* OwnDevUnit.h

   Created 2/10/91 by Christopher A. Wichura
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/* macro to grab the name of the library */
#define ODU_NAME "OwnDevUnit.library"

/* strings that can be returned by LockDevUnit() and AttempDevUnit() to
   indicate an internal error.  Note that these all start with a
   special character to allow clients to only have to check one byte
   to determine if an error occured. */

#define ODUERR_LEADCHAR "\x07"

#define ODUERR_NOMEM	ODUERR_LEADCHAR "Out of memory"
#define ODUERR_NOTIMER	ODUERR_LEADCHAR "Unable to open timer.device"
#define ODUERR_BADNAME	ODUERR_LEADCHAR "Bogus device name supplied"
#define ODUERR_BADBIT	ODUERR_LEADCHAR "Bogus notify bit supplied"
#define ODUERR_UNKNOWN	ODUERR_LEADCHAR "Unknown"
				/* returned if owner's name is NULL */

#endif
