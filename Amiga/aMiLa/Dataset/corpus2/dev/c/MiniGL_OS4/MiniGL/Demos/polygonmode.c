#include <stdlib.h>
#include <GL/glut.h>
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

GLint width, height;
GLboolean drawPoly = GL_FALSE;
GLfloat angle = 0.0f;

void myinit(void)
{
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	glFrontFace(GL_CCW);
}

void display(void)
{
	//float angle = glutGet(GLUT_ELAPSED_TIME);
	//angle /= 10.0f;
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glPushMatrix();
	glRotatef(angle, 0.0f, 1.0f, 0.0f);
	
	
	
	if (drawPoly)
		glBegin(GL_POLYGON);
	else
		glBegin(GL_TRIANGLES);
	
		glColor3f(1.0f, 0.0f, 0.0f);
		glVertex3f(-3.0f, 0.0f, 0.0f);
		
		glColor3f(1.0f, 1.0f, 1.0f);
		glVertex3f(3.0f, 0.0f, 0.0f);
		glVertex3f(0.0f, 3.0f, 0.0f);
		
	glEnd();
	glPopMatrix();
    glutSwapBuffers();
    glFlush();
}

void myReshape(int w, int h)
{
	width = w;
	height = h;
	
    const GLdouble ar = (GLdouble) width / (GLdouble) height;
    
    glViewport(0, 0, w, h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

	gluPerspective(90.0, ar, 0.1, 100.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity() ;
    gluLookAt(0.0, 0.0, 4.0,
    	0.0, 0.0, 0.0,
    	0.0, 1.0, 0.0);
}

static void
key(unsigned char k, int x, int y)
{
	static GLboolean cull = GL_FALSE;
  	switch (k) {
  	case 27:  /* Escape */
    	exit(0);
    	break;
    case 'q':
    	glPolygonMode(GL_FRONT, GL_POINT);
    	break;
    case 'w':
    	glPolygonMode(GL_FRONT, GL_LINE);
    	break;
    case 'e':
    	glPolygonMode(GL_FRONT, GL_FILL);
    	break;
    case 'a':
    	glPolygonMode(GL_BACK, GL_POINT);
    	break;
    case 's':
    	glPolygonMode(GL_BACK, GL_LINE);
    	break;
    case 'd':
    	glPolygonMode(GL_BACK, GL_FILL);
    	break;
    case 'p':
    	drawPoly = !drawPoly;
    	break;
    case '1':
    	angle -= 1.0f;
    	break;
    case '2':
    	angle += 1.0f;
    	break;
    case 'c':
    	cull = !cull;
    	if (cull == GL_TRUE)
    	{
    		glEnable(GL_CULL_FACE);
    		glCullFace(GL_BACK);
    	}
    	else
    	{
    		glDisable(GL_CULL_FACE);
    	}
    	break;
  	default:
    	return;
  }
  glutPostRedisplay();
}

void idle(void)
{
	glutPostRedisplay();
}

int main(int argc, char** argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize (500, 500);
    glutCreateWindow (argv[0]);

    myinit();
    glutReshapeFunc (myReshape);
    glutDisplayFunc(display);
    glutKeyboardFunc(key);
    glutIdleFunc(idle);
    glutMainLoop();
    return 0;             /* ANSI C requires main to return int. */
}
