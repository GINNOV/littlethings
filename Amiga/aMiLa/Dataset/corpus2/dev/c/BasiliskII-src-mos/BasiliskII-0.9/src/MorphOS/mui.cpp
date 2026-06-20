/*
 *  mui.cpp - MUI support functions for MorphOS
 *
 *  Basilisk II (C) 1997-2001 Christian Bauer
 *                  2005 Ilkka Lehtoranta
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#define CATCOMP_ARRAY

#include <libraries/asl.h>

#include <proto/intuition.h>
#include <proto/locale.h>
#include <proto/muimaster.h>

#include "locale/locale.c"
#include "locale/locale.h"
#include "mui.h"

/**********************************************************************
	GetLocaleString
**********************************************************************/

extern struct Catalog *catalog;

CONST_STRPTR GetLocaleString(LONG id)
{
	return GetCatalogStr(catalog, id, CatCompArray[id].cca_Str);
}

/**********************************************************************
	getv
**********************************************************************/

ULONG getv(Object *obj, ULONG attr)
{
	ULONG val;
	GetAttr(attr, obj, &val);
	return val;
}

/**********************************************************************
	MakePopFile
**********************************************************************/

Object *MakePopFile(LONG id, ULONG maxlen, Object **str_obj)
{
	Object *obj, *pop;

	obj = PopaslObject,
		MUIA_Popasl_Type, ASL_FileRequest,
		MUIA_Popstring_Button, pop = PopButton(MUII_PopDrawer),
		MUIA_Popstring_String, *str_obj = MakeString(id, maxlen),
		End;

	if (obj)
	{
		SetAttrs(pop, MUIA_CycleChain, 1, TAG_DONE);
	}

	return obj;
}

/**********************************************************************
	MakeCycle
**********************************************************************/

Object *MakeCycle(LONG id, const CONST_STRPTR *entries)
{
	Object	*obj;

	obj = MUI_MakeObject(MUIO_Cycle, (IPTR)GetLocaleString(id), (ULONG)entries);

	if (obj)
	{
		SetAttrs(obj,
			MUIA_CycleChain, 1,
			TAG_DONE);
	}

	return obj;
}

/**********************************************************************
	MakeRect
**********************************************************************/

Object *MakeRect(ULONG weight)
{
	return RectangleObject, MUIA_Weight, weight, End;
}

/**********************************************************************
	MakeLLabel
**********************************************************************/

static Object *MakeLLabel(LONG id)
{
	Object	*obj;

	obj	= MUI_MakeObject(MUIO_Label, (IPTR)GetLocaleString(id), MUIO_Label_LeftAligned);

	return obj;
}

/**********************************************************************
	MakeCheck
**********************************************************************/

Object *MakeCheck(LONG id, Object **ch_obj)
{
	Object *obj, *ch;

	obj = HGroup,
		Child, ch = MUI_MakeObject(MUIO_Checkmark, (IPTR)GetLocaleString(id)),
		Child, MakeLLabel(id),
		Child, MakeRect(100),
	End;

	if (obj)
	{
		*ch_obj	= ch;
		SetAttrs(ch, MUIA_CycleChain, 1, TAG_DONE);
	}

	return (obj);
}

/**********************************************************************
	MakeInteger
**********************************************************************/

Object *MakeInteger(LONG id, ULONG maxlen)
{
	Object	*obj;

	obj = MUI_MakeObject(MUIO_String, (IPTR)GetLocaleString(id), maxlen);

	if (obj)
	{
		SetAttrs(obj,
			MUIA_CycleChain, 1,
			MUIA_Weight, 25,
			MUIA_String_Accept, (ULONG)"01234567890",
			MUIA_String_Integer, 0,
			TAG_DONE);
	}

	return obj;
}

/**********************************************************************
	MakeString
**********************************************************************/

Object *MakeString(LONG id, ULONG maxlen)
{
	Object	*obj;

	obj = MUI_MakeObject(MUIO_String, (IPTR)GetLocaleString(id), maxlen);

	if (obj)
	{
		SetAttrs(obj, MUIA_CycleChain, 1, TAG_DONE);
	}

	return obj;
}

/**********************************************************************
	MakeLabel
**********************************************************************/

Object *MakeLabel(LONG id)
{
	Object	*obj;

	obj	= MUI_MakeObject(MUIO_Label, (IPTR)GetLocaleString(id), 0);

	return obj;
}

/**********************************************************************
	MakeButton
**********************************************************************/

Object *MakeButton(LONG id)
{
	Object	*obj;

	obj = MUI_MakeObject(MUIO_Button, (IPTR)GetLocaleString(id));

	if (obj)
	{
		SetAttrs(obj, MUIA_CycleChain, 1, TAG_DONE);
	}

	return obj;
}

/**********************************************************************
	MakeSlider
**********************************************************************/

Object *MakeSlider(LONG id, ULONG min, ULONG max)
{
	Object	*obj;

	obj = MUI_MakeObject(MUIO_Slider, (IPTR)GetLocaleString(id), min, max);

	if (obj)
	{
		SetAttrs(obj, MUIA_CycleChain, 1, TAG_DONE);
	}

	return obj;
}
