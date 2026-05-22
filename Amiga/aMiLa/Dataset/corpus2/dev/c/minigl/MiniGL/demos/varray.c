#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifdef __VBCC__
#include <extra.h>	//OF
#endif

#include <mgl/gl.h>

//#include <StAnDebug.h>

#ifdef __VBCC__
#pragma amiga-align
#endif

#include <proto/dos.h>

#ifdef __VBCC__
#pragma default-align
#endif

GLenum LockMode = MGL_LOCK_MANUAL;


typedef struct myVertex_t
{
	GLfloat x, y, z;
	GLubyte r, g, b, a;
	GLfloat s, t;
} myVertex;


myVertex cube[] =
{
  { -1.0, -1.0, -1.0,  0, 0, 255, 255,  0.5, 0.5 }, // 0
  { -1.0, -1.0,  1.0,  0, 0, 255, 255,  0.5, 0.0 }, // 1
  { -1.0,  1.0,  1.0,  0, 255, 255, 255,  0.0, 0.0 }, // 2
  { -1.0,  1.0, -1.0,  0, 255, 255, 255,  0.0, 0.5 }, // 3
  {  1.0,  1.0,  1.0,  255, 255, 255, 255,  0.5, 0.5 }, // 4
  {  1.0, -1.0,  1.0,  255, 0, 255, 255,  0.5, 0.0 }, // 5
  {  1.0, -1.0, -1.0,  255, 0, 255, 255,  0.0, 0.0 }, // 6
  {  1.0,  1.0, -1.0,  255, 255, 255, 255,  0.5, 0.5 } // 7
};


unsigned char cube_idx[] =
{
	1, 4, 5,  1, 2, 4,      // Front
	5, 6, 7,  5, 4, 7,      // Right
	6, 3, 0,  6, 7, 3,      // Back
	2, 3, 0,  0, 1, 2,      // Left
	2, 4, 3,  2, 4, 7,      // Top
	1, 5, 6,  1, 6, 0       // Bottom
};

/*
note that triangle 3 and triangle 8 can be draw with glDrawArrays - this is exploited with -compiled parameter
to demonstrate the flexibility of compiled arrays
*/

#define NUMIDX sizeof(cube_idx)/sizeof(unsigned char)


int main(int argc, char *argv[])
{
	int i;
	GLuint t = 0;
	GLboolean Compiled_Arrays;
	GLboolean No_Pipeline;

	Compiled_Arrays = GL_FALSE;
	No_Pipeline = GL_FALSE;

	MGLInit();

	mglChooseVertexBufferSize(1024);
	mglChooseNumberOfBuffers(2);
	mglChoosePixelDepth(16);
	mglChooseWindowMode(GL_TRUE);

	for (i=1; i<argc; i++)
	{
         if (0 == strcmp(argv[i], "-lock"))
         {

	   if( (i+1)<argc )	//OF
	   {
	   i++;

            if (0 == stricmp(argv[i], "auto"))
            {
                LockMode = MGL_LOCK_AUTOMATIC;
            }
            else if (0 == stricmp(argv[i], "smart"))
            {
                LockMode = MGL_LOCK_SMART;
            }
            else
            {
                LockMode = MGL_LOCK_MANUAL;
            }
	   }

	   }

	   if (0 == stricmp(argv[i], "-compiled"))
	   {
	   //i++;	//OF (removed)
			Compiled_Arrays = GL_TRUE;
	   }

	   if (0 == stricmp(argv[i], "-bypass"))
	   {
	   //i++;	//OF (removed)
			No_Pipeline = GL_TRUE;
	   }

	}

	if(Compiled_Arrays == GL_TRUE && No_Pipeline == GL_FALSE)
		printf("Using compiled vertexarrays..\n");
	else
		printf("Using standard vertexarrays..\n");

	if(No_Pipeline == GL_TRUE)
		printf("Bypassing transformation pipeline..\n");


	if (mglCreateContext(0, 0, 640, 480))
	{
		mglLockMode(LockMode);	//OF (was called before mglCreateContext())

		if (LockMode == MGL_LOCK_MANUAL)
			mglLockDisplay();

		glViewport(0, 0, 640, 480);

		glDisable(GL_CULL_FACE);

		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(90.0, 1.333333, 0.2, 100.0);

		glMatrixMode(GL_MODELVIEW);
		glTranslatef(0.0, 0.0, -8.0);

		glRotatef(30.0, 1.0, 1.0, 1.0);

		glClearColor(0.0, 0.0, 0.0, 1.0);
		glClear(GL_COLOR_BUFFER_BIT);

		if(No_Pipeline == GL_TRUE)
		{
			glDisable(MGL_ARRAY_TRANSFORMATIONS);
		}

		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);

		//PUTS( "b4 pointers" );

		glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(myVertex), (void *)&cube[0].r);

		glVertexPointer(3, GL_FLOAT, sizeof(myVertex), (void *)cube);

		if(Compiled_Arrays == GL_TRUE && 	No_Pipeline == GL_FALSE)
		{

		glLockArrays(0, 8); //preprocess data

/*
	this could be done with a single glDrawElements call,
	but that is not what this part of the demo is about :)
*/

		glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, (void *)cube_idx);

		glDrawArrays(GL_TRIANGLES, 5, 3);

		glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_BYTE, (void *)&cube_idx[9]);

		glDrawArrays(GL_TRIANGLES, 0, 3);

			glBegin(GL_TRIANGLES);

			for (i=24; i<NUMIDX; i++)
			glArrayElement(cube_idx[i]);

			glEnd();


		glUnlockArrays();

		}
		else
		{
		   if(No_Pipeline == GL_TRUE)					     glDrawElements(W3D_PRIMITIVE_TRIANGLES, NUMIDX, W3D_INDEX_UBYTE, (void *)cube_idx);
		   else
		     glDrawElements(GL_TRIANGLES, NUMIDX, GL_UNSIGNED_BYTE, (void *)cube_idx);
		}

	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);

	mglSwitchDisplay();

	Delay(50);

	mglDeleteContext();
	}

	MGLTerm();
	return 0;
}
