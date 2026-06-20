/*
 * $Id: draw.c,v 1.4 2001/02/01 14:36:49 tfrieden Exp $
 *
 * $Date: 2001/02/01 14:36:49 $
 * $Revision: 1.4 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */


#include "sysinc.h"
#include <math.h>

#include <stdlib.h>
#ifdef __VBCC__
#include <stdio.h>
#endif

#ifndef PI
	#ifdef M_PI
	#define PI M_PI
	#else
	#define PI 3.1415927
	#endif
#endif

#ifdef DISABLE_TRANSFORMATION
#warning "Compiling without transformation pipeline. Only flat geometry supported"
#endif

static char rcsid[] = "$Id: draw.c,v 1.4 2001/02/01 14:36:49 tfrieden Exp $";

typedef void (*Multfn)(struct Matrix_t *, float *, struct Matrix_t *);

INLINE void m_MatCopy(Matrix *pA, Matrix *pB);
INLINE void m_MatMultGeneral(Matrix *pA, float *pB, Matrix *pC);

INLINE void m_MatMultAIdent(float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultAPerspB0001(Matrix *pA, float *pB, Matrix *pC); //surgeon: common case for m_CombineMatrices
INLINE void m_MatMultRotRot(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultBRot001(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultBRot010(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultBRot100(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultA0001_BRot001(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultA0001_BRot010(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultA0001_BRot100(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultA0001_B0001(Matrix *pA, float *pB, Matrix *pC); //surgeon

INLINE void m_MatMultB0001(Matrix *pA, float *pB, Matrix *pC);
INLINE void m_MatMultA0001(Matrix *pA, float *pB, Matrix *pC);
INLINE void m_MatMultATrans(Matrix *pA, float *pB, Matrix *pC);
INLINE void m_MatMultBTrans(Matrix *pA, float *pB, Matrix *pC);
INLINE void m_MatMultBScale(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultBOrtho(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultBPersp(Matrix *pA, float *pB, Matrix *pC); //surgeon

INLINE void m_MatMultA0001_BTrans(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultA0001_BScale(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultA0001_BOrtho(Matrix *pA, float *pB, Matrix *pC); //surgeon
INLINE void m_MatMultA0001_BPersp(Matrix *pA, float *pB, Matrix *pC); //surgeon

INLINE void m_LoadMatrixf(Matrix *pA, const float *v);
INLINE void m_LoadMatrixd(Matrix *pA, const double *v);
INLINE void m_LoadIdentity(Matrix *pA);
INLINE void m_Mult(Matrix *pA, float *v, int vtype, Matrix *pC);
void m_CombineMatrices(GLcontext context);
void GLMatrixInit(GLcontext context);


/* I am too lazy to convert our old code */
#define CM_0 OF_11
#define CM_1 OF_12
#define CM_2 OF_13
#define CM_3 OF_21
#define CM_4 OF_22
#define CM_5 OF_23
#define CM_6 OF_31
#define CM_7 OF_32
#define CM_8 OF_33

/*
** Computes the determinant of the upper 3x3 submatrix block
** of the supplied matrix
*/
INLINE GLfloat m_Determinant(Matrix *pA)
{
   #define a(x) (pA->v[CM_##x])
   float a0 = a(0);
   float a1 = a(1);
   float a2 = a(2);
   float a3 = a(3);
   float a4 = a(4);
   float a5 = a(5);
   float a6 = a(6);
   float a7 = a(7);
   float a8 = a(8);


    return ( a0*a4*a8  +  a1*a5*a6  + a2*a3*a7 -  a0*a5*a7  -  a1*a3*a8  - a2*a4*a6);

   #undef a
}

/*
** Builds the inverse of the upper 3x3 submatrix block of the
** supplied matrix for the backtransformation of the normals
*/

void m_DoInvert(Matrix *pA, int flags, GLfloat *out)
{

   #define a(x) (pA->v[CM_##x])

   float a0 = a(0);
   float a1 = a(1);
   float a2 = a(2);
   float a3 = a(3);
   float a4 = a(4);
   float a5 = a(5);
   float a6 = a(6);
   float a7 = a(7);
   float a8 = a(8);

   GLfloat det = a0*a4*a8 + a1*a5*a6 + a2*a3*a7
		 - a0*a5*a7 - a1*a3*a8 - a2*a4*a6;

   det = 1.0 / det;

   *out++ = (GLfloat)(a4*a8 - a5*a7)*det;
   *out++ = (GLfloat)(a2*a7 - a1*a8)*det;
   *out++ = (GLfloat)(a1*a5 - a2*a4)*det;

   *out++ = (GLfloat)(a5*a6 - a3*a8)*det;
   *out++ = (GLfloat)(a0*a8 - a2*a6)*det;
   *out++ = (GLfloat)(a2*a3 - a0*a5)*det;
   
   *out++ = (GLfloat)(a3*a7 - a4*a6)*det;
   *out++ = (GLfloat)(a1*a6 - a0*a7)*det;
   *out++ = (GLfloat)(a0*a4 - a1*a3)*det;

   #undef a
}

void m_PrintMatrix(Matrix *pA);

void m_BuildInverted(GLcontext context)
{
//   m_PrintMatrix(CurrentMV);
//   printf("flags: %i\n\n", CurrentMV->flags);

   context->InvRotValid = GL_TRUE;
   m_DoInvert(CurrentMV, CurrentMV->flags, context->InvRot);
}


/*
** Copy matrix B to matrix A
** A = B
*/
INLINE void m_MatCopy(Matrix *pA, Matrix *pB)
{
   int i;

//   for (i=0; i<16; i++)
   i = 0;
   do{
 
	pA->v[i] = pB->v[i];
	i++;
	} while (i<16);

   pA->flags = pB->flags;
   pA->Inverse = pB->Inverse;
}

/*
** General case: Matrix multiply
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultGeneral(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float b11 = b(11);
   float b12 = b(12);
   float b13 = b(13);
   float b14 = b(14);
   float b21 = b(21);
   float b22 = b(22);
   float b23 = b(23);
   float b24 = b(24);
   float b31 = b(31);
   float b32 = b(32);
   float b33 = b(33);
   float b34 = b(34);
   float b41 = b(41);
   float b42 = b(42);
   float b43 = b(43);
   float b44 = b(44);

float a11 = a(11);
float a12 = a(12);
float a13 = a(13);
float a14 = a(14);

float a21 = a(21);
float a22 = a(22);
float a23 = a(23);
float a24 = a(24);

float a31 = a(31);
float a32 = a(32);
float a33 = a(33);
float a34 = a(34);

float a41 = a(41);
float a42 = a(42);
float a43 = a(43);
float a44 = a(44);

   c(11)  = a11*b11;
   c(12)  = a11*b12;
   c(13)  = a11*b13;
   c(11) += a12*b21;
   c(12) += a12*b22;
   c(13) += a12*b23;
   c(11) += a13*b31;
   c(12) += a13*b32;
   c(13) += a13*b33;
   c(11) += a14*b41;
   c(12) += a14*b42;
   c(13) += a14*b43;

   c(21)  = a21*b11;
   c(22)  = a21*b12;
   c(23)  = a21*b13;
   c(21) += a22*b21;
   c(22) += a22*b22;
   c(23) += a22*b23;
   c(21) += a23*b31;
   c(22) += a23*b32;
   c(23) += a23*b33;
   c(21) += a24*b41;
   c(22) += a24*b42;
   c(23) += a24*b43;

   c(31)  = a31*b11;
   c(32)  = a31*b12;
   c(33)  = a31*b13;
   c(31) += a32*b21;
   c(32) += a32*b22;
   c(33) += a32*b23;
   c(31) += a33*b31;
   c(32) += a33*b32;
   c(33) += a33*b33;
   c(31) += a34*b41;
   c(32) += a34*b42;
   c(33) += a34*b43;

   c(41)  = a41*b11;
   c(42)  = a41*b12;
   c(43)  = a41*b13;
   c(41) += a42*b21;
   c(42) += a42*b22;
   c(43) += a42*b23;
   c(41) += a43*b31;
   c(42) += a43*b32;
   c(43) += a43*b33;
   c(41) += a44*b41; 
   c(42) += a44*b42;
   c(43) += a44*b43;

   c(14)  = b14*a11;
   c(24)  = b14*a21;
   c(34)  = b14*a31;
   c(44)  = b14*a41;

   c(14) += b24*a12;
   c(24) += b24*a22;
   c(34) += b24*a32;
   c(44) += b24*a42;

   c(14) += b34*a13;
   c(24) += b34*a23;
   c(34) += b34*a33;
   c(44) += b34*a43;

   c(14) += b44*a14;
   c(24) += b44*a24;
   c(34) += b44*a34;
   c(44) += b44*a44;

   #undef a
   #undef b
}



/*
** Matrix A is an identity matrix
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultAIdent(float *pB, Matrix *pC)
{
   int i;

//for (i=0; i<16; i++)
   i = 0;
	do {
		pC->v[i] = pB[i];
		i++;
	} while(i < 16);
}

/*
** Matrix A and matrix B are rotation matrices
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultRotRot(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12),  b12 = b(12);
   float a13 = a(13),  b13 = b(13);
   float a21 = a(21),  b21 = b(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float a31 = a(31),  b31 = b(31);
   float a32 = a(32),  b32 = b(32);
   float a33 = a(33),  b33 = b(33);

   c(11) = a11*b11 + a12*b21 + a13*b31;
   c(12) = a11*b12 + a12*b22 + a13*b32;
   c(13) = a11*b13 + a12*b23 + a13*b33;
   c(14) = 0.f;


   c(21) = a21*b11 + a22*b21 + a23*b31;
   c(22) = a21*b12 + a22*b22 + a23*b32;
   c(23) = a21*b13 + a22*b23 + a23*b33;
   c(24) = 0.f;

   c(31) = a31*b11 + a32*b21 + a33*b31;
   c(32) = a31*b12 + a32*b22 + a33*b32;
   c(33) = a31*b13 + a32*b23 + a33*b33;
   c(34) = 0.f;

   c(41) = 0.f;
   c(42) = 0.f;
   c(43) = 0.f;
   c(44) = 1.f;

   #undef a
   #undef b
}

/*
** Matrix A is a perspective matrix
** Matrix B has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultAPerspB0001(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float 		 b12 = b(12);
   float a13 = a(13),  b13 = b(13);
   float 		 b14 = b(14);
   float 		 b21 = b(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float 		 b24 = b(24);
   float 		 b31 = b(31);
   float 		 b32 = b(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34),  b34 = b(34);

   c(11) = a11*b11 + a13*b31;
   c(12) = a11*b12 + a13*b32;
   c(13) = a11*b13 + a13*b33;
   c(14) = a11*b14 + a13*b34;

   c(21) = a22*b21 + a23*b31;
   c(22) = a22*b22 + a23*b32;
   c(23) = a22*b23 + a23*b33;
   c(24) = a22*b24 + a23*b34;

   c(31) = a33*b31;
   c(32) = a33*b32;
   c(33) = a33*b33;
   c(34) = a33*b34 + a34;

   c(41) = -b31;
   c(42) = -b32;
   c(43) = -b33;
   c(44) = -b34;

   #undef a
   #undef b
}

/*
** Matrix B has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultB0001(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12),  b12 = b(12);
   float a13 = a(13),  b13 = b(13);
   float a14 = a(14),  b14 = b(14);
   float a21 = a(21),  b21 = b(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float a24 = a(24),  b24 = b(24);
   float a31 = a(31),  b31 = b(31);
   float a32 = a(32),  b32 = b(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34),  b34 = b(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = a(44);


   c(11) = a11*b11 + a12*b21 + a13*b31;
   c(12) = a11*b12 + a12*b22 + a13*b32;
   c(13) = a11*b13 + a12*b23 + a13*b33;

   c(21) = a21*b11 + a22*b21 + a23*b31;
   c(22) = a21*b12 + a22*b22 + a23*b32;
   c(23) = a21*b13 + a22*b23 + a23*b33;

   c(31) = a31*b11 + a32*b21 + a33*b31;
   c(32) = a31*b12 + a32*b22 + a33*b32;
   c(33) = a31*b13 + a32*b23 + a33*b33;

   c(41) = a41*b11 + a42*b21 + a43*b31;
   c(42) = a41*b12 + a42*b22 + a43*b32;
   c(43) = a41*b13 + a42*b23 + a43*b33;

a14 += b34*a13;
a24 += b34*a23;
a34 += b34*a33;
a44 += b34*a43;

a14 += b24*a12;
a24 += b24*a22;
a34 += b24*a32;
a44 += b24*a42;

a14 += b14*a11;
a24 += b14*a21;
a34 += b14*a31;
a44 += b14*a41;

c(14) = a14; 
c(24) = a24; 
c(34) = a34; 
c(44) = a44; 

   #undef a
   #undef b
}

// --> surgeon begin

/*
** Matrix B has three rows
** Matrix A has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultA0001_B0001(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12),  b12 = b(12);
   float a13 = a(13),  b13 = b(13);
   float a14 = a(14),  b14 = b(14);
   float a21 = a(21),  b21 = b(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float a24 = a(24),  b24 = b(24);
   float a31 = a(31),  b31 = b(31);
   float a32 = a(32),  b32 = b(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34),  b34 = b(34);

   c(11) = a11*b11 + a12*b21 + a13*b31;
   c(12) = a11*b12 + a12*b22 + a13*b32;
   c(13) = a11*b13 + a12*b23 + a13*b33;

   c(21) = a21*b11 + a22*b21 + a23*b31;
   c(22) = a21*b12 + a22*b22 + a23*b32;
   c(23) = a21*b13 + a22*b23 + a23*b33;

   c(31) = a31*b11 + a32*b21 + a33*b31;
   c(32) = a31*b12 + a32*b22 + a33*b32;
   c(33) = a31*b13 + a32*b23 + a33*b33;

   c(41) = 0.f;
   c(42) = 0.f;
   c(43) = 0.f;
   c(44) = 1.f;

a14 += b34*a13;
a24 += b34*a23;
a34 += b34*a33;

a14 += b24*a12;
a24 += b24*a22;
a34 += b24*a32;

a14 += b14*a11;
a24 += b14*a21;
a34 += b14*a31;

c(14) = a14; 
c(24) = a24; 
c(34) = a34; 

   #undef a
   #undef b
}

/*
** Matrix B has three rows
** Matrix A has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultA0001_BRot001(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12),  b12 = b(12);
   float a13 = a(13);
   float a14 = a(14);
   float a21 = a(21),  b21 = b(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23);
   float a24 = a(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33);
   float a34 = a(34);

   c(11) = a11*b11 + a12*b21;
   c(12) = a11*b12 + a12*b22;
   c(13) = a13;
   c(14) = a14;

   c(21) = a21*b11 + a22*b21;
   c(22) = a21*b12 + a22*b22;
   c(23) = a23;
   c(24) = a24;

   c(31) = a31*b11 + a32*b21;
   c(32) = a31*b12 + a32*b22;
   c(33) = a33;
   c(34) = a34;

   c(41) = 0.f;
   c(42) = 0.f;
   c(43) = 0.f;
   c(44) = 1.f;

   #undef a
   #undef b
}

/*
** Matrix B has three rows
** Matrix A has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultA0001_BRot010(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12);
   float a13 = a(13),  b13 = b(13);
   float a14 = a(14);
   float a21 = a(21);
   float a22 = a(22);
   float a23 = a(23);
   float a24 = a(24);
   float a31 = a(31),  b31 = b(31);
   float a32 = a(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34);

   c(11) = a11*b11 + a13*b31;
   c(12) = a12;
   c(13) = a11*b13 + a13*b33;
   c(14) = a14;

   c(21) = a21*b11 + a23*b31;
   c(22) = a22;
   c(23) = a21*b13 + a23*b33;
   c(24) = a24;

   c(31) = a31*b11 + a33*b31;
   c(32) = a32;
   c(33) = a31*b13 + a33*b33;
   c(34) = a34;

   c(41) = 0.f;
   c(42) = 0.f;
   c(43) = 0.f;
   c(44) = 1.f;

   #undef a
   #undef b
}

/*
** Matrix B has three rows
** Matrix A has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultA0001_BRot100(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11);
   float a12 = a(12);
   float a13 = a(13);
   float a14 = a(14);
   float a21 = a(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float a24 = a(24);
   float a31 = a(31);
   float a32 = a(32),  b32 = b(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34);


   c(11) = a11;
   c(12) = a12*b22 + a13*b32;
   c(13) = a12*b23 + a13*b33;
   c(14) = a14;

   c(21) = a21;
   c(22) = a22*b22 + a23*b32;
   c(23) = a22*b23 + a23*b33;
   c(24) = a24;

   c(31) = a31;
   c(32) = a32*b22 + a33*b32;
   c(33) = a32*b23 + a33*b33;
   c(34) = a34;

   c(41) = 0.f;
   c(42) = 0.f;
   c(43) = 0.f;
   c(44) = 1.f;

   #undef a
   #undef b
}

/*
** Matrix B has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultBRot001(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12),  b12 = b(12);
   float a13 = a(13);
   float a14 = a(14);
   float a21 = a(21),  b21 = b(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23);
   float a24 = a(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33);
   float a34 = a(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = a(44);

   c(11) = a11*b11 + a12*b21;
   c(12) = a11*b12 + a12*b22;
   c(13) = a13;
   c(14) = a14;

   c(21) = a21*b11 + a22*b21;
   c(22) = a21*b12 + a22*b22;
   c(23) = a23;
   c(24) = a24;

   c(31) = a31*b11 + a32*b21;
   c(32) = a31*b12 + a32*b22;
   c(33) = a33;
   c(34) = a34;

   c(41) = a41*b11 + a42*b21;
   c(42) = a41*b12 + a42*b22;
   c(43) = a43;
   c(44) = a44;

   #undef a
   #undef b
}

/*
** Matrix B has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultBRot010(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12);
   float a13 = a(13),  b13 = b(13);
   float a14 = a(14);
   float a21 = a(21);
   float a22 = a(22);
   float a23 = a(23);
   float a24 = a(24);
   float a31 = a(31),  b31 = b(31);
   float a32 = a(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = a(44);

   c(11) = a11*b11 + a13*b31;
   c(12) = a12;
   c(13) = a11*b13 + a13*b33;
   c(14) = a14;

   c(21) = a21*b11 + a23*b31;
   c(22) = a22;
   c(23) = a21*b13 + a23*b33;
   c(24) = a24;

   c(31) = a31*b11 + a33*b31;
   c(32) = a32;
   c(33) = a31*b13 + a33*b33;
   c(34) = a34;

   c(41) = a41*b11 + a43*b31;
   c(42) = a42;
   c(43) = a41*b13 + a43*b33;
   c(44) = a44;

   #undef a
   #undef b
}

/*
** Matrix B has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultBRot100(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11);
   float a12 = a(12);
   float a13 = a(13);
   float a14 = a(14);
   float a21 = a(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float a24 = a(24);
   float a31 = a(31);
   float a32 = a(32),  b32 = b(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = a(44);


   c(11) = a11;
   c(12) = a12*b22 + a13*b32;
   c(13) = a12*b23 + a13*b33;
   c(14) = a14;

   c(21) = a21;
   c(22) = a22*b22 + a23*b32;
   c(23) = a22*b23 + a23*b33;
   c(24) = a24;

   c(31) = a31;
   c(32) = a32*b22 + a33*b32;
   c(33) = a32*b23 + a33*b33;
   c(34) = a34;

   c(41) = a41;
   c(42) = a42*b22 + a43*b32;
   c(43) = a42*b23 + a43*b33;
   c(44) = a44;

   #undef a
   #undef b
}
// <--surgeon end

/*
** Matrix A has three rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultA0001(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12),  b12 = b(12);
   float a13 = a(13),  b13 = b(13);
   float a14 = a(14),  b14 = b(14);
   float a21 = a(21),  b21 = b(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float a24 = a(24),  b24 = b(24);
   float a31 = a(31),  b31 = b(31);
   float a32 = a(32),  b32 = b(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34),  b34 = b(34);
   float               b41 = b(41);
   float               b42 = b(42);
   float               b43 = b(43);
   float               b44 = b(44);


   c(11) = a11*b11 + a12*b21 + a13*b31 + a14*b41;
   c(12) = a11*b12 + a12*b22 + a13*b32 + a14*b42;
   c(13) = a11*b13 + a12*b23 + a13*b33 + a14*b43;
   c(14) = a11*b14 + a12*b24 + a13*b34 + a14*b44;

   c(21) = a21*b11 + a22*b21 + a23*b31 + a24*b41;
   c(22) = a21*b12 + a22*b22 + a23*b32 + a24*b42;
   c(23) = a21*b13 + a22*b23 + a23*b33 + a24*b43;
   c(24) = a21*b14 + a22*b24 + a23*b34 + a24*b44;

   c(31) = a31*b11 + a32*b21 + a33*b31 + a34*b41;
   c(32) = a31*b12 + a32*b22 + a33*b32 + a34*b42;
   c(33) = a31*b13 + a32*b23 + a33*b33 + a34*b43;
   c(34) = a31*b14 + a32*b24 + a33*b34 + a34*b44;

   c(41) = b41;
   c(42) = b42;
   c(43) = b43;
   c(44) = b44;

   #undef a
   #undef b
}

/*
** Matrix A is a translation matrix
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultATrans(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float               b11 = b(11);
   float               b12 = b(12);
   float               b13 = b(13);
   float a14 = a(14),  b14 = b(14);
   float               b21 = b(21);
   float               b22 = b(22);
   float               b23 = b(23);
   float a24 = a(24),  b24 = b(24);
   float               b31 = b(31);
   float               b32 = b(32);
   float               b33 = b(33);
   float a34 = a(34),  b34 = b(34);
   float               b41 = b(41);
   float               b42 = b(42);
   float               b43 = b(43);
   float               b44 = b(44);


b11 += a14*b41;
b12 += a14*b42;
b13 += a14*b43;
   c(11) = b11;
   c(12) = b12;
   c(13) = b13;


b21 += a24*b41;
b22 += a24*b42;
b23 += a24*b43;
   c(21) = b21;
   c(22) = b22;
   c(23) = b23;


b31 += a34*b41;
b32 += a34*b42;
b33 += a34*b43;
   c(31) = b31;
   c(32) = b32;
   c(33) = b33;

b14 += b44*a14;
b24 += b44*a24;
b34 += b44*a34;
   c(14) = b14;
   c(24) = b23;
   c(34) = b34;

   c(41) = b41;
   c(42) = b42;
   c(44) = b44;
   c(43) = b43;



   #undef a
   #undef b
}

/*
** Matrix B is a translation matrix
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultBTrans(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11);
   float a12 = a(12);
   float a13 = a(13);
   float a14 = a(14),  b14 = b(14);
   float a21 = a(21);
   float a22 = a(22);
   float a23 = a(23);
   float a24 = a(24),  b24 = b(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33);
   float a34 = a(34),  b34 = b(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = a(44);


a14 += b34*a13;
a24 += b34*a23;
a34 += b34*a33;
a44 += b34*a43;

a14 += b24*a12;
a24 += b24*a22;
a34 += b24*a32;
a44 += b24*a42;

a14 += b14*a11;
a24 += b14*a21;
a34 += b14*a31;
a44 += b14*a41;

c(14) = a14; 
c(24) = a24; 
c(34) = a34; 
c(44) = a44; 

   c(11) = a11;
   c(12) = a12;
   c(13) = a13;

   c(21) = a21;
   c(22) = a22;
   c(23) = a23;

   c(31) = a31;
   c(32) = a32;
   c(33) = a33;

   c(41) = a41;
   c(42) = a42;
   c(43) = a43;

   #undef a
   #undef b
}

//surgeon: added scaling, ortho and perspective matrices
/*
** Matrix B is a scaling matrix
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultBScale(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12);
   float a13 = a(13);
   float a14 = a(14);
   float a21 = a(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23);
   float a24 = a(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = a(44);

//surgeon: order switched to preserve registers

   c(11) = b11*a11;
   c(21) = b11*a21;
   c(31) = b11*a31;
   c(41) = b11*a41;

   c(12) = b22*a12;
   c(22) = b22*a22;
   c(32) = b22*a32;
   c(42) = b22*a42;

   c(13) = b33*a13;
   c(23) = b33*a23;
   c(33) = b33*a33;
   c(43) = b33*a43;

   c(14) = a14;
   c(24) = a24;
   c(34) = a34;
   c(44) = a44;

   #undef a
   #undef b
}
/*
** Matrix B is a orthogonal matrix
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultBOrtho(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12);
   float a13 = a(13);
   float a14 = a(14),  b14 = b(14);
   float a21 = a(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23);
   float a24 = a(24),  b24 = b(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34),  b34 = b(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = a(44);

//surgeon: pipelining

   c(11) = b11*a11;
   c(21) = b11*a21;
   c(31) = b11*a31;
   c(41) = b11*a41;

   c(12) = b22*a12;
   c(22) = b22*a22;
   c(32) = b22*a32;
   c(42) = b22*a42;
 
   c(13) = b33*a13;
   c(23) = b33*a23;
   c(33) = b33*a33;
   c(43) = b33*a43;

a14 += b34*a13;
a24 += b34*a23;
a34 += b34*a33;
a44 += b34*a43;

a14 += b24*a12;
a24 += b24*a22;
a34 += b24*a32;
a44 += b24*a42;

a14 += b14*a11;
a24 += b14*a21;
a34 += b14*a31;
a44 += b14*a41;

c(14) = a14; 
c(24) = a24; 
c(34) = a34; 
c(44) = a44; 

   #undef a
   #undef b
}

INLINE void m_MatMultBPersp(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12);
   float a13 = a(13),  b13 = b(13);
   float a14 = -a(14);
   float a21 = a(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float a24 = -a(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = -a(34),  b34 = b(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = -a(44);


   c(11) = b11*a11;
   c(21) = b11*a21;
   c(31) = b11*a31;
   c(41) = b11*a41;

   c(12) = b22*a12;
   c(22) = b22*a22;
   c(32) = b22*a32;
   c(42) = b22*a42;

   c(14) = b34*a13;
   c(24) = b34*a23;
   c(34) = b34*a33;
   c(44) = b34*a43;

a14 += b33*a13;
a24 += b33*a23;
a34 += b33*a33;
a44 += b33*a43;

a14 += b23*a12;
a24 += b23*a22;
a34 += b23*a32;
a44 += b23*a42;

a14 += b13*a11;
a24 += b13*a21;
a34 += b13*a31;
a44 += b13*a41;

c(13) = a14; 
c(23) = a24; 
c(33) = a34; 
c(43) = a44; 


   #undef a
   #undef b
}

//surgeon begin -->
/*
** Matrix B is a translation matrix
** Matrix A has 3 rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultA0001_BTrans(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11);
   float a12 = a(12);
   float a13 = a(13);
   float a14 = a(14),  b14 = b(14);
   float a21 = a(21);
   float a22 = a(22);
   float a23 = a(23);
   float a24 = a(24),  b24 = b(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33);
   float a34 = a(34),  b34 = b(34);



a14 += b34*a13;
a24 += b34*a23;
a34 += b34*a33;

a14 += b24*a12;
a24 += b24*a22;
a34 += b24*a32;

a14 += b14*a11;
a24 += b14*a21;
a34 += b14*a31;

c(14) = a14; 
c(24) = a24; 
c(34) = a34; 
c(44) = 1.f; 

   c(11) = a11;
   c(12) = a12;
   c(13) = a13;

   c(21) = a21;
   c(22) = a22;
   c(23) = a23;

   c(31) = a31;
   c(32) = a32;
   c(33) = a33;

   c(41) = 0.f;
   c(42) = 0.f;
   c(43) = 0.f;

   #undef a
   #undef b
}

//surgeon: added scaling, ortho and perspective matrices
/*
** Matrix B is a scaling matrix
** Matrix A has 3 rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultA0001_BScale(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12);
   float a13 = a(13);
   float a14 = a(14);
   float a21 = a(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23);
   float a24 = a(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34);


   c(11) = b11*a11;
   c(21) = b11*a21;
   c(31) = b11*a31;
   c(41) = 0.f;

   c(12) = b22*a12;
   c(22) = b22*a22;
   c(32) = b22*a32;
   c(42) = 0.f;

   c(13) = b33*a13;
   c(23) = b33*a23;
   c(33) = b33*a33;
   c(43) = 0.f;

   c(14) = a14;
   c(24) = a24;
   c(34) = a34;
   c(44) = 1.f;

   #undef a
   #undef b
}

/*
** Matrix B is a orthogonal matrix
** Matrix A has 3 rows
** Multiply matrix A by float field, storing the result in matrix C
*/
INLINE void m_MatMultA0001_BOrtho(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12);
   float a13 = a(13);
   float a14 = a(14),  b14 = b(14);
   float a21 = a(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23);
   float a24 = a(24),  b24 = b(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = a(34),  b34 = b(34);


   c(11) = b11*a11;
   c(21) = b11*a21;
   c(31) = b11*a31;
   c(41) = 0.f;

   c(12) = b22*a12;
   c(22) = b22*a22;
   c(32) = b22*a32;
   c(42) = 0.f;
 
   c(13) = b33*a13;
   c(23) = b33*a23;
   c(33) = b33*a33;
   c(43) = 0.f;

a14 += b34*a13;
a24 += b34*a23;
a34 += b34*a33;

a14 += b24*a12;
a24 += b24*a22;
a34 += b24*a32;

a14 += b14*a11;
a24 += b14*a21;
a34 += b14*a31;

c(14) = a14; 
c(24) = a24; 
c(34) = a34; 
c(44) = 1.f; 

   #undef a
   #undef b
}

INLINE void m_MatMultA0001_BPersp(Matrix *pA, float *pB, Matrix *pC)
{
   #define a(x) (pA->v[OF_##x])
   #define b(x) (pB[OF_##x])
   #define c(x) (pC->v[OF_##x])

   float a11 = a(11),  b11 = b(11);
   float a12 = a(12);
   float a13 = a(13),  b13 = b(13);
   float a14 = -a(14);
   float a21 = a(21);
   float a22 = a(22),  b22 = b(22);
   float a23 = a(23),  b23 = b(23);
   float a24 = -a(24);
   float a31 = a(31);
   float a32 = a(32);
   float a33 = a(33),  b33 = b(33);
   float a34 = -a(34),  b34 = b(34);
   float a41 = a(41);
   float a42 = a(42);
   float a43 = a(43);
   float a44 = -a(44);

   c(11) = b11*a11;
   c(21) = b11*a21;
   c(31) = b11*a31;
   c(41) = 0.f;

   c(12) = b22*a12;
   c(22) = b22*a22;
   c(32) = b22*a32;
   c(42) = 0.f;

   c(14) = b34*a13;
   c(24) = b34*a23;
   c(34) = b34*a33;
   c(44) = 0.f;

a14 += b33*a13;
a24 += b33*a23;
a34 += b33*a33;

a14 += b23*a12;
a24 += b23*a22;
a34 += b23*a32;

a14 += b13*a11;
a24 += b13*a21;
a34 += b13*a31;

c(13) = a14; 
c(23) = a24; 
c(33) = a34; 
c(43) = -1; 


   #undef a
   #undef b
}

//surgeon end <--

INLINE void m_LoadMatrixf(Matrix *pA, const float *v)
{
   #define a(x) (pA->v[OF_##x] = *v++)

   a(11); a(21); a(31); a(41);
   a(12); a(22); a(32); a(42);
   a(13); a(23); a(33); a(43);
   a(14); a(24); a(34); a(44);

   if (*(v-4) == 0.f && *(v-3) == 0.f && *(v-2) == 0.f && *(v-1) == 1.f)
      pA->flags = MGLMAT_0001;
   else
      pA->flags = MGLMAT_UNKNOWN;
   #undef a
}

INLINE void m_LoadMatrixd(Matrix *pA, const double *v)
{
   #define a(x) (pA->v[OF_##x] = (float)*v++)

   a(11); a(21); a(31); a(41);
   a(12); a(22); a(32); a(42);
   a(13); a(23); a(33); a(43);
   a(14); a(24); a(34); a(44);

   if (*(v-4) == 0.0 && *(v-3) == 0.0 && *(v-2) == 0.0 && *(v-1) == 1.0)
      pA->flags = MGLMAT_0001;
   else
      pA->flags = MGLMAT_UNKNOWN;

   #undef a
}


INLINE void m_LoadIdentity(Matrix *pA)
{
   #define a(x) (pA->v[OF_##x] = 0.f)
   #define b(x) (pA->v[OF_##x] = 1.f)

   b(11); a(21); a(31); a(41);
   a(12); b(22); a(32); a(42);
   a(13); a(23); b(33); a(43);
   a(14); a(24); a(34); b(44);

   pA->flags = MGLMAT_IDENTITY;

   #undef a
   #undef b
}

/*
** Multiply matrix A by the matrix passed by v.
** The vtype specifies what kind of matrix v points to, so that
** this routine may select an optimized matrix multiplication routine.
*/

INLINE void m_Mult(Matrix *pA, float *v, int vtype, Matrix *pC)
{

	if(pA->flags == MGLMAT_IDENTITY)
	{
		m_MatMultAIdent(v, pC);
		pC->flags = vtype;
		return;
	}
 
    if(pA->flags & (MGLMASK_NONE | MGLMAT_PERSPECTIVE)) 
    {
	switch (vtype)
	{
	case MGLMAT_ROT100:
		m_MatMultBRot100(pA, v, pC);
		break;

	case MGLMAT_ROT001:
		m_MatMultBRot001(pA, v, pC);
		break;

	case MGLMAT_ROT010:
		m_MatMultBRot010(pA, v, pC);
		break;

	case MGLMAT_TRANSLATION:
		m_MatMultBTrans(pA, v, pC);
		break;

	case MGLMAT_GENERAL_SCALE:
		m_MatMultBScale(pA, v, pC);
		break;

	case MGLMAT_PERSPECTIVE:
		m_MatMultBPersp(pA, v, pC);
		break;

	case MGLMAT_ORTHO:
		m_MatMultBOrtho(pA, v, pC);
		break;

	case MGLMAT_0001:
	case MGLMAT_ROTATION:
		{
		if(pA->flags & MGLMAT_PERSPECTIVE)
			m_MatMultAPerspB0001(pA, v, pC);
		else
			m_MatMultB0001(pA, v, pC);
		break;
		}

	default:
		switch (pA->flags)
		{
		case MGLMAT_TRANSLATION:
			m_MatMultATrans(pA, v, pC);
			break;

		case MGLMAT_0001:
		case MGLMAT_ROTATION:
			m_MatMultA0001(pA, v, pC);
			break;
		default: //MGLMASK_UNKNOWN
			m_MatMultGeneral(pA, v, pC);
			break;
		}
	break;
	}
    }
    else //pA = MGLMASK_0001
    {
	switch (vtype)
	{
	case MGLMAT_ROT100:
		m_MatMultA0001_BRot100(pA, v, pC);
		break;

	case MGLMAT_ROT001:
		m_MatMultA0001_BRot001(pA, v, pC);
		break;

	case MGLMAT_ROT010:
		m_MatMultA0001_BRot010(pA, v, pC);
		break;

	case MGLMAT_TRANSLATION:
		m_MatMultA0001_BTrans(pA, v, pC);
		break;

	case MGLMAT_GENERAL_SCALE:
		m_MatMultA0001_BScale(pA, v, pC);
		break;

	case MGLMAT_PERSPECTIVE:
		m_MatMultA0001_BPersp(pA, v, pC);
		break;

	case MGLMAT_ORTHO:
		m_MatMultA0001_BOrtho(pA, v, pC);
		break;

	case MGLMAT_0001:
	case MGLMAT_ROTATION:
		m_MatMultA0001_B0001(pA, v, pC);
		break;

	default:
		m_MatMultA0001(pA, v, pC);
		break;
	}

    }

	pC->flags = MGLMAT_UNKNOWN;

#if 0 //not used

	if ((vtype == MGLMAT_PERSPECTIVE) && (pA->flags & MGLMASK_0001))
	{
	pC->flags = MGLMAT_00NEG10;
	return;
	}

#endif

	if (!(vtype & MGLMASK_NONE))
	{
		if (!(pA->flags & MGLMASK_NONE))
		pC->flags = MGLMAT_0001;
   	}

}


void m_CombineMatrices(GLcontext context)
{
  context->CombinedValid = GL_TRUE;

  m_Mult(CurrentP, CurrentMV->v, CurrentMV->flags, 			   &(context->CombinedMatrix));

}


void m_PrintMatrix(Matrix *pA)
{
#ifndef NDEBUG
   #define a(x) (pA->v[OF_##x])
   printf("Matrix at 0x%lX\n", (ULONG)pA);
   printf("    | %3.6f %3.6f %3.6f %3.6f |\n",
      a(11), a(12), a(13), a(14));
   printf("    | %3.6f %3.6f %3.6f %3.6f |\n",
      a(21), a(22), a(23), a(24));
   printf("A = | %3.6f %3.6f %3.6f %3.6f |\n",
      a(31), a(32), a(33), a(34));
   printf("    | %3.6f %3.6f %3.6f %3.6f |\n",
      a(41), a(42), a(43), a(44));
   #undef a
#endif
}

// Interface functions
void GLMatrixMode(GLcontext context, GLenum mode)
{
   //LOG(3, glMatrixMode, "%d", mode);
   GLASSERT(mode == GL_PROJECTION || mode == GL_MODELVIEW);
   GLASSERT(context != NULL);

   context->CurrentMatrixMode = mode;
}

void GLLoadIdentity(GLcontext context)
{
   //LOG(3, glLoadIdentity, "");
   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   if (context->CurrentMatrixMode == GL_MODELVIEW)
   {
      m_LoadIdentity(CurrentMV);
   }
   else
   {
      m_LoadIdentity(CurrentP);
   }
   context->CombinedValid = GL_FALSE;
   context->InvRotValid = GL_FALSE;
}

void MGLPrintMatrix(GLcontext context, int mode)
{
#ifndef NDEBUG
   if (mode == GL_MODELVIEW)
   {
      m_PrintMatrix(CurrentMV);
   }
   else
   {
      m_PrintMatrix(CurrentP);
   }
   printf("\n");
#endif
}

void MGLPrintMatrixStack(GLcontext context, int mode)
{
#ifndef NDEBUG
   int i;

   printf("Stack Top:\n");
   MGLPrintMatrix(context, mode);
   printf("Rest of stack:\n");

   if (mode == GL_MODELVIEW) {
      if (context->ModelViewStackPointer == 0) {
         printf("Empty\n\n\n");
         return;
      }
      for (i=context->ModelViewStackPointer-1; i>=0; i--)
      {
         printf("%d:\n", i);
         m_PrintMatrix(&(context->ModelViewStack[i]));
      }
   }
   else
   {
      if (context->ProjectionStackPointer == 0) {
         printf("Empty\n\n\n");
         return;
      }
      for (i=context->ProjectionStackPointer-1; i>=0; i--)
      {
         printf("%d:\n", i);
         m_PrintMatrix(&(context->ProjectionStack[i]));
      }
   }
   printf("\n\n");
#endif
}


void GLLoadMatrixf(GLcontext context, const GLfloat *m)
{
   //LOG(3, glLoadMatrixf, "%f %f %f ...", *m, *(m+1), *(m+2));
   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   
   context->CombinedValid = GL_FALSE;
   context->InvRotValid = GL_FALSE;
   m_LoadMatrixf(CMATRIX(context), m);
}

void GLLoadMatrixd(GLcontext context, const GLdouble *m)
{
   //LOG(3, glLoadMatrixf, "%lf %lf %lf ...", *m, *(m+1), *(m+2));
   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   
   context->CombinedValid = GL_FALSE;
   context->InvRotValid = GL_FALSE;
   m_LoadMatrixd(CMATRIX(context), m);
}

void GLPushMatrix(GLcontext context)
{
   //LOG(3, glPushMatrix, "");
   GLASSERT(context != NULL);
   GLASSERT(context->ProjectionStackPointer <= PROJECTION_STACK_SIZE);
   GLASSERT(context->ModelViewStackPointer  <= MODELVIEW_STACK_SIZE);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);

   if (context->CurrentMatrixMode == GL_PROJECTION)
   {
      m_MatCopy(&(context->ProjectionStack[context->ProjectionStackPointer]),
         CurrentP);
      context->ProjectionStackPointer ++;
   }
   else
   {
      m_MatCopy(&(context->ModelViewStack[context->ModelViewStackPointer]),
         CurrentMV);
      context->ModelViewStackPointer ++;
   }
}

void GLPopMatrix(GLcontext context)
{
   //LOG(3, glPopMatrix, "");
   GLASSERT(context != NULL);
   GLASSERT(context->ProjectionStackPointer >= 0);
   GLASSERT(context->ModelViewStackPointer  >= 0);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

   if (context->CurrentMatrixMode == GL_PROJECTION)
   {
      if (context->ProjectionStackPointer <= 0)
      {
         context->CurrentError = GL_INVALID_OPERATION;
         return;
      }
      context->ProjectionStackPointer --;
      m_MatCopy(CurrentP,
         &(context->ProjectionStack[context->ProjectionStackPointer]));
   }
   else
   {
      if (context->ModelViewStackPointer <= 0)
      {
         context->CurrentError = GL_INVALID_OPERATION;
         return;
      }
      context->ModelViewStackPointer --;
      m_MatCopy(CurrentMV,
         &(context->ModelViewStack[context->ModelViewStackPointer]));
   }

}

void GLFrustum(GLcontext context, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
{

/*
layout:
		X  0  X  0

		0  X  X  0

		0  0  X  X

		0  0 -1  0
*/

   float v[16];
   float n2 = 2.0*zNear;
   float rli = 1.f / (float)(right-left);
   float tbi = 1.f / (float)(top-bottom);
   float fni = 1.f / (float)(zFar-zNear);

   //LOG(3, glFrustum, "%lf &lf %lf %lf %lf %lf", left, right, bottom, top, zNear, zFar);

   GLASSERT(context != NULL);
   GLFlagError(context, zFar<=0.0 || zNear <=0.0, GL_INVALID_VALUE);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

   v[OF_11] = n2*rli; v[OF_21] = 0.0;
   v[OF_31] = 0.0; v[OF_41] = 0.0;

   v[OF_22] = n2*tbi;
   v[OF_12] = 0.0; v[OF_32] = 0.0; v[OF_42] = 0.0;

   v[OF_13] = (right+left)*rli; v[OF_23] = (top+bottom)*tbi;
   v[OF_33] = -(zFar+zNear)*fni;
   v[OF_43] = -1.0;

   v[OF_14] = 0.0; v[OF_24] = 0.0;
   v[OF_34] = -(2.0*zFar*zNear)*fni;
   v[OF_44] = 0.0;

   m_Mult(CMATRIX(context),
      v,
      MGLMAT_PERSPECTIVE,
      OMATRIX(context)
      );
   SMATRIX(context);
/*
   m_MatMultBPersp(CMATRIX(context), v, OMATRIX(context));
   SMATRIX(context);
*/
}

void GLOrtho(GLcontext context, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
{

/*
layout:
		X  0  0  X

		0  X  0  X

		0  0  X  X

		0  0  0  1
*/

   float rli = 1.0  / (right-left);
   float tbi = 1.0  / (top-bottom);
   float fni = 1.0 / (zFar-zNear);
   float v[16];

   //LOG(3, glOrtho, "%lf %lf %lf %lf %lf %lf", left, right, bottom, top, zNear, zFar);

   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

   v[OF_11] = 2.0*rli;
   v[OF_12] = 0.0; v[OF_13] = 0.0;
   v[OF_14] = -(right+left)*rli;

   v[OF_21] = 0.0;
   v[OF_22] = 2.0*tbi;
   v[OF_23] = 0.0;
   v[OF_24] = -(top+bottom)*tbi;

   v[OF_31] = 0.0;
   v[OF_32] = 0.0;
   v[OF_33] = -2.0*fni; v[OF_34] = -(zFar+zNear)*fni;

   v[OF_41] = v[OF_42] = v[OF_43] = 0.0;
   v[OF_44] = 1.0;

   m_Mult(CMATRIX(context), v, MGLMAT_ORTHO, OMATRIX(context));
   SMATRIX(context);
/*
   m_MatMultBOrtho(CMATRIX(context), v, OMATRIX(context));
   SMATRIX(context);
*/
}

void GLMultMatrixf(GLcontext context, const GLfloat *mat)
{
   //LOG(3, glMultMatrixf, "%f %f %f ...", *mat, *(mat+1), *(mat+2));
   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

//   m_Mult(CMATRIX(context), (float *)mat, 0, OMATRIX(context));
   m_Mult(CMATRIX(context), (float *)mat, MGLMAT_UNKNOWN, OMATRIX(context));
   SMATRIX(context);
}

void GLMultMatrixd(GLcontext context, const GLdouble *mat)
{
   GLfloat v[16];
   int i;
   //LOG(3, glMultMatrixd, "%lf %lf %lf ...", *mat, *(mat+1), *(mat+2));

   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

   for (i=0; i<16; i++)
   {
        v[i] = (GLfloat) *mat++;
   }

//   m_Mult(CMATRIX(context), v, 0, OMATRIX(context));
   m_Mult(CMATRIX(context), v, MGLMAT_UNKNOWN, OMATRIX(context));
   SMATRIX(context);
}

/*
** The following routine was ripped from the Mesa source code.
** I did use this because it is much better than my original design. The code
** is just modified a bit to adapt to my code layout, but otherwise is unmodified.
** This code is included with the kind permission of Brian Paul, the author of Mesa.
*/


void GLRotatef(GLcontext context, GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{

/*
layout:
x x x 0
x x x 0
x x x 0
0 0 0 1
*/

   float v[16];
   float mag, s, c;
   float xx,yy,zz,xy,yz,zx,xs,ys,zs,one_c;

   #define v(x) (v[OF_##x])

   //LOG(3, glRotatef, "%f %f %f %f", angle, x,y,z);

   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

//moved by surgeon
// s = (float)sin(angle * PI/180.0);
// c = (float)cos(angle * PI/180.0);
// mag = sqrt(x*x+y*y+z*z);

   xx = x*x;
   yy = y*y;
   zz = z*z;
   mag = sqrt(xx+yy+zz);

   if (mag == 0.0) return;

   if (mag != 1.0)
   {
      x /= mag;
      y /= mag;
      z /= mag;
   //surgeon
      xx = x*x;
      yy = y*y;
      zz = z*z;
   }

#ifdef TRIGTABLES
   s = (float)MGLSIN(angle);
   c = (float)MGLCOS(angle);
#else
   s = (float)sin(angle * PI/180.0);
   c = (float)cos(angle * PI/180.0);
#endif

// xx = x*x;
// yy = y*y;
// zz = z*z;
   xy = x*y;
   yz = y*z;
   zx = z*x;
   xs = x*s;
   ys = y*s;
   zs = z*s;

   one_c = 1.f - c;

   v(11) = one_c*xx + c;
   v(12) = one_c*xy - zs;
   v(13) = one_c*zx + ys;

   v(21) = one_c*xy + zs;
   v(22) = one_c*yy + c;
   v(23) = one_c*yz - xs;

   v(31) = one_c*zx - ys;
   v(32) = one_c*yz + xs;
   v(33) = one_c*zz + c;

   v(14) = v(24) = v(34) = 0.f;
   v(41) = 0.f;
   v(42) = 0.f;
   v(43) = 0.f;
   v(44) = 1.f;

   m_Mult(CMATRIX(context), v, MGLMAT_ROTATION, OMATRIX(context));
   SMATRIX(context);
   #undef v
}

void GLRotated(GLcontext context, GLdouble angle, GLdouble x, GLdouble y, GLdouble z)
{
   GLRotatef(context, (GLfloat)angle, (GLfloat)x, (GLfloat)y, (GLfloat)z);
}

/**********************************************************
Simplified ultra-fast rotation-routines by SuRgEoN
***********************************************************/

void GLRotatefEXT(GLcontext context, GLfloat angle, const GLint xyz)
{

/*
layout:

001:
x x 0 0
x x 0 0
0 0 1 0
0 0 0 1


010:
x 0 x 0
0 1 0 0
x 0 x 0
0 0 0 1

100:
1 0 0 0
0 x x 0
0 x x 0
0 0 0 1

*/

   float c,s;
   float v[16];

   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

   s = (float)sin(angle * PI/180.0);
   c = (float)cos(angle * PI/180.0);

#define v(x) (v[OF_##x])

   v(14) = v(24) = v(34) = 0.f;
   v(41) = 0.f;
   v(42) = 0.f;
   v(43) = 0.f;
   v(44) = 1.f;

if(xyz == GLROT_001)
{
   v(11) = c;
   v(12) = -s;
   v(13) = 0.f;
   v(21) = s;
   v(22) = c;
   v(23) = 0.f;
   v(31) = 0.f;
   v(32) = 0.f;
   v(33) = 1.f;
}
else if (xyz == GLROT_010)
{
   v(11) = c;
   v(12) = 0.f;
   v(13) = s;
   v(21) = 0.f;
   v(22) = 1.f;
   v(23) = 0.f;
   v(31) = -s;
   v(32) = 0.f;
   v(33) = c;

}
else //if (xyz == GLROT_100)
{
   v(11) = 1.f;
   v(12) = 0.f;
   v(13) = 0.f;
   v(21) = 0.f;
   v(22) = c;
   v(23) = -s;
   v(31) = 0.f;
   v(32) = s;
   v(33) = c;
}


   m_Mult(CMATRIX(context), v, xyz, OMATRIX(context));
   SMATRIX(context);
#undef v
}

void GLRotatefEXTs(GLcontext context, GLfloat sin_an, GLfloat cos_an, const GLint xyz)
{

/*
layout:

001:
x x 0 0
x x 0 0
0 0 1 0
0 0 0 1


010:
x 0 x 0
0 1 0 0
x 0 x 0
0 0 0 1

100:
1 0 0 0
0 x x 0
0 x x 0
0 0 0 1

*/
float v[16];

   GLASSERT(context != NULL);
   GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

#define v(x) (v[OF_##x])

   v(14) = v(24) = v(34) = 0.f;
   v(41) = 0.f;
   v(42) = 0.f;
   v(43) = 0.f;
   v(44) = 1.f;

if(xyz == GLROT_001)
{
   v(11) = cos_an;
   v(12) = -sin_an;
   v(13) = 0.f;
   v(21) = sin_an;
   v(22) = cos_an;
   v(23) = 0.f;
   v(31) = 0.f;
   v(32) = 0.f;
   v(33) = 1.f;
}
else if (xyz == GLROT_010)
{
   v(11) = cos_an;
   v(12) = 0.f;
   v(13) = sin_an;
   v(21) = 0.f;
   v(22) = 1.f;
   v(23) = 0.f;
   v(31) = -sin_an;
   v(32) = 0.f;
   v(33) = cos_an;
}
else //if (xyz == GLROT_100)
{
   v(11) = 1.f;
   v(12) = 0.f;
   v(13) = 0.f;
   v(21) = 0.f;
   v(22) = cos_an;
   v(23) = -sin_an;
   v(31) = 0.f;
   v(32) = sin_an;
   v(33) = cos_an;
}

   m_Mult(CMATRIX(context), v, xyz, OMATRIX(context));
   SMATRIX(context);
#undef v
}

void GLScaled(GLcontext context, GLdouble x, GLdouble y, GLdouble z)
{
   float v[16];
   //LOG(3, glScaled, "%lf %lf %lf", x,y,z);
   GLASSERT(context!=NULL);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;
   #define v(x) (v[OF_##x])
   v(11) = (float)x;

   v(12) = 0.0; v(13) = 0.0; v(14) = 0.0;
   v(21) = 0.0;

   v(22) = (float)y;

   v(23) = 0.0; v(24) = 0.0;
   v(31) = 0.0; v(32) = 0.0;

   v(33) = (float)z;

   v(34) = 0.0;
   v(41) = 0.0; v(42) = 0.0; v(43) = 0.0; v(44) = 1.0;

   m_Mult(CMATRIX(context), v, MGLMAT_GENERAL_SCALE, OMATRIX(context));
   SMATRIX(context);
/*
   m_MatMultBScale(CMATRIX(context), v, OMATRIX(context));
   SMATRIX(context);
*/
   #undef v
}

void GLScalef(GLcontext context, GLfloat x, GLfloat y, GLfloat z)
{

/*
layout:
x 0 0 0
0 y 0 0
0 0 z 0
0 0 0 1
*/

   float v[16];
   //LOG(3, glScalef, "%f %f %f", x,y,z);
   GLASSERT(context!=NULL);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;
   #define v(x) (v[OF_##x])
   v(11) = x;

   v(12) = 0.0; v(13) = 0.0; v(14) = 0.0;
   v(21) = 0.0;

   v(22) = y;

   v(23) = 0.0; v(24) = 0.0;
   v(31) = 0.0; v(32) = 0.0;

   v(33) = z;

   v(34) = 0.0;
   v(41) = 0.0; v(42) = 0.0; v(43) = 0.0; v(44) = 1.0;

   m_Mult(CMATRIX(context), v, MGLMAT_GENERAL_SCALE, OMATRIX(context));
   SMATRIX(context);
/*
   m_MatMultBScale(CMATRIX(context), v, OMATRIX(context));
   SMATRIX(context);
*/
   #undef v
}

void GLTranslated(GLcontext context, GLdouble x, GLdouble y, GLdouble z)
{
   float v[16];

   //LOG(3, glTranslated, "%lf %lf %lf", x,y,z);

   GLASSERT(context != NULL);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

   #define v(x) (v[OF_##x])
     v(11) = v(22) = v(33) = v(44) = 1.f;
     v(21) = v(31) = v(41) = v(12) = v(32) = v(42) = v(13) = v(23) = v(43) = 0.f;


   v(14) = (float)x; v(24) = (float)y; v(34) = (float)z;

   m_Mult(CMATRIX(context), v, MGLMAT_TRANSLATION, OMATRIX(context));
   SMATRIX(context);
/*
   m_MatMultBTrans(CMATRIX(context), v, OMATRIX(context));
   SMATRIX(context);
*/
   #undef v
}

void GLTranslatef(GLcontext context, GLfloat x, GLfloat y, GLfloat z)
{
/*
layout:
1 0 0 x
0 1 0 y
0 0 1 z
0 0 0 1
*/

   float vv[16];
   //LOG(3, glTranslatef, "%f %f %f", x,y,z);

   GLASSERT(context != NULL);
   context->InvRotValid = GL_FALSE;
   context->CombinedValid = GL_FALSE;

   #define v(x) (vv[OF_##x])
     v(11) = v(22) = v(33) = v(44) = 1.f;
     v(21) = v(31) = v(41) = v(12) = v(32) = v(42) = v(13) = v(23) = v(43) = 0.f;

   v(14) = (float)x; v(24) = (float)y; v(34) = (float)z;

   #undef v

   m_Mult(CMATRIX(context), vv, MGLMAT_TRANSLATION, OMATRIX(context));
   SMATRIX(context);

/*
   m_MatMultBTrans(CMATRIX(context), vv, OMATRIX(context));
   SMATRIX(context);
*/
}

void GLMatrixInit(GLcontext context)
{
   context->ModelViewStackPointer = 0;
   context->ProjectionStackPointer = 0;
   context->ModelViewNr = 0;
   context->ProjectionNr = 0;
   context->CombinedValid = GL_FALSE;
   context->InvRotValid = GL_FALSE;
   GLMatrixMode(context, GL_PROJECTION);
   GLLoadIdentity(context);
   GLMatrixMode(context, GL_MODELVIEW);
   GLLoadIdentity(context);

}

