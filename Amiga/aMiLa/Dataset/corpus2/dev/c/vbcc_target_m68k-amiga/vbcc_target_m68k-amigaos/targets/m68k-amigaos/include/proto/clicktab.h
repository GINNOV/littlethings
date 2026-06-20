#ifndef _PROTO_CLICKTAB_H
#define _PROTO_CLICKTAB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_CLICKTAB_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/clicktab_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ClickTabBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/clicktab.h>
#else
#include <inline/clicktab.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/clicktab_protos.h>
#endif
#else
#include <pragma/clicktab_lib.h>
#endif

#endif	/*  _PROTO_CLICKTAB_H  */
