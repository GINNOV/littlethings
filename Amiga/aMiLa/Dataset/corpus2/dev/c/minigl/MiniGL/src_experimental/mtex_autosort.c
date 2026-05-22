
//For chaining and buffering multitexture-polys:

typedef struct MtexPolyIdx_s
{
        GLint   polyverts;
#ifndef AUTO_TEXSORT
        GLint   binding;
#else
        GLint   pos;    // position in ptex_buffer
#endif

} MtexPolyIdx;

#ifdef AUTO_TEXSORT

typedef struct MGLMtexChain_s
{
        MtexPolyIdx *mtexpoly[256];
        GLuint mtexpolycount;
        
} MGLMtexChain;

static MGLMtexChain texchain[256];
static GLuint new_mtexnum[256];
static GLuint num_mtextures;

#endif


#define MTEX_INDEXSIZE 1024
#define MTEX_VERTEXBUFFERSIZE 4096

static MtexPolyIdx pidx[MTEX_INDEXSIZE];

static int polypointer = 0;

static W3D_Vertex *mtex_pbuffer = NULL;

GLboolean AllocMtex()
{
        int i;

        if(mtex_pbuffer == NULL)
        {
        mtex_pbuffer = (W3D_Vertex*) malloc(sizeof(W3D_Vertex)*MTEX_VERTEXBUFFERSIZE);
        }

        if(!mtex_pbuffer)
                return GL_FALSE;
        else
        {
                return GL_TRUE;
        }
}

void FreeMtex(void)
{
        if(mtex_pbuffer) free(mtex_pbuffer);
}

static INLINE void v_MtexToScreen_Flat(GLcontext context, int i, int bufpointer)
{
        float w;

        w = 1.0 / context->VertexBuffer[i].bw;

        mtex_pbuffer[bufpointer].x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        mtex_pbuffer[bufpointer].y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        mtex_pbuffer[bufpointer].z = context->az + context->VertexBuffer[i].bz * w * context->sz;

        if (context->ZOffset_State == GL_TRUE)
                mtex_pbuffer[bufpointer].z += (W3D_Float)context->ZOffset;

        mtex_pbuffer[bufpointer].w = w;

        mtex_pbuffer[bufpointer].u = context->VertexBuffer[i].v.u;
        mtex_pbuffer[bufpointer].v = context->VertexBuffer[i].v.v;

}

static INLINE void v_MtexToScreen_Smooth(GLcontext context, int i, int bufpointer)
{
        float w;

        w = 1.0 / context->VertexBuffer[i].bw;

        mtex_pbuffer[bufpointer].x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        mtex_pbuffer[bufpointer].y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        mtex_pbuffer[bufpointer].z = context->az + context->VertexBuffer[i].bz * w * context->sz;

        if (context->ZOffset_State == GL_TRUE)
                mtex_pbuffer[bufpointer].z += (W3D_Float)context->ZOffset;

        mtex_pbuffer[bufpointer].w = w;

        mtex_pbuffer[bufpointer].u = context->VertexBuffer[i].v.u;
        mtex_pbuffer[bufpointer].v = context->VertexBuffer[i].v.v;

        mtex_pbuffer[bufpointer].color.r = context->VertexBuffer[i].v.color.r;
        mtex_pbuffer[bufpointer].color.g = context->VertexBuffer[i].v.color.g;
        mtex_pbuffer[bufpointer].color.b = context->VertexBuffer[i].v.color.b;
        mtex_pbuffer[bufpointer].color.a = context->VertexBuffer[i].v.color.a;
}

