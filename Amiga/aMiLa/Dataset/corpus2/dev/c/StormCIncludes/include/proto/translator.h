#ifndef _PROTO_TRANSLATOR_H
#define _PROTO_TRANSLATOR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_TRANSLATOR_PROTOS_H
#include <clib/translator_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *TranslatorBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/translator.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/translator_lib.h>
#endif
#endif

#endif	/*  _PROTO_TRANSLATOR_H  */
