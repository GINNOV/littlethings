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
 *  Function Name: os_AllocateDependentObjects()
 *
 *  Project: AVD_Template
 *
 *  Description: Constucts the GUI Interface for this Application
 *
 *  Entry Values: pOSApp = Pointer to the OS Specific structure
 *
 *  Exit Values: AVD_ERRORCODE (if any)
 *
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

AVD_ERRORCODE os_AllocateDependentObjects(OSAPP *pOSApp)
{
	struct AVD_ListHandle *pNewListHandle = NULL;
	struct Node           *pNewNode       = NULL;
	AVD_ERRORCODE         Results         = AVDERR_NOERROR;

	/*
	 * You can add any MANUAL object creation you need here,
	 * but make sure not to remove or change anything below
	 * the AVD header, also do not remove or change the local
	 * variables above (AVD_ERRORCODE Results, etc.) as they
	 * are used by the code generated below.
	 */

/*AVD_START_HERE
 *********** AVD RESERVED SECTION FOR AUTO-GENERATED SOURCE CODE ***********
 * This section of the file is automatically read and updated at build time,
 * do not make any changes or add anything between here and the 'AVD_END_HERE'
 * header, or the end of this file if no 'END'ing header is found.
 ************************* DO NOT EDIT THIS HEADER *************************
 */
/*
 *********** AVD RESERVED SECTION FOR AUTO-GENERATED SOURCE CODE ***********
 * This completes this reserved section of the file.
 * You are free to modify or add any custom code from this point.
 ************************* DO NOT EDIT THIS HEADER *************************
 AVD_END_HERE*/

	return( Results );
}
