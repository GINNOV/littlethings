
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
	\class   LWLayer
	\ingroup g_imports
	\author  Timo Suoranta
	\date    2001
*/


#ifndef TEDDY_IMPORTS_LW_LAYER_H
#define TEDDY_IMPORTS_LW_LAYER_H


#include "Maths/Vector.h"
#include "Models/Mesh.h"
#include "Imports/lwdef.h"
#include "SysSupport/StdMap.h"
#include "SysSupport/Types.h"
#include <cstring>
namespace Models { class Face;   };
namespace Models { class Vertex; };
using namespace Models;


namespace Imports {


class LWClip;
class LWEnvelope;
class LWFile;
class LWMesh;
class LWSurface;


struct less_str {
	bool operator()( char *a, char *b ) const {
		if( strcmp(a,b) < 0 ){
			return true;
		}else{
			return false;
		}
	}
};

typedef map<char*, Mesh      *, less_str   > string_to_Mesh;
typedef map<char*, LWSurface *, less_str   > string_to_LWSurface;
typedef map<U4,    Vertex    *> U4_to_Vertex;
typedef map<U4,    Face      *> U4_to_Face;
typedef map<U4,    LWEnvelope*> U4_to_LWEnvelope;
typedef map<U4,    LWClip    *> U4_to_LWClip;


class LWLayer : public Mesh {
public:
	LWLayer( LWMesh *mesh, char *name, U2 flags, Vector pivot, int parent );
	virtual ~LWLayer();

	void     processLayer();  //!<  Returns true if next layer
	LWClip  *getClip                          ( VX clip_index );
	LWMesh  *getMesh                          ();

protected:
	bool processChunk        ();  //!<  returns true if next layer is needed

	//  LWOB & LWLO
	void pointList                 ();  //  LWOB::PNTS & LWO2::PNTS
	void polygonList               ();  //  LWO2::POLS
	void faceList                  ();  //  LWOB::POLS
	void surfaceList               ();  //  SRFS
	void curveList                 ();  //  CRVS
	void patchList                 ();  //  PCHS
	void surface_sc                ();  //  SURF

	//  LWO2
	void vertexMapping_ID4_U2_S0_d ();  //  VMAP
	void polygonTags_ID4_d         ();  //  PTAG
	void envelope_U4_sc            ();  //  ENVL
	void clip_U4_sc                ();  //  CLIP
	void surf_S0_S0_sc             ();  //  SURF
	void boundingBox_VEC12_VEC12   ();  //  BBOX
	void descriptionLine_S0        ();  //  DESC
	void comments_S0               ();  //  TEXT
	void thumbnail_U2_U2_d         ();  //  ICON

protected:
	LWFile  *f;
	LWMesh  *mesh;          //!<  Mesh which contains this Layer
	Vector   pivot;         //!<  Pivot point of layer
	U2       flags;         //!<  Layer flags
	F4       max_len;       //!<  Longest vertex in mesh, for view volume clipping
	int      parent_layer;  //!<  Parent layer number

	string_to_Mesh       meshes;
	string_to_LWSurface  surfaces;
	U4_to_Vertex         vertices;  //!<  These are shared among surfaces
	U4_to_Face           faces;
	U4_to_LWEnvelope     envelopes;
	U4_to_LWClip         clips;
	U4                   num_vertices;
	U4                   num_faces;
	U4                   num_surfaces;
	U4                   num_envelopes;
	U4                   num_clips;
	U4                   current_surface;
	Vector               bbox_min;
	Vector               bbox_max;
	const char          *description_line;
	const char          *commentary_text;	
};


};  //  namespace Imports


#endif  //  TEDDY_IMPORTS_LW_MESH_H

