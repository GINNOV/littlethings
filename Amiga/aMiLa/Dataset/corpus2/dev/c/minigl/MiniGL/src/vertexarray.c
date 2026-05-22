/*
 * $Id: vertexarray.c,v 1.3 2001/02/05 16:56:03 tfrieden Exp $
 *
 * $Date: 2001/02/05 16:56:03 $
 * $Revision: 1.3 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

/*
** glDrawArrays pipeline by Christian 'SuRgEoN' Michael
** Thanks to Olivier Fabre for bug-hunting
*/

/*
** revised 07-04-02:
**
** In some cases A_DrawTriangles didn't use the correct
** start position during backface-culling
**
** Support for GL_EXT_compiled_vertex_array was added.
**
** When AP_COMPILED is set, it will wrap
** to GLDrawElements (at the very beginning of GLDrawArrays,
** which is ofcourse not an optimal solution.
** Anyways, the use if glDrawArrays is probably rare in case
** of compiled arrays, but it should be supported.
** One possible solution to this is to make the default
** W3D_VertexPointer point to the W3D_Vertex struct inside
** the vertexbuffer like for elements, but it would probably
** lower the general performance of glDrawArrays.
*/


#include "sysinc.h"
#include "vertexarray.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


//Clipping (convert color and texcoords to vertexbuffer)

static void Convert_F_RGB(GLcontext context, MGLVertex *v, const int i);
static void Convert_F_RGBA(GLcontext context, MGLVertex *v, const int i);
static void Convert_UB_RGB(GLcontext context, MGLVertex *v, const int i);
static void Convert_UB_RGBA(GLcontext context, MGLVertex *v, const int i);
static void Convert_UB_BGR(GLcontext context, MGLVertex *v, const int i);
static void Convert_UB_BGRA(GLcontext context, MGLVertex *v, const int i);
static void Convert_UB_ARGB(GLcontext context, MGLVertex *v, const int i);

//pointer to color/texcoord conversion routine for clipping events:

Convfn Convert = (Convfn)Convert_UB_RGBA;


/*

NOTE:
        Transformation and clipping pipeline can be turned on/off with glDisable/glEnable(MGL_ARRAY_TRANSFORMATIONS) before the pointers are set.

The MGL_FLATFAN will work regardless of pipeline state.

Tricky stuff:

Problem 1: We don't want to copy texcoords unless we really have to (clipping) and we don't want to write the w-coords to application-arrays since a texcoordpointer is allowed to have a stride of 2.

        Current solution:
        We allocate some memory exclusively for the w-coords
        in order to cope with any texcoordstride.
        The relative w-coord buffer offset is calculated
        whenever texcoordpointer is set.

Problem 2: Clipping events are expensive because texcoords and colors currently need to be converted and copied to the vertexbuffer.

        Solution: ?? Currently, a sort of guardband is used
                     in order to avoid clipping in most cases.


TODO:

- Implement remaining GL primitives.
- Implement multitexturing (virtual TMU for now).

*/


//NYI:

static void A_DrawQuads         (GLcontext context, int first, int count);
static void A_DrawQuadStrip     (GLcontext context, int first, int count);

//implemented:
static void A_DrawTriFan        (GLcontext context, int first, int count);
static void A_DrawTriStrip      (GLcontext context, int first, int count);
static void A_DrawTriangles     (GLcontext context, int first, int count);
static void A_DrawFlatFan       (GLcontext context, int first, int count);


extern void TMA_Start(LockTimeHandle *handle);
extern GLboolean TMA_Check(LockTimeHandle *handle);

extern void fog_Set(GLcontext context);

static INLINE void PreDraw(GLcontext context);
static INLINE void PostDraw(GLcontext context);

static GLuint Reset_W3D_VertexPointer = GL_TRUE;

static ULONG A_TransformArray (GLcontext context, const int first, const int size);

#ifdef __PPC__
static INLINE
#else
static
#endif
void A_ToScreenArray(GLcontext context, MGLVertex *v, const int first, const int size);

extern void m_CombineMatrices(GLcontext context);

extern int AE_ClipTriangle(GLcontext context, PolyBuffer *in, PolyBuffer *out, int *clipstart, ULONG or_codes);


#define MAX_ELEMENTS 16384 //should be enough
static UWORD e_wrap[MAX_ELEMENTS]; //should be enough 

//called from MGLInit:

static GLboolean e_wrapped = GL_FALSE;

void Init_ArrayToElements_Warpper(void)
{
        int i;

        if(e_wrapped == GL_FALSE)
        {
                for (i=0; i<MAX_ELEMENTS; i++)
                {
                        e_wrap[i] = (UWORD)i;
                }

                e_wrapped = GL_TRUE;
        }
}

extern void GLDrawElements(GLcontext context, GLenum mode, const GLsizei count, GLenum type, const GLvoid *indices);



static ULONG A_TransformArray (GLcontext context, const int first, const int size)
{
   int i;
   ULONG and_code, or_code;

   #define OF_11 0
   #define OF_12 4
   #define OF_13 8
   #define OF_14 12

   #define OF_21 1
   #define OF_22 5
   #define OF_23 9
   #define OF_24 13

   #define OF_31 2
   #define OF_32 6
   #define OF_33 10
   #define OF_34 14

   #define OF_41 3
   #define OF_42 7
   #define OF_43 11
   #define OF_44 15

   if(context->ArrayPointer.state & AP_FIXPOINT)
   {
        static int m[16];
        UBYTE *vpointer;
        MGLVertex *v;
        int stride;

        #define CLIP_EPS ((int)((1e-7)*32768.f))
        #define a(x) (context->CombinedMatrix.v[OF_##x])
        #define b(x) (m[OF_##x])

        if(context->CombinedValid == GL_FALSE)
        {
        const float float2fix = 32768.f;

                m_CombineMatrices(context);

                b(11)=(int)(a(11)*float2fix);
                b(12)=(int)(a(12)*float2fix);
                b(13)=(int)(a(13)*float2fix);
                b(14)=(int)(a(14)*float2fix);
                b(21)=(int)(a(21)*float2fix);
                b(22)=(int)(a(22)*float2fix);
                b(23)=(int)(a(23)*float2fix);
                b(24)=(int)(a(24)*float2fix);
                b(31)=(int)(a(31)*float2fix);
                b(32)=(int)(a(32)*float2fix);
                b(33)=(int)(a(33)*float2fix);
                b(34)=(int)(a(34)*float2fix);
                b(41)=(int)(a(41)*float2fix);
                b(42)=(int)(a(42)*float2fix);
                b(43)=(int)(a(43)*float2fix);
                b(44)=(int)(a(44)*float2fix);
        }

     stride = context->ArrayPointer.vertexstride;
     vpointer = (context->ArrayPointer.verts + first*stride);

     and_code = 0xff;
     or_code = 0;

     v = &context->VertexBuffer[0];

     i = size;
     do
     {
        ULONG local_outcode;
        int tx,ty,tz,tw;
        int *vp = (int *)vpointer;
        int x = vp[0];
        int y = vp[1];
        int z = vp[2];

//pipelined transformations

        tx  = x*b(11);
        ty  = x*b(21);
        tz  = x*b(31);
        tw  = x*b(41);

        tx += y*b(12);
        ty += y*b(22);
        tz += y*b(32);
        tw += y*b(42);

        tx += z*b(13);
        ty += z*b(23);
        tz += z*b(33);
        tw += z*b(43);

        tx += b(14);
        ty += b(24);
        tz += b(34);
        tw += b(44);

        local_outcode = 0;

        if (tw < CLIP_EPS )
        {
                local_outcode |= MGL_CLIP_NEGW;
        }
        if (-tw > tx)
        {
                local_outcode |= MGL_CLIP_LEFT;
        }
        else if (tx > tw)
        {
                local_outcode |= MGL_CLIP_RIGHT;
        }

        if (-tw > ty)
        {
                local_outcode |= MGL_CLIP_BOTTOM;
        }
        else if (ty > tw)
        {
                local_outcode |= MGL_CLIP_TOP;
        }
        
        if (-tw > tz)
        {
                local_outcode |= MGL_CLIP_BACK;
        }
        else if (tz > tw)
        {
                local_outcode |= MGL_CLIP_FRONT;
        }

        v->bx = (float)tx;      
        v->by = (float)ty;
        v->bz = (float)tz;      
        v->bw = (float)tw;      

     v->outcode = local_outcode;
     and_code &= local_outcode;
     or_code  |= local_outcode;

     v++; vpointer += stride;

     } while (--i);

   #undef a
   #undef b
   #undef CLIP_EPS 
   }
   else
   {
     float a11,a12,a13,a14;
     float a21,a22,a23,a24;
     float a31,a32,a33,a34;
     float a41,a42,a43,a44;
     UBYTE *vpointer;
     MGLVertex *v;
     int stride;

     #define CLIP_EPS (1e-7)
     #define a(x) (context->CombinedMatrix.v[OF_##x])

     if(context->CombinedValid == GL_FALSE)
                m_CombineMatrices(context);

     a11=a(11); a12=a(12); a13=a(13); a14=a(14);
     a21=a(21); a22=a(22); a23=a(23); a24=a(24);
     a31=a(31); a32=a(32); a33=a(33); a34=a(34);
     a41=a(41); a42=a(42); a43=a(43); a44=a(44);

     stride = context->ArrayPointer.vertexstride;
     vpointer = (context->ArrayPointer.verts + first*stride);

     and_code = 0xff;
     or_code = 0;
     v = &(context->VertexBuffer[0]);

     i = size;

     do
     {
        ULONG local_outcode;
        float cw;
        float *vp = (float *)vpointer;
        float x = vp[0];
        float y = vp[1];
        float z = vp[2];

        v->bx = a11*x + a12*y + a13*z + a14;
        v->by = a21*x + a22*y + a23*z + a24;
        v->bz = a31*x + a32*y + a33*z + a34;
        v->bw = a41*x + a42*y + a43*z + a44;

        cw = v->bw;
        local_outcode = 0;

        if (cw < CLIP_EPS )
        {
                local_outcode |= MGL_CLIP_NEGW;
        }
        if (-cw > v->bx)
        {
                local_outcode |= MGL_CLIP_LEFT;
        }
        else if (v->bx > cw)
        {
                local_outcode |= MGL_CLIP_RIGHT;
        }

        if (-cw > v->by)
        {
                local_outcode |= MGL_CLIP_BOTTOM;
        }
        else if (v->by > cw)
        {
                local_outcode |= MGL_CLIP_TOP;
        }
        
        if (-cw > v->bz)
        {
                local_outcode |= MGL_CLIP_BACK;
        }
        else if (v->bz > cw)
        {
                local_outcode |= MGL_CLIP_FRONT;
        }

        and_code &= local_outcode;
        or_code  |= local_outcode;
        v->outcode = local_outcode;

     v++; vpointer += stride;
     } while (--i);

   #undef CLIP_EPS 
   #undef a
   }

   if(and_code)
      return 0xFFFFFFFF;
   else
      return or_code;
}





