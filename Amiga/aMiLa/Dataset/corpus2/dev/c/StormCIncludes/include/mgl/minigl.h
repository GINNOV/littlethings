/*
 * $Id: minigl.h,v 1.4 2000/12/05 18:24:06 nobody Exp $
 *
 * $Date: 2000/12/05 18:24:06 $
 * $Revision: 1.4 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef __MINIGL_H_INLINES
#define __MINIGL_H_INLINES

#ifndef MGLAPI
	#if defined(__GNUC__)
	#define MGLAPI static __inline
	#elif defined(__STORM__)
	#define MGLAPI __inline
	#elif defined(__VBCC__)
	#define MGLAPI
	#endif
#endif

#define CC mini_CurrentContext

MGLAPI void glAlphaFunc(GLenum func, GLclampf ref)
{
	GLAlphaFunc(CC, func, ref);
}

MGLAPI void glBegin(GLenum mode)
{
	GLBegin(CC, mode);
}

MGLAPI void glBindTexture(GLenum target, GLuint texture)
{
	GLBindTexture(CC, target, texture);
}

MGLAPI void glBlendFunc(GLenum sfactor, GLenum dfactor)
{
	GLBlendFunc(CC, sfactor, dfactor);
}

MGLAPI void glClear(GLbitfield mask)
{
	GLClear(CC, mask);
}

MGLAPI void glClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
{
	GLClearColor(CC, red, green, blue, alpha);
}

MGLAPI void glClearDepth(GLclampd depth)
{
	GLClearDepth(CC, depth);
}

MGLAPI void glColor3f(GLfloat red, GLfloat green, GLfloat blue)
{
	GLColor4f(CC, red, green, blue, 1.f);
}

MGLAPI void glColor3fv(GLfloat *v)
{
	GLColor3fv(CC, v);
}

MGLAPI void glColor3ubv(GLubyte *v)
{
	GLColor3ubv(CC, v);
}

MGLAPI void glColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
	GLColor4f(CC, red, green, blue, alpha);
}

MGLAPI void glColor4fv(GLfloat *v)
{
	GLColor4fv(CC, v);
}

MGLAPI void glColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha)
{
	GLColor4ub(CC, red, green, blue, alpha);
}

MGLAPI void glColor4ubv(GLubyte *v)
{
	GLColor4ubv(CC, v);
}

MGLAPI void glCullFace(GLenum mode)
{
	GLCullFace(CC, mode);
}

MGLAPI void glDeleteTextures(GLsizei n, const GLuint *textures)
{
	GLDeleteTextures(CC, n, textures);
}

MGLAPI void glDepthFunc(GLenum func)
{
	GLDepthFunc(CC, func);
}

MGLAPI void glDepthMask(GLboolean flag)
{
	GLDepthMask(CC, flag);
}

MGLAPI void glDepthRange(GLclampd n, GLclampd f)
{
	GLDepthRange(CC, n, f);
}

MGLAPI void glDisable(GLenum cap)
{
	MGLSetState(CC, cap, GL_FALSE);
}

MGLAPI void glDrawBuffer(GLenum mode)
{
	GLDrawBuffer(CC, mode);
}

MGLAPI void glEnable(GLenum cap)
{
	MGLSetState(CC, cap, GL_TRUE);
}

MGLAPI void glEnd(void)
{
	GLEnd(CC);
}

MGLAPI void glFinish(void)
{
	GLFinish(CC);
}

MGLAPI void glFlush(void)
{
	GLFlush(CC);
}

MGLAPI void glFogf(GLenum pname, GLfloat param)
{
	GLFogf(CC, pname, param);
}

MGLAPI void glFogi(GLenum pname, GLint param)
{
	GLFogf(CC, pname, (GLfloat)param);
}

MGLAPI void glFogfv(GLenum pname, GLfloat *param)
{
	GLFogfv(CC, pname, param);
}

MGLAPI void glFrontFace(GLenum mode)
{
	GLFrontFace(CC, mode);
}

MGLAPI void glFrustum(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
{
	GLFrustum(CC, left, right, bottom, top, zNear, zFar);
}

MGLAPI void glGenTextures(GLsizei n, GLuint *textures)
{
	GLGenTextures(CC, n, textures);
}

MGLAPI GLenum glGetError(void)
{
	return GLGetError(CC);
}

MGLAPI void glGetFloatv(GLenum pname, GLfloat *params)
{
	GLGetFloatv(CC, pname, params);
}

MGLAPI const GLubyte * glGetString(GLenum name)
{
	return GLGetString(CC, name);
}

MGLAPI void glHint(GLenum target, GLenum mode)
{
	GLHint(CC, target, mode);
}

MGLAPI void glLoadIdentity(void)
{
	GLLoadIdentity(CC);
}

MGLAPI void glLoadMatrixd(const GLdouble *m)
{
	GLLoadMatrixd(CC, m);
}

MGLAPI void glLoadMatrixf(const GLfloat *m)
{
	GLLoadMatrixf(CC, m);
}

MGLAPI void glMatrixMode(GLenum mode)
{
	GLMatrixMode(CC, mode);
}

MGLAPI void glMultMatrixd(const GLdouble *m)
{
	GLMultMatrixd(CC, m);
}

MGLAPI void glMultMatrixf(const GLfloat *m)
{
	GLMultMatrixf(CC, m);
}

MGLAPI void glNormal3f(GLfloat x, GLfloat y, GLfloat z)
{
	GLNormal3f(CC, x, y, z);
}

MGLAPI void glOrtho(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
{
	GLOrtho(CC, left, right, bottom, top, zNear, zFar);
}

MGLAPI void glPixelStorei(GLenum pname, GLint param)
{
	GLPixelStorei(CC, pname, param);
}

MGLAPI void glPolygonMode(GLenum face, GLenum mode)
{
	GLPolygonMode(CC, face, mode);
}

MGLAPI void glPopMatrix(void)
{
	GLPopMatrix(CC);
}

MGLAPI void glPushMatrix(void)
{
	GLPushMatrix(CC);
}

MGLAPI void glReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels)
{
	GLReadPixels(CC, x, y, width, height, format, type, pixels);
}

MGLAPI void glRotatef(GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
	GLRotatef(CC, angle, x, y, z);
}

MGLAPI void glRotated(GLdouble angle, GLdouble x, GLdouble y, GLdouble z)
{
	GLRotated(CC, angle, x, y, z);
}

MGLAPI void glScalef(GLfloat x, GLfloat y, GLfloat z)
{
	GLScalef(CC, x, y, z);
}

MGLAPI void glScaled(GLdouble x, GLdouble y, GLdouble z)
{
	GLScaled(CC, x, y, z);
}

MGLAPI void glScissor(GLint x, GLint y, GLsizei width, GLsizei height)
{
	GLScissor(CC, x, y, width, height);
}

MGLAPI void glShadeModel(GLenum mode)
{
	GLShadeModel(CC, mode);
}

MGLAPI void glTexCoord2f(GLfloat s, GLfloat t)
{
	GLTexCoord2f(CC, s, t);
}

MGLAPI void glTexCoord2fv(GLfloat *v)
{
	GLTexCoord2fv(CC, v);
}

MGLAPI void glTexCoord4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q)
{
	GLTexCoord4f(CC, s, t, r, q);
}

MGLAPI void glTexCoord4fv(GLfloat *v)
{
	GLTexCoord4fv(CC, v);
}

MGLAPI void glTexEnvf(GLenum target, GLenum pname, GLfloat param)
{
	GLTexEnvi(CC, target, pname, (GLint)param);
}

MGLAPI void glTexEnvi(GLenum target, GLenum pname, GLint param)
{
	GLTexEnvi(CC, target, pname, param);
}

MGLAPI void glTexGeni(GLenum coord, GLenum mode, GLenum map)
{
	GLTexGeni(CC, coord, mode, map);
}

MGLAPI void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels)
{
	GLTexImage2D(CC, target, level, internalformat, width, height, border, format, type, pixels);
}

MGLAPI void glTexParameteri(GLenum target, GLenum pname, GLint param)
{
	GLTexParameteri(CC, target, pname, param);
}

MGLAPI void glTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels)
{
	GLTexSubImage2D(CC, target, level, xoffset, yoffset, width, height, format, type, pixels);
}

MGLAPI void glTranslated(GLdouble x, GLdouble y, GLdouble z)
{
	GLTranslated(CC, x, y, z);
}

MGLAPI void glTranslatef(GLfloat x, GLfloat y, GLfloat z)
{
	GLTranslatef(CC, x, y, z);
}

MGLAPI void glVertex2f(GLfloat x, GLfloat y)
{
	GLVertex4f(CC, x, y, 0.f, 1.f);
}

MGLAPI void glVertex3f(GLfloat x, GLfloat y, GLfloat z)
{
	GLVertex4f(CC, x, y, z, 1.f);
}

MGLAPI void glVertex3fv(GLfloat *v)
{
	GLVertex3fv(CC, v);
}

MGLAPI void glVertex4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w)
{
	GLVertex4f(CC, x, y, z, w);
}

MGLAPI void glVertex4fv(GLfloat *v)
{
	GLVertex4fv(CC, v);
}

MGLAPI void glViewport(GLint x, GLint y, GLsizei width, GLsizei height)
{
	GLViewport(CC, x, y, width, height);
}

MGLAPI void * mglCreateContext(int offx, int offy, int w, int h)
{
	CC = (GLcontext)MGLCreateContext(offx, offy, w,h);
	return (void *)CC;
}

MGLAPI void * mglCreateContextFromID(GLint id, GLint *w, GLint *h)
{
	CC = (GLcontext)MGLCreateContextFromID(id, w, h);
	return (void *)CC;
}


MGLAPI void mglDeleteContext(void)
{
	MGLDeleteContext(CC);
}

MGLAPI void mglEnableSync(GLboolean enable)
{
	MGLEnableSync(CC, enable);
}

MGLAPI void mglExit(void)
{
	MGLExit(CC);
}

MGLAPI void * mglGetWindowHandle(void)
{
	return MGLGetWindowHandle(CC);
}

MGLAPI void mglIdleFunc(IdleFn i)
{
	MGLIdleFunc(CC, i);
}

MGLAPI void mglKeyFunc(KeyHandlerFn k)
{
	MGLKeyFunc(CC, k);
}

MGLAPI GLboolean mglLockDisplay(void)
{
	return MGLLockDisplay(CC);
}

#ifdef AUTOMATIC_LOCKING_ENABLE
MGLAPI void mglLockMode(GLenum lockMode)
{
	MGLLockMode(CC, lockMode);
}
#endif

MGLAPI void mglMainLoop(void)
{
	MGLMainLoop(CC);
}

MGLAPI void mglMouseFunc(MouseHandlerFn m)
{
	MGLMouseFunc(CC, m);
}

MGLAPI void mglResizeContext(GLsizei width, GLsizei height)
{
	MGLResizeContext(CC, width, height);
}

MGLAPI void mglPrintMatrix(GLenum mode)
{
	MGLPrintMatrix(CC, mode);
}

MGLAPI void mglPrintMatrixStack(GLenum mode)
{
	MGLPrintMatrixStack(CC,mode);
}

MGLAPI void mglSpecialFunc(SpecialHandlerFn s)
{
	MGLSpecialFunc(CC, s);
}

MGLAPI void mglSwitchDisplay(void)
{
	MGLSwitchDisplay(CC);
}

MGLAPI void mglUnlockDisplay(void)
{
	MGLUnlockDisplay(CC);
}

MGLAPI void mglWriteShotPPM(char *filename)
{
	MGLWriteShotPPM(CC, filename);
}

MGLAPI void mglTexMemStat(GLint *Current, GLint *Peak)
{
	MGLTexMemStat(CC, Current, Peak);
}

MGLAPI void mglSetZOffset(GLfloat offset)
{
	MGLSetZOffset(CC, offset);
}

MGLAPI void glColorTable(GLenum target, GLenum internalformat, GLint width, GLenum format, GLenum type, GLvoid *data)
{
	GLColorTable(CC, target, internalformat, width, format, type, data);
}

MGLAPI void glColorTableEXT(GLenum target, GLenum internalformat, GLint width, GLenum format, GLenum type, GLvoid *data)
{
	GLColorTable(CC, target, internalformat, width, format, type, data);
}


/*
** These function have no hidden context parameter, but are handled the same in case we want to make
** MiniGL a shared library some day
*/

MGLAPI void gluLookAt(GLfloat ex, GLfloat ey, GLfloat ez, GLfloat cx, GLfloat cy, GLfloat cz, GLfloat ux, GLfloat uy, GLfloat uz)
{
	GLULookAt(ex, ey, ez, cx, cy, cz, ux, uy, uz);
}

MGLAPI void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat znear, GLfloat zfar)
{
	GLUPerspective(fovy, aspect, znear, zfar);
}

/*
** Additional functions for targetted context creation
*/

MGLAPI GLboolean mglLockBack(MGLLockInfo *info)
{
	return MGLLockBack(CC, info);
}


#endif
