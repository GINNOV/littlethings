#ifndef _GLUT_H_
#define _GLUT_H_

#include <stdlib.h>

extern struct GlutIFace *__glut_current_context;

MGLAPI void glutInit(int *argc, char **argv)
{
	__glut_current_context->GLUTInit(argc, argv);
}

MGLAPI void glutInitWindowSize(int width, int height)
{
	__glut_current_context->GLUTInitWindowSize(width, height);
}

MGLAPI void glutInitWindowPosition(int x, int y)
{
	__glut_current_context->GLUTInitWindowPosition(x, y);
}

MGLAPI void glutInitDisplayMode(unsigned int mode)
{
	__glut_current_context->GLUTInitDisplayMode(mode);
}

MGLAPI int glutCreateWindow(char *name)
{
	int res;
	GLUTcontext ctx = (GLUTcontext)GET_INSTANCE(__glut_current_context);
	
	res = __glut_current_context->GLUTCreateWindow(name);
	if (res == -1)
		exit(0);
	
	mglMakeCurrent(ctx->__glutContext);

	return res;
}

MGLAPI void glutDestroyWindow(int window)
{
	__glut_current_context->GLUTDestroyWindow(window);
}

MGLAPI void glutPostRedisplay(void)
{
	__glut_current_context->GLUTPostRedisplay();
}

MGLAPI void glutSwapBuffers(void)
{
	__glut_current_context->GLUTSwapBuffers();
}

MGLAPI void glutPositionWindow(int x, int y)
{
	__glut_current_context->GLUTPositionWindow(x, y);
}

MGLAPI void glutReshapeWindow(int width, int height)
{
	__glut_current_context->GLUTReshapeWindow(width, height);
}

MGLAPI void glutFullScreen(void)
{
	__glut_current_context->GLUTFullScreen();
}

MGLAPI void glutPushWindow(void)
{
	__glut_current_context->GLUTPushWindow();
}

MGLAPI void glutPopWindow(void)
{
	__glut_current_context->GLUTPopWindow();
}

MGLAPI void glutShowWindow()
{
	__glut_current_context->GLUTShowWindow();
}

MGLAPI void glutHideWindow()
{
	__glut_current_context->GLUTHideWindow();
}

MGLAPI void glutIconifyWindow()
{
	__glut_current_context->GLUTIconifyWindow();
}

MGLAPI void glutSetWindowTitle(char *name)
{
	__glut_current_context->GLUTSetWindowTitle(name);
}

MGLAPI void glutSetIconTitle(char *name)
{
	__glut_current_context->GLUTSetIconTitle(name);
}

MGLAPI void glutMainLoop(void)
{
	__glut_current_context->GLUTMainLoop();
}

MGLAPI void glutDisplayFunc(void (*func)(void))
{
	__glut_current_context->GLUTDisplayFunc(func);
}

MGLAPI void glutReshapeFunc(void (*func)(int width, int height))
{
	__glut_current_context->GLUTReshapeFunc(func);
}

MGLAPI void glutKeyboardFunc(void (*func)(unsigned char key, int x, int y))
{
	__glut_current_context->GLUTKeyboardFunc(func);
}

MGLAPI void glutMouseFunc(void (*func)(int button, int state, int x, int y))
{
	__glut_current_context->GLUTMouseFunc(func);
}

MGLAPI void glutMotionFunc(void (*func)(int x, int y))
{
	__glut_current_context->GLUTMotionFunc(func);
}

MGLAPI void glutPassiveMotionFunc(void (*func)(int x, int y))
{
	__glut_current_context->GLUTPassiveMotionFunc(func);
}

MGLAPI void glutVisibilityFunc(void (*func)(int state))
{
	__glut_current_context->GLUTVisibilityFunc(func);
}

MGLAPI void glutEntryFunc(void (*func)(int state))
{
	__glut_current_context->GLUTEntryFunc(func);
}

MGLAPI void glutSpecialFunc(void (*func)(int key, int x, int y))
{
	__glut_current_context->GLUTSpecialFunc(func);
}

MGLAPI void glutIdleFunc(void (*func)(void))
{
	__glut_current_context->GLUTIdleFunc(func);
}

MGLAPI int glutGet(GLenum state)
{
	return __glut_current_context->GLUTGet(state);
}
#endif //_GLUT_H_
