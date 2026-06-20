
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
	\class	 Scene
	\ingroup g_scenes
	\author  Timo Suoranta
	\brief	 Collections of Models, ModelInstances, Lights and Cameras
	\bug	 Destructors missing?
	\todo	 Group instances by material
	\todo	 Improve light management
	\todo	 Improved sorting, especially for transluent surface support
	\date	 1999, 2000, 2001

	Scene contains Lights and ModelInstances. Scene is responsible of
	rendering the scene according to Camera / Projection Area /
	(Transform)View settings, and each individual ModelInstance settings.

	At the moment rendering the Scene is a very unoptimized
	process. Later on things to be drawn should be arranged
	by material etc.

	While all ModelInstances of scene are potentially drawn, they are
	selected by range and view frustum culling. (Possible other culling
	types could be added later?)

	Rendering transluent instances and elements is not yet implemented.
*/


#ifndef TEDDY_SCENES_SCENE_H
#define TEDDY_SCENES_SCENE_H


#include "Maths/Vector.h"
#include "MixIn/Named.h"
#include "SysSupport/StdList.h"
namespace Materials          { class Light;         };
namespace Models             { class ModelInstance; };
namespace PhysicalComponents { class Projection;    };
using namespace Materials;
using namespace Models;
using namespace PhysicalComponents;


namespace Scenes {


class Camera;
class PostElement;


class Scene : public Named {
public:
	Scene( const char *name );
	
	void                  addLight        ( Light         *l );
	void                  addPostElement  ( PostElement   *p );
	void                  addInstance     ( ModelInstance *i );
	void                  draw            ( Camera        *c, Projection *p );
	void                  drawPostElements( Camera        *c, Projection *p );
	ModelInstance        *pickInstance    ( Camera        *c, Projection *p );
	void                  update          ( Projection    *p );
	list<ModelInstance*> &getInstances    ();
	
	static int culled;
	static int drawn;

protected:
	list<Light*>          lights;
	list<ModelInstance*>  instances;
	list<PostElement*>    post_elements;
};


};  //  namespace Scenes


#endif  //  TEDDY_SCENES_SCENE_H

