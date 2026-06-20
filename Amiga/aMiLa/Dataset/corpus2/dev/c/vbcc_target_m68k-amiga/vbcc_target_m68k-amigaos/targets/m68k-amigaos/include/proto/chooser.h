#ifndef _PROTO_CHOOSER_H
#define _PROTO_CHOOSER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_CHOOSER_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/chooser_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ChooserBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/chooser.h>
#else
#include <inline/chooser.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/chooser_protos.h>
#endif
#else
#include <pragma/chooser_lib.h>
#endif

#endif	/*  _PROTO_CHOOSER_H  */
