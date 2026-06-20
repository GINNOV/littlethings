;/* Execute me to compile
gcc -o LayoutExample LayoutExample.c -lauto -lraauto 
quit
;*/

/*************************************************************************
 * ClassAct Comprehensive Demo Program
 * Copyright © 1995 Osma Ahvenlampi
 * Converted to OS4 Reaction 2005
 */

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/icon.h>

#include <workbench/startup.h>
#include <workbench/workbench.h>

void kprintf(const char *, ...);
struct List *BrowserNodesA( STRPTR * );
struct List *ChooserLabelsA( STRPTR * );
void FreeBrowserNodes( struct List *);
void FreeChooserLabels( struct List * );

/* a simple button - there are lots more macros to be found like this in reaction/reaction_macros.h */
#define SButton(a) ButtonObject, GA_Text, a, ButtonEnd
#define DButton(a) ButtonObject, GA_Text, a, GA_Disabled, TRUE, ButtonEnd

/**************************************************************************
 * Some label arrays for the gadgets in this demo.
 */
 
static STRPTR objtypes[] = 
{
	"Exec",
	"Image",
	"Sound",
	"Menu",
	"Icon",
	"Dock",
	"Access",
	NULL 	
};

static STRPTR objnames[] = 
{
	"ToolManager",
	"ScreenMode",
	"WBPattern",
	NULL
};

/*************************************************************************
 * Gadget list
 * This wouldn't be strictly necessary, but it's an easy way of keeping
 * the gadget pointers for when we need to access the gadgets.
 */
typedef enum { 
	G_ObjType = 1, 
	G_ObjList, 
	G_Top, 
	G_Up, 
	G_Down, 
	G_Bottom,
	G_Sort, 
	G_New, 
	G_Edit, 
	G_Copy, 
	G_Remove, 
	G_Help, 
	G_Save, 
	G_Use,
	G_Test, 
	G_Cancel,
	 G_MAX 
} GadgetIDs;
 
struct Gadget *GL[G_MAX+1];

/*************************************************************************
 * ReadArgs */
 
#define TEMPLATE "S=SIMPLEREFRESH/S,NC=NOCAREREFRESH/S,ND=NDEFER/S"
LONG ARG[3];
typedef enum { 
	A_Simple, 
	A_NoCare, 
	A_NoDefer 
} Args;

/*************************************************************************
 * App message hook.
 * Workbench App messages can be caught with a callback hook such as this.
 * We'll not worry about the app message type in this hook. Objects dropped
 * on the window or on the icon (while iconified) will be added to the 
 * listview.
 */

void AppMsgFunc(	register struct Hook *Hook,
				register Object *Window,
				register struct AppMessage *Msg )
{
	struct Window *Win;
	struct WBArg *arg = Msg->am_ArgList;
	LONG i = Msg->am_NumArgs;
	struct List *l = Hook->h_Data;
	struct Node *n;
	UBYTE name[256];
	
	IIntuition->GetAttr( WINDOW_Window, Window, (ULONG *)&Win );

	/* Detach the list for modifications.*/
	IIntuition->SetGadgetAttrs( GL[G_ObjList], Win, NULL, LISTBROWSER_Labels, ~0, TAG_END );
		
	while (i--)
	{
		/* Add the name of the icon to the listview. ListBrowser can copy the
		 * text into an internal buffer and thus let us not worry about the
		 * pointer validity.
		 */
		
		IDOS->NameFromLock( arg->wa_Lock, name, sizeof(name) );
		IDOS->AddPart( name, arg->wa_Name, sizeof(name) );
		
		if (n = IListBrowser->AllocListBrowserNode( 1, LBNCA_CopyText, TRUE, LBNCA_Text, name, TAG_END ))
			IExec->AddTail( l, n );
			
		arg++;
	}
	
	/* Reattach the list */
	IIntuition->SetGadgetAttrs( GL[G_ObjList], Win, NULL, LISTBROWSER_Labels, l, TAG_END );
}

/*************************************************************************
 * Main Program */
