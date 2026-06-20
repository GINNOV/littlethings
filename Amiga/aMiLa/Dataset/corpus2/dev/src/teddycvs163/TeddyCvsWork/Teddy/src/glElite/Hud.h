
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta
    tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!
	\class   Hud
	\ingroup g_application
	\author  Timo Suoranta
	\date    2001

	Heads Up Display
*/


#ifndef TEDDY_APPLICATION_HUD_H
#define TEDDY_APPLICATION_HUD_H


#include "PhysicalComponents/Area.h"
#include "Scenes/Camera.h"
namespace Models { class ModelInstance; };
namespace Scenes { class Camera; };
using namespace Models;
using namespace PhysicalComponents;
using namespace Scenes;


namespace Application {


class UI;


class Hud : public Area {
public:
	Hud( UI *ui );

	void setTargetMatrix  ( Matrix *m );

	virtual void drawSelf();

protected:
	UI     *ui;
	Matrix *target_matrix;
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_HUD_H

