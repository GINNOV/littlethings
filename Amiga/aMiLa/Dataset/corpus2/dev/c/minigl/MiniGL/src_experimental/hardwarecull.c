/*
** 02-04-02
**
** MiniGL Interface to hardware backface culling by surgeon.
** Note that this interface is not yet tested with MiniGL.
**
** Implementation:
**
** The MGLSetHardwareCull function should be called from
** MGLSetstate function when the parameter is GL_CULL_FACE
** and with the assiciated flag propagandated.
**
** The MGLUpdateHardwareCull function should be called
** from GLFrontFace and GLEnd with parameter 0, and in
** d_DrawTriangleStrip in all cases where a clipped or
** culled strip is drawn, with the original
** vertexbuffer-position of the first vertex as parameter.
** With strip-sections, it is important that
** context->CurrentCullSign has not been flipped because it
** is used as reference.
**
**
** Optimizing performance:
**
** W3D functions will only be called if needed. Therfore,
** it will be beneficial for performance to sort clipped
** strip-sections by clockwise/counter-clockwise
** vertexorder of the first triangle before calling
** MGLUpdateHardwareCull. Use parameter 1 if the first
** triangle in a section has reversed vertexorder.
** For optimal performance, those "uneven" primitives should
** be drawn last to ensure max 2 W3D_FrontFace calls pr
** rendered mesh (the original strip).
*/

#include "sysinc.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define CLEANACCESS 1

static GLint PrevCullSign = 0;
static GLboolean HWCull_IsEnabled = GL_FALSE;

void MGLSetHardwareCull(GLcontext context, const GLboolean flag)
{
	if (context->w3dChipID == W3D_CHIP_VIRGE)
		return; //does not support culling in hardware

	if(flag == GL_FALSE || context->CurrentCullSign == 0)
	{
		PrevCullSign = 0;

		if(HWCull_IsEnabled == GL_FALSE)
		{
			return;
		}
		else
		{
			W3D_SetState(context->w3dContext, W3D_CULLFACE, W3D_DISABLE);

			HWCull_IsEnabled = GL_FALSE;
		}
	}
	else
	{
		if(HWCull_IsEnabled == GL_FALSE)
		{
			W3D_SetState(context->w3dContext, W3D_CULLFACE, W3D_ENABLE);

			HWCull_IsEnabled = GL_TRUE;
		}

		if(PrevCullSign == context->CurrentCullSign)
		{
			return;
		}
		else if(context->CurrentCullSign == 1)
		{
#ifdef CLEANACCESS
			W3D_SetFrontFace(context->w3dContext, W3D_CCW):
#else
			context->w3dContext->FrontFaceOrder = W3D_CCW;
#endif
		}
		else if(context->CurrentCullSign == -1)
		{
#ifdef CLEANACCESS
			W3D_SetFrontFace(context->w3dContext, W3D_CW):
#else
			context->w3dContext->FrontFaceOrder = W3D_CW;
#endif
		}

	PrevCullSign = context->CurrentCullSign;
	}
}



//NOTE: vstart is needed when a strip is sectioned

void MGLUpdateHardwareCull(GLcontext context, GLuint vstart)
{
	GLint cull_sign;

	if (context->w3dChipID == W3D_CHIP_VIRGE)
		return; //does not support culling in hardware

	cull_sign = context->CurrentCullSign;

	if(cull_sign == 0 && HWCull_IsEnabled == GL_TRUE)
	{
		MGLSetHardwareCull(context, GL_FALSE);
		return;
	}

	if(PrevCullSign == 0)
	{
		MGLSetHardwareCull(context, GL_TRUE);
	}


	if(vstart > 0)
	{
		if(vstart%2)
		cull_sign = -cull_sign; //invert
	}

	if(cull_sign == PrevCullSign)
	{
		return;
	}
	else
	{
		PrevCullSign = cull_sign;
	}

	if(cull_sign == 1)
	{
#ifdef CLEANACCESS
		W3D_SetFrontFace(context->w3dContext, W3D_CCW):
#else
		context->w3dContext->FrontFaceOrder = W3D_CCW;
#endif
	}
	else
	{
#ifdef CLEANACCESS
		W3D_SetFrontFace(context->w3dContext, W3D_CW):
#else
		context->w3dContext->FrontFaceOrder = W3D_CW;
#endif
	}
}
