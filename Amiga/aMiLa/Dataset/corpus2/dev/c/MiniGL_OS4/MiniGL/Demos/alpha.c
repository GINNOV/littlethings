#include <stdlib.h>
#include <GL/glut.h>


GLuint MakeTexture(void)
{
	int i, j;
	char *image = malloc(16*16);
	GLuint t;
	
	for (i = 0; i < 16; i++)
		for (j = 0; j < 16; j++)		
			image[i*16+j] = i*j;

	glGenTextures(1, &t);
	glBindTexture(GL_TEXTURE_2D, t);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, 16, 16, 0, GL_ALPHA,
		GL_UNSIGNED_BYTE, image);

	
	return t;
}


void display (void)
{
	glClearColor(0.2, 0.2, 0.2, 0.0);
    glClear (GL_COLOR_BUFFER_BIT);

	glColor4f(1.0, 1.0, 1.0, 1.0);
	
    glBegin (GL_QUADS);
    	glTexCoord2f(0.0, 0.0);
	    glVertex3f (-1.0, -1.0, 0.0);
	    
	    glTexCoord2f(1.0, 0.0);
	    glVertex3f (1.0, -1.0, 0.0);
	    
	    glTexCoord2f(1.0, 1.0);
	    glVertex3f (1.0, 1.0, 0.0);
	    
	    glTexCoord2f(1.0, 0.0);
	    glVertex3f (-1.0, 1.0, 0.0);
    glEnd();
    
}
void myReshape(int w, int h)
{
    glViewport (0, 0, w, h);
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity ();

	glOrtho (-1.5, 1.5, -1.5*(GLdouble)h/(GLdouble)w,
	    1.5*(GLdouble)h/(GLdouble)w, -10.0, 10.0);
    glMatrixMode (GL_MODELVIEW);
}

static void
key(unsigned char k, int x, int y)
{
  switch (k) {
  case 27:  /* Escape */
    exit(0);
    break;
  case '1':
	glShadeModel(GL_SMOOTH);
  	break;
  case '2':
	glShadeModel(GL_FLAT);
  	break;
  }
  glutPostRedisplay();
}

/*  Main Loop
 *  Open window with initial window size, title bar,
 *  RGBA display mode, and handle input events.
 */
int main(int argc, char** argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode (GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize (400, 400);
    glutCreateWindow (argv[0]);
    glutReshapeFunc (myReshape);
    glutDisplayFunc(display);
    glutKeyboardFunc(key);
    MakeTexture();
    glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
    glutMainLoop();
    return 0;             /* ANSI C requires main to return int. */
}