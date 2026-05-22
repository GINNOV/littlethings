/* Compile me to get full executable. */

#include <stdio.h>
#include "togbutsample.c"

/* Cut the core out of this function and edit it suitably. */

void ProcessWindowWin0( LONG Class, UWORD Code, APTR IAddress )
{
struct Gadget *gad;
switch ( Class )
	{
	case IDCMP_GADGETUP :
		/* Gadget message, gadget = gad. */
		gad = (struct Gadget *)IAddress;
		switch ( gad->GadgetID )
			{
			case tAbout :
				break;
			case bDegistir :
				/* Button pressed  , Text of gadget : Degistir */
				//Win0Gadgets[0]->Flags |= SELECTED; // SELECTED Flag is set (ON)
				//Win0Gadgets[0]->Flags -= SELECTED; // SELECTED Flag is clear (OFF)

				//SetGadgetAttrs(Win0Gadgets[0], Win0, NULL, SELECTED, TRUE, TAG_DONE);

				if ((Win0Gadgets[0]->Flags) & SELECTED)
				{
					Win0Gadgets[0]->Flags &= ~SELECTED; // SELECTED Flag is clear (OFF)
					printf("SELECTED Flag is clear (OFF)\n");
				}
				else
				{
					Win0Gadgets[0]->Flags |= SELECTED; // SELECTED Flag is set (ON)
					printf("SELECTED Flag is set (ON)\n");
				}

				GT_RefreshWindow( Win0, NULL);
				RefreshGList( Win0GList, Win0, NULL, ~0);
				printf("Ok\n\n" );
				break;
			}
		break;
	case IDCMP_CLOSEWINDOW :
		/* CloseWindow Now */
		break;
	case IDCMP_REFRESHWINDOW :
		GT_BeginRefresh( Win0);
		/* Refresh window. */
		RendWindowWin0( Win0, Win0VisualInfo );
		GT_EndRefresh( Win0, TRUE);
		GT_RefreshWindow( Win0, NULL);
		RefreshGList( Win0GList, Win0, NULL, ~0);
		break;
	}
}


int main(void)
{
int done=0;
ULONG clas;
UWORD code;
struct Gadget *pgsel;
struct IntuiMessage *imsg;
if (OpenLibs()==0)
	{
	OpenbaseCatalog(NULL,NULL);
	if (MakeImages()==0)
		{
		if (OpenWindowWin0()==0)
			{
			while(done==0)
				{
				Wait(1L << Win0->UserPort->mp_SigBit);
				imsg=GT_GetIMsg(Win0->UserPort);
				while (imsg != NULL )
					{
					clas=imsg->Class;
					code=imsg->Code;
					pgsel=(struct Gadget *)imsg->IAddress; /* Only reference if it is a gadget message */
					GT_ReplyIMsg(imsg);
					ProcessWindowWin0(clas, code, pgsel);
					/* The next line is just so you can quit, remove when proper method implemented. */
					if (clas==IDCMP_CLOSEWINDOW)
						done=1;
					imsg=GT_GetIMsg(Win0->UserPort);
					}
				}

			CloseWindowWin0();
			}
		else
			printf("Cannot open window.\n");
		FreeImages();
		}
	else
		printf("Cannot make images.\n");
	ClosebaseCatalog();
	CloseLibs();
	}
else
	printf("Cannot open libraries.\n");
}
