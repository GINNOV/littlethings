
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
	\class   Scanner
	\ingroup g_testing_environment
	\author  Timo Suoranta
	\date    2000, 2001
*/


#ifndef TEDDY_APPLICATION_SCANNER_H
#define TEDDY_APPLICATION_SCANNER_H


#include "PhysicalComponents/Area.h"
namespace Graphics  { class Texture; };
namespace Scenes    { class Camera; };
using namespace Graphics;
using namespace PhysicalComponents;
using namespace Scenes;


namespace Application {


class UI;


class Scanner : public Area {
public:
	Scanner( UI *ui );

	void cycle();

	virtual void drawSelf();

protected:
	UI       *ui;
	Camera   *camera;
	int       range;
	Texture  *txt;
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_SCANNER_H

