;/* Page Example
gcc -o PageExample pageexample.c -lauto -lraauto
quit
*/

/**
 **  PageExample.c -- Layout page gadget class Example.
 **
 **  This is a simple example testing some of the NEW capabilities
 **  of the clicktab and page layout gadget class. Note, the
 **  "embedded" page
 **
 **  Best viewed with TabSize = 2, or = 4.
 **/

/* system includes */
#define ALL_REACTION_CLASSES
#include <reaction/reaction.h>
#include <reaction/reaction_macros.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/icon.h>

enum
{
	GID_MAIN=0,
	GID_CLICKTAB,
	GID_PAGE,

	GID_ALIGN1,
	GID_ALIGN2,
	GID_ALIGN3,

	GID_PAGELAY1,
	GID_PAGELAY2,

	GID_COMPANY,
	GID_LASTNAME,
	GID_FIRSTNAME,
	GID_ADD1,
	GID_ADD2,
	GID_CITY,
	GID_STATE,
	GID_ZIPCODE,
	GID_PHONE,
	GID_FAX,

	GID_CUSTOMERS,
	GID_ORDERS,
	GID_DETAILS,
	GID_NEWORD,
	GID_EDITORD,
	GID_DELORD,

	GID_QUIT,
	GID_LAST
};

enum
{
	WID_MAIN=0,
	WID_LAST
};

enum
{
	OID_MAIN=0,
	OID_LAST
};


