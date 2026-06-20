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
  #ifdef MULTIIMAGE
    #define READPIX_CALL   (*readPixels)(x, y, width, height, format, type, *imagePtr++);
  #else
    #define READPIX_CALL   (*readPixels)(x, y, width, height, format, type, image);
  #endif
  #define PIXELSTORE_CALL  (*pixelStore)
#else
  #ifdef MULTIIMAGE
    #define READPIX_CALL   glReadPixels(x, y, width, height, format, type, *imagePtr++);
  #else
    #define READPIX_CALL   glReadPixels(x, y, width, height, format, type, image);
  #endif
  #define PIXELSTORE_CALL  glPixelStorei
#endif

void FUNCTION (TestPtr thisTest)
{
    ReadPixelsPtr this = (ReadPixelsPtr)thisTest;
    int iterations = this->iterations;
    int numDrawn = this->numDrawn;
    int width = this->readPixelsWidth;
    int height = this->readPixelsHeight;
    int x, y;
  #ifdef SUBIMAGE
    GLint imageWidth = this->image_ReadPixels.imageWidth;
  #endif
    int format = this->image_ReadPixels.imageFormat;
    int type = this->image_ReadPixels.imageType;
    int i,j;
  #ifdef MULTIIMAGE
    int numObjects = this->numObjects;
    int k;
    void **imageData = this->imageData;
    void **imagePtr = imageData;
  #else
    void *image = *(this->imageData);
  #endif
  #ifdef SUBIMAGE
    GLint *subImageData = this->subImageData;
    GLint *subPtr = subImageData;
  #endif
    GLint *srcData = this->srcData;
    GLint *posPtr = srcData;
  #ifdef FUNCTION_PTRS
   #ifdef WIN32
    void (APIENTRY *readPixels)(GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, GLvoid*) = glReadPixels;
    void (APIENTRY *pixelStore)(GLenum, GLint) = glPixelStorei;
   #else
    void (*readPixels)(GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, GLvoid*) = glReadPixels;
    void (*pixelStore)(GLenum, GLint) = glPixelStorei;
   #endif
  #endif

  #ifdef SUBIMAGE
    PIXELSTORE_CALL(GL_UNPACK_ROW_LENGTH, imageWidth);
  #endif
    for (i = iterations; i > 0; i--) {
	for (j = numDrawn; j > 0; j--) {
	  #ifdef SUBIMAGE
	    PIXELSTORE_CALL(GL_UNPACK_SKIP_PIXELS, *subPtr++);
	    PIXELSTORE_CALL(GL_UNPACK_SKIP_ROWS, *subPtr++);
	  #endif        
	    x = *posPtr++;
	    y = *posPtr++;
          #ifdef MULTIIMAGE
	    for (k = numObjects; k > 0; k--)
          #endif
		READPIX_CALL
          #ifdef MULTIIMAGE
	    imagePtr = imageData;
          #endif
	}
	posPtr = srcData;
      #ifdef SUBIMAGE
	subPtr = subImageData;
      #endif
    }
}

#undef READPIX_CALL
#undef PIXELSTORE_CALL
