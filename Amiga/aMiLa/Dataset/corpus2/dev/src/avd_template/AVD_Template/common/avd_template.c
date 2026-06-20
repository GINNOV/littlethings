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
 * Template Application for writing AVD aware software
 *
 * Project: AVD_Template
 *
 * Description: This program is intended to provide a basis for writing
 *              AVD aware software applications by providing a ready to
 *              use framework in C.
 *
 * $VER: avd_template.c 1.0.0.0
 * 
 * *****************  Version 1  *****************
 */

/* Include project header file */
#include "avd_template.h"

/*********************************************************************/
/****************************  MAIN  *********************************/
/*********************************************************************/

AVD_ERRORCODE AVD_Main(AVDAPP *pApp)
{
	char          oVersion[]  = VERSION_STRING;
	AVD_ERRORCODE MainResults = AVDERR_NOERROR;

	puts("MADE IT!!! :)");

	/* Open GUI interface if requested */
	if ( TRUE == pApp->oOSApp.bOpenOnStart )
	{
		os_DisplayGUI(&pApp->oOSApp);
	}

	/* Process all events until asked to quit */
	MainResults = os_ProcessEvents(&pApp->oOSApp);

	puts("--GOODBYE!");

	return( (AVD_ERRORCODE)MainResults );
}
