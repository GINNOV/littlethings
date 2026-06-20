/*
 * $Id: minigl.h 160 2005-08-04 14:40:28Z tfrieden $
 *
 * $Date: 2005-08-04 09:40:28 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 160 $
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
	#define MGLAPI static inline
	#elif defined(__STORMC__)
	#define MGLAPI __inline
	#elif defined(__VBCC__)
	#define MGLAPI __inline
	#endif
#endif

#include <interfaces/minigl.h>

#ifndef GET_INSTANCE
#include <exec/interfaces.h>
#define GET_INSTANCE(self)                          \
          ((uint32)self - self->Data.NegativeSize)
#endif

#define CC mini_CurrentContext

MGLAPI void glClipPlane(GLenum plane, GLdouble *eqn)
{
	CC->GLClipPlane(plane, eqn);
}

MGLAPI void glPolygonOffset(GLfloat factor, GLfloat units)
{
	CC->GLPolygonOffset(factor, units);
}

MGLAPI void   glTexEnviv(GLenum target, GLenum pname, GLint *param)
{
	CC->GLTexEnvi(target, pname, *(param)) ;
}

MGLAPI void   glTexEnvfv(GLenum target, GLenum pname, GLfloat *param)
{
	CC->GLTexEnvfv(target, pname, param) ;
}


MGLAPI void glGetBooleanv( GLenum pname, GLboolean *params)
{
	CC->GLGetBooleanv(pname, params) ;
}

MGLAPI void glGetIntegerv( GLenum pname, GLint *params)
{
	CC->GLGetIntegerv(pname, params) ;
}

MGLAPI GLboolean glIsEnabled(GLenum cap)
{
   return CC->GLIsEnabled(cap);
}

MGLAPI void glAlphaFunc(GLenum func, GLclampf ref)
{
	CC->GLAlphaFunc(func, ref);
}

MGLAPI void glBegin(GLenum mode)
{
	CC->GLBegin(mode);
}

MGLAPI void glBindTexture(GLenum target, GLuint texture)
{
	CC->GLBindTexture(target, texture);
}

MGLAPI void glBlendFunc(GLenum sfactor, GLenum dfactor)
{
	CC->GLBlendFunc(sfactor, dfactor);
}

MGLAPI void glClear(GLbitfield mask)
{
	CC->GLClear(mask);
}

MGLAPI void glClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
{
	CC->GLClearColor(red, green, blue, alpha);
}

MGLAPI void glClearDepth(GLclampd depth)
{
	CC->GLClearDepth(depth);
}

MGLAPI void glColor3b(GLbyte red, GLbyte green, GLbyte blue)
{
	CC->GLColor4f((GLfloat)red/255.0f, (GLfloat)green/255.0f, (GLfloat)blue/255.f, 1.0f);
}

MGLAPI void glColor3ub(GLubyte red, GLubyte green, GLubyte blue)
{
	CC->GLColor4f((GLfloat)red/255.0f, (GLfloat)green/255.0f, (GLfloat)blue/255.f, 1.0f);
}

MGLAPI void glColor3bv(GLbyte *v)
{
	CC->GLColor4f((GLfloat)v[0]/255.0f, (GLfloat)v[1]/255.0f, (GLfloat)v[2]/255.f, 1.0f);
}

MGLAPI void glColor3ubv(GLubyte *v)
{
	CC->GLColor4f((GLfloat)v[0]/255.0f, (GLfloat)v[1]/255.0f, (GLfloat)v[2]/255.f, 1.0f);
}

MGLAPI void glColor3s(GLshort red, GLshort green, GLshort blue)
{
	CC->GLColor4f((GLfloat)red/65535.0f, (GLfloat)green/65535.0f, (GLfloat)blue/65535.f, 1.0f);
}

MGLAPI void glColor3us(GLushort red, GLushort green, GLushort blue)
{
	CC->GLColor4f((GLfloat)red/65535.0f, (GLfloat)green/65535.0f, (GLfloat)blue/65535.f, 1.0f);
}

MGLAPI void glColor3sv(GLshort *v)
{
	CC->GLColor4f((GLfloat)v[0]/65535.0f, (GLfloat)v[1]/65535.0f, (GLfloat)v[2]/65535.f, 1.0f);
}

MGLAPI void glColor3usv(GLushort *v)
{
	CC->GLColor4f((GLfloat)v[0]/65535.0f, (GLfloat)v[1]/65535.0f, (GLfloat)v[2]/65535.f, 1.0f);
}

MGLAPI void glColor3i(GLint red, GLint green, GLint blue)
{
	CC->GLColor4f((GLfloat)red/429496795.0f, (GLfloat)green/429496795.0f, (GLfloat)blue/429496795.f, 1.0f);
}

MGLAPI void glColor3ui(GLuint red, GLuint green, GLuint blue)
{
	CC->GLColor4f((GLfloat)red/429496795.0f, (GLfloat)green/429496795.0f, (GLfloat)blue/429496795.f, 1.0f);
}

MGLAPI void glColor3iv(GLint *v)
{
	CC->GLColor4f((GLfloat)v[0]/429496795.0f, (GLfloat)v[1]/429496795.0f, (GLfloat)v[2]/429496795.f, 1.0f);
}

MGLAPI void glColor3uiv(GLuint *v)
{
	CC->GLColor4f((GLfloat)v[0]/429496795.0f, (GLfloat)v[1]/429496795.0f, (GLfloat)v[2]/429496795.f, 1.0f);
}

MGLAPI void glColor3f(GLfloat red, GLfloat green, GLfloat blue)
{
	CC->GLColor4f((GLfloat)red, (GLfloat)green, (GLfloat)blue, 1.0f);
}

MGLAPI void glColor3fv(GLfloat *v)
{
	CC->GLColor4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glColor3d(GLdouble red, GLdouble green, GLdouble blue)
{
	CC->GLColor4f((GLfloat)red, (GLfloat)green, (GLfloat)blue, 1.0f);
}

MGLAPI void glColor3dv(GLdouble *v)
{
	CC->GLColor4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glColor4b(GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha)
{
	CC->GLColor4f((GLfloat)red/255.0f, (GLfloat)green/255.0f, (GLfloat)blue/255.f, (GLfloat)alpha/255.0f);
}

MGLAPI void glColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha)
{
	CC->GLColor4f((GLfloat)red/255.0f, (GLfloat)green/255.0f, (GLfloat)blue/255.f, (GLfloat)alpha/255.0f);
}

MGLAPI void glColor4bv(GLbyte *v)
{
	CC->GLColor4f((GLfloat)v[0]/255.0f, (GLfloat)v[1]/255.0f, (GLfloat)v[2]/255.f, (GLfloat)v[3]/255.0f);
}

MGLAPI void glColor4ubv(GLubyte *v)
{
	CC->GLColor4f((GLfloat)v[0]/255.0f, (GLfloat)v[1]/255.0f, (GLfloat)v[2]/255.f, (GLfloat)v[3]/255.0f);
}

MGLAPI void glColor4s(GLshort red, GLshort green, GLshort blue, GLshort alpha)
{
	CC->GLColor4f((GLfloat)red/65535.0f, (GLfloat)green/65535.0f, (GLfloat)blue/65535.f, (GLfloat)alpha/65535.0f);
}

MGLAPI void glColor4us(GLushort red, GLushort green, GLushort blue, GLushort alpha)
{
	CC->GLColor4f((GLfloat)red/65535.0f, (GLfloat)green/65535.0f, (GLfloat)blue/65535.f, (GLfloat)alpha/65535.0f);
}

MGLAPI void glColor4sv(GLshort *v)
{
	CC->GLColor4f((GLfloat)v[0]/65535.0f, (GLfloat)v[1]/65535.0f, (GLfloat)v[2]/65535.f, (GLfloat)v[3]/65535.0f);
}

MGLAPI void glColor4usv(GLushort *v)
{
	CC->GLColor4f((GLfloat)v[0]/65535.0f, (GLfloat)v[1]/65535.0f, (GLfloat)v[2]/65535.f, (GLfloat)v[3]/65535.0f);
}

MGLAPI void glColor4i(GLint red, GLint green, GLint blue, GLint alpha)
{
	CC->GLColor4f((GLfloat)red/429496795.0f, (GLfloat)green/429496795.0f, (GLfloat)blue/429496795.0f, (GLfloat)alpha/429496795.0f);
}

MGLAPI void glColor4ui(GLuint red, GLuint green, GLuint blue, GLuint alpha)
{
	CC->GLColor4f((GLfloat)red/429496795.0f, (GLfloat)green/429496795.0f, (GLfloat)blue/4294967950.f, (GLfloat)alpha/429496795.0f);
}

MGLAPI void glColor4iv(GLint *v)
{
	CC->GLColor4f((GLfloat)v[0]/429496795.0f, (GLfloat)v[1]/429496795.0f, (GLfloat)v[2]/4294967950.f, (GLfloat)v[3]/429496795.0f);
}

MGLAPI void glColor4uiv(GLuint *v)
{
	CC->GLColor4f((GLfloat)v[0]/429496795.0f, (GLfloat)v[1]/429496795.0f, (GLfloat)v[2]/4294967950.f, (GLfloat)v[3]/429496795.0f);
}

MGLAPI void glColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
	CC->GLColor4f((GLfloat)red, (GLfloat)green, (GLfloat)blue, (GLfloat)alpha);
}

MGLAPI void glColor4fv(GLfloat *v)
{
	CC->GLColor4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glColor4d(GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha)
{
	CC->GLColor4f((GLfloat)red, (GLfloat)green, (GLfloat)blue, (GLfloat)alpha);
}

MGLAPI void glColor4dv(GLdouble *v)
{
	CC->GLColor4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glCullFace(GLenum mode)
{
	CC->GLCullFace(mode);
}

MGLAPI void glVertex2s(GLshort x, GLshort y)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, 0.0f, 1.0f);
}

MGLAPI void glVertex2i(GLint x, GLint y)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, 0.0f, 1.0f);
}

MGLAPI void glVertex2f(GLfloat x, GLfloat y)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, 0.0f, 1.0f);
}

MGLAPI void glVertex2d(GLfloat x, GLfloat y)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, 0.0f, 1.0f);
}

MGLAPI void glVertex3s(GLshort x, GLshort y, GLshort z)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, (GLfloat)z, 1.0f);
}

MGLAPI void glVertex3i(GLint x, GLint y, GLint z)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, (GLfloat)z, 1.0f);
}

MGLAPI void glVertex3f(GLfloat x, GLfloat y, GLfloat z)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, (GLfloat)z, 1.0f);
}

MGLAPI void glVertex3d(GLdouble x, GLdouble y, GLdouble z)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, (GLfloat)z, 1.0f);
}

MGLAPI void glVertex4s(GLshort x, GLshort y, GLshort z, GLshort w)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, (GLfloat)z, (GLfloat)w);
}

MGLAPI void glVertex4i(GLint x, GLint y, GLint z, GLint w)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, (GLfloat)z, (GLfloat)w);
}

MGLAPI void glVertex4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, (GLfloat)z, (GLfloat)w);
}

MGLAPI void glVertex4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w)
{
	CC->GLVertex4f((GLfloat)x, (GLfloat)y, (GLfloat)z, (GLfloat)w);
}

MGLAPI void glVertex2sv(GLshort *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], 0.0f, 1.0f);
}

MGLAPI void glVertex2iv(GLint *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], 0.0f, 1.0f);
}

MGLAPI void glVertex2fv(GLfloat *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], 0.0f, 1.0f);
}

MGLAPI void glVertex2dv(GLdouble *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], 0.0f, 1.0f);
}

MGLAPI void glVertex3sv(GLshort *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glVertex3iv(GLint *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glVertex3fv(GLfloat *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glVertex3dv(GLdouble *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glVertex4sv(GLshort *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glVertex4iv(GLint *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glVertex4fv(GLfloat *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glVertex4dv(GLdouble *v)
{
	CC->GLVertex4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}


MGLAPI void glDeleteTextures(GLsizei n, const GLuint *textures)
{
	CC->GLDeleteTextures(n, textures);
}

MGLAPI void glDepthFunc(GLenum func)
{
	CC->GLDepthFunc(func);
}

MGLAPI void glDepthMask(GLboolean flag)
{
	CC->GLDepthMask(flag);
}

MGLAPI void glDepthRange(GLclampd n, GLclampd f)
{
	CC->GLDepthRange(n, f);
}

MGLAPI void glDisable(GLenum cap)
{
	CC->SetState(cap, GL_FALSE);
}

MGLAPI void glDrawBuffer(GLenum mode)
{
	CC->GLDrawBuffer(mode);
}

MGLAPI void glEnable(GLenum cap)
{
	CC->SetState(cap, GL_TRUE);
}

MGLAPI void glEnd(void)
{
	CC->GLEnd();
}

MGLAPI void glFinish(void)
{
	CC->GLFinish();
}

MGLAPI void glFlush(void)
{
	CC->GLFlush();
}

MGLAPI void glFogf(GLenum pname, GLfloat param)
{
	CC->GLFogf(pname, param);
}

MGLAPI void glFogi(GLenum pname, GLint param)
{
	CC->GLFogf(pname, (GLfloat)param);
}

MGLAPI void glFogfv(GLenum pname, GLfloat *param)
{
	CC->GLFogfv(pname, param);
}

MGLAPI void glFrontFace(GLenum mode)
{
	CC->GLFrontFace(mode);
}

MGLAPI void glFrustum(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
{
	CC->GLFrustum(left, right, bottom, top, zNear, zFar);
}

MGLAPI void glGenTextures(GLsizei n, GLuint *textures)
{
	CC->GLGenTextures(n, textures);
}

MGLAPI GLenum glGetError(void)
{
	return CC->GLGetError();
}

MGLAPI void glGetFloatv(GLenum pname, GLfloat *params)
{
	CC->GLGetFloatv(pname, params);
}

MGLAPI const GLubyte * glGetString(GLenum name)
{
	return CC->GLGetString(name);
}

MGLAPI void glHint(GLenum target, GLenum mode)
{
	CC->GLHint(target, mode);
}

MGLAPI void glLoadIdentity(void)
{
	CC->GLLoadIdentity();
}

MGLAPI void glLoadMatrixd(const GLdouble *m)
{
	CC->GLLoadMatrixd(m);
}

MGLAPI void glLoadMatrixf(const GLfloat *m)
{
	CC->GLLoadMatrixf(m);
}

MGLAPI void glMatrixMode(GLenum mode)
{
	CC->GLMatrixMode(mode);
}

MGLAPI void glMultMatrixd(const GLdouble *m)
{
	CC->GLMultMatrixd(m);
}

MGLAPI void glMultMatrixf(const GLfloat *m)
{
	CC->GLMultMatrixf(m);
}

MGLAPI void glNormal3fv(GLfloat n[])
{
	CC->GLNormal3f(n[0], n[1], n[2]);
}

MGLAPI void glNormal3f(GLfloat x, GLfloat y, GLfloat z)
{
	CC->GLNormal3f(x, y, z);
}

MGLAPI void glOrtho(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
{
	CC->GLOrtho(left, right, bottom, top, zNear, zFar);
}

MGLAPI void glPixelStorei(GLenum pname, GLint param)
{
	CC->GLPixelStorei(pname, param);
}

MGLAPI void glPolygonMode(GLenum face, GLenum mode)
{
	CC->GLPolygonMode(face, mode);
}

MGLAPI void glPopMatrix(void)
{
	CC->GLPopMatrix();
}

MGLAPI void glPushMatrix(void)
{
	CC->GLPushMatrix();
}

MGLAPI void glReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels)
{
	CC->GLReadPixels(x, y, width, height, format, type, pixels);
}

MGLAPI void	glRectf(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2)
{
	CC->GLRectf(x1, y1, x2, y2);
}

MGLAPI void	glRects(GLshort x1, GLshort y1, GLshort x2, GLshort y2)
{
	CC->GLRectf((GLfloat)x1, (GLfloat)y1, (GLfloat)x2, (GLfloat)y2);
}

MGLAPI void	glRecti(GLint x1, GLint y1, GLint x2, GLint y2)
{
	CC->GLRectf((GLfloat)x1, (GLfloat)y1, (GLfloat)x2, (GLfloat)y2);
}

MGLAPI void	glRectd(GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2)
{
	CC->GLRectf((GLfloat)x1, (GLfloat)y1, (GLfloat)x2, (GLfloat)y2);
}

MGLAPI void	glRectsv(GLshort *v)
{
	CC->GLRectf((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void	glRectiv(GLint *v)
{
	CC->GLRectf((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void	glRectfv(GLfloat *v)
{
	CC->GLRectf((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void	glRectdv(GLdouble *v)
{
	CC->GLRectf((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}



MGLAPI void glRotatef(GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
	CC->GLRotatef(angle, x, y, z);
}

MGLAPI void glRotated(GLdouble angle, GLdouble x, GLdouble y, GLdouble z)
{
	CC->GLRotatef((GLfloat)angle, (GLfloat)x, (GLfloat)y, (GLfloat)z);
}

MGLAPI void glScalef(GLfloat x, GLfloat y, GLfloat z)
{
	CC->GLScalef(x, y, z);
}

MGLAPI void glScaled(GLdouble x, GLdouble y, GLdouble z)
{
	CC->GLScalef((GLfloat)x, (GLfloat)y, (GLfloat)z);
}

MGLAPI void glScissor(GLint x, GLint y, GLsizei width, GLsizei height)
{
	CC->GLScissor(x, y, width, height);
}

MGLAPI void glShadeModel(GLenum mode)
{
	CC->GLShadeModel(mode);
}

MGLAPI void glTexCoord2f(GLfloat s, GLfloat t)
{
	CC->GLTexCoord2f(s, t);
}

MGLAPI void glTexCoord2d(GLdouble s, GLdouble t)
{
	CC->GLTexCoord2f((GLfloat)s, (GLfloat)t);
}


MGLAPI void glTexCoord2i(GLint s, GLint t)
{
	CC->GLTexCoord2f((GLfloat)s, (GLfloat)t);
}
	
MGLAPI void glTexCoord2fv(GLfloat *v)
{
	CC->GLTexCoord2f(v[0], v[1]);
}

MGLAPI void glTexCoord3f(GLfloat s, GLfloat t, GLfloat r)
{
	CC->GLTexCoord2f(s, t);
}

MGLAPI void glTexCoord3fv(GLfloat *v)
{
	CC->GLTexCoord2f(v[0], v[1]);
}


MGLAPI void glTexCoord4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q)
{
	CC->GLTexCoord4f(s, t, r, q);
}

MGLAPI void glTexCoord4fv(GLfloat *v)
{
	CC->GLTexCoord4f(v[0], v[1], v[2], v[3]);
}

MGLAPI void glTexEnvf(GLenum target, GLenum pname, GLfloat param)
{
	CC->GLTexEnvi(target, pname, (GLint)param);
}

MGLAPI void glTexEnvi(GLenum target, GLenum pname, GLint param)
{
	CC->GLTexEnvi(target, pname, param);
}

MGLAPI void glTexGeni(GLenum coord, GLenum mode, GLint param)
{
	CC->GLTexGeni(coord, mode, param);
}

MGLAPI void glTexGenfv(GLenum coord, GLenum pname, GLfloat *params)
{
	CC->GLTexGenfv(coord, pname, params);
}

MGLAPI void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels)
{
	CC->GLTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
}

MGLAPI void glTexParameteri(GLenum target, GLenum pname, GLint param)
{
	CC->GLTexParameteri(target, pname, param);
}

/*
surgeon begin: you should consider including glTexParameterf - I guess you just forgot :)
ThomasF: Yep, you're right :)
*/
MGLAPI void glTexParameterf(GLenum target, GLenum pname, GLfloat param)
{
	CC->GLTexParameteri(target, pname, (GLint)param);
}
/*
surgeon end
*/


