;/*
gcc -noixemul -O2 color_chooser.c -s -o color_chooser
quit
;*/

#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/muimaster.h>

int main()
{
	int rc = RETURN_FAIL;
	APTR app, win, chooser;

	app = ApplicationObject,
			MUIA_Application_Base, "COLORCHOOSERDEMO",
			MUIA_Application_Title, "Color Chooser Demo",
			SubWindow, win = WindowObject,
				MUIA_Window_Title, "Color Chooser Demo",
				WindowContents, VGroup,
					Child, chooser = ColoradjustObject, End,
				End,
			End,
		End;

	if (app)
	{
		ULONG *rgb;

		DoMethod(win, MUIM_Notify, MUIA_Window_CloseRequest, TRUE, app, 2, MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit);
		set(win, MUIA_Window_Open, TRUE);
		DoMethod(app, MUIM_Application_Run);

		GetAttr(MUIA_Coloradjust_RGB, chooser, (ULONG *)&rgb);
		Printf("Red  : 0x%08lx\n", rgb[0]);
		Printf("Green: 0x%08lx\n", rgb[1]);
		Printf("Blue : 0x%08lx\n", rgb[2]);

		MUI_DisposeObject(app);
	}

	rc = RETURN_OK;

	return rc;
}
