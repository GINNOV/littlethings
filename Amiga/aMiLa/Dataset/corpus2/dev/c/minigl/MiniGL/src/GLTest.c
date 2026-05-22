/*
 * $Id: GLTest.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $
 *
 * $Date: 2000/04/07 19:44:51 $
 * $Revision: 1.1.1.1 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#include "mgl/gl.h"

#include <math.h>

#ifdef __VBCC__
#pragma amiga-align
#endif

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>
#include <libraries/lowlevel.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>	//OF
#include <dos/dos.h>

#ifdef __VBCC__
#pragma default-align
#endif

#ifdef __GNUC__
#ifdef __PPC__
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/lowlevel.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#else
#include <inline/exec.h>
#include <inline/intuition.h>
#include <inline/lowlevel.h>
#include <inline/dos.h>
#include <inline/graphics.h>
#endif
#endif

#ifdef __STORMC__
//#include <string.h>	//OF (made include string.h for all compilers)
#include <clib/powerpc_protos.h>
#ifndef __PPC__
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/lowlevel.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#else
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/lowlevel_protos.h>
#include <clib/dos_protos.h>
#include <clib/graphics_protos.h>
#endif


#define M_PI 3.1415927


int kprintf(char *format, ...)
{
    return 0;
}
#endif

#ifdef __VBCC__
#pragma amiga-align

#include <extra.h>			//OF
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/lowlevel.h>
#include <proto/dos.h>
#include <proto/graphics.h>

#pragma default-align

#define   M_PI 3.14159265358979323846

	#ifndef inline
	//#define inline		//OF (removed)
	#endif

#endif

static char rcsid[] = "$Id: GLTest.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $";
struct Library *LowLevelBase;

#ifndef __PPC__
extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;
extern struct Library *UtilityBase;
extern struct DosLibrary *DOSBase;
extern struct ExecBase *SysBase;
#endif

extern int kprintf(char *format, ...);
#define DEBUG(x) kprintf x

extern void GLPrintMatrix(int);

static struct EClockVal eval;
static float fps;
static GLfloat fog_start, fog_end;
static GLboolean fogon = GL_FALSE;
static GLboolean sync = GL_TRUE;

typedef struct
{
    GLfloat x,y,z,u,v;
} MyVertex;


#ifndef __VBCC__
static
#endif
MyVertex vertices1 [] =
{
    {-1, -1, -1, 0.5, 0.5}, // 0
    {-1, -1,  1, 0.5, 0.0}, // 1
    {-1,  1,  1, 0.0, 0.0}, // 2
    {-1,  1, -1, 0.0, 0.5}, // 3
    { 1,  1, -1, 0.0, 1.0}, // 4
    { 1, -1, -1, 0.5, 1.0}, // 5
    { 1, -1,  1, 1.0, 1.0}, // 6
    {-1, -1,  1, 1.0, 0.5}  // 7
};

#ifndef __VBCC__
static
#endif
MyVertex vertices2 [] =
{
    { 1,  1,  1, 0.5, 0.5}, // 0
    { 1, -1,  1, 0.5, 0.0}, // 1
    { 1, -1, -1, 0.0, 0.0}, // 2
    { 1,  1, -1, 0.0, 0.5}, // 3
    {-1,  1, -1, 0.0, 1.0}, // 4
    {-1,  1,  1, 0.5, 1.0}, // 5
    {-1, -1,  1, 1.0, 1.0}, // 6
    { 1, -1,  1, 1.0, 0.5}  // 7
};

#ifndef __VBCC__
static
#endif
MyVertex verticesS1 [] =
{
    {-1, -1, -1, 0.5, 0.5}, // 0
    {-1, -1,  1, 0.5, 0.0}, // 1
    {-1,  1, -1, 0.0, 0.5}, // 2
    {-1,  1,  1, 0.0, 0.0}, // 3

    { 1,  1, -1, 0.0, 0.5}, // 4
    { 1,  1,  1, 0.5, 0.5}, // 5
    { 1, -1, -1, 0.0, 0.0}, // 6
    { 1, -1,  1, 0.5, 0.0}, // 7
};

#ifndef __VBCC__
static
#endif
MyVertex verticesS2 [] =
{
    {-1,  1, -1, 0.0, 0.5}, // 0
    { 1,  1, -1, 0.0, 1.0}, // 1
    {-1, -1, -1, 0.5, 0.5}, // 2
    { 1, -1, -1, 0.5, 1.0}, // 3

    {-1, -1,  1, 1.0, 0.5}, // 4
    { 1, -1,  1, 1.0, 1.0}, // 5
    {-1,  1,  1, 0.5, 1.0}, // 6
    { 1,  1,  1, 0.5, 0.5}, // 7
};


struct ResInfo
{
    int width, height;
    char *name;
};

struct ResInfo Resolutions [] =
{
    {320, 240, "320 x 240"},
    {400, 300, "400 x 300"},
    {640, 480, "640 x 480"},
    {800, 600, "800 x 600"}, // Out of memory...
    {1024, 768, "1024 x 768"},
    {-1, -1, NULL}
};

GLint ResPtr;
char *CurrentRes;
GLboolean ShowRes = GL_TRUE;
GLboolean zbuffer = GL_TRUE;

GLfloat mouse_x = 0.0, mouse_y = 0.0, mouse_z = 0.0;
GLint offset = 0;
GLfloat fov = 70.0;
GLfloat inf_w = 0.1;
GLfloat zback = 1000.0;
GLfloat alpha = 1.0;


GLubyte index_texture[] =
{
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,
    1,0,1,2,2,2,2,2,2,2,2,2,2,1,0,1,
    1,0,1,2,1,1,1,1,1,1,1,1,2,1,0,1,
    1,0,1,2,1,3,3,3,3,3,3,1,2,1,0,1,
    1,0,1,2,1,3,1,1,1,1,3,1,2,1,0,1,
    1,0,1,2,1,3,1,4,4,1,3,1,2,1,0,1,
    1,0,1,2,1,3,1,4,4,1,3,1,2,1,0,1,
    1,0,1,2,1,3,1,1,1,1,3,1,2,1,0,1,
    1,0,1,2,1,3,3,3,3,3,3,1,2,1,0,1,
    1,0,1,2,1,1,1,1,1,1,1,1,2,1,0,1,
    1,0,1,2,2,2,2,2,2,2,2,2,2,1,0,1,
    1,0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,
    1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
};

GLubyte palette[] =
{
    0x00, 0x00, 0x00,
    0xFF, 0x00, 0x00,
    0x00, 0xFF, 0x00,
    0x00, 0x00, 0xff,
    0xFF, 0xFF, 0xFF,
};

static void ReplaceTexture(void)
{
    GLenum error;
    int i=1;

    glDeleteTextures(1, (const unsigned int *)&i);
    glBindTexture(GL_TEXTURE_2D, 1);

    glColorTable(GL_COLOR_TABLE, GL_RGB, 5, GL_RGB, GL_UNSIGNED_BYTE, palette);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 16, 16, 0, GL_COLOR_INDEX, GL_UNSIGNED_BYTE, index_texture);

    error = glGetError();
    kprintf("Error = %d\n", error);
}

static void MakeRot(GLfloat angle1, GLfloat angle2)
{
    GLfloat sinel = (GLfloat)sin((double)angle1/180*M_PI);
    GLfloat cosel = (GLfloat)cos((double)angle1/180*M_PI);
    GLfloat sinaz = (GLfloat)sin((double)angle2/180*M_PI);
    GLfloat cosaz = (GLfloat)cos((double)angle2/180*M_PI);

    GLfloat mat[16];

    mat[0] = cosaz;        mat[4] = 0.0;    mat[8] = -sinaz;       mat[12] = 0;
    mat[1] = -sinel*sinaz; mat[5] = cosel;  mat[9] = -sinel*cosaz; mat[13] = 0.0;
    mat[2] = cosel*sinaz;  mat[6] = sinel;  mat[10] = cosel*cosaz; mat[14] = 0.0;
    mat[3] =               mat[7] =         mat[11] = 0.0;         mat[15] = 1.0;
    glMultMatrixf(mat);
}

static void UpRes(void)
{
    ResPtr++; if (Resolutions[ResPtr].width == -1) ResPtr = 0;
    mglResizeContext(Resolutions[ResPtr].width, Resolutions[ResPtr].height);
    CurrentRes = Resolutions[ResPtr].name;
    ShowRes = GL_TRUE;
}

void PrExit(void)
{
    if (LowLevelBase)   CloseLibrary(LowLevelBase);
    exit(0L);
}

void PrInit(void)
{
    LowLevelBase  = OpenLibrary("lowlevel.library", 40L);
    if (!LowLevelBase) PrExit();
}

GLdouble angle = 0.0;
GLfloat mouse_angle_x = 0.0;
GLfloat mouse_angle_y = 0.0;
GLfloat tlow = 0.0;
GLfloat offx = 0.f, offy = 0.f;
GLdouble zclear = 1.0;
GLenum primitive = GL_POLYGON;

/*
** Load a PPM file into memory.
** The resulting pointer can be free()'d
*/
GLubyte *LoadPPM(char *name, GLint *w, GLint *h)
{
    int i;
    unsigned long x,y;
    FILE *f;
    GLubyte *where;
    static  char buffer2[256];

    f = fopen(name, "r");

    if (!f)
    {
        *w = 0; *h=0;
        return NULL;
    }
    #ifndef __STORM__
    i = fscanf(f, "P6\n%lu %lu\n255\n",&x, &y);	//OF (%lu)
    #else
    i = fscanf(f, "P6\n%lu\n%lu\n255\n", &x, &y);	//OF (%lu)
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

void TexInit(void)
{
    GLubyte *tmap;
    GLint x,y;

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);

    tmap = LoadPPM("data/t1.ppm",&x, &y);
    if(!tmap)
	printf("Error: tmap t1 is NULL\n");

    glBindTexture(GL_TEXTURE_2D, 1);
    glTexImage2D(GL_TEXTURE_2D, 0, 3,
        x,y, 0, GL_RGB, GL_UNSIGNED_BYTE, tmap);
    free(tmap);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    tmap = LoadPPM("data/t2.ppm",&x, &y);
    if(!tmap)
	printf("Error: tmap t2 is NULL\n");

    glBindTexture(GL_TEXTURE_2D, 2);
    glTexImage2D(GL_TEXTURE_2D, 0, 3,
        x,y, 0, GL_RGB, GL_UNSIGNED_BYTE, tmap);
    free(tmap);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    tmap = LoadPPM("data/stars.ppm",&x, &y);
    if(!tmap)
	printf("Error: tmap stars is NULL\n");glBindTexture(GL_TEXTURE_2D, 3);

    glTexImage2D(GL_TEXTURE_2D, 0, 3,
        x,y, 0, GL_RGB, GL_UNSIGNED_BYTE, tmap);
    free(tmap);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

}

