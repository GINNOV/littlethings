#ifndef _INCLUDE_PRAGMA_KEYMAP_LIB_H
#define _INCLUDE_PRAGMA_KEYMAP_LIB_H

#ifndef CLIB_KEYMAP_PROTOS_H
#include <clib/keymap_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/keymap.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(KeymapBase,0x01E,SetKeyMapDefault(a0))
#pragma amicall(KeymapBase,0x024,AskKeyMapDefault())
#pragma amicall(KeymapBase,0x02A,MapRawKey(a0,a1,d1,a2))
#pragma amicall(KeymapBase,0x030,MapANSI(a0,d0,a1,d1,a2))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall KeymapBase SetKeyMapDefault     01E 801
#pragma  libcall KeymapBase AskKeyMapDefault     024 00
#pragma  libcall KeymapBase MapRawKey            02A A19804
#pragma  libcall KeymapBase MapANSI              030 A190805
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_KEYMAP_LIB_H  */
