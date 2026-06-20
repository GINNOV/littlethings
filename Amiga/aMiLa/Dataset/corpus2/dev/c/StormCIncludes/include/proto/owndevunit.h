#ifndef _PROTO_OWNDEVUNIT_H
#define _PROTO_OWNDEVUNIT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_OWNDEVUNIT_PROTOS_H
#include <clib/OwnDevUnit_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *OwnDevUnitBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/OwnDevUnit.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/OwnDevUnit_lib.h>
#endif
#endif

#endif	/*  _PROTO_OWNDEVUNIT_H  */
