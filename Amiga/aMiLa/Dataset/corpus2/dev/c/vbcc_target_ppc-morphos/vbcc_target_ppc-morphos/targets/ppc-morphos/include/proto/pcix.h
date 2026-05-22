#ifndef _PROTO_PCIX_H
#define _PROTO_PCIX_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_PCIX_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/pcix_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *PCIXBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/pcix.h>
#else
#include <inline/pcix.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/pcix_protos.h>
#endif
#else
#include <pragma/pcix_lib.h>
#endif

#endif	/*  _PROTO_PCIX_H  */
