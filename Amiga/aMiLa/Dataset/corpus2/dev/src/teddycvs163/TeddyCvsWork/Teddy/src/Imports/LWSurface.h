
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
	\class   LWSurface
	\ingroup g_imports
	\author  Timo Suoranta
	\brief   Parser for LightWave object file surface subchunks
	\date    1999, 2000, 2001
*/


#ifndef TEDDY_IMPORTS_LW_SURFACE_H
#define TEDDY_IMPORTS_LW_SURFACE_H


#include "Materials/Material.h"
#include "Graphics/Color.h"
#include "SysSupport/StdMap.h"
#include "Imports/lwdef.h"
namespace Models { class Mesh; };
using namespace Materials;
using namespace Models;


namespace Imports {


class LWClip;
class LWEnvelope;
class LWFile;
class LWLayer;
class LWMesh;
class LWSurfaceBlok;
class LWTexture;


typedef map<int, LWTexture     *, less<int> > int_to_LWTexture;
typedef map<int, LWSurfaceBlok *, less<int> > int_to_LWSurfaceBlok;


class LWSurface : public Material {
public:
	LWSurface( LWLayer *layer, Mesh *mesh, const char *name );
	virtual ~LWSurface();

	void          processSubChunk ();
	void          setMesh         ( Mesh *mesh );
	LWLayer      *getLayer        ();
	Mesh         *getMesh         ();
	void          endSurface      ();
	virtual void  setTexture      ( Texture *t, bool enable=false );
												  
protected:
	int  getMapType          ( const char *s );
	void endTexture          ();
	void useTextureColormap  ();

	void readBaseColor_COL4  ();  //  COLR
	void readStateFlags_U2   ();  //  FLAG
	void readLuminosity_IP2  ();  //  LUMI
	void readLuminosity_FP4  ();  //  VLUM
	void readDiffuse_IP2     ();  //  DIFF
	void readDiffuse_FP4     ();  //  VDIF
	void readSpecular_IP2_4  ();  //  SPEC
	void readSpecular_FP4    ();  //  VSPC
	void readReflection_IP2_4();  //  REFL
	void readReflection_FP4  ();  //  VRFL
	void readTransparency_IP2();  //  TRAN
	void readTransparency_FP4();  //  VTRN

	void readSpecularGlossiness_I2_4         ();  //  GLOS
	void readReflectionMode_U2               ();  //  RFLT
	void readReflectionMapImage_FNAM0        ();  //  RIMG
	void readReflectionMapImageSeamAngle_DEG4();  //  RSAN
	void readRefractiveIndex_F4              ();  //  RIND
	void readEdgeTransparencyTreshold_F4     ();  //  EDGE
	void readMaxSmoothingAngle_DEG4          ();  //  SMAN

	void readAlphaMode_U2_U2           ();  //  ALPH
	void readShaderPlugin_S0           ();  //  SHDR
	void readShaderData_f              ();  //  SDAT
	void readSequenceOptions_U2_U2_U2  ();  //  IMSQ
	void readFlyerClipOptions_U4_U4    ();  //  FLYR
	void readColorCycleOptions_U2_U2_U2();  //  IMCC

	void readColorTexture_S0       ();  //  CTEX
	void readDiffuseTexture_S0     ();  //  DTEX
	void readSpecularTexture_S0    ();  //  STEX
	void readReflectionTexture_S0  ();  //  RTEX
	void readTransparencyTexture_S0();  //  TTEX
	void readLuminosityTexture_S0  ();  //  LTEX
	void readBumpTexture_S0        ();  //  BTEX

	void readBaseColor_COL12_VX                 ();
	void readLuminosity_FP4_VX                  ();
	void readDiffuse_FP4_VX                     ();
	void readSpecular_FP4_VX                    ();
	void readReflection_FP4_VX                  ();
	void readTransparency_FP4_VX                ();
	void readTranslucency_FP4_VX                ();
	void readSpecularGlossiness_FP4_VX          ();
	void readDiffuseSharpness_FP4_VX            ();
	void readBumpIntensity_FP4_VX               ();
	void readPolygonSidedness_U2                ();
	void readMaxSmoothingAngle_ANG4             ();
	void readReflectionOptions_U2               ();
	void readReflectionMapImage_VX              ();
	void readReflectionMapImageSeamAngle_ANG4_VX();
	void readRefractiveIndex_F4_VX              ();
	void readColorHighlights_FP4_VX             ();
	void readTransparencyOptions_U2             ();
	void readRefractionMapImage_VX              ();
	void readColorFilter_FP4_VX                 ();
	void readAdditiveTransparency_FP4_VX        ();
	void readGlowEffect_U2_F4_VX_F4_VX          ();
	void readRenderOutlines_U2_F4_VX_COL12_VX   ();
	void readAlphaMode_U2_FP4                   ();
	void readBlok                               ();

	void readComment_S0                         ();

protected:
	LWFile               *f;
	LWLayer              *layer;
	Mesh                 *mesh;
	LWMesh               *root_mesh;
	ID4                   subchunk_id;
	U4                    subchunk_length;
	Color                 baseColor;
	long                  stateFlags;
	float                 luminosity_p;
	float                 diffuse_p;
	float                 specular_p;
	float                 reflection_p;
	float                 transparency_p;
	float                 translucency_p;  //  LWO2
	float                 specularGlossiness_p;
	long                  reflectionMode;
	unsigned char         reflectionMapImage[256];
	float                 reflectionMapImageSeamAngle;
	float                 refractiveIndex;
	float                 edgeTransparencyTreshold;
	float                 maxSmoothingAngle;
	long                  alphaMode;
	int_to_LWTexture      textures;
	int_to_LWSurfaceBlok  bloks;
	LWTexture            *current_texture;
	// shaderPlugin		 
	// shaderData
	// sequenceOptions
	// flyerClipOptions
	// colorCycleOptions

	static char          *LW_ImageMapStrings[];
};


};  //  namespace Imports


#endif  //  TEDDY_IMPORTS_LW_SURFACE_H


