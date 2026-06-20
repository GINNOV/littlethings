
/*!
	\file
	\ingroup
	\author
	\date    2001
*/


#ifndef TEDDY_TINY_GL_ZMATH_H
#define TEDDY_TINY_GL_ZMATH_H


/* Matrix & Vertex */
struct m4_struct {
	float m[4][4];
};
typedef struct m4_struct M4;

typedef struct m3_struct {
	float m[3][3];
} M3;

typedef struct m34_struct {
	 float m[3][4];
} M34;


typedef struct v3_struct {
	 float v[3];
} V3;

typedef struct v4_struct {
	 float v[4];
} V4;

	
extern void gl_M4_Id       ( M4 *a );
extern int  gl_M4_IsId     ( M4 *a );
extern void gl_M4_Move     ( M4 *a, M4 *b );
extern void gl_MoveV3      ( V3 *a, V3 *b );
extern void gl_MulM4V3     ( V3 *a, M4 *b ,V3 *c );
extern void gl_MulM3V3     ( V3 *a, M4 *b ,V3 *c );
extern void gl_M4_MulV4    ( V4 *a, M4 *b ,V4 *c );
extern void gl_M4_InvOrtho ( M4 *a, M4 b );
extern void gl_M4_Inv      ( M4 *a, M4 *b );
extern void gl_M4_Mul      ( M4 *c, M4 *a, M4 *b );
extern void gl_M4_MulLeft  ( M4 *c, M4 *a );
extern void gl_M4_Transpose( M4 *a, M4 *b );
extern void gl_M4_Rotate   ( M4 *c, float t, int u );
extern int  gl_V3_Norm     ( V3 *a );
extern V3   gl_V3_New      ( float x, float y, float z );
extern V4   gl_V4_New      ( float x, float y, float z, float w );
extern int gl_Matrix_Inv   ( float *r, float *m, int n );


#endif  /*  TEDDY_TINY_GL_ZMATH_H  */