static void drawCubeFan(GLint tex1, GLint tex2)
{
    GLfloat w = 1.0;

    if (tex1 == tex2) w = inf_w;

    glBindTexture(GL_TEXTURE_2D, tex1);
    glBegin(GL_TRIANGLE_FAN);
        //glColor3f(1.0, 0.0, 0.0);
        glTexCoord2f(vertices1[0].u, vertices1[0].v);
        glVertex4f(vertices1[0].x, vertices1[0].y, vertices1[0].z,w);
        if (tex1 != tex2) glColor4f(0.7, 0.7, 0.7, alpha);
        glTexCoord2f(vertices1[1].u, vertices1[1].v);
        glVertex4f(vertices1[1].x, vertices1[1].y, vertices1[1].z,w);
        glTexCoord2f(vertices1[2].u, vertices1[2].v);
        glVertex4f(vertices1[2].x, vertices1[2].y, vertices1[2].z,w);
        glTexCoord2f(vertices1[3].u, vertices1[3].v);
        glVertex4f(vertices1[3].x, vertices1[3].y, vertices1[3].z,w);
        glTexCoord2f(vertices1[4].u, vertices1[4].v);
        glVertex4f(vertices1[4].x, vertices1[4].y, vertices1[4].z,w);
        glTexCoord2f(vertices1[5].u, vertices1[5].v);
        glVertex4f(vertices1[5].x, vertices1[5].y, vertices1[5].z,w);
        glTexCoord2f(vertices1[6].u, vertices1[6].v);
        glVertex4f(vertices1[6].x, vertices1[6].y, vertices1[6].z,w);
        glTexCoord2f(vertices1[7].u, vertices1[7].v);
        glVertex4f(vertices1[7].x, vertices1[7].y, vertices1[7].z,w);
    glEnd();

    glBindTexture(GL_TEXTURE_2D, tex2);
    glBegin(GL_TRIANGLE_FAN);
        if (tex1 != tex2) glColor4f(0.0, 1.0, 0.0, alpha);
        glTexCoord2f(vertices2[0].u, vertices2[0].v);
        glVertex4f(vertices2[0].x, vertices2[0].y, vertices2[0].z,w);
        if (tex1 != tex2) glColor4f(0.7, 0.7, 0.7, alpha);
        glTexCoord2f(vertices2[1].u, vertices2[1].v);
        glVertex4f(vertices2[1].x, vertices2[1].y, vertices2[1].z,w);
        glTexCoord2f(vertices2[2].u, vertices2[2].v);
        glVertex4f(vertices2[2].x, vertices2[2].y, vertices2[2].z,w);
        glTexCoord2f(vertices2[3].u, vertices2[3].v);
        glVertex4f(vertices2[3].x, vertices2[3].y, vertices2[3].z,w);
        glTexCoord2f(vertices2[4].u, vertices2[4].v);
        glVertex4f(vertices2[4].x, vertices2[4].y, vertices2[4].z,w);
        glTexCoord2f(vertices2[5].u, vertices2[5].v);
        glVertex4f(vertices2[5].x, vertices2[5].y, vertices2[5].z,w);
        glTexCoord2f(vertices2[6].u, vertices2[6].v);
        glVertex4f(vertices2[6].x, vertices2[6].y, vertices2[6].z,w);
        glTexCoord2f(vertices2[7].u, vertices2[7].v);
        glVertex4f(vertices2[7].x, vertices2[7].y, vertices2[7].z,w);
    glEnd();
}

