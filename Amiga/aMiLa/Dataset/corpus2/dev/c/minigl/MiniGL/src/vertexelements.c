#include "sysinc.h"
#include "vertexarray.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/*
** glDrawElements pipeline by Christian 'Surgeon' Michael
** Thanks to Olivier Fabre for bug-hunting
**
** major revision 05-07 april 2002:
** optimized path for GL_EXT_compiled_vertex_array
**
*/


extern void TMA_Start(LockTimeHandle *handle);
extern GLboolean TMA_Check(LockTimeHandle *handle);
extern void fog_Set(GLcontext context);

void GLLockArrays(GLcontext context, GLuint first, GLsizei count);
void GLUnLockArrays(GLcontext context);

extern void m_CombineMatrices(GLcontext context);

extern int AE_ClipTriangle(GLcontext context, PolyBuffer *in, PolyBuffer *out, int *clipstart, ULONG or_codes);


extern Convfn Convert;

//NYI:
static void E_DrawQuads         (GLcontext context, const int count, const UWORD *idx);

static void E_DrawQuadStrip     (GLcontext context, const int count, const UWORD *idx);

//implemented:

#ifndef __VBCC__
static void E_DrawTriFan           (GLcontext context, const int count, const UWORD *idx);
#else
static void E_DrawTriFan           (GLcontext context, const int count, UWORD *idx);
#endif

static void E_DrawTriStrip         (GLcontext context, const int count, const UWORD *idx);

static void E_DrawTriangles     (GLcontext context, const int count, const UWORD *idx);

static void E_DrawFlatFan       (GLcontext context, const int count, const UWORD *idx);

static PolyBuffer clipbuffer[MGL_MAXVERTS>>2];

#define CBUF clipbuffer
#define PBUF polys

#define NOGUARD (MGL_CLIP_LEFT|MGL_CLIP_RIGHT|MGL_CLIP_TOP|MGL_CLIP_BOTTOM|MGL_CLIP_FRONT|MGL_CLIP_BACK|MGL_CLIP_NEGW)


static INLINE GLuint E_CheckTri(GLcontext context, const MGLVertex *a, const MGLVertex *b, const MGLVertex *c)
{
        float area;
        float x1,y1;
        float x2,y2;

        x1 = b->v.x - a->v.x;
        y1 = b->v.y - a->v.y;
        x2 = c->v.x - a->v.x;
        y2 = c->v.y - a->v.y;
           
        area = y2*x1 - x2*y1;

        if(context->CurrentCullSign > 0)
                area = -area;

        if(area < context->MinTriArea)
                return GL_FALSE;
        else
                return GL_TRUE;
}

//added 15-JUL-02: For locked arrays

static INLINE GLuint E_CheckTriLocked(GLcontext context, const MGLVertex *a, const MGLVertex *b, const MGLVertex *c)
{
        float area;
        float x1,y1;
        float x2,y2;

        x1 = b->bx - a->bx;
        y1 = b->by - a->by;
        x2 = c->bx - a->bx;
        y2 = c->by - a->by;
           
        area = y2*x1 - x2*y1;

        if(context->CurrentCullSign > 0)
                area = -area;

        if(area < context->MinTriArea)
                return GL_FALSE;
        else
                return GL_TRUE;
}

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


static INLINE void TransformIndex(GLcontext context, const int size, const UWORD *idx)
{
   int i;

   #define a(x) (context->CombinedMatrix.v[OF_##x])

   if(context->ArrayPointer.state & AP_FIXPOINT)
   {
   static int m[16];
   int stride;
   const float fix2float = 1.f/32768.f;

        #define CLIP_EPS ((int)((1e-7)*32768.f))

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

     i = size-1;
     do
     {
        MGLVertex *v;
        ULONG local_outcode;
        int tx,ty,tz,tw;
        int x,y,z;
        int *vp;

        v = &(context->VertexBuffer[idx[i]]);
        vp = (int *)(context->ArrayPointer.verts + idx[i]*stride);

        x = vp[0];
        y = vp[1];
        z = vp[2];

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

        v->bx = (float)tx*fix2float;    
        v->by = (float)ty*fix2float;
        v->bz = (float)tz*fix2float;    
        v->bw = (float)tw*fix2float;    

      v->outcode = local_outcode;

     } while (i--);

     #undef b
     #undef CLIP_EPS 
   }
   else
   {
     float a11,a12,a13,a14;
     float a21,a22,a23,a24;
     float a31,a32,a33,a34;
     float a41,a42,a43,a44;
     int stride;

     #define CLIP_EPS (1e-7)

     if(context->CombinedValid == GL_FALSE)
                m_CombineMatrices(context);

     a11=a(11); a12=a(12); a13=a(13); a14=a(14);
     a21=a(21); a22=a(22); a23=a(23); a24=a(24);
     a31=a(31); a32=a(32); a33=a(33); a34=a(34);
     a41=a(41); a42=a(42); a43=a(43); a44=a(44);

     stride = context->ArrayPointer.vertexstride;

     i = size-1;

     do
     {
        MGLVertex *v;
        ULONG local_outcode;
        float cw;
        float x,y,z;
        float *vp;

        v = &(context->VertexBuffer[idx[i]]);
        vp = (float *)(context->ArrayPointer.verts + idx[i]*stride);

        x = vp[0];
        y = vp[1];
        z = vp[2];

        v->bx = a11*x + a12*y + a13*z + a14;
        v->by = a21*x + a22*y + a23*z + a24;
        v->bz = a31*x + a32*y + a33*z + a34;
        v->bw = a41*x + a42*y + a43*z + a44;

        cw = v->bw;
        local_outcode = 0;

        if (cw < CLIP_EPS )
                local_outcode |= MGL_CLIP_NEGW;
        
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

        v->outcode = local_outcode;

     } while (i--);

     #undef CLIP_EPS
     #undef a
   }
}


//following 6 functions are called from glLockArrays

//05-04-02    returns number of onscreen verts

static INLINE ULONG TransformRange(GLcontext context, const int first, const int size)
{
   int i;
   ULONG border;
   int offs = first+context->ArrayPointer.transformed;

   #define a(x) (context->CombinedMatrix.v[OF_##x])

   if(context->ArrayPointer.state & AP_FIXPOINT)
   {
        static int m[16];
        UBYTE *vpointer;
        MGLVertex *v;
        int stride;

        #define CLIP_EPS ((int)((1e-7)*32768.f))

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

     v = &(context->VertexBuffer[offs]);

     border = 0;
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

        border |= local_outcode;

        v->outcode = local_outcode;

        v->bx = (float)tx;      
        v->by = (float)ty;
        v->bz = (float)tz;      
        v->bw = (float)tw;      

     v++; vpointer += stride;

     } while (--i);

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

     if(context->CombinedValid == GL_FALSE)
     {
                m_CombineMatrices(context);
     }

     a11=a(11); a12=a(12); a13=a(13); a14=a(14);
     a21=a(21); a22=a(22); a23=a(23); a24=a(24);
     a31=a(31); a32=a(32); a33=a(33); a34=a(34);
     a41=a(41); a42=a(42); a43=a(43); a44=a(44);

     stride = context->ArrayPointer.vertexstride;
     vpointer = (context->ArrayPointer.verts + first*stride);

     v = &(context->VertexBuffer[offs]);
     i = size;

     do
     {
        float *vp = (float *)vpointer;
        float x = vp[0];
        float y = vp[1];
        float z = vp[2];

        v->bx = a11*x + a12*y + a13*z + a14;
        v->by = a21*x + a22*y + a23*z + a24;
        v->bz = a31*x + a32*y + a33*z + a34;
        v->bw = a41*x + a42*y + a43*z + a44;

     v++; vpointer += stride;

     } while (--i);

     v = &context->VertexBuffer[offs];
     i = size;
     border = 0;

     do
     {
        ULONG local_outcode = 0;
        float cw = v->bw;

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

        v->outcode = local_outcode;

        border |= local_outcode;

      v++;
      } while (--i);

      #undef CLIP_EPS 
   }

   #undef a

   return border;
}


