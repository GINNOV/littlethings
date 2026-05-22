/*
 * $Id: clip.h 101 2005-03-04 16:44:41Z tfrieden $
 *
 * $Date: 2005-03-04 11:44:41 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 101 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */


#ifndef _CLIP_H
#define _CLIP_H

#include "mgl/mgltypes.h"

void        hc_CodePoint(GLcontext context, MGLVertex *v);
GLboolean   hc_DecideFrontface(GLcontext context, MGLVertex *a, MGLVertex *b, MGLVertex *c, GLuint outcode);
void        dh_DrawPoly(GLcontext context, MGLPolygon *poly);
void        hc_ClipAndDrawPoly(GLcontext context, MGLPolygon *poly, GLuint or_codes);

#endif



