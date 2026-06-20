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
 *  Function Name: os_DisposeOSApp()
 *
 *  Project: AVD_Template
 *
 *  Description: Frees the OS Specific project structure
 *               previously allocated by AVD_InitApp()
 *
 *  Entry Values: pOSApp = Pointer to the OS Specific structure to be disposed
 *
 *  Exit Values: AVD_ERRORCODE (if any)
 *
 * $VER: $
 * $History: os_dispapp.c $
 * 
 * *****************  Version 1  *****************
 */

#include "os_main.h"
#include <common.h>

AVD_ERRORCODE os_DisposeOSApp( OSAPP *pOSApp )
{
	struct AVD_WindowHandle *pWindowHandle = NULL;
	CxMsg                   *cxMsg         = NULL;
	struct List             *pList         = NULL;
	struct Node             *pWindowNode   = NULL;
	struct Node             *pNextNode     = NULL;
	AVD_ERRORCODE           Results        = AVDERR_NOERROR;

	if ( pOSApp )
	{
		/* Dispose all the Windows in the list */
		pList = &pOSApp->oWindowList;
		if ( 0 != pList->lh_TailPred )
		{
			if ( !IsListEmpty(pList) )
			{
				/* Scan through each AVD Window Handle node in the list, and Dispose them */
				for( pNextNode = pList->lh_TailPred; pNextNode->ln_Pred; )
				{
					pWindowNode   = pNextNode;
					pWindowHandle = (struct AVD_WindowHandle *)pWindowNode;
					pNextNode     = pNextNode->ln_Pred; /* We are going to destroy the pWindowNode/pNextNode BEFORE looping back to the top, so we need to fetch the next node to operate on FIRST */
					if ( pWindowHandle->wh_WinObj )
					{
						/* Free the Window Object and it's attached Interface Object */
						IIntuition->DisposeObject(pWindowHandle->wh_WinObj);
						pWindowHandle = NULL;
					}
					/* Remove/Free the AVD Window Handle Node */
					IExec->Remove(pWindowNode);
					IExec->FreeVec(pWindowNode);
					pWindowNode = NULL;
				}
			}
		}

		/* Free any dependent list nodes that may have been created for the Windows */
		os_FreeDependentObjects(pOSApp);

		/* If the MsgPort for the Main App Window was created, flush out any messages and delete it */
		if ( pOSApp->pMsgPort )
		{
			IExec->DeleteMsgPort(pOSApp->pMsgPort);
			pOSApp->pMsgPort = NULL;
		}

		/* If the Commodity Broker was created, Delete it and all it's associated parts */
		if ( pOSApp->broker )
		{
			ICommodities->DeleteCxObjAll(pOSApp->broker);
			pOSApp->broker = NULL;
		}

		/* If the Commodity MsgPort was created, flush out any messages and delete it */
		if ( pOSApp->pCxMsgPort )
		{
			/* Make sure to Empty the port of CxMsgs */
			while( cxMsg = (CxMsg *)IExec->GetMsg(pOSApp->pCxMsgPort) ) IExec->ReplyMsg((struct Message *)cxMsg);
			IExec->DeleteMsgPort(pOSApp->pCxMsgPort);
			pOSApp->pCxMsgPort = NULL;
		}

		/* Unlock the Public Screen */
		if ( pOSApp->screen )
		{
			IIntuition->UnlockPubScreen(0,pOSApp->screen);
			pOSApp->screen = NULL;
		}

		/* Free the command line arguments memory that was setup by ArgArrayInit() */
		/* Be sure to clean up the ToolType argument array (before close of Icon.library) */
		if ( pOSApp->pToolTypes )
		{
			ArgArrayDone();
			pOSApp->pToolTypes = NULL;
		}

		/* Call os_CloseLibs() to free every library or Interface we used (if any) and cleanup */
		os_CloseLibs(pOSApp);
	}
	return( (AVD_ERRORCODE)Results );
}
