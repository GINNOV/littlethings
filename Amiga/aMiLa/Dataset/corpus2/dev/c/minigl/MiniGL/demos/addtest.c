#include <stdlib.h>
#include <mgl/gl.h>

#include <math.h>
#ifndef M_PI
#define M_PI 3.14159265
#endif
#include <stdio.h>

GLint width=640; GLint height=480;
GLfloat startilt = 0.0;
GLfloat t_off = 0.0;
GLfloat fov = 170.0;
int x, y;

typedef struct
{
    GLfloat x,y,z,u,v;
} MyVertex;


GLubyte *LoadPPM(char *name, GLint *w, GLint *h)
{
    int i, j;
    unsigned long x,y;
    FILE *f;
    GLubyte *where;
    GLubyte *cur;

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

    where = malloc(x*y*4);
    if (!where)
    {
	printf("Error out of Memory\n");
	fclose(f);
	*w = 0; *h = 0;
	return NULL;
    }

    cur = where;
    for (j = 0; j < x*y; j++)
    {
	fread(cur, 1, 1, f); cur++;
	fread(cur, 1, 1, f); cur++;
	fread(cur, 1, 1, f); cur++;
	*cur++ = 100;
    }
#if 0
    i = fread(where, 1, x*y*3, f);
    fclose(f);

    if (i != x*y*3)
    {
	printf("Error while reading file\n");
	free(where);
	*w = 0; *h = 0;
	return NULL;
    }
#endif
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
    glTexImage2D(GL_TEXTURE_2D, 0, 4,
	x,y, 0, GL_RGBA, GL_UNSIGNED_BYTE, tmap);
    free(tmap);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glEnable(GL_TEXTURE_2D);

    return TRUE;
}

static void drawFlare(GLint texnum)
{
    GLfloat w,h;

    w=width/10.0;
    h=w;


    glBindTexture(GL_TEXTURE_2D, texnum);
    glBlendFunc(GL_ONE, GL_ONE);
    glEnable(GL_BLEND);
    /*
    ** An MGL_FLATFAN is a shortcut to draw something into the
    ** screen that does not go through the transformation pipeline.
    ** This is also not clipped, so you have to take care to avoid
    ** going over the edges, or clip yourself.
    */
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

void DoFrame(void)
{
//    glClear(GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(fov, 1.3333333, 1.0, 100.0);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();


    drawFlare(2);

    startilt += 0.1;
    t_off += 0.007;

    mglSwitchDisplay();
}


void keys(char c)
{

    switch (c)
    {
	case 0x1b:
	    mglExit();
	    break;
	case 'w':
	    y-=5;
	    break;
	case 's':
	    y+=5;
	    break;
	case 'q':
	    x-=5;
	    break;
	case 'e':
	    x+=5;
	    break;
	case '1':
	    glDisable(GL_BLEND);
	    break;
	case '2':
	    glEnable(GL_BLEND);
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
	if (0 == stricmp(argv[i], "-texture"))
	{
	    i++;
	    filename = argv[i];
	}
	if (0 == stricmp(argv[i], "-flare"))
	{
	    i++;
	    flarename = argv[i];
	}
    }

    MGLInit();

    mglChooseVertexBufferSize(1000);
    mglChooseNumberOfBuffers(2);
    mglCreateContext(0,0,width,height);
    mglEnableSync(GL_FALSE);

    glClearColor(0.0, 0.0, 0.0, 0.0);
    reshape(width, height);
    glDisable(GL_DEPTH_TEST);

    x=width/2.0;
    y=height/2.0;

    glClearColor(0.3, 0.3, 0.3, 0.3);
    mglSwitchDisplay();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    mglSwitchDisplay();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    mglSwitchDisplay();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    if ( TexInit(filename, 1) && TexInit(flarename, 2) )
    {
	glClearColor(0.0, 0.0, 0.0, 1.0);
	glColor3f(1.0, 1.0, 1.0);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glHint(MGL_W_ONE_HINT, GL_FASTEST);
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);


	mglLockMode(MGL_LOCK_SMART);
	mglIdleFunc(DoFrame);
	mglKeyFunc(keys);
	mglMainLoop();
    }
    else
    {
	printf("Can't load textures\n");
    }

    mglDeleteContext();
    MGLTerm();
    return 0;             /* ANSI C requires main to return int. */
}

