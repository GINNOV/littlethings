/*
 * $Id: texture.c,v 1.1.1.1 2000/04/07 19:44:51 tfrieden Exp $
 *
 * $Date: 2000/04/07 19:44:51 $
 * $Revision: 1.1.1.1 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#include "sysinc.h"

#include <stdlib.h>
#include <stdio.h>
#ifdef __VBCC__
#include <string.h> //inlined memcpy
#endif


static char rcsid[] = "$Id: texture.c,v 1.1.1.1 2000/04/07 19:44:51 tfrieden Exp $";


#ifndef __PPC__
extern struct ExecBase *SysBase;
#endif

void tex_FreeTextures(GLcontext context);
void tex_SetEnv(GLcontext context, GLenum env);
ULONG tex_GLFilter2W3D(GLenum filter);
void tex_SetFilter(GLcontext context, GLenum min, GLenum mag);
void tex_SetWrap(GLcontext context, GLenum wrap_s, GLenum wrap_t);

/*
** Surgeon: support for GL_ALPHA, GL_LUMINANCE and GL_LUMINANCE_ALPHA
** The support is indirect because GL_ALPHA and GL_LUMINANCE are converted to A4R4G4B4.
** Funnily A8 and L8 are supported in hardware by Voodoo3 but these formats seem to have some Warp3D related problems. */

//NOTE: warp3D has problem with one byte/pixel formats
//#define EIGHTBIT_TEXTURES 1

//Formats directly supported by Warp3D:

