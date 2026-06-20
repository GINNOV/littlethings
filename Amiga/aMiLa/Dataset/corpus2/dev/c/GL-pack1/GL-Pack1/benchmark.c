/*
 * Drawing a triangle with time measurement
 *
 * It's an easy example because it only shows a coloured triangle but
 * it also introduces the glutGet(GLUT_ELAPSED_TIME) function, used
 * to measure speed (just have a look at other examples).
 *
 * Each triangle calculated is drawn in a single frame. So, you obtain
 * the speed in frames per second (FPS).
 * If you put glSwapBuffers into comments, you won't show anything but
 * you will obtain the amount of triangles the TinyGL engine is able
 * to compute in a second.
 */

#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>

#define NUM_TRIANGLES 300

static int glutWindow;


void init(void)	 {
	glEnable(GL_DEPTH_TEST);
	glShadeModel(GL_SMOOTH);
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
	int i;
	int etime;

	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

	for (i=0; i<NUM_TRIANGLES; i++) {
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
	glutDestroyWindow(glutWindow);

	etime = glutGet(GLUT_ELAPSED_TIME);
	printf("%d triangles drawn in %d ms\n", NUM_TRIANGLES, etime);
	printf("Speed = %d triangles per seconde\n", (int)(NUM_TRIANGLES*1000/etime));
	exit(0);
}


int main(int argc, char** argv)	{
	glutInit(&argc, argv);
	glutInitWindowSize(320, 240);
	glutInitWindowPosition(0, 0);
	glutWindow = glutCreateWindow("TinyGL speed test ... please wait");
	init();
	glutDisplayFunc(display);
	glutReshapeFunc(reshape);

	glutMainLoop();

	return 0 ;
}
