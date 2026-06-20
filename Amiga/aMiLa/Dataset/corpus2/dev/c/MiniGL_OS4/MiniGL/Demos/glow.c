#include <math.h>
#include <string.h>
#include <stdio.h>
#include <GL/glut.h>

#include "texload.h"
#include <proto/exec.h>

GLboolean doubleBuffer;
GLuint windW, windH;
GLuint glowTex;
GLuint glowColorTex;
GLuint barTex;
GLuint wallTex;
GLuint floorTex;
GLuint renderTarget;
GLuint renderTarget2;

GLboolean firstGlow = GL_TRUE;
GLboolean secondGlow = GL_TRUE;

GLfloat angle = 0.0f;
GLfloat distance = 2.0f;

GLboolean overlayOnly = GL_FALSE;
GLboolean noGlow = GL_FALSE;
GLuint glowTexSize = 32;

#define GLOW_TEX_SIZE	glowTexSize


static void
Args(int argc, char **argv)
{
	GLint i;

	doubleBuffer = GL_TRUE;

	for (i = 1; i < argc; i++) 
	{
		if (strcmp(argv[i], "--single-buffer") == 0) 
		{
			doubleBuffer = GL_FALSE;
		} 
		else if (strcmp(argv[i], "--double-buffer") == 0) 
		{
			doubleBuffer = GL_TRUE;
		}
		else if (strcmp(argv[i], "--glowsize") == 0)
		{
			i++;
			if (i < argc) glowTexSize = (GLuint)strtol(argv[i], 0, 0);
		}
	}
}

static void
SetCamera(void)
{
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt(0.0, 1.0, distance,
		0.0, 1.0, 0.0,
		0.0, 1.0, 0.0);
	glRotatef(angle, 0.0f, 1.0f, 0.0f);
}

static void
Init(void)
{
	uint32 renderBuffer[256*256];
	glowTex = mglMakeTextureFromFile(GL_RGB, "data/glow.png", NULL, NULL);
	barTex = mglMakeTextureFromFile(GL_RGB, "data/bar.png", NULL, NULL);
	glowColorTex = mglMakeMipMapFromFiles(GL_RGBA, "data/glow_color_%d.png", 
		NULL, NULL);
	floorTex = mglMakeTextureFromFile(GL_RGB, "data/floor.png", NULL, NULL);
	wallTex = mglMakeTextureFromFile(GL_RGB, "data/wall.png", NULL, NULL);	
	if (glowTex)
	{
		glEnable(GL_TEXTURE_2D);
	}
	SetCamera();
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER, 0.1);
	
	glGenTextures(1, &renderTarget);
	glBindTexture(GL_TEXTURE_2D, renderTarget);
	glTexImage2D(GL_TEXTURE_2D, 0,
		GL_RGBA, 
		GLOW_TEX_SIZE, GLOW_TEX_SIZE, 0,
		GL_RGBA, GL_UNSIGNED_BYTE,
		renderBuffer);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glGenTextures(1, &renderTarget2);
	glBindTexture(GL_TEXTURE_2D, renderTarget2);
	glTexImage2D(GL_TEXTURE_2D, 0,
		GL_RGBA, 
		GLOW_TEX_SIZE/2, GLOW_TEX_SIZE/2, 0,
		GL_RGBA, GL_UNSIGNED_BYTE,
		renderBuffer);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glBindTexture(GL_TEXTURE_2D, glowTex);
	mglPinTexture(renderTarget);
	mglPinTexture(renderTarget2);
}

static void
Reshape(int width, int height)
{
	windW = width;
	windH = height;

	glViewport(0, 0, width, height);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(90.0, (double)width / (double)height, 0.1, 100.0);
	glMatrixMode(GL_MODELVIEW);
}

static void
DrawColumn(GLfloat x, GLfloat z)
{
	glBegin(GL_QUADS);
		// Front Face
		glTexCoord2f(0.0f, 1.0f); glVertex3f(x-0.1f, -0.2f, z);
		glTexCoord2f(1.0f, 1.0f); glVertex3f(x+0.1f, -0.2f, z);
		glTexCoord2f(1.0f, 0.0f); glVertex3f(x+0.1f,  2.8f, z);
		glTexCoord2f(0.0f, 0.0f); glVertex3f(x-0.1f,  2.8f, z);
	glEnd();	
}