#ifdef __PPC__
static INLINE
#else
static
#endif
 void A_ToScreenArray(GLcontext context, MGLVertex *v, const int first, const int size)
{
   int i, stride;
   UBYTE *pointer;   

   if(context->ArrayPointer.state & AP_FIXPOINT)
   {
      stride = context->ArrayPointer.texcoordstride;
      pointer = context->ArrayPointer.w_buffer + first * stride;
      i = size;

      do
      {
           float *wa;
           float x = v->bx;
           float y = v->by;
           float z = v->bz;
           float w = 1.0 / v->bw;
        
           v->bx = context->ax + x * w * context->sx;
           v->by = context->ay - y * w * context->sy;
           v->bz = context->az + z * w * context->sz;

           w *= 32768.f;
           wa = (float*)pointer;
           *wa = w;

      v++;
      pointer += stride;

      } while (--i);    
   }
   else
   {
      stride = context->ArrayPointer.texcoordstride;
      pointer = context->ArrayPointer.w_buffer + first * stride;

      i = size;
      do
      {
           float *wa;
           float x = v->bx;
           float y = v->by;
           float z = v->bz;
           float w = 1.0 / v->bw;
        
           v->bx = context->ax + x * w * context->sx;
           v->by = context->ay - y * w * context->sy;
           v->bz = context->az + z * w * context->sz;

           wa = (float*)pointer;
           *wa = w;

      v++;
      pointer += stride;
      } while (--i);
   }
}

//fix to float conversion

static INLINE void ConvertFixverts(MGLVertex *v, const int size)
{
        const float f = 1.f/32768.f;
        int i = size-2;

        v->bx *= f;
        v->by *= f;
        v->bz *= f;
        v->bw *= f;

        v++;

        v->bx *= f;
        v->by *= f;
        v->bz *= f;
        v->bw *= f;

        v++;

        do
        {
                v->bx *= f;
                v->by *= f;
                v->bz *= f;
                v->bw *= f;
        v++;
        } while (--i);
}


// special case color-copy / texcoord-conversion routines

static void Convert_F_RGB(GLcontext context, MGLVertex *v, const int i)
{
   if(context->ClientState & GLCS_TEXTURE)
   {
   float *tex = (float*)(context->ArrayPointer.texcoords + i * context->ArrayPointer.texcoordstride);

      v->v.u = tex[0] * (float)context->w3dTexBuffer[context->CurrentBinding]->texwidth;
      v->v.v = tex[1] * (float)context->w3dTexBuffer[context->CurrentBinding]->texheight;
   }

   if(context->ShadeModel == GL_SMOOTH)
   {
   float *col = (float*)(context->ArrayPointer.colors + i * context->ArrayPointer.colorstride);;

      v->v.color.r = col[0];
      v->v.color.g = col[1];
      v->v.color.b = col[2];
      v->v.color.a = 1.0;
   }
}


static void Convert_F_RGBA(GLcontext context, MGLVertex *v, const int i)
{
   if(context->ClientState & GLCS_TEXTURE)
   {
   float *tex = (float*)(context->ArrayPointer.texcoords + i * context->ArrayPointer.texcoordstride);

      v->v.u = tex[0] * (float)context->w3dTexBuffer[context->CurrentBinding]->texwidth;
      v->v.v = tex[1] * (float)context->w3dTexBuffer[context->CurrentBinding]->texheight;
   }

   if(context->ShadeModel == GL_SMOOTH)
   {
   float *col = (float*)(context->ArrayPointer.colors + i * context->ArrayPointer.colorstride);;

      v->v.color.r = col[0];
      v->v.color.g = col[1];
      v->v.color.b = col[2];
      v->v.color.a = col[3];
   }
}


static void Convert_UB_RGB(GLcontext context, MGLVertex *v, const int i)
{
   if(context->ClientState & GLCS_TEXTURE)
   {
   float *tex = (float*)(context->ArrayPointer.texcoords + i * context->ArrayPointer.texcoordstride);

      v->v.u = tex[0] * (float)context->w3dTexBuffer[context->CurrentBinding]->texwidth;
      v->v.v = tex[1] * (float)context->w3dTexBuffer[context->CurrentBinding]->texheight;
   }

   if(context->ShadeModel == GL_SMOOTH)
   {
   UBYTE *col = (context->ArrayPointer.colors + i * context->ArrayPointer.colorstride);
   float f = 1.0/255.0;

      v->v.color.r = (float)col[0]*f;
      v->v.color.g = (float)col[1]*f;
      v->v.color.b = (float)col[2]*f;
      v->v.color.a = 1.0;
   }
}


static void Convert_UB_RGBA(GLcontext context, MGLVertex *v, const int i)
{
   if(context->ClientState & GLCS_TEXTURE)
   {
   float *tex = (float*)(context->ArrayPointer.texcoords + i * context->ArrayPointer.texcoordstride);

      v->v.u = tex[0] * (float)context->w3dTexBuffer[context->CurrentBinding]->texwidth;
      v->v.v = tex[1] * (float)context->w3dTexBuffer[context->CurrentBinding]->texheight;
   }

   if(context->ShadeModel == GL_SMOOTH)
   {
   UBYTE *col = (context->ArrayPointer.colors + i * context->ArrayPointer.colorstride);
   float f = 1.0/255.0;

      v->v.color.r = (float)col[0]*f;
      v->v.color.g = (float)col[1]*f;
      v->v.color.b = (float)col[2]*f;
      v->v.color.a = (float)col[3]*f;
   }
}


static void Convert_UB_BGR(GLcontext context, MGLVertex *v, const int i)
{
   if(context->ClientState & GLCS_TEXTURE)
   {
   float *tex = (float*)(context->ArrayPointer.texcoords + i * context->ArrayPointer.texcoordstride);

      v->v.u = tex[0] * (float)context->w3dTexBuffer[context->CurrentBinding]->texwidth;
      v->v.v = tex[1] * (float)context->w3dTexBuffer[context->CurrentBinding]->texheight;
   }

   if(context->ShadeModel == GL_SMOOTH)
   {
   UBYTE *col = (context->ArrayPointer.colors + i * context->ArrayPointer.colorstride);
   float f = 1.0/255.0;

      v->v.color.b = (float)col[0]*f;
      v->v.color.g = (float)col[1]*f;
      v->v.color.r = (float)col[2]*f;
      v->v.color.a = 1.0;
   }
}

static void Convert_UB_BGRA(GLcontext context, MGLVertex *v, const int i)
{
   if(context->ClientState & GLCS_TEXTURE)
   {
   float *tex = (float*)(context->ArrayPointer.texcoords + i * context->ArrayPointer.texcoordstride);

      v->v.u = tex[0] * (float)context->w3dTexBuffer[context->CurrentBinding]->texwidth;
      v->v.v = tex[1] * (float)context->w3dTexBuffer[context->CurrentBinding]->texheight;
   }

   if(context->ShadeModel == GL_SMOOTH)
   {
   UBYTE *col = (context->ArrayPointer.colors + i * context->ArrayPointer.colorstride);
   float f = 1.0/255.0;

      v->v.color.b = (float)col[0]*f;
      v->v.color.g = (float)col[1]*f;
      v->v.color.r = (float)col[2]*f;
      v->v.color.a = (float)col[3]*f;
   }
}

