#ifndef GLU_H
#define GLU_H


#include <GL/gl.h>


#ifdef __cplusplus
extern "C" {
#endif


void gluLookAt(GLdouble eyex, GLdouble eyey, GLdouble eyez,
					GLdouble centerx, GLdouble centery, GLdouble centerz,
					GLdouble upx, GLdouble upy, GLdouble upz);
void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat znear, GLfloat zfar);


#ifdef __cplusplus
}
#endif


#endif
