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
 * Function Name: os_InitArgs()
 *
 * Description: Handles the command line parsing, placing
 *              the results into a AVDAPP project structure
 *
 * Entry Values: pOSApp = Pointer to the Project's OS Specific Structure
 *               argc   = Total number of command arguments
 *               argv   = pointer to an array of argument strings
 *
 * Exit Values: AVD_ERRORCODE if any. (eg. AVDERR_NOERROR)
 *
 * $VER: $
 * $History: os_initargs.c $
 * 
 * *****************  Version 1  *****************
 */

#include "os_main.h"
#include <common.h>

AVD_ERRORCODE os_InitArgs( OSAPP *pOSApp, int argc, char *argv[] )
{
	AVD_ERRORCODE Results           = AVDERR_INITARGSFAILED;
	STRPTR        pCenterWin       = NULL;
	STRPTR        pPopUp           = NULL;
	uint16        nInitialDefWidth  = DEFAULT_WINWIDTH;
	uint16        nInitialDefHeight = DEFAULT_WINHEIGHT;

	if ( AVD_NULL != pOSApp )
	{
		/* Parse the Icon's Tool Types or CLI command line arguments */
		if ( pOSApp->pToolTypes = (ArgArrayInit(argc,(CONST_STRPTR *)argv)) )
		{
			Results = AVDERR_NOERROR;

			/*
			 * Check for specified Help Request [-?|-h|-help]
			 */
			if ( NULL != ArgString((CONST_STRPTR *)pOSApp->pToolTypes,"?",(STRPTR)NULL) )
			{
				Results = AVDERR_HELPREQUEST;
			}
			else if ( NULL != ArgString((CONST_STRPTR *)pOSApp->pToolTypes,"-?",(STRPTR)NULL) )
			{
				Results = AVDERR_HELPREQUEST;
			}
			else if ( NULL != ArgString((CONST_STRPTR *)pOSApp->pToolTypes,"-h",(STRPTR)NULL) )
			{
				Results = AVDERR_HELPREQUEST;
			}
			else if ( NULL != ArgString((CONST_STRPTR *)pOSApp->pToolTypes,"-help",(STRPTR)NULL) )
			{
				Results = AVDERR_HELPREQUEST;
			}
			else if ( NULL != ArgString((CONST_STRPTR *)pOSApp->pToolTypes,"--help",(STRPTR)NULL) )
			{
				Results = AVDERR_HELPREQUEST;
			}

			if ( AVDERR_NOERROR == Results )
			{
				/*
				 * Check for specified Version Request [-version|--version]
				 */
				if ( NULL != ArgString((CONST_STRPTR *)pOSApp->pToolTypes,"-version",(STRPTR)NULL) )
				{
					Results = AVDERR_VERSIONREQUEST;
				}
				else if ( NULL != ArgString((CONST_STRPTR *)pOSApp->pToolTypes,"--version",(STRPTR)NULL) )
				{
					Results = AVDERR_VERSIONREQUEST;
				}
			}
			
			if ( AVDERR_NOERROR == Results )
			{
				/* Parse for CX_PRIORITY - Default = 0 */
				pOSApp->oNewBroker.nb_Pri = (BYTE)ArgInt((CONST_STRPTR *)pOSApp->pToolTypes,TN_CX_PRIORITY,0);
				/* Parse for CX_POPKEY - Default = DEFAULT_POPKEY_STR */
				pOSApp->pPopKey = (uint8 *)ArgString((CONST_STRPTR *)pOSApp->pToolTypes,TN_CX_POPKEY,DEFAULT_POPKEY_STR);
				/* Parse for HIDEKEY - Default = DEFAULT_HIDEKEY_STR */
				pOSApp->pHideKey = (uint8 *)ArgString((CONST_STRPTR *)pOSApp->pToolTypes,TN_HIDEKEY,DEFAULT_HIDEKEY_STR);
				/* Parse for CX_POPUP - Default = "yes" */
				pPopUp = ArgString((CONST_STRPTR *)pOSApp->pToolTypes,TN_CX_POPUP,"yes");
				if ( IIcon->MatchToolValue((CONST_STRPTR)pPopUp,"no") )
				{
					pOSApp->bOpenOnStart = FALSE;
				}
				/* Parse for PUBSCREEN - Default = NULL (System Default PubScreen) */
				pOSApp->sPubScreenName = ArgString((CONST_STRPTR *)pOSApp->pToolTypes,TN_PUBSCREEN,(STRPTR)NULL);
				/* Obtain the specified Public screen, or fallback and grab the default Public Screen */
				if ( NULL == (pOSApp->screen = IIntuition->LockPubScreen(pOSApp->sPubScreenName)) )
				{
					/* If we can't get the intended Public Screen, then grab the default one */
					pOSApp->screen = IIntuition->LockPubScreen(NULL);
				}
				/*
				 * Parse Initial sizes to open window at
				 */
				/* Set our final "default" window position values */
				pOSApp->bCenterWin = TRUE;
				/* Set our final "default" window size values */
				pOSApp->oWindowSize.Left = (WORD)ArgInt((CONST_STRPTR *)pOSApp->pToolTypes,TN_LEFT,-1);
				if ( -1 != pOSApp->oWindowSize.Left )
				{
					/* If a Left or Top value was specified, then do not Centered flag */
					pOSApp->bCenterWin = FALSE;
				}
				else
				{
					pOSApp->oWindowSize.Left = DEFAULT_WINLEFT;
				}
				pOSApp->oWindowSize.Top = (WORD)ArgInt((CONST_STRPTR *)pOSApp->pToolTypes,TN_TOP,-1);
				if ( -1 != pOSApp->oWindowSize.Top )
				{
					/* If a Left or Top value was specified, then do not Centered flag */
					pOSApp->bCenterWin = FALSE;
				}
				else
				{
					pOSApp->oWindowSize.Top  = DEFAULT_WINTOP;
				}
				pOSApp->oWindowSize.Width  = (WORD)ArgInt((CONST_STRPTR *)pOSApp->pToolTypes,TN_WIDTH,nInitialDefWidth);
				pOSApp->oWindowSize.Height = (WORD)ArgInt((CONST_STRPTR *)pOSApp->pToolTypes,TN_HEIGHT,nInitialDefHeight);
				/* Set our final "default" window position values */
				pCenterWin = ArgString((CONST_STRPTR *)pOSApp->pToolTypes,TN_CENTERED,"");
				if ( IIcon->MatchToolValue(pCenterWin,"yes") )
				{
					pOSApp->bCenterWin = TRUE;
				}
				else if ( IIcon->MatchToolValue(pCenterWin,"true") )
				{
					pOSApp->bCenterWin = TRUE;
				}
				else if ( IIcon->MatchToolValue(pCenterWin,"no") )
				{
					pOSApp->bCenterWin = FALSE;
				}
				else if ( IIcon->MatchToolValue(pCenterWin,"false") )
				{
					pOSApp->bCenterWin = FALSE;
				}
				/* Set our default Zoom size to "Full Screen" */
				if ( pOSApp->screen )
				{
					pOSApp->oZoomSize.Width  = pOSApp->screen->Width;
					pOSApp->oZoomSize.Height = (pOSApp->screen->Height - 1);
				}
				else
				{
					pOSApp->oZoomSize.Width    = DEFAULT_ZOOM_WIDTH;
					pOSApp->oZoomSize.Height   = DEFAULT_ZOOM_HEIGHT;
				}
			}
		}
		else
		{
			/*
			 * No arguments provided so setup based on defaults only
			 */

			/* Setup defaults for Broker structure */
			pOSApp->oNewBroker.nb_Pri = (BYTE)0;
			pOSApp->pPopKey           = (uint8 *)DEFAULT_POPKEY_STR;
			pOSApp->pHideKey          = (uint8 *)DEFAULT_HIDEKEY_STR;
			pOSApp->bOpenOnStart      = TRUE;

			/* Parse for PUBSCREEN - Default = NULL (System Default PubScreen) */
			pOSApp->sPubScreenName    = (STRPTR)NULL;
			/* Obtain the system current default Public Screen */
			pOSApp->screen            = IIntuition->LockPubScreen(NULL);
			/*
			 * Parse Initial sizes to open window at
			 */
			/* Set our final "default" window size values */
			pOSApp->oWindowSize.Left   = (WORD)DEFAULT_WINLEFT;
			pOSApp->oWindowSize.Top    = (WORD)DEFAULT_WINTOP;
			pOSApp->oWindowSize.Width  = (WORD)nInitialDefWidth;
			pOSApp->oWindowSize.Height = (WORD)nInitialDefHeight;
			pOSApp->bCenterWin         = TRUE;
			/* Set our default Zoom size to "Full Screen" */
			if ( pOSApp->screen )
			{
				pOSApp->oZoomSize.Width    = pOSApp->screen->Width;
				pOSApp->oZoomSize.Height   = (pOSApp->screen->Height - 1);
			}
			else
			{
				pOSApp->oZoomSize.Width    = DEFAULT_ZOOM_WIDTH;
				pOSApp->oZoomSize.Height   = DEFAULT_ZOOM_HEIGHT;
			}
			Results = AVDERR_NOERROR;
		}

		/* Store our Hot Key(s) as Code/Qualifier pairs */
		if ( pOSApp->pHideKey )
		{
			ICommodities->ParseIX((CONST_STRPTR)pOSApp->pHideKey,(IX *)&pOSApp->oHideKey);
		}

	}
	return( (AVD_ERRORCODE)Results );
}
