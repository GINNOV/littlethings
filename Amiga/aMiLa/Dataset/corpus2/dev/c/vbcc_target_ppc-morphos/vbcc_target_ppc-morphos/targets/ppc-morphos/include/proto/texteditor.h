#ifndef _PROTO_TEXTEDITOR_H
#define _PROTO_TEXTEDITOR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_TEXTEDITOR_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/texteditor_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *TextEditorBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/texteditor.h>
#else
#include <inline/texteditor.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/texteditor_protos.h>
#endif
#else
#include <pragma/texteditor_lib.h>
#endif

#endif	/*  _PROTO_TEXTEDITOR_H  */
