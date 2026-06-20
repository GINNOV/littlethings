/*
**      $VER: meshwriter_public.h 1.00 (14.3.1999)
**
**      Creation date     : 31.10.1998
**
**      Description       :
**         Public type definitions and constants for the mesh writer module.
**
**      Written by Stephan Bielmann
**
**
*/

#ifndef INCLUDE_MESHWRITER_PUBLIC_H
#define INCLUDE_MESHWRITER_PUBLIC_H

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <exec/types.h>

/**************************** Defines *******************************/
/*
** 3D file types
*/
#define  T3DFRAWA   1     /* RAW ASCII            raw    */
#define  T3DFRAWB   2     /* RAW binary           raw    */
#define  T3DFDXF    3     /* AutoCAD DXF          dxf    */
#define  T3DFVRML1  4     /* VRML 1               wrl    */
#define  T3DFPOV3   5     /* POVRay 3.X           pov    */
#define  T3DFLWOB   6     /* Lightwave            lwob   */
#define  T3DFTDDD   7     /* Imagine original     iob    */
#define  T3DFTDDDH  8     /* Imagine huge         iob    */
#define  T3DFREF4   9     /* Reflections 4.X      r4     */
#define  T3DFGEOA   10    /* Videoscape ASCII     geo    */
#define  T3DFREAL   11    /* Real 3D              real   */

/*
** 2D file types
*/
#define  T2DFEPS    1     /* Encapsulated PostScript   eps   */
#define  T2DFPSP    2     /* PostScript portrait       ps    */
#define  T2DFPSL    3     /* PostScript landscape      ps    */

/*
** View types
*/
#define TVWTOP			1	/* Top view, xy axis               */
#define TVWBOTTOM		2	/* Bottom view, xy axis            */
#define TVWLEFT		3	/* Left view yz axis               */
#define TVWRIGHT		4	/* Right view yz axis              */
#define TVWFRONT		5	/* Front view xz axis              */
#define TVWBACK		6	/* Back view xz axis               */
#define TVWPERSP		7	/* Perspectiv view                 */
#define TVW4SIDES		8	/* Top, front, left and perspecive */

/*
** drawing modes
*/
#define TDMPOINTS		1	/* Points, black and white    */
#define TDMGRIDBW		2	/* Grid, black and white      */
#define TDMGRIDGR		3	/* Grid, gray scales          */
#define TDMGRIDCL		4	/* Grid, colors               */
#define TDMSURFBW		5	/* Surface, black and white   */
#define TDMSURFGR		6	/* Surface, gray scales       */
#define TDMSURFCL		7	/* Surface, colors            */

/*
** Return codes, IoErr will be used too to get AmigaDos errors
*/
#define RCNOERROR                     0      /* All went well.                           */
#define RCNOMEMORY                    2000   /* No more free memory.                     */
#define RCNOMESH                      2001   /* No mesh to process.                      */
#define RCNOPOLYGON                   2002   /* No polygon  to process.                  */
#define RCNOMATERIAL 	               2003   /* No material to process.                  */
#define RCUNKNOWNFTYPE                2004   /* Unkown file type.                        */
#define RCUNKNOWNVTYPE                2005   /* Unkown view type.                        */
#define RCUNKNOWNDMODE                2006   /* Unkown draw mode.                        */
#define RCCHGBUF                      2007   /* Could not change the buffer size.        */
#define RCWRITEDATA                   2008   /* Error occured while writing the file.    */
#define RCVERTEXOVERFLOW              2009   /* Error, too much vertices.                */
#define RCVALUEOUTOFRANGE             2010   /* An argument its value is out of range.   */
#define RCVERTEXINPOLYGONOVERFLOW     2011   /* Error, too much vertices in a polygon.   */
#define RCNOVERTEX                    2012   /* The vertex is not in the mesh.           */
#define RCVERTEXUNDERFLOW             2013   /* Error, not enough vertices.              */
#define RCINVALIDOPERATION            2014   /* The operation you want to do is invalid. */

/*
** CTM operations
*/
#define CTMADD		1	/* Add the value to the CTM       */
#define CTMSUB		2	/* Substract the value to the CTM */
#define CTMMUL		3	/* Multiply the value to the CTM  */
#define CTMDIV		4	/* Divide the value to the CTM    */
#define CTMSET		5	/* Set the value in the CTM       */
#define CTMRESET	6	/* Reset the value in the CTM     */

/*********************** Type definitions ***************************/

/*
** Primitive types
*/
typedef FLOAT TOCLFloat;

/*
** Vertex structure
*/
typedef struct {
	TOCLFloat x,y,z;
}TOCLVertex;

/*
** Color structure
*/
typedef struct {
	UBYTE r,g,b;
}TOCLColor;

#endif

/************************* End of file ******************************/
