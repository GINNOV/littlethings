
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
	\class	 FrontierMesh
	\ingroup g_application
	\author  Timo Suoranta
	\brief	 Reverse-engineered Frontier First Encounters data file source object file parser
	\date	 2001
*/


#ifndef TEDDY_APPLICATION_FRONTIER_MESH_H
#define TEDDY_APPLICATION_FRONTIER_MESH_H


#include "Models/Mesh.h"
#include "Models/Face.h"
#include "SysSupport/StdMap.h"
using namespace Models;


namespace Application {


typedef map<int, Vertex *, less<int> > int_to_Vertex;


class FrontierFile;


class FrontierMesh : public Mesh {
public:
	FrontierMesh( FrontierFile *f, int ob_id, const char *name );

	virtual void  debug 	( Uint32 command, void *data );

protected:
	void	faceBegin		();
	void	faceInsertVertex( int index );
	void	faceInsertSpline( int p1, int p2, int c1, int c2 );
	void	faceClose		( int normal_index = -1 );
	void	makeVertex		( Vertex &v1, Vertex &v2 );
	void	parseObject 	( const int object_index );
	void	parseVertices	();
	void	parseNormals	();
	void	parseSpecs		();
	void	parseElements	();

	void	printVertices	();

	//	Object struct
	char     *mesh_pointer;
	char     *vertex_pointer;
	Sint32    vertex_count;
	char     *normal_pointer;
	Uint32	  normal_count;
	Uint32    unknown_2;
	Uint32    unknown_3;
	Uint32    radius;
	Sint32    primitive_count;
	Uint32    unknown_4;
	Uint32    unknown_5;
	Uint32    unknown_6;
	Uint32    unknown_7;
	char     *collision_pointer;
	char     *spec_pointer;
	Uint32    unknown_8;
	Uint32    unknown_9;

	FrontierFile                   *f;
	Face                           *face;
	bool                            face_open;
	bool                            face_good;
	int                             face_num_vertices;
	int                             last_vertex_index;
	int_to_Vertex                   vertices;
	int_to_Vertex                   normals;
	list<Element*>::const_iterator  debug_selected_element_it;
};


};	//	namespace Application


#endif	//	TEDDY_APPLICATION_FRONTIER_MESH_H

