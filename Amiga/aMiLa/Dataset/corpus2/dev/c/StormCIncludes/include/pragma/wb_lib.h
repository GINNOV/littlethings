#ifndef _INCLUDE_PRAGMA_WB_LIB_H
#define _INCLUDE_PRAGMA_WB_LIB_H

#ifndef CLIB_WB_PROTOS_H
#include <clib/wb_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/wb.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(WorkbenchBase,0x030,AddAppWindowA(d0,d1,a0,a1,a2))
#pragma amicall(WorkbenchBase,0x036,RemoveAppWindow(a0))
#pragma amicall(WorkbenchBase,0x03C,AddAppIconA(d0,d1,a0,a1,a2,a3,a4))
#pragma amicall(WorkbenchBase,0x042,RemoveAppIcon(a0))
#pragma amicall(WorkbenchBase,0x048,AddAppMenuItemA(d0,d1,a0,a1,a2))
#pragma amicall(WorkbenchBase,0x04E,RemoveAppMenuItem(a0))
#pragma amicall(WorkbenchBase,0x05A,WBInfo(a0,a1,a2))
#pragma amicall(WorkbenchBase,0x060,OpenWorkbenchObjectA(a0,a1))
#pragma amicall(WorkbenchBase,0x066,CloseWorkbenchObjectA(a0,a1))
#pragma amicall(WorkbenchBase,0x06C,WorkbenchControlA(a0,a1))
#pragma amicall(WorkbenchBase,0x072,AddAppWindowDropZoneA(a0,d0,d1,a1))
#pragma amicall(WorkbenchBase,0x078,RemoveAppWindowDropZone(a0,a1))
#pragma amicall(WorkbenchBase,0x07E,ChangeWorkbenchSelectionA(a0,a1,a2))
#pragma amicall(WorkbenchBase,0x084,MakeWorkbenchObjectVisibleA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall WorkbenchBase AddAppWindowA        030 A981005
#pragma  libcall WorkbenchBase RemoveAppWindow      036 801
#pragma  libcall WorkbenchBase AddAppIconA          03C CBA981007
#pragma  libcall WorkbenchBase RemoveAppIcon        042 801
#pragma  libcall WorkbenchBase AddAppMenuItemA      048 A981005
#pragma  libcall WorkbenchBase RemoveAppMenuItem    04E 801
#pragma  libcall WorkbenchBase WBInfo               05A A9803
#pragma  libcall WorkbenchBase OpenWorkbenchObjectA 060 9802
#pragma  libcall WorkbenchBase CloseWorkbenchObjectA 066 9802
#pragma  libcall WorkbenchBase WorkbenchControlA    06C 9802
#pragma  libcall WorkbenchBase AddAppWindowDropZoneA 072 910804
#pragma  libcall WorkbenchBase RemoveAppWindowDropZone 078 9802
#pragma  libcall WorkbenchBase ChangeWorkbenchSelectionA 07E A9803
#pragma  libcall WorkbenchBase MakeWorkbenchObjectVisibleA 084 9802
#endif
#ifdef __STORM__
#pragma tagcall(WorkbenchBase,0x030,AddAppWindow(d0,d1,a0,a1,a2))
#pragma tagcall(WorkbenchBase,0x03C,AddAppIcon(d0,d1,a0,a1,a2,a3,a4))
#pragma tagcall(WorkbenchBase,0x048,AddAppMenuItem(d0,d1,a0,a1,a2))
#pragma tagcall(WorkbenchBase,0x060,OpenWorkbenchObject(a0,a1))
#pragma tagcall(WorkbenchBase,0x066,CloseWorkbenchObject(a0,a1))
#pragma tagcall(WorkbenchBase,0x06C,WorkbenchControl(a0,a1))
#pragma tagcall(WorkbenchBase,0x072,AddAppWindowDropZone(a0,d0,d1,a1))
#pragma tagcall(WorkbenchBase,0x07E,ChangeWorkbenchSelection(a0,a1,a2))
#pragma tagcall(WorkbenchBase,0x084,MakeWorkbenchObjectVisible(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall WorkbenchBase AddAppWindow         030 A981005
#pragma  tagcall WorkbenchBase AddAppIcon           03C CBA981007
#pragma  tagcall WorkbenchBase AddAppMenuItem       048 A981005
#pragma  tagcall WorkbenchBase OpenWorkbenchObject  060 9802
#pragma  tagcall WorkbenchBase CloseWorkbenchObject 066 9802
#pragma  tagcall WorkbenchBase WorkbenchControl     06C 9802
#pragma  tagcall WorkbenchBase AddAppWindowDropZone 072 910804
#pragma  tagcall WorkbenchBase ChangeWorkbenchSelection 07E A9803
#pragma  tagcall WorkbenchBase MakeWorkbenchObjectVisible 084 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_WB_LIB_H  */
