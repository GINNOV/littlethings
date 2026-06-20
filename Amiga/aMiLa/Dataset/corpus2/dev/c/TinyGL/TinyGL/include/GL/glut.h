#ifndef GLUT_H
#define GLUT_H


#include <GL/gl.h>
#include <GL/glu.h>

#ifdef __cplusplus
extern "C" {
#endif


/* Display mode bit masks. */
#define GLUT_RGB        0
#define GLUT_RGBA       GLUT_RGB
#define GLUT_INDEX         1
#define GLUT_SINGLE        0
#define GLUT_DOUBLE        2
#define GLUT_ACCUM         4
#define GLUT_ALPHA         8
#define GLUT_DEPTH         16
#define GLUT_STENCIL       32
#define GLUT_MULTISAMPLE   128
#define GLUT_STEREO        256
#define GLUT_LUMINANCE     512

/* glutGet parameters. */
#define GLUT_WINDOW_X         100
#define GLUT_WINDOW_Y         101
#define GLUT_WINDOW_WIDTH     102
#define GLUT_WINDOW_HEIGHT    103
#define GLUT_WINDOW_DEPTH_SIZE      106
#define GLUT_WINDOW_DOUBLEBUFFER 115
#define GLUT_WINDOW_PARENT    117
#define GLUT_WINDOW_NUM_CHILDREN 118
#define GLUT_SCREEN_WIDTH     200
#define GLUT_SCREEN_HEIGHT    201
#define GLUT_SCREEN_WIDTH_MM     202
#define GLUT_SCREEN_HEIGHT_MM    203
#define GLUT_INIT_WINDOW_X    500
#define GLUT_INIT_WINDOW_Y    501
#define GLUT_INIT_WINDOW_WIDTH      502
#define GLUT_INIT_WINDOW_HEIGHT     503
#define GLUT_ELAPSED_TIME     700


/* API Calls */

void glutInit(int *argcp, char **argv);

void glutInitWindowPosition(int x, int y);

void glutInitWindowSize(int width, int height);

int glutCreateWindow(char *name);

void glutFullScreen(void);

void glutSetWindow(int win);

int glutGetWindow(void);

void glutDestroyWindow(int win);

void glutSwapBuffers(void);

void glutMainLoop(void);

void glutPostRedisplay(void);

void glutDisplayFunc(void (*func)(void));

void glutReshapeFunc(void (*func)(int width, int height));

void glutIdleFunc(void (*func)(void));

void glutKeyboardFunc(void (*func)(unsigned char key, int x, int y));

int glutGet(GLenum state);





//////////// Not implemented


void glutInitDisplayMode(unsigned int mode);


#ifdef __cplusplus
}
#endif

#endif
