/*
 * $Id: context.h,v 1.2 2000/10/20 11:32:35 nobody Exp $
 *
 * $Date: 2000/10/20 11:32:35 $
 * $Revision: 1.2 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef __CONTEXT_H
#define __CONTEXT_H

#include "mgl/matrix.h"
#include "mgl/config.h"
#include "mgl/vertexbuffer.h"

#include <intuition/intuition.h>

#ifdef __PPC__
#include <devices/timer.h>

typedef struct LockTimeHandle_s
{
	struct timeval StartTime;
} LockTimeHandle;
#else
typedef struct LockTimeHandle_s
{
	ULONG s_hi, s_lo;
	ULONG e_freq;
} LockTimeHandle;
#endif

struct GLcontext_t;

typedef void (*DrawFn)(struct GLcontext_t *);

typedef enum
{
	MGLKEY_F1, MGLKEY_F2, MGLKEY_F3, MGLKEY_F4, MGLKEY_F5, MGLKEY_F6, MGLKEY_F7, MGLKEY_F8,
	MGLKEY_F9, MGLKEY_F10,
	MGLKEY_CUP, MGLKEY_CDOWN, MGLKEY_CLEFT, MGLKEY_CRIGHT
} MGLspecial;

typedef void (*KeyHandlerFn)(char key);
typedef void (*SpecialHandlerFn)(MGLspecial special_key);
typedef void (*MouseHandlerFn)(GLint x, GLint y, GLbitfield buttons);
typedef void (*IdleFn)(void);

struct GLcontext_t
{
	/*
	** The primitive with which glBegin was called,
	** or GL_BASE if outside glBegin/glEnd
	*/

	GLenum      CurrentPrimitive;

	/*
	** Current error
	*/
	GLenum      CurrentError;

	/*
	** The ModelView/Projection matrix stack.
	** Note that the topmost (= current) matrix is not the
	** top of the stack, but rather one of the ModelView[]/Projection[] below.
	** This makes copying the matrices unnecessary...
	*/
	Matrix      ModelViewStack[MODELVIEW_STACK_SIZE];
	int         ModelViewStackPointer;

	Matrix      ProjectionStack[PROJECTION_STACK_SIZE];
	int         ProjectionStackPointer;

	/*
	** The current ModelView/Projeciton matrix.
	** The matrix multiplication routine will switch between those
	** two to avoid copying stuff.
	*/
	Matrix      ModelView[2];
	GLuint      ModelViewNr;

	#define     CurrentMV (&(context->ModelView[context->ModelViewNr]))
	#define     SwitchMV  context->ModelViewNr = !(context->ModelViewNr)

	Matrix      Projection[2];
	GLuint      ProjectionNr;

	#define     CurrentP (&(context->Projection[context->ProjectionNr]))
	#define     SwitchP  context->ProjectionNr = !(context->ProjectionNr)

	// The current matrix mode (GL_MODELVIEW or GL_PROJECTION)
	GLuint      CurrentMatrixMode;


	/*
	** Vertex buffers
	** A call to glVertex*() will fill one entry of the vertex buffer
	** with the current data. glEnd() will go over this data and
	** draw the primitives based on this.
	*/
	MGLVertex * VertexBuffer;
	GLuint      VertexBufferSize;           // Size of the buffer
	GLuint      VertexBufferPointer;        // Next free entry

	/*
	** Current colors and normals
	*/
	GLuint      ClearColor;
	W3D_Double  ClearDepth;
	MGLColor    CurrentColor;
	MGLNormal   CurrentNormal;
	GLfloat     CurrentTexS, CurrentTexT, CurrentTexQ;
	GLboolean   CurrentTexQValid;

	/*
	** The flag indicates wether the combined matrix is valid or not.
	** If it indicates GL_TRUE, the CombinedMatrix field contains the
	** product of the ModelView and Projection matrix.
	*/
	GLboolean   CombinedValid;
	Matrix      CombinedMatrix;

	/*
	** Scale factors for the transformation of normalized coordinates
	** to window coordinates. The *x and *y values are set by glViewPort.
	** *z is set by glDepthRange, which also sets near and far.
	*/
	GLdouble    sx,sy,sz;
	GLdouble    ax,ay,az;
	GLdouble    near,far;

	// CullFace mode
	GLenum      CurrentCullFace;
	GLenum      CurrentFrontFace;

	// Pixel states
	GLint       PackAlign;
	GLint       UnpackAlign;

	/*
	** GL Rendering States
	*/
	GLboolean   AlphaTest_State;
	GLboolean   Blend_State;
	GLboolean   Texture2D_State;
	GLboolean   TextureGenS_State;
	GLboolean   TextureGenT_State;
	GLboolean   Fog_State;
	GLboolean   Scissor_State;
	GLboolean   CullFace_State;
	GLboolean   DepthTest_State;
	GLboolean   PointSmooth_State;
	GLboolean   Dither_State;
	GLboolean   ZOffset_State;

	/*
	** 'Internal' states
	*/

	GLboolean   FogDirty;
	GLdouble    FogStart;
	GLdouble    FogEnd;

	/*
	** Drawing and clipping functions for the current primitive
	*/

	DrawFn      CurrentDraw;

	/*
	** Warp3D specific stuff
	*/

	W3D_Context *           w3dContext;
	struct Window *         w3dWindow;
	struct Screen *         w3dScreen;
	W3D_Texture **          w3dTexBuffer;
	GLubyte **              w3dTexMemory;
	GLint                   TexBufferSize;
	GLint                   CurrentBinding;
	struct ScreenBuffer *   Buffers[3];
	struct BitMap *         w3dBitMap; // If in windowed mode
	struct RastPort *       w3dRastPort; // for windowed ClipBlit mode
	int                     BufNr;
	int                     NumBuffers;
	W3D_Scissor             scissor;
	GLboolean               w3dLocked;
