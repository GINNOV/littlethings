#ifndef _PROTO_CIA_H
#define _PROTO_CIA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_CIA_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/cia_protos.h>
#pragma stdargs-off
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/cia.h>
#else
#include <inline/cia.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/cia_protos.h>
#endif
#else
#include <pragma/cia_lib.h>
#endif

#endif	/*  _PROTO_CIA_H  */
