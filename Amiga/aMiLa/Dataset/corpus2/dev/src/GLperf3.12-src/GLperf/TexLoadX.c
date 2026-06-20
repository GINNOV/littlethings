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
  #ifdef GEN_MIPMAP
    #if (TEX_DIM == 1)
      #define TEXLOAD_CALL(Level, Image) (*build1dmipmaps)(target, comps, width, format, type, Image);
    #elif (TEX_DIM == 2)
      #define TEXLOAD_CALL(Level, Image) (*build2dmipmaps)(target, comps, width, height, format, type, Image);
    #endif
  #else
    #if (TEX_DIM == 1)
      #ifdef SUBTEXTURE
        #define TEXLOAD_CALL(Level, Image) (*texsubimage1dext)(target, Level, x, width, format, type, Image);
      #else
        #define TEXLOAD_CALL(Level, Image) (*teximage1d)(target, Level, comps, width, border, format, type, Image);
      #endif
    #elif (TEX_DIM == 2)
      #ifdef SUBTEXTURE
        #define TEXLOAD_CALL(Level, Image) (*texsubimage2dext)(target, Level, x, y, width, height, format, type, Image);
      #else
        #define TEXLOAD_CALL(Level, Image) (*teximage2d)(target, Level, comps, width, height, border, format, type, Image);
      #endif
    #elif (TEX_DIM == 3)
      #ifdef SUBTEXTURE
        #define TEXLOAD_CALL(Level, Image) (*texsubimage3dext)(target, Level, x, y, z, width, height, depth, format, type, Image);
      #else
        #define TEXLOAD_CALL(Level, Image) (*teximage3dext)(target, Level, comps, width, height, depth, border, format, type, Image);
      #endif
    #elif (TEX_DIM == 4)
      #define TEXLOAD_CALL(Level, Image) (*teximage4dsgis)(target, Level, comps, width, height, depth, extent, border, format, type, Image);
    #endif
  #endif
  #define PIXELSTORE_CALL  (*pixelStore)
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
  #ifdef GEN_MIPMAP
    #if (TEX_DIM == 1)
      #define TEXLOAD_CALL(Level, Image) gluBuild1DMipmaps(target, comps, width, format, type, Image);
    #elif (TEX_DIM == 2)
      #define TEXLOAD_CALL(Level, Image) gluBuild2DMipmaps(target, comps, width, height, format, type, Image);
    #endif
  #else
    #if (TEX_DIM == 1)
      #ifdef SUBTEXTURE
        #define TEXLOAD_CALL(Level, Image) glTexSubImage1DEXT(target, Level, x, width, format, type, Image);
      #else
        #define TEXLOAD_CALL(Level, Image) glTexImage1D(target, Level, comps, width, border, format, type, Image);
      #endif
    #elif (TEX_DIM == 2)
      #ifdef SUBTEXTURE
        #define TEXLOAD_CALL(Level, Image) glTexSubImage2DEXT(target, Level, x, y, width, height, format, type, Image);
      #else
        #define TEXLOAD_CALL(Level, Image) glTexImage2D(target, Level, comps, width, height, border, format, type, Image);
      #endif
    #elif (TEX_DIM == 3)
      #ifdef SUBTEXTURE
        #define TEXLOAD_CALL(Level, Image) glTexSubImage3DEXT(target, Level, x, y, z, width, height, depth, format, type, Image);
      #else
        #define TEXLOAD_CALL(Level, Image) glTexImage3DEXT(target, Level, comps, width, height, depth, border, format, type, Image);
      #endif
    #elif (TEX_DIM == 4)
      #define TEXLOAD_CALL(Level, Image) glTexImage4DSGIS(target, Level, comps, width, height, depth, extent, border, format, type, Image);
    #endif
  #endif
  #define PIXELSTORE_CALL  glPixelStorei
  #ifdef TRI_DRAW
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
  #define DRAW_OBJ  \
    BEGIN_CALL   \
    VERTEX_CALL  \
    END_CALL
#else
  #define DEFINE_TRI
  #define DRAW_OBJ
#endif

