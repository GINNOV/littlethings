
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
	\class	 Camera
	\ingroup g_scenes
	\author  Timo Suoranta
	\brief	 Camera
	\warning Starfield is not working
	\warning Cull method needs checking, it does not work with picking
	\date	 2000, 2001

	Sorry no documentation here yet.
*/


#ifndef TEDDY_SCENES_CAMERA_H
#define TEDDY_SCENES_CAMERA_H


#include "Maths/Vector.h"
#include "Maths/Plane.h"
//#include "Maths/Random.h"
#include "Models/ModelInstance.h"
#include "SysSupport/Types.h"
namespace Models             { class Mesh;       };
namespace PhysicalComponents { class Projection; };
using namespace PhysicalComponents;
using namespace Models;


namespace Scenes {


class Scene;
class StarField;


class Camera : public ModelInstance {
public:
	Camera( const char *name, Scene *scene );
	~Camera();

	virtual void   projectScene ( Projection *p );

	void           setFov       ( const float fov );
	float          getFov       () const;
	void           setScene     ( Scene *scene );
	Scene         *getScene     () const;
	void           updatePlanes ();
	bool           cull         ( ModelInstance *mi );
	ModelInstance *pickInstance ( Projection *p, const int x, const int y );

	void           setTitle     ( char *title );
	char          *getTitle     ();

	Matrix         getFrustumMatrix    ( const float left, const float right,  const float bottom, const float top, const float nearval, const float farval );
	Matrix         getPerspectiveMatrix( const float fovy, const float aspect, const float zNear,  const float zFar );
	Matrix         getPickMatrix       ( const float x,    const float y,      const float width,  const float height, int viewport[4] );
	Vector4        projectVector       ( const Vector4 &v );

	void           doProjection        ( Projection *p, const bool load_matrix = true );
	void           doCamera            ( Projection *p, const bool load_matrix = true );
	void           doObjectMatrix      ( Projection *p, const Matrix &m, const bool load_matrix = true );

public:
	Matrix      debug_matrix;        //!<  For debugging purposes
	Vector4     debug_vector;        //!<  For debugging purposes

protected:
	Scene      *scene;               //!<  Scene to draw
//	Mesh       *skybox;              //!<  SkyBox mesh
	Projection *p;                   //!<  Last active projection where to draw
//	StarField  *star_field;          //!<  Stars
	char       *title;               //!<  Title text for the camera
	Matrix      view_matrix;         //!<  Current/latest view matrix
	Matrix      model_view_matrix;   //!<
	Matrix      projection_matrix;   //!<  Current/latest projection matrix
	Matrix      to_screen_s_matrix;  //!<  To screen space -matrix
	Plane       view_plane[6];       //!<  Camera view volume planes for clipping
	int         viewport  [4];       //!<  Current/latest projection viewport
	float       far_clip;            //!<  Far clip plane z
	float       near_clip;           //!<  Near clip plane z
	float       fov;                 //!<  Field of vision
};


};  //  namespace Scenes


#endif  //  TEDDY_SCENES_CAMERA_H

