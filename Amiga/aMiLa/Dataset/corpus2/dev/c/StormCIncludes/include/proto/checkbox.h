#ifndef _PROTO_CHECKBOX_H
#define _PROTO_CHECKBOX_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_CHECKBOX_PROTOS_H
#include <clib/checkbox_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *CheckBoxBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/checkbox.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/checkbox_lib.h>
#endif
#endif

#endif	/*  _PROTO_CHECKBOX_H  */
