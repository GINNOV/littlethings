
#include <GL/gla.h>
#include "zgl.h"

static unsigned long *recup_cmap(int nc, unsigned long *cr);

typedef struct {
    GLContext *gl_context;
    int xsize,ysize;

    GLADrawable drawable;
    unsigned char *image;
    int bpp;

    int do_convert;
    struct BitMap *bitmap;
} TinyGLAContext;


/*
 * CreateContext
 */
GLAContext glACreateContext(void) //Display *dpy, XVisualInfo *vis, GLAContext shareList, BOOL direct )
{
  TinyGLAContext *ctx;

  ctx=gl_malloc(sizeof(TinyGLAContext));
	if (!ctx){
		return NULL;
	}
  ctx->gl_context=NULL;
	ctx->image=NULL;
	ctx->bitmap = NULL;
	ctx->drawable=NULL;

  return (GLAContext) ctx;
}


/*
 * DestroyContext
 */
void glADestroyContext(GLAContext ctx1)
{
	TinyGLAContext *ctx = (TinyGLAContext *) ctx1;
	
	// Close zbuffer and other things if necessary (dither stuff, frame buffer
	// if internally allocated, ...)
  ZB_close(ctx->gl_context->zb);
	
  // Destroy the internal GLContext struct
  if (ctx->gl_context != NULL) {
    glClose();
  }
	
	// Display buffers to be freed
	if (ctx->image){
    gl_free(ctx->image);
	} 
	if (ctx->bitmap){
    FreeBitMap(ctx->bitmap);
	}

  gl_free(ctx);
}

/* resize the glx viewport : we try to use the xsize and ysize
given. We return the effective size which is guaranted to be smaller */

static int glA_resize_viewport(GLContext *c, int *xsize_ptr, int *ysize_ptr)
{
    TinyGLAContext *ctx;
    int xsize,ysize;
		
    ctx=(TinyGLAContext *)c->opaque;

    xsize=*xsize_ptr;
    ysize=*ysize_ptr;

    /* we ensure that xsize and ysize are multiples of 2 for the zbuffer.
TODO: find a better solution */
    xsize&=~3;
    ysize&=~3;

    if (xsize == 0 || ysize == 0) return -1;

    *xsize_ptr=xsize;
    *ysize_ptr=ysize;
    
    if (ctx->bpp == 8){
        if (ctx->image == NULL){
            ctx->image = (unsigned char *)gl_malloc(xsize * ysize * (ctx->bpp / 8));
        }else{
            if ((xsize !=   ctx->xsize) || (ysize != ctx->ysize)){
                gl_free(ctx->image);
                ctx->image = (unsigned char *)gl_malloc(xsize * ysize * (ctx->bpp / 8));
            }
        }
        if (ctx->image == NULL){
            return -1;
        }
    }else{
        if (ctx->bitmap == NULL){
            ctx->bitmap = AllocBitMap(xsize, ysize, 16, BMF_MINPLANES|BMF_SPECIALFMT|SHIFT_PIXFMT(PIXFMT_RGB16), NULL); //ctx->drawable->RPort->BitMap);
        }else{
            if ((xsize !=   ctx->xsize) || (ysize != ctx->ysize)){
                FreeBitMap(ctx->bitmap);
                ctx->bitmap = AllocBitMap(xsize, ysize, 16, BMF_MINPLANES|BMF_SPECIALFMT|SHIFT_PIXFMT(PIXFMT_RGB16), NULL); //ctx->drawable->RPort->BitMap);
            }
        }
        if (ctx->bitmap == NULL){
            return -1;
        }
    }
    ctx->xsize=xsize;
    ctx->ysize=ysize;
    
    /* resize the Z buffer */
    //if (ctx->do_convert){
      ZB_resize(c->zb,NULL,xsize,ysize);
    //}else{
    //  ZB_resize(c->zb,ctx->image,xsize,ysize);
    //}

    return 0;
}

/*
 * MakeCurrent
 */