void SHORT4444_4444(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void SHORT565_565(GLcontext context, GLubyte *input, UWORD *output, int width, int height);


//supported, but not in hardware on voodoo3:

void L8A8_L8A8(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

#ifdef EIGHTBIT_TEXTURES

void EIGHT_EIGHT(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

#endif



//conversion routines:

void SHORT565_4444(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void SHORT4444_565(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void A8_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void L8_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void RGBA_RGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void RGBA_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void RGB_RGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void RGB_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

void RGBA4_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height);

ULONG MGLConvert(GLcontext context, const GLvoid *inputp, UWORD *output, int width, int height, GLenum internalformat, GLenum format);

static ULONG Allocated_Size = 0;
static ULONG Peak_Size      = 0;

void *tex_Alloc(ULONG size)
{
	ULONG *x;
	Allocated_Size += size+4;
	x=(ULONG *)malloc(size+4);
	*x = size;

	if (Allocated_Size > Peak_Size) Peak_Size = Allocated_Size;

	return x+1;
}

void tex_Free(void *chunk)
{
	ULONG *mem = (ULONG *)chunk;
	mem--;
	Allocated_Size -= *mem;
	Allocated_Size -= 4;
	free(mem);
}

void tex_Statistic(void)
{
//	printf("Peak Allocation Size: %ld\n", Peak_Size);
	printf("Peak Allocation Size: %lu\n", Peak_Size); //OF

}

void MGLTexMemStat(GLcontext context, GLint *Current, GLint *Peak)
{
	if (Current) *Current = (GLint)Allocated_Size;
	if (Peak)    *Peak    = (GLint)Peak_Size;
}

void GLDeleteTextures(GLcontext context, GLsizei n, const GLuint *textures)
{
	int i;
	for (i=0; i<n; i++)
	{
		int j = *textures++;
		if (context->w3dTexBuffer[j])
		{
			W3D_FreeTexObj(context->w3dContext, context->w3dTexBuffer[j]);
			context->w3dTexBuffer[j] = NULL;
		}
		if (context->w3dTexMemory[j])
		{
			void *x = context->w3dTexMemory[j];
			tex_Free(x);
			context->w3dTexMemory[j] = NULL;
		}
		context->GeneratedTextures[j] = 0;
	}
}

void GLGenTextures(GLcontext context, GLsizei n, GLuint *textures)
{
	int i,j;

	j = 1;
	for (i=0; i<n; i++)
	{
		// Find a free texture
		while (j < context->TexBufferSize)
		{
			if (context->GeneratedTextures[j] == 0) break;
			j++;
		}

		// If we get here, we found one, or there's noting available. Flag an error in that case..
		if (j == context->TexBufferSize)
		{
		    GLFlagError(context, j == context->TexBufferSize, GL_INVALID_OPERATION);
		    return;
		}

		// Insert the texture in the output array, and flag it as used internally
		*textures = j;
		context->GeneratedTextures[j] = 1;
		textures++;
		j++;
	}
}



void tex_FreeTextures(GLcontext context)
{
	int i;

	for (i=0; i<context->TexBufferSize; i++)
	{
		if (context->w3dTexBuffer[i])
		{
			W3D_FreeTexObj(context->w3dContext, context->w3dTexBuffer[i]);
		}

		if (context->w3dTexMemory[i])
		{
			tex_Free(context->w3dTexMemory[i]);
		}

		context->w3dTexBuffer[i] = 0;
		context->w3dTexMemory[i] = 0;
	}
	W3D_FreeAllTexObj(context->w3dContext);
}


void tex_SetEnv(GLcontext context, GLenum env)
{
	W3D_Texture *tex;

	if(context->ActiveTexture == 1)
		return;

	if(context->CurTexEnv == env)
		return;

	tex = context->w3dTexBuffer[context->CurrentBinding];

	if (!tex) return;

	context->CurTexEnv = env;

	switch(env)
	{
		case GL_MODULATE:   W3D_SetTexEnv(context->w3dContext, tex, W3D_MODULATE, NULL);
							break;
		case GL_DECAL:      W3D_SetTexEnv(context->w3dContext, tex, W3D_DECAL, NULL);
							break;
		case GL_REPLACE:    W3D_SetTexEnv(context->w3dContext, tex, W3D_REPLACE, NULL);
							break;
		default:            break;
	}
}

ULONG tex_GLFilter2W3D(GLenum filter)
{
	switch(filter)
	{
		case GL_NEAREST:                return W3D_NEAREST;
		case GL_LINEAR:                 return W3D_LINEAR;
		case GL_NEAREST_MIPMAP_NEAREST: return W3D_NEAREST_MIP_NEAREST;
		case GL_LINEAR_MIPMAP_NEAREST:  return W3D_LINEAR_MIP_NEAREST;
		case GL_NEAREST_MIPMAP_LINEAR:  return W3D_NEAREST_MIP_LINEAR;
		case GL_LINEAR_MIPMAP_LINEAR:   return W3D_LINEAR_MIP_LINEAR;
	}
	return 0;
}

void tex_SetFilter(GLcontext context, GLenum min, GLenum mag)
{
	ULONG minf, magf;
	W3D_Texture *tex;

	if(context->ActiveTexture)
		tex = context->w3dTexBuffer[context->VirtualBinding];
	else
		tex = context->w3dTexBuffer[context->CurrentBinding];

	if (!tex) return;

	minf = tex_GLFilter2W3D(min);
	magf = tex_GLFilter2W3D(mag);

	W3D_SetFilter(context->w3dContext, tex, minf, magf);
}

void tex_SetWrap(GLcontext context, GLenum wrap_s, GLenum wrap_t)
{
	ULONG Ws,Wt;
	W3D_Texture *tex;

	if(context->ActiveTexture)
		tex = context->w3dTexBuffer[context->VirtualBinding];
	else
		tex = context->w3dTexBuffer[context->CurrentBinding];

	if (!tex) return;

	if (wrap_s == GL_REPEAT) Ws = W3D_REPEAT;
						else Ws = W3D_CLAMP;
	if (wrap_t == GL_REPEAT) Wt = W3D_REPEAT;
						else Wt = W3D_CLAMP;

	W3D_SetWrapMode(context->w3dContext, tex, Ws, Wt, NULL);
}

void GLTexEnvi(GLcontext context, GLenum target, GLenum pname, GLint param)
{
   //LOG(2, glTexEnvi, "%d %d", pname, param);

	//ignore unit 1 env until mglDrawMultitexBuffer

	if(context->ActiveTexture == 1)
		return;

   	context->TexEnv[0] = (GLenum)param;

   	tex_SetEnv(context, param);
}

void GLTexParameteri(GLcontext context, GLenum target, GLenum pname, GLint param)
{
	GLenum min, mag;
	GLenum wraps, wrapt;
	//LOG(2, glTexParameteri, "%d %d %d", target, pname, param);
	switch(pname)
	{
		case GL_TEXTURE_MIN_FILTER:
			mag = context->MagFilter;
			tex_SetFilter(context, mag, (GLenum)param);
			context->MinFilter = (GLenum)param;
			break;

		case GL_TEXTURE_MAG_FILTER:
			min = context->MinFilter;
			tex_SetFilter(context, (GLenum)param, min);
			context->MagFilter = (GLenum)param;
			break;

		case GL_TEXTURE_WRAP_S:
			wrapt = context->WrapT;
			tex_SetWrap(context, (GLenum)param, wrapt);
			context->WrapS = (GLenum)param;
			break;

		case GL_TEXTURE_WRAP_T:
			wraps = context->WrapS;
			tex_SetWrap(context, wraps, (GLenum)param);
			context->WrapT = (GLenum)param;
			break;
		default:
			GLFlagError(context, 1, GL_INVALID_ENUM);
	}
}

void GLPixelStorei(GLcontext context, GLenum pname, GLint param)
{
	switch(pname)
	{
		case GL_PACK_ALIGNMENT:
			context->PackAlign = param;
			break;

		case GL_UNPACK_ALIGNMENT:
			context->UnpackAlign = param;
			break;

      case GL_UNPACK_ROW_LENGTH:
	 context->CurUnpackRowLength = param ;
	 break ;

      case GL_UNPACK_SKIP_PIXELS:
	 context->CurUnpackSkipPixels = param ;
	 break ;

      case GL_UNPACK_SKIP_ROWS:
	 context->CurUnpackSkipRows = param ;
	 break ;

		default:
			// Others here
			break;
	}
}

void GLBindTexture(GLcontext context, GLenum target, GLuint texture)
{
   int active;

	//LOG(2, glBindTexture, "%d %d", target, texture);
	GLFlagError(context, target != GL_TEXTURE_2D, GL_INVALID_ENUM);

   active = context->ActiveTexture;


   if(active)
   {
	context->VirtualBinding = texture;

	if (context->w3dTexBuffer[context->VirtualBinding] == NULL)
	{   // Set to default for unbound objects
		context->MinFilter = GL_NEAREST;
		context->MagFilter = GL_NEAREST;
		context->WrapS     = GL_REPEAT;
		context->WrapT     = GL_REPEAT;
	}
   }
   else
   {
	context->CurrentBinding = texture;

	if (context->w3dTexBuffer[context->CurrentBinding] == NULL)
	{   // Set to default for unbound objects
		context->TexEnv[0] = GL_MODULATE;
		context->MinFilter = GL_NEAREST;
		context->MagFilter = GL_NEAREST;
		context->WrapS     = GL_REPEAT;
		context->WrapT     = GL_REPEAT;
	}
   }
}


/*
** There are two possible output formats:
** - RGB
** - RGBA
**
** There are two possible input formats:
** - RGB
** - RGBA
**
** Thus there must be four conversion routines, since the
** routine must be able to add or remove the alpha component
**
** The following set of routines assumes that input is always given as
** a stream of GL_UNSIGNED_BYTE with either three or four components.
**
** ROOM FOR IMPROVMENT
** These routines assume way too much to be considered anything else but
** special cases. The whole texture stuff should be reworked to include
** possible convertion routines for all kinds of textures. This could, of
** course, be left to Warp3D, but this would mean there has to be two sets
** of textures in memory, which is clearly too much. Perhaps we should
** change the behaviour of Warp3D in this point - room for discussion.
*/

#define CORRECT_ALIGN \
		if ((int)input % context->PackAlign) \
		{ \
			input += context->PackAlign - ((int)input % context->PackAlign);\
		} \


#define SETUP_LOOP(x) \
	GLubyte *oldInput;                          \
	int realWidth = width*x;                    \
	if (context->CurUnpackRowLength > 0)        \
	    realWidth = context->CurUnpackRowLength*x;


#define SETUP_LOOP_SHORT(x)                         \
	UWORD *oldInput;                            \
	int realWidth = width;                      \
	if (context->CurUnpackRowLength > 0)        \
	    realWidth = context->CurUnpackRowLength;

#define SETUP_LOOP_LONG                         \
	ULONG *oldInput;                            \
	int realWidth = width;                      \
	if (context->CurUnpackRowLength > 0)        \
	    realWidth = context->CurUnpackRowLength;


#define CORRECT_ALIGN_SHORT \
		if ((int)input % context->PackAlign) \
		{ \
			input += ((context->PackAlign - ((int)input % context->PackAlign))>>1);\
		} \

#define CORRECT_ALIGN_LONG \
		if ((int)input % context->PackAlign) \
		{ \
			input += ((context->PackAlign - ((int)input % context->PackAlign))>>2);\
		} \


#define START_LOOP \
	oldInput = input;

#define NEXT_LOOP       \
	input = oldInput + realWidth;


#define ARGBFORM(a,r,g,b) \
	( (UWORD)(((( a & 0xf0 ) << 8)  \
	|(( r & 0xf0 ) << 4)  \
	|(( g & 0xf0 )     )  \
	|(( b & 0xf0 ) >> 4))) )

/*
#define RGBFORM(r,g,b) \
	( (UWORD)(0x8000 | ((r & 0xF8) << 7) \
			   | ((g & 0xF8) << 2) \
			   | ((b & 0xF8) >> 3)) )


#define REDBYTE(rgb)    (((UWORD)rgb & 0x7C00) >> 7)
#define GREENBYTE(rgb)  (((UWORD)rgb & 0x03E0) >> 2)
#define BLUEBYTE(rgb)   (((UWORD)rgb & 0x001F) << 3)
#define RGB_GET(i) ((UBYTE *)(context->PaletteData)+3*i)
#define ARGB_GET(i) ((UBYTE *)(context->PaletteData)+4*i)
*/

#define RGBFORM(r,g,b) \
	( (UWORD)(((r & 0xF8) << 8) \
	      | ((g & 0xFC) << 3) \
	      | ((b & 0xF8) >> 3)) )


#define REDBYTE(rgb)        (((UWORD)rgb & 0xF800) >> 8)
#define GREENBYTE(rgb)      (((UWORD)rgb & 0x07E0) >> 3)
#define BLUEBYTE(rgb)       (((UWORD)rgb & 0x001F) << 3)
#define REDBYTEA(rgba)      (((UWORD)rgba & 0x0f00) >> 4)
#define GREENBYTEA(rgba)    (((UWORD)rgba & 0x00f0))
#define BLUEBYTEA(rgba)     (((UWORD)rgba & 0x000f) << 4)
#define ALPHABYTEA(rgba)    (((UWORD)rgba & 0xf000) >> 8)
#define RGB_GET(i) ((UBYTE *)(context->PaletteData)+3*i)
#define ARGB_GET(i) ((UBYTE *)(context->PaletteData)+4*i)


/*
** This function converts a non-alpha texture buffer into a
** alpha'ed texture buffer. This is used in case additive blending
** was selected but the texture does not have alpha, and additive blending
** is not
*/

void tex_AddAlpha(UWORD *output, int width, int height)
{
	int size;
	UBYTE r,g,b,a;
	UWORD x;
	ULONG a_tmp;
	size = width*height;

	while (size)
	{
	x=*output;
	
	r = REDBYTE(x);
	g = GREENBYTE(x);
	b = BLUEBYTE(x);

	//a=(r+g+b)/3;

	a=(r>g)?r:g;
	a=(a>b)?a:b;


	// These should emulate additive blending, so ensure it's in some appropriate range

/*
	a *= 0.8f;
*/
	a_tmp = a;
	a_tmp <<= 3;
	a_tmp /= 10;
	a = a_tmp;

	*output = ARGBFORM(a,r,g,b);
	output++; size--;
	}
}


/*
** Convert the currently bound texture to a format that has an alpha channel.
** Also sets the texture parameters according to the current settings.
*/

void tex_ConvertTexture(GLcontext context)
{
	W3D_Texture *newtex;
	struct TagItem AllocTags[20];
	W3D_Texture *oldtex = context->w3dTexBuffer[context->CurrentBinding];
	UWORD *output = (UWORD *)context->w3dTexMemory[context->CurrentBinding];

	if (!oldtex) return;
	if (oldtex->texfmtsrc == context->w3dAlphaFormat) return;

	tex_AddAlpha(output, oldtex->texwidth, oldtex->texheight);

	AllocTags[0].ti_Tag  = W3D_ATO_IMAGE;
	AllocTags[0].ti_Data = (ULONG)context->w3dTexMemory[context->CurrentBinding];

	AllocTags[1].ti_Tag  = W3D_ATO_FORMAT;
	AllocTags[1].ti_Data = context->w3dAlphaFormat;

	AllocTags[2].ti_Tag  = W3D_ATO_WIDTH;
	AllocTags[2].ti_Data = oldtex->texwidth;

	AllocTags[3].ti_Tag  = W3D_ATO_HEIGHT;
	AllocTags[3].ti_Data = oldtex->texheight;

	AllocTags[4].ti_Tag  = TAG_DONE;
	AllocTags[4].ti_Data = 0;

	newtex = W3D_AllocTexObj(context->w3dContext, NULL, AllocTags);
	if (!newtex)    return;
	
	W3D_FreeTexObj(context->w3dContext, oldtex);
	context->w3dTexBuffer[context->CurrentBinding] = newtex;

	tex_SetEnv(context, context->TexEnv[0]);

	tex_SetFilter(context, context->MinFilter, context->MagFilter);

	tex_SetWrap(context, context->WrapS, context->WrapT);
}


//These formats need no conversion:

void EIGHT_EIGHT (GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE *in = (UBYTE*)input;
	UBYTE *out = (UBYTE*)output;

	for (i=0; i<height; i++)
	{
		for (j=0; j<width; j++)
		{
			*out++ = *in++;
		}
		CORRECT_ALIGN
	}
}

void L8A8_L8A8(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;

//assume a width divisible by 2 for faster copy

	UWORD *in = (UWORD*)input;
	UWORD *out = (UWORD*)output;

	for (i=0; i<height;i++)
	{
		for (j=0; j<width; j++)
		{
			*out++ = *in++;
		}
		CORRECT_ALIGN
	}
}

void SHORT565_565(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;

//assume a width divisible by 2 for faster copy

	UWORD *in = (UWORD*)input;
	UWORD *out = (UWORD*)output;

	for (i = 0; i < height; i++)
	{
		for (j = 0; j < width; j++)
		{
			*out++ = *in++;
		}
		CORRECT_ALIGN
	}
}

void SHORT4444_4444(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;

//assume a width divisible by 2 for faster copy

	UWORD *in = (UWORD*)input;
	UWORD *out = (UWORD*)output;

	for (i = 0; i < height; i++)
	{
		for (j = 0; j < width; j++)
		{
			*out++ = *in++;
		}
		CORRECT_ALIGN
	}
}

//These formats need conversion:

#if 1

void A8_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	GLubyte a;

	for (i=0; i<height;i++)
	{
		for (j=0; j<width; j++)
		{
			a = *input++;
			*output++ = ( ((UWORD)a & 0xF0) << 8) | 0x0FFF;
		}
		CORRECT_ALIGN
	}
}

void L8_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	GLubyte la,lb,lc;

	for (i=0; i<height;i++)
	{
		for (j=0; j<width; j++)
		{
			la = lb = lc = *input++;
			*output++ = ARGBFORM(0xff, la, lb, lc);
		}
		CORRECT_ALIGN
	}
}

#endif

void RGBA_RGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE r,g,b,a;

	for (i=0; i<height;i++)
	{
		for (j=0; j<width; j++)
		{
			r=*input++;
			g=*input++;
			b=*input++;
			a=*input++;
			*output++ = RGBFORM(r,g,b);
		}
		CORRECT_ALIGN
	}
}


void RGBA_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE r,g,b,a;

	for (i=0; i<height;i++)
	{
		for (j=0; j<width; j++)
		{
			r=*input++;
			g=*input++;
			b=*input++;
			a=*input++;
			*output++ = ARGBFORM(a,r,g,b);
		}
		CORRECT_ALIGN
	}
}

