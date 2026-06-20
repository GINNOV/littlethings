#ifndef _INCLUDE_PRAGMA_OWNDEVUNIT_LIB_H
#define _INCLUDE_PRAGMA_OWNDEVUNIT_LIB_H

#ifndef CLIB_OWNDEVUNIT_PROTOS_H
#include <clib/OwnDevUnit_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/OwnDevUnit.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(OwnDevUnitBase,0x01E,LockDevUnit(a0,d0,a1,d1))
#pragma amicall(OwnDevUnitBase,0x024,AttemptDevUnit(a0,d0,a1,d1))
#pragma amicall(OwnDevUnitBase,0x02A,FreeDevUnit(a0,d0))
#pragma amicall(OwnDevUnitBase,0x030,NameDevUnit(a0,d0,a1))
#pragma amicall(OwnDevUnitBase,0x036,AvailDevUnit(a0,d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall OwnDevUnitBase LockDevUnit          01E 190804
#pragma  libcall OwnDevUnitBase AttemptDevUnit       024 190804
#pragma  libcall OwnDevUnitBase FreeDevUnit          02A 0802
#pragma  libcall OwnDevUnitBase NameDevUnit          030 90803
#pragma  libcall OwnDevUnitBase AvailDevUnit         036 0802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_OWNDEVUNIT_LIB_H  */
