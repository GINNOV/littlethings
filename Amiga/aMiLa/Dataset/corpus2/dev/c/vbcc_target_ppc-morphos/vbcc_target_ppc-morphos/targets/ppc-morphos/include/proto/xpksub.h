#ifndef _PROTO_XPKSUB_H
#define _PROTO_XPKSUB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_XPKSUB_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/xpksub_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *XpkSubBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/xpksub.h>
#else
#include <inline/xpksub.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/xpksub_protos.h>
#endif
#else
#include <pragma/xpksub_lib.h>
#endif

#endif	/*  _PROTO_XPKSUB_H  */
