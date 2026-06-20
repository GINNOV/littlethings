/*
//   (C) COPYRIGHT International Business Machines Corp. 1993
//   All Rights Reserved
//   Licensed Materials - Property of IBM
//   US Government Users Restricted Rights - Use, duplication or
//   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//

//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose and without fee is hereby granted, provided
// that the above copyright notice appear in all copies and that both that
// copyright notice and this permission notice appear in supporting
// documentation, and that the name of I.B.M. not be used in advertising
// or publicity pertaining to distribution of the software without specific,
// written prior permission. I.B.M. makes no representations about the
// suitability of this software for any purpose.  It is provided "as is"
// without express or implied warranty.
//
// I.B.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL I.B.M.
// BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Author:  John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

/* Define calls if using function pointers or not */
#ifdef FUNCTION_PTRS
  #if (COLOR_DIM == 3)
    #define COLOR_CALL   (*color3fv)(ptr)
  #else
    #define COLOR_CALL   (*color4fv)(ptr)
  #endif
  #define NORMAL_CALL  (*normal3fv)(ptr)
  #if (TEX_DIM == 1)
    #define TEXTURE_CALL (*texCoord1fv)(ptr)
  #elif (TEX_DIM == 2)
    #define TEXTURE_CALL (*texCoord2fv)(ptr)
  #elif (TEX_DIM == 3)
    #define TEXTURE_CALL (*texCoord3fv)(ptr)
  #else
    #define TEXTURE_CALL (*texCoord4fv)(ptr)
  #endif
  #define INDEX_CALL   (*indexfv)(ptr)
  #if (VERTEX_DIM == 2)
    #define VERTEX_CALL  (*vertex2fv)(ptr)
  #else
    #define VERTEX_CALL  (*vertex3fv)(ptr)
  #endif
  #define BEGIN_CALL   (*begin)(primitiveType)
  #define END_CALL     (*end)()
#else
  #if (COLOR_DIM == 3)
    #define COLOR_CALL   glColor3fv(ptr)
  #else
    #define COLOR_CALL   glColor4fv(ptr)
  #endif
  #define NORMAL_CALL  glNormal3fv(ptr)
  #if (TEX_DIM == 1)
    #define TEXTURE_CALL glTexCoord1fv(ptr)
  #elif (TEX_DIM == 2)
    #define TEXTURE_CALL glTexCoord2fv(ptr)
  #elif (TEX_DIM == 3)
    #define TEXTURE_CALL glTexCoord3fv(ptr)
  #else
    #define TEXTURE_CALL glTexCoord4fv(ptr)
  #endif
  #define INDEX_CALL   glIndexfv(ptr)
  #if (VERTEX_DIM == 2)
    #define VERTEX_CALL  glVertex2fv(ptr)
  #else
    #define VERTEX_CALL  glVertex3fv(ptr)
  #endif
  #define BEGIN_CALL   glBegin(primitiveType)
  #define END_CALL     glEnd()
#endif

/* Define data definitions with pointer increments */
#if (VISUAL == RGB)
  #define COLOR_DATA COLOR_CALL; ptr += COLOR_DIM;
#else
  #define COLOR_DATA INDEX_CALL; ptr += 1;
#endif
#define NORMAL_DATA  NORMAL_CALL;  ptr += 3;
#define TEXTURE_DATA TEXTURE_CALL; ptr += TEX_DIM;
#define VERTEX_DATA VERTEX_CALL; ptr += VERTEX_DIM;

/* Specify the type of ColorData */
#if (COLOR == PER_VERTEX)
  #define VERTEX_COLOR_DATA COLOR_DATA
  #define FACET_COLOR_DATA
#elif (COLOR == PER_FACET)
  #define HAS_FACET_DATA
  #define VERTEX_COLOR_DATA
  #define FACET_COLOR_DATA  COLOR_DATA
#else
  #define VERTEX_COLOR_DATA
  #define FACET_COLOR_DATA
#endif
  
/* Specify the type of NormalData */
#if (NORMAL == PER_VERTEX)
  #define VERTEX_NORMAL_DATA NORMAL_DATA
  #define FACET_NORMAL_DATA
#elif (NORMAL == PER_FACET)
  #define HAS_FACET_DATA
  #define VERTEX_NORMAL_DATA
  #define FACET_NORMAL_DATA  NORMAL_DATA
#else
  #define VERTEX_NORMAL_DATA
  #define FACET_NORMAL_DATA
#endif
  
/* Specify the type of TexData */
#if (TEXTURE == PER_VERTEX)
  #define VERTEX_TEXTURE_DATA TEXTURE_DATA
#else
  #define VERTEX_TEXTURE_DATA
#endif

/* This is the data that will be given for each vertex */
#define PER_VERTEX_DATA \
  VERTEX_COLOR_DATA     \
  VERTEX_NORMAL_DATA    \
  VERTEX_TEXTURE_DATA   \
  VERTEX_DATA

/* This is the data that will be given before each facet */
#define PER_FACET_DATA  \
  FACET_COLOR_DATA      \
  FACET_NORMAL_DATA

