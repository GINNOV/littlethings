
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


#include "glElite/ui.h"
#include "Graphics/View.h"
#include "Imports/LWMesh.h"
#include "Models/ModelInstance.h"
#include "Scenes/Scene.h"
#include "SysSupport/FileScan.h"
#include "SysSupport/Messages.h"
#include <cstdio>
using namespace Graphics;
using namespace Imports;
using namespace Models;
using namespace Scenes;


namespace Application {


#define SPACE 5


/*!
		LightWave Object scanner and loader
		Messy - FileScan class currently works differently on
		different platforms..
*/
void UI::loadLWO(){
	lwo_debug_msg( "UI::loadLWO..." );

	DoubleVector  v;
	double		  cursor = -400.0;
	int 		  i;

	FileScan lwos( "*lwo" );
	int 	num 		  = lwos.get_files().size();

	if( num >0 ){
		con << ": Found " << num << " lightwave objects" << endl;
		view->display();
	}else{
		con << ": No lightwave files found" << endl;
		view->display();
		return;
	}

	list<char*>::iterator f_it = lwos.get_files().begin();
	char *fname;

	//	-----  Read In Files -----
	double	line_z[1000];
	double	line_x[1000];
	Mesh   *lwom  [1000];

	int 	per_line	  = (int)(::sqrt( num ));
	int 	lines		  = num/per_line+1;
	int 	count		  = 0;
	int 	cur_line	  = 0;
	int 	items_on_line = 0;

	//	Initialize each line to width 0
	for( i=0; i<lines; i++ ){
		line_z[i] = 0;
		line_x[i] = 0;
	}
	for( i=0; i<num; i++ ){
		lwom[i] = NULL;
	}

	double total_z      = 0;
	double prev_ob_size = 0;

	//	Read in all files and slice them to lines
	while( f_it != lwos.get_files().end() ){
		double ob_rad;
		fname = new char[ strlen((*f_it))+5 ];
		sprintf( fname, "%s",  *f_it );
		lwom[count] = new LWMesh( fname, 0 /*LWFILE_OPTION_SKIP_MATERIAL_M*/ );
		if( lwom[count] != NULL ){
			ob_rad = lwom[count]->getClipRadius();
		}else{
			ob_rad = 0;
		}
		count++;
		items_on_line++;

		//	Line full enough?
		if( items_on_line > per_line ){
			line_z[cur_line] += SPACE;	//	Add some space
			total_z += line_z[cur_line];
			cur_line++;
			items_on_line = 0;
		}

		//	Make sure line is wide enough
		line_x[cur_line] += ob_rad + SPACE;  //  Add some space
		if( line_z[cur_line] < ob_rad*2 ){
			line_z[cur_line] = ob_rad*2;
		}
		// con << "Processed file " << fname << endl; view->display();
		con << ".";
		view->display();
		f_it++;
	}
	total_z += line_z[cur_line];

	//	Place all lines so that:
	//	 - Each line has own Z, centered on X
	//	 - All lines together are centered in Z
	cur_line		= 0;
	items_on_line	= 0;
	double z_offset = -total_z / 2;
	double x_offset = -line_x[cur_line] / 2;

	z_offset -= line_z[cur_line]/2;

	for( i=0; i<num; i++ ){
		if( lwom[i] == NULL ){
			lwo_debug_msg( "NULL Mesh\n" );
			continue;
		}
		ModelInstance *mi = new ModelInstance(
			lwom[i]->getName(),
			lwom[i]
		);
		x_offset += lwom[i]->getClipRadius()*1.1f + SPACE;
		mi->setPosition( x_offset, 0, z_offset );

/*		switch( i %3 ){
		case 0: mi->tick_rotation = DoubleVector( 0.17f, 0.15f, 0.13f ); break;
		case 1: mi->tick_rotation = DoubleVector(-0.13f,-0.17f,-0.15f ); break;
		case 2: mi->tick_rotation = DoubleVector( 0.15f, 0.13f, 0.17f ); break;
		default: break;
		}*/

		scene->addInstance( mi );

		x_offset += lwom[i]->getClipRadius()*1.1f + SPACE;
		items_on_line++;
		if( items_on_line > per_line ){
			z_offset += line_z[cur_line]/2;
			cur_line++;
			z_offset += line_z[cur_line]/2;
			items_on_line = 0;
			x_offset = -line_x[cur_line] / 2;
		}

	}

	con << endl;
	view->display();
}


};

