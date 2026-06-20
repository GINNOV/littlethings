#ifndef _PROTO_RADIOBUTTON_H
#define _PROTO_RADIOBUTTON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_RADIOBUTTON_PROTOS_H
#include <clib/radiobutton_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *RadioButtonBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/radiobutton.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/radiobutton_lib.h>
#endif
#endif

#endif	/*  _PROTO_RADIOBUTTON_H  */
