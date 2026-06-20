#ifndef _PROTO_BUTTON_H
#define _PROTO_BUTTON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_BUTTON_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/button_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ButtonBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/button.h>
#else
#include <inline/button.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/button_protos.h>
#endif
#else
#include <pragma/button_lib.h>
#endif

#endif	/*  _PROTO_BUTTON_H  */
