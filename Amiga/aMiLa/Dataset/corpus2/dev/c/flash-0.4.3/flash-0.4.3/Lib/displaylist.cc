////////////////////////////////////////////////////////////
// Flash Plugin and Player
// Copyright (C) 1998,1999 Olivier Debon
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
//  Author : Olivier Debon  <odebon@club-internet.fr>
//  

#include <stdio.h>
#include <assert.h>

static char *rcsid = "$Id: displaylist.cc,v 1.7 1999/02/02 18:45:05 olivier Exp $";

#include "displaylist.h"
#include "graphic.h"
#include "character.h"

#define PRINT 0

DisplayList::DisplayList()
{
	list = 0;
	bg = 0;
}

DisplayList::~DisplayList()
{
	clearList();
}

void
DisplayList::clearList()
{
	DisplayListEntry *del, *e;

	for(e = list; e;)
	{
		del = e;
		e = e->next;
		delete del;
	}
	list = 0;
}

DisplayListEntry *
DisplayList::getList()
{
	return list;
}

void
DisplayList::placeObject(Character *character, long depth, Matrix *matrix, Cxform *cxform)
{
	DisplayListEntry *n,*e,*prev;

	n = new DisplayListEntry;
	n->depth = depth;
	n->matrix = matrix;
	n->cxform = cxform;
	n->character = character;

	if (character == 0 || matrix == 0 || cxform == 0) {
		for (e = list; e; prev = e, e = e->next) {
			if (e->depth == n->depth) {
				if (character == 0) {
					n->character = e->character;
				}
				if (matrix == 0) {
					n->matrix = e->matrix;
				}
				if (cxform == 0) {
					n->cxform = e->cxform;
				}
				break;
			}
		}
	}

	if (n->character == 0) {
		// Not found !!!    Should not happen
		printf("PlaceObject cannot find character at depth %d\n", n->depth);
		delete n;
		return;
	}

	prev = 0;
	for (e = list; e; prev = e, e = e->next)
	{
		if (e->depth == n->depth) {
			// Replace object
			if (prev) {
				prev->next = e->next;
				delete e;
				e = prev->next;
			} else {
				list = e->next;
				delete e;
				e = list;
			}
			if (e) {
				// Should break then
				assert(e->depth > n->depth);
			} else {
				break;
			}
		}
		if (e->depth > n->depth) break;
	}
	if (prev == 0) {
		// Object comes at first place
		n->next = list;
		list = n;
	} else {
		// Insert object
		n->next = prev->next;
		prev->next = n;
	}
}

Character *
DisplayList::removeObject(Character *character, long depth)
{
	DisplayListEntry *e,*prev;

	// List should not be empty
	if (list == 0) return 0;

	prev = 0;
	for (e = list; e; prev = e, e = e->next)
	{
		if (e->depth == depth) {
		 	if (prev) {
				prev->next = e->next;
			} else {
				list = e->next;
			}
			if (character == 0) {
				character = e->character;
			}
			delete e;
			return character;
		}
	}
	return 0;	// Should not happen
}

Character *
DisplayList::removeObject(long depth)
{
	return removeObject((Character *)0,depth);
}

ActionRecord *
DisplayList::processEvent(GraphicDevice *gd, FlashEvent *event)
{
	DisplayListEntry *e;
	ActionRecord	 *action = 0;

	for (e = list; e; e = e->next)
	{
		if (e->character) {
			if (e->character->hasEventHandler()){
				action = e->character->eventHandler(gd, event);
				if (action) {
					break;
				}
			}
		}
	}

	return action;
}

void
DisplayList::setBackgroundColor(Color *color)
{
	bg = color;
}

int
DisplayList::render(GraphicDevice *gd, Matrix *m)
{
	DisplayListEntry *e;
	int sprite = 0;
	long n = 0;

	if (bg) {
		gd->setBackgroundColor(*bg);
		bg = 0;
	}

	for (e = list; e; e = e->next)
	{
#if PRINT
		printf("Character %3d @ %3d\n", e->character ? e->character->getTagId() : 0, e->depth);
#endif
		if (e->character) {
			Matrix mat;

			if (m) {
				mat = *m;
			}

			if (e->matrix) {
				mat = mat * (*e->matrix);
			}

			if (e->character->hasEventHandler()) {
				long hitTestId;

				hitTestId = gd->registerHitTest(e->character->getTagId());
				if (hitTestId) {
					e->character->getRegion(gd, &mat, hitTestId);
				}
			}

			if (e->character->execute(gd, &mat, e->cxform)) {
				sprite = 1;
			}

			n++;
		}
	}
	return sprite;
}
