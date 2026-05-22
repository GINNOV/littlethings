#ifndef _INCLUDE_PRAGMA_MPEGA_LIB_H
#define _INCLUDE_PRAGMA_MPEGA_LIB_H

#ifndef CLIB_MPEGA_PROTOS_H
#include <clib/mpega_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/mpega.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MPEGABase,0x01E,MPEGA_open(a0,a1))
#pragma amicall(MPEGABase,0x024,MPEGA_close(a0))
#pragma amicall(MPEGABase,0x02A,MPEGA_decode_frame(a0,a1))
#pragma amicall(MPEGABase,0x030,MPEGA_seek(a0,d0))
#pragma amicall(MPEGABase,0x036,MPEGA_time(a0,a1))
#pragma amicall(MPEGABase,0x03C,MPEGA_find_sync(a0,d0))
#pragma amicall(MPEGABase,0x042,MPEGA_scale(a0,d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MPEGABase MPEGA_open           01E 9802
#pragma  libcall MPEGABase MPEGA_close          024 801
#pragma  libcall MPEGABase MPEGA_decode_frame   02A 9802
#pragma  libcall MPEGABase MPEGA_seek           030 0802
#pragma  libcall MPEGABase MPEGA_time           036 9802
#pragma  libcall MPEGABase MPEGA_find_sync      03C 0802
#pragma  libcall MPEGABase MPEGA_scale          042 0802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_MPEGA_LIB_H  */
