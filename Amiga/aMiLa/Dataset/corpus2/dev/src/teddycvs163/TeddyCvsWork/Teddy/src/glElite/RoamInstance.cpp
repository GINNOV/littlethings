
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


#if 0


#include "UniverseDevelopmentKit/CMaster.h"
#include "glElite/RoamInstance.h"
#include "glElite/RoamSphere.h"
#include "PhysicalComponents/Projection.h"
#include "UniverseDevelopmentKit/CVertex.h"
#include "Scenes/Camera.h"
using namespace PhysicalComponents;
using namespace UniverseDevelopmentKit;
using namespace Scenes;


namespace Application {


float c_h;


RoamInstance::RoamInstance( const char *name, Mesh *mesh ):CollisionInstance(name,mesh){
}


/*virtual*/ bool RoamInstance::collisionCheck( CollisionInstance *other ){
	RoamSphere *sphere = dynamic_cast<RoamSphere*>( this->mesh );
	if( sphere == NULL ){
		return false;
	}

	Vector other_pos = other->getPosition();
	float   radius    = other->getClipRadius();
	if( sphere->collisionCheck( other_pos - this->getPosition(), radius ) ){
		this->applyCollision( other );
		other->applyCollision( this );
		return true;
	}
	return false;
}

/*virtual*/ void RoamInstance::drawImmediate( Projection *p ){
	View       *view   = p->getView  ();
	Camera     *camera = p->getCamera();
	RoamSphere *sphere = dynamic_cast<RoamSphere*>( this->mesh );
	if( sphere == NULL || p==NULL ){
		return;
	}

//	need origo camera fix
//	Vector vPosition_beg = p->getCamera()->getPosition() - this->getPosition();
	Vector vPosition_beg =  - this->getPosition() + camera->getPosition();
	Vector vPosition     =  this->rotateVector( vPosition_beg );

	c_h = 0;

	if( roam_update ){
		sphere->update( vPosition, camera );
	}

//  need origo camera fix
//	Matrix m = getScaledModelMatrix( p->getCamera() );
	camera->doObjectMatrix( p, localToWorld() );

	CVertex::Array.EnableVertexArray();
	CVertex::Array.EnableNormalArray();
	CVertex::Array.InitRender();
	mesh->drawImmediate( p, this->material );
	CVertex::Array.FinishRender();
}


};  //  namespace Application



#endif

