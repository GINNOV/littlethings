
#include <mgl/gl.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>	//OF
#include <math.h>

#ifdef __VBCC__
	#pragma amiga-align
#endif

#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/graphics.h>

#ifdef __VBCC__
	#pragma default-align
#endif

//tex numbers

GLuint t1;
GLuint t2;
GLuint t3;
GLuint t4;

GLenum currentenv = 0;
GLenum currentblend = 0;
GLuint swap_textures = 0;

int TexEnv_Array[3] = {
GL_MODULATE,
GL_DECAL,
GL_REPLACE,
};

char TexEnv_Str [3][16] = {
{"GL_MODULATE"},
{"GL_DECAL"},
{"GL_REPLACE"},
};

int BlendDst_Array[2] = {
GL_SRC_COLOR,
GL_SRC_ALPHA,
};

char BlendDst_Str [2][16] = {
{"GL_SRC_COLOR"},
{"GL_SRC_ALPHA"},
};

#if 0
GLubyte *LoadPPM(char *name, GLint *w, GLint *h)
{
    int i;
    unsigned long x,y;
    FILE *f;
    GLubyte *where;
    GLubyte *pCur;
    int psize = 3;

    f = fopen(name, "r");

    if (!f)
    {
	*w = 0; *h=0;
	return NULL;
    }

    i = fscanf(f, "P6\n%ld\n%ld\n255\n", &x, &y);

    if (i!= 2)
    {
	printf("Error scanning PPM header\n");
	fclose(f);
	*w = 0; *h = 0;
	return NULL;
    }

    *w = x;
    *h = y;

    where = (GLubyte*)malloc(x*y*psize);
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
#endif


void AddAlpha (GLubyte *in, GLubyte *out, GLuint w, GLuint h, GLboolean alpha_average)
{
	int i,j;
	GLubyte r,g,b;

   if(alpha_average == GL_FALSE)
   {
	for (i=0; i<h; i++)
	{
		for(j=0; j<w; j++)
		{
			r = *in++;
			g = *in++;
			b = *in++;

			*out++ = r;
			*out++ = g;
			*out++ = b;
			*out++ = 0xFF;
		}
	}
   }
   else
   {
	ULONG alpha;

	for (i=0; i<h; i++)
	{
		for(j=0; j<w; j++)
		{
			r = *in++;
			g = *in++;
			b = *in++;

			alpha = (ULONG)r+(ULONG)g+(ULONG)b;
			if(alpha) alpha /= 3;

			*out++ = r;
			*out++ = g;
			*out++ = b;
			*out++ = (GLubyte)alpha;
		}
	}
   }
}

GLubyte *LoadPPM_Alpha(char *name, GLint *w, GLint *h, GLboolean genalpha)
{
    int i;
    unsigned long x,y;
    FILE *f;
    GLubyte *where;
    GLubyte *out;
    GLubyte *pCur;

    f = fopen(name, "r");

    if (!f)
    {
	*w = 0; *h=0;
	return NULL;
    }

    i = fscanf(f, "P6\n%lu\n%lu\n255\n", &x, &y);	//OF (%lu)

    if (i!= 2)
    {
	printf("Error scanning PPM header\n");
	fclose(f);
	*w = 0; *h = 0;
	return NULL;
    }

    *w = x;
    *h = y;

    where = (GLubyte*)malloc(x*y*3);

    if (!where)
    {
	printf("Error out of Memory\n");
	fclose(f);
	*w = 0; *h = 0;
	return NULL;
    }

    out = (GLubyte*)malloc(x*y*4);

    if (!out)
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
	if(out) free(out);
	*w = 0; *h = 0;
	return NULL;
    }

    AddAlpha(where, out, x, y, genalpha);

    free(where);

    return out;
}


extern GLcontext mini_CurrentContext;

void create_window(int w, int h)
{
       ULONG info;

    MGLInit();

    mglChooseWindowMode(GL_TRUE);
    mglChoosePixelDepth(16);
    mglChooseNumberOfBuffers(2);

    mglCreateContext(0,0,w,h);

//    mglLockMode(MGL_LOCK_SMART);
      mglLockMode(MGL_LOCK_MANUAL);  //01-05-02

}

void delete_window()
{
    mglDeleteContext();
    MGLTerm();
}

void switch_buffer()
{
    struct Window *win = mglGetWindowHandle();
    static char buffer[256];

    mglSwitchDisplay();

    Move(win->RPort, win->Width - 200, 30);
    sprintf(buffer, "GL_MGL_ARB_multitexture");
    Text(win->RPort, buffer, strlen(buffer));

    Move(win->RPort, win->Width - 200, 50);
    sprintf(buffer, "Current Unit 1 settings:");
    Text(win->RPort, buffer, strlen(buffer));

    Move(win->RPort, win->Width - 200, 60);
    //sprintf(buffer, "TexEnv : %s", &TexEnv_Str[currentenv]);
    sprintf(buffer, "TexEnv : %s", TexEnv_Str[currentenv]); //OF
    Text(win->RPort, buffer, strlen(buffer));

    Move(win->RPort, win->Width - 200, 70);
    //sprintf(buffer, "Blend  : GL_ONE  %s", &BlendDst_Str[currentblend]);
    sprintf(buffer, "Blend  : GL_ONE  %s", BlendDst_Str[currentblend]); //OF
    Text(win->RPort, buffer, strlen(buffer));

    Move(win->RPort, win->Width - 200, 90);
    sprintf(buffer, "    (E/B toggles Env/Blend)");
    Text(win->RPort, buffer, strlen(buffer));

    Move(win->RPort, win->Width - 200, 100);
    sprintf(buffer, "    (T swaps texture sets)");
    Text(win->RPort, buffer, strlen(buffer));
}

