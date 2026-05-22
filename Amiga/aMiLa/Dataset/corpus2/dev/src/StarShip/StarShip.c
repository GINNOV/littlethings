/* StarShip.c : Draw a textured 3D object with 148 lines of code
Compiled with GCC. Use StormMesa libraries (needed)
This Free Source example come from Dream/Login Magazine #69	
Alain Thellier enhanced it a lot in August 2008			
This example show how to use the						
super-function glDrawElements() to draw a textured object	
with OpenGL/StormMesa the simplest way	with 148 lines of code	
If OpenGL was too difficult for you this example will change your mind */

/* StarShip.c : Trace un objet 3D texture avec 148 lignes de code
Compile avec GCC. Bibliotheques StormMesa necessaire
Cet exemple libre provenait du Magazine Dream/Login n°69		
Alain Thellier l'a beaucoup ameliore en Aout 2008			
Cet exemple montre comment en utilisant la 				
super-fonction glDrawElements() on peut tracer un objet+texture
avec OpenGL/StormMesa le plus simplement en 148 lignes de code	
Si OpenGL etait trop complique pour toi Tu changera d'avis avec cet exemple */

#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>

static GLfloat xRot = 0.0;
static GLfloat yRot = 0.0;
static GLfloat zRot = 0.0;
GLuint textureID,windowID;
unsigned char *texture=NULL;

#include "StarShip.h"

static void DrawObject(void)
{
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glTexCoordPointer(2, GL_FLOAT, 5*4,&points[0]);
	glVertexPointer(  3, GL_FLOAT, 5*4,&points[2]);
	glBindTexture(GL_TEXTURE_2D, textureID);
	glDrawElements(GL_TRIANGLES, trianglesCount*3, GL_UNSIGNED_INT, indices);

	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
}

static void DisplayFunc(void)
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glPushMatrix();
	glRotatef(xRot, 1.0f, 0.0f, 0.0f);
	glRotatef(yRot, 0.0f, 1.0f, 0.0f);
	glRotatef(zRot, 0.0f, 0.0f, 1.0f);
		DrawObject();
	glPopMatrix();
	glutSwapBuffers();
}


static void IdleFunc(void)
{
	xRot -= 3.0;	yRot += 2.0;	zRot += 1.0;
	if(xRot<0.0) xRot+=360.0; if(360.0<=xRot) xRot-=360.0;
	if(yRot<0.0) yRot+=360.0; if(360.0<=yRot) yRot-=360.0;
	if(zRot<0.0) zRot+=360.0; if(360.0<=zRot) zRot-=360.0;
	glutPostRedisplay();
}

static void ReshapeFunc(GLsizei width, GLsizei height)
{
	GLfloat h = (GLfloat) height / (GLfloat) width;

	glViewport(0, 0,  width,  height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
/*	glFrustum(-1.0, 1.0, -h, h, 0.0, 1.0); */
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslatef(0.0, 0.0,0.0);
}

void VisibilityFunc(int vis)
{
	if (vis == GLUT_VISIBLE)
		glutIdleFunc(IdleFunc);
	else
		glutIdleFunc(NULL);
}

void KeyboardFunc(unsigned char key,int x, int y)
{
   switch (key)
	{
      case 27:
	      glutDestroyWindow(windowID);
		free(texture);
	      exit(1);
 	default:
      	break;
    }
}

int LoadFile(unsigned char *buffer, char* name,long bufferSize)
{
	FILE *fp;
	long size;

	fp = fopen(name,"rb");
	if(fp == NULL)
	{
		printf("Cant open file !\n");
		return 0;
	}

	size = fread(buffer,bufferSize,1,fp);
	if(size ==0 )
	{
		printf("Cant read file !\n");
		return 0;
	}
	fclose(fp);
	return 1;
}

GLuint  LoadTexture(char* name,int size,int bits)
{
unsigned long textureSize = size*size*bits/8;

	texture = (unsigned char *) malloc(textureSize);
	if(texture==NULL)
		{
	      glutDestroyWindow(windowID);
	      exit(1);
		}
	LoadFile(texture,name,textureSize);
	glGenTextures(1,&textureID);
	glBindTexture(GL_TEXTURE_2D, textureID);
	glTexImage2D(GL_TEXTURE_2D,0,bits/8,size,size,0,GL_RGB,GL_UNSIGNED_BYTE, texture);
	glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	return(textureID);
}

int main(int argc, char *argv[])
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DEPTH | GLUT_DOUBLE );
	windowID=glutCreateWindow("StarShip Demo (Esc to exit)");

	LoadTexture(TEXNAME,TEXSIZE,24);

	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glClearColor(0.1f, 0.1f, 0.5f, 1.0f);
	glDisable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);
	glFrontFace(GL_CCW);
	glEnable(GL_CULL_FACE);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

	glutDisplayFunc(DisplayFunc);
	glutReshapeFunc(ReshapeFunc);
	glutVisibilityFunc(VisibilityFunc);
	glutKeyboardFunc(KeyboardFunc);

	glutMainLoop();
	return 0;
}