static INLINE void ProjectRange(GLcontext context, const int first, const int size)
{
   int i, stride;
   UBYTE *pointer;
   float az;

   int offs = first+context->ArrayPointer.transformed;
   MGLVertex *v = &context->VertexBuffer[offs];
   stride = context->ArrayPointer.texcoordstride;
   pointer = context->ArrayPointer.w_buffer + first * stride;

   if(context->ZOffset_State == GL_TRUE)
   {
	az = context->az + context->ZOffset;
   }
   else
   {
	az = context->az;
   }

   if (context->ArrayPointer.state & AP_FIXPOINT)
   {
         i = size;
         do
         {
           float x = v->bx;
           float y = v->by;
           float z = v->bz;
           float w = 1.0 / v->bw;
        
           v->bx = context->ax + x * w * context->sx;
           v->by = context->ay - y * w * context->sy;
           v->bz = az + z * w * context->sz;

           w *= 32768.f;

           ((float*)pointer)[0] = w;           

         v++;
         pointer += stride;

         } while (--i);
   }
   else
   {
         i = size;
         do
         {
           float x = v->bx;
           float y = v->by;
           float z = v->bz;
           float w = 1.0 / v->bw;
        
           v->bx = context->ax + x * w * context->sx;
           v->by = context->ay - y * w * context->sy;
           v->bz = az + z * w * context->sz;

           ((float*)pointer)[0] = w;           

         v++;
         pointer += stride;
         } while (--i);
   }
}


static INLINE void ProjectRangeByOutcode(GLcontext context, const int first, const int size)
{
   int i, stride;
   UBYTE *pointer;
   float az;

   int offs = first+context->ArrayPointer.transformed;
   MGLVertex *v = &context->VertexBuffer[offs];
   stride = context->ArrayPointer.texcoordstride;
   pointer = context->ArrayPointer.w_buffer + first * stride;

   if(context->ZOffset_State == GL_TRUE)
   {
	az = context->az + context->ZOffset;
   }
   else
   {
	az = context->az;
   }

   if(context->ClipFlags == NOGUARD)
   {
      if(context->ArrayPointer.state & AP_FIXPOINT)
      {
             const float fix2float = 1.f/32768.f;

             for (i=0; i<size; i++, v++, pointer += stride)
             {
             float x = v->bx;
             float y = v->by;
             float z = v->bz;
             float w = v->bw;

             v->bx = fix2float * x;
             v->by = fix2float * y;
             v->bz = fix2float * z;
             v->bw = fix2float * w;

             if(v->outcode) continue;

             w = 1.0 / w;
        
             v->v.x = context->ax + x * w * context->sx;
             v->v.y = context->ay - y * w * context->sy;
             v->v.z = az + z * w * context->sz;

             w *= 32768.f;
             ((float*)pointer)[0] = w;           
             v->v.w = w;
             }
      }
      else
      {
             for (i=0; i<size; i++, v++, pointer += stride)
             {
             float x,y,z,w;

             if(v->outcode) continue;

             x = v->bx;
             y = v->by;
             z = v->bz;
             w = 1.0/v->bw;
        
             v->v.x = context->ax + x * w * context->sx;
             v->v.y = context->ay - y * w * context->sy;
             v->v.z = az + z * w * context->sz;

             ((float*)pointer)[0] = w;           
             v->v.w = w;
             }
      }
   }
   else
   {
      if(context->ArrayPointer.state & AP_FIXPOINT)
      {
             const float fix2float = 1.f/32768.f;

             for (i=0; i<size; i++, v++, pointer += stride)
             {
             float x = v->bx;
             float y = v->by;
             float z = v->bz;
             float w = v->bw;

             v->bx = fix2float * x;
             v->by = fix2float * y;
             v->bz = fix2float * z;
             v->bw = fix2float * w;

             if(v->cbuf_pos) continue;

             w = 1.0 / w;
        
             v->v.x = context->ax + x * w * context->sx;
             v->v.y = context->ay - y * w * context->sy;
             v->v.z = az + z * w * context->sz;

             w *= 32768.f;
             ((float*)pointer)[0] = w;           
             v->v.w = w;
             }
      }
      else
      {
             for (i=0; i<size; i++, v++, pointer += stride)
             {
             float x,y,z,w;

             if(v->cbuf_pos) continue;

             x = v->bx;
             y = v->by;
             z = v->bz;
             w = 1.0/v->bw;
        
             v->v.x = context->ax + x * w * context->sx;
             v->v.y = context->ay - y * w * context->sy;
             v->v.z = az + z * w * context->sz;

             ((float*)pointer)[0] = w;           
             v->v.w = w;
             }
      }
   }
}

#ifdef __PPC__
static INLINE
#else
static
#endif
 void E_ToScreenArray(GLcontext context, const int count, const UWORD *idx)
{
   int i, stride;
   float az;

   if(context->ZOffset_State == GL_TRUE)
   {
	az = context->az + context->ZOffset;
   }
   else
   {
	az = context->az;
   }

   stride = context->ArrayPointer.texcoordstride;
   i = 0;

   do
   {
        float *wa;
        MGLVertex *v = &context->VertexBuffer[idx[i]];
        float x = v->bx;
        float y = v->by;
        float z = v->bz;
        float w = 1.0 / v->bw;
        
        v->v.x = context->ax + x * w * context->sx;
        v->v.y = context->ay - y * w * context->sy;
        v->v.z = az + z * w * context->sz;

        wa = (float*)(context->ArrayPointer.w_buffer + idx[i] * stride);
        *wa = w;

   i++;
   } while (i < count);      
}


#ifdef __VBCC__

#define E_ToScreen(ctx,vnum){\
float wdiv = 1.f / ctx->VertexBuffer[vnum].bw;\
ctx->VertexBuffer[vnum].v.x = ctx->ax + ctx->VertexBuffer[vnum].bx * wdiv * ctx->sx;\
ctx->VertexBuffer[vnum].v.y = ctx->ay - ctx->VertexBuffer[vnum].by * wdiv * ctx->sy;\
ctx->VertexBuffer[vnum].v.z  = ctx->az + ctx->VertexBuffer[vnum].bz * wdiv * ctx->sz;\
ctx->VertexBuffer[vnum].v.w = wdiv;\
if(ctx->ZOffset_State == GL_TRUE) ctx->VertexBuffer[vnum].v.z += ctx->ZOffset;\
((float*)(ctx->ArrayPointer.w_buffer + (vnum) * ctx->ArrayPointer.texcoordstride))[0] = wdiv;}