static void drawCubeStrip(GLint tex1, GLint tex2)
{
    GLfloat w = 1.0;

    if (tex1 == tex2) w = inf_w;

    glBindTexture(GL_TEXTURE_2D, tex1);
    glBegin(GL_TRIANGLE_STRIP);
       //glColor3f(1.0, 0.0, 0.0);
        glTexCoord2f(verticesS1[0].u, verticesS1[0].v);
        glVertex4f(verticesS1[0].x, verticesS1[0].y, verticesS1[0].z,w);
         if (tex1 != tex2) glColor4f(0.7, 0.7, 0.7, alpha);
        glTexCoord2f(verticesS1[1].u, verticesS1[1].v);
        glVertex4f(verticesS1[1].x, verticesS1[1].y, verticesS1[1].z,w);
        glTexCoord2f(verticesS1[2].u, verticesS1[2].v);
        glVertex4f(verticesS1[2].x, verticesS1[2].y, verticesS1[2].z,w);
        glTexCoord2f(verticesS1[3].u, verticesS1[3].v);
        glVertex4f(verticesS1[3].x, verticesS1[3].y, verticesS1[3].z,w);
        glTexCoord2f(verticesS1[4].u, verticesS1[4].v);
        glVertex4f(verticesS1[4].x, verticesS1[4].y, verticesS1[4].z,w);
        glTexCoord2f(verticesS1[5].u, verticesS1[5].v);
        glVertex4f(verticesS1[5].x, verticesS1[5].y, verticesS1[5].z,w);
        glTexCoord2f(verticesS1[6].u, verticesS1[6].v);
        glVertex4f(verticesS1[6].x, verticesS1[6].y, verticesS1[6].z,w);
        glTexCoord2f(verticesS1[7].u, verticesS1[7].v);
        glVertex4f(verticesS1[7].x, verticesS1[7].y, verticesS1[7].z,w);
    glEnd();

    glBindTexture(GL_TEXTURE_2D, tex2);
    glBegin(GL_TRIANGLE_STRIP);
        if (tex1 != tex2) glColor4f(0.0, 1.0, 0.0, alpha);
        glTexCoord2f(verticesS2[0].u, verticesS2[0].v);
        glVertex4f(verticesS2[0].x, verticesS2[0].y, verticesS2[0].z,w);
        if (tex1 != tex2) glColor4f(0.7, 0.7, 0.7, alpha);
        glTexCoord2f(verticesS2[1].u, verticesS2[1].v);
        glVertex4f(verticesS2[1].x, verticesS2[1].y, verticesS2[1].z,w);
        glTexCoord2f(verticesS2[2].u, verticesS2[2].v);
        glVertex4f(verticesS2[2].x, verticesS2[2].y, verticesS2[2].z,w);
        glTexCoord2f(verticesS2[3].u, verticesS2[3].v);
        glVertex4f(verticesS2[3].x, verticesS2[3].y, verticesS2[3].z,w);
        glTexCoord2f(verticesS2[4].u, verticesS2[4].v);
        glVertex4f(verticesS2[4].x, verticesS2[4].y, verticesS2[4].z,w);
        glTexCoord2f(verticesS2[5].u, verticesS2[5].v);
        glVertex4f(verticesS2[5].x, verticesS2[5].y, verticesS2[5].z,w);
        glTexCoord2f(verticesS2[6].u, verticesS2[6].v);
        glVertex4f(verticesS2[6].x, verticesS2[6].y, verticesS2[6].z,w);
        glTexCoord2f(verticesS2[7].u, verticesS2[7].v);
        glVertex4f(verticesS2[7].x, verticesS2[7].y, verticesS2[7].z,w);
    glEnd();
}

