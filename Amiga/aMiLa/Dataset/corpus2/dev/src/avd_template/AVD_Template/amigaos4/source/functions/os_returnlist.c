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
 *  Function Name: os_ReturnList()
 *
 *  Project: AVD_Template
 *
 *  Description: Return the pointer to the list nodes for a specified object
 *
 *  Entry Values: pOSApp    = Pointer to the OS Specific structure
 *                lObjectID = Object ID to match for this list
 *
 *  Exit Values: Pointer to the List of Nodes for this Object (struct List *)
 *               or NULL if no match is found.
 *
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

struct List * os_ReturnList(OSAPP *pOSApp, uint32 lObjectID)
{
	struct AVD_ListHandle *pListHandle = NULL;
	struct List           *pList       = NULL;
	struct Node           *pNextNode   = NULL;

	if ( pOSApp )
	{
		/* Find and return the pointer to the List of Nodes for the specified Object by ID */
		pList = &pOSApp->oListHandles;
		if ( 0 != pList->lh_TailPred )
		{
			if ( !IsListEmpty(pList) )
			{
				/* Scan through each AVD ListHandle nodes, and return the matching one or NULL */
				for( pNextNode = pList->lh_Head; pNextNode->ln_Succ; pNextNode = pNextNode->ln_Succ )
				{
					pListHandle = (struct AVD_ListHandle *)pNextNode;
					/* If the ID of the ListHandle and the ID of the Object Match, then return the ListHandle's embedded List */
					if ( pListHandle->lhd_ObjectID == lObjectID ) return( (struct List *)&pListHandle->lhd_List );
				}
			}
		}
	}
	return( (struct List *)NULL );
}
