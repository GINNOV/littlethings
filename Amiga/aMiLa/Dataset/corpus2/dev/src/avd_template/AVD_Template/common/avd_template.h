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
 * Project: AVD_Template
 *
 * This file defines a set datatypes and defines for AVD_Template
 *
 * $VER: avd_template.h 1.0.0.0
 * 
 */

#ifndef __AVD_TEMPLATE_H__
#define __AVD_TEMPLATE_H__

/*
 * First include the defines for the true starting point,
 * the OS dependant - main() defined in <os_main.c>
 */
#include <os_main.h>

/*
 * Then include the defines for the "Common",
 * OS Independant supporting code.
 */
#include <common.h>

/* Include the version information for this project */
#include <avd_ver.h>

/* Prototype for our Project's entry point */
AVD_ERRORCODE AVD_Main( AVDAPP *pApp );

/* Project sub-functions are prototyped here */


#endif