static void ProjectMtex_Flat(GLcontext context, int numverts, int bufstart)
{
        int i;
        int bufpointer;

        i = 0;
        bufpointer = bufstart;

        do
        {
        float w = 1.0 / context->VertexBuffer[i].bw;

        mtex_pbuffer[bufpointer].x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        mtex_pbuffer[bufpointer].y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        mtex_pbuffer[bufpointer].z = context->az + context->VertexBuffer[i].bz * w * context->sz;

        if (context->ZOffset_State == GL_TRUE)
                mtex_pbuffer[bufpointer].z += (W3D_Float)context->ZOffset;

        mtex_pbuffer[bufpointer].w = w;

        mtex_pbuffer[bufpointer].u = context->VertexBuffer[i].v.u;
        mtex_pbuffer[bufpointer].v = context->VertexBuffer[i].v.v;

        i++; bufpointer++;
        } while (i < numverts);

}

static void ProjectMtex_Smooth(GLcontext context, int numverts, int bufstart)
{
        int i;
        int bufpointer;

        i = 0;
        bufpointer = bufstart;

        do
        {
        float w = 1.0 / context->VertexBuffer[i].bw;

        mtex_pbuffer[bufpointer].x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        mtex_pbuffer[bufpointer].y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        mtex_pbuffer[bufpointer].z = context->az + context->VertexBuffer[i].bz * w * context->sz;

        if (context->ZOffset_State == GL_TRUE)
                mtex_pbuffer[bufpointer].z += (W3D_Float)context->ZOffset;

        mtex_pbuffer[bufpointer].w = w;

        mtex_pbuffer[bufpointer].u = context->VertexBuffer[i].v.u;
        mtex_pbuffer[bufpointer].v = context->VertexBuffer[i].v.v;

        mtex_pbuffer[bufpointer].color.r = context->VertexBuffer[i].v.color.r;
        mtex_pbuffer[bufpointer].color.g = context->VertexBuffer[i].v.color.g;
        mtex_pbuffer[bufpointer].color.b = context->VertexBuffer[i].v.color.b;
        mtex_pbuffer[bufpointer].color.a = context->VertexBuffer[i].v.color.a;

        i++; bufpointer++;
        } while (i < numverts);

}


#ifdef FIXPOINT_POLYGONS

extern void hc_ClipFixPolyFF(GLcontext context, MGLPolygon *poly, ULONG or_codes);

ULONG TransformFixPoly (GLcontext context)
{
   int i;
   static int m[16];
   int tx,ty,tz,tw;
   int x,y,z;
   MGLVertex *v;
   ULONG local_outcode;
   ULONG and_code, or_code;

   #define a(x) (context->CombinedMatrix.v[OF_##x])
   #define b(x) (m[OF_##x])
   #define FIXCLIP_EPS ((int)((1e-7)*32768.f))

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

   and_code = 0xFF;
   or_code = 0;

   v = &(context->VertexBuffer[0]);

   i = context->VertexBufferPointer;
   do
   {
        x = v->xi;
        y = v->yi;
        z = v->zi;

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

        if (tw < FIXCLIP_EPS )
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

   v++;

   } while (--i);

   #undef a
   #undef b
   #undef FIXCLIP_EPS   

   if (and_code)
        return 0xFFFFFFFF;
   else
        return or_code;
}

#define v_FixToScreen(ctx,vnum){\
static float wdiv;\
wdiv = 1.0 / ctx->VertexBuffer[vnum].bw; \
ctx->VertexBuffer[vnum].v.x = ctx->ax + ctx->VertexBuffer[vnum].bx * wdiv * ctx->sx; \
ctx->VertexBuffer[vnum].v.y = ctx->ay - ctx->VertexBuffer[vnum].by * wdiv * ctx->sy; \
ctx->VertexBuffer[vnum].v.z = ctx->az + ctx->VertexBuffer[vnum].bz * wdiv * ctx->sz; \
if (ctx->ZOffset_State == GL_TRUE) ctx->VertexBuffer[vnum].v.z += (W3D_Float)ctx->ZOffset; \
ctx->VertexBuffer[vnum].v.w = 32768.f * wdiv;}


