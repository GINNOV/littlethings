head	1.815;
access;
symbols;
locks
	lilja:1.815; strict;
comment	@ * @;


1.815
date	96.12.14.12.13.03;	author lilja;	state Exp;
branches;
next	1.795;

1.795
date	96.09.28.13.32.58;	author lilja;	state Exp;
branches;
next	1.710;

1.710
date	96.07.25.00.21.30;	author lilja;	state Exp;
branches;
next	1.692;

1.692
date	96.07.20.00.28.38;	author lilja;	state Exp;
branches;
next	;


desc
@Support functions for the Speedbar.
@


1.815
log
@Fixed the proxy-port settings.
Replaced % with @@ since the proxy actually seems to work with other
ftpproxies.
Fixed the Height/Width save-problem.
@
text
@/* RCS Id: $Id: SpeedBar.c 1.795 1996/09/28 13:32:58 lilja Exp $
   Version: $Revision: 1.795 $
*/

#include "AmiFTP.h"
#include "gui.h"

#include "penmapimages.c"

enum {SB_QUIT=0, SB_ZZZ, SB_Connect, SB_Disconnect, SB_Parent, SB_Get, SB_Put,
	SB_View};

struct List SpeedBarList;
struct Image *speedImages[8];

void InitSpeedBarList(void)
{
    struct Node *node;
    WORD i=0;
    extern struct Screen *Screen;
    struct foobar {
	void *data; int spacing;
    } barfoo[]={
	image6data, 2,
	image5data, 3,
	image0data, 6,
	image1data, 3,
	image7data, 6,
	image2data, 6,
	image3data, 3,
	image4data, 3};

    NewList(&SpeedBarList);
    for (i=0; i < 8; i++) {
	speedImages[i]=(struct Image *)NewObject(NULL, "penmap.image",
						 PENMAP_RenderData, barfoo[i].data,
						 PENMAP_Palette, image0palette,
						 PENMAP_Screen, Screen,
						 PENMAP_MaskBlit, TRUE,
						 TAG_DONE);
	if (!speedImages[i])
	  printf("barf\n");
	else
	  if (node = (struct Node *)AllocSpeedButtonNode(i,
						       SBNA_Image, speedImages[i],
						       SBNA_Top, 2,
						       SBNA_Left, 0,
						       SBNA_Enabled, TRUE,
						       SBNA_Spacing, barfoo[i].spacing,
						       SBNA_Highlight, SBH_RECESS,
						       TAG_DONE))
	  AddTail(&SpeedBarList, node);
    }
}

void FreeSpeedBarList(void)
{
    struct Node *node;

    while (node=RemHead(&SpeedBarList))
      FreeSpeedButtonNode(node);

    NewList(&SpeedBarList);
}

int HandleSpeedBar(int button)
{
    extern int prev_state;

    switch (button) {
      case SB_QUIT:
	return 0;
	break;
      case SB_ZZZ:
	if (CA_Iconify(MainWin_Object))
	  MainWindow=NULL;
	break;
      case SB_Connect:
	Connect_clicked();
	break;
      case SB_Disconnect:
	Disconnect_clicked();
	break;
      case SB_Parent:
	if (connected && !CurrentState.ADTMode)
	  Parent_clicked();
	break;
      case SB_Get:
	if (FileList && connected && prev_state==MB_FILESELECTED)
	  Get_clicked();
	break;
      case SB_Put:
	Put_clicked();
	break;
      case SB_View:
	if (FileList && connected && prev_state==MB_FILESELECTED)
	  View_clicked(FALSE);
	break;
    }
    return 1;
}

void UpdateSpeedBar(int state)
{
    extern int prev_state;

    if (prev_state!=MB_DISCONNECTED && state==MB_DISCONNECTED) {
	int i;

#if 0
	for (i=SB_Disconnect; i < 7; i++)
	  SetGadgetAttrs(MG_List[MG_SpeedBar], MainWindow, NULL,
			 SPEEDBAR_OffButton, i,
			 TAG_DONE);
#endif
	{
	    struct Node *node;
	    node=GetHead(&SpeedBarList);
	    node=GetSucc(GetSucc(GetSucc(node)));
	    for (; node; node=GetSucc(node)) {
		SetSpeedButtonNodeAttrs(node, SBNA_Disabled, TRUE, TAG_DONE);
	    }
	}
	if (MainWindow)
	  RefreshGList(MG_List[MG_SpeedBar], MainWindow, NULL, 1);
    }
    else if (prev_state==MB_DISCONNECTED && state!=MB_DISCONNECTED) {
	int i;

#if 0
	for (i=SB_Disconnect; i < 7; i++)
	  SetGadgetAttrs(MG_List[MG_SpeedBar], MainWindow, NULL,
			 SPEEDBAR_OnButton, i,
			 TAG_DONE);
#endif
	{
	    struct Node *node;
	    node=GetHead(&SpeedBarList);
	    node=GetSucc(GetSucc(GetSucc(node)));
	    for (; node; node=GetSucc(node)) {
		SetSpeedButtonNodeAttrs(node, SBNA_Disabled, FALSE, TAG_DONE);
	    }
	}
	if (MainWindow)
	  RefreshGList(MG_List[MG_SpeedBar], MainWindow, NULL, 1);
    }
}
@


1.795
log
@Stuff.
@
text
@d1 2
a2 2
/* RCS Id: $Id: SpeedBar.c 1.710 1996/07/25 00:21:30 lilja Exp lilja $
   Version: $Revision: 1.710 $
a33 1

d42 1
a42 1
	  kprintf("barf\n");
@


1.710
log
@Fontprefs seems to work ok, except in PrefsWindow.
@
text
@d1 2
a2 2
/* RCS Id: $Id: SpeedBar.c 1.692 1996/07/20 00:28:38 lilja Exp lilja $
   Version: $Revision: 1.692 $
d10 2
a11 1
enum {SB_ZZZ=0, SB_Connect, SB_Disconnect, SB_Get, SB_Put, SB_View};
d14 1
a14 1
struct Image *speedImages[6];
d24 2
a25 1
	image5data, 2,
d28 1
d35 1
a35 1
    for (i=0; i < 6; i++) {
d40 1
d72 3
d85 4
d106 3
a108 1
    if (state==MB_DISCONNECTED) {
d111 2
a112 1
	for (i=SB_Disconnect; i < 6; i++)
d116 11
d128 1
a128 1
    else {
d131 2
a132 1
	for (i=SB_Disconnect; i < 6; i++)
d136 11
a147 2
    if (MainWindow)
      RefreshGList(MG_List[MG_SpeedBar], MainWindow, NULL, 1);
@


1.692
log
@Speedbar and buttons configurable.
@
text
@d1 2
a2 2
/* RCS Id: $Id$
   Version: $Revision$
d65 2
d79 1
a79 1
	if (FileList && connected)
d86 1
a86 1
	if (FileList && connected)
@
