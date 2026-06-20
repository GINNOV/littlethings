/*
 * (c) Copyright 1995, Silicon Graphics, Inc.
 * ALL RIGHTS RESERVED
 * Permission to use, copy, modify, and distribute this software for
 * any purpose and without fee is hereby granted, provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation, and that
 * the name of Silicon Graphics, Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission.
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
 * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
 * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
 * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * US Government Users Restricted Rights
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics,
 * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
 *
 * Author: John Spitzer, SGI Applied Engineering
 *
 */

/* Define calls if using function pointers or not */
#ifdef FUNCTION_PTRS
  #if (TRANSFORM_TYPE == Translate)
   #ifdef WIN32
    #define DEFINE_TRANSFORM void (APIENTRY *translate)(GLfloat, GLfloat, GLfloat) = glTranslatef;
   #else
    #define DEFINE_TRANSFORM void (*translate)(GLfloat, GLfloat, GLfloat) = glTranslatef;
   #endif
    #define TRANSFORM_CALL (*translate)(ptr[0], ptr[1], ptr[2]); ptr+=3;
  #elif (TRANSFORM_TYPE == Rotate)
   #ifdef WIN32
    #define DEFINE_TRANSFORM void (APIENTRY *rotate)(GLfloat, GLfloat, GLfloat, GLfloat) = glRotatef;
   #else
    #define DEFINE_TRANSFORM void (*rotate)(GLfloat, GLfloat, GLfloat, GLfloat) = glRotatef;
   #endif
    #define TRANSFORM_CALL (*rotate)(ptr[0], ptr[1], ptr[2], ptr[3]); ptr+=4;
  #elif (TRANSFORM_TYPE == Scale)
   #ifdef WIN32
    #define DEFINE_TRANSFORM void (APIENTRY *scale)(GLfloat, GLfloat, GLfloat) = glScalef;
   #else
    #define DEFINE_TRANSFORM void (*scale)(GLfloat, GLfloat, GLfloat) = glScalef;
   #endif
    #define TRANSFORM_CALL (*scale)(ptr[0], ptr[1], ptr[2]); ptr+=3;
  #elif (TRANSFORM_TYPE == Perspective)
   #ifdef WIN32
    #define DEFINE_TRANSFORM void (APIENTRY *perspective)(GLdouble, GLdouble, GLdouble, GLdouble) = gluPerspective;
   #else
    #define DEFINE_TRANSFORM void (*perspective)(GLdouble, GLdouble, GLdouble, GLdouble) = gluPerspective;
   #endif
    #define TRANSFORM_CALL (*perspective)(ptr[0], ptr[1], ptr[2], ptr[3]); ptr+=4;
  #elif (TRANSFORM_TYPE == Ortho)
   #ifdef WIN32
    #define DEFINE_TRANSFORM void (APIENTRY *ortho)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble) = glOrtho;
   #else
    #define DEFINE_TRANSFORM void (*ortho)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble) = glOrtho;
   #endif
    #define TRANSFORM_CALL (*ortho)(ptr[0], ptr[1], ptr[2], ptr[3], ptr[4], ptr[5]); ptr+=6;
  #elif (TRANSFORM_TYPE == Ortho2)
   #ifdef WIN32
    #define DEFINE_TRANSFORM void (APIENTRY *ortho2)(GLdouble, GLdouble, GLdouble, GLdouble) = gluOrtho2D;
   #else
    #define DEFINE_TRANSFORM void (*ortho2)(GLdouble, GLdouble, GLdouble, GLdouble) = gluOrtho2D;
   #endif
    #define TRANSFORM_CALL (*ortho2)(ptr[0], ptr[1], ptr[2], ptr[3]); ptr+=4;
  #elif (TRANSFORM_TYPE == Frustum)
   #ifdef WIN32
    #define DEFINE_TRANSFORM void (APIENTRY *frustum)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble) = glFrustum;
   #else
    #define DEFINE_TRANSFORM void (*frustum)(GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble) = glFrustum;
   #endif
    #define TRANSFORM_CALL (*frustum)(ptr[0], ptr[1], ptr[2], ptr[3], ptr[4], ptr[5]); ptr+=6;
  #endif
  #ifdef POINT_DRAW
    #define VERTEX_CALL  (*vertex3fv)(point);
    #define BEGIN_CALL   (*begin)(GL_POINTS);
    #define END_CALL     (*end)();
  #endif
  #ifdef PUSH_POP
    #define PUSH_CALL  (*pushmatrix)();
    #define POP_CALL   (*popmatrix)();
  #endif
