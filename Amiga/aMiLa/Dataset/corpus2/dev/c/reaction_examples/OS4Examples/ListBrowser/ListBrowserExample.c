;/* Execute me to compile
gcc -o ListBrowserExample ListBrowserExample.c -lauto 
quit
;*/
/**
 **  ListBrowserTest.c -- List Browser class test.
 **
 **  This is a simple example testing some of the capabilities of the
 **  ListBrowser gadget class.
 **
 **  This code opens a simple window and then a ListBrowser gadget which is
 **  subsequently attached to the window's gadget list.  Everytime the user
 **  clicks on the close gadget, this code changes some of the attributes
 **  of the ListBrowser gadget to demonstrate different ways it can be used,
 **  including one demonstration which creates two images using the Label
 **  class and shows them in the ListBrowser.
 **
 **/

#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>

#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>

#define RAWKEY_CURSORUP 76
#define RAWKEY_CURSORDOWN 77
#define QUALIFIER_SHIFT 0x03
#define QUALIFIER_CTRL 0x08


/* Function prototypes. */
BOOL make_list(struct List *, UBYTE **, LONG *);
VOID free_list(struct List *);
VOID wait_for_close(struct Window *, struct Gadget *);
struct Library * OpenClass(STRPTR, ULONG);

/* Global variables.*/
struct Library *ListBrowserBase;
struct ListBrowserIFace *IListBrowser;
struct Library *LabelBase;
struct LabelIFace *ILabel;


UBYTE *col1[] =
{
	"This is a", "test of the", "ListBrowser", "gadget class.",
	"This is like", "a souped-up", "listview", "gadget.  It", "has many",
	"cool new", "features", "though like", "multiple", "columns,",
	"horizontal", "scrolling,", "images in", "nodes,", "columns titles",
	"and much much", "more!",
	"This is a", "test of the", "ListBrowser", "gadget class.",
	"This is like", "a souped-up", "listview", "gadget.  It", "has many",
	"cool new", "features", "though like", "multiple", "columns,",
	"horizontal", "scrolling,", "images in", "nodes,", "columns titles",
	"and much much", "more!",
	"This is a", "test of the", "ListBrowser", "gadget class.",
	"This is like", "a souped-up", "listview", "gadget.  It", "has many",
	"cool new", "features", "though like", "multiple", "columns,",
	"horizontal", "scrolling,", "images in", "nodes,", "columns titles",
	"and much much", "more!", NULL
};

LONG col2[] =
{
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
	15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
	27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
	39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
	51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62,
	63
};

struct ColumnInfo ci[] =
{
	{ 80, "Col 1", 0 },
	{ 60, "Col 2", 0 },
	{ 60, "Col 3", 0 },
	{ -1, (STRPTR)~0, -1 }
};

struct ColumnInfo fancy_ci[] =
{
	{ 100, NULL, 0 },
	{ -1, (STRPTR)~0, -1 }
};

/* Some fonts for our fancy list. */
struct TextAttr helvetica24b = { (STRPTR)"helvetica.font", 24, FSF_BOLD, FPF_DISKFONT };
struct TextAttr times18i = { (STRPTR)"times.font", 18, FSF_ITALIC, FPF_DISKFONT };
struct TextAttr times18 = { (STRPTR)"times.font", 18, 0, FPF_DISKFONT };