static void Convert_UB_ARGB(GLcontext context, MGLVertex *v, const int i)
{
   if(context->ClientState & GLCS_TEXTURE)
   {
   float *tex = (float*)(context->ArrayPointer.texcoords + i * context->ArrayPointer.texcoordstride);

      v->v.u = tex[0] * (float)context->w3dTexBuffer[context->CurrentBinding]->texwidth;
      v->v.v = tex[1] * (float)context->w3dTexBuffer[context->CurrentBinding]->texheight;
   }

   if(context->ShadeModel == GL_SMOOTH)
   {
   UBYTE *col = (context->ArrayPointer.colors + i * context->ArrayPointer.colorstride);
   float f = 1.0/255.0;

      v->v.color.a = (float)col[0]*f;
      v->v.color.r = (float)col[1]*f;
      v->v.color.g = (float)col[2]*f;
      v->v.color.b = (float)col[3]*f;
   }
}

#ifdef __VBCC__

#define A_ToScreen(ctx,vtx,vnum){\
float wdiv = 1.f / (vtx)->bw;\
(vtx)->bx = ctx->ax + (vtx)->bx * wdiv * ctx->sx;\
(vtx)->by = ctx->ay - (vtx)->by * wdiv * ctx->sy;\
(vtx)->bz = ctx->az + (vtx)->bz * wdiv * ctx->sz;\
*((float*)(ctx->ArrayPointer.w_buffer + (vnum) * ctx->ArrayPointer.texcoordstride)) = wdiv;}

#define AV_ToScreen(ctx,vtx,vnum){\
float wdiv = 1.f / (vtx)->bw;\
(vtx)->v.x = (vtx)->bx = ctx->ax + (vtx)->bx * wdiv * ctx->sx;\
(vtx)->v.y = (vtx)->by = ctx->ay - (vtx)->by * wdiv * ctx->sy;\
(vtx)->bz  =           ctx->az + (vtx)->bz * wdiv * ctx->sz;\
(vtx)->v.z = (W3D_Double)((vtx)->bz);\
(vtx)->v.w = wdiv;\
*((float*)(ctx->ArrayPointer.w_buffer + (vnum) * ctx->ArrayPointer.texcoordstride)) = wdiv;}

#define V_ToScreen(ctx,vtx){\
float wdiv = 1.f/(vtx)->bw;\
(vtx)->v.x = ctx->ax + (vtx)->bx * wdiv * ctx->sx;\
(vtx)->v.y = ctx->ay - (vtx)->by * wdiv * ctx->sy;\
(vtx)->v.z = ctx->az + (vtx)->bz * wdiv * ctx->sz;\
(vtx)->v.w = wdiv;}

#else

static INLINE void A_ToScreen(GLcontext context, MGLVertex *v, int vnum)
{
        float *wa;
        float w = 1.0/v->bw;

        v->bx = context->ax + v->bx * w * context->sx;
        v->by = context->ay - v->by * w * context->sy;
        v->bz = context->az + v->bz * w * context->sz;

        wa = (float*)(context->ArrayPointer.w_buffer + vnum * context->ArrayPointer.texcoordstride);
        *wa = w;
}

static INLINE void AV_ToScreen(GLcontext context, MGLVertex *v, int vnum)
{
        float *wa;
        float w;
        w = 1.0/v->bw;

        v->v.x = v->bx = context->ax + v->bx * w * context->sx;
        v->v.y = v->by = context->ay - v->by * w * context->sy;
        v->bz          = context->az + v->bz * w * context->sz;
        v->v.z = (W3D_Double)(v->bz);

        v->v.w = w;

        wa = (float*)(context->ArrayPointer.w_buffer + vnum * context->ArrayPointer.texcoordstride);
        *wa = w;
}

static INLINE void V_ToScreen(GLcontext context, MGLVertex *v)
{
        float w;
        w = 1.f / v->bw;

        v->v.x = context->ax + v->bx * w * context->sx;
        v->v.y = context->ay - v->by * w * context->sy;
        v->v.z = context->az + v->bz * w * context->sz;
        v->v.w = w;
}
#endif




static PolyBuffer clipbuffer[MGL_MAXVERTS>>2];

#define CBUF clipbuffer
#define PBUF polys


static void A_DrawQuads(GLcontext context, int first, int count)
{
        int i;
        int end;

        //quick hack

        end = first + count;

        for(i=first; i<end; i+=4)
        {
            MGLVertex *offset = context->VertexBuffer-i;
            context->w3dContext->VertexPointer = (void*)&offset->bx;

           context->VertexBufferPointer = 4;

           A_DrawTriFan(context, i, i+4);
        }
}


static void A_DrawQuadStrip(GLcontext context, int first, int count)
{
        int i;
        int end;

        //quick hack

        end = (first + count) - 2;

        for(i=first; i<end; i+=2)
        {
            MGLVertex *offset = context->VertexBuffer-i;
            context->w3dContext->VertexPointer = (void*)&offset->bx;

            context->VertexBufferPointer = 4;

            A_DrawTriStrip(context, i, i+4);
        }
}


static void A_DrawTriFan(GLcontext context, int first, int count)
{
      int i;
      ULONG outcode, local_or, local_and;
      ULONG error;
      static ULONG complete[MGL_MAXVERTS];
      static ULONG visible[MGL_MAXVERTS];
      static PolyIndex polys[256];
      int triangle;
      int pnum, cnum, prevcopy, free;
      int newfirst, size, backface;

      outcode = A_TransformArray(context, first, count);

      if (outcode == 0xFFFFFFFF)
      {
        return;
      }
      else if(outcode != 0 && !(outcode & context->ClipFlags))
      {
        float gw;
        ULONG original_outcode;
        MGLVertex *v;

        original_outcode = outcode;
        outcode = 0;

        v = &context->VertexBuffer[0];

        i = count;
        do
        {
          if(v->outcode)
          {
                gw = v->bw * 2.0;

                if (-gw > v->bx || v->bx > gw || -gw > v->by || v->by > gw)
                {
                        outcode = original_outcode;
                        break;
                }
          }

        v++;
        } while (--i);
      }

      if (outcode == 0)
      {
                A_ToScreenArray(context, &(context->VertexBuffer[0]), first, count);

                if(context->CullFace_State == GL_FALSE)
                {
                        error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIFAN, first, count);
                }
                else
                {
                   float fsign;
                   float area,area2;
                   float x1,x2;
                   float y1,y2;
                   float x0,y0;

                   #define x(a) (context->VertexBuffer[a].bx)
                   #define y(a) (context->VertexBuffer[a].by)

                   fsign = (float)-context->CurrentCullSign;
                   size = count;

                   if(size == 3)
                   {
                        newfirst = first;

                        x0 = x(0);
                        y0 = y(0);
                        x1 = x(1) - x0;
                        y1 = y(1) - y0;
                        x2 = x(2) - x0;
                        y2 = y(2) - y0;

                        area = y2*x1 - x2*y1;
                        area *= fsign;
                   }
                   else
                   {
                        newfirst = 0;
                        backface = 0;

                        x0 = x(0);
                        y0 = y(0);
                        x1 = x(1) - x0;
                        y1 = y(1) - y0;
                        x2 = x(2) - x0;
                        y2 = y(2) - y0;

                        area = y2*x1 - x2*y1;
                        area *= fsign;

                        if(area < 0.f)
                        {
                                newfirst++;
                                area = 0.f;
                        }
        
                        i = 1;
                        do
                        {
                                x1 = x2;
                                y1 = y2;
                                x2 = x(i+2) - x0;
                                y2 = y(i+2) - y0;

                                area2 = y2*x1 - x2*y1;
                                area2 *= fsign;
        
                                if(area2 < 0.f)
                                {
                                    if(newfirst == i)
                                        newfirst++;
                                    else
                                        backface++;
                                }
                                else
                                {
                                    backface = 0;
                                    area += area2;
                                }

                        i++;
                        } while (i < size-2);

                        size -= backface + newfirst; //shrink
                        newfirst += first;
                   }

                   if(area >= context->MinTriArea)
                   {
                        if( newfirst > first)
                        {
                                e_wrap[newfirst] = first;

                                error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, size, (void*)&(e_wrap[newfirst]));

                                e_wrap[newfirst] = newfirst;
                        }
                        else
                        {
                                error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIFAN, newfirst, size);
                        }
                   }

                   #undef x
                   #undef y
                }

        return;
        }

        backface = 0;

        if(context->CullFace_State == GL_FALSE)
        {
          for(i=1,triangle=0; i<context->VertexBufferPointer-1; i++,triangle++)
          {
                local_and =
                        context->VertexBuffer[0].outcode
                        & context->VertexBuffer[i].outcode
                        & context->VertexBuffer[i+1].outcode;

                local_or =
                        context->VertexBuffer[0].outcode
                        | context->VertexBuffer[i].outcode
                        | context->VertexBuffer[i+1].outcode;

                if (local_and == 0) // if the local and code is zero, we're not
                {
                        complete[triangle] = local_or;
                        visible[triangle] = GL_TRUE;
                        backface = 0;
                }
                else
                {
                        visible[triangle] = GL_FALSE;    
                        backface++;
                }
          }
        }
        else
        {
          for(i=1,triangle=0; i<context->VertexBufferPointer-1; i++,triangle++)
          {
              local_and =
                        context->VertexBuffer[0].outcode
                        & context->VertexBuffer[i].outcode
                        & context->VertexBuffer[i+1].outcode;

              local_or =
                        context->VertexBuffer[0].outcode
                        | context->VertexBuffer[i].outcode
                        | context->VertexBuffer[i+1].outcode;

                if (local_and == 0)
                {
                     complete[triangle] = local_or;

                   if(local_or & MGL_CLIP_NEGW)
                   {
                        visible[triangle] = GL_TRUE;
                        backface = 0;
                   }
                   else
                   {
                        visible[triangle] = hc_DecideFrontface(context, &(context->VertexBuffer[0]), &(context->VertexBuffer[i]), &(context->VertexBuffer[i+1]));

                        if(visible[triangle] == GL_FALSE)
                                backface++;
                        else
                                backface = 0;
                   }
                }
                else
                {
                        visible[triangle] = GL_FALSE;    
                        backface++;
                }
          }
        }


        if(backface == count-2) //early out
        return;

        visible[count-2] = GL_FALSE; //reduce control variable checking in next loop

        context->VertexBufferPointer -= backface;

        if(context->ArrayPointer.state & AP_FIXPOINT)
        {
                ConvertFixverts(&(context->VertexBuffer[0]), context->VertexBufferPointer);
        }

        Convert(context, &context->VertexBuffer[0], first);

        prevcopy = 0;
        free = context->VertexBufferPointer;
        pnum = 0; cnum = 0; triangle = 0;

        while(visible[triangle] == GL_FALSE) triangle++;

        newfirst = triangle+1;
        i = newfirst;

        do
        {
                if(visible[triangle] == GL_FALSE)
                {
                        triangle++; i++;
                }
                else
                {
                        if (complete[triangle]) // case 1
                        {
                           static PolyBuffer clip;
                           clip.verts[0] = 0;
                           clip.verts[1] = i;
                           clip.verts[2] = i+1;

                           if(prevcopy != i)
                           Convert(context, &context->VertexBuffer[i], first+i);

                           Convert(context, &context->VertexBuffer[i+1], first+i+1);
                           prevcopy = i+1;

                           cnum += AE_ClipTriangle(context, &clip, &CBUF[cnum], &free, complete[triangle]);

                           triangle++; i++;
                        }
                        else
                        {   // case 2 (the difficult part)
                           int k=3;
                           PBUF[pnum].first = i+first;
                           triangle++; i++;

                           while (complete[triangle]==0 && visible[triangle])
                           {
                                triangle++; i++; k++;
                           }

                           PBUF[pnum].numverts = k;
                           pnum++;
                        }
              }
        } while (i < context->VertexBufferPointer-1);


