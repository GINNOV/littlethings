
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
	\class	 Projection
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief	 Areas that need projection matrix
	\date	 2000, 2001

	Each projection area maintains it own rendering preferences.
	Those are independent of potential Material properties of
	ModelInstances which can be viewed in the Projection area.

	While some of the projection properties are default values,
	which can be overridden by material properties, others may
	override any material properties. For example, if projection
	is set to use wireframe rendering, no material property can
	override this - all modelinstances are drawn in wireframe
	mode.

	Projection is responsible for implementing and applying
	Material properties.
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_PROJECTION_H
#define TEDDY_PHYSICAL_COMPONENTS_PROJECTION_H


#include "Maths/Matrix.h"
#include "MixIn/Options.h"
#include "PhysicalComponents/Area.h"
namespace Scenes    { class Camera;   };
namespace Graphics  { class Texture;  };
namespace Materials { class Material; };
using namespace Graphics;
using namespace Materials;
using namespace Maths;
using namespace Scenes;


namespace PhysicalComponents {


//  Options for Projection
#define PR_CLEAR  (1L<<0L)  //!<  Clear the area before drawing?
#define PR_CLIP   (1L<<1L)  //!<  Clip drawing
#define PR_PICK   (1L<<2L)  //!<  Are we doing a pick?


class Projection : public Area, public Options {
public:
	Projection( const char *name, Camera *camera );
	virtual ~Projection();

	void           setProjectionMatrix  ( Matrix &m );
	void           setModelViewMatrix   ( Matrix &m );

	//  Area Input Interface
	virtual Area  *getHit               ( const int x, const int y );
	virtual void   drawSelf             ();  //!<  Will render only self

	Material      *getMaster            ();
	unsigned long  getSelect            ();
	void           setSelect            ( unsigned long select );
	void           enableSelect         ( unsigned long select );
	void           disableSelect        ( unsigned long select );
	void           setClearColor        ( Color c );
	Color          getClearColor        ();

	//  Projection Interface - Accessors
	Camera        *getCamera            ();
	void           setCamera            ( Camera *c = NULL );

	//  Projection Interface - Material control
	void           materialApply        ( Material *m );
	void           materialReapplyActive();
	bool           materialPass         ();

	//  Projection Interface - Pick control
	void           pickState            ( const bool state );

	void           applyFillOutline     ();
	void           applyRemoveHidden    ();
	void           applyFrustumCull     ();
	void           applySortInstances   ();
	void           applySortElements    ();

protected:
	Camera   *camera;                         //<!  Attached camera (determines Scene)
	Material *active_material;                //<!  Currently active Material (last applied)
	Texture  *active_texture;                 //<!  Currently active Texture (last applied)
	Area     *frame;                          //<!  Window frame
	Material *master_material;                //<!  Override settings
	Uint8     render_pass;                    //<!  Current / last render pass
	Uint8     render_pass_count;              //<!  How many render passes have been decided
	Uint32    render_options_selection_mask;  //<!  If bit 1 then render option is set from active material
	Color     clear_color;                    //<!  
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_PROJECTION_H

