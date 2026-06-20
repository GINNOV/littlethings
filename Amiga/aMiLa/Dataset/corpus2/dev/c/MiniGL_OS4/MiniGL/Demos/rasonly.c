/*
 * rasonly.c -
 *  Demonstrates the use of OpenGL for rasterization-only, with
 *  perspective-correct texture mapping.
 *
 * Michael I. Gold <gold@berkelium.com>
 * Silicon Graphics Computer Systems, May 1997
 * NVIDIA Corporation, March 1999
 *
 * Since current low-end 3D accelerators support only rasterization in
 * hardware, a number of developers have expressed interested in using
 * OpenGL as an interface to rasterization hardware while retaining
 * control of transformations and lighting in the application code.
 * Many OpenGL implementations detect and optimize for identity xforms,
 * so this approach is entirely reasonable.
 *
 * Setting up rasterization-only is fairly straightforward.  The projection
 * matrix is set up as a one-to-one mapping between eye and clip coordinates,
 * and the modelview matrix is set up as identity, e.g. object coordinates
 * map directly to eye coordinates.  This can be achieved as follows:
 *
 *  glMatrixMode(GL_PROJECTION);
 *  glLoadIdentity();
 *  glOrtho(0.0f, (GLfloat) width, 0.0f, (GLfloat) height, 0.0f, 1.0f);
 *  glMatrixMode(GL_MODELVIEW);
 *  glLoadIdentity();
 *  glViewport(0, 0, width, height);
 *      glDepthRange(0.0f, 1.0f);
 *
 * where (width, height) represent the window dimensions.
 *
 * Now transformed geometry may be specified directly through the standard
 * interfaces (e.g. glVertex*()).  The only tricky part that remains is
 * specifying texture coordinates such that perspective correction may
 * occur.  The answer is to use glTexCoord4*(), and perform the perspective
 * divide on the texture coordinates directly.
 *
 * Changes -
 *
 * 3/14/1999
 * Fixed glOrtho z-mapping, was [-1,1], should have been [0,1].
 * Explicitly set glDepthRange to [0,1].
 * Thanks to Jonathon Wolfe <jwolfe@lclark.edu> for the bug report!
 */

/*
 * Adapted to MiniGL
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <mgl/gl.h>
#include <assert.h>

GLboolean motion = GL_TRUE;
void Motion(void);

/* Matrices */
GLfloat rot = 0.0f;
GLfloat ModelView[16];
GLfloat Projection[16];
GLfloat Viewport[4];

/* Sample geometry */
GLfloat quadV[][4] = {
	{ -1.0f, 0.0f, -1.0f, 1.0f },
	{  1.0f, 0.0f, -1.0f, 1.0f },
	{  1.0f, 0.5f, -0.2f, 1.0f },
	{ -1.0f, 0.5f, -0.2f, 1.0f },
};

GLfloat quadC[][3] = {
	{ 1.0f, 0.0f, 0.0f },
	{ 0.0f, 1.0f, 0.0f },
	{ 0.0f, 0.0f, 1.0f },
	{ 1.0f, 1.0f, 1.0f },
};

GLfloat quadT[][2] = {
	{ 0.0f, 0.0f },
	{ 0.0f, 1.0f },
	{ 1.0f, 1.0f },
	{ 1.0f, 0.0f },
};

/*********************************************************************
 * Utility functions
 */

int texWidth = 128;
int texHeight = 128;

/* Create and download the application texture map */
static void
setCheckedTexture(void)
{
	int texSize;
	void *textureBuf;
	GLubyte *p;
	int i,j;

	/* malloc for rgba as worst case */
	texSize = texWidth*texHeight*4;

	textureBuf = malloc(texSize);
	if (NULL == textureBuf) return;

	p = (GLubyte *)textureBuf;
	for (i=0; i < texWidth; i++) {
		for (j=0; j < texHeight; j++) {
			if ((i ^ j) & 8) {
				p[0] = 0xff; p[1] = 0xff; p[2] = 0xff; p[3] = 0xff;
			} else {
				p[0] = 0x08; p[1] = 0x08; p[2] = 0x08; p[3] = 0xff;
			}
			p += 4;
		}
	}

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight,
			0, GL_RGBA, GL_UNSIGNED_BYTE, textureBuf);

	free(textureBuf);
}

