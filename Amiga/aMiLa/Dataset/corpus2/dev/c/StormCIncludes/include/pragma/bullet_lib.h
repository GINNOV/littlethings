#ifndef _INCLUDE_PRAGMA_BULLET_LIB_H
#define _INCLUDE_PRAGMA_BULLET_LIB_H

#ifndef CLIB_BULLET_PROTOS_H
#include <clib/bullet_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/bullet.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(BulletBase,0x01E,OpenEngine())
#pragma amicall(BulletBase,0x024,CloseEngine(a0))
#pragma amicall(BulletBase,0x02A,SetInfoA(a0,a1))
#pragma amicall(BulletBase,0x030,ObtainInfoA(a0,a1))
#pragma amicall(BulletBase,0x036,ReleaseInfoA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall BulletBase OpenEngine           01E 00
#pragma  libcall BulletBase CloseEngine          024 801
#pragma  libcall BulletBase SetInfoA             02A 9802
#pragma  libcall BulletBase ObtainInfoA          030 9802
#pragma  libcall BulletBase ReleaseInfoA         036 9802
#endif
#ifdef __STORM__
#pragma tagcall(BulletBase,0x02A,SetInfo(a0,a1))
#pragma tagcall(BulletBase,0x030,ObtainInfo(a0,a1))
#pragma tagcall(BulletBase,0x036,ReleaseInfo(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall BulletBase SetInfo              02A 9802
#pragma  tagcall BulletBase ObtainInfo           030 9802
#pragma  tagcall BulletBase ReleaseInfo          036 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_BULLET_LIB_H  */
