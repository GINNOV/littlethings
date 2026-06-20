#ifndef _LIB_CYBERGL_H
#define _LIB_CYBERGL_H

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif /* !__INLINE_MACROS_H */

#ifndef CYBERGL_BASE_NAME
#define CYBERGL_BASE_NAME CyberGLBase
#endif /* !CYBERGL_BASE_NAME */

#include <inline/exec.h>
#include <gl/gl.h>

/* externs from crt0.c */
extern void *ixemulbase;
extern int errno;
extern char *_ctype_;
extern void *__sF;
extern void *__stk_limit;

extern struct ExecBase *SysBase;
struct Library *CyberGLBase = 0;

void constructor(void) {
  if(!(CyberGLBase = OpenLibrary("cybergl.library", 39))) {
    printf("Can't open CyberGL.library version 39!\n");
    exit(10);
  }
}

void destructor(void) {
  if(CyberGLBase) {
    CloseLibrary(CyberGLBase);
    CyberGLBase = 0;
  }
}

asm ("	.text; 	.stabs \"___CTOR_LIST__\",22,0,0,_constructor");
asm ("	.text; 	.stabs \"___DTOR_LIST__\",22,0,0,_destructor");

#define allocColor_jump(window, r, g, b) \
	LP4(0x42, GLubyte, allocColor, GLvoid *, window, a0, GLubyte, r, d0, GLubyte, g, d1, GLubyte, b, d2, \
	, CYBERGL_BASE_NAME)
GLubyte allocColor(GLvoid *window, GLubyte r, GLubyte g, GLubyte b) {
  return allocColor_jump(window, r, g, b);
}

#define allocColorRange_jump(window, r1, g1, b1, r2, g2, b2, num) \
	LP8(0x48, GLubyte, allocColorRange, GLvoid *, window, a0, GLubyte, r1, d0, GLubyte, g1, d1, GLubyte, b1, d2, GLubyte, r2, d3, GLubyte, g2, d4, GLubyte, b2, d5, GLubyte, num, d6, \
	, CYBERGL_BASE_NAME)
GLubyte allocColorRange(GLvoid *window, GLubyte r1, GLubyte g1, GLubyte b1, GLubyte r2, GLubyte g2, GLubyte b2, GLubyte num) {
  return allocColorRange_jump(window, r1, g1, b1, r2, g2, b2, num);
}

#define attachGLWindowTagList_jump(wnd, width, height, tags) \
	LP4(0x2a, GLvoid *, attachGLWindowTagList, struct Window *, wnd, a0, GLint, width, d0, GLint, height, d1, struct TagItem *, tags, a1, \
	, CYBERGL_BASE_NAME)
GLvoid *attachGLWindowTagList(struct Window *wnd, GLint width, GLint height, struct TagItem *tags) {
  return attachGLWindowTagList_jump(wnd, width, height, tags);
}

#ifndef NO_INLINE_STDARG
#define attachGLWindowTags(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; attachGLWindowTagList((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define attachGLWndToRPTagList_jump(scr, rp, width, height, tags) \
	LP5(0x4e, GLvoid *, attachGLWndToRPTagList, struct Screen *, scr, a0, struct RastPort *, rp, a1, GLint, width, d0, GLint, height, d1, struct TagItem *, tags, a2, \
	, CYBERGL_BASE_NAME)
GLvoid *attachGLWndToRPTagList(struct Screen *scr, struct RastPort *rp, GLint width, GLint height, struct TagItem *tags) {
  return attachGLWndToRPTagList_jump(scr, rp, width, height, tags);
}

#ifndef NO_INLINE_STDARG
#define attachGLWndToRPTags(a0, a1, a2, a3, tags...) \
	({ULONG _tags[] = { tags }; attachGLWndToRPTagList((a0), (a1), (a2), (a3), (struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define closeGLWindow_jump(window) \
	LP1NR(0x24, closeGLWindow, GLvoid *, window, a0, \
	, CYBERGL_BASE_NAME)
GLvoid closeGLWindow(GLvoid *window) {
  closeGLWindow_jump(window);
}

#define disposeGLWindow_jump(window) \
	LP1NR(0x30, disposeGLWindow, GLvoid *, window, a0, \
	, CYBERGL_BASE_NAME)
GLvoid disposeGLWindow(GLvoid *window) {
  disposeGLWindow_jump(window);
}

#define getWindow_jump(window) \
	LP1(0x3c, struct Window *, getWindow, GLvoid *, window, a0, \
	, CYBERGL_BASE_NAME)
struct Window *getWindow(GLvoid *window) {
  return getWindow_jump(window);
}

#define glBegin_jump(mode) \
	LP1NR(0x114, glBegin, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glBegin(GLenum mode) {
  glBegin_jump(mode);
}

#define glBitmap_jump(bitmap) \
	LP1NR(0x66c, glBitmap, const GLbitmap *, bitmap, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glBitmap(GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig,
                GLfloat xmove, GLfloat ymove, const GLubyte *bitmap) {
  GLbitmap sbitmap;
  
  sbitmap.width = width;
  sbitmap.height = height;
  sbitmap.xorig = xorig;
  sbitmap.xmove = xmove;
  sbitmap.ymove = ymove;
  sbitmap.bitmap = bitmap;
  
  glBitmap_jump(&sbitmap);
}

#define glClear_jump(mask) \
	LP1NR(0x4fe, glClear, GLbitfield, mask, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glClear(GLbitfield mask) {
  glClear_jump(mask);
}

#define glClearColor_jump(red, green, blue, alpha) \
	LP4NR(0x504, glClearColor, GLclampf, red, fp0, GLclampf, green, fp1, GLclampf, blue, fp2, GLclampf, alpha, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glClearColor(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) {
  glClearColor_jump(red, green, blue, alpha);
}

#define glClearDepth_jump(depth) \
	LP1NR(0x510, glClearDepth, GLclampd, depth, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glClearDepth(GLclampd depth) {
  glClearDepth_jump(depth);
}

#define glClearIndex_jump(index) \
	LP1NR(0x50a, glClearIndex, GLfloat, index, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glClearIndex(GLfloat index) {
  glClearIndex_jump(index);
}

#define glClipPlane_jump(plane, equation) \
	LP2NR(0x4f8, glClipPlane, GLenum, plane, d0, const GLdouble *, equation, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glClipPlane(GLenum plane, const GLdouble *equation) {
  glClipPlane_jump(plane, equation);
}

#define glColor3b_jump(red, green, blue) \
	LP3NR(0x2ac, glColor3b, GLbyte, red, d0, GLbyte, green, d1, GLbyte, blue, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3b(GLbyte red, GLbyte green, GLbyte blue) {
  glColor3b_jump(red, green, blue);
}

#define glColor3bv_jump(v) \
	LP1NR(0x30c, glColor3bv, const GLbyte *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3bv(const GLbyte *v) {
  glColor3bv_jump(v);
}

#define glColor3d_jump(red, green, blue) \
	LP3NR(0x2c4, glColor3d, GLdouble, red, fp0, GLdouble, green, fp1, GLdouble, blue, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3d(GLdouble red, GLdouble green, GLdouble blue) {
  glColor3d_jump(red, green, blue);
}

#define glColor3dv_jump(v) \
	LP1NR(0x324, glColor3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3dv(const GLdouble *v) {
  glColor3dv_jump(v);
}

#define glColor3f_jump(red, green, blue) \
	LP3NR(0x2be, glColor3f, GLfloat, red, fp0, GLfloat, green, fp1, GLfloat, blue, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3f(GLfloat red, GLfloat green, GLfloat blue) {
  glColor3f_jump(red, green, blue);
}

#define glColor3fv_jump(v) \
	LP1NR(0x31e, glColor3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3fv(const GLfloat *v) {
  glColor3fv_jump(v);
}

#define glColor3i_jump(red, green, blue) \
	LP3NR(0x2b8, glColor3i, GLint, red, d0, GLint, green, d1, GLint, blue, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3i(GLint red, GLint green, GLint blue) {
  glColor3i_jump(red, green, blue);
}

#define glColor3iv_jump(v) \
	LP1NR(0x318, glColor3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3iv(const GLint *v) {
  glColor3iv_jump(v);
}

#define glColor3s_jump(red, green, blue) \
	LP3NR(0x2b2, glColor3s, GLshort, red, d0, GLshort, green, d1, GLshort, blue, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3s(GLshort red, GLshort green, GLshort blue) {
  glColor3s_jump(red, green, blue);
}

#define glColor3sv_jump(v) \
	LP1NR(0x312, glColor3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3sv(const GLshort *v) {
  glColor3sv_jump(v);
}

#define glColor3ub_jump(red, green, blue) \
	LP3NR(0x2ca, glColor3ub, GLubyte, red, d0, GLubyte, green, d1, GLubyte, blue, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3ub(GLubyte red, GLubyte green, GLubyte blue) {
  glColor3ub_jump(red, green, blue);
}

#define glColor3ubv_jump(v) \
	LP1NR(0x32a, glColor3ubv, const GLubyte *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3ubv(const GLubyte *v) {
  glColor3ubv_jump(v);
}

#define glColor3ui_jump(red, green, blue) \
	LP3NR(0x2d6, glColor3ui, GLuint, red, d0, GLuint, green, d1, GLuint, blue, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3ui(GLuint red, GLuint green, GLuint blue) {
  glColor3ui_jump(red, green, blue);
}

#define glColor3uiv_jump(v) \
	LP1NR(0x336, glColor3uiv, const GLuint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3uiv(const GLuint *v) {
  glColor3uiv_jump(v);
}

#define glColor3us_jump(red, green, blue) \
	LP3NR(0x2d0, glColor3us, GLushort, red, d0, GLushort, green, d1, GLushort, blue, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3us(GLushort red, GLushort green, GLushort blue) {
  glColor3us_jump(red, green, blue);
}

#define glColor3usv_jump(v) \
	LP1NR(0x330, glColor3usv, const GLushort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor3usv(const GLushort *v) {
  glColor3usv_jump(v);
}

#define glColor4b_jump(red, green, blue, alpha) \
	LP4NR(0x2dc, glColor4b, GLbyte, red, d0, GLbyte, green, d1, GLbyte, blue, d2, GLbyte, alpha, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4b(GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha) {
  glColor4b_jump(red, green, blue, alpha);
}

#define glColor4bv_jump(v) \
	LP1NR(0x33c, glColor4bv, const GLbyte *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4bv(const GLbyte *v) {
  glColor4bv_jump(v);
}

#define glColor4d_jump(red, green, blue, alpha) \
	LP4NR(0x2f4, glColor4d, GLdouble, red, fp0, GLdouble, green, fp1, GLdouble, blue, fp2, GLdouble, alpha, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4d(GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha) {
  glColor4d_jump(red, green, blue, alpha);
}

#define glColor4dv_jump(v) \
	LP1NR(0x354, glColor4dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4dv(const GLdouble *v) {
  glColor4dv_jump(v);
}

#define glColor4f_jump(red, green, blue, alpha) \
	LP4NR(0x2ee, glColor4f, GLfloat, red, fp0, GLfloat, green, fp1, GLfloat, blue, fp2, GLfloat, alpha, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
  glColor4f_jump(red, green, blue, alpha);
}

#define glColor4fv_jump(v) \
	LP1NR(0x34e, glColor4fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4fv(const GLfloat *v) {
  glColor4fv_jump(v);
}

#define glColor4i_jump(red, green, blue, alpha) \
	LP4NR(0x2e8, glColor4i, GLint, red, d0, GLint, green, d1, GLint, blue, d2, GLint, alpha, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4i(GLint red, GLint green, GLint blue, GLint alpha) {
  glColor4i_jump(red, green, blue, alpha);
}

#define glColor4iv_jump(v) \
	LP1NR(0x348, glColor4iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4iv(const GLint *v) {
  glColor4iv_jump(v);
}

#define glColor4s_jump(red, green, blue, alpha) \
	LP4NR(0x2e2, glColor4s, GLshort, red, d0, GLshort, green, d1, GLshort, blue, d2, GLshort, alpha, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4s(GLshort red, GLshort green, GLshort blue, GLshort alpha) {
  glColor4s_jump(red, green, blue, alpha);
}

#define glColor4sv_jump(v) \
	LP1NR(0x342, glColor4sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4sv(const GLshort *v) {
  glColor4sv_jump(v);
}

#define glColor4ub_jump(red, green, blue, alpha) \
	LP4NR(0x2fa, glColor4ub, GLubyte, red, d0, GLubyte, green, d1, GLubyte, blue, d2, GLubyte, alpha, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha) {
  glColor4ub_jump(red, green, blue, alpha);
}

#define glColor4ubv_jump(v) \
	LP1NR(0x35a, glColor4ubv, const GLubyte *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4ubv(const GLubyte *v) {
  glColor4ubv_jump(v);
}

#define glColor4ui_jump(red, green, blue, alpha) \
	LP4NR(0x306, glColor4ui, GLuint, red, d0, GLuint, green, d1, GLuint, blue, d2, GLuint, alpha, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4ui(GLuint red, GLuint green, GLuint blue, GLuint alpha) {
  glColor4ui_jump(red, green, blue, alpha);
}

#define glColor4uiv_jump(v) \
	LP1NR(0x366, glColor4uiv, const GLuint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4uiv(const GLuint *v) {
  glColor4uiv_jump(v);
}

#define glColor4us_jump(red, green, blue, alpha) \
	LP4NR(0x300, glColor4us, GLushort, red, d0, GLushort, green, d1, GLushort, blue, d2, GLushort, alpha, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4us(GLushort red, GLushort green, GLushort blue, GLushort alpha) {
  glColor4us_jump(red, green, blue, alpha);
}

#define glColor4usv_jump(v) \
	LP1NR(0x360, glColor4usv, const GLushort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glColor4usv(const GLushort *v) {
  glColor4usv_jump(v);
}

#define glColorMaterial_jump(face, mode) \
	LP2NR(0x5d0, glColorMaterial, GLenum, face, d0, GLenum, mode, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glColorMaterial(GLenum face, GLenum mode) {
  glColorMaterial_jump(face, mode);
}

#define glCullFace_jump(mode) \
	LP1NR(0x558, glCullFace, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glCullFace(GLenum mode) {
  glCullFace_jump(mode);
}

#define glDepthFunc_jump(func) \
	LP1NR(0x546, glDepthFunc, GLenum, func, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glDepthFunc(GLenum func) {
  glDepthFunc_jump(func);
}

#define glDepthRange_jump(zNear, zFar) \
	LP2NR(0x468, glDepthRange, GLclampd, zNear, fp0, GLclampd, zFar, fp1, \
	, CYBERGL_BASE_NAME)
GLvoid glDepthRange(GLclampd zNear, GLclampd zFar) {
  glDepthRange_jump(zNear, zFar);
}

#define glDisable_jump(cap) \
	LP1NR(0x72, glDisable, GLenum, cap, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glDisable(GLenum cap) {
  glDisable_jump(cap);
}

#define glDrawBuffer_jump(mode) \
	LP1NR(0x528, glDrawBuffer, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glDrawBuffer(GLenum mode) {
  glDrawBuffer_jump(mode);
}

#define glDrawPixels_jump(width, height, format, type, data) \
	LP5NR(0x666, glDrawPixels, GLsizei, width, d0, GLsizei, height, d1, GLenum, format, d2, GLenum, type, d3, const GLvoid *, data, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glDrawPixels(GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *data) {
  glDrawPixels_jump(width, height, format, type, data);
}

#define glEdgeFlag_jump(flag) \
	LP1NR(0x3cc, glEdgeFlag, GLboolean, flag, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glEdgeFlag(GLboolean flag) {
  glEdgeFlag_jump(flag);
}

#define glEdgeFlagv_jump(flag) \
	LP1NR(0x3d2, glEdgeFlagv, const GLboolean *, flag, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glEdgeFlagv(const GLboolean *flag) {
  glEdgeFlagv_jump(flag);
}

#define glEnable_jump(cap) \
	LP1NR(0x6c, glEnable, GLenum, cap, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glEnable (GLenum cap) {
  glEnable_jump(cap);
}

#define glEnd_jump() \
	LP0NR(0x11a, glEnd, \
	, CYBERGL_BASE_NAME)
GLvoid glEnd(GLvoid) {
  glEnd_jump();
}

#define glFinish_jump() \
	LP0NR(0x51c, glFinish, \
	, CYBERGL_BASE_NAME)
GLvoid glFinish(GLvoid) {
  glFinish_jump();
}

#define glFlush_jump() \
	LP0NR(0x516, glFlush, \
	, CYBERGL_BASE_NAME)
GLvoid glFlush(GLvoid) {
  glFlush_jump();
}

#define glFogf_jump(pname, param) \
	LP2NR(0x52e, glFogf, GLenum, pname, d0, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glFogf(GLenum pname, GLfloat param) {
  glFogf_jump(pname, param);
}

#define glFogfv_jump(pname, params) \
	LP2NR(0x53a, glFogfv, GLenum, pname, d0, const GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glFogfv(GLenum pname, const GLfloat *params) {
  glFogfv_jump(pname, params);
}

#define glFogi_jump(pname, param) \
	LP2NR(0x534, glFogi, GLenum, pname, d0, GLint, param, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glFogi(GLenum pname, GLint param) {
  glFogi_jump(pname, param);
}

#define glFogiv_jump(pname, params) \
	LP2NR(0x540, glFogiv, GLenum, pname, d0, const GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glFogiv(GLenum pname, const GLint *params) {
  glFogiv_jump(pname, params);
}

#define glFrontFace_jump(mode) \
	LP1NR(0x55e, glFrontFace, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glFrontFace(GLenum mode) {
  glFrontFace_jump(mode);
}

#define glFrustum_jump(frustum) \
	LP1NR(0x4c2, glFrustum, const GLfrustum *, frustum, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glFrustum(GLdouble left,  GLdouble right, GLdouble bottom, GLdouble top,
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

#define glGetBooleanv_jump(pname, params) \
	LP2NR(0x7e, glGetBooleanv, GLenum, pname, d0, GLboolean *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetBooleanv(GLenum pname, GLboolean *params) {
  glGetBooleanv_jump(pname, params);
}

#define glGetClipPlane_jump(plane, equation) \
	LP2NR(0x96, glGetClipPlane, GLenum, plane, d0, GLdouble *, equation, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetClipPlane(GLenum plane, GLdouble *equation) {
  glGetClipPlane_jump(plane, equation);
}

#define glGetDoublev_jump(pname, params) \
	LP2NR(0x90, glGetDoublev, GLenum, pname, d0, GLdouble *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetDoublev(GLenum pname, GLdouble *params) {
  glGetDoublev_jump(pname, params);
}

#define glGetError_jump() \
	LP0(0x66, GLenum, glGetError, \
	, CYBERGL_BASE_NAME)
GLenum glGetError(GLvoid) {
  return glGetError_jump();
}

#define glGetFloatv_jump(pname, params) \
	LP2NR(0x8a, glGetFloatv, GLenum, pname, d0, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetFloatv(GLenum pname, GLfloat *params) {
  glGetFloatv_jump(pname, params);
}

#define glGetIntegerv_jump(pname, params) \
	LP2NR(0x84, glGetIntegerv, GLenum, pname, d0, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetIntegerv(GLenum pname, GLint *params) {
  glGetIntegerv_jump(pname, params);
}

#define glGetLightfv_jump(light, pname, params) \
	LP3NR(0x9c, glGetLightfv, GLenum, light, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetLightfv(GLenum light, GLenum pname, GLfloat *params) {
  glGetLightfv_jump(light, pname, params);
}

#define glGetLightiv_jump(light, pname, params) \
	LP3NR(0xa2, glGetLightiv, GLenum, light, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetLightiv(GLenum light, GLenum pname, GLint *params) {
  glGetLightiv_jump(light, pname, params);
}

#define glGetMaterialfv_jump(face, pname, params) \
	LP3NR(0xa8, glGetMaterialfv, GLenum, face, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetMaterialfv(GLenum face, GLenum pname, GLfloat *params) {
  glGetMaterialfv_jump(face, pname, params);
}

#define glGetMaterialiv_jump(face, pname, params) \
	LP3NR(0xae, glGetMaterialiv, GLenum, face, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetMaterialiv(GLenum face, GLenum pname, GLint *params) {
  glGetMaterialiv_jump(face, pname, params);
}

#define glGetPixelMapfv_jump(map, values) \
	LP2NR(0xc6, glGetPixelMapfv, GLenum, map, d0, GLfloat *, values, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetPixelMapfv(GLenum map, GLfloat *values) {
  glGetPixelMapfv_jump(map, values);
}

#define glGetPixelMapuiv_jump(map, values) \
	LP2NR(0xcc, glGetPixelMapuiv, GLenum, map, d0, GLuint *, values, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetPixelMapuiv(GLenum map, GLuint *values) {
  glGetPixelMapuiv_jump(map, values);
}

#define glGetPixelMapusv_jump(map, values) \
	LP2NR(0xd2, glGetPixelMapusv, GLenum, map, d0, GLushort *, values, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetPixelMapusv(GLenum map, GLushort *values) {
  glGetPixelMapusv_jump(map, values);
}

#define glGetString_jump(name) \
	LP1(0x102, GLubyte *, glGetString, GLenum, name, d0, \
	, CYBERGL_BASE_NAME)
GLubyte *glGetString(GLenum name) {
  return glGetString_jump(name);
}

#define glGetTexEnvfv_jump(target, pname, params) \
	LP3NR(0xd8, glGetTexEnvfv, GLenum, target, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexEnvfv(GLenum target, GLenum pname, GLfloat *params) {
  glGetTexEnvfv_jump(target, pname, params);
}

#define glGetTexEnviv_jump(target, pname, params) \
	LP3NR(0xde, glGetTexEnviv, GLenum, target, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexEnviv(GLenum target, GLenum pname, GLint *params) {
  glGetTexEnviv_jump(target, pname, params);
}

#define glGetTexGendv_jump(coord, pname, params) \
	LP3NR(0xb4, glGetTexGendv, GLenum, coord, d0, GLenum, pname, d1, GLdouble *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexGendv(GLenum coord, GLenum pname, GLdouble *params) {
  glGetTexGendv_jump(coord, pname, params);
}

#define glGetTexGenfv_jump(coord, pname, params) \
	LP3NR(0xba, glGetTexGenfv, GLenum, coord, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexGenfv(GLenum coord, GLenum pname, GLfloat *params) {
  glGetTexGenfv_jump(coord, pname, params);
}

#define glGetTexGeniv_jump(coord, pname, params) \
	LP3NR(0xc0, glGetTexGeniv, GLenum, coord, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexGeniv(GLenum coord, GLenum pname, GLint *params) {
  glGetTexGeniv_jump(coord, pname, params);
}

#define glGetTexImage_jump(target, level, format, type, pixels) \
	LP5NR(0xfc, glGetTexImage, GLenum, target, d0, GLint, level, d1, GLenum, format, d2, GLenum, type, d3, GLvoid *, pixels, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels) {
  glGetTexImage_jump(target, level, format, type, pixels);
}

#define glGetTexLevelParameterfv_jump(target, level, pname, params) \
	LP4NR(0xe4, glGetTexLevelParameterfv, GLenum, target, d0, GLint, level, d1, GLenum, pname, d2, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexLevelParameterfv(GLenum target, GLint level, GLenum pname, GLfloat *params) {
  glGetTexLevelParameterfv_jump(target, level, pname, params);
}

#define glGetTexLevelParameteriv_jump(target, level, pname, params) \
	LP4NR(0xea, glGetTexLevelParameteriv, GLenum, target, d0, GLint, level, d1, GLenum, pname, d2, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexLevelParameteriv(GLenum target, GLint level, GLenum pname, GLint *params) {
  glGetTexLevelParameteriv_jump(target, level, pname, params);
}

#define glGetTexParameterfv_jump(target, pname, params) \
	LP3NR(0xf0, glGetTexParameterfv, GLenum, target, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexParameterfv(GLenum target, GLenum pname, GLfloat *params) {
  glGetTexParameterfv_jump(target, pname, params);
}

#define glGetTexParameteriv_jump(target, pname, params) \
	LP3NR(0xf6, glGetTexParameteriv, GLenum, target, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glGetTexParameteriv(GLenum target, GLenum pname, GLint *params) {
  glGetTexParameteriv_jump(target, pname, params);
}

#define glHint_jump(target, mode) \
	LP2NR(0x522, glHint, GLenum, target, d0, GLenum, mode, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glHint(GLenum target, GLenum mode) {
  glHint_jump(target, mode);
}

#define glIndexd_jump(index) \
	LP1NR(0x37e, glIndexd, GLdouble, index, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glIndexd(GLdouble index) {
  glIndexd_jump(index);
}

#define glIndexdv_jump(v) \
	LP1NR(0x396, glIndexdv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glIndexdv(const GLdouble *v) {
  glIndexdv_jump(v);
}

#define glIndexf_jump(index) \
	LP1NR(0x378, glIndexf, GLfloat, index, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glIndexf(GLfloat index) {
  glIndexf_jump(index);
}

#define glIndexfv_jump(v) \
	LP1NR(0x390, glIndexfv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glIndexfv(const GLfloat *v) {
  glIndexfv_jump(v);
}

#define glIndexi_jump(index) \
	LP1NR(0x372, glIndexi, GLint, index, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glIndexi(GLint index) {
  glIndexi_jump(index);
}

#define glIndexiv_jump(v) \
	LP1NR(0x38a, glIndexiv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glIndexiv(const GLint *v) {
  glIndexiv_jump(v);
}

#define glIndexs_jump(index) \
	LP1NR(0x36c, glIndexs, GLshort, index, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glIndexs(GLshort index) {
  glIndexs_jump(index);
}

#define glIndexsv_jump(v) \
	LP1NR(0x384, glIndexsv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glIndexsv(const GLshort *v) {
  glIndexsv_jump(v);
}

#define glInitNames_jump() \
	LP0NR(0x56a, glInitNames, \
	, CYBERGL_BASE_NAME)
GLvoid glInitNames(GLvoid) {
  glInitNames_jump();
}

#define glIsEnabled_jump(cap) \
	LP1(0x78, GLboolean, glIsEnabled, GLenum, cap, d0, \
	, CYBERGL_BASE_NAME)
GLboolean glIsEnabled(GLenum cap) {
  return glIsEnabled_jump(cap);
}

#define glLightModelf_jump(pname, param) \
	LP2NR(0x5a0, glLightModelf, GLenum, pname, d0, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glLightModelf(GLenum pname, GLfloat param) {
  glLightModelf_jump(pname, param);
}

#define glLightModelfv_jump(pname, params) \
	LP2NR(0x5ac, glLightModelfv, GLenum, pname, d0, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glLightModelfv(GLenum pname, GLfloat *params) {
  glLightModelfv_jump(pname, params);
}

#define glLightModeli_jump(pname, param) \
	LP2NR(0x5a6, glLightModeli, GLenum, pname, d0, GLint, param, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glLightModeli(GLenum pname, GLint param) {
  glLightModeli_jump(pname, param);
}

#define glLightModeliv_jump(pname, params) \
	LP2NR(0x5b2, glLightModeliv, GLenum, pname, d0, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glLightModeliv(GLenum pname, GLint *params) {
  glLightModeliv_jump(pname, params);
}

#define glLightf_jump(light, pname, param) \
	LP3NR(0x588, glLightf, GLenum, light, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glLightf(GLenum light, GLenum pname, GLfloat param) {
  glLightf_jump(light, pname, param);
}

#define glLightfv_jump(light, pname, params) \
	LP3NR(0x594, glLightfv, GLenum, light, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glLightfv(GLenum light, GLenum pname, GLfloat *params) {
  glLightfv_jump(light, pname, params);
}

#define glLighti_jump(light, pname, param) \
	LP3NR(0x58e, glLighti, GLenum, light, d0, GLenum, pname, d1, GLint, param, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glLighti(GLenum light, GLenum pname, GLint param) {
  glLighti_jump(light, pname, param);
}

#define glLightiv_jump(light, pname, params) \
	LP3NR(0x59a, glLightiv, GLenum, light, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glLightiv(GLenum light, GLenum pname, GLint *params) {
  glLightiv_jump(light, pname, params);
}

#define glLoadIdentity_jump() \
	LP0NR(0x492, glLoadIdentity, \
	, CYBERGL_BASE_NAME)
GLvoid glLoadIdentity(GLvoid) {
  glLoadIdentity_jump();
}

#define glLoadMatrixd_jump(m) \
	LP1NR(0x480, glLoadMatrixd, const GLdouble *, m, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glLoadMatrixd(const GLdouble *m) {
  glLoadMatrixd_jump(m);
}

#define glLoadMatrixf_jump(m) \
	LP1NR(0x47a, glLoadMatrixf, const GLfloat *, m, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glLoadMatrixf(const GLfloat *m) {
  glLoadMatrixf_jump(m);
}

#define glLoadName_jump(name) \
	LP1NR(0x570, glLoadName, GLuint, name, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glLoadName(GLuint name) {
  glLoadName_jump(name);
}

#define glLookAt_jump(lookAt) \
	LP1NR(0x4ec, glLookAt, const GLlookAt *, lookAt, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glLookAt(GLdouble eyex, GLdouble eyey, GLdouble eyez, 
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

#define glMaterialf_jump(face, pname, param) \
	LP3NR(0x5b8, glMaterialf, GLenum, face, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glMaterialf(GLenum face, GLenum pname, GLfloat param) {
  glMaterialf_jump(face, pname, param);
}

#define glMaterialfv_jump(face, pname, params) \
	LP3NR(0x5c4, glMaterialfv, GLenum, face, d0, GLenum, pname, d1, GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glMaterialfv(GLenum face, GLenum pname, GLfloat *params) {
  glMaterialfv_jump(face, pname, params);
}

#define glMateriali_jump(face, pname, param) \
	LP3NR(0x5be, glMateriali, GLenum, face, d0, GLenum, pname, d1, GLint, param, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glMateriali(GLenum face, GLenum pname, GLint param) {
  glMateriali_jump(face, pname, param);
}

#define glMaterialiv_jump(face, pname, params) \
	LP3NR(0x5ca, glMaterialiv, GLenum, face, d0, GLenum, pname, d1, GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glMaterialiv(GLenum face, GLenum pname, GLint *params) {
  glMaterialiv_jump(face, pname, params);
}

#define glMatrixMode_jump(mode) \
	LP1NR(0x474, glMatrixMode, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glMatrixMode(GLenum mode) {
  glMatrixMode_jump(mode);
}

#define glMultMatrixd_jump(m) \
	LP1NR(0x48c, glMultMatrixd, const GLdouble *, m, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glMultMatrixd(const GLdouble *m) {
  glMultMatrixd_jump(m);
}

#define glMultMatrixf_jump(m) \
	LP1NR(0x486, glMultMatrixf, const GLfloat *, m, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glMultMatrixf(const GLfloat *m) {
  glMultMatrixf_jump(m);
}

#define glNormal3b_jump(nx, ny, nz) \
	LP3NR(0x270, glNormal3b, GLbyte, nx, d0, GLbyte, ny, d1, GLbyte, nz, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3b(GLbyte nx, GLbyte ny, GLbyte nz) {
  glNormal3b_jump(nx, ny, nz);
}

#define glNormal3bv_jump(v) \
	LP1NR(0x28e, glNormal3bv, const GLbyte *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3bv(const GLbyte *v) {
  glNormal3bv_jump(v);
}

#define glNormal3d_jump(nx, ny, nz) \
	LP3NR(0x288, glNormal3d, GLdouble, nx, fp0, GLdouble, ny, fp1, GLdouble, nz, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3d(GLdouble nx, GLdouble ny, GLdouble nz) {
  glNormal3d_jump(nx, ny, nz);
}

#define glNormal3dv_jump(v) \
	LP1NR(0x2a6, glNormal3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3dv(const GLdouble *v) {
  glNormal3dv_jump(v);
}

#define glNormal3f_jump(nx, ny, nz) \
	LP3NR(0x282, glNormal3f, GLfloat, nx, fp0, GLfloat, ny, fp1, GLfloat, nz, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3f(GLfloat nx, GLfloat ny, GLfloat nz) {
  glNormal3f_jump(nx, ny, nz);
}

#define glNormal3fv_jump(v) \
	LP1NR(0x2a0, glNormal3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3fv(const GLfloat *v) {
  glNormal3fv_jump(v);
}

#define glNormal3i_jump(nx, ny, nz) \
	LP3NR(0x27c, glNormal3i, GLint, nx, d0, GLint, ny, d1, GLint, nz, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3i(GLint nx, GLint ny, GLint nz) {
  glNormal3i_jump(nx, ny, nz);
}

#define glNormal3iv_jump(v) \
	LP1NR(0x29a, glNormal3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3iv(const GLint *v) {
  glNormal3iv_jump(v);
}

#define glNormal3s_jump(nx, ny, nz) \
	LP3NR(0x276, glNormal3s, GLshort, nx, d0, GLshort, ny, d1, GLshort, nz, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3s(GLshort nx, GLshort ny, GLshort nz) {
  glNormal3s_jump(nx, ny, nz);
}

#define glNormal3sv_jump(v) \
	LP1NR(0x294, glNormal3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glNormal3sv(const GLshort *v) {
  glNormal3sv_jump(v);
}

#define glOrtho_jump(ortho) \
	LP1NR(0x4c2, glOrtho, const GLortho *, ortho, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glOrtho(GLdouble left,  GLdouble right, GLdouble bottom, GLdouble top,
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

#define glOrtho2D_jump(left, right, bottom, top) \
	LP4NR(0x4d4, glOrtho2D, GLdouble, left, fp0, GLdouble, right, fp1, GLdouble, bottom, fp2, GLdouble, top, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glOrtho2D(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top) {
  glOrtho2D_jump(left, right, bottom, top);
}

#define glPerspective_jump(fovy, aspect, zNear, zFar) \
	LP4NR(0x4e6, glPerspective, GLdouble, fovy, fp0, GLdouble, aspect, fp1, GLdouble, zNear, fp2, GLdouble, zFar, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glPerspective(GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar) {
  glPerspective_jump(fovy, aspect, zNear, zFar);
}

#define glPickMatrix_jump(x, y, width, height) \
	LP4NR(0x4f2, glPickMatrix, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, width, fp2, GLdouble, height, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glPickMatrix(GLdouble x, GLdouble y, GLdouble width, GLdouble height) {
  glPickMatrix_jump(x, y, width, height);
}

#define glPixelMapfv_jump(map, mapsize, values) \
	LP3NR(0x65a, glPixelMapfv, GLenum, map, d0, GLsizei, mapsize, d1, const GLfloat *, values, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glPixelMapfv(GLenum map, GLsizei mapsize, const GLfloat *values) {
  glPixelMapfv_jump(map, mapsize, values);
}

#define glPixelMapuiv_jump(map, mapsize, values) \
	LP3NR(0x64e, glPixelMapuiv, GLenum, map, d0, GLsizei, mapsize, d1, const GLuint *, values, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glPixelMapuiv(GLenum map, GLsizei mapsize, const GLuint *values) {
  glPixelMapuiv_jump(map, mapsize, values);
}

#define glPixelMapusv_jump(map, mapsize, values) \
	LP3NR(0x654, glPixelMapusv, GLenum, map, d0, GLsizei, mapsize, d1, const GLushort *, values, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glPixelMapusv(GLenum map, GLsizei mapsize, const GLushort *values) {
  glPixelMapusv_jump(map, mapsize, values);
}

#define glPixelStoref_jump(pname, param) \
	LP2NR(0x63c, glPixelStoref, GLenum, pname, d0, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glPixelStoref(GLenum pname, GLfloat param) {
  glPixelStoref_jump(pname, param);
}

#define glPixelStorei_jump(pname, param) \
	LP2NR(0x636, glPixelStorei, GLenum, pname, d0, GLint, param, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glPixelStorei(GLenum pname, GLint param) {
  glPixelStorei_jump(pname, param);
}

#define glPixelTransferf_jump(pname, param) \
	LP2NR(0x648, glPixelTransferf, GLenum, pname, d0, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glPixelTransferf(GLenum pname, GLfloat param) {
  glPixelTransferf_jump(pname, param);
}

#define glPixelTransferi_jump(pname, param) \
	LP2NR(0x642, glPixelTransferi, GLenum, pname, d0, GLint, param, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glPixelTransferi(GLenum pname, GLint param) {
  glPixelTransferi_jump(pname, param);
}

#define glPixelZoom_jump(xfactor, yfactor) \
	LP2NR(0x660, glPixelZoom, GLfloat, xfactor, fp0, GLfloat, yfactor, fp1, \
	, CYBERGL_BASE_NAME)
GLvoid glPixelZoom(GLfloat xfactor, GLfloat yfactor) {
  glPixelZoom_jump(xfactor, yfactor);
}

#define glPolygonMode_jump(face, mode) \
	LP2NR(0x54c, glPolygonMode, GLenum, face, d0, GLenum, mode, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glPolygonMode(GLenum face, GLenum mode) {
  glPolygonMode_jump(face, mode);
}

#define glPopAttrib_jump() \
	LP0NR(0x10e, glPopAttrib, \
	, CYBERGL_BASE_NAME)
GLvoid glPopAttrib(GLvoid) {
  glPopAttrib_jump();
}

#define glPopMatrix_jump() \
	LP0NR(0x4ce, glPopMatrix, \
	, CYBERGL_BASE_NAME)
GLvoid glPopMatrix(GLvoid) {
  glPopMatrix_jump();
}

#define glPopName_jump() \
	LP0NR(0x57c, glPopName, \
	, CYBERGL_BASE_NAME)
GLvoid glPopName(GLvoid) {
  glPopName_jump();
}

/*
 * probably wrong
 */
#define glProject_jump(objx, objy, objz, winx, winy, winz) \
	LP6(0x4da, GLboolean, glProject, GLdouble, objx, fp0, GLdouble, objy, fp1, GLdouble, objz, fp2, GLdouble *, winx, a0, GLdouble *, winy, a1, GLdouble *, winz, a2, \
	, CYBERGL_BASE_NAME)
GLboolean glProject(GLdouble objx, GLdouble objy, GLdouble objz, GLdouble *winx, GLdouble *winy, GLdouble *winz) {
  glProject_jump(objx, objy, objz, winx, winy, winz);
}

#define glPushAttrib_jump(mask) \
	LP1NR(0x108, glPushAttrib, GLbitfield, mask, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glPushAttrib(GLbitfield mask) {
  glPushAttrib_jump(mask);
}

#define glPushMatrix_jump() \
	LP0NR(0x4c8, glPushMatrix, \
	, CYBERGL_BASE_NAME)
GLvoid glPushMatrix(GLvoid) {
  glPushMatrix_jump();
}

#define glPushName_jump(name) \
	LP1NR(0x576, glPushName, GLuint, name, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glPushName(GLuint name) {
  glPushName_jump(name);
}

#define glRasterPos2d_jump(s, t) \
	LP2NR(0x3ea, glRasterPos2d, GLdouble, s, fp0, GLdouble, t, fp1, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos2d(GLdouble s, GLdouble t) {
  glRasterPos2d_jump(s, t);
}

#define glRasterPos2dv_jump(v) \
	LP1NR(0x432, glRasterPos2dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos2dv(const GLdouble *v) {
  glRasterPos2dv_jump(v);
}

#define glRasterPos2f_jump(s, t) \
	LP2NR(0x3e4, glRasterPos2f, GLfloat, s, fp0, GLfloat, t, fp1, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos2f(GLfloat s, GLfloat t) {
  glRasterPos2f_jump(s, t);
}

#define glRasterPos2fv_jump(v) \
	LP1NR(0x42c, glRasterPos2fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos2fv(const GLfloat *v) {
  glRasterPos2fv_jump(v);
}

#define glRasterPos2i_jump(s, t) \
	LP2NR(0x3de, glRasterPos2i, GLint, s, d0, GLint, t, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos2i(GLint s, GLint t) {
  glRasterPos2i_jump(s, t);
}

#define glRasterPos2iv_jump(v) \
	LP1NR(0x426, glRasterPos2iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos2iv(const GLint *v) {
  glRasterPos2iv_jump(v);
}

#define glRasterPos2s_jump(s, t) \
	LP2NR(0x3d8, glRasterPos2s, GLshort, s, d0, GLshort, t, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos2s(GLshort s, GLshort t) {
  glRasterPos2s_jump(s, t);
}

#define glRasterPos2sv_jump(v) \
	LP1NR(0x420, glRasterPos2sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos2sv(const GLshort *v) {
  glRasterPos2sv_jump(v);
}

#define glRasterPos3d_jump(s, t, r) \
	LP3NR(0x402, glRasterPos3d, GLdouble, s, fp0, GLdouble, t, fp1, GLdouble, r, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos3d(GLdouble s, GLdouble t, GLdouble r) {
  glRasterPos3d_jump(s, t, r);
}

#define glRasterPos3dv_jump(v) \
	LP1NR(0x44a, glRasterPos3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos3dv(const GLdouble *v) {
  glRasterPos3dv_jump(v);
}

#define glRasterPos3f_jump(s, t, r) \
	LP3NR(0x3fc, glRasterPos3f, GLfloat, s, fp0, GLfloat, t, fp1, GLfloat, r, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos3f(GLfloat s, GLfloat t, GLfloat r) {
  glRasterPos3f_jump(s, t, r);
}

#define glRasterPos3fv_jump(v) \
	LP1NR(0x444, glRasterPos3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos3fv(const GLfloat *v) {
  glRasterPos3fv_jump(v);
}

#define glRasterPos3i_jump(s, t, r) \
	LP3NR(0x3f6, glRasterPos3i, GLint, s, d0, GLint, t, d1, GLint, r, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos3i(GLint s, GLint t, GLint r) {
  glRasterPos3i_jump(s, t, r);
}

#define glRasterPos3iv_jump(v) \
	LP1NR(0x43e, glRasterPos3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos3iv(const GLint *v) {
  glRasterPos3iv_jump(v);
}

#define glRasterPos3s_jump(s, t, r) \
	LP3NR(0x3f0, glRasterPos3s, GLshort, s, d0, GLshort, t, d1, GLshort, r, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos3s(GLshort s, GLshort t, GLshort r) {
  glRasterPos3s_jump(s, t, r);
}

#define glRasterPos3sv_jump(v) \
	LP1NR(0x438, glRasterPos3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos3sv(const GLshort *v) {
  glRasterPos3sv_jump(v);
}

#define glRasterPos4d_jump(s, t, r, q) \
	LP4NR(0x41a, glRasterPos4d, GLdouble, s, fp0, GLdouble, t, fp1, GLdouble, r, fp2, GLdouble, q, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos4d(GLdouble s, GLdouble t, GLdouble r, GLdouble q) {
  glRasterPos4d_jump(s, t, r, q);
}

#define glRasterPos4dv_jump(v) \
	LP1NR(0x462, glRasterPos4dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos4dv(const GLdouble *v) {
  glRasterPos4dv_jump(v);
}

#define glRasterPos4f_jump(s, t, r, q) \
	LP4NR(0x414, glRasterPos4f, GLfloat, s, fp0, GLfloat, t, fp1, GLfloat, r, fp2, GLfloat, q, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q) {
  glRasterPos4f_jump(s, t, r, q);
}

#define glRasterPos4fv_jump(v) \
	LP1NR(0x45c, glRasterPos4fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos4fv(const GLfloat *v) {
  glRasterPos4fv_jump(v);
}

#define glRasterPos4i_jump(s, t, r, q) \
	LP4NR(0x40e, glRasterPos4i, GLint, s, d0, GLint, t, d1, GLint, r, d2, GLint, q, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos4i(GLint s, GLint t, GLint r, GLint q) {
  glRasterPos4i_jump(s, t, r, q);
}

#define glRasterPos4iv_jump(v) \
	LP1NR(0x456, glRasterPos4iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos4iv(const GLint *v) {
  glRasterPos4iv_jump(v);
}

#define glRasterPos4s_jump(s, t, r, q) \
	LP4NR(0x408, glRasterPos4s, GLshort, s, d0, GLshort, t, d1, GLshort, r, d2, GLshort, q, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos4s(GLshort s, GLshort t, GLshort r, GLshort q) {
  glRasterPos4s_jump(s, t, r, q);
}

#define glRasterPos4sv_jump(v) \
	LP1NR(0x450, glRasterPos4sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glRasterPos4sv(const GLshort *v) {
  glRasterPos4sv_jump(v);
}

#define glRectd_jump(x1, y1, x2, y2) \
	LP4NR(0x3ae, glRectd, GLdouble, x1, fp0, GLdouble, y1, fp1, GLdouble, x2, fp2, GLdouble, y2, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glRectd(GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2) {
  glRectd_jump(x1, y1, x2, y2);
}

#define glRectdv_jump(v1, v2) \
	LP2NR(0x3c6, glRectdv, const GLdouble *, v1, a0, const GLdouble *, v2, a1, \
	, CYBERGL_BASE_NAME)
GLvoid glRectdv(const GLdouble *v1, const GLdouble *v2) {
  glRectdv_jump(v1, v2);
}

#define glRectf_jump(x1, y1, x2, y2) \
	LP4NR(0x3a8, glRectf, GLfloat, x1, fp0, GLfloat, y1, fp1, GLfloat, x2, fp2, GLfloat, y2, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glRectf(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2) {
  glRectf_jump(x1, y1, x2, y2);
}

#define glRectfv_jump(v1, v2) \
	LP2NR(0x3c0, glRectfv, const GLfloat *, v1, a0, const GLfloat *, v2, a1, \
	, CYBERGL_BASE_NAME)
GLvoid glRectfv(const GLfloat *v1, const GLfloat *v2) {
  glRectfv_jump(v1, v2);
}

#define glRecti_jump(x1, y1, x2, y2) \
	LP4NR(0x3a2, glRecti, GLint, x1, d0, GLint, y1, d1, GLint, x2, d2, GLint, y2, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glRecti(GLint x1, GLint y1, GLint x2, GLint y2) {
  glRecti_jump(x1, y1, x2, y2);
}

#define glRectiv_jump(v1, v2) \
	LP2NR(0x3ba, glRectiv, const GLint *, v1, a0, const GLint *, v2, a1, \
	, CYBERGL_BASE_NAME)
GLvoid glRectiv(const GLint *v1, const GLint *v2) {
  glRectiv_jump(v1, v2);
}

#define glRects_jump(x1, y1, x2, y2) \
	LP4NR(0x39c, glRects, GLshort, x1, d0, GLshort, y1, d1, GLshort, x2, d2, GLshort, y2, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glRects(GLshort x1, GLshort y1, GLshort x2, GLshort y2) {
  glRects_jump(x1, y1, x2, y2);
}

#define glRectsv_jump(v1, v2) \
	LP2NR(0x3b4, glRectsv, const GLshort *, v1, a0, const GLshort *, v2, a1, \
	, CYBERGL_BASE_NAME)
GLvoid glRectsv(const GLshort *v1, const GLshort *v2) {
  glRectsv_jump(v1, v2);
}

#define glRenderMode_jump(mode) \
	LP1(0x564, GLint, glRenderMode, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)
GLint glRenderMode(GLenum mode) {
  return glRenderMode_jump(mode);
}

#define glRotated_jump(angle, x, y, z) \
	LP4NR(0x49e, glRotated, GLdouble, angle, fp0, GLdouble, x, fp1, GLdouble, y, fp2, GLdouble, z, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glRotated(GLdouble angle, GLdouble x, GLdouble y, GLdouble z) {
  glRotated_jump(angle, x, y, z);
}

#define glRotatef_jump(angle, x, y, z) \
	LP4NR(0x498, glRotatef, GLfloat, angle, fp0, GLfloat, x, fp1, GLfloat, y, fp2, GLfloat, z, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glRotatef(GLfloat angle, GLfloat x, GLfloat y, GLfloat z) {
  glRotatef_jump(angle, x, y, z);
}

#define glScaled_jump(x, y, z) \
	LP3NR(0x4b6, glScaled, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, z, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glScaled(GLdouble x, GLdouble y, GLdouble z) {
  glScaled_jump(x, y, z);
}

#define glScalef_jump(x, y, z) \
	LP3NR(0x4b0, glScalef, GLfloat, x, fp0, GLfloat, y, fp1, GLfloat, z, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glScalef(GLfloat x, GLfloat y, GLfloat z) {
  glScalef_jump(x, y, z);
}

#define glSelectBuffer_jump(size, buffer) \
	LP2NR(0x582, glSelectBuffer, GLsizei, size, d0, GLuint *, buffer, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glSelectBuffer(GLsizei size, GLuint *buffer) {
  glSelectBuffer_jump(size, buffer);
}

#define glShadeModel_jump(mode) \
	LP1NR(0x552, glShadeModel, GLenum, mode, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glShadeModel(GLenum mode) {
  glShadeModel_jump(mode);
}

#define glTexCoord1d_jump(s) \
	LP1NR(0x1c2, glTexCoord1d, GLdouble, s, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord1d(GLdouble s) {
  glTexCoord1d_jump(s);
}

#define glTexCoord1dv_jump(v) \
	LP1NR(0x222, glTexCoord1dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord1dv(const GLdouble *v) {
  glTexCoord1dv_jump(v);
}

#define glTexCoord1f_jump(s) \
	LP1NR(0x1bc, glTexCoord1f, GLfloat, s, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord1f(GLfloat s) {
  glTexCoord1f_jump(s);
}

#define glTexCoord1fv_jump(v) \
	LP1NR(0x21c, glTexCoord1fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord1fv(const GLfloat *v) {
  glTexCoord1fv_jump(v);
}

#define glTexCoord1i_jump(s) \
	LP1NR(0x1b6, glTexCoord1i, GLint, s, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord1i(GLint s) {
  glTexCoord1i_jump(s);
}

#define glTexCoord1iv_jump(v) \
	LP1NR(0x216, glTexCoord1iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord1iv(const GLint *v) {
  glTexCoord1iv_jump(v);
}

#define glTexCoord1s_jump(s) \
	LP1NR(0x1b0, glTexCoord1s, GLshort, s, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord1s(GLshort s) {
  glTexCoord1s_jump(s);
}

#define glTexCoord1sv_jump(v) \
	LP1NR(0x210, glTexCoord1sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord1sv(const GLshort *v) {
  glTexCoord1sv_jump(v);
}

#define glTexCoord2d_jump(s, t) \
	LP2NR(0x1da, glTexCoord2d, GLdouble, s, fp0, GLdouble, t, fp1, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord2d(GLdouble s, GLdouble t) {
  glTexCoord2d_jump(s, t);
}

#define glTexCoord2dv_jump(v) \
	LP1NR(0x23a, glTexCoord2dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord2dv(const GLdouble *v) {
  glTexCoord2dv_jump(v);
}

#define glTexCoord2f_jump(s, t) \
	LP2NR(0x1d4, glTexCoord2f, GLfloat, s, fp0, GLfloat, t, fp1, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord2f(GLfloat s, GLfloat t) {
  glTexCoord2f_jump(s, t);
}

#define glTexCoord2fv_jump(v) \
	LP1NR(0x234, glTexCoord2fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord2fv(const GLfloat *v) {
  glTexCoord2fv_jump(v);
}

#define glTexCoord2i_jump(s, t) \
	LP2NR(0x1ce, glTexCoord2i, GLint, s, d0, GLint, t, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord2i(GLint s, GLint t) {
  glTexCoord2i_jump(s, t);
}

#define glTexCoord2iv_jump(v) \
	LP1NR(0x22e, glTexCoord2iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord2iv(const GLint *v) {
  glTexCoord2iv_jump(v);
}

#define glTexCoord2s_jump(s, t) \
	LP2NR(0x1c8, glTexCoord2s, GLshort, s, d0, GLshort, t, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord2s(GLshort s, GLshort t) {
  glTexCoord2s_jump(s, t);
}

#define glTexCoord2sv_jump(v) \
	LP1NR(0x228, glTexCoord2sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord2sv(const GLshort *v) {
  glTexCoord2sv_jump(v);
}

#define glTexCoord3d_jump(s, t, r) \
	LP3NR(0x1f2, glTexCoord3d, GLdouble, s, fp0, GLdouble, t, fp1, GLdouble, r, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord3d(GLdouble s, GLdouble t, GLdouble r) {
  glTexCoord3d_jump(s, t, r);
}

#define glTexCoord3dv_jump(v) \
	LP1NR(0x252, glTexCoord3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord3dv(const GLdouble *v) {
  glTexCoord3dv_jump(v);
}

#define glTexCoord3f_jump(s, t, r) \
	LP3NR(0x1ec, glTexCoord3f, GLfloat, s, fp0, GLfloat, t, fp1, GLfloat, r, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord3f(GLfloat s, GLfloat t, GLfloat r) {
  glTexCoord3f_jump(s, t, r);
}

#define glTexCoord3fv_jump(v) \
	LP1NR(0x24c, glTexCoord3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord3fv(const GLfloat *v) {
  glTexCoord3fv_jump(v);
}

#define glTexCoord3i_jump(s, t, r) \
	LP3NR(0x1e6, glTexCoord3i, GLint, s, d0, GLint, t, d1, GLint, r, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord3i(GLint s, GLint t, GLint r) {
  glTexCoord3i_jump(s, t, r);
}

#define glTexCoord3iv_jump(v) \
	LP1NR(0x246, glTexCoord3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord3iv(const GLint *v) {
  glTexCoord3iv_jump(v);
}

#define glTexCoord3s_jump(s, t, r) \
	LP3NR(0x1e0, glTexCoord3s, GLshort, s, d0, GLshort, t, d1, GLshort, r, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord3s(GLshort s, GLshort t, GLshort r) {
  glTexCoord3s_jump(s, t, r);
}

#define glTexCoord3sv_jump(v) \
	LP1NR(0x240, glTexCoord3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord3sv(const GLshort *v) {
  glTexCoord3sv_jump(v);
}

#define glTexCoord4d_jump(s, t, r, q) \
	LP4NR(0x20a, glTexCoord4d, GLdouble, s, fp0, GLdouble, t, fp1, GLdouble, r, fp2, GLdouble, q, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord4d(GLdouble s, GLdouble t, GLdouble r, GLdouble q) {
  glTexCoord4d_jump(s, t, r, q);
}

#define glTexCoord4dv_jump(v) \
	LP1NR(0x26a, glTexCoord4dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord4dv(const GLdouble *v) {
  glTexCoord4dv_jump(v);
}

#define glTexCoord4f_jump(s, t, r, q) \
	LP4NR(0x204, glTexCoord4f, GLfloat, s, fp0, GLfloat, t, fp1, GLfloat, r, fp2, GLfloat, q, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q) {
  glTexCoord4f_jump(s, t, r, q);
}

#define glTexCoord4fv_jump(v) \
	LP1NR(0x264, glTexCoord4fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord4fv(const GLfloat *v) {
  glTexCoord4fv_jump(v);
}

#define glTexCoord4i_jump(s, t, r, q) \
	LP4NR(0x1fe, glTexCoord4i, GLint, s, d0, GLint, t, d1, GLint, r, d2, GLint, q, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord4i(GLint s, GLint t, GLint r, GLint q) {
  glTexCoord4i_jump(s, t, r, q);
}

#define glTexCoord4iv_jump(v) \
	LP1NR(0x25e, glTexCoord4iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord4iv(const GLint *v) {
  glTexCoord4iv_jump(v);
}

#define glTexCoord4s_jump(s, t, r, q) \
	LP4NR(0x1f8, glTexCoord4s, GLshort, s, d0, GLshort, t, d1, GLshort, r, d2, GLshort, q, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord4s(GLshort s, GLshort t, GLshort r, GLshort q) {
  glTexCoord4s_jump(s, t, r, q);
}

#define glTexCoord4sv_jump(v) \
	LP1NR(0x258, glTexCoord4sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexCoord4sv(const GLshort *v) {
  glTexCoord4sv_jump(v);
}

#define glTexEnvf_jump(target, pname, param) \
	LP3NR(0x5fa, glTexEnvf, GLenum, target, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexEnvf(GLenum target, GLenum pname, GLfloat param) {
  glTexEnvf_jump(target, pname, param);
}

#define glTexEnvfv_jump(target, pname, params) \
	LP3NR(0x606, glTexEnvfv, GLenum, target, d0, GLenum, pname, d1, const GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexEnvfv(GLenum target, GLenum pname, const GLfloat *params) {
  glTexEnvfv_jump(target, pname, params);
}

#define glTexEnvi_jump(target, pname, param) \
	LP3NR(0x600, glTexEnvi, GLenum, target, d0, GLenum, pname, d1, GLint, param, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glTexEnvi(GLenum target, GLenum pname, GLint param) {
  glTexEnvi_jump(target, pname, param);
}

#define glTexEnviv_jump(target, pname, params) \
	LP3NR(0x60c, glTexEnviv, GLenum, target, d0, GLenum, pname, d1, const GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexEnviv(GLenum target, GLenum pname, const GLint *params) {
  glTexEnviv_jump(target, pname, params);
}

#define glTexGend_jump(coord, pname, param) \
	LP3NR(0x5e2, glTexGend, GLenum, coord, d0, GLenum, pname, d1, GLdouble, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexGend(GLenum coord, GLenum pname, GLdouble param) {
  glTexGend_jump(coord, pname, param);
}

#define glTexGendv_jump(coord, pname, params) \
	LP3NR(0x5f4, glTexGendv, GLenum, coord, d0, GLenum, pname, d1, const GLdouble *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexGendv(GLenum coord, GLenum pname, const GLdouble *params) {
  glTexGendv_jump(coord, pname, params);
}

#define glTexGenf_jump(coord, pname, param) \
	LP3NR(0x5dc, glTexGenf, GLenum, coord, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexGenf(GLenum coord, GLenum pname, GLfloat param) {
  glTexGenf_jump(coord, pname, param);
}

#define glTexGenfv_jump(coord, pname, params) \
	LP3NR(0x5ee, glTexGenfv, GLenum, coord, d0, GLenum, pname, d1, const GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexGenfv(GLenum coord, GLenum pname, const GLfloat *params) {
  glTexGenfv_jump(coord, pname, params);
}

#define glTexGeni_jump(coord, pname, param) \
	LP3NR(0x5d6, glTexGeni, GLenum, coord, d0, GLenum, pname, d1, GLint, param, d0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexGeni(GLenum coord, GLenum pname, GLint param) {
  glTexGeni_jump(coord, pname, param);
}

#define glTexGeniv_jump(coord, pname, params) \
	LP3NR(0x5e8, glTexGeniv, GLenum, coord, d0, GLenum, pname, d1, const GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexGeniv(GLenum coord, GLenum pname, const GLint *params) {
  glTexGeniv_jump(coord, pname, params);
}

#define glTexImage1D_jump(target, level, components, width, border, format, type, pixels) \
	LP8NR(0x62a, glTexImage1D, GLenum, target, d0, GLint, level, d1, GLint, components, d2, GLsizei, width, d3, GLint, border, d4, GLenum, format, d5, GLenum, type, d6, const GLvoid *, pixels, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexImage1D(GLenum target, GLint level, GLint components, GLsizei width,
                  GLint border, GLenum format, GLenum type, const GLvoid *pixels) {
  glTexImage1D_jump(target, level, components, width, border, format, type, pixels);
}

#define glTexImage2D_jump(target, level, components, width, height, border, format, type, pixels) \
	LP9NR(0x630, glTexImage2D, GLenum, target, d0, GLint, level, d1, GLint, components, d2, GLsizei, width, d3, GLsizei, height, d4, GLint, border, d5, GLenum, format, d6, GLenum, type, d7, const GLvoid *, pixels, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexImage2D(GLenum target, GLint level, GLint components, GLsizei width, GLsizei height,
                  GLint border, GLenum format, GLenum type, const GLvoid *pixels) {
  glTexImage2D_jump(target, level, components, width, height, border, format, type, pixels);
}

#define glTexParameterf_jump(target, pname, param) \
	LP3NR(0x612, glTexParameterf, GLenum, target, d0, GLenum, pname, d1, GLfloat, param, fp0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexParameterf(GLenum target, GLenum pname, GLfloat param) {
  glTexParameterf_jump(target, pname, param);
}

#define glTexParameterfv_jump(target, pname, params) \
	LP3NR(0x61e, glTexParameterfv, GLenum, target, d0, GLenum, pname, d1, const GLfloat *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexParameterfv(GLenum target, GLenum pname, const GLfloat *params) {
  glTexParameterfv_jump(target, pname, params);
}

#define glTexParameteri_jump(target, pname, param) \
	LP3NR(0x618, glTexParameteri, GLenum, target, d0, GLenum, pname, d1, GLint, param, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glTexParameteri(GLenum target, GLenum pname, GLint param) {
  glTexParameteri_jump(target, pname, param);
}

#define glTexParameteriv_jump(target, pname, params) \
	LP3NR(0x624, glTexParameteriv, GLenum, target, d0, GLenum, pname, d1, const GLint *, params, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glTexParameteriv(GLenum target, GLenum pname, const GLint *params) {
  glTexParameteriv_jump(target, pname, params);
}

#define glTranslated_jump(x, y, z) \
	LP3NR(0x4aa, glTranslated, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, z, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glTranslated(GLdouble x, GLdouble y, GLdouble z) {
  glTranslated_jump(x, y, z);
}

#define glTranslatef_jump(x, y, z) \
	LP3NR(0x4a4, glTranslatef, GLfloat, x, fp0, GLfloat, y, fp1, GLfloat, z, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glTranslatef(GLfloat x, GLfloat y, GLfloat z) {
  glTranslatef_jump(x, y, z);
}

/*
 * probably wrong
 */
#define glUnProject_jump(winx, winy, winz, objx, objy, objz) \
	LP6(0x4e0, GLboolean, glUnProject, GLdouble, winx, fp0, GLdouble, winy, fp1, GLdouble, winz, fp2, GLdouble *, objx, a0, GLdouble *, objy, a1, GLdouble *, objz, a2, \
	, CYBERGL_BASE_NAME)
GLboolean glUnProject(GLdouble winx, GLdouble winy, GLdouble winz, GLdouble *objx, GLdouble *objy, GLdouble *objz) {
  return glUnProject_jump(winx, winy, winz, objx, objy, objz);
}

#define glVertex2d_jump(x, y) \
	LP2NR(0x132, glVertex2d, GLdouble, x, fp0, GLdouble, y, fp1, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex2d(GLdouble x, GLdouble y) {
  glVertex2d_jump(x, y);
}

#define glVertex2dv_jump(v) \
	LP1NR(0x17a, glVertex2dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex2dv(const GLdouble *v) {
  glVertex2dv_jump(v);
}

#define glVertex2f_jump(x, y) \
	LP2NR(0x12c, glVertex2f, GLfloat, x, fp0, GLfloat, y, fp1, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex2f(GLfloat x, GLfloat y) {
  glVertex2f_jump(x, y);
}

#define glVertex2fv_jump(v) \
	LP1NR(0x174, glVertex2fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex2fv(const GLfloat *v) {
  glVertex2fv_jump(v);
}

#define glVertex2i_jump(x, y) \
	LP2NR(0x126, glVertex2i, GLint, x, d0, GLint, y, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex2i(GLint x, GLint y) {
  glVertex2i_jump(x, y);
}

#define glVertex2iv_jump(v) \
	LP1NR(0x16e, glVertex2iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex2iv(const GLint *v) {
  glVertex2iv_jump(v);
}

#define glVertex2s_jump(x, y) \
	LP2NR(0x120, glVertex2s, GLshort, x, d0, GLshort, y, d1, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex2s(GLshort x, GLshort y) {
  glVertex2s_jump(x, y);
}

#define glVertex2sv_jump(v) \
	LP1NR(0x168, glVertex2sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex2sv(const GLshort *v) {
  glVertex2sv_jump(v);
}

#define glVertex3d_jump(x, y, z) \
	LP3NR(0x14a, glVertex3d, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, z, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex3d(GLdouble x, GLdouble y, GLdouble z) {
  glVertex3d_jump(x, y, z);
}

#define glVertex3dv_jump(v) \
	LP1NR(0x192, glVertex3dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex3dv(const GLdouble *v) {
  glVertex3dv_jump(v);
}

#define glVertex3f_jump(x, y, z) \
	LP3NR(0x144, glVertex3f, GLfloat, x, fp0, GLfloat, y, fp1, GLfloat, z, fp2, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex3f(GLfloat x, GLfloat y, GLfloat z) {
  glVertex3f_jump(x, y, z);
}

#define glVertex3fv_jump(v) \
	LP1NR(0x18c, glVertex3fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex3fv(const GLfloat *v) {
  glVertex3fv_jump(v);
}

#define glVertex3i_jump(x, y, z) \
	LP3NR(0x13e, glVertex3i, GLint, x, d0, GLint, y, d1, GLint, z, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex3i(GLint x, GLint y, GLint z) {
  glVertex3i_jump(x, y, z);
}

#define glVertex3iv_jump(v) \
	LP1NR(0x186, glVertex3iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex3iv(const GLint *v) {
  glVertex3iv_jump(v);
}

#define glVertex3s_jump(x, y, z) \
	LP3NR(0x138, glVertex3s, GLshort, x, d0, GLshort, y, d1, GLshort, z, d2, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex3s(GLshort x, GLshort y, GLshort z) {
  glVertex3s_jump(x, y, z);
}

#define glVertex3sv_jump(v) \
	LP1NR(0x180, glVertex3sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex3sv(const GLshort *v) {
  glVertex3sv_jump(v);
}

#define glVertex4d_jump(x, y, z, w) \
	LP4NR(0x162, glVertex4d, GLdouble, x, fp0, GLdouble, y, fp1, GLdouble, z, fp2, GLdouble, w, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w) {
  glVertex4d_jump(x, y, z, w);
}

#define glVertex4dv_jump(v) \
	LP1NR(0x1aa, glVertex4dv, const GLdouble *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex4dv(const GLdouble *v) {
  glVertex4dv_jump(v);
}

#define glVertex4f_jump(x, y, z, w) \
	LP4NR(0x15c, glVertex4f, GLfloat, x, fp0, GLfloat, y, fp1, GLfloat, z, fp2, GLfloat, w, fp3, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {
  glVertex4f_jump(x, y, z, w);
}

#define glVertex4fv_jump(v) \
	LP1NR(0x1a4, glVertex4fv, const GLfloat *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex4fv(const GLfloat *v) {
  glVertex4fv_jump(v);
}

#define glVertex4i_jump(x, y, z, w) \
	LP4NR(0x156, glVertex4i, GLint, x, d0, GLint, y, d1, GLint, z, d2, GLint, w, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex4i(GLint x, GLint y, GLint z, GLint w) {
  glVertex4i_jump(x, y, z, w);
}

#define glVertex4iv_jump(v) \
	LP1NR(0x19e, glVertex4iv, const GLint *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex4iv(const GLint *v) {
  glVertex4iv_jump(v);
}

#define glVertex4s_jump(x, y, z, w) \
	LP4NR(0x150, glVertex4s, GLshort, x, d0, GLshort, y, d1, GLshort, z, d2, GLshort, w, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex4s(GLshort x, GLshort y, GLshort z, GLshort w) {
  glVertex4s_jump(x, y, z, w);
}

#define glVertex4sv_jump(v) \
	LP1NR(0x198, glVertex4sv, const GLshort *, v, a0, \
	, CYBERGL_BASE_NAME)
GLvoid glVertex4sv(const GLshort *v) {
  glVertex4sv_jump(v);
}

#define glViewport_jump(x, y, width, height) \
	LP4NR(0x46e, glViewport, GLint, x, d0, GLint, y, d1, GLsizei, width, d2, GLsizei, height, d3, \
	, CYBERGL_BASE_NAME)
GLvoid glViewport(GLint x, GLint y, GLsizei width, GLsizei height) {
  glViewport_jump(x, y, width, height);
}

#define openGLWindowTagList_jump(width, height, tags) \
	LP3(0x1e, GLvoid *, openGLWindowTagList, GLint, width, d0, GLint, height, d1, struct TagItem *, tags, a0, \
	, CYBERGL_BASE_NAME)
GLvoid *openGLWindowTagList(GLint width, GLint height, struct TagItem *tags) {
  return openGLWindowTagList_jump(width, height, tags);
}

#ifndef NO_INLINE_STDARG
#define openGLWindowTags(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; openGLWindowTagList((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define resizeGLWindow_jump(window, width, height) \
	LP3NR(0x36, resizeGLWindow, GLvoid *, window, a0, GLint, width, d0, GLint, height, d1, \
	, CYBERGL_BASE_NAME)
GLvoid resizeGLWindow(GLvoid *window, GLint width, GLint height) {
  resizeGLWindow_jump(window, width, height);
}



#endif /* !_LIB_CYBERGL_H */
