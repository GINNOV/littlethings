/*
 * $Id: context.h 210 2006-11-09 11:52:57Z hfrieden $
 *
 * $Date: 2006-11-09 06:52:57 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 210 $
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

#include <mgl/GL.h>
#include "mgl/matrix.h"
#include "mgl/config.h"
#include "mgl/vertexbuffer.h"
#include "mgl/context.h"
#include "mgl/mgltypes.h"
#include "mgl/state.h"

#include <devices/timer.h>
#include <intuition/intuition.h>


struct GLParameters
{
	int newVertexBufferSize;        // Default: 8192 entries in vertex buffer
	int newTextureBufferSize;       // Default: 8192 texture objects
	int newDisplayListArraySize;	// Default: 8192 display-list objects
	int maxDisplayListNesting;		 // Default: 64 nestings in a display-list call
	int newNumberOfBuffers;         // Default: Double buffering
	int newPixelDepth;              // Default: 16 bits per pixel
	GLboolean newWindowMode;      	// Default: Use fullscreen instead of window
	GLboolean clw;                	// Default: Keep workbench open
	GLboolean newNoMipMapping;    	// Default: Do allow mipmapping
	GLboolean newNoFallbackAlpha; 	// Default: Fall back to supported blend mode
	GLboolean newCloseGadget;		// Default: Don't add a close gadget
	GLboolean newStencilBuffer;		// Default: Don't add a stencil buffer
	GLboolean newSizeGadget;
};

typedef struct LockTimeHandle_s
{
	ULONG s_hi, s_lo;
	ULONG e_freq;
} LockTimeHandle;

struct SmartLock_s;


typedef void (*DrawFn)(struct GLcontext_t *);

typedef enum
{
	MGLKEY_F1, MGLKEY_F2, MGLKEY_F3, MGLKEY_F4, MGLKEY_F5, MGLKEY_F6, MGLKEY_F7, MGLKEY_F8,
	MGLKEY_F9, MGLKEY_F10,
	MGLKEY_CUP, MGLKEY_CDOWN, MGLKEY_CLEFT, MGLKEY_CRIGHT
} MGLspecial;

typedef enum
{
	GLCS_COLOR   = 1L<<0,
	GLCS_VERTEX  = 1L<<1,
	GLCS_NORMAL  = 1L<<2,
	GLCS_TEXTURE0= 1L<<3,
	GLCS_TEXTURE1= 1L<<4,
	GLCS_TEXTURE2= 1L<<5,
	GLCS_TEXTURE3= 1L<<6,
	GLCS_MASK    = 0x7f,
} ClientStates;

typedef struct DLOperation_s DLOperation;

typedef struct DisplayList_s{
	DLOperation *firstOp;
} DisplayList;

typedef void (*KeyHandlerFn)(char key);
typedef void (*SpecialHandlerFn)(MGLspecial special_key);
typedef void (*MouseHandlerFn)(GLint x, GLint y, GLbitfield buttons);
typedef void (*IdleFn)(void);


#define FRONT_MAT_INDEX 0
#define BACK_MAT_INDEX 1

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
	** The ModelView/Projection/Texture matrix stack.
	** Note that the topmost (= current) matrix is not the
	** top of the stack, but rather one of the ModelView[]/Projection[] below.
	** This makes copying the matrices unnecessary...
	*/
	Matrix      ModelViewStack[MODELVIEW_STACK_SIZE];
	int         ModelViewStackPointer;

	Matrix      ProjectionStack[PROJECTION_STACK_SIZE];
	int         ProjectionStackPointer;
	
	Matrix		TextureStack[TEXTURE_STACK_SIZE][MAX_TEXTURE_UNITS];
	int			TextureStackPointer[MAX_TEXTURE_UNITS];

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
	
	Matrix		Texture[2][MAX_TEXTURE_UNITS];
	GLuint		TextureNr[MAX_TEXTURE_UNITS];

	#define     CurrentT (&(context->Texture[context->TextureNr[context->texture.ActiveTexture]][context->texture.ActiveTexture]))
	#define     SwitchT  context->TextureNr[context->texture.ActiveTexture] = !(context->TextureNr[context->texture.ActiveTexture])
	

	/*
	** Vertex buffers
	** A call to glVertex*() will fill one entry of the vertex buffer
	** with the current data. glEnd() will go over this data and
	** draw the primitives based on this.
	*/
	MGLVertex * VertexBuffer;
	GLuint *	IndexBuffer;
	GLuint      VertexBufferSize;           // Size of the buffer
	GLuint      VertexBufferPointer;        // Next free entry

	/*
	** Displaylists
	*/
	DisplayList *DisplayListArray;
	GLuint TargetDisplayListIdx;
	DLOperation *TargetDisplayListStart; // Set to 0 if we're not compiling a display-list
	DLOperation *TargetDisplayListEnd;
	GLenum DisplayListCompileError;
	GLenum DisplayListCompileMode;
	GLuint DisplayListArraySize;
	GLint MaxDisplayListNesting; // Default is 64
	GLint DisplayListNestingLevel;
	GLuint DisplayListBaseOffset;

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

	// Number of texture units the driver supports
	GLuint		NumTextureUnits;
								   
	// Current layout for vertex
	uint32 		VertexFormat;

	GLboolean   FogDirty;

	/* Drawing and clipping functions for the current primitive */

	DrawFn      CurrentDraw;

	/*
	** Warp3D specific stuff
	*/

	W3D_Context *           w3dContext;
	struct Window *         w3dWindow;
	struct Screen *         w3dScreen;
	GLboolean				w3dScreenLocked;
	MGLTexture *			w3dTextures;
	GLint                   TexBufferSize;
	GLboolean				ConvertTo16Bit;
	void *					ConvertBuffer;
	GLuint					ConvertBufferSize;
	struct ScreenBuffer *   Buffers[3];
	GLboolean				w3dBitMapAlien;
	struct BitMap *         w3dBitMap; // If in windowed mode
	struct RastPort *       w3dRastPort; // for windowed ClipBlit mode
	int                     BufNr;
	int                     NumBuffers;
	W3D_Scissor             w3dScissor;
	W3D_Scissor				backupScissor;
	GLuint					textureRenderTarget;
	GLboolean               w3dLocked;
