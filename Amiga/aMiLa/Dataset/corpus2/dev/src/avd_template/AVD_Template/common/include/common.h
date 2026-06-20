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
 * Project: All
 *
 * Description: OS Independent Definitions and Functions (common.h)
 *
 * $VER: common.h 1.0.0.0
 * 
 */

#ifndef __COMMON_H__ 
#define __COMMON_H__ 
 
#include <os_main.h> 
#include <avd_ver.h>
#include <avd_types.h> 
#include <debug.h>
 
#define APP_NAME    PRODUCT_NAME
#define APP_VERSION PRODUCT_VER
 
/* Default values of command line options */ 
#define MAX_PATH_SIZE 256 
#define ADDRMAXLEN    256
#define PASSWDMAXLEN  256
 
/* Project's Common App Errors */ 
typedef enum AppErrorCodes 
{ 
	AVDERR_NOERROR,
	AVDERR_INITAPPFAILED,
	AVDERR_INITARGSFAILED,
	AVDERR_ARGREQUIRED,
	AVDERR_RESOURCENOTFOUND,
	AVDERR_INITFAILED,
	AVDERR_ALREADYRUNNING,
	AVDERR_HELPREQUEST,
	AVDERR_VERSIONREQUEST,
	AVDERR_NOCONFIGFILE
} AVD_ERRORCODE;

/* Project Specific App Structure */
typedef struct App
{
	AVD_BOOL bHelpRequest;
	AVD_BOOL bVersionRequest;
	AVD_BOOL bQuiet;
	AVD_BOOL bVerbose;
	AVD_BOOL bRunning;
} APP;

/* Standardized AVD Application Structure */
typedef struct AVDApp
{
	AVD_ERRORCODE nErrorCode;
	char *       sAppName;
	char *       sVersion;
	APP          oApp;     /* OS Independent extension -Defined Above <common.h> */
	OSAPP        oOSApp;   /* OS Dependent extension   -Defined in <os_main.h>   */
} AVDAPP;

/* Defines for the AVD_ReturnArg() function */
enum ArgMatchLabel
{
	ARG_EXCLUDESLABEL, /* Return argument that excludes the specified sLabel */
	ARG_MATCHESLABEL   /* Return argument with matching sLabel               */
};

enum ArgMatchCase
{
	ARG_IGNORECASE,    /* Return argument which matches sLabel (Case is ignored)        */
	ARG_MATCHCASE      /* Return argument which exactly matches sLabel (considers Case) */
};

#ifdef __cplusplus
extern "C" {
#endif
/*
 * Define Project's OS Independent Prototypes
 */
AVD_ERRORCODE AVD_DisposeApp( AVDAPP *pApp );
AVDAPP *      AVD_InitApp( void );
AVD_ERRORCODE AVD_InitArgs( AVDAPP *pApp, int argc, char *argv[] );
AVD_ERRORCODE AVD_Main( AVDAPP *pApp );
char *        AVD_ReturnArg( char *sLabel, enum ArgMatchLabel nMatch, enum ArgMatchCase nCase, int nStartingArg, int *pnArgFoundAt, int argc, char *argv[] );
void          AVD_Usage( AVDAPP *pApp, char *sComment );

/* Case-Independent string matching, similar to strstr but ignoring case */
#ifndef HAVE_STRCASESTR
char * strcasestr( char *haystack, char *needle );
#endif

/*
 * Define Project's OS Dependent Prototypes
 */
AVD_ERRORCODE os_DisposeOSApp( OSAPP *pOSApp );
AVD_ERRORCODE os_Init( OSAPP *pOSApp );
AVD_ERRORCODE os_InitArgs( OSAPP *pApp, int argc, char *argv[] );
AVD_ERRORCODE os_InitOSApp( OSAPP *pOSApp );
AVD_ERRORCODE os_OutputString( AVDAPP *pApp, char *sOutputString );
AVD_ERRORCODE os_ReadConfig( APP *pApp, OSAPP *pOSApp, char *sFilename );
char *        os_ReturnErrorMsg( char *sErrorString, int nErrorStringMaxLen, AVD_ERRORCODE ErrorMsgCode );
AVD_ERRORCODE os_SaveConfig( APP *pApp, OSAPP *pOSApp, char *sFilename );
void          os_Usage( AVDAPP *pApp );
#ifdef __cplusplus
}
#endif

#endif /* End of __COMMON_H__ */