int main(void)
{
	struct MsgPort *AppPort;

	struct Window *windows[WID_LAST];

	struct Gadget *gadgets[GID_LAST];

	Object *objects[OID_LAST];

	/* special case - reference buttonbase to make sure it autoinit! */
	if ( !ButtonBase )
		return(30);
	else if ( AppPort = IExec->CreateMsgPort() )
	{
		STRPTR tablabels[] = { "_Contacts","_Orders", NULL };

		if (tablabels)
		{
			/* Create the window object */
			objects[OID_MAIN] = WindowObject,
				WA_ScreenTitle, "Reaction OS4",
				WA_Title, "ReAction Page Example",
				WA_Activate, TRUE,
				WA_DepthGadget, TRUE,
				WA_DragBar, TRUE,
				WA_CloseGadget, TRUE,
				WA_SizeGadget, TRUE,
				WINDOW_IconifyGadget, TRUE,
				WINDOW_IconTitle, "Page",
				WINDOW_AppPort, AppPort,
				WINDOW_Position, WPOS_CENTERMOUSE,
				WINDOW_ParentGroup, gadgets[GID_MAIN] = VGroupObject,
					LAYOUT_DeferLayout, TRUE,
					LAYOUT_SpaceOuter, TRUE,
					LAYOUT_SpaceInner, TRUE,

					LAYOUT_AddChild,  gadgets[GID_CLICKTAB] = ClickTabObject,
						GA_ID, GID_CLICKTAB,
						GA_RelVerify, TRUE,
						GA_Text, tablabels,

						/* Embed the PageObject "inside" the Clicktab
						 * the clicktab's beveling will surround the page.
						 */
						CLICKTAB_PageGroup, gadgets[GID_PAGE] = PageObject,
							/* We will defer layout/render changing pages! */
							LAYOUT_DeferLayout, TRUE,

							PAGE_Add, gadgets[GID_PAGELAY1] = VGroupObject,
								LAYOUT_SpaceOuter, TRUE,
								LAYOUT_SpaceInner, TRUE,

								LAYOUT_AddChild, gadgets[GID_COMPANY] = StringObject,
									GA_ID, GID_COMPANY,
									GA_RelVerify, TRUE,
									GA_TabCycle, TRUE,
									STRINGA_MaxChars, 48,
									STRINGA_TextVal, "",
								StringEnd,
								CHILD_Label, LabelObject, LABEL_Text,"Company", LabelEnd,
								CHILD_MinWidth, 200,

								LAYOUT_AddChild, gadgets[GID_ALIGN1] = HGroupObject,
									LAYOUT_AddChild, gadgets[GID_LASTNAME] = StringObject,
										GA_ID, GID_LASTNAME,
										GA_RelVerify, TRUE,
										GA_TabCycle, TRUE,
										STRINGA_MaxChars, 48,
										STRINGA_TextVal, "",
									StringEnd,
									CHILD_Label, LabelObject, LABEL_Text,"Last", LabelEnd,

									LAYOUT_AddChild, gadgets[GID_FIRSTNAME] = StringObject,
										GA_ID, GID_FIRSTNAME,
										GA_RelVerify, TRUE,
										GA_TabCycle, TRUE,
										STRINGA_MaxChars, 48,
										STRINGA_TextVal, "",
									StringEnd,
									CHILD_Label, LabelObject, LABEL_Text,"First", LabelEnd,
								LayoutEnd,
								CHILD_WeightedHeight, 0,

								LAYOUT_AddChild, gadgets[GID_ADD1] = StringObject,
									GA_ID, GID_ADD1,
									GA_RelVerify, TRUE,
									GA_TabCycle, TRUE,
									STRINGA_MaxChars, 48,
									STRINGA_TextVal, "",
								StringEnd,
								CHILD_Label, LabelObject, LABEL_Text,"Address 1", LabelEnd,

								LAYOUT_AddChild, gadgets[GID_ADD2] = StringObject,
									GA_ID, GID_ADD2,
									GA_RelVerify, TRUE,
									GA_TabCycle, TRUE,
									STRINGA_MaxChars, 48,
									STRINGA_TextVal, "",
								StringEnd,
								CHILD_Label, LabelObject, LABEL_Text,"Address 2", LabelEnd,

								LAYOUT_AddChild, gadgets[GID_ALIGN2] = HGroupObject,
									LAYOUT_AddChild, gadgets[GID_CITY] = StringObject,
										GA_ID, GID_CITY,
										GA_RelVerify, TRUE,
										GA_TabCycle, TRUE,
										STRINGA_MaxChars, 48,
										STRINGA_TextVal, "",
									StringEnd,
									CHILD_Label, LabelObject, LABEL_Text,"City", LabelEnd,
									CHILD_WeightedWidth, 100,

									LAYOUT_AddChild, gadgets[GID_STATE] = StringObject,
										GA_ID, GID_STATE,
										GA_RelVerify, TRUE,
										GA_TabCycle, TRUE,
										STRINGA_MaxChars, 48,
										STRINGA_TextVal, "",
									StringEnd,
									CHILD_Label, LabelObject, LABEL_Text,"State", LabelEnd,
									CHILD_WeightedWidth, 75,

									LAYOUT_AddChild, gadgets[GID_ZIPCODE] = StringObject,
										GA_ID, GID_ZIPCODE,
										GA_RelVerify, TRUE,
										GA_TabCycle, TRUE,
										STRINGA_MaxChars, 24,
										STRINGA_TextVal, "",
									StringEnd,
									CHILD_Label, LabelObject, LABEL_Text,"ZipCode", LabelEnd,
									CHILD_WeightedWidth, 25,
								LayoutEnd,
								CHILD_WeightedHeight, 0,

								LAYOUT_AddChild, gadgets[GID_ALIGN3] = HGroupObject,
									LAYOUT_BevelStyle, BVS_SBAR_VERT,
									LAYOUT_TopSpacing, 2,

									LAYOUT_AddChild, gadgets[GID_PHONE] = StringObject,
										GA_ID, GID_PHONE,
										GA_RelVerify, TRUE,
										GA_TabCycle, TRUE,
										STRINGA_MaxChars, 48,
										STRINGA_TextVal, "",
									StringEnd,
									CHILD_Label, LabelObject, LABEL_Text,"Phone", LabelEnd,

									LAYOUT_AddChild, gadgets[GID_FAX] = StringObject,
										GA_ID, GID_FAX,
										GA_RelVerify, TRUE,
										GA_TabCycle, TRUE,
										STRINGA_MaxChars, 48,
										STRINGA_TextVal, "",
									StringEnd,
									CHILD_Label, LabelObject, LABEL_Text,"Fax", LabelEnd,
								LayoutEnd,
								CHILD_WeightedHeight, 0,
							LayoutEnd,

							PAGE_Add, gadgets[GID_PAGELAY2] = VGroupObject,
								LAYOUT_SpaceOuter, TRUE,
								LAYOUT_SpaceInner, TRUE,

								LAYOUT_AddChild, HGroupObject,
									LAYOUT_SpaceInner, TRUE,
									// customer
									LAYOUT_AddChild, gadgets[GID_CUSTOMERS] = ListBrowserObject,
										GA_ID, GID_CUSTOMERS,
										GA_RelVerify, TRUE,
										LISTBROWSER_Labels, NULL,
										LISTBROWSER_ShowSelected, TRUE,
										LISTBROWSER_HorizontalProp, TRUE,
									ListBrowserEnd,
									CHILD_WeightedWidth, 30,

									LAYOUT_AddChild, VGroupObject,
										LAYOUT_SpaceInner, TRUE,
										// orders
										LAYOUT_AddChild, gadgets[GID_ORDERS] = ListBrowserObject,
											GA_ID, GID_ORDERS,
											GA_RelVerify, TRUE,
											LISTBROWSER_Labels, NULL,
											LISTBROWSER_ShowSelected, TRUE,
											LISTBROWSER_HorizontalProp, TRUE,
										ListBrowserEnd,
										// details
										LAYOUT_AddChild, gadgets[GID_DETAILS] = ListBrowserObject,
											GA_ID, GID_DETAILS,
											GA_RelVerify, TRUE,
											LISTBROWSER_Labels, NULL,
											LISTBROWSER_ShowSelected, TRUE,
											LISTBROWSER_HorizontalProp, TRUE,
										ListBrowserEnd,
									LayoutEnd,
									CHILD_WeightedWidth, 70,
								LayoutEnd,

								LAYOUT_AddChild, HGroupObject,
									LAYOUT_AddChild, gadgets[GID_NEWORD] = ButtonObject,
										GA_ID, GID_NEWORD,
										GA_RelVerify, TRUE,
										GA_Text, "_New Order",
									ButtonEnd,

									LAYOUT_AddChild, gadgets[GID_EDITORD] = ButtonObject,
										GA_ID, GID_EDITORD,
										GA_RelVerify, TRUE,
										GA_Text, "_Edit Order",
									ButtonEnd,

									LAYOUT_AddChild, gadgets[GID_DELORD] = ButtonObject,
										GA_ID, GID_DELORD,
										GA_RelVerify, TRUE,
										GA_Text, "_Delete Order",
									ButtonEnd,

								LayoutEnd,
								CHILD_WeightedHeight, 0,

							LayoutEnd,

						PageEnd,

					ClickTabEnd,

					LAYOUT_AddChild, ButtonObject,
						GA_ID, GID_QUIT,
						GA_RelVerify, TRUE,
						GA_Text,"_Quit",
					ButtonEnd,
					CHILD_WeightedHeight, 0,

				EndGroup,
			EndWindow;

	 	 	/*  Object creation sucessful? */
			if (objects[OID_MAIN])
			{
				/* Set up inter-group label pagement. */
				IIntuition->SetAttrs( gadgets[GID_PAGELAY1], LAYOUT_AlignLabels,  gadgets[GID_ALIGN1], TAG_DONE);
				IIntuition->SetAttrs( gadgets[GID_ALIGN1], LAYOUT_AlignLabels, gadgets[GID_ALIGN2], TAG_DONE);
				IIntuition->SetAttrs( gadgets[GID_ALIGN2], LAYOUT_AlignLabels, gadgets[GID_ALIGN3], TAG_DONE);

				/*  Open the window. */
				if (windows[WID_MAIN] = (struct Window *) RA_OpenWindow(objects[OID_MAIN]))
				{
					ULONG wait, signal, app = (1L << AppPort->mp_SigBit);
					ULONG done = FALSE;
					ULONG result;
					UWORD code;

				 	/* Obtain the window wait signal mask. */
					IIntuition->GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);

					/* Activate the first string gadget! */
					ILayout->ActivateLayoutGadget( gadgets[GID_MAIN], windows[WID_MAIN], NULL, (Object) &gadgets[GID_COMPANY] );

					/* Input Event Loop */
					while (!done)
					{
						wait = IExec->Wait( signal | SIGBREAKF_CTRL_C | app );

						if ( wait & SIGBREAKF_CTRL_C )
						{
							done = TRUE;
						}
						else
						{
							while ( (result = RA_HandleInput(objects[OID_MAIN], &code) ) != WMHI_LASTMSG )
							{
								switch (result & WMHI_CLASSMASK)
								{
									case WMHI_CLOSEWINDOW:
										windows[WID_MAIN] = NULL;
										done = TRUE;
										break;

									case WMHI_GADGETUP:
										switch (result & WMHI_GADGETMASK)
										{
											case GID_COMPANY:
												printf( "Company: %s\n", ((struct StringInfo *)(gadgets[GID_COMPANY]->SpecialInfo))->Buffer);
												break;

											case GID_QUIT:
												done = TRUE;
												break;
										}
										break;

									case WMHI_ICONIFY:
										RA_Iconify(objects[OID_MAIN]);
										windows[WID_MAIN] = NULL;
										break;

									case WMHI_UNICONIFY:
										windows[WID_MAIN] = (struct Window *) RA_OpenWindow(objects[OID_MAIN]);

										if (windows[WID_MAIN])
										{
											IIntuition->GetAttr(WINDOW_SigMask, objects[OID_MAIN], &signal);
										}
										else
										{
											done = TRUE;	// error re-opening window!
										}
									 	break;
								}
							}
						}
					}
				}

				/* Disposing of the window object will also close the window if it is
				 * already opened, and it will dispose of the layout object attached to it.
				 */
				IIntuition->DisposeObject(objects[OID_MAIN]);
			}

		}

		/* close/free the application port. */
		IExec->DeleteMsgPort(AppPort);
	}

	return(0);
}
