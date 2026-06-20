
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta
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


#ifndef TEDDY_TEST_MANIPULATE_L_SYSTEM_H
#define TEDDY_TEST_MANIPULATE_L_SYSTEM_H


#include "Models/LineMesh.h"
#include "SysSupport/StdStack.h"
#include "SysSupport/StdString.h"
#include "State.h"
namespace Models { class Face; };
using namespace Models;


//!  LSystem
/*
	\author Timo Suoranta
	\todo   conditional rules
	\todo   stochastic rules
*/
class LSystem : public LineMesh {
public:
	LSystem();
	virtual ~LSystem();

	void setAxiom ( char          *axiom );
	void setRule  ( unsigned char  c, char *rule );
	void setAngle ( float          angle  );
	void setLength( float          length );
	void expand   ( int            depth  );
	void generate ();

protected:
	void push     ();
	void pop      ();

	void move     ( float len, bool draw, bool vertex );
	void heading  ( float direction );
	void pitch    ( float direction );
	void roll     ( float direction );
	void rollHoriz( float val );
	void randomDir( float val );
	void gravity  ( float val );

	void length   ( float val );
	void angle    ( float val );
	void thickness( float val );

	void polyBegin();
	void polyEnd  ();

	void color    ();

protected:
	string        cur_data;
	string        rules[256];
	unsigned int  cursor;
	float         param;
	bool          use_param;
	stack<State>  state_stack;
	State         current_state;
	Mesh         *polygons;
	Face         *current_face;
};


#endif  //  TEDDY_TEST_MANIPULATE_L_SYSTEM_H