MGLAPI void glTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels)
{
	CC->GLTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels);
}

MGLAPI void glTranslated(GLdouble x, GLdouble y, GLdouble z)
{
	CC->GLTranslatef((GLfloat)x, (GLfloat)y, (GLfloat)z);
}

MGLAPI void glTranslatef(GLfloat x, GLfloat y, GLfloat z)
{
	CC->GLTranslatef(x, y, z);
}

MGLAPI void glViewport(GLint x, GLint y, GLsizei width, GLsizei height)
{
	CC->GLViewport(x, y, width, height);
}


MGLAPI void mglSetBitmap(void *bm)
{
	CC->SetBitmap(bm);
}

MGLAPI void mglDeleteContext(void)
{
	CC->DeleteContext();
	CC = 0;
}

MGLAPI void mglEnableSync(GLboolean enable)
{
	CC->EnableSync(enable);
}

MGLAPI void mglMakeCurrent(void *context)
{
	CC = (struct GLContextIFace *)context;
}

//MGLAPI void mglEnableFrameStats(GLboolean enable)
//{
//	MGLEnableFrameStats(enable);
//}

MGLAPI void mglMinTriArea(GLfloat area)
{
	CC->MinTriArea(area);
}


MGLAPI void * mglGetWindowHandle(void)
{
	return CC->GetWindowHandle();
}


