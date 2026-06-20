#ifndef _PROTO_REQTOOLS_H
#define _PROTO_REQTOOLS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_REQTOOLS_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/reqtools_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct ReqToolsBase *ReqToolsBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/reqtools.h>
#else
#include <inline/reqtools.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/reqtools_protos.h>
#endif
#else
#include <pragma/reqtools_lib.h>
#endif

#endif	/*  _PROTO_REQTOOLS_H  */