#if !defined (__STORM__) && !defined (__VBCC__)
static
#endif
inline void myVertex(int i)
{
    glTexCoord2f(vertices1[i].u, vertices1[i].v);
    glVertex3f(vertices1[i].x, vertices1[i].y, vertices1[i].z);
}

#if !defined (__STORM__) && !defined (__VBCC__)

static
#endif
inline void myVertex2(int i)
{
    glTexCoord2f(vertices2[i].u, vertices2[i].v);
    glVertex3f(vertices2[i].x, vertices1[i].y, vertices2[i].z);
}

static void drawCubeQuad(GLint tex1, GLint tex2)
{
    glDisable(GL_TEXTURE_2D);
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
    glEnable(GL_TEXTURE_2D);
}

static void drawCubePoly(GLint tex1, GLint tex2)
{
    glDisable(GL_TEXTURE_2D);
    glBegin(GL_POLYGON);
        glColor3f(1.0, 0.0, 0.0);
        glVertex3f(-1,-1,-1); glColor3f(0.5, 0.5, 0.5);
        glVertex3f(-1,1,-1); glVertex3f(1,1,-1); glVertex3f(1,-1,-1);
    glEnd();
    glBegin(GL_POLYGON);
        glColor3f(1.0, 0.5, 0.0);
        glVertex3f(-1,1,-1); glColor3f(0.5, 0.5, 0.5);
        glVertex3f(-1,1,1); glVertex3f(1,1,1); glVertex3f(1,1,-1);
    glEnd();
    glBegin(GL_POLYGON);
        glColor3f(0.0, 1.0, 0.0);
        glVertex3f(1,1,-1); glColor3f(0.5, 0.5, 0.5);
        glVertex3f(1,1,1); glVertex3f(1,-1,1); glVertex3f(1,-1,-1);
    glEnd();
    glBegin(GL_POLYGON);
        glColor3f(0.0, 0.0, 1.0);
        glVertex3f(1,1,1); glColor3f(0.5, 0.5, 0.5);
        glVertex3f(-1,1,1); glVertex3f(-1,-1,1); glVertex3f(1,-1,1);
    glEnd();
    glBegin(GL_POLYGON);
        glColor3f(0.0, 0.0, 0.0);
        glVertex3f(-1,1,1); glColor3f(0.5, 0.5, 0.5);
        glVertex3f(-1,1,-1); glVertex3f(-1,-1,-1); glVertex3f(-1,-1,1);
    glEnd();
    glBegin(GL_POLYGON);
        glColor3f(1.0, 1.0, 1.0);
        glVertex3f(-1,-1,1); glColor3f(0.5, 0.5, 0.5);
        glVertex3f(-1,-1,-1);
        glVertex3f(1,-1,-1);
        glVertex3f(1,-1,1);
    glEnd();
    glEnable(GL_TEXTURE_2D);
}