#define V_ToScreen(ctx,vnum){\
float wdiv = 1.f / ctx->VertexBuffer[vnum].bw;\
ctx->VertexBuffer[vnum].v.x = ctx->ax + ctx->VertexBuffer[vnum].bx * wdiv * ctx->sx;\
ctx->VertexBuffer[vnum].v.y = ctx->ay - ctx->VertexBuffer[vnum].by * wdiv * ctx->sy;\
ctx->VertexBuffer[vnum].v.z  = ctx->az + ctx->VertexBuffer[vnum].bz * wdiv * ctx->sz;\
ctx->VertexBuffer[vnum].v.w = wdiv;\
if(ctx->ZOffset_State == GL_TRUE) ctx->VertexBuffer[vnum].v.z += ctx->ZOffset;}

#else

static INLINE void E_ToScreen(GLcontext context, const int vnum)
{
        float *wa;
        float w = 1.0/context->VertexBuffer[vnum].bw;

        context->VertexBuffer[vnum].v.x = context->ax + context->VertexBuffer[vnum].bx * w * context->sx;
        context->VertexBuffer[vnum].v.y = context->ay - context->VertexBuffer[vnum].by * w * context->sy;
        context->VertexBuffer[vnum].v.z = context->az + context->VertexBuffer[vnum].bz * w * context->sz;

        context->VertexBuffer[vnum].v.w = w; 

        if(context->ZOffset_State == GL_TRUE)
        context->VertexBuffer[vnum].v.z += context->ZOffset;

        wa = (float*)(context->ArrayPointer.w_buffer + vnum * context->ArrayPointer.texcoordstride);
        *wa = w;
}

static INLINE void V_ToScreen(GLcontext context, const int i)
{
        float w;
        w = 1.f / context->VertexBuffer[i].bw;

        context->VertexBuffer[i].v.x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        context->VertexBuffer[i].v.y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        context->VertexBuffer[i].v.z = context->az + context->VertexBuffer[i].bz * w * context->sz;
        context->VertexBuffer[i].v.w = w;
        if(context->ZOffset_State == GL_TRUE)
        context->VertexBuffer[i].v.z += context->ZOffset;
}

#endif



static void E_DrawQuads(GLcontext context, const int count, const UWORD *idx)
{
   int i;
   //quick hack

   for(i=0; i<count; i+=4)
   {
      E_DrawTriFan(context, 4, &idx[i]);
   }
}

static void E_DrawQuadStrip(GLcontext context, const int count, const UWORD*idx)
{
   int i;
   int end;

   //quick hack

   end = count-2;

   for(i=0; i<end; i+=2)
   {
      E_DrawTriFan(context, 4, &idx[i]);
   }
}

