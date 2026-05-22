/*
 * $Id: glu.c,v 1.1.1.1 2000/04/07 19:44:51 tfrieden Exp $
 *
 * $Date: 2000/04/07 19:44:51 $
 * $Revision: 1.1.1.1 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */
#include "sysinc.h"

#include <mgl/gl.h>
#include <math.h>


#include <stdio.h>


#define VEC_NORM(v)                                      \
{                                                        \
    GLfloat m = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]); \
    v[0] /= m;                                           \
    v[1] /= m;                                           \
    v[2] /= m;                                           \
}

#define VEC_CROSS(v, a, b)                               \
    v[0] = a[1] * b[2] - a[2] * b[1];                    \
    v[1] = a[2] * b[0] - a[0] * b[2];                    \
    v[2] = a[0] * b[1] - a[1] * b[0];

#define VEC_SUB(v, a, b)                                 \
    v[0] = a[0] - b[0];                                  \
    v[1] = a[1] - b[1];                                  \
    v[2] = a[2] - b[2];

#define VEC_ADD(v, a, b)                                 \
    v[0] = a[0] + b[0];                                  \
    v[1] = a[1] + b[1];                                  \
    v[2] = a[2] + b[2];

#define VEC_PRINT(v)                                     \
    printf("<%f, %f, %f>\n", v[0], v[1], v[2]);

static char rcsid[] = "$Id: glu.c,v 1.1.1.1 2000/04/07 19:44:51 tfrieden Exp $ ";


void GLULookAt(GLfloat ex, GLfloat ey, GLfloat ez, GLfloat cx, GLfloat cy, GLfloat cz, GLfloat ux, GLfloat uy, GLfloat uz)
{
    GLfloat u[3], v[3], w[3];
    GLfloat m[16];

    w[0] = ex - cx;     w[1] = ey - cy;     w[2] = ez - cz;
    v[0] = ux;          v[1] = uy;          v[2] = uz;

    VEC_NORM(w);
    VEC_CROSS(u, v, w);
    VEC_CROSS(v, w, u);
    VEC_NORM(u);
    VEC_NORM(v);

    m[ 0] = u[0];   m[ 1] = v[0];   m[ 2] = w[0];   m[ 3] = 0.0;
    m[ 4] = u[1];   m[ 5] = v[1];   m[ 6] = w[1];   m[ 7] = 0.0;
    m[ 8] = u[2];   m[ 9] = v[2];   m[10] = w[2];   m[11] = 0.0;
    m[12] = 0.0;    m[13] = 0.0;    m[14] = 0.0;    m[15] = 1.0;

    glMultMatrixf(m);
    glTranslatef(-ex, -ey, -ez);
}

void GLUPerspective(GLfloat fovy, GLfloat aspect, GLfloat znear, GLfloat zfar)
{
   GLfloat xmin, xmax, ymin, ymax;

   ymax = znear * tan(fovy * 0.008726646);
   ymin = -ymax;
   xmin = ymin * aspect;
   xmax = ymax * aspect;

   glFrustum(xmin, xmax, ymin, ymax, znear, zfar);
}