MGLAPI GLboolean mglLockDisplay(void)
{
	return CC->LockDisplay();
}

MGLAPI void mglLockMode(GLenum lockMode)
{
	CC->LockMode(lockMode);
}


MGLAPI void mglResizeContext(GLsizei width, GLsizei height)
{
	CC->ResizeContext(width, height);
}

MGLAPI void mglSwitchDisplay(void)
{
	CC->SwitchDisplay();
}

MGLAPI void mglUnlockDisplay(void)
{
	CC->UnlockDisplay();
}

//MGLAPI void mglTexMemStat(GLint *Current, GLint *Peak)
//{
//	MGLTexMemStat(Current, Peak);
//}

MGLAPI void mglSetZOffset(GLfloat offset)
{
	CC->SetZOffset(offset);
}

MGLAPI void glColorTable(GLenum target, GLenum internalformat, GLint width, GLenum format, GLenum type, GLvoid *data)
{
	CC->GLColorTable(target, internalformat, width, format, type, data);
}

MGLAPI void glColorTableEXT(GLenum target, GLenum internalformat, GLint width, GLenum format, GLenum type, GLvoid *data)
{
	CC->GLColorTable(target, internalformat, width, format, type, data);
}



/*
** Additional functions for targetted context creation
*/

MGLAPI GLboolean mglLockBack(MGLLockInfo *info)
{
	return CC->LockBack(info);
}


