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
 * Description: This function Initializes system library not handled by -lauto
 *              
 * $VER: os_OpenLibs() 1.0.0.0
 * 
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

/* Global Library Interfaces */
struct Library          *CxBase          = NULL;
struct CommoditiesIFace *ICommodities    = NULL;
struct Library          *IntuitionBase   = NULL;
struct IntuitionIFace   *IIntuition      = NULL;
struct Library          *GadToolsBase    = NULL;
struct GadToolsIFace    *IGadTools       = NULL;
struct Library          *IconBase        = NULL;
struct IconIFace        *IIcon           = NULL;
struct Library          *KeymapBase      = NULL;
struct KeymapIFace      *IKeymap         = NULL;
struct Library          *DateBrowserBase = NULL;
struct DateBrowserIFace *IDateBrowser    = NULL;
struct Library          *PaletteBase     = NULL;
struct PaletteIFace     *IPalette        = NULL;
struct Library          *PartitionBase   = NULL;
struct PartitionIFace   *IPartition      = NULL;
struct Library          *PopupMenuBase   = NULL;
struct PopupMenuIFace   *IPopupMenu      = NULL;
struct Library          *SketchBoardBase = NULL;
struct SketchBoardIFace *ISketchBoard    = NULL;

BOOL os_OpenLibs( OSAPP *pOSApp )
{
	BOOL bResult = FALSE;

	if ( pOSApp )
	{
		/* Obtain the Main Interface to the Exec from the only static location within the system (4) */
		struct ExecIFace *IExec = (struct ExecIFace *)(*(struct ExecBase **)4)->MainInterface;
		
		if ( CxBase = IExec->OpenLibrary("commodities.library",50) )
		{
			if ( ICommodities = (struct CommoditiesIFace *)IExec->GetInterface(CxBase,"main",1,NULL) )
			{
				if ( IntuitionBase = IExec->OpenLibrary("intuition.library",50) )
				{
					if ( IIntuition = (struct IntuitionIFace *)IExec->GetInterface(IntuitionBase,"main",1,NULL) )
					{
						if ( GadToolsBase = IExec->OpenLibrary("gadtools.library",50) )
						{
							if ( IGadTools = (struct GadToolsIFace *)IExec->GetInterface(GadToolsBase,"main",1,NULL) )
							{
								if ( IconBase = IExec->OpenLibrary("icon.library",50) )
								{
									if ( IIcon = (struct IconIFace *)IExec->GetInterface(IconBase,"main",1,NULL) )
									{
										if ( KeymapBase = IExec->OpenLibrary("keymap.library",50) )
										{
											if ( IKeymap = (struct KeymapIFace *)IExec->GetInterface(KeymapBase,"main",1,NULL) )
											{
												if ( DateBrowserBase = IExec->OpenLibrary("gadgets/datebrowser.gadget",50) )
												{
													if ( IDateBrowser = (struct DateBrowserIFace *)IExec->GetInterface(DateBrowserBase,"main",1,NULL) )
													{
														if ( PaletteBase = IExec->OpenLibrary("gadgets/palette.gadget",50) )
														{
															if ( IPalette = (struct PaletteIFace *)IExec->GetInterface(PaletteBase,"main",1,NULL) )
															{
																if ( PartitionBase = IExec->OpenLibrary("gadgets/partition.gadget",46) )
																{
																	if ( IPartition = (struct PartitionIFace *)IExec->GetInterface(PartitionBase,"main",1,NULL) )
																	{
																		if ( PopupMenuBase = IExec->OpenLibrary("popupmenu.class",50) )
																		{
																			if ( IPopupMenu = (struct PopupMenuIFace *)IExec->GetInterface(PopupMenuBase,"main",1,NULL) )
																			{
																				if ( SketchBoardBase = IExec->OpenLibrary("gadgets/sketchboard.gadget",51) )
																				{
																					if ( ISketchBoard = (struct SketchBoardIFace *)IExec->GetInterface(SketchBoardBase,"main",1,NULL) )
																					{
																						bResult = TRUE;
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		/* If even one library or Interface did not setup, call os_CloseLibs() to cleanup */
		if ( FALSE == bResult ) os_CloseLibs(pOSApp);
	}
	return( bResult );
}
