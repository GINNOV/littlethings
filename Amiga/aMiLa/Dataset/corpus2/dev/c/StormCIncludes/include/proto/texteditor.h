#ifndef _PROTO_TEXTEDITOR_H
#define _PROTO_TEXTEDITOR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_TEXTEDITOR_PROTOS_H
#include <clib/texteditor_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *TextEditorBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/texteditor.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/texteditor_lib.h>
#endif
#endif

#endif	/*  _PROTO_TEXTEDITOR_H  */
