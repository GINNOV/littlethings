/*
 * Function.c
 *
 * Simple demonstration for "test.library"
 */


#include <exec/libraries.h>
#include <graphics/rastport.h>
#include <graphics/text.h>
#include <intuition/screens.h>
#include <utility/tagitem.h>

#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#include <SDI_compiler.h>

/* We did reserve a slot but we don't assign a function to it */

/* First function available from the outside (LVO -36) */
LIBFUNC LONG Add( REG(d0, LONG a), REG(d1, LONG b))
{
	return a + b;
}


/* LVO -42 */
LIBFUNC LONG Sub( REG(d0, LONG a), REG(d1, LONG b))
{
	return b - a;
}


/* Private function */
static ULONG mystrlen( const UBYTE *s)
{
	const UBYTE *e = s;

	while (*e)
		e ++;

	return e - s;
}

/* We did reserve an additional slot but we don't assign a function to it */

/* LVO -54 */
LIBFUNC struct Screen * CloneWBScr()
{
	struct Screen *scr;
	struct TagItem tags[3];
	ULONG width, height, len, y, x;
	struct TextFont *font;
	static UBYTE scrname[] = "Cloned WB";
	static UBYTE info[] = "Cloned WBench screen!";

	tags[0].ti_Tag = SA_Title;
	tags[0].ti_Data = (ULONG) scrname;
	tags[1].ti_Tag = SA_LikeWorkbench;
	tags[1].ti_Data = TRUE;
	tags[2].ti_Tag = TAG_END;

	scr = OpenScreenTagList( NULL, tags);

	if (scr)
	{
		width = (scr->Width - 1) / 2;
		height = (scr->Height - 1) / 2;
		font = scr->RastPort.Font;

		len = TextLength( &scr->RastPort, info, mystrlen( info));
		y = height - (font->tf_YSize / 2) + font->tf_Baseline;
		x = width - (len / 2);
		SetBPen( &scr->RastPort, 0);
		SetDrMd( &scr->RastPort, JAM2);
		Move( &scr->RastPort, x, y);
		Text( &scr->RastPort, info, mystrlen( info));
	}

	return scr;
}

/* LVO -60 */
LIBFUNC void CloseClonedWBScr( REG(a0, struct Screen *scr))
{
	if (scr)
	{
		while (scr->FirstWindow)
			Delay( 6);

		CloseScreen( scr);
	}
}

LIBFUNC void GetClonedWBScrAttrA( REG(a0, struct Screen *scr), REG(a1, struct TagItem *tags))
{
	ULONG *itemAdr;

	if (scr)
	{
		while (tags->ti_Tag != TAG_DONE)
		{
			if (tags->ti_Tag == SA_Width)
			{
				itemAdr = (ULONG *) tags->ti_Data;	/* Get address of the user's variable */
				*itemAdr = scr->Width;				/* Put value into user's variable */
			}

			if (tags->ti_Tag == SA_Height)
			{
				itemAdr = (ULONG *) tags->ti_Data;
				*itemAdr = scr->Height;
			}

			if (tags->ti_Tag == SA_Depth)
			{
				itemAdr = (ULONG *) tags->ti_Data;
				*itemAdr = GetBitMapAttr( scr->RastPort.BitMap, BMA_DEPTH);
			}

			tags ++;
		}
	}
}
