#ifndef _PROTO_SERSCRIPT_H
#define _PROTO_SERSCRIPT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_SERSCRIPT_PROTOS_H) && !defined(__GNUC__)
#include <clib/serscript_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *SerScriptBase;
#endif

#ifdef __GNUC__
#include <inline/serscript.h>
#elif defined(__VBCC__)
#include <inline/serscript_protos.h>
#else
#include <pragma/serscript_lib.h>
#endif

#endif	/*  _PROTO_SERSCRIPT_H  */