#ifndef __VBCC__
static void E_DrawTriFan(GLcontext context, const int count, const UWORD *idx)
#else
static void E_DrawTriFan(GLcontext context, const int count, UWORD *idx)
#endif
{
      int i;
      int size;
      ULONG and_code, or_code, guard_band;
      ULONG local_or, local_and;
      ULONG error;
      static ULONG complete[MGL_MAXVERTS];
      static ULONG visible[MGL_MAXVERTS];
      static PolyIndex polys[256];
      int first, triangle;
      int cnum, pnum, backface, prevcopy, free;

      int offs = context->ArrayPointer.transformed;
      MGLVertex *vbase = &(context->VertexBuffer[offs]);

        if(context->ArrayPointer.state & AP_CLIP_BYPASS)
        {
           size = count;
           first = 0;

           //first check if we are in guardband-mode
           //and discard/shrink offscreen primitives

           if((context->ArrayPointer.state & AP_CHECK_OUTCODES) && vbase[idx[0]].outcode)
           {
                i = size - 2;

                local_and = vbase[idx[0]].outcode & vbase[idx[i]].outcode & vbase[idx[i+1]].outcode;

                while(local_and && --i)
                {
                           local_and &= vbase[idx[i]].outcode;
                }

                if(i == 0)
                return;

                size = i+2;

                if(size > 3)
                {
                        i = 2;

                        local_and = vbase[idx[0]].outcode & vbase[idx[1]].outcode & vbase[idx[2]].outcode;

                        while (local_and && (++i < size-1))
                        {
                                local_and &= vbase[idx[i]].outcode;
                        }

                        first = i-2;
                        size -= first;
                  }
           }

           if(context->CullFace_State == GL_FALSE)
           {
                if(first)
                {
                        UWORD val = idx[first];
                        idx[first] = idx[0];

                        error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, size, (void*)&idx[first]);

                        idx[first] = val;
                }
                else
                {
                   error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, size, (void*)idx);
                }
           }
           else
           {
                float fsign;
                float area;
                float area2;
                float x0,y0;
                float x1,x2;
                float y1,y2;
                int oldfirst;

                #define x(a) (vbase[idx[a]].bx)
                #define y(a) (vbase[idx[a]].by)

                fsign = (float)(-context->CurrentCullSign);
                i = first+1;
   
                x0 = x(0);
                y0 = y(0);
     
                x1 = x(i)   - x0;
                y1 = y(i)   - y0;
                x2 = x(i+1) - x0;
                y2 = y(i+1) - y0;

                area = y2*x1 - x2*y1;
                area *= fsign;

                if(size > 3)
                {
                     backface = 0;
                     oldfirst = first;
        
                     if(area < 0.f)
                     {
                                first++;
                                area = 0.f;
                     }
        
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
                                        if(first == i)
                                                first++;
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

                     size -= backface + (first-oldfirst); //shrink
                }

                #undef x
                #undef y

                if(area >= context->MinTriArea)
                {
                   if(first)
                   {
                        UWORD val = idx[first];

                        idx[first] = idx[0];

                        error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, size, (void*)&idx[first]);

                        idx[first] = val;
                   }
                   else
                   {
                        error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, size, (void*)idx);
                   }
                }
           }

        return;
        }


        if(context->ArrayPointer.locksize == 0)
        {
                TransformIndex(context, count, idx);
        }


        or_code = 0;
        and_code = 0xff;

        for(i=0; i<count; i++)
        {
                and_code &= vbase[idx[i]].outcode;
                or_code |= vbase[idx[i]].outcode;
        }

        if(and_code)
                return;

        if(or_code == 0 || (or_code & context->ClipFlags))
        {
                guard_band = or_code;
        }
        else
        {
                float gcw;
                MGLVertex *v;

                i = 0;
                guard_band = 0;

		  if(context->ArrayPointer.state & AP_COMPILED)
                do
                {
                   v = &vbase[idx[i]];

                   if(v->cbuf_pos)
                   {
                                guard_band = 1;
                                break;
                   }

                i++;
                } while (i < count);
                else
                do
                {
                   v = &vbase[idx[i]];

                   if(v->outcode)
                   {
                        gcw = v->bw * 2.0;

                        if (-gcw > v->bx || v->bx > gcw || -gcw > v->by || v->by > gcw)
                        {
                                guard_band = 1;
                                break;
                        }
                   }

                i++;
                } while (i < count);
        }

        if (guard_band == 0)
        {
           if(context->ArrayPointer.locksize == 0)
           {
                E_ToScreenArray(context, count, idx);
           }

           if(context->CullFace_State == GL_FALSE)
           {
                error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, count, (void*)idx);
           }
           else
           {
              float fsign;
              float area;
              float area2;
              float x0,y0;
              float x1,x2;
              float y1,y2;

              #define x(a) (vbase[idx[a]].v.x)
              #define y(a) (vbase[idx[a]].v.y)

              fsign = (float)(-context->CurrentCullSign);

              size = count;
              first = 0;
        
              x0 = x(0);
              y0 = y(0);
              x1 = x(1) - x0;
              y1 = y(1) - y0;
              x2 = x(2) - x0;
              y2 = y(2) - y0;

              area = y2*x1 - x2*y1;
              area *= fsign;

              if(size > 3)
              {
                 if(area < 0.f)
                 {
                        first++;
                        area = 0.f;
                 }
        
                 backface = 0;
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
                                if(first == i)
                                        first++;
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

                 size -= backface+first; //shrink
              }

              if(area >= context->MinTriArea)
              {
                 if(first)
                 {
                        UWORD val = idx[first];

                        idx[first] = idx[0];

                        error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, size, (void*)&idx[first]);

                        idx[first] = val;
                 }
                 else
                 {
                        error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, size, (void*)idx);
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
        for(i=1,triangle=0; i<count-1; i++,triangle++)
        {
                local_and = vbase[idx[0]].outcode
                        & vbase[idx[i]].outcode
                        & vbase[idx[i+1]].outcode;

                local_or = vbase[idx[0]].outcode
                        | vbase[idx[i]].outcode
                        | vbase[idx[i+1]].outcode;

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
        for(i=1,triangle=0; i<count-1; i++,triangle++)
        {
                local_and = vbase[idx[0]].outcode
                        & vbase[idx[i]].outcode
                        & vbase[idx[i+1]].outcode;

                local_or = vbase[idx[0]].outcode
                        | vbase[idx[i]].outcode
                        | vbase[idx[i+1]].outcode;

                if (local_and == 0) // if the local and code is zero, we're not
                {
                     complete[triangle] = local_or;

                   if(local_or & MGL_CLIP_NEGW)
                   {
                        visible[triangle] = GL_TRUE;
                        backface = 0;
                   }
                   else
                   {
                        visible[triangle] = hc_DecideFrontface(context, &(vbase[idx[0]]), &(vbase[idx[i]]), &(vbase[idx[i+1]]));

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

        size = count - backface;

        Convert(context, &vbase[idx[0]], idx[0]);

        prevcopy = 0;
        free = context->VertexBufferPointer;
        pnum = 0; cnum = 0;
        triangle = 0;
        i = 1;

        do
        {
                if (visible[triangle] == GL_FALSE) // case 3
                {
                        triangle ++;
                        i        ++;
                }
                else
                {
                        if (complete[triangle]) // case 1
                        {
                           static PolyBuffer clip;

                           clip.verts[0] = offs+idx[0];
                           clip.verts[1] = offs+idx[i];
                           clip.verts[2] = offs+idx[i+1];

                           if(prevcopy != i)
                           Convert(context, &vbase[idx[i]], idx[i]);

                           Convert(context, &vbase[idx[i+1]], idx[i+1]);
                           prevcopy = i+1;

                           cnum += AE_ClipTriangle(context, &clip, &CBUF[cnum], &free, complete[triangle]);

                           triangle++; i++;
                        }
                        else
                        {   // case 2 (the difficult part)
                            int k=3;
                            PBUF[pnum].first = i;

                            triangle++; i++;

                            while (complete[triangle]==0 && visible[triangle])
                            {
                                i++; k++; triangle++;
                            }

                        PBUF[pnum].numverts = k;
                        pnum++;
                        }
                }
        } while (i<size-1);

//Project to screen and draw:

  for(i=context->VertexBufferPointer; i<free; i++)
  {
        if(context->VertexBuffer[i].outcode == 0)
        {
           V_ToScreen(context, i);
        }
  }

  if(pnum)
  {
      int vone,vzero,k;

      if(context->ArrayPointer.locksize == 0)
      {
        E_ToScreen(context, idx[0]);
          context->VertexBuffer[idx[0]].outcode = 1;

        do
        {
        pnum--;

             vone  = PBUF[pnum].first;
             vzero = vone-1;
             k = vzero + PBUF[pnum].numverts;
 
             for(i=vone; i<k; i++)
             {
                if(context->VertexBuffer[idx[i]].outcode == 0)
                {
                        context->VertexBuffer[idx[i]].outcode   = 1;
                        E_ToScreen(context, idx[i]);
                }
             }

           k = idx[vzero];
           idx[vzero] = idx[0];

           error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, PBUF[pnum].numverts, (void*)&(idx[vzero]));

           idx[vzero] = k;

        } while (pnum > 0);
      }
      else
      {
        do
        {
        pnum--;

               vzero  = PBUF[pnum].first-1;
               k = idx[vzero];
               idx[vzero] = idx[0];

               error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, PBUF[pnum].numverts, (void*)&(idx[vzero]));

               idx[vzero] = k;

        } while (pnum > 0);
      }
  }

  if(cnum)
  {
      int j;
      static W3D_TrianglesV fan;
      static W3D_Vertex *verts[16];

      fan.st_pattern = NULL;
      fan.tex = context->w3dTexBuffer[context->CurrentBinding];
      fan.v = verts;

      if(context->ArrayPointer.locksize == 0)
      {
        for(i=0; i<cnum; i++)
        {
          PolyBuffer *p = &CBUF[i];

          for (j=0; j<p->numverts; j++)
          {
                int vert = p->verts[j];
                verts[j] = &(context->VertexBuffer[vert].v);

              if(vert < context->VertexBufferPointer && context->VertexBuffer[vert].outcode == 0)
                {
                        context->VertexBuffer[vert].outcode     = 1;
                        V_ToScreen(context, vert);
                }
          }

          fan.vertexcount = p->numverts;

          error = W3D_DrawTriFanV(context->w3dContext, &fan);
        }
      }
      else
      {
        for(i=0; i<cnum; i++)
        {
          PolyBuffer *p = &CBUF[i];

            for(j=0; j<p->numverts; j++)
            {
                verts[j] = &(context->VertexBuffer[p->verts[j]].v);
            }

            fan.vertexcount = p->numverts;

          error = W3D_DrawTriFanV(context->w3dContext, &fan);
        }
      }
  }
}


static void E_DrawTriStrip(GLcontext context, const int count, const UWORD*idx)
{
      int i;
      int size;
      ULONG and_code, or_code, guard_band;
      ULONG local_or, local_and;
      ULONG error;
      static ULONG complete[MGL_MAXVERTS];
      static ULONG visible[MGL_MAXVERTS];
      static PolyIndex polys[256];
      int first;
      int cnum, pnum, backface, prevcopy, free;
      GLint CurrentCullSign;
      int offs = context->ArrayPointer.transformed;
      MGLVertex *vbase = &(context->VertexBuffer[offs]);


        if(context->ArrayPointer.state & AP_CLIP_BYPASS)
        {
           size = count;
           first = 0;

           //first check if we are in guardband-mode
           //and discard/shrink offscreen primitives

           if((context->ArrayPointer.state & AP_CHECK_OUTCODES) && (vbase[idx[0]].outcode || vbase[idx[size-1]].outcode))
           {
                i = size - 3;
                local_and = vbase[idx[i]].outcode & vbase[idx[i+1]].outcode & vbase[idx[i+2]].outcode;

                while (local_and && --i)
                {
                           local_and &= vbase[idx[i]].outcode;
                }

                if(i < 0)
                return;

                size = i+3;

                if(size > 3)
                {
                        local_and = vbase[idx[0]].outcode & vbase[idx[1]].outcode & vbase[idx[2]].outcode;

                        i = 2;

                        while (local_and && (++i < size-1))
                        {
                                local_and &= vbase[idx[i]].outcode;
                        }

                        first = i-2;
                        size -= first;
                }
           }

           if(context->CullFace_State == GL_FALSE)
           {
                error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, W3D_INDEX_UWORD, size, (void*)&idx[first]);
           }
           else
           {
              float fsign;
              float area;
              float area2;
              float a1,a2,b1,b2;
              float x1,x2;
              float y1,y2;
              int oldfirst;

              #define x(a) (vbase[idx[a]].bx)
              #define y(a) (vbase[idx[a]].by)

                if(first & 1) //uneven triangle
                {
                   fsign = (float)(context->CurrentCullSign);
                }
                else
                {
                   fsign = (float)(-context->CurrentCullSign);
                }

                if(size == 3)
                {
                        i = first+1;

                        x1 = x(i)   - x(first);
                        y1 = y(i)   - y(first);
                        x2 = x(i+1) - x(first);
                        y2 = y(i+1) - y(first);

                        area = y2*x1 - x2*y1;
                        area *= fsign;
                }
                else
                {
                        backface = 0;
                        oldfirst = first;
                        i = first+1;

                        a1 = x(i);
                        b1 = y(i);
                        a2 = x(i+1);
                        b2 = y(i+1);

                        x1 = a1 - x(first);
                        y1 = b1 - y(first);
                        x2 = a2 - x(first);
                        y2 = b2 - y(first);

                        area = y2*x1 - x2*y1;
                        area *= fsign;
 
                        if(area < 0.f)
                        {
                              first++;
                              area = 0.f;
                        }
        
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
                                  if(first == i)
                                        first++;
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

                        size -= backface + (first-oldfirst);
                }

              #undef x
              #undef y

              if(area >= context->MinTriArea)
              {
                   error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, W3D_INDEX_UWORD, size, (void*)&idx[first]);
              }
           }

        return;
        }


        if(context->ArrayPointer.locksize == 0)
        {
                TransformIndex(context, count, idx);
        }

        or_code = 0;
        and_code = 0xff;

        for(i=0; i<count; i++)
        {
                and_code &= vbase[idx[i]].outcode;
                or_code |= vbase[idx[i]].outcode;
        }

        if(and_code)
                return;

        if(or_code == 0 || (or_code & context->ClipFlags))
        {
                guard_band = or_code;
        }
        else
        {
                float gcw;
                MGLVertex *v;

                i = 0;
                guard_band = 0;

		  if(context->ArrayPointer.state & AP_COMPILED)
                do
                {
                   v = &vbase[idx[i]];

                   if(v->cbuf_pos)
                   {
                                guard_band = 1;
                                break;
                   }

                i++;
                } while (i < count);
                else
                do
                {
                v = &vbase[idx[i]];

                   if(v->outcode)
                   {
                        gcw = v->bw * 2.0;

                        if (-gcw > v->bx || v->bx > gcw || -gcw > v->by || v->by > gcw)
                        {
                                guard_band = 1;
                        }
                   }

                i++;
                } while (i < count && guard_band == 0);
        }

        if (guard_band == 0)
        {
                if(context->ArrayPointer.locksize == 0)
                {
                        E_ToScreenArray(context, count, idx);
                }

                if(context->CullFace_State == GL_FALSE)
                {
                        error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, W3D_INDEX_UWORD, count, (void*)idx);
                }
                else
                {
                   #define x(a) (vbase[idx[a]].v.x)
                   #define y(a) (vbase[idx[a]].v.y)

                   float fsign;
                   float area;
                   float area2;
                   float a1,a2,b1,b2;
                   float x1,x2;
                   float y1,y2;

                   fsign = (float)(-context->CurrentCullSign);

                   size  = count;
                   first = 0;

                   if(size == 3)
                   {
                        x1 = x(1) - x(0);
                        y1 = y(1) - y(0);
                        x2 = x(2) - x(0);
                        y2 = y(2) - y(0);

                        area = y2*x1 - x2*y1;
                        area *= fsign;
                   }
                   else
                   {
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
                                first++;
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
                                  if(first == i)
                                        first++;
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

                        size -= first + backface;
                   }

                   if(area >= context->MinTriArea)
                   {
                         error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, W3D_INDEX_UWORD, size, (void*)&idx[first]); 
                   }

                   #undef x
                   #undef y
                }
        return;
        }


   backface = 0;

   if(context->CullFace_State == GL_FALSE)
   {
      for(i=0; i<count-2; i++)
      {
                local_and = vbase[idx[i]].outcode
                        & vbase[idx[i+1]].outcode
                        & vbase[idx[i+2]].outcode;

                local_or = vbase[idx[i]].outcode
                        | vbase[idx[i+1]].outcode
                        | vbase[idx[i+2]].outcode;

                if (local_and == 0) // if the local and code is zero, we're not
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
      CurrentCullSign = context->CurrentCullSign;

      for(i=0; i<count-2; i++)
      {
                local_and = vbase[idx[i]].outcode
                        & vbase[idx[i+1]].outcode
                        & vbase[idx[i+2]].outcode;

                local_or = vbase[idx[i]].outcode
                        | vbase[idx[i+1]].outcode
                        | vbase[idx[i+2]].outcode;

                if (local_and == 0) // if the local and code is zero, we're not
                {
                        complete[i] = local_or;

                        if(local_or & MGL_CLIP_NEGW)
                        {
                        visible[i] = GL_TRUE;    
                        backface = 0;
                        }
                        else
                        {
                                visible[i] = hc_DecideFrontface(context, &vbase[idx[i]], &vbase[idx[i+1]], &vbase[idx[i+2]]);

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

        context->CurrentCullSign = -context->CurrentCullSign;
        }

      context->CurrentCullSign = CurrentCullSign;
   }

   if(backface == count-2)
   return;

   visible[count-2] = GL_FALSE; //reduce control variable checking in next loop

        size = count - backface;

        free = context->VertexBufferPointer;
        prevcopy = -1;
        pnum = 0; cnum = 0;
        i = 0;

        do
        {
                if (visible[i] == GL_FALSE) // case 3
                {
                        i++;
                }
                else
                {
                        if (complete[i]) // case 1
                        {
                            static PolyBuffer clip;

                            clip.verts[0] = offs+idx[i];
                            clip.verts[1] = offs+idx[i+1];
                            clip.verts[2] = offs+idx[i+2];

                            if(prevcopy == i+1)
                            {
                                Convert(context, &vbase[idx[i+2]], idx[i+2]);
                            }
                            else if(prevcopy == i)
                            {
                                Convert(context, &vbase[idx[i+1]], idx[i+1]);
                                Convert(context, &vbase[idx[i+2]], idx[i+2]);
                            }
                            else
                            {
                                Convert(context, &vbase[idx[i]], idx[i]);
                                Convert(context, &vbase[idx[i+1]], idx[i+1]);
                                Convert(context, &vbase[idx[i+2]], idx[i+2]);
                            }

                            prevcopy = i+2;

                            cnum += AE_ClipTriangle(context, &clip, &CBUF[cnum], &free, complete[i]);

                            i++;
                        }
                        else
                        {   // case 2 (the difficult part)
                          int k = 3;
                          PBUF[pnum].first = i;

                          i++;

                          while (complete[i]==0 && visible[i])
                          {
                                i++; k++;
                          }

                          PBUF[pnum].numverts = k;
                          pnum++;
                        }
                }
        } while (i < size-2);


//Project to screen and draw:

  for(i=context->VertexBufferPointer; i<free; i++)
  {
        if(context->VertexBuffer[i].outcode == 0)
        {
           V_ToScreen(context, i);
        }
  }


  if(pnum)
  {
      int vzero;

        if(context->ArrayPointer.locksize == 0)
        {
        do
        {
           pnum--;
           vzero = PBUF[pnum].first;

             for(i=vzero; i<PBUF[pnum].numverts+vzero; i++)
             {
                        if(context->VertexBuffer[idx[i]].outcode == 0)
                        {
                                context->VertexBuffer[idx[i]].outcode   = 1;
                                E_ToScreen(context, idx[i]);
                        }
             }

           error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, W3D_INDEX_UWORD, PBUF[pnum].numverts, (void*)&(idx[vzero]));

        } while (pnum > 0);
        }
        else
        {
        do
        {
           pnum--;
           vzero = PBUF[pnum].first;

           error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRISTRIP, W3D_INDEX_UWORD, PBUF[pnum].numverts, (void*)&(idx[vzero]));

        } while (pnum > 0);
        }
  }

  if(cnum)
  {
      int j;
        static W3D_TrianglesV fan;
        static W3D_Vertex *verts[16];

        fan.st_pattern = NULL;
        fan.tex = context->w3dTexBuffer[context->CurrentBinding];
        fan.v = verts;

      if(context->ArrayPointer.locksize == 0)
      {
        for(i=0; i<cnum; i++)
        {
          PolyBuffer *p = &CBUF[i];

          for (j=0; j<p->numverts; j++)
          {
                int vert = p->verts[j];
                verts[j] = &(context->VertexBuffer[vert].v);

              if(vert < context->VertexBufferPointer && context->VertexBuffer[vert].outcode == 0)
                {
                        context->VertexBuffer[vert].outcode     = 1;
                        V_ToScreen(context, vert);
                }
          }

            fan.vertexcount = p->numverts;
          error = W3D_DrawTriFanV(context->w3dContext, &fan);
        }
      }
      else
      {
        for(i=0; i<cnum; i++)
        {
          PolyBuffer *p = &CBUF[i];

            for(j=0; j<p->numverts; j++)
            {
                verts[j] = &(context->VertexBuffer[p->verts[j]].v);
            }

            fan.vertexcount = p->numverts;
          error = W3D_DrawTriFanV(context->w3dContext, &fan);
        }
      }
  }
}