/*
** Functions implementing vertex arras
*/

MGLAPI void glEnableClientState(GLenum cap)
{
	CC->GLEnableClientState(cap);
}

MGLAPI void glDisableClientState(GLenum cap)
{
	CC->GLDisableClientState(cap);
}

MGLAPI void glClientActiveTexture(GLenum texture)
{
	CC->GLClientActiveTexture(texture);
}

MGLAPI void glClientActiveTextureARB(GLenum texture)
{
	CC->GLClientActiveTexture(texture);
}

MGLAPI void glTexCoordPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
	CC->GLTexCoordPointer(size, type, stride, pointer);
}

MGLAPI void glColorPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
	CC->GLColorPointer(size, type, stride, pointer);
}

MGLAPI void glNormalPointer(GLenum type, GLsizei stride, const GLvoid *pointer)
{
	CC->GLNormalPointer(type, stride, pointer);
}

MGLAPI void glVertexPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer)
{
	CC->GLVertexPointer(size, type, stride, pointer);
}

MGLAPI void glInterleavedArrays(GLenum format, GLsizei stride, const GLvoid *pointer) 
{
	CC->GLInterleavedArrays(format, stride, pointer);
}

MGLAPI void glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *pointer)
{
	CC->GLDrawElements(mode, count, type, pointer);
}

