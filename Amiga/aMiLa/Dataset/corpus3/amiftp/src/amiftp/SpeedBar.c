/* RCS Id: $Id: SpeedBar.c 1.815 1996/12/14 12:13:03 lilja Exp lilja $
   Version: $Revision: 1.815 $
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
