#ifndef _H_SHARED

#define _H_SHARED

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"


typedef struct
{
	Vector	Norm;
	float		Dist;
	int		Type;
} Plane_t;

typedef struct Point3D
{
	struct Point3D *Next;
	Vector	Pos;
	ubyte		CCodes;
	ubyte		Pad;
	ushort	Side;
	int		Sx;
	int		Sy;
	float		Fx;
	float		Fy;
} Point3D_t;


#ifdef __cplusplus
 }
#endif

#endif
