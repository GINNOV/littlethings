#ifndef VERTEXARRAY_H
#define VERTEXARRAY_H 1

#include "sysinc.h"


typedef void (*Convfn)(struct GLcontext_t *, struct MGLVertex_t *, const int);

typedef void (*ADrawfn)(struct GLcontext_t *, int, int);
typedef void (*EDrawfn)(struct GLcontext_t *, const int, const UWORD *);

/*
** Note that the following defines are poking directly into
** the W3D_Context, updating only the necessary fields.
** This is ofcourse not future-proof, but it avoids a 
** significant overhead.
** The pipepine itself also relies on fast pointer-switch
*/

#ifndef __VBCC__ //inlines that bypasses the library call

static INLINE void Set_W3D_Texture (W3D_Context *w3dctx, int u, W3D_Texture *tex)
{
	w3dctx->CurrentTex[u] = tex;
}

static INLINE void Set_W3D_ColorPointer (W3D_Context *w3dctx, void *pointer, int stride, ULONG format, ULONG mode, ULONG flags)
{
	w3dctx->ColorPointer = pointer;
	w3dctx->CPStride = stride;
	w3dctx->CPMode = mode | format;
}

static INLINE void Set_W3D_TexCoordPointer (W3D_Context *w3dctx, void *pointer, int stride, int u, int v_off, int w_off, ULONG flags)
{
	w3dctx->TexCoordPointer[u] = pointer;
	w3dctx->TPStride[u] = stride;
	w3dctx->TPWOffs[u] = w_off;
}

static INLINE void Set_W3D_VertexPointer (W3D_Context *w3dctx, void *pointer, int stride, ULONG mode, ULONG flags)
{
	w3dctx->VertexPointer = pointer;
	w3dctx->VPStride = stride;
	w3dctx->VPMode = mode;
}

// following func is called from draw.c after
// multitexturebuffer and triangle-drawing

static INLINE void Reset_W3D_ArrayPointers (GLcontext glctx, GLbitfield cls)
{
	if(cls & GLCS_VERTEX)
	{
	   if(glctx->VertexArrayPipeline == GL_FALSE)
	   {
	     glctx->w3dContext->VertexPointer = (void *)&glctx->ArrayPointer.verts;
	     glctx->w3dContext->VPStride = glctx->ArrayPointer.vertexstride;
	     glctx->w3dContext->VPMode = W3D_VERTEX_F_F_F;
	   }
	   else
	   {
	     glctx->w3dContext->VertexPointer = (void *)&glctx->VertexBuffer[0].bx;
	     glctx->w3dContext->VPStride = (int)sizeof(MGLVertex);
	     glctx->w3dContext->VPMode = W3D_VERTEX_F_F_F;
	   }
	}

	if(cls & GLCS_COLOR)
	{
	glctx->w3dContext->ColorPointer = (void *)glctx->ArrayPointer.colors;
	glctx->w3dContext->CPStride = (int)glctx->ArrayPointer.colorstride;
	glctx->w3dContext->CPMode = (ULONG)glctx->ArrayPointer.colormode;
	}

	if(cls & GLCS_TEXTURE)
	{
	glctx->w3dContext->TexCoordPointer[0] = (void *)glctx->ArrayPointer.texcoords;
	glctx->w3dContext->TPStride[0] = (int)glctx->ArrayPointer.texcoordstride;
	glctx->w3dContext->TPWOffs[0] = (int)glctx->ArrayPointer.w_off;
	}
}

#else

//macros that bypasses the library call:

#define Set_W3D_Texture(w3dctx,u,tex) \
{ \
	w3dctx->CurrentTex[(int)u] = (W3D_Texture *)tex;	\
}

#define Set_W3D_ColorPointer(w3dctx,pointer,stride,format,mode, flags) \
{ \
	w3dctx->ColorPointer = (void *)pointer;		\
	w3dctx->CPStride = (int)stride;			\
	w3dctx->CPMode = ((ULONG)mode | (ULONG)format);	\
}

#define Set_W3D_TexCoordPointer(w3dctx,pointer,stride,u,v_off, w_off,flags) \
{ \
	w3dctx->TexCoordPointer[(int)u] = (void *)pointer;	\
	w3dctx->TPStride[(int)u] = (int)stride;		\
	w3dctx->TPWOffs[(int)u] = (int)w_off;		\
}

#define Set_W3D_VertexPointer(w3dctx,pointer,stride,mode,flags) \
{ \
	w3dctx->VertexPointer = (void *)pointer;	\
	w3dctx->VPStride = (int)stride;			\
	w3dctx->VPMode = (ULONG)mode;			\
}


#define Reset_W3D_ArrayPointers(glctx, cls) \
{ \
if(cls & GLCS_VERTEX) \
{ \
   if(glctx->VertexArrayPipeline == GL_FALSE) \
   { \
     glctx->w3dContext->VertexPointer = (void *)&glctx->ArrayPointer.verts; \
     glctx->w3dContext->VPStride = glctx->ArrayPointer.vertexstride; \
     glctx->w3dContext->VPMode = W3D_VERTEX_F_F_F; \
   } \
   else \
   { \
     glctx->w3dContext->VertexPointer = (void *)&glctx->VertexBuffer[0].bx; \
     glctx->w3dContext->VPStride = (int)sizeof(MGLVertex); \
     glctx->w3dContext->VPMode = W3D_VERTEX_F_F_F; \
   } \
} \
if(cls & GLCS_COLOR) \
{ \
glctx->w3dContext->ColorPointer = (void *)glctx->ArrayPointer.colors; \
glctx->w3dContext->CPStride = (int)glctx->ArrayPointer.colorstride; \
glctx->w3dContext->CPMode = (ULONG)glctx->ArrayPointer.colormode; \
} \
\
if(cls & GLCS_TEXTURE) \
{ \
glctx->w3dContext->TexCoordPointer[0] = (void *)glctx->ArrayPointer.texcoords; \
glctx->w3dContext->TPStride[0] = (int)glctx->ArrayPointer.texcoordstride; \
glctx->w3dContext->TPWOffs[0] = (int)glctx->ArrayPointer.w_off; \
} \
}

#endif

#endif
