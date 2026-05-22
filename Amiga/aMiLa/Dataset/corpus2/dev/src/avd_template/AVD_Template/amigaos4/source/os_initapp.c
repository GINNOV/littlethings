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
 *  Function Name: os_InitOSApp()
 *
 *  Project: AVD_Template
 *
 *  Description: Sets up the OS specific DEFAULT values
 *
 *  Entry Values: Pointer to the OS Specific Application Structure
 *                (OSAPP *pOSApp).
 *
 *  Exit Values: Error code
 *
 * $VER: $
 * $History: initosapp.c $
 * 
 * *****************  Version 1  *****************
 */

#include "os_main.h"
#include <common.h>
#include "../source/functions/os_functions.h"

AVD_ERRORCODE os_InitOSApp( OSAPP *pOSApp )
{
	if ( AVD_NULL != pOSApp )
	{
		/*
		 * Setup OS Specific defaults
		 */

		/* (struct NewBroker) Our CxObject */
		pOSApp->oNewBroker.nb_Version         = NB_VERSION;                             /* (BYTE) Must be set to NB_VERSION */
		pOSApp->oNewBroker.nb_Name            = PRODUCT_NAME;                           /* (STRPTR) Name   */
		pOSApp->oNewBroker.nb_Title           = PRODUCT_TITLE " v" PRODUCT_VER;         /* (STRPTR) Title  */
		pOSApp->oNewBroker.nb_Descr           = "by BITbyBIT Software Group LLC ©2005"; /* (STRPTR) Descr  */
		pOSApp->oNewBroker.nb_Unique          = (NBU_UNIQUE | NBU_NOTIFY);              /* (WORD)   Unique */
		pOSApp->oNewBroker.nb_Flags           = COF_SHOW_HIDE;                          /* (WORD)   Flags  */
		pOSApp->oNewBroker.nb_Pri             = 0;                                      /* (BYTE)   Pri    */
		pOSApp->oNewBroker.nb_Port            = 0;                                      /* (struct MsgPort *) Port */
		pOSApp->oNewBroker.nb_ReservedChannel = 0;                                      /* (WORD) ReservedChannel*/

		/* (IX) Setup the default Hide Key */
		pOSApp->oHideKey.ix_Version           = IX_VERSION;                             /* must be set to IX_VERSION */
		pOSApp->oHideKey.ix_Class             = IECLASS_RAWKEY;                         /* class must match exactly  */
		pOSApp->oHideKey.ix_Code              = RAWKEY_ESC;                             /* Bits that we want */
		pOSApp->oHideKey.ix_CodeMask          = 0xFF;                                   /* Set bits here to indicate which bits in ix_Code are don't care bits. */
		pOSApp->oHideKey.ix_Qualifier         = QUALIFIER_NONE;                         /* Bits that we want */
		pOSApp->oHideKey.ix_QualMask          = IX_NORMALQUALS;                         /* Set bits here to indicate which bits in ix_Qualifier are don't care bits */
		pOSApp->oHideKey.ix_QualSame          = 0;                                      /* synonyms in qualifier */

		/* Window Title String, Public Screen Name */
		pOSApp->sWindowTitle                  = WINTITLE;                               /* (char *) Window Title String */
		pOSApp->sPubScreenName                = NULL;                                   /* (char *) Public Screen Name */

		/* Global Window/Screen size position data */
		pOSApp->bOpenOnStart                  = TRUE;                                   /* (BOOL) bOpenOnStart */
		pOSApp->bFirstOpen                    = TRUE;                                   /* (BOOL) bFirstOpen */
		pOSApp->bCenterWin                    = TRUE;                                   /* (BOOL) bCenterWin */
		/* (struct IBox) { Left, Top, Width, Height } */
		pOSApp->oWindowSize.Left              = DEFAULT_WINLEFT;                        /* (WORD) Left */
		pOSApp->oWindowSize.Top               = DEFAULT_WINTOP;                         /* (WORD) Top */
		pOSApp->oWindowSize.Width             = DEFAULT_WINWIDTH;                       /* (WORD) Width */
		pOSApp->oWindowSize.Height            = DEFAULT_WINHEIGHT;                      /* (WORD) Height */
		/* (struct ZoomSize) { LeftEdge, TopEdge, Width, Height } */
		pOSApp->oZoomSize.Left                = DEFAULT_ZOOM_LEFTEDGE;                  /* (WORD) Left */
		pOSApp->oZoomSize.Top                 = DEFAULT_ZOOM_TOPEDGE;                   /* (WORD) Top */
		pOSApp->oZoomSize.Width               = DEFAULT_ZOOM_WIDTH;                     /* (WORD) Width */
		pOSApp->oZoomSize.Height              = DEFAULT_ZOOM_HEIGHT;                    /* (WORD) Height */

		/*
		 * (struct NewMenu) Array of the Window's Menu items
		 */
		/* Menu -Title("Project") */
		pOSApp->oWindowMenu[0].nm_Type          = NM_TITLE;  /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[0].nm_Label         = "Project"; /* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[0].nm_CommKey       = NULL;      /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[0].nm_Flags         = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[0].nm_MutualExclude = 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[0].nm_UserData      = NULL;      /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -Item("Hide","h",MENUID_HIDE) */
		pOSApp->oWindowMenu[1].nm_Type          = NM_ITEM;   /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[1].nm_Label         = "Hide";    /* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[1].nm_CommKey       = "h";       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[1].nm_Flags         = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[1].nm_MutualExclude = 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[1].nm_UserData      = (APTR)MENUID_HIDE; /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -Item("Iconify",".",MENUID_ICONIFY) */
		pOSApp->oWindowMenu[2].nm_Type          = NM_ITEM;   /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[2].nm_Label         = "Iconify"; /* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[2].nm_CommKey       = ".";       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[2].nm_Flags         = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[2].nm_MutualExclude = 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[2].nm_UserData      = (APTR)MENUID_ICONIFY; /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -ItemBar */
		pOSApp->oWindowMenu[3].nm_Type          = NM_ITEM;    /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[3].nm_Label         = NM_BARLABEL;/* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[3].nm_CommKey       = NULL;       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[3].nm_Flags         = 0;          /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[3].nm_MutualExclude = 0;          /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[3].nm_UserData      = NULL;       /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -Item("About","a",MENUID_ABOUT) */
		pOSApp->oWindowMenu[4].nm_Type          = NM_ITEM;   /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[4].nm_Label         = "About";   /* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[4].nm_CommKey       = "a";       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[4].nm_Flags         = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[4].nm_MutualExclude = 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[4].nm_UserData      = (APTR)MENUID_ABOUT; /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -ItemBar */
		pOSApp->oWindowMenu[5].nm_Type          = NM_ITEM;    /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[5].nm_Label         = NM_BARLABEL;/* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[5].nm_CommKey       = NULL;       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[5].nm_Flags         = 0;          /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[5].nm_MutualExclude = 0;          /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[5].nm_UserData      = NULL;       /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -Item("Quit","q",MENUID_QUIT) */
		pOSApp->oWindowMenu[6].nm_Type          = NM_ITEM;   /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[6].nm_Label         = "Quit";    /* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[6].nm_CommKey       = "q";       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[6].nm_Flags         = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[6].nm_MutualExclude = 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[6].nm_UserData      = (APTR)MENUID_QUIT; /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */

		/* Menu -Title("Window") */
		pOSApp->oWindowMenu[7].nm_Type          = NM_TITLE;  /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[7].nm_Label         = "Window"; /* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[7].nm_CommKey       = NULL;      /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[7].nm_Flags         = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[7].nm_MutualExclude = 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[7].nm_UserData      = NULL;      /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -Item("Snapshot","s",MENUID_SNAPSHOT) */
		pOSApp->oWindowMenu[8].nm_Type          = NM_ITEM;   /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[8].nm_Label         = "Snapshot";/* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[8].nm_CommKey       = "s";       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[8].nm_Flags         = NM_ITEMDISABLED; /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[8].nm_MutualExclude = 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[8].nm_UserData      = (APTR)MENUID_SNAPSHOT; /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -Item("Center","c",MENUID_CENTER) */
		pOSApp->oWindowMenu[9].nm_Type          = NM_ITEM;   /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[9].nm_Label         = "Center";  /* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[9].nm_CommKey       = "t";       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[9].nm_Flags         = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[9].nm_MutualExclude = 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[9].nm_UserData      = (APTR)MENUID_CENTER; /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */
		/* Menu -Item("Zoom/Zip","z",MENUID_ZOOMZIP) */
		pOSApp->oWindowMenu[10].nm_Type         = NM_ITEM;   /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[10].nm_Label        = "Zoom/Zip";/* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[10].nm_CommKey      = "z";       /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[10].nm_Flags        = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[10].nm_MutualExclude= 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[10].nm_UserData     = (APTR)MENUID_ZOOMZIP; /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */

		/* Menu -EndMenu */
		pOSApp->oWindowMenu[11].nm_Type         = NM_END;    /* (UBYTE) Menu Type (ie. NM_TITLE) */
		pOSApp->oWindowMenu[11].nm_Label        = NULL;      /* (STRPTR)Menu's label */
		pOSApp->oWindowMenu[11].nm_CommKey      = NULL;      /* (STRPTR)MenuItem's Command Key Equiv */
		pOSApp->oWindowMenu[11].nm_Flags        = 0;         /* (UWORD) Menu or MenuItem flags */
		pOSApp->oWindowMenu[11].nm_MutualExclude= 0;         /* (LONG)  MenuItem MutualExclude word */
		pOSApp->oWindowMenu[11].nm_UserData     = NULL;      /* (APTR)  For your own use (ID, Pointer to Hook Function, etc.) */

		/* List of AVD WindowHandles */
		IExec->NewList(&pOSApp->oWindowList); /* List structure to hold our Window Object (struct AVD_WindowHandle) nodes */

		/* List of AVD ObjectHandles */
		IExec->NewList(&pOSApp->oListHandles); /* List structure to hold our Dependent Objects (struct AVD_ObjectHandle) nodes */

		/* Any OS Specific Allocations can be made here, and freed in os_Free() */

		/* Now Initialize all the system libraries we need */
		if ( FALSE == os_OpenLibs(pOSApp) )
		{
			return( (AVD_ERRORCODE)AVDERR_RESOURCENOTFOUND );
		}

		return( (AVD_ERRORCODE)AVDERR_NOERROR );
	}
	return( (AVD_ERRORCODE)AVDERR_INITAPPFAILED );
}
