/*
    warp.c

    This is an example of what extreme field of view can do.....

*/

#include <stdlib.h>
#include <string.h>
#include <GL/glut.h>

#include <math.h>
#ifndef M_PI
#define M_PI 3.14159265
#endif
#include <stdio.h>

GLint width=640; GLint height=480;
GLfloat startilt = 0.0;
GLfloat t_off = 0.0;
GLfloat fov = 170.0;

typedef struct
{
    GLfloat x,y,z,u,v;
} MyVertex;


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

	f = fopen(name, "rb");

	if (!f)
	{
		printf("PPM open failed\n");
		*w = 0; *h=0;
		return NULL;
	}
	i = fscanf(f, "P6\n");
	if(fgetc(f) == '#'){
		while(fgetc(f) != '\n' && !ferror(f)){
			;
		}
		if(ferror(f)){
			printf("PPM open failed\n");
			*w = 0; *h=0;
			return NULL;
		}
	}
	else{
		fseek(f, -1, SEEK_CUR);
	}
	i += fscanf(f,"%ld %ld\n255\n", &x, &y);

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


BOOL TexInit(char *name, int num)
{
    GLubyte *tmap;
    GLint x,y;

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);

    if (!name)
    {
		return FALSE;
    }
    else
    {
		tmap = LoadPPM(name, &x, &y);
    }

    if (!tmap)
		return FALSE;

    glBindTexture(GL_TEXTURE_2D, num);
    glTexImage2D(GL_TEXTURE_2D, 0, 3,
		x,y, 0, GL_RGB, GL_UNSIGNED_BYTE, tmap);
    free(tmap);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glEnable(GL_TEXTURE_2D);

    return TRUE;
}

static void drawFlare(GLint texnum)
{
    GLfloat x,y,w,h;

    w=width/10.0;
    h=w;

    x=width/2.0-w/2.0;
    y=height/2.0-h/2.0;


    glBindTexture(GL_TEXTURE_2D, texnum);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    /*
    ** An MGL_FLATFAN is a shortcut to draw something into the
    ** screen that does not go through the transformation pipeline.
    ** This is also not clipped, so you have to take care to avoid
    ** going over the edges, or clip yourself.
    */
    glColor3f(1.0, 1.0, 1.0);
    glBegin(MGL_FLATFAN);
	glTexCoord2f(0.0, 0.0);
	glVertex2f(x,y);
	glTexCoord2f(1.0, 0.0);
	glVertex2f(x+w, y);
	glTexCoord2f(1.0, 1.0);
	glVertex2f(x+w,y+h);
	glTexCoord2f(0.0, 1.0);
	glVertex2f(x,y+h);
    glEnd();
    glDisable(GL_BLEND);
}


static void drawStarField(GLint tex1, GLfloat off)
{
    #define BACKPLANE -8.0
    #define TEXTU 0.0
    #define TEXTV 2.0

    glBindTexture(GL_TEXTURE_2D, tex1);

    glColor4f(1.0, 1.0, 1.0, 1.0);
    glBegin(GL_QUADS);

	glTexCoord2f(TEXTU, TEXTV+off);
	glVertex3f(-1.0,  1.0,  BACKPLANE);
	glTexCoord2f(TEXTU, off);
	glVertex3f(-1.0,  1.0,   1.0);
	glTexCoord2f(1.0, off);
	glVertex3f(-1.0, -1.0,   1.0);
	glTexCoord2f(1.0, TEXTV+off);
	glVertex3f(-1.0, -1.0,  BACKPLANE);

	glTexCoord2f(TEXTU, TEXTV+off);
	glVertex3f( 1.0,  1.0,  BACKPLANE);
	glTexCoord2f(TEXTU, off);
	glVertex3f( 1.0,  1.0,   1.0);
	glTexCoord2f(1.0, off);
	glVertex3f( 1.0, -1.0,   1.0);
	glTexCoord2f(1.0, TEXTV+off);
	glVertex3f( 1.0, -1.0,  BACKPLANE);

	glTexCoord2f(TEXTU, TEXTV+off);
	glVertex3f(-1.0,  1.0,  BACKPLANE);
	glTexCoord2f(TEXTU, off);
	glVertex3f(-1.0,  1.0,   1.0);
	glTexCoord2f(1.0, off);
	glVertex3f( 1.0,  1.0,   1.0);
	glTexCoord2f(1.0, TEXTV+off);
	glVertex3f( 1.0,  1.0,  BACKPLANE);

	glTexCoord2f(TEXTU, TEXTV+off);
	glVertex3f(-1.0, -1.0,  BACKPLANE);
	glTexCoord2f(TEXTU, off);
	glVertex3f(-1.0, -1.0,   1.0);
	glTexCoord2f(1.0, off);
	glVertex3f( 1.0, -1.0,   1.0);
	glTexCoord2f(1.0, TEXTV+off);
	glVertex3f( 1.0, -1.0,  BACKPLANE);

    glEnd();


}


void reshape(int w, int h)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(70.0, 1.3333333, 1.0, 100.0);

    glMatrixMode(GL_MODELVIEW);
    glViewport(0, 0, w, h);
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClearDepth(1.0);
}

void DoFrame(void)
{
    glClear(GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(fov, 1.3333333, 1.0, 100.0);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glScalef(20.0, 20.0, 20.0);
    glRotatef(startilt, 0.0, 0.0, 1.0);
    glDisable(GL_CULL_FACE);

    drawStarField(1, t_off);
    drawFlare(2);

    startilt += 0.1;
    t_off += 0.007;

    glutSwapBuffers();
}


void keys(unsigned char c, int x, int y)
{

    switch (c)
    {
	case 0x1b:
	    exit(0);
	    break;
	case '+':
	    if (fov < 165.0)
		fov += 5.0;
	    break;
	case '-':
	    if (fov > 30)
		fov -= 5.0;
	    break;
    }

}

int main(int argc, char *argv[])
{
    int i;
    char *filename = "data/stars.ppm";
    char *flarename = "data/flare.ppm";

    for (i=1; i<argc; i++)
    {
	if (0 == strcasecmp(argv[i], "-width"))
	{
	    i++;
	    width = atoi(argv[i]);
	}
	if (0 == strcasecmp(argv[i], "-height"))
	{
	    i++;
	    height = atoi(argv[i]);
	}
	if (0 == strcasecmp(argv[i], "-window"))
	{
//	    mglChooseWindowMode(GL_TRUE);
	}
	if (0 == strcasecmp(argv[i], "-texture"))
	{
	    i++;
	    filename = argv[i];
	}
	if (0 == strcasecmp(argv[i], "-flare"))
	{
	    i++;
	    flarename = argv[i];
	}
    }

	glutInit(&argc, argv);
 	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
 	glutInitWindowSize(width, height);
 	glutCreateWindow("Warp");

    reshape(width, height);
    glDisable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    if ( TexInit(filename, 1) && TexInit(flarename, 2) )
    {
		glClearColor(0.3, 0.3, 0.3, 1.0);
		glColor3f(1.0, 1.0, 1.0);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glHint(MGL_W_ONE_HINT, GL_FASTEST);
		glEnable(GL_TEXTURE_2D);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

		glShadeModel(GL_SMOOTH);
		mglLockMode(MGL_LOCK_SMART);
		glutIdleFunc(DoFrame);
		glutKeyboardFunc(keys);
		glutMainLoop();
    }
    else
    {
		printf("Can't load textures\n");
    }

    return 0;             /* ANSI C requires main to return int. */
}

