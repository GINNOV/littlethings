#include <mgl/gl.h>

#include <stdlib.h>


GLint width=640; GLint height=480;

GLfloat eye[3] = {15.0, 8.0, 0.0};
GLfloat look[3] = {0.0, 0.0, 0.0};

GLubyte texture[768];

char *texture_ascii[] =
{
	   "################",
	   "################",
	   "#######@@#######",
	   "#####@@88@@#####",
	   "####@8oooo8@####",
	   "####@o+--+o@####",
	   "###@8o-..-o8@###",
	   "###@8+-  -+8@###",
	   "####@o+--+o@####",
	   "####@8oooo8@####",
	   "#####@@88@@#####",
	   "#######@@#######",
	   "################",
	   "################",
	   "################",
	   "################"
};

#define MAX_PARTICLES 512

struct Particle
{
	GLboolean used;     // flag: is this entry used
	GLfloat x, y, z;    // Position
	GLfloat dx, dy, dz; // Directional velocity
	GLfloat r,g,b;      // Color
	GLint age;          // Age
};

struct Particle psystem[MAX_PARTICLES];

void CreateTexture()
{
	int i, j;
	GLubyte *t = texture;

	for (i = 0; i < 16; i++)
	{
		for (j = 0; j < 16; j++)
		{
			switch (texture_ascii[i][j])
			{
				case '#':
					*t++ = 0;       // R
					*t++ = 0;       // G
					*t++ = 0;       // B
					break;
				case '@':
					*t++ = 32;
					*t++ = 32;
					*t++ = 32;
					break;
				case '8':
					*t++ = 64;
					*t++ = 64;
					*t++ = 64;
					break;
				case 'o':
					*t++ = 96;
					*t++ = 96;
					*t++ = 96;
					break;
				case '+':
					*t++ = 128;
					*t++ = 128;
					*t++ = 128;
					break;
				case '-':
					*t++ = 160;
					*t++ = 160;
					*t++ = 160;
					break;
				case '.':
					*t++ = 192;
					*t++ = 192;
					*t++ = 192;
					break;
				case ' ':
					*t++ = 240;
					*t++ = 240;
					*t++ = 240;
					break;
			}
		}
	}

	glBindTexture(GL_TEXTURE_2D, 1);
	glTexImage2D(GL_TEXTURE_2D, 0, 3, 16, 16,
		0, GL_RGB, GL_UNSIGNED_BYTE, texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}


void reshape(int w, int h)
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(70.0, 1.3333333, 1.0, 100.0);

	glMatrixMode(GL_MODELVIEW);
	glViewport(0, 0, w, h);
	glClearColor(0.0f, 0.f, 0.f, 1.f);
	glClearDepth(1.0);
}

void UpdateParticles(void)
{
	int i;
	int cRate = 5;

	for (i = 0; i < MAX_PARTICLES; i++)
	{
		if (psystem[i].used)
		{
			psystem[i].x += psystem[i].dx;
			psystem[i].y += psystem[i].dy;
			psystem[i].z += psystem[i].dz;

			glPushMatrix();
			glTranslatef(psystem[i].x, psystem[i].y, psystem[i].z);

			glColor3f(psystem[i].r, psystem[i].g, psystem[i].b);

			glBegin(GL_QUADS);
				glTexCoord2f(0.0, 0.0);
				glVertex3f(-0.5, 0.5, 0.0);
				glTexCoord2f(1.0, 0.0);
				glVertex3f(0.5, 0.5, 0.0);
				glTexCoord2f(1.0, 1.0);
				glVertex3f(0.5, -0.5, 0.0);
				glTexCoord2f(0.0, 1.0);
				glVertex3f(-0.5, -0.5, 0.0);
			glEnd();

			glPopMatrix();

			psystem[i].age++;

			if (psystem[i].age > 100)
				psystem[i].used = GL_FALSE;
		}
		else
		{
			cRate--;
			if (cRate == 0) break;

			psystem[i].x = (GLfloat)(rand()%20) - 10.0;
			psystem[i].y = 10.0;
			psystem[i].z = (GLfloat)(rand()%20) - 10.0;

			psystem[i].dx = 0.0;
			psystem[i].dy = -0.2;
			psystem[i].dz = 0.0;

			psystem[i].r = (GLfloat)(rand()%255)/255.0;
			psystem[i].g = (GLfloat)(rand()%255)/255.0;
			psystem[i].b = (GLfloat)(rand()%255)/255.0;

			psystem[i].used = GL_TRUE;
			psystem[i].age = 0;
		}
	}
}

void DoFrame(void)
{
	mglLockDisplay();

	glClearColor(0.0f, 0.f, 0.f, 1.f);
	glClearDepth(1.0);
	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
	glEnable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt(eye[0], eye[1], eye[2], look[0], look[1], look[2], 0.0, 1.0, 0.0);

	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);

	glColor3f(0.2, 0.8, 0.2);

	glBegin(GL_QUADS);
		glVertex3f(-10.0, 0.0, -10.0);
		glVertex3f(10.0, 0.0, -10.0);
		glVertex3f(10.0, 0.0, 10.0);
		glVertex3f(-10.0, 0.0, 10.0);
	glEnd();

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);

	UpdateParticles();

	glFlush();

	mglUnlockDisplay();
	mglSwitchDisplay();
}

#ifndef __VBCC__
void keys(unsigned char c)
{

	switch (c)
	{
		case 0x1b:
			mglExit();
			break;
	}
}
#else
void keys(char c)
{

	switch (c)
	{
		case 0x1b:
			mglExit();
			break;
	}
}
#endif

#ifdef __VBCC__
int
#else
void
#endif
main(int argc, char *argv[])
{
	int i;

	for (i=1; i<argc; i++)
	{
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
		if (0 == stricmp(argv[i], "-window"))
		{
			mglChooseWindowMode(GL_TRUE);
		}
	}

	MGLInit();

	mglChooseVertexBufferSize(1000);
	mglChooseNumberOfBuffers(3);
	mglCreateContext(0,0,width,height);
	mglEnableSync(GL_FALSE);

	reshape(width, height);

	CreateTexture();

	mglIdleFunc(DoFrame);
	mglKeyFunc(keys);
	mglMainLoop();


	mglDeleteContext();
	MGLTerm();
#ifdef __VBCC__
	return 0;
#endif
}
