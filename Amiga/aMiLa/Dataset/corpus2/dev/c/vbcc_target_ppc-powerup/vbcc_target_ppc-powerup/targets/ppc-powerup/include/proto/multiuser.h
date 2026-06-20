#ifndef _PROTO_MULTIUSER_H
#define _PROTO_MULTIUSER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_MULTIUSER_PROTOS_H) && !defined(__GNUC__)
#include <clib/multiuser_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *muBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/multiuser.h>
#else
#include <inline/multiuser.h>
#endif
#elif !defined(__VBCC__)
#include <pragma/multiuser_lib.h>
#endif

#endif	/*  _PROTO_MULTIUSER_H  */
