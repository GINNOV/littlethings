/* ========================================================================== *
 * $Id$
 * -------------------------------------------------------------------------- *
 * The XPM BOOPSI image class.
 *
 * Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
 * ========================================================================== */

#ifndef IMAGES_XPM_H
#define IMAGES_XPM_H


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif
#ifndef INTUITION_IMAGECLASS_H
#include <intuition/imageclass.h>
#endif


/* ========================================================================== */


/*
 * Additional attributes defined by the XPM BOOPSI image class.
 */

#define XPM_Dummy                (TAG_USER + 0)

#define XPM_Screen               (XPM_Dummy + 1)
        /* (struct Screen *) Screen to use image on. */

#define XPM_ColorMap             (XPM_Dummy + 2)
        /* (struct ColorMap *) Colormap to remap image. */

#define XPM_XpmImage             (XPM_Dummy + 3)
        /* Private! */

#define XPM_XpmFile              (XPM_Dummy + 4)
        /* (STRPTR) Name of XPM image file. */

#define XPM_XpmData              (XPM_Dummy + 5)
        /* (STRPTR *) Pointer to XPM data. */

#define XPM_XpmBuffer            (XPM_Dummy + 6)
        /* (STRPTR) Pointer to XPM buffer. */

#define XPM_XpmColorSymbols      (XPM_Dummy + 7)
        /* Private! */

#define XPM_NumXpmColorSymbols   (XPM_Dummy + 8)
        /* Private! */

#define XPM_Precision            (XPM_Dummy + 9)
        /* (ULONG) Precision for obtaining pens. */

#define XPM_FailIfBad            (XPM_Dummy + 10)
        /* (BOOL) Fail if obtained pens not within precision? */

#define XPM_CacheScale           (XPM_Dummy + 11)
        /* (BOOL) Chace scaled image? */


#endif   /* IMAGES_XPM_H */
