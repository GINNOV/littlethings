#ifndef _INCLUDE_PRAGMA_RADIOBUTTON_LIB_H
#define _INCLUDE_PRAGMA_RADIOBUTTON_LIB_H

#ifndef CLIB_RADIOBUTTON_PROTOS_H
#include <clib/radiobutton_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/radiobutton.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(RadioButtonBase,0x01E,RADIOBUTTON_GetClass())
#pragma amicall(RadioButtonBase,0x024,AllocRadioButtonNodeA(d0,a0))
#pragma amicall(RadioButtonBase,0x02A,FreeRadioButtonNode(a0))
#pragma amicall(RadioButtonBase,0x030,SetRadioButtonNodeAttrsA(a0,a1))
#pragma amicall(RadioButtonBase,0x036,GetRadioButtonNodeAttrsA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall RadioButtonBase RADIOBUTTON_GetClass 01E 00
#pragma  libcall RadioButtonBase AllocRadioButtonNodeA 024 8002
#pragma  libcall RadioButtonBase FreeRadioButtonNode  02A 801
#pragma  libcall RadioButtonBase SetRadioButtonNodeAttrsA 030 9802
#pragma  libcall RadioButtonBase GetRadioButtonNodeAttrsA 036 9802
#endif
#ifdef __STORM__
#pragma tagcall(RadioButtonBase,0x024,AllocRadioButtonNode(d0,a0))
#pragma tagcall(RadioButtonBase,0x030,SetRadioButtonNodeAttrs(a0,a1))
#pragma tagcall(RadioButtonBase,0x036,GetRadioButtonNodeAttrs(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall RadioButtonBase AllocRadioButtonNode 024 8002
#pragma  tagcall RadioButtonBase SetRadioButtonNodeAttrs 030 9802
#pragma  tagcall RadioButtonBase GetRadioButtonNodeAttrs 036 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_RADIOBUTTON_LIB_H  */
