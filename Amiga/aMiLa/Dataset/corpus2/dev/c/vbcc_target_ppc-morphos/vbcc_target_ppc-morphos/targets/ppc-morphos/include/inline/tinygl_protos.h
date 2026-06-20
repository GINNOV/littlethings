#ifndef _VBCCINLINE_TINYGL_H
#define _VBCCINLINE_TINYGL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void __GLEnable(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEnable(arg1, arg2) __GLEnable((arg1), (arg2))

void __GLDisable(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDisable(arg1, arg2) __GLDisable((arg1), (arg2))

GLboolean __GLIsEnabled(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLIsEnabled(arg1, arg2) __GLIsEnabled((arg1), (arg2))

void __GLShadeModel(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLShadeModel(arg1, arg2) __GLShadeModel((arg1), (arg2))

void __GLCullFace(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLCullFace(arg1, arg2) __GLCullFace((arg1), (arg2))

void __GLPolygonMode(GLContext * arg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPolygonMode(arg1, arg2, arg3) __GLPolygonMode((arg1), (arg2), (arg3))

void __GLBegin(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLBegin(arg1, arg2) __GLBegin((arg1), (arg2))

void __GLEnd(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEnd(arg1) __GLEnd((arg1))

void __GLVertex3f(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLVertex3f(arg1, arg2, arg3, arg4) __GLVertex3f((arg1), (arg2), (arg3), (arg4))

void __GLVertex4f(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLVertex4f(arg1, arg2, arg3, arg4, arg5) __GLVertex4f((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLVertex3fv(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLVertex3fv(arg1, arg2) __GLVertex3fv((arg1), (arg2))

void __GLVertex4fv(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLVertex4fv(arg1, arg2) __GLVertex4fv((arg1), (arg2))

void __GLColor3f(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor3f(arg1, arg2, arg3, arg4) __GLColor3f((arg1), (arg2), (arg3), (arg4))

void __GLColor4f(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor4f(arg1, arg2, arg3, arg4, arg5) __GLColor4f((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLColor3fv(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor3fv(arg1, arg2) __GLColor3fv((arg1), (arg2))

void __GLColor4fv(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor4fv(arg1, arg2) __GLColor4fv((arg1), (arg2))

void __GLColor3ub(GLContext * arg1, GLubyte arg2, GLubyte arg3, GLubyte arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor3ub(arg1, arg2, arg3, arg4) __GLColor3ub((arg1), (arg2), (arg3), (arg4))

void __GLColor4ub(GLContext * arg1, GLubyte arg2, GLubyte arg3, GLubyte arg4, GLubyte arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor4ub(arg1, arg2, arg3, arg4, arg5) __GLColor4ub((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLColor3ubv(GLContext * arg1, const GLubyte * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor3ubv(arg1, arg2) __GLColor3ubv((arg1), (arg2))

void __GLColor4ubv(GLContext * arg1, const GLubyte * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor4ubv(arg1, arg2) __GLColor4ubv((arg1), (arg2))

void __GLNormal3f(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLNormal3f(arg1, arg2, arg3, arg4) __GLNormal3f((arg1), (arg2), (arg3), (arg4))

void __GLNormal3fv(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLNormal3fv(arg1, arg2) __GLNormal3fv((arg1), (arg2))

void __GLTexCoord2f(GLContext * arg1, GLfloat arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexCoord2f(arg1, arg2, arg3) __GLTexCoord2f((arg1), (arg2), (arg3))

void __GLTexCoord2fv(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexCoord2fv(arg1, arg2) __GLTexCoord2fv((arg1), (arg2))

void __GLMultiTexCoord2fARB(GLContext * arg1, GLenum arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMultiTexCoord2fARB(arg1, arg2, arg3, arg4) __GLMultiTexCoord2fARB((arg1), (arg2), (arg3), (arg4))

void __GLMultiTexCoord2fvARB(GLContext * arg1, GLenum arg2, const GLfloat * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMultiTexCoord2fvARB(arg1, arg2, arg3) __GLMultiTexCoord2fvARB((arg1), (arg2), (arg3))

void __GLEdgeFlag(GLContext * arg1, GLboolean arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEdgeFlag(arg1, arg2) __GLEdgeFlag((arg1), (arg2))

void __GLMatrixMode(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMatrixMode(arg1, arg2) __GLMatrixMode((arg1), (arg2))

void __GLLoadMatrixf(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLoadMatrixf(arg1, arg2) __GLLoadMatrixf((arg1), (arg2))

void __GLLoadIdentity(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLoadIdentity(arg1) __GLLoadIdentity((arg1))

void __GLMultMatrixf(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMultMatrixf(arg1, arg2) __GLMultMatrixf((arg1), (arg2))

void __GLPushMatrix(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPushMatrix(arg1) __GLPushMatrix((arg1))

void __GLPopMatrix(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPopMatrix(arg1) __GLPopMatrix((arg1))

void __GLRotatef(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRotatef(arg1, arg2, arg3, arg4, arg5) __GLRotatef((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLTranslatef(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTranslatef(arg1, arg2, arg3, arg4) __GLTranslatef((arg1), (arg2), (arg3), (arg4))

void __GLScalef(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLScalef(arg1, arg2, arg3, arg4) __GLScalef((arg1), (arg2), (arg3), (arg4))

void __GLViewport(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLViewport(arg1, arg2, arg3, arg4, arg5) __GLViewport((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLFrustum(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5, GLfloat arg6, GLfloat arg7) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLFrustum(arg1, arg2, arg3, arg4, arg5, arg6, arg7) __GLFrustum((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7))

void __GLOrtho(GLContext * arg1, float arg2, float arg3, float arg4, float arg5, float arg6, float arg7) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLOrtho(arg1, arg2, arg3, arg4, arg5, arg6, arg7) __GLOrtho((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7))

unsigned int __GLGenLists(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGenLists(arg1, arg2) __GLGenLists((arg1), (arg2))

int __GLIsList(GLContext * arg1, unsigned int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLIsList(arg1, arg2) __GLIsList((arg1), (arg2))

void __GLNewList(GLContext * arg1, unsigned int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLNewList(arg1, arg2, arg3) __GLNewList((arg1), (arg2), (arg3))

void __GLEndList(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEndList(arg1) __GLEndList((arg1))

void __GLCallList(GLContext * arg1, unsigned int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLCallList(arg1, arg2) __GLCallList((arg1), (arg2))

void __GLDeleteLists(GLContext * arg1, GLint arg2, GLsizei arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDeleteLists(arg1, arg2, arg3) __GLDeleteLists((arg1), (arg2), (arg3))

void __GLClear(GLContext * arg1, GLbitfield arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLClear(arg1, arg2) __GLClear((arg1), (arg2))

void __GLClearColor(GLContext * arg1, GLclampf arg2, GLclampf arg3, GLclampf arg4, GLclampf arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLClearColor(arg1, arg2, arg3, arg4, arg5) __GLClearColor((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLClearDepth(GLContext * arg1, GLclampf arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLClearDepth(arg1, arg2) __GLClearDepth((arg1), (arg2))

int __GLRenderMode(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRenderMode(arg1, arg2) __GLRenderMode((arg1), (arg2))

void __GLSelectBuffer(GLContext * arg1, int arg2, unsigned int * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLSelectBuffer(arg1, arg2, arg3) __GLSelectBuffer((arg1), (arg2), (arg3))

void __GLInitNames(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLInitNames(arg1) __GLInitNames((arg1))

void __GLPushName(GLContext * arg1, unsigned int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPushName(arg1, arg2) __GLPushName((arg1), (arg2))

void __GLPopName(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPopName(arg1) __GLPopName((arg1))

void __GLLoadName(GLContext * arg1, unsigned int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLoadName(arg1, arg2) __GLLoadName((arg1), (arg2))

void __GLGenTextures(GLContext * arg1, GLsizei arg2, GLuint * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGenTextures(arg1, arg2, arg3) __GLGenTextures((arg1), (arg2), (arg3))

void __GLDeleteTextures(GLContext * arg1, GLsizei arg2, const GLuint * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDeleteTextures(arg1, arg2, arg3) __GLDeleteTextures((arg1), (arg2), (arg3))

void __GLBindTexture(GLContext * arg1, GLenum arg2, GLuint arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLBindTexture(arg1, arg2, arg3) __GLBindTexture((arg1), (arg2), (arg3))

void __GLTexImage2D(GLContext * arg1, GLenum arg2, GLint arg3, GLenum arg4, GLsizei arg5, GLsizei arg6, GLsizei arg7, GLenum arg8, GLenum arg9, GLvoid * arg10) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexImage2D(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) __GLTexImage2D((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7), (arg8), (arg9), (arg10))

void __GLTexSubImage2D(GLContext * arg1, GLenum arg2, GLint arg3, GLint arg4, GLint arg5, GLsizei arg6, GLsizei arg7, GLenum arg8, GLenum arg9, GLvoid * arg10) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexSubImage2D(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) __GLTexSubImage2D((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7), (arg8), (arg9), (arg10))

void __GLTexEnvi(GLContext * arg1, GLenum arg2, GLenum arg3, GLint arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexEnvi(arg1, arg2, arg3, arg4) __GLTexEnvi((arg1), (arg2), (arg3), (arg4))

void __GLTexEnvf(GLContext * arg1, GLenum arg2, GLenum arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexEnvf(arg1, arg2, arg3, arg4) __GLTexEnvf((arg1), (arg2), (arg3), (arg4))

void __GLTexParameteri(GLContext * arg1, int arg2, int arg3, int arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexParameteri(arg1, arg2, arg3, arg4) __GLTexParameteri((arg1), (arg2), (arg3), (arg4))

void __GLTexParameterf(GLContext * arg1, int arg2, int arg3, float arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexParameterf(arg1, arg2, arg3, arg4) __GLTexParameterf((arg1), (arg2), (arg3), (arg4))

void __GLPixelStorei(GLContext * arg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPixelStorei(arg1, arg2, arg3) __GLPixelStorei((arg1), (arg2), (arg3))

void __GLActiveTextureARB(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLActiveTextureARB(arg1, arg2) __GLActiveTextureARB((arg1), (arg2))

void __GLTexGeni(GLContext * arg1, GLenum arg2, GLenum arg3, GLint arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexGeni(arg1, arg2, arg3, arg4) __GLTexGeni((arg1), (arg2), (arg3), (arg4))

void __GLTexGenfv(GLContext * arg1, GLenum arg2, GLenum arg3, GLfloat * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexGenfv(arg1, arg2, arg3, arg4) __GLTexGenfv((arg1), (arg2), (arg3), (arg4))

void __GLMaterialfv(GLContext * arg1, int arg2, int arg3, float * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMaterialfv(arg1, arg2, arg3, arg4) __GLMaterialfv((arg1), (arg2), (arg3), (arg4))

void __GLMaterialf(GLContext * arg1, int arg2, int arg3, float arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMaterialf(arg1, arg2, arg3, arg4) __GLMaterialf((arg1), (arg2), (arg3), (arg4))

void __GLColorMaterial(GLContext * arg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColorMaterial(arg1, arg2, arg3) __GLColorMaterial((arg1), (arg2), (arg3))

void __GLLightfv(GLContext * arg1, int arg2, int arg3, float * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLightfv(arg1, arg2, arg3, arg4) __GLLightfv((arg1), (arg2), (arg3), (arg4))

void __GLLightf(GLContext * arg1, int arg2, int arg3, float arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLightf(arg1, arg2, arg3, arg4) __GLLightf((arg1), (arg2), (arg3), (arg4))

void __GLLightModeli(GLContext * arg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLightModeli(arg1, arg2, arg3) __GLLightModeli((arg1), (arg2), (arg3))

void __GLLightModelfv(GLContext * arg1, int arg2, float * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLightModelfv(arg1, arg2, arg3) __GLLightModelfv((arg1), (arg2), (arg3))

void __GLLightModelf(GLContext * arg1, int arg2, float arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLightModelf(arg1, arg2, arg3) __GLLightModelf((arg1), (arg2), (arg3))

void __GLFlush(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLFlush(arg1) __GLFlush((arg1))

void __GLHint(GLContext * arg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLHint(arg1, arg2, arg3) __GLHint((arg1), (arg2), (arg3))

void __GLGetIntegerv(GLContext * arg1, int arg2, int * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetIntegerv(arg1, arg2, arg3) __GLGetIntegerv((arg1), (arg2), (arg3))

void __GLGetFloatv(GLContext * arg1, int arg2, float * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetFloatv(arg1, arg2, arg3) __GLGetFloatv((arg1), (arg2), (arg3))

void __GLFrontFace(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLFrontFace(arg1, arg2) __GLFrontFace((arg1), (arg2))

void __GLEnableClientState(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEnableClientState(arg1, arg2) __GLEnableClientState((arg1), (arg2))

void __GLDisableClientState(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDisableClientState(arg1, arg2) __GLDisableClientState((arg1), (arg2))

void __GLArrayElement(GLContext * arg1, GLint arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLArrayElement(arg1, arg2) __GLArrayElement((arg1), (arg2))

void __GLVertexPointer(GLContext * arg1, GLint arg2, GLenum arg3, GLsizei arg4, const GLvoid * arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLVertexPointer(arg1, arg2, arg3, arg4, arg5) __GLVertexPointer((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLColorPointer(GLContext * arg1, GLint arg2, GLenum arg3, GLsizei arg4, const GLvoid * arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColorPointer(arg1, arg2, arg3, arg4, arg5) __GLColorPointer((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLNormalPointer(GLContext * arg1, GLenum arg2, GLsizei arg3, const GLvoid * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLNormalPointer(arg1, arg2, arg3, arg4) __GLNormalPointer((arg1), (arg2), (arg3), (arg4))

void __GLTexCoordPointer(GLContext * arg1, GLint arg2, GLenum arg3, GLsizei arg4, const GLvoid * arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexCoordPointer(arg1, arg2, arg3, arg4, arg5) __GLTexCoordPointer((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLLockArraysEXT(GLContext * arg1, GLint arg2, GLint arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLockArraysEXT(arg1, arg2, arg3) __GLLockArraysEXT((arg1), (arg2), (arg3))

void __GLUnlockArraysEXT(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUnlockArraysEXT(arg1) __GLUnlockArraysEXT((arg1))

void __GLDrawElements(GLContext * arg1, GLenum arg2, GLsizei arg3, GLenum arg4, GLvoid * arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDrawElements(arg1, arg2, arg3, arg4, arg5) __GLDrawElements((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLDrawArrays(GLContext * arg1, GLenum arg2, GLint arg3, GLsizei arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDrawArrays(arg1, arg2, arg3, arg4) __GLDrawArrays((arg1), (arg2), (arg3), (arg4))

void __GLClientActiveTextureARB(GLContext  * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLClientActiveTextureARB(arg1, arg2) __GLClientActiveTextureARB((arg1), (arg2))

void __GLPolygonOffset(GLContext * arg1, GLfloat arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPolygonOffset(arg1, arg2, arg3) __GLPolygonOffset((arg1), (arg2), (arg3))

void __GLBlendFunc(GLContext * arg1, GLenum arg2, GLenum arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLBlendFunc(arg1, arg2, arg3) __GLBlendFunc((arg1), (arg2), (arg3))

void __GLDepthMask(GLContext * arg1, GLboolean arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDepthMask(arg1, arg2) __GLDepthMask((arg1), (arg2))

void __GLAlphaFunc(GLContext * arg1, GLenum arg2, GLclampf arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLAlphaFunc(arg1, arg2, arg3) __GLAlphaFunc((arg1), (arg2), (arg3))

void __GLPointSize(GLContext * arg1, GLfloat arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPointSize(arg1, arg2) __GLPointSize((arg1), (arg2))

void __GLPointParameterfEXT(GLContext * arg1, GLenum arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPointParameterfEXT(arg1, arg2, arg3) __GLPointParameterfEXT((arg1), (arg2), (arg3))

void __GLPointParameterfvEXT(GLContext * arg1, GLenum arg2, GLfloat * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPointParameterfvEXT(arg1, arg2, arg3) __GLPointParameterfvEXT((arg1), (arg2), (arg3))

void __GLDepthRange(GLContext * arg1, GLclampf arg2, GLclampf arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDepthRange(arg1, arg2, arg3) __GLDepthRange((arg1), (arg2), (arg3))

void __GLDepthFunc(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDepthFunc(arg1, arg2) __GLDepthFunc((arg1), (arg2))

void * __TGLGetContexts() =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define TGLGetContexts() __TGLGetContexts()

GLContext * __GLInit() =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLInit() __GLInit()

void __GLClose(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLClose(arg1) __GLClose((arg1))

void __GLUPerspective(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUPerspective(arg1, arg2, arg3, arg4, arg5) __GLUPerspective((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLULookAt(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5, GLfloat arg6, GLfloat arg7, GLfloat arg8, GLfloat arg9, GLfloat arg10) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLULookAt(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) __GLULookAt((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7), (arg8), (arg9), (arg10))

void __GLUTInit(GLContext * arg1, int * arg2, char ** arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTInit(arg1, arg2, arg3) __GLUTInit((arg1), (arg2), (arg3))

void __GLUTInitWindowPosition(GLContext * arg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTInitWindowPosition(arg1, arg2, arg3) __GLUTInitWindowPosition((arg1), (arg2), (arg3))

void __GLUTInitWindowSize(GLContext * arg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTInitWindowSize(arg1, arg2, arg3) __GLUTInitWindowSize((arg1), (arg2), (arg3))

int __GLUTCreateWindow(GLContext * arg1, char * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTCreateWindow(arg1, arg2) __GLUTCreateWindow((arg1), (arg2))

void __GLUTFullScreen(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTFullScreen(arg1) __GLUTFullScreen((arg1))

void __GLUTSetWindow(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-694(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTSetWindow(arg1, arg2) __GLUTSetWindow((arg1), (arg2))

int __GLUTGetWindow(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-700(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTGetWindow(arg1) __GLUTGetWindow((arg1))

void __GLUTDestroyWindow(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-706(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTDestroyWindow(arg1, arg2) __GLUTDestroyWindow((arg1), (arg2))

void __GLUTSwapBuffers(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-712(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTSwapBuffers(arg1) __GLUTSwapBuffers((arg1))

void __GLUTMainLoop(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-718(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTMainLoop(arg1) __GLUTMainLoop((arg1))

void __GLUTPostRedisplay(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-724(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTPostRedisplay(arg1) __GLUTPostRedisplay((arg1))

void __GLUTDisplayFunc(GLContext * arg1, void (*arg2)(void)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-730(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTDisplayFunc(arg1, arg2) __GLUTDisplayFunc((arg1), (arg2))

void __GLUTReshapeFunc(GLContext * arg1, void (*arg2)(int width, int height)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-736(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTReshapeFunc(arg1, arg2) __GLUTReshapeFunc((arg1), (arg2))

void __GLUTIdleFunc(GLContext * arg1, void (*arg2)(void)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-742(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTIdleFunc(arg1, arg2) __GLUTIdleFunc((arg1), (arg2))

void __GLUTKeyboardFunc(GLContext * arg1, void (*arg2)(unsigned char key, int x, int y)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-748(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTKeyboardFunc(arg1, arg2) __GLUTKeyboardFunc((arg1), (arg2))

void __GLUTKeyboardUpFunc(GLContext * arg1, void (*arg2)(unsigned char key, int x, int y)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-754(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTKeyboardUpFunc(arg1, arg2) __GLUTKeyboardUpFunc((arg1), (arg2))

void __GLUTMouseFunc(GLContext * arg1, void (*arg2)(int button, int state, int x, int y)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-760(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTMouseFunc(arg1, arg2) __GLUTMouseFunc((arg1), (arg2))

void __GLUTMotionFunc(GLContext * arg1, void (*arg2)(int x, int y)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-766(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTMotionFunc(arg1, arg2) __GLUTMotionFunc((arg1), (arg2))

void __GLUTEntryFunc(GLContext * arg1, void (*arg2)(int state)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-772(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTEntryFunc(arg1, arg2) __GLUTEntryFunc((arg1), (arg2))

void __GLUTShowWindow(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-778(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTShowWindow(arg1) __GLUTShowWindow((arg1))

void __GLUTHideWindow(GLContext * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-784(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTHideWindow(arg2) __GLUTHideWindow((arg2))

void __GLUTPositionWindow(GLContext * arg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-790(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTPositionWindow(arg1, arg2, arg3) __GLUTPositionWindow((arg1), (arg2), (arg3))

void __GLUTReshapeWindow(GLContext * iarg1, int arg2, int arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-796(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTReshapeWindow(iarg1, arg2, arg3) __GLUTReshapeWindow((iarg1), (arg2), (arg3))

int __GLUTGet(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-802(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTGet(arg1, arg2) __GLUTGet((arg1), (arg2))

void __GLUTInitDisplayMode(GLContext * arg1, unsigned int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-808(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTInitDisplayMode(arg1, arg2) __GLUTInitDisplayMode((arg1), (arg2))

void __GLUTSpecialFunc(GLContext * arg1, void (*arg2)(int key, int x, int y)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-814(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTSpecialFunc(arg1, arg2) __GLUTSpecialFunc((arg1), (arg2))

void __GLUTTimerFunc(GLContext * arg1, int arg2, void (*arg3)(int value), int arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-820(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTTimerFunc(arg1, arg2, arg3, arg4) __GLUTTimerFunc((arg1), (arg2), (arg3), (arg4))

int __GLUTGetModifiers(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-826(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTGetModifiers(arg1) __GLUTGetModifiers((arg1))

void __GLUTPassiveMotionFunc(GLContext * arg1, void (*arg2)(int x, int y)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-832(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTPassiveMotionFunc(arg1, arg2) __GLUTPassiveMotionFunc((arg1), (arg2))

int __GLAInitializeContextWindowed(GLContext * arg1, void * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-838(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLAInitializeContextWindowed(arg1, arg2) __GLAInitializeContextWindowed((arg1), (arg2))

void __GLADestroyContextWindowed(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-844(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLADestroyContextWindowed(arg1) __GLADestroyContextWindowed((arg1))

void __GLASwapBuffers(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-850(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLASwapBuffers(arg1) __GLASwapBuffers((arg1))

void * __GLUTGetWindowHandle(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-856(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTGetWindowHandle(arg1) __GLUTGetWindowHandle((arg1))

GLbyte * __GLGetString(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-862(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetString(arg1, arg2) __GLGetString((arg1), (arg2))

void __GLPushAttrib(GLContext * arg1, GLbitfield arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-868(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPushAttrib(arg1, arg2) __GLPushAttrib((arg1), (arg2))

void __GLPopAttrib(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-874(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPopAttrib(arg1) __GLPopAttrib((arg1))

void __GLScissor(GLContext * arg1, GLint arg2, GLint arg3, GLsizei arg4, GLsizei arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-880(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLScissor(arg1, arg2, arg3, arg4, arg5) __GLScissor((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLListBase(GLContext * arg1, GLuint arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-886(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLListBase(arg1, arg2) __GLListBase((arg1), (arg2))

void __GLCallLists(GLContext * arg1, GLsizei arg2, GLenum arg3, GLvoid   * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-892(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLCallLists(arg1, arg2, arg3, arg4) __GLCallLists((arg1), (arg2), (arg3), (arg4))

void __GLGetDoublev(GLContext * arg1, int arg2, double * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-898(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetDoublev(arg1, arg2, arg3) __GLGetDoublev((arg1), (arg2), (arg3))

void __GLUTSpecialUpFunc(GLContext * arg1, void (*arg2)(int key, int x, int y)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-904(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTSpecialUpFunc(arg1, arg2) __GLUTSpecialUpFunc((arg1), (arg2))

void __GLLineWidth(GLContext * arg1, GLfloat arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-910(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLineWidth(arg1, arg2) __GLLineWidth((arg1), (arg2))

void __GLRectf(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-916(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRectf(arg1, arg2, arg3, arg4, arg5) __GLRectf((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLRectfv(GLContext * arg1, GLfloat * arg2, GLfloat * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-922(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRectfv(arg1, arg2, arg3) __GLRectfv((arg1), (arg2), (arg3))

void __GLRectiv(GLContext * arg1, GLint  * arg2, GLint * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-928(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRectiv(arg1, arg2, arg3) __GLRectiv((arg1), (arg2), (arg3))

void __GLRectdv(GLContext * arg1, GLdouble * arg2, GLdouble * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-934(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRectdv(arg1, arg2, arg3) __GLRectdv((arg1), (arg2), (arg3))

void __GLEvalPoint1(GLContext * arg1, GLint arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-940(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEvalPoint1(arg1, arg2) __GLEvalPoint1((arg1), (arg2))

void __GLEvalPoint2(GLContext * arg1, GLint arg2, GLint arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-946(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEvalPoint2(arg1, arg2, arg3) __GLEvalPoint2((arg1), (arg2), (arg3))

void __GLEvalCoord1f(GLContext * arg1, GLfloat arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-952(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEvalCoord1f(arg1, arg2) __GLEvalCoord1f((arg1), (arg2))

void __GLEvalCoord2f(GLContext * arg1, GLfloat arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-958(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEvalCoord2f(arg1, arg2, arg3) __GLEvalCoord2f((arg1), (arg2), (arg3))

void __GLEvalCoord1fv(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-964(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEvalCoord1fv(arg1, arg2) __GLEvalCoord1fv((arg1), (arg2))

void __GLEvalCoord2fv(GLContext * arg1, const GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-970(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEvalCoord2fv(arg1, arg2) __GLEvalCoord2fv((arg1), (arg2))

void __GLEvalMesh1(GLContext * arg1, GLenum arg2, GLint arg3, GLint arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-976(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEvalMesh1(arg1, arg2, arg3, arg4) __GLEvalMesh1((arg1), (arg2), (arg3), (arg4))

void __GLEvalMesh2(GLContext * arg1, GLenum arg2, GLint arg3, GLint arg4, GLint arg5, GLint arg6) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-982(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLEvalMesh2(arg1, arg2, arg3, arg4, arg5, arg6) __GLEvalMesh2((arg1), (arg2), (arg3), (arg4), (arg5), (arg6))

void __GLMap1f(GLContext * arg1, GLenum arg2, GLfloat arg3, GLfloat arg4, GLint arg5, GLint arg6, const GLfloat * arg7) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-988(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMap1f(arg1, arg2, arg3, arg4, arg5, arg6, arg7) __GLMap1f((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7))

void __GLMap1d(GLContext * arg1, GLenum arg2, GLdouble arg3, GLdouble arg4, GLint arg5, GLint arg6, const GLdouble * arg7) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-994(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMap1d(arg1, arg2, arg3, arg4, arg5, arg6, arg7) __GLMap1d((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7))

void __GLMap2f(GLContext * arg1, GLenum arg2, GLfloat arg3, GLfloat arg4, GLint arg5, GLint arg6, GLfloat arg7, GLfloat arg8, GLint arg9, GLint arg10, const GLfloat * arg11) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1000(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMap2f(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11) __GLMap2f((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7), (arg8), (arg9), (arg10), (arg11))

void __GLMap2d(GLContext * arg1, GLenum arg2, GLdouble arg3, GLdouble arg4, GLint arg5, GLint arg6, GLdouble arg7, GLdouble arg8, GLint arg9, GLint arg10, const GLdouble * arg11) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1006(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMap2d(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11) __GLMap2d((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7), (arg8), (arg9), (arg10), (arg11))

void __GLGetMapdv(GLContext * arg1, GLenum arg2, GLenum arg3, GLdouble * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1012(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetMapdv(arg1, arg2, arg3, arg4) __GLGetMapdv((arg1), (arg2), (arg3), (arg4))

void __GLGetMapfv(GLContext * arg1, GLenum arg2, GLenum arg3, GLfloat * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1018(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetMapfv(arg1, arg2, arg3, arg4) __GLGetMapfv((arg1), (arg2), (arg3), (arg4))

void __GLGetMapiv(GLContext * arg1, GLenum arg2, GLenum arg3, GLint * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1024(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetMapiv(arg1, arg2, arg3, arg4) __GLGetMapiv((arg1), (arg2), (arg3), (arg4))

void __GLMapGrid1f(GLContext * arg1, GLint arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1030(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMapGrid1f(arg1, arg2, arg3, arg4) __GLMapGrid1f((arg1), (arg2), (arg3), (arg4))

void __GLMapGrid1d(GLContext * arg1, GLint arg2, GLdouble arg3, GLdouble arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1036(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMapGrid1d(arg1, arg2, arg3, arg4) __GLMapGrid1d((arg1), (arg2), (arg3), (arg4))

void __GLMapGrid2f(GLContext * arg1, GLint arg2, GLfloat arg3, GLfloat arg4, GLint arg5, GLfloat arg6, GLfloat arg7) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1042(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMapGrid2f(arg1, arg2, arg3, arg4, arg5, arg6, arg7) __GLMapGrid2f((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7))

void __GLMapGrid2d(GLContext * arg1, GLint arg2, GLdouble arg3, GLdouble arg4, GLint arg5, GLdouble arg6, GLdouble arg7) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1048(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMapGrid2d(arg1, arg2, arg3, arg4, arg5, arg6, arg7) __GLMapGrid2d((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7))

void __GLMultMatrixd(GLContext * arg1, const GLdouble * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1054(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMultMatrixd(arg1, arg2) __GLMultMatrixd((arg1), (arg2))

int __GLAInitializeContextScreen(GLContext * arg1, void * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1060(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLAInitializeContextScreen(arg1, arg2) __GLAInitializeContextScreen((arg1), (arg2))

void __GLADestroyContextScreen(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1066(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLADestroyContextScreen(arg1) __GLADestroyContextScreen((arg1))

int __GLAInitializeContextBitMap(GLContext * arg1, void * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1072(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLAInitializeContextBitMap(arg1, arg2) __GLAInitializeContextBitMap((arg1), (arg2))

void __GLADestroyContextBitMap(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1078(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLADestroyContextBitMap(arg1) __GLADestroyContextBitMap((arg1))

void __GLColorTable(GLContext * arg1, GLenum arg2, GLenum arg3, GLint arg4, GLenum arg5, GLenum arg6, GLvoid * arg7) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1084(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColorTable(arg1, arg2, arg3, arg4, arg5, arg6, arg7) __GLColorTable((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7))

void __GLRasterPos2f(GLContext * arg1, GLfloat arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1090(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRasterPos2f(arg1, arg2, arg3) __GLRasterPos2f((arg1), (arg2), (arg3))

void __GLWindowPos2f(GLContext * arg1, GLfloat arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1096(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLWindowPos2f(arg1, arg2, arg3) __GLWindowPos2f((arg1), (arg2), (arg3))

void __GLBitmap(GLContext * arg1, GLsizei arg2, GLsizei arg3, GLfloat arg4, GLfloat arg5, GLfloat arg6, GLfloat arg7, const GLubyte * arg8) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1102(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLBitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) __GLBitmap((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7), (arg8))

void __GLRasterPos3f(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1108(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRasterPos3f(arg1, arg2, arg3, arg4) __GLRasterPos3f((arg1), (arg2), (arg3), (arg4))

void __GLUTVisibilityFunc(GLContext  * arg1, void (*arg2)(int state)) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1114(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUTVisibilityFunc(arg1, arg2) __GLUTVisibilityFunc((arg1), (arg2))

void __GLFogf(GLContext * arg1, GLenum arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1120(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLFogf(arg1, arg2, arg3) __GLFogf((arg1), (arg2), (arg3))

void __GLFogfv(GLContext * arg1, GLenum arg2, GLfloat * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1126(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLFogfv(arg1, arg2, arg3) __GLFogfv((arg1), (arg2), (arg3))

void __GLASetSync(GLContext * arg1, int arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1132(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLASetSync(arg1, arg2) __GLASetSync((arg1), (arg2))

void __GLLoadMatrixd(GLContext * arg1, const GLdouble * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1138(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLoadMatrixd(arg1, arg2) __GLLoadMatrixd((arg1), (arg2))

void __GLVertex3dv(GLContext * arg1, const GLdouble * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1144(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLVertex3dv(arg1, arg2) __GLVertex3dv((arg1), (arg2))

void __GLVertex4dv(GLContext * arg1, const GLdouble * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1150(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLVertex4dv(arg1, arg2) __GLVertex4dv((arg1), (arg2))

void __GLTexCoord2dv(GLContext * arg1, const GLdouble * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1156(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexCoord2dv(arg1, arg2) __GLTexCoord2dv((arg1), (arg2))

void __GLMultiTexCoord2dvARB(GLContext * arg1, GLenum arg2, const GLdouble * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1162(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMultiTexCoord2dvARB(arg1, arg2, arg3) __GLMultiTexCoord2dvARB((arg1), (arg2), (arg3))

void __GLColor3dv(GLContext * arg1, const GLdouble * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1168(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor3dv(arg1, arg2) __GLColor3dv((arg1), (arg2))

void __GLColor4dv(GLContext * arg1, const GLdouble * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1174(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColor4dv(arg1, arg2) __GLColor4dv((arg1), (arg2))

void __GLReadPixels(GLContext * arg1, GLint arg2, GLint arg3, GLsizei arg4, GLsizei arg5, GLenum arg6, GLenum arg7, GLvoid * arg8) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1180(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLReadPixels(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) __GLReadPixels((arg1), (arg2), (arg3), (arg4), (arg5), (arg6), (arg7), (arg8))

int __GLAReinitializeContextWindowed(GLContext * arg1, void * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1186(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLAReinitializeContextWindowed(arg1, arg2) __GLAReinitializeContextWindowed((arg1), (arg2))

int __GLIsTexture(GLContext * arg1, GLuint arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1192(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLIsTexture(arg1, arg2) __GLIsTexture((arg1), (arg2))

void __GLGetTexLevelParameteriv(GLContext   * arg1, GLenum arg2, GLint arg3, GLenum arg4, GLint * arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1198(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetTexLevelParameteriv(arg1, arg2, arg3, arg4, arg5) __GLGetTexLevelParameteriv((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLGetTexImage(GLContext * arg1, GLenum arg2, GLint arg3, GLint arg4, GLenum arg5, GLvoid   * arg6) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1204(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetTexImage(arg1, arg2, arg3, arg4, arg5, arg6) __GLGetTexImage((arg1), (arg2), (arg3), (arg4), (arg5), (arg6))

void __GLStencilFunc(GLContext * arg1, GLenum arg2, GLint arg3, GLuint arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1210(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLStencilFunc(arg1, arg2, arg3, arg4) __GLStencilFunc((arg1), (arg2), (arg3), (arg4))

void __GLStencilOp(GLContext * arg1, GLenum arg2, GLenum arg3, GLenum arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1216(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLStencilOp(arg1, arg2, arg3, arg4) __GLStencilOp((arg1), (arg2), (arg3), (arg4))

void __GLStencilMask(GLContext * arg1, GLuint arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1222(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLStencilMask(arg1, arg2) __GLStencilMask((arg1), (arg2))

void __GLClearStencil(GLContext * arg1, GLint arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1228(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLClearStencil(arg1, arg2) __GLClearStencil((arg1), (arg2))

void __GLADestroyContext(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1234(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLADestroyContext(arg1) __GLADestroyContext((arg1))

int __GLAInitializeContext(GLContext * arg1, struct TagItem * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1240(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLAInitializeContext(arg1, arg2) __GLAInitializeContext((arg1), (arg2))

void __GLGetLightfv(GLContext * arg1, GLenum arg2, GLenum arg3, GLfloat * arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1246(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetLightfv(arg1, arg2, arg3, arg4) __GLGetLightfv((arg1), (arg2), (arg3), (arg4))

void __GLReadBuffer(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1252(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLReadBuffer(arg1, arg2) __GLReadBuffer((arg1), (arg2))

GLenum __GLGetError(GLContext * arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1258(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLGetError(arg1) __GLGetError((arg1))

void __GLTexCoord2iv(GLContext * arg1, const GLint * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1264(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexCoord2iv(arg1, arg2) __GLTexCoord2iv((arg1), (arg2))

void __GLClipPlane(GLContext * arg1, GLenum arg2, GLdouble arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1270(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLClipPlane(arg1, arg2, arg3) __GLClipPlane((arg1), (arg2), (arg3))

void __GLTexCoord3f(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1276(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLTexCoord3f(arg1, arg2, arg3, arg4) __GLTexCoord3f((arg1), (arg2), (arg3), (arg4))

void __GLColorMask(GLContext * arg1, GLboolean arg2, GLboolean arg3, GLboolean arg4, GLboolean arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1282(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLColorMask(arg1, arg2, arg3, arg4, arg5) __GLColorMask((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLMultiTexCoord3fARB(GLContext * arg1, GLenum arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1288(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMultiTexCoord3fARB(arg1, arg2, arg3, arg4, arg5) __GLMultiTexCoord3fARB((arg1), (arg2), (arg3), (arg4), (arg5))

void __GLMultiTexCoord3fvARB(GLContext * arg1, GLenum arg2, const GLfloat * arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1294(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLMultiTexCoord3fvARB(arg1, arg2, arg3) __GLMultiTexCoord3fvARB((arg1), (arg2), (arg3))

void __GLDrawPixels(GLContext * arg1, GLsizei arg2, GLsizei arg3, GLenum arg4, GLenum arg5, const GLvoid * arg6) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1300(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDrawPixels(arg1, arg2, arg3, arg4, arg5, arg6) __GLDrawPixels((arg1), (arg2), (arg3), (arg4), (arg5), (arg6))

void __GLRasterPos2fv(GLContext * arg1, GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1306(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRasterPos2fv(arg1, arg2) __GLRasterPos2fv((arg1), (arg2))

void __GLRasterPos3fv(GLContext * arg1, GLfloat * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1312(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLRasterPos3fv(arg1, arg2) __GLRasterPos3fv((arg1), (arg2))

void __GLNormal3sv(GLContext * arg1, const GLshort * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1318(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLNormal3sv(arg1, arg2) __GLNormal3sv((arg1), (arg2))

void __GLNormal3s(GLContext * arg1, const GLshort arg2, GLshort arg3, GLshort arg4) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1324(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLNormal3s(arg1, arg2, arg3, arg4) __GLNormal3s((arg1), (arg2), (arg3), (arg4))

void __GLPixelTransferi(GLContext * arg1, GLenum arg2, GLint arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1330(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPixelTransferi(arg1, arg2, arg3) __GLPixelTransferi((arg1), (arg2), (arg3))

void __GLPixelTransferf(GLContext * arg1, GLenum arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1336(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPixelTransferf(arg1, arg2, arg3) __GLPixelTransferf((arg1), (arg2), (arg3))

void __GLPixelZoom(GLContext * arg1, GLfloat arg2, GLfloat arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1342(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPixelZoom(arg1, arg2, arg3) __GLPixelZoom((arg1), (arg2), (arg3))

void __GLUPickMatrix(GLContext * arg1, GLfloat arg2, GLfloat arg3, GLfloat arg4, GLfloat arg5, GLint arg6) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1348(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLUPickMatrix(arg1, arg2, arg3, arg4, arg5, arg6) __GLUPickMatrix((arg1), (arg2), (arg3), (arg4), (arg5), (arg6))

void __GLDrawBuffer(GLContext * arg1, GLenum arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1354(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLDrawBuffer(arg1, arg2) __GLDrawBuffer((arg1), (arg2))

void __GLNormal3dv(GLContext * arg1, const GLdouble * arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1360(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLNormal3dv(arg1, arg2) __GLNormal3dv((arg1), (arg2))

void __GLPushClientAttrib(GLContext * arg1, GLbitfield arg2) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1366(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPushClientAttrib(arg1, arg2) __GLPushClientAttrib((arg1), (arg2))

void __GLPopClientAttrib(GLContext* arg1) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1372(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLPopClientAttrib(arg1) __GLPopClientAttrib((arg1))

void __GLLineStipple(GLContext * arg1, GLint arg2, GLushort arg3) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1378(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLLineStipple(arg1, arg2, arg3) __GLLineStipple((arg1), (arg2), (arg3))

void __GLCopyPixels(GLContext * arg1, GLint arg2, GLint arg3, GLsizei arg4, GLsizei arg5, GLenum arg6) =
	"\tlis\t11,TinyGLBase@ha\n"
	"\tlwz\t12,TinyGLBase@l(11)\n"
	"\tlwz\t0,-1384(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GLCopyPixels(arg1, arg2, arg3, arg4, arg5, arg6) __GLCopyPixels((arg1), (arg2), (arg3), (arg4), (arg5), (arg6))

#endif /*  _VBCCINLINE_TINYGL_H  */
