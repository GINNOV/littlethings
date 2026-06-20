#ifndef _VBCCINLINE_VAMPIRE_H
#define _VBCCINLINE_VAMPIRE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

UBYTE * __V_AllocExpansionPort(__reg("a6") void *, __reg("d0") ULONG, __reg("a1") CONST_STRPTR)="\tjsr\t-6(a6)";
#define V_AllocExpansionPort(unitNum, name) __V_AllocExpansionPort(VampireBase, (unitNum), (name))

VOID __V_FreeExpansionPort( __reg("a6") void *, __reg("d0") ULONG)="\tjsr\t-12(a6)";
#define V_FreeExpansionPort(unitNum) __V_FreeExpansionPort(VampireBase, (unitNum))

ULONG __V_EnableAMMX( __reg("a6") void *, __reg("d0") ULONG) = "\tjsr\t-18(a6)";
#define V_EnableAMMX( _version_ ) __V_EnableAMMX(VampireBase, (_version_))

#endif /*  _VBCCINLINE_VAMPIRE_H  */
