#ifndef _INCLUDE_PRAGMA_CHUNKYPPC_LIB_H
#define _INCLUDE_PRAGMA_CHUNKYPPC_LIB_H

#ifndef CLIB_CHUNKYPPC_PROTOS_H
#include <clib/chunkyppc_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/chunkyppc.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ChunkyPPCBase,0x0C6,ChunkyInit68k(a0,d0))
#pragma amicall(ChunkyPPCBase,0x0CC,OpenGraphics(a0,a1,d0))
#pragma amicall(ChunkyPPCBase,0x0D2,CloseGraphics(a0,d0))
#pragma amicall(ChunkyPPCBase,0x0D8,LoadColors(a0,a1))
#pragma amicall(ChunkyPPCBase,0x0DE,DoubleBuffer(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ChunkyPPCBase ChunkyInit68k        0C6 0802
#pragma  libcall ChunkyPPCBase OpenGraphics         0CC 09803
#pragma  libcall ChunkyPPCBase CloseGraphics        0D2 0802
#pragma  libcall ChunkyPPCBase LoadColors           0D8 9802
#pragma  libcall ChunkyPPCBase DoubleBuffer         0DE 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_CHUNKYPPC_LIB_H  */
