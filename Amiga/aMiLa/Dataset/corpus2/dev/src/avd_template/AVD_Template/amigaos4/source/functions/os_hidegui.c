/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 9/25/2003
 *---------------------------------------------------------------------
 * Copyright (c) 2003 BITbyBIT Software Group, All Rights Reserved.
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
 *  Function Name: os_HideGUI()
 *
 *  Project: AVD_Template
 *
 *  Description: Hides the GUI Interface for this Application
 *
 *  Entry Values: pOSApp = Pointer to the OS Specific structure
 *
 *  Exit Values: AVD_ERRORCODE (if any)
 *
 * $VER: $
 * $History: os_processevents.c $
 * 
 * *****************  Version 1  *****************
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

AVD_ERRORCODE os_HideGUI(OSAPP *pOSApp, enum Hide_Window_Methods nHideMethod)
{
	struct AVD_WindowHandle *pWindowHandle = NULL;
	struct List             *pList         = NULL;
	struct Node             *pNextNode     = NULL;
	AVD_ERRORCODE           Results        = AVDERR_NOERROR;

	if ( pOSApp )
	{
		/* Hide all the Windows in the list */
		pList = &pOSApp->oWindowList;
		if ( 0 != pList->lh_TailPred )
		{
			if ( !IsListEmpty(pList) )
			{
				/*
				 * Scan through each AVD Window Handle node in the list,
				 * and hide each window object we find.
				 */
				for( pNextNode = pList->lh_Head; pNextNode->ln_Succ; pNextNode = pNextNode->ln_Succ )
				{
					pWindowHandle = (struct AVD_WindowHandle *)pNextNode;
					if ( pWindowHandle->wh_Window )
					{
						/* First store an update of the Window's last known Open position (WinSize) */
						if ( IIntuition->GetWindowAttr(pWindowHandle->wh_Window,WA_WindowBox,&pWindowHandle->wh_WindowSize,sizeof(pWindowHandle->wh_WindowSize)) )
						{
							/* Store the Window's Zoom Size */
							if ( IIntuition->GetWindowAttr(pWindowHandle->wh_Window,WA_Zoom,&pWindowHandle->wh_ZoomSize,sizeof(pWindowHandle->wh_ZoomSize)) )
							{
								if ( pWindowHandle->wh_WinObj )
								{
									/* Mark this window to be unhidden later */
									pWindowHandle->wh_Flags |= WHFLG_OPENONSTART;
									if ( ICONIFY_ALL_WINDOWS == nHideMethod )
									{
										/* Close the Window, and Iconify */
										RA_Iconify(pWindowHandle->wh_WinObj);
										/* After we Iconify the Main (or first) Window, change the hide method for the remainder of the windows */
										nHideMethod = HIDE_ALL_WINDOWS;
									}
									else if ( CENTER_MAIN_WINDOW == nHideMethod )
									{
										/* Close the Window */
										RA_CloseWindow(pWindowHandle->wh_WinObj);
										/* Set the Center Window Position for this window object */
										IIntuition->SetAttrs(pWindowHandle->wh_WinObj,WINDOW_Position,WPOS_CENTERSCREEN,TAG_END);
										/* After we close, and mark for centering, the Main (or first) Window, change the hide method for the remainder of the windows */
										nHideMethod = HIDE_ALL_WINDOWS;
									}
									else
									{
										/* Close the Window */
										RA_CloseWindow(pWindowHandle->wh_WinObj);
									}
									/* Clear the pointer to the now closed window (Pointer to Intuition Window NOT Window Class Object) */
									pWindowHandle->wh_Window = NULL;
								}
							}
						}
					}
				}
			}
		}
	}
	return( Results );
}
