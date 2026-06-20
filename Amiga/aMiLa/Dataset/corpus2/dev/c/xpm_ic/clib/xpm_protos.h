/* ========================================================================== *
 * $Id$
 * -------------------------------------------------------------------------- *
 * C prototypes for the XPM BOOPSI image class.
 *
 * Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
 * ========================================================================== */

#ifndef CLIB_XPM_PROTOS_H
#define CLIB_XPM_PROTOS_H


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef UTILITY_TAGITEM
#include <utility/tagitem.h>
#endif
#ifndef INTUITION_CLASSES_H
#include <intuition/classes.h>
#endif
#ifndef INTUITION_IMAGECLASS_H
#include <intuition/imageclass.h>
#endif


/* ========================================================================== */


Class *CreateXpmClass (VOID);
BOOL DisposeXpmClass (Class *);


#endif /* CLIB_XPM_PROTOS_H */
