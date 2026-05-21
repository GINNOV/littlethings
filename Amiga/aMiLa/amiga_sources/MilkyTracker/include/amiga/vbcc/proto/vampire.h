#ifndef _PROTO_VAMPIRE_H
#define _PROTO_VAMPIRE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_VAMPIRE_PROTOS_H) && !defined(__GNUC__)
#include <clib/vampire_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *VampireBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/vampire.h>
#else
#include <inline/vampire.h>
#endif
#elif defined(__VBCC__)
#include <inline/vampire_protos.h>
#else
#include <pragma/vampire_lib.h>
#endif

#endif	/*  _PROTO_VAMPIRE_H  */