GLuint create_texture(char *texture, GLboolean alpha)
{
    GLuint t = 0;
    GLint w, h;
    GLubyte *pic;

	pic = LoadPPM_Alpha(texture, &w, &h, alpha);
    

    if (!pic)
    {
	printf("Error loading texture\n");
	return 0;
    }

    glGenTextures(1, &t);

    if (glGetError() != GL_NO_ERROR)
    {
	printf("Error generating texture\n");
      if(pic) free(pic);
	return 0;
    }

    glBindTexture(GL_TEXTURE_2D, t);

if(alpha == GL_TRUE)
{
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, pic);
}
else
{
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, pic);
}

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

    if (glGetError() != GL_NO_ERROR)
    {
	printf("Error creating texture\n");
      if(pic) free(pic);

	return 0;
    }

    if(pic) free(pic);

    return t;
}


void idle()
{
    GLenum BDst;
    static float a = 0.0;
    static float b = 0.0;

    static float da = 3.1415927/2.0;

	a += 0.002;
	if (a > 360.0)
	    a -= 360.0;

    mglLockDisplay(); //01-05-02

	glClear(GL_COLOR_BUFFER_BIT);

	glActiveTextureARB(GL_TEXTURE0_ARB);

if(!swap_textures)
	glBindTexture(GL_TEXTURE_2D, t1);
else
	glBindTexture(GL_TEXTURE_2D, t3);

	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glEnable(GL_TEXTURE_2D);

	glActiveTextureARB(GL_TEXTURE1_ARB);

if(!swap_textures)
	glBindTexture(GL_TEXTURE_2D, t2);
else
	glBindTexture(GL_TEXTURE_2D, t4);

	glEnable(GL_TEXTURE_2D); //enabled during upload
/*
The following is ignored by MiniGL but is needed for normal ARB multitexturing
*/

	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, (GLenum)TexEnv_Array[currentenv]);


	glBegin(GL_POLYGON);

	glColor3f(sin(a)+0.1, fabs(cos(a))+0.1, sin(a)+0.1);

	glMultiTexCoord2fARB(GL_TEXTURE0_ARB, sin(a), cos(a));
	glMultiTexCoord2fARB(GL_TEXTURE1_ARB, 0.0, 0.0);
	glVertex3f(-5.0, 5.0, 0.0);

	glColor3f(fabs(cos(a))+0.1, fabs(cos(a))+0.1, sin(a)+0.1);

	glMultiTexCoord2fARB(GL_TEXTURE0_ARB, sin(a+da), cos(a+da));
	glMultiTexCoord2fARB(GL_TEXTURE1_ARB, 1.0, 0.0);
	glVertex3f(5.0, 5.0, 0.0);

	glColor3f(fabs(cos(a)+0.1), sin(a)+0.1, fabs(cos(a))+0.1);

	glMultiTexCoord2fARB(GL_TEXTURE0_ARB, sin(a+2*da), cos(a+2*da));
	glMultiTexCoord2fARB(GL_TEXTURE1_ARB, 1.0, 1.0);
	glVertex3f(5.0, -5.0, 0.0);

	glColor3f(sin(a)+0.1, sin(a)+0.1, fabs(cos(a))+0.1);

	glMultiTexCoord2fARB(GL_TEXTURE0_ARB, sin(a+3*da), cos(a+3*da));
	glMultiTexCoord2fARB(GL_TEXTURE1_ARB, 0.0, 1.0);
	glVertex3f(-5.0, -5.0, 0.0);

	glEnd();

//draw buffer:

	mglDrawMultitexBuffer(GL_ONE, (GLenum)BlendDst_Array[currentblend], (GLenum)TexEnv_Array[currentenv]);

	glFinish();

	switch_buffer();
}

void keys(char c)
{
    if (c == 0x1b)
	mglExit();

	switch (c)
	{
		case 'B':
		case 'b':
			currentblend = !currentblend;
			break;
		case 'E':
		case 'e':
			if(currentenv == 2)
				currentenv = 0;
			else
				currentenv++;

			break;
		case 'T':
		case 't':
			swap_textures = !swap_textures;
		default:
			break;
	}

}

   
int main()
{
    struct Window *win;
    float a = 0;
    float da = 3.1415927/2.0;

    create_window(640, 480);

    win = (struct Window *)mglGetWindowHandle();

    SetAPen(win->RPort, 2);

//upload with unit1 

    glActiveTextureARB(GL_TEXTURE1_ARB);
    glEnable(GL_TEXTURE_2D);

    t1 = create_texture("data/test1.ppm", GL_FALSE);
    t2 = create_texture("data/test2.ppm", GL_TRUE);
    t3 = create_texture("data/t1.ppm", GL_FALSE);
    t4 = create_texture("data/t2.ppm", GL_TRUE);

    printf("Extensions: %s\n", glGetString(GL_EXTENSIONS));

    glViewport(0, 0, 640, 480);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(75.0, 1.3, 0.1, 10000.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0, 0.0, -20.0,  0.0, 0.0, 0.0,  0.0, 1.0, 0.0);

    glScalef(3.0, 3.0, 1.0);
    glRotatef(45, 35, 15, 25);

    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);

    glColor3f(1.0, 1.0, 1.0);
    glClearColor(0.0, 0.0, 0.0, 0.0);

    mglIdleFunc(idle);
    mglKeyFunc(keys);
    mglMainLoop();

      delete_window();

    return 0;
}
