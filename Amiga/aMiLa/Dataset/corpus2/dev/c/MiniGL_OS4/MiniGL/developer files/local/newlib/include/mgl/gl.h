/*
 * $Id: gl.h 163 2005-08-04 14:42:10Z tfrieden $
 *
 * $Date: 2005-08-04 09:42:10 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 163 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef GL_H_
#define GL_H_

#ifdef __cplusplus
extern "C"
{
#endif

#ifndef __gl_h_
#include <GL/gl.h>
#endif

#include <mgl/config.h>
#include <mgl/mgltypes.h>
#include <mgl/modes.h>
#include <interfaces/minigl.h>

#ifndef NLOGGING
extern int MGLDebugLevel;
#define mglSetDebugLevel(level) \
	MGLDebugLevel = level
#endif


#define GL_BASE							0x00000
#ifdef AUTOMATIC_LOCKING_ENABLE
#define MGL_LOCK_AUTOMATIC				0x10000
#define MGL_LOCK_MANUAL					0x10001
#define MGL_LOCK_SMART					0x10002
#endif
#define MGL_FLATFAN						0x10003
#define MGL_PERSPECTIVE_MAPPING			0x10004
#define MGL_W_ONE_HINT					0x10005
#define MGL_Z_OFFSET					0x10006
#define MGL_UBYTE_BGRA					0x10007
#define MGL_UNSIGNED_SHORT_5_6_5		0x10008
#define MGL_UNSIGNED_SHORT_4_4_4_4		0x10009
#define MGL_TEXTURE_QUALITY_HINT		0x1000a
	

#define GL_TRUE                 1
#define GL_FALSE                0

#define MGL_BUTTON_LEFT         0x00000001
#define MGL_BUTTON_RIGHT        0x00000002
#define MGL_BUTTON_MID          0x00000004

#define MGL_SM_BESTMODE         0xFFFFFFFF
#define MGL_SM_WINDOWMODE       0x00000000


#include "mgl/vertexbuffer.h"
#include "mgl/context.h"
#include "mgl/clip.h"
#include "mgl/modes.h"

/*
	The current context is refered to as an extern variable, which
	is a pointer to the context.
*/

struct MGLSemaphore
{
	struct SignalSemaphore	semaphore;
	void *context;
};

extern struct GLContextIFace *mini_CurrentContext;

/* Tags for CreateContext */
#define MGLCC_Width					(TAG_USER + 1)
#define MGLCC_Height				(TAG_USER + 2)
#define MGLCC_OffsetX				(TAG_USER + 3)
#define MGLCC_OffsetY				(TAG_USER + 4)
#define MGLCC_Windowed				(TAG_USER + 5)
#define MGLCC_Bitmap				(TAG_USER + 6)
#define MGLCC_ScreenMode			(TAG_USER + 7)
#define MGLCC_VertexBufferSize		(TAG_USER + 8)
#define MGLCC_TextureBufferSize		(TAG_USER + 9)
#define MGLCC_Buffers				(TAG_USER + 10)
#define MGLCC_PixelDepth			(TAG_USER + 11)
#define MGLCC_CloseWorkbench		(TAG_USER + 12)
#define MGLCC_NoMipMapping			(TAG_USER + 13)
#define MGLCC_CloseGadget			(TAG_USER + 14)
#define MGLCC_StencilBuffer			(TAG_USER + 15)
#define MGLCC_SizeGadget			(TAG_USER + 16)
#define MGLCC_DisplayListArraySize	(TAG_USER + 17)
#define MGLCC_MaxDisplayListNesting	(TAG_USER + 18)


#if 0
/*
	Prototypes and appropriate defines
	These are derived from the OpenGL manpages
	Some defines are duplicated with EXT suffix, to be compatible.
	Additionally, some of these may not be needed (Maybe glBegin).
	There may also be a problem with floating point parameters for
	certain compilers. May be addressed in the macros.
*/