MGLAPI void glDrawArrays(GLenum mode, GLint first, GLsizei count)
{
	CC->GLDrawArrays(mode, first, count);
}

MGLAPI void glArrayElement(GLint i) 
{
	CC->GLArrayElement(i);
}

MGLAPI void glLockArraysEXT(GLint first, GLsizei count)
{
	CC->GLLockArrays(first, count);
}

MGLAPI void glUnlockArraysEXT(void)
{
	CC->GLUnlockArrays();
}


MGLAPI void glPushAttrib(GLbitfield bits)
{
	CC->GLPushAttrib(bits);
}

MGLAPI void glPopAttrib(void)
{
	CC->GLPopAttrib();
}


/*
** Everything related to multitexturing
*/

MGLAPI void glActiveTextureARB(GLenum unit)
{
	CC->GLActiveTexture(unit);
}

MGLAPI void glMultiTexCoord2fARB(GLenum unit, GLfloat s, GLfloat t)
{
	CC->GLMultiTexCoord2f(unit, s, t);
}

MGLAPI void glMultiTexCoord2fvARB(GLenum unit, GLfloat *v)
{
	CC->GLMultiTexCoord2f(unit, v[0], v[1]);
}

MGLAPI void glMultiTexCoord4fARB(GLenum unit, GLfloat s, GLfloat t, GLfloat r, GLfloat q)
{
	CC->GLMultiTexCoord4f(unit, s, t, r, q);
}

