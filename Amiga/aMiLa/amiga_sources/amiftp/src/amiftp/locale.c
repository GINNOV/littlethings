/* RCS Id: $Id: locale.c 1.625 1996/07/04 17:50:58 lilja Exp $
   Locked version: $Revision: 1.625 $
*/

#include "AmiFTP.h"

static void LocalizeMenuTable(struct NewMenu *Menu, LONG *Table);

void SetupLocaleStrings()
{
    extern struct NewMenu mainmenus[];
    extern LONG MenuLabels[];

    LocalizeMenuTable(mainmenus,MenuLabels);
}

static void LocalizeMenuTable(struct NewMenu *Menu, LONG *Table)
{
    STRPTR	Label,Shortcut;
    LONG	From = 0;

    while(Menu -> nm_Type != NM_END) {
	Shortcut = GetAmiFTPString((APTR)Table[From]);

	if(Shortcut[0] && !Shortcut[1])
	  Label = Shortcut + 2;
	else {
	    Label = Shortcut;
	    Shortcut= NULL;
	}

	switch(Menu -> nm_Type) {
	  case NM_TITLE:

	    Menu -> nm_Label = Label;

	    From++;

	    break;

	  case NM_ITEM:
	  case NM_SUB:

	    if(Menu -> nm_Label != NM_BARLABEL) {
		Menu -> nm_Label	= Label;
		Menu -> nm_CommKey	= Shortcut;

		From++;
	    }

	    break;
	}
	Menu++;
    }
}

/* EOF */
