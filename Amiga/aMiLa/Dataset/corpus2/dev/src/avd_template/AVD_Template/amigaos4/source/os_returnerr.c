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
 *  Function Name: os_ReturnErrorMsg()
 *
 *  Project: AVD_Template
 *
 *  Description: Fulfills the supplied buffer with a printable
 *               string based on the supplied error code (ErrorMsgCode)
 *
 *  Entry Values: sErrorString       = Pointer to the buffer to be fulfilled.
 *                nErrorStringMaxLen = Maximum length of that buffer.
 *                ErrorMsgCode       = Which error code to be used to
 *                                     determine the resulting message.
 *
 *  Exit Values: Returns a printable string (char *) based on
 *               the error message supplied in ErrorMsgCode.
 *
 * $VER: $
 * $History: os_returnerr.c $
 * 
 * *****************  Version 1  *****************
 */

#include "os_main.h"
#include <common.h>

char * os_ReturnErrorMsg( char *sErrorString, int nErrorStringMaxLen, AVD_ERRORCODE ErrorMsgCode )
{
	if ( AVD_NULL != sErrorString )
	{
		memset(sErrorString,0,nErrorStringMaxLen);

		/* Application Error Code (AVD_ERRORCODE) */
		switch( ErrorMsgCode )
		{
			case AVDERR_INITAPPFAILED:
				snprintf(sErrorString,nErrorStringMaxLen,"%s Error:Failed to Initialize.\n",APP_NAME);
			break;
			case AVDERR_INITARGSFAILED:
				snprintf(sErrorString,nErrorStringMaxLen,"%s Error:Could not read the specified arguments.\n",APP_NAME);
			break;
			case AVDERR_ARGREQUIRED:
				snprintf(sErrorString,nErrorStringMaxLen,"%s Error:Missing required argument. (Incomplete Configuration or Missing support files)\n",APP_NAME);
			break;
			case AVDERR_NOCONFIGFILE:
				snprintf(sErrorString,nErrorStringMaxLen,"%s Error:Can not read specified configuration file.\n",APP_NAME);
			break;
			case AVDERR_HELPREQUEST:
			case AVDERR_VERSIONREQUEST:
			case AVDERR_NOERROR:
			default:
			break;
		}
		return( (char*)sErrorString );
	}
}
