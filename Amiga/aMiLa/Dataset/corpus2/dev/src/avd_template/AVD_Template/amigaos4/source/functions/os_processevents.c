/*
 *---------------------------------------------------------------------
 * Original Author: Jamie Krueger
 * Creation Date  : 9/25/2003
 *---------------------------------------------------------------------
 * Copyright (c) 2003 BITbyBIT Software Group, All Rights Reserved.
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
 *  Function Name: os_ProcessEvents()
 *
 *  Project: AVD_Template
 *
 *  Description: Handles all event messages until "quit" is indicated
 *
 *  Entry Values: pOSApp = Pointer to the OS Specific structure
 *
 *  Exit Values: AVD_ERRORCODE (if any)
 *
 * $VER: $
 * $History: os_processevents.c $
 * 
 * *****************  Version 1  *****************
 */

/* Include Operating Specific Functions header file */
#include "os_functions.h"

AVD_ERRORCODE os_ProcessEvents(OSAPP *pOSApp)
{
	struct AVD_WindowHandle *pWindowHandle = NULL;
	struct List             *pWindowList   = NULL;
	struct Node             *pNextNode     = NULL;
	uint32                  sigcxmask      = 0;
	uint32                  siggot         = 0;
	CxMsg                   *CXMsg         = NULL;
	uint32                  nMsgID         = 0;
	uint32                  nMsgType       = 0;
	uint32                  result         = 0;
	uint32                  code           = 0;
	uint32                  nQualifier     = 0;
	BOOL                    done           = FALSE;
	AVD_ERRORCODE           Results        = AVDERR_NOERROR;

	if ( pOSApp )
	{
		if ( (pOSApp->pCxMsgPort) && (pOSApp->pMsgPort) )
		{
			/* Make sure we have a valid pointer to the List of Window (struct AVD_WindowHandle) nodes */
			pWindowList = &pOSApp->oWindowList;
			if ( 0 == pWindowList->lh_TailPred ) IExec->NewList(pWindowList);

			/* Get the CxBroker's signal mask */
			sigcxmask = (1L << pOSApp->pCxMsgPort->mp_SigBit);

			while( !done )
			{
				/*
				 * Get ALL the signal masks for all Window Objects.
				 * This must be done each time through to pick up new windows being opened,
				 * or drop ones that have been closed.
				 */
				pOSApp->sigwinmask = os_ReturnAllSigmasks(pOSApp,pWindowList);

				siggot = IExec->Wait(sigcxmask | pOSApp->sigwinmask | SIGBREAKF_CTRL_C);
				if (siggot & SIGBREAKF_CTRL_C) done = TRUE;

				/*
				 * Scan through all the AVD Window Handle nodes in the list,
				 * and process the events from each window object.
				 */
				/* If we got a signal for the ReAction Window Object, then handle it's Input Msgs */
				if ( siggot & pOSApp->sigwinmask )
				{
					if ( !IsListEmpty(pWindowList) )
					{
						for( pNextNode = pWindowList->lh_Head; pNextNode->ln_Succ; pNextNode = pNextNode->ln_Succ )
						{
							pWindowHandle = (struct AVD_WindowHandle *)pNextNode;
							if ( pWindowHandle->wh_WinObj )
							{
								if ( NULL == pWindowHandle->wh_Window )
								{
									/* The window is not open yet, so just look for Open/Uniconify messages */
									while( (result = RA_HandleInput(pWindowHandle->wh_WinObj,&code)) )
									{
										switch( result & WMHI_CLASSMASK )
										{
											case WMHI_UNICONIFY:
												DEBUG_TEXT("You hit UNICONIFY!")
												os_DisplayGUI(pOSApp);
											break;
										}
									}; /* While RA_HandleInput */
								}
								else
								{
									/* Next Process the events sent to our Window's MsgPort */
									while( (result = RA_HandleInput(pWindowHandle->wh_WinObj,&code)) )
									{
										switch( result & WMHI_CLASSMASK )
										{
											case WMHI_CLOSEWINDOW:
												DEBUG_TEXT("Close Gadget Hit: Hiding Window...")
												os_HideGUI(pOSApp,HIDE_ALL_WINDOWS);
											break;

											case WMHI_MENUPICK:
												switch( result & MENUID_MASK )
												{
													case MENUID_HIDE:
														os_HideGUI(pOSApp,HIDE_ALL_WINDOWS);
													break;

													case MENUID_ICONIFY:
														DEBUG_TEXT("You hit ICONIFY!")
														os_HideGUI(pOSApp,ICONIFY_ALL_WINDOWS);
													break;

													case MENUID_ABOUT:
													break;

													case MENUID_QUIT:
														DEBUG_TEXT("Bye Bye now... :^)\n")
														done = TRUE;
													break;

													case MENUID_SNAPSHOT:
													break;

													case MENUID_CENTER:
														/* Turn on the Centering Flag, and refresh the window */
														os_HideGUI(pOSApp,CENTER_MAIN_WINDOW);
														os_DisplayGUI(pOSApp);
													break;

													case MENUID_ZOOMZIP:
														IIntuition->ZipWindow(pWindowHandle->wh_Window);
													break;

													default:
													break;
												}
											break;

											case WMHI_GADGETUP:
												switch( result & WMHI_GADGETMASK )
												{
/*AVD_START_HERE
 *********** AVD RESERVED SECTION FOR AUTO-GENERATED SOURCE CODE ***********
 * This section of the file is automatically read and updated at build time,
 * do not make any changes or add anything between here and the 'AVD_END_HERE'
 * header, or the end of this file if no 'END'ing header is found.
 ************************* DO NOT EDIT THIS HEADER *************************
 */
													case OBJ3_BUTTON:
														puts("You Hit BUTTON Object[0x3]");
													break;
													case OBJ5_BUTTON:
														puts("You Hit BUTTON Object[0x5]");
													break;
													case OBJ6_BUTTON:
														puts("You Hit BUTTON Object[0x6]");
														done = TRUE;
													break;
/*
 *********** AVD RESERVED SECTION FOR AUTO-GENERATED SOURCE CODE ***********
 * This completes this reserved section of the file.
 * You are free to modify or add any custom code from this point.
 ************************* DO NOT EDIT THIS HEADER *************************
 AVD_END_HERE*/
													default:
													break;
												}
											break;

											case WMHI_GADGETHELP:
												DEBUG_TEXT("Got a WMHI_GADGETHELP Message...")
											break;

											case WMHI_MOUSEBUTTONS:
												DEBUG_TEXT("Got a WMHI_MOUSEBUTTONS Message...")
											break;

											case WMHI_VANILLAKEY:
												DEBUG_TEXT("Got a WMHI_VANILLAKEY Message...")
											break;

											case WMHI_ICONIFY:
												DEBUG_TEXT("You hit ICONIFY!")
												os_HideGUI(pOSApp,ICONIFY_ALL_WINDOWS);
											break;

											case WMHI_UNICONIFY:
												DEBUG_TEXT("You hit UNICONIFY!")
												os_DisplayGUI(pOSApp);
											break;

											case WMHI_RAWKEY:
												/* Check for Hide Key */
												if ( ((result & WMHI_KEYMASK) & pOSApp->oHideKey.ix_CodeMask) == pOSApp->oHideKey.ix_Code )
												{
													/* Fetch the current WINDOW_Qualifier key */
													IIntuition->GetAttr(WINDOW_Qualifier,pWindowHandle->wh_WinObj,(ULONG *)&nQualifier);
													DEBUG_MSG("WMHI_RAWKEY Message with IEQUALIFIER_0x%lx",nQualifier)

													if ( (nQualifier & pOSApp->oHideKey.ix_QualMask) == pOSApp->oHideKey.ix_Qualifier )
													{
														DEBUG_MSG("HideKey Hit(0x%x:0x%x): Hiding Window...",pOSApp->oHideKey.ix_Code,pOSApp->oHideKey.ix_Qualifier)
														os_HideGUI(pOSApp,HIDE_ALL_WINDOWS);
													}
												}
											break;
		        					
											default:
												//DEBUG_MSG("Got unhandled Event:0x%x\n",(result & WMHI_CLASSMASK))
											break;
										}
									}; /* While RA_HandleInput */
								}
							} /* If sigwinmask */
						}
					}
				}

				/*
				 * If we got a signal for the CxBroker, then process the CxMsgs
				 */
				if ( siggot & sigcxmask )
				{
					/* First process all CxMsgs from our Broker's MsgPort */
					while( CXMsg = (CxMsg *)IExec->GetMsg(pOSApp->pCxMsgPort) )
					{
						/* Make a copy of everything we need from the Msg and reply as quickly as possible */
						nMsgID   = ICommodities->CxMsgID(CXMsg);
						nMsgType = ICommodities->CxMsgType(CXMsg);
						IExec->ReplyMsg((struct Message *)CXMsg);

						switch( nMsgType )
						{
							case CXM_IEVENT:
								DEBUG_TEXT("Got CXM_IEVENT...")
								switch( nMsgID )
								{
									case EVT_HOTKEY:
										DEBUG_TEXT("Got EVT_HOTKEY")
										os_DisplayGUI(pOSApp);
									break;
								}
							break;

							case CXM_COMMAND:
								switch( nMsgID )
								{
									case CXCMD_KILL:
										done = TRUE;
									break;

									case CXCMD_DISABLE:
										//DEBUG_TEXT("Got CXCMD_DISABLE")
										//ICommodities->ActivateCxObj(pCxBroker,0L);
									break;

									case CXCMD_ENABLE:
										//DEBUG_TEXT("Got CXCMD_ENABLE")
										//ICommodities->ActivateCxObj(pCxBroker,1L);
									break;

									case CXCMD_DISAPPEAR:
										DEBUG_TEXT("Got CXCMD_DISAPPEAR")
										os_HideGUI(pOSApp,HIDE_ALL_WINDOWS);
									break;

									case CXCMD_UNIQUE:
										DEBUG_TEXT("Got CXCMD_UNIQUE, fallthrough to Appear...")
									case CXCMD_APPEAR:
										DEBUG_TEXT("Got CXCMD_APPEAR")
										os_DisplayGUI(pOSApp);
									break;
								}
							break;
						}
					}; /* While CXMsg */
				}
			}; /* While !done */
		}
	}
	return( (AVD_ERRORCODE)Results );
}