#ifdef AUTOMATIC_LOCKING_ENABLE
	GLenum                  LockMode;
	LockTimeHandle          LockTime;
#endif
	GLboolean               DoSync;
	ULONG                   w3dChipID;
	ULONG                   w3dFormat;
	ULONG                   w3dAlphaFormat;
	GLint                   w3dBytesPerTexel;

	GLenum                  TexEnv;
	GLenum                  MinFilter;
	GLenum                  MagFilter;
	GLenum                  WrapS;
	GLenum                  WrapT;

	W3D_Fog                 w3dFog;
	ULONG                   w3dFogMode;
	GLfloat                 FogRange;
	GLfloat                 FogMult;
	GLenum                  ShadeModel;
	GLboolean               DepthMask;

	GLboolean               NoMipMapping;
	GLboolean               NoFallbackAlpha;

	KeyHandlerFn            KeyHandler;
	MouseHandlerFn          MouseHandler;
	SpecialHandlerFn        SpecialHandler;
	IdleFn                  Idle;
	GLboolean               Running;

	GLenum              SrcAlpha;
	GLenum              DstAlpha;
	GLboolean               AlphaFellBack;

	GLfloat                 InvRot[9];
	GLboolean       InvRotValid;

	GLboolean       WOne_Hint;

	GLfloat         ZOffset;

	void           *PaletteData;
	GLenum          PaletteFormat;
	GLint           PaletteSize;
};

/*
** The CMATRIX macro give the address of the currently
** active matrix, depending on the matrix mode.
** The OMATRIX macro gives the address of the secondary matrix
** The SMATRIX macro switches the active and backup matrix
*/
#define CMATRIX(context) context->CurrentMatrixMode == GL_MODELVIEW ?\
	(&(context->ModelView[context->ModelViewNr])):\
	(&(context->Projection[context->ProjectionNr]))

#define OMATRIX(context) context->CurrentMatrixMode == GL_MODELVIEW ?\
	(&(context->ModelView[!(context->ModelViewNr)])):\
	(&(context->Projection[!(context->ProjectionNr)]))

#define SMATRIX(context) if (context->CurrentMatrixMode == GL_MODELVIEW)\
	context->ModelViewNr = !(context->ModelViewNr);\
   else context->ProjectionNr = !(context->ProjectionNr)


typedef struct GLcontext_t * GLcontext;

#endif

