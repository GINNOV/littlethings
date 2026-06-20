#ifndef _PROTO_PCIIDS_H
#define _PROTO_PCIIDS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_PCIIDS_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/pciids_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *PCIIDSBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/pciids.h>
#else
#include <inline/pciids.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/pciids_protos.h>
#endif
#else
#include <pragma/pciids_lib.h>
#endif

#endif	/*  _PROTO_PCIIDS_H  */
