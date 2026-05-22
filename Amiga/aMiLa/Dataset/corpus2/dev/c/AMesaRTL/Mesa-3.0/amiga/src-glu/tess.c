/* $Id: tess.c,v 1.9 1998/06/01 01:10:29 brianp Exp $ */

/*
 * Mesa 3-D graphics library
 * Version:  2.6
 * Copyright (C) 1995-1997  Brian Paul
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


/*
 * tess.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * File created from tess.c ver 1.8 and glu.h ver 1.9 using GenProtos
 *
 * Version 1.1  04 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to v1.9 of tess.c
 *
 */


/*
 * This file is part of the polygon tesselation code contributed by
 * Bogdan Sikorski
 */


#ifdef PC_HEADER
#include "all.h"
#else
#include <math.h>
#include <stdlib.h>
#include "tess.h"
#endif


/*
 * This is ugly, but seems the easiest way to do things to make the
 * code work under YellowBox for Windows
 */
#if defined(OPENSTEP) && defined(CALLBACK)
#undef CALLBACK
#define CALLBACK
#endif


extern void tess_test_polygon(GLUtriangulatorObj *);
extern void tess_find_contour_hierarchies(GLUtriangulatorObj *);
extern void tess_handle_holes(GLUtriangulatorObj *);
extern void tess_tesselate(GLUtriangulatorObj *);
extern void tess_tesselate_with_edge_flag(GLUtriangulatorObj *);
static void delete_contours(GLUtriangulatorObj *);

#ifdef __CYGWIN32__
#define _CALLBACK
#else
#define _CALLBACK CALLBACK
#endif

void init_callbacks(tess_callbacks *callbacks)
{
   callbacks->begin = ( void (_CALLBACK*)(GLenum) ) 0;
   callbacks->edgeFlag = ( void (_CALLBACK*)(GLboolean) ) 0;
   callbacks->vertex = ( void (_CALLBACK*)(void*) ) 0;
   callbacks->end = ( void (_CALLBACK*)(void) ) 0;
   callbacks->error = ( void (_CALLBACK*)(GLenum) ) 0;
}

void tess_call_user_error(GLUtriangulatorObj *tobj,
	GLenum gluerr)
{
	if(tobj->error==GLU_NO_ERROR)
		tobj->error=gluerr;
	if(tobj->callbacks.error!=NULL)
		(tobj->callbacks.error)(gluerr);
}

__asm __saveds GLUtriangulatorObj* APIENTRY gluNewTess( void )
{
   GLUtriangulatorObj *tobj;

	if((tobj=(GLUtriangulatorObj *)
		malloc(sizeof(struct GLUtriangulatorObj)))==NULL)
		return NULL;
	tobj->contours=tobj->last_contour=NULL;
	init_callbacks(&tobj->callbacks);
	tobj->error=GLU_NO_ERROR;
	tobj->current_polygon=NULL;
	tobj->contour_cnt=0;
	return tobj;
}


__asm __saveds void APIENTRY gluTessCallback( register __a0 GLUtriangulatorObj *tobj, register __d0 GLenum which,
                                              register __a1 void (CALLBACK *fn)() )
{
	switch(which)
	{
		case GLU_BEGIN:
			tobj->callbacks.begin = (void (_CALLBACK*)(GLenum)) fn;
			break;
		case GLU_EDGE_FLAG:
			tobj->callbacks.edgeFlag = (void (_CALLBACK*)(GLboolean)) fn;
			break;
		case GLU_VERTEX:
			tobj->callbacks.vertex = (void (_CALLBACK*)(void *)) fn;
			break;
		case GLU_END:
			tobj->callbacks.end = (void (_CALLBACK*)(void)) fn;
			break;
		case GLU_ERROR:
			tobj->callbacks.error = (void (_CALLBACK*)(GLenum)) fn;
			break;
		default:
			tobj->error=GLU_INVALID_ENUM;
			break;
	}
}



__asm __saveds void APIENTRY gluDeleteTess( register __a0 GLUtriangulatorObj *tobj )
{
	if(tobj->error==GLU_NO_ERROR && tobj->contour_cnt)
		/* was gluEndPolygon called? */
		tess_call_user_error(tobj,GLU_TESS_ERROR1);
	/* delete all internal structures */
	delete_contours(tobj);
	free(tobj);
}


__asm __saveds void APIENTRY gluBeginPolygon( register __a0 GLUtriangulatorObj *tobj )
{
/*
	if(tobj->error!=GLU_NO_ERROR)
		return;
*/
        tobj->error = GLU_NO_ERROR;
	if(tobj->current_polygon!=NULL)
	{
		/* gluEndPolygon was not called */
		tess_call_user_error(tobj,GLU_TESS_ERROR1);
		/* delete all internal structures */
		delete_contours(tobj);
	}
	else
	{
		if((tobj->current_polygon=
			(tess_polygon *)malloc(sizeof(tess_polygon)))==NULL)
		{
			tess_call_user_error(tobj,GLU_OUT_OF_MEMORY);
			return;
		}
		tobj->current_polygon->vertex_cnt=0;
		tobj->current_polygon->vertices=
			tobj->current_polygon->last_vertex=NULL;
	}
}


