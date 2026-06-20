#ifndef _INCLUDE_PRAGMA_SLIDER_LIB_H
#define _INCLUDE_PRAGMA_SLIDER_LIB_H

#ifndef CLIB_SLIDER_PROTOS_H
#include <clib/slider_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/slider.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(SliderBase,0x01E,SLIDER_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall SliderBase SLIDER_GetClass      01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_SLIDER_LIB_H  */
