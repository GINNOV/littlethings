#ifndef _PROTO_MATHTRANS_H
#define _PROTO_MATHTRANS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_MATHTRANS_PROTOS_H
#include <clib/mathtrans_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *MathTransBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/mathtrans.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/mathtrans_lib.h>
#endif
#endif

#endif	/*  _PROTO_MATHTRANS_H  */