#ifdef AUTOMATIC_LOCKING_ENABLE
	GLenum                  LockMode;
	LockTimeHandle          LockTime;
	struct SmartLock_s             *smartLock;
#endif
	GLboolean               DoSync;
	ULONG                   w3dChipID;


	W3D_Fog                 w3dFog;
	ULONG                   w3dFogMode;
	GLfloat                 FogRange;
	GLfloat                 FogMult;


	GLboolean               NoMipMapping;
	GLboolean               NoFallbackAlpha;
	GLboolean               AlphaFellBack;

	GLfloat                 InvRot[9];
	GLboolean       InvRotValid;
	
	Matrix			InverseModelView;
	GLboolean 		InverseModelViewValid;

	GLboolean       WOne_Hint;

	GLfloat			DepthBufferUnit;

	void           *PaletteData;
	GLenum          PaletteFormat;
	GLint           PaletteSize;

	GLfloat         MinTriArea;         /* Minimal area of triangles to be drawn (smaller ones will
					       				 * be rejected) 
					       				 */
	GLubyte*	GeneratedTextures;  /* Array to keep track of generated textures */
	
	GLuint		FrameCode;
	
	GLboolean   GrabMouse;
	
		
	/* Timing */
	GLuint		statFrame;
	struct TimeVal frameStartTime;
	struct TimeVal frameEndTime;
	GLfloat		currentFPS;
	GLfloat		averageFPS;
	GLdouble	accumulatedFPS;
	GLfloat		currentFrameTime;
	GLfloat		averageFrameTime;
	GLdouble	accumulatedFrameTime;
	GLfloat		currentSwapTime;
	GLfloat		averageSwapTime;
	GLdouble 	accumulatedSwapTime;
	GLboolean	enableFPS;
	
	/* ENV_COMBINE extension */
	GLboolean	envCombineSupported;
	GLboolean		combineDirty[MAX_TEXTURE_UNITS];
	
	/* Extension string */
	char *		extensionString;
	
	/* GL_EXT_compiled_vertex_arrays state */
	GLint		LockArraysFirst;
	GLsizei		LockArraysCount;
	GLbitfield	LockedArrays;
	GLuint		TexFrameCode;
	GLuint		TransformFrameCode;
	
	GLboolean	DoOpenWorkbench;

	/* Bitmap rasterization */
	GLubyte *	CurrentBitmapBackingStore;
	GLsizei		CurrentBitmapBackingStoreSize;
	
	struct GLParameters Params;
	struct GLContextIFace *Self;
	uint16 *	MousePointer;

	GLboolean	UseZFog;

	GLboolean	NeedEye;
	GLboolean	NeedEyeNormal;

	GLboolean 	Normalize;
	
	/* Server state records */
	struct GLcolor_buffer_state		color_buffer;
	struct GLcurrent_state			current;
	struct GLdepth_buffer_state		depth_buffer;
	struct GLenable_state			enable;
	struct GLfog_state				fog;
	struct GLhint_state				hint;
	struct GLlighting_state			lighting;
	struct GLline_state				line;
	struct GLpoint_state			point;
	struct GLpolygon_state			polygon;
	struct GLpolygon_stipple_state	polygon_stipple;
	struct GLscissor_state			scissor;
	struct GLstencil_buffer_state	stencil_buffer;
	struct GLtexture_state			texture;
	struct GLtransform_state		transform;
	struct GLviewport_state			viewport;
	
	/* Client state records */
	struct GLvertex_array_state		vertex_array;
	struct GLpixel_store_state		pixel_store;
	
	/* Server attribute stack */
	GLuint		AttribStackPointer;
	GLuint		AttribStackBits[ATTRIB_STACK_SIZE];
	
	struct GLcolor_buffer_state		color_buffer_stack[ATTRIB_STACK_SIZE];
	struct GLcurrent_state			current_stack[ATTRIB_STACK_SIZE];
	struct GLdepth_buffer_state		depth_buffer_stack[ATTRIB_STACK_SIZE];
	struct GLenable_state			enable_stack[ATTRIB_STACK_SIZE];
	struct GLfog_state				fog_stack[ATTRIB_STACK_SIZE];
	struct GLhint_state				hint_stack[ATTRIB_STACK_SIZE];
	struct GLlighting_state			lighting_stack[ATTRIB_STACK_SIZE];
	struct GLline_state				line_stack[ATTRIB_STACK_SIZE];
	struct GLpoint_state			point_stack[ATTRIB_STACK_SIZE];
	struct GLpolygon_state			polygon_stack[ATTRIB_STACK_SIZE];
	struct GLpolygon_stipple_state	polygon_stipple_stack[ATTRIB_STACK_SIZE];
	struct GLscissor_state			scissor_stack[ATTRIB_STACK_SIZE];
	struct GLstencil_buffer_state	stencil_buffer_stack[ATTRIB_STACK_SIZE];
	struct GLtexture_state			texture_stack[ATTRIB_STACK_SIZE];
	struct GLtransform_state		transform_stack[ATTRIB_STACK_SIZE];
	struct GLviewport_state			viewport_stack[ATTRIB_STACK_SIZE];
	
	
	/* Server attribute stack */
	uint32		ClientAttribStackPointer;
	uint32		ClientAttribStackBits[ATTRIB_STACK_SIZE];

	struct GLvertex_array_state		vertex_array_stack[ATTRIB_STACK_SIZE];
	struct GLpixel_store_state		pixel_store_stack[ATTRIB_STACK_SIZE];
};