void RGB_RGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE r,g,b;

	for (i=0; i<height;i++)
	{
		for (j=0; j<width; j++)
		{
			r=*input++;
			g=*input++;
			b=*input++;
			*output++ = RGBFORM(r,g,b);
		}
		CORRECT_ALIGN
	}
}

void RGB_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE r,g,b;

	for (i=0; i<height;i++)
	{
		for (j=0; j<width; j++)
		{
			r=*input++;
			g=*input++;
			b=*input++;
			*output++ = ARGBFORM(0xff,r,g,b);
		}
		CORRECT_ALIGN
	}
}

void SHORT4444_565(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE r,g,b;
	UWORD *in = (UWORD *)input;

	for (i = 0; i < height; i++)
	{
		for (j = 0; j < width; j++)
		{
			r = REDBYTEA(*in);
			g = GREENBYTEA(*in);
			b = BLUEBYTEA(*in);
			*output++ = RGBFORM(r, g, b);
			in++;
		}
		CORRECT_ALIGN
	}
}

void SHORT565_4444(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE r,g,b;

	UWORD *in = (UWORD *)input;

	for (i = 0; i < height; i++)
	{
		for (j = 0; j < width; j++)
		{
			r = REDBYTE(*in);
			g = GREENBYTE(*in);
			b = BLUEBYTE(*in);
			*output++ = ARGBFORM(0xff, r, g, b);
			in++;
		}
		CORRECT_ALIGN
	}
}

