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
 * Function Name: AVD_Usage()
 *
 * Project: avd_template
 *
 * Description: Displays the usage for message
 *
 * Entry Values: pApp     = Pointer to the Project's AVDAPP Structure
 *               sComment = Pointer to addition comment line (C-String)
 *
 * Exit Values: None.
 *
 * $VER: usage.c 1.0.0.0
 * 
 */

#include "common.h"

void AVD_Usage( AVDAPP *pApp, char *sComment )
{
	char sOutputBuf[80];

	D( os_OutputString(pApp,"\n\7 !!!!!!!!! OPERATING IN DEBUG MODE - RECOMPILE BEFORE RELEASE !!!!!!!!!\n"); )

	/* Start with the specific reason for displaying the usage */
	if ( AVD_NULL != sComment )
	{
		if ( 0 < strlen(sComment) )
		{
			os_OutputString(pApp,"");
			os_OutputString(pApp,sComment);
		}
	}

	/* Format and output the built-in Usage(Help) text */
	snprintf(sOutputBuf,sizeof(sOutputBuf),"%s: %u.%u.%u.%lu",PRODUCT_NAME,VER_MAJOR,VER_MINOR,VER_MAINTENANCE,VER_BUILD);
	os_OutputString(pApp,sOutputBuf);
	os_OutputString(pApp,"-------------------------------------------------------");
	snprintf(sOutputBuf,sizeof(sOutputBuf),"Usage: %s --version",PRODUCT_NAME);
	os_OutputString(pApp,sOutputBuf);
	os_OutputString(pApp,"");
	os_OutputString(pApp,"  [--version|-version]");
	os_OutputString(pApp,"     Output the version information.");
#ifdef INCLUDE_COMMON_ARGS
	os_OutputString(pApp,"  [--quiet|-quiet]");
	os_OutputString(pApp,"     Suppress all output when executing the commands.");
	os_OutputString(pApp,"  [-v|--verbose|-verbose]");
	os_OutputString(pApp,"     Be verbose in the output when executing the commands.");
#endif
	os_OutputString(pApp,"  [-h|--help|-help|--usage|-usage]");
	os_OutputString(pApp,"     Display of this help text.");
#ifdef INCLUDE_CONFIG_FILE
	os_OutputString(pApp,"  [--SAVE|-SAVE]");
	os_OutputString(pApp,"     Write out the current configuration.");
#endif

	/* Give the OS a chance to add to the Usage output */
	os_Usage(pApp);
}
