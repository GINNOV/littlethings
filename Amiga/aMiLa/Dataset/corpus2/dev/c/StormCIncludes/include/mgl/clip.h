/*
 * $Id: clip.h,v 1.2 2000/10/20 11:32:30 nobody Exp $
 *
 * $Date: 2000/10/20 11:32:30 $
 * $Revision: 1.2 $
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

void        hc_CodePoint(MGLVertex *v);
GLboolean   hc_DecideFrontface(GLcontext context, MGLVertex *a, MGLVertex *b, MGLVertex *c, GLubyte outcode);

/*
** This structure holds the polygon data for clipping.
*/
typedef struct MGLPolygon_t
{
	int numverts;
	int verts[MGL_MAXVERTS];
} MGLPolygon;

void        dh_DrawPoly(GLcontext context, MGLPolygon *poly);
void        hc_ClipAndDrawPoly(GLcontext context, MGLPolygon *poly, GLubyte or_codes);

#endif



