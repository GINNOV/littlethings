#ifndef _INCLUDE_PRAGMA_WARP3DPPC_LIB_H
#define _INCLUDE_PRAGMA_WARP3DPPC_LIB_H

#ifndef CLIB_WARP3DPPC_PROTOS_H
#include <clib/Warp3DPPC_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/Warp3DPPC.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#endif
#if defined(_DCC) || defined(__SASC)
#endif
#ifdef __STORM__
#endif
#ifdef __SASC_60
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_WARP3DPPC_LIB_H  */