void RGBA4_ARGB (GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE r,g,b,a;

	UWORD *in = (UWORD *)input;

	for (i = 0; i < height; i++)
	{
		for (j = 0; j < width; j++)
		{
			r = ((*in)&0xf000) >> 8;
			g = ((*in)&0x0f00) >> 4;
			b = ((*in)&0x00f0);
			a = ((*in)&0x000f) << 4;
			*output++ = ARGBFORM(a, r, g, b);
			in++;
		}
		CORRECT_ALIGN
	}
}

void INDEX_RGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE ind;
	UBYTE r,g,b;

	if (context->PaletteFormat == GL_RGB)
	{
		for (i=0; i<height; i++)
		{
			for (j=0; j<width; j++)
			{
				ind = *input++;
				r = *RGB_GET(ind);
				g = *(RGB_GET(ind)+1);
				b = *(RGB_GET(ind)+2);
				*output++ = RGBFORM(r,g,b);
			}
			CORRECT_ALIGN
		}
	}
	else
	{
		for (i=0; i<height; i++)
		{
			for (j=0; j<width; j++)
			{
				ind = *input++;
				r = *RGB_GET(ind);
				g = *(ARGB_GET(ind)+1);
				b = *(ARGB_GET(ind)+2);
				*output++ = RGBFORM(r,g,b);
			}
			CORRECT_ALIGN
		}

	}
}

void INDEX_ARGB(GLcontext context, GLubyte *input, UWORD *output, int width, int height)
{
	int i,j;
	UBYTE ind;
	UBYTE r,g,b,a;

	if (context->PaletteFormat == GL_RGB)
	{
		for (i=0; i<height; i++)
		{
			for (j=0; j<width; j++)
			{
				ind = *input++;
				r = *RGB_GET(ind);
				g = *(RGB_GET(ind)+1);
				b = *(RGB_GET(ind)+2);
				*output++ = ARGBFORM(0xff,r,g,b);
			}
			CORRECT_ALIGN
		}
	}
	else
	{
		for (i=0; i<height; i++)
		{
			for (j=0; j<width; j++)
			{
				ind = *input++;
				r = *RGB_GET(ind);
				g = *(ARGB_GET(ind)+1);
				b = *(ARGB_GET(ind)+2);
				a = *(ARGB_GET(ind)+3);
				*output++ = ARGBFORM(a,r,g,b);
			}
			CORRECT_ALIGN
		}

	}
}



