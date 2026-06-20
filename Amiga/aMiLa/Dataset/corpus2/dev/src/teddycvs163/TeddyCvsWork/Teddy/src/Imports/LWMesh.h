
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
	\class   LWMesh
	\ingroup g_imports
	\author  Timo Suoranta
	\brief   LightWave object file loader
	\warning Many features are not yet implemented
	\todo    Detail polygons
	\todo    Points
	\todo    Lines
	\todo    Polygon tessalation
	\todo    Layers
	\todo    Texture and Image maps
	\bug     Destructors missing
	\date    1999, 2000, 2001

	This class implements loader for LightWave object files.
	It is a subclass of Mesh that contains no Elements,
	only submeshes. Each Layer that is encountered in the file
	is placed into a submesh. If the file has data for arbitrary
	layer, eg., there is data before layer, a default layer 1
	is created and data is placed there.

	Data in layers is organized by surfaces. For each surface
	found in the file a submesh for the layer is created and
	LWSurface is created. Thus each layer mesh contains no
	Elements, just submeshes.

	The LightWave object file format spesification is available
	from NewTek internet pages. Parts LightWave object file format
	specifications are placed into comments into source-code. 
*/


#ifndef TEDDY_IMPORTS_LW_MESH_H
#define TEDDY_IMPORTS_LW_MESH_H


#include "Maths/Vector.h"
#include "Models/Mesh.h"
#include "Imports/lwdef.h"
#include "SysSupport/Types.h"
#include "SysSupport/StdMap.h"
#include <cstring>
using namespace Models;


namespace Imports {


class LWFile;
class LWLayer;


typedef map<U4, LWLayer*> U4_to_LWLayer;
typedef map<U4, char   *> U4_to_string;


class LWMesh : public Mesh {
public:
	LWMesh( char *name );
	LWMesh( char *fname, Uint32 options );
	virtual ~LWMesh();

	LWFile  *getFile                () const;
	LWLayer *getLayer               ( int layer_number );
	char    *getTag                 ( VX  tag_index    );
	void     layer_U2_U2_S0         ();  //  LWLO::LAYR
	void     layer_U2_U2_VEC12_S0_U2();  //  LWO2::LAYR
	void     tags_d                 ();  //  TAGS

protected:
	LWFile        *f;
	U4_to_LWLayer  layers;    //!<  Layers of Lightwave Object
	U4_to_string   tags;
	U4             num_tags;
};


};  //  namespace Imports


#endif  //  TEDDY_IMPORTS_LW_MESH_H

