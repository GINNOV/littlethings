#ifndef _PROTO_AMIGAGUIDECLASS_H
#define _PROTO_AMIGAGUIDECLASS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_AMIGAGUIDECLASS_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/amigaguideclass_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *AmigaGuideClassBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/amigaguideclass.h>
#else
#include <inline/amigaguideclass.h>
#endif
#elif defined(__VBCC__)
#ifndef __NOINLINEASM__
#include <inline/amigaguideclass_protos.h>
#endif
#else
#include <pragma/amigaguideclass_lib.h>
#endif

#endif	/*  _PROTO_AMIGAGUIDECLASS_H  */
