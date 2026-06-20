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

#ifdef MULTIIMAGE
  #define TEX_OBJ *objPtr++
  #define LIST_NUM listNum++
#else
  #define TEX_OBJ obj
  #define LIST_NUM list
#endif

/* Define calls if using function pointers or not */
#ifdef FUNCTION_PTRS
  #if (TEX_SRC == DISPLAY_LIST)
    #define TEXBIND_CALL   (*calllist)(LIST_NUM);
  #else
    #define TEXBIND_CALL   (*bindtexture)(target, TEX_OBJ);
  #endif
  #if defined(TRI_DRAW)
    #define VERTEX_CALL  \
      (*texcoord4fv)(point); \
      (*vertex3fv)(point+4); \
      (*texcoord4fv)(point+7); \
      (*vertex3fv)(point+11); \
      (*texcoord4fv)(point+14); \
      (*vertex3fv)(point+18);
    #define BEGIN_CALL   (*begin)(GL_TRIANGLE_STRIP);
    #define END_CALL     (*end)();
  #elif defined(POINT_DRAW)
    #define VERTEX_CALL  \
      (*texcoord4fv)(point); \
      (*vertex3fv)(point+4);
    #define BEGIN_CALL   (*begin)(GL_POINTS);
    #define END_CALL     (*end)();
  #endif
#else
  #if (TEX_SRC == DISPLAY_LIST)
    #define TEXBIND_CALL   glCallList(LIST_NUM);
  #else
    #define TEXBIND_CALL   glBindTextureEXT(target, TEX_OBJ);
  #endif
  #if defined(TRI_DRAW)
    #define VERTEX_CALL  \
      glTexCoord4fv(point); \
      glVertex3fv(point+4); \
      glTexCoord4fv(point+7); \
      glVertex3fv(point+11); \
      glTexCoord4fv(point+14); \
      glVertex3fv(point+18);
    #define BEGIN_CALL   glBegin(GL_TRIANGLE_STRIP);
    #define END_CALL     glEnd();
  #elif defined(POINT_DRAW)
    #define VERTEX_CALL  \
      glTexCoord4fv(point); \
      glVertex3fv(point+4);
    #define BEGIN_CALL   glBegin(GL_POINTS);
    #define END_CALL     glEnd();
  #endif
#endif

#if defined(POINT_DRAW) || defined(TRI_DRAW)
  #define DEFINE_TRI GLfloat* point = this->triangleData; 
  #define TEXBIND  { \
    TEXBIND_CALL \
    BEGIN_CALL   \
    VERTEX_CALL  \
    END_CALL \
  }
#else
  #define DEFINE_TRI
  #define TEXBIND  \
    TEXBIND_CALL
#endif

void FUNCTION (TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    int iterations = this->iterations;
    GLenum target = this->texTarget;
    int i;
  #ifdef MULTIIMAGE
    int numObjects = this->numObjects;
    int j;
   #if (TEX_SRC == DISPLAY_LIST)
    GLuint listBase = this->dlBase;
    GLuint listNum = listBase;
   #else
    GLuint *objData = this->texObjs;
    GLuint *objPtr = objData;
   #endif
  #else
   #if (TEX_SRC == DISPLAY_LIST)
    GLuint list = this->dlBase;
   #else
    GLuint obj = *(this->texObjs);
   #endif
  #endif
  #ifdef FUNCTION_PTRS
   #ifdef WIN32
    #define LINK_CONV APIENTRY
   #else
    #define LINK_CONV
   #endif
   #if (TEX_SRC == DISPLAY_LIST)
    void (LINK_CONV *calllist)(GLuint) = glCallList;
   #else
    void (LINK_CONV *bindtexture)(GLenum, GLuint) = glBindTextureEXT;
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
        #ifdef MULTIIMAGE
	  for (j = numObjects; j > 0; j--)
        #endif
	    TEXBIND
        #ifdef MULTIIMAGE
	 #if (TEX_SRC == DISPLAY_LIST)
	  listNum = listBase;
	 #else
	  objPtr = objData;
	 #endif
        #endif
    }
}

#undef TEXBIND_CALL
#undef TEXBIND
#undef TEX_OBJ
#undef LIST_NUM
#undef BEGIN_CALL
#undef END_CALL
#undef VERTEX_CALL
#undef DEFINE_TRI