void ProjectFixPoly(GLcontext context)
{
   int i;
   MGLVertex *v;


        i = context->VertexBufferPointer;
        v = &context->VertexBuffer[0];

   if(context->ZOffset_State == GL_TRUE)
   {
   float x,y,z,w;

      do
      {
           x = v->bx;
           y = v->by;
           z = v->bz;
           w = 1.0 / v->bw;
        
           v->v.x = context->ax + x * w * context->sx;
           v->v.y = context->ay - y * w * context->sy;
           v->v.z = (W3D_Float)context->ZOffset + context->az + z * w * context->sz;
             v->v.w = 32768.f * w;

      v++;
      } while (--i);
   }
   else
   {
   float x,y,z,w;

      do
      {
           x = v->bx;
           y = v->by;
           z = v->bz;
           w = 1.0 / v->bw;
        
           v->v.x = context->ax + x * w * context->sx;
           v->v.y = context->ay - y * w * context->sy;
           v->v.z = context->az + z * w * context->sz;
             v->v.w = 32768.f * w;

      v++;
      } while (--i);    
   }
}

static void ProjectFixMtex_Flat(GLcontext context, MGLPolygon *p, int bufstart)
{
        int i;
        int bufpointer;

        i = 0;
        bufpointer = bufstart;

        do
        {
        float w = 1.0 / context->VertexBuffer[i].bw;

        mtex_pbuffer[bufpointer].x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        mtex_pbuffer[bufpointer].y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        mtex_pbuffer[bufpointer].z = context->az + context->VertexBuffer[i].bz * w * context->sz;

        if (context->ZOffset_State == GL_TRUE)
                mtex_pbuffer[bufpointer].z += (W3D_Float)context->ZOffset;

        mtex_pbuffer[bufpointer].w = 32768.f * w;

        mtex_pbuffer[bufpointer].u = context->VertexBuffer[i].v.u;
        mtex_pbuffer[bufpointer].v = context->VertexBuffer[i].v.v;
        p->verts[i] = i;

        i++; bufpointer++;
        } while (i < p->numverts);

}

static void ProjectFixMtex_Smooth(GLcontext context, MGLPolygon *p, int bufstart)
{
        int i;
        int bufpointer;

        i = 0;
        bufpointer = bufstart;

        do
        {
        float w = 1.0 / context->VertexBuffer[i].bw;

        mtex_pbuffer[bufpointer].x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        mtex_pbuffer[bufpointer].y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        mtex_pbuffer[bufpointer].z = context->az + context->VertexBuffer[i].bz * w * context->sz;

        if (context->ZOffset_State == GL_TRUE)
                mtex_pbuffer[bufpointer].z += (W3D_Float)context->ZOffset;

        mtex_pbuffer[bufpointer].w = 32768.f * w;

        mtex_pbuffer[bufpointer].u = context->VertexBuffer[i].v.u;
        mtex_pbuffer[bufpointer].v = context->VertexBuffer[i].v.v;

        mtex_pbuffer[bufpointer].color.r = context->VertexBuffer[i].v.color.r;
        mtex_pbuffer[bufpointer].color.g = context->VertexBuffer[i].v.color.g;
        mtex_pbuffer[bufpointer].color.b = context->VertexBuffer[i].v.color.b;
        mtex_pbuffer[bufpointer].color.a = context->VertexBuffer[i].v.color.a;

        p->verts[i] = i;
        i++; bufpointer++;
        } while (i < p->numverts);

}

static void v_FixMtexToScreen_Flat(GLcontext context, int i, int bufpointer)
{
        float w = 1.0 / context->VertexBuffer[i].bw;

        mtex_pbuffer[bufpointer].x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        mtex_pbuffer[bufpointer].y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        mtex_pbuffer[bufpointer].z = context->az + context->VertexBuffer[i].bz * w * context->sz;

        if (context->ZOffset_State == GL_TRUE)
                mtex_pbuffer[bufpointer].z += (W3D_Float)context->ZOffset;

        mtex_pbuffer[bufpointer].w = 32768.f * w;

        mtex_pbuffer[bufpointer].u = context->VertexBuffer[i].v.u;
        mtex_pbuffer[bufpointer].v = context->VertexBuffer[i].v.v;
}