int main(void)
{
	struct List *objlist; 
	struct List *typelist; 
	struct RDArgs *args;
	struct MsgPort *appport;

	if (!ButtonBase) /* force it open */
		return 30;
		
	if (!(args = IDOS->ReadArgs(TEMPLATE, ARG, NULL)))
		return 20;
		
	IDOS->Printf("%seferred %s refresh %s\n", ARG[A_NoDefer] ? "Non-d" : "D", ARG[A_Simple] ? "Simple" : "Smart", ARG[A_NoCare] ? "(NoCare)" : "");

	objlist = BrowserNodesA( objnames );
	typelist = ChooserLabelsA( objtypes );

	/* By providing a message port you enable windowclass to handle iconification
	 * and appwindows. This port can shared by all the windows of your application.
	 */
	appport = IExec->CreateMsgPort();

	if (objlist && typelist && appport)
	{
		struct Gadget *MainLayout;
		Object *Window;
		
		struct Hook apphook;
		apphook.h_Entry = (ULONG (* )())AppMsgFunc;
		apphook.h_SubEntry = NULL;
		apphook.h_Data = objlist;
		
		/* Create a Window object with a Layout. When Window is asked to open itself,
		 * it will calculate how much space the Layout needs and size itself accordingly.
		 */
	
		Window = WindowObject,
				
				/* these tags describe the window 
				 */
		
				WA_IDCMP, IDCMP_RAWKEY,
				WA_Top, 20,
				WA_Left, 20,
				WA_SizeGadget, TRUE,
				WA_DepthGadget, TRUE,
				WA_DragBar, TRUE,
				WA_CloseGadget, TRUE,
				WA_Activate, TRUE,
				
				/* About window refreshes:
				 * Because WindowClass and LayoutClass can, when used together, change the
				 * normal Intuition practise of refreshing gadgets in the input.device context,
				 * some rules about the refresh system change.
				 * Deferred refresh works in both smart and simple refresh windows, but
				 * if nocarerefresh is used, Intuition does not retain the damage regions
				 * and any window damage will force the whole window to be refreshed.
				 * This demo allows you to try combinations of refresh types.
				 * In the normal case you can ignore this and let WindowClass and the user
				 * decide what kind of refreshes they want. Nocare refresh can be
				 * combined with smart refresh to provide a fast, but somewhat more memory
				 * hungry refresh method. Simple refresh can save some memory but it's
				 * slower.
				 */
				
				WA_SimpleRefresh, ARG[A_Simple],
				WA_NoCareRefresh, ARG[A_NoCare],	
				WA_SmartRefresh, !ARG[A_Simple],
				
				WA_Title, "ReAction layout.gadget Example (ToolManager preferences mockup)",
				WA_ScreenTitle, "ReAction OS4",
				
				/* Turn on gadget help in the window  */
				
				WINDOW_GadgetHelp, TRUE,
				
				/* Add an iconification gadget. If you have this, you must listen to
				 * WMHI_ICONIFY.
				 */
				 
				WINDOW_IconifyGadget, TRUE,
				
				/* This message port lets windowclass handle the icon and appwindow. */
				 
				WINDOW_AppPort, appport,
				WINDOW_AppWindow, TRUE,
				WINDOW_AppMsgHook, &apphook,
				
				/* The windowclass will automatically free the DiskObject used when
				 * iconifying the window. If you do not provide a valid DiskObject,
				 * windowclass will try to use env:sys/def_window.info or the default
				 * project icon.
				 */
				
				WINDOW_Icon, IIcon->GetDiskObject( "PROGDIR:LayoutExample" ),
				WINDOW_IconTitle, "ReAction Example",
				
				/* Below is the layout of the window  */
				
				WINDOW_ParentGroup,	MainLayout = VGroupObject,
					LAYOUT_SpaceOuter, TRUE,
					LAYOUT_BevelStyle, BVS_THIN,
					
					/* this tag instructs layout.gadget to defer GM_LAYOUT and GM_RENDER and ask
					 * the windowclass to do them. This lessens the load on input.device 
					 */
					LAYOUT_DeferLayout, !ARG[A_NoDefer],

					/* A 1-of-n chooser using the labels list we made from the label array earlier  */

					StartMember, GL[G_ObjType] = ChooserObject,
						CHOOSER_Labels, typelist,
					EndMember,
					MemberLabel("_Object Type"),
					
					/* Objects can be given arbitary weights within groups, and layout.gadget
					 * will distribute space relative to the total weight of the group.
					 * Here we set the button column to 0 weight which means minimum space.
					 * Thus the listview gets all available extra space.
					 */
					
					StartHGroup, BAligned,
						StartMember, GL[G_ObjList] = ListBrowserObject,
							LISTBROWSER_Labels, objlist,
							LISTBROWSER_ShowSelected, TRUE,
						EndMember,
						
						StartVGroup,
							StartMember, GL[G_Top] = DButton("Top"),
							StartMember, GL[G_Up] = DButton("Up"),
							StartMember, GL[G_Down] = DButton("Down"),
							StartMember, GL[G_Bottom] = DButton("Bottom"),
							StartMember, GL[G_Sort] = SButton("So_rt"),
						EndGroup,
						CHILD_WeightedWidth, 0,
						
						/* One way to keep the buttons constant size is to set the
						 * group to stay at minimum size with a weight of 0. We could
						 * also set the weight of each of the buttons to 0. That way
						 * extra space would be distributed between the buttons
						 * instead of all below. This looks better.
						 */
						
						CHILD_WeightedHeight, 0,
					EndGroup,
					
					/* two rows of buttons. EvenSized instructs layout.gadget that it
					 * should make sure the minimum size of each matches, so that we
					 * get four neat columns.
					 * Again the weight is set to 0. When the window is resized, all
					 * space is given to the listview.
					 */
					
					StartHGroup, EvenSized,
						StartMember, GL[G_New] = SButton("_New..."),
						StartMember, GL[G_Edit] = DButton("_Edit..."),
						StartMember, GL[G_Copy] = DButton("Co_py"),
						StartMember, GL[G_Remove] = DButton("Remove"),
					EndGroup,
					CHILD_WeightedHeight, 0,
					
					StartHGroup, EvenSized,
						StartMember, GL[G_Save] = SButton("_Save"),
						StartMember, GL[G_Use] = SButton("_Use"),
						StartMember, GL[G_Test] = SButton("_Test"),
						StartMember, GL[G_Cancel] = SButton("_Cancel"),
					EndGroup,
					CHILD_WeightedHeight, 0,
					
					StartMember, GL[G_Help] = ButtonObject,
						GA_ReadOnly, TRUE,
						GA_Text, "Welcome to ClassAct demo!",
					EndMember,
					CHILD_WeightedHeight, 0,
				EndGroup,
			EndWindow;
	
		if (Window)
		{
			/* Window pointer cache. */
		
			struct Window *Win;
		
			/* Finish the gadgetarray initialisation. Set gadget IDs and release verify. 
			 * This is one way of avoiding boring repetition in the layout description
			 * taglist itself.
			 */
			
			{
				LONG i = 1;
				do IIntuition->SetAttrs(GL[i], GA_ID, i, GA_RelVerify, TRUE, TAG_END);
				while (GL[++i]);
			}
			
			if (Win = RA_OpenWindow( Window ))
			{
				ULONG wsig, asig = 1L << appport->mp_SigBit;
				BOOL done = FALSE;
				
				/* Now that the window has been opened, we can get the signal mask
				 * of its user port. If the program supported iconification and didn't
				 * use a shared IDCMP port between all windows, this signal bit
				 * would have to be re-queried before each Wait().
				 */
				
				IIntuition->GetAttr( WINDOW_SigMask, Window, &wsig );
	
				while (done == FALSE)
				{
					ULONG sig = IExec->Wait(wsig | asig | SIGBREAKF_CTRL_C);
					ULONG result;
					WORD code;

					if (sig & (wsig | asig))
					{
						/* Messages waiting at the window's IDCMP port. Loop at WM_HANDLEINPUT
						 * until all have been processed.
						 */
					
						while ((result = RA_HandleInput(Window,&code)) != WMHI_LASTMSG)
						{
							/* The return code of this method is two-part. The upper word describes the
							 * class of the message (gadgetup, menupick, closewindow, iconify, etc),
							 * and the lower word is a class-defined ID, currently in use in the
							 * gadgetup and menupick return codes.
							 * Switch on the class, then on the ID.
							 */
						
							switch(result & WMHI_CLASSMASK)
							{
							case WMHI_GADGETUP:
							
								/* OK, got a gadgetup from something. Lets find out what the something is.
								 * The code WORD to which a pointer was passed to WM_HANDLEINPUT has been
								 * set to the Code value from the IDCMP_GADGETUP, in case we need it.
								 */
							
								switch(result & WMHI_GADGETMASK)
								{
								case G_ObjList:
									/* User clicked on the listview  */
									{
										static ULONG ids[] = { G_Top, G_Up, G_Down, G_Bottom, G_Edit, G_Copy, G_Remove, 0 };
										ULONG i, dis = FALSE;
										
										if (code < 0) /* no node was selected */
											dis = TRUE;
										
										for ( i = 0 ; ids[i] ; i++ )
										{
											IIntuition->SetGadgetAttrs( GL[ids[i]], Win, NULL, GA_Disabled, dis, TAG_END );
											IIntuition->RefreshGList( GL[ids[i]], Win, NULL, 1 );
										}
										
										break;
									}
								}
								break;
								
							case WMHI_GADGETHELP:
								{
									STRPTR helptext;
									
									/* A gadget help message informs the application about the gadget
									 * under the mouse pointer. The code WORD is set to the value the
									 * gadget returned. Result code contains the ID of the gadget, 
									 * or NULL (not in the window) or WMHI_GADGETMASK (not over a gadget).
									 */
								
									switch(result & WMHI_GADGETMASK)
									{
									case G_ObjType:
										helptext = "Choose object type";
										break;
									case G_ObjList:
										helptext = "Choose object to modify";
										break;
									case G_Top:
										helptext = "Move object to top";
										break;
									case G_Up:
										helptext = "Move object upwards";
										break;
									case G_Down:
										helptext = "Move object downwards";
										break;
									case G_Bottom:
										helptext = "Move object to bottom";
										break;
									case G_Sort:
										helptext = "Sort object list";
										break;
									case G_New:
										helptext = "Create new object";
										break;
									case G_Edit:
										helptext = "Edit object";
										break;
									case G_Copy:
										helptext = "Make a new copy of object";
										break;
									case G_Remove:
										helptext = "Delete the object";
										break;
									case G_Help:
										helptext = "Hey there ;)";
										break;
									case G_Save:
										helptext = "Save settings";
										break;
									case G_Use:
										helptext = "Use these settings";
										break;
									case G_Test:
										helptext = "Test these settings";
										break;
									case G_Cancel:
										helptext = "Cancel changes";
										break;
									default:
										helptext = "";
										break;
									}
									if (IIntuition->SetGadgetAttrs( GL[G_Help], Win, NULL, GA_Text, helptext, TAG_END ))
										IIntuition->RefreshGList(GL[G_Help], Win, NULL, 1);
								}
								break;

							case WMHI_CLOSEWINDOW:
								/* The window close gadget was hit. Time to die... */
								done = TRUE;
								break;
								
							case WMHI_ICONIFY:
								/* Window requests that it be iconified. Handle this event as
								 * soon as possible. The window is not iconified automatically to
								 * give you a chance to make note that the window pointer will be 
								 * invalid before the window closes. It also allows you to free
								 * resources only needed when the window is open, if you wish to.
								 */
								if (RA_Iconify( Window ))
									Win = NULL;
								break;
								 
							case WMHI_UNICONIFY:
								/* The window should be reopened. If you had free'd something
								 * on iconify, now is the time to re-allocate it, before calling
								 * RA_OpenWindow.
								 */
								Win = RA_OpenWindow( Window );
								break;
							}
						}
					}
					else if (sig & SIGBREAKF_CTRL_C)
					{
						done = TRUE;
					}
				}
				/* Close the window and dispose of all attached gadgets  */
				IIntuition->DisposeObject( Window );
			}
		}
	}
	
	if (appport)
		IExec->DeleteMsgPort(appport);
	
	/* NULL is valid input for these helper functions, so no need to check.
	 */
	FreeChooserLabels( typelist );
	FreeBrowserNodes( objlist );
	
	IDOS->FreeArgs(args);
}

