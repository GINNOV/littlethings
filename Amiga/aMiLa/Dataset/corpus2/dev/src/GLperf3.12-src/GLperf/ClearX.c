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
  #define CLEAR_CALL   (*clear)(mask);
  #ifdef POINT_DRAW
    #define VERTEX_CALL \
      (*vertex3fv)(point1); \
      (*vertex3fv)(point2); \
      (*vertex3fv)(point3); \
      (*vertex3fv)(point4);
    #define BEGIN_CALL   (*begin)(GL_POINTS);
    #define END_CALL     (*end)();
  #endif
#else
  #define CLEAR_CALL   glClear(mask);
  #ifdef POINT_DRAW
    #define VERTEX_CALL  \
      glVertex3fv(point1); \
      glVertex3fv(point2); \
      glVertex3fv(point3); \
      glVertex3fv(point4);
    #define BEGIN_CALL   glBegin(GL_POINTS);
    #define END_CALL     glEnd();
  #endif
#endif

#ifdef POINT_DRAW
  #define DEFINE_POINTS \
    GLfloat point1[3] = { -0.99, -0.99, -1.0 }; \
    GLfloat point2[3] = {  0.99, -0.99, -1.0 }; \
    GLfloat point3[3] = { -0.99,  0.99, -1.0 }; \
    GLfloat point4[3] = {  0.99,  0.99, -1.0 };
  #define CLEAR  \
    BEGIN_CALL   \
    VERTEX_CALL  \
    END_CALL     \
    CLEAR_CALL
#else
  #define DEFINE_POINTS
  #define CLEAR  \
    CLEAR_CALL
#endif

/* Unroll the clears to the number specified */
#if (UNROLL == 1)
  #define UNROLLED_CLEARS CLEAR
  #define DEFINE_CLEANUP
#elif (UNROLL == 2)
  #define UNROLLED_CLEARS CLEAR CLEAR
  #define DEFINE_CLEANUP int remainingClears = iterations & 1;
#elif (UNROLL == 3)
  #define UNROLLED_CLEARS CLEAR CLEAR CLEAR
  #define DEFINE_CLEANUP int remainingClears = iterations % 3;
#elif (UNROLL == 4)
  #define UNROLLED_CLEARS CLEAR CLEAR CLEAR CLEAR
  #define DEFINE_CLEANUP int remainingClears = iterations & 3;
#elif (UNROLL == 5)
  #define UNROLLED_CLEARS CLEAR CLEAR CLEAR CLEAR CLEAR
  #define DEFINE_CLEANUP int remainingClears = iterations % 5;
#elif (UNROLL == 6)
  #define UNROLLED_CLEARS CLEAR CLEAR CLEAR CLEAR CLEAR CLEAR
  #define DEFINE_CLEANUP int remainingClears = iterations % 6;
#elif (UNROLL == 7)
  #define UNROLLED_CLEARS CLEAR CLEAR CLEAR CLEAR CLEAR CLEAR CLEAR
  #define DEFINE_CLEANUP int remainingClears = iterations % 7;
#elif (UNROLL == 8)
  #define UNROLLED_CLEARS CLEAR CLEAR CLEAR CLEAR CLEAR CLEAR CLEAR CLEAR
  #define DEFINE_CLEANUP int remainingClears = iterations & 7;
#endif

#if (UNROLL > 1)
  #define CLEANUP_LOOP \
    for (i=remainingClears; i>0; i--) { \
      CLEAR \
    }
#else
  #define CLEANUP_LOOP
#endif

void FUNCTION (TestPtr thisTest)
{
    ClearPtr this = (ClearPtr)thisTest;
    int iterations = this->iterations;
    int loops = iterations/UNROLL;
    int mask = this->mask;
    int i;
    DEFINE_POINTS
    DEFINE_CLEANUP
  #ifdef FUNCTION_PTRS
  #ifdef WIN32
    #ifdef POINT_DRAW
      void (APIENTRY *vertex3fv)(const GLfloat*) = glVertex3fv;
      void (APIENTRY *begin)(GLenum) = glBegin;
      void (APIENTRY *end)(void) = glEnd;
    #endif
    void (APIENTRY *clear)(GLbitfield) = glClear;
   #else
    #ifdef POINT_DRAW
      void (*vertex3fv)(const GLfloat*) = glVertex3fv;
      void (*begin)(GLenum) = glBegin;
      void (*end)(void) = glEnd;
    #endif
    void (*clear)(GLbitfield) = glClear;
   #endif
  #endif

    for (i=loops; i>0; i--) {
        UNROLLED_CLEARS
    }
    CLEANUP_LOOP
}

#undef CLEAR_CALL
#undef BEGIN_CALL
#undef END_CALL
#undef VERTEX_CALL
#undef CLEAR
#undef UNROLLED_CLEARS
#undef DEFINE_POINTS
#undef DEFINE_CLEANUP
#undef CLEANUP_LOOP
