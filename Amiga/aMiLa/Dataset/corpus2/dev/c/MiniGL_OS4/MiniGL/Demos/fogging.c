#include <stdlib.h>
#ifdef WIN32
#include <GL/openglut.h>
#else
#include <GL/glut.h>
#endif
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __amigaos4__
#include <proto/intuition.h>
#include <proto/graphics.h>

struct Window *_infoWin;
#endif

GLboolean fogging = GL_TRUE;
GLenum fog_mode = GL_LINEAR;
GLfloat fog_start = 4.0f;
GLfloat fog_end = 10.0f;
GLfloat fog_density = 0.04f;
GLfloat width,height;
GLboolean simple_ground = GL_FALSE;
GLfloat angularSpeed = 0.1f;
GLboolean rotating = GL_TRUE;

GLint faces[6][4] = {  /* Vertex indices for the 6 faces of a cube. */
  {0, 1, 2, 3}, {3, 2, 6, 7}, {7, 6, 5, 4},
  {4, 5, 1, 0}, {5, 6, 2, 1}, {7, 4, 0, 3} };
GLfloat v[8][3];  /* Will be filled in with X,Y,Z vertexes. */

void myReshape(int,int);

void
drawBox(void)
{
  	int i;

	glPushMatrix();
	glScalef(0.2, 3.0, 0.2);
  	for (i = 0; i < 6; i++) 
  	{
		glEnableClientState(GL_VERTEX_ARRAY);
    	glVertexPointer(3, GL_FLOAT, 0, v);
		//glColor3fv(&colors[i][0]);
    	glDrawElements(GL_QUADS, 4, GL_UNSIGNED_INT, faces[i]);
  	}
  	glPopMatrix();
}

#if 1
#if defined(__amigaos4__)
void ShowParams(void)
{
	_infoWin = mglGetWindowHandle();
	if (!_infoWin) return;
	static int xx = 0;
	
	xx++; if (xx < 10) return;

	xx = 0;
	static char buffer[256];
	sprintf(buffer, "MODE: %s s: %4.2f e: %4.2f d: %4.2f",
		fog_mode == GL_LINEAR ? "GL_LINEAR" :
		fog_mode == GL_EXP ? "GL_EXP" :
		fog_mode == GL_EXP2 ? "GL_EXP2" :
			"Unknown",
		fog_start, fog_end, fog_density);
	IGraphics->Move(_infoWin->RPort, 10, _infoWin->Height - _infoWin->BorderBottom - 10);
	IGraphics->Text(_infoWin->RPort, buffer, strlen(buffer));
}
#else
void ShowParams(void)
{
	char buffer[256], *c;
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	gluOrtho2D(0, width, height, 0);
	
	
	glDisable(GL_FOG);
	glRasterPos2f(10, 10);
	
	sprintf(buffer, "MODE: %s s: %f e: %f d: %f c:%s",
		fog_mode == GL_LINEAR ? "GL_LINEAR" :
		fog_mode == GL_EXP ? "GL_EXP" :
		fog_mode == GL_EXP2 ? "GL_EXP2" :
			"Unknown",
		fog_start, fog_end, fog_density,
		simple_ground == GL_TRUE ? "N" : "Y");
	
	for (c=buffer; *c; c++)
		glutBitmapCharacter(GLUT_BITMAP_8_BY_13, *c);
	
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();
	if (fogging) glEnable(GL_FOG);
}
#endif
#endif

#define GROUND_W 30
#define GROUND_H 30
#define GROUND_STEP 3.0f

typedef struct
{
	GLfloat x,y,z;
	GLfloat r,g,b;
} Vertex;

Vertex vertexArray[GROUND_W*GROUND_H];
#define Vi(x,y) (y*GROUND_W+x)
#define V(x,y) vertexArray[Vi(x,y)]

GLuint indexArrays[(GROUND_H-1)][GROUND_W*2];