static void v_FixMtexToScreen_Smooth(GLcontext context, int i, int bufpointer)
{
        float w = 1.0 / context->VertexBuffer[i].bw;

        mtex_pbuffer[bufpointer].x = context->ax + context->VertexBuffer[i].bx * w * context->sx;
        mtex_pbuffer[bufpointer].y = context->ay - context->VertexBuffer[i].by * w * context->sy;
        mtex_pbuffer[bufpointer].z = context->az + context->VertexBuffer[i].bz * w * context->sz;

        if (context->ZOffset_State == GL_TRUE)
                mtex_pbuffer[bufpointer].z += (W3D_Float)context->ZOffset;

        mtex_pbuffer[bufpointer].w = 32768.f * w;

        mtex_pbuffer[bufpointer].u = context->VertexBuffer[i].v.u;
        mtex_pbuffer[bufpointer].v = context->VertexBuffer[i].v.v;

        mtex_pbuffer[bufpointer].color.r = context->VertexBuffer[i].v.color.r;
        mtex_pbuffer[bufpointer].color.g = context->VertexBuffer[i].v.color.g;
        mtex_pbuffer[bufpointer].color.b = context->VertexBuffer[i].v.color.b;
        mtex_pbuffer[bufpointer].color.a = context->VertexBuffer[i].v.color.a;
}

