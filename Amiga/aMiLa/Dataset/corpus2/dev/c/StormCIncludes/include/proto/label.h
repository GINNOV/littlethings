#ifndef _PROTO_LABEL_H
#define _PROTO_LABEL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_LABEL_PROTOS_H
#include <clib/label_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *LabelBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/label.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/label_lib.h>
#endif
#endif

#endif	/*  _PROTO_LABEL_H  */
