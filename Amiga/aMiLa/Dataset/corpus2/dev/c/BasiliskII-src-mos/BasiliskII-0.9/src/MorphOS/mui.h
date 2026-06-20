/*
 *  mui.h - MorphOS MUI support functions
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

#ifndef MUI_MORPHOS_H
#define MUI_MORPHOS_H

#define CATCOMP_NUMBERS
#include "locale/locale.h"

// Methods and tags

#define MM_Application_About	(0xad00e000 + 0)
#define MM_Display_Update		(0xad00e000 + 0)

typedef enum
{
	DRAW_CLASSIC = 0,
	DRAW_LUT_8BIT,
	DRAW_PIXELARRAY,
	DRAW_CHUNKYPIX
} DRAWMODE;

struct Display_Data
{
	UWORD				null_pointer[6];
	UWORD				*current_pointer;
	DRAWMODE			drawmode;
	ULONG				width, height, frameskip, bytes_per_row;
	APTR				pixelarray, VLayer;
	Object			*parent;

	struct MsgPort						*timerport;
	struct timerequest				*timer_io;
	struct MUI_InputHandlerNode	ihnode;
	struct MUI_EventHandlerNode	ehnode;
	ULONG									timer_ok;
	ULONG									pix_array_size;
};


#define	MUIA_Application_UsedClasses	0x8042e9a7	/* V20 STRPTR *	i..	*/
#define	MUIA_Dtpic_Name 0x80423d72
#define	MUIA_Window_DisableKeys 0x80424c36 /* V15 isg ULONG */ /* private */

CONST_STRPTR GetLocaleString(LONG id);
ULONG		getv			(Object *obj, ULONG attr);
Object *	MakePopFile	(LONG id, ULONG maxlen, Object **str_obj);
Object *	MakeCycle	(LONG id, const CONST_STRPTR *entries);
Object *	MakeRect		(ULONG weight);
Object *	MakeCheck	(LONG id, Object **ch_obj);
Object *	MakeInteger	(LONG id, ULONG maxlen);
Object *	MakeString	(LONG id, ULONG maxlen);
Object *	MakeLabel	(LONG id);
Object *	MakeButton	(LONG id);
Object *	MakeSlider	(LONG id, ULONG min, ULONG max);

#define _L(id) GetLocaleString(id)

#endif /* MUI_MORPHOS_H */