/*
**	$VER: cybergl_protos.h 1.0 (20.03.1997)
**
**	C prototypes. For use with 32 bit integers only.
**
**	Copyright © 1996-1997 by phase5 digital products
**	All Rights reserved.
**
*/

#ifndef  CLIB_CYBERGL_H
#define  CLIB_CYBERGL_H

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef  INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif
#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

/*--------------gl window related ---------------------------------------------*/

GLvoid *openGLWindowTagList(GLint width, GLint height, struct TagItem *tags);
//GLvoid *openGLWindowTags(GLint width, GLint height, Tag, ...);
#ifndef _INLINE_CYBERGL_H
#define openGLWindowTags(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; openGLWindowTagList((a0), (a1), (struct TagItem *)_tags);})
#endif
GLvoid closeGLWindow(GLvoid *window);
GLvoid *attachGLWindowTagList(struct Window *wnd, GLint width, GLint height, struct TagItem *tags);
//GLvoid *attachGLWindowTags(struct Window *wnd, GLint width, GLint height, Tag, ...);
#ifndef _INLINE_CYBERGL_H
#define attachGLWindowTags(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; attachGLWindowTagList((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif
GLvoid disposeGLWindow(GLvoid *window);
GLvoid resizeGLWindow(GLvoid *window, GLint width, GLint height);
struct Window *getWindow(GLvoid *window);
GLubyte allocColor(GLvoid *window, GLubyte r, GLubyte g, GLubyte b);
GLubyte allocColorRange(GLvoid *window, GLubyte r1, GLubyte g1, GLubyte b1, GLubyte r2, GLubyte g2, GLubyte b2, GLubyte num);
GLvoid *attachGLWndToRPTagList(struct Screen *scr, struct RastPort *rp, GLint width, GLint height, struct TagItem *tags);
//GLvoid *attachGLWndToRPTags(struct Screen *scr, struct RastPort *rp, GLint width, GLint height, Tag, ...);
#ifndef _INLINE_CYBERGL_H
#define attachGLWndToRPTags(a0, a1, a2, a3, tags...) \
	({ULONG _tags[] = { tags }; attachGLWndToRPTagList((a0), (a1), (a2), (a3), (struct TagItem *)_tags);})
#endif

/*----------------------Contexts-----------------------------*/

GLenum glGetError(GLvoid);
GLvoid glEnable (GLenum cap);
GLvoid glDisable(GLenum cap);
GLboolean glIsEnabled(GLenum cap);
GLvoid glGetBooleanv(GLenum pname, GLboolean *params);
GLvoid glGetIntegerv(GLenum pname, GLint *params);
GLvoid glGetFloatv(GLenum pname, GLfloat *params);
GLvoid glGetDoublev(GLenum pname, GLdouble *params);
GLvoid glGetClipPlane(GLenum plane, GLdouble *equation);
GLvoid glGetLightfv(GLenum light, GLenum pname, GLfloat *params);
GLvoid glGetLightiv(GLenum light, GLenum pname, GLint *params);
GLvoid glGetMaterialfv(GLenum face, GLenum pname, GLfloat *params);
GLvoid glGetMaterialiv(GLenum face, GLenum pname, GLint *params);
GLvoid glGetTexGendv(GLenum coord, GLenum pname, GLdouble *params);
GLvoid glGetTexGenfv(GLenum coord, GLenum pname, GLfloat *params);
GLvoid glGetTexGeniv(GLenum coord, GLenum pname, GLint *params);
GLvoid glGetPixelMapfv(GLenum map, GLfloat *values);
GLvoid glGetPixelMapuiv(GLenum map, GLuint *values);
GLvoid glGetPixelMapusv(GLenum map, GLushort *values);
GLvoid glGetTexEnvfv(GLenum target, GLenum pname, GLfloat *params);
GLvoid glGetTexEnviv(GLenum target, GLenum pname, GLint *params);
GLvoid glGetTexLevelParameterfv(GLenum target, GLint level, GLenum pname, GLfloat *params);
GLvoid glGetTexLevelParameteriv(GLenum target, GLint level, GLenum pname, GLint *params);
GLvoid glGetTexParameterfv(GLenum target, GLenum pname, GLfloat *params);
GLvoid glGetTexParameteriv(GLenum target, GLenum pname, GLint *params);
GLvoid glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels);
GLubyte *glGetString(GLenum name);
GLvoid glPushAttrib(GLbitfield mask);
GLvoid glPopAttrib(GLvoid);

/*----------------------Primitives---------------------------*/

GLvoid glBegin(GLenum mode);
GLvoid glEnd(GLvoid);

GLvoid glVertex2s(GLshort x, GLshort y);
GLvoid glVertex2i(GLint x, GLint y);
GLvoid glVertex2f(GLfloat x, GLfloat y);
GLvoid glVertex2d(GLdouble x, GLdouble y);
GLvoid glVertex3s(GLshort x, GLshort y, GLshort z);
GLvoid glVertex3i(GLint x, GLint y, GLint z);
GLvoid glVertex3f(GLfloat x, GLfloat y, GLfloat z);
GLvoid glVertex3d(GLdouble x, GLdouble y, GLdouble z);
GLvoid glVertex4s(GLshort x, GLshort y, GLshort z, GLshort w);
GLvoid glVertex4i(GLint x, GLint y, GLint z, GLint w);
GLvoid glVertex4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w);
GLvoid glVertex4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w);
GLvoid glVertex2sv(const GLshort *v);
GLvoid glVertex2iv(const GLint *v);
GLvoid glVertex2fv(const GLfloat *v);
GLvoid glVertex2dv(const GLdouble *v);
GLvoid glVertex3sv(const GLshort *v);
GLvoid glVertex3iv(const GLint *v);
GLvoid glVertex3fv(const GLfloat *v);
GLvoid glVertex3dv(const GLdouble *v);
GLvoid glVertex4sv(const GLshort *v);
GLvoid glVertex4iv(const GLint *v);
GLvoid glVertex4fv(const GLfloat *v);
GLvoid glVertex4dv(const GLdouble *v);

GLvoid glTexCoord1s(GLshort s);
GLvoid glTexCoord1i(GLint s);
GLvoid glTexCoord1f(GLfloat s);
GLvoid glTexCoord1d(GLdouble s);
GLvoid glTexCoord2s(GLshort s, GLshort t);
GLvoid glTexCoord2i(GLint s, GLint t);
GLvoid glTexCoord2f(GLfloat s, GLfloat t);
GLvoid glTexCoord2d(GLdouble s, GLdouble t);
GLvoid glTexCoord3s(GLshort s, GLshort t, GLshort r);
GLvoid glTexCoord3i(GLint s, GLint t, GLint r);
GLvoid glTexCoord3f(GLfloat s, GLfloat t, GLfloat r);
GLvoid glTexCoord3d(GLdouble s, GLdouble t, GLdouble r);
GLvoid glTexCoord4s(GLshort s, GLshort t, GLshort r, GLshort q);
GLvoid glTexCoord4i(GLint s, GLint t, GLint r, GLint q);
GLvoid glTexCoord4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q);
GLvoid glTexCoord4d(GLdouble s, GLdouble t, GLdouble r, GLdouble q);
GLvoid glTexCoord1sv(const GLshort *v);
GLvoid glTexCoord1iv(const GLint *v);
GLvoid glTexCoord1fv(const GLfloat *v);
GLvoid glTexCoord1dv(const GLdouble *v);
GLvoid glTexCoord2sv(const GLshort *v);
GLvoid glTexCoord2iv(const GLint *v);
GLvoid glTexCoord2fv(const GLfloat *v);
GLvoid glTexCoord2dv(const GLdouble *v);
GLvoid glTexCoord3sv(const GLshort *v);
GLvoid glTexCoord3iv(const GLint *v);
GLvoid glTexCoord3fv(const GLfloat *v);
GLvoid glTexCoord3dv(const GLdouble *v);
GLvoid glTexCoord4sv(const GLshort *v);
GLvoid glTexCoord4iv(const GLint *v);
GLvoid glTexCoord4fv(const GLfloat *v);
GLvoid glTexCoord4dv(const GLdouble *v);

GLvoid glNormal3b(GLbyte nx, GLbyte ny, GLbyte nz);
GLvoid glNormal3s(GLshort nx, GLshort ny, GLshort nz);
GLvoid glNormal3i(GLint nx, GLint ny, GLint nz);
GLvoid glNormal3f(GLfloat nx, GLfloat ny, GLfloat nz);
GLvoid glNormal3d(GLdouble nx, GLdouble ny, GLdouble nz);
GLvoid glNormal3bv(const GLbyte *v);
GLvoid glNormal3sv(const GLshort *v);
GLvoid glNormal3iv(const GLint *v);
GLvoid glNormal3fv(const GLfloat *v);
GLvoid glNormal3dv(const GLdouble *v);

GLvoid glColor3b(GLbyte red, GLbyte green, GLbyte blue);
GLvoid glColor3s(GLshort red, GLshort green, GLshort blue);
GLvoid glColor3i(GLint red, GLint green, GLint blue);
GLvoid glColor3f(GLfloat red, GLfloat green, GLfloat blue);
GLvoid glColor3d(GLdouble red, GLdouble green, GLdouble blue);
GLvoid glColor3ub(GLubyte red, GLubyte green, GLubyte blue);
GLvoid glColor3us(GLushort red, GLushort green, GLushort blue);
GLvoid glColor3ui(GLuint red, GLuint green, GLuint blue);
GLvoid glColor4b(GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha);
GLvoid glColor4s(GLshort red, GLshort green, GLshort blue, GLshort alpha);
GLvoid glColor4i(GLint red, GLint green, GLint blue, GLint alpha);
GLvoid glColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
GLvoid glColor4d(GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha);
GLvoid glColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha);
GLvoid glColor4us(GLushort red, GLushort green, GLushort blue, GLushort alpha);
GLvoid glColor4ui(GLuint red, GLuint green, GLuint blue, GLuint alpha);
GLvoid glColor3bv(const GLbyte *v);
GLvoid glColor3sv(const GLshort *v);
GLvoid glColor3iv(const GLint *v);
GLvoid glColor3fv(const GLfloat *v);
GLvoid glColor3dv(const GLdouble *v);
GLvoid glColor3ubv(const GLubyte *v);
GLvoid glColor3usv(const GLushort *v);
GLvoid glColor3uiv(const GLuint *v);
GLvoid glColor4bv(const GLbyte *v);
GLvoid glColor4sv(const GLshort *v);
GLvoid glColor4iv(const GLint *v);
GLvoid glColor4fv(const GLfloat *v);
GLvoid glColor4dv(const GLdouble *v);
GLvoid glColor4ubv(const GLubyte *v);
GLvoid glColor4usv(const GLushort *v);
GLvoid glColor4uiv(const GLuint *v);

GLvoid glIndexs(GLshort index);
GLvoid glIndexi(GLint index);
GLvoid glIndexf(GLfloat index);
GLvoid glIndexd(GLdouble index);
GLvoid glIndexsv(const GLshort *v);
GLvoid glIndexiv(const GLint *v);
GLvoid glIndexfv(const GLfloat *v);
GLvoid glIndexdv(const GLdouble *v);

GLvoid glRects(GLshort x1, GLshort y1, GLshort x2, GLshort y2);
GLvoid glRecti(GLint x1, GLint y1, GLint x2, GLint y2);
GLvoid glRectf(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2);
GLvoid glRectd(GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2);
GLvoid glRectsv(const GLshort *v1, const GLshort *v2);
GLvoid glRectiv(const GLint *v1, const GLint *v2);
GLvoid glRectfv(const GLfloat *v1, const GLfloat *v2);
GLvoid glRectdv(const GLdouble *v1, const GLdouble *v2);

GLvoid glEdgeFlag(GLboolean flag);
GLvoid glEdgeFlagv(const GLboolean *flag);

GLvoid glRasterPos2s(GLshort s, GLshort t);
GLvoid glRasterPos2i(GLint s, GLint t);
GLvoid glRasterPos2f(GLfloat s, GLfloat t);
GLvoid glRasterPos2d(GLdouble s, GLdouble t);
GLvoid glRasterPos3s(GLshort s, GLshort t, GLshort r);
GLvoid glRasterPos3i(GLint s, GLint t, GLint r);
GLvoid glRasterPos3f(GLfloat s, GLfloat t, GLfloat r);
GLvoid glRasterPos3d(GLdouble s, GLdouble t, GLdouble r);
GLvoid glRasterPos4s(GLshort s, GLshort t, GLshort r, GLshort q);
GLvoid glRasterPos4i(GLint s, GLint t, GLint r, GLint q);
GLvoid glRasterPos4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q);
GLvoid glRasterPos4d(GLdouble s, GLdouble t, GLdouble r, GLdouble q);
GLvoid glRasterPos2sv(const GLshort *v);
GLvoid glRasterPos2iv(const GLint *v);
GLvoid glRasterPos2fv(const GLfloat *v);
GLvoid glRasterPos2dv(const GLdouble *v);
GLvoid glRasterPos3sv(const GLshort *v);
GLvoid glRasterPos3iv(const GLint *v);
GLvoid glRasterPos3fv(const GLfloat *v);
GLvoid glRasterPos3dv(const GLdouble *v);
GLvoid glRasterPos4sv(const GLshort *v);
GLvoid glRasterPos4iv(const GLint *v);
GLvoid glRasterPos4fv(const GLfloat *v);
GLvoid glRasterPos4dv(const GLdouble *v);

/*----------------------Transforming-------------------------*/

GLvoid glDepthRange(GLclampd zNear, GLclampd zFar);
GLvoid glViewport(GLint x, GLint y, GLsizei width, GLsizei height);
GLvoid glMatrixMode(GLenum mode);
GLvoid glLoadMatrixf(const GLfloat *m);
GLvoid glLoadMatrixd(const GLdouble *m);
GLvoid glMultMatrixf(const GLfloat *m);
GLvoid glMultMatrixd(const GLdouble *m);
GLvoid glLoadIdentity(GLvoid);
GLvoid glRotatef(GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
GLvoid glRotated(GLdouble angle, GLdouble x, GLdouble y, GLdouble z);
GLvoid glTranslatef(GLfloat x, GLfloat y, GLfloat z);
GLvoid glTranslated(GLdouble x, GLdouble y, GLdouble z);
GLvoid glScalef(GLfloat x, GLfloat y, GLfloat z);
GLvoid glScaled(GLdouble x, GLdouble y, GLdouble z);
GLvoid glFrustum(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, 
    GLdouble zNear, GLdouble zFar);
GLvoid glOrtho(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, 
    GLdouble zNear, GLdouble zFar);

GLvoid glPushMatrix(GLvoid);
GLvoid glPopMatrix(GLvoid);
GLvoid glOrtho2D(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top);
GLboolean glProject(GLdouble objx, GLdouble objy, GLdouble objz, 
    GLdouble *winx, GLdouble *winy, GLdouble *winz);
GLboolean glUnProject(GLdouble winx, GLdouble winy, GLdouble winz, 
    GLdouble *objx, GLdouble *objy, GLdouble *objz);

GLvoid glPerspective(GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar);

GLvoid glLookAt(GLdouble eyex, GLdouble eyey, GLdouble eyez, 
    GLdouble centerx, GLdouble centery, GLdouble centerz, 
    GLdouble upx, GLdouble upy, GLdouble upz);
GLvoid glPickMatrix(GLdouble x, GLdouble y, GLdouble width, GLdouble height);

/*----------------------Clipping-----------------------------*/

GLvoid glClipPlane(GLenum plane, const GLdouble *equation);

/*----------------------Drawing--------------------------*/

GLvoid glClear(GLbitfield mask);
GLvoid glClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);
GLvoid glClearIndex(GLfloat index);
GLvoid glClearDepth(GLclampd depth);
GLvoid glFlush(GLvoid);
GLvoid glFinish(GLvoid);
GLvoid glHint(GLenum target, GLenum mode);
GLvoid glDrawBuffer(GLenum mode);
GLvoid glFogf(GLenum pname, GLfloat param);
GLvoid glFogi(GLenum pname, GLint param);
GLvoid glFogfv(GLenum pname, const GLfloat *params);
GLvoid glFogiv(GLenum pname, const GLint *params);
GLvoid glDepthFunc(GLenum func);
GLvoid glPolygonMode(GLenum face, GLenum mode);
GLvoid glShadeModel(GLenum mode);
GLvoid glCullFace(GLenum mode);
GLvoid glFrontFace(GLenum mode);

/*----------------------Selection----------------------------*/

GLint glRenderMode(GLenum mode);
GLvoid glInitNames(GLvoid);
GLvoid glLoadName(GLuint name);
GLvoid glPushName(GLuint name);
GLvoid glPopName(GLvoid);
GLvoid glSelectBuffer(GLsizei size, GLuint *buffer);

/*----------------------Lighting-----------------------------*/

GLvoid glLightf(GLenum light, GLenum pname, GLfloat param);
GLvoid glLighti(GLenum light, GLenum pname, GLint param);
GLvoid glLightfv(GLenum light, GLenum pname, GLfloat *params);
GLvoid glLightiv(GLenum light, GLenum pname, GLint *params);
GLvoid glLightModelf(GLenum pname, GLfloat param);
GLvoid glLightModeli(GLenum pname, GLint param);
GLvoid glLightModelfv(GLenum pname, GLfloat *params);
GLvoid glLightModeliv(GLenum pname, GLint *params);
GLvoid glMaterialf(GLenum face, GLenum pname, GLfloat param);
GLvoid glMateriali(GLenum face, GLenum pname, GLint param);
GLvoid glMaterialfv(GLenum face, GLenum pname, GLfloat *params);
GLvoid glMaterialiv(GLenum face, GLenum pname, GLint *params);
GLvoid glColorMaterial(GLenum face, GLenum mode);

/*----------------------Texturing----------------------------*/

GLvoid glTexGeni(GLenum coord, GLenum pname, GLint param);
GLvoid glTexGenf(GLenum coord, GLenum pname, GLfloat param);
GLvoid glTexGend(GLenum coord, GLenum pname, GLdouble param);
GLvoid glTexGeniv(GLenum coord, GLenum pname, const GLint *params);
GLvoid glTexGenfv(GLenum coord, GLenum pname, const GLfloat *params);
GLvoid glTexGendv(GLenum coord, GLenum pname, const GLdouble *params);
GLvoid glTexEnvf(GLenum target, GLenum pname, GLfloat param);
GLvoid glTexEnvi(GLenum target, GLenum pname, GLint param);
GLvoid glTexEnvfv(GLenum target, GLenum pname, const GLfloat *params);
GLvoid glTexEnviv(GLenum target, GLenum pname, const GLint *params);
GLvoid glTexParameterf(GLenum target, GLenum pname, GLfloat param);
GLvoid glTexParameteri(GLenum target, GLenum pname, GLint param);
GLvoid glTexParameterfv(GLenum target, GLenum pname, const GLfloat *params);
GLvoid glTexParameteriv(GLenum target, GLenum pname, const GLint *params);
GLvoid glTexImage1D(GLenum target, GLint level, GLint components, GLsizei width, 
    GLint border, GLenum format, GLenum type, const GLvoid *pixels);
GLvoid glTexImage2D(GLenum target, GLint level, GLint components, GLsizei width, GLsizei height, 
    GLint border, GLenum format, GLenum type, const GLvoid *pixels);

/*------------------------Images-----------------------------*/

GLvoid glPixelStorei(GLenum pname, GLint param);
GLvoid glPixelStoref(GLenum pname, GLfloat param);
GLvoid glPixelTransferi(GLenum pname, GLint param);
GLvoid glPixelTransferf(GLenum pname, GLfloat param);
GLvoid glPixelMapuiv(GLenum map, GLsizei mapsize, const GLuint values[]);
GLvoid glPixelMapusv(GLenum map, GLsizei mapsize, const GLushort values[]);
GLvoid glPixelMapfv(GLenum map, GLsizei mapsize, const GLfloat values[]);
GLvoid glPixelZoom(GLfloat xfactor, GLfloat yfactor);
GLvoid glDrawPixels(GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *data);
GLvoid glBitmap(GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, 
    GLfloat xmove, GLfloat ymove, const GLubyte *bitmap);

/*-----------------------------------------------------------*/
#endif
