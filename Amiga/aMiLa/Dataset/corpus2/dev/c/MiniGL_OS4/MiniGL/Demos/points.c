/*
 * Points demo
 * Demonstrates the use of points to "simulate" snow
 */

#include <GL/glut.h>
#include <GL/gl.h>
#ifdef WIN32
#include <GL/glu.h>
#endif

#include <stdlib.h>

static float random(float max)
{
	float res = (float)rand() / (float)RAND_MAX;
	return res*max;
}

typedef struct
{
	float x,y,z;
	float vel;
	int floorcnt;
} PointRec;

#define NUM_POINTS 4000
#define FLOORCNT_INIT 200

PointRec Points[NUM_POINTS];

void initPoint(int i)
{
	Points[i].x = random(20.0f) - 10.0f;
	Points[i].z = random(20.0f) - 10.0f;
	
	Points[i].y = random(5.0f) + 3.0f;
	
	Points[i].vel = random(0.01f);
	Points[i].floorcnt = FLOORCNT_INIT;
}

void initPoints(void)
{
	int i;
	for (i=0; i<NUM_POINTS; i++)
	{
		initPoint(i);
	}
}

void updatePoints(void)
{
	int i;
	for (i=0; i<NUM_POINTS; i++)
	{
		// Check if the point is still falling
		if (Points[i].vel != 0.0f)
		{
			Points[i].y -= Points[i].vel;
			if (Points[i].y <= 0.0f)
			{
				// Reached the floor
				Points[i].vel = 0.0f;
			}
		}
		else
		// On the ground
		{
			// Let it melt
			Points[i].floorcnt--;
			if (Points[i].floorcnt == 0)
			{
				// Make a new point
				initPoint(i);
			}
		}
	}
}

void drawPoints(void)
{
	int i;
	glBegin(GL_POINTS);
	glColor3f(1.0, 1.0, 1.0);
	for (i=0; i<NUM_POINTS; i++)
	{
		glVertex3f(Points[i].x, Points[i].y, Points[i].z);
	}
	glEnd();
}
			

/* GLUT callback Handlers */

static void 
resize(int width, int height)
{
    const GLdouble ar = (GLdouble) width / (GLdouble) height;
    
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

	gluPerspective(90.0, ar, 0.1, 100.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity() ;
    gluLookAt(0.0, 6.0, 8.0,
    	0.0, 0.0, 0.0,
    	0.0, 1.0, 0.0);
}

static void 
display(void)
{
	updatePoints();
	glClear(GL_COLOR_BUFFER_BIT);

	glBegin(GL_QUADS);
		glColor3f(0.2f, 0.2f, 0.2f);
		glVertex3f(-10.0f, 0.0f, -10.0f);
		glVertex3f(-10.0f, 0.0f, 10.0f);
		glVertex3f(10.0f, 0.0f, 10.0f);
		glVertex3f(10.0f, 0.0f, -10.0f);
	
	glEnd();

	drawPoints();

    glutSwapBuffers();
}


static void 
key(unsigned char key, int x, int y)
{
    switch (key) 
    {
        case 27 : 
        case 'q':
            exit(0);
            break;

    }

    glutPostRedisplay();
}

static void 
idle(void)
{
    glutPostRedisplay();
}


/* Program entry point */

int 
main(int argc, char *argv[])
{
    glutInit(&argc, argv);
    glutInitWindowSize(640,480);
    glutInitWindowPosition(10,10);
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);

    glutCreateWindow("Points Demo");

    glutReshapeFunc(resize);
    glutDisplayFunc(display);
    glutKeyboardFunc(key);
    glutIdleFunc(idle);

    glClearColor(0,0,0,0);

	initPoints();

    glutMainLoop();

    return EXIT_SUCCESS;
}

