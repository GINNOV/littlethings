;/*
gcc -o reqTools reqtools.c -lauto -lraauto
quit
*/

/* ReAction Example, "reqtools" prefs skeleton.*/

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>

struct Screen *Scr = NULL;
struct DrawInfo *Dri;
BOOL done = FALSE;

/**************************************************************************
 * Chooser label arrays */
static STRPTR chooserlabels1[] = 
{
	"File Requester", 
	"Font Requester", 
	"Palette Requester", 
	"Screen Mode Requester", 
	"Volume Requester", 
	"Other Requesters", 
	NULL 	
};

static STRPTR chooserlabels2[] = 
{
	"Mouse Pointer",
	"Center in Window", 
	"Center on Screen", 
	"Top Left of Window", 
	"Top Left of Screen", 
	NULL
};

/*************************************************************************
 * Gadget list */
typedef enum { 
	G_PopScreen = 1, 
	G_UseSysFont, 
	G_ImmSort, 
	G_DrawerFirst,
 	G_MixFiles, 
	G_DiskLed, 
	G_DefPage, 
	G_Visible, 
	G_VisMin, 
	G_VisMax,
 	G_Pos, 
	G_PosX, 
	G_PosY, 
	G_Save, 
	G_Use, 
	G_Cancel, 
	G_MAX 
} GadgetIDs;
 
struct Gadget *GList[G_MAX+1];

/*************************************************************************
 * Main Program */

