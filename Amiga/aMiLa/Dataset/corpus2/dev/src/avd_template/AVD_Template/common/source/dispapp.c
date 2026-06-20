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
 *  Function Name: AVD_DisposeApp()
 *
 *  Project: AVD_Template
 *
 *  Description: Frees a AVDAPP project structure previously allocated by
 *               AVD_InitApp()
 *
 *  Entry Values: PApp (Global) = Pointer to the AVDAPP structure to be disposed
 *
 *  Exit Values: None
 *
 * $VER: dispapp.c 1.0.0.0
 * 
 */

#include "common.h"

AVD_ERRORCODE AVD_DisposeApp( AVDAPP *pApp )
{
	AVD_ERRORCODE Results = AVDERR_NOERROR;

	extern AVDAPP *PApp;

	/* Free all attached OS layer memory and resources */
	if ( AVDERR_NOERROR == (Results = os_DisposeOSApp(&PApp->oOSApp)) )
	{
		/* Free all attached APP layer memory and resources */

		/* Free the AVDAPP Project structure */
		free(PApp);

		/* Clear the AVDAPP Pointer - This works because PApp is Global */
		PApp = AVD_NULL;
	}
	return( Results );
}
