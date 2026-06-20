#ifndef _INCLUDE_PRAGMA_680X0_LIB_H
#define _INCLUDE_PRAGMA_680X0_LIB_H

#ifndef CLIB_680X0_PROTOS_H
#include <clib/680x0_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MC680x0Base,0x01E,CPUType())
#pragma amicall(MC680x0Base,0x024,FPUType())
#pragma amicall(MC680x0Base,0x02A,MMUType())
#pragma amicall(MC680x0Base,0x030,SetFPUExceptions(d0,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MC680x0Base CPUType              01E 00
#pragma  libcall MC680x0Base FPUType              024 00
#pragma  libcall MC680x0Base MMUType              02A 00
#pragma  libcall MC680x0Base SetFPUExceptions     030 1002
#endif

#endif	/*  _INCLUDE_PRAGMA_680X0_LIB_H  */
