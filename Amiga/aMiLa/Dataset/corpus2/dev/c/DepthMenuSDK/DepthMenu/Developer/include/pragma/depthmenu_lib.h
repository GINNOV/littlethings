#ifndef PRAGMAS_DEPTHMENU_PRAGMAS_H
#define PRAGMAS_DEPTHMENU_PRAGMAS_H

/*
**  $VER: depthmenu_lib.h v3 (18.11.2002)
**
**  depthmenu.library pragmas
**
**  (C) Copyright 2001-2002 Arkadiusz [Yak] Wahlig
**      All Rights Reserved.
*/

#pragma amicall(DepthMenuBase,0x1e,DM_AddModule(a0))
#pragma amicall(DepthMenuBase,0x24,DM_RemModule(a0))
#pragma amicall(DepthMenuBase,0x2a,DM_FreeItems(a0))
#pragma amicall(DepthMenuBase,0x30,DM_CreateItemsNewMenuA(a0,a1))
#pragma tagcall(DepthMenuBase,0x30,DM_CreateItemsNewMenu(a0,a1))

#endif /* PRAGMAS_DEPTHMENU_PRAGMAS_H */
