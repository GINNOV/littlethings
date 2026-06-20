#ifndef CLIB_DEPTHMENU_PROTOS_H
#define CLIB_DEPTHMENU_PROTOS_H

/*
**  $VER: depthmenu_protos.h v3 (18.11.2002)
**
**  depthmenu.library prototypes
**
**  (C) Copyright 2001-2002 Arkadiusz [Yak] Wahlig
**      All Rights Reserved.
*/

#ifndef LIBRARIES_DEPTHMENU_H
#include <libraries/depthmenu.h>
#endif

ULONG DM_AddModule(struct DM_Module *dmmodule);
ULONG DM_RemModule(struct DM_Module *dmmodule);
void DM_FreeItems(APTR items);
APTR DM_CreateItemsNewMenuA(struct NewMenu *newmenu, struct TagItem *tags);
APTR DM_CreateItemsNewMenu(struct NewMenu *newmenu, ULONG tag1, ...);

#endif /* CLIB_DEPTHMENU_PROTOS_H */