/* Perform one transform operation */
static void
Transform(GLfloat *matrix, GLfloat *in, GLfloat *out)
{
	int ii;

	for (ii=0; ii<4; ii++) {
		out[ii] =
			in[0] * matrix[0*4+ii] +
			in[1] * matrix[1*4+ii] +
			in[2] * matrix[2*4+ii] +
			in[3] * matrix[3*4+ii];
	}
}

/* Transform a vertex from object coordinates to window coordinates.
 * Lighting is left as an exercise for the reader.
 */
static void
DoTransform(GLfloat *in, GLfloat *out)
{
	GLfloat tmp[4];
	GLfloat invW;   /* 1/w */

	/* Modelview xform */
	Transform(ModelView, in, tmp);

	/* Lighting calculation goes here! */

	/* Projection xform */
	Transform(Projection, tmp, out);

	if (out[3] == 0.0f) /* do what? */
		return;

	invW = 1.0f / out[3];

	/* Perspective divide */
	out[0] *= invW;
	out[1] *= invW;
	out[2] *= invW;

	/* Map to 0..1 range */
	out[0] = out[0] * 0.5f + 0.5f;
	out[1] = out[1] * 0.5f + 0.5f;
	out[2] = out[2] * 0.5f + 0.5f;

	/* Map to viewport */
	out[0] = out[0] * Viewport[2] + Viewport[0];
	out[1] = out[1] * Viewport[3] + Viewport[1];

	/* Store inverted w for performance */
	out[3] = invW;
}

/*********************************************************************
 * Application code begins here
 */

/* For the sake of brevity, I'm use OpenGL to compute my matrices. */
void UpdateModelView(void)
{
	glPushMatrix();
	glLoadIdentity();
	gluLookAt(0.0f, 1.0f, -4.0f,
		  0.0f, 0.0f, 0.0f,
		  0.0f, 1.0f, 0.0f);
	glRotatef(rot, 0.0f, 1.0f, 0.0f);
	/* Retrieve the matrix */
	glGetFloatv(GL_MODELVIEW_MATRIX, ModelView);
	glPopMatrix();
}

void InitMatrices(void)
{
	/* Calculate projection matrix */
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	gluPerspective(45.0f, 1.0f, 1.0f, 100.0f);
	/* Retrieve the matrix */
	glGetFloatv(GL_PROJECTION_MATRIX, Projection);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	UpdateModelView();
}

void Init()
{
	glClearColor(0.2f, 0.2f, 0.6f, 1.0f);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glEnable(GL_TEXTURE_2D);
	setCheckedTexture();

	InitMatrices();
}

void Redraw(void)
{
	GLfloat tmp[4];
	int ii;
//
	mglLockDisplay();

	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

//        glBegin(GL_QUADS);
	glBegin(GL_TRIANGLE_FAN);


	for (ii = 0; ii < 4; ii++) {

		/* Transform a vertex from object to window coordinates.
		 * 1/w is returned as tmp[3] for perspective-correcting
		 * the texture coordinates.
		 */
		DoTransform(quadV[ii], tmp);

		/* Ideally the colors will be computed by the lighting equation,
		 * but I've hard-coded values for this example.
		 */
		glColor3fv(quadC[ii]);

		/* Scale by 1/w (stored in tmp[3]) */
		glTexCoord4f(quadT[ii][0] * tmp[3],
				 quadT[ii][1] * tmp[3], 0.0f, tmp[3]);

		/* Note I am using Vertex3, not Vertex4, since we have already
		 * performed the perspective divide.
		 */
		glVertex3fv(tmp);
	}

	glEnd();

//	mglUnlockDisplay();
//	mglSwitchDisplay();

	if (motion)
		Motion();

}

void Motion(void)
{
	rot += 3.0f;
	if (rot >= 360.0f) rot -= 360.0f;
	UpdateModelView();
}


void Key(unsigned char key)
{
	switch (key) {
		case 27:
			exit(0);
			break;
		case 'm':
			motion = !motion;
			break;
	}
}


