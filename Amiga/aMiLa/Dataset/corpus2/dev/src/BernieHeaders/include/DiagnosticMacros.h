#ifndef DIAGNOSTICMACROS_H
#define DIAGNOSTICMACROS_H
/*
**	$Id: DiagnosticMacros.h,v 1.2 1999/02/07 14:41:02 bernie Exp $
**
**	Copyright (C) 1999 Bernardo Innocenti <bernardo.innocenti@usa.net>
**	All rights reserved.
**
**	Use 4 chars wide TABs to read this file
**
**	These are some handy macros to dump some common system
**	structures to the debug console. Use DUMP_XXX(pointer)
**	in your code to get a full dump of the structure contents.
**
**	These macros will automatically disable themselves when the
**	preprocessor symbol DEBUG isn't defined.
*/

#ifdef DEBUG

#define DUMP_BITMAP(p)		DumpBitMap(p, #p);
#define DUMP_LAYER(p)		DumpLayer(p, #p);
#define DUMP_GADGETINFO(p)	DumpGadgetInfo (p, #p);

#ifdef INTUITION_CGHOOKS_H
static void DumpGadgetInfo (struct GadgetInfo *p, const char *name)
{
	if (p)
	{
		DBPRINTF ("struct GadgetInfo * %s (at 0x%lx) = {\n", name, p);
		DBPRINTF ("    struct Screen *    gi_Screen    = 0x%lx\n", p->gi_Screen);
		DBPRINTF ("    struct Window *    gi_Window    = 0x%lx\n", p->gi_Window);
		DBPRINTF ("    struct Requester * gi_Requester = 0x%lx\n", p->gi_Requester);

		DBPRINTF ("    struct RastPort *  gi_RastPort  = 0x%lx\n", p->gi_RastPort);
		DBPRINTF ("    struct Layer *     gi_Layer     = 0x%lx\n", p->gi_Layer);
		DBPRINTF ("    struct IBox        gi_Domain    = { %ld, %ld, %ld, %ld }\n",
			p->gi_Domain.Left, p->gi_Domain.Top, p->gi_Domain.Width, p->gi_Domain.Height);
		DBPRINTF ("    UBYTE              gi_Pens      = { %ld, %ld }\n",
			p->gi_Pens.DetailPen, p->gi_Pens.BlockPen);
		DBPRINTF ("    struct DrawInfo *  gi_DrInfo    = 0x%lx\n", p->gi_DrInfo);
	}
	else
		DBPRINTF ("    struct GadgetInfo * %s = NULL\n", name);
}
#endif /* !INTUITION_CGHOOKS_H */

#ifdef GRAPHICS_GFX_H
static void DumpBitMap (struct BitMap *p, const char *name)
{
	if (p)
	{
		DBPRINTF ("struct BitMap * %s (at 0x%lx) = {\n", name, p);
		DBPRINTF ("    UWORD    BytesPerRow = %ld\n", p->BytesPerRow);
		DBPRINTF ("    UWORD    Rows        = %ld\n", p->Rows);
		DBPRINTF ("    UBYTE    Flags       = 0x%lx\n", p->Flags);
		DBPRINTF ("    UBYTE    Depth       = %ld\n", p->Depth);
		DBPRINTF ("    UWORD    pad         = %ld\n", p->pad);
		DBPRINTF ("    PLANEPTR Planes[8]   = { 0x%lx, 0x%lx, 0x%lx, 0x%lx, 0x%lx, 0x%lx, 0x%lx, 0x%lx }\n",
			p->Planes[0], p->Planes[1], p->Planes[2], p->Planes[3],
			p->Planes[4], p->Planes[5], p->Planes[6], p->Planes[7]);
		DBPRINTF ("};\n");
	}
	else
		DBPRINTF ("    struct BitMap * %s = NULL\n", name);
}
#endif /* !GRAPHICS_GFX_H */


