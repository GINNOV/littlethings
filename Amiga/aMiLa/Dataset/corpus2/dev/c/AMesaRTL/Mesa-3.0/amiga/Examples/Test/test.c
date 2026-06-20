
/*
 * test.c
 *
 * Version 1.0  28 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Test some Amiga GLUT functionality
 * Based on cube.c redbook example
 *
 */

#include <gl/glut.h>

#include <stdlib.h>
#include <stdio.h>


int rotx,roty;

void init(void)
{
	glClearColor (0.0, 0.0, 0.0, 0.0);
	glShadeModel (GL_FLAT);
	rotx = roty = 0;
}


void display(void)
{
	printf("Displaying\n");
	glClear (GL_COLOR_BUFFER_BIT);
	glColor3f (1.0, 0.0, 0.0);
	glLoadIdentity ();				/* clear the matrix */
		/* viewing transformation  */
	gluLookAt (0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
	glRotatef(rotx, 1.0, 0.0, 0.0);
	glRotatef(roty, 0.0, 1.0, 0.0);
	glScalef (1.0, 2.0, 1.0);		/* modeling transformation */
	glutWireCube (1.5);
	glRotatef(30.0,0.0,1.0,0.0);
	glColor3f (0.0, 1.0, 0.0);
	glutWireCube (1.0);
	glRotatef(30.0,1.0,0.0,0.0);
	glColor3f (0.0, 0.0, 1.0);
	glutWireCube (0.5);
	glFlush ();
	printf("Displayed\n");
}


void reshape (int w, int h)
{
	printf("Reshaping to %d %d\n",w,h);
	glViewport (0, 0, (GLsizei) w, (GLsizei) h);
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity ();
	glFrustum (-1.0, 1.0, -1.0, 1.0, 1.5, 20.0);
	glMatrixMode (GL_MODELVIEW);
	printf("Reshaped\n");
}


void special(int key, int x, int y)
{
	switch(key) {
		case GLUT_KEY_UP:
			rotx += 5.0;
			break;
		case GLUT_KEY_DOWN:
			rotx -= 5.0;
			break;
		case GLUT_KEY_LEFT:
			roty += 5.0;
			break;
		case GLUT_KEY_RIGHT:
			roty -= 5.0;
			break;
		default:
			return;
	}

	glutPostRedisplay();
}


void keyboard(unsigned char key, int x, int y)
{
	printf("Got keypress %d (%c) at (%d,%d)\n",key,key,x,y);
	switch(key)
	{
		case 27:
			exit(0);
			break;
	}
}


void menu(int value)
{
	printf("Got menu value %d\n",value);

	if(value == 999)
		exit(0);
}


void setupmenus(void)
{
	int m1,m2,m3;

	m1 = glutCreateMenu(menu);
	glutAddMenuEntry("Entry 1",1);
	m2 = glutCreateMenu(menu);
	glutAddMenuEntry("Sub Entry 1",11);
	glutAddMenuEntry("Sub Entry 2",12);
	glutAddMenuEntry("Sub Entry 3",13);
	glutSetMenu(m1);
	glutAddSubMenu("Sub Menu",m2);
	glutAddMenuEntry("Entry 3",3);
	m3 = glutCreateMenu(menu);
	glutAddMenuEntry("Sub Sub Entry 1",111);
	glutAddMenuEntry("Sub Sub Entry 2",112);
	glutAddMenuEntry("Sub Sub Entry 3",113);
	glutSetMenu(m2);
	glutChangeToSubMenu(2,"Sub Sub Menu", m3);
	glutSetMenu(m1);
	glutAttachMenu(GLUT_RIGHT_BUTTON);

	glutCreateMenu(menu);
	glutAddMenuEntry("Quit",999);
	glutAttachMenu(GLUT_LEFT_BUTTON);
}


int main(int argc, char *argv[])
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
	glutInitWindowSize(200,200);
	glutInitWindowPosition(100,100);
	glutCreateWindow("Test");
	init();
	glutDisplayFunc(display);
	glutReshapeFunc(reshape);
	glutKeyboardFunc(keyboard);
	glutSpecialFunc(special);
	setupmenus();

	glutMainLoop();

	return(EXIT_SUCCESS);
}
