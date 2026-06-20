#ifndef CLIB_OWNDEVUNIT_PROTOS_H
#define CLIB_OWNDEVUNIT_PROTOS_H

#ifndef LIBRARIES_OWNDEVUNIT_H
#include <libraries/OwnDevUnit.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* prototypes for the functions found in this library */
STRPTR LockDevUnit(STRPTR Device, ULONG Unit, STRPTR OwnerName, UBYTE NotifyBit);
STRPTR AttemptDevUnit(STRPTR Device, ULONG Unit, STRPTR OwnerName, UBYTE NotifyBit);
void   FreeDevUnit(STRPTR Device, ULONG Unit);
void   NameDevUnit(STRPTR Device, ULONG Unit, STRPTR OwnerName);
BOOL   AvailDevUnit(STRPTR Device, ULONG Unit);

#ifdef __cplusplus
}
#endif

#endif
