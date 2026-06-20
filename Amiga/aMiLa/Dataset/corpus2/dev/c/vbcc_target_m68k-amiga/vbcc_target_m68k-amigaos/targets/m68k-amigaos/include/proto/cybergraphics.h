#ifndef _PROTO_CYBERGRAPHICS_H
#define _PROTO_CYBERGRAPHICS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_CYBERGRAPHICS_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/cybergraphics_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *CyberGfxBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/cybergraphics.h>
#else
#include <inline/cybergraphics.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/cybergraphics_protos.h>
#endif
#else
#include <pragma/cybergraphics_lib.h>
#endif

#endif	/*  _PROTO_CYBERGRAPHICS_H  */
