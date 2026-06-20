/* Compile me to get full executable. */

#include <stdio.h>
#include "iraGUI.c"

/* Cut the core out of this function and edit it suitably. */

STATIC void ProcessWindowIRAPref0( LONG Class, UWORD Code, APTR IAddress )
{
struct Gadget *gad;
switch ( Class )
	{
	case IDCMP_GADGETUP :
		/* Gadget message, gadget = gad. */
		gad = (struct Gadget *)IAddress;
		switch ( gad->GadgetID ) 
			{
			case Win0_Gad0 :
				/* Cycle changed   , Text of gadget : CPU */
				break;
			case Win0_Gad1 :
				/* Cycle changed   , Text of gadget : FPU */
				break;
			case Win0_Gad2 :
				/* Cycle changed   , Text of gadget : MMU */
				break;
			case IRAPref0_Gad3 :
				/* CheckBox changed, Text of gadget : Append address and data. */
				break;
			case IRAPref0_Gad4 :
				/* CheckBox changed, Text of gadget : Show hunkstructure. */
				break;
			case IRAPref0_Gad5 :
				/* CheckBox changed, Text of gadget : Scan for data/text and code. */
				break;
			case IRAPref0_Gad6 :
				/* CheckBox changed, Text of gadget : Load configfile. */
				break;
			case IRAPref0_Gad7 :
				/* CheckBox changed, Text of gadget : Put each section in its own file. */
				break;
			case IRAPref0_Gad10 :
				/* CheckBox changed, Text of gadget : Keep binary data. */
				break;
			case IRAPref0_Gad11 :
				/* CheckBox changed, Text of gadget : Leave empty hunks away. */
				break;
			case IRAPref0_Gad13 :
				/* String entered  , Text of gadget : Offset to relocate at. */
				break;
			case IRAPref0_Gad14 :
				/* String entered  , Text of gadget : Entry of code scanning. */
				break;
			case IRAPref0_Gad15 :
				/* Cycle changed   , Text of gadget : Base register */
				break;
			case IRAPref0_Gad16 :
				/* String entered  , Text of gadget : Base address. */
				break;
			case IRAPref0_Gad17 :
				/* String entered  , Text of gadget : Base section. */
				break;
			case IRAPref0_Gad18 :
				/* Button pressed  , Text of gadget : Save */
				break;
			case IRAPref0_Gad19 :
				/* Button pressed  , Text of gadget : Use */
				break;
			case IRAPref0_Gad20 :
				/* Button pressed  , Text of gadget : Cancel */
				break;
			}
		break;
	case IDCMP_CLOSEWINDOW :
		/* CloseWindow Now */
		break;
	case IDCMP_REFRESHWINDOW :
		GT_BeginRefresh( IRAPref0);
		/* Refresh window. */
	RendWindowIRAPref0( IRAPref0, IRAPref0VisualInfo );
		GT_EndRefresh( IRAPref0, TRUE);
	GT_RefreshWindow( IRAPref0, NULL);
	RefreshGList( IRAPref0GList, IRAPref0, NULL, ~0);
		break;
	}
}


int main(void)
{
int done=0, rc = RETURN_FAIL;
ULONG class;
UWORD code;
struct Gadget *pgsel;
struct IntuiMessage *imsg;
if (OpenLibs()==0)
	{
	OpenbaseCatalog(NULL,NULL);
	OpenDiskFonts();
	if (OpenWindowIRAPref0()==0)
		{
			rc = RETURN_OK;
		while(done==0)
			{
			Wait(1L << IRAPref0->UserPort->mp_SigBit);
			imsg=GT_GetIMsg(IRAPref0->UserPort);
			while (imsg != NULL )
				{
				class=imsg->Class;
				code=imsg->Code;
				pgsel=(struct Gadget *)imsg->IAddress; /* Only reference if it is a gadget message */
				GT_ReplyIMsg(imsg);
				ProcessWindowIRAPref0(class, code, pgsel);
				/* The next line is just so you can quit, remove when proper method implemented. */
				if (class==IDCMP_CLOSEWINDOW)
					done=1;
				imsg=GT_GetIMsg(IRAPref0->UserPort);
				}
			}
		
		CloseWindowIRAPref0();
		}
	else
		printf("Cannot open window.\n");
	ClosebaseCatalog();
	CloseLibs();
	}
else
	printf("Cannot open libraries.\n");

	return rc;
}
