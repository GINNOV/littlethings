/*************************************
*  Drawing a triangle
*
************/

#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>


int glutWindow;


void init(void)	 {
	glEnable(GL_DEPTH_TEST);
	glShadeModel(GL_FLAT);
	glClearColor(0.0, 0.0, 0.0, 0.0) ;
}


void reshape(int width, int height) {
	glViewport(0, 0, (GLint) width, (GLint) height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glFrustum(-2.0, 2.0, -2.0, 2.0, 6.0, 20.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslatef(0.0, 0.0, -8.0);
}


void display(void)	{
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	glPushMatrix();
	glTranslatef(-1.0, 0.0, 0.0);
	glRotatef(0, 0.0, 0.0, 1.0);
	glBegin(GL_TRIANGLES);
		glColor3f(1.0f, 0.0f, 0.0f);
		glVertex2f(0, -0.5);
		glColor3f(0.0f, 1.0f, 0.0f);
		glVertex2f(1.0, 1.0);
		glColor3f(0.0f, 0.0f, 1.0f);
		glVertex2f(-1.0, 1.0);
	glEnd();
	glPopMatrix();
	
	glutSwapBuffers();
}


void idle() {
	glutPostRedisplay();
}


int main(int argc, char** argv)	{
	glutInit(&argc, argv);
	glutInitWindowSize(320, 240);
	glutInitWindowPosition(0, 0);
	glutWindow = glutCreateWindow("OpenGL triangle");
	init();
	glutDisplayFunc(display);
	glutReshapeFunc(reshape);
	glutIdleFunc(idle);
	glutMainLoop();

	return 0 ;
}
