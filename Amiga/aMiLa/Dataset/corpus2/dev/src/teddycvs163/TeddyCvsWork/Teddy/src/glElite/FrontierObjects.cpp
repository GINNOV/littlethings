
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

/*!
	\file
	\ingroup g_testing_environment
	\author  Timo Suoranta
	\warning This file contains Logical UserInterface Actions
	\date	 2001
*/


#include "glElite/ui.h"
#include "glElite/FrontierFile.h"
#include "glElite/FrontierBitmap.h"
#include "glElite/FrontierMesh.h"
#include "Graphics/View.h"
#include "Models/ModelInstance.h"
#include "Scenes/Scene.h"
using namespace Graphics;
using namespace Models;
using namespace Scenes;


namespace Application {


//!  Add FFE ships
void UI::addFFE(){
	//con << ": Reading ffedat.asm... " << endl;
	view->display();

	FrontierFile  *f  =  new FrontierFile( "ffedat.asm", 0 );
	FrontierMesh  *m;
	ModelInstance *mi;

	con << ": Parsing FFE objects: " << endl;
	view->display();

	int i = 4;
	for( int x=0; x<13; x++ ){
		for( int z=0; z<11; z++ ){
			i++;
			DoubleVector v = DoubleVector( (x-6)*240.0, 0.0, (z-5)*240.0 );
			m  = new FrontierMesh (  f, i, "?"  );
			mi = new ModelInstance(  m->getName(), m );
			mi->setPosition( v );
			mi->setMaterial( NULL );  //  Use material from Mesh
			scene->addInstance( mi );
		}
		con << ".";
		view->display();
	}
	console->newLine();
}


};	//	namespace Application

