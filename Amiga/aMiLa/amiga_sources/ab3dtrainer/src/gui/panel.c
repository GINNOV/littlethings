#include <clib/gadtools_protos.h>
#include <clib/intuition_protos.h>

#include <pragmas/gadtools_pragmas.h>
#include <pragmas/intuition_pragmas.h>

#include <exec/types.h>
#include <intuition/gadgetclass.h>
#include <stdio.h>
#include <string.h>

#include "defines.h"

/***** INSTANCE VARIABLES *****/

static STRPTR ControlCycle [] = { "No change", "Force Joystick", "Force Joypad", NULL };

/***** EXTERNAL VARIABLES *****/

/*	This function calculates all gadgetsizes and creates all gadgets
	for this window.
*/

BOOL CreateControlPanel (void)
{	struct Gadget *Gad;
	LONG Width;

	Gad = CreateContext (&(Panel.GList));

	CalcCheckbox (GAD_ENERGY);
	CalcCheckbox (GAD_AMMO);
	CalcCheckbox (GAD_HACK);
	CalcCheckbox (GAD_CONTROL);
	CalcLabel (LAB_ENERGY, "Infinite _Energy");
	CalcLabel (LAB_AMMO, "Infinite _Ammunition");
	CalcLabel (LAB_HACK, "Use _HackAB3D");
	CalcCycle (GAD_CONTROL, ControlCycle);
	CalcLabel (LAB_CONTROL, "Controller:");
	CalcButton (GAD_PLAY, "_Play");
	CalcButton (GAD_CANCEL, "_Cancel");
	CalcBlank (GAD_BLANK1, "|");
	CalcBlank (GAD_BLANK2, "|");

	Width = MAX(AllGads[GAD_PLAY].Width, AllGads[GAD_CANCEL].Width);
	AllGads[GAD_PLAY].Width   = Width;
	AllGads[GAD_CANCEL].Width = Width;

	AllGads[GAD_BLANK2].Height = INTERHEIGHT;

	BeginWindow (HORIZONTAL, WINDOWTITLE);
		PushColumn ();
			PushColumn ();
				GadgetAdd (GAD_ENERGY);
				GadgetAdd (GAD_AMMO);
				GadgetAdd (GAD_BLANK2);
				GadgetAdd (GAD_HACK);
				GadgetAdd (GAD_BLANK2);
			PopColumn ();
			PushColumn ();
				GadgetAdd (LAB_ENERGY);
				GadgetAdd (LAB_AMMO);
				GadgetAdd (GAD_BLANK2);
				GadgetAdd (LAB_HACK);
				GadgetAdd (GAD_BLANK2);
			PopColumn ();
		PopColumn ();
		PushColumn ();
			GadgetAdd (LAB_CONTROL);
		PopColumn ();
		PushColumn ();
			GadgetAdd (GAD_CONTROL);
		PopColumn ();
		PushColumn ();
			GadgetAdd (GAD_BLANK1);
		PopColumn ();
		PushColumn ();
			GadgetAdd (GAD_PLAY);
			GadgetAdd (GAD_CANCEL);
		PopColumn ();
		AlignToRight (GAD_CANCEL);
	EndWindow ();

	AllGads[GAD_CONTROL].x = AllGads[GAD_PLAY].x;
	AllGads[GAD_CONTROL].Width = AllGads[GAD_CANCEL].x + AllGads[GAD_CANCEL].Width - AllGads[GAD_CONTROL].x;

	// Create the actual gadgets

	CreateCheckbox (&Gad, GAD_ENERGY);
	CreateCheckbox (&Gad, GAD_AMMO);
	CreateCheckbox (&Gad, GAD_HACK);
	CreateCycle (&Gad, GAD_CONTROL, ControlCycle);
	CreateLabel (&Gad, LAB_ENERGY);
	CreateLabel (&Gad, LAB_AMMO);
	CreateLabel (&Gad, LAB_HACK);
	CreateLabel (&Gad, LAB_CONTROL);
	CreateButton(&Gad, GAD_PLAY);
	CreateButton(&Gad, GAD_CANCEL);

	// All gadgets have been added
	if (!Gad) return FALSE;

	return TRUE;
}