//added 27-05-02

static void E_DrawTriangles_Locked(GLcontext context, const int count, const UWORD*idx)
{
      int i;
      ULONG local_and, local_or;
      ULONG error;
      static UWORD trichain[MGL_MAXVERTS*4];
      GLuint visible;
      int cnum, free, chainverts;
      int offs = context->ArrayPointer.transformed;
      MGLVertex *vbase = &(context->VertexBuffer[offs]);

        if(context->ArrayPointer.state & AP_CLIP_BYPASS)
        {
                chainverts = 0;

                if(!(context->ArrayPointer.state & AP_CHECK_OUTCODES))
                {
                   if(context->CullFace_State == GL_FALSE)
                   {
                        error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, W3D_INDEX_UWORD, count, (void *)idx);
                   }
                   else
                   {
                        for(i=0; i<count; i+=3)
                        {
                           if(E_CheckTriLocked(context, &vbase[idx[i]], &vbase[idx[i+1]], &vbase[idx[i+2]]) == GL_TRUE)
                           {
                                trichain[chainverts]   = idx[i];
                                trichain[chainverts+1] = idx[i+1];
                                trichain[chainverts+2] = idx[i+2];
                                chainverts+=3; 
                           }
                        }
                   }
                }
                else
                {
                   if(context->CullFace_State == GL_FALSE)
                   {
                        for(i=0; i<count; i+=3)
                        {
                           local_and = vbase[idx[i]].outcode & vbase[idx[i+1]].outcode & vbase[idx[i+2]].outcode;

                           if(local_and == 0)
                           {
                                trichain[chainverts]   = idx[i];
                                trichain[chainverts+1] = idx[i+1];
                                trichain[chainverts+2] = idx[i+2];
                                chainverts+=3;
                           }
                        }
                   }
                   else
                   {            
                        for(i=0; i<count; i+=3)
                        {
                           local_and = vbase[idx[i]].outcode & vbase[idx[i+1]].outcode & vbase[idx[i+2]].outcode;

                           if(local_and == 0)
                           {
                              if( E_CheckTriLocked(context, &vbase[idx[i]], &vbase[idx[i+1]], &vbase[idx[i+2]]) == GL_TRUE)
                              {
                                trichain[chainverts]   = idx[i];
                                trichain[chainverts+1] = idx[i+1];
                                trichain[chainverts+2] = idx[i+2];
                                chainverts+=3;
                              }
                           }
                        }
                   }
                }

                if(chainverts)
                {
                        error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, W3D_INDEX_UWORD, chainverts, (void *)trichain);
                }
        return;
        }


        free = context->VertexBufferPointer;
        chainverts = 0;
        cnum = 0;

        for(i=0; i<count; i+=3)
        {
           local_and = vbase[idx[i]].outcode & vbase[idx[i+1]].outcode & vbase[idx[i+2]].outcode;

           local_or = vbase[idx[i]].outcode | vbase[idx[i+1]].outcode | vbase[idx[i+2]].outcode;

           if(local_and)
           continue;

           if (local_or == 0)
           {
                if(context->CullFace_State == GL_FALSE)
                {
                   trichain[chainverts]   = idx[i];
                   trichain[chainverts+1] = idx[i+1];
                   trichain[chainverts+2] = idx[i+2];
                   chainverts += 3;
                }
                else
                {
                   if(E_CheckTri(context, &vbase[idx[i]], &vbase[idx[i+1]], &vbase[idx[i+2]]) == GL_TRUE)
                   {
                        trichain[chainverts]   = idx[i];
                        trichain[chainverts+1] = idx[i+1];
                        trichain[chainverts+2] = idx[i+2];
                        chainverts += 3;
                   }
                }
           }
           else
           {
                if(context->CullFace_State == GL_FALSE || (local_or & MGL_CLIP_NEGW))
                {
                        visible = GL_TRUE;
                }
                else
                {
                        visible = hc_DecideFrontface(context, &(vbase[idx[i]]), &(vbase[idx[i+1]]), &(vbase[idx[i+2]]));
                }

                if(visible)
                {
                   static PolyBuffer clip;

                   clip.verts[0] = offs+idx[i];
                   clip.verts[1] = offs+idx[i+1];
                   clip.verts[2] = offs+idx[i+2];

                   Convert(context, &vbase[idx[i]], idx[i]);
                   Convert(context, &vbase[idx[i+1]], idx[i+1]);
                   Convert(context, &vbase[idx[i+2]], idx[i+2]);

                   cnum += AE_ClipTriangle(context, &clip, &CBUF[cnum], &free, local_or);
                }
            }
        }

        if(chainverts)
        {
                error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, W3D_INDEX_UWORD, chainverts, (void*)&trichain[0]);
        }


      if (cnum)
      {
        int j;
        PolyBuffer *p;
        static W3D_TrianglesV fan;
        static W3D_Vertex *verts[16];

        fan.st_pattern = NULL;
        fan.tex = context->w3dTexBuffer[context->CurrentBinding];
        fan.v = verts;

           for(i=context->VertexBufferPointer; i<free; i++)
           {
                if(context->VertexBuffer[i].outcode == 0)
                {
                   V_ToScreen(context, i);
                }
           } 

           i = 0;
           do
           {
                p = &CBUF[i];

                  for(j=0; j<p->numverts; j++)
                  {
                        verts[j] = &(context->VertexBuffer[p->verts[j]].v);
                  }

                  fan.vertexcount = p->numverts;
                error = W3D_DrawTriFanV(context->w3dContext, &fan);

           i++;
           } while (i < cnum);
      }
}


