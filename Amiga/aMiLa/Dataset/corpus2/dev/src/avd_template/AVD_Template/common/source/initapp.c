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
 *  Function Name: AVD_InitApp()
 *
 *  Project: AVD_Template
 *
 *  Description: Creates & Initializes a AVDAPP project structure
 *
 *  Entry Values: None.
 *
 *  Exit Values: Pointer to the newly created AVDAPP project structure
 *
 * $VER: initapp.c 1.0.0.0
 * 
 */

#include "common.h"

AVDAPP * AVD_InitApp( void )
{
	AVDAPP *pApp = AVD_NULL;

	/* Allocate a new AVDAPP Project structure */
	if ( AVD_NULL != (pApp = (AVDAPP *)malloc(sizeof(AVDAPP))) )
	{
		/* Initialize the newly allocated AVDAPP structure */
		memset(pApp,0,sizeof(AVDAPP));
		pApp->sAppName = APP_NAME;
		pApp->sVersion = APP_VERSION;
        
		/* Fill in any defaults for pApp->oApp - HERE */
		pApp->oApp.bHelpRequest = AVD_FALSE;

		/* Let the OS layer fill in it's defaults */
		if ( AVDERR_NOERROR == os_InitOSApp(&pApp->oOSApp) )
		{
			/* Done - return the pointer to our new AVDAPP structure */
			return( pApp );
		}
		/* Could not setup OS Defaults!?! */

		/* Could not setup Defaults!?! */
		free(pApp);
	}
	return( (AVDAPP *)AVD_NULL );
}
