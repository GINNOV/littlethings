#ifndef _GL_H_
#define _GL_H_


#ifndef	NULL
#define NULL			0
#endif

#ifndef	FALSE
#define FALSE			0
#endif

#ifndef	TRUE
#define TRUE			1
#endif


#define MATRIXSTACKDEPTH	32


#define BLACK			0
#define RED			1
#define GREEN			2
#define YELLOW			3
#define BLUE			4
#define MAGENTA			5
#define CYAN			6
#define WHITE			7


#define GD_XPMAX		0
#define GD_YPMAX		1
#define GD_BITS_NORM_SNG_CMODE	2
#define GD_BITS_NORM_DBL_CMODE	3
#define GD_NVERTEX_POLY		4

/* matrix modes: mmode(?) */
#define MSINGLE         0
#define MPROJECTION     1
#define MVIEWING        2
#define MTEXTURE        3



typedef unsigned char Byte;
typedef long Boolean;
typedef char *String;
typedef void *Lstring;

typedef short Angle;
typedef short Screencoord;
typedef short Scoord;
typedef long Icoord;
typedef float Coord;
typedef float Matrix[4][4];

typedef unsigned short Colorindex;


/* prototypes */
#include"usr:src/agl/prototypes.h"



#endif
