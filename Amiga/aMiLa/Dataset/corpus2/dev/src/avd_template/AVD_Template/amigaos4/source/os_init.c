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
 *  Function Name: os_Init()
 *
 *  Project: AVD_Template
 *
 *  Description: Sets up the OS Specific project (last stage)
 *
 *  Entry Values: pOSApp = Pointer to the OS Specific structure
 *
 *  Exit Values: AVD_ERRORCODE (if any)
 *
 * $VER: $
 * $History: os_init.c $
 * 
 * *****************  Version 1  *****************
 */

#include "os_main.h"
#include <common.h>

AVD_ERRORCODE os_Init( OSAPP *pOSApp )
{
	AVD_ERRORCODE Results = AVDERR_INITFAILED;
	CxMsg         *cxMsg  = NULL;

	/* Attempt to open the Commodities Library and create our CxBroker */
	if ( pOSApp->pCxMsgPort = IExec->CreateMsgPort() )
	{
		pOSApp->oNewBroker.nb_Port = pOSApp->pCxMsgPort;
		if ( pOSApp->broker = ICommodities->CxBroker(&pOSApp->oNewBroker,(LONG *)NULL) )
		{
			/* Setup the HotKey notification Filter */
			DEBUG_MSG("HOTKEY = %s\n",pOSApp->pPopKey)
			/* Build the Window's title text adding the "pop/hide" keys */
			snprintf(&pOSApp->oWindowTitle[0],sizeof(pOSApp->oWindowTitle),"%s: PopKey = <%s> HideKey = <%s>\0",WINTITLE,pOSApp->pPopKey,pOSApp->pHideKey);
			if ( pOSApp->hotkey_filter = HotKey((CONST_STRPTR)pOSApp->pPopKey,pOSApp->pCxMsgPort,EVT_HOTKEY) )
			{
				/* Successfully created the HotKey Triad, now attach it to our Broker */
				ICommodities->AttachCxObj(pOSApp->broker,pOSApp->hotkey_filter);
				pOSApp->sWindowTitle = (char *)&pOSApp->oWindowTitle[0];
			}
			/* Successfully created the Commodity - Activate it and continue */
			ICommodities->ActivateCxObj(pOSApp->broker,1L);

			/* Allocate a second MsgPort for the Main App Window */
			if ( pOSApp->pMsgPort = IExec->CreateMsgPort() )
			{
				Results = AVDERR_NOERROR;
			}
			else
			{
				/* Failed to create the MsgPort for the Main App Window */
				Results = AVDERR_RESOURCENOTFOUND;
			}
		}
		else
		{
			/*
			 * Failed to create the Commodity - There could be another copy already running, so quit out
			 */
			Results = AVDERR_ALREADYRUNNING;
		}
	}
	else
	{
		/* Failed to create the MsgPort for the Commodity */
		Results = AVDERR_RESOURCENOTFOUND;
	}

	return( (AVD_ERRORCODE)Results );
}