/* we assume here that drawable is a window */
int glAMakeCurrent(GLADrawable drawable, GLAContext ctx1)
{
  TinyGLAContext *ctx = (TinyGLAContext *) ctx1;
  int xsize,ysize;
  ZBuffer *zb;
  unsigned int palette[ZB_NB_COLORS];
  unsigned char color_indexes[ZB_NB_COLORS];
	unsigned long *new_palette;
	int i;
	int mode;
	int bpp;
	struct Screen *currentScreen;
   
	//if((dpy==NULL)||(ctx1==NULL)) return(0);

	bpp = GetBitMapAttr(drawable->RPort->BitMap, BMA_DEPTH);

/*
	if (bpp >= 15){
		bpp = 24;
	}
*/
	ctx->bpp = bpp;
   
  if (ctx->gl_context == NULL) {

    /* create the TinyGL context */

        ctx->drawable=drawable;
     
        xsize = drawable->Width;
        ysize = drawable->Height;
 
        switch (bpp){
					case 8:
						mode = ZB_MODE_INDEX;
                        
						for(i=0;i<ZB_NB_COLORS;i++){
							color_indexes[i]=i;
						}

						/* Open the Z Buffer - 256 colors */
						zb=ZB_open(xsize,ysize,mode,ZB_NB_COLORS,color_indexes,palette,NULL);
						if (zb == NULL) {
							fprintf(stderr, "Error while initializing Z buffer\n");
							exit(1);
						}

						// Affectation de la cmap au drawable si l'écran n'est pas le Wb
						currentScreen = LockPubScreen("Workbench");
						if (currentScreen){
							if (currentScreen != drawable->WScreen){
								new_palette = recup_cmap(ZB_NB_COLORS, (unsigned long *)palette);
								LoadRGB32(&drawable->WScreen->ViewPort, new_palette);
								free(new_palette);
								UnlockPubScreen(NULL, currentScreen);
							}
						}

            ctx->do_convert = 1;
            break;
/*
					case 24:
            mode = ZB_MODE_RGB24;
            ctx->do_convert = 1; //TGL_FEATURE_RENDER_BITS != 16;
            zb = ZB_open(xsize, ysize, mode, 0, NULL, NULL, NULL);
            break;
					case 32:
            mode = ZB_MODE_RGBA;
            ctx->do_convert = 1; //TGL_FEATURE_RENDER_BITS != 16;
            zb = ZB_open(xsize, ysize, mode, 0, NULL, NULL, NULL); //ctx->image);
            break;
*/

					default:
                  mode = ZB_MODE_5R6G5B;
						zb = ZB_open(xsize, ysize, mode, 0, NULL, NULL, NULL);
        }
			
			if (zb == NULL){
				fprintf(stderr,	"Error while initializing Z buffer\n");
				exit(1);
			}
 

    /* initialisation of the TinyGL interpreter */
    glInit(zb);

    ctx->gl_context=gl_get_context();
    ctx->gl_context->opaque=(void *) ctx;
		ctx->gl_context->gl_resize_viewport=glA_resize_viewport;

    /* set the viewport : we force a call to glX_resize_viewport */
    ctx->gl_context->viewport.xsize=-1;
    ctx->gl_context->viewport.ysize=-1;

		glViewport(0, 0, xsize, ysize);
  }

  return 1;
}


/*
 * SwapBuffers
 */
void glASwapBuffers(GLADrawable drawable)
{
  GLContext *gl_context;
  TinyGLAContext *ctx;
	int i;
	int comp = 0;
	unsigned char *ptr;
	//unsigned long *new_palette;
	unsigned short *seize;
	unsigned short s;
	unsigned char *buf;
	unsigned char r,g,b;
	APTR bmapHandle;
	ULONG bmapBase;
		
  /* retrieve the current GLXContext */
  gl_context=gl_get_context();
  ctx=(TinyGLAContext *)gl_context->opaque;

    if (ctx->bpp == 8){
        ZB_copyFrameBuffer(ctx->gl_context->zb, ctx->image, ctx->xsize);
        
        WriteChunkyPixels(drawable->RPort, 0, 0, drawable->Width - 1, drawable->Height - 1, (unsigned char *)ctx->image/*ctx->gl_context->zb->pbuf*/, drawable->Width);
    }else{
/*
        if (ctx->do_convert){
          // bytes per line en dernier argument
          ZB_copyFrameBuffer(ctx->gl_context->zb, ctx->image, ctx->xsize * ctx->bpp / 8);
        }

        switch (ctx->bpp){
            case 32:
                (void)WritePixelArray(ctx->image,
                                                0,0,
                                                drawable->Width * ctx->bpp / 8,
                                                drawable->RPort,
                                                0, 0,
                                                drawable->Width,
                                                drawable->Height,
                                                RECTFMT_ARGB);
                break;

            default:
                (void)WritePixelArray(ctx->image,
                                                0,0,
                                                drawable->Width * ctx->bpp / 8,
                                                drawable->RPort,
                                                0, 0,
                                                drawable->Width,
                                                drawable->Height,
                                                RECTFMT_RGB);
        }
*/


        bmapHandle = LockBitMapTags(ctx->bitmap, LBMI_BASEADDRESS, &bmapBase, TAG_DONE);
        if (bmapHandle){
            //ZB_copyBuffer(ctx->gl_context->zb, bmapBase, ctx->xsize * 2);
            CopyMemQuick(ctx->gl_context->zb->pbuf, bmapBase, ctx->xsize * ctx->ysize * 2);
            UnLockBitMap(bmapHandle);
        }

        BltBitMapRastPort(ctx->bitmap, 0, 0, drawable->RPort, drawable->BorderLeft, drawable->BorderTop, ctx->xsize * 2, ctx->ysize, 0xc0);

    }
}

/* Create an AmigaOS color map (usable with LoadRGB32()) */
static unsigned long *recup_cmap(int nc, unsigned long *cr)
{
    int c;
    unsigned long *colourtable;
    unsigned char r, g, b;

    if ((colourtable = (unsigned long *)malloc((1 + 3 * nc + 1) * sizeof(unsigned long))))
    {
        colourtable[0] = (nc << 16) + 0;

        for (c = 0; c < nc; c++)
        {
            r = (unsigned char)((cr[c]>>16) & 0xFF);
            g = (unsigned char)((cr[c]>>8) & 0xFF);
            b = (unsigned char)((cr[c]) & 0xFF);
       
            colourtable[3 * c + 1] = (unsigned long)(r * 0x01010101);
            colourtable[3 * c + 2] = (unsigned long)(g * 0x01010101);
            colourtable[3 * c + 3] = (unsigned long)(b * 0x01010101);
        }

        colourtable[1 + 3 * nc] = 0;
    }

    return colourtable;
}

