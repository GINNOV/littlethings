#ifndef _PROTO_LOG_H
#define _PROTO_LOG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_LOG_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/log_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *LogBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/log.h>
#else
#include <inline/log.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/log_protos.h>
#endif
#else
#include <pragma/log_lib.h>
#endif

#endif	/*  _PROTO_LOG_H  */