ULONG MGLConvert(GLcontext context, const GLvoid *inputp, UWORD *output, int width, int height, GLenum internalformat, GLenum format)
{
	GLvoid *input = (GLvoid *)inputp;

	if(internalformat == GL_RGB5_A1)
	{
		internalformat = GL_RGBA;
	}

	switch(internalformat) // The format the texture should have
	{
		case GL_ALPHA: //eq 1
			switch(format)
			{
				case GL_ALPHA:
				#ifdef EIGHTBIT_TEXTURES
					EIGHT_EIGHT(context, (GLubyte *)input, output, width, height);
					return W3D_A8;
				#else
					A8_ARGB(context, (GLubyte *)input, output, width, height);
					return context->w3dAlphaFormat;

				#endif
			}
			break;

		case GL_LUMINANCE:
			switch(format) // the format of the pixel (input) data
			{
				case GL_LUMINANCE:
				#ifdef EIGHTBIT_TEXTURES
					EIGHT_EIGHT(context, (GLubyte *)input, output, width, height);
					return W3D_L8;
				#else
					L8_ARGB(context, (GLubyte *)input, output, width, height);
					return context->w3dAlphaFormat;
				#endif
			}
			break;

		case GL_LUMINANCE_ALPHA:
			switch(format)
			{
				case GL_LUMINANCE_ALPHA:
					L8A8_L8A8(context, (GLubyte *)input, output, width, height);
					return W3D_L8A8;
			}
			break;

		case 3:
		case GL_RGB:
			switch(format)
			{
				case GL_RGB:
					RGB_RGB(context, (GLubyte *)input, output, width, height);
					return context->w3dFormat;
				case GL_RGBA:
					RGBA_RGB(context, (GLubyte *)input, output, width, height);
					return context->w3dFormat;
				case GL_COLOR_INDEX:
					INDEX_RGB(context, (GLubyte *)input, output, width, height);
					return context->w3dFormat;
				case MGL_UNSIGNED_SHORT_5_6_5:
					SHORT565_565(context, (GLubyte *)input, output, width, height);
					return context->w3dFormat;
				case MGL_UNSIGNED_SHORT_4_4_4_4:
					SHORT4444_565(context, (GLubyte *)input, output, width, height);
					return context->w3dFormat;

			}
			break;

		case 4:
		case GL_RGBA:
			switch(format)
			{
				case GL_RGB:
					RGB_ARGB(context, (GLubyte *)input, output, width, height);
					return context->w3dAlphaFormat;
				case GL_RGBA:
					RGBA_ARGB(context, (GLubyte *)input, output, width, height);
					return context->w3dAlphaFormat;
				case GL_COLOR_INDEX:
					INDEX_ARGB(context, (GLubyte *)input, output, width, height);
					return context->w3dAlphaFormat;
				case MGL_UNSIGNED_SHORT_5_6_5:
					SHORT565_4444(context, (GLubyte *)input, output, width, height);
					return context->w3dAlphaFormat;
				case MGL_UNSIGNED_SHORT_4_4_4_4:
					SHORT4444_4444(context, (GLubyte *)input, output, width, height);
					return context->w3dAlphaFormat;
			}
			break;

			case MGL_UNSIGNED_SHORT_5_6_5:
			switch(format)
			{
			    case MGL_UNSIGNED_SHORT_5_6_5:
				SHORT565_565(context, (GLubyte *)input, output, width, height);
				return context->w3dFormat;
			}
			break;

		case MGL_UNSIGNED_SHORT_4_4_4_4:
			switch(format)
			{
		    	case MGL_UNSIGNED_SHORT_4_4_4_4:
				SHORT4444_4444(context, (GLubyte *)input, output, width, height);
				return context->w3dAlphaFormat;
			}
			break;
	}
}

void GLTexImage2DNoMIP(GLcontext context, GLenum gltarget, GLint level,
	GLint internalformat, GLsizei width, GLsizei height, GLint border,
	GLenum format, GLenum type, const GLvoid *pixels);


#ifndef __PPC__

void UpdateTexImage(W3D_Context *context, W3D_Texture *texture, void *image, int level, ULONG *pal)
{
    W3D_UpdateTexImage(context, texture, image, level, pal);
}

#endif