void myinit(void)
{

	GLfloat fogcolor[]  = {0.1f, 0.1f, 0.1f, 1.0f};
 	glEnable(GL_DEPTH_TEST);
	//glShadeModel(GL_FLAT);
 	glClearColor(fogcolor[0], fogcolor[1], fogcolor[2], fogcolor[3]);

	glColor3f(1.0f, 1.0f, 1.0f);
	
	glFogi(GL_FOG_MODE,     fog_mode);
	glFogf(GL_FOG_START,    fog_start);
	glFogf(GL_FOG_END,	    fog_end);
	glFogf(GL_FOG_DENSITY,  fog_density);
	glFogfv(GL_FOG_COLOR,   fogcolor);
	if (fogging) glEnable(GL_FOG);
	
	int index = 0;
	// Initialize the vertex array for the ground
	for (int x=0; x<GROUND_W; x++)
	{
		for (int y=0; y<GROUND_H; y++)
		{
			vertexArray[index].x = (x-GROUND_W/2)*GROUND_STEP;
			vertexArray[index].y = (x & 1) * (y & 1);
			vertexArray[index].z = (y-GROUND_H/2)*GROUND_STEP;
			vertexArray[index].r = ((x & 1) * (y & 1))*0.5 + 0.5;
			vertexArray[index].g = ((x & 1) * (y & 1))*0.5 + 0.5;
			vertexArray[index].b = ((x & 1) * (y & 1))*0.5 + 0.5;
			index++;
		}
	}

	// Initialize the index arrays for the triangle strips
	for (int strip=0; strip<GROUND_H-1; strip++)
	{
		int base_index = GROUND_W * strip;
		for (int index = 0; index < GROUND_W; index++)
		{
			indexArrays[strip][2*index] = base_index + index;
			indexArrays[strip][2*index+1] = base_index + GROUND_W + index;
		}
	}
	
  	/* Setup cube vertex data. */
  	v[0][0] = v[1][0] = v[2][0] = v[3][0] = -1;
  	v[4][0] = v[5][0] = v[6][0] = v[7][0] = 1;
  	v[0][1] = v[1][1] = v[4][1] = v[5][1] = -1;
  	v[2][1] = v[3][1] = v[6][1] = v[7][1] = 1;
  	v[0][2] = v[3][2] = v[4][2] = v[7][2] = 1;
  	v[1][2] = v[2][2] = v[5][2] = v[6][2] = -1;
}

void
drawColumns(void)
{
	glPushMatrix();

	glTranslatef(8.0f, 0.0f, 1.0f);
	for (int i=0; i<8; i++)
	{
		glTranslatef(-2.0f, 0.0f, 0.0f);
		drawBox();
	}
	
	glPopMatrix();
}

void display(void)
{
	static GLfloat angle = 0.0f;
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glPushMatrix();
	glRotatef(angle, 0.0f, 1.0f, 0.0f);
	if (rotating) angle += angularSpeed;
	
	glColor3f(1.0f, 1.0f, 1.0f);
	if (!simple_ground)
	{
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glVertexPointer(3, GL_FLOAT, sizeof(Vertex), vertexArray);
		glColorPointer(3, GL_FLOAT, sizeof(Vertex), ((GLubyte *)vertexArray) + 3*sizeof(float));
		for (int strip = 0; strip < GROUND_H-1; strip ++)
		{
			glDrawElements(GL_TRIANGLE_STRIP, GROUND_W*2, GL_UNSIGNED_INT, 
				indexArrays[strip]);
		}
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
	}
	else
	{
		GLfloat w = (float)GROUND_W/2.0f * GROUND_STEP;
		glBegin(GL_QUADS);
			glVertex3f(-w, 0.0f, -w);
			glVertex3f(-w, 0.0f,  w);
			glVertex3f( w, 0.0f,  w);
			glVertex3f( w, 0.0f, -w);
		glEnd();
	}

	drawColumns();

	glPopMatrix();


	ShowParams();


    glutSwapBuffers();
    glFlush();

#if defined(__amigaos4__)
	ShowParams();
#endif
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
    gluLookAt(0.0, 2.0, 8.0,
    	0.0, 0.0, 0.0,
    	0.0, 1.0, 0.0);
}

static void
key(unsigned char k, int x, int y)
{
  	switch (k) {
  	case 27:  /* Escape */
    	exit(0);
    	break;
	case '7':
		fog_start += 0.2f;
		glFogf(GL_FOG_START, fog_start);
		break;
	case '4':
		fog_start -= 0.2f;
		glFogf(GL_FOG_START, fog_start);
		break;
	case '8':
		fog_end += 0.2f;
		glFogf(GL_FOG_END, fog_end);
		break;
	case '5':
		fog_end -= 0.2f;
		glFogf(GL_FOG_END, fog_end);
		break;
	case '9':
		fog_density += 0.01f;
		glFogf(GL_FOG_DENSITY, fog_density);
		break;
	case '6':
		fog_density -= 0.01f;
		if (fog_density <= 0.0f) fog_density = 0.0f;
		glFogf(GL_FOG_DENSITY, fog_density);
		break;
	case '0':
		if (fog_mode == GL_LINEAR) fog_mode = GL_EXP;
		else if (fog_mode == GL_EXP) fog_mode = GL_EXP2;
		else if (fog_mode == GL_EXP2) fog_mode = GL_LINEAR;
		glFogi(GL_FOG_MODE, fog_mode);
		break;
	case 'f':
		if (fogging) 
		{
			glDisable(GL_FOG);
			fogging = GL_FALSE;
		}
		else
		{
			glEnable(GL_FOG);
			fogging = GL_TRUE;
		}
		break;
	case 'g':
		simple_ground = !simple_ground;
		break;
	case '+':
		angularSpeed *= 2;
		break;
	case '-':
		angularSpeed /= 2;
		break;
	case ' ':
		rotating = !rotating;
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
    if (argc > 1) fogging = GL_FALSE;
    myinit();
    glutReshapeFunc (myReshape);
    glutDisplayFunc(display);
    glutKeyboardFunc(key);
    glutIdleFunc(idle);
    glutMainLoop();
    return 0;             /* ANSI C requires main to return int. */
}
