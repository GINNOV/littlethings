/*
**      $VER: td_public.h 0.1 (19.6.1999)
**
**      Creation date     : 11.4.1999
**
**      Description       :
**         Public type definitions and constants for the td library.
**
**      Written by Stephan Bielmann
**
**
*/

#ifndef INCLUDE_TD_PUBLIC_H
#define INCLUDE_TD_PUBLIC_H

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <exec/types.h>

/**************************** Defines *******************************/

/*
** View types
*/
#define TVWTOP			1	/* Top view, xy axis               */
#define TVWBOTTOM		2	/* Bottom view, xy axis            */
#define TVWLEFT		3	/* Left view yz axis               */
#define TVWRIGHT		4	/* Right view yz axis              */
#define TVWFRONT		5	/* Front view xz axis              */
#define TVWREAR		6	/* Rear view xz axis               */
#define TVWPERSP		7	/* Perspectiv view                 */
#define TVW4SIDES		8	/* Top, front, left and perspecive */

/*
** drawing modes
*/
#define DMPOINTS      1   /* Points, black and white      */
#define DMWIREBW      2   /* Wireframe, black and white   */
#define DMWIREGR      3   /* Wireframe, gray scales       */
#define DMWIRECL      4   /* Wireframe, colors            */
#define DMHIDDBW      5   /* Hidden line, black and white */
#define DMHIDDGR      6   /* Hidden line, gray scales     */
#define DMHIDDCL      7   /* Hidden line, colors          */
#define DMSURFBW      8   /* Surface, black and white     */
#define DMSURFGR      9   /* Surface, gray scales         */
#define DMSURFCL     10   /* Surface, colors              */

/*
** Return codes, IoErr will be used too to get AmigaDos errors
*/
#define RCNOERROR                     0      /* All went well.                           */
#define RCNOMEMORY                    2000   /* No more free memory.                     */
#define RCNOSPACE                     2001   /* No space to process.                     */
#define RCNOMESH                      2002   /* No mesh to process.                      */
#define RCNOPOLYGON                   2003   /* No polygon  to process.                  */
#define RCNOMATERIAL 	               2004   /* No material to process.                  */
#define RCNOPART	 	               2005   /* No part to process.                      */
#define RCUNKNOWNFORMAT               2006   /* Unkown file format.                      */
#define RCUNKNOWNVTYPE                2007   /* Unkown view type.                        */
#define RCUNKNOWNDMODE                2008   /* Unkown draw mode.                        */
#define RCWRITEDATA                   2009   /* Error occured while writing the file.    */
#define RCREADDATA                    2010   /* Error occured while reading the file.    */
#define RCVALUEOUTOFRANGE             2011   /* An argument its value is out of range.   */
#define RCOVERFLOW                    2012   /* Error, too extensive mesh.               */
#define RCNOVERTEX                    2013   /* The vertex is not in the mesh.           */
#define RCVERTEXUNDERFLOW             2014   /* Error, not enough vertices.              */
#define RCINVALIDOPERATION            2015   /* The operation you want to do is invalid. */
#define RCNOWIDTH                     2016   /* The width is not set.                    */
#define RCNOHEIGHT                    2017   /* The height is not set.                   */
#define RCNOFILE                      2018   /* Could not open the file                  */
#define RCNOTIMPL                     2019   /* If a function is not implemented.        */
#define RCSAVEROPEN                   2020   /* The saver library could not be opened    */
#define RCLOADEROPEN                  2021   /* The loader library could not be opened   */


/*********************** Type definitions ***************************/

typedef enum {
	ER_NOERROR,	/* All went well.                           */
	ER_NOMEMORY,	/* No more free memory.                     */
	ER_NOSPACE,	/* No space to process.                     */
	ER_NOTYPE,
	ER_NOINDEX,
	ER_NOOPERATION,
	ER_NOOBJECT,
	ER_NOVERTEX,
	ER_NOMATERIAL,
	ER_NOMATGROUP,
	ER_NOPOLYGON,
	ER_NOVALUE,
	ER_OVERFLOW,
	ER_WRITEDATA,
	ER_READDATA,
	ER_CREATEFILE,
	ER_NOFILE,
	ER_UNKNOWNFORMAT
} TDerrors;

typedef enum {
	TD_NOTHING,
	TD_SPACE,
	TD_MATERIAL,
	TD_AMBIENT,
	TD_DIFFUSE,
	TD_SHININESS,
	TD_TRANSPARENCY,
	TD_ADD,
	TD_SUB,
	TD_MUL,
	TD_DIV,
	TD_SET,
	TD_RESET,
	TD_OBJECT,
	TD_POLYMESH,
	TD_CUBE,
	TD_SCALE,
	TD_ROTATION,
	TD_TRANSLATION,
	TD_ORIGIN,
	TD_POLYGON,
	TD_MATGROUP,
	TD_VERTEX,
	TD_SURFACE,
	TD_TEXTURE,
	TD_TEXBINDING,
	TD_3X,
	TD_3XSAVE,
	TD_3XLOAD
} TDenum;

/*
** Primitive types
*/
typedef FLOAT TTDOFloat;
typedef DOUBLE TTDODouble;

/*
** Vertex structures
*/
typedef struct {
	TTDOFloat x,y,z;
}TTDOVertexf;

typedef struct {
	TTDODouble x,y,z;
}TTDOVertexd;

/*
** Bounding box structures
*/
typedef struct {
	TTDOFloat front,rear,left,right,top,bottom;
}TTDOBBoxf;

typedef struct {
	TTDODouble front,rear,left,right,top,bottom;
}TTDOBBoxd;

/*
** 2D file parameter structure
*/
typedef struct {
	ULONG viewtype;
	ULONG drawmode;
	ULONG width;
	ULONG height;
}TTDO2DParams;






/*
** Primitive types
*/
typedef FLOAT TDfloat;
typedef DOUBLE TDdouble;

/*
** Vector structures
*/
typedef struct {
	TDfloat x,y,z;
}TDvectorf;

typedef struct {
	TDdouble x,y,z;
}TDvectord;

/*
** Bounding box structures
*/
typedef struct {
	TDfloat front,rear,left,right,top,bottom;
}TDbboxf;

typedef struct {
	TDdouble front,rear,left,right,top,bottom;
}TDbboxd;

/*
** Color structure
*/
typedef struct {
	UBYTE r,g,b;
}TDcolorub;

#endif

/************************* End of file ******************************/
