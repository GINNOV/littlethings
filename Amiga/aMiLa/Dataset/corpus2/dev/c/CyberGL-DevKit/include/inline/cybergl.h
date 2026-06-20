/* Automatically generated header! Do not edit! */

#ifndef _INLINE_CYBERGL_H
#define _INLINE_CYBERGL_H

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif /* !__INLINE_MACROS_H */

#ifndef CYBERGL_BASE_NAME
#define CYBERGL_BASE_NAME CyberGLBase
#endif /* !CYBERGL_BASE_NAME */

#define allocColor(window, r, g, b) \
	LP4(0x42, GLubyte, allocColor, void *, window, a0, GLubyte, r, d0, GLubyte, g, d1, GLubyte, b, d2, \
	, CYBERGL_BASE_NAME)

#define allocColorRange(window, r1, g1, b1, r2, g2, b2, num) \
	LP8(0x48, GLubyte, allocColorRange, void *, window, a0, GLubyte, r1, d0, GLubyte, g1, d1, GLubyte, b1, d2, GLubyte, r2, d3, GLubyte, g2, d4, GLubyte, b2, d5, GLubyte, num, d6, \
	, CYBERGL_BASE_NAME)

#define attachGLWindowTagList(wnd, width, height, tags) \
	LP4(0x2a, void *, attachGLWindowTagList, struct Window *, wnd, a0, GLint, width, d0, GLint, height, d1, struct TagItem *, tags, a1, \
	, CYBERGL_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define attachGLWindowTags(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; attachGLWindowTagList((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define attachGLWndToRPTagList(scr, rp, width, height, tags) \
	LP5(0x4e, void *, attachGLWndToRPTagList, struct Screen *, scr, a0, struct RastPort *, rp, a1, GLint, width, d0, GLint, height, d1, struct TagItem *, tags, a2, \
	, CYBERGL_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define attachGLWndToRPTags(a0, a1, a2, a3, tags...) \
	({ULONG _tags[] = { tags }; attachGLWndToRPTagList((a0), (a1), (a2), (a3), (struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define closeGLWindow(window) \
	LP1NR(0x24, closeGLWindow, void *, window, a0, \
	, CYBERGL_BASE_NAME)

#define disposeGLWindow(window) \
	LP1NR(0x30, disposeGLWindow, void *, window, a0, \
	, CYBERGL_BASE_NAME)

#define getWindow(window) \
	LP1(0x3c, struct Window *, getWindow, void *, window, a0, \
	, CYBERGL_BASE_NAME)

#define glBegin(mode) \
	LP1NR(0x114, glBegin, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)

#define glBitmap_jump(bitmap) \
	LP1NR(0x66c, glBitmap, const GLbitmap *, bitmap, a0, \
	, CYBERGL_BASE_NAME)
extern __inline GLvoid glBitmap(GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig,
                                GLfloat xmove, GLfloat ymove, GLubyte *bitmap) {
  GLbitmap sbitmap;
  
  sbitmap.width = width;
  sbitmap.height = height;
  sbitmap.xorig = xorig;
  sbitmap.xmove = xmove;
  sbitmap.ymove = ymove;
  sbitmap.bitmap = bitmap;
  
  glBitmap_jump(&sbitmap);
}

#define glClear(mask) \
	LP1NR(0x4fe, glClear, GLbitfield, mask, d0, \
	, CYBERGL_BASE_NAME)

#define glClearColor(red, green, blue, alpha) \
	LP4NR(0x504, glClearColor, GLclampf, red, fp0, GLclampf, green, fp1, GLclampf, blue, fp2, GLclampf, alpha, fp3, \
	, CYBERGL_BASE_NAME)

#define glClearDepth(depth) \
	LP1NR(0x510, glClearDepth, GLclampd, depth, fp0, \
	, CYBERGL_BASE_NAME)

#define glClearIndex(index) \
	LP1NR(0x50a, glClearIndex, GLfloat, index, fp0, \
	, CYBERGL_BASE_NAME)

#define glClipPlane(plane, equation) \
	LP2NR(0x4f8, glClipPlane, GLenum, plane, d0, const GLdouble *, equation, a0, \
	, CYBERGL_BASE_NAME)

#define glColor3b(red, green, blue) \
	LP3NR(0x2ac, glColor3b, GLbyte, red, d0, GLbyte, green, d1, GLbyte, blue, d2, \
	, CYBERGL_BASE_NAME)

#define glColor3bv(v) \
	LP1NR(0x30c, glColor3bv, const GLbyte *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor3d(red, green, blue) \
	LP3NR(0x2c4, glColor3d, GLdouble, red, fp0, GLdouble, green, fp1, GLdouble, blue, fp2, \
	, CYBERGL_BASE_NAME)

#define glColor3dv(v) \
	LP1NR(0x324, glColor3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor3f(red, green, blue) \
	LP3NR(0x2be, glColor3f, GLfloat, red, fp0, GLfloat, green, fp1, GLfloat, blue, fp2, \
	, CYBERGL_BASE_NAME)

#define glColor3fv(v) \
	LP1NR(0x31e, glColor3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor3i(red, green, blue) \
	LP3NR(0x2b8, glColor3i, GLint, red, d0, GLint, green, d1, GLint, blue, d2, \
	, CYBERGL_BASE_NAME)

#define glColor3iv(v) \
	LP1NR(0x318, glColor3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor3s(red, green, blue) \
	LP3NR(0x2b2, glColor3s, GLshort, red, d0, GLshort, green, d1, GLshort, blue, d2, \
	, CYBERGL_BASE_NAME)

#define glColor3sv(v) \
	LP1NR(0x312, glColor3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor3ub(red, green, blue) \
	LP3NR(0x2ca, glColor3ub, GLubyte, red, d0, GLubyte, green, d1, GLubyte, blue, d2, \
	, CYBERGL_BASE_NAME)

#define glColor3ubv(v) \
	LP1NR(0x32a, glColor3ubv, const GLubyte *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor3ui(red, green, blue) \
	LP3NR(0x2d6, glColor3ui, GLuint, red, d0, GLuint, green, d1, GLuint, blue, d2, \
	, CYBERGL_BASE_NAME)

#define glColor3uiv(v) \
	LP1NR(0x336, glColor3uiv, const GLuint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor3us(red, green, blue) \
	LP3NR(0x2d0, glColor3us, GLushort, red, d0, GLushort, green, d1, GLushort, blue, d2, \
	, CYBERGL_BASE_NAME)

#define glColor3usv(v) \
	LP1NR(0x330, glColor3usv, const GLushort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor4b(red, green, blue, alpha) \
	LP4NR(0x2dc, glColor4b, GLbyte, red, d0, GLbyte, green, d1, GLbyte, blue, d2, GLbyte, alpha, d3, \
	, CYBERGL_BASE_NAME)

#define glColor4bv(v) \
	LP1NR(0x33c, glColor4bv, const GLbyte *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor4d(red, green, blue, alpha) \
	LP4NR(0x2f4, glColor4d, GLdouble, red, fp0, GLdouble, green, fp1, GLdouble, blue, fp2, GLdouble, alpha, fp3, \
	, CYBERGL_BASE_NAME)

#define glColor4dv(v) \
	LP1NR(0x354, glColor4dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor4f(red, green, blue, alpha) \
	LP4NR(0x2ee, glColor4f, GLfloat, red, fp0, GLfloat, green, fp1, GLfloat, blue, fp2, GLfloat, alpha, fp3, \
	, CYBERGL_BASE_NAME)

#define glColor4fv(v) \
	LP1NR(0x34e, glColor4fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor4i(red, green, blue, alpha) \
	LP4NR(0x2e8, glColor4i, GLint, red, d0, GLint, green, d1, GLint, blue, d2, GLint, alpha, d3, \
	, CYBERGL_BASE_NAME)

#define glColor4iv(v) \
	LP1NR(0x348, glColor4iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor4s(red, green, blue, alpha) \
	LP4NR(0x2e2, glColor4s, GLshort, red, d0, GLshort, green, d1, GLshort, blue, d2, GLshort, alpha, d3, \
	, CYBERGL_BASE_NAME)

#define glColor4sv(v) \
	LP1NR(0x342, glColor4sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor4ub(red, green, blue, alpha) \
	LP4NR(0x2fa, glColor4ub, GLubyte, red, d0, GLubyte, green, d1, GLubyte, blue, d2, GLubyte, alpha, d3, \
	, CYBERGL_BASE_NAME)

#define glColor4ubv(v) \
	LP1NR(0x35a, glColor4ubv, const GLubyte *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor4ui(red, green, blue, alpha) \
	LP4NR(0x306, glColor4ui, GLuint, red, d0, GLuint, green, d1, GLuint, blue, d2, GLuint, alpha, d3, \
	, CYBERGL_BASE_NAME)

#define glColor4uiv(v) \
	LP1NR(0x366, glColor4uiv, const GLuint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColor4us(red, green, blue, alpha) \
	LP4NR(0x300, glColor4us, GLushort, red, d0, GLushort, green, d1, GLushort, blue, d2, GLushort, alpha, d3, \
	, CYBERGL_BASE_NAME)

#define glColor4usv(v) \
	LP1NR(0x360, glColor4usv, const GLushort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glColorMaterial(face, mode) \
	LP2NR(0x5d0, glColorMaterial, GLenum, face, d0, GLenum, mode, d1, \
	, CYBERGL_BASE_NAME)

#define glCullFace(mode) \
	LP1NR(0x558, glCullFace, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)

#define glDepthFunc(func) \
	LP1NR(0x546, glDepthFunc, GLenum, func, d0, \
	, CYBERGL_BASE_NAME)

#define glDepthRange(zNear, zFar) \
	LP2NR(0x468, glDepthRange, GLclampd, zNear, fp0, GLclampd, zFar, fp1, \
	, CYBERGL_BASE_NAME)

#define glDisable(cap) \
	LP1NR(0x72, glDisable, GLenum, cap, d0, \
	, CYBERGL_BASE_NAME)

#define glDrawBuffer(mode) \
	LP1NR(0x528, glDrawBuffer, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)

#define glDrawPixels(width, height, format, type, data) \
	LP5NR(0x666, glDrawPixels, GLsizei, width, d0, GLsizei, height, d1, GLenum, format, d2, GLenum, type, d3, const void *, data, a0, \
	, CYBERGL_BASE_NAME)

#define glEdgeFlag(flag) \
	LP1NR(0x3cc, glEdgeFlag, GLboolean, flag, d0, \
	, CYBERGL_BASE_NAME)

#define glEdgeFlagv(flag) \
	LP1NR(0x3d2, glEdgeFlagv, const GLboolean *, flag, a0, \
	, CYBERGL_BASE_NAME)

#define glEnable(cap) \
	LP1NR(0x6c, glEnable, GLenum, cap, d0, \
	, CYBERGL_BASE_NAME)

#define glEnd() \
	LP0NR(0x11a, glEnd, \
	, CYBERGL_BASE_NAME)

#define glFinish() \
	LP0NR(0x51c, glFinish, \
	, CYBERGL_BASE_NAME)

#define glFlush() \
	LP0NR(0x516, glFlush, \
	, CYBERGL_BASE_NAME)

#define glFogf(pname, param) \
	LP2NR(0x52e, glFogf, GLenum, pname, d0, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glFogfv(pname, params) \
	LP2NR(0x53a, glFogfv, GLenum, pname, d0, const GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glFogi(pname, param) \
	LP2NR(0x534, glFogi, GLenum, pname, d0, GLint, param, d1, \
	, CYBERGL_BASE_NAME)

#define glFogiv(pname, params) \
	LP2NR(0x540, glFogiv, GLenum, pname, d0, const GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glFrontFace(mode) \
	LP1NR(0x55e, glFrontFace, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)

#define glFrustum_jump(frustum) \
	LP1NR(0x4c2, glFrustum, const GLfrustum *, frustum, a0, \
	, CYBERGL_BASE_NAME)
extern __inline GLvoid glFrustum(GLdouble left,  GLdouble right, GLdouble bottom, GLdouble top,
                                 GLdouble zNear, GLdouble zFar) {
  GLfrustum sfrustum;
  
  sfrustum.left = left;
  sfrustum.right = right;
  sfrustum.bottom = bottom;
  sfrustum.top = top;
  sfrustum.zNear = zNear;
  sfrustum.zFar = zFar;
  
  glFrustum_jump(&sfrustum);
}

#define glGetBooleanv(pname, params) \
	LP2NR(0x7e, glGetBooleanv, GLenum, pname, d0, GLboolean *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetClipPlane(plane, equation) \
	LP2NR(0x96, glGetClipPlane, GLenum, plane, d0, GLdouble *, equation, a0, \
	, CYBERGL_BASE_NAME)

#define glGetDoublev(pname, params) \
	LP2NR(0x90, glGetDoublev, GLenum, pname, d0, GLdouble *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetError() \
	LP0(0x66, GLenum, glGetError, \
	, CYBERGL_BASE_NAME)

#define glGetFloatv(pname, params) \
	LP2NR(0x8a, glGetFloatv, GLenum, pname, d0, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetIntegerv(pname, params) \
	LP2NR(0x84, glGetIntegerv, GLenum, pname, d0, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetLightfv(light, pname, params) \
	LP3NR(0x9c, glGetLightfv, GLenum, light, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetLightiv(light, pname, params) \
	LP3NR(0xa2, glGetLightiv, GLenum, light, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetMaterialfv(face, pname, params) \
	LP3NR(0xa8, glGetMaterialfv, GLenum, face, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetMaterialiv(face, pname, params) \
	LP3NR(0xae, glGetMaterialiv, GLenum, face, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetPixelMapfv(map, values) \
	LP2NR(0xc6, glGetPixelMapfv, GLenum, map, d0, GLfloat *, values, a0, \
	, CYBERGL_BASE_NAME)

#define glGetPixelMapuiv(map, values) \
	LP2NR(0xcc, glGetPixelMapuiv, GLenum, map, d0, GLuint *, values, a0, \
	, CYBERGL_BASE_NAME)

#define glGetPixelMapusv(map, values) \
	LP2NR(0xd2, glGetPixelMapusv, GLenum, map, d0, GLushort *, values, a0, \
	, CYBERGL_BASE_NAME)

#define glGetString(name) \
	LP1(0x102, GLubyte *, glGetString, GLenum, name, d0, \
	, CYBERGL_BASE_NAME)

#define glGetTexEnvfv(target, pname, params) \
	LP3NR(0xd8, glGetTexEnvfv, GLenum, target, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexEnviv(target, pname, params) \
	LP3NR(0xde, glGetTexEnviv, GLenum, target, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexGendv(coord, pname, params) \
	LP3NR(0xb4, glGetTexGendv, GLenum, coord, d0, GLenum, pname, d1, GLdouble *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexGenfv(coord, pname, params) \
	LP3NR(0xba, glGetTexGenfv, GLenum, coord, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexGeniv(coord, pname, params) \
	LP3NR(0xc0, glGetTexGeniv, GLenum, coord, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexImage(target, level, format, type, pixels) \
	LP5NR(0xfc, glGetTexImage, GLenum, target, d0, GLint, level, d1, GLenum, format, d2, GLenum, type, d3, void *, pixels, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexLevelParameterfv(target, level, pname, params) \
	LP4NR(0xe4, glGetTexLevelParameterfv, GLenum, target, d0, GLint, level, d1, GLenum, pname, d2, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexLevelParameteriv(target, level, pname, params) \
	LP4NR(0xea, glGetTexLevelParameteriv, GLenum, target, d0, GLint, level, d1, GLenum, pname, d2, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexParameterfv(target, pname, params) \
	LP3NR(0xf0, glGetTexParameterfv, GLenum, target, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glGetTexParameteriv(target, pname, params) \
	LP3NR(0xf6, glGetTexParameteriv, GLenum, target, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glHint(target, mode) \
	LP2NR(0x522, glHint, GLenum, target, d0, GLenum, mode, d1, \
	, CYBERGL_BASE_NAME)

#define glIndexd(index) \
	LP1NR(0x37e, glIndexd, GLdouble, index, fp0, \
	, CYBERGL_BASE_NAME)

#define glIndexdv(v) \
	LP1NR(0x396, glIndexdv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glIndexf(index) \
	LP1NR(0x378, glIndexf, GLfloat, index, fp0, \
	, CYBERGL_BASE_NAME)

#define glIndexfv(v) \
	LP1NR(0x390, glIndexfv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glIndexi(index) \
	LP1NR(0x372, glIndexi, GLint, index, d0, \
	, CYBERGL_BASE_NAME)

#define glIndexiv(v) \
	LP1NR(0x38a, glIndexiv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glIndexs(index) \
	LP1NR(0x36c, glIndexs, GLshort, index, d0, \
	, CYBERGL_BASE_NAME)

#define glIndexsv(v) \
	LP1NR(0x384, glIndexsv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glInitNames() \
	LP0NR(0x56a, glInitNames, \
	, CYBERGL_BASE_NAME)

#define glIsEnabled(cap) \
	LP1(0x78, GLboolean, glIsEnabled, GLenum, cap, d0, \
	, CYBERGL_BASE_NAME)

#define glLightModelf(pname, param) \
	LP2NR(0x5a0, glLightModelf, GLenum, pname, d0, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glLightModelfv(pname, params) \
	LP2NR(0x5ac, glLightModelfv, GLenum, pname, d0, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glLightModeli(pname, param) \
	LP2NR(0x5a6, glLightModeli, GLenum, pname, d0, GLint, param, d1, \
	, CYBERGL_BASE_NAME)

#define glLightModeliv(pname, params) \
	LP2NR(0x5b2, glLightModeliv, GLenum, pname, d0, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glLightf(light, pname, param) \
	LP3NR(0x588, glLightf, GLenum, light, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glLightfv(light, pname, params) \
	LP3NR(0x594, glLightfv, GLenum, light, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glLighti(light, pname, param) \
	LP3NR(0x58e, glLighti, GLenum, light, d0, GLenum, pname, d1, GLint, param, d2, \
	, CYBERGL_BASE_NAME)

#define glLightiv(light, pname, params) \
	LP3NR(0x59a, glLightiv, GLenum, light, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glLoadIdentity() \
	LP0NR(0x492, glLoadIdentity, \
	, CYBERGL_BASE_NAME)

#define glLoadMatrixd(m) \
	LP1NR(0x480, glLoadMatrixd, const GLdouble *, m, a0, \
	, CYBERGL_BASE_NAME)

#define glLoadMatrixf(m) \
	LP1NR(0x47a, glLoadMatrixf, const GLfloat *, m, a0, \
	, CYBERGL_BASE_NAME)

#define glLoadName(name) \
	LP1NR(0x570, glLoadName, GLuint, name, d0, \
	, CYBERGL_BASE_NAME)

#define glLookAt_jump(lookAt) \
	LP1NR(0x4ec, glLookAt, const GLlookAt *, lookAt, a0, \
	, CYBERGL_BASE_NAME)
extern __inline GLvoid glLookAt(GLdouble eyex, GLdouble eyey, GLdouble eyez, 
                                GLdouble centerx, GLdouble centery, GLdouble centerz, 
                                GLdouble upx, GLdouble upy, GLdouble upz) {
  GLlookAt slookat;
  
  slookat.eyex = eyex;
  slookat.eyey = eyey;
  slookat.eyez = eyez;
  slookat.centerx = centerx;
  slookat.centery = centery;
  slookat.centerz = centerz;
  slookat.upx = upx;
  slookat.upy = upy;
  slookat.upz = upz;
  
  glLookAt_jump(&slookat);
}

#define glMaterialf(face, pname, param) \
	LP3NR(0x5b8, glMaterialf, GLenum, face, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glMaterialfv(face, pname, params) \
	LP3NR(0x5c4, glMaterialfv, GLenum, face, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glMateriali(face, pname, param) \
	LP3NR(0x5be, glMateriali, GLenum, face, d0, GLenum, pname, d1, GLint, param, d2, \
	, CYBERGL_BASE_NAME)

#define glMaterialiv(face, pname, params) \
	LP3NR(0x5ca, glMaterialiv, GLenum, face, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glMatrixMode(mode) \
	LP1NR(0x474, glMatrixMode, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)

#define glMultMatrixd(m) \
	LP1NR(0x48c, glMultMatrixd, const GLdouble *, m, a0, \
	, CYBERGL_BASE_NAME)

#define glMultMatrixf(m) \
	LP1NR(0x486, glMultMatrixf, const GLfloat *, m, a0, \
	, CYBERGL_BASE_NAME)

#define glNormal3b(nx, ny, nz) \
	LP3NR(0x270, glNormal3b, GLbyte, nx, d0, GLbyte, ny, d1, GLbyte, nz, d2, \
	, CYBERGL_BASE_NAME)

#define glNormal3bv(v) \
	LP1NR(0x28e, glNormal3bv, const GLbyte *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glNormal3d(nx, ny, nz) \
	LP3NR(0x288, glNormal3d, GLdouble, nx, fp0, GLdouble, ny, fp1, GLdouble, nz, fp2, \
	, CYBERGL_BASE_NAME)

#define glNormal3dv(v) \
	LP1NR(0x2a6, glNormal3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glNormal3f(nx, ny, nz) \
	LP3NR(0x282, glNormal3f, GLfloat, nx, fp0, GLfloat, ny, fp1, GLfloat, nz, fp2, \
	, CYBERGL_BASE_NAME)

#define glNormal3fv(v) \
	LP1NR(0x2a0, glNormal3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glNormal3i(nx, ny, nz) \
	LP3NR(0x27c, glNormal3i, GLint, nx, d0, GLint, ny, d1, GLint, nz, d2, \
	, CYBERGL_BASE_NAME)

#define glNormal3iv(v) \
	LP1NR(0x29a, glNormal3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glNormal3s(nx, ny, nz) \
	LP3NR(0x276, glNormal3s, GLshort, nx, d0, GLshort, ny, d1, GLshort, nz, d2, \
	, CYBERGL_BASE_NAME)

#define glNormal3sv(v) \
	LP1NR(0x294, glNormal3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glOrtho_jump(ortho) \
	LP1NR(0x4c2, glOrtho, const GLortho *, ortho, a0, \
	, CYBERGL_BASE_NAME)
extern __inline GLvoid glOrtho(GLdouble left,  GLdouble right, GLdouble bottom, GLdouble top,
                               GLdouble zNear, GLdouble zFar) {
  GLortho sortho;
  
  sortho.left = left;
  sortho.right = right;
  sortho.bottom = bottom;
  sortho.top = top;
  sortho.zNear = zNear;
  sortho.zFar = zFar;
  
  glOrtho_jump(&sortho);
}

#define glOrtho2D(left, right, bottom, top) \
	LP4NR(0x4d4, glOrtho2D, GLdouble, left, fp0, GLdouble, right, fp1, GLdouble, bottom, fp2, GLdouble, top, fp3, \
	, CYBERGL_BASE_NAME)

#define glPerspective(fovy, aspect, zNear, zFar) \
	LP4NR(0x4e6, glPerspective, GLdouble, fovy, fp0, GLdouble, aspect, fp1, GLdouble, zNear, fp2, GLdouble, zFar, fp3, \
	, CYBERGL_BASE_NAME)

#define glPickMatrix(x, y, width, height) \
	LP4NR(0x4f2, glPickMatrix, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, width, fp2, GLdouble, height, fp3, \
	, CYBERGL_BASE_NAME)

#define glPixelMapfv(map, mapsize, values) \
	LP3NR(0x65a, glPixelMapfv, GLenum, map, d0, GLsizei, mapsize, d1, const GLfloat, values, a0, \
	, CYBERGL_BASE_NAME)

#define glPixelMapuiv(map, mapsize, values) \
	LP3NR(0x64e, glPixelMapuiv, GLenum, map, d0, GLsizei, mapsize, d1, const GLuint, values, a0, \
	, CYBERGL_BASE_NAME)

#define glPixelMapusv(map, mapsize, values) \
	LP3NR(0x654, glPixelMapusv, GLenum, map, d0, GLsizei, mapsize, d1, const GLushort, values, a0, \
	, CYBERGL_BASE_NAME)

#define glPixelStoref(pname, param) \
	LP2NR(0x63c, glPixelStoref, GLenum, pname, d0, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glPixelStorei(pname, param) \
	LP2NR(0x636, glPixelStorei, GLenum, pname, d0, GLint, param, d1, \
	, CYBERGL_BASE_NAME)

#define glPixelTransferf(pname, param) \
	LP2NR(0x648, glPixelTransferf, GLenum, pname, d0, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glPixelTransferi(pname, param) \
	LP2NR(0x642, glPixelTransferi, GLenum, pname, d0, GLint, param, d1, \
	, CYBERGL_BASE_NAME)

#define glPixelZoom(xfactor, yfactor) \
	LP2NR(0x660, glPixelZoom, GLfloat, xfactor, fp0, GLfloat, yfactor, fp1, \
	, CYBERGL_BASE_NAME)

#define glPolygonMode(face, mode) \
	LP2NR(0x54c, glPolygonMode, GLenum, face, d0, GLenum, mode, d1, \
	, CYBERGL_BASE_NAME)

#define glPopAttrib() \
	LP0NR(0x10e, glPopAttrib, \
	, CYBERGL_BASE_NAME)

#define glPopMatrix() \
	LP0NR(0x4ce, glPopMatrix, \
	, CYBERGL_BASE_NAME)

#define glPopName() \
	LP0NR(0x57c, glPopName, \
	, CYBERGL_BASE_NAME)

#define glProject(objx, objy, objz, winx, winy, winz) \
	LP6(0x4da, GLboolean, glProject, GLdouble, objx, fp0, GLdouble, objy, fp1, GLdouble, objz, fp2, GLdouble *, winx, a0, GLdouble *, winy, a1, GLdouble *, winz, a2, \
	, CYBERGL_BASE_NAME)

#define glPushAttrib(mask) \
	LP1NR(0x108, glPushAttrib, GLbitfield, mask, d0, \
	, CYBERGL_BASE_NAME)

#define glPushMatrix() \
	LP0NR(0x4c8, glPushMatrix, \
	, CYBERGL_BASE_NAME)

#define glPushName(name) \
	LP1NR(0x576, glPushName, GLuint, name, d0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos2d(s, t) \
	LP2NR(0x3ea, glRasterPos2d, GLdouble, s, fp0, GLdouble, t, fp1, \
	, CYBERGL_BASE_NAME)

#define glRasterPos2dv(v) \
	LP1NR(0x432, glRasterPos2dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos2f(s, t) \
	LP2NR(0x3e4, glRasterPos2f, GLfloat, s, fp0, GLfloat, t, fp1, \
	, CYBERGL_BASE_NAME)

#define glRasterPos2fv(v) \
	LP1NR(0x42c, glRasterPos2fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos2i(s, t) \
	LP2NR(0x3de, glRasterPos2i, GLint, s, d0, GLint, t, d1, \
	, CYBERGL_BASE_NAME)

#define glRasterPos2iv(v) \
	LP1NR(0x426, glRasterPos2iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos2s(s, t) \
	LP2NR(0x3d8, glRasterPos2s, GLshort, s, d0, GLshort, t, d1, \
	, CYBERGL_BASE_NAME)

#define glRasterPos2sv(v) \
	LP1NR(0x420, glRasterPos2sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos3d(s, t, r) \
	LP3NR(0x402, glRasterPos3d, GLdouble, s, fp0, GLdouble, t, fp1, GLdouble, r, fp2, \
	, CYBERGL_BASE_NAME)

#define glRasterPos3dv(v) \
	LP1NR(0x44a, glRasterPos3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos3f(s, t, r) \
	LP3NR(0x3fc, glRasterPos3f, GLfloat, s, fp0, GLfloat, t, fp1, GLfloat, r, fp2, \
	, CYBERGL_BASE_NAME)

#define glRasterPos3fv(v) \
	LP1NR(0x444, glRasterPos3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos3i(s, t, r) \
	LP3NR(0x3f6, glRasterPos3i, GLint, s, d0, GLint, t, d1, GLint, r, d2, \
	, CYBERGL_BASE_NAME)

#define glRasterPos3iv(v) \
	LP1NR(0x43e, glRasterPos3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos3s(s, t, r) \
	LP3NR(0x3f0, glRasterPos3s, GLshort, s, d0, GLshort, t, d1, GLshort, r, d2, \
	, CYBERGL_BASE_NAME)

#define glRasterPos3sv(v) \
	LP1NR(0x438, glRasterPos3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos4d(s, t, r, q) \
	LP4NR(0x41a, glRasterPos4d, GLdouble, s, fp0, GLdouble, t, fp1, GLdouble, r, fp2, GLdouble, q, fp3, \
	, CYBERGL_BASE_NAME)

#define glRasterPos4dv(v) \
	LP1NR(0x462, glRasterPos4dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos4f(s, t, r, q) \
	LP4NR(0x414, glRasterPos4f, GLfloat, s, fp0, GLfloat, t, fp1, GLfloat, r, fp2, GLfloat, q, fp3, \
	, CYBERGL_BASE_NAME)

#define glRasterPos4fv(v) \
	LP1NR(0x45c, glRasterPos4fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos4i(s, t, r, q) \
	LP4NR(0x40e, glRasterPos4i, GLint, s, d0, GLint, t, d1, GLint, r, d2, GLint, q, d3, \
	, CYBERGL_BASE_NAME)

#define glRasterPos4iv(v) \
	LP1NR(0x456, glRasterPos4iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRasterPos4s(s, t, r, q) \
	LP4NR(0x408, glRasterPos4s, GLshort, s, d0, GLshort, t, d1, GLshort, r, d2, GLshort, q, d3, \
	, CYBERGL_BASE_NAME)

#define glRasterPos4sv(v) \
	LP1NR(0x450, glRasterPos4sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glRectd(x1, y1, x2, y2) \
	LP4NR(0x3ae, glRectd, GLdouble, x1, fp0, GLdouble, y1, fp1, GLdouble, x2, fp2, GLdouble, y2, fp3, \
	, CYBERGL_BASE_NAME)

#define glRectdv(v1, v2) \
	LP2NR(0x3c6, glRectdv, const GLdouble *, v1, a0, const GLdouble *, v2, a1, \
	, CYBERGL_BASE_NAME)

#define glRectf(x1, y1, x2, y2) \
	LP4NR(0x3a8, glRectf, GLfloat, x1, fp0, GLfloat, y1, fp1, GLfloat, x2, fp2, GLfloat, y2, fp3, \
	, CYBERGL_BASE_NAME)

#define glRectfv(v1, v2) \
	LP2NR(0x3c0, glRectfv, const GLfloat *, v1, a0, const GLfloat *, v2, a1, \
	, CYBERGL_BASE_NAME)

#define glRecti(x1, y1, x2, y2) \
	LP4NR(0x3a2, glRecti, GLint, x1, d0, GLint, y1, d1, GLint, x2, d2, GLint, y2, d3, \
	, CYBERGL_BASE_NAME)

#define glRectiv(v1, v2) \
	LP2NR(0x3ba, glRectiv, const GLint *, v1, a0, const GLint *, v2, a1, \
	, CYBERGL_BASE_NAME)

#define glRects(x1, y1, x2, y2) \
	LP4NR(0x39c, glRects, GLshort, x1, d0, GLshort, y1, d1, GLshort, x2, d2, GLshort, y2, d3, \
	, CYBERGL_BASE_NAME)

#define glRectsv(v1, v2) \
	LP2NR(0x3b4, glRectsv, const GLshort *, v1, a0, const GLshort *, v2, a1, \
	, CYBERGL_BASE_NAME)

#define glRenderMode(mode) \
	LP1(0x564, GLint, glRenderMode, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)

#define glRotated(angle, x, y, z) \
	LP4NR(0x49e, glRotated, GLdouble, angle, fp0, GLdouble, x, fp1, GLdouble, y, fp2, GLdouble, z, fp3, \
	, CYBERGL_BASE_NAME)

#define glRotatef(angle, x, y, z) \
	LP4NR(0x498, glRotatef, GLfloat, angle, fp0, GLfloat, x, fp1, GLfloat, y, fp2, GLfloat, z, fp3, \
	, CYBERGL_BASE_NAME)

#define glScaled(x, y, z) \
	LP3NR(0x4b6, glScaled, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, z, fp2, \
	, CYBERGL_BASE_NAME)

#define glScalef(x, y, z) \
	LP3NR(0x4b0, glScalef, GLfloat, x, fp0, GLfloat, y, fp1, GLfloat, z, fp2, \
	, CYBERGL_BASE_NAME)

#define glSelectBuffer(size, buffer) \
	LP2NR(0x582, glSelectBuffer, GLsizei, size, d0, GLuint *, buffer, a0, \
	, CYBERGL_BASE_NAME)

#define glShadeModel(mode) \
	LP1NR(0x552, glShadeModel, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord1d(s) \
	LP1NR(0x1c2, glTexCoord1d, GLdouble, s, fp0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord1dv(v) \
	LP1NR(0x222, glTexCoord1dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord1f(s) \
	LP1NR(0x1bc, glTexCoord1f, GLfloat, s, fp0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord1fv(v) \
	LP1NR(0x21c, glTexCoord1fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord1i(s) \
	LP1NR(0x1b6, glTexCoord1i, GLint, s, d0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord1iv(v) \
	LP1NR(0x216, glTexCoord1iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord1s(s) \
	LP1NR(0x1b0, glTexCoord1s, GLshort, s, d0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord1sv(v) \
	LP1NR(0x210, glTexCoord1sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord2d(s, t) \
	LP2NR(0x1da, glTexCoord2d, GLdouble, s, fp0, GLdouble, t, fp1, \
	, CYBERGL_BASE_NAME)

#define glTexCoord2dv(v) \
	LP1NR(0x23a, glTexCoord2dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord2f(s, t) \
	LP2NR(0x1d4, glTexCoord2f, GLfloat, s, fp0, GLfloat, t, fp1, \
	, CYBERGL_BASE_NAME)

#define glTexCoord2fv(v) \
	LP1NR(0x234, glTexCoord2fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord2i(s, t) \
	LP2NR(0x1ce, glTexCoord2i, GLint, s, d0, GLint, t, d1, \
	, CYBERGL_BASE_NAME)

#define glTexCoord2iv(v) \
	LP1NR(0x22e, glTexCoord2iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord2s(s, t) \
	LP2NR(0x1c8, glTexCoord2s, GLshort, s, d0, GLshort, t, d1, \
	, CYBERGL_BASE_NAME)

#define glTexCoord2sv(v) \
	LP1NR(0x228, glTexCoord2sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord3d(s, t, r) \
	LP3NR(0x1f2, glTexCoord3d, GLdouble, s, fp0, GLdouble, t, fp1, GLdouble, r, fp2, \
	, CYBERGL_BASE_NAME)

#define glTexCoord3dv(v) \
	LP1NR(0x252, glTexCoord3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord3f(s, t, r) \
	LP3NR(0x1ec, glTexCoord3f, GLfloat, s, fp0, GLfloat, t, fp1, GLfloat, r, fp2, \
	, CYBERGL_BASE_NAME)

#define glTexCoord3fv(v) \
	LP1NR(0x24c, glTexCoord3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord3i(s, t, r) \
	LP3NR(0x1e6, glTexCoord3i, GLint, s, d0, GLint, t, d1, GLint, r, d2, \
	, CYBERGL_BASE_NAME)

#define glTexCoord3iv(v) \
	LP1NR(0x246, glTexCoord3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord3s(s, t, r) \
	LP3NR(0x1e0, glTexCoord3s, GLshort, s, d0, GLshort, t, d1, GLshort, r, d2, \
	, CYBERGL_BASE_NAME)

#define glTexCoord3sv(v) \
	LP1NR(0x240, glTexCoord3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord4d(s, t, r, q) \
	LP4NR(0x20a, glTexCoord4d, GLdouble, s, fp0, GLdouble, t, fp1, GLdouble, r, fp2, GLdouble, q, fp3, \
	, CYBERGL_BASE_NAME)

#define glTexCoord4dv(v) \
	LP1NR(0x26a, glTexCoord4dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord4f(s, t, r, q) \
	LP4NR(0x204, glTexCoord4f, GLfloat, s, fp0, GLfloat, t, fp1, GLfloat, r, fp2, GLfloat, q, fp3, \
	, CYBERGL_BASE_NAME)

#define glTexCoord4fv(v) \
	LP1NR(0x264, glTexCoord4fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord4i(s, t, r, q) \
	LP4NR(0x1fe, glTexCoord4i, GLint, s, d0, GLint, t, d1, GLint, r, d2, GLint, q, d3, \
	, CYBERGL_BASE_NAME)

#define glTexCoord4iv(v) \
	LP1NR(0x25e, glTexCoord4iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexCoord4s(s, t, r, q) \
	LP4NR(0x1f8, glTexCoord4s, GLshort, s, d0, GLshort, t, d1, GLshort, r, d2, GLshort, q, d3, \
	, CYBERGL_BASE_NAME)

#define glTexCoord4sv(v) \
	LP1NR(0x258, glTexCoord4sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glTexEnvf(target, pname, param) \
	LP3NR(0x5fa, glTexEnvf, GLenum, target, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glTexEnvfv(target, pname, params) \
	LP3NR(0x606, glTexEnvfv, GLenum, target, d0, GLenum, pname, d1, const GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glTexEnvi(target, pname, param) \
	LP3NR(0x600, glTexEnvi, GLenum, target, d0, GLenum, pname, d1, GLint, param, d2, \
	, CYBERGL_BASE_NAME)

#define glTexEnviv(target, pname, params) \
	LP3NR(0x60c, glTexEnviv, GLenum, target, d0, GLenum, pname, d1, const GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glTexGend(coord, pname, param) \
	LP3NR(0x5e2, glTexGend, GLenum, coord, d0, GLenum, pname, d1, GLdouble, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glTexGendv(coord, pname, params) \
	LP3NR(0x5f4, glTexGendv, GLenum, coord, d0, GLenum, pname, d1, const GLdouble *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glTexGenf(coord, pname, param) \
	LP3NR(0x5dc, glTexGenf, GLenum, coord, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glTexGenfv(coord, pname, params) \
	LP3NR(0x5ee, glTexGenfv, GLenum, coord, d0, GLenum, pname, d1, const GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glTexGeni() \
	LP0NR(0x5d6, glTexGeni, \
	, CYBERGL_BASE_NAME)

#define glTexGeniv(coord, pname, params) \
	LP3NR(0x5e8, glTexGeniv, GLenum, coord, d0, GLenum, pname, d1, const GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glTexImage1D(target, level, components, width, border, format, type, pixels) \
	LP8NR(0x62a, glTexImage1D, GLenum, target, d0, GLint, level, d1, GLint, components, d2, GLsizei, width, d3, GLint, border, d4, GLenum, format, d5, GLenum, type, d6, const void *, pixels, a0, \
	, CYBERGL_BASE_NAME)

#define glTexImage2D(target, level, components, width, height, border, format, type, pixels) \
	LP9NR(0x630, glTexImage2D, GLenum, target, d0, GLint, level, d1, GLint, components, d2, GLsizei, width, d3, GLsizei, height, d4, GLint, border, d5, GLenum, format, d6, GLenum, type, d7, const void *, pixels, a0, \
	, CYBERGL_BASE_NAME)

#define glTexParameterf(target, pname, param) \
	LP3NR(0x612, glTexParameterf, GLenum, target, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)

#define glTexParameterfv(target, pname, params) \
	LP3NR(0x61e, glTexParameterfv, GLenum, target, d0, GLenum, pname, d1, const GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glTexParameteri(target, pname, param) \
	LP3NR(0x618, glTexParameteri, GLenum, target, d0, GLenum, pname, d1, GLint, param, d2, \
	, CYBERGL_BASE_NAME)

#define glTexParameteriv(target, pname, params) \
	LP3NR(0x624, glTexParameteriv, GLenum, target, d0, GLenum, pname, d1, const GLint *, params, a0, \
	, CYBERGL_BASE_NAME)

#define glTranslated(x, y, z) \
	LP3NR(0x4aa, glTranslated, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, z, fp2, \
	, CYBERGL_BASE_NAME)

#define glTranslatef(x, y, z) \
	LP3NR(0x4a4, glTranslatef, GLfloat, x, fp0, GLfloat, y, fp1, GLfloat, z, fp2, \
	, CYBERGL_BASE_NAME)

#define glUnProject(winx, winy, winz, objx, objy, objz) \
	LP6(0x4e0, GLboolean, glUnProject, GLdouble, winx, fp0, GLdouble, winy, fp1, GLdouble, winz, fp2, GLdouble *, objx, a0, GLdouble *, objy, a1, GLdouble *, objz, a2, \
	, CYBERGL_BASE_NAME)

#define glVertex2d(x, y) \
	LP2NR(0x132, glVertex2d, GLdouble, x, fp0, GLdouble, y, fp1, \
	, CYBERGL_BASE_NAME)

#define glVertex2dv(v) \
	LP1NR(0x17a, glVertex2dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex2f(x, y) \
	LP2NR(0x12c, glVertex2f, GLfloat, x, fp0, GLfloat, y, fp1, \
	, CYBERGL_BASE_NAME)

#define glVertex2fv(v) \
	LP1NR(0x174, glVertex2fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex2i(x, y) \
	LP2NR(0x126, glVertex2i, GLint, x, d0, GLint, y, d1, \
	, CYBERGL_BASE_NAME)

#define glVertex2iv(v) \
	LP1NR(0x16e, glVertex2iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex2s(x, y) \
	LP2NR(0x120, glVertex2s, GLshort, x, d0, GLshort, y, d1, \
	, CYBERGL_BASE_NAME)

#define glVertex2sv(v) \
	LP1NR(0x168, glVertex2sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex3d(x, y, z) \
	LP3NR(0x14a, glVertex3d, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, z, fp2, \
	, CYBERGL_BASE_NAME)

#define glVertex3dv(v) \
	LP1NR(0x192, glVertex3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex3f(x, y, z) \
	LP3NR(0x144, glVertex3f, GLfloat, x, fp0, GLfloat, y, fp1, GLfloat, z, fp2, \
	, CYBERGL_BASE_NAME)

#define glVertex3fv(v) \
	LP1NR(0x18c, glVertex3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex3i(x, y, z) \
	LP3NR(0x13e, glVertex3i, GLint, x, d0, GLint, y, d1, GLint, z, d2, \
	, CYBERGL_BASE_NAME)

#define glVertex3iv(v) \
	LP1NR(0x186, glVertex3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex3s(x, y, z) \
	LP3NR(0x138, glVertex3s, GLshort, x, d0, GLshort, y, d1, GLshort, z, d2, \
	, CYBERGL_BASE_NAME)

#define glVertex3sv(v) \
	LP1NR(0x180, glVertex3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex4d(x, y, z, w) \
	LP4NR(0x162, glVertex4d, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, z, fp2, GLdouble, w, fp3, \
	, CYBERGL_BASE_NAME)

#define glVertex4dv(v) \
	LP1NR(0x1aa, glVertex4dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex4f(x, y, z, w) \
	LP4NR(0x15c, glVertex4f, GLfloat, x, fp0, GLfloat, y, fp1, GLfloat, z, fp2, GLfloat, w, fp3, \
	, CYBERGL_BASE_NAME)

#define glVertex4fv(v) \
	LP1NR(0x1a4, glVertex4fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex4i(x, y, z, w) \
	LP4NR(0x156, glVertex4i, GLint, x, d0, GLint, y, d1, GLint, z, d2, GLint, w, d3, \
	, CYBERGL_BASE_NAME)

#define glVertex4iv(v) \
	LP1NR(0x19e, glVertex4iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glVertex4s(x, y, z, w) \
	LP4NR(0x150, glVertex4s, GLshort, x, d0, GLshort, y, d1, GLshort, z, d2, GLshort, w, d3, \
	, CYBERGL_BASE_NAME)

#define glVertex4sv(v) \
	LP1NR(0x198, glVertex4sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)

#define glViewport(x, y, width, height) \
	LP4NR(0x46e, glViewport, GLint, x, d0, GLint, y, d1, GLsizei, width, d2, GLsizei, height, d3, \
	, CYBERGL_BASE_NAME)

#define openGLWindowTagList(width, height, tags) \
	LP3(0x1e, void *, openGLWindowTagList, GLint, width, d0, GLint, height, d1, struct TagItem *, tags, a0, \
	, CYBERGL_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define openGLWindowTags(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; openGLWindowTagList((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define resizeGLWindow(window, width, height) \
	LP3NR(0x36, resizeGLWindow, void *, window, a0, GLint, width, d0, GLint, height, d1, \
	, CYBERGL_BASE_NAME)

#endif /* !_INLINE_CYBERGL_H */
