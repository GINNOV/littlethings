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
 * Function Name: AVD_InitArgs()
 *
 * Description: Handles the command line parsing, placing
 *              the results into a AVDAPP project structure
 *
 * Entry Values: pApp = Pointer to the Project's AVDAPP Structure
 *               argc = Total number of command arguments
 *               argv = pointer to an array of argument strings
 *
 * Exit Values: AVD_ERRORCODE if any. (eg. AVDERR_NOERROR)
 *
 * $VER: initargs.c 1.0.0.0
 * 
 */

#include "common.h"

AVD_ERRORCODE AVD_InitArgs( AVDAPP *pApp, int argc, char *argv[] )
{
	AVD_ERRORCODE Results         = AVDERR_INITARGSFAILED;
	char          *sArgument      = AVD_NULL;
	int           nLastArgc       = 0;
	AVD_BOOL      bReadCfg        = AVD_TRUE;

	if ( (AVD_NULL != pApp) && (AVD_NULL != argv) )
	{

#ifdef INCLUDE_COMMON_ARGS /* The AmigaOS version(s) take care of these in os_InitArgs() */
		/*
		 * Check for VERSION REQUEST: [-V] (uppercase) [--version|-version] (Ignoring case)
		 */
		sArgument = AVD_ReturnArg("-V",ARG_MATCHESLABEL,ARG_MATCHCASE,1,(int *)&nLastArgc,argc,argv);
		if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("--version",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
		if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("-version",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
		if ( AVD_NULL != sArgument )
		{
			pApp->oApp.bVersionRequest = AVD_TRUE;
			Results = AVDERR_NOERROR;
			bReadCfg = AVD_FALSE; /* Version requests are mutually-exclusive with all other arguments */
		}

		if ( AVD_TRUE == bReadCfg )
		{
			/*
			 * Check for USAGE REQUEST: [-h|--help|-help|--usage|-usage] (Ignoring case)
			 */
			sArgument = AVD_ReturnArg("-h",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("--help",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("-help",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("--usage",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("-usage",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL != sArgument )
			{
				pApp->oApp.bHelpRequest = AVD_TRUE;
				Results = AVDERR_NOERROR;
				bReadCfg = AVD_FALSE; /* Usage requests are mutually-exclusive with all other arguments */
			}
		}
#endif

		if ( AVD_TRUE == bReadCfg )
		{
			/*
			 * Throw in OS layer arguments (like Configuration filename, etc.)
			 */
			Results = os_InitArgs(&pApp->oOSApp,argc,argv);
			if ( AVDERR_NOERROR != Results )
			{
				bReadCfg = AVD_FALSE; /* Stop reading further args on any error */
				if ( AVDERR_HELPREQUEST == Results )
				{
					/* If this is just a help/usage request, then set the HelpRequest Flag and clear the Error code */
					pApp->oApp.bHelpRequest = AVD_TRUE;
					Results = AVDERR_NOERROR;
				}
				else if ( AVDERR_VERSIONREQUEST == Results )
				{
					/* If this is just a Version request, then set the VersionRequest Flag and clear the Error code */
					pApp->oApp.bVersionRequest = AVD_TRUE;
					Results = AVDERR_NOERROR;
				}
			}
		}

#ifdef INCLUDE_CONFIG_FILE
		/* If no mutually-exclusive items have been found, read in the Configuration File */
		if ( AVD_TRUE == bReadCfg )
		{
			/*
			 * Ask OS layer to read in last known Configuration (into pApp)
			 * The results here are consider informational only, as not being able
			 * to read in the configuration file is not necessarily an error.
			 */
			Results = os_ReadConfig(&pApp->oApp,&pApp->oOSApp,AVD_NULL);
		}
#endif

#ifdef INCLUDE_COMMON_ARGS
		/*
		 * If no mutually-exclusive items have been found, continue parsing the command line.
		 * Further options found here will override those within the configuration file.
		 */
		if ( AVD_TRUE == bReadCfg )
		{
			/*
			 * Check for QUIET REQUEST: [--quiet|-quiet] (Ignoring case)
			 */
			sArgument = AVD_ReturnArg("--quiet",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("-quiet",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL != sArgument )
			{
				pApp->oApp.bQuiet = AVD_TRUE;
			}

			/*
			 * Check for VERBOSE REQUEST: [-v] (lowercase) [--verbose|-verbose] (Ignoring case)
			 */
			sArgument = AVD_ReturnArg("-v",ARG_MATCHESLABEL,ARG_MATCHCASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("--verbose",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("-verbose",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL != sArgument )
			{
				pApp->oApp.bVerbose = AVD_TRUE;
			}
#endif

#ifdef INCLUDE_CONFIG_FILE
			/*
			 * Check for SAVE CONFIGURATION REQUEST: [--save|-save] (Ignoring case)
			 */
			sArgument = AVD_ReturnArg("--save",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL == sArgument ) sArgument = AVD_ReturnArg("-save",ARG_MATCHESLABEL,ARG_IGNORECASE,1,(int *)&nLastArgc,argc,argv);
			if ( AVD_NULL != sArgument )
			{
				/* Ask OS layer to write updated Configuration (from pApp) */
				Results = os_SaveConfig(&pApp->oApp,&pApp->oOSApp,AVD_NULL);
			}
#endif

#ifdef INCLUDE_COMMON_ARGS
		}
#endif

	}
	return( (AVD_ERRORCODE)Results );
}