void        GLAlphaFunc(GLcontext context, GLenum func, GLclampf ref);
void        GLBegin(GLcontext context, GLenum mode);
void        GLBindTexture(GLcontext context, GLenum target, GLuint texture);
void        GLBlendFunc(GLcontext context, GLenum sfactor, GLenum dfactor);
void        GLClear(GLcontext context, GLbitfield mask);
void        GLClearColor(GLcontext context, GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
void        GLClearDepth(GLcontext context, GLclampd depth);
void        GLColor4f(GLcontext context, GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
void        GLColorTable(GLcontext context, GLenum target, GLenum internalformat, GLint width, GLenum format, GLenum type, GLvoid *data);
void        GLCullFace(GLcontext context, GLenum mode);
void        GLDeleteTextures(GLcontext context, GLsizei n, const GLuint *textures);
void        GLDepthFunc(GLcontext context, GLenum func);
void        GLDepthMask(GLcontext context, GLboolean flag);
void        GLDepthRange(GLcontext context, GLclampd n, GLclampd f);
void        GLDrawBuffer(GLcontext context, GLenum mode);
void        GLEnd(GLcontext context);
void        GLFinish(GLcontext context);
void        GLFlush(GLcontext context);
void        GLFogf(GLcontext context, GLenum pname, GLfloat param);
void        GLFogfv(GLcontext context, GLenum pname, GLfloat *param);
void        GLFrontFace(GLcontext context, GLenum mode);
void        GLFrustum(GLcontext context, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);
void        GLGenTextures(GLcontext context, GLsizei n, GLuint *textures);
void        GLGetBooleanv(GLcontext context, GLenum pname, GLboolean *params);
GLenum      GLGetError(GLcontext context);
void        GLGetFloatv(GLcontext context, GLenum pname, GLfloat *params);
void        GLGetIntegerv(GLcontext context, GLenum pname, GLint *params);
const GLubyte* GLGetString(GLcontext context, GLenum name);
void        GLHint(GLcontext context, GLenum target, GLenum mode);
GLboolean   GLIsEnabled(GLcontext context, GLenum cap);
void        GLLoadIdentity(GLcontext context);
void        GLLoadMatrixd(GLcontext context, const GLdouble *m);
void        GLLoadMatrixf(GLcontext context, const GLfloat *m);
void        GLMatrixMode(GLcontext context, GLenum mode);
void        GLMultMatrixd(GLcontext context, const GLdouble *m);
void        GLMultMatrixf(GLcontext context, const GLfloat *m);
void        GLNormal3f(GLcontext context, GLfloat x, GLfloat y, GLfloat z);
void        GLOrtho(GLcontext context, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);
void        GLPixelStorei(GLcontext context, GLenum pname, GLint param);
void        GLPolygonMode(GLcontext context, GLenum face, GLenum mode);
void        GLPolygonOffset(GLcontext context, GLfloat factor, GLfloat units);
void        GLPopMatrix(GLcontext context);
void        GLPushMatrix(GLcontext context);
void        GLReadPixels(GLcontext context, GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels);
void        GLRotatef(GLcontext context, GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
void        GLScalef(GLcontext context, GLfloat x, GLfloat y, GLfloat z);
void        GLScissor(GLcontext context, GLint x, GLint y, GLsizei width, GLsizei height);
void        GLShadeModel(GLcontext context, GLenum mode);
void        GLTexCoord2f(GLcontext context, GLfloat s, GLfloat t);
void        GLTexCoord4f(GLcontext context, GLfloat s, GLfloat t, GLfloat r, GLfloat q);
void        GLTexEnvi(GLcontext context, GLenum target, GLenum pname, GLint param);
void		GLTexEnvfv(GLcontext context, GLenum target, GLenum pname, GLfloat *param);
void        GLTexGeni(GLcontext context, GLenum coord, GLenum mode, GLint param);
void		GLTexGenfv(GLcontext context, GLenum coord, GLenum pname, GLfloat *params); 
void        GLTexImage2D(GLcontext context, GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels);
void        GLTexParameteri(GLcontext context, GLenum target, GLenum pname, GLint param);
void        GLTexSubImage2D(GLcontext context, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels);
void        GLTranslatef(GLcontext context, GLfloat x, GLfloat y, GLfloat z);
void        GLVertex4f(GLcontext context, GLfloat x, GLfloat y, GLfloat z, GLfloat w);
void        GLViewport(GLcontext context, GLint x, GLint y, GLsizei width, GLsizei height);
void	    GLPushAttrib(GLcontext, GLbitfield);
void	    GLPopAttrib(GLcontext);		
void		GLRectf(GLcontext, GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2);
void        mglChooseNumberOfBuffers(int number);
void        mglChoosePixelDepth(int depth);
void        mglChooseTextureBufferSize(int size);
void        mglChooseVertexBufferSize(int size);
void        mglChooseWindowMode(GLboolean flag);
void		mglChooseStencilBuffer(GLboolean flag);
void		mglChooseCloseGadget(GLboolean flag);
void *      MGLCreateContext(int offx, int offy, int w, int h);
void        MGLDeleteContext(GLcontext context);
void        MGLEnableSync(GLcontext context, GLboolean enable);
void	    MGLMinTriArea(GLcontext, GLfloat area);
void        MGLExit(GLcontext context);
void *      MGLGetWindowHandle(GLcontext context);
void        MGLIdleFunc(GLcontext context, IdleFn i);
void        MGLKeyFunc(GLcontext context, KeyHandlerFn k);
GLboolean   MGLLockDisplay(GLcontext context);
void        MGLMainLoop(GLcontext context);
void        MGLMouseFunc(GLcontext context, MouseHandlerFn m);
void        mglProhibitAlphaFallback(GLboolean flag);
void        mglProhibitMipMapping(GLboolean flag);
void        mglProposeCloseDesktop(GLboolean closeme);
void        MGLResizeContext(GLcontext context, GLsizei width, GLsizei height);
void        MGLSetState(GLcontext context, GLenum cap, GLboolean state);
void        MGLSpecialFunc(GLcontext context, SpecialHandlerFn s);
void        MGLSwitchDisplay(GLcontext context);
void        MGLTexMemStat(GLcontext context, GLint *Current, GLint *Peak);
void        MGLUnlockDisplay(GLcontext context);
void        MGLWriteShotPPM(GLcontext context, char *filename);
GLboolean   MGLInit(void);
void        MGLTerm(void);
void		MGLEnableFrameStats(GLcontext context, GLboolean enable);

#ifdef AUTOMATIC_LOCKING_ENABLE
void        MGLLockMode(GLcontext context, GLenum lockMode);
#endif

void        MGLPrintMatrix(GLcontext context, int mode);
void        MGLPrintMatrixStack(GLcontext context, int mode);

void        MGLSetZOffset(GLcontext context, GLfloat offset);


GLint       mglGetSupportedScreenModes(MGLScreenModeCallback CallbackFn);
void *      MGLCreateContextFromID(GLint ID, GLint *w, GLint *h);
GLboolean   MGLLockBack(GLcontext context, MGLLockInfo *info);

void        GLEnableClientState(GLcontext context, GLenum state);
void        GLDisableClientState(GLcontext context, GLenum state);

void        GLTexCoordPointer(GLcontext context, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);
void		GLNormalPointer(GLcontext context, GLenum type, GLsizei stride, const GLvoid *pointer);
void        GLColorPointer(GLcontext context, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);
void        GLVertexPointer(GLcontext context, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer);

void        GLDrawElements(GLcontext context, GLenum mode, GLsizei cound, GLenum type, const GLvoid *indices);
void        GLDrawArrays(GLcontext context, GLenum mode, GLint first, GLsizei count);
void		GLArrayElement(GLcontext context, GLint i);
void		GLClientActiveTexture(GLcontext context, GLenum texture);
void		GLInterleavedArrays(GLcontext context, GLenum format, GLsizei stride, const GLvoid *pointer);
void		GLLockArrays(GLcontext context, GLint first, GLsizei count);
void 		GLUnlockArrays(GLcontext);

void        GLActiveTexture(GLcontext context, GLenum unit);
void        GLMultiTexCoord2f(GLcontext context, GLenum unit, GLfloat s, GLfloat t);
void        GLMultiTexCoord4f(GLcontext context, GLenum unit, GLfloat s, GLfloat t, GLfloat r, GLfloat q);

void		GLMaterialf(GLcontext, GLenum, GLenum, GLfloat);
void		GLMaterialfv(GLcontext, GLenum, GLenum, GLfloat *);
void		GLMaterialiv(GLcontext, GLenum, GLenum, GLint *);
void 		GLLightf(GLcontext, GLenum, GLenum, GLfloat);
void		GLLightfv(GLcontext, GLenum, GLenum, GLfloat *);
void		GLLightiv(GLcontext, GLenum, GLenum, GLint *);
void 		GLLightModelf(GLcontext, GLenum, GLfloat);
void		GLLightModelfv(GLcontext, GLenum, GLfloat *);
void		GLLightModeliv(GLcontext, GLenum, GLint *);
void		GLColorMaterial(GLcontext, GLenum, GLenum);


void        MGLGrabFocus(GLcontext, GLboolean);
void 		mglProhibitMipMapping(GLboolean flag);

void 		GLStencilFunc(GLcontext context, GLenum func, GLint ref, GLint mask);
void 		GLStencilOp(GLcontext context, GLenum sfail, GLenum dpfail, GLenum dppass);
void 		GLStencilMask(GLcontext context, GLuint mask);
void 		GLClearStencil(GLcontext context, GLint s);
void 		GLColorMask(GLcontext, GLboolean, GLboolean, GLboolean, GLboolean);
void		GLLineWidth(GLcontext, GLfloat);
void		GLClipPlane(GLcontext context, GLenum plane, GLdouble *eqn);
void *		MGLCreateContextFromBitmap(int, int, void*);
void		MGLSetBitmap(GLcontext, void *);
void *		MGLGetProcAddress(GLcontext, const char *);
void		GLPointSize(GLcontext, GLfloat);
void 		GLBitmap(GLcontext context, GLsizei w, GLsizei h, GLfloat xbo, GLfloat ybo, GLfloat xbi, GLfloat ybi, GLubyte *data);
void		GLLineStipple(GLcontext context, GLint factor, GLushort pattern);
void 		GLPolygonStipple(GLcontext context, GLubyte *pattern);
void 		GLRasterPos4f(GLcontext context, GLfloat x, GLfloat y, GLfloat z, GLfloat w);

void		cgl_GLCallList(GLcontext context, GLuint list);
void 		cgl_GLCallLists(GLcontext context, GLsizei n, GLenum type, const GLvoid *lists);
void 		cgl_GLDeleteLists(GLcontext context, GLuint list, GLsizei range);
void 		cgl_GLEndList(GLcontext context);
GLuint		cgl_GLGenLists(GLcontext context, GLsizei range);
GLboolean	cgl_GLIsList(GLcontext context, GLuint list);
void 		cgl_GLListBase(GLcontext context, GLuint base);
void 		cgl_GLNewList(GLcontext context, GLuint list, GLenum mode);

void		MGLPinTexture(GLcontext context, GLuint texnum);
void		MGLUnpinTexture(GLcontext context, GLuint texnum);
void		MGLSetTextureRenderTarget(GLcontext context, GLuint texnum);
#endif


void		GLUTInit(int *argc, char **argv);
void		GLUTInitWindowSize(int width, int height);
void		GLUTInitWindowPosition(int x, int y);
void		GLUTInitDisplayMode(unsigned int mode);
int			GLUTCreateWindow(char *name);
void		GLUTDestroyWindow(GLcontext context, int window);
void		GLUTPostRedisplay(GLcontext context);
void		GLUTSwapBuffers(GLcontext context);
void		GLUTMainLoop(GLcontext context);
void 		GLUTPositionWindow(GLcontext context, int x, int y);
void 		GLUTReshapeWindow(GLcontext context, int width, int height);
void		GLUTFullScreen(GLcontext context);
void		GLUTPushWindow(GLcontext context);
void		GLUTPopWindow(GLcontext context);
void		GLUTShowWindow(GLcontext context);
void 		GLUTHideWindow(GLcontext context);
void 		GLUTIconifyWindow(GLcontext context);
void		GLUTSetWindowTitle(GLcontext context, char *name);
void		GLUTSetIconTitle(GLcontext context, char *name);
void		GLUTDisplayFunc(GLcontext context, void (*func)(void));
void		GLUTReshapeFunc(GLcontext context, void (*func)(int width, int height));
void		GLUTKeyboardFunc(GLcontext context, void (*func)(unsigned char key, int x, int y));
void		GLUTMouseFunc(GLcontext context, void (*func)(int button, int state, int x, int y));
void		GLUTMotionFunc(GLcontext context, void (*func)(int x, int y));
void		GLUTPassiveMotionFunc(GLcontext context, void (*func)(int x, int y));
void		GLUTVisibilityFunc(GLcontext context, void (*func)(int state));
void		GLUTEntryFunc(GLcontext context, void (*func)(int state));
void		GLUTSpecialFunc(GLcontext context, void (*func)(int key, int x, int y));
void		GLUTIdleFunc(GLcontext context, void (*func)(void));
int			GLUTGet(GLcontext context, GLenum state);

void        GLULookAt(GLfloat ex, GLfloat ey, GLfloat ez, GLfloat cx, GLfloat cy, GLfloat cz, GLfloat ux, GLfloat uy, GLfloat uz);
void        GLUPerspective(GLfloat fovy, GLfloat aspect, GLfloat znear, GLfloat zfar);
void		GLUOrtho2D(GLcontext context, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top);
GLint 		GLUBuild2DMipmaps(GLcontext, GLenum, GLint, GLint, GLint, GLenum, GLenum, const void *);

#include "mgl/minigl.h"

#ifdef __cplusplus
}
#endif


#endif