void GLTexImage2D(GLcontext context, GLenum gltarget, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels)
{
	int current;
	ULONG w,h;
	ULONG targetsize;
	ULONG error;
	UBYTE *target;
	int i,iw,ih;
	void *miparray[16];
	ULONG useFormat;
	ULONG BytesPerTexel;
	struct TagItem AllocTags[20];


	if(context->ActiveTexture)
		current = context->VirtualBinding;
	else
		current = context->CurrentBinding;

#ifdef EIGHTBIT_TEXTURES
	if(format == GL_ALPHA || format == GL_LUMINANCE)
		BytesPerTexel = 1;
	else
#endif
		BytesPerTexel = context->w3dBytesPerTexel;


	if(internalformat == GL_RGB5_A1)
	{
		internalformat = GL_RGBA;
	}


	if (context->NoMipMapping == GL_TRUE)
	{
		GLTexImage2DNoMIP(context, gltarget, level, internalformat, width,
			height, border, format, type, pixels);
		return;
	}

	GLFlagError(context, type != GL_UNSIGNED_BYTE && type != MGL_UNSIGNED_SHORT_5_6_5 && type != MGL_UNSIGNED_SHORT_4_4_4_4, GL_INVALID_OPERATION);
	GLFlagError(context, gltarget != GL_TEXTURE_2D, GL_INVALID_ENUM);

	if (type == MGL_UNSIGNED_SHORT_5_6_5 || type == MGL_UNSIGNED_SHORT_4_4_4_4)
	    format = type;


	/*
	** We will use width and height only when the mipmap level
	** is really 0. Otherwise, we need to upscale the values
	** according to the level.
	**
	** Note this will most likely be difficult with non-square
	** textures, as the first side to reach one will remain
	** there. For example, consider the sequence
	** 8x4, 4x2, 2x1, 1x1
	**  0     1   2    3
	** If the 1x1 mipmap is given, upscaling will yield 8x8, not 8x4
	*/

	w=(ULONG)width;
	h=(ULONG)height;
	if (level)
	{
		int i=level;
		while (i)
		{
			w*=2; h*=2; i--;
		}
	}

	if (context->w3dTexBuffer[current] == NULL)
	{
		/*
		** Create a new texture object
		** Get the memory
		*/

		targetsize = (w * h * BytesPerTexel * 4) / 3;
		if (context->w3dTexMemory[current])
			tex_Free(context->w3dTexMemory[current]);
		context->w3dTexMemory[current] = (GLubyte *)tex_Alloc(targetsize);
		if (!context->w3dTexMemory[current])
			return;
	}

	/*
	** Find the starting address for the given mipmap level in the
	** texture memory area
	*/

	target = context->w3dTexMemory[current];
	i = level;
	iw = w; ih=h;

	while (i)
	{
		target += iw * ih * BytesPerTexel;
		i      -- ;
		if (iw>1) iw/=2;
		if (ih>1) ih/=2;
	}

	/*
	** Convert the data to the target address
	*/

	useFormat = MGLConvert(context, pixels, (UWORD *)target, width, height, internalformat, format);

	/*
	** Create a new W3D_Texture if none was present, using the converted
	** data.
	** Otherwise, call W3D_UpdateTexImage
	*/

	if (context->w3dTexBuffer[current] == NULL)
	{
		i=0;
		iw=w;
		ih=h;
		target = context->w3dTexMemory[current];

		while (1)
		{
			miparray[i++] = target;
			if (iw == 1 && ih == 1) break;

			target += iw * ih * BytesPerTexel;
			if (iw > 1)     iw     /= 2;
			if (ih > 1)     ih     /= 2;
		}

		AllocTags[0].ti_Tag  = W3D_ATO_IMAGE;
		AllocTags[0].ti_Data = (ULONG)context->w3dTexMemory[current];

		AllocTags[1].ti_Tag  = W3D_ATO_FORMAT;
		AllocTags[1].ti_Data = useFormat;

		AllocTags[2].ti_Tag  = W3D_ATO_WIDTH;
		AllocTags[2].ti_Data = w;

		AllocTags[3].ti_Tag  = W3D_ATO_HEIGHT;
		AllocTags[3].ti_Data = h;

		AllocTags[4].ti_Tag  = W3D_ATO_MIPMAP;
		AllocTags[4].ti_Data = 0;

		AllocTags[5].ti_Tag  = W3D_ATO_MIPMAPPTRS;
		AllocTags[5].ti_Data = (ULONG)miparray;

		AllocTags[6].ti_Tag  = TAG_DONE;
		AllocTags[6].ti_Data = 0;

		context->w3dTexBuffer[current] = W3D_AllocTexObj(context->w3dContext, &error, AllocTags);

		if (context->w3dTexBuffer[current] == NULL || error != W3D_SUCCESS) return;

		/*
		** Set the appropriate wrap modes, texture env, and filters
		*/
		tex_SetWrap(context, context->WrapS, context->WrapT);
		tex_SetFilter(context, context->MinFilter, context->MagFilter);
		tex_SetEnv(context, context->TexEnv[0]);

	}

#ifndef __PPC__
		UpdateTexImage(context->w3dContext, context->w3dTexBuffer[current],
			target, level, NULL);
#else
		W3D_UpdateTexImage(context->w3dContext, context->w3dTexBuffer[current],
			target, level, NULL);
#endif
}

