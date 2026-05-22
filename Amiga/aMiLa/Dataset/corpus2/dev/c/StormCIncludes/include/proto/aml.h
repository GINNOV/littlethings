#ifndef _PROTO_AML_H
#define _PROTO_AML_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_AML_PROTOS_H
#include <clib/aml_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *AmlBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/aml.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/aml_lib.h>
#endif
#endif

#endif	/*  _PROTO_AML_H  */
