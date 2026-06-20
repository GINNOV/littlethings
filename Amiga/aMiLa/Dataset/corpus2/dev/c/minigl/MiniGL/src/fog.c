/*
 * $Id: fog.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $
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

static char rcsid[] = "$Id: fog.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $";

void GLFogf(GLcontext context, GLenum pname, GLfloat param)
{
	context->FogDirty = GL_TRUE;

	switch(pname)
	{
		case GL_FOG_MODE:
			switch((GLint)param)
			{
				case GL_LINEAR:
					context->w3dFogMode = W3D_FOG_LINEAR;
					break;
				case GL_EXP:
					context->w3dFogMode = W3D_FOG_EXP;
					break;
				case GL_EXP2:
					context->w3dFogMode = W3D_FOG_EXP_2;
					break;
				default:
					GLFlagError(context, 1, GL_INVALID_ENUM);
			}
			break;

		case GL_FOG_DENSITY:
			GLFlagError(context, param<0, GL_INVALID_VALUE);
			context->w3dFog.fog_density = (W3D_Float)param;
			break;

		case GL_FOG_START:
			context->FogStart = param;
			break;

		case GL_FOG_END:
			context->FogEnd   = param;
			break;

		case GL_FOG_INDEX:
			GLFlagError(context, 1, GL_INVALID_ENUM);
			break;

		default:
			GLFlagError(context, 1, GL_INVALID_ENUM);
			break;
	}
}



void GLFogfv(GLcontext context, GLenum pname, GLfloat *param)
{
	context->FogDirty = GL_TRUE;

	switch(pname)
	{
		case GL_FOG_MODE:
			switch((GLint)*param)
			{
				case GL_LINEAR:
					context->w3dFogMode = W3D_FOG_LINEAR;
					break;
				case GL_EXP:
					context->w3dFogMode = W3D_FOG_EXP;
					break;
				case GL_EXP2:
					context->w3dFogMode = W3D_FOG_EXP_2;
					break;
				default:
					GLFlagError(context, 1, GL_INVALID_ENUM);
			}
			break;

		case GL_FOG_DENSITY:
			GLFlagError(context, *param<0, GL_INVALID_VALUE);
			context->w3dFog.fog_density = (W3D_Float)(*param);
			break;
		case GL_FOG_START:
			context->FogStart = *param;
			break;
		case GL_FOG_END:
			context->FogEnd   = *param;
			break;
		case GL_FOG_INDEX:
			GLFlagError(context, 1, GL_INVALID_ENUM);
			break;
		case GL_FOG_COLOR:
			context->w3dFog.fog_color.r = (W3D_Float)*param;
			context->w3dFog.fog_color.g = (W3D_Float)*(param+1);
			context->w3dFog.fog_color.b = (W3D_Float)*(param+2);
			break;
		default:
			GLFlagError(context, 1, GL_INVALID_ENUM);
			break;
	}
}

static float fog_Clamp(float f)
{
	if (f > 1.0)
		f = 1.0;

	if (f < 0.0)
		f = 0.0;

	return f;
}

void fog_Set(GLcontext context)
{
	ULONG error;

	context->w3dFog.fog_start = fog_Clamp(-1.0 / ((context->FogStart) * (CurrentP->v[OF_43]) + (CurrentP->v[OF_44])));
	context->w3dFog.fog_end   = fog_Clamp(-1.0 / ((context->FogEnd)   * (CurrentP->v[OF_43]) + (CurrentP->v[OF_44])));

	error = W3D_SetFogParams(context->w3dContext, &(context->w3dFog), context->w3dFogMode);
	if (error == W3D_UNSUPPORTEDFOG)
	{
		context->w3dFogMode = W3D_FOG_INTERPOLATED;
		error = W3D_SetFogParams(context->w3dContext, &(context->w3dFog), context->w3dFogMode);
	}
}