MGLAPI void glMultiTexCoord4fvARB(GLenum unit, GLfloat *v)
{
	CC->GLMultiTexCoord4f(unit, v[0], v[1], v[2], v[3]);
}


MGLAPI void glActiveTexture(GLenum unit)
{
	CC->GLActiveTexture(unit);
}

MGLAPI void glMultiTexCoord2f(GLenum unit, GLfloat s, GLfloat t)
{
	CC->GLMultiTexCoord2f(unit, s, t);
}

MGLAPI void glMultiTexCoord2fv(GLenum unit, GLfloat *v)
{
	CC->GLMultiTexCoord2f(unit, v[0], v[1]);
}

MGLAPI void glMultiTexCoord4f(GLenum unit, GLfloat s, GLfloat t, GLfloat r, GLfloat q)
{
	CC->GLMultiTexCoord4f(unit, s, t, r, q);
}

MGLAPI void glMultiTexCoord4fv(GLenum unit, GLfloat *v)
{
	CC->GLMultiTexCoord4f(unit, v[0], v[1], v[2], v[3]);
}

MGLAPI void glMaterialf(GLenum face, GLenum pname, GLfloat param)
{
	CC->GLMaterialf(face, pname, param);
}

MGLAPI void glMateriali(GLenum face, GLenum pname, GLint param)
{
	CC->GLMaterialf(face, pname, (GLfloat)param);
}

