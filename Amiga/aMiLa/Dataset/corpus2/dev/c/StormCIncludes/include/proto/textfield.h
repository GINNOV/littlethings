#ifndef _PROTO_TEXTFIELD_H
#define _PROTO_TEXTFIELD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_TEXTFIELD_PROTOS_H
#include <clib/textfield_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *TextFieldBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/textfield.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/textfield_lib.h>
#endif
#endif

#endif	/*  _PROTO_TEXTFIELD_H  */
