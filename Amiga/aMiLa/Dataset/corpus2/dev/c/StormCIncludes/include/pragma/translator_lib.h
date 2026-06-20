#ifndef _INCLUDE_PRAGMA_TRANSLATOR_LIB_H
#define _INCLUDE_PRAGMA_TRANSLATOR_LIB_H

#ifndef CLIB_TRANSLATOR_PROTOS_H
#include <clib/translator_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/translator.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(TranslatorBase,0x01E,Translate(a0,d0,a1,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall TranslatorBase Translate            01E 190804
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_TRANSLATOR_LIB_H  */
