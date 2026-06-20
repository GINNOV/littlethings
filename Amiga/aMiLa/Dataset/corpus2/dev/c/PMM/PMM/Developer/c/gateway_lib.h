#ifndef _INCLUDE_PRAGMA_GATEWAY_LIB_H
#define _INCLUDE_PRAGMA_GATEWAY_LIB_H

#ifndef CLIB_GATEWAY_PROTOS_H
#include "gateway_protos.h"
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#include "_Pragmas_From_Fd_2_AMICALL"
#endif
#if defined(_DCC) || defined(__SASC)
#include "_Pragmas_From_Fd_2_LIBCALL"
#endif
#ifdef __STORM__
#endif
#ifdef __SASC_60
#endif

#endif	/*  _INCLUDE_PRAGMA_GATEWAY_LIB_H  */
