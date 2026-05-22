/* ========================================================================== *
 * $Id$
 * -------------------------------------------------------------------------- *
 * Methods for the XPM BOOPSI image class.
 *
 * Copyright © 1996 Lorens Younes (d93-hyo@nada.kth.se)
 * ========================================================================== */


#include "methods.h"

#include <images/xpm.h>

#include <graphics/scale.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/utility.h>


/* ========================================================================== */


#define IMAGESOURCE    0
#define FILESOURCE     1
#define DATASOURCE     2
#define BUFFERSOURCE   3


typedef struct BestPenArgs
{
    ULONG   precision;
    BOOL    fail_if_bad;
} BestPenArgs;


/* ========================================================================== */


static int
AllocColorWithPrecision (
    Display      *display,   /* not used */
    Colormap      colormap,
    char         *colorname,
    XColor       *xcolor,
    BestPenArgs  *args)
{
    if (colorname != NULL)
    {
	if (!ParseColor (colorname, xcolor))
	    return -1;
    }

    return AllocBestPen (colormap, xcolor, args->precision, args->fail_if_bad);
}


static XImage *
ScaleXImage (
    XImage  *img,
    UWORD    width,
    UWORD    height)
{
    XImage               *scale_img;
    struct BitScaleArgs   bsa;

    if (img == NULL)
	return NULL;

    if (img->width == width && img->height == height)
	return img;

    scale_img = AllocXImage (width, height, img->rp->BitMap->Depth);
    if (scale_img == NULL)
	return img;

    bsa.bsa_SrcX = 0;
    bsa.bsa_SrcY = 0;
    bsa.bsa_DestX = 0;
    bsa.bsa_DestY = 0;
    bsa.bsa_Flags = 0;
    bsa.bsa_XSrcFactor = bsa.bsa_SrcWidth = img->width;
    bsa.bsa_YSrcFactor = bsa.bsa_SrcHeight = img->height;
    bsa.bsa_SrcBitMap = img->rp->BitMap;
    bsa.bsa_XDestFactor = bsa.bsa_DestWidth = scale_img->width;
    bsa.bsa_YDestFactor = bsa.bsa_DestHeight = scale_img->height;
    bsa.bsa_DestBitMap = scale_img->rp->BitMap;
    BitMapScale (&bsa);

    return scale_img;
}


/* ========================================================================== */


BOOL
XpmMethodNew (
    Class         *cl,
    struct Image  *obj,
    struct opSet  *msg)
{
    XpmClassData    *data = INST_DATA (cl, obj);
    struct TagItem  *ti, *tstate = msg->ops_AttrList;
    void            *source = NULL;
    UBYTE            source_type;
    BestPenArgs      bpa;
    BOOL             explicit_size = FALSE;
    int              status;

    data->image = data->mask = NULL;
    data->attributes.valuemask = 0;
    data->attributes.colorsymbols = NULL;
    data->attributes.numsymbols = 0;
    data->flags = 0;

    bpa.precision = PRECISION_IMAGE;
    bpa.fail_if_bad = FALSE;

