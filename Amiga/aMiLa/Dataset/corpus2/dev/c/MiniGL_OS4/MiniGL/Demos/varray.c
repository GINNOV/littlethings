#include <mgl/gl.h>
#include <proto/dos.h>
#include <stdio.h>
#include <stdlib.h>

;// Tri_FFF
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
;;//
;// Tri_F_RGB
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
;;//


int main()
{
    GLenum err;
	MGLInit();

	mglChooseNumberOfBuffers(2);
	mglChoosePixelDepth(16);
	mglChooseWindowMode(GL_TRUE);

	if (mglCreateContext(0, 0, 640, 480))
	{
		glViewport(0, 0, 640, 480);

		glDisable(GL_CULL_FACE);

		glClearColor(0.0, 0.0, 0.0, 1.0);
		glClear(GL_COLOR_BUFFER_BIT);

		glEnableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);

		glColorPointer(3, GL_FLOAT, 3*sizeof(float), Tri_F_RGB);
		glVertexPointer(3, GL_FLOAT, 3*sizeof(float), (void *)Tri_FFF);

		glDrawArrays(GL_TRIANGLES, 0, 18);
		err = glGetError();

		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);

		mglSwitchDisplay();
		Delay(50);

		mglDeleteContext();
	}

	MGLTerm();

	return 0;
}
