#ifndef _INCLUDE_PRAGMA_TEST_LIB_H
#define _INCLUDE_PRAGMA_TEST_LIB_H

#ifndef CLIB_TEST_PROTOS_H
#include <clib/test_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(TestBase,0x024,Add(d0,d1))
#pragma amicall(TestBase,0x02a,Sub(d0,d1))
#pragma amicall(TestBase,0x036,CloneWBScr())
#pragma amicall(TestBase,0x03c,CloseClonedWBScr(a0))
#pragma amicall(TestBase,0x042,GetClonedWBScrAttrA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall TestBase Add                    024 1002
#pragma  libcall TestBase Sub                    02a 1002
#pragma  libcall TestBase CloneWBScr             036 00
#pragma  libcall TestBase CloseClonedWBScr       03c 801
#pragma  libcall TestBase GetClonedWBScrAttrA    042 9802
#endif
#ifdef __STORM__
#pragma tagcall(TestBase,0x042,GetClonedWBScrAttr(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall TestBase GetClonedWBScrAttr     042 9802
#endif

#endif	/*  _INCLUDE_PRAGMA_TEST_LIB_H  */