static void
DrawScene(GLboolean doTextures)
{
	// Draw the glowing object. This will always use a texture

	glEnable(GL_TEXTURE_2D);
	if (doTextures == GL_FALSE)
	{
		glEnable(GL_BLEND);
		glEnable(GL_ALPHA_TEST);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glBindTexture(GL_TEXTURE_2D, glowColorTex);
	}
	else
	{
		glDisable(GL_BLEND);
		glDisable(GL_ALPHA_TEST);
		glBindTexture(GL_TEXTURE_2D, glowTex);
	}
	
	glColor3f(1.0f, 1.0f, 1.0f);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	
	glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 1.0f);
		glVertex3f(-1.5f, -0.2f, 0.0f);
		
		glTexCoord2f(1.0f, 1.0f);
		glVertex3f(1.5f, -0.2f, 0.0f);
		
		glTexCoord2f(1.0f, 0.0f);
		glVertex3f(1.5f, 2.8f, 0.0f);
		
		glTexCoord2f(0.0f, 0.0f);
		glVertex3f(-1.5f, 2.8f, 0.0f);
	glEnd();
	
	if (doTextures == GL_TRUE)
	{
		// Draw other non-occluders
		
		// 1) Walls
		glBindTexture(GL_TEXTURE_2D, wallTex);
		
		glBegin(GL_QUADS);
			// right wall
			glTexCoord2f(0.0f, 1.0f);
			glVertex3f(1.5f, -0.2f, 0.0f);
		
			glTexCoord2f(1.0f, 1.0f);
			glVertex3f(4.5f, -0.2f, 0.0f);
		
			glTexCoord2f(1.0f, 0.0f);
			glVertex3f(4.5f, 2.8f, 0.0f);
		
			glTexCoord2f(0.0f, 0.0f);
			glVertex3f(1.5f, 2.8f, 0.0f);
			
			// Right wall, angled
			glTexCoord2f(0.0f, 1.0f);
			glVertex3f(4.5f, -0.2f, 0.0f);
		
			glTexCoord2f(1.0f, 1.0f);
			glVertex3f(4.5f, -0.2f, 4.0f);
		
			glTexCoord2f(1.0f, 0.0f);
			glVertex3f(4.5f, 2.8f, 4.0f);
		
			glTexCoord2f(0.0f, 0.0f);
			glVertex3f(4.5f, 2.8f, 0.0f);
		
			// left wall
			glTexCoord2f(0.0f, 1.0f);
			glVertex3f(-1.5f, -0.2f, 0.0f);
		
			glTexCoord2f(1.0f, 1.0f);
			glVertex3f(-4.5f, -0.2f, 0.0f);
		
			glTexCoord2f(1.0f, 0.0f);
			glVertex3f(-4.5f, 2.8f, 0.0f);
		
			glTexCoord2f(0.0f, 0.0f);
			glVertex3f(-1.5f, 2.8f, 0.0f);
			
			// left wall, angled
			glTexCoord2f(0.0f, 1.0f);
			glVertex3f(-4.5f, -0.2f, 0.0f);
		
			glTexCoord2f(1.0f, 1.0f);
			glVertex3f(-4.5f, -0.2f, 4.0f);
		
			glTexCoord2f(1.0f, 0.0f);
			glVertex3f(-4.5f, 2.8f, 4.0f);
		
			glTexCoord2f(0.0f, 0.0f);
			glVertex3f(-4.5f, 2.8f, 0.0f);	
			
		glEnd();
		
		// 2) Floor and ceiling
		glBindTexture(GL_TEXTURE_2D, floorTex);
		glBegin(GL_QUADS);
			// Floor
			glTexCoord2f(0.0f, 1.0f);
			glVertex3f(-4.5f, -0.2f, 0.0f);
		
			glTexCoord2f(1.0f, 1.0f);
			glVertex3f(4.5f, -0.2f, 0.0f);
		
			glTexCoord2f(1.0f, 0.0f);
			glVertex3f(4.5f, -0.2f, 4.0f);
		
			glTexCoord2f(0.0f, 0.0f);
			glVertex3f(-4.5f, -0.2f, 4.0f);
			
			// Ceiling
			glTexCoord2f(0.0f, 1.0f);
			glVertex3f(-4.5f, 2.8f, 0.0f);
		
			glTexCoord2f(1.0f, 1.0f);
			glVertex3f(4.5f, 2.8f, 0.0f);
		
			glTexCoord2f(1.0f, 0.0f);
			glVertex3f(4.5f, 2.8f, 4.0f);
		
			glTexCoord2f(0.0f, 0.0f);
			glVertex3f(-4.5f, 2.8f, 4.0f);
			
		glEnd();
	}
	
	glDisable(GL_BLEND);
	glDisable(GL_ALPHA_TEST);

	glPushMatrix();	
	if (doTextures)
	{
		glBindTexture(GL_TEXTURE_2D, barTex);
		glColor3f(0.5f, 0.5f, 0.5f);
	}
	else
	{
		glDisable(GL_TEXTURE_2D);
		glColor3f(0.0f, 0.0f, 0.0f);
	}
		
	for (int i=-4; i<5; i++)
	{
		DrawColumn((GLfloat)(i), 0.4);
	}
	
	glPopMatrix();
	glDisable(GL_BLEND);
}