typedef void (*drawFunc)(GLint, GLint);

drawFunc funcs[] =
{
    drawCubeFan,
    drawCubeStrip,
    drawCubeQuad,
    drawCubePoly,
    NULL,
};

static void (*drawCube)(GLint, GLint) = drawCubeFan;

void Rot1(void)
{
    glLoadIdentity();
    glTranslatef(0.f, 0.f, -8.f);
    glRotatef(angle, 0.f, 1.f, 1.f);
}

void Rot2(void)
{
    glLoadIdentity();
    glTranslatef(1.0, 3.0, -8.f);
    glRotatef(-angle, 0.f, 1.f, 1.f);
    glScalef(0.8, 2.0, 1.2);
}

void Rot3(void)
{
    glLoadIdentity();
    glTranslatef(-3.0, 2.0, -7.0);

//    glRotatef(-90, 1,0,0);
    glRotatefEXTs(-1.f, 0.f, GLROT_100);

//    glRotatef(90, 0,0,1);
    glRotatefEXTs(1.f, 0.f, GLROT_001);

//    glRotatef(angle, 1.0, 0.0, 0.0);
    glRotatefEXT(angle, GLROT_100);

//    glRotatef(-angle, 0.0, 1.0, 0.0);
    glRotatefEXT(-angle, GLROT_010);

//    glRotatef(angle/2.0, 0.0, 0.0, 1.0);
    glRotatefEXT(angle/2.0, GLROT_001);

    glRotatef(-angle, 1.0, 1.0, 1.0);
}

