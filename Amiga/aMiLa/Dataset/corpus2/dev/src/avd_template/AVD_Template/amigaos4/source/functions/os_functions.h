/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 02/16/2005
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
 * Project: AVD_Template
 *
 * OS Specific Data and Functions (os_functions.h)
 *
 * $VER: os_functions.h 1.0.0.0
 * 
 */
 
#ifndef __OS_FUNCTIONS_H__
#define __OS_FUNCTIONS_H__

#include <os_main.h>
#include <common.h>

enum Hide_Window_Methods
{
	HIDE_ALL_WINDOWS,
	ICONIFY_ALL_WINDOWS,
	CENTER_MAIN_WINDOW
};

AVD_ERRORCODE os_AllocateDependentObjects( OSAPP *pOSApp );
VOID          os_CloseLibs( OSAPP *pOSApp );
AVD_ERRORCODE os_CreateGUI( OSAPP *pOSApp );
AVD_ERRORCODE os_DisplayGUI( OSAPP *pOSApp );
VOID          os_FreeDependentObjects( OSAPP *pOSApp );
AVD_ERRORCODE os_HideGUI( OSAPP *pOSApp, enum Hide_Window_Methods nHideMethod );
BOOL          os_OpenLibs( OSAPP *pOSApp );
AVD_ERRORCODE os_ProcessEvents( OSAPP *pOSApp );
uint32        os_ReturnAllSigmasks( OSAPP *pOSApp, struct List *pWindowList );
struct List * os_ReturnList( OSAPP *pOSApp, uint32 lObjectID );

#endif /* End of __OS_MAIN_H__ */
