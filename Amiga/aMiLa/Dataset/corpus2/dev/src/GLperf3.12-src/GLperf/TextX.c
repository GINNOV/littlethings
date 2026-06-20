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
  #if (COLOR_DIM == 3)
    #define COLOR_CALL   (*color3fv)(srcPtr)
  #else
    #define COLOR_CALL   (*color4fv)(srcPtr)
  #endif
  #define INDEX_CALL   (*indexfv)(srcPtr)
  #ifdef MULTIIMAGE
    #define CALLLISTS_CALL   (*calllists)(charsPerString, type, *imagePtr++);
  #else
    #define CALLLISTS_CALL   (*calllists)(charsPerString, type, image);
  #endif
  #if (RASTERPOS_DIM == 2)
    #define RASTERPOS_CALL   (*rasterPos2fv)(srcPtr);
  #else
    #define RASTERPOS_CALL   (*rasterPos3fv)(srcPtr);
  #endif
#else
  #if (COLOR_DIM == 3)
    #define COLOR_CALL   glColor3fv(srcPtr)
  #else
    #define COLOR_CALL   glColor4fv(srcPtr)
  #endif
  #define INDEX_CALL   glIndexfv(srcPtr)
  #ifdef MULTIIMAGE
    #define CALLLISTS_CALL   glCallLists(charsPerString, type, *imagePtr++);
  #else
    #define CALLLISTS_CALL   glCallLists(charsPerString, type, image);
  #endif
  #if (RASTERPOS_DIM == 2)
    #define RASTERPOS_CALL   glRasterPos2fv(srcPtr);
  #else
    #define RASTERPOS_CALL   glRasterPos3fv(srcPtr);
  #endif
#endif

#if (RASTERPOS_DIM == 2)
  #define NEXT_RASTERPOS srcPtr += 2;
#else
  #define NEXT_RASTERPOS srcPtr += 3;
#endif

#if (VISUAL == RGB)
  #define COLOR_DATA COLOR_CALL; srcPtr += COLOR_DIM;
#else
  #define COLOR_DATA INDEX_CALL; srcPtr += 1;
#endif
#if (COLOR == PER_RASTERPOS)
  #define RASTERPOS_COLOR_DATA COLOR_DATA
#else
  #define RASTERPOS_COLOR_DATA
#endif

void FUNCTION (TestPtr thisTest)
{
    TextPtr this = (TextPtr)thisTest;
    int iterations = this->iterations;
    int numDrawn = this->numDrawn;
    GLuint base = this->base;
    GLenum type = GL_UNSIGNED_BYTE;
    GLsizei charsPerString = this->charsPerString;
    int i,j;
  #ifdef MULTIIMAGE
    int numObjects = this->numObjects;
    int k;
    void **imageData = this->imageData;
    void **imagePtr = imageData;
  #else
    void *image = *(this->imageData);
  #endif
    GLfloat *traversalData = this->traversalData;
    GLfloat *srcPtr = traversalData;
  #ifdef FUNCTION_PTRS
   #ifdef WIN32
    #if (VISUAL == RGB)
     #if (COLOR_DIM == 3)
      void (APIENTRY *color3fv)(const GLfloat*) = glColor3fv;
     #else
      void (APIENTRY *color4fv)(const GLfloat*) = glColor4fv;
     #endif
    #else
     void (APIENTRY *indexfv)(const GLfloat*) = glIndexfv;
    #endif
     void (APIENTRY *calllists)(GLsizei, GLenum, const GLvoid*) = glCallLists;
    #if (RASTERPOS_DIM == 2)
     void (APIENTRY *rasterPos2fv)(const GLfloat*) = glRasterPos2fv;
    #else
     void (APIENTRY *rasterPos3fv)(const GLfloat*) = glRasterPos3fv;
    #endif
   #else
    #if (VISUAL == RGB)
     #if (COLOR_DIM == 3)
      void (*color3fv)(const GLfloat*) = glColor3fv;
     #else
      void (*color4fv)(const GLfloat*) = glColor4fv;
     #endif
    #else
     void (*indexfv)(const GLfloat*) = glIndexfv;
    #endif
     void (*calllists)(GLsizei, GLenum, const GLvoid*) = glCallLists;
    #if (RASTERPOS_DIM == 2)
     void (*rasterPos2fv)(const GLfloat*) = glRasterPos2fv;
    #else
     void (*rasterPos3fv)(const GLfloat*) = glRasterPos3fv;
    #endif
   #endif
  #endif

    glListBase(base);
    for (i = iterations; i > 0; i--) {
	for (j = numDrawn; j > 0; j--) {
	    RASTERPOS_COLOR_DATA
          #ifdef MULTIIMAGE
	    for (k = numObjects; k > 0; k--) {
          #endif
	      RASTERPOS_CALL
	      CALLLISTS_CALL
          #ifdef MULTIIMAGE
	    }
	    imagePtr = imageData;
          #endif
	    NEXT_RASTERPOS
	}
	srcPtr = traversalData;
    }
}

#undef CALLLISTS_CALL
#undef RASTERPOS_CALL
#undef NEXT_RASTERPOS
#undef COLOR_DATA
#undef RASTERPOS_COLOR_DATA
#undef COLOR_CALL
#undef INDEX_CALL