void Rot4(void)
{
    glLoadIdentity();
    glTranslatef(3.0, 3.0, -10.0);
//    glRotatef(2.0*angle, 0.0, 0.0, 1.0);
    glRotatefEXT(2.0*angle, GLROT_001);
}

void Rot5(void)
{
    glScalef(20.0, 20.0, 20.0);
}


static
GLboolean draw(void)
{
    static int framecount = 0;
    ULONG fracsecs;
    static  char buffer[256];
    struct Window *win = mglGetWindowHandle();


    #ifndef NODRAW
    if (GL_FALSE == mglLockDisplay())
    {
        printf("Unable to lock drawing area\n");
        return GL_FALSE;
    }

    glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    #endif


    if (alpha != 1.0)
    {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }

    glEnable(GL_TEXTURE_2D);

    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glLoadIdentity();
    //MakeRot(mouse_angle_x, mouse_angle_y);
    MakeRot(angle, angle);
    Rot5();
    glFrontFace(GL_CW);
    glColor4f(1.f, 1.f, 1.f, 1.f);
    drawCube(3,3);
    glFrontFace(GL_CCW);

    if (alpha != 1.0) glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);

    Rot1();
    glColor4f(1.0, 1.0, 0.0, alpha);
    drawCube(1,2);

    Rot2();
    glColor4f(1.0, 0.0, 0.0, alpha);
    drawCube(1,2);

    Rot3();
    glColor4f(0.0, 0.0, 1.0, alpha);
    drawCube(1,2);

    Rot4();
    glColor4f(0.0, 1.0, 1.0, alpha);
    drawCube(1,2);

    #ifndef NODRAW
    mglUnlockDisplay();
    #endif

    mglSwitchDisplay();
    framecount++;

    if (fogon == GL_TRUE)
    {
        Move(win->RPort, 10, win->Height-5);
        sprintf(buffer, "S: %6.3f E: %6.3f", fog_start, fog_end);
        Text(win->RPort, buffer, strlen(buffer));
    }

    fracsecs  = ElapsedTime(&eval);
    fracsecs &= 0xFFFF;

    fps = 65536.0/(float)(fracsecs+1);
    
    Move(win->RPort, win->Width - 65, 14);
    sprintf(buffer, "fps:%4.2f", fps);
    Text(win->RPort, buffer, strlen(buffer));

    return GL_TRUE;
//    return GL_FALSE;
}

static GLboolean idle (void)
{
  return draw ();
}

static void reshape(int width, int height, int offset, float fov)
{
    GLfloat fog_color[4] = {0.6, 0.3, 0.1, 1.0};
    glFogfv(GL_FOG_COLOR, fog_color);
    glFogf(GL_FOG_MODE, GL_LINEAR);
    glFogf(GL_FOG_START, 1.5);
    glFogf(GL_FOG_END,   fog_end);


    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(fov, 1.3333333, 1.0, (GLdouble)zback);

    glMatrixMode(GL_MODELVIEW);
    glViewport(offset,offset, (GLint)width-2*offset, (GLint)height-2*offset);
    glClearColor(0.0f, 0.f, 0.f, 1.f);
    glClearDepth(zclear);
    glEnable(GL_TEXTURE_2D);
    if (alpha == 1.0) glEnable(GL_CULL_FACE);
    else              glDisable(GL_CULL_FACE);

}

void ClampMouse(struct Window *window, int x, int y, GLboolean left, GLboolean right)
{
    if (left == GL_FALSE && right == GL_FALSE)
    {
        mouse_x = (GLfloat)x/(GLfloat)(window->Width)*8.0;
        mouse_y = (GLfloat)(window->Height - y)/(GLfloat)(window->Height)*8.0;
        if (mouse_x > 8.0) mouse_x = 8.0;
        if (mouse_y > 8.0) mouse_y = 8.0;
        if (mouse_x < 0.0) mouse_x = 0.0;
        if (mouse_y < 0.0) mouse_y = 0.0;
        mouse_x -= 4.0;
        mouse_y -= 4.0;
        mouse_x *= 2.0;
        mouse_y *= 2.0;
    }
    else
    if (left == GL_TRUE && right == GL_FALSE)
    {
        mouse_z = (GLfloat)y/(GLfloat)(window->Height)*15.0;
        if (mouse_z > 15.0) mouse_z = 15.0;
        if (mouse_z < 0.0) mouse_z = 0.0;
        mouse_z -= 5.0;
    }
    else
    if (left == GL_FALSE && right == GL_TRUE)
    {
        mouse_angle_x = (GLfloat)x/(GLfloat)(window->Width)*360.0;
        mouse_angle_y = (GLfloat)y/(GLfloat)(window->Height)*360.0;
    }
}