int main(argc,argv)
	int argc;
	char *argv[];
{
	struct Window *Win;

	Scr = IIntuition->LockPubScreen(NULL);
	
	if (!ButtonBase) /* force it open */
		return (30);

	if (Scr == NULL)
	{
		/* Shut down, no screen lock */ 
		IDOS->Printf("Failed locking public screen.\n");
		return(30);
	}

	Dri = IIntuition->GetScreenDrawInfo(Scr);
	if (Dri)
	{
		struct Gadget *MainLayout, *l1, *l2;
		Object *Window;
	
		Window = WindowObject,
			WA_SizeGadget, TRUE,
			WA_DepthGadget, TRUE,
			WA_DragBar, TRUE,
			WA_CloseGadget, TRUE,
			WA_Activate, TRUE,
			WA_PubScreen, Scr,
			WA_Title, "ReAction layout.gadget Example (ReqTools preferences mockup)",
			WA_ScreenTitle, "ReAction OS4",
			WINDOW_Position, WPOS_CENTERMOUSE,
			WINDOW_ParentGroup,	MainLayout = VGroupObject, 
				LAYOUT_SpaceOuter, TRUE,
				LAYOUT_DeferLayout, TRUE,		/* this tag instructs layout.gadget to
											 * defer GM_LAYOUT and GM_RENDER and ask
											 * the application to do them. This
											 * lessens the load on input.device */
				StartHGroup,
					StartVGroup,
							
						/* This is a basic vertical centered layout group with three gadgets */
						StartVGroup, VCentered, LAYOUT_SpaceOuter, TRUE,
							LAYOUT_BevelStyle, GroupFrame,
							LAYOUT_Label, "General",
									
							/* SetGadgetCommKeys will set the gadget IDs automatically */
							StartMember, GList[G_PopScreen] = CheckBoxObject,
								GA_Text, "_Pop screen to front",
							End,
										
							StartMember, GList[G_UseSysFont] = CheckBoxObject,
								GA_Text, "Us_e system default font",
							End,
						End,
						CHILD_WeightMinimum, TRUE,	/* by setting WeightMinimum you instruct
												 * layout.gadget to weight the object according
												 * to its minimum size. This retains group
												 * aspects at all sizes. */
								
						StartVGroup, VCentered, LAYOUT_SpaceOuter, TRUE,
							LAYOUT_BevelStyle, GroupFrame,
							LAYOUT_Label, "File Requester",
									
							StartMember, GList[G_ImmSort] = CheckBoxObject,
								GA_Text, "_Immediate sort",
							End,
									
							StartMember, GList[G_DrawerFirst] = CheckBoxObject,
								GA_Text, "_Display drawers first",
							End,
									
							StartMember, GList[G_MixFiles] = CheckBoxObject,
								GA_Text, "Mi_x files and drawers",
							End,
									
							StartMember, GList[G_DiskLed] = CheckBoxObject,
							 	GA_Text, "Dis_k activity LED",
							End,
						End,
						CHILD_WeightMinimum, TRUE,
					End,
					CHILD_WeightMinimum, TRUE,
							
					StartVGroup, TOffset(INTERSPACING),
						StartMember, GList[G_DefPage] = ChooserObject,
							CHOOSER_LabelArray, chooserlabels1,
						End,
						CHILD_Label, LabelObject, LABEL_Text, "De_faults for", End,
						CHILD_WeightedHeight, 0,
						
						StartMember, l1 = VGroupObject,
							LAYOUT_SpaceOuter, TRUE,
							LAYOUT_BevelStyle, StandardFrame,
							LAYOUT_BevelState, IDS_SELECTED,
									
							StartHGroup, TOffset(INTERSPACING),
								LAYOUT_Label, "Size (% of visible height):",
										
								StartMember, GList[G_Visible] = ScrollerObject,
									SCROLLER_Total, 100,
									SCROLLER_Arrows, FALSE,
									SCROLLER_Orientation, SORIENT_HORIZ,
								End,
								CHILD_MinHeight, Scr->Font->ta_YSize + 6,
									
							End,
							CHILD_WeightedHeight, 0,
			
							StartMember, l2 = HGroupObject, TOffset(INTERSPACING),
								LAYOUT_Label, "Number of visible entries:",
								
								StartMember, GList[G_VisMin] = IntegerObject, 
									GA_TabCycle, TRUE,
								End,
								CHILD_Label, LabelObject, LABEL_Text, "_Minimum", End,
									
								StartMember, GList[G_VisMax] = IntegerObject, 
									GA_RelVerify, TRUE,
									GA_TabCycle, TRUE,
								End,
								CHILD_Label, LabelObject, LABEL_Text, "Ma_ximum", End,
									
							End,
							CHILD_WeightedHeight, 0,
			
							StartMember, GList[G_Pos] = ChooserObject,
								GA_TabCycle, TRUE,
								CHOOSER_LabelArray, chooserlabels2,
							End,
							CHILD_Label, LabelObject, LABEL_Text, "P_osition", End,
							CHILD_WeightedHeight, 0,
									
							StartHGroup,
									
								StartMember, GList[G_PosX] = IntegerObject, 
									GA_TabCycle, TRUE,
								End,
										
								StartMember, GList[G_PosY] = IntegerObject, 
									GA_TabCycle, TRUE,
								End,
										
							End,
							CHILD_Label, LabelObject, LABEL_Text, "Offse_t", End,
							CHILD_WeightedHeight, 0,
						End, 
					End,
					CHILD_WeightMinimum, TRUE,
				End,
						
				StartHGroup,
					LAYOUT_EvenSize, TRUE,
							
					StartMember, GList[G_Save] = ButtonObject,
						GA_Text, "_Save",
					End,
					CHILD_NominalSize, TRUE, /* make it a bit larger than necessary */
					CHILD_WeightedWidth, 0,
						
					StartMember, GList[G_Use] = ButtonObject,
						GA_Text, "_Use",
					End,
					CHILD_NominalSize, TRUE,
					CHILD_WeightedWidth, 0,
							
					StartMember, GList[G_Cancel] = ButtonObject,
						GA_Text, "_Cancel",
					End,
					CHILD_NominalSize, TRUE,
					CHILD_WeightedWidth, 0,
				End,
				CHILD_WeightedHeight, 0,
			End,
		EndWindow;
	
		if (Window)
		{
			/* set up automatic label justification */
			IIntuition->SetAttrs( l1, LAYOUT_AlignLabels, l2, TAG_END );
			IIntuition->SetAttrs( l2, LAYOUT_AlignLabels, l1, TAG_END );
	
			/* Finish the gadgetarray initialisation. Set gadget IDs and release verify */
				
			{
				LONG i = 1;
				do IIntuition->SetAttrs(GList[i], GA_ID, i, GA_RelVerify, TRUE, TAG_END);
				while (GList[++i]);
			}
				
			if (Win = RA_OpenWindow( Window ))
			{
				ULONG wsig;
					
				IIntuition->GetAttr( WINDOW_SigMask, Window, &wsig );
		
				while (done == FALSE)
				{
					ULONG sig = IExec->Wait(wsig | SIGBREAKF_CTRL_C);
					ULONG result;
					WORD code;
	
					if (sig & wsig)
					{
						while ((result = RA_HandleInput(Window,&code)) != WMHI_LASTMSG)
						{
							switch(result & WMHI_CLASSMASK)
							{
							case WMHI_GADGETUP:
								switch(result & WMHI_GADGETMASK)
								{
								case G_Save:
								case G_Use:
								case G_Cancel:
									done = TRUE;
									/*FALLTHROUGH*/
										
								/* Gadgets here */
								default:
									IDOS->Printf("Gadget ID %ld hit (code %ld)\n", result & WMHI_GADGETMASK, code);
									break;
								}
								break;

							case WMHI_CLOSEWINDOW:
								done = TRUE;
								break;
							}
						}
					}
					else if (sig & SIGBREAKF_CTRL_C)
					{
						done = TRUE;
					}
				}
				/* Close the window and dispose of all attached gadgets */
				IIntuition->DisposeObject( Window );
			}
		}
		
		IIntuition->FreeScreenDrawInfo(Win->WScreen, Dri);
	}
    	IIntuition->UnlockPubScreen(0, Scr);
}
