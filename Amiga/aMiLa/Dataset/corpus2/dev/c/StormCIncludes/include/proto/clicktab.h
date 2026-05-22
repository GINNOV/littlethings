#ifndef _PROTO_CLICKTAB_H
#define _PROTO_CLICKTAB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_CLICKTAB_PROTOS_H
#include <clib/clicktab_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *ClickTabBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/clicktab.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/clicktab_lib.h>
#endif
#endif

#endif	/*  _PROTO_CLICKTAB_H  */
