#ifndef CLASSDATA_H
#define CLASSDATA_H

/*****************************************************************************/

#include <exec/types.h>
#include <graphics/gfx.h>
#include <graphics/rastport.h>
#include <intuition/screens.h>
#include <intuition/intuition.h>

#include "classbase.h"

/*****************************************************************************/

struct objectData
{
	struct DrawInfo	*od_DrawInfo;
	struct IBox		od_ImageBox;
	LONG			od_BGPen;
	LONG			od_FGPen;
	LONG			od_FillPen;
	
	/* -- attributes of our object -- */
	WORD			od_Value;
	ULONG			od_Flags;
	
	/* -- some sizes of text drawed -- */
	struct IBox		od_LabelLeftBox;
	struct IBox		od_LabelRightBox;
	struct IBox		od_LabelInsideBox;
	
	STRPTR			od_LabelLeftText;
	STRPTR			od_LabelRightText;
	
	/* -- sizes of graphics drawed -- */
	WORD			od_SpaceX;
	WORD			od_SpaceY;
	struct IBox		od_FillBox;
	
	/* -- objects used -- */
	Object			*od_FrameAround;
	Object			*od_FrameInside;
	
	/* -- properties of objects used -- */
	struct IBox		od_AroundBox;
	struct IBox		od_frameAroundBox;	/* FrameAround has to frame this box */
	struct IBox		od_InsideBox;
	struct IBox		od_frameInsideBox;
};

/*****************************************************************************/

enum {
	ODB_FRAMEAROUND = 0,
	ODB_FRAMEINSIDE,
	ODB_LABELLEFT,
	ODB_LABELRIGHT,
	ODB_LABELINSIDE,
	ODB_SIZEREFRESH
};

#define ODF_FRAMEAROUND		(1UL << ODB_FRAMEAROUND)
#define ODF_FRAMEINSIDE		(1UL << ODB_FRAMEINSIDE)
#define ODF_LABELLEFT		(1UL << ODB_LABELLEFT)
#define ODF_LABELRIGHT		(1UL << ODB_LABELRIGHT)
#define ODF_LABELINSIDE		(1UL << ODB_LABELINSIDE)
#define ODF_SIZEREFRESH		(1UL << ODB_SIZEREFRESH)

/*****************************************************************************/

LONG ASM ClassDispatcher (REG(a0) Class *cl, REG(a1) ULONG *msg, REG(a2) struct Image *im);

/*****************************************************************************/

#endif /* CLASSDATA_H */
