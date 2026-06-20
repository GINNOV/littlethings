
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta, Sean O' Neil
	tksuoran@cc.helsinki.fi, s_p_oneil@hotmail.com

		Adapted from

		The Universe Development Kit
		Copyright (C) 2000	Sean O'Neil
		s_p_oneil@hotmail.com

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

#include "config.h"
#include "UniverseDevelopmentKit/CMaster.h"
#include "glElite/RoamSphere.h"
using namespace UniverseDevelopmentKit;


int roam_triangle_count = 0;


namespace Application {


//void RoamSphere::Draw( C3DBase *pCamera, GLenum nMode ){
/*virtual*/ void RoamSphere::drawElements( Projection *p ){
//void CROAMSphere::Draw(C3DBase *pCamera, bool bTexture)

	BuildIndexList();
	int nStart          = 0;
	int nSize           = m_nSize;
	roam_triangle_count = m_nSize;

#	if !defined( USE_TINY_GL )

	while(nSize > 60000){
		glDrawElements( GL_TRIANGLES, 60000, GL_UNSIGNED_SHORT, &m_nIndex[nStart] );
		nSize -= 60000;
		nStart += 60000;
	}
	glDrawElements( GL_TRIANGLES, nSize, GL_UNSIGNED_SHORT, &m_nIndex[nStart] );

#	else

	glBegin( GL_TRIANGLES );
	for( int i=0; i<m_nSize; i++ ){
		glNormal3fv( CVertex::Array[ m_nIndex[i] ]->m_vNormal	);
		glVertex3fv( CVertex::Array[ m_nIndex[i] ]->m_vPosition );
	}
	glEnd();

#	endif

}


};	//	namespace Application


#endif 

