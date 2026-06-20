/////////////////////////////////////////////////////////////
// Flash Plugin and Player
// Copyright (C) 1998 Olivier Debon
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// 
///////////////////////////////////////////////////////////////
#ifndef _DISPLAYLIST_H_
#define _DISPLAYLIST_H_

#include "graphic.h"

class Character;

// Display List management
struct DisplayListEntry {
	Character		*character;
	long			 depth;
	Matrix			*matrix;
	Cxform			*cxform;

	DisplayListEntry	*next;
};

class DisplayList {
	DisplayListEntry	*list;
	Color			*bg;

public:
	DisplayList();
	~DisplayList();
	DisplayListEntry	*getList();
	void			 clearList();
	void			 placeObject(Character *character, long depth, Matrix *matrix = 0, Cxform *cxform = 0);
	Character		*removeObject(Character *character, long depth);
	Character		*removeObject(long depth);

	ActionRecord		*processEvent(GraphicDevice *gd, FlashEvent *event);
	int			 render(GraphicDevice *gd, Matrix *m = 0);
	void			 setBackgroundColor(Color *color);
};

#endif /* _DISPLAYLIST_H_ */