/* Unroll the facet into multiple vertices (however many are per facet) */
#if (VERTS_PER_FACET == 1)
  #define UNROLLED_FACET PER_VERTEX_DATA
#elif (VERTS_PER_FACET == 2)
  #define UNROLLED_FACET PER_VERTEX_DATA PER_VERTEX_DATA
#elif (VERTS_PER_FACET == 3)
  #define UNROLLED_FACET PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (VERTS_PER_FACET == 4)
  #define UNROLLED_FACET PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (VERTS_PER_FACET == 5)
  #define UNROLLED_FACET PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (VERTS_PER_FACET == 6)
  #define UNROLLED_FACET PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (VERTS_PER_FACET == 7)
  #define UNROLLED_FACET PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (VERTS_PER_FACET == 8)
  #define UNROLLED_FACET PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#endif

/* Unroll the vertices to the number specified */
#if (UNROLL == 1)
  #define UNROLLED_VERTICES PER_VERTEX_DATA
#elif (UNROLL == 2)
  #define UNROLLED_VERTICES PER_VERTEX_DATA PER_VERTEX_DATA
#elif (UNROLL == 3)
  #define UNROLLED_VERTICES PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (UNROLL == 4)
  #define UNROLLED_VERTICES PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (UNROLL == 5)
  #define UNROLLED_VERTICES PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (UNROLL == 6)
  #define UNROLLED_VERTICES PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (UNROLL == 7)
  #define UNROLLED_VERTICES PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#elif (UNROLL == 8)
  #define UNROLLED_VERTICES PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA PER_VERTEX_DATA
#endif

#if (VERTS_PER_FACET == 9)
  /* Special case, this is used if VERTS_PER_FACET is greater than 8 */
  #define UNROLLED_FACET for (i=vertsPerFacet; i>0; i--) { PER_VERTEX_DATA }
  #define DEFINE_VERTS_PER_FACET int vertsPerFacet = this->vertsPerFacet;
  #define VERTS_PER_FACET_OVER_UNROLL vertsPerFacet
#else
  #define DEFINE_VERTS_PER_FACET
  #define VERTS_PER_FACET_OVER_UNROLL (VERTS_PER_FACET/UNROLL)
#endif

#if (UNROLL < VERTS_PER_FACET)
  #define FACETS_PER_LOOP 1
  #ifdef HAS_FACET_DATA
    #define DEFINE_LOOPCOUNT int loopsPerBgnEnd = facetsPerBgnEnd;
  #else
    #define DEFINE_LOOPCOUNT int loopsPerBgnEnd = facetsPerBgnEnd*VERTS_PER_FACET_OVER_UNROLL;
  #endif
  #define FACET \
    PER_FACET_DATA \
    for (l=VERTS_PER_FACET_OVER_UNROLL; l>0; l--) { \
      UNROLLED_VERTICES \
    }
#else
  #define FACETS_PER_LOOP (UNROLL/VERTS_PER_FACET)
  #define DEFINE_LOOPCOUNT int loopsPerBgnEnd = facetsPerBgnEnd/FACETS_PER_LOOP;
  #define FACET \
    PER_FACET_DATA \
    UNROLLED_FACET
#endif

#if (UNROLL > VERTS_PER_FACET)
  #if (FACETS_PER_LOOP == 2)
    #define DEFINE_CLEANUP int remainingFacets = facetsPerBgnEnd & 1;
  #elif (FACETS_PER_LOOP == 3)
    #define DEFINE_CLEANUP int remainingFacets = facetsPerBgnEnd % 3;
  #elif (FACETS_PER_LOOP == 4)
    #define DEFINE_CLEANUP int remainingFacets = facetsPerBgnEnd & 3;
  #elif (FACETS_PER_LOOP == 5)
    #define DEFINE_CLEANUP int remainingFacets = facetsPerBgnEnd % 5;
  #elif (FACETS_PER_LOOP == 6)
    #define DEFINE_CLEANUP int remainingFacets = facetsPerBgnEnd % 6;
  #elif (FACETS_PER_LOOP == 7)
    #define DEFINE_CLEANUP int remainingFacets = facetsPerBgnEnd % 7;
  #elif (FACETS_PER_LOOP == 8)
    #define DEFINE_CLEANUP int remainingFacets = facetsPerBgnEnd & 7;
  #endif
  #define CLEANUP_LOOP \
    for (k=remainingFacets; k>0; k--) { \
      FACET \
    }
#else
  #define DEFINE_CLEANUP
  #define CLEANUP_LOOP
#endif