    while (ti = NextTagItem (&tstate))
    {
	switch (ti->ti_Tag)
	{
	case IA_Width:
	case IA_Height:
	    explicit_size = TRUE;
	    break;
	case XPM_Screen:
	    if (ti->ti_Data != NULL)
	    {
		data->attributes.colormap =
		    ((struct Screen *)ti->ti_Data)->ViewPort.ColorMap;
		data->attributes.depth =
		    ((struct Screen *)ti->ti_Data)->RastPort.BitMap->Depth;
		data->attributes.valuemask |= XpmColormap | XpmDepth;
	    }
	    break;
	case XPM_ColorMap:
	    if (ti->ti_Data != NULL)
	    {
		UWORD   count;

		data->attributes.colormap = (struct ColorMap *)ti->ti_Data;
		data->attributes.depth = 1;
		count = 2;
		while (count < data->attributes.colormap->Count)
		{
		    data->attributes.depth++;
		    count <<= 1;
		}
		data->attributes.valuemask |= XpmColormap | XpmDepth;
	    }
	    break;
	case XPM_XpmImage:
	    if (ti->ti_Data != NULL)
	    {
		source = (XpmImage *)ti->ti_Data;
		source_type = IMAGESOURCE;
	    }
	    break;
	case XPM_XpmFile:
	    if (ti->ti_Data != NULL)
	    {
		source = (char *)ti->ti_Data;
		source_type = FILESOURCE;
	    }
	    break;
	case XPM_XpmData:
	    if (ti->ti_Data != NULL)
	    {
		source = (char **)ti->ti_Data;
		source_type = DATASOURCE;
	    }
	    break;
	case XPM_XpmBuffer:
	    if (ti->ti_Data != NULL)
	    {
		source = (char *)ti->ti_Data;
		source_type = BUFFERSOURCE;
	    }
	    break;
	case XPM_XpmColorSymbols:
	    data->attributes.colorsymbols = (XpmColorSymbol *)ti->ti_Data;
	    break;
	case XPM_NumXpmColorSymbols:
	    data->attributes.numsymbols = (ULONG)ti->ti_Data;
	    break;
	case XPM_Precision:
	    bpa.precision = (ULONG)ti->ti_Data;
	    break;
	case XPM_FailIfBad:
	    bpa.fail_if_bad = (BOOL)ti->ti_Data;
	    break;
	case XPM_CacheScale:
	    if ((BOOL)ti->ti_Data)
		data->flags |= CACHESCALE;
	    else
		data->flags &= ~CACHESCALE;
	    break;
	}
    }

    if (source == NULL || data->attributes.colormap == NULL)
	return FALSE;

    if (data->attributes.colorsymbols != NULL &&
	data->attributes.numsymbols > 0)
    {
	data->attributes.valuemask |= XpmColorSymbols;
    }

    data->attributes.valuemask |= XpmAllocColor | XpmColorClosure;
    data->attributes.alloc_color = AllocColorWithPrecision;
    data->attributes.color_closure = &bpa;

    data->attributes.valuemask |= XpmReturnAllocPixels;

    switch (source_type)
    {
    case IMAGESOURCE:
	status = XpmCreateImageFromXpmImage (NULL, (XpmImage *)source,
					     &data->image, &data->mask,
					     &data->attributes);
	break;
    case FILESOURCE:
	status = XpmReadFileToImage (NULL, (char *)source,
				     &data->image, &data->mask,
				     &data->attributes);
	break;
    case DATASOURCE:
	status = XpmCreateImageFromData (NULL, (char **)source,
					 &data->image, &data->mask,
					 &data->attributes);
	break;
    case BUFFERSOURCE:
	status = XpmCreateImageFromBuffer (NULL, (char *)source,
					   &data->image, &data->mask,
					   &data->attributes);
	break;
    }
    data->scale_image = data->image;
    data->scale_mask = data->mask;
    if (status != XpmSuccess)
	return FALSE;

    if (explicit_size && (data->flags | CACHESCALE))
    {
	data->scale_image = ScaleXImage (data->image, obj->Width, obj->Height);
	data->scale_mask = ScaleXImage (data->mask, obj->Width, obj->Height);
    }
    else
    {
	obj->Width = data->image->width;
	obj->Height = data->image->height;
    }

    return TRUE;
}


void
XpmMethodDispose (
    Class   *cl,
    Object  *obj,
    Msg      msg)
{
    XpmClassData  *data = INST_DATA (cl, obj);

    if (data->image != NULL)
    {
	if (data->scale_image != data->image)
	    FreeXImage (data->scale_image);
	FreeXImage (data->image);
    }

    if (data->mask != NULL)
    {
	if (data->scale_mask != data->mask)
	    FreeXImage (data->scale_mask);
	FreeXImage (data->mask);
    }

    if (data->attributes.valuemask | XpmReturnAllocPixels)
    {
	FreePens (data->attributes.colormap,
	          data->attributes.alloc_pixels,
	          data->attributes.nalloc_pixels);
    }
    XpmFreeAttributes (&data->attributes);
}


void
XpmMethodSet (
    Class         *cl,
    struct Image  *obj,
    struct opSet  *msg)
{
    XpmClassData    *data = INST_DATA (cl, obj);
    struct TagItem  *ti, *tstate = msg->ops_AttrList;
    BOOL             new_size = FALSE;