//Project to screen and draw:

   if(pnum && cnum)
   {
        AV_ToScreen(context, &context->VertexBuffer[0], first);

        for(i=newfirst; i<context->VertexBufferPointer; i++)
        {
           if(context->VertexBuffer[i].outcode == 0)
           {
                AV_ToScreen(context, &context->VertexBuffer[i], first+i);
           }
        }

        for(i=context->VertexBufferPointer; i<free; i++)
        {
           if(context->VertexBuffer[i].outcode == 0)
           {
                V_ToScreen(context, &context->VertexBuffer[i]);
           }
        }

   }
   else if(pnum)
   {
        A_ToScreen(context, &context->VertexBuffer[0], first);

        for(i=newfirst; i<context->VertexBufferPointer; i++)
        {
                if(context->VertexBuffer[i].outcode == 0)
                {
                        A_ToScreen(context, &context->VertexBuffer[i], first+i);
                }
        }
   }
   else
   {

        if(context->VertexBuffer[0].outcode == 0)
        V_ToScreen(context, &context->VertexBuffer[0]);

        for(i=newfirst; i<free; i++)
        {
                if(context->VertexBuffer[i].outcode == 0)
                {
                        V_ToScreen(context, &context->VertexBuffer[i]);
                }
        }

   }

   if(pnum)
   {
        int vzero;

        pnum--;
        vzero  = PBUF[pnum].first-1;

        if(vzero == first)
        {
                error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIFAN, first, PBUF[pnum].numverts);
        }
        else
        {
                e_wrap[vzero] = first;

                error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, PBUF[pnum].numverts, (void*)&(e_wrap[vzero]));

                e_wrap[vzero] = vzero;
        }

        while (--pnum >= 0)
        {

                vzero  = PBUF[pnum].first-1;
                e_wrap[vzero] = first;

                error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, PBUF[pnum].numverts, (void*)&(e_wrap[vzero]));

                e_wrap[vzero] = vzero;

        }
   }

   if(cnum)
   {
        int j;
        static W3D_Vertex *verts[16];
        static W3D_TrianglesV fan;

        fan.st_pattern = NULL;
        fan.v = verts;
        fan.tex = context->w3dTexBuffer[context->CurrentBinding];

        for(i=0; i<cnum; i++)
        {
            PolyBuffer *p = &CBUF[i];

            for (j=0; j<p->numverts; j++)
            {
                verts[j] = &(context->VertexBuffer[p->verts[j]].v);
            }

          fan.vertexcount = p->numverts;

          error = W3D_DrawTriFanV(context->w3dContext, &fan);
        }
   }
}


static void A_DrawTriStrip(GLcontext context, int first, int count)
{
      int i;
      ULONG outcode, local_or, local_and;
      ULONG error;
      int backface, size, newfirst;
      static ULONG visible[MGL_MAXVERTS];
      static ULONG complete[MGL_MAXVERTS];
      static PolyIndex polys[256];
      int pnum, cnum, free, prevcopy;


      outcode = A_TransformArray(context, first, count);

      if (outcode == 0xFFFFFFFF)
      {
        return;
      }
      else if(outcode != 0 && !(outcode & context->ClipFlags))
      {
        float gw;
          ULONG original_outcode;
        MGLVertex *v;

        original_outcode = outcode;
          outcode = 0;

        v = &context->VertexBuffer[0];

        i = count;
        do
        {
          if(v->outcode)
          {
                gw = v->bw * 2.0;

                if (-gw > v->bx || v->bx > gw || -gw > v->by || v->by > gw)
                {
                        outcode = original_outcode;
                          break;
                }
          }

        v++;
        } while (--i);
      }

        if (outcode == 0)
        {
                A_ToScreenArray(context, &(context->VertexBuffer[0]), first, count);

                if(context->CullFace_State == GL_FALSE)
                {
                        error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, first, count);
                }
                else
                {
                   float fsign;
                   float area;
                   float x1,x2;
                   float y1,y2;
                   float a1,a2,b1,b2;
                   float area2;

                   #define x(a) (context->VertexBuffer[a].bx)
                   #define y(a) (context->VertexBuffer[a].by)

                   fsign = (float)-context->CurrentCullSign;
                   size = count;

                   if(size == 3)
                   {
                        newfirst = first;

                        x1 = x(1) - x(0);
                        y1 = y(1) - y(0);
                        x2 = x(2) - x(0);
                        y2 = y(2) - y(0);

                        area = y2*x1 - x2*y1;
                        area *= fsign;
                   }
                   else
                   {
                        newfirst = 0;
                        backface = 0;

                        a1 = x(1);
                        b1 = y(1);
                        a2 = x(2);
                        b2 = y(2);

                        x1 = a1 - x(0);
                        y1 = b1 - y(0);
                        x2 = a2 - x(0);
                        y2 = b2 - y(0);

                        area = y2*x1 - x2*y1;
                        area *= fsign;

                        if(area < 0.f)
                        {
                                newfirst++;
                                area = 0.f;
                        }
        
                        i = 1;
                        do
                        {
                          fsign = -fsign;

                          x1 = a2 - a1;
                          y1 = b2 - b1;
                          x2 = x(i+2) - a1;
                          y2 = y(i+2) - b1;
                          a1 = a2;
                          b1 = b2;
                          a2 = x(i+2);
                          b2 = y(i+2);

                          area2 = y2*x1 - x2*y1;
                          area2 *= fsign;
        
                          if(area2 < 0.f)
                          {
                                if(newfirst == i)
                                    newfirst++;
                                else
                                    backface++;
                          }
                          else
                          {
                                backface = 0;
                                area += area2;
                          }

                        i++;
                        } while (i < size-2);

                        size -= backface + newfirst;
                        newfirst += first;
                   }

                   if(area >= context->MinTriArea)
                   {
                        error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, newfirst, size);
                   }

                #undef x
                #undef y
                }

        return;
        }


        backface = 0;

        if(context->CullFace_State == GL_FALSE)
        {
           for(i=0; i<context->VertexBufferPointer-2; i++)
           {
              local_or =
              context->VertexBuffer[i].outcode |
              context->VertexBuffer[i+1].outcode |
              context->VertexBuffer[i+2].outcode;

              local_and =
              context->VertexBuffer[i].outcode &
              context->VertexBuffer[i+1].outcode &
              context->VertexBuffer[i+2].outcode;

              if (local_and == 0)
              {
                        complete[i] = local_or;
                        visible[i] = GL_TRUE;
                        backface = 0;
              }
              else
              {
                        visible[i] = GL_FALSE;
                        backface++;
              }
           }
        }
        else
        {
           GLint CurrentCullSign = context->CurrentCullSign;

           for(i=0; i<context->VertexBufferPointer-2; i++)
           {
                local_or =
                context->VertexBuffer[i].outcode |
                context->VertexBuffer[i+1].outcode |
                context->VertexBuffer[i+2].outcode;

                local_and =
                context->VertexBuffer[i].outcode &
                context->VertexBuffer[i+1].outcode &
                context->VertexBuffer[i+2].outcode;

                if (local_and == 0)
                {
                  complete[i] = local_or;

                  if(local_or & MGL_CLIP_NEGW)
                  {
                          visible[i] = GL_TRUE;
                          backface = 0;
                  }
                  else
                  {
                        visible[i] = hc_DecideFrontface(context, &(context->VertexBuffer[i]), &(context->VertexBuffer[i+1]), &(context->VertexBuffer[i+2]));

                        if(visible[i] == GL_FALSE)
                           backface++;
                        else
                           backface = 0;
                  }
                }
                else
                {
                        visible[i] = GL_FALSE;
                        backface++;
                }

                context->CurrentCullSign = -context->CurrentCullSign; //reverse order
           }
           context->CurrentCullSign = CurrentCullSign;
        }

        if(backface == count-2) //early out
        return;

        visible[count-2] = GL_FALSE; //reduce control variable checking in next loop

        context->VertexBufferPointer -= backface;

        prevcopy = -1;
        free = context->VertexBufferPointer;
        pnum = 0; cnum = 0;
        i = 0;

        while(visible[i] == GL_FALSE) i++;
        newfirst = i;

        if(context->ArrayPointer.state & AP_FIXPOINT)
        {
                ConvertFixverts(&(context->VertexBuffer[newfirst]), (context->VertexBufferPointer-newfirst));
        }

        do
        {
                if(visible[i] == GL_FALSE)
                {
                        i++;
                }
                else
                {
                   if (complete[i]) // case 1
                   {
                        static PolyBuffer clip;
                        clip.verts[0] = i;
                        clip.verts[1] = i+1;
                        clip.verts[2] = i+2;

                   //this element is never shared with next triangle:
                        if(prevcopy == i+1)
                        {
                                   Convert(context, &context->VertexBuffer[i+2], first+i+2);
                        }
                        else if(prevcopy == i)
                        {
                                   Convert(context, &context->VertexBuffer[i+1], first+i+1);
                                   Convert(context, &context->VertexBuffer[i+2], first+i+2);
                        }
                        else
                        {
                                   Convert(context, &context->VertexBuffer[i], first+i);
                                   Convert(context, &context->VertexBuffer[i+1], first+i+1);
                                   Convert(context, &context->VertexBuffer[i+2], first+i+2);
                        }

                        prevcopy = i+2;

                        cnum += AE_ClipTriangle(context, &clip, &CBUF[cnum], &free, complete[i]);

                    i++;
                    }
                    else
                    {
                        int k=3;
                        PBUF[pnum].first = i+first;
                        i++;

                        while (complete[i]==0 && visible[i])
                        {
                                i++; k++;
                        }

                        PBUF[pnum].numverts = k;
                        pnum++;
                    }
                }
        } while (i < context->VertexBufferPointer-2);


