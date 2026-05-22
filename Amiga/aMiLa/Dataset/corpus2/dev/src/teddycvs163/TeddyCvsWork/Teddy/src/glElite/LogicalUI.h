
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
	\class   LogicalUI
	\ingroup g_application
	\author  Timo Suoranta
	\brief   Command parser
	\date    2001
*/


#ifndef TEDDY_APPLICATION_LOGICAL_UI_H
#define TEDDY_APPLICATION_LOGICAL_UI_H


#include "SysSupport/StdVector.h"
#include "glElite/Action.h"


namespace Application {


class LogicalUI {
public:
	void insert( Action *a );
	bool invoke( const char *s );

protected:
	vector<Action*> actions;
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_LOGICAL_UI_H