    while (ti = NextTagItem (&tstate))
    {
	switch (ti->ti_Tag)
	{
	case IA_Width:
	    new_size = new_size || data->scale_image->width != obj->Width;
	    break;
	case IA_Height:
	    new_size = new_size || data->scale_image->height != obj->Height;
	    break;
	case XPM_CacheScale:
	    if ((BOOL)ti->ti_Data)
	    {
		if (!(data->flags | CACHESCALE))
		{
		    data->flags |= CACHESCALE;
		    new_size = TRUE;
		}
	    }
	    else if (data->flags | CACHESCALE)
	    {
		data->flags &= ~CACHESCALE;
		if (data->scale_image != data->image)
		{
		    FreeXImage (data->scale_image);
		    data->scale_image = data->image;
		}
		if (data->scale_mask != data->mask)
		{
		    FreeXImage (data->scale_mask);
		    data->scale_mask = data->mask;
		}
	    }
	    break;
	}
    }

    if (new_size)
    {
	if (data->scale_image != data->image)
	    FreeXImage (data->scale_image);
	if (data->scale_mask != data->mask)
	    FreeXImage (data->scale_mask);

	data->scale_image = ScaleXImage (data->image, obj->Width, obj->Height);
	data->scale_mask = ScaleXImage (data->mask, obj->Width, obj->Height);
    }
}


BOOL
XpmMethodGet (
    Class         *cl,
    Object        *obj,
    struct opGet  *msg)
{
    XpmClassData  *data = INST_DATA (cl, obj);

    switch (msg->opg_AttrID)
    {
    case XPM_ColorMap:
	*msg->opg_Storage = (ULONG)data->attributes.colormap;
	break;
    case XPM_XpmColorSymbols:
	*msg->opg_Storage = (ULONG)data->attributes.colorsymbols;
	break;
    case XPM_NumXpmColorSymbols:
	*msg->opg_Storage = (ULONG)data->attributes.numsymbols;
	break;
    case XPM_CacheScale:
	*msg->opg_Storage = (data->flags | CACHESCALE);
	break;
    default:
	return FALSE;
    }

    return TRUE;
}


void
XpmMethodDraw (
    Class           *cl,
    struct Image    *obj,
    struct impDraw  *msg)
{
    XpmClassData  *data = INST_DATA (cl, obj);
    WORD           left, top;
    WORD           width, height;
    XImage        *out_img;
    XImage        *out_mask;

    left = msg->imp_Offset.X + obj->LeftEdge;
    top = msg->imp_Offset.Y + obj->TopEdge;
    if (msg->MethodID == IM_DRAW)
    {
	width = obj->Width;
	height = obj->Height;
    }
    else
    {
	width = msg->imp_Dimensions.Width;
	height = msg->imp_Dimensions.Height;
    }

    out_img = ScaleXImage (data->scale_image, width, height);
    out_mask = ScaleXImage (data->scale_mask, width, height);

    if (out_mask == NULL)
    {
	BltBitMapRastPort (out_img->rp->BitMap, 0, 0,
			   msg->imp_RPort, left, top, width, height, 0xC0);
    }
    else
    {
	BltMaskBitMapRastPort (out_img->rp->BitMap, 0, 0,
			       msg->imp_RPort, left, top, width, height, 0xE0,
			       out_mask->rp->BitMap->Planes[0]);
    }
    WaitBlit ();

    if (out_img != data->scale_image)
	FreeXImage (out_img);
    if (out_mask != data->scale_mask)
	FreeXImage (out_mask);
}


BOOL
XpmMethodHitFrame (
    Class              *cl,
    struct Image       *obj,
    struct impHitTest  *msg)
{
    return (BOOL)(msg->imp_Point.X >= obj->LeftEdge &&
		  msg->imp_Point.X >= obj->TopEdge &&
		  msg->imp_Point.X < obj->LeftEdge + msg->imp_Dimensions.Width &&
		  msg->imp_Point.Y < obj->TopEdge + msg->imp_Dimensions.Height);
}


void
XpmMethodEraseFrame (
    Class            *cl,
    struct Image     *obj,
    struct impErase  *msg)
{
    WORD   left, top;

    left = obj->LeftEdge + msg->imp_Offset.X;
    top = obj->TopEdge + msg->imp_Offset.Y;
    EraseRect (msg->imp_RPort, left, top,
	       left + msg->imp_Dimensions.Width - 1,
	       left + msg->imp_Dimensions.Height - 1);
}