//Project to screen and draw:

   if(pnum && cnum)
   {
        for(i=newfirst; i<context->VertexBufferPointer; i++)
        {
           if(context->VertexBuffer[i].outcode == 0)
           {
                AV_ToScreen(context, &context->VertexBuffer[i], i+first);
           }
        }

        for(i=context->VertexBufferPointer; i<free; i++)
        {
           if(context->VertexBuffer[i].outcode == 0)
           {
                V_ToScreen(context, &context->VertexBuffer[i]);
           }
        }

   }
   else if(pnum)
   {
        for(i=newfirst; i<context->VertexBufferPointer; i++)
        {
                if(context->VertexBuffer[i].outcode == 0)
                {
                        A_ToScreen(context, &context->VertexBuffer[i], i+first);
                }
        }
   }
   else
   {
        for(i=newfirst; i<free; i++)
        {
                if(context->VertexBuffer[i].outcode == 0)
                {
                        V_ToScreen(context, &context->VertexBuffer[i]);
                }
        }
   }

   if(pnum) //draw buffered unclipped trifans
   {
        do
        {
           pnum--;

           error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, PBUF[pnum].first, PBUF[pnum].numverts);

        } while (pnum > 0);
   }

   if(cnum)
   {
        int j;
        static W3D_Vertex *verts[16];
        static W3D_TrianglesV fan;

        fan.st_pattern = NULL;
        fan.v = verts;
        fan.tex = context->w3dTexBuffer[context->CurrentBinding];

        for(i=0; i<cnum; i++)
        {
            PolyBuffer *p = &CBUF[i];

            for (j=0; j<p->numverts; j++)
            {
                verts[j] = &(context->VertexBuffer[p->verts[j]].v);
            }

            fan.vertexcount = p->numverts;
            error = W3D_DrawTriFanV(context->w3dContext, &fan);
        }
   }
}


static void A_DrawTriangles(GLcontext context, int first, int count)
{
      int i;
      ULONG and_code;
        ULONG or_code;
      ULONG error;
      GLuint visible;
      static int sign;
      int cnum, free, start, vbptr;
      int chainverts;

      error = A_TransformArray(context, first, count);

        if(error == 0) //all verts on screen - simple case
        {    
           A_ToScreenArray(context, &context->VertexBuffer[0], first, count);

           if(context->CullFace_State == GL_FALSE)
           {
                error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, first, count);
           }
         else
         {
              #define x(a) (context->VertexBuffer[a].bx)
              #define y(a) (context->VertexBuffer[a].by)

              float area;
              float x1,x2,y1,y2;

                vbptr = 0;
              chainverts = 0;
              i = start = first;
              sign = context->CurrentCullSign;

                do
                {
                   x1 = x(vbptr+1) - x(vbptr);
                   y1 = y(vbptr+1) - y(vbptr);
                   x2 = x(vbptr+2) - x(vbptr);
                   y2 = y(vbptr+2) - y(vbptr);

                   area = y2*x1 - x2*y1;

                   if(sign > 0)
                      area = -area;

                   if(area < context->MinTriArea)
                   {
                        if (chainverts)
                        {
                           error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, start, chainverts);

                           chainverts = 0;
                        }
                     }
                     else
                   {
                        if(chainverts == 0)
                        {
                                start = i;
                                chainverts = 3;
                        }
                        else
                        {
                                chainverts += 3;
                        }
                   }

                i     += 3;
                vbptr += 3;

                } while (vbptr < context->VertexBufferPointer);

              #undef x
              #undef y

              if (chainverts) //draw eventual remainder
              {
                    error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, start, chainverts);
              }

         }

      return;
        }

      chainverts = 0;
      cnum = 0;
      vbptr = 0;

      sign = context->CurrentCullSign;
      free = context->VertexBufferPointer;

      start = first;
      i = first;

      do
      {
           and_code = context->VertexBuffer[vbptr].outcode & context->VertexBuffer[vbptr+1].outcode & context->VertexBuffer[vbptr+2].outcode;

           or_code = context->VertexBuffer[vbptr].outcode | context->VertexBuffer[vbptr+1].outcode | context->VertexBuffer[vbptr+2].outcode;

           if(and_code)
           {
                if(chainverts)
                {
                        error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, start, chainverts);

                chainverts = 0;
                }

           vbptr += 3;
           i     += 3;

           }
           else
           {
                if(or_code == 0)
                {
                   A_ToScreenArray(context, &(context->VertexBuffer[vbptr]), i, 3);

                   if(context->CullFace_State == GL_FALSE)
                   {
                        visible = GL_TRUE;
                   }
                   else
                   {
                        #define x(a) (context->VertexBuffer[a].bx)
                        #define y(a) (context->VertexBuffer[a].by)

                        float area;
                        float x1,x2,y1,y2;

                        x1 = x(vbptr+1) - x(vbptr);
                        y1 = y(vbptr+1) - y(vbptr);
                        x2 = x(vbptr+2) - x(vbptr);
                        y2 = y(vbptr+2) - y(vbptr);

                        area = y2*x1 - x2*y1;

                        if(sign > 0)
                        area = -area;

                        if(area < context->MinTriArea)
                                visible = GL_FALSE;
                        else
                                visible = GL_TRUE;

                   #undef x
                   #undef y
                   }

                   if(visible)
                   {
                        if(chainverts == 0)
                        {
                                start = i;
                                chainverts = 3;
                        }
                        else
                        {
                                chainverts += 3;
                        }
                   }
                   else
                   {
                        if (chainverts)
                        {
                           error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, start, chainverts);

                           chainverts = 0;
                        }
                   }

           vbptr += 3;
           i     += 3;

           }
           else
           {
                   if(chainverts)
                   {
                        error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, start, chainverts);
                        chainverts = 0;
                   }

                   if(context->ArrayPointer.state & AP_FIXPOINT)
                   {
                        ConvertFixverts(&(context->VertexBuffer[vbptr]), 3);
                   }

                   if(context->CullFace_State == GL_FALSE || (or_code & MGL_CLIP_NEGW))
                   {
                        visible = GL_TRUE;
                   }
                   else
                   {
                        visible = hc_DecideFrontface(context, &(context->VertexBuffer[vbptr]), &(context->VertexBuffer[vbptr+1]), &(context->VertexBuffer[vbptr+2]));
                   }

                   if(visible)
                   {
                     static PolyBuffer clip;

                     clip.verts[0] = vbptr;
                     clip.verts[1] = vbptr+1;
                     clip.verts[2] = vbptr+2;

                     Convert(context, &context->VertexBuffer[vbptr], i);
                     Convert(context, &context->VertexBuffer[vbptr+1], i+1);
                     Convert(context, &context->VertexBuffer[vbptr+2], i+2);

                     cnum += AE_ClipTriangle(context, &clip, &CBUF[cnum], &free, or_code);
                   }

                vbptr += 3;
                i     += 3;

                }
           }

      } while (vbptr < context->VertexBufferPointer);


      if(chainverts) //draw remainder of unclipped triangles
      {
                error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, start, chainverts);
      }

      if (cnum)
      {
         int j;
         static W3D_Vertex *verts[16];
         static W3D_TrianglesV fan;

         fan.tex = context->w3dTexBuffer[context->CurrentBinding];
         fan.st_pattern = NULL;
         fan.v = verts;


         for(i=0; i<cnum; i++)
         {
              PolyBuffer *p = &CBUF[i];

              for (j=0; j<p->numverts; j++)
              {
                   verts[j] = &(context->VertexBuffer[p->verts[j]].v);
                   V_ToScreen(context, &context->VertexBuffer[p->verts[j]]);
              }

              fan.vertexcount = p->numverts;
              error = W3D_DrawTriFanV(context->w3dContext, &fan);
         }
     }
}


