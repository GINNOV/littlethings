#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <GL/glut.h>
#include <exec/exec.h>
#include <dos/dos.h>
#include <proto/dos.h>

#define COS(X)   cos( (X) * 3.14159/180.0 )
#define SIN(X)   sin( (X) * 3.14159/180.0 )

#define RED 1
#define WHITE 2
#define CYAN 3

#define NUMSLICE 8.0

GLboolean IndexMode = GL_FALSE;
GLuint Ball;
GLenum Mode;
GLfloat Zrot = 0.0, Zstep = 3.0;
GLfloat Xpos = 0.0, Ypos = 1.0;
GLfloat Xvel = 0.2, Yvel = 0.0;
GLfloat Xmin = -4.0, Xmax = 4.0;
GLfloat Ymin = -2.8, Ymax = 4.0;
GLfloat G = -0.05;
GLfloat rot = 0.0;
GLfloat step = 0.0;
GLboolean do_cage = GL_FALSE;
GLboolean bounce = GL_TRUE;

typedef struct
{
	GLint command;
	GLfloat p1, p2, p3;
} GL_Command;

#define GLC_VERTEX 1
#define GLC_COLOR  2
#define GLC_BEGIN  3
#define GLC_END    4
#define GLC_FINISH 5

GL_Command cmd[150000];
int cmdptr=0;


GLubyte *LoadPPM(char *name, GLint *w, GLint *h)
{
	int i;
	unsigned long x,y;
	FILE *f;
	GLubyte *where;

	f = fopen(name, "r");

	if (!f)
	{
		*w = 0; *h=0;
		return NULL;
	}
	#ifndef __STORM__
	i = fscanf(f, "P6\n%ld %ld\n255\n",&x, &y);
	#else
	i = fscanf(f, "P6\n%ld\n%ld\n255\n", &x, &y);
	#endif

	if (i!= 2)
	{
		printf("Error scanning PPM header\n");
		fclose(f);
		*w = 0; *h = 0;
		return NULL;
	}

	*w = x;
	*h = y;

	where = malloc(x*y*3);
	if (!where)
	{
		printf("Error out of Memory\n");
		fclose(f);
		*w = 0; *h = 0;
		return NULL;
	}

	i = fread(where, 1, x*y*3, f);
	fclose(f);

	if (i != x*y*3)
	{
		printf("Error while reading file\n");
		free(where);
		*w = 0; *h = 0;
		return NULL;
	}

	return where;
}


BOOL TexInit(char *name)
{
	GLubyte *tmap;
	GLint x,y;

	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glPixelStorei(GL_PACK_ALIGNMENT, 1);

	if (!name)
	{
		tmap = LoadPPM("data/chrome.ppm",&x, &y);
	}
	else
	{
		tmap = LoadPPM(name, &x, &y);
	}

	if (!tmap)
		return FALSE;

	glBindTexture(GL_TEXTURE_2D, 1);
	glTexImage2D(GL_TEXTURE_2D, 0, 3,
		x,y, 0, GL_RGB, GL_UNSIGNED_BYTE, tmap);
	free(tmap);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_TEXTURE_GEN_S);
	glEnable(GL_TEXTURE_GEN_T);
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

	return TRUE;
}