void GLTexImage2DNoMIP(GLcontext context, GLenum gltarget, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels)
{
	int current;
	ULONG w,h;
	ULONG targetsize;
	ULONG error;
	UBYTE *target;
	ULONG useFormat;
	ULONG BytesPerTexel;
	struct TagItem AllocTags[20];


	if(context->ActiveTexture)
		current = context->VirtualBinding;
	else
		current = context->CurrentBinding;

#ifdef EIGHTBIT_TEXTURES
	if(format == GL_ALPHA || format == GL_LUMINANCE)
		BytesPerTexel = 1;
	else
#endif
		BytesPerTexel = context->w3dBytesPerTexel;

	if(internalformat == GL_RGB5_A1)
	{
		internalformat = GL_RGBA;
	}


	//LOG(3, glTexImage2DNoMIP, "target = %d level=%d, size=%d×%d", gltarget, level, width, height);
	GLFlagError(context, type != GL_UNSIGNED_BYTE && type != MGL_UNSIGNED_SHORT_5_6_5 && type != MGL_UNSIGNED_SHORT_4_4_4_4, GL_INVALID_OPERATION);
	GLFlagError(context, gltarget != GL_TEXTURE_2D, GL_INVALID_ENUM);

	if (type == MGL_UNSIGNED_SHORT_5_6_5 || type == MGL_UNSIGNED_SHORT_4_4_4_4)
	{
	    format = type;
//            kprintf("Texture of MGL_UNSIGNED_SHORT_5_6_5, target = %d, level = %d, size %d×%d\n",
//                        gltarget, level, width, height);
	}

	if (level != 0) return;

	w=(ULONG)width;
	h=(ULONG)height;

	if (context->w3dTexBuffer[current] == NULL)
	{
	/*
	** Create a new texture object
	** Get the memory
	*/

	targetsize = (w * h * BytesPerTexel);

	if (context->w3dTexMemory[current])
		tex_Free(context->w3dTexMemory[current]);
	context->w3dTexMemory[current] = (GLubyte *)tex_Alloc(targetsize);
	if (!context->w3dTexMemory[current])
		return;
	}

	target = context->w3dTexMemory[current];

	/*
	** Convert the data to the target address
	*/
	useFormat = MGLConvert(context, pixels, (UWORD *)target, width, height, internalformat, format);

	/*
	** Create a new W3D_Texture if none was present, using the converted
	** data.
	** Otherwise, call W3D_UpdateTexImage
	*/

	if (context->w3dTexBuffer[current] == NULL)
	{
	W3D_Texture *tex;

	AllocTags[0].ti_Tag  = W3D_ATO_IMAGE;
	AllocTags[0].ti_Data = (ULONG)context->w3dTexMemory[current];

	AllocTags[1].ti_Tag  = W3D_ATO_FORMAT;
	AllocTags[1].ti_Data = useFormat;

	AllocTags[2].ti_Tag  = W3D_ATO_WIDTH;
	AllocTags[2].ti_Data = w;

	AllocTags[3].ti_Tag  = W3D_ATO_HEIGHT;
	AllocTags[3].ti_Data = h;

	AllocTags[4].ti_Tag  = TAG_DONE;
	AllocTags[4].ti_Data = 0;

	tex = W3D_AllocTexObj(context->w3dContext, &error, AllocTags);

	if (tex == NULL || error != W3D_SUCCESS) return;

	context->w3dTexBuffer[current] = tex;

	/*
	** Set the appropriate wrap modes, texture env, and filters
	*/

	tex_SetWrap(context, context->WrapS, context->WrapT);
	tex_SetFilter(context, context->MinFilter, context->MagFilter);
	tex_SetEnv(context, context->TexEnv[0]);

	}
	else
	{
#ifndef __PPC__
	    UpdateTexImage(context->w3dContext, context->w3dTexBuffer[current],
		    context->w3dTexMemory[current], 0, NULL);
#else
	    W3D_UpdateTexImage(context->w3dContext, context->w3dTexBuffer[current],
		    context->w3dTexMemory[current], 0, NULL);
#endif

	}
}




//used for fast update when srcfmt = dstfmt :

#ifdef EIGHTBIT_TEXTURES

inline void tex_UpdateScanlineByte(UBYTE *start, UBYTE *pixels, int numpixels)
{
	int i;

	//update the 8-bit Alpha/Luminance Channel
	//fast copy

	UBYTE *in = (UBYTE*)pixels;
	UBYTE *out = (UBYTE*)start;

	for (i=0; i<numpixels; i++)
	{
		*out++ = *in++;
	}
}
#endif

inline void tex_UpdateScanlineShort(UWORD *start, UBYTE *pixels, int numpixels)
{
	int i;

	UWORD *in = (UWORD*)pixels;
	UWORD *out = (UWORD*)start;

	for (i=0; i<numpixels; i++)
	{
		*out++ = *in++;
	}
}

//Conversion:

inline void tex_UpdateScanlineA8_ARGB(UWORD *start, UBYTE *pixels, int numpixels)
{
	int i;
	UBYTE a;

	for (i=0; i<numpixels; i++)
	{
		a = *pixels++;
		*start++ = ( ((UWORD)a & 0xF0) << 8) | 0x0FFF;
	}
}

inline void tex_UpdateScanlineL8_ARGB(UWORD *start, UBYTE *pixels, int numpixels)
{
	int i;
	UBYTE la,lb,lc;

	for (i=0; i<numpixels; i++)
	{
		la = lb = lc = *pixels++;
		*start++ = ARGBFORM(0xff, la, lb, lc);
	}
}

inline void tex_UpdateScanlineAlpha(UWORD *start, UBYTE *pixels, int numpixels)
{
	int i;
	UBYTE r,g,b,a;
	for (i=0; i<numpixels; i++)
	{
		r=*pixels++;
		g=*pixels++;
		b=*pixels++;
		a=*pixels++;

		*start++ = ARGBFORM(a,r,g,b);
	}
}

inline void tex_UpdateScanlineNoAlpha(UWORD *start, UBYTE *pixels, int numpixels)
{
	int i;
	UBYTE r,g,b;
	for (i=0; i<numpixels; i++)
	{
		r=*pixels++;
		g=*pixels++;
		b=*pixels++;

		*start++ = RGBFORM(r,g,b);
	}
}

inline void tex_UpdateScanlineVerbatim(UBYTE *start, UBYTE *pixels, int numpixels)
{
	memcpy(pixels, start, numpixels);
}


void GLTexSubImage2DNoMIP(GLcontext context, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels);

void GLTexSubImage2D(GLcontext context, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels)
{
	int current;

	if (context->NoMipMapping == GL_TRUE)
	{
		GLTexSubImage2DNoMIP(context, target, level, xoffset, yoffset, width, height, format, type, (void *)pixels);
		return;
	}

	if(context->ActiveTexture)
		current = context->VirtualBinding;
	else
		current = context->CurrentBinding;


	GLFlagError(context, target!=GL_TEXTURE_2D, GL_INVALID_ENUM);
	GLFlagError(context, context->w3dTexBuffer[current] == NULL, GL_INVALID_OPERATION);

//    GLFlagError(context, 1, GL_INVALID_OPERATION);
}

