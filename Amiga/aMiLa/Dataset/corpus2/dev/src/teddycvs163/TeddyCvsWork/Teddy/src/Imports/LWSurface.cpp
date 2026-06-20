
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


#include "Graphics/Color.h"
#include "Imports/LWFile.h"
#include "Imports/LWLayer.h"
#include "Imports/LWMesh.h"
#include "Imports/LWSurface.h"
#include "Imports/LWSurfaceBlok.h"
#include "Imports/LWTexture.h"
#include "SysSupport/Messages.h"
#include "SysSupport/StdMaths.h"
#include <cstring>
using namespace Graphics;


namespace Imports {


char *LWSurface::LW_ImageMapStrings[] = {
	"Planar Image Map",
	"Cylindrical Image Map",
	"Spherical Image Map",
	"Cubic Image Map",
};

/*
#define LW_PLANAR_IMAGE_MAP 	 1
#define LW_CYLINDRICAL_IMAGE_MAP 2
#define LW_SPHERICAL_IMAGE_MAP	 3
#define LW_CUBIC_IMAGE_MAP		 4
*/

int LWSurface::getMapType( const char *s ){
	int type = 0;

	if( strcmp( s, "Planar Image Map"      ) == 0 ) type = LW_PLANAR_IMAGE_MAP;
	if( strcmp( s, "Cylindrical Image Map" ) == 0 ) type = LW_CYLINDRICAL_IMAGE_MAP;
	if( strcmp( s, "Spherical Image Map"   ) == 0 ) type = LW_SPHERICAL_IMAGE_MAP;
	if( strcmp( s, "Cubic Image Map"       ) == 0 ) type = LW_CUBIC_IMAGE_MAP;

	return type;
}


//!  Constructor
LWSurface::LWSurface( LWLayer *layer, Mesh *mesh, const char *name )
:Material(
	name,
	RENDER_MODE_FILL/*_OUTLINE*/,
	RENDER_LIGHTING_SIMPLE,
//	RENDER_LIGHTING_COLOR,
	RENDER_OPTION_CULL_FACE_M  |
	RENDER_OPTION_DEPTH_TEST_M |
	RENDER_OPTION_AMBIENT_M    |
	RENDER_OPTION_DIFFUSE_M    |
	RENDER_OPTION_SPECULAR_M   |
	RENDER_OPTION_EMISSION_M   |
	RENDER_OPTION_SHINYNESS_M 
//	RENDER_OPTION_BORDER_M
//	RENDER_OPTION_SMOOTH_M
){
	setAmbient ( Color::GRAY_25 );
	setDiffuse ( Color::GRAY_50 );
	setSpecular( Color::GRAY_75 );
	setEmission( Color::BLACK );
	setBorder  ( Color::WHITE );
	this->f             = layer->getMesh()->getFile();
	this->layer         = layer;
	this->mesh          = mesh;
	baseColor           = Color::BLACK;
	luminosity_p        = 0;
	diffuse_p           = 0;
	specular_p          = 0; 
	reflection_p        = 0;
	transparency_p      = 0;
	translucency_p      = 0;
	shininess           = shininess = pow( 2, (10.0f * 0.40f) + 2 );
	current_texture     = NULL;
	max_smoothing_angle = 0;
	//lwo_debug_msg( "Surface %s", name );
}


//!  Destructor
/*virtual*/ LWSurface::~LWSurface(){
	//	FIX
}


LWLayer *LWSurface::getLayer(){
	return layer;
}

Mesh *LWSurface::getMesh(){
	return mesh;
}

void LWSurface::setMesh( Mesh *mesh ){
	this->mesh = mesh;
}


//!  Process surface subchunks
void LWSurface::processSubChunk(){
	if( f== (LWFile*)(0xfdfdfdfd) ){
		lwo_debug_msg( "ERROR" );
		return;
	}
	subchunk_id     = f->read_ID4();
	subchunk_length = f->read_U2();

	//did( subchunk_id );
	//cout << " subchunk of length " << subchunk_length << endl;

	f->pushDomain( subchunk_length );

	lwo_debug_msg(
		"%s::SURF::%s (%d bytes)",
		did( f->getType() ),
		did( subchunk_id ),
		subchunk_length
	);

	switch( f->getType() ){
	case ID_LWOB:
		switch( subchunk_id ){
		case ID_COLR: readBaseColor_COL4(); break;
		case ID_FLAG: readStateFlags_U2(); break;
		case ID_LUMI: readLuminosity_IP2(); break;
		case ID_DIFF: readDiffuse_IP2(); break;
		case ID_SPEC: readSpecular_IP2_4(); break;
		case ID_REFL: readReflection_IP2_4(); break;
		case ID_TRAN: readTransparency_IP2(); break;
		case ID_VLUM: readLuminosity_FP4(); break;
		case ID_VDIF: readDiffuse_FP4(); break;
		case ID_VSPC: readSpecular_FP4(); break;
		case ID_VRFL: readReflection_FP4(); break;
		case ID_VTRN: readTransparency_FP4(); break;
		case ID_GLOS: readSpecularGlossiness_I2_4(); break;
		case ID_RFLT: readReflectionMode_U2(); break;
		case ID_RIMG: readReflectionMapImage_FNAM0(); break;
		case ID_RSAN: readReflectionMapImageSeamAngle_DEG4(); break;
		case ID_RIND: readRefractiveIndex_F4(); break;
		case ID_EDGE: readEdgeTransparencyTreshold_F4(); break;
		case ID_SMAN: readMaxSmoothingAngle_DEG4(); break;
		case ID_ALPH: readAlphaMode_U2_U2(); break;
		case ID_SHDR: readShaderPlugin_S0(); break;
		case ID_SDAT: readShaderData_f(); break;
		case ID_IMSQ: readSequenceOptions_U2_U2_U2(); break;
		case ID_FLYR: readFlyerClipOptions_U4_U4(); break;
		case ID_IMCC: readColorCycleOptions_U2_U2_U2(); break;
		case ID_CTEX: readColorTexture_S0(); break;
		case ID_DTEX: readDiffuseTexture_S0(); break;
		case ID_STEX: readSpecularTexture_S0(); break;
		case ID_RTEX: readReflectionTexture_S0(); break;
		case ID_TTEX: readTransparencyTexture_S0(); break;
		case ID_LTEX: readLuminosityTexture_S0(); break;
		case ID_BTEX: readBumpTexture_S0(); break;

		//	Texture parameters are actually handled by current texture

		default:
			if( current_texture != NULL ){
				switch( subchunk_id ){
				case ID_TFLG: current_texture->readTextureFlags_U2(); break;
				case ID_TSIZ: current_texture->readTextureSize_VEC12(); break;
				case ID_TCTR: current_texture->readTextureCenter_VEC12(); break;
				case ID_TFAL: current_texture->readTextureFallOff_VEC12(); break;
				case ID_TVEL: current_texture->readTextureVelocity_VEC12(); break;
				case ID_TREF: current_texture->readTextureReferenceObject_S0(); break;
				case ID_TCLR: current_texture->readTextureColor_COL4(); break;
				case ID_TVAL: current_texture->readTextureValue_IP2(); break;
				case ID_TAMP: current_texture->readBumpTextureAmplitude_FP4(); break;
				case ID_TFP : current_texture->readTextureAlgorithm_F4(); break;  // ns not yet handled
				case ID_TIP : current_texture->readTextureAlgorithm_I2(); break;
				case ID_TSP : current_texture->readTextureAlgorithm_F4(); break;  // obsolete
				case ID_TFRQ: current_texture->readTextureAlgorithm_I2(); break;  // obsolete
				case ID_TIMG: current_texture->readImageMap_FNAM0(); break;
				case ID_TALP: current_texture->readImageAlpha_FNAM0(); break;
				case ID_TWRP: current_texture->readImageWarpOptions_U2_U2(); break;
				case ID_TAAS: current_texture->readAntialiasingStrength_FP4(); break;
				case ID_TOPC: current_texture->readTextureOpacity_FP4(); break;
				default:
//					cout << "handler not implemented\n";
					break;
						}
			}else{
				lwo_debug_msg( "There is no texture where to bind found texture subchunk\n" );
			}
			break;
		}
		break;

	case ID_LWO2:
		switch( subchunk_id ){
		case ID_COLR: readBaseColor_COL12_VX(); break;
		case ID_LUMI: readLuminosity_FP4_VX(); break;
		case ID_DIFF: readDiffuse_FP4_VX(); break;
		case ID_SPEC: readSpecular_FP4_VX(); break;
		case ID_REFL: readReflection_FP4_VX(); break;
		case ID_TRAN: readTransparency_FP4_VX(); break;
		case ID_TRNL: readTranslucency_FP4_VX(); break;
		case ID_GLOS: readSpecularGlossiness_FP4_VX(); break;
		case ID_SHRP: readDiffuseSharpness_FP4_VX(); break;
		case ID_BUMP: readBumpIntensity_FP4_VX(); break;
		case ID_SIDE: readPolygonSidedness_U2(); break;
		case ID_SMAN: readMaxSmoothingAngle_ANG4(); break;
		case ID_RFOP: readReflectionOptions_U2(); break;
		case ID_RIMG: readReflectionMapImage_VX(); break;
		case ID_RSAN: readReflectionMapImageSeamAngle_ANG4_VX(); break;
		case ID_RIND: readRefractiveIndex_F4_VX(); break;
		case ID_CLRH: readColorHighlights_FP4_VX(); break;
		case ID_TROP: readTransparencyOptions_U2(); break;
		case ID_TIMG: readRefractionMapImage_VX(); break;
		case ID_CLRF: readColorFilter_FP4_VX(); break;
		case ID_ADTR: readAdditiveTransparency_FP4_VX(); break;
		case ID_GLOW: readGlowEffect_U2_F4_VX_F4_VX(); break;
		case ID_LINE: readRenderOutlines_U2_F4_VX_COL12_VX(); break;
		case ID_ALPH: readAlphaMode_U2_FP4(); break;
		case ID_BLOK: readBlok(); break;
		case ID_CMNT: readComment_S0(); break;

		//	Texture parameters are actually handled by current texture

		default:
			if( current_texture != NULL ){
				switch( subchunk_id ){
				case ID_TFLG: current_texture->readTextureFlags_U2(); break;
				case ID_TSIZ: current_texture->readTextureSize_VEC12(); break;
				case ID_TCTR: current_texture->readTextureCenter_VEC12(); break;
				case ID_TFAL: current_texture->readTextureFallOff_VEC12(); break;
				case ID_TVEL: current_texture->readTextureVelocity_VEC12(); break;
				case ID_TREF: current_texture->readTextureReferenceObject_S0(); break;
				case ID_TCLR: current_texture->readTextureColor_COL4(); break;
				case ID_TVAL: current_texture->readTextureValue_IP2(); break;
				case ID_TAMP: current_texture->readBumpTextureAmplitude_FP4(); break;
				case ID_TFP : current_texture->readTextureAlgorithm_F4(); break;  // ns not yet handled
				case ID_TIP : current_texture->readTextureAlgorithm_I2(); break;
				case ID_TSP : current_texture->readTextureAlgorithm_F4(); break;  // obsolete
				case ID_TFRQ: current_texture->readTextureAlgorithm_I2(); break;  // obsolete
				case ID_TIMG: current_texture->readImageMap_FNAM0(); break;
				case ID_TALP: current_texture->readImageAlpha_FNAM0(); break;
				case ID_TWRP: current_texture->readImageWarpOptions_U2_U2(); break;
				case ID_TAAS: current_texture->readAntialiasingStrength_FP4(); break;
				case ID_TOPC: current_texture->readTextureOpacity_FP4(); break;
				default:
					lwo_debug_msg( "Handler not implemented" );
//					cout << "handler not implemented\n";
					break;
				}

			}else{
				lwo_debug_msg( "There is no texture where to bind found texture subchunk" );
			}
			break;
		}
		break;

	default:
		lwo_debug_msg( "handler not implemented" );
		break;
	}

	f->popDomain( true );
}


void LWSurface::endSurface(){
	endTexture();
}

void LWSurface::endTexture(){
	if( current_texture != NULL ){
		current_texture->applyTexture();
	}
	current_texture = NULL;
}


void LWSurface::setTexture( Texture *t, bool enable ){
	Material::setTexture( t, enable );
	useTextureColormap();
}



void LWSurface::useTextureColormap(){
	baseColor = Color::WHITE;
	ambient   = baseColor * luminosity_p;
	diffuse   = baseColor * diffuse_p;
	specular  = Color::WHITE * specular_p;
}


/*! LWOB

	COLR { base-color[COL4] } 
		
	This defines the base color of the surface, which is the color that lies 
	under all the other texturing attributes.
*/
void LWSurface::readBaseColor_COL4(){
	U1 red   = f->read_U1();
	U1 green = f->read_U1();
	U1 blue  = f->read_U1();
	(void)f->read_U1();

	baseColor = Color( red/255., green/255., blue/255. );
	ambient   = baseColor * luminosity_p;
	diffuse   = baseColor * diffuse_p;
	specular  = Color::WHITE * specular_p;
}


/*!  LWOB, LWLO, LWO2

	LUMI, DIFF, SPEC, REFL, TRAN { percentage[IP2] }
	VLUM, VDIF, VSPC, VRFL, VTRN { percentage[FP4] } 
	
	These sub-chunks specify the base level of the surface's luminosity, 
	diffuse, specular, reflection, or transparency settings. Each setting has a 
	fixed-point and a floating-point form, but if both are present the 
	floating-point form should take precedence. The fixed-point value should be 
	rounded to the nearest half percent. Even though the floating-point form is 
	prefered, the convention is to write both sub-chunks to a surface 
	description to support older parsers. If any of these sub-chunks are absent 
	for a surface, a value of zero is assumed. The LUMI or VLUM sub-chunk 
	overrides the Luminous bit of the FLAG sub-chunk. 
*/
void LWSurface::readStateFlags_U2(){
	int count = 0;
	U2  flags = f->read_U2();

}


//!  LWOB Luminosity
void LWSurface::readLuminosity_IP2(){
	luminosity_p = f->read_U2() / 255.0;
	ambient      = baseColor * luminosity_p;
}


//!  LWOB Luminosity
void LWSurface::readLuminosity_FP4(){
	luminosity_p = f->read_FP4();
	ambient      = baseColor * luminosity_p;
}


//!  LWOB Diffuse
void LWSurface::readDiffuse_IP2(){
	diffuse_p = f->read_U2() / 255.0;
	diffuse   = baseColor * diffuse_p;
}


//!  LWOB Diffuse
void LWSurface::readDiffuse_FP4(){
	diffuse_p = f->read_FP4();
	diffuse   = baseColor * diffuse_p;
}


//!  LWOB Specularity
void LWSurface::readSpecular_IP2_4(){
	specular_p = f->read_U2() / 255.0;
	specular   = Color::WHITE * specular_p;
}


//!  LWOB Specularity
void LWSurface::readSpecular_FP4(){
	specular_p = f->read_FP4();
	specular   = Color::WHITE * specular_p;
}


//!  LWOB Specular glossiness
void LWSurface::readSpecularGlossiness_I2_4(){
	U4 dl = f->domainLeft();
	if( dl != 2 ){
		lwo_debug_msg( "Domain left %ld bytes, expecting 2", dl );
	}

	I2 int_shi = f->read_I2();
	shininess = pow( 2, (10.0f * int_shi) + 2 );
//		cout << "Shininess " << shininess << endl;
	if( shininess < 0 ){
		lwo_debug_msg(
			"Negative specular glossiness % 4.1f is invalid, replacing with zero.",
			shininess
		);
		shininess = 0;
	}
	if( shininess > 128 ){
		shininess = 128;
	}
	//lwo_debug_msg( "Glossiness %4.1f", shininess );
}


void LWSurface::readReflection_IP2_4(){}
void LWSurface::readTransparency_IP2(){}
void LWSurface::readReflection_FP4(){}
void LWSurface::readTransparency_FP4(){}
void LWSurface::readReflectionMode_U2(){}
void LWSurface::readReflectionMapImage_FNAM0(){}
void LWSurface::readReflectionMapImageSeamAngle_DEG4(){}
void LWSurface::readRefractiveIndex_F4(){}
void LWSurface::readEdgeTransparencyTreshold_F4(){}
void LWSurface::readMaxSmoothingAngle_DEG4(){
	max_smoothing_angle = f->read_ANG4();
}
void LWSurface::readAlphaMode_U2_U2(){}
void LWSurface::readShaderPlugin_S0(){}
void LWSurface::readShaderData_f(){}
void LWSurface::readSequenceOptions_U2_U2_U2(){}
void LWSurface::readFlyerClipOptions_U4_U4(){}
void LWSurface::readColorCycleOptions_U2_U2_U2(){}

/*! LWOB Start Texture Definition 

	CTEX, DTEX, STEX, RTEX, TTEX, LTEX, BTEX { texture-type[S0] } 

	The presence of one of these sub-chunks indicates that the current surface 
	has a color, diffuse, specular, reflection, transparency, luminosity, or 
	bump texture. The contents of the sub-chunk is a character string specifying 
	the texture type as shown on the control panel. Once one of these sub-chunks 
	is encountered within a SURF chunk, all subsequent texture-related 
	sub-chunks are considered to pertain to the current texture, until another 
	one of these texture starting sub-chunks is read. There may be any number of 
	textures for each parameter, and the textures are layered in the order they 
	are read. 

*/
void LWSurface::readColorTexture_S0(){
	S0 color_texture = f->read_S0();
	endTexture();
	current_texture = new LWTexture( this, getMapType(color_texture) );
}

void LWSurface::readDiffuseTexture_S0(){
	S0 diffuse_texture = f->read_S0();
	//current_texture = new LWTexture( this, getMapType(diffuse_texture) );
}

void LWSurface::readSpecularTexture_S0(){
	S0 specular_texture = f->read_S0();
	//current_texture = new LWTexture( this, getMapType(specular_texture) );
}

void LWSurface::readReflectionTexture_S0(){
	S0 reflection_texture = f->read_S0();
	//current_texture = new LWTexture( this, getMapType(reflection_texture) );
}

void LWSurface::readTransparencyTexture_S0(){
	S0 transparency_texture = f->read_S0();
	//current_texture = new LWTexture( this, getMapType(transparency_texture) );
}

void LWSurface::readLuminosityTexture_S0(){
	S0 luminosity_texture = f->read_S0();
	//current_texture = new LWTexture( this, getMapType(luminosity_texture) );
}

void LWSurface::readBumpTexture_S0(){
	S0 bump_texture = f->read_S0();
	//current_texture = new LWTexture( this, getMapType(bump_texture) );
}



//	LWO2


void LWSurface::readComment_S0(){
	const char *comment = f->read_S0();
	if( strstr(comment,"polygon_offset") != NULL ){
		setPolygonOffset( 1 );
//		printf( "Polygon offset enabled\n" );
	}
}

/*!
	LWO2 Base Color 

	COLR { base-color[COL12], envelope[VX] } 

	This defines the base color of the surface, which is the color that
	lies under all the other texturing attributes. 
*/
void LWSurface::readBaseColor_COL12_VX(){
	baseColor   = f->read_COL12();
	VX envelope = f->read_VX();     //  FIX envelope

	ambient  = baseColor * luminosity_p;
	diffuse  = baseColor * diffuse_p;
	specular = baseColor * specular_p;
}


/*!
	LWO2 Base Shading Values 

	DIFF, LUMI, SPEC, REFL, TRAN, TRNL { intensity[FP4], envelope[VX] } 

	These sub-chunks specify the base level of the surface's
	diffuse, luminosity, specular, reflection, transparency, or
	tranlucency settings. If any of these sub-chunks are absent
	for a surface, a value of zero is assumed. 
*/
void LWSurface::readLuminosity_FP4_VX(){
	luminosity_p = f->read_FP4();
	VX envelope  = f->read_VX();	 //  FIX envelope

	ambient = baseColor * luminosity_p;
}
void LWSurface::readDiffuse_FP4_VX(){
	diffuse_p   = f->read_FP4();
	VX envelope = f->read_VX(); 	//	FIX envelope

	diffuse = baseColor * diffuse_p;
}
void LWSurface::readSpecular_FP4_VX(){
	specular_p  = f->read_FP4();
	VX envelope = f->read_VX(); 	//	FIX envelope

	specular = Color::WHITE * specular_p;
}
void LWSurface::readReflection_FP4_VX(){
	reflection_p = f->read_FP4();
	VX envelope  = f->read_VX();	 //  FIX envelope

	//	FIX no reflections yet? reflection = baseColor * reflection_p;
}
void LWSurface::readTransparency_FP4_VX(){
	transparency_p = f->read_FP4();
	VX envelope    = f->read_VX();	   //  FIX envelope

	//	FIX no transparency yet
}
void LWSurface::readTranslucency_FP4_VX(){
	translucency_p = f->read_FP4();
	VX envelope    = f->read_VX();	   //  FIX envelope

	//	FIX no translucency yet
}


/*!  LWO2 Specular Glossiness 

	GLOS { glossiness[FP4], envelope[VX] } 

	Glossiness controls the falloff of specular highlights.
	The intensity of a specular highlight is calculated as
	cos^n a, where a is the angle between the reflection and
	view vectors. The power n is the specular exponent. The
	GLOS chunk stores a glossiness g as a floating point
	fraction related to n by: n = 2(10g + 2). A glossiness
	of 20% (0.2) gives a specular exponent of 2^4, or 16,
	equivalent to the "Low" glossiness preset in versions of
	LightWave prior to 6.0. Likewise 40% is 64 or "Medium,"
	60% is 256 or "High," and 80% is 1024 or "Maximum." The
	GLOS subchunk is only meaningful when the specularity in
	SPEC is non-zero. If GLOS is missing, a value of 40% is
	assumed. 
*/
void LWSurface::readSpecularGlossiness_FP4_VX(){
	float shi = f->read_FP4();
	shininess = pow( 2, (10.0f * shi) + 2 );
	if( shininess < 0 ){
		lwo_debug_msg( "Negative specular glossiness %f is invalid, replacing with zero", shi );
		shininess = 0;
	}
	if( shininess > 128 ){
		shininess = 128;
	}
	VX envelope = f->read_VX();  //  FIX envelope
	//lwo_debug_msg( "Glossiness %4.1f", shininess );
}


/*!  LWO2 Diffuse Sharpness 

	SHRP { sharpness[FP4], envelope[VX] } 

	Diffuse sharpness models non-Lambertian surfaces. The
	sharpness refers to the transition from lit to unlit
	portions of the surface, where the difference in diffuse
	shading is most obvious. For a sharpness of 0.0, diffuse
	shading of a sphere produces a linear gradient. A sharpness
	of 50% (0.5) corresponds to the fixed "Sharp Terminator"
	switch in versions of LightWave prior to 6.0. It produces
	planet-like shading on a sphere, with a brightly lit day
	side and a rapid falloff near the day/night line (the
	terminator). 100% sharpness is more like the Moon, with no
	falloff until just before the terminator. 
*/
void LWSurface::readDiffuseSharpness_FP4_VX(){
	FP4  sharpness = f->read_FP4();
	VX   envelope  = f->read_VX();   //  FIX envelope
	//	FIX Is this possible to be done with OpenGL?
}


/*!  LWO2 Bump Intensity 

	BUMP { strength[FP4], envelope[VX] } 

	Bump strength scales the height of the bumps
	in the gradient calculation. Higher values have
	the effect of increasing the contrast of the
	bump shading. The default value is 1.0. 
*/
void LWSurface::readBumpIntensity_FP4_VX(){
	FP4  streangth = f->read_FP4();
	VX   envelope  = f->read_VX();   //  FIX envelope
	//	FIX Neither am I :)
}


/*!  LWO2 Polygon Sidedness 

	SIDE { sidedness[U2] } 

	The sidedness of a polygon can be 1 for front-only, or 3 for
	front and back. This replaces the old "Double Sided" flag bit.
	If missing, single-sided polygons are assumed. 
*/
void LWSurface::readPolygonSidedness_U2(){
	U2 side = f->read_U2();
	switch( side ){
	case 1:
	case 2:
	case 3:
	default:
		break;
	}
}


/*!
	LWO2 Max Smoothing Angle 

	SMAN { max-smoothing-angle[ANG4] } 

	The maximum angle between adjacent polygons that will
	be smooth shaded. Shading across edges at higher angles
	won't be interpolated (the polygons will appear to meet
	at a sharp seam). If this chunk is missing, or if the
	value is <= 0, then the polygons are not smoothed. 



*/
void LWSurface::readMaxSmoothingAngle_ANG4(){
	max_smoothing_angle = f->read_ANG4();
}


/*!
	LWO2 Reflection Options 

	RFOP { reflection-options[U2] } 

	Reflection options is a numeric code that describes
	how reflections are handled for this surface and is
	only meaningful if the reflectivity in REFL is non-zero.

	0 - Backdrop Only 

	Only the backdrop is reflected. 

	1 - Raytracing + Backdrop 

	Objects in the scene are reflected when raytracing
	is enabled. Rays that don't intercept an object are
	assigned the backdrop color. 

	2 - Spherical Map 

	If an image is provided in an RIMG subchunk, the image
	is reflected as if it were spherically wrapped around
	the scene. 

	3 - Raytracing + Spherical Map 

	Objects in the scene are reflected when raytracing is
	enabled. Rays that don't intercept an object are assigned
	a color from the image map. 

	If there is no RFOP subchunk, a value of 0 is assumed. 
*/
void LWSurface::readReflectionOptions_U2(){
	U2 reflection_options = f->read_U2();
	//	FIX support for this
}


/*!
	LWO2 Reflection Map Image 

	RIMG { image[VX] } 

	A surface reflects this image as if it were
	spherically wrapped around the scene. The
	RIMG is only used if the reflection options
	in RFOP are set to use an image and the
	reflectivity of the surface in REFL is non-zero.
	The image is the index of a CLIP chunk, or
	zero to indicate no image
*/
void LWSurface::readReflectionMapImage_VX(){
	VX reflection_map_image = f->read_VX();
	//	FIX support for this
}


/*!  LWO2 Reflection Map Image Seam Angle 

	RSAN { seam-angle[ANG4], envelope[VX] } 

	This angle is the heading angle of the reflection map seam.
	If missing, a value of zero is assumed. 
*/
void LWSurface::readReflectionMapImageSeamAngle_ANG4_VX(){
	ANG4  seam_angle = f->read_ANG4();
	VX    envelope   = f->read_VX();    //  FIX envelope
}


/*!
	LWO2 Refractive Index 

	RIND { refractive-index[F4], envelope[VX] } 

	The surface's refractive index determines how much light rays bend
	when passing into or out of this material, and is defined as the
	ratio of the speed of light in a vacuum to the speed of light in
	the material. Since light is fastest in a vacuum, this value should
	therefore be greater than or equal to 1.0. 
*/
void LWSurface::readRefractiveIndex_F4_VX(){
	F4  refractive_index = f->read_F4();
	VX  envelope         = f->read_VX();  //  FIX envelope
	//	FIX support for this.. ?
}


/*!  LWO2 Color Highlights 

	CLRH { color-highlights[FP4], envelope[VX] } 

	The color highlight percentage determines how
	much the reflections on a surface, including
	specular highlights, are tinted by the color
	of the surface. This replaces the old discrete
	"Color Highlights" flag. 

	Specular highlights are ordinarily the color of
	the incident light. Color highlights models the
	behavior of dialectric and conducting materials,
	in which the color of the specular highlight tends
	to be closer to the color of the material. A higher
	color highlight value blends more of the surface
	color and less of the incident light color. 
*/
void LWSurface::readColorHighlights_FP4_VX(){
	FP4 color_highlights = f->read_FP4();
	VX  envelope         = f->read_VX();   //  FIX envelope
}


/*!  LWO2 Transparency Options 

	TROP { transparency-options[U2] } 

	Transparency options are just the same as reflection options
	except that they describe how refraction is handled. Refraction
	can be any combination of background color, image or raytracing. 
*/
void LWSurface::readTransparencyOptions_U2(){
	//  FIX support for this
}


/*!
	LWO2 Refraction Map Image 

	TIMG { image[VX] } 

	The refraction image is wrapped around the scene and is used for
	refraction mapping if the TROP mode is set to use an image and
	the transparency of the surface is non-zero. This setting is the
	refractive analogue of RIMG. 
*/
void LWSurface::readRefractionMapImage_VX(){
	//	FIX support for this
}


/*!
	LWO2 Color Filter 

	CLRF { color-filter[FP4], envelope[VX] } 

	The color filter percentage determines how much rays passing through
	a transparent surface are tinted by the color of the surface. This
	replaces the old discrete "Color Filter" flag. 
*/
void LWSurface::readColorFilter_FP4_VX(){
	FP4 color_filter = f->read_FP4();
	VX  envelope     = f->read_VX();   //  FIX envelope
	//	FIX support for this
}


/*!
	LWO2 Additive Transparency 

	ADTR { additive[FP4], envelope[VX] } 

	This percentage selects how "additive" transparency effect are.
	The default value of zero indicates that transparent surfaces
	fully attenuate the background color while a value of 100%
	indicates that that the background color is full strength under
	the transparent surface. 
*/
void LWSurface::readAdditiveTransparency_FP4_VX(){
	FP4 additive = f->read_FP4();
	VX  envelope = f->read_VX();   //  FIX envelope
	//	FIX support for this
}


/*!
	LWO2 Glow Effect 

	GLOW { type[U2], intensity[F4], intensity-envelope[VX], size[F4], size-envelope[VX] } 

	The glow effect causes a surface to spread and effect neighboring
	areas of the image.The type can be 0 for Hastings glow, and 1 for
	image convolution. The size and intensity modulate how large and
	how strong the effect is, but the exact units are unclear. 
*/
void LWSurface::readGlowEffect_U2_F4_VX_F4_VX(){
	U2 type               = f->read_U2();
	F4 intensity          = f->read_F4();
	VX intensity_envelope = f->read_VX();     //  FIX envelope
	F4 size               = f->read_F4();
	VX size_envelope      = f->read_VX();     //  FIX envelope
	//  Unclear to me too
	//  FIX support for this
}


/*!
	LWO2 Render Outlines 

	LINE { flags[U2], ( size[F4], size-envelope[VX], ( color[COL12], color-envelope[VX] )? )? }

	The line effect draws the surface as a wireframe
	of the polygon edges. Currently the only flag
	defined is an enable switch in the low bit. The
	size is the thickness of the lines in pixels,
	and the color, if not given, is the base color
	of the surface. Note that you may encounter LINE
	subchunks with no color information (these will
	have a subchunk length of 8 bytes) and possibly
	without size information (subchunk length 2).

*/
void LWSurface::readRenderOutlines_U2_F4_VX_COL12_VX(){
	U2    flags          = f->read_U2();
	if( f->domainLeft()<4 ) return;
	F4    size           = f->read_F4();
	if( f->domainLeft()<4 ) return;
	VX    size_envelope  = f->read_VX();     //  FIX envelope
	Color color          = f->read_COL12();
	VX    color_envelope = f->read_VX();     //  FIX envelope
}


/*!
	LWO2 Alpha Mode 

	ALPH { mode[U2], value[FP4] } 

	This chunk defines the alpha channel output options for the surface.

	If mode is 0, this surface does not affect the Alpha channel at all
	when rendered.
	
	If mode is 1, the alpha channel will have a fixed value which is the second
	parameter in the chunk and should normally have a value between 0.0 and 1.0.
	
	If mode is 2, the alpha value is derived from surface opacity, which is the
	default if the ALPH chunk is missing.

	If mode is 3, the alpha value comes from shadow density. 
*/
void LWSurface::readAlphaMode_U2_FP4(){
	//  FIX support for this
}


/*!
	LWO2 BLOK

	A surface may contain any number of 'blocks' which hold texture layers or
	shaders. The blocks are defined by a sub-chunk with the following format. 

	BLOK { 
			type { ordinal[ID4], header[SUB-CHUNK] * },
					attributes[SUB-CHUNK] * 
	} 

	Immediately inside the block sub-chunk is another sub-chunk which is the
	header for the block. The type code for this header block defines the type
	of the block. This header block contains an ordinal string followed by any
	number and type of header sub-chunks. Following the required header sub-chunk,
	sub-chunks which contain the attributes of this block are found in any order.
	The chunks here will depend on the overall type of the block. 

	Ordinary string compare functions are used to sort the ordinal strings. These
	are never read by the user, so they can contain any characters from 1 to 255
	and tend to be very short. The only rule is that an ordinal string must not
	end with a 1 byte, since that prevents arbitrary insertion. 

	The header for any block can contain the following sub-chunks, although some
	are ignored for different block types. 
*/
void LWSurface::readBlok(){
	LWSurfaceBlok *blok = new LWSurfaceBlok( this );
	blok->processBlok();
}


};  //  namespace Imports


