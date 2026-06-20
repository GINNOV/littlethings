#ifndef PRAGMAS_EASYGADGETS_PRAGMAS_H
#define PRAGMAS_EASYGADGETS_PRAGMAS_H

#ifndef CLIB_EASYGADGETS_PROTOS_H
#include <clib/easygadgets_protos.h>
#endif

#ifdef PRAGMAS_DECLARING_LIBBASE
extern struct Library *EasyGadgetsBase;
#endif

#pragma libcall EasyGadgetsBase egIsMenuItemChecked 1e 0802
#pragma libcall EasyGadgetsBase egSetMenuBitA 24 109804
#pragma libcall EasyGadgetsBase egTextWidth 2a 9802
#pragma libcall EasyGadgetsBase egMaxLenA 30 8902
#pragma libcall EasyGadgetsBase egSpreadGadgets 36 32109806
#pragma libcall EasyGadgetsBase egRequestA 3c BCA9805
#pragma libcall EasyGadgetsBase egDisplayAlert 42 18003
#pragma libcall EasyGadgetsBase egCloseWindowSafely 48 801
#pragma libcall EasyGadgetsBase egCloseTask 4e 801
#pragma libcall EasyGadgetsBase egTaskToFront 54 801
#pragma libcall EasyGadgetsBase egRenderGadgets 5a 801
#pragma libcall EasyGadgetsBase egFreeGList 60 801
#pragma libcall EasyGadgetsBase egCreateGadgetA 66 8902
#pragma libcall EasyGadgetsBase egAllocEasyGadgetsA 6c 801
#pragma libcall EasyGadgetsBase egFreeEasyGadgets 72 801
#pragma libcall EasyGadgetsBase egCountVisitors 78 801
#pragma libcall EasyGadgetsBase egGetMsg 7e 801
#pragma libcall EasyGadgetsBase egLinkTasksA 84 8902
#pragma libcall EasyGadgetsBase egSetGadgetAttrsA 8a BA9804
#pragma libcall EasyGadgetsBase egCreateContext 90 9802
#pragma libcall EasyGadgetsBase egShowAmigaGuide 96 9802
#pragma libcall EasyGadgetsBase egCloseAmigaGuide 9c 801
#pragma libcall EasyGadgetsBase egWait a2 0802
#pragma libcall EasyGadgetsBase egSetGadgetState a8 09803
#pragma libcall EasyGadgetsBase egHandleAmigaGuide ae 801
#pragma libcall EasyGadgetsBase egHandleListviewArrows b4 A8903
#pragma libcall EasyGadgetsBase egConvertRawKey ba 801
#pragma libcall EasyGadgetsBase egCreateMenuA c0 801
#pragma libcall EasyGadgetsBase egFindVanillaKey c6 801
#pragma libcall EasyGadgetsBase egGetNode cc 0802
#pragma libcall EasyGadgetsBase egGetGadgetAttrsA d2 BA9804
#pragma libcall EasyGadgetsBase egCountList d8 801
#pragma libcall EasyGadgetsBase egOpenTaskA de 8902
#pragma libcall EasyGadgetsBase egIsDisplay e4 0802
#pragma libcall EasyGadgetsBase egLockTaskA ea 9802
#pragma libcall EasyGadgetsBase egUnlockTaskA f0 9802
#pragma libcall EasyGadgetsBase egGhostRect f6 43210806
#pragma libcall EasyGadgetsBase egMakeHelpMenu fc 9802
#pragma libcall EasyGadgetsBase egIconify 102 0802
#pragma libcall EasyGadgetsBase egFindMenuItem 108 0802
#pragma libcall EasyGadgetsBase egResetAllTasks 10e 801
#pragma libcall EasyGadgetsBase egInitialize 114 A9803
#pragma libcall EasyGadgetsBase egLockAllTasks 11a 801
#pragma libcall EasyGadgetsBase egUnlockAllTasks 120 801
#pragma libcall EasyGadgetsBase egOpenAllTasks 126 801
#pragma libcall EasyGadgetsBase egCloseAllTasks 12c 801

#ifdef __SASC_60
#pragma tagcall EasyGadgetsBase egSetMenuBit 24 109804
#pragma tagcall EasyGadgetsBase egMaxLen 30 8902
#pragma tagcall EasyGadgetsBase egRequest 3c BCA9805
#pragma tagcall EasyGadgetsBase egCreateGadget 66 8902
#pragma tagcall EasyGadgetsBase egAllocEasyGadgets 6c 801
#pragma tagcall EasyGadgetsBase egLinkTasks 84 8902
#pragma tagcall EasyGadgetsBase egSetGadgetAttrs 8a BA9804
#pragma tagcall EasyGadgetsBase egCreateMenu c0 801
#pragma tagcall EasyGadgetsBase egGetGadgetAttrs d2 BA9804
#pragma tagcall EasyGadgetsBase egOpenTask de 8902
#pragma tagcall EasyGadgetsBase egLockTask ea 9802
#pragma tagcall EasyGadgetsBase egUnlockTask f0 9802
#endif	/*  __SASC_60  */

#endif	/*  PRAGMAS_EASYGADGETS_PRAGMAS_H  */
