/*
     PLIB - A Suite of Portable Game Libraries
     Copyright (C) 2001  Steve Baker

     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.

     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with this program; if not, write to the Free Software
     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

     For further information visit http://plib.sourceforge.net

     $Id: WavingFlag.h 1551 2002-09-01 12:04:53Z ude $
*/


#ifndef _WAVINGFLAG_
#define _WAVINGFLAG_

class WavingFlag
{
public:
	WavingFlag( sgVec4 color, char *texture1=NULL, char *texture2=NULL, int s=5 );
	~WavingFlag();
	void animate( float time, float windVelocity );
	ssgEntity *getObject();
private:
	ssgBranch *branch;
	ssgColourArray *colors;
	ssgNormalArray *normals;
	ssgTexCoordArray *texCoords;
	ssgVertexArray *vertices;
	int size;
};

#endif