/* This is the start of our programme. */
main()
{
	struct Screen *screen = NULL;

	/* We'll just open up on the default public screen, and use its screen font. */
	if (screen = IIntuition->LockPubScreen(NULL))
	{
		struct Window *win = NULL;

		/* Open the window, note how we size the window to perfectly fit
		 * all the gadgets.
		 */
		if (win = IIntuition->OpenWindowTags(NULL,
			WA_Left, 0,
			WA_Top, screen->Font->ta_YSize + 3,
			WA_Width, 300,
			WA_Height, 160,
			WA_CustomScreen, screen,
			WA_IDCMP, IDCMP_GADGETUP | IDCMP_MOUSEMOVE | IDCMP_RAWKEY |
						IDCMP_CLOSEWINDOW | IDCMP_GADGETDOWN,
			WA_Flags, WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET |
						WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH,
			WA_Title, "ReAction ListBrowser Class Demo",
			WA_MinWidth, 50,
			WA_MinHeight, 50,
			WA_MaxWidth, -1,
			WA_MaxHeight, -1,
			TAG_DONE))
		{
			/* Create the private BOOPSI image class. */
			IDOS->PutStr("Creating ListBrowser class\n");
			if ((ListBrowserBase = OpenClass("gadgets/listbrowser.gadget", 0)) && (IListBrowser = (struct ListbrowserIFace *)IExec->GetInterface( ListBrowserBase, "main", 1L, NULL)))
			{
				struct Gadget *listbrowser_gad;
				struct List label_list;

				make_list(&label_list, col1, col2);

				/* Create a listbrowser gadget. */
				IDOS->PutStr("Creating ListBrowser object\n");
				if (listbrowser_gad = (struct Gadget *)IIntuition->NewObject(IListBrowser->LISTBROWSER_GetClass(), NULL,
														GA_ID, 1,
														GA_Top, win->BorderTop + 5,
														GA_Left, 10,
														GA_RelWidth, -34,
														GA_RelHeight, -(win->BorderTop + win->BorderBottom + 10),
														GA_RelVerify, TRUE,
														LISTBROWSER_Labels, (ULONG)&label_list,
														LISTBROWSER_ColumnInfo, (ULONG)&ci,
														LISTBROWSER_ColumnTitles, TRUE,
														LISTBROWSER_MultiSelect, FALSE,
														LISTBROWSER_Separators, TRUE,
														LISTBROWSER_ShowSelected, FALSE,
														LISTBROWSER_Editable, TRUE,
														TAG_END))
				{
					/* Adding gadgets */
					IDOS->PutStr("Adding gadget\n");
					IIntuition->AddGList(win, listbrowser_gad, -1, -1, NULL);
					IDOS->PutStr("Refreshing gadget\n");
					IIntuition->RefreshGList(listbrowser_gad, win, NULL, -1);

					/* Wait for close gadget click to continue. */
					IIntuition->SetWindowTitles(win, "<- Click here to continue", (UBYTE *)~0);
					wait_for_close(win, listbrowser_gad);

					/* Make Visible */
					IIntuition->SetWindowTitles(win, "Make Visible 10", (UBYTE *)~0);
					IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
						LISTBROWSER_MakeVisible, 10,
						LISTBROWSER_EditNode, 8,
						LISTBROWSER_EditColumn, 1,
						TAG_DONE);
					IIntuition->ActivateGadget(listbrowser_gad, win, NULL);
					wait_for_close(win, listbrowser_gad);

					/* Show selected */
					IIntuition->SetWindowTitles(win, "Show selected, Auto-Fit", (UBYTE *)~0);
					IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
						LISTBROWSER_ShowSelected, TRUE,
						LISTBROWSER_AutoFit, TRUE,
						LISTBROWSER_HorizontalProp, TRUE,
						TAG_DONE);
					wait_for_close(win, listbrowser_gad);

					/* Multi-select */
					IIntuition->SetWindowTitles(win, "Multi-select, Virtual Width of 500", (UBYTE *)~0);
					IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
						LISTBROWSER_MultiSelect, TRUE,
						LISTBROWSER_VirtualWidth, 500,
						LISTBROWSER_AutoFit, FALSE,
						TAG_DONE);
					wait_for_close(win, listbrowser_gad);

					/* Detach the list. */
					IIntuition->SetWindowTitles(win, "Detached list", (UBYTE *)~0);
					IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
						LISTBROWSER_MultiSelect, FALSE,
						LISTBROWSER_Labels, ~0,
						TAG_DONE);
					wait_for_close(win, listbrowser_gad);

					/* No separators, no title, 1 column. */
					IIntuition->SetWindowTitles(win, "No separators, no title, 1 column.", (UBYTE *)~0);
					IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
						LISTBROWSER_Labels, (ULONG)&label_list,
						LISTBROWSER_ColumnInfo, (ULONG)&fancy_ci,
						LISTBROWSER_Separators, FALSE,
						LISTBROWSER_ColumnTitles, FALSE,
						LISTBROWSER_AutoFit, TRUE,
						LISTBROWSER_VirtualWidth, 0,
						TAG_DONE);
					wait_for_close(win, listbrowser_gad);

					/* Fancy list. */
					IDOS->PutStr("Creating Label class\n");
					if ((LabelBase = OpenClass("images/label.image", 0)) && (ILabel = (struct LabelIFace *)IExec->GetInterface( LabelBase, "main", 1L, NULL )))
					{
						struct List fancy_list;
						struct Image *image1, *image2;
						struct Node *node1, *node2;

						IExec->NewList(&fancy_list);

						IDOS->PutStr("Creating Label object\n");
						if (image1 = (struct Image *)IIntuition->NewObject(ILabel->LABEL_GetClass(), NULL,
														IA_FGPen, 1,
														IA_BGPen, 2,
														IA_Font, (ULONG)&helvetica24b,
														LABEL_Text, (ULONG)"R",
														IA_Font, (ULONG)&times18i,
														LABEL_Text, (ULONG)"e ",
														IA_Font, (ULONG)&helvetica24b,
														LABEL_Text, (ULONG)"A",
														IA_Font, (ULONG)&times18i,
														LABEL_Text, (ULONG)"ction",
														TAG_END))
						{
							IDOS->PutStr("Creating Label object\n");
							if (image2 = (struct Image *)IIntuition->NewObject(ILabel->LABEL_GetClass(), NULL,
															IA_FGPen, 2,
															IA_BGPen, 0,
															IA_Font, (ULONG)&times18,
															LABEL_Text, (ULONG)"Thanks to AmigaOS 4",
															TAG_END))
							{
								if (node1 = IListBrowser->AllocListBrowserNode(1,
												LBNA_Column, 0,
													LBNCA_Image, (ULONG)image1,
													LBNCA_Justification, LCJ_CENTRE,
												TAG_DONE))
								{
									IExec->AddTail(&fancy_list, node1);

									if (node2 = IListBrowser->AllocListBrowserNode(1,
													LBNA_Column, 0,
														LBNCA_Image, (ULONG)image2,
														LBNCA_Justification, LCJ_CENTRE,
													TAG_DONE))
									{
										IExec->AddTail(&fancy_list, node2);

										/* Set listbrowser. */
										IIntuition->SetWindowTitles(win, "Fancy", (UBYTE *)~0);
										IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
											LISTBROWSER_ColumnInfo, &fancy_ci,
											LISTBROWSER_Labels, (ULONG)&fancy_list,
											LISTBROWSER_AutoFit, TRUE,
											TAG_DONE);

										wait_for_close(win, listbrowser_gad);

										IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
											LISTBROWSER_Labels, ~0,
											TAG_DONE);

										IListBrowser->FreeListBrowserNode(node2);
									}
									IListBrowser->FreeListBrowserNode(node1);
								}
								IIntuition->DisposeObject(image2);
							}
							IIntuition->DisposeObject(image1);
						}

						IDOS->PutStr("Closing Label class\n");
						IExec->CloseLibrary((struct Library *)LabelBase);
					}
					else
						IDOS->PutStr("ERROR: Couldn't create Label class\n");

					/* Read-only */
					IIntuition->SetWindowTitles(win, "Read-only", (UBYTE *)~0);
					IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
						LISTBROWSER_ColumnInfo, (ULONG)&ci,
						LISTBROWSER_Labels, (ULONG)&label_list,
						LISTBROWSER_AutoFit, TRUE,
						LISTBROWSER_Selected, -1,
						GA_ReadOnly, TRUE,
						TAG_DONE);
					wait_for_close(win, listbrowser_gad);

					/* Disabled. */
					IIntuition->SetWindowTitles(win, "Disabled", (UBYTE *)~0);
					IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
						GA_Disabled, TRUE,
						GA_ReadOnly, FALSE,
						TAG_DONE);
					wait_for_close(win, listbrowser_gad);

					/* No scrollbars, borderless. */
					IIntuition->SetWindowTitles(win, "No scrollbars, borderless", (UBYTE *)~0);
					IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
						GA_Disabled, FALSE,
						GA_Top, win->BorderTop,
						GA_Left, 2,
						GA_RelWidth, -18,
						GA_RelHeight, -(win->BorderTop + win->BorderBottom),
						LISTBROWSER_Borderless, TRUE,
						LISTBROWSER_HorizontalProp, FALSE,
						LISTBROWSER_VerticalProp, FALSE,
						TAG_DONE);
					wait_for_close(win, listbrowser_gad);

					IIntuition->RemoveGList(win, listbrowser_gad, -1);
					IIntuition->DisposeObject(listbrowser_gad);
				}
				else
					IDOS->PutStr("ERROR: Couldn't create ListBrowser gadgetn");

				free_list(&label_list);

				IDOS->PutStr("Freeing ListBrowser class\n");
				IExec->CloseLibrary((struct Library *)ListBrowserBase);
			}
			else
				IDOS->PutStr("ERROR: Couldn't create ListBrowser class\n");

			IIntuition->CloseWindow(win);
		}
		else
			IDOS->PutStr("ERROR: Couldn't open window\n");

	    IIntuition->UnlockPubScreen(0, screen);
	}
	else
		IDOS->PutStr("ERROR: Couldn't lock public screen\n");
}


