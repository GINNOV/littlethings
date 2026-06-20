#ifndef _INCLUDE_PRAGMA_DISKFONT_LIB_H
#define _INCLUDE_PRAGMA_DISKFONT_LIB_H

#ifndef CLIB_DISKFONT_PROTOS_H
#include <clib/diskfont_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/diskfont.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(DiskfontBase,0x01E,OpenDiskFont(a0))
#pragma amicall(DiskfontBase,0x024,AvailFonts(a0,d0,d1))
#pragma amicall(DiskfontBase,0x02A,NewFontContents(a0,a1))
#pragma amicall(DiskfontBase,0x030,DisposeFontContents(a1))
#pragma amicall(DiskfontBase,0x036,NewScaledDiskFont(a0,a1))
#pragma amicall(DiskfontBase,0x03C,GetDiskFontCtrl(d0))
#pragma amicall(DiskfontBase,0x042,SetDiskFontCtrlA(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall DiskfontBase OpenDiskFont         01E 801
#pragma  libcall DiskfontBase AvailFonts           024 10803
#pragma  libcall DiskfontBase NewFontContents      02A 9802
#pragma  libcall DiskfontBase DisposeFontContents  030 901
#pragma  libcall DiskfontBase NewScaledDiskFont    036 9802
#pragma  libcall DiskfontBase GetDiskFontCtrl      03C 001
#pragma  libcall DiskfontBase SetDiskFontCtrlA     042 801
#endif
#ifdef __STORM__
#pragma tagcall(DiskfontBase,0x042,SetDiskFontCtrl(a0))
#endif
#ifdef __SASC_60
#pragma  tagcall DiskfontBase SetDiskFontCtrl      042 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_DISKFONT_LIB_H  */