void d_DrawFixPolygon(GLcontext context)
{
   int i;
   ULONG error;
   ULONG or_code;
   ULONG outcode;
   MGLPolygon poly;

        if(context->CullFace_State == GL_TRUE && context->CurrentCullFace == GL_FRONT_AND_BACK)
                return;

        or_code = TransformFixPoly(context);

        if (or_code == 0xFFFFFFFF)
                return;

        outcode = or_code;

        poly.numverts = context->VertexBufferPointer;


   PrepTexCoords(context, 0, poly.numverts, GL_FALSE);

   if(or_code)
   {
        poly.verts[0] = 0;
        poly.verts[1] = 1;
        poly.verts[2] = 2;

        for(i=3; i<poly.numverts; i++)
        {
                poly.verts[i] = i;
        }

        hc_ClipFixPolyFF(context, &poly, or_code);

        if(!poly.numverts)
                return;
   }

   if(context->Texture2D_State[1] == GL_FALSE) //only unit0 is active
   {
        static W3D_Vertex *verts[64];
        static W3D_TrianglesV fan;

        if(outcode == 0)
        {
                ProjectFixPoly(context);

                poly.verts[0] = 0;
                poly.verts[1] = 1;
                poly.verts[2] = 2;

                verts[0] = &(context->VertexBuffer[0].v);
                verts[1] = &(context->VertexBuffer[1].v);
                verts[2] = &(context->VertexBuffer[2].v);

                for(i=3; i<poly.numverts; i++)
                {
                        poly.verts[i] = i;
                        verts[i] = &(context->VertexBuffer[i].v);
                }
        }
        else
        {
                verts[0] = &(context->VertexBuffer[poly.verts[0]].v);
                v_FixToScreen(context, poly.verts[0]);
                verts[1] = &(context->VertexBuffer[poly.verts[1]].v);
                v_FixToScreen(context, poly.verts[1]);
                verts[2] = &(context->VertexBuffer[poly.verts[2]].v);
                v_FixToScreen(context, poly.verts[2]);

           for(i=3; i<poly.numverts; i++)
           {
                verts[i] = &(context->VertexBuffer[poly.verts[i]].v);
                v_FixToScreen(context, poly.verts[i]);

           }
        }

           if(context->CullFace_State == GL_TRUE && poly.numverts > 3)
           {
                float x0,y0;
                float x1,y1;
                float x2,y2;
                GLfloat area;

                #define x(a) (context->VertexBuffer[poly.verts[a]].v.x)
                #define y(a) (context->VertexBuffer[poly.verts[a]].v.y)

                x0 = x(0);
                y0 = y(0);
                x1 = x(1) - x0;
                y1 = y(1) - y0;
                x2 = x(2) - x0;
                y2 = y(2) - y0;

                area = y2*x1 - x2*y1;

                i = 1;

                while (i < poly.numverts-2 && fabs(area) < context->MinTriArea)
                {
                   x1 = x2;
                   y1 = y2;
                   x2 = x(i+2) - x0;
                   y2 = y(i+2) - y0;

                   area += y2*x1 - x2*y1;
                   i++;
                }               

                if(context->CurrentCullSign > 0)
                area = -area;

                if(area < context->MinTriArea)
                return;

                #undef x
                #undef y
           }

           fan.tex = context->w3dTexBuffer[context->CurrentBinding];
           fan.st_pattern = NULL;
           fan.vertexcount = poly.numverts;
           fan.v = verts;

           error = W3D_DrawTriFanV(context->w3dContext, &fan);
        }
        else
        {
 //multitexturing:
 //buffered continous projection in W3D_Vertex struct
        static int mtexverts;
        static int start;
        static float texwidth, texheight;
        static W3D_Triangles cont_fan;
        static MGLVertex *vf;
        static W3D_Vertex *vd;

        if(polypointer == 0)
        {
                mtexverts = 0; //reset
        #ifdef AUTO_TEXSORT
                num_mtextures = 0;
        #endif
        }

        start = mtexverts;

        if(outcode == 0)
        {
           if(context->ShadeModel == GL_SMOOTH)
           {
                ProjectFixMtex_Smooth(context, &poly, mtexverts);
           }
           else
           {
                ProjectFixMtex_Flat(context, &poly, mtexverts);
           }
        mtexverts += poly.numverts;
        }
        else
        {
           if(context->ShadeModel == GL_SMOOTH)
           {
                  v_FixMtexToScreen_Smooth(context, poly.verts[0], mtexverts++);
                  v_FixMtexToScreen_Smooth(context, poly.verts[1], mtexverts++);
                  v_FixMtexToScreen_Smooth(context, poly.verts[2], mtexverts++);

                for(i=3; i< poly.numverts; i++)
                {
                  v_FixMtexToScreen_Smooth(context, poly.verts[i], mtexverts++);
                }
           }
           else
           {
                  v_FixMtexToScreen_Flat(context, poly.verts[0], mtexverts++);
                  v_FixMtexToScreen_Flat(context, poly.verts[1], mtexverts++);
                  v_FixMtexToScreen_Flat(context, poly.verts[2], mtexverts++);

                for(i=3; i< poly.numverts; i++)
                {
                  v_FixMtexToScreen_Flat(context, poly.verts[i], mtexverts++);
                }
           }
        }

           if (context->CullFace_State == GL_TRUE && poly.numverts > 3)
           {
           float x0,y0;
           float x1,y1;
           float x2,y2;
           GLfloat area;

           i = start + 1;

                #define x(a) (mtex_pbuffer[a].x)
                #define y(a) (mtex_pbuffer[a].y)

                x0 = x(start);
                y0 = y(start);
                x1 = x(start+1) - x0;
                y1 = y(start+1) - y0;
                x2 = x(start+2) - x0;
                y2 = y(start+2) - y0;

                area = y2*x1 - x2*y1;

                while (i < mtexverts-2 && fabs(area) < context->MinTriArea)
                {
                   x1 = x2;
                   y1 = y2;
                   x2 = x(i+2) - x0;
                   y2 = y(i+2) - y0;

                   area += y2*x1 - x2*y1;
                i++;
                }

                #undef x
                #undef y
                
                if(context->CurrentCullSign > 0)
                area = -area;

                if(area < context->MinTriArea)
                {
                        mtexverts = start;
                        return;
                }
           }

           cont_fan.tex = context->w3dTexBuffer[context->CurrentBinding];
           cont_fan.st_pattern = NULL;
           cont_fan.vertexcount = poly.numverts;
           cont_fan.v = &(mtex_pbuffer[start]);

           error = W3D_DrawTriFan(context->w3dContext, &cont_fan);

           //copy texcoords from virtual unit1 to real unit0

           texwidth = (float)context->w3dTexBuffer[context->VirtualBinding]->texwidth;
           texheight = (float)context->w3dTexBuffer[context->VirtualBinding]->texwidth;

           vf = context->VertexBuffer;
           vd = &mtex_pbuffer[start];

           vd[0].u = vf[poly.verts[0]].tcoord.s * texwidth;
           vd[0].v = vf[poly.verts[0]].tcoord.t * texheight;
           vd[1].u = vf[poly.verts[1]].tcoord.s * texwidth;
           vd[1].v = vf[poly.verts[1]].tcoord.t * texheight;
           vd[2].u = vf[poly.verts[2]].tcoord.s * texwidth;
           vd[2].v = vf[poly.verts[2]].tcoord.t * texheight;

           for(i=3; i<poly.numverts; i++)
           {
                MGLVertex *v = &vf[poly.verts[i]];      

                vd[i].u = v->tcoord.s * texwidth;
                vd[i].v = v->tcoord.t * texheight;
           }


#ifdef AUTO_TEXSORT
           if(num_mtextures == 0)
           {
                new_mtexnum[0] = context->VirtualBinding;
                num_mtextures++;

                texchain[0].mtexpoly[0] = &(pidx[0]);
                texchain[0].mtexpolycount = 1;
           }
           else
           {
                int k, p;

                k = polypointer;
                p = 0;

                for(i=0; i<num_mtextures; i++)
                {
                   if(context->VirtualBinding == new_mtexnum[i])
                   {
                        p = texchain[i].mtexpolycount;
                        texchain[i].mtexpoly[p] = &(pidx[k]);
                        texchain[i].mtexpolycount += 1;
                        break;
                   }
                }

                if(p == 0)
                {
                   new_mtexnum[num_mtextures] = context->VirtualBinding;
                   texchain[num_mtextures].mtexpoly[0] = &(pidx[k]);
                   texchain[num_mtextures].mtexpolycount = 1;
                   num_mtextures++;

                }
           }
#endif

           pidx[polypointer].polyverts = poly.numverts;
#ifndef AUTO_TEXSORT
           pidx[polypointer].binding = context->VirtualBinding;
#else
           pidx[polypointer].pos = start;
#endif
           polypointer++;

   }
}

