#ifndef LIBRARIES_TOWER_H
#define LIBRARIES_TOWER_H
/*
**  $VER: tower.h 0.9 (27.7.94)
**
**  Interface definitions for tower.library.
**
**  Copyright © 1993,1994 Christoph Feck, TowerSystems.
**  All Rights Reserved.
**
**  NOTE:  This file is provided "AS-IS" and subject to change without
**  prior notice; no warranties are made.  All use is at your own risk.
**  No liability or responsibility is assumed.
*/

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#ifndef	UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef INTUITION_CLASSES_H
#include <intuition/classes.h>
#endif

/*****************************************************************************/

#define TOWERLIBRARY		"tower.library"

/*****************************************************************************/

#define TA_Dummy		(TAG_USER + 0x00070000L)
#define TM_Dummy		(0x00070000L)

/*****************************************************************************/

#endif /* LIBRARIES_TOWER_H */
