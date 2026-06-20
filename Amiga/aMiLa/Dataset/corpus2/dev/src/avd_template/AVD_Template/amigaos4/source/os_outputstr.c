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
 *  Function Name: os_OutputString()
 *
 *  Project: AVD_Template
 *
 *  Description: Outputs a text string to the "console",
 *               which could be standard out or a window.
 *
 *  Entry Values: pApp = Pointer to the AVDAPP structure
 *
 *  Exit Values: AVD_ERRORCODE (if any)
 *
 * $VER: $
 * $History: os_outputstr.c $
 * 
 * *****************  Version 1  *****************
 */

#include "os_main.h"
#include <common.h>

AVD_ERRORCODE os_OutputString( AVDAPP *pApp, char *sOutputString )
{
	AVD_ERRORCODE Results = AVDERR_NOERROR;

	if ( AVD_NULL != sOutputString ) puts(sOutputString);

	return( (AVD_ERRORCODE)Results );
}