static void E_DrawTriangles(GLcontext context, const int count, const UWORD*idx)
{
      int i;
      ULONG local_and, local_or;
      ULONG error;
      static UWORD trichain[MGL_MAXVERTS*4]; //should be enough
      static GLuint visible;
      int cnum, free, chainverts;

        if(context->ArrayPointer.locksize > 0)
        {
                E_DrawTriangles_Locked(context, count, idx);
                return;
        }

        TransformIndex(context, count, idx);

        free = context->VertexBufferPointer;
        chainverts = 0;
        cnum = 0;

        for(i=0; i<count; i+=3)
        {
           local_and = context->VertexBuffer[idx[i]].outcode & context->VertexBuffer[idx[i+1]].outcode & context->VertexBuffer[idx[i+2]].outcode;

           local_or = context->VertexBuffer[idx[i]].outcode | context->VertexBuffer[idx[i+1]].outcode | context->VertexBuffer[idx[i+2]].outcode;

           if(local_and)
           continue;

           if (local_or == 0)
           {
                E_ToScreenArray(context, 3, &idx[i]);

                if(context->CullFace_State == GL_FALSE)
                {
                   trichain[chainverts] = idx[i];
                   trichain[chainverts+1] = idx[i+1];
                   trichain[chainverts+2] = idx[i+2];
                   chainverts += 3;
                }
                else
                {
                   if( E_CheckTri(context, &context->VertexBuffer[idx[i]], &context->VertexBuffer[idx[i+1]], &context->VertexBuffer[idx[i+2]]) == GL_TRUE)
                   {
                        trichain[chainverts] = idx[i];
                        trichain[chainverts+1] = idx[i+1];
                        trichain[chainverts+2] = idx[i+2];
                        chainverts += 3;
                   }
                }
           }            
           else
           {
                if(context->CullFace_State == GL_FALSE || (local_or & MGL_CLIP_NEGW))
                {
                   visible = GL_TRUE;
                }
                else
                {
                   visible = hc_DecideFrontface(context, &(context->VertexBuffer[idx[i]]), &(context->VertexBuffer[idx[i+1]]), &(context->VertexBuffer[idx[i+2]]));
                }

                if(visible)
                {
                   static PolyBuffer clip;

                   clip.verts[0] = idx[i];
                   clip.verts[1] = idx[i+1];
                   clip.verts[2] = idx[i+2];

                   Convert(context, &context->VertexBuffer[idx[i]], idx[i]);
                   Convert(context, &context->VertexBuffer[idx[i+1]], idx[i+1]);
                   Convert(context, &context->VertexBuffer[idx[i+2]], idx[i+2]);

                   cnum += AE_ClipTriangle(context, &clip, &CBUF[cnum], &free, local_or);
                }
            }
        }


      if(chainverts)
      {
                error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIANGLES, W3D_INDEX_UWORD, chainverts, (void*)&trichain[0]);
      }

      if (cnum)
      {
        int j;
        PolyBuffer *p;
        static W3D_TrianglesV fan;
        static W3D_Vertex *verts[16];

        fan.st_pattern = NULL;
        fan.tex = context->w3dTexBuffer[context->CurrentBinding];
        fan.v = verts;

           i = 0;
           do
           {
                   p = &CBUF[i];

                   for(j=0; j<p->numverts; j++)
                   {
                        int vert = p->verts[j];
                          verts[j] = &(context->VertexBuffer[vert].v);

                        if(vert < context->VertexBufferPointer)
                          {
                                if(context->VertexBuffer[vert].outcode == 0)
                                {
                                   context->VertexBuffer[vert].outcode = 1;
                                 V_ToScreen(context, vert);
                                }
                        }
                          else
                          {
                                 V_ToScreen(context, vert);
                          }
                   }

                fan.vertexcount = p->numverts;

                error = W3D_DrawTriFanV(context->w3dContext, &fan);

           i++;
           } while (i < cnum);
      }
}

