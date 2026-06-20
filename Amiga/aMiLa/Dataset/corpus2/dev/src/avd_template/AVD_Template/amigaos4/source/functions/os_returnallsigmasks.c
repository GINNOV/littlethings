/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 6/30/2005
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
 *  Function Name: os_ReturnAllSigmasks()
 *
 *  Project: AVD_Template
 *
 *  Description: Gathers and returns the Signal Masks for all Window Objects
 *
 *  Entry Values: pOSApp = Pointer to the OS Specific structure
 *
 *  Exit Values: 32 BIT Mask Value containing all Sigmasks or ZERO
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

uint32 os_ReturnAllSigmasks(OSAPP *pOSApp, struct List *pWindowList)
{
	struct AVD_WindowHandle *pWindowHandle = NULL;
	struct Node             *pNextNode     = NULL;
	uint32                  lWinSigMask    = 0L;
	uint32                  lAllSigMasks   = 0L;

	if ( pOSApp )
	{
		if ( pWindowList )
		{
			/* Now pick up the SIGMASK from all the AVD Window Handle Nodes in the list */
			if ( 0 != pWindowList->lh_TailPred )
			{
				if ( !IsListEmpty(pWindowList) )
				{
					/*
					 * Scan through the AVD Window Handle nodes in the list,
					 * and gather the SIGMASKs from each window object.
					 */
					for( pNextNode = pWindowList->lh_Head; pNextNode->ln_Succ; pNextNode = pNextNode->ln_Succ )
					{
						pWindowHandle = (struct AVD_WindowHandle *)pNextNode;
						if ( pWindowHandle->wh_WinObj )
						{
							/* Get the Window Object's signal mask */
							lWinSigMask = 0L;
							if ( 0 != IIntuition->GetAttr(WINDOW_SigMask,pWindowHandle->wh_WinObj,&lWinSigMask) )
							{
								lAllSigMasks |= lWinSigMask;
							}
						}
					}
				}
			}
		}
	}
	return( lAllSigMasks );
}