/* Function to make a List of ListBrowserNodes from a couple of arrays.
 * Just to demonstrate things, we make make three columns, 2 with text
 * (the same text) and the third with numbers.
 */
BOOL make_list(struct List *list, UBYTE **labels1, LONG *labels2)
{
	struct Node *node;
	WORD i = 0;

	IExec->NewList(list);

	while (*labels1)
	{
		if (node = IListBrowser->AllocListBrowserNode(3,
						LBNA_Column, 0,
							LBNCA_CopyText, TRUE,
							LBNCA_Text, *labels1,
							LBNCA_MaxChars, 40,
							LBNCA_Editable, TRUE,
						LBNA_Column, 1,
							LBNCA_CopyText, TRUE,
							LBNCA_Text, *labels1,
							LBNCA_MaxChars, 40,
							LBNCA_Editable, TRUE,
						LBNA_Column, 2,
							LBNCA_Integer, &labels2[i],
							LBNCA_Justification, LCJ_RIGHT,
						TAG_DONE))
		{
			IExec->AddTail(list, node);
		}
		else
			break;

		labels1++;
		i++;
	}
	return(TRUE);
}


/* Function to free an Exec List of ListBrowser nodes. */
VOID free_list(struct List *list)
{
	struct Node *node, *nextnode;

	node = list->lh_Head;
	while (nextnode = node->ln_Succ)
	{
		IListBrowser->FreeListBrowserNode(node);
		node = nextnode;
	}
	IExec->NewList(list);
}