static void A_DrawFlatFan(GLcontext context, int first, int count)
{
   int i;
   ULONG error;
   MGLVertex *v;
   UBYTE *Vpointer;
   UBYTE *Wpointer;
   float *W;
   int Vstride;
   int Wstride;

   Vstride = context->ArrayPointer.vertexstride;
   Wstride = context->ArrayPointer.texcoordstride;

   Wpointer = context->ArrayPointer.w_buffer + first * Wstride;
   Vpointer = context->ArrayPointer.verts + first * Vstride;

   v = &context->VertexBuffer[0];

   if(context->ArrayPointer.state & AP_FIXPOINT)
   {
      int *V;
      i = count;

      do
      {
         V = (int*)Vpointer;

         v->bx = (float)V[0];
         v->by = (float)V[1];
         v->bz = (float)V[2];

         W = (float*)Wpointer;
         *W = 1.0;

        v++; Vpointer += Vstride; Wpointer += Wstride;
      } while (--i);
   }
   else
   {
      float *V;
      i = count;

      do
      {
         V = (float*)Vpointer;

         v->bx = V[0];
         v->by = V[1];
         v->bz = V[2];

         W = (float*)Wpointer;
         *W = 1.0;

        v++; Vpointer += Vstride; Wpointer += Wstride;
      } while (--i);
   }

   error = W3D_DrawArray(context->w3dContext, W3D_PRIMITIVE_TRIFAN, first, count);
}

//end of pipeline

#ifdef VA_SANITY_CHECK

// Swap_TextureCoordPointers added 01-06-2002
// Thanks to Olivier Fabre for making me aware of possible
// memprot problems without such a safety-check.
// It will only be needed if glTexcoordPointer,
// GL_TEXTURE_COORD_ARRAY and GL_TEXTURE_2D state are not
// in "sync".

void Swap_TextureCoordPointers(GLcontext context, GLboolean enable) 
{
        if(enable == GL_TRUE)
        {
                Set_W3D_TexCoordPointer(context->w3dContext, (void*)context->ArrayPointer.texcoords, context->ArrayPointer.texcoordstride, 0, sizeof(GLfloat), context->ArrayPointer.w_off, W3D_TEXCOORD_NORMALIZED);
        }
        else
        {
        // guaranteed valid spot as long as vertexbuffer
        // is big enough

                Set_W3D_TexCoordPointer(context->w3dContext, (void*)&context->VertexBuffer[0].v.u, sizeof(MGLVertex), 0, 4, -4, W3D_TEXCOORD_NORMALIZED);
        }
}

#else

        #define Swap_TextureCoordPointers(c,e) {}

#endif

void GLEnableClientState(GLcontext context, GLenum state)
{
        switch (state)
        {
                case GL_TEXTURE_COORD_ARRAY:
                      context->ClientState |= GLCS_TEXTURE;
                      Swap_TextureCoordPointers(context, GL_TRUE); 
                      break;

                case GL_COLOR_ARRAY:
                      context->ClientState |= GLCS_COLOR;
                      break;

                case GL_VERTEX_ARRAY:
                      context->ClientState |= GLCS_VERTEX;
                      break;

                default:
                        GLFlagError(context, 1, GL_INVALID_ENUM);
                break;
        }
}


void GLDisableClientState(GLcontext context, GLenum state)
{
        switch (state)
        {
                case GL_TEXTURE_COORD_ARRAY:
                        context->ClientState &= ~GLCS_TEXTURE;
                        Swap_TextureCoordPointers(context, GL_FALSE); 
                        break;

                case GL_COLOR_ARRAY:
                        context->ClientState &= ~GLCS_COLOR;
                        break;

                case GL_VERTEX_ARRAY:
                        context->ClientState &= ~GLCS_VERTEX;
                        break;

                default:
                        GLFlagError(context, 1, GL_INVALID_ENUM);
                        break;
        }

}


void GLInterleavedArrays(GLcontext context, GLenum format, GLsizei stride, const GLvoid *pointer)
{

   #define PTR context->ArrayPointer

   switch((int)format)
   {
        case GL_V3F:
                context->ClientState = GLCS_VERTEX;
                PTR.verts = (UBYTE *)pointer;
                Convert = (Convfn)Convert_F_RGB; //dummy

                if(stride == 0)
                        PTR.vertexstride = 3*sizeof(GLfloat);
                else
                        PTR.vertexstride = stride;
        break;
        case GL_C4UB_V3F:
                context->ClientState = GLCS_VERTEX|GLCS_COLOR;
                PTR.colors = (UBYTE *)pointer;
                PTR.verts = ((UBYTE *)pointer + 4);
                PTR.colormode = W3D_COLOR_UBYTE | W3D_CMODE_RGBA;
                Convert = (Convfn)Convert_UB_RGBA;

                if(stride == 0)
                {
                        PTR.vertexstride = PTR.colorstride = 3*sizeof(GLfloat) + 4*sizeof(GLubyte);
                }
                else
                {
                        PTR.vertexstride = PTR.colorstride = stride;
                }
        break;
        case GL_C3F_V3F:
                context->ClientState = GLCS_VERTEX|GLCS_COLOR;
                PTR.colors = (UBYTE *)pointer;
                PTR.verts = ((UBYTE *)pointer + 12);
                PTR.colormode = W3D_COLOR_FLOAT | W3D_CMODE_RGB;
                Convert = (Convfn)Convert_F_RGB;

                if(stride == 0)
                {
                        PTR.vertexstride = PTR.colorstride = 6*sizeof(GLfloat);
                }
                else
                {
                        PTR.vertexstride = PTR.colorstride = stride;
                }
        break;
        case GL_T2F_V3F:
                context->ClientState = GLCS_VERTEX|GLCS_TEXTURE;
                PTR.texcoords = (UBYTE *)pointer;
                PTR.verts = ((UBYTE *)pointer + 8);
                Convert = (Convfn)Convert_F_RGB;

                if(stride == 0)
                {
                        PTR.vertexstride = PTR.texcoordstride = 5*sizeof(GLfloat);
                }
                else
                {
                        PTR.vertexstride = PTR.texcoordstride = stride;
                }
        break;
        case GL_T2F_C4UB_V3F:
                context->ClientState = GLCS_VERTEX|GLCS_TEXTURE|GLCS_COLOR;
                PTR.texcoords = (UBYTE *)pointer;
                PTR.colors = ((UBYTE *)pointer + 8);
                PTR.colormode = W3D_COLOR_UBYTE | W3D_CMODE_RGBA;
                Convert = (Convfn)Convert_UB_RGBA;
                PTR.verts = ((UBYTE *)pointer + 12);

                if(stride == 0)
                {
                        PTR.vertexstride = PTR.colorstride = PTR.texcoordstride = 5*sizeof(GLfloat) + 4*sizeof(GLubyte);
                }
                else
                {
                        PTR.vertexstride = PTR.colorstride = PTR.texcoordstride = stride;
                }
        break;
        case GL_T2F_C3F_V3F:
                context->ClientState = GLCS_VERTEX|GLCS_TEXTURE|GLCS_COLOR;
                PTR.texcoords = (UBYTE *)pointer;
                PTR.colors = ((UBYTE *)pointer + 8);
                PTR.colormode = W3D_COLOR_FLOAT | W3D_CMODE_RGB;
                Convert = (Convfn)Convert_F_RGB;
                PTR.verts = ((UBYTE *)pointer + 20);

                if(stride == 0)
                {
                        PTR.vertexstride = PTR.colorstride = PTR.texcoordstride = 8*sizeof(GLfloat);
                }
                else
                {
                        PTR.vertexstride = PTR.colorstride = PTR.texcoordstride = stride;
                }
        break;
        default:
                GLFlagError(context, 1, GL_INVALIE_ENUM);
                context->ClientState = 0;
        break;
   }


   if(context->ClientState & GLCS_COLOR)
   {
        if(PTR.colormode & W3D_COLOR_UBYTE)
        {
           Set_W3D_ColorPointer(context->w3dContext, (void *)PTR.colors, PTR.colorstride, W3D_COLOR_UBYTE, W3D_CMODE_RGBA, 0);
        }
        else
        {
           ULONG cmode = PTR.colormode &~W3D_COLOR_FLOAT;

           Set_W3D_ColorPointer(context->w3dContext, (void *)PTR.colors, PTR.colorstride, W3D_COLOR_FLOAT, cmode, 0);
        }
   }


   if(context->ClientState & GLCS_TEXTURE)
   {
        int w_off;
        BYTE *base, *target;

        target = (BYTE*)context->WBuffer;
        base   = (BYTE*)PTR.texcoords;

        if(target < base)
        {
                w_off = (base - target);
                w_off = -w_off; 
        }
        else
        {
                w_off = (target - base);
        }

        PTR.w_off = w_off;
        PTR.w_buffer = target;

        Set_W3D_TexCoordPointer(context->w3dContext, (void*)PTR.texcoords, PTR.texcoordstride, 0, sizeof(GLfloat), w_off, W3D_TEXCOORD_NORMALIZED);
   }
   else
   {
        PTR.w_buffer = (GLubyte*)&context->VertexBuffer[0].v.w;

        Set_W3D_TexCoordPointer(context->w3dContext, (void*)&context->VertexBuffer[0].v.u, sizeof(MGLVertex), 0, 4, -4, W3D_TEXCOORD_NORMALIZED);

   }

   #undef PTR

   context->ArrayPointer.state = 0;
}