GLenum LockMode = MGL_LOCK_SMART;

void IdleHandler(void)
{
    angle+=1.0;
    idle();
}

static int fixpointtrans = GL_NICEST; // T switches routine
static GLenum shade = GL_SMOOTH;


void initFog(void)
{
	GLfloat fogColor[] = {0.5f, 0.5f, 0.5f};

	glEnable(GL_FOG);

	glFogi(GL_FOG_MODE, GL_EXP2);
	glFogf(GL_FOG_DENSITY, 0.025f);
	glFogfv(GL_FOG_COLOR, fogColor);
}

void KeyHandler(char key)
{
    struct Window *window;
    static int drawfn = 0;
    static GLenum WHint = GL_DONT_CARE;
    window = (struct Window *)mglGetWindowHandle();

    switch(key)
    {
	  case 'F': 
            if (fogon == GL_FALSE)
            {
                initFog();
                fogon = GL_TRUE;
            }
            else
            {
                glDisable(GL_FOG);
                fogon = GL_FALSE;
            }
            break;
	  case 'g':
	      if (shade == GL_SMOOTH)
		{
			glShadeModel(GL_FLAT);
			shade = GL_FLAT;
		}
		else
		{
			glShadeModel(GL_SMOOTH);
			shade = GL_SMOOTH;
		}
		break;
        case '1':
            if (WHint == GL_DONT_CARE) WHint = GL_FASTEST;
            else                       WHint = GL_DONT_CARE;
            glHint(MGL_W_ONE_HINT, WHint);
            break;
        case 's':
            if (sync == GL_FALSE)   sync = GL_TRUE;
            else                sync = GL_FALSE;
            mglEnableSync(sync);
            break;
        case '8':
            fog_end++; if (fog_end > zback) fog_end = zback;
            glFogf(GL_FOG_END, fog_end);
            break;
        case '5':
            fog_end--; if (fog_end < fog_start) fog_end = fog_start;
            glFogf(GL_FOG_END, fog_end);
            break;
        case '7':
            fog_start++; if (fog_start > fog_end) fog_start = fog_end;
            glFogf(GL_FOG_START, fog_start);
            break;
        case '4':
            fog_start--; if (fog_start < 1.5) fog_start = 1.5;
            glFogf(GL_FOG_START, fog_start);
            break;
        case 'f':
            if (fogon == GL_FALSE)
            {
                glEnable(GL_FOG);
                fogon = GL_TRUE;
            }
            else
            {
                glDisable(GL_FOG);
                fogon = GL_FALSE;
            }
            break;
        case 'd':
            drawfn++; if (funcs[drawfn] == NULL) drawfn = 0;
            drawCube = funcs[drawfn];
            break;
        case 27:
            mglExit();
            break;
        case '+':
            if (zclear < 1.0) zclear += 0.01;
            if (zclear > 1.0) zclear = 1.0;
            glClearDepth(zclear);
            break;
        case '-':
            if (zclear > 0.0) zclear -= 0.01;
            if (zclear < 0.0) zclear = 0.0;
            glClearDepth(zclear);
            break;
        case 'e':
            mouse_z = 10.0;
            break;
        case 'w':
            offset += 10;
            if (offset >=100) offset = 100;
            reshape((int)window->Width,(int)window->Height, offset, fov);
            break;
        case 'q':
            offset -= 10;
            if (offset <=0) offset = 0;
            reshape((int)window->Width,(int)window->Height, offset, fov);
        case 't':
		glHint(MGL_FIXPOINTTRANS_HINT, fixpointtrans);
		if(fixpointtrans == GL_FASTEST)
			fixpointtrans = GL_NICEST;
		else
			fixpointtrans = GL_FASTEST;
            break;
        case 'y':
            fov += 2.0;
            if (fov>180.0) fov = 180.0;
            reshape((int)window->Width,(int)window->Height, offset, fov);
            break;
        case 'x':
            fov -= 2.0;
            if (fov<40.0) fov = 40.0;
            reshape((int)window->Width,(int)window->Height, offset, fov);
            break;
        case 'z':
            if (zbuffer == GL_TRUE)
            {
                zbuffer = GL_FALSE;
                glDisable(GL_DEPTH_TEST);
            }
            else
            {
                zbuffer = GL_TRUE;
                glEnable(GL_DEPTH_TEST);
            }
            break;
        case 'r':
            ReplaceTexture();
            break;
    }
}

