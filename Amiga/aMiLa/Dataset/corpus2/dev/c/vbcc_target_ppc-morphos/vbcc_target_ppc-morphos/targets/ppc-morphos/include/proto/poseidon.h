#ifndef _PROTO_POSEIDON_H
#define _PROTO_POSEIDON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_POSEIDON_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/poseidon_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *PsdBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/poseidon.h>
#else
#include <inline/poseidon.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/poseidon_protos.h>
#endif
#else
#include <pragma/poseidon_lib.h>
#endif

#endif	/*  _PROTO_POSEIDON_H  */
