head	1.798;
access;
symbols;
locks
	lilja:1.798; strict;
comment	@ * @;


1.798
date	96.11.06.19.32.54;	author lilja;	state Exp;
branches;
next	1.795;

1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.692;

1.692
date	96.07.20.00.28.38;	author lilja;	state Exp;
branches;
next	1.630;

1.630
date	96.07.07.20.10.48;	author lilja;	state Exp;
branches;
next	1.625;

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
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	1.124;

1.124
date	96.02.10.15.46.32;	author lilja;	state Exp;
branches;
next	0.1332;

0.1332
date	95.12.17.13.21.38;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.863;

0.863
date	95.10.28.17.17.56;	author lilja;	state Exp;
branches;
next	0.857;

0.857
date	95.10.24.18.41.14;	author lilja;	state Exp;
branches;
next	0.827;

0.827
date	95.10.23.21.01.35;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.807;

0.807
date	95.10.13.12.51.19;	author lilja;	state Exp;
branches;
next	;


desc
@AmigaGuide support functions.
@


1.798
log
@Fixed init of AmigaGuide.
@
text
@/* RCS Id:  $Id: AGuide.c 1.795 1996/09/28 13:32:58 lilja Exp lilja $
   Locked version: $Revision: 1.795 $
*/

#include "AmiFTP.h"

STRPTR context[]=
{
    "MAIN",
    "MENUCONNECT",
    "MENUDISCONNECT",
    "MENURECONNECT",
    "MENUADDTOSITELIST",
    "MENURESETADT",
    "MENUICONIFY",
    "MENUABOUT",
    "MENUQUIT",
    "MENUTAGALL",
    "MENUUNTAGALL",
    "MENUPATTERNSELECT",
    "MENUTRANSFERMODE",
    "MENUCLEARCACHE",
    "MENUDELETE",
    "MENUPARENT",
    "MENUPUT",
    "MENUGET",
    "MENUVIEW",
    "MENUVIEWREADME",
    "MENUSORT",
    "MENUGLOBAL",
    "MENUSITELIST",
    "MENULOGWINDOW",
    "MENUTOGGLEDOTS",
    "MENUSHOWALLRECENT",
    "MENULOADSETTINGS",
    "MENUSAVESETTINGS",
    "MENUHOTLIST",
    "MAINWINDOW",
    "GLOBALPREFERENCES",
    "SITELIST",
    "SITECONFIGURATION",
    "TRANSFERWINDOW",
    "CONNECTWINDOW",
    "MAIN",
    NULL
};

int HandleAmigaGuide()
{
    struct AmigaGuideMsg *agm;

    if (AmigaGuideBase) {
	while (agm=GetAmigaGuideMsg(ag.ag_AmigaGuide)) {
	    switch (agm->agm_Type) {
	      case ActiveToolID:
		break;
	      case ToolCmdReplyID:
		if (agm->agm_Pri_Ret)
		  Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
		break;
	      case ShutdownMsgID:
		if (agm->agm_Pri_Ret)
		  Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
		break;
	      case ToolStatusID:
		if (agm->agm_Pri_Ret)
		  Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
		break;
	      default:
		break;
	    }
	    ReplyAmigaGuideMsg(agm);
	}
    }
    return 1;
}
extern ULONG AG_Signal;

int SendAGMessage(LONG ContextNumber)
{
    if (AmigaGuideBase) {
	if (!ag.ag_AmigaGuide) {
	    if (!(ag.ag_AmigaGuide=OpenAmigaGuideAsync(&ag.ag_NAG,NULL)))
	      return 0;
	    else {
		struct Msg *msg;
		AG_Signal=AmigaGuideSignal(ag.ag_AmigaGuide);
		Wait(AG_Signal);
		while (msg=GetAmigaGuideMsg(ag.ag_AmigaGuide))
		  ReplyAmigaGuideMsg(msg);
	    }
	}

	SendAmigaGuideCmd(ag.ag_AmigaGuide,NULL,
			  AGA_Context,ContextNumber,
			  TAG_DONE);
    }
    return 1;
}

