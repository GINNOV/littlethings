/*
**	$Id:$
**
**	Copyright (C) 1999 Bernardo Innocenti
**	All rights reserved.
**
**	Use 4 chars wide TABs to read this file
**
**	Prototypes for the GetGadgetBox() and GetGadgetBounds() helpers
*/

#ifndef INTUITION_CGHOOKS_H
#include <intuition/cghooks.h>
#endif

#ifndef INTUITION_IMAGECLASS_H
#include <intuition/imageclass.h>
#endif


/* Supported class flavours:
 *
 * FLAVOUR_CLASSLIB
 *	Build a class library if this option is set or
 *	a static linker object otherwise.
 *
 * FLAVOUR_PUBCLASS
 *	Call AddClass() to show this class globally if set,
 *	make a private class otherwise.
 */
#define FLAVOUR_CLASSLIB	(1<<0)
#define FLAVOUR_PUBCLASS	(1<<1)



/* Useful functions to compute the actual size of a gadget, regardless
 * of its relativity flags
 */
void GetGadgetBox(struct GadgetInfo *ginfo, struct ExtGadget *g, struct IBox *box);
void GetGadgetBounds(struct GadgetInfo *ginfo, struct ExtGadget *g, struct IBox *bounds);


/* Convert a struct IBox to a struct Rectangle
 */
INLINE void IBoxToRect(struct IBox *box, struct Rectangle *rect)
{
	ASSERT_VALID_PTR(box)
	ASSERT_VALID_PTR(rect)

	rect->MinX = box->Left;
	rect->MinY = box->Top;
	rect->MaxX = box->Left + box->Width - 1;
	rect->MaxY = box->Top + box->Height - 1;
}


/* Tell if a gadget has a boopsi frame
 */
INLINE BOOL GadgetHasFrame(struct Gadget *g)
{
	return (BOOL)(
		g->GadgetRender &&
		(g->Flags & GFLG_GADGIMAGE) &&
		(((struct Image *)g->GadgetRender)->Depth == CUSTOMIMAGEDEPTH));
}


/* Some layers magic adapded from "MUI.undoc",
 * by Alessandro Zummo <azummo@ita.flashnet.it>
 */

/* This macro evalutates to true when the layer is
 * covered by another layer
 */
#define LayerCovered(l)									\
	((!(l)->ClipRect) ||								\
	((l)->bounds.MinX != (l)->ClipRect->bounds.MinX) ||	\
	((l)->bounds.MinY != (l)->ClipRect->bounds.MinY) ||	\
	((l)->bounds.MaxX != (l)->ClipRect->bounds.MaxX) ||	\
	((l)->bounds.MaxY != (l)->ClipRect->bounds.MaxY))

/* memcmp(&(l)->ClipRect->bounds, &(l)->bounds, sizeof (struct Rectangle))) */

/* This macro evalutates to true if the layer has damage regions */
#define LayerDamaged(l) \
	((l)->DamageList && (l)->DamageList->RegionRectangle)

/* This macro checks if ScrollRaster() needs to be called to
 * scroll the layer damage after a scrolling operation.
 */
#define NeedZeroScrollRaster(l) \
	(((l)->Flags & LAYERSIMPLE) && (LayerCovered(l) || LayerDamaged(l)))
