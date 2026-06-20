#ifndef PRAGMAS_FREEDB_PRAGMAS_H
#define PRAGMAS_FREEDB_PRAGMAS_H

/*
**  $VER: freedb_pragmas.h 3.1 (12.12.2001)
**  Includes Release 3.1
**
**  Written by Alfonso Ranieri
**  Released under the GNU Public Licence version 2
*/

#ifndef CLIB_FREEDB_PROTOS_H
#include <clib/freedb_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(FreeDBBase,0x024,FreeDBGetString(d0))
#pragma amicall(FreeDBBase,0x02a,FreeDBReadTOCA(a0))
#pragma amicall(FreeDBBase,0x030,FreeDBAllocObjectA(d0,a0))
#pragma amicall(FreeDBBase,0x036,FreeDBClearObject(a0))
#pragma amicall(FreeDBBase,0x03c,FreeDBFreeObject(a0))
#pragma amicall(FreeDBBase,0x042,FreeDBGetLocalDiscA(a0))
#pragma amicall(FreeDBBase,0x048,FreeDBSaveLocalDiscA(a0))
#pragma amicall(FreeDBBase,0x04e,FreeDBHandleCreateA(a0))
#pragma amicall(FreeDBBase,0x054,FreeDBHandleCommandA(a0,d0,a1))
#pragma amicall(FreeDBBase,0x05a,FreeDBHandleSignal(a0))
#pragma amicall(FreeDBBase,0x060,FreeDBHandleWait(a0))
#pragma amicall(FreeDBBase,0x066,FreeDBHandleAbort(a0))
#pragma amicall(FreeDBBase,0x06c,FreeDBHandleCheck(a0))
#pragma amicall(FreeDBBase,0x072,FreeDBHandleFree(a0))
#pragma amicall(FreeDBBase,0x078,FreeDBFreeMessage(a0))
#pragma amicall(FreeDBBase,0x07e,FreeDBGetDiscA(a0))
#pragma amicall(FreeDBBase,0x084,FreeDBFreeConfig(a0))
#pragma amicall(FreeDBBase,0x08a,FreeDBReadConfig(a0))
#pragma amicall(FreeDBBase,0x090,FreeDBSaveConfig(a0,a1))
#pragma amicall(FreeDBBase,0x096,FreeDBConfigChanged())
#pragma amicall(FreeDBBase,0x09c,FreeDBPlayMSFA(a0))
#pragma amicall(FreeDBBase,0x0a2,FreeDBMatchStartA(a0))
#pragma amicall(FreeDBBase,0x0a8,FreeDBMatchNext(a0))
#pragma amicall(FreeDBBase,0x0ae,FreeDBMatchEnd(a0))
#pragma amicall(FreeDBBase,0x0b4,FreeDBSetDiscInfoA(a0,a1))
#pragma amicall(FreeDBBase,0x0ba,FreeDBSetDiscInfoTrackA(a0,d0,a1))
#pragma amicall(FreeDBBase,0x0c0,FreeDBCreateAppA(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall FreeDBBase FreeDBGetString         024 001
#pragma  libcall FreeDBBase FreeDBReadTOCA          02a 801
#pragma  libcall FreeDBBase FreeDBAllocObjectA      030 8002
#pragma  libcall FreeDBBase FreeDBClearObject       036 801
#pragma  libcall FreeDBBase FreeDBFreeObject        03c 801
#pragma  libcall FreeDBBase FreeDBGetLocalDiscA     042 801
#pragma  libcall FreeDBBase FreeDBSaveLocalDiscA    048 801
#pragma  libcall FreeDBBase FreeDBHandleCreateA     04e 801
#pragma  libcall FreeDBBase FreeDBHandleCommandA    054 90803
#pragma  libcall FreeDBBase FreeDBHandleSignal      05a 801
#pragma  libcall FreeDBBase FreeDBHandleWait        060 801
#pragma  libcall FreeDBBase FreeDBHandleAbort       066 801
#pragma  libcall FreeDBBase FreeDBHandleCheck       06c 801
#pragma  libcall FreeDBBase FreeDBHandleFree        072 801
#pragma  libcall FreeDBBase FreeDBFreeMessage       078 801
#pragma  libcall FreeDBBase FreeDBGetDiscA          07e 801
#pragma  libcall FreeDBBase FreeDBFreeConfig        084 801
#pragma  libcall FreeDBBase FreeDBReadConfig        08a 801
#pragma  libcall FreeDBBase FreeDBSaveConfig        090 9802
#pragma  libcall FreeDBBase FreeDBConfigChanged     096 00
#pragma  libcall FreeDBBase FreeDBPlayMSFA          09c 801
#pragma  libcall FreeDBBase FreeDBMatchStartA       0a2 801
#pragma  libcall FreeDBBase FreeDBMatchNext         0a8 801
#pragma  libcall FreeDBBase FreeDBMatchEnd          0ae 801
#pragma  libcall FreeDBBase FreeDBSetDiscInfoA      0b4 9802
#pragma  libcall FreeDBBase FreeDBSetDiscInfoTrackA 0ba 90803
#pragma  libcall FreeDBBase FreeDBCreateAppA        0c0 801
#endif
#ifdef __STORM__
#pragma tagcall(FreeDBBase,0x02a,FreeDBReadTOC(a0))
#pragma tagcall(FreeDBBase,0x030,FreeDBAllocObject(d0,a0))
#pragma tagcall(FreeDBBase,0x042,FreeDBGetLocalDisc(a0))
#pragma tagcall(FreeDBBase,0x048,FreeDBSaveLocalDisc(a0))
#pragma tagcall(FreeDBBase,0x04e,FreeDBHandleCreate(a0))
#pragma tagcall(FreeDBBase,0x054,FreeDBHandleCommand(a0,d0,a1))
#pragma tagcall(FreeDBBase,0x07e,FreeDBGetDisc(a0))
#pragma tagcall(FreeDBBase,0x09c,FreeDBPlayMSF(a0))
#pragma tagcall(FreeDBBase,0x0a2,FreeDBMatchStart(a0))
#pragma tagcall(FreeDBBase,0x0b4,FreeDBSetDiscInfo(a0,a1))
#pragma tagcall(FreeDBBase,0x0ba,FreeDBSetDiscInfoTrack(a0,d0,a1))
#pragma tagcall(FreeDBBase,0x0c0,FreeDBCreateApp(a0))
#endif
#ifdef __SASC_60
#pragma  tagcall FreeDBBase FreeDBReadTOC          02a 801
#pragma  tagcall FreeDBBase FreeDBAllocObject      030 8002
#pragma  tagcall FreeDBBase FreeDBGetLocalDisc     042 801
#pragma  tagcall FreeDBBase FreeDBSaveLocalDisc    048 801
#pragma  tagcall FreeDBBase FreeDBHandleCreate     04e 801
#pragma  tagcall FreeDBBase FreeDBHandleCommand    054 90803
#pragma  tagcall FreeDBBase FreeDBGetDisc          07e 801
#pragma  tagcall FreeDBBase FreeDBPlayMSF          09c 801
#pragma  tagcall FreeDBBase FreeDBMatchStart       0a2 801
#pragma  tagcall FreeDBBase FreeDBSetDiscInfo      0b4 9802
#pragma  tagcall FreeDBBase FreeDBSetDiscInfoTrack 0ba 90803
#pragma  tagcall FreeDBBase FreeDBCreateApp        0c0 801
#endif

#endif /* PRAGMAS_FREEDB_PRAGMAS_H */