/* Function to open a BOOPSI class library.*/
struct Library * OpenClass(STRPTR name, ULONG version)
{
	struct Library *retval;
	UBYTE buffer[256];

	if ((retval = IExec->OpenLibrary(name, version)) == NULL)
	{
		sprintf (buffer, ":classes/%s", name);
		if ((retval = IExec->OpenLibrary(buffer, version)) == NULL)
		{
			sprintf(buffer, "classes/%s", name);
			retval = IExec->OpenLibrary(buffer, version);
		}
	}
	return((struct Library *)retval);
}

/* Wait for the window close gadget to be pressed. */
VOID wait_for_close(struct Window *win, struct Gadget *listbrowser_gad)
{
	BOOL ok = TRUE;

	/* Just wait around until the close gadget is pressed.*/
	while (ok)
	{
		struct Gadget *gadget;
		struct IntuiMessage *imsg;
			
		IExec->WaitPort(win->UserPort);
		while (imsg = (struct IntuiMessage *)IExec->GetMsg(win->UserPort))
		{
			switch (imsg->Class)
			{
				case IDCMP_CLOSEWINDOW:
					ok = FALSE;
					break;

				case IDCMP_RAWKEY:
					if (!(imsg->Code & IECODE_UP_PREFIX))
					{
						switch (imsg->Code)
						{
							case RAWKEY_CURSORUP:
								if (imsg->Qualifier & QUALIFIER_CTRL)
									IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
										LISTBROWSER_Position, LBP_TOP,
										TAG_DONE);
								if (imsg->Qualifier & QUALIFIER_SHIFT)
									IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
										LISTBROWSER_Position, LBP_PAGEUP,
										TAG_DONE);
								else
									IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
										LISTBROWSER_Position, LBP_LINEUP,
										TAG_DONE);
								break;

							case RAWKEY_CURSORDOWN:
								if (imsg->Qualifier & QUALIFIER_CTRL)
									IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
										LISTBROWSER_Position, LBP_BOTTOM,
										TAG_DONE);
								if (imsg->Qualifier & QUALIFIER_SHIFT)
									IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
										LISTBROWSER_Position, LBP_PAGEDOWN,
										TAG_DONE);
								else
									IIntuition->SetGadgetAttrs(listbrowser_gad, win, NULL,
										LISTBROWSER_Position, LBP_LINEDOWN,
										TAG_DONE);
								break;

							default:
								break;
						}
					}
					break;

				case IDCMP_GADGETUP:
					gadget = (struct Gadget *)imsg->IAddress;
					IDOS->Printf("Gadget: %ld  Code: %ld\n",
						(LONG)gadget->GadgetID, (LONG)imsg->Code);

					break;
		
				default:
					break;
			}
			IExec->ReplyMsg((struct Message *)imsg);
		}
	}
}
