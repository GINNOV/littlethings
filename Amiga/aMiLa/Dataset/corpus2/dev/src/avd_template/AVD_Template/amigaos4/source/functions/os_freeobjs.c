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
 *  Function Name: os_FreeDependentObjects()
 *
 *  Project: AVD_Template
 *
 *  Description: Frees the dependent GUI List Node for this Application's Interface
 *
 *  Entry Values: pOSApp = Pointer to the OS Specific structure
 *
 *  Exit Values: NONE
 *
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

VOID os_FreeDependentObjects(OSAPP *pOSApp)
{
	struct AVD_ListHandle *pListHandle     = NULL;
	struct List           *pList           = NULL;
	struct List           *pGUIList        = NULL;
	struct Node           *pListHandleNode = NULL;
	struct Node           *pGUINode        = NULL;
	struct Node           *pNextNode       = NULL;
	struct Node           *pNextGUINode    = NULL;

	if ( pOSApp )
	{
		/* Dispose all the Dependent List Nodes by Type */
		pList = &pOSApp->oListHandles;
		if ( 0 != pList->lh_TailPred )
		{
			if ( !IsListEmpty(pList) )
			{
				/* Scan through each AVD ListHandle nodes in the list, and Dispose them */
				for( pNextNode = pList->lh_TailPred; pNextNode->ln_Pred; )
				{
					pListHandleNode = pNextNode;
					pListHandle     = (struct AVD_ListHandle *)pListHandleNode;
					pNextNode       = pNextNode->ln_Pred; /* We are going to destroy the pListHandleNode/pNextNode BEFORE looping back to the top, so we need to fetch the next node to operate on FIRST */
					/* Dispose all the Dependent List Nodes by Type */
					pGUIList = &pListHandle->lhd_List;
					if ( 0 != pGUIList->lh_TailPred )
					{
						if ( !IsListEmpty(pGUIList) )
						{
							/* Scan through each Dependent GUI nodes in the list, and Dispose them */
							for( pNextGUINode = pGUIList->lh_TailPred; pNextGUINode->ln_Pred; )
							{
								pGUINode     = pNextGUINode;
								pNextGUINode = pNextGUINode->ln_Pred; /* We are going to destroy the pGUINode/pNextNode BEFORE looping back to the top, so we need to fetch the next node to operate on FIRST */
								/* Remove the GUI Node */
								IExec->Remove(pGUINode);
								/* Free the GUI Node */
								switch( pListHandle->lhd_ListType )
								{
									case LHT_CHOOSER_NODES:
									case LHT_DROPDOWN_NODES:
										IChooser->FreeChooserNode(pGUINode);
									break;
									case LHT_CLICKTAB_NODES:
										IClickTab->FreeClickTabNode(pGUINode);
									break;
									case LHT_LISTBROWSER_NODES:
										IListBrowser->FreeListBrowserNode(pGUINode);
									break;
									case LHT_PARTITION_NODES:
										IPartition->FreePartitionNode(pGUINode);
									break;
									case LHT_RADIOBUTTON_NODES:
										IRadioButton->FreeRadioButtonNode(pGUINode);
									break;
									case LHT_SPEEDBAR_NODES:
										ISpeedBar->FreeSpeedButtonNode(pGUINode);
									break;
								}
								pGUINode = NULL;
							}
						}
					}
					/* Remove/Free the AVD ListHandle Node */
					IExec->Remove(pListHandleNode);
					IExec->FreeVec(pListHandleNode);
					pListHandleNode = NULL;
					pListHandle = NULL;
				}
			}
		}
	}
}
