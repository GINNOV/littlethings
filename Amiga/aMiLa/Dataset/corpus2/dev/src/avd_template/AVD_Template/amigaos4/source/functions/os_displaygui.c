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
 *  Function Name: os_DisplayGUI()
 *
 *  Project: AVD_Template
 *
 *  Description: Displays the GUI Interface for this Application
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

AVD_ERRORCODE os_DisplayGUI(OSAPP *pOSApp)
{
	struct AVD_WindowHandle *pWindowHandle = NULL;
	struct List             *pList         = NULL;
	struct Node             *pNextNode     = NULL;
	struct Screen           *pPubScreen    = NULL;
	AVD_ERRORCODE           Results        = AVDERR_RESOURCENOTFOUND;

	if ( pOSApp )
	{
		/* Show all the Windows in the list (if they have the open flag set) */
		pList = &pOSApp->oWindowList;
		if ( 0 != pList->lh_TailPred )
		{
			if ( !IsListEmpty(pList) )
			{
				/* If we have a lock on a screen already, use it */
				if ( pOSApp->screen )
				{
					pPubScreen = pOSApp->screen;
				}
				else
				{
					/* If we do not already have a screen lock, then try to get the specified one (by screen name) */
					if ( NULL == (pPubScreen = IIntuition->LockPubScreen(pOSApp->sPubScreenName)) )
					{
						/* If we can't get the intended Public Screen, then grab the default one */
						pPubScreen = IIntuition->LockPubScreen(NULL);
					}
					pOSApp->screen = pPubScreen; /* Update our screen pointer to keep in sync */
				}
				/*
				 * Scan through each AVD Window Handle node in the list,
				 * and open each window object we find.
				 */
				for( pNextNode = pList->lh_Head; pNextNode->ln_Succ; pNextNode = pNextNode->ln_Succ )
				{
					pWindowHandle = (struct AVD_WindowHandle *)pNextNode;
					if ( pWindowHandle->wh_WinObj )
					{
						DEBUG_MSG("Considering opening Window Object[0x%lx]",pWindowHandle->wh_WinObj)
						if ( pWindowHandle->wh_Window )
						{
							/* If window already exists, just bring to front and return */
							IIntuition->GetAttr(WA_PubScreen,pWindowHandle->wh_WinObj,(ULONG *)&pPubScreen);
							if ( pPubScreen ) IIntuition->ScreenToFront(pPubScreen);
							IIntuition->SetAttrs(pWindowHandle->wh_WinObj,WINDOW_FrontBack,WT_FRONT,TAG_END);
							IIntuition->SetAttrs(pWindowHandle->wh_WinObj,WINDOW_Activate,TRUE,TAG_END);
							Results = AVDERR_NOERROR;
						}
						else
						{
							if ( WHFLG_OPENONSTART & pWindowHandle->wh_Flags )
							{
								DEBUG_MSG("Attempting to Opening Window Object[0x%lx]",pWindowHandle->wh_WinObj)
								/* Set the screen this window is to open on */
								if ( pPubScreen )
								{
									IIntuition->SetAttrs(pWindowHandle->wh_WinObj,WA_PubScreen,pPubScreen,TAG_END);
									IIntuition->ScreenToFront(pPubScreen);
								}
								/* Restore the Window's last known Open position (WinSize) */
								IIntuition->SetAttrs(pWindowHandle->wh_WinObj,WA_WindowBox,&pWindowHandle->wh_WindowSize,TAG_END);
								/* Restore the Window's Zoom Size */
								IIntuition->SetAttrs(pWindowHandle->wh_WinObj,WA_Zoom,&pWindowHandle->wh_ZoomSize,TAG_END);
								/* Open the Window */
								if ( pWindowHandle->wh_Window = RA_OpenWindow(pWindowHandle->wh_WinObj) )
								{
									DEBUG_MSG("Window Object[0x%lx] Intuition Window[0x%lx] is now open!",pWindowHandle->wh_WinObj,pWindowHandle->wh_Window)
									Results = AVDERR_NOERROR; /* We return no error, if at least one window was opened */
								}
							}
						}
					}
				}
				if ( pPubScreen )
				{
					/* Unlock the Public Screen (Once our window is open we don't need to hang onto the Public Screen) */
					IIntuition->UnlockPubScreen(0,pPubScreen);
					/* Clear the pointer to the screen as well, since we have released it */
					pOSApp->screen = NULL;
				}
			}
		}
	}
	return( Results );
}
