#include <images/xpm.h>
#include <clib/xpm_protos.h>

#include <proto/exec.h>
#include <proto/intuition.h>


Class  *xpm_class;
#define XPM_GetClass()   (xpm_class)


int
main (
    int    argc,
    char **argv)
{
    struct Screen   *scr;
    struct Image    *img;
    struct Window   *win;
    struct Message  *msg;

    if (argc != 2)
	return 5;

    xpm_class = CreateXpmClass ();
    if (xpm_class != NULL)
    {
	scr = LockPubScreen (NULL);
	if (scr != NULL)
	{
	    img = NewObject (XPM_GetClass (), NULL,
			     XPM_ColorMap, scr->ViewPort.ColorMap,
			     XPM_XpmFile, argv[1],
			     IA_Width, 40,
			     IA_Height, 40,
			     TAG_DONE);
	    if (img != NULL)
	    {
		win = OpenWindowTags (NULL,
				      WA_InnerWidth, img->Width,
				      WA_InnerHeight, img->Height,
				      WA_Title, argv[1],
				      WA_DragBar, TRUE,
				      WA_DepthGadget, TRUE,
				      WA_CloseGadget, TRUE,
				      WA_IDCMP, IDCMP_CLOSEWINDOW,
				      TAG_DONE);
		if (win != NULL)
		{
		    DrawImageState (win->RPort, img,
				    win->BorderLeft, win->BorderTop,
				    IDS_NORMAL, NULL);

		    WaitPort (win->UserPort);
		    while (msg = GetMsg (win->UserPort))
			ReplyMsg (msg);

		    CloseWindow (win);
		}

		DisposeObject (img);
	    }

	    UnlockPubScreen (NULL, scr);
	}

	DisposeXpmClass (xpm_class);
    }

    return 0;
}
