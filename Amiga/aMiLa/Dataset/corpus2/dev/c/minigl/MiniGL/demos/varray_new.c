#include <mgl/gl.h>

#include <stdio.h>
#include <stdlib.h>

#ifdef __VBCC__
	#pragma amiga-align
#endif

#include <proto/dos.h>

#ifdef __VBCC__
	#pragma default-align
#endif

unsigned short index[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17};

// Tri_FFF
float Tri_FFF[] =
{
     10.0, 210.0, 0.0,
    210.0, 210.0, 0.0,
    110.0,  10.0, 0.0,

     10.0, 230.0, 0.0,
    210.0, 230.0, 0.0,
    110.0, 430.0, 0.0,

    220.0, 210.0, 0.0,
    420.0, 210.0, 0.0,
    320.0,  10.0, 0.0,

    220.0, 230.0, 0.0,
    420.0, 230.0, 0.0,
    320.0, 430.0, 0.0,

    430.0, 210.0, 0.0,
    630.0, 210.0, 0.0,
    530.0,  10.0, 0.0,

    430.0, 230.0, 0.0,
    630.0, 230.0, 0.0,
    530.0, 430.0, 0.0

};


// Tri_F_RGB
float Tri_F_RGB[] =
{
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0,

    1.0, 1.0, 0.0,
    0.0, 1.0, 1.0,
    1.0, 0.0, 1.0,

    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0,

    1.0, 1.0, 0.0,
    0.0, 1.0, 1.0,
    1.0, 0.0, 1.0,

    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0,

    1.0, 1.0, 0.0,
    0.0, 1.0, 1.0,
    1.0, 0.0, 1.0
};


int main()
{
    int i;
    GLenum err;

	MGLInit();

	mglChooseNumberOfBuffers(2);
	mglChoosePixelDepth(16);
	mglChooseWindowMode(GL_TRUE);

	if (mglCreateContext(0, 0, 640, 480))
	{
		glViewport(0, 0, 640, 480);

		glDisable(GL_CULL_FACE);

//Surgeon begin -->
	//test the pipeline for transform, project and clip:
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity ();
		glOrtho (0, 640, 480, 0, -99999, 99999);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity ();
		glRotatef(30, 0, 0, 1);
		glRotatef(30, 0, 1, 0);
		glRotatef(30, 1, 0, 0);

		mglLockDisplay();
// <-- Surgeon end


		glClearColor(0.0, 0.0, 0.0, 1.0);
		glClear(GL_COLOR_BUFFER_BIT);


		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);

		//turn off the vertexarray pipeline:
		//glDisable(MGL_ARRAY_TRANSFORMATIONS);

		glColorPointer(3, GL_FLOAT, 3*sizeof(float), Tri_F_RGB);
		glVertexPointer(3, GL_FLOAT, 3*sizeof(float), (void *)Tri_FFF);

		for(i=0; i<18; i+=3)
		glDrawArrays(GL_POLYGON, i, 3);

//		glDrawArrays(GL_TRIANGLES, 0, 18);

		err = glGetError();

		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);

		mglSwitchDisplay();

		Delay(50);

		mglDeleteContext();
	}

	MGLTerm();

	return 0;
}
