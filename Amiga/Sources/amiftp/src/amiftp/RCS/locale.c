head	1.625;
access;
symbols;
locks
	lilja:1.625; strict;
comment	@ * @;


1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.401;

1.401
date	96.03.28.13.52.44;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	;


desc
@Locale support routines.
@


1.625
log
@Cleaned up the code a bit.
Rename ftpwin.h to AmiFTP.h and ftpwin.c to AmiFTP.c.
Created Menu.c and moved all menu-functions there.
@
text
@/* RCS Id: $Id: locale.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
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
@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id: $Id$
   Locked version: $Revision$
d5 1
a5 1
#include "ftpwin.h"
a6 1
static void LocalizeGadgetTable(struct NewGadget *newgadget, LONG *Table);
d57 1
a57 17
static void LocalizeGadgetTable(struct NewGadget *newgadget, LONG *Table)
{
    LONG From=0;

    while(Table[From]!=-1) {
	if (Table[From]) {
	    newgadget->ng_GadgetText=GetAmiFTPString((APTR)Table[From]);
	}
	From++;
	newgadget++;
    }
}





@


1.401
log
@Started on improving the functionnames.
Added Aminet-mode, not 100% finished yet.
Reworked the prefs-window, not everything is finished.
Started using listbrowser v41-functions.
Added parsing of URL-like commandline.
@
text
@d1 4
a13 14
#if 0
    extern struct NewGadget co_NewGadgets[];
    extern LONG co_GadgetLabels[];
    extern struct NewGadget sc_NewGadgets[];
    extern LONG sc_GadgetLabels[];
    extern struct NewGadget dl_NewGadgets[];
    extern LONG dl_GadgetLabels[];
    extern struct NewGadget pr_NewGadgets[];
    extern LONG pr_GadgetLabels[];
    extern struct NewGadget connect_NewGadgets[];
    extern LONG connect_GadgetLabels[];
    extern struct NewGadget main_NewGadgets[];
    extern LONG main_GadgetLabels[];
#endif
a15 6
//    LocalizeGadgetTable(co_NewGadgets,co_GadgetLabels);
//    LocalizeGadgetTable(sc_NewGadgets,sc_GadgetLabels);
//    LocalizeGadgetTable(dl_NewGadgets,dl_GadgetLabels);
//    LocalizeGadgetTable(pr_NewGadgets,pr_GadgetLabels);
//    LocalizeGadgetTable(connect_NewGadgets,connect_GadgetLabels);
//    LocalizeGadgetTable(main_NewGadgets,main_GadgetLabels);
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d77 1
a77 1
    WORD i;
@


0.371
log
@Localized source.
@
text
@d10 1
d23 1
d26 6
a31 6
    LocalizeGadgetTable(co_NewGadgets,co_GadgetLabels);
    LocalizeGadgetTable(sc_NewGadgets,sc_GadgetLabels);
    LocalizeGadgetTable(dl_NewGadgets,dl_GadgetLabels);
    LocalizeGadgetTable(pr_NewGadgets,pr_GadgetLabels);
    LocalizeGadgetTable(connect_NewGadgets,connect_GadgetLabels);
    LocalizeGadgetTable(main_NewGadgets,main_GadgetLabels);
@
