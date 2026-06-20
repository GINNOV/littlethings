/* $Id: glu.h,v 1.9 1998/01/16 02:29:26 brianp Exp $ */

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
 * glu.h
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * File created from glu.h ver 1.9 using GenProtos
 *
 * Version 1.1  09 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Added __stdargs to gluLookAt
 *
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Stubs are now #defined so that they pass the
 *   current mesamainBase rather than the global one
 */


#ifndef GLU_H
#define GLU_H


#if defined(USE_MGL_NAMESPACE)
#include "glu_mangle.h"
#endif


#ifdef __cplusplus
extern "C" {
#endif

#ifndef MAKE_MESAMAINLIB
#include "pragmas/gl_pragmas.h"
#endif

#include "GL/gl.h"


#ifdef macintosh
	#pragma enumsalwaysint on
	#if PRAGMA_IMPORT_SUPPORTED
	#pragma import on
	#endif
#endif


#define GLU_VERSION_1_1		1


#define GLU_TRUE   GL_TRUE
#define GLU_FALSE  GL_FALSE


enum {
	/* Normal vectors */
	GLU_SMOOTH	= 100000,
	GLU_FLAT	= 100001,
	GLU_NONE	= 100002,

	/* Quadric draw styles */
	GLU_POINT	= 100010,
	GLU_LINE	= 100011,
	GLU_FILL	= 100012,
	GLU_SILHOUETTE	= 100013,

	/* Quadric orientation */
	GLU_OUTSIDE	= 100020,
	GLU_INSIDE	= 100021,

	/* Tesselator */
	GLU_BEGIN	= 100100,
	GLU_VERTEX	= 100101,
	GLU_END		= 100102,
	GLU_ERROR	= 100103,
	GLU_EDGE_FLAG	= 100104,

	/* Contour types */
	GLU_CW		= 100120,
	GLU_CCW		= 100121,
	GLU_INTERIOR	= 100122,
	GLU_EXTERIOR	= 100123,
	GLU_UNKNOWN	= 100124,

	/* Tesselation errors */
	GLU_TESS_ERROR1	= 100151,  /* missing gluEndPolygon */
	GLU_TESS_ERROR2 = 100152,  /* missing gluBeginPolygon */
	GLU_TESS_ERROR3 = 100153,  /* misoriented contour */
	GLU_TESS_ERROR4 = 100154,  /* vertex/edge intersection */
	GLU_TESS_ERROR5 = 100155,  /* misoriented or self-intersecting loops */
	GLU_TESS_ERROR6 = 100156,  /* coincident vertices */
	GLU_TESS_ERROR7 = 100157,  /* all vertices collinear */
	GLU_TESS_ERROR8 = 100158,  /* intersecting edges */
	GLU_TESS_ERROR9 = 100159,  /* not coplanar contours */

	/* NURBS */
	GLU_AUTO_LOAD_MATRIX	= 100200,
	GLU_CULLING		= 100201,
	GLU_PARAMETRIC_TOLERANCE= 100202,
	GLU_SAMPLING_TOLERANCE	= 100203,
	GLU_DISPLAY_MODE	= 100204,
	GLU_SAMPLING_METHOD	= 100205,
	GLU_U_STEP		= 100206,
	GLU_V_STEP		= 100207,

	GLU_PATH_LENGTH		= 100215,
	GLU_PARAMETRIC_ERROR	= 100216,
	GLU_DOMAIN_DISTANCE	= 100217,

	GLU_MAP1_TRIM_2		= 100210,
	GLU_MAP1_TRIM_3		= 100211,

	GLU_OUTLINE_POLYGON	= 100240,
	GLU_OUTLINE_PATCH	= 100241,

	GLU_NURBS_ERROR1  = 100251,   /* spline order un-supported */
	GLU_NURBS_ERROR2  = 100252,   /* too few knots */
	GLU_NURBS_ERROR3  = 100253,   /* valid knot range is empty */
	GLU_NURBS_ERROR4  = 100254,   /* decreasing knot sequence */
	GLU_NURBS_ERROR5  = 100255,   /* knot multiplicity > spline order */
	GLU_NURBS_ERROR6  = 100256,   /* endcurve() must follow bgncurve() */
	GLU_NURBS_ERROR7  = 100257,   /* bgncurve() must precede endcurve() */
	GLU_NURBS_ERROR8  = 100258,   /* ctrlarray or knot vector is NULL */
	GLU_NURBS_ERROR9  = 100259,   /* can't draw pwlcurves */
	GLU_NURBS_ERROR10 = 100260,   /* missing gluNurbsCurve() */
	GLU_NURBS_ERROR11 = 100261,   /* missing gluNurbsSurface() */
	GLU_NURBS_ERROR12 = 100262,   /* endtrim() must precede endsurface() */
	GLU_NURBS_ERROR13 = 100263,   /* bgnsurface() must precede endsurface() */
	GLU_NURBS_ERROR14 = 100264,   /* curve of improper type passed as trim curve */
	GLU_NURBS_ERROR15 = 100265,   /* bgnsurface() must precede bgntrim() */
	GLU_NURBS_ERROR16 = 100266,   /* endtrim() must follow bgntrim() */
	GLU_NURBS_ERROR17 = 100267,   /* bgntrim() must precede endtrim()*/
	GLU_NURBS_ERROR18 = 100268,   /* invalid or missing trim curve*/
	GLU_NURBS_ERROR19 = 100269,   /* bgntrim() must precede pwlcurve() */
	GLU_NURBS_ERROR20 = 100270,   /* pwlcurve referenced twice*/
	GLU_NURBS_ERROR21 = 100271,   /* pwlcurve and nurbscurve mixed */
	GLU_NURBS_ERROR22 = 100272,   /* improper usage of trim data type */
	GLU_NURBS_ERROR23 = 100273,   /* nurbscurve referenced twice */
	GLU_NURBS_ERROR24 = 100274,   /* nurbscurve and pwlcurve mixed */
	GLU_NURBS_ERROR25 = 100275,   /* nurbssurface referenced twice */
	GLU_NURBS_ERROR26 = 100276,   /* invalid property */
	GLU_NURBS_ERROR27 = 100277,   /* endsurface() must follow bgnsurface() */
	GLU_NURBS_ERROR28 = 100278,   /* intersecting or misoriented trim curves */
	GLU_NURBS_ERROR29 = 100279,   /* intersecting trim curves */
	GLU_NURBS_ERROR30 = 100280,   /* UNUSED */
	GLU_NURBS_ERROR31 = 100281,   /* unconnected trim curves */
	GLU_NURBS_ERROR32 = 100282,   /* unknown knot error */
	GLU_NURBS_ERROR33 = 100283,   /* negative vertex count encountered */
	GLU_NURBS_ERROR34 = 100284,   /* negative byte-stride */
	GLU_NURBS_ERROR35 = 100285,   /* unknown type descriptor */
	GLU_NURBS_ERROR36 = 100286,   /* null control point reference */
	GLU_NURBS_ERROR37 = 100287,   /* duplicate point on pwlcurve */

	/* Errors */
	GLU_INVALID_ENUM		= 100900,
	GLU_INVALID_VALUE		= 100901,
	GLU_OUT_OF_MEMORY		= 100902,
	GLU_INCOMPATIBLE_GL_VERSION	= 100903,

	/* New in GLU 1.1 */
	GLU_VERSION	= 100800,
	GLU_EXTENSIONS	= 100801
};


/*
 * These are the GLU 1.1 typedefs.  GLU 1.2 has different ones!
 */
typedef struct GLUquadricObj GLUquadricObj;

typedef struct GLUtriangulatorObj GLUtriangulatorObj;

typedef struct GLUnurbsObj GLUnurbsObj;



#if defined(__BEOS__) || defined(__QUICKDRAW__)
#pragma export on
#endif


/*
 *
 * Miscellaneous functions
 *
 */

extern __stdargs __saveds void APIENTRY gluLookAt( GLdouble eyex, GLdouble eyey, GLdouble eyez,
                                         GLdouble centerx, GLdouble centery,
                                         GLdouble centerz,
                                         GLdouble upx, GLdouble upy, GLdouble upz );


extern __asm __saveds void APIENTRY gluOrtho2D( register __fp0 GLdouble left, register __fp1 GLdouble right,
                                                register __fp2 GLdouble bottom, register __fp3 GLdouble top );


extern __asm __saveds void APIENTRY gluPerspective( register __fp0 GLdouble fovy, register __fp1 GLdouble aspect,
                                                    register __fp2 GLdouble zNear, register __fp3 GLdouble zFar );


extern __asm __saveds void APIENTRY gluPickMatrix( register __fp0 GLdouble x, register __fp1 GLdouble y,
                                                   register __fp2 GLdouble width, register __fp3 GLdouble height,
                                                   register __a0 const GLint viewport[4] );

extern __asm __saveds GLint APIENTRY gluProject( register __fp0 GLdouble objx, register __fp1 GLdouble objy, register __fp2 GLdouble objz,
                                                 register __a0 const GLdouble modelMatrix[16],
                                                 register __a1 const GLdouble projMatrix[16],
                                                 register __a2 const GLint viewport[4],
                                                 register __a3 GLdouble *winx, register __a4 GLdouble *winy,
                                                 register __a5 GLdouble *winz );

extern __asm __saveds GLint APIENTRY gluUnProject( register __fp0 GLdouble winx, register __fp1 GLdouble winy,
                                                   register __fp2 GLdouble winz,
                                                   register __a0 const GLdouble modelMatrix[16],
                                                   register __a1 const GLdouble projMatrix[16],
                                                   register __a2 const GLint viewport[4],
                                                   register __a3 GLdouble *objx, register __a4 GLdouble *objy,
                                                   register __a5 GLdouble *objz );

extern __asm __saveds const GLubyte* APIENTRY gluErrorString( register __d0 GLenum errorCode );



/*
 *
 * Mipmapping and image scaling
 *
 */

extern __asm __saveds GLint APIENTRY gluScaleImage( register __d0 GLenum format,
                                                    register __d1 GLint widthin, register __d2 GLint heightin,
                                                    register __d3 GLenum typein, register __a0 const void *datain,
                                                    register __d4 GLint widthout, register __d5 GLint heightout,
                                                    register __d6 GLenum typeout, register __a1 void *dataout );

extern __asm __saveds GLint APIENTRY gluBuild1DMipmaps( register __d0 GLenum target, register __d1 GLint components,
                                                        register __d2 GLint width, register __d3 GLenum format,
                                                        register __d4 GLenum type, register __a0 const void *data );

extern __asm __saveds GLint APIENTRY gluBuild2DMipmaps( register __d0 GLenum target, register __d1 GLint components,
                                                        register __d2 GLint width, register __d3 GLint height,
                                                        register __d4 GLenum format,
                                                        register __d5 GLenum type, register __a0 const void *data );



/*
 *
 * Quadrics
 *
 */

extern __asm __saveds GLUquadricObj* APIENTRY gluNewQuadric( void );

extern __asm __saveds void APIENTRY gluDeleteQuadric( register __a0 GLUquadricObj *state );

extern __asm __saveds void APIENTRY gluQuadricDrawStyle( register __a0 GLUquadricObj *quadObject,
                                                         register __d0 GLenum drawStyle );

extern __asm __saveds void APIENTRY gluQuadricOrientation( register __a0 GLUquadricObj *quadObject,
                                                           register __d0 GLenum orientation );

extern __asm __saveds void APIENTRY gluQuadricNormals( register __a0 GLUquadricObj *quadObject,
                                                       register __d0 GLenum normals );

extern __asm __saveds void APIENTRY gluQuadricTexture( register __a0 GLUquadricObj *quadObject,
                                                       register __d0 GLboolean textureCoords );

extern __asm __saveds void APIENTRY gluQuadricCallback( register __a0 GLUquadricObj *qobj,
                                                        register __d0 GLenum which, register __a1 void (CALLBACK *fn)() );

extern __asm __saveds void APIENTRY gluCylinder( register __a0 GLUquadricObj *qobj,
                                                 register __fp0 GLdouble baseRadius,
                                                 register __fp1 GLdouble topRadius,
                                                 register __fp2 GLdouble height,
                                                 register __d0 GLint slices, register __d1 GLint stacks );

extern __asm __saveds void APIENTRY gluSphere( register __a0 GLUquadricObj *qobj,
                                               register __fp0 GLdouble radius, register __d0 GLint slices, register __d1 GLint stacks );

extern __asm __saveds void APIENTRY gluDisk( register __a0 GLUquadricObj *qobj,
                                             register __fp0 GLdouble innerRadius, register __fp1 GLdouble outerRadius,
                                             register __d0 GLint slices, register __d1 GLint loops );

extern __asm __saveds void APIENTRY gluPartialDisk( register __a0 GLUquadricObj *qobj, register __fp0 GLdouble innerRadius,
                                                    register __fp1 GLdouble outerRadius, register __d0 GLint slices,
                                                    register __d1 GLint loops, register __fp2 GLdouble startAngle,
                                                    register __fp3 GLdouble sweepAngle );



/*
 *
 * Nurbs
 *
 */

extern __asm __saveds GLUnurbsObj* APIENTRY gluNewNurbsRenderer( void );

extern __asm __saveds void APIENTRY gluDeleteNurbsRenderer( register __a0 GLUnurbsObj *nobj );

extern __asm __saveds void APIENTRY gluLoadSamplingMatrices( register __a0 GLUnurbsObj *nobj,
                                                             register __a1 const GLfloat modelMatrix[16],
                                                             register __a2 const GLfloat projMatrix[16],
                                                             register __a3 const GLint viewport[4] );

extern __asm __saveds void APIENTRY gluNurbsProperty( register __a0 GLUnurbsObj *nobj, register __d0 GLenum property,
                                                      register __fp0 GLfloat value );

extern __asm __saveds void APIENTRY gluGetNurbsProperty( register __a0 GLUnurbsObj *nobj, register __d0 GLenum property,
                                                         register __a1 GLfloat *value );

extern __asm __saveds void APIENTRY gluBeginCurve( register __a0 GLUnurbsObj *nobj );

extern __asm __saveds void APIENTRY gluEndCurve( register __a0 GLUnurbsObj * nobj );

extern __asm __saveds void APIENTRY gluNurbsCurve( register __a0 GLUnurbsObj *nobj, register __d0 GLint nknots,
                                                   register __a1 GLfloat *knot, register __d1 GLint stride,
                                                   register __a2 GLfloat *ctlarray, register __d2 GLint order,
                                                   register __d3 GLenum type );

extern __asm __saveds void APIENTRY gluBeginSurface( register __a0 GLUnurbsObj *nobj );

extern __asm __saveds void APIENTRY gluEndSurface( register __a0 GLUnurbsObj * nobj );

extern __asm __saveds void APIENTRY gluNurbsSurface( register __a0 GLUnurbsObj *nobj,
                                                     register __d0 GLint sknot_count, register __a1 GLfloat *sknot,
                                                     register __d1 GLint tknot_count, register __a2 GLfloat *tknot,
                                                     register __d2 GLint s_stride, register __d3 GLint t_stride,
                                                     register __a3 GLfloat *ctlarray,
                                                     register __d4 GLint sorder, register __d5 GLint torder,
                                                     register __d6 GLenum type );

extern __asm __saveds void APIENTRY gluBeginTrim( register __a0 GLUnurbsObj *nobj );

extern __asm __saveds void APIENTRY gluEndTrim( register __a0 GLUnurbsObj *nobj );

extern __asm __saveds void APIENTRY gluPwlCurve( register __a0 GLUnurbsObj *nobj, register __d0 GLint count,
                                                 register __a1 GLfloat *array, register __d1 GLint stride, register __d2 GLenum type );

extern __asm __saveds void APIENTRY gluNurbsCallback( register __a0 GLUnurbsObj *nobj, register __d0 GLenum which,
                                                      register __a1 void (CALLBACK *fn)() );



/*
 *
 * Polygon tesselation
 *
 */

extern __asm __saveds GLUtriangulatorObj* APIENTRY gluNewTess( void );

extern __asm __saveds void APIENTRY gluTessCallback( register __a0 GLUtriangulatorObj *tobj, register __d0 GLenum which,
                                                     register __a1 void (CALLBACK *fn)() );

extern __asm __saveds void APIENTRY gluDeleteTess( register __a0 GLUtriangulatorObj *tobj );

extern __asm __saveds void APIENTRY gluBeginPolygon( register __a0 GLUtriangulatorObj *tobj );

extern __asm __saveds void APIENTRY gluEndPolygon( register __a0 GLUtriangulatorObj *tobj );

extern __asm __saveds void APIENTRY gluNextContour( register __a0 GLUtriangulatorObj *tobj, register __d0 GLenum type );

extern __asm __saveds void APIENTRY gluTessVertex( register __a0 GLUtriangulatorObj *tobj, register __a1 GLdouble v[3],
                                                   register __a2 void *data );



/*
 *
 * New functions in GLU 1.1
 *
 */

extern __asm __saveds const GLubyte* APIENTRY gluGetString( register __d0 GLenum name );


#ifndef MAKE_MESAMAINLIB

extern __stdargs __saveds void APIENTRY STUBgluLookAt(GLdouble eyex, GLdouble eyey, GLdouble eyez, GLdouble centerx, GLdouble centery, GLdouble centerz, GLdouble upx, GLdouble upy, GLdouble upz, struct Library *mesamainBase);
#define gluLookAt(eyex,eyey,eyez,centerx,centery,centerz,upx,upy,upz) STUBgluLookAt(eyex,eyey,eyez,centerx,centery,centerz,upx,upy,upz,mesamainBase)

extern __asm __saveds GLint APIENTRY STUBgluProject(register __fp0 GLdouble objx, register __fp1 GLdouble objy, register __fp2 GLdouble objz, register __a0 const GLdouble modelMatrix[16], register __a1 const GLdouble projMatrix[16], register __a2 const GLint viewport[4], register __a3 GLdouble *winx, register __a4 GLdouble *winy, register __a5 GLdouble *winz, register __a6 struct Library *mesamainBase);
#define gluProject(objx,objy,objz,modelMatrix,projMatrix,viewport,winx,winy,winz) STUBgluProject(objx,objy,objz,modelMatrix,projMatrix,viewport,winx,winy,winz,mesamainBase)

extern __asm __saveds GLint APIENTRY STUBgluUnProject(register __fp0 GLdouble winx, register __fp1 GLdouble winy, register __fp2 GLdouble winz, register __a0 const GLdouble modelMatrix[16], register __a1 const GLdouble projMatrix[16], register __a2 const GLint viewport[4], register __a3 GLdouble *objx, register __a4 GLdouble *objy, register __a5 GLdouble *objz, register __a6 struct Library *mesamainBase);
#define gluUnProject(winx,winy,winz,modelMatrix,projMatrix,viewport,objx,objy,objz) STUBgluUnProject(winx,winy,winz,modelMatrix,projMatrix,viewport,objx,objy,objz,mesamainBase)

extern __asm __saveds void APIENTRY STUBgluCylinder(register __a0 GLUquadricObj *qobj, register __fp0 GLdouble baseRadius, register __fp1 GLdouble topRadius, register __fp2 GLdouble height, register __d0 GLint slices, register __d1 GLint stacks, register __a1 struct Library *mesamainBase);
#define gluCylinder(qobj,baseRadius,topRadius,height,slices,stacks) STUBgluCylinder(qobj,baseRadius,topRadius,height,slices,stacks,mesamainBase)

extern __asm __saveds void APIENTRY STUBgluPartialDisk(register __a0 GLUquadricObj *qobj, register __fp0 GLdouble innerRadius, register __fp1 GLdouble outerRadius, register __d0 GLint slices, register __d1 GLint loops, register __fp2 GLdouble startAngle, register __fp3 GLdouble sweepAngle, register __a1 struct Library *mesamainBase);
#define gluPartialDisk(qobj,innerRadius,outerRadius,slices,loops,startAngle,sweepAngle) STUBgluPartialDisk(qobj,innerRadius,outerRadius,slices,loops,startAngle,sweepAngle,mesamainBase)

#endif


#if defined(__BEOS__) || defined(__QUICKDRAW__)
#pragma export off
#endif


#ifdef macintosh
	#pragma enumsalwaysint reset
	#if PRAGMA_IMPORT_SUPPORTED
	#pragma import off
	#endif
#endif


#ifdef __cplusplus
}
#endif


#endif
