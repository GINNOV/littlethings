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
 * with BITbyBIT Software Group LLC.
 *
 * BITbyBIT Software Group LLC MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT
 * THE SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING
 * FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. BITbyBIT Software
 * Group LLC SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY
 * LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS
 * SOFTWARE OR ITS DERIVATIVES.
 *---------------------------------------------------------------------
 *
 * Tool for Browsing the AmigaOS 4 SDK
 *
 * Project: AVD_Template
 *
 * Description: This function closes all system libraries not handled by -lauto
 *              
 * $VER: os_CloseLibs() 1.0.0.0
 * 
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

VOID os_CloseLibs( OSAPP *pOSApp )
{
	if ( pOSApp )
	{
		/* Free the Commodities Library & Interface */
		if ( CxBase )
		{
			if ( ICommodities )
			{
				/* Free the main interface for the Commodities Library */
				IExec->DropInterface((struct Interface *)ICommodities);
				ICommodities = NULL;
			}
			/* Free the Commodities Library */
			IExec->CloseLibrary(CxBase);
			CxBase = NULL;
		}

		/* Free the Intuition Library & Interface */
		if ( IntuitionBase )
		{
			if ( IIntuition )
			{
				/* Free the main interface for the Intuition Library */
				IExec->DropInterface((struct Interface *)IIntuition);
				IIntuition = NULL;
			}
			/* Free the Intuition Library */
			IExec->CloseLibrary(IntuitionBase);
			IntuitionBase = NULL;
		}

		/* Free the GadTools Library & Interface */
		if ( GadToolsBase )
		{
			if ( IGadTools )
			{
				/* Free the main interface for the GadTools Library */
				IExec->DropInterface((struct Interface *)IGadTools);
				IGadTools = NULL;
			}
			/* Free the GadTools Library */
			IExec->CloseLibrary(GadToolsBase);
			GadToolsBase = NULL;
		}

		/* Free the Icon Library & Interface */
		if ( IconBase )
		{
			if ( IIcon )
			{
				/* Free the main interface for the Icon Library */
				IExec->DropInterface((struct Interface *)IIcon);
				IIcon = NULL;
			}
			/* Free the Icon Library */
			IExec->CloseLibrary(IconBase);
			IconBase = NULL;
		}

		/* Free the Keymap Library & Interface */
		if ( KeymapBase )
		{
			if ( IKeymap )
			{
				/* Free the main interface for the Keymap Library */
				IExec->DropInterface((struct Interface *)IKeymap);
				IKeymap = NULL;
			}
			/* Free the Keymap Library */
			IExec->CloseLibrary(KeymapBase);
			KeymapBase = NULL;
		}

		/* Free the DateBrowser Library & Interface */
		if ( DateBrowserBase )
		{
			if ( IDateBrowser )
			{
				/* Free the main interface for the DateBrowser Library */
				IExec->DropInterface((struct Interface *)IDateBrowser);
				IDateBrowser = NULL;
			}
			/* Free the DateBrowser Library */
			IExec->CloseLibrary(DateBrowserBase);
			DateBrowserBase = NULL;
		}

		/* Free the Palette Library & Interface */
		if ( PaletteBase )
		{
			if ( IPalette )
			{
				/* Free the main interface for the Palette Library */
				IExec->DropInterface((struct Interface *)IPalette);
				IPalette = NULL;
			}
			/* Free the Palette Library */
			IExec->CloseLibrary(PaletteBase);
			PaletteBase = NULL;
		}

		/* Free the Partition Library & Interface */
		if ( PartitionBase )
		{
			if ( IPartition )
			{
				/* Free the main interface for the Partition Library */
				IExec->DropInterface((struct Interface *)IPartition);
				IPartition = NULL;
			}
			/* Free the Partition Library */
			IExec->CloseLibrary(PartitionBase);
			PartitionBase = NULL;
		}

		/* Free the PopupMenu Library & Interface */
		if ( PopupMenuBase )
		{
			if ( IPopupMenu )
			{
				/* Free the main interface for the PopupMenu Library */
				IExec->DropInterface((struct Interface *)IPopupMenu);
				IPopupMenu = NULL;
			}
			/* Free the PopupMenu Library */
			IExec->CloseLibrary(PopupMenuBase);
			PopupMenuBase = NULL;
		}

		/* Free the SketchBoard Library & Interface */
		if ( SketchBoardBase )
		{
			if ( ISketchBoard )
			{
				/* Free the main interface for the SketchBoard Library */
				IExec->DropInterface((struct Interface *)ISketchBoard);
				ISketchBoard = NULL;
			}
			/* Free the SketchBoard Library */
			IExec->CloseLibrary(SketchBoardBase);
			SketchBoardBase = NULL;
		}
	}
}