void GLTexSubImage2DNoMIP(GLcontext context, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels)
{
	UBYTE *where;
	UBYTE *from = pixels;
	int current;
	int linelength;
	int sourcelength, sourceunit = 0;
	int i; 
	ULONG BytesPerTexel;

	if(context->ActiveTexture)
		current = context->VirtualBinding;
	else
		current = context->CurrentBinding;

	GLFlagError(context, target!=GL_TEXTURE_2D, GL_INVALID_ENUM);

	GLFlagError(context, context->w3dTexBuffer[context->CurrentBinding] == NULL, GL_INVALID_OPERATION);

	GLFlagError(context, type != GL_UNSIGNED_BYTE, GL_INVALID_ENUM);

#ifdef EIGHTBIT_TEXTURES
	if(format == GL_ALPHA || format == GL_LUMINANCE)
		BytesPerTexel = 1;
	else
#endif
		BytesPerTexel = context->w3dBytesPerTexel;

	switch(format)
	{
		case GL_ALPHA:
		case GL_LUMINANCE:
			sourceunit = 1;
		break;

		case GL_LUMINANCE_ALPHA:
		case MGL_UNSIGNED_SHORT_4_4_4_4:
		case MGL_UNSIGNED_SHORT_5_6_5:
			sourceunit = 2;
		break;

		case GL_RGBA:
		case 4:
			sourceunit = 4;
		break;

		case GL_RGB:
		case 3:
			sourceunit = 3;
		break;

	}

	linelength = context->w3dTexBuffer[current]->texwidth * BytesPerTexel;

	sourcelength = width * sourceunit;

	where = (UBYTE *)context->w3dTexMemory[current]
	  +          linelength * yoffset
	  +          BytesPerTexel * xoffset;

#ifdef EIGHTBIT_TEXTURES
	if(format == GL_ALPHA || format == GL_LUMINANCE)
	{
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineByte(where, from, width);
			where += linelength;
			from  += sourcelength;
		}
	}
	else
#endif
	if(context->w3dTexBuffer[current]->texfmtsrc == W3D_L8A8)
	{
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineShort((UWORD *)where, from, width);
			where += linelength;
			from  += sourcelength;
		}
	}
	else if (context->w3dTexBuffer[current]->texfmtsrc == context->w3dFormat)
	{
	   if(sourceunit == 2)
	   {
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineShort((UWORD *)where, from, width);
			where += linelength;
			from  += sourcelength;
		}
	   }
	   else
	   {
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineNoAlpha((UWORD *)where, from, width);
			where += linelength;
			from  += sourcelength;
		}
	   }
	}
#ifndef EIGHTBIT_TEXTURES
	else if (format == GL_ALPHA)
	{
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineA8_ARGB((UWORD *)where, from, width);
			where += linelength;
			from  += sourcelength;
		}

	}
	else if (format == GL_LUMINANCE)
	{
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineL8_ARGB((UWORD *)where, from, width);
			where += linelength;
			from  += sourcelength;
		}

	}
#endif
	else if (context->w3dTexBuffer[current]->texfmtsrc == context->w3dAlphaFormat)
	{
	   if(sourceunit == 2)
	   {
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineShort((UWORD *)where, from, width);
			where += linelength;
			from  += sourcelength;
		}
	   }
	   else
	   {
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineAlpha((UWORD *)where, from, width);
			where += linelength;
			from  += sourcelength;
		}
	   }
	}
	else
	{
		for (i=0; i<height; i++)
		{
			tex_UpdateScanlineVerbatim((UBYTE *)where, from, width);
			where += linelength;
			from  += sourcelength;
		}
	}

//experimental shortcut
/*
	if(context->w3dContext->CurrentChip == W3D_CHIP_AVENGER_BE)
	{
	   context->w3dTexBuffer[current]->dirty = W3D_TRUE;
	}
	else
	{
*/
	#ifndef __PPC__

	UpdateTexImage(context->w3dContext, context->w3dTexBuffer[current],
	    context->w3dTexMemory[current], 0, NULL);
	#else

	W3D_UpdateTexImage(context->w3dContext, context->w3dTexBuffer[current],
	    context->w3dTexMemory[current], 0, NULL);

	#endif
/*
	}
*/
}

void GLTexGeni(GLcontext context, GLenum coord, GLenum mode, GLenum map)
{
//    GLFlagError(context, 1, GL_INVALID_OPERATION);
}

void GLColorTable(GLcontext context, GLenum target, GLenum internalformat, GLint width, GLenum format, GLenum type, GLvoid *data)
{
	int i;
	GLubyte *palette;
	GLubyte *where;
	GLubyte a,r,g,b;

	GLFlagError(context, width>256, GL_INVALID_VALUE);
	GLFlagError(context, target!=GL_COLOR_TABLE, GL_INVALID_OPERATION);

	palette = (GLubyte *)data;
	where   = (GLubyte *)context->PaletteData;

	GLFlagError(context, where == NULL, GL_INVALID_OPERATION);

	switch(internalformat)
	{
		case 4:
		case GL_RGBA: // convert to argb from...
			switch(format)
			{
				case GL_RGB: // ...RGB, ignoring alpha
					for (i=0; i<width; i++)
					{
						r=*palette++;
						g=*palette++;
						b=*palette++;
						palette++;
						*where++ = r;
						*where++ = g;
						*where++ = b;
					}
					break;
				case GL_RGBA: // ...ARGB with alpha
					for (i=0; i<width; i++)
					{
						a=*palette++;
						r=*palette++;
						g=*palette++;
						b=*palette++;
						*where++ = a;
						*where++ = r;
						*where++ = g;
						*where++ = b;
					}
					break;
			}
			break;
		case 3:
		case GL_RGB: // convert to RGB from...
			switch(format)
			{
				case GL_RGB: // ...RGB without alpha
					for (i=0; i<width; i++)
					{
						r=*palette++;
						g=*palette++;
						b=*palette++;
						*where++ = r;
						*where++ = g;
						*where++ = b;
					}
					break;
				case GL_RGBA: // ...ARGB, assuming alpha == 1
					for (i=0; i<width; i++)
					{
						r=*palette++;
						g=*palette++;
						b=*palette++;
						*where++ = 0xff;
						*where++ = r;
						*where++ = g;
						*where++ = b;
					}
					break;
			}
			break;
	}
	context->PaletteFormat = format;
	context->PaletteSize   = width;
}



void GLActiveTextureARB(GLcontext context, GLenum unit)
{
    GLFlagError(context, (unit < GL_TEXTURE0_ARB || unit > (GL_TEXTURE0_ARB+MAX_TEXUNIT)), GL_INVALID_ENUM);

    context->ActiveTexture = unit - GL_TEXTURE0_ARB;
}
