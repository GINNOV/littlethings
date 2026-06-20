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
#ifdef FUNCTION_PTRS

  #define VERTEX_PTR_CALL (*vertexPtrCall)(vertexDim, type, stride, tmpVertexPtr);
  #define NORMAL_PTR_CALL (*normalPtrCall)(type, stride, tmpNormalPtr);
  #define COLOR_PTR_CALL (*colorPtrCall)(colorDim, type, stride, tmpColorPtr);
  #define INDEX_PTR_CALL (*indexPtrCall)(type, stride, tmpIndexPtr);
  #define TEX_PTR_CALL (*texPtrCall)(texDim, type, stride, tmpTexPtr);
  #define INTERLEAVED_PTR_CALL (*interleavedPtrCall)(INTERLEAVED_FORMAT, stride, tmpInterleavedPtr);
  #ifdef DRAW_ELEMENTS
    #define DRAW_ARRAYS_CALL (*drawElementsCall)(mode, vertsPerBgnEnd, GL_UNSIGNED_INT, tmpElementsPtr);
  #else
    #define DRAW_ARRAYS_CALL (*drawArrayCall)(mode, first, vertsPerBgnEnd);
  #endif
  #ifdef LOCK_ARRAYS
    #define LOCK_ARRAYS_CALL (*lockArrays)(0, vertsPerBgnEnd*numBgnEnds);
    #define UNLOCK_ARRAYS_CALL (*unlockArrays)();
  #else
    #define LOCK_ARRAYS_CALL
    #define UNLOCK_ARRAYS_CALL
  #endif

#else

  #define VERTEX_PTR_CALL glVertexPointer(vertexDim, type, stride, tmpVertexPtr);
  #define NORMAL_PTR_CALL glNormalPointer(type, stride, tmpNormalPtr);
  #define COLOR_PTR_CALL glColorPointer(colorDim, type, stride, tmpColorPtr);
  #define INDEX_PTR_CALL glIndexPointer(type, stride, tmpIndexPtr);
  #define TEX_PTR_CALL glTexCoordPointer(texDim, type, stride, tmpTexPtr);
  #define INTERLEAVED_PTR_CALL glInterleavedArrays(INTERLEAVED_FORMAT, stride, tmpInterleavedPtr);
  #ifdef DRAW_ELEMENTS
    #define DRAW_ARRAYS_CALL glDrawElements(mode, vertsPerBgnEnd, GL_UNSIGNED_INT, tmpElementsPtr);
  #else
    #define DRAW_ARRAYS_CALL glDrawArrays(mode, first, vertsPerBgnEnd);
  #endif
  #ifdef LOCK_ARRAYS
    #define LOCK_ARRAYS_CALL glLockArraysSGI(0, vertsPerBgnEnd*numBgnEnds);
    #define UNLOCK_ARRAYS_CALL glUnlockArraysSGI();
  #else
    #define LOCK_ARRAYS_CALL
    #define UNLOCK_ARRAYS_CALL
  #endif

#endif

#ifdef INTERLEAVED_DATA
  #define VERTEX_PTR
  #define SET_VERTEX_PTR
  #define INCR_VERTEX_PTR
#else
  #define VERTEX_PTR VERTEX_PTR_CALL
  #define SET_VERTEX_PTR tmpVertexPtr = vertexPtr;
  #define INCR_VERTEX_PTR tmpVertexPtr += bgnendSize;
#endif

#define DRAW_ARRAYS DRAW_ARRAYS_CALL

#ifdef NORMAL_DATA
  #define NORMAL_PTR NORMAL_PTR_CALL
  #define SET_NORMAL_PTR tmpNormalPtr = normalPtr;
  #define INCR_NORMAL_PTR tmpNormalPtr += bgnendSize;
#else
  #define NORMAL_PTR
  #define SET_NORMAL_PTR
  #define INCR_NORMAL_PTR
#endif

#ifdef COLOR_DATA
  #define COLOR_PTR COLOR_PTR_CALL
  #define SET_COLOR_PTR tmpColorPtr = colorPtr;
  #define INCR_COLOR_PTR tmpColorPtr += bgnendSize;
#else
  #define COLOR_PTR
  #define SET_COLOR_PTR
  #define INCR_COLOR_PTR
#endif

#ifdef INDEX_DATA
  #define INDEX_PTR INDEX_PTR_CALL
  #define SET_INDEX_PTR tmpIndexPtr = indexPtr;
  #define INCR_INDEX_PTR tmpIndexPtr += bgnendSize;
#else
  #define INDEX_PTR
  #define SET_INDEX_PTR
  #define INCR_INDEX_PTR
#endif