/* As ReAction doesn't have some of the nicer macros that 
*  ClassAct had, we are creating them here as functions for 
*  legacy compatibility 
*/

struct List *
BrowserNodesA( STRPTR *labelarray )
{

	struct List *browserlist;
	struct Node *node;
	int index = 0;

	if (!( browserlist = IExec->AllocMem( sizeof (struct List), MEMF_ANY ))) 
		return 0;

	IExec->NewList( browserlist );

	while ( labelarray[index]) {
	
		if (node = IListBrowser->AllocListBrowserNode( 1, LBNCA_Text, labelarray[index], TAG_DONE ))
			IExec->AddTail( browserlist, node );

		index++;
	}

	return (struct List *)browserlist;

}


void
FreeBrowserNodes( struct List *browserlist )		
{

	if (browserlist) {
		IListBrowser->FreeListBrowserList( browserlist );	
		IExec->FreeMem( browserlist, sizeof (struct List ) );
	}
}

struct List*
ChooserLabelsA(  STRPTR *labelarray )
{

	struct List *chooserlist;
	struct Node *node;
	int index = 0;

	if (!( chooserlist = IExec->AllocMem( sizeof (struct List), MEMF_ANY ))) 
		return 0;

	IExec->NewList( chooserlist );

	while ( labelarray[index]) {
		
		if (node = IChooser->AllocChooserNode( CNA_Text, labelarray[index], TAG_DONE ))
			IExec->AddTail( chooserlist, node );

		index++;
	}

	return (struct List *)chooserlist;

}

void 
FreeChooserLabels( struct List *chooserlist )
{

	struct Node *node;

	if (chooserlist) {
		node = chooserlist->lh_Head;

		while (node->ln_Succ) {

			IChooser->FreeChooserNode( node );

			node = node->ln_Succ;
		}

		IExec->FreeMem( chooserlist, sizeof (struct List ));
	}

}
