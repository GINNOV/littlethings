/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 9/25/2003
 *---------------------------------------------------------------------
 * Copyright (c) 2005 BITbyBIT Software Group, All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * BITbyBIT Software Group (Confidential Information).  You shall not
 * disclose such Confidential Information and shall use it only in
 * accordance with the terms of the license agreement you entered into
 * with BITbyBIT Software Group.
 *
 * BITbyBIT SOFTWARE GROUP MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE
 * SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING
 * FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * BITbyBIT Software Group LLC SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
 * LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS
 * SOFTWARE OR ITS DERIVATIVES.
 *---------------------------------------------------------------------
 *
 *  Template Application for writing AVD aware software
 *
 *  Function Name: os_CreateGUI()
 *
 *  Project: AVD_Template
 *
 *  Description: Constucts the GUI Interface for this Application
 *
 *  Entry Values: pOSApp = Pointer to the OS Specific structure
 *
 *  Exit Values: AVD_ERRORCODE (if any)
 *
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

AVD_ERRORCODE os_CreateGUI(OSAPP *pOSApp)
{
	struct AVD_WindowHandle *pNewWinHandle = NULL;
	AVD_ERRORCODE           Results        = AVDERR_RESOURCENOTFOUND;

	/*
	 * You can add any MANUAL object creation you need here,
	 * but make sure not to remove or change anything below
	 * the AVD header, also do not remove or change the local
	 * variables above (AVD_ERRORCODE Results, etc.) as they
	 * are used by the code generated below.
	 */

/*AVD_START_HERE
 *********** AVD RESERVED SECTION FOR AUTO-GENERATED SOURCE CODE ***********
 * This section of the file is automatically read and updated at build time,
 * do not make any changes or add anything between here and the 'AVD_END_HERE'
 * header, or the end of this file if no 'END'ing header is found.
 ************************* DO NOT EDIT THIS HEADER *************************
 */
	/*
	 * First Allocate any dependencies for the object we are about to create
	 */
	Results = os_AllocateDependentObjects(pOSApp);
	if ( AVDERR_NOERROR != Results ) return( Results );
	/*
	 * Allocate a new window handle and create the Window class object itself
	 */
	/* Set the error code to assume a failure to start */
	Results = AVDERR_RESOURCENOTFOUND;
	if ( pNewWinHandle = (struct AVD_WindowHandle *)IExec->AllocVec(sizeof(struct AVD_WindowHandle),MEMF_VIRTUAL|MEMF_CLEAR) )
	{
		/* Zero out our new Window Handle structure */
		memset(pNewWinHandle,0,sizeof(struct AVD_WindowHandle));
		/* Initialize the final "default" window size values */
		pNewWinHandle->wh_WindowSize.Left   = pOSApp->oWindowSize.Left;
		pNewWinHandle->wh_WindowSize.Top    = pOSApp->oWindowSize.Top;
		pNewWinHandle->wh_WindowSize.Width  = pOSApp->oWindowSize.Width;
		pNewWinHandle->wh_WindowSize.Height = pOSApp->oWindowSize.Height;
		/* Initialize the final "default" window's zoom size values */
		pNewWinHandle->wh_ZoomSize.Left   = pOSApp->oZoomSize.Left;
		pNewWinHandle->wh_ZoomSize.Top    = pOSApp->oZoomSize.Top;
		pNewWinHandle->wh_ZoomSize.Width  = pOSApp->oZoomSize.Width;
		pNewWinHandle->wh_ZoomSize.Height = pOSApp->oZoomSize.Height;
		/* Create the Window Class Object with attached ReAction Interface */
		if ( pNewWinHandle->wh_WinObj = WindowObject,
			WA_Title,             pOSApp->sWindowTitle,
			WA_DragBar,           TRUE,
			WA_SmartRefresh,      TRUE,
			WA_CloseGadget,       TRUE,
			WA_SizeGadget,        TRUE,
			WA_DepthGadget,       TRUE,
			WA_Activate,          TRUE,
			WA_UserPort,          pOSApp->pMsgPort,
			WA_PubScreenName,     pOSApp->sPubScreenName,
			WA_PubScreenFallBack, TRUE,
			WA_IDCMP,
				( IDCMP_CLOSEWINDOW
				| IDCMP_NEWSIZE
				| IDCMP_REFRESHWINDOW
				| IDCMP_MOUSEBUTTONS
				| IDCMP_MOUSEMOVE
				| IDCMP_GADGETDOWN
				| IDCMP_MENUPICK
				| IDCMP_RAWKEY
				| IDCMP_ACTIVEWINDOW
				| IDCMP_INACTIVEWINDOW
				| IDCMP_DELTAMOVE
				| IDCMP_IDCMPUPDATE
				| IDCMP_MENUHELP
				| IDCMP_CHANGEWINDOW
				| IDCMP_GADGETHELP
				| IDCMP_GADGETUP ),
			WA_AutoAdjust,        TRUE,
			WA_MinWidth,          DEFAULT_WA_MINWIDTH,
			WA_MinHeight,         DEFAULT_WA_MINHEIGHT,
			WA_WindowBox,         &pNewWinHandle->wh_WindowSize,
			WA_Zoom,              &pNewWinHandle->wh_ZoomSize,
			WINDOW_VertProp,      0, /* 1 = Enable/Create Vertical Scroller (In Window border) */
			/* Add our Menus (defined in os_main.h and initialized in os_initapp.c) to the Window */
			WINDOW_NewMenu,       (struct NewMenu *)&pOSApp->oWindowMenu[0],
			/* Since we are using the Menu's nm_UserData field to store custom Menu IDs, we need to tell the Window class to ignore them */
			WINDOW_MenuUserData,  WGUD_IGNORE,
			WINDOW_GadgetHelp,    TRUE,
			WINDOW_AppPort,       pOSApp->pMsgPort,
			WINDOW_AppWindow,     TRUE,
			WINDOW_IconifyGadget, TRUE,
			WINDOW_IconTitle,     DEFAULT_ICONTITLE_STR,
			/* Attach our GUI Interface object to the window as it's contents */
			WINDOW_IconifyGadget, TRUE,
			WINDOW_Layout, pNewWinHandle->wh_Layout = VLayoutObject,
				GA_RelVerify, TRUE,
				LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
				LAYOUT_FixedHoriz, TRUE,
				LAYOUT_FixedVert, FALSE,
				LAYOUT_HorizAlignment, LAYOUT_ALIGN_LEFT,
				LAYOUT_VertAlignment, LAYOUT_ALIGN_TOP,
				LAYOUT_AddChild, OBJ(OBJ3_BUTTON) = ToggleObject,
					GA_ID, OBJ3_BUTTON,
					GA_Text, "Simple _Push Button",
					GA_RelVerify, TRUE,
					GA_ToggleSelect, TRUE,
					BUTTON_PushButton, TRUE,
					BUTTON_BevelStyle, BVS_BUTTON,
				ButtonEnd,
				LAYOUT_AddChild, HLayoutObject,
					GA_RelVerify, TRUE,
					LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
					LAYOUT_FixedHoriz, TRUE,
					LAYOUT_FixedVert, TRUE,
					LAYOUT_HorizAlignment, LAYOUT_ALIGN_LEFT,
					LAYOUT_VertAlignment, LAYOUT_ALIGN_TOP,
					LAYOUT_AddChild, OBJ(OBJ5_BUTTON) = ButtonObject,
						GA_ID, OBJ5_BUTTON,
						GA_Text, "A_nother Button",
						GA_RelVerify, TRUE,
						BUTTON_BevelStyle, BVS_BUTTON,
					ButtonEnd,
					LAYOUT_AddChild, OBJ(OBJ6_BUTTON) = ButtonObject,
						GA_ID, OBJ6_BUTTON,
						GA_Text, "_Quit",
						GA_RelVerify, TRUE,
						BUTTON_BevelStyle, BVS_BUTTON,
					ButtonEnd,
				LayoutEnd,
			LayoutEnd,
		WindowEnd )
		{
			/* Success */
			pNewWinHandle->wh_ObjectID = OBJ1_WINDOW;
			OBJ(OBJ1_WINDOW) = pNewWinHandle->wh_WinObj;
			if ( TRUE == pOSApp->bCenterWin )
			{
				/* Set the Center Window Position for this window object (used by os_DisplayGUI()) */
				IIntuition->SetAttrs(pNewWinHandle->wh_WinObj,WINDOW_Position,WPOS_CENTERSCREEN,TAG_END);
			}
			if ( TRUE == pOSApp->bOpenOnStart )
			{
				/* Mark this window to open on startup */
				pNewWinHandle->wh_Flags |= WHFLG_OPENONSTART;
			}
			IExec->AddTail(&pOSApp->oWindowList,(struct Node *)pNewWinHandle);
			DEBUG_MSG("Successfully created Window [ID=%d,Handle=0x%lx,Object=0x%lx,Layout=0x%lx,Flags=0x%lx]",pNewWinHandle->wh_ObjectID,pNewWinHandle,pNewWinHandle->wh_WinObj,pNewWinHandle->wh_Layout,pNewWinHandle->wh_Flags)
			Results = AVDERR_NOERROR;
		}
		else
		{
			/* Failed to Create the Window Object, so Free the AVD Window Handle */
			IExec->FreeVec(pNewWinHandle);
			pNewWinHandle = AVD_NULL;
		}
	}

	/* If an error occurred in creating the Window Object or it's interface, then return with the error */
	if ( AVDERR_NOERROR != Results ) return( Results );

/*
 *********** AVD RESERVED SECTION FOR AUTO-GENERATED SOURCE CODE ***********
 * This completes this reserved section of the file.
 * You are free to modify or add any custom code from this point.
 ************************* DO NOT EDIT THIS HEADER *************************
 AVD_END_HERE*/

	return( Results );
}
