#ifndef _INCLUDE_PRAGMA_COMMODITIES_LIB_H
#define _INCLUDE_PRAGMA_COMMODITIES_LIB_H

#ifndef CLIB_COMMODITIES_PROTOS_H
#include <clib/commodities_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/commodities.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(CxBase,0x01E,CreateCxObj(d0,a0,a1))
#pragma amicall(CxBase,0x024,CxBroker(a0,d0))
#pragma amicall(CxBase,0x02A,ActivateCxObj(a0,d0))
#pragma amicall(CxBase,0x030,DeleteCxObj(a0))
#pragma amicall(CxBase,0x036,DeleteCxObjAll(a0))
#pragma amicall(CxBase,0x03C,CxObjType(a0))
#pragma amicall(CxBase,0x042,CxObjError(a0))
#pragma amicall(CxBase,0x048,ClearCxObjError(a0))
#pragma amicall(CxBase,0x04E,SetCxObjPri(a0,d0))
#pragma amicall(CxBase,0x054,AttachCxObj(a0,a1))
#pragma amicall(CxBase,0x05A,EnqueueCxObj(a0,a1))
#pragma amicall(CxBase,0x060,InsertCxObj(a0,a1,a2))
#pragma amicall(CxBase,0x066,RemoveCxObj(a0))
#pragma amicall(CxBase,0x072,SetTranslate(a0,a1))
#pragma amicall(CxBase,0x078,SetFilter(a0,a1))
#pragma amicall(CxBase,0x07E,SetFilterIX(a0,a1))
#pragma amicall(CxBase,0x084,ParseIX(a0,a1))
#pragma amicall(CxBase,0x08A,CxMsgType(a0))
#pragma amicall(CxBase,0x090,CxMsgData(a0))
#pragma amicall(CxBase,0x096,CxMsgID(a0))
#pragma amicall(CxBase,0x09C,DivertCxMsg(a0,a1,a2))
#pragma amicall(CxBase,0x0A2,RouteCxMsg(a0,a1))
#pragma amicall(CxBase,0x0A8,DisposeCxMsg(a0))
#pragma amicall(CxBase,0x0AE,InvertKeyMap(d0,a0,a1))
#pragma amicall(CxBase,0x0B4,AddIEvents(a0))
#pragma amicall(CxBase,0x0CC,MatchIX(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall CxBase CreateCxObj          01E 98003
#pragma  libcall CxBase CxBroker             024 0802
#pragma  libcall CxBase ActivateCxObj        02A 0802
#pragma  libcall CxBase DeleteCxObj          030 801
#pragma  libcall CxBase DeleteCxObjAll       036 801
#pragma  libcall CxBase CxObjType            03C 801
#pragma  libcall CxBase CxObjError           042 801
#pragma  libcall CxBase ClearCxObjError      048 801
#pragma  libcall CxBase SetCxObjPri          04E 0802
#pragma  libcall CxBase AttachCxObj          054 9802
#pragma  libcall CxBase EnqueueCxObj         05A 9802
#pragma  libcall CxBase InsertCxObj          060 A9803
#pragma  libcall CxBase RemoveCxObj          066 801
#pragma  libcall CxBase SetTranslate         072 9802
#pragma  libcall CxBase SetFilter            078 9802
#pragma  libcall CxBase SetFilterIX          07E 9802
#pragma  libcall CxBase ParseIX              084 9802
#pragma  libcall CxBase CxMsgType            08A 801
#pragma  libcall CxBase CxMsgData            090 801
#pragma  libcall CxBase CxMsgID              096 801
#pragma  libcall CxBase DivertCxMsg          09C A9803
#pragma  libcall CxBase RouteCxMsg           0A2 9802
#pragma  libcall CxBase DisposeCxMsg         0A8 801
#pragma  libcall CxBase InvertKeyMap         0AE 98003
#pragma  libcall CxBase AddIEvents           0B4 801
#pragma  libcall CxBase MatchIX              0CC 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_COMMODITIES_LIB_H  */