@


1.795
log
@Stuff.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AGuide.c 1.692 1996/07/20 00:28:38 lilja Exp lilja $
   Locked version: $Revision: 1.692 $
d86 1
d88 3
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AGuide.c 1.630 1996/07/07 20:10:48 lilja Exp lilja $
   Locked version: $Revision: 1.630 $
d11 1
a11 1
    "MENURECONNECT",
d23 3
a26 1
    "MENUPUT",
d28 1
a28 1
    "MENUDELETE",
@


1.630
log
@Added items in the menu to duplicate the buttons.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AGuide.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
d20 1
@


1.625
log
@Cleaned up the code a bit.
Rename ftpwin.h to AmiFTP.h and ftpwin.c to AmiFTP.c.
Created Menu.c and moved all menu-functions there.
@
text
@d1 2
a2 2
/* RCS Id:  $Id: AGuide.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d10 2
d22 3
@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id:  $Id$
   Locked version: $Revision$
d5 1
a5 1
#include "ftpwin.h"
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
a4 1
/* Should work with V37. Not 100% sure */
@


1.200
log
@GETATTR-hit fixed.
@
text
@d9 1
d23 1
@


1.124
log
@AmiTCP and AS225r2 support in the same binary.
ARexx-command VIEW added.
New option to SETATTR, QUIET.
SETATTR LOCALDIR didn't update the download dir-gadget.
GETATTR STEM=bar didn't work since bar is in lowercase.
Enforcer hits when trying to open AmiFTP on a non-existing screen removed.
Moved 'Show dot-files?' to the Settings-menu.
Icelandic and Spanish catalogs added.
@
text
@d62 1
a62 1
    return (1);
d71 1
a71 1
	      return (0);
d81 1
a81 1
    return (1);
@


0.1332
log
@Release 1.0
AmiFTP doesn't need amigaguide.library in order to start.
@
text
@d21 1
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d38 21
a58 18
    while (agm=GetAmigaGuideMsg(ag.ag_AmigaGuide)) {
	switch (agm->agm_Type) {
	  case ActiveToolID:
	    break;
	  case ToolCmdReplyID:
	    if (agm->agm_Pri_Ret)
	      Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
	    break;
	  case ShutdownMsgID:
	    if (agm->agm_Pri_Ret)
	      Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
	    break;
	  case ToolStatusID:
	    if (agm->agm_Pri_Ret)
	      Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
	    break;
	  default:
	    break;
a59 1
	ReplyAmigaGuideMsg(agm);
d67 7
a73 5
    if (!ag.ag_AmigaGuide) {
	if (!(ag.ag_AmigaGuide=OpenAmigaGuideAsync(&ag.ag_NAG,NULL)))
	  return (0);
	else {
	    AG_Signal=AmigaGuideSignal(ag.ag_AmigaGuide);
d75 4
a79 4

    SendAmigaGuideCmd(ag.ag_AmigaGuide,NULL,
		      AGA_Context,ContextNumber,
		      TAG_DONE);
@


0.863
log
@Releaseversion (maybe)
@
text
@d1 1
d30 1
@


0.857
log
@Log-window function working. Only thing missing a to control it from ARexx.
@
text
@d41 2
a42 2
/*	    if (agm->agm_Pri_Ret)
	      Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));*/
d45 2
a46 2
/*	    if (agm->agm_Pri_Ret)
	      Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));*/
d49 2
a50 2
/*	    if (agm->agm_Pri_Ret)
	      Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));*/
@


0.827
log
@Add Current to sitelist added.
More rtLockWindow()'s
Leeching seems to work, but is not finished yet.
@
text
@d19 1
@


0.814
log
@Added default download-dir.
@
text
@d7 1
@


0.807
log
@Added AmigaGuide on-line help.
@
text
@d55 1
d72 1
@
