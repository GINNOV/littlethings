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
 *  Project: AVD_Template
 *
 *  Description: OS Specific Project Entry Point (os_main.c)
 *               Completes by jumping into Common Project Main AVD_Main(),
 *               in (avd_template.c)
 *
 * $VER: $
 * $History: os_main.c $
 * 
 * *****************  Version 1  *****************
 */

#include "os_main.h"
#include <common.h>

/* Declare the Project's Global App Pointer */
AVDAPP *PApp = AVD_NULL;

int main(int argc, char *argv[])
{
	char               sErrorString[160];
	int                nOpenArg1          = AVD_NULL;
	AVD_ERRORCODE      Results            = AVDERR_NOERROR;
	AVDAPP             *pApp              = AVD_NULL;

	/*
	 * Initialize (Create) the Project App Object
	 */
	if ( AVD_NULL != (pApp = AVD_InitApp()) )
	{
		PApp = pApp; /* Assign the Global AVDAPP pointer */
		/*
		 * Parse the Cmd Args List & update Config as Needed
		 */
		if ( AVDERR_NOERROR == (Results = AVD_InitArgs(pApp,argc,argv)) )
		{
			if ( AVD_TRUE == pApp->oApp.bHelpRequest )
			{
				Results = AVDERR_HELPREQUEST;
			}
			else if ( AVD_TRUE == pApp->oApp.bVersionRequest )
			{
				snprintf(sErrorString,sizeof(sErrorString),"%s version: %s  Build date: %s %s",PRODUCT_NAME,PRODUCT_VER,__DATE__,__TIME__);
				os_OutputString(pApp,(char *)sErrorString);
				os_OutputString(pApp,(char *)PRODUCT_DESCRIPTION);
				Results = AVDERR_VERSIONREQUEST;
			}
			else
			{
				/*
				 * Check for required arguments
				 */
				/* Results = AVDERR_ARGREQUIRED; */
				/* Add any must have (required) argument tests here */
				/*
				 * OS Specific startup & Initialization code
				 */
				if ( AVDERR_NOERROR == (Results = os_Init(&pApp->oOSApp)) )
				{
					/* Create GUI (Main App Window) */
					if ( AVDERR_NOERROR == (Results = os_CreateGUI(&pApp->oOSApp)) )
					{
						/*
						 * Jump into Project's common code engine!!!
						 */
						pApp->oApp.bRunning = AVD_TRUE; /* Set Run State to TRUE */
						Results = AVD_Main(pApp);       /* Jump into main engine */
					}
				}
			}
		}
		/* Check if Usage needs to be output */
		if ( AVDERR_NOERROR != Results )
		{
			if ( AVDERR_VERSIONREQUEST != Results )
			{
				if ( AVDERR_ALREADYRUNNING != Results )
				{
					/* Invoke Usage dump with an Additional OS Specific Msg */
					AVD_Usage(pApp,(char *)os_ReturnErrorMsg(sErrorString,sizeof(sErrorString),Results));
				}
			}
		}

		/*
		 * Dispose App Object and all associated Objects
		 */
		Results = AVD_DisposeApp(pApp);
	}
	else
	{
		snprintf(sErrorString,sizeof(sErrorString),"%s Error: Failed to Setup NO Memory!",PRODUCT_NAME);
		os_OutputString(AVD_NULL,sErrorString);
		/* App Failed to setup - No Memory?!? */
		Results = AVDERR_INITAPPFAILED;
	}

	exit( Results );
}