static GLuint cur_texcoordpointer_state = GL_TRUE;


void GLTexCoordPointer(GLcontext context, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
   int w3dStride;
   int w_off;
   BYTE *base, *target;

//check pipeline state to make sure that w_off was calculated:

   if((context->ArrayPointer.texcoords == (UBYTE*)pointer) && (cur_texcoordpointer_state == context->VertexArrayPipeline))
   {
        return;
   }

#ifdef VA_SANITY_CHECK

   if(!pointer) //thanks to OF for making me aware..
   {
        context->ArrayPointer.texcoords = (UBYTE*)&context->VertexBuffer[0].v.u;
        context->ArrayPointer.texcoordstride = sizeof(MGLVertex);
        context->ArrayPointer.w_off = -4;
        context->ArrayPointer.w_buffer = (UBYTE*)&context->VertexBuffer[0].v.w;
        
      Set_W3D_TexCoordPointer(context->w3dContext, (void*)&context->VertexBuffer[0].v.u, sizeof(MGLVertex), 0, 4, -4, W3D_TEXCOORD_NORMALIZED);

        return;
   }

#endif

   if (stride == 0)     w3dStride = size*sizeof(GLfloat);
   else         w3dStride = stride;

   if (type != GL_FLOAT)   GLFlagError(context, 1, GL_INVALID_ENUM);

   context->ArrayPointer.texcoords = (UBYTE*)pointer;
   context->ArrayPointer.texcoordstride = w3dStride;

   cur_texcoordpointer_state = context->VertexArrayPipeline;

   if(context->VertexArrayPipeline == GL_FALSE)
   {
        if (size < 3)          GLFlagError(context, 1, GL_INVALID_VALUE);

        context->ArrayPointer.w_off = (size-1)*sizeof(GLfloat);
        context->ArrayPointer.w_buffer = context->ArrayPointer.texcoords + context->ArrayPointer.w_off;

        Set_W3D_TexCoordPointer(context->w3dContext, (void*)context->ArrayPointer.texcoords, w3dStride, 0, sizeof(GLfloat), context->ArrayPointer.w_off, W3D_TEXCOORD_NORMALIZED);
   }
   else
   {
        if(size > 2) // Last element used for writing w-coords
        {            // NOT OpenGL conforming !

           w_off = (size-1)*sizeof(GLfloat);

           context->ArrayPointer.w_off = w_off;
           context->ArrayPointer.w_buffer = context->ArrayPointer.texcoords + w_off;
        }
        else
        {
         //find w_array-offset relative to current pointer:

           target = (BYTE*)context->WBuffer;
           base   = (BYTE*)pointer;

           if(target < base)
           {
                w_off = (base - target);
                w_off = -w_off; 
           }
           else
           {
                w_off = (target - base);
           }

           context->ArrayPointer.w_off = w_off;
           context->ArrayPointer.w_buffer = target;
        }


      Set_W3D_TexCoordPointer(context->w3dContext, (void*)context->ArrayPointer.texcoords, w3dStride, 0, sizeof(GLfloat), w_off, W3D_TEXCOORD_NORMALIZED);
   }
}


void GLColorPointer(GLcontext context, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
    int w3dStride;
    ULONG w3dType, w3dFormat;

    if(context->ArrayPointer.colors == (UBYTE*)pointer)
        return;

#ifdef VA_SANITY_CHECK

    if(!pointer) //thanks to OF for making me aware..
    {
        context->ArrayPointer.colors = (UBYTE*)&context->VertexBuffer[0].v.color;
      context->ArrayPointer.colorstride = sizeof(MGLVertex);
        context->ArrayPointer.colormode = W3D_COLOR_FLOAT | W3D_CMODE_RGBA;
        Convert = (Convfn)Convert_F_RGBA;

      Set_W3D_ColorPointer(context->w3dContext, (void *)&context->VertexBuffer[0].v.color, sizeof(MGLVertex),
            W3D_COLOR_FLOAT, W3D_CMODE_RGBA, 0);
 
        return;
    }

#endif

    if (type != GL_UNSIGNED_BYTE && type != GL_FLOAT && type != MGL_UBYTE_BGRA && type != MGL_UBYTE_ARGB)
        GLFlagError(context, 1, GL_INVALID_ENUM);

    if (stride == 0)
        w3dStride = size * (type == GL_FLOAT ? sizeof(GLfloat) : sizeof(GLubyte));
    else
        w3dStride = stride;

    context->ArrayPointer.colors = (UBYTE*)pointer;
    context->ArrayPointer.colorstride = w3dStride;


    if(type == GL_FLOAT)
        w3dType = W3D_COLOR_FLOAT;
    else
        w3dType = W3D_COLOR_UBYTE;


    if (type != MGL_UBYTE_ARGB)
    {
          if(type == GL_FLOAT)
          {
                if(size == 3)
                {
                   w3dFormat = W3D_CMODE_RGB;
                   Convert   = (Convfn)Convert_F_RGB;
                }
                else
                {
                   w3dFormat = W3D_CMODE_RGBA;
                   Convert   = (Convfn)Convert_F_RGBA;
                }
          }
          else if (type == MGL_UBYTE_BGRA)
          {
                if(size == 3)
                {
                   w3dFormat = W3D_CMODE_BGR;
                   Convert   = (Convfn)Convert_UB_BGR;
                }
                else
                {
                   w3dFormat = W3D_CMODE_BGRA;
                   Convert   = (Convfn)Convert_UB_BGRA;
                }
          }
          else // GL_UNSIGNED_BYTE
          {
                if(size == 3)
                {
                   w3dFormat = W3D_CMODE_RGB;
                   Convert   = (Convfn)Convert_UB_RGB;
                }
                else
                {
                   w3dFormat = W3D_CMODE_RGBA;
                   Convert   = (Convfn)Convert_UB_RGBA;
                }
          }
    }
    else
    {
        if(size != 4) GLFlagError(context, 1, GL_INVALID_VALUE);

        w3dFormat = W3D_CMODE_ARGB;
        Convert = (Convfn)Convert_UB_ARGB;
    }

    context->ArrayPointer.colormode = w3dType | w3dFormat;

    Set_W3D_ColorPointer(context->w3dContext, (void *)context->ArrayPointer.colors, w3dStride, w3dType, w3dFormat, 0);
}


static GLuint cur_vertexpointer_state = GL_TRUE;

