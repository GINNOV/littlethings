/*
 * $Id: others.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $
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

#include <stdio.h>
#include <stdlib.h>

static char rcsid[] = "$Id: others.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $";


#ifndef __PPC__
extern struct IntuitionBase *IntuitionBase;
extern struct ExecBase *SysBase;
#endif

void GLAlphaFunc(GLcontext context, GLenum func, GLclampf ref)
{
	ULONG w3dmode;
	W3D_Float refvalue = (W3D_Float)ref;

	GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);

	switch(func)
	{
		case GL_NEVER:
			w3dmode = W3D_A_NEVER;
			break;
		case GL_LESS:
			w3dmode = W3D_A_LESS;
			break;
		case GL_EQUAL:
			w3dmode = W3D_A_EQUAL;
			break;
		case GL_LEQUAL:
			w3dmode = W3D_A_LEQUAL;
			break;
		case GL_GREATER:
			w3dmode = W3D_A_GREATER;
			break;
		case GL_NOTEQUAL:
			w3dmode = W3D_A_NOTEQUAL;
			break;
		case GL_GEQUAL:
			w3dmode = W3D_A_GEQUAL;
			break;
		case GL_ALWAYS:
			w3dmode = W3D_A_ALWAYS;
			break;
		default:
			GLFlagError(context, 1, GL_INVALID_ENUM);
			break;
	}

	W3D_SetAlphaMode(context->w3dContext, w3dmode, &refvalue);
}


void GLDrawBuffer(GLcontext context, GLenum mode)
{
}

void GLPolygonMode(GLcontext context, GLenum face, GLenum mode)
{
   context->CurPolygonMode = mode ;
   return ;
}

void GLShadeModel(GLcontext context, GLenum mode)
{
	//LOG(2, glShadeModel, "%d", mode);

      context->CurShadeModel = mode ;

//avoid excessive state changes:

   if(context->CurShadeModel != context->ShadeModel)
   {
	context->ShadeModel = mode;

	if (mode == GL_FLAT)
	{
		W3D_SetState(context->w3dContext, W3D_GOURAUD, W3D_DISABLE);
	}
	else if (mode == GL_SMOOTH)
	{
		W3D_SetState(context->w3dContext, W3D_GOURAUD, W3D_ENABLE);
	}
   }
}



#define BLS(X) case GL_##X: src=W3D_##X; break
#define BLD(X) case GL_##X: dest=W3D_##X; break

void GLBlendFunc(GLcontext context, GLenum sfactor, GLenum dfactor)
{
	ULONG src, dest;

   if((context->CurBlendSrc == sfactor) && (context->CurBlendDst == dfactor))
	return;


	context->CurBlendSrc = sfactor ;
	context->CurBlendDst = dfactor ;

	switch(sfactor)
	{
		BLS(ZERO);
		BLS(ONE);
		BLS(DST_COLOR);
		BLS(ONE_MINUS_DST_COLOR);
		BLS(SRC_ALPHA);
		BLS(ONE_MINUS_SRC_ALPHA);
		BLS(DST_ALPHA);
		BLS(ONE_MINUS_DST_ALPHA);
		BLS(SRC_ALPHA_SATURATE);
	default:
		GLFlagError(context, 1, GL_INVALID_ENUM);
	}

	switch(dfactor)
	{
		BLD(ZERO);
		BLD(ONE);
		BLD(SRC_COLOR);
		BLD(ONE_MINUS_SRC_COLOR);
		BLD(SRC_ALPHA);
		BLD(ONE_MINUS_SRC_ALPHA);
		BLD(DST_ALPHA);
		BLD(ONE_MINUS_DST_ALPHA);
	}

	// Try to set the mode, if unavailable, switch to
	// (SRC_ALPHA, ONE_MINUS_SRC_ALPHA) which is supported
	// by almost all Amiga supported graphics cards

	if (W3D_SetBlendMode(context->w3dContext, src, dest) == W3D_UNSUPPORTEDBLEND)
	{
		if (context->NoFallbackAlpha == GL_FALSE)
		{
			W3D_SetBlendMode(context->w3dContext, W3D_SRC_ALPHA, W3D_ONE_MINUS_SRC_ALPHA);
			context->AlphaFellBack = GL_TRUE;
		}
		else
		{
			context->AlphaFellBack = GL_FALSE;
		}
	}
	else
	{
		context->AlphaFellBack = GL_FALSE;
	}

	context->SrcAlpha = sfactor;
	context->DstAlpha = dfactor;
}


void GLHint(GLcontext context, GLenum target, GLenum mode)
{
	ULONG hint;
	switch(mode)
	{
		case GL_FASTEST:    hint = W3D_H_FAST; break;
		case GL_NICEST:     hint = W3D_H_NICE; break;
		case GL_DONT_CARE:  hint = W3D_H_AVERAGE; break;
		default:
			GLFlagError(context, 1, GL_INVALID_ENUM);
			break;
	}

	switch(target)
	{
		case GL_FOG_HINT:
			W3D_Hint(context->w3dContext, W3D_H_FOGGING, hint);
			break;
		case GL_PERSPECTIVE_CORRECTION_HINT:
			W3D_Hint(context->w3dContext, W3D_H_PERSPECTIVE, hint);
			break;
		case MGL_W_ONE_HINT:
			if (mode == GL_FASTEST) context->WOne_Hint = GL_TRUE;
			else            context->WOne_Hint = GL_FALSE;
			break;
		case MGL_FIXPOINTTRANS_HINT:
			if (mode == GL_FASTEST) context->FixpointTrans_Hint = GL_TRUE;
			else            context->FixpointTrans_Hint = GL_FALSE;
			break;
		default:
			GLFlagError(context, 1, GL_INVALID_ENUM);
	}
}


void  GLGetBooleanv(GLcontext context, GLenum pname, GLboolean *params)
{
	switch( pname )
   {
      case GL_DEPTH_TEST:
      	*params = context->CurDepthTest ;
         return ;

      case GL_DEPTH_WRITEMASK:
      	*params = context->CurWriteMask ;
         return ;

      default:
      	*params = GL_FALSE ;
         GLFlagError(context, 1, GL_INVALID_ENUM);
	return ;
   }

}


void  GLGetIntegerv(GLcontext context, GLenum pname, GLint *params)
{
	switch( pname )
   {
      case GL_POLYGON_MODE:
      	*params = context->CurPolygonMode ;
         return ;

      case GL_SHADE_MODEL:
      	*params = context->CurShadeModel ;
         return ;

      case GL_BLEND_SRC:
      	*params = context->CurBlendSrc ;
         return ;

      case GL_BLEND_DST:
      	*params = context->CurBlendDst ;
         return ;

      case GL_MAX_TEXTURE_SIZE:
      	*params = 256 ;
         return ;

      case GL_UNPACK_ROW_LENGTH:
      	*params = context->CurUnpackRowLength ;
         return ;

      case GL_UNPACK_SKIP_PIXELS:
      	*params = context->CurUnpackSkipPixels ;
         return ;

      case GL_UNPACK_SKIP_ROWS:
      	*params = context->CurUnpackSkipRows ;
         return ;

	case GL_MAX_TEXTURE_UNITS_ARB:
		*params = MAX_TEXUNIT;
	   return ;
      default:
      	*params = 0 ;
         GLFlagError(context, 1, GL_INVALID_ENUM);
	return ;
   }

}


const GLubyte * GLGetString(GLcontext context, GLenum name)
{
	switch(name)
	{
		case GL_RENDERER:
			if (context->w3dContext)
			{
				switch(context->w3dContext->CurrentChip)
				{
					case W3D_CHIP_VIRGE:
						return "MiniGL/Warp3D S3 ViRGE (virge)";
					case W3D_CHIP_PERMEDIA2:
						return "MiniGL/Warp3D 3DLabs Permedia 2 (permedia)";
					case W3D_CHIP_VOODOO1:
						return "MiniGL/Warp3D 3DFX Voodoo 1 (voodoo)";
					case W3D_CHIP_AVENGER_BE:
					case W3D_CHIP_AVENGER_LE:
						return "MiniGL/Warp3D 3DFX Voodoo 3 (avenger)";

					case W3D_CHIP_UNKNOWN:
						return "MiniGL/Warp3D Unknown graphics chip";
					default:
						return "MiniGL/Warp3D";
				}
			}
			else
			{
				return "MiniGL/Warp3D";
			}

		case GL_VENDOR:     return "Hyperion";
		case GL_VERSION:    return "1.1";
		case GL_EXTENSIONS:
			switch(context->w3dContext->CurrentChip)
			{
			    case W3D_CHIP_AVENGER_BE:
			    case W3D_CHIP_AVENGER_LE:
			    case W3D_CHIP_PERMEDIA2:
				return "GL_MGL_ARB_multitexture GL_EXT_compiled_vertex_array GL_MGL_packed_pixels GL_EXT_color_table";
			}
			return "GL_MGL_packed_pixels GL_EXT_color_table";

		default:            return "Huh?";
	}
}

void GLGetFloatv(GLcontext context, GLenum pname, GLfloat *params)
{
	int i;

	switch(pname)
	{
		case GL_MODELVIEW_MATRIX:
			for (i=0; i<16; i++)
			{
				*params = context->ModelView[context->ModelViewNr].v[i];
				params++;
			}
			return;
		case GL_PROJECTION_MATRIX:
			for (i=0; i<16; i++)
			{
				*params = context->Projection[context->ProjectionNr].v[i];
				params++;
			}
			return;

		default:
			GLFlagError(context, 1, GL_INVALID_ENUM);
			return;
	}
}

GLenum GLGetError(GLcontext context)
{
	GLenum ret = context->CurrentError;
	context->CurrentError = GL_NO_ERROR;
	return ret;
}

GLboolean GLIsEnabled(GLcontext context, GLenum cap)
{
	switch(cap)
	{
   	case GL_BLEND:
         return( context->Blend_State ) ;

      case GL_DEPTH_TEST:
         return( context->DepthTest_State ) ;

	case GL_TEXTURE_2D:
	   	return (context->Texture2D_State[context->ActiveTexture]) ;

	default:
	#ifndef __VBCC__
		GLFlagError(context, 1, GL_INVALID_ENUM);
	#else
		return GL_FALSE;
	#endif
	}
}


void MGLSetZOffset(GLcontext context, GLfloat offset)
{
	context->ZOffset = offset;
}

void MGLWriteShotPPM(GLcontext context, char *filename)
{
	GLubyte *pixelline;
	FILE *f;
	int i;
	size_t bytes;

	pixelline = (GLubyte *)malloc(context->w3dWindow->Width*3);
	if (!pixelline) return;

	f = fopen(filename, "wb");
	if (!f)
	{
		free(pixelline);
		return;
	}

	// Write PPM header
	fprintf(f, "P6\n%d %d\n255\n", context->w3dWindow->Width,
	context->w3dWindow->Height);

	for (i=0; i<context->w3dWindow->Height; i++)
	{
		(void)ReadPixelArray(pixelline, 0, 0, context->w3dWindow->Width, context->w3dWindow->RPort,
			0, (UWORD)i, context->w3dWindow->Width, 1, RECTFMT_RGB);
		bytes = fwrite(pixelline, context->w3dWindow->Width*3, 1, f);
	}

	fclose(f);
	free(pixelline);
}

// NYI:
void GLReadPixels(GLcontext context, GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels)
{
	GLubyte *pixelrect;
	GLubyte *dest;
	int i;

	pixelrect = (GLubyte *)malloc(context->w3dWindow->Width*context->w3dWindow->Height*3);
	if (!pixelrect)
		return;

	dest = pixelrect;

	for (i=0; i<context->w3dWindow->Height; i++)
	{
		(void)ReadPixelArray(dest, 0, 0, context->w3dWindow->Width, context->w3dWindow->RPort, 0, (UWORD)i, context->w3dWindow->Width, 1, RECTFMT_RGB);

		dest += context->w3dWindow->Width * 3;
	}

	//convert and copy to *pixels ....


	free(pixelrect);
}

void MGLKeyFunc(GLcontext context, KeyHandlerFn k)
{
	context->KeyHandler = k;
}

void MGLSpecialFunc(GLcontext context, SpecialHandlerFn s)
{
	context->SpecialHandler = s;
}

void MGLMouseFunc(GLcontext context, MouseHandlerFn m)
{
	context->MouseHandler = m;
}

void MGLIdleFunc(GLcontext context, IdleFn i)
{
	context->Idle = i;
}

void MGLExit(GLcontext context)
{
	context->Running = GL_FALSE;
}

void MGLMainLoop(GLcontext context)
{
	// FIXME: This should become 68k
	struct IntuiMessage *imsg;
	struct Window *window;
	ULONG Class;
	UWORD Code;
	WORD MouseX, MouseY;
	GLbitfield buttons = 0;

	window = (struct Window *)mglGetWindowHandle();
	ModifyIDCMP(window, IDCMP_VANILLAKEY|IDCMP_RAWKEY|IDCMP_MOUSEMOVE|IDCMP_MOUSEBUTTONS);

	context->Running = GL_TRUE;

	while (context->Running == GL_TRUE)
	{
		while (imsg = (struct IntuiMessage *)GetMsg(window->UserPort))
		{
			Class  = imsg->Class;
			Code   = imsg->Code;
			MouseX = imsg->MouseX;
			MouseY = imsg->MouseY;
			ReplyMsg((struct Message *)imsg);
			switch(Class)
			{
			case IDCMP_VANILLAKEY:
				if (context->KeyHandler)
				{
					context->KeyHandler((char)Code);
				}
				break;
			case IDCMP_MOUSEBUTTONS:
				switch(Code)
				{
					case SELECTDOWN: buttons |= MGL_BUTTON_LEFT;    break;
					case SELECTUP:   buttons &= ~MGL_BUTTON_LEFT;   break;
					case MENUDOWN:   buttons |= MGL_BUTTON_RIGHT;   break;
					case MENUUP:     buttons &= ~MGL_BUTTON_RIGHT;  break;
					case MIDDLEDOWN: buttons |= MGL_BUTTON_MID;     break;
					case MIDDLEUP:   buttons &= MGL_BUTTON_MID;     break;
				}
			// drop through
			case IDCMP_MOUSEMOVE:
				if (context->MouseHandler)
				{
					context->MouseHandler((GLint)MouseX, (GLint)MouseY, buttons);
				}
				break;
			} /* switch Class */
		} /* While imsg */

		if (context->Idle)
		{
			context->Idle();
		}
	} /* While running */
}


