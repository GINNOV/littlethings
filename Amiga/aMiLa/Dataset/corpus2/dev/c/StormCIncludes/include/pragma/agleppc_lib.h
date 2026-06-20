#ifndef _INCLUDE_PRAGMA_AGLEPPC_LIB_H
#define _INCLUDE_PRAGMA_AGLEPPC_LIB_H

#ifndef CLIB_AGLEPPC_PROTOS_H
#include <clib/agleppc_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/agleppc.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#endif
#if defined(_DCC) || defined(__SASC)
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_AGLEPPC_LIB_H  */
