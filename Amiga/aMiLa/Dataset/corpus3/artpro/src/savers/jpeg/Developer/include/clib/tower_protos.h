#ifndef CLIB_TOWER_PROTOS_H
#define CLIB_TOWER_PROTOS_H
/*
**  $VER: tower_protos.h 0.1 (14.5.94)
**
**  C prototypes. For use with 32 bit integers only.
**
**  Copyright © 1994 Christoph Feck, TowerSystems.
**  All Rights Reserved.
**
**  NOTE:  This file is provided "AS-IS" and subject to change without
**  prior notice; no warranties are made.  All use is at your own risk.
**  No liability or responsibility is assumed.
*/

#ifndef LIBRARIES_TOWER_H
#include <libraries/tower.h>
#endif

APTR NewExtObjectA( ClassID id, struct TagItem *attributes );
APTR NewExtObject( ClassID id, Tag attr1, ... );
VOID DisposeExtObject( APTR object );

#endif /* CLIB_TOWER_PROTOS_H */
