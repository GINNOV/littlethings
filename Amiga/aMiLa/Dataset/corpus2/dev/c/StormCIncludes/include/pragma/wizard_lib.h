#ifndef _INCLUDE_PRAGMA_WIZARD_LIB_H
#define _INCLUDE_PRAGMA_WIZARD_LIB_H

#ifndef CLIB_WIZARD_PROTOS_H
#include <clib/wizard_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/wizard.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(WizardBase,0x01E,WZ_OpenSurfaceA(a0,a1,a2))
#pragma amicall(WizardBase,0x024,WZ_CloseSurface(a0))
#pragma amicall(WizardBase,0x02A,WZ_AllocWindowHandleA(d0,d1,a0,a1))
#pragma amicall(WizardBase,0x030,WZ_CreateWindowObjA(a0,d0,a1))
#pragma amicall(WizardBase,0x036,WZ_OpenWindowA(a0,a1,a2))
#pragma amicall(WizardBase,0x03C,WZ_CloseWindow(a0))
#pragma amicall(WizardBase,0x042,WZ_FreeWindowHandle(a0))
#pragma amicall(WizardBase,0x048,WZ_LockWindow(a0))
#pragma amicall(WizardBase,0x04E,WZ_UnlockWindow(a0))
#pragma amicall(WizardBase,0x054,WZ_LockWindows(a0))
#pragma amicall(WizardBase,0x05A,WZ_UnlockWindows(a0))
#pragma amicall(WizardBase,0x060,WZ_GadgetHelp(a0,a1))
#pragma amicall(WizardBase,0x066,WZ_GadgetConfig(a0,a1))
#pragma amicall(WizardBase,0x06C,WZ_MenuHelp(a0,d0))
#pragma amicall(WizardBase,0x072,WZ_MenuConfig(a0,d0))
#pragma amicall(WizardBase,0x078,WZ_InitEasyStruct(a0,a1,d0,d1))
#pragma amicall(WizardBase,0x07E,WZ_SnapShotA(a0,a1))
#pragma amicall(WizardBase,0x084,WZ_GadgetKeyA(a0,d0,d1,a1))
#pragma amicall(WizardBase,0x08A,WZ_DrawVImageA(a0,d0,d1,d2,d3,d4,d5,d6,a1))
#pragma amicall(WizardBase,0x090,WZ_EasyRequestArgs(a0,a1,d0,a2))
#pragma amicall(WizardBase,0x096,WZ_GetNode(a0,d0))
#pragma amicall(WizardBase,0x09C,WZ_ListCount(a0))
#pragma amicall(WizardBase,0x0A2,WZ_NewObjectA(a1,d0,a0))
#pragma amicall(WizardBase,0x0A8,WZ_GadgetHelpMsg(a0,a1,a2,d0,d1,d2))
#pragma amicall(WizardBase,0x0AE,WZ_ObjectID(a0,a2,a1))
#pragma amicall(WizardBase,0x0B4,WZ_InitNodeA(a0,d0,a1))
#pragma amicall(WizardBase,0x0BA,WZ_InitNodeEntryA(a0,d0,a1))
#pragma amicall(WizardBase,0x0C0,WZ_CreateImageBitMap(d0,a0,a1,a2,a3))
#pragma amicall(WizardBase,0x0C6,WZ_DeleteImageBitMap(a0,a1,a2,a3))
#pragma amicall(WizardBase,0x0CC,WZ_GetDataAddress(a0,d0,d1))
#pragma amicall(WizardBase,0x0D2,WZ_GadgetObjectname(a0,a1))
#pragma amicall(WizardBase,0x0D8,WZ_MenuObjectname(a0,d0))
#pragma amicall(WizardBase,0x0DE,WZ_WindowGadgets(a0,d0))
#pragma amicall(WizardBase,0x0E4,WZ_HandleIMessage(a0,a1))
#pragma amicall(WizardBase,0x0EA,WZ_ControlBubbleHelpA(a0,a1))
#pragma amicall(WizardBase,0x0F0,WZ_WindowObjectname(a0,d0))
#pragma amicall(WizardBase,0x0F6,WZ_RequestObjectname(a0,d0))
#pragma amicall(WizardBase,0x0FC,WZ_FontObjectname(a0,d0))
#pragma amicall(WizardBase,0x102,WZ_LibraryObjectname(a0,d0))
#pragma amicall(WizardBase,0x108,WZ_ImageObjectname(a0,d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall WizardBase WZ_OpenSurfaceA      01E A9803
#pragma  libcall WizardBase WZ_CloseSurface      024 801
#pragma  libcall WizardBase WZ_AllocWindowHandleA 02A 981004
#pragma  libcall WizardBase WZ_CreateWindowObjA  030 90803
#pragma  libcall WizardBase WZ_OpenWindowA       036 A9803
#pragma  libcall WizardBase WZ_CloseWindow       03C 801
#pragma  libcall WizardBase WZ_FreeWindowHandle  042 801
#pragma  libcall WizardBase WZ_LockWindow        048 801
#pragma  libcall WizardBase WZ_UnlockWindow      04E 801
#pragma  libcall WizardBase WZ_LockWindows       054 801
#pragma  libcall WizardBase WZ_UnlockWindows     05A 801
#pragma  libcall WizardBase WZ_GadgetHelp        060 9802
#pragma  libcall WizardBase WZ_GadgetConfig      066 9802
#pragma  libcall WizardBase WZ_MenuHelp          06C 0802
#pragma  libcall WizardBase WZ_MenuConfig        072 0802
#pragma  libcall WizardBase WZ_InitEasyStruct    078 109804
#pragma  libcall WizardBase WZ_SnapShotA         07E 9802
#pragma  libcall WizardBase WZ_GadgetKeyA        084 910804
#pragma  libcall WizardBase WZ_DrawVImageA       08A 96543210809
#pragma  libcall WizardBase WZ_EasyRequestArgs   090 A09804
#pragma  libcall WizardBase WZ_GetNode           096 0802
#pragma  libcall WizardBase WZ_ListCount         09C 801
#pragma  libcall WizardBase WZ_NewObjectA        0A2 80903
#pragma  libcall WizardBase WZ_GadgetHelpMsg     0A8 210A9806
#pragma  libcall WizardBase WZ_ObjectID          0AE 9A803
#pragma  libcall WizardBase WZ_InitNodeA         0B4 90803
#pragma  libcall WizardBase WZ_InitNodeEntryA    0BA 90803
#pragma  libcall WizardBase WZ_CreateImageBitMap 0C0 BA98005
#pragma  libcall WizardBase WZ_DeleteImageBitMap 0C6 BA9804
#pragma  libcall WizardBase WZ_GetDataAddress    0CC 10803
#pragma  libcall WizardBase WZ_GadgetObjectname  0D2 9802
#pragma  libcall WizardBase WZ_MenuObjectname    0D8 0802
#pragma  libcall WizardBase WZ_WindowGadgets     0DE 0802
#pragma  libcall WizardBase WZ_HandleIMessage    0E4 9802
#pragma  libcall WizardBase WZ_ControlBubbleHelpA 0EA 9802
#pragma  libcall WizardBase WZ_WindowObjectname  0F0 0802
#pragma  libcall WizardBase WZ_RequestObjectname 0F6 0802
#pragma  libcall WizardBase WZ_FontObjectname    0FC 0802
#pragma  libcall WizardBase WZ_LibraryObjectname 102 0802
#pragma  libcall WizardBase WZ_ImageObjectname   108 0802
#endif
#ifdef __STORM__
#pragma tagcall(WizardBase,0x01E,WZ_OpenSurface(a0,a1,a2))
#pragma tagcall(WizardBase,0x02A,WZ_AllocWindowHandle(d0,d1,a0,a1))
#pragma tagcall(WizardBase,0x030,WZ_CreateWindowObj(a0,d0,a1))
#pragma tagcall(WizardBase,0x036,WZ_OpenWindow(a0,a1,a2))
#pragma tagcall(WizardBase,0x07E,WZ_SnapShot(a0,a1))
#pragma tagcall(WizardBase,0x084,WZ_GadgetKey(a0,d0,d1,a1))
#pragma tagcall(WizardBase,0x08A,WZ_DrawVImage(a0,d0,d1,d2,d3,d4,d5,d6,a1))
#pragma tagcall(WizardBase,0x090,WZ_EasyRequest(a0,a1,d0,a2))
#pragma tagcall(WizardBase,0x0A2,WZ_NewObject(a1,d0,a0))
#pragma tagcall(WizardBase,0x0B4,WZ_InitNode(a0,d0,a1))
#pragma tagcall(WizardBase,0x0BA,WZ_InitNodeEntry(a0,d0,a1))
#pragma tagcall(WizardBase,0x0EA,WZ_ControlBubbleHelp(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall WizardBase WZ_OpenSurface       01E A9803
#pragma  tagcall WizardBase WZ_AllocWindowHandle 02A 981004
#pragma  tagcall WizardBase WZ_CreateWindowObj   030 90803
#pragma  tagcall WizardBase WZ_OpenWindow        036 A9803
#pragma  tagcall WizardBase WZ_SnapShot          07E 9802
#pragma  tagcall WizardBase WZ_GadgetKey         084 910804
#pragma  tagcall WizardBase WZ_DrawVImage        08A 96543210809
#pragma  tagcall WizardBase WZ_EasyRequest       090 A09804
#pragma  tagcall WizardBase WZ_NewObject         0A2 80903
#pragma  tagcall WizardBase WZ_InitNode          0B4 90803
#pragma  tagcall WizardBase WZ_InitNodeEntry     0BA 90803
#pragma  tagcall WizardBase WZ_ControlBubbleHelp 0EA 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_WIZARD_LIB_H  */
