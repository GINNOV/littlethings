#ifndef _PROTO_DATATYPES_H
#define _PROTO_DATATYPES_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_DATATYPES_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/datatypes_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *DataTypesBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/datatypes.h>
#else
#include <inline/datatypes.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/datatypes_protos.h>
#endif
#else
#include <pragma/datatypes_lib.h>
#endif

#endif	/*  _PROTO_DATATYPES_H  */
