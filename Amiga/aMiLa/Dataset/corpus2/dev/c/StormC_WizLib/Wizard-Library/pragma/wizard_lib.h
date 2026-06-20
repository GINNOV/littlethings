#ifndef _INCLUDE_PRAGMA_WIZARD_LIB_H
#define _INCLUDE_PRAGMA_WIZARD_LIB_H

/*
**  $VER: wizard_lib.h 37.0 (14.05.96)
**
**  '(C) Copyright 1996 Haage & Partner Computer GmbH'
**	 All Rights Reserved
*/

#ifndef _INCLUDE_PROTOS_WIZARD_LIB_H
#include <clib/wizard_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#pragma amicall(WizardBase, 0x1E, WZ_OpenSurfaceA(a0,a1,a2))
#pragma tagcall(WizardBase, 0x1E, WZ_OpenSurface(a0,a1,a2))
#pragma amicall(WizardBase, 0x24, WZ_CloseSurface(a0))
#pragma amicall(WizardBase, 0x2A, WZ_AllocWindowHandleA(d0,d1,a0,a1))
#pragma tagcall(WizardBase, 0x2A, WZ_AllocWindowHandle(d0,d1,a0,a1))
#pragma amicall(WizardBase, 0x30, WZ_CreateWindowObjA(a0,d0,a1))
#pragma tagcall(WizardBase, 0x30, WZ_CreateWindowObj(a0,d0,a1))
#pragma amicall(WizardBase, 0x36, WZ_OpenWindowA(a0,a1,a2))
#pragma tagcall(WizardBase, 0x36, WZ_OpenWindow(a0,a1,a2))
#pragma amicall(WizardBase, 0x3C, WZ_CloseWindow(a0))
#pragma amicall(WizardBase, 0x42, WZ_FreeWindowHandle(a0))
#pragma amicall(WizardBase, 0x48, WZ_LockWindow(a0))
#pragma amicall(WizardBase, 0x4E, WZ_UnlockWindow(a0))
#pragma amicall(WizardBase, 0x54, WZ_LockWindows(a0))
#pragma amicall(WizardBase, 0x5A, WZ_UnlockWindows(a0))
#pragma amicall(WizardBase, 0x60, WZ_GadgetHelp(a0,a1))
#pragma amicall(WizardBase, 0x66, WZ_GadgetConfig(a0,a1))
#pragma amicall(WizardBase, 0x6C, WZ_MenuHelp(a0,d0))
#pragma amicall(WizardBase, 0x72, WZ_MenuConfig(a0,d0))
#pragma amicall(WizardBase, 0x78, WZ_InitEasyStruct(a0,a1,d0,d1))
#pragma amicall(WizardBase, 0x7E, WZ_SnapShotA(a0,a1))
#pragma tagcall(WizardBase, 0x7E, WZ_SnapShot(a0,a1))
#pragma amicall(WizardBase, 0x84, WZ_GadgetKeyA(a0,d0,d1,a1))
#pragma tagcall(WizardBase, 0x84, WZ_GadgetKey(a0,d0,d1,a1))
#pragma amicall(WizardBase, 0x8A, WZ_DrawVImageA(a0,d0,d1,d2,d3,d4,d5,d6,a1))
#pragma tagcall(WizardBase, 0x8A, WZ_DrawVImage(a0,d0,d1,d2,d3,d4,d5,d6,a1))
#pragma amicall(WizardBase, 0x90, WZ_EasyRequestArgs(a0,a1,d0,a2))
#pragma amicall(WizardBase, 0x96, WZ_GetNode(a0,d0))
#pragma amicall(WizardBase, 0x9C, WZ_ListCount(a0))
#pragma amicall(WizardBase, 0xA2, WZ_NewObjectA(a1,d0,a0))
#pragma tagcall(WizardBase, 0xA2, WZ_NewObject(a1,d0,a0))
#pragma amicall(WizardBase, 0xA8, WZ_GadgetHelpMsg(a0,a1,a2,d0,d1,d2))
#pragma amicall(WizardBase, 0xAE, WZ_ObjectID(a0,a2,a1))
#pragma amicall(WizardBase, 0xB4, WZ_InitNodeA(a0,d0,a1))
#pragma tagcall(WizardBase, 0xB4, WZ_InitNode(a0,d0,a1))
#pragma amicall(WizardBase, 0xBA, WZ_InitNodeEntryA(a0,d0,a1))
#pragma tagcall(WizardBase, 0xBA, WZ_InitNodeEntry(a0,d0,a1))
#pragma amicall(WizardBase, 0xC0, WZ_CreateImageBitMap(d0,a0,a1,a2,a3))
#pragma amicall(WizardBase, 0xC6, WZ_DeleteImageBitMap(a0,a1,a2,a3))
#pragma amicall(WizardBase, 0xCC, WZ_GetDataAddress(a0,d0,d1))
#pragma amicall(WizardBase, 0xD2, WZ_GadgetObjectname(a0,a1))
#pragma amicall(WizardBase, 0xD8, WZ_MenuObjectname(a0,d0))

#ifdef __cplusplus
}
#endif

#endif