void MouseHandler(GLint MouseX, GLint MouseY, GLbitfield buttons)
{
}

void MainLoop(void)
{
    struct Window *window;


    window = (struct Window *)mglGetWindowHandle();

    TexInit();

    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

    reshape((int)window->Width,(int)window->Height, offset, fov);
    ElapsedTime(&eval);
    SetAPen(window->RPort, 2);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);

    mglLockMode(LockMode);
    mglKeyFunc(KeyHandler);
    mglMouseFunc(MouseHandler);
    mglIdleFunc(IdleHandler);

    mglMainLoop();
}

int main(int argc, char **argv)
{
    int i;
    int numb=3, resnr=0;
    GLint width=320; GLint height=240;

    printf("Calling MGLInit...\n");
    PrInit();
    MGLInit();

    for (i=1; i<argc; i++)
    {
        if (0 == strcmp(argv[i], "-window"))
        {
            mglChooseWindowMode(GL_TRUE);
        }
        else if (0 == strcmp(argv[i], "-zback"))
        {
            i++;
            zback = (GLfloat)atof(argv[i]);
        }
        else if (0 == strcmp(argv[i], "-w"))
        {
            i++;
            inf_w = (GLfloat)atof(argv[i]);
        }
        else if (0 == strcmp(argv[i], "-buffers"))
        {
            i++;
            numb = atoi(argv[i]);
        }
        else if (0 == strcmp(argv[i], "-res"))
        {
            i++;
            resnr = atoi(argv[i]);
        }
        else if (0 == strcmp(argv[i], "-alpha"))
        {
            i++;
            alpha = atof(argv[i]);
        }
        else if (0 == strcmp(argv[i], "-lock"))
        {
            i++;
            if (0 == stricmp(argv[i], "manual"))
            {
                LockMode = MGL_LOCK_MANUAL;
            }
            else if (0 == stricmp(argv[i], "auto"))
            {
                LockMode = MGL_LOCK_AUTOMATIC;
            }
            else if (0 == stricmp(argv[i], "smart"))
            {
                LockMode = MGL_LOCK_SMART;
            }
            else printf("Unknown lockmode. Using default\n");
        }
        else
        {
            printf("Unknown option %s\n", argv[i]);
            printf("Usage: %s -zback <float> -w <float> -res <int> -lock (manual|auto|smart) -buffers <int>\n", argv[0]);
            exit(0);
        }
    }

    ResPtr = resnr;
    CurrentRes = Resolutions[ResPtr].name;

    fog_start = 1.5;
    fog_end = 100.0;

    //mglSetDebugLevel(10);
    printf("Setting number of buffers to %d...\n", numb);
    mglChooseNumberOfBuffers(numb);
    printf("Setting pixel depth to 16...\n");
    mglChoosePixelDepth(16);
    printf("Creating context...\n");

    width = Resolutions[ResPtr].width;
    height = Resolutions[ResPtr].height;

    if (mglCreateContext(0,0, Resolutions[ResPtr].width, Resolutions[ResPtr].height))
    {
        if (alpha != 1.0) glShadeModel(GL_FLAT);
        printf("Switching sync...\n");
        mglEnableSync(GL_TRUE);

        printf("Going into main loop...\n");

        MainLoop();
        printf("Done\n");
        mglDeleteContext();
    }
/*
    else (mglCreateContextFromID(0x50011102,&width,&height))
    {
        if (alpha != 1.0) glShadeModel(GL_FLAT);
        printf("Switching sync...\n");
        mglEnableSync(GL_TRUE);
        printf("Going into main loop...\n");

        MainLoop();
        printf("Done\n");
        mglDeleteContext();
    }
*/
    else 
    {
        printf("Error: Can't mglCreateContext()\n");
    }

    MGLTerm();
    PrExit();
    return 0;
}


