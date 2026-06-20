#ifndef _INCLUDE_PRAGMA_BUTTON_LIB_H
#define _INCLUDE_PRAGMA_BUTTON_LIB_H

#ifndef CLIB_BUTTON_PROTOS_H
#include <clib/button_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/button.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ButtonBase,0x01E,BUTTON_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ButtonBase BUTTON_GetClass      01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_BUTTON_LIB_H  */