static GLuint make_ball(void)
{
	GLuint list = 0;
	GLfloat a, b;
	GLfloat da = 180.0/NUMSLICE, db = 180.0/NUMSLICE;
	GLfloat radius = 1.0;
	GLuint color;
	GLfloat x, y, z;

	cmdptr=0;

	color = 0;

	for (a = -90.0; a + da <= 90.0; a += da)
	{

		cmd[cmdptr++].command = GLC_BEGIN;

		for (b = 0.0; b <= 360.0; b += db)
		{

			if (color)
			{
				cmd[cmdptr].command = GLC_COLOR;
				cmd[cmdptr].p1 = 1.0;
				cmd[cmdptr].p2 = 0.0;
				cmd[cmdptr].p3 = 0.0;
				cmdptr++;
			}
			else
			{
				cmd[cmdptr].command = GLC_COLOR;
				cmd[cmdptr].p1 = 1.0;
				cmd[cmdptr].p2 = 1.0;
				cmd[cmdptr].p3 = 1.0;
				cmdptr++;
			}

			x = radius * COS(b) * COS(a);
			y = radius * SIN(b) * COS(a);
			z = radius * SIN(a);
			cmd[cmdptr].command = GLC_VERTEX;
			cmd[cmdptr].p1 = x;
			cmd[cmdptr].p2 = y;
			cmd[cmdptr].p3 = z;
			cmdptr++;

			x = radius * COS(b) * COS(a + da);
			y = radius * SIN(b) * COS(a + da);
			z = radius * SIN(a + da);
			cmd[cmdptr].command = GLC_VERTEX;
			cmd[cmdptr].p1 = x;
			cmd[cmdptr].p2 = y;
			cmd[cmdptr].p3 = z;
			cmdptr++;

			color = 1 - color;
		}
		cmd[cmdptr++].command = GLC_END;
	}
	cmd[cmdptr++].command = GLC_FINISH;

	return list;
}

void drawCube(void)
{
	glBegin(GL_QUADS);
		glColor3f(1.0, 0.0, 0.0);
		glVertex3f(-1,-1,-1); glColor3f(0.5, 0.5, 0.5);
		glVertex3f(-1,1,-1); glVertex3f(1,1,-1); glVertex3f(1,-1,-1);

		glColor3f(1.0, 0.5, 0.0);
		glVertex3f(-1,1,-1); glColor3f(0.5, 0.5, 0.5);
		glVertex3f(-1,1,1); glVertex3f(1,1,1); glVertex3f(1,1,-1);

		glColor3f(0.0, 1.0, 0.0);
		glVertex3f(1,1,-1); glColor3f(0.5, 0.5, 0.5);
		glVertex3f(1,1,1); glVertex3f(1,-1,1); glVertex3f(1,-1,-1);

		glColor3f(0.0, 0.0, 1.0);
		glVertex3f(1,1,1); glColor3f(0.5, 0.5, 0.5);
		glVertex3f(-1,1,1); glVertex3f(-1,-1,1); glVertex3f(1,-1,1);

		glColor3f(0.0, 0.0, 0.0);
		glVertex3f(-1,1,1); glColor3f(0.5, 0.5, 0.5);
		glVertex3f(-1,1,-1); glVertex3f(-1,-1,-1); glVertex3f(-1,-1,1);

		glColor3f(1.0, 1.0, 1.0);
		glVertex3f(-1,-1,1); glColor3f(0.5, 0.5, 0.5);
		glVertex3f(-1,-1,-1);
		glVertex3f(1,-1,-1);
		glVertex3f(1,-1,1);

	glEnd();
}


static void drawBall(void)
{
	int i = 0;

	while (cmd[i].command != GLC_FINISH)
	{
		switch(cmd[i].command)
		{
			case GLC_BEGIN:
				glBegin(GL_QUAD_STRIP);
				break;
			case GLC_COLOR:
				glColor3f(cmd[i].p1, cmd[i].p2, cmd[i].p3);
				break;
			case GLC_VERTEX:
				glVertex3f(cmd[i].p1, cmd[i].p2, cmd[i].p3);
				break;
			case GLC_END:
				glEnd();
				break;
		}
		i++;
	}
}


