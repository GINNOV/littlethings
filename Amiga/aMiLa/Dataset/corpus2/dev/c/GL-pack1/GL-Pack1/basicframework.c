/*
 * Basic framework example. This simply opens an OpenGL window and adds 
 * an idle function, that simply redisplays the window
 *
 * This example doesn't draws anything but shows the very basics
 * for a TinyGL/OpenGL program.
 */

#include <stdio.h>
#include <stdlib.h>

/* This is the TinyGL standard GLUT header. glut.h already includes gl.h
 * and glu.h so there is no need to include those
 */
#include <GL/glut.h>

int glutWindow;

/* Some GL initializations. In this case, only setting the clear color to black */
void init(void)	 {
	glClearColor(0.0, 0.0, 0.0, 0.0) ;
}


/* The display function just clears the background
 * NOTE: Since our window is using a single buffer,
 * we don't need to call glutSwapBuffers here
 */
void display(void)	{
	glClear(GL_COLOR_BUFFER_BIT);
}


/* The idle function can be used for parts of code that don't depend
 * on user input (for example, automatic animations or sounds). In the end
 * we need to update the window contents.
 */
void idle() {
	glutPostRedisplay();
}


int main(int argc, char** argv)	{
	/* Some initilizations for GLUT and our window bounds */
	glutInit(&argc, argv);
	glutInitWindowSize(320, 240);
	glutInitWindowPosition(0, 0);
	glutWindow = glutCreateWindow("Basic OpenGL app") ;
	init();
	/* Registering the callback functions */
	glutDisplayFunc(display);
	glutIdleFunc(idle);
	/* Entering the GLUT main loop */
	glutMainLoop();

	return 0 ;
}