void GLVertexPointer(GLcontext context, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
    int w3dStride;

    if (size < 3 || (type != GL_FLOAT && type != GL_INT))
    GLFlagError(context, 1, GL_INVALID_VALUE);

    if((context->ArrayPointer.verts == (UBYTE*)pointer) && (cur_vertexpointer_state == context->VertexArrayPipeline))
    {
        return;
    }

#ifdef VA_SANITY_CHECK

    if(!pointer) //thanks to OF for making me aware..
    {
        context->ArrayPointer.verts = (UBYTE*)&context->VertexBuffer[0].bx;
        context->ArrayPointer.vertexstride = sizeof(MGLVertex);

        context->ArrayPointer.state = 0;

        if (Reset_W3D_VertexPointer == GL_TRUE)
        {
                Set_W3D_VertexPointer(context->w3dContext, (void *) &(context->VertexBuffer->bx), sizeof(MGLVertex), W3D_VERTEX_F_F_F, 0);

                Reset_W3D_VertexPointer = GL_FALSE;
        }

    return;
    }

#endif

    if(type == GL_INT)
    {
        context->ArrayPointer.state = AP_FIXPOINT;
      if (stride == 0) w3dStride = size * sizeof(GLint);
        else w3dStride = stride;
    }
    else
    {
        context->ArrayPointer.state = 0;
      if (stride == 0) w3dStride = size * sizeof(GLfloat);
        else w3dStride = stride;
    }

    context->ArrayPointer.verts = (UBYTE*)pointer;
    context->ArrayPointer.vertexstride = w3dStride;

    cur_vertexpointer_state = context->VertexArrayPipeline;

    if(context->VertexArrayPipeline == GL_FALSE)
    {
        if(type == GL_INT)
        GLFlagError(context, 1, GL_INVALID_VALUE);

        Reset_W3D_VertexPointer = GL_TRUE; //not default

        Set_W3D_VertexPointer(context->w3dContext, (void *)pointer, w3dStride, W3D_VERTEX_F_F_F, 0);
    }
    else if (Reset_W3D_VertexPointer == GL_TRUE)
    {
        Set_W3D_VertexPointer(context->w3dContext, (void *) &(context->VertexBuffer->bx), sizeof(MGLVertex), W3D_VERTEX_F_F_F, 0);

        Reset_W3D_VertexPointer = GL_FALSE;
    }
}


static INLINE void PreDraw(GLcontext context)
{
   //validate w-offset:

   if(!(context->ClientState & GLCS_TEXTURE))
   {
        context->ArrayPointer.w_buffer = (GLubyte *)context->WBuffer;
   }


   if (context->FogDirty && context->Fog_State)
   {
        fog_Set(context);
        context->FogDirty = GL_FALSE;
   }


   if (context->ShadeModel == GL_FLAT && context->UpdateCurrentColor == GL_TRUE)
   {
        context->UpdateCurrentColor = GL_FALSE;
        W3D_SetCurrentColor(context->w3dContext, &context->CurrentColor);
   }

#ifdef AUTOMATIC_LOCKING_ENABLE
   if (context->LockMode != MGL_LOCK_MANUAL)
   {
        if (context->LockMode == MGL_LOCK_AUTOMATIC) // Automatic: Lock per primitive
        {
        if (W3D_SUCCESS == W3D_LockHardware(context->w3dContext))
        {
                context->w3dLocked = GL_TRUE;
        }
        else
        {
                printf("Error during LockHardware\n");
        }
        }
        else // Smart: Lock timer based
        {
        if (context->w3dLocked == GL_FALSE)
        {
            if (W3D_SUCCESS != W3D_LockHardware(context->w3dContext))
            {
                return; // give up
            }
            context->w3dLocked = GL_TRUE;
            TMA_Start(&(context->LockTime));
        }
        }
   }
#endif
}

static INLINE void PostDraw(GLcontext context)
{
   if(!(context->ClientState & GLCS_TEXTURE))
   {
        context->ArrayPointer.w_buffer = context->ArrayPointer.texcoords + context->ArrayPointer.w_off;
   }

   context->VertexBufferPointer = 0;

#ifdef AUTOMATIC_LOCKING_ENABLE
    if (context->LockMode == MGL_LOCK_SMART && TMA_Check(&(context->LockTime)) == GL_TRUE)
    {
        // Time to unlock
        W3D_UnLockHardware(context->w3dContext);
        context->w3dLocked = GL_FALSE;
    }
    else if (context->LockMode == MGL_LOCK_AUTOMATIC)
    {
                W3D_UnLockHardware(context->w3dContext);
                context->w3dLocked = GL_FALSE;
    }
#endif
}

#ifndef GL_NOERRORCHECK
static void A_DrawNULL(GLcontext context, int first, int count)
{
        GLFlagError(context, 1, GL_INVALID_ENUM);
}
#endif

static void A_DrawDirect(GLcontext context, int first, int count)
{
        ULONG error;

        error = W3D_DrawArray(context->w3dContext, context->CurrentPrimitive, first, count);
}


void GLDrawArrays(GLcontext context, GLenum mode, GLint first, GLsizei count)
{
   static ADrawfn A_Draw;
   MGLVertex *offset;
#ifdef VA_SANITY_CHECK
   GLuint ShadeModel_bypass;
   GLuint TexCoord_bypass;
#endif

#ifndef GL_NOERRORCHECK
        if(!(context->ClientState & GLCS_VERTEX))
        {
                  GLFlagError(context, 1, GL_INVALID_OPERATION);        
                return; //added 28-JUL-02
        }
#endif

   if(count < 3)
        return; //invalid vertexcount or primitive


   //11-04-02 - check for compiled arrays
   //sorry - no time to write proper handling for this.
   //Anyways, glDrawArrays is rarely used within a lock.

   if(context->ArrayPointer.state & AP_COMPILED)
   {
        GLDrawElements(context, mode, count, GL_UNSIGNED_SHORT, (void*)&(e_wrap[first]));
        return;
   }

#ifdef VA_SANITY_CHECK
   ShadeModel_bypass = 0;
   TexCoord_bypass = 0;

   //Thanks to OF for making me aware of this unlikely case

   if((context->ShadeModel == GL_SMOOTH) && !(context->ClientState & GLCS_COLOR))
   {
        glShadeModel(GL_FLAT);
        ShadeModel_bypass |= 0x01;
   }
   else if((context->ShadeModel == GL_FLAT) && (context->ClientState & GLCS_COLOR)
   {
        context->ClientState &= ~GLCS_COLOR;
        ShadeModel_bypass |= 0x02;
   }

   if((context->Texture2D_State[0] == GL_TRUE) && !(context->ClientState & GLCS_TEXTURE))
   {
        glDisable(GL_TEXTURE_2D);
        TexCoord_bypass |= 0x01;
   }
   if((context->Texture2D_State[0] == GL_FALSE) && (context->ClientState & GLCS_TEXTURE))
   {
        context->ClientState &= ~GLCS_TEXTURE;
        TexCoord_bypass |= 0x02;
   }
#endif

   if(context->Texture2D_State[0] == GL_TRUE)
   {
      Set_W3D_Texture(context->w3dContext, 0, context->w3dTexBuffer[context->CurrentBinding]);
   }
   else
   {
      Set_W3D_Texture(context->w3dContext, 0, NULL);
   }

   if(context->VertexArrayPipeline == GL_FALSE)
   {
         context->CurrentPrimitive = mode;
         A_Draw = (ADrawfn)A_DrawDirect;
   }
   else
   {
        switch(mode)
        {
                case MGL_FLATFAN:
                A_Draw = (ADrawfn)A_DrawFlatFan;
                break;

                case GL_QUADS:
                A_Draw = (ADrawfn)A_DrawQuads;
                break;

                case GL_QUAD_STRIP:
                A_Draw = (ADrawfn)A_DrawQuadStrip;
                break;

                case GL_TRIANGLES:
                A_Draw = (ADrawfn)A_DrawTriangles;
                break;

                case GL_TRIANGLE_STRIP:
                A_Draw = (ADrawfn)A_DrawTriStrip;
                break;

#ifdef GL_NOERRORCHECK
                default:
#else
                case GL_POLYGON:
                case GL_TRIANGLE_FAN:
#endif
                A_Draw = (ADrawfn)A_DrawTriFan;
                break;

#ifndef GL_NOERRORCHECK
                default:
                A_Draw = (ADrawfn)A_DrawNULL;
#endif
        }
   }

   PreDraw(context);

   context->VertexBufferPointer = count;

   if(first && context->VertexArrayPipeline != GL_FALSE)
   {
     offset = context->VertexBuffer - first;
     context->w3dContext->VertexPointer = (void*)&offset->bx;
   }

   if(context->ZOffset_State == GL_TRUE)
   {
	context->az += context->ZOffset;
   }

   A_Draw(context, first, count);

   if(context->ZOffset_State == GL_TRUE)
   {
	context->az -= context->ZOffset;
   }

   if(context->VertexArrayPipeline != GL_FALSE)
   {
      context->w3dContext->VertexPointer = (void*)&context->VertexBuffer[0].bx;
   }
   else
   {
      context->CurrentPrimitive = GL_BASE;
   }

   PostDraw(context);


#ifdef VA_SANITY_CHECK
   if(ShadeModel_bypass)
   {
        if(ShadeModel_bypass & 1)
        {
                glShadeModel(GL_SMOOTH);
        }
        if(ShadeModel_bypass & 2)
        {
                context->ClientState |= GLCS_COLOR;
        }
   }

   if(TexCoord_bypass)
   {
        if(TexCoord_bypass & 1)
        {
                glEnable(GL_TEXTURE_2D);
        }
        if(TexCoord_bypass & 2)
        {
                context->ClientState |= GLCS_TEXTURE;
        }
   }
#endif
}