static void E_DrawFlatFan(GLcontext context, const int count, const UWORD*idx)
{
      int i;
      int vnum;
      ULONG error;
        MGLVertex *v;
      float *W;
      float *V;
      int Vstride;
      int offs;

        offs    = context->ArrayPointer.transformed;
      Vstride = context->ArrayPointer.vertexstride;

      i = 0;
      do
      {
        vnum = idx[i];
          v = &context->VertexBuffer[offs+vnum];
        V = (float*)(context->ArrayPointer.verts + vnum * Vstride);

         v->v.x = V[0];
         v->v.y = V[1];
         v->v.z = V[2];

         W = (float*)(context->ArrayPointer.w_buffer + vnum * context->ArrayPointer.texcoordstride);
         *W = 1.0;

        i++;
      } while (i < count);

      error = W3D_DrawElements(context->w3dContext, W3D_PRIMITIVE_TRIFAN, W3D_INDEX_UWORD, count, (void *)idx);
}

//Range guardband-check added 18-05-02 (surgeon)

static INLINE ULONG TestRangeGuardBand(GLcontext context, const GLuint first, const GLsizei count)
{
        int i; 
        MGLVertex *v;
        ULONG ret;

        ret = 0;

        v = &context->VertexBuffer[first+context->ArrayPointer.transformed];
        i = count;

        do
        {
           if(v->outcode)
           {
                float x  = v->bx;
                float y  = v->by;
                float gw = v->bw * 2.f;

                if (x > gw || y > gw || -gw > x || -gw > y)
                {
                        ret = 1;
                        break;
                }
           }

        v++;
        } while (--i);

        return ret;
}

static INLINE ULONG EncodeRangeGuardBand(GLcontext context, const GLuint first, const GLsizei count)
{
        int i; 
        MGLVertex *v;
        ULONG mustclip;
        ULONG ret;

        v = &context->VertexBuffer[first+context->ArrayPointer.transformed];
        mustclip = context->ClipFlags;
        ret = 0;

        i = count;
        do
        {
           ULONG outcode = v->outcode;

           if(outcode)
           {
             if(outcode & mustclip)
             {
                v->cbuf_pos = 1;
                ret = 1;
             }
             else
             {
                float x  = v->bx;
                float y  = v->by;
                float gw = v->bw * 2.f;

                if (x > gw || y > gw || -gw > x || -gw > y)
                {
                   v->cbuf_pos = 1;
                   ret = 1;
                }
                else
                {
                   v->cbuf_pos = 0;
                }
             }
           }
           else
           {
                v->cbuf_pos = 0;
           }

        v++;
        } while (--i);

        return ret;
}


//called at lock initiation:

