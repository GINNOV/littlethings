// This demo demonstrates the "Amiga-specific" display features, like
// screenmode callbacks, and access of the back buffer


#include <stdio.h>
#include <mgl/gl.h>

#include <proto/dos.h>          // For Delay()

GLboolean ScreenModeCallback(MGLScreenMode *mode)
{
	printf("ModeID: %d\n", mode->id);
	printf("   Size is %d×%d\n", mode->width, mode->height);
	printf("   Depth is %d\n", mode->bit_depth);
	printf("   Name is %s\n", mode->mode_name);
	printf("\n");
	return GL_FALSE;
}

GLboolean ScreenModeCallback2(MGLScreenMode *mode)
{
	if (mode->width == 320 && mode->bit_depth==16) return GL_TRUE;
	else return GL_FALSE;
}

int main(int argc, char **argv)
{
	GLint id;
	GLint w, h;
	MGLLockInfo li;

	MGLInit();

	printf("Getting all modes:\n");
	id = mglGetSupportedScreenModes(ScreenModeCallback);
	printf("(Returned id %d)\n",id);
	printf("\n\nTrying to find a mode that satisfies ""Width==320"" and ""bit_depth==16""\n");

	id = mglGetSupportedScreenModes(ScreenModeCallback2);
	printf("Returned id is %d\n", id);

	if (id == -1 || (argc == 2 && 0 == stricmp(argv[1],"-window")))
	{
		mglChooseWindowMode(GL_TRUE);
	}


	mglCreateContext(0, 0, 320, 240);

	if (mglLockBack(&li))
	{
		glClearColor(0.0, 0.0, 0.0, 0.0);
		glClear(GL_COLOR_BUFFER_BIT);
		glFinish();             // <--- Note this glFinish(); It ensures that the clear operation
								//      is really done when we access the back buffer

		memset(li.base_address, 0xff, 20);
		mglUnlockDisplay();
		mglSwitchDisplay();
		Delay(100);


		printf("Display info:\nDimensions:%d×%d×%d\n", li.width, li.height, li.depth);
		printf("Pixel format: %d\n", li.pixel_format);
		printf("Base address: 0x%x\n", li.base_address);
		printf("Pitch: %d\n", li.pitch);
	}
	else
	{
		printf("Unable to lock back buffer\n");
	}

	mglDeleteContext();

	MGLTerm();

	return 0;
}