void Reshape(int width, int height)
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0.0f, (GLfloat) width, 0.0f, (GLfloat) height, -1.0f, 1.0f);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glViewport(0, 0, width, height);
	glDepthRange(0.0f, 1.0f);

	Viewport[0] = Viewport[1] = 0.0f;
	Viewport[2] = (GLfloat) width;
	Viewport[3] = (GLfloat) height;
}


#if 0
int
#ifdef WIN32
__cdecl
#endif
main(int argc, char *argv[])
{
	int width = 640, height = 480;

	mglChooseWindowMode(GL_TRUE);
	MGLInit();
	mglCreateContext(0,0,width,height);

	Init();
	Reshape(width, height);

	mglKeyFunc(Key);
	mglIdleFunc(Redraw);
	mglMainLoop();

	mglDeleteContext();
	MGLTerm();


	return 0;
}
#else

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/exec.h>


int main(int argc, char **argv)
{
	struct Library *IBase;
	struct IntuitionIFace *IIntuition;
	struct Library *GBase;
	struct GraphicsIFace *IGraphics;
	struct Library *MiniGLBase;
	struct MiniGLIFace *IMiniGL;
	struct GLContextIFace *IGL;
	struct Window *win;
	struct BitMap *bm;
	struct RastPort rp;
	BOOL bRun = TRUE;
	
	IBase = IExec->OpenLibrary("intuition.library", 0);
	IIntuition = (struct IntuitionIFace *)IExec->GetInterface(IBase, "main", 1, NULL);
	
	GBase = IExec->OpenLibrary("graphics.library", 0);
	IGraphics = (struct GraphicsIFace *)IExec->GetInterface(GBase, "main", 1, NULL);
	
	MiniGLBase = IExec->OpenLibrary("minigl.library", 0);
	if (!MiniGLBase)
	{
		printf("Need minigl.library to run\n");
		exit(0);
	}
	IMiniGL = (struct MiniGLIFace *)IExec->GetInterface(MiniGLBase, "main", 1, NULL);
	
	win = IIntuition->OpenWindowTags(NULL, 
		WA_PubScreen,			0,
		WA_InnerWidth,			640,
		WA_InnerHeight,			480,
		WA_Left,				30,
		WA_Top,					30,
		WA_Title,				"Test window",
		WA_DragBar,				TRUE,
		WA_DepthGadget,			TRUE,
		WA_CloseGadget,			TRUE,
		WA_Flags,				WFLG_ACTIVATE,
		WA_IDCMP,				IDCMP_CLOSEWINDOW,
		TAG_DONE);
		
	if (win)
	{
		bm = IGraphics->AllocBitMap(640, 480, 8, BMF_MINPLANES|BMF_DISPLAYABLE,
			win->RPort->BitMap);
			
		if (bm)
		{
			IGraphics->InitRastPort(&rp);
			rp.BitMap = bm;
			
			IGL = IMiniGL->CreateContextTags(
						MGLCC_Bitmap,			bm,
						MGLCC_StencilBuffer,	TRUE,
				TAG_DONE);
			
			mglMakeCurrent(IGL);
			mglLockMode(MGL_LOCK_SMART);
			
			Init();
			Reshape(640, 480);
			
			while (bRun)
			{
				struct IntuiMessage *imsg;
				
				Redraw();
				mglUnlockDisplay();
				
				IGraphics->ClipBlit(&rp, 0, 0, 	
					win->RPort, win->BorderLeft, win->BorderTop,
					win->Width - win->BorderLeft - win->BorderRight,
					win->Height	- win->BorderTop - win->BorderBottom,
					0xC0);
					
				while ((imsg = (struct IntuiMessage *)IExec->GetMsg(win->UserPort)))
				{
					if (imsg->Class == IDCMP_CLOSEWINDOW)
						bRun = FALSE;
					IExec->ReplyMsg((struct Message *)imsg);
				}
			}
			
			mglDeleteContext();

			IGraphics->FreeBitMap(bm);
		}
		
		IIntuition->CloseWindow(win);
	}
	
	IExec->DropInterface((struct Interface *)IMiniGL);
	IExec->CloseLibrary(MiniGLBase);
	
	IExec->DropInterface((struct Interface *)IGraphics);
	IExec->CloseLibrary(GBase);
	
	IExec->DropInterface((struct Interface *)IIntuition);
	IExec->CloseLibrary(IBase);
	
	return 0;
}
			
#endif
