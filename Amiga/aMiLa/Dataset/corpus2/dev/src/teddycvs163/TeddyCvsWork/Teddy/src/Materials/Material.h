
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
	\class	 Material
	\ingroup g_materials
	\author  Timo Suoranta
	\brief	 Surface rendering and lighting properties and textures
	\bug	 Destructors missing
	\todo	 Front face (sidedness)
	\todo	 Textures
	\todo	 Multiple Materials with weighting
	\todo	 Blending
	\todo	 Fog
	\date	 1999, 2000, 2001
	FIX
*/


#ifndef TEDDY_MATERIALS_MATERIAL_H
#define TEDDY_MATERIALS_MATERIAL_H


#include "Graphics/Color.h"
#include "Materials/Render.h"
#include "MixIn/Named.h"
#include "MixIn/Options.h"
#include "SDL_types.h"
namespace Graphics { class Texture; };
using namespace Graphics;


namespace Materials {


class Material : public Named, public Options {
public:
	Material( const Material &material );
	Material( const Material &material, Uint8 lighting );
	Material( const char *name );
	Material( const char *name, Uint8 mode, Uint8 lighting, unsigned long options );
	Material( const char *name, Color color );
	Material( const char *name, const unsigned long options );
	virtual ~Material();
	
	void             applyAmbient        ( Uint8 lighting );
	void             applyDiffuse        ( Uint8 lighting );
	void             applySpecular       ( Uint8 lighting );
	void             applyEmission       ( Uint8 lighting );
	void             applyShinyness      ( Uint8 lighting );
	void             applyBorder         ( Uint8 lighting );

	virtual void     setMode             ( Uint8  mode );
	virtual Uint8    getMode             () const;
	virtual void     setLighting         ( Uint8  lighting );
	virtual Uint8    getLighting         () const;

	virtual void     setEmission         ( const Color &e );
	virtual Color    getEmission         () const;
	virtual void     setAmbient          ( const Color &a );
	virtual Color    getAmbient          () const;
	virtual void     setDiffuse          ( const Color &d );
	virtual Color    getDiffuse          () const;
	virtual void     setSpecular         ( const Color &s );
	virtual Color    getSpecular         () const;
	virtual void     setShininess        ( float s );
	virtual float    getShininess        () const;
	virtual void     setBorder           ( const Color &s );
	virtual Color    getBorder           () const;
	virtual void     setPolygonOffset    ( const int offset );
	virtual int      getPolygonOffset    () const;
	virtual void     setMaxSmoothingAngle( const float angle );
	virtual float    getMaxSmoothingAngle() const;
	virtual Texture *getTexture          ();
	virtual void     setTexture          ( Texture *t, bool enable=false );

protected:
	Texture *texture;	
	Uint8    render_mode;
	Uint8    render_lighting;
	float    shininess;
	Color    ambient;
	Color    diffuse;
	Color    specular;
	Color    emission;
	Color    border;
	int      polygon_offset;
	float    max_smoothing_angle;

public:
	static Material BLACK;
	static Material GRAY_25;
	static Material GRAY_50;
	static Material GRAY_75;
	static Material WHITE;
	static Material RED;
	static Material YELLOW;
	static Material ORANGE;
	static Material GREEN;
	static Material CYAN;
	static Material BLUE;
	static Material MAGENTA;
	static Material DARK_ORANGE;
	static Material DARK_RED;
	static Material DARK_YELLOW;
	static Material DARK_GREEN;
	static Material DARK_CYAN;
	static Material DARK_BLUE;
	static Material DARK_MAGENTA;
	static Material LIGHT_ORANGE;
	static Material LIGHT_RED;
	static Material LIGHT_YELLOW;
	static Material LIGHT_GREEN;
	static Material LIGHT_CYAN;
	static Material LIGHT_BLUE;
	static Material LIGHT_MAGENTA;
};


};	//	namespace Materials


#endif	//	TEDDY_MATERIALS_MATERIAL_H