__asm __saveds void APIENTRY gluEndPolygon( register __a0 GLUtriangulatorObj *tobj )
{
	/*tess_contour *contour_ptr;*/

	/* there was an error */
	if(tobj->error!=GLU_NO_ERROR) goto end;

	/* check if gluBeginPolygon was called */
	if(tobj->current_polygon==NULL)
	{
		tess_call_user_error(tobj,GLU_TESS_ERROR2);
		return;
	}
	tess_test_polygon(tobj);
	/* there was an error */
	if(tobj->error!=GLU_NO_ERROR) goto end;

	/* any real contours? */
	if(tobj->contour_cnt==0)
	{
		/* delete all internal structures */
		delete_contours(tobj);
		return;
	}
	tess_find_contour_hierarchies(tobj);
	/* there was an error */
	if(tobj->error!=GLU_NO_ERROR) goto end;

	tess_handle_holes(tobj);
	/* there was an error */
	if(tobj->error!=GLU_NO_ERROR) goto end;

	/* if no callbacks, nothing to do */
	if(tobj->callbacks.begin!=NULL && tobj->callbacks.vertex!=NULL &&
		tobj->callbacks.end!=NULL)
	{
		if(tobj->callbacks.edgeFlag==NULL)
			tess_tesselate(tobj);
		else
			tess_tesselate_with_edge_flag(tobj);
	}

end:
	/* delete all internal structures */
	delete_contours(tobj);
}


__asm __saveds void APIENTRY gluNextContour( register __a0 GLUtriangulatorObj *tobj, register __d0 GLenum type )
{
	if(tobj->error!=GLU_NO_ERROR)
		return;
	if(tobj->current_polygon==NULL)
	{
		tess_call_user_error(tobj,GLU_TESS_ERROR2);
		return;
	}
	/* first contour? */
	if(tobj->current_polygon->vertex_cnt)
		tess_test_polygon(tobj);
}


__asm __saveds void APIENTRY gluTessVertex( register __a0 GLUtriangulatorObj *tobj, register __a1 GLdouble v[3], register __a2 void *data )
{
	tess_polygon *polygon=tobj->current_polygon;
	tess_vertex *last_vertex_ptr;

	if(tobj->error!=GLU_NO_ERROR)
		return;
	if(polygon==NULL)
	{
		tess_call_user_error(tobj,GLU_TESS_ERROR2);
		return;
	}
	last_vertex_ptr=polygon->last_vertex;
	if(last_vertex_ptr==NULL)
	{
		if((last_vertex_ptr=(tess_vertex *)
			malloc(sizeof(tess_vertex)))==NULL)
		{
			tess_call_user_error(tobj,GLU_OUT_OF_MEMORY);
			return;
		}
		polygon->vertices=last_vertex_ptr;
		polygon->last_vertex=last_vertex_ptr;
		last_vertex_ptr->data=data;
		last_vertex_ptr->location[0]=v[0];
		last_vertex_ptr->location[1]=v[1];
		last_vertex_ptr->location[2]=v[2];
		last_vertex_ptr->next=NULL;
		last_vertex_ptr->previous=NULL;
		++(polygon->vertex_cnt);
	}
	else
	{
		tess_vertex *vertex_ptr;

		/* same point twice? */
		if(fabs(last_vertex_ptr->location[0]-v[0]) < EPSILON &&
			fabs(last_vertex_ptr->location[1]-v[1]) < EPSILON &&
			fabs(last_vertex_ptr->location[2]-v[2]) < EPSILON)
		{
			tess_call_user_error(tobj,GLU_TESS_ERROR6);
			return;
		}
		if((vertex_ptr=(tess_vertex *)
			malloc(sizeof(tess_vertex)))==NULL)
		{
			tess_call_user_error(tobj,GLU_OUT_OF_MEMORY);
			return;
		}
		vertex_ptr->data=data;
		vertex_ptr->location[0]=v[0];
		vertex_ptr->location[1]=v[1];
		vertex_ptr->location[2]=v[2];
		vertex_ptr->next=NULL;
		vertex_ptr->previous=last_vertex_ptr;
		++(polygon->vertex_cnt);
		last_vertex_ptr->next=vertex_ptr;
		polygon->last_vertex=vertex_ptr;
	}
}


static void delete_contours(GLUtriangulatorObj *tobj)
{
	tess_polygon *polygon=tobj->current_polygon;
	tess_contour *contour,*contour_tmp;
	tess_vertex *vertex,*vertex_tmp;

	/* remove current_polygon list - if exists due to detected error */
	if(polygon!=NULL)
	{
		if (polygon->vertices)
		{
			for(vertex=polygon->vertices;vertex!=polygon->last_vertex;)
			{
				vertex_tmp=vertex->next;
				free(vertex);
				vertex=vertex_tmp;
			}
			free(vertex);
		}
		free(polygon);
		tobj->current_polygon=NULL;
	}
	/* remove all contour data */
	for(contour=tobj->contours;contour!=NULL;)
	{
		for(vertex=contour->vertices;vertex!=contour->last_vertex;)
		{
			vertex_tmp=vertex->next;
			free(vertex);
			vertex=vertex_tmp;
		}
		free(vertex);
		contour_tmp=contour->next;
		free(contour);
		contour=contour_tmp;
	}
	tobj->contours=tobj->last_contour=NULL;
	tobj->contour_cnt=0;
}



