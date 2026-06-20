#ifndef _PROTO_USERGROUP_H
#define _PROTO_USERGROUP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_USERGROUP_PROTOS_H
#include <clib/usergroup_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *UserGroupBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/usergroup.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/usergroup_lib.h>
#endif
#endif

#endif	/*  _PROTO_USERGROUP_H  */
