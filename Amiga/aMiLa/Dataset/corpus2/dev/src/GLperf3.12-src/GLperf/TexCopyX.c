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
  #if (TEX_DIM == 1)
    #ifdef SUBTEXTURE
      #define TEXLOAD_CALL (*copytexsubimage1dext)(target, texLevel, x, srcx, srcy, width);
    #else
      #define TEXLOAD_CALL (*copyteximage1dext)(target, texLevel, comps, srcx, srcy, width, border);
    #endif
  #elif (TEX_DIM == 2)
    #ifdef SUBTEXTURE
      #define TEXLOAD_CALL (*copytexsubimage2dext)(target, texLevel, x, y, srcx, srcy, width, height);
    #else
      #define TEXLOAD_CALL (*copyteximage2dext)(target, texLevel, comps, srcx, srcy, width, height, border);
    #endif
  #elif (TEX_DIM == 3)
    #define TEXLOAD_CALL (*copytexsubimage3dext)(target, texLevel, x, y, z, srcx, srcy, width, height);
  #endif
  #if defined(POINT_DRAW)
    #define VERTEX_CALL  \
      (*texcoord4fv)(point); \
      (*vertex3fv)(point+4);
    #define BEGIN_CALL   (*begin)(GL_POINTS);
    #define END_CALL     (*end)();
  #elif defined(TRI_DRAW)
    #define VERTEX_CALL  \
      (*texcoord4fv)(point); \
      (*vertex3fv)(point+4); \
      (*texcoord4fv)(point+7); \
      (*vertex3fv)(point+11); \
      (*texcoord4fv)(point+14); \
      (*vertex3fv)(point+18);
    #define BEGIN_CALL   (*begin)(GL_TRIANGLE_STRIP);
    #define END_CALL     (*end)();
  #endif
#else
  #if (TEX_DIM == 1)
    #ifdef SUBTEXTURE
      #define TEXLOAD_CALL glCopyTexSubImage1DEXT(target, texLevel, x, srcx, srcy, width);
    #else
      #define TEXLOAD_CALL glCopyTexImage1DEXT(target, texLevel, comps, srcx, srcy, width, border);
    #endif
  #elif (TEX_DIM == 2)
    #ifdef SUBTEXTURE
      #define TEXLOAD_CALL glCopyTexSubImage2DEXT(target, texLevel, x, y, srcx, srcy, width, height);
    #else
      #define TEXLOAD_CALL glCopyTexImage2DEXT(target, texLevel, comps, srcx, srcy, width, height, border);
    #endif
  #elif (TEX_DIM == 3)
    #define TEXLOAD_CALL glCopyTexSubImage3DEXT(target, texLevel, x, y, z, srcx, srcy, width, height);
  #endif
  #if defined(POINT_DRAW)
    #define VERTEX_CALL  \
      glTexCoord4fv(point); \
      glVertex3fv(point+4);
    #define BEGIN_CALL   glBegin(GL_POINTS);
    #define END_CALL     glEnd();
  #elif defined(TRI_DRAW)
    #define VERTEX_CALL  \
      glTexCoord4fv(point); \
      glVertex3fv(point+4); \
      glTexCoord4fv(point+7); \
      glVertex3fv(point+11); \
      glTexCoord4fv(point+14); \
      glVertex3fv(point+18);
    #define BEGIN_CALL   glBegin(GL_TRIANGLE_STRIP);
    #define END_CALL     glEnd();
  #endif
#endif

#if defined(POINT_DRAW) || defined(TRI_DRAW)
  #define DEFINE_TRI GLfloat* point = this->triangleData; 
  #define DRAW_OBJ  \
    BEGIN_CALL   \
    VERTEX_CALL  \
    END_CALL
#else
  #define DEFINE_TRI
  #define DRAW_OBJ
#endif

#ifdef SUBTEXTURE
  #if (TEX_DIM == 1)
    #define SET_SUBTEXTURE x = *subTexPtr++;
  #elif (TEX_DIM == 2)
    #define SET_SUBTEXTURE x = *subTexPtr++; \
                           y = *subTexPtr++;
  #elif (TEX_DIM == 3)
    #define SET_SUBTEXTURE x = *subTexPtr++; \
                           y = *subTexPtr++; \
                           z = *subTexPtr++;
  #endif
#else
  #define SET_SUBTEXTURE
#endif
  
void FUNCTION (TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    int iterations = this->iterations;
    int numDrawn = this->numDrawn;
    GLenum target = this->texTarget;
    GLenum border = this->texBorder;
    GLenum comps = this->texComps;
    GLint* copyTexData = this->copyTexData;
    GLint* copyTexPtr = copyTexData;
    GLint srcx, srcy;
  #ifdef SUBTEXTURE
    GLint* subTexData = this->subTexData;
    GLint* subTexPtr = subTexData;
    int x;
    int width = this->subTexWidth;
   #if (TEX_DIM >= 2)
    int y;
    int height = this->subTexHeight;
   #endif
   #if (TEX_DIM == 3)
    int z;
   #endif
  #else
    int width = this->texImageWidth;
   #if (TEX_DIM >= 2)
    int height = this->texImageHeight;
   #endif
  #endif
    int i, j;
    int texLevel = this->texLevel;
  #ifdef FUNCTION_PTRS
   #ifdef WIN32
    #define LINK_CONV APIENTRY
   #else
    #define LINK_CONV
   #endif
   #if (TEX_DIM == 1)
    #ifdef SUBTEXTURE
     void (LINK_CONV *copytexsubimage1dext)(GLenum, GLint, GLint, GLint, GLint, GLsizei) = glCopyTexSubImage1DEXT;
    #else
     void (LINK_CONV *copyteximage1dext)(GLenum, GLint, GLenum, GLint, GLint, GLsizei, GLint) = glCopyTexImage1DEXT;
    #endif
   #elif (TEX_DIM == 2)
    #ifdef SUBTEXTURE
     void (LINK_CONV *copytexsubimage2dext)(GLenum, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei) = glCopyTexSubImage2DEXT;
    #else
     void (LINK_CONV *copyteximage2dext)(GLenum, GLint, GLenum, GLint, GLint, GLsizei, GLsizei, GLint) = glCopyTexImage2DEXT;
    #endif
   #elif (TEX_DIM == 3)
    void (LINK_CONV *copytexsubimage3dext)(GLenum, GLint, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei) = glCopyTexSubImage3DEXT;
   #endif
   #if defined(POINT_DRAW) || defined(TRI_DRAW)
    void (LINK_CONV *texcoord4fv)(const GLfloat*) = glTexCoord4fv;
    void (LINK_CONV *vertex3fv)(const GLfloat*) = glVertex3fv;
    void (LINK_CONV *begin)(GLenum) = glBegin;
    void (LINK_CONV *end)(void) = glEnd;
   #endif
  #endif
    DEFINE_TRI

    for (i = iterations; i > 0; i--) {
	for (j = numDrawn; j > 0; j--) {
	    SET_SUBTEXTURE
	    srcx = *copyTexPtr++;
	    srcy = *copyTexPtr++;
	    TEXLOAD_CALL
	    DRAW_OBJ
	}
	copyTexPtr = copyTexData;
      #ifdef SUBTEXTURE
        subTexPtr = subTexData;
      #endif
    }
}

#undef TEXLOAD_CALL
#undef BEGIN_CALL
#undef END_CALL
#undef VERTEX_CALL
#undef DEFINE_TRI
#undef DRAW_OBJ
#undef SET_SUBTEXTURE
