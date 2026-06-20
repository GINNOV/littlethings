
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


#include "Graphics/Device.h"
#include "Graphics/Texture.h"
#include "Materials/Material.h"
#include "PhysicalComponents/Projection.h"
#include <cstdio>
using namespace Graphics;


namespace Materials {


//	Note:
//
//	Color::BLACK etc. cannot be used here,
//	because they might not be constructed yet!
Material Material::BLACK         = Material( "Default Black Material",         Color(C_BLACK         )  );
Material Material::GRAY_25       = Material( "Default Gray 25 Material",       Color(C_GRAY_25       )  );
Material Material::GRAY_50       = Material( "Default Gray 50 Material",       Color(C_GRAY_50       )  );
Material Material::GRAY_75       = Material( "Default Gray 75 Material",       Color(C_GRAY_75       )  );
Material Material::WHITE         = Material( "Default White Material",         Color(C_WHITE         )  );
Material Material::ORANGE        = Material( "Default Orange Material",        Color(C_ORANGE        )  );
Material Material::RED           = Material( "Default Red Material",           Color(C_RED           )  );
Material Material::YELLOW        = Material( "Default Yellow Material",        Color(C_YELLOW        )  );
Material Material::GREEN         = Material( "Default Green Material",         Color(C_GREEN         )  );
Material Material::CYAN          = Material( "Default Cyan Material",          Color(C_CYAN          )  );
Material Material::BLUE          = Material( "Default Blue Material",          Color(C_BLUE          )  );
Material Material::MAGENTA       = Material( "Default Magenta Material",       Color(C_MAGENTA       )  );
Material Material::DARK_ORANGE   = Material( "Default Dark Orange Material",   Color(C_DARK_ORANGE   )  );
Material Material::DARK_RED      = Material( "Default Dark Red Material",      Color(C_DARK_RED      )  );
Material Material::DARK_YELLOW   = Material( "Default Dark Yellow Material",   Color(C_DARK_YELLOW   )  );
Material Material::DARK_GREEN    = Material( "Default Dark Green Material",    Color(C_DARK_GREEN    )  );
Material Material::DARK_CYAN     = Material( "Default Dark Cyan Material",     Color(C_DARK_CYAN     )  );
Material Material::DARK_BLUE     = Material( "Default Dark Blue Material",     Color(C_DARK_BLUE     )  );
Material Material::DARK_MAGENTA  = Material( "Default Dark Magenta Material",  Color(C_DARK_MAGENTA  )  );
Material Material::LIGHT_ORANGE  = Material( "Default Light Orange Material",  Color(C_LIGHT_ORANGE  )  );
Material Material::LIGHT_RED     = Material( "Default Light Red Material",     Color(C_LIGHT_RED     )  );
Material Material::LIGHT_YELLOW  = Material( "Default Light Yellow Material",  Color(C_LIGHT_YELLOW  )  );
Material Material::LIGHT_GREEN   = Material( "Default Light Green Material",   Color(C_LIGHT_GREEN   )  );
Material Material::LIGHT_CYAN    = Material( "Default Light Cyan Material",    Color(C_LIGHT_CYAN    )  );
Material Material::LIGHT_BLUE    = Material( "Default Light Blue Material",    Color(C_LIGHT_BLUE    )  );
Material Material::LIGHT_MAGENTA = Material( "Default Light Magenta Material", Color(C_LIGHT_MAGENTA )  );


//!  Constructor with name
Material::Material( const char *name ):
Named  (name),
Options(0)
{
	this->shininess 	  = 0.0;
	this->ambient		  = Color::BLACK;
	this->diffuse		  = Color::BLACK;
	this->specular		  = Color::BLACK;
	this->emission		  = Color::BLACK;
	this->render_mode	  = RENDER_MODE_FILL;
	this->render_lighting = RENDER_LIGHTING_SIMPLE;
	this->texture		  = NULL;
	this->polygon_offset  = 0;
	this->max_smoothing_angle = 60.0f;
}

//!  Constructor with name and options
Material::Material( const char *name, const unsigned long options ):
Named  (name),
Options(options)
{
	this->shininess 	  = 0.0;
	this->ambient		  = Color::BLACK;
	this->diffuse		  = Color::BLACK;
	this->specular		  = Color::BLACK;
	this->emission		  = Color::BLACK;
	this->render_mode	  = RENDER_MODE_FILL;
	this->render_lighting = RENDER_LIGHTING_SIMPLE;
	this->texture		  = NULL;
	this->polygon_offset  = 0;
	this->max_smoothing_angle = 60.0f;
}



//!  Constructor with name, lighting and shading modes
Material::Material( const char *name, Uint8 mode, Uint8 lighting, unsigned long options ):
Named          (name),
Options        (options),
texture        (NULL),
render_mode    (mode),
render_lighting(lighting),
shininess      (0),
ambient        (Color::BLACK),
diffuse        (Color::GRAY_50),
specular       (Color::BLACK),
emission       (Color::BLACK),
border         (Color::GRAY_50),
polygon_offset (0),
max_smoothing_angle(60.0f)
{
}


//!  Copyconstructor
Material::Material( const Material &m ):
Named  (m.name),
Options(m.options)
{
	this->shininess       = m.shininess;
	this->ambient         = m.ambient;
	this->diffuse         = m.diffuse;
	this->specular        = m.specular;
	this->emission        = m.emission;
	this->border          = m.border;
	this->render_mode     = m.render_mode;
	this->render_lighting = m.render_lighting;
	this->texture         = m.texture;
	this->polygon_offset  = 0;
	this->max_smoothing_angle = 60.0f;
}


//!  Copyconstructor with lighting mode change
Material::Material( const Material &m, Uint8 lighting ):
Named  (m.name),
Options(m.options)
{
	this->shininess       = m.shininess;
	this->ambient         = m.ambient;
	this->diffuse         = m.diffuse;
	this->specular        = m.specular;
	this->emission        = m.emission;
	this->border          = m.border;
	this->render_mode     = m.render_mode;
	this->render_lighting = lighting;
	this->texture         = m.texture;
	this->polygon_offset  = 0;
	this->max_smoothing_angle = 60.0f;
}


//!  Constructor with name and ambient/diffuse color
Material::Material( const char *name, Color color ):
Named  (name),
Options(
	RENDER_OPTION_CULL_FACE_M  |
	RENDER_OPTION_DEPTH_TEST_M |
	RENDER_OPTION_AMBIENT_M    |
	RENDER_OPTION_DIFFUSE_M    |
	RENDER_OPTION_SPECULAR_M   |
	RENDER_OPTION_EMISSION_M   |
	RENDER_OPTION_SHINYNESS_M  |
	RENDER_OPTION_SMOOTH_M
)
{
	this->shininess       = 40.0f;
	this->ambient         = Color::BLACK;
	this->diffuse         = color;
	this->specular        = Color::WHITE;
	this->emission        = Color::BLACK;
	this->border          = Color::GRAY_75;
	this->render_mode     = RENDER_MODE_FILL;
	this->render_lighting = RENDER_LIGHTING_SIMPLE;
	this->texture         = NULL;
	this->polygon_offset  = 0;
	this->max_smoothing_angle = 60.0f;
}


//!  Destructor
Material::~Material(){
}


//!  FIX
void Material::applyAmbient( Uint8 lighting ){
	switch( lighting ){
	case RENDER_LIGHTING_COLOR:   break;
	case RENDER_LIGHTING_CUSTOM:  break;
		break;
	case RENDER_LIGHTING_PRIMARY_LIGHT_ONLY:
		//	Fall through
	case RENDER_LIGHTING_FULL:
		//	FIX Not yet implemented, fall through
	case RENDER_LIGHTING_SIMPLE:
		glMaterialfv( GL_FRONT, GL_AMBIENT, ambient.rgba );
#		ifdef DEBUG_MATERIALS
		printf( << "Ambient %d, %d, %d\n", ambient.rgba[0], ambient.rgba[1], ambient.rgba[2] );
#		endif
		break;
	default:
		printf( "Unknown lighting mode\n" );
		break;
	}
}


//!  FIX
void Material::applyDiffuse( Uint8 lighting ){
//	cout << "applyDiffuse " << (int)(lighting) << endl;
	switch( lighting ){
	case RENDER_LIGHTING_COLOR:
		diffuse.glApply();
//		cout << "applyDiffuse " << diffuse.rgba[0] << ", " << diffuse.rgba[1] << ", " << diffuse.rgba[2] << endl;
		break;
	case RENDER_LIGHTING_CUSTOM:  break;
	case RENDER_LIGHTING_PRIMARY_LIGHT_ONLY:
		//	Fall through
	case RENDER_LIGHTING_FULL:
		//	FIX Not yet implemented, fall through
	case RENDER_LIGHTING_SIMPLE:
		glMaterialfv( GL_FRONT, GL_DIFFUSE, diffuse.rgba );
#		ifdef DEBUG_MATERIALS
		printf( "applyDiffuse %d, %d, %d\n", diffuse.rgba[0], diffuse.rgba[1], diffuse.rgba[2] );
#		endif
		break;
	default:
		printf( "Unknown lighting mode\n" );
		break;
	}
}


//!  FIX
void Material::applySpecular( Uint8 lighting ){
	switch( lighting ){
	case RENDER_LIGHTING_COLOR:   break;
	case RENDER_LIGHTING_CUSTOM:  break;
		break;
	case RENDER_LIGHTING_PRIMARY_LIGHT_ONLY:
		//	Fall through
	case RENDER_LIGHTING_FULL:
		//	FIX Not yet implemented, fall through
	case RENDER_LIGHTING_SIMPLE:
		glMaterialfv( GL_FRONT, GL_SPECULAR, specular.rgba );
#		ifdef DEBUG_MATERIALS
		printf( "Specular %d, %d, %d\n", specular.rgba[0], specular.rgba[1], specular.rgba[2] );
#		endif
		break;
	default:
		printf( "Unknown lighting mode\n" );
		break;
	}
}


//!  FIX
void Material::applyEmission( Uint8 lighting ){
	switch( lighting ){
	case RENDER_LIGHTING_COLOR:   break;
	case RENDER_LIGHTING_CUSTOM:  break;
		break;
	case RENDER_LIGHTING_PRIMARY_LIGHT_ONLY:
		//	Fall through
	case RENDER_LIGHTING_FULL:
		//	FIX Not yet implemented, fall through
	case RENDER_LIGHTING_SIMPLE:
		glMaterialfv( GL_FRONT, GL_EMISSION, emission.rgba );
#		ifdef DEBUG_MATERIALS
		printf( "Emission %d, %d, %d\n", emission.rgba[0], emission.rgba[1], emission.rgba[2] );
#		endif
		break;
	default:
		printf( "Unknown lighting mode\n" );
		break;
	}
}


//!  FIX
void Material::applyBorder( Uint8 lighting ){
	switch( lighting ){
	case RENDER_LIGHTING_COLOR:
		border.glApply();
		break;
	case RENDER_LIGHTING_CUSTOM:  break;
	case RENDER_LIGHTING_PRIMARY_LIGHT_ONLY:
		//	Fall through
	case RENDER_LIGHTING_FULL:
		//	FIX Not yet implemented, fall through
	case RENDER_LIGHTING_SIMPLE:
		glMaterialfv( GL_FRONT, GL_DIFFUSE, border.rgba );
#		ifdef DEBUG_MATERIALS
		printf( "Border Diffuse %d, %d, %d\n", border.rgba[0], border.rgba[1], border.rgba[2] );
#		endif
		break;
	default:
		printf( "Unknown lighting mode\n" );
		break;
	}
}


//!  FIX
void Material::applyShinyness( Uint8 lighting ){
	switch( lighting ){
	case RENDER_LIGHTING_COLOR:
	case RENDER_LIGHTING_CUSTOM:
		break;
	case RENDER_LIGHTING_PRIMARY_LIGHT_ONLY:
		//	Fall through
	case RENDER_LIGHTING_FULL:
		//	FIX Not yet implemented, fall through
	case RENDER_LIGHTING_SIMPLE:
		glMaterialf( GL_FRONT, GL_SHININESS, shininess );
#		ifdef DEBUG_MATERIALS
		printf( "Shininess %f\n", shininess );
#		endif
		break;
	default:
		printf( "Unknown lighting mode\n" );
		break;
	}
}


//!  Set Render mode
void Material::setMode( Uint8 mode ){
	this->render_mode = mode;
}


//!  Get Render mode
Uint8 Material::getMode() const {
	return this->render_mode;
}


//!  Set Render Lighting mode
void Material::setLighting( Uint8 lighting ){
	this->render_lighting = lighting;
}


//!  Get Render Lighting mode
Uint8 Material::getLighting() const {
	return this->render_lighting;
}


//!  Set Material emission component
void Material::setEmission( const Color &e ){
	this->emission = e;
}


//!  Get Material emission component
Color Material::getEmission() const {
	return this->emission;
}


//!  Set Material ambient component
void Material::setAmbient( const Color &a ){
	this->ambient = a;
}


//!  Get Material ambient component
Color Material::getAmbient() const {
	return this->ambient;
}


//!  Set diffuse component
void Material::setDiffuse( const Color &d ){
	this->diffuse = d;
}


//!  Get Material diffuse component
Color Material::getDiffuse() const {
	return this->diffuse;
}


//!  Set Material specular component
void Material::setSpecular( const Color &s ){
	this->specular = s;
}


//!  Get Material specular component
Color Material::getSpecular() const {
	return this->specular;
}


//!  Set Material border component
void Material::setBorder( const Color &b ){
	this->border = b;
}


//!  Get Material border component
Color Material::getBorder() const {
	return this->border;
}


//!  Get Material Texture
Texture *Material::getTexture(){
	return this->texture;
}


//!  Set Material Texture
void Material::setTexture( Texture *t, bool enable ){
	this->texture = t;
	if( enable && texture->isGood() ){
		enableOptions( RENDER_OPTION_TEXTURE_2D_M );
	}
}


//!  Set Material shininess
void Material::setShininess( float s ){
	this->shininess = s;
}


//!  Get shininess
float Material::getShininess() const {
	return this->shininess;
}


/*virtual*/ void Material::setPolygonOffset( const int offset ){
	this->polygon_offset = offset;
}


/*virtual*/ int Material::getPolygonOffset() const {
	return polygon_offset;
}


/*virtual*/ void Material::setMaxSmoothingAngle( const float angle ){
	this->max_smoothing_angle = angle;
}


/*virtual*/ float Material::getMaxSmoothingAngle() const {
	return max_smoothing_angle;
}


};	//	namespace Materials

