;/* execute me to compile
gcc -o ClickTabExample ClickTabExample.c -lauto ;-lraauto
quit
;*/

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <stdio.h>
#include <string.h>
#include <math.h>

#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/exec.h>

struct Library *WindowBase;
struct WindowIFace *IWindow;
struct Library *LayoutBase;
struct LayoutIFace *ILayout;
struct Library *ClickTabBase;
struct ClickTabIFace *IClickTab;

#define ID_CLICKTAB		1

struct List listitems;
UBYTE *names[] = 
{
    "Tab_1",
    "Tab_2",
    "Tab_3",
    "Tab_4",
    NULL
};

BOOL ClickTabNodes(struct List *list, UBYTE **labels)
{
	struct Node *node;
	WORD i = 0;

	IExec->NewList(list);

	while (*labels)
	{
		if (node = (struct Node *)IClickTab->AllocClickTabNode(
			TNA_Text, *labels,
			TNA_Number, i,
			TNA_Enabled, TRUE,
			TNA_Spacing, 6,
			TAG_DONE))
		{
			IExec->AddTail(list, node);
		}
		labels++;
		i++;
	}
	return(TRUE);
}

VOID FreeClickTabNodes(struct List *list)
{
	struct Node *node, *nextnode;

	node = list->lh_Head;
	while (nextnode = node->ln_Succ)
	{
		IClickTab->FreeClickTabNode(node);
		node = nextnode;
	}
	IExec->NewList(list);
}

int main( int argc, char *argv[] )
{
	struct Window *window;
	Object *Tab_Object;
	Object *Win_Object;

	/* Open the classes - typically not required to be done manually.
	 * GCC AutoInit can do this for you if linked with the
	 * compiler switch -lraauto
	 */
	WindowBase = (struct Library *)IExec->OpenLibrary("window.class",0L);
	IWindow = (struct WindowIFace *)IExec->GetInterface( WindowBase, "main", 1L, NULL );
	LayoutBase = (struct Library *)IExec->OpenLibrary("gadgets/layout.gadget",0L);
	ILayout = (struct LayoutIFace *)IExec->GetInterface( LayoutBase, "main", 1L, NULL );
	ClickTabBase = (struct Library *)IExec->OpenLibrary("gadgets/clicktab.gadget",0L);
	IClickTab = (struct ClickTabIFace *)IExec->GetInterface( ClickTabBase, "main", 1L, NULL );

	if(WindowBase && IWindow && LayoutBase && ILayout && ClickTabBase && IClickTab)
	{
		ClickTabNodes(&listitems, names);

		/* Create the window object. */
		Win_Object = WindowObject,
			WA_ScreenTitle, "ReAction OS4",
			WA_Title, "ReAction clicktab.gadget Example",
			WA_SizeGadget, TRUE,
			WA_Left, 40,
			WA_Top, 30,
			WA_DepthGadget, TRUE,
			WA_DragBar, TRUE,
			WA_CloseGadget, TRUE,
			WA_Activate, TRUE,
			WA_SmartRefresh, TRUE,
			WINDOW_ParentGroup, VLayoutObject,
				LAYOUT_SpaceOuter, TRUE,
				LAYOUT_DeferLayout, TRUE,
				StartMember, Tab_Object = ClickTabObject,
					GA_ID, ID_CLICKTAB,
					CLICKTAB_Labels, &listitems,
					CLICKTAB_Current, 0L,
				EndMember,
			EndMember,
		EndWindow;

		/*  Object creation sucessful? */
		if( Win_Object )
		{
			/*  Open the window. */
			if( window = (struct Window *) RA_OpenWindow(Win_Object) )
			{
				ULONG wait, signal, result, done = FALSE;
				WORD Code;
				
				/* Obtain the window wait signal mask. */
				IIntuition->GetAttr( WINDOW_SigMask, Win_Object, &signal );

				/* Input Event Loop */
				while( !done )
				{
					wait = IExec->Wait(signal|SIGBREAKF_CTRL_C);
					
					if (wait & SIGBREAKF_CTRL_C) done = TRUE;
					else

					while ((result = RA_HandleInput(Win_Object,&Code)) != WMHI_LASTMSG)
					{
						switch (result & WMHI_CLASSMASK)
						{
							case WMHI_CLOSEWINDOW:
								done = TRUE;
								break;

							case WMHI_GADGETUP:
								switch(result & WMHI_GADGETMASK)
								{
									case ID_CLICKTAB:
										break;
								}
								break;
						}
					}
				}
			}

			/* Disposing of the window object will
			 * also close the window if it is
			 * already opened and it will dispose of
			 * all objects attached to it.
			 */
			IIntuition->DisposeObject( Win_Object );
		}
	}

	FreeClickTabNodes(&listitems);

	/* Close the classes. */
	if (IClickTab) IExec->DropInterface( (struct Interface *)IClickTab );
	if (ClickTabBase) IExec->CloseLibrary( (struct Library *)ClickTabBase );
	if (ILayout) IExec->DropInterface( (struct Interface *)ILayout );
	if (LayoutBase)	IExec->CloseLibrary( (struct Library *)LayoutBase );
	if (IWindow) IExec->DropInterface( (struct Interface *)IWindow );
	if (WindowBase) IExec->CloseLibrary( (struct Library *)WindowBase );
}

#ifdef _DCC
int wbmain( struct WBStartup *wbs )
{
	return( main( 0, NULL ));
}
#endif
