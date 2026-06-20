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
 * Function Name: os_Usage()
 *
 * Project: AVD_Template
 *
 * Description: Displays the usage for message
 *
 * Entry Values: pApp     = Pointer to the Project's AVDAPP Structure
 *               sComment = Pointer to addition comment line (C-String)
 *
 * Exit Values: None.
 *
 * $VER: $
 * $History: os_usage.c $
 * 
 * *****************  Version 1  *****************
 */

#include "common.h"

void os_Usage( AVDAPP *pApp )
{
#ifdef INCLUDE_CONFIG_FILE
	os_OutputString(pApp,"  [-f|--filename|-filename|--config|-config <configfile>]");
	os_OutputString(pApp,"     Specify the path and filename of the configuration file");
	os_OutputString(pApp,"     to be used.");
	os_OutputString(pApp,"");
#endif
	os_OutputString(pApp,"\nThe following options can be specified on the command line");
	os_OutputString(pApp,"or as ToolTypes in the icon used to launch this program.");
	os_OutputString(pApp,"----------------------------------------------------------");
	os_OutputString(pApp,"CX_POPUP=<YES|NO>              - Defaults to YES.");
	os_OutputString(pApp,"CX_PRIORITY=<-127 to 127>      - Defaults to 0.");
	os_OutputString(pApp,"CX_POPKEY=<hotkey string>      - Defaults to F1.");
	os_OutputString(pApp,"HIDEKEY=<hotkey string>        - Defaults to ESC.");
	os_OutputString(pApp,"PUBSCREEN=<public screen name> - Defaults to System Default.");
	os_OutputString(pApp,"LEFT=<Number of pixels from the LEFT edge of the Screen>");
	os_OutputString(pApp,"TOP=<Number of lines down from the TOP of the Screen>");
	os_OutputString(pApp,"WIDTH=<WIDTH in pixels to open the window to>");
	os_OutputString(pApp,"HEIGHT=<HEIGHT of pixels to open the window to>");
	os_OutputString(pApp,"CENTERED=<YES|NO> - This option overrides LEFT and TOP values.\n");
	os_OutputString(pApp,"This program is Copyright(c)2005 by BITbyBIT Software Group LLC,");
	os_OutputString(pApp,"All Rights Reserved.");
}