static void
DrawOverlay()
{
	GLfloat deltau, deltav;
	
	#define CI 1.0f
	#define OI 0.5f
	#define FACTOR 6.0f
	
	deltau = FACTOR / windW;
	deltav = FACTOR / windH;
	
	glBindTexture(GL_TEXTURE_2D, renderTarget);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	gluOrtho2D(-1.0f, 1.0f, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glEnable(GL_TEXTURE_2D);
	glBlendFunc(GL_ONE, GL_ONE);

	if (firstGlow)
	{
		glBegin(GL_QUADS);
			glColor4f(CI, CI, CI, CI);
			glTexCoord2f(0.0f-deltau, 1.0f-deltav);	glVertex3f(-1.0f, -1.0f, 0.0f);
			glTexCoord2f(1.0f+deltau, 1.0f-deltav);	glVertex3f(1.0f, -1.0f, 0.0f);
			glTexCoord2f(1.0f+deltau, 0.0f+deltav);	glVertex3f(1.0f, 1.0f, 0.0f);
			glTexCoord2f(0.0f-deltau, 0.0f+deltav);	glVertex3f(-1.0f, 1.0f, 0.0f);
		glEnd();
	}
	
	if (secondGlow)
	{
		glBindTexture(GL_TEXTURE_2D, renderTarget2);
	
		glBegin(GL_QUADS);
			glColor4f(CI, CI, CI, CI);
			glTexCoord2f(0.0f-deltau, 1.0f-deltav);	glVertex3f(-1.0f, -1.0f, 0.0f);
			glTexCoord2f(1.0f+deltau, 1.0f-deltav);	glVertex3f(1.0f, -1.0f, 0.0f);
			glTexCoord2f(1.0f+deltau, 0.0f+deltav);	glVertex3f(1.0f, 1.0f, 0.0f);
			glTexCoord2f(0.0f-deltau, 0.0f+deltav);	glVertex3f(-1.0f, 1.0f, 0.0f);
		glEnd();
	}
	
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	
}

static void
Display(void)
{
	/* Render the glow parts into the texture */

	GLuint w = windW, h = windH;

	mglSetTextureRenderTarget(renderTarget);
	Reshape(GLOW_TEX_SIZE, GLOW_TEX_SIZE);
	SetCamera();
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	DrawScene(GL_FALSE);
	glFlush();
	glFinish();
	mglSetTextureRenderTarget(0);
	
	mglSetTextureRenderTarget(renderTarget2);
	Reshape(GLOW_TEX_SIZE/2, GLOW_TEX_SIZE/2);
	SetCamera();
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	DrawScene(GL_FALSE);
	glFlush();
	glFinish();
	mglSetTextureRenderTarget(0);
	
	Reshape(w,h);
	
	glClearDepth(1.0f);
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	if (overlayOnly == GL_FALSE) DrawScene(GL_TRUE);
	
	if (noGlow == GL_FALSE)
	{
		glEnable(GL_BLEND);
		
		/* Draw the overlay */
		glDisable(GL_DEPTH_TEST);
		DrawOverlay();
		glEnable(GL_DEPTH_TEST);
		glDisable(GL_DEPTH_TEST);
	}
	
	glutSwapBuffers();
}

static void
Key(unsigned char key, int x, int y)
{
  	switch (key) 
  	{
	case 27:
    	exit(0);
    case 'o':
    case 'O':
    	overlayOnly = !overlayOnly;
    	break;
    case 'g':
    case 'G':
    	noGlow = !noGlow;
    	break;
    case '1':
    	firstGlow = !firstGlow;
    	break;
    case '2':
		secondGlow = !secondGlow;
		break;    	
	}
	glutPostRedisplay();
}

static void
SpecialKey(int key, int x, int y)
{
	switch(key)
	{
	case GLUT_KEY_LEFT:
		angle -= 3.0f;
		if (angle < -45.0f) angle = -45.0f;
		break;
	case GLUT_KEY_RIGHT:
		angle += 3.0f;
		if (angle > 45.0f) angle = 45.0f;
		break;
	case GLUT_KEY_UP:
		distance -= 0.1f;
		if (distance < 1.0f) distance = 1.0f;
		break;
	case GLUT_KEY_DOWN:
		distance += 0.1f;
		if (distance > 4.0f) distance = 4.0f;
		break;
	}
	
	SetCamera();
	glutPostRedisplay();
}

int
main(int argc, char **argv)
{
	GLenum type;

	glutInit(&argc, argv);
	glutInitWindowSize(512, 512);
	Args(argc, argv);

	type = GLUT_RGB;
	type |= (doubleBuffer) ? GLUT_DOUBLE : GLUT_SINGLE;
	glutInitDisplayMode(type);
	glutCreateWindow("Glow");
	mglEnableSync(GL_TRUE);
	Init();

	glutReshapeFunc(Reshape);
	glutKeyboardFunc(Key);
	glutSpecialFunc(SpecialKey);
	glutDisplayFunc(Display);
	glutMainLoop();
	return 0;             /* ANSI C requires main to return int. */
}
