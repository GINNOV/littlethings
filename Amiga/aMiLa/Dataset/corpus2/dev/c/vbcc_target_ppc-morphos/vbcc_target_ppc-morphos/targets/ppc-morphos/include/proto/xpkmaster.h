#ifndef _PROTO_XPKMASTER_H
#define _PROTO_XPKMASTER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_XPKMASTER_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/xpkmaster_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *XpkBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/xpkmaster.h>
#else
#include <inline/xpkmaster.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/xpkmaster_protos.h>
#endif
#else
#include <pragma/xpkmaster_lib.h>
#endif

#endif	/*  _PROTO_XPKMASTER_H  */
