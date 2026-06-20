/*
 * Lines demo
 * Demonstrates the use of Lines to "simulate" snow
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
} Line;

#define NUM_LINES 4000

Line Lines[NUM_LINES];

void initLine(int i)
{
	Lines[i].x = random(20.0f) - 10.0f;
	Lines[i].z = random(20.0f) - 10.0f;
	
	Lines[i].y = random(5.0f) + 3.0f;
	
	Lines[i].vel = 0.1;
}

void initLines(void)
{
	int i;
	for (i=0; i<NUM_LINES; i++)
	{
		initLine(i);
	}
}

void updateLines(void)
{
	int i;
	for (i=0; i<NUM_LINES; i++)
	{
		// Check if the Line is still falling
		if (Lines[i].vel != 0.0f)
		{
			Lines[i].y -= Lines[i].vel;
			if (Lines[i].y <= 0.0f)
			{
				// Reached the floor
				Lines[i].vel = 0.0f;
			}
		}
		else
		// On the ground
		{
			// Make a new Line
			initLine(i);
		}
	}
}

void drawLines(void)
{
	int i;
	glBegin(GL_LINES);
	glColor3f(0.4, 1.0, 1.0);
	for (i=0; i<NUM_LINES; i++)
	{
		glVertex3f(Lines[i].x, Lines[i].y, Lines[i].z);
		glVertex3f(Lines[i].x, Lines[i].y-Lines[i].vel, Lines[i].z);
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
	updateLines();
	glClear(GL_COLOR_BUFFER_BIT);

	glBegin(GL_QUADS);
		glColor3f(0.1f, 0.1f, 0.4f);
		glVertex3f(-10.0f, 0.0f, -10.0f);
		glVertex3f(-10.0f, 0.0f, 10.0f);
		glVertex3f(10.0f, 0.0f, 10.0f);
		glVertex3f(10.0f, 0.0f, -10.0f);
	
	glEnd();

	drawLines();

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



/* Program entry Line */

int 
main(int argc, char *argv[])
{
    glutInit(&argc, argv);
    glutInitWindowSize(640,480);
    glutInitWindowPosition(10,10);
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);

    glutCreateWindow("Lines Demo");

    glutReshapeFunc(resize);
    glutDisplayFunc(display);
    glutKeyboardFunc(key);
    glutIdleFunc(idle);

    glClearColor(0,0,0,0);

	initLines();

    glutMainLoop();

    return EXIT_SUCCESS;
}