#ifdef SUBIMAGE
  #if (TEX_DIM == 1)
    #define SET_SUBIMAGE PIXELSTORE_CALL(GL_UNPACK_SKIP_PIXELS, *subImagePtr++);
  #elif (TEX_DIM == 2)
    #define SET_SUBIMAGE PIXELSTORE_CALL(GL_UNPACK_SKIP_PIXELS, *subImagePtr++); \
                         PIXELSTORE_CALL(GL_UNPACK_SKIP_ROWS, *subImagePtr++);
  #elif (TEX_DIM == 3)
    #define SET_SUBIMAGE PIXELSTORE_CALL(GL_UNPACK_SKIP_PIXELS, *subImagePtr++); \
                         PIXELSTORE_CALL(GL_UNPACK_SKIP_ROWS, *subImagePtr++); \
                         PIXELSTORE_CALL(GL_UNPACK_SKIP_IMAGES_EXT, *subImagePtr++);
  #elif (TEX_DIM == 4)
    #define SET_SUBIMAGE PIXELSTORE_CALL(GL_UNPACK_SKIP_PIXELS, *subImagePtr++); \
                         PIXELSTORE_CALL(GL_UNPACK_SKIP_ROWS, *subImagePtr++); \
                         PIXELSTORE_CALL(GL_UNPACK_SKIP_IMAGES_EXT, *subImagePtr++); \
                         PIXELSTORE_CALL(GL_UNPACK_SKIP_VOLUMES_SGIS, *subImagePtr++);
  #endif
#else
  #define SET_SUBIMAGE
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
  
#ifdef MULTILEVEL
  #if (TEX_DIM == 1)
    #define SET_DIMS	width = *mipmapDimPtr++;
  #elif (TEX_DIM == 2)
    #define SET_DIMS	width = *mipmapDimPtr++; \
			height = *mipmapDimPtr++;
  #elif (TEX_DIM == 3)
    #define SET_DIMS	width = *mipmapDimPtr++; \
			height = *mipmapDimPtr++; \
			depth = *mipmapDimPtr++;
  #elif (TEX_DIM == 4)
    #define SET_DIMS	width = *mipmapDimPtr++; \
			height = *mipmapDimPtr++; \
			depth = *mipmapDimPtr++; \
			extent = *mipmapDimPtr++;
  #endif
  #ifdef MULTIIMAGE
    #define TEXLOAD { \
      imagePtr = *mipmapPtr++; \
      for (l = 0; l < mipmapLevels; l++) { \
          SET_DIMS \
          TEXLOAD_CALL(l, *imagePtr++) \
      } \
      DRAW_OBJ \
      mipmapDimPtr = mipmapDimData; \
    }
  #else
    #define TEXLOAD { \
      imagePtr = mipmap; \
      for (l = 0; l < mipmapLevels; l++) { \
          SET_DIMS \
          TEXLOAD_CALL(l, *imagePtr++) \
      } \
      DRAW_OBJ \
      mipmapDimPtr = mipmapDimData; \
    }
  #endif
#else
  #ifdef MULTIIMAGE
    #define TEXLOAD { \
      TEXLOAD_CALL(texLevel, *imagePtr++) \
      DRAW_OBJ \
    }
  #else
    #define TEXLOAD { \
      TEXLOAD_CALL(texLevel, image) \
      DRAW_OBJ \
    }
  #endif
#endif
  
void FUNCTION (TestPtr thisTest)
{
    TexImagePtr this = (TexImagePtr)thisTest;
    int iterations = this->iterations;
    int numDrawn = this->numDrawn;
    GLenum target = this->texTarget;
    GLenum type = this->image_TexImage.imageType;
    GLenum format = this->image_TexImage.imageFormat;
    GLenum border = this->texBorder;
    GLenum comps = this->texComps;
  #ifdef SUBIMAGE
    GLint* subImageData = this->subImageData;
    GLint* subImagePtr = subImageData;
  #endif
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
    int depth = this->subTexDepth;
   #endif
  #else
    int width = this->texImageWidth;
   #if (TEX_DIM >= 2)
    int height = this->texImageHeight;
   #endif
   #if (TEX_DIM >= 3)
    int depth = this->texImageDepth;
   #endif
   #if (TEX_DIM == 4)
    int extent = this->texImageExtent;
   #endif
  #endif
    int i,j;
  #ifdef MULTILEVEL
    GLint* mipmapDimData = this->mipmapDimData;
    GLint* mipmapDimPtr = mipmapDimData;
    int mipmapLevels = this->mipmapLevels;
    int l;
  #else
    int texLevel = this->texLevel;
  #endif
  #ifdef MULTIIMAGE
    int numObjects = this->numObjects;
    int k;
   #ifdef MULTILEVEL
    void*** mipmapData = this->mipmapData;
    void*** mipmapPtr = mipmapData;
    void** imagePtr;
   #else
    void** imageData = this->imageData;
    void** imagePtr = imageData;
   #endif
  #else
   #ifdef MULTILEVEL
    void** mipmap = *(this->mipmapData);
    void** imagePtr;
   #else
    void *image = *(this->imageData);
   #endif
  #endif
  #ifdef FUNCTION_PTRS
   #ifdef WIN32
    #define LINK_CONV APIENTRY
   #else
    #define LINK_CONV
   #endif
   #ifdef SUBIMAGE
    void (LINK_CONV *pixelStore)(GLenum, GLint) = glPixelStorei;
   #endif
   #ifdef GEN_MIPMAP
    #if (TEX_DIM == 1)
     int (LINK_CONV *build1dmipmaps)(GLenum, GLint, GLint, GLenum, GLenum, const void*) = gluBuild1DMipmaps;
    #elif (TEX_DIM == 2)
     int (LINK_CONV *build2dmipmaps)(GLenum, GLint, GLint, GLint, GLenum, GLenum, const void*) = gluBuild2DMipmaps;
    #endif
   #else
    #if (TEX_DIM == 1)
     #ifdef SUBTEXTURE
      void (LINK_CONV *texsubimage1dext)(GLenum, GLint, GLint, GLsizei, GLenum, GLenum, const void*) = glTexSubImage1DEXT;
     #else
      void (LINK_CONV *teximage1d)(GLenum, GLint, GLint, GLsizei, GLint, GLenum, GLenum, const void*) = glTexImage1D;
     #endif
    #elif (TEX_DIM == 2)
     #ifdef SUBTEXTURE
      void (LINK_CONV *texsubimage2dext)(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, const void*) = glTexSubImage2DEXT;
     #else
      void (LINK_CONV *teximage2d)(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const void*) = glTexImage2D;
     #endif
    #elif (TEX_DIM == 3)
     #ifdef SUBTEXTURE
      void (LINK_CONV *texsubimage3dext)(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLenum, const void*) = glTexSubImage3DEXT;
     #else
      void (LINK_CONV *teximage3dext)(GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, const void*) = glTexImage3DEXT;
     #endif
    #elif (TEX_DIM == 4)
     void (LINK_CONV *teximage4dsgis)(GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, const void*) = glTexImage4DSGIS;
    #endif
   #endif
   #if defined(POINT_DRAW) || defined(TRI_DRAW)
    void (LINK_CONV *texcoord4fv)(const GLfloat*) = glTexCoord4fv;
    void (LINK_CONV *vertex3fv)(const GLfloat*) = glVertex3fv;
    void (LINK_CONV *begin)(GLenum) = glBegin;
    void (LINK_CONV *end)(void) = glEnd;
   #endif
   #undef LINK_CONV
  #endif
    DEFINE_TRI

  #ifdef SUBIMAGE
   #if (TEX_DIM >= 2)
    PIXELSTORE_CALL(GL_UNPACK_ROW_LENGTH, this->image_TexImage.imageWidth);
   #endif
   #if (TEX_DIM >= 3)
    PIXELSTORE_CALL(GL_UNPACK_IMAGE_HEIGHT_EXT, this->image_TexImage.imageHeight);
   #endif
   #if (TEX_DIM == 4)
    PIXELSTORE_CALL(GL_UNPACK_IMAGE_DEPTH_SGIS, this->imageDepth);
   #endif
  #endif

    for (i = iterations; i > 0; i--) {
	for (j = numDrawn; j > 0; j--) {
	  SET_SUBIMAGE
	  SET_SUBTEXTURE
          #ifdef MULTIIMAGE
	    for (k = numObjects; k > 0; k--)
          #endif
		TEXLOAD
          #ifdef MULTIIMAGE
           #ifdef MULTILEVEL
            mipmapPtr = mipmapData;
           #else
            imagePtr = imageData;
           #endif
          #endif
	}
      #ifdef SUBIMAGE
        subImagePtr = subImageData;
      #endif
      #ifdef SUBTEXTURE
        subTexPtr = subTexData;
      #endif
    }
}

#undef TEXLOAD_CALL
#undef TEXLOAD
#undef BEGIN_CALL
#undef END_CALL
#undef VERTEX_CALL
#undef DEFINE_TRI
#undef DRAW_OBJ
#undef SET_SUBIMAGE
#undef SET_SUBTEXTURE
#undef PIXELSTORE_CALL
#undef SET_DIMS