typedef struct GLUTcontext_t * GLUTcontext;
struct GLUTcontext_t
{
	GLbitfield	GlutEvent;
	GLboolean	GlutSingle;
	
	GLuint		newX, newY;		/* Reposition event */
	GLuint		newW, newH;		/* Reshape event */
	GLuint		GlutW, GlutH;
	char *		IconName;
	
	void		(*glutDisplayFunc)(void);
	void		(*glutReshapeFunc)(int width, int height);
	void		(*glutKeyboardFunc)(unsigned char key, int x, int y);
	void		(*glutMouseFunc)(int button, int state, int x, int y);
	void		(*glutMotionFunc)(int x, int y);
	void		(*glutPassiveMotionFunc)(int x, int y);
	void		(*glutVisibilityFunc)(int state);
	void		(*glutEntryFunc)(int state);
	void		(*glutSpecialFunc)(int key, int x, int y);
	void		(*glutIdleFunc)(void);
	
	struct TimeVal __glutStartTime;
	GLuint __glutWindowX;
	GLuint __glutWindowY;
	GLuint __glutWindowWidth;
	GLuint __glutWindowHeight;
	GLuint __glutDisplayMode;
	struct GLContextIFace *__glutContext;
	GLcontext glctx;
};

/*
** The CMATRIX macro give the address of the currently
** active matrix, depending on the matrix mode.
** The OMATRIX macro gives the address of the secondary matrix
** The SMATRIX macro switches the active and backup matrix
*/
/*
#define CMATRIX(context) context->CurrentMatrixMode == GL_MODELVIEW ?\
	(&(context->ModelView[context->ModelViewNr])):\
	(&(context->Projection[context->ProjectionNr]))
*/
static inline Matrix *CMATRIX(GLcontext context)
{
	switch (context->transform.CurrentMatrixMode)
	{
		case GL_MODELVIEW:
			return &context->ModelView[context->ModelViewNr];
		case GL_PROJECTION:
			return &context->Projection[context->ProjectionNr];
		case GL_TEXTURE:
			return &context->Texture[context->TextureNr[context->texture.ActiveTexture]][context->texture.ActiveTexture];
	}
	
	return 0;
};

/*
#define OMATRIX(context) context->CurrentMatrixMode == GL_MODELVIEW ?\
	(&(context->ModelView[!(context->ModelViewNr)])):\
	(&(context->Projection[!(context->ProjectionNr)]))
*/
static inline Matrix *OMATRIX(GLcontext context)
{
	switch (context->transform.CurrentMatrixMode)
	{
		case GL_MODELVIEW:
			return &context->ModelView[!context->ModelViewNr];
		case GL_PROJECTION:
			return &context->Projection[!context->ProjectionNr];
		case GL_TEXTURE:
			return &context->Texture[!context->TextureNr[context->texture.ActiveTexture]][context->texture.ActiveTexture];
	}
	
	return 0;
};

/*
#define SMATRIX(context) if (context->CurrentMatrixMode == GL_MODELVIEW)\
	context->ModelViewNr = !(context->ModelViewNr);\
  else context->ProjectionNr = !(context->ProjectionNr)
*/
static inline void SMATRIX(GLcontext context)
{
	switch (context->transform.CurrentMatrixMode)
	{
		case GL_MODELVIEW:
			context->ModelViewNr = !context->ModelViewNr;
			break;
		case GL_PROJECTION:
			context->ProjectionNr = !context->ProjectionNr;
			break;
		case GL_TEXTURE:
			context->TextureNr[context->texture.ActiveTexture] = 
				!context->TextureNr[context->texture.ActiveTexture];
			break;
	}
}
#endif

