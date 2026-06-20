/////////////////////////////////////////////////////////////
// Flash Plugin and Player
// Copyright (C) 1998,1999 Olivier Debon
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
// 
///////////////////////////////////////////////////////////////
//  Author : Olivier Debon  <odebon@club-internet.fr>
//  

static char *rcsid = "$Id";

#include "cxform.h"

long
Cxform::getRed(long v) {
	return (long)(ra*v+rb);
}

long
Cxform::getGreen(long v) {
	return (long)(ga*v+gb);
}

long
Cxform::getBlue(long v) {
	return (long)(ba*v+bb);
}

float
Cxform::getAlpha(float v) {
	return aa*v+ab;
}

Color
Cxform::getColor(Color color) {
	Color newColor;

	newColor.red = getRed(color.red);
	newColor.green = getGreen(color.green);
	newColor.blue = getBlue(color.blue);
	if (newColor.red > 255) newColor.red = 255;
	if (newColor.green > 255) newColor.green = 255;
	if (newColor.blue > 255) newColor.blue = 255;
	newColor.alpha = getAlpha(color.alpha);

	return newColor;
}
