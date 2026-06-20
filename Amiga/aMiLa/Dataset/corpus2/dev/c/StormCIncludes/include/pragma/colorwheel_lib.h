#ifndef _INCLUDE_PRAGMA_COLORWHEEL_LIB_H
#define _INCLUDE_PRAGMA_COLORWHEEL_LIB_H

#ifndef CLIB_COLORWHEEL_PROTOS_H
#include <clib/colorwheel_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/colorwheel.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ColorWheelBase,0x01E,ConvertHSBToRGB(a0,a1))
#pragma amicall(ColorWheelBase,0x024,ConvertRGBToHSB(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ColorWheelBase ConvertHSBToRGB      01E 9802
#pragma  libcall ColorWheelBase ConvertRGBToHSB      024 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_COLORWHEEL_LIB_H  */
