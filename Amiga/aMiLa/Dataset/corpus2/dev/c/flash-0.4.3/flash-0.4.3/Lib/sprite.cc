/////////////////////////////////////////////////////////////
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
#include "sprite.h"

static char *rcsid = "$Id: sprite.cc,v 1.7 1999/01/31 20:24:58 olivier Exp $";

Sprite::Sprite(long id, long frameCount) : Character(SpriteType, id)
{
	program = new Program(frameCount);
}

Sprite::~Sprite()
{
	delete program;
}

void
Sprite::reset()
{
	program->rewindMovie();
}

int
Sprite::hasEventHandler()
{
	return 1;
}

Program *
Sprite::getProgram()
{
	return program;
}

int
Sprite::execute(GraphicDevice *gd, Matrix *matrix, Cxform *cxform)
{
	return program->nestedMovie(gd,0,matrix);
}

ActionRecord *
Sprite::eventHandler(GraphicDevice *gd, FlashEvent *event)
{
	DisplayList *dl;
	ActionRecord *actions;

	dl = program->getDisplayList();
	actions = dl->processEvent(gd, event);
	if (actions) {
		program->doAction(actions,0);
	}
	return actions;
}
