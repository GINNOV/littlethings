#ifndef _INCLUDE_PRAGMA_TEXTFIELD_LIB_H
#define _INCLUDE_PRAGMA_TEXTFIELD_LIB_H

#ifndef CLIB_TEXTFIELD_PROTOS_H
#include <clib/textfield_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/textfield.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(TextFieldBase,0x01E,TEXTFIELD_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall TextFieldBase TEXTFIELD_GetClass   01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_TEXTFIELD_LIB_H  */