void FUNCTION (TestPtr thisTest)
{
    VertexPtr this = (VertexPtr)thisTest;
    int i, j, k, l;
    GLfloat* ptr;
    GLfloat* traversalData = this->traversalData;
    int iterations = this->iterations;
    int numBgnEnds = this->numBgnEnds;
    /* May want to compute loopsPerBgnEnd and remainingVerts outside timing loop */
    int facetsPerBgnEnd = this->facetsPerBgnEnd;
    DEFINE_VERTS_PER_FACET
    DEFINE_LOOPCOUNT
    DEFINE_CLEANUP
    int primitiveType = this->primitiveType;
  #ifdef FUNCTION_PTRS
   #ifdef WIN32
    #if (VISUAL == CI)
      void (APIENTRY *indexfv)(const GLfloat*) = glIndexfv;
    #else
      #if (COLOR_DIM == 3)
        void (APIENTRY *color3fv)(const GLfloat*) = glColor3fv;
      #else
        void (APIENTRY *color4fv)(const GLfloat*) = glColor4fv;
      #endif
      #if (TEX_DIM == 1)
        void (APIENTRY *texCoord1fv)(const GLfloat*) = glTexCoord1fv;
      #elif (TEX_DIM == 2)
        void (APIENTRY *texCoord2fv)(const GLfloat*) = glTexCoord2fv;
      #elif (TEX_DIM == 3)
        void (APIENTRY *texCoord3fv)(const GLfloat*) = glTexCoord3fv;
      #else
        void (APIENTRY *texCoord4fv)(const GLfloat*) = glTexCoord4fv;
      #endif
    #endif
    void (APIENTRY *normal3fv)(const GLfloat*) = glNormal3fv;
    #if (VERTEX_DIM == 2)
      void (APIENTRY *vertex2fv)(const GLfloat*) = glVertex2fv;
    #else
      void (APIENTRY *vertex3fv)(const GLfloat*) = glVertex3fv;
    #endif
    void (APIENTRY *begin)(GLenum) = glBegin;
    void (APIENTRY *end)(void) = glEnd;
   #else
    #if (VISUAL == CI)
      void (*indexfv)(const GLfloat*) = glIndexfv;
    #else
      #if (COLOR_DIM == 3)
        void (*color3fv)(const GLfloat*) = glColor3fv;
      #else
        void (*color4fv)(const GLfloat*) = glColor4fv;
      #endif
      #if (TEX_DIM == 1)
        void (*texCoord1fv)(const GLfloat*) = glTexCoord1fv;
      #elif (TEX_DIM == 2)
        void (*texCoord2fv)(const GLfloat*) = glTexCoord2fv;
      #elif (TEX_DIM == 3)
        void (*texCoord3fv)(const GLfloat*) = glTexCoord3fv;
      #else
        void (*texCoord4fv)(const GLfloat*) = glTexCoord4fv;
      #endif
    #endif
    void (*normal3fv)(const GLfloat*) = glNormal3fv;
    #if (VERTEX_DIM == 2)
      void (*vertex2fv)(const GLfloat*) = glVertex2fv;
    #else
      void (*vertex3fv)(const GLfloat*) = glVertex3fv;
    #endif
    void (*begin)(GLenum) = glBegin;
    void (*end)(void) = glEnd;
   #endif
  #endif

    for (i=iterations; i>0; i--) {
      ptr = traversalData;
      for (j=numBgnEnds; j>0; j--) {
        BEGIN_CALL;
        for (k=loopsPerBgnEnd; k>0; k--) {
        #ifdef HAS_FACET_DATA
          #if (FACETS_PER_LOOP >= 1)
            FACET
          #endif
          #if (FACETS_PER_LOOP >= 2)
            FACET
          #endif
          #if (FACETS_PER_LOOP >= 3)
            FACET
          #endif
          #if (FACETS_PER_LOOP >= 4)
            FACET
          #endif
          #if (FACETS_PER_LOOP >= 5)
            FACET
          #endif
          #if (FACETS_PER_LOOP >= 6)
            FACET
          #endif
          #if (FACETS_PER_LOOP >= 7)
            FACET
          #endif
          #if (FACETS_PER_LOOP >= 8)
            FACET
          #endif
	#else
	  UNROLLED_VERTICES
        #endif
	}
	CLEANUP_LOOP
	END_CALL;
      }
    }
}

#undef COLOR_CALL
#undef NORMAL_CALL
#undef TEXTURE_CALL
#undef INDEX_CALL
#undef VERTEX_CALL
#undef BEGIN_CALL
#undef END_CALL
#undef COLOR_DATA
#undef NORMAL_DATA
#undef TEXTURE_DATA
#undef VERTEX_DATA
#undef VERTEX_COLOR_DATA
#undef FACET_COLOR_DATA
#undef VERTEX_NORMAL_DATA
#undef FACET_NORMAL_DATA
#undef VERTEX_TEXTURE_DATA
#undef HAS_FACET_DATA
#undef PER_VERTEX_DATA
#undef PER_FACET_DATA
#undef UNROLLED_FACET
#undef UNROLLED_VERTICES
#undef FACETS_PER_LOOP
#undef FACET
#undef DEFINE_LOOPCOUNT
#undef DEFINE_CLEANUP
#undef CLEANUP_LOOP
#undef DEFINE_VERTS_PER_FACET
#undef VERTS_PER_FACET_OVER_UNROLL
