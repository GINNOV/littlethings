/* ========================================================================== *
 * $Id$
 * -------------------------------------------------------------------------- *
 * Interface to methods for the XPM BOOPSI image class.
 *
 * Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
 * ========================================================================== */

#ifndef XPMMETHODS_H
#define XPMMETHODS_H


#include <xpm.h>

#include <exec/types.h>
#include <intuition/classes.h>
#include <intuition/imageclass.h>


/* ========================================================================== */


typedef struct XpmClassData
{
    XImage         *image, *scale_image;
    XImage         *mask, *scale_mask;
    XpmAttributes   attributes;
    UBYTE           flags;
} XpmClassData;

#define CACHESCALE   (1 << 0)


/* ========================================================================== */


extern BOOL
XpmMethodNew (
    Class         *cl,
    struct Image  *obj,
    struct opSet  *msg);


extern void
XpmMethodDispose (
    Class   *cl,
    Object  *obj,
    Msg      msg);


extern void
XpmMethodSet (
    Class         *cl,
    struct Image  *obj,
    struct opSet  *msg);


extern BOOL
XpmMethodGet (
    Class         *cl,
    Object        *obj,
    struct opGet  *msg);


extern void
XpmMethodDraw (
    Class           *cl,
    struct Image    *obj,
    struct impDraw  *msg);


extern BOOL
XpmMethodHitFrame (
    Class              *cl,
    struct Image       *obj,
    struct impHitTest  *msg);


extern void
XpmMethodEraseFrame (
    Class            *cl,
    struct Image     *obj,
    struct impErase  *msg);


#endif   /* XPMMETHODS_H */
