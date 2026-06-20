#define INTUI_V36_NAMES_ONLY

#include <clib/alib_protos.h>
#include <clib/asl_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/icon_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/wb_protos.h>

#include <pragmas/asl_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/icon_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/wb_pragmas.h>

#include <dos.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <exec/nodes.h>
#include <exec/types.h>
#include <intuition/gadgetclass.h>
#include <stdio.h>
#include <string.h>

#include <dos.h>
#include <exec/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"

static char *Version = VERSIONSTRING;
struct PREFS Prefs;

/* Find string in array and return pointer to byte after end
 * or NULL if not found.
*/
STRPTR StringValue(ULONG MaxNum, STRPTR Strings[], STRPTR Search)
{
	UWORD i, srlen;
    STRPTR Result = NULL;

	srlen = strlen(Search);

	for (i=0; i<MaxNum; i++)
	{
		if (strncmp(Strings[i], Search, srlen) == 0)
		{
			Result = (STRPTR)((UBYTE *)Strings[i] + srlen);
			break;
		}
	}

	return (Result);
}


/* Search for a string in an array of strings
 * Return 1 if found, 0 if not.
*/

#define FindString(MaxNum, Strings, Search)	\
	((StringValue(MaxNum, Strings, Search) == NULL) ? 0 : 1)


/* Parse arguments and set trainer values
*/
void PrefsConstructor (ULONG argc, char *argv [])
{
	STRPTR ctrl;

	Prefs.NoGUI     = FindString(argc, argv, "NOGUI");
	Prefs.InfEnergy = FindString(argc, argv, "INF_ENERGY");
	Prefs.InfAmmo   = FindString(argc, argv, "INF_AMMO");
	Prefs.UseHack   = FindString(argc, argv, "HACKAB3D");

	Prefs.Control	= 0;

	if ((ctrl = StringValue(argc, argv, "CONTROL=")) != NULL)
	{
		if (strcmp("JOYSTICK", ctrl) == 0)
		{
			Prefs.Control	= 1;
		}
		else if (strcmp("JOYPAD", ctrl) == 0)
		{
			Prefs.Control	= 2;
		}
	}
}


/*	This function calls all other constructors.
*/

BOOL GlobalConstructor (int argc, char *argv [])
{
	/* Parse arguments if any
	*/
	PrefsConstructor((ULONG)argc, argv);

	if (!Prefs.NoGUI)
	{
		/* Setup window layout stuff
		*/
		if (!WindowConstructor ())
		{
			PutStr ("ERROR: WindowConstructor() failed\n");
			return FALSE;
		}

		/* Layout the window
		*/
		if (!CreateControlPanel ())
		{
			PutStr ("ERROR: CreateControlPanel() failed\n");
			return FALSE;
		}

		/* Open the window
		*/
		if (!OpenControlPanel ())
		{
			PutStr ("ERROR: OpenControlPanel() failed\n");
			return FALSE;
		}

		/* Set gadgets to stored values
		*/
		SetCheckbox(GAD_ENERGY, Prefs.InfEnergy);
		SetCheckbox(GAD_AMMO, Prefs.InfAmmo);
		SetCheckbox(GAD_HACK, Prefs.UseHack);
		SetCycle(GAD_CONTROL, Prefs.Control);
	}

	return TRUE;
}

/*	This function closes all things that were opened, and destructs all
	things that were constructed.
*/

void GlobalDestructor (void)
{
	if (!Prefs.NoGUI)
	{
		WindowDestructor ();
	}
}

/* Window processing loop
*/

BOOL HandleWindowEvents(void)
{
	struct IntuiMessage *IMsg;
	ULONG class;
	UWORD code;
	struct Gadget *Gad;
	struct Window *Win = Panel.Win;
	BOOL Done = FALSE;
	BOOL Play = FALSE;

	while (!Done)
	{
		Wait(1 << Win->UserPort->mp_SigBit);

		while (!Done &&	(IMsg = GT_GetIMsg(Win->UserPort)))
		{
			Gad   = (struct Gadget *)IMsg->IAddress;
			class = IMsg->Class;
			code  = IMsg->Code;

			GT_ReplyIMsg(IMsg);

			switch (class)
			{
				case IDCMP_GADGETDOWN:
				case IDCMP_MOUSEMOVE:
				case IDCMP_GADGETUP:
					switch (Gad->GadgetID)
					{
						case GAD_AMMO:
							Prefs.InfAmmo = !Prefs.InfAmmo;
							SetCheckbox(GAD_AMMO, Prefs.InfAmmo);
						break;
						case GAD_ENERGY:
							Prefs.InfEnergy = !Prefs.InfEnergy;
							SetCheckbox(GAD_ENERGY, Prefs.InfEnergy);
						break;
						case GAD_HACK:
							Prefs.UseHack = !Prefs.UseHack;
							SetCheckbox(GAD_HACK, Prefs.UseHack);
						break;
						case GAD_CONTROL:
							Prefs.Control = code;
							SetCycle(GAD_CONTROL, Prefs.Control);
						break;
						case GAD_PLAY:
							Play = TRUE;
							Done = TRUE;
						break;
						case GAD_CANCEL:
							Play = FALSE;
							Done = TRUE;
						break;
					}
					break;

				case IDCMP_VANILLAKEY:
					switch (code)
					{
						case 'p':
						case 'P':
							Play = TRUE;
							Done = TRUE;
						break;
						case 'c':
						case 'C':
							Play = FALSE;
							Done = TRUE;
						break;
						case 'e':
						case 'E':
							Prefs.InfEnergy = !Prefs.InfEnergy;
							SetCheckbox(GAD_ENERGY, Prefs.InfEnergy);
						break;
						case 'a':
						case 'A':
							Prefs.InfAmmo = !Prefs.InfAmmo;
							SetCheckbox(GAD_AMMO, Prefs.InfAmmo);
						break;
						case 'h':
						case 'H':
							Prefs.UseHack = !Prefs.UseHack;
							SetCheckbox(GAD_HACK, Prefs.UseHack);
						break;
					}
					break;

				case IDCMP_CLOSEWINDOW:
					Play = FALSE;
					Done = TRUE;
					break;

				case IDCMP_REFRESHWINDOW:
					GT_BeginRefresh(Win);
					GT_EndRefresh(Win, TRUE);
					break;
			}
		}
	}

	return(Play);
}


/*	The main routine for AB3DTrainer
*/

int main (int argc, char *argv [])
{
	BOOL Play;
	char BootString[100];

	if (argc == 0) {
		argc = _WBArgc;
		argv = _WBArgv;
	}

	/* Set up everything
	*/
	if (!GlobalConstructor (argc, argv))
	{
		GlobalDestructor ();
		exit (RETURN_WARN);
	}

	/* The main loop
	*/
	if (!Prefs.NoGUI)
	{
		Play = HandleWindowEvents();
	}
	else
	{
		Play = TRUE;
	}

	/* Clean up before leaving
	*/
	GlobalDestructor();

	/* If user selected to play, then run boot program
	*/
	if (Play)
	{
		sprintf(BootString, "AB3DTBoot %d %d %d %d ", 
					Prefs.InfEnergy, Prefs.InfAmmo,
					Prefs.UseHack, Prefs.Control);
		Execute(BootString, 0L, 0L);
	}

	exit (RETURN_OK);
}