MGLAPI void glMaterialfv(GLenum face, GLenum pname, GLfloat *params)
{
	CC->GLMaterialfv(face, pname, params);
}

MGLAPI void glMaterialiv(GLenum face, GLenum pname, GLint *params)
{
	CC->GLMaterialiv(face, pname, params);
}

MGLAPI void glLightf(GLenum light, GLenum pname, GLfloat param)
{
	CC->GLLightf(light, pname, param);
}

MGLAPI void glLighti(GLenum light, GLenum pname, GLint param)
{
	CC->GLLightf(light, pname, (GLfloat)param);
}

MGLAPI void glLightfv(GLenum light, GLenum pname, GLfloat* params)
{
	CC->GLLightfv(light, pname, params);
}

MGLAPI void glLightiv(GLenum light, GLenum pname, GLint *params)
{
	CC->GLLightiv(light, pname, params);
}

MGLAPI void glLighModelf(GLenum pname, GLfloat param)
{
	CC->GLLightModelf(pname, param);
}

MGLAPI void glLightModeli(GLenum pname, GLint param)
{
	CC->GLLightModelf(pname, (GLfloat)param);
}

MGLAPI void glLightModelfv(GLenum pname, GLfloat *params)
{
	CC->GLLightModelfv(pname, params);
}

MGLAPI void glLightModeliv(GLenum pname, GLint *params)
{
	CC->GLLightModeliv(pname, params);
}

MGLAPI void glColorMaterial(GLenum face, GLenum mode)
{
	CC->GLColorMaterial(face, mode);
}

MGLAPI void mglGrabFocus(GLboolean yesno)
{
    CC->GrabFocus(yesno);
}

MGLAPI void glStencilOp(GLenum sfail, GLenum dpfail, GLenum dppass)
{
	CC->GLStencilOp(sfail, dpfail, dppass);
}

MGLAPI void glStencilFunc(GLenum func, GLint ref, GLint mask)
{
	CC->GLStencilFunc(func, ref, mask);
}

MGLAPI void glClearStencil(GLint s)
{
	CC->GLClearStencil(s);
}

MGLAPI void glStencilMask(GLuint mask)
{
	CC->GLStencilMask(mask);
}

MGLAPI void glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha)
{
	CC->GLColorMask(red, green, blue, alpha);
}

MGLAPI void glLineWidth(GLfloat width)
{
	CC->GLLineWidth(width);
}

MGLAPI void glPointSize(GLfloat size)
{
	CC->GLPointSize(size);
}

MGLAPI void glBitmap(GLsizei w, GLsizei h, GLfloat xbo, GLfloat ybo, GLfloat xbi, GLfloat ybi, GLubyte *data)
{
	CC->GLBitmap(w, h, xbo, ybo, xbi, ybi, data);
}

MGLAPI void glLineStipple(GLint factor, GLushort pattern)
{
	CC->GLLineStipple(factor, pattern);
}

MGLAPI void glPolygonStipple(GLubyte *pattern)
{
	CC->GLPolygonStipple(pattern);
}

MGLAPI void glRasterPos2s(GLshort x, GLshort y)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, 0.0f, 1.0f);
}

MGLAPI void glRasterPos2i(GLint x, GLint y)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, 0.0f, 1.0f);
}

MGLAPI void glRasterPos2f(GLfloat x, GLfloat y)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, 0.0f, 1.0f);
}

MGLAPI void glRasterPos2d(GLdouble x, GLdouble y)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, 0.0f, 1.0f);
}

MGLAPI void glRasterPos3s(GLshort x, GLshort y, GLshort z)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, (GLfloat)z, 1.0f);
}

MGLAPI void glRasterPos3i(GLint x, GLint y, GLint z)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, (GLfloat)z, 1.0f);
}

MGLAPI void glRasterPos3f(GLfloat x, GLfloat y, GLfloat z)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, (GLfloat)z, 1.0f);
}

MGLAPI void glRasterPos3d(GLdouble x, GLdouble y, GLdouble z)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, (GLfloat)z, 1.0f);
}

MGLAPI void glRasterPos4s(GLshort x, GLshort y, GLshort z, GLshort w)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, (GLfloat)z, (GLfloat)w);
}

MGLAPI void glRasterPos4i(GLint x, GLint y, GLint z, GLint w)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, (GLfloat)z, (GLfloat)w);
}