#else
  #if (TRANSFORM_TYPE == Translate)
    #define TRANSFORM_CALL glTranslatef(ptr[0], ptr[1], ptr[2]); ptr+=3;
  #elif (TRANSFORM_TYPE == Rotate)
    #define TRANSFORM_CALL glRotatef(ptr[0], ptr[1], ptr[2], ptr[3]); ptr+=4;
  #elif (TRANSFORM_TYPE == Scale)
    #define TRANSFORM_CALL glScalef(ptr[0], ptr[1], ptr[2]); ptr+=3;
  #elif (TRANSFORM_TYPE == Perspective)
    #define TRANSFORM_CALL gluPerspective(ptr[0], ptr[1], ptr[2], ptr[3]); ptr+=4;
  #elif (TRANSFORM_TYPE == Ortho)
    #define TRANSFORM_CALL glOrtho(ptr[0], ptr[1], ptr[2], ptr[3], ptr[4], ptr[5]); ptr+=6;
  #elif (TRANSFORM_TYPE == Ortho2)
    #define TRANSFORM_CALL gluOrtho2D(ptr[0], ptr[1], ptr[2], ptr[3]); ptr+=4;
  #elif (TRANSFORM_TYPE == Frustum)
    #define TRANSFORM_CALL glFrustum(ptr[0], ptr[1], ptr[2], ptr[3], ptr[4], ptr[5]); ptr+=6;
  #endif
  #ifdef POINT_DRAW
    #define VERTEX_CALL  glVertex3fv(point);
    #define BEGIN_CALL   glBegin(GL_POINTS);
    #define END_CALL     glEnd();
  #endif
  #ifdef PUSH_POP
    #define PUSH_CALL  glPushMatrix();
    #define POP_CALL   glPopMatrix();
  #endif
#endif

#ifdef POINT_DRAW
  #define DEFINE_POINT GLfloat point[3] = { 0.0, 0.0, -1.0 };
  #define PRE_TRANSFORM  \
    TRANSFORM_CALL \
    BEGIN_CALL   \
    VERTEX_CALL  \
    END_CALL
#else
  #define DEFINE_POINT
  #define PRE_TRANSFORM  \
    TRANSFORM_CALL
#endif

#ifdef PUSH_POP
  #define TRANSFORM \
    PUSH_CALL       \
    PRE_TRANSFORM   \
    POP_CALL
#else
  #define TRANSFORM \
    PRE_TRANSFORM
#endif
  
/* Unroll the transforms to the number specified */
#if (UNROLL == 1)
  #define UNROLLED_TRANSFORMS TRANSFORM
  #define DEFINE_CLEANUP
#elif (UNROLL == 2)
  #define UNROLLED_TRANSFORMS TRANSFORM TRANSFORM
  #define DEFINE_CLEANUP int remainingTransforms = iterations & 1;
#elif (UNROLL == 3)
  #define UNROLLED_TRANSFORMS TRANSFORM TRANSFORM TRANSFORM
  #define DEFINE_CLEANUP int remainingTransforms = iterations % 3;
#elif (UNROLL == 4)
  #define UNROLLED_TRANSFORMS TRANSFORM TRANSFORM TRANSFORM TRANSFORM
  #define DEFINE_CLEANUP int remainingTransforms = iterations & 3;
#elif (UNROLL == 5)
  #define UNROLLED_TRANSFORMS TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM
  #define DEFINE_CLEANUP int remainingTransforms = iterations % 5;
#elif (UNROLL == 6)
  #define UNROLLED_TRANSFORMS TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM
  #define DEFINE_CLEANUP int remainingTransforms = iterations % 6;
#elif (UNROLL == 7)
  #define UNROLLED_TRANSFORMS TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM
  #define DEFINE_CLEANUP int remainingTransforms = iterations % 7;
#elif (UNROLL == 8)
  #define UNROLLED_TRANSFORMS TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM TRANSFORM
  #define DEFINE_CLEANUP int remainingTransforms = iterations & 7;
#endif

#if (UNROLL > 1)
  #define CLEANUP_LOOP \
    ptr = data; \
    for (i=remainingTransforms; i>0; i--) { \
      TRANSFORM \
    }
#else
  #define CLEANUP_LOOP
#endif

void FUNCTION (TestPtr thisTest)
{
    TransformPtr this = (TransformPtr)thisTest;
    int iterations = this->iterations;
    int loops = iterations/UNROLL;
    int i;
    DEFINE_POINT
    DEFINE_CLEANUP
    GLfloat *data = this->transformData;
    GLfloat *ptr;
  #ifdef FUNCTION_PTRS
   #ifdef WIN32
    #ifdef POINT_DRAW
      void (APIENTRY *vertex3fv)(const GLfloat*) = glVertex3fv;
      void (APIENTRY *begin)(GLenum) = glBegin;
      void (APIENTRY *end)(void) = glEnd;
    #endif
    #ifdef PUSH_POP
      void (APIENTRY *pushmatrix)(void) = glPushMatrix;
      void (APIENTRY *popmatrix)(void) = glPopMatrix;
    #endif
   #else
    #ifdef POINT_DRAW
      void (*vertex3fv)(const GLfloat*) = glVertex3fv;
      void (*begin)(GLenum) = glBegin;
      void (*end)(void) = glEnd;
    #endif
    #ifdef PUSH_POP
      void (*pushmatrix)(void) = glPushMatrix;
      void (*popmatrix)(void) = glPopMatrix;
    #endif
   #endif
    DEFINE_TRANSFORM
  #endif

    for (i=loops; i>0; i--) {
        ptr = data;
        UNROLLED_TRANSFORMS
    }
    CLEANUP_LOOP
}

#undef TRANSFORM_CALL
#undef BEGIN_CALL
#undef END_CALL
#undef VERTEX_CALL
#undef PUSH_CALL
#undef POP_CALL
#undef PRE_TRANSFORM
#undef TRANSFORM
#undef UNROLLED_TRANSFORMS
#undef DEFINE_TRANSFORM
#undef DEFINE_POINT
#undef DEFINE_CLEANUP
#undef CLEANUP_LOOP
