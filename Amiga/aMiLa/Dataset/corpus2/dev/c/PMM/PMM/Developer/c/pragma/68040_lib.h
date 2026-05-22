#ifndef _INCLUDE_PRAGMA_68040_LIB_H
#define _INCLUDE_PRAGMA_68040_LIB_H

#ifndef CLIB_68040_PROTOS_H
#include <clib/68040_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MC68040Base,0x0DE,FPUControl(d0,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MC68040Base FPUControl           0DE 1002
#endif

#endif	/*  _INCLUDE_PRAGMA_68040_LIB_H  */
