
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
	\file
	\ingroup g_lightwave
	\author  Timo Suoranta
	\brief   Lightwave file format interpreter tools
	\date    1999, 2000, 2001
*/


#ifndef TEDDY_IMPORTS_LW_DEF_H
#define TEDDY_IMPORTS_LW_DEF_H


#include "Graphics/Color.h"
#include "Maths/Vector.h"
using namespace Graphics;
using namespace Maths;


namespace Imports {


//  Types
typedef unsigned long  ID4;
typedef signed char    I1;
typedef signed short   I2;
typedef signed long    I4;
typedef unsigned char  U1;
typedef unsigned short U2;
typedef unsigned long  U4;
typedef float          F4;
typedef char          *S0;
typedef unsigned long  VX;
typedef Color          COL4;
typedef Color          COL12;
typedef Vector         VEC12;
typedef float          FP4;
typedef float          ANG4;
typedef char          *FNAM0;

//!  Generate long chunk id from four chars
#define MAKE_ID(a,b,c,d)	\
	((unsigned long) (a)<<24 | (unsigned long) (b)<<16 | \
	 (unsigned long) (c)<<8 | (unsigned long) (d))


//  LWOB Surface flags
#define LW_SF_LUMINOUS          (1<< 0)
#define LW_SF_OUTLINE           (1<< 1)
#define LW_SF_SMOOTHING         (1<< 2)
#define LW_SF_COLOR_HILIGHTS    (1<< 3)
#define LW_SF_COLOR_FILTER      (1<< 4)
#define LW_SF_OPAQUE_EDGE       (1<< 5)
#define LW_SF_TRANSPARENT_EDGE  (1<< 6)
#define LW_SF_SHARP_TERMINATOR  (1<< 7)
#define LW_SF_DOUBLE_SIDED      (1<< 8)
#define LW_SF_ADDITIVE          (1<< 9)
#define LW_SF_SHADOW_ALPHA      (1<<10)

#define LW_PLANAR_IMAGE_MAP      1
#define LW_CYLINDRICAL_IMAGE_MAP 2
#define LW_SPHERICAL_IMAGE_MAP   3
#define LW_CUBIC_IMAGE_MAP       4

#define LW_AXIS_X 0
#define LW_AXIS_Y 1
#define LW_AXIS_Z 2

#define LW_ALPHA_MODE_DISABLED   0
#define LW_ALPHA_MODE_CONSTANT   1
#define LW_ALPHA_MODE_OPACITY    2  //  default
#define LW_ALPHA_MODE_SHADOW     3

//  LWO2::BLOK::OPAC
#define LW_OPACITY_TYPE_ADDITIVE             0
#define LW_OPACITY_TYPE_SUBSTRACTIVE         1
#define LW_OPACITY_TYPE_DIFFERENCE           2
#define LW_OPACITY_TYPE_MULTIPLY             3
#define LW_OPACITY_TYPE_DIVIDE               4
#define LW_OPACITY_TYPE_ALPHA                5
#define LW_OPACITY_TYPE_TEXTURE_DISPLACEMENT 6

//  LWO2::BLOK::PROJ
#define LW_PROJECTION_PLANAR      0
#define LW_PROJECTION_CYLINDRICAL 1
#define LW_PROJECTION_SPHERICAL   2
#define LW_PROJECTION_CUBIC       3
#define LW_PROJECTION_FRONT       4
#define LW_PROJECTION_UV          5

//  LWO2::BLOK_WRAP
#define LW_WRAP_RESET  0
#define LW_WRAP_REPEAT 1
#define LW_WRAP_MIRROR 2
#define LW_WRAP_EDGE   3


#define ID_FORM     MAKE_ID('F','O','R','M')
#define ID_LWOB     MAKE_ID('L','W','O','B')  //  LWOB
#define ID_LWLO     MAKE_ID('L','W','L','O')  //  LWLO
#define ID_LWO2     MAKE_ID('L','W','O','2')

/**  PRIMARY CHUNK ID  **/
#define ID_LAYR		MAKE_ID('L','A','Y','R')
#define ID_PNTS		MAKE_ID('P','N','T','S')
#define ID_VMAP		MAKE_ID('V','M','A','P')
#define ID_POLS		MAKE_ID('P','O','L','S')

#define ID_CRVS		MAKE_ID('C','R','V','S')  // LWOB only
#define ID_PCHS		MAKE_ID('P','C','H','S')  // LWOB only
#define ID_SRFS     MAKE_ID('S','R','F','S')  // LWOB only
#define ID_VLUM     MAKE_ID('V','L','U','M')  // LWOB only
#define ID_VDIF     MAKE_ID('V','D','I','F')  // LWOB only
#define ID_VSPC     MAKE_ID('V','S','P','C')  // LWOB only
#define ID_VRFL     MAKE_ID('V','R','F','L')  // LWOB only
#define ID_VTRN     MAKE_ID('V','T','R','N')  // LWOB only

#define ID_RFLT     MAKE_ID('R','F','L','T')  // LWOB only
#define ID_EDGE     MAKE_ID('E','D','G','E')  // LWOB only
#define ID_SDAT     MAKE_ID('S','D','A','T')  // LWOB only
#define ID_IMSQ     MAKE_ID('I','M','S','Q')  // LWOB only
#define ID_FLYR     MAKE_ID('F','L','Y','R')  // LWOB only
#define ID_IMCC     MAKE_ID('I','M','C','C')  // LWOB only
#define ID_CTEX     MAKE_ID('C','T','E','X')  // LWOB only
#define ID_DTEX     MAKE_ID('D','T','E','X')  // LWOB only
#define ID_STEX     MAKE_ID('S','T','E','X')  // LWOB only
#define ID_RTEX     MAKE_ID('R','T','E','X')  // LWOB only
#define ID_TTEX     MAKE_ID('T','T','E','X')  // LWOB only
#define ID_LTEX     MAKE_ID('L','T','E','X')  // LWOB only
#define ID_BTEX     MAKE_ID('B','T','E','X')  // LWOB only

#define ID_TFLG     MAKE_ID('T','F','L','G')  // LWOB only
#define ID_TSIZ     MAKE_ID('T','S','I','Z')  // LWOB only
#define ID_TCTR     MAKE_ID('T','C','T','R')  // LWOB only
#define ID_TFAL     MAKE_ID('T','F','A','L')  // LWOB only
#define ID_TVEL     MAKE_ID('T','V','E','L')  // LWOB only
#define ID_TREF     MAKE_ID('T','R','E','F')  // LWOB only
#define ID_TCLR     MAKE_ID('T','C','L','R')  // LWOB only
#define ID_TVAL     MAKE_ID('T','V','A','L')  // LWOB only
#define ID_TFP      MAKE_ID('T','F','P',' ')  // LWOB only
#define ID_TIP      MAKE_ID('T','I','P',' ')  // LWOB only
#define ID_TSP      MAKE_ID('T','S','P',' ')  // LWOB only
#define ID_TFRQ     MAKE_ID('T','F','R','Q')  // LWOB only
#define ID_TALP     MAKE_ID('T','A','L','P')  // LWOB only
#define ID_TWRP     MAKE_ID('T','W','R','P')  // LWOB only
#define ID_TAAS     MAKE_ID('T','A','A','S')  // LWOB only
#define ID_TOPC     MAKE_ID('T','O','P','C')  // LWOB only


#define ID_TAGS		MAKE_ID('T','A','G','S')
#define ID_PTAG		MAKE_ID('P','T','A','G')
#define ID_ENVL		MAKE_ID('E','N','V','L')
#define ID_CLIP		MAKE_ID('C','L','I','P')
#define ID_SURF		MAKE_ID('S','U','R','F')
#define ID_BBOX		MAKE_ID('B','B','O','X')
#define ID_DESC		MAKE_ID('D','E','S','C')
#define ID_TEXT		MAKE_ID('T','E','X','T')
#define ID_ICON		MAKE_ID('I','C','O','N')

/**  POLS TYPE  **/
#define ID_FACE		MAKE_ID('F','A','C','E')
#define ID_CURV		MAKE_ID('C','U','R','V')  // was ID_CRVS
#define ID_PRCH		MAKE_ID('P','T','C','H')  // was ID_PCHS
#define ID_MBAL		MAKE_ID('M','B','A','L')
#define ID_BONE		MAKE_ID('B','O','N','E')

/**  PTAG TYPE  **/
#define ID_SURF		MAKE_ID('S','U','R','F')
#define ID_BNID		MAKE_ID('B','N','I','D')
#define ID_SGMP		MAKE_ID('S','G','M','P')
#define ID_PART		MAKE_ID('P','A','R','T')

/**  IMAGE SUB-CHUNK ID  */
#define ID_STIL		MAKE_ID('S','T','I','L')
#define ID_ISEQ		MAKE_ID('I','S','E','Q')
#define ID_ANIM		MAKE_ID('A','N','I','M')
#define ID_XREF		MAKE_ID('X','R','E','F')
#define ID_STCC		MAKE_ID('S','T','C','C')
#define ID_CONT		MAKE_ID('C','O','N','T')
#define ID_BRIT		MAKE_ID('B','R','I','T')
#define ID_SATR		MAKE_ID('S','A','T','R')
#define ID_HUE		MAKE_ID('H','U','E',' ')
#define ID_GAMM		MAKE_ID('G','A','M','M')
#define ID_NEGA		MAKE_ID('N','E','G','A')
#define ID_CROP		MAKE_ID('C','R','O','P')
#define ID_ALPH		MAKE_ID('A','L','P','H')
#define ID_COMP		MAKE_ID('C','O','M','P')
#define ID_IFLT		MAKE_ID('I','F','L','T')
#define ID_PFLT		MAKE_ID('P','F','L','T')

/**  ENVELOPE SUB-CHUNK  **/
#define ID_PRE		MAKE_ID('P','R','E',' ')
#define ID_POST		MAKE_ID('P','O','S','T')
#define ID_KEY		MAKE_ID('K','E','Y',' ')
#define ID_SPAN		MAKE_ID('S','P','A','N')
#define ID_CHAN		MAKE_ID('C','H','A','N')

/**  SURFACE SUB-CHUNK ID  */
#define ID_COLR		MAKE_ID('C','O','L','R')
#define ID_DIFF		MAKE_ID('D','I','F','F')
#define ID_LUMI		MAKE_ID('L','U','M','I')
#define ID_SPEC		MAKE_ID('S','P','E','C')
#define ID_REFL		MAKE_ID('R','E','F','L')
#define ID_TRAN		MAKE_ID('T','R','A','N')
#define ID_TRNL		MAKE_ID('T','R','N','L')
#define ID_GLOS		MAKE_ID('G','L','O','S')
#define ID_SHRP		MAKE_ID('S','H','R','P')
#define ID_BUMP		MAKE_ID('B','U','M','P')
#define ID_SIDE		MAKE_ID('S','I','D','E')
#define ID_SMAN		MAKE_ID('S','M','A','N')
#define ID_RFOP		MAKE_ID('R','F','O','P')
#define ID_RIMG		MAKE_ID('R','I','M','G')
#define ID_RSAN		MAKE_ID('R','S','A','N')
#define ID_RIND		MAKE_ID('R','I','N','D')
#define ID_CLRH		MAKE_ID('C','L','R','H')
#define ID_TROP		MAKE_ID('T','R','O','P')
#define ID_TIMG		MAKE_ID('T','I','M','G')
#define ID_CLRF		MAKE_ID('C','L','R','F')
#define ID_ADTR		MAKE_ID('A','D','T','R')
#define ID_GLOW		MAKE_ID('G','L','O','W')
#define ID_LINE		MAKE_ID('L','I','N','E')
#define ID_ALPH		MAKE_ID('A','L','P','H')
#define ID_AVAL		MAKE_ID('A','V','A','L')
#define ID_GVAL		MAKE_ID('G','V','A','L')
#define ID_BLOK		MAKE_ID('B','L','O','K')
#define ID_LCOL		MAKE_ID('L','C','O','L')  //  Documentation?
#define ID_LSIZ		MAKE_ID('L','S','I','Z')  //
#define ID_CMNT		MAKE_ID('C','M','N','T')  //

/**  TEXTURE LAYER  **/
#define ID_CHAN		MAKE_ID('C','H','A','N')
#define ID_TYPE		MAKE_ID('T','Y','P','E')
#define ID_NAME		MAKE_ID('N','A','M','E')
#define ID_ENAB		MAKE_ID('E','N','A','B')
#define ID_OPAC		MAKE_ID('O','P','A','C')
#define ID_FLAG		MAKE_ID('F','L','A','G')
#define ID_PROJ		MAKE_ID('P','R','O','J')
#define ID_STCK		MAKE_ID('S','T','C','K')
#define ID_TAMP		MAKE_ID('T','A','M','P')

/**  TEXTURE MAPPING  **/
#define ID_TMAP		MAKE_ID('T','M','A','P')
#define ID_AXIS		MAKE_ID('A','X','I','S')
#define ID_CNTR		MAKE_ID('C','N','T','R')
#define ID_SIZE		MAKE_ID('S','I','Z','E')
#define ID_ROTA		MAKE_ID('R','O','T','A')
#define ID_OREF		MAKE_ID('O','R','E','F')
#define ID_FALL		MAKE_ID('F','A','L','L')
#define ID_CSYS		MAKE_ID('C','S','Y','S')

/**  IMAGE MAP  **/
#define ID_IMAP		MAKE_ID('I','M','A','P')
#define ID_IMAG		MAKE_ID('I','M','A','G')
#define ID_WRAP		MAKE_ID('W','R','A','P')
#define ID_WRPW		MAKE_ID('W','R','P','W')
#define ID_WRPH		MAKE_ID('W','R','P','H')
#define ID_VMAP		MAKE_ID('V','M','A','P')
#define ID_AAST		MAKE_ID('A','A','S','T')
#define ID_PIXB		MAKE_ID('P','I','X','B')

/**  PROCUDUAL TEXTURE  **/
#define ID_PROC		MAKE_ID('P','R','O','C')
#define ID_COLR		MAKE_ID('C','O','L','R')
#define ID_VALU		MAKE_ID('V','A','L','U')
#define ID_FUNC		MAKE_ID('F','U','N','C')
#define ID_FTPS		MAKE_ID('F','T','P','S')
#define ID_ITPS		MAKE_ID('I','T','P','S')
#define ID_ETPS		MAKE_ID('E','T','P','S')

/**  GRADIENT **/
#define ID_GRAD		MAKE_ID('G','R','A','D')
#define ID_GRST		MAKE_ID('G','R','S','T')
#define ID_GREN		MAKE_ID('G','R','E','N')

/**  SHADER PLUGIN  */
#define ID_SHDR		MAKE_ID('S','H','D','R')
#define ID_DATA		MAKE_ID('D','A','T','A')


/**  VERTEX MAPPING  */
#define ID_TXUV		MAKE_ID('T','X','U','V')
#define ID_MNUW		MAKE_ID('M','N','U','W')
#define ID_MORF		MAKE_ID('M','O','R','F')
#define ID_SPOT		MAKE_ID('S','P','O','T')
#define ID_RGBA		MAKE_ID('R','G','B','A')

#define ID_PNAM		MAKE_ID('P','N','A','M') 
#define ID_INAM		MAKE_ID('I','N','A','M') 
#define ID_GRPT		MAKE_ID('G','R','P','T') 
#define ID_FKEY		MAKE_ID('F','K','E','Y') 
#define ID_IKEY		MAKE_ID('I','K','E','Y') 


};  //  namespace Imports


#endif  //  TEDDY_IMPORTS_LW_DEF_H