#endif //FIXPOINT_POLYGONS

static void d_DrawMtexPolyChains(GLcontext context)
{
        int i;
        int first;
        static W3D_Triangles tris;
        ULONG error;
        int j, next;

#ifdef AUTO_TEXSORT

        for(i=0; i<num_mtextures; i++)
        {
                tris.st_pattern = NULL;
                tris.tex = context->w3dTexBuffer[new_mtexnum[i]];

                for(j=0; j<texchain[i].mtexpolycount; j++)
                {
                   tris.vertexcount = texchain[i].mtexpoly[j]->polyverts;
                   tris.v = &mtex_pbuffer[texchain[i].mtexpoly[j]->pos];

                   error = W3D_DrawTriFan(context->w3dContext, &tris);
                }
        }

        polypointer = 0;

#else

        first = 0;
        tris.st_pattern = NULL;
        i = 0;

        do
        {
           if(pidx[i].binding >= 0)
           {
                tris.tex = context->w3dTexBuffer[pidx[i].binding];
                tris.v = &mtex_pbuffer[first];
                tris.vertexcount = pidx[i].polyverts;
                error = W3D_DrawTriFan(context->w3dContext, &tris);
                first += pidx[i].polyverts;

                next = first;

                for(j=(i+1); j < polypointer; j++)
                {
                   if(pidx[j].binding == pidx[i].binding)
                   {
                   tris.v = &mtex_pbuffer[next];
                   tris.vertexcount = pidx[j].polyverts;

                   error = W3D_DrawTriFan(context->w3dContext, &tris);
                   pidx[j].binding = -1;
                   }
                   next += pidx[j].polyverts;
                }
           }
           else
           {
                first += pidx[i].polyverts;
           }

        i++;
        } while (i < polypointer);

        polypointer = 0;
#endif
}

