#ifndef _PROTO_EXEC_H
#define _PROTO_EXEC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_EXEC_PROTOS_H
#include <clib/exec_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct ExecBase *SysBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/exec.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/exec_lib.h>
#endif
#endif

#endif	/*  _PROTO_EXEC_H  */
