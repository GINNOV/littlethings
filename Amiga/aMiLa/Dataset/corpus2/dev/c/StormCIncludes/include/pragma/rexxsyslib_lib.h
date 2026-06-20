#ifndef _INCLUDE_PRAGMA_REXXSYSLIB_LIB_H
#define _INCLUDE_PRAGMA_REXXSYSLIB_LIB_H

#ifndef CLIB_REXXSYSLIB_PROTOS_H
#include <clib/rexxsyslib_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/rexxsyslib.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(RexxSysBase,0x07E,CreateArgstring(a0,d0))
#pragma amicall(RexxSysBase,0x084,DeleteArgstring(a0))
#pragma amicall(RexxSysBase,0x08A,LengthArgstring(a0))
#pragma amicall(RexxSysBase,0x090,CreateRexxMsg(a0,a1,d0))
#pragma amicall(RexxSysBase,0x096,DeleteRexxMsg(a0))
#pragma amicall(RexxSysBase,0x09C,ClearRexxMsg(a0,d0))
#pragma amicall(RexxSysBase,0x0A2,FillRexxMsg(a0,d0,d1))
#pragma amicall(RexxSysBase,0x0A8,IsRexxMsg(a0))
#pragma amicall(RexxSysBase,0x1C2,LockRexxBase(d0))
#pragma amicall(RexxSysBase,0x1C8,UnlockRexxBase(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall RexxSysBase CreateArgstring      07E 0802
#pragma  libcall RexxSysBase DeleteArgstring      084 801
#pragma  libcall RexxSysBase LengthArgstring      08A 801
#pragma  libcall RexxSysBase CreateRexxMsg        090 09803
#pragma  libcall RexxSysBase DeleteRexxMsg        096 801
#pragma  libcall RexxSysBase ClearRexxMsg         09C 0802
#pragma  libcall RexxSysBase FillRexxMsg          0A2 10803
#pragma  libcall RexxSysBase IsRexxMsg            0A8 801
#pragma  libcall RexxSysBase LockRexxBase         1C2 001
#pragma  libcall RexxSysBase UnlockRexxBase       1C8 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_REXXSYSLIB_LIB_H  */