void reshape(int width, int height)
{
	float aspect = (float) width / (float) height;
	glViewport(0, 0, (GLint) width, (GLint) height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(-6.0 * aspect, 6.0 * aspect, -6.0, 6.0, -6.0, 6.0);
	glMatrixMode(GL_MODELVIEW);
}

static void key(unsigned char k, int x, int y)
{
	switch (k)
	{
		case 'b':
			do_cage = !do_cage;
			break;
		case 's':
			bounce = !bounce;
			break;
		case 'o':
			glPolygonMode(GL_FRONT, GL_LINE);
			break;
		case 'p':
			glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
			break;
		case 27:
			exit(0);
	}
}

static void drawCage(void)
{
	GLfloat xmin = Xmin - 2.0,
			xmax = Xmax + 2.0,
			ymin = Ymin - 2.0,
			ymax = Ymax + 2.0;

	glEnable(GL_BLEND);
	glColor4f(0.0, 0.5, 0.5, 0.5);

	glBegin(GL_QUADS);
		glVertex2f(xmax, ymax);
		glVertex2f(xmax, ymin);
		glVertex2f(xmin, ymin);
		glVertex2f(xmin, ymax);
	glEnd();
	glDisable(GL_BLEND);
}

static void draw(void)
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glRotatef(rot, 0.0, 1.0, 0.0);

	if (do_cage == GL_TRUE) drawCage();

	glPushMatrix();
	glTranslatef(Xpos, Ypos, 0.0);
	glScalef(2.f, 2.f, 2.f);
	glRotatef(8.0, 0.0, 0.0, 1.0);
	glRotatef(90.0, 1.0, 0.0, 0.0);
	glRotatef(Zrot, 0.0, 0.0, 1.0);

	drawBall();


	glPopMatrix();

	glFrontFace(GL_CCW);
	if (do_cage == GL_TRUE) drawCage();
	glFrontFace(GL_CW);

	glFlush();

	glutSwapBuffers();
}

static void idle(void)
{
	static float vel0 = -100.0;

	step += rot;
	step = fmod(step,180.0);
	
	if (!bounce)
		return;
		
	Zrot += fabs(Zstep);

	Xpos += Xvel;
	if (Xpos >= Xmax)
	{
		Xpos = Xmax;
		Xvel = -Xvel;
		Zstep = -Zstep;
	}
	if (Xpos <= Xmin)
	{
		Xpos = Xmin;
		Xvel = -Xvel;
		Zstep = -Zstep;
	}
	Ypos += Yvel;
	Yvel += G;
	if (Ypos < Ymin)
	{
		Ypos = Ymin;
		if (vel0 == -100.0)
		{
			vel0 = fabs(Yvel);
		}
		Yvel = vel0;
	}

	glutPostRedisplay();
}

int main(int argc, char *argv[])
{
	GLint width=320; GLint height=240;
	int i;
	GLboolean culling = GL_TRUE;
	ULONG ModeID = INVALID_ID;
	GLenum sync = GL_FALSE;

	for (i=1; i<argc; i++)
	{
		if (0 == stricmp(argv[i], "-modeid"))
		{
			i++;
			ModeID = atoi(argv[i]);
		}
		if (0 == stricmp(argv[i], "-width"))
		{
			i++;
			width = atoi(argv[i]);
		}
		if (0 == stricmp(argv[i], "-height"))
		{
			i++;
			height = atoi(argv[i]);
		}
		if (0 == stricmp(argv[i],"-xmin"))
		{
			i++;
			Xmin = atof(argv[i]);
		}
		if (0 == stricmp(argv[i],"-xmax"))
		{
			i++;
			Xmax = atof(argv[i]);
		}
		if (0 == stricmp(argv[i],"-rot"))
		{
			i++;
			rot = atof(argv[i]);
		}
		if (0 == stricmp(argv[i],"-nocull"))
		{
			culling = GL_FALSE;
		}
		if (0 == stricmp(argv[i],"-noback"))
		{
			do_cage = GL_FALSE;
		}
		if (0 == stricmp(argv[i],"-sync"))
		{
			sync = GL_TRUE;
		}
	}

	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
//	glutInitWindowSize(width, height);
	glutCreateWindow("bounce");

	mglEnableSync(sync);

	glClearColor(0.0, 0.0, 0.0, 1.0);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	Ball = make_ball();
	glCullFace(GL_BACK);
	if (culling == GL_TRUE)
	{
		glEnable(GL_CULL_FACE);
	}
	else
	{
		glDisable(GL_CULL_FACE);
	}

	glDisable(GL_DEPTH_TEST);
	glShadeModel(GL_FLAT);

	reshape(width,height);
//	mglLockMode(MGL_LOCK_MANUAL);
	glutIdleFunc(idle);
	glutKeyboardFunc(key);
	glutDisplayFunc(draw);
	glutMainLoop();
	return 0;             /* ANSI C requires main to return int. */
}