#ifdef TEX_DATA
  #define TEX_PTR TEX_PTR_CALL
  #define SET_TEX_PTR tmpTexPtr = texPtr;
  #define INCR_TEX_PTR tmpTexPtr += bgnendSize;
#else
  #define TEX_PTR
  #define SET_TEX_PTR
  #define INCR_TEX_PTR
#endif

#ifdef INTERLEAVED_DATA
  #define INTERLEAVED_PTR INTERLEAVED_PTR_CALL
  #define SET_INTERLEAVED_PTR tmpInterleavedPtr = interleavedPtr;
  #define INCR_INTERLEAVED_PTR tmpInterleavedPtr += bgnendSize;
#else
  #define INTERLEAVED_PTR
  #define SET_INTERLEAVED_PTR
  #define INCR_INTERLEAVED_PTR
#endif

#ifdef DRAW_ELEMENTS
  #define INIT_ELEMENTS_PTR 						\
    {									\
	int numElements = numBgnEnds*vertsPerBgnEnd;			\
	elementsPtr = (GLuint *)malloc(numElements*sizeof(GLuint));	\
	for (i=0; i<numElements; i++) {					\
	    elementsPtr[i] = i;						\
	}								\
    }
  #define SET_ELEMENTS_PTR  tmpElementsPtr = elementsPtr;
  #define INCR_ELEMENTS_PTR tmpElementsPtr += vertsPerBgnEnd;
  #define FREE_ELEMENTS_PTR free(elementsPtr);
#else
  #define INIT_ELEMENTS_PTR
  #define SET_ELEMENTS_PTR
  #define INCR_ELEMENTS_PTR
  #define FREE_ELEMENTS_PTR
#endif

#define CALL_PTRS VERTEX_PTR \
		  NORMAL_PTR \
		  COLOR_PTR \
		  INDEX_PTR \
		  TEX_PTR \
		  INTERLEAVED_PTR

#define SET_PTRS SET_NORMAL_PTR \
		 SET_COLOR_PTR \
		 SET_INDEX_PTR \
		 SET_TEX_PTR \
		 SET_VERTEX_PTR \
		 SET_INTERLEAVED_PTR

#define INCR_PTRS INCR_NORMAL_PTR \
		  INCR_COLOR_PTR \
		  INCR_INDEX_PTR \
		  INCR_TEX_PTR \
		  INCR_VERTEX_PTR \
		  INCR_INTERLEAVED_PTR \
		  INCR_ELEMENTS_PTR

void FUNCTION (TestPtr thisTest)
{
    VertexPtr this = (VertexPtr)thisTest;
    int i, j;
    int iterations = this->iterations;
    int numBgnEnds = this->numBgnEnds;
    GLenum type = GL_FLOAT;
    GLsizei vertsPerBgnEnd = this->vertsPerBgnEnd;
    GLint first = 0;
    GLint vertexDim = this->vertexDim;
    GLsizei stride = this->vertexStride; 
    GLsizei bgnendSize = this->bgnendSize; 
    GLenum mode = this->primitiveType;

#ifndef INTERLEAVED_DATA
    char* vertexPtr = this->vertexPtr; 
    char* tmpVertexPtr;
#endif
#ifdef NORMAL_DATA
    char* normalPtr = this->normalPtr;
    char* tmpNormalPtr;
#endif
#ifdef COLOR_DATA
    GLint colorDim = this->colorDim;
    char* colorPtr = this->colorPtr;
    char* tmpColorPtr;
#endif
#ifdef INDEX_DATA
    char* indexPtr = this->indexPtr;
    char* tmpIndexPtr;
#endif
#ifdef TEX_DATA
    GLint texDim = this->texDim;
    char* texPtr = this->texPtr;
    char* tmpTexPtr;
#endif
#ifdef INTERLEAVED_DATA
    char* interleavedPtr = this->colorPtr;
    char* tmpInterleavedPtr;
#endif
#ifdef DRAW_ELEMENTS
    GLuint* elementsPtr;
    GLuint* tmpElementsPtr;
#endif

#ifdef FUNCTION_PTRS
  #ifdef WIN32
      void (APIENTRY *vertexPtrCall)(GLint, GLenum, GLsizei, const void*) = glVertexPointer;
    #ifdef NORMAL_DATA
      void (APIENTRY *normalPtrCall)(GLenum, GLsizei, const void*) = glNormalPointer;
    #endif
    #ifdef COLOR_DATA
      void (APIENTRY *colorPtrCall)(GLint, GLenum, GLsizei, const void*) = glColorPointer;
    #endif
    #ifdef INDEX_DATA
      void (APIENTRY *indexPtrCall)(GLenum, GLsizei, const void*) = glIndexPointer;
    #endif
    #ifdef TEX_DATA
      void (APIENTRY *texPtrCall)(GLint, GLenum, GLsizei, const void*) = glTexCoordPointer;
    #endif
    #ifdef INTERLEAVED_DATA
      void (APIENTRY *interleavedPtrCall)(GLenum, GLsizei, const GLvoid *) = glInterleavedArrays;
    #endif
    #ifdef DRAW_ELEMENTS
      void (APIENTRY *drawElementsCall)(GLenum, GLsizei, GLenum, const GLvoid *) = glDrawElements;
    #else
      void (APIENTRY *drawArrayCall)(GLenum, GLint, GLsizei) = glDrawArrays;
    #endif
    #ifdef LOCK_ARRAYS
      void (APIENTRY *lockArrays)(GLint, GLsizei) = glLockArraysSGI;
      void (APIENTRY *unlockArrays)(void) = glUnlockArraysSGI;
    #endif
  #else
      void (*vertexPtrCall)(GLint, GLenum, GLsizei, const void*) = glVertexPointer;
    #ifdef NORMAL_DATA
      void (*normalPtrCall)(GLenum, GLsizei, const void*) = glNormalPointer;
    #endif
    #ifdef COLOR_DATA
      void (*colorPtrCall)(GLint, GLenum, GLsizei, const void*) = glColorPointer;
    #endif
    #ifdef INDEX_DATA
      void (*indexPtrCall)(GLenum, GLsizei, const void*) = glIndexPointer;
    #endif
    #ifdef TEX_DATA
      void (*texPtrCall)(GLint, GLenum, GLsizei, const void*) = glTexCoordPointer;
    #endif
    #ifdef INTERLEAVED_DATA
      void (*interleavedPtrCall)(GLenum, GLsizei, const GLvoid *) = glInterleavedArrays;
    #endif
    #ifdef DRAW_ELEMENTS
      void (*drawElementsCall)(GLenum, GLsizei, GLenum, const GLvoid *) = glDrawElements;
    #else
      void (*drawArrayCall)(GLenum, GLint, GLsizei) = glDrawArrays;
    #endif
    #ifdef LOCK_ARRAYS
      void (*lockArrays)(GLint, GLsizei) = glLockArraysSGI;
      void (*unlockArrays)(void) = glUnlockArraysSGI;
    #endif
  #endif
#endif

#ifdef DRAW_ELEMENTS
    SET_PTRS
    CALL_PTRS
    INIT_ELEMENTS_PTR
    for (i = iterations; i > 0; i--) {
        SET_ELEMENTS_PTR
	LOCK_ARRAYS_CALL
	for (j = numBgnEnds; j > 0; j--) {
	    DRAW_ARRAYS
	    INCR_ELEMENTS_PTR
	}
	UNLOCK_ARRAYS_CALL
    }
    FREE_ELEMENTS_PTR
#else
    for (i = iterations; i > 0; i--) {
	SET_PTRS
	LOCK_ARRAYS_CALL
	for (j = numBgnEnds; j > 0; j--) {
	    CALL_PTRS
	    DRAW_ARRAYS
	    INCR_PTRS
	}
	UNLOCK_ARRAYS_CALL
    }
#endif
}

#undef VERTEX_PTR_CALL
#undef NORMAL_PTR_CALL
#undef COLOR_PTR_CALL
#undef INDEX_PTR_CALL
#undef TEX_PTR_CALL
#undef DRAW_ARRAYS_CALL
#undef VERTEX_PTR
#undef DRAW_ARRAYS
#undef NORMAL_PTR
#undef COLOR_PTR
#undef INDEX_PTR
#undef TEX_PTR
#undef SET_PTRS
#undef INCR_PTRS
#undef SET_NORMAL_PTR
#undef SET_COLOR_PTR
#undef SET_INDEX_PTR
#undef SET_TEX_PTR
#undef SET_VERTEX_PTR
#undef INCR_NORMAL_PTR
#undef INCR_COLOR_PTR
#undef INCR_INDEX_PTR
#undef INCR_TEX_PTR
#undef INCR_VERTEX_PTR
#undef INTERLEAVED_PTR_CALL
#undef LOCK_ARRAYS_CALL
#undef UNLOCK_ARRAYS_CALL
#undef INTERLEAVED_PTR
#undef SET_INTERLEAVED_PTR
#undef INCR_INTERLEAVED_PTR
#undef INIT_ELEMENTS_PTR
#undef SET_ELEMENTS_PTR
#undef INCR_ELEMENTS_PTR
#undef FREE_ELEMENTS_PTR