/*
**

MiniGL API:

mglDrawMultitexBuffer(GLenum bs, GLenum bd, GLenum env)

where bs = BlendSrc, bd = BlendDst, env = TexEnv

This function should be called when all polys are in chain or a global state change make it required.
It sets the supplied state-parameters, draws the buffer, and returns the context as it was before.


**
*/

void MGLDrawMultitexBuffer (GLcontext context, GLenum BSrc, GLenum BDst, GLenum TexEnv)
{
        GLboolean blendfunc_changed;
        GLenum CurBlendSrc, CurBlendDst;

        if(!polypointer)
                return;

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


        if (context->FogDirty && context->Fog_State)
        {
                fog_Set(context);
                context->FogDirty = GL_FALSE;
        }

        if(context->CurTexEnv != TexEnv)
        {
                W3D_Texture *tex;
#ifndef AUTO_TEXSORT
                tex = context->w3dTexBuffer[pidx[0].binding];
#else
                tex = context->w3dTexBuffer[new_mtexnum[0]];
#endif
                switch(TexEnv)
                {
                case GL_MODULATE:
                        W3D_SetTexEnv(context->w3dContext, tex, W3D_MODULATE, NULL);
                        break;
                case GL_DECAL:
                        W3D_SetTexEnv(context->w3dContext, tex, W3D_DECAL, NULL);
                        break;
                case GL_REPLACE:
                        W3D_SetTexEnv(context->w3dContext, tex, W3D_REPLACE, NULL);
                        break;
                default:
                        break;
                }
        }

        if(context->CurBlendSrc != BSrc || context->CurBlendDst != BDst)
        {
                CurBlendSrc = context->CurBlendSrc;
                CurBlendDst = context->CurBlendDst;

                GLBlendFunc(context, BSrc, BDst);
                blendfunc_changed = GL_TRUE;
        }
        else
        {
                blendfunc_changed = GL_FALSE;
        }

        if(context->ShadeModel == GL_FLAT && context->UpdateCurrentColor == GL_TRUE)
        {
                W3D_SetCurrentColor(context->w3dContext, &context->CurrentColor);
                context->UpdateCurrentColor = GL_FALSE;
        }

        ENABLE_BLEND

        d_DrawMtexPolyChains(context);

        DISABLE_BLEND


        if(blendfunc_changed == GL_TRUE)
        {
                GLBlendFunc(context, CurBlendSrc, CurBlendDst);
        }


        if(context->CurTexEnv != TexEnv)
        {
                W3D_Texture *tex;
#ifndef AUTO_TEXSORT
                tex = context->w3dTexBuffer[pidx[0].binding];
#else
                tex = context->w3dTexBuffer[new_mtexnum[0]];
#endif

                switch(context->CurTexEnv)
                {
                case GL_MODULATE:
                        W3D_SetTexEnv(context->w3dContext, tex, W3D_MODULATE, NULL);
                        break;
                case GL_DECAL:
                        W3D_SetTexEnv(context->w3dContext, tex, W3D_DECAL, NULL);
                        break;
                case GL_REPLACE:
                        W3D_SetTexEnv(context->w3dContext, tex, W3D_REPLACE, NULL);
                        break;
                default:
                        break;
                }
        }

        if(context->LockMode == MGL_LOCK_MANUAL)
                return;

        else if (context->LockMode == MGL_LOCK_SMART && TMA_Check(&(context->LockTime)) == GL_TRUE)
        {
                // Time to unlock
                W3D_UnLockHardware(context->w3dContext);
                context->w3dLocked = GL_FALSE;
        }
        else
        {
                W3D_UnLockHardware(context->w3dContext);
                context->w3dLocked = GL_FALSE;
        }

}

#ifdef __VBCC__

        #undef v_ToScreen
        #undef v_ToScreenVA

#endif