#ifdef GRAPHICS_CLIP_H
static void DumpLayer (struct Layer *p, const char *name)
{
	if (p)
	{
		char flags[128];

		flags[0] = '\0';

		if (p->Flags & LAYERSIMPLE)		strcat(flags, "LAYERSIMPLE");
		if (p->Flags & LAYERSMART)		strcat(flags, " | LAYERSMART");
		if (p->Flags & LAYERSUPER)		strcat(flags, " | LAYERSUPER");
		if (p->Flags & 0x0008)			strcat(flags, " | 0x0008");
		if (p->Flags & LAYERUPDATING)	strcat(flags, " | LAYERUPDATING");
		if (p->Flags & 0x0020)			strcat(flags, " | 0x0020");
		if (p->Flags & LAYERBACKDROP)	strcat(flags, " | LAYERBACKDROP");
		if (p->Flags & LAYERREFRESH)	strcat(flags, " | LAYERREFRESH");
		if (p->Flags & LAYER_CLIPRECTS_LOST) strcat(flags, " | LAYER_CLIPRECTS_LOST");
		if (p->Flags & LAYERIREFRESH)	strcat (flags, " | LAYERIREFRESH");
		if (p->Flags & LAYERIREFRESH2)	strcat (flags, " | LAYERIREFRESH2");
		if (p->Flags & 0x0800)			strcat(flags, " | 0x0800");
		if (p->Flags & 0x1000)			strcat(flags, " | 0x1000");
		if (p->Flags & 0x2000)			strcat(flags, " | 0x2000");
		if (p->Flags & 0x4000)			strcat(flags, " | 0x4000");
		if (p->Flags & 0x8000)			strcat(flags, " | 0x8000");


		DBPRINTF ("struct Layer * %s (at 0x%lx) = {\n", name, p);
		DBPRINTF ("    struct Layer *      front         = 0x%lx, back = 0x%lx\n", p->front, p->back);
		DBPRINTF ("    struct ClipRect *   ClipRect      = 0x%lx\n", p->ClipRect);
		DBPRINTF ("    struct RastPort *   rp            = 0x%lx\n", p->rp);
        DBPRINTF ("    struct Rectangle    bounds        = { %ld, %ld, %ld, %ld }\n",
        	p->bounds.MinX, p->bounds.MinY, p->bounds.MaxX, p->bounds.MaxY);
        DBPRINTF ("    UBYTE               reserved[4]   = { %ld, %ld, %ld, %ld }\n",
        	p->reserved[0], p->reserved[1], p->reserved[2], p->reserved[3]);
		DBPRINTF ("    UWORD               priority      = %ld\n", p->priority);
		DBPRINTF ("    UWORD               Flags         = 0x%lx (%s)\n", p->Flags, flags);
		DBPRINTF ("    struct BitMap *     SuperBitMap   = 0x%lx\n", p->SuperBitMap);
		DBPRINTF ("    struct ClipRect *   SuperClipRect = 0x%lx\n", p->SuperClipRect);
		DBPRINTF ("    APTR                Window        = 0x%lx\n", p->Window);
		DBPRINTF ("    UWORD               Scroll_X      = %ld, Scroll_Y = %ld\n", p->Scroll_X, p->Scroll_Y);
		DBPRINTF ("    struct ClipRect *   cr            = 0x%lx, cr2 = 0x%lx, crnew = 0x%lx\n",
			p->cr, p->cr2, p->crnew);
		DBPRINTF ("    struct ClipRect *   SuperSaveClipRects = 0x%lx\n", p->SuperSaveClipRects);
		DBPRINTF ("    struct ClipRect *   _cliprects    = 0x%lx\n", p->_cliprects);
		DBPRINTF ("    struct Layer_Info * LayerInfo     = 0x%lx\n", p->LayerInfo);
		DBPRINTF ("    struct SignalSemaphore Lock = {\n");
		DBPRINTF ("        WORD          ss_NestCount = %ld\n", p->Lock.ss_NestCount);
		DBPRINTF ("        struct Task * ss_Owner     = 0x%lx\n", p->Lock.ss_Owner);
        DBPRINTF ("        ...\n");
		DBPRINTF ("    };\n");
		DBPRINTF ("    struct Hook *       BackFill      = 0x%lx\n", p->BackFill);
		DBPRINTF ("    ULONG               reserved1     = 0x%lx\n", p->reserved1);
		DBPRINTF ("    struct Region *     ClipRegion    = 0x%lx\n", p->ClipRegion);
		DBPRINTF ("    struct Region *     saveClipRects = 0x%lx\n", p->saveClipRects);
		DBPRINTF ("    WORD                Width         = %ld, Height = %ld\n", p->Width, p->Height);
		DBPRINTF ("    UBYTE               reserved2[18] = ...\n");
		DBPRINTF ("    struct Region *     DamageList    = 0x%lx\n", p->DamageList);
		DBPRINTF ("};\n");
	}
	else
		DBPRINTF ("struct Layer * %s = NULL\n", name);
}
#endif /* !GRAPHICS_CLIP_H */




#else /* DEBUG not defined */

#define DUMP_BITMAP(x)
#define DUMP_LAYER(x)
#define DUMP_GADGETINFO(x)

#endif /* !DEBUG */

#endif /* !DIAGNOSTICMACROS_H */