static INLINE void PreDrawLock(GLcontext context)
{
   if(!(context->ClientState & GLCS_TEXTURE))
   {
        context->ArrayPointer.w_buffer = (GLubyte *)context->WBuffer;
   }

   if (context->FogDirty && context->Fog_State)
   {
        fog_Set(context);
        context->FogDirty = GL_FALSE;
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

//called at lock termination:
static INLINE void PostDrawUnlock(GLcontext context)
{
   if(!(context->ClientState & GLCS_TEXTURE))
   {
        context->ArrayPointer.w_buffer = context->ArrayPointer.texcoords + context->ArrayPointer.w_off;
   }

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


void GLLockArrays(GLcontext context, GLuint first, GLsizei count)
{
        GLbitfield check_outcodes;
        ULONG offscreen;


#ifndef GL_NOERRORCHECK
        if(!(context->ClientState & GLCS_VERTEX))
        {
                  GLFlagError(context, 1, GL_INVALID_OPERATION);        
                return; //added 28-JUL-02
        }

          if(context->VertexArrayPipeline == GL_FALSE)
          {
                  GLFlagError(context, 1, GL_INVALID_OPERATION);        
                return; //added 01-SEP-02
          }
#endif

        context->ArrayPointer.lockfirst   = first;
        context->ArrayPointer.locksize    = count;
        context->ArrayPointer.transformed = context->VertexBufferSize >> 2;     // offset for preprocessed data allows for glArrayElement

        PreDrawLock( context );

        //pre-transform and code all verts within range:

        check_outcodes = 0;

        offscreen = TransformRange(context, first, count);

        if(offscreen && (context->ClipFlags != NOGUARD))
        {
                check_outcodes = AP_CHECK_OUTCODES;
                offscreen = EncodeRangeGuardBand(context, first, count);
        }

        //project verts:

        if (offscreen)
        {
             context->ArrayPointer.state |= AP_COMPILED;

             ProjectRangeByOutcode(context, first, count);
  
        context->w3dContext->VPMode = W3D_VERTEX_F_F_D;
        context->w3dContext->VertexPointer = (void *)&(context->VertexBuffer[context->ArrayPointer.transformed].v.x);
        }
        else //all vertices on screen or within guardband
        {
                context->ArrayPointer.state |= (AP_COMPILED|AP_CLIP_BYPASS|check_outcodes);

                ProjectRange(context, first, count);

        context->w3dContext->VertexPointer = (void *)&(context->VertexBuffer[context->ArrayPointer.transformed].bx);
        }
}

void GLUnlockArrays(GLcontext context)
{
        #ifndef GL_NOERRORCHECK
        if(context->ArrayPointer.locksize == 0)
        {
                //range was never locked...
                GLFlagError(context, 1, GL_INVALID_OPERATION);
                return;
        }
        #endif

        context->ArrayPointer.transformed = 0;
        context->ArrayPointer.lockfirst = 0;
        context->ArrayPointer.locksize = 0;

        if(!(context->ArrayPointer.state & AP_CLIP_BYPASS))
        {
           context->w3dContext->VPMode = W3D_VERTEX_F_F_F;
        }

        context->w3dContext->VertexPointer = (void *)&(context->VertexBuffer[0].bx);

        context->ArrayPointer.state &=~(AP_COMPILED|AP_CLIP_BYPASS|AP_CHECK_OUTCODES);

        PostDrawUnlock(context);
}


//called during lock:
static INLINE void PreDrawIsLocked(GLcontext context)
{
   if (context->ShadeModel == GL_FLAT && context->UpdateCurrentColor == GL_TRUE)
   {
        context->UpdateCurrentColor = GL_FALSE;

        W3D_SetCurrentColor(context->w3dContext, &context->CurrentColor);
   }
}

//called during lock:
static INLINE void PostDrawIsLocked(GLcontext context)
{
   context->VertexBufferPointer = 0;
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
static void E_DrawNULL(GLcontext context, const int count, const UWORD*idx)
{
        GLFlagError(context, 1, GL_INVALID_ENUM);
}
#endif


void GLDrawElements(GLcontext context, GLenum mode, GLsizei count, GLenum type, const GLvoid *indices)
{
   int i;
   UBYTE *ub;
   ULONG *ul;
   UWORD *idx;
   static EDrawfn E_Draw;

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

   if(context->VertexArrayPipeline == GL_TRUE)
   switch(type)
   {
      case GL_UNSIGNED_SHORT:
                idx = (UWORD*)indices;

      break;

      case GL_UNSIGNED_BYTE:

                ub = (UBYTE *)indices;
                idx = context->ElementIndex;

                idx[0] = ub[0];
                idx[1] = ub[1];
                idx[2] = ub[2];

                i = 3;

                while (i < count)
                {
                        idx[i] = ub[i];
                i++;
                }
      break;

#ifdef GL_NOERRORCHECK
      default:
#endif
      case GL_UNSIGNED_INT:

                ul = (ULONG *)indices;
                idx = context->ElementIndex;

                idx[0] = ul[0];
                idx[1] = ul[1];
                idx[2] = ul[2];

                i = 3;

                while (i < count)
                {
                        idx[i] = ul[i];
                i++;
                }

      break;

#ifndef GL_NOERRORCHECK
      default:
                GLFlagError(context, 1, GL_INVALID_ENUM);
                return;
#endif
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

   if(context->VertexArrayPipeline != GL_FALSE)
   {
        switch(mode)
        {
                case MGL_FLATFAN:
                E_Draw = (EDrawfn)E_DrawFlatFan;
                break;

                case GL_QUADS:
                E_Draw = (EDrawfn)E_DrawQuads;
                break;

                case GL_QUAD_STRIP:
                E_Draw = (EDrawfn)E_DrawQuadStrip;
                break;

                case GL_TRIANGLES:
                E_Draw = (EDrawfn)E_DrawTriangles;
                break;

                case GL_TRIANGLE_STRIP:
                E_Draw = (EDrawfn)E_DrawTriStrip;
                break;

#ifdef GL_NOERRORCHECK
                default:
#else
                case GL_POLYGON:
                case GL_TRIANGLE_FAN:
#endif
                E_Draw = (EDrawfn)E_DrawTriFan;
                break;

#ifndef GL_NOERRORCHECK
                default:
                E_Draw = (EDrawfn)E_DrawNULL;

#endif
        }

        if(context->ArrayPointer.locksize == 0)
        {
           context->VertexBufferPointer = context->VertexBufferSize >> 1;   //avoid index-scan. Is this margin a safe assumption ?

           context->w3dContext->VPMode = W3D_VERTEX_F_F_D;
           context->w3dContext->VertexPointer = (void *)&(context->VertexBuffer[0].v.x);

        }
        else
        {
           context->VertexBufferPointer = 0;

           // transformed data starts from offset
           // context->ArrayPointer.transformed
        }
   }

   if(context->ArrayPointer.locksize > 0)
   {
      PreDrawIsLocked(context);
   }
   else
   {
      PreDraw(context);
   }


   if(context->VertexArrayPipeline == GL_FALSE)
   {
	ULONG error;
   	error = W3D_DrawElements(context->w3dContext, mode, type, count, (void*)indices);
   }
   else
   {
   	E_Draw(context, count, idx);
   }

   if(context->ArrayPointer.locksize > 0)
   {
      PostDrawIsLocked(context);
   }
   else
   {
      PostDraw(context);
   }

   if(context->VertexArrayPipeline != GL_FALSE && context->ArrayPointer.locksize == 0)
   {
           context->w3dContext->VPMode = W3D_VERTEX_F_F_F;
           context->w3dContext->VertexPointer = (void *)&(context->VertexBuffer[0].bx);
   }

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