MGLAPI void glRasterPos4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, (GLfloat)z, (GLfloat)w);
}

MGLAPI void glRasterPos4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w)
{
	CC->GLRasterPos4f((GLfloat)x, (GLfloat)y, (GLfloat)z, (GLfloat)w);
}

MGLAPI void glRasterPos2sv(GLshort *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], 0.0f, 1.0f);
}

MGLAPI void glRasterPos2iv(GLint *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], 0.0f, 1.0f);
}

MGLAPI void glRasterPos2fv(GLfloat *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], 0.0f, 1.0f);
}

MGLAPI void glRasterPos2dv(GLdouble *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], 0.0f, 1.0f);
}

MGLAPI void glRasterPos3sv(GLshort *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glRasterPos3iv(GLint *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glRasterPos3fv(GLfloat *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glRasterPos3dv(GLdouble *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], 1.0f);
}

MGLAPI void glRasterPos4sv(GLshort *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glRasterPos4iv(GLint *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glRasterPos4fv(GLfloat *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glRasterPos4dv(GLdouble *v)
{
	CC->GLRasterPos4f((GLfloat)v[0], (GLfloat)v[1], (GLfloat)v[2], (GLfloat)v[3]);
}

MGLAPI void glCallList(GLuint list)
{
	CC->GLCallList(list);
}

MGLAPI void glCallLists(GLsizei n, GLenum type, const GLvoid *lists)
{
	CC->GLCallLists(n, type, lists);
}

MGLAPI void glDeleteLists(GLuint list, GLsizei range)
{
	CC->GLDeleteLists(list, range);
}

MGLAPI GLuint glGenLists(GLsizei range)
{
	return CC->GLGenLists(range);
}

MGLAPI void glNewList(GLuint list, GLenum mode)
{
	CC->GLNewList(list, mode);
}

MGLAPI void glEndList(void)
{
	CC->GLEndList();
}

MGLAPI GLboolean glIsList(GLuint list){
	return CC->GLIsList(list);
}

MGLAPI void glListBase(GLuint base){
	CC->GLListBase(base);
}


/* -------------------- Unsupported stubs -------------------- */
MGLAPI void glEdgeFlag(GLboolean edge)
{
}


MGLAPI void glReadBuffer(GLenum mode)
{
	/* Does nothing */
}

MGLAPI void glPrioritizeTextures(GLsizei n, const GLuint *textures, const GLclampf *priorities)
{
	/* Ignored */
}

MGLAPI void glDrawPixels(GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels)
{
	/* IMPLEMENT ME */
}

MGLAPI void glGetTexLevelParameterfv(GLenum target, GLint level, GLenum pname, GLfloat *params)
{
	/* IMPLEMENT ME */
	/* IMPLEMENT PORXY_TEXTURE */
}

MGLAPI void glGetTexLevelParameteriv(GLenum target, GLint level, GLenum pname, GLint *params)
{
	/* IMPLEMENT ME */
	/* IMPLEMENT PORXY_TEXTURE */
}

MGLAPI void *mglGetProcAddress(const char *name)
{
	return 0; /*MGLGetProcAddress(name);*/
}

/* Render Targets and texture pinning */

MGLAPI void mglPinTexture(GLuint texnum)
{
	CC->PinTexture(texnum);
}

MGLAPI void mglUnpinTexture(GLuint texnum)
{
	CC->UnpinTexture(texnum);
}

MGLAPI void mglSetTextureRenderTarget(GLuint texnum)
{
	CC->SetTextureRenderTarget(texnum);
}

/* GLU */

MGLAPI void gluLookAt(GLfloat ex, GLfloat ey, GLfloat ez, GLfloat cx, GLfloat cy, GLfloat cz, GLfloat ux, GLfloat uy, GLfloat uz)
{
	GLULookAt(ex, ey, ez, cx, cy, cz, ux, uy, uz);
}

MGLAPI void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat znear, GLfloat zfar)
{
	GLUPerspective(fovy, aspect, znear, zfar);
}

MGLAPI void gluOrtho2D(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top)
{
	GLcontext c = (GLcontext)GET_INSTANCE(CC);
	GLUOrtho2D(c, left, right, bottom, top);
}

MGLAPI GLint gluBuild2DMipmaps(GLenum target, GLint components, GLint width, GLint height, GLenum format, GLenum type, const void *data)
{
	GLcontext c = (GLcontext)GET_INSTANCE(CC);
	return GLUBuild2DMipmaps(c, target, components, width, height, format, type, data);
}


#endif
