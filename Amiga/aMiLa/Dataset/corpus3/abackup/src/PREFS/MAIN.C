/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*      ___________________

	ABackup Prefs
	main.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Aug-93
	Modified: 18-Jan-98
	___________________
*/

#include "headers.h"
#include "main.h"

STATIC VOID     HandleWindow    (VOID);
STATIC BYTE     HandleIDCMP     	(VOID);
STATIC VOID     HandleAppMsg    (VOID);
STATIC BOOL     CheckOptions    (VOID);
STATIC BYTE     HandleGadgets   (UWORD,UWORD);
STATIC BYTE     HandleKey       	(UWORD);
STATIC BYTE     HandleMenu      	(UWORD);
STATIC BOOL     ShowWindow      	(VOID);
STATIC VOID     About   		(VOID);

//______________________________________________________________________________

int     main (int argc,char *argv[])
{
	BOOL    rc;

	if (rc = Setup((BOOL)argc)) HandleWindow();

	Cleanup();
	return(rc?EXIT_SUCCESS:EXIT_FAILURE);
}
//______________________________________________________________________________

__inline STATIC VOID
HandleWindow()
{
	BYTE    rc = USE;

	FOREVER {
		if (rc != DISAPPEAR && NOT UpdateWindow()) break;

		switch (rc = HandleIDCMP()) {
			case APPEAR:
				break;

			case DISAPPEAR:
				if (Broker) {
					if (Win) {
						CleanupGadgets();
						CleanupWindow();
					}
					break;
				}
			case QUIT:
				return;

			default:
				CopyPrefs(rc);
				UpdateGadgets();
				break;
		}
	}
}
//______________________________________________________________________________

__inline STATIC BYTE
HandleIDCMP()
{
	struct Message  	*msg;
	struct IntuiMessage     *imsg;
	CxMsg   			*xmsg;
	APTR    			iaddr;
	ULONG   ipcsig,cxsig,appsig,winsig,allsig,signals,class,cxtype,abmsg;
	LONG    cxID;
	UWORD   code,gadID = 0;
	BYTE    rc;

	cxsig  = BrokerMP? (1L<<BrokerMP->mp_SigBit): NULL;
	appsig = AppWin? (1L<<MsgPort->mp_SigBit): NULL;
	winsig = Win? (1L<<Win->UserPort->mp_SigBit): NULL;
	ipcsig = IPCMsgPort? (1L<<IPCMsgPort->mp_SigBit): NULL;

	allsig = SIGBREAKF_CTRL_C |SIGBREAKF_CTRL_F |ipcsig |cxsig |appsig |winsig;

	FOREVER {
		signals = Wait(allsig);

		// Ctrl-C: Quit.
		if (AND(signals,SIGBREAKF_CTRL_C)) return QUIT;

		// Ctrl-F: Activate window and bring it to front.
		if (AND(signals,SIGBREAKF_CTRL_F) && ShowWindow()) return APPEAR;

		// Commodity:
		if (AND(signals,cxsig)) {
			while (xmsg = (CxMsg *)GetMsg(BrokerMP)) {
				cxID   = CxMsgID(xmsg);
				cxtype = CxMsgType(xmsg);

				ReplyMsg((struct Message *)xmsg);

				if (cxtype == CXM_COMMAND) {
					switch(cxID) {
						case CXCMD_DISAPPEAR:
							return DISAPPEAR;

						case CXCMD_KILL:
							return QUIT;

						case CXCMD_APPEAR:
						case CXCMD_UNIQUE:
							if (ShowWindow()) return APPEAR;
							break;
					}
				}
			}
		}

		// AppWindow:
		if (AND(signals,appsig)) HandleAppMsg();

		// Message from ABackup
		if (AND(signals,ipcsig)) {

			// get eventual message, and take argument in mn_Length
			code = 0;
			while (msg = GetMsg(IPCMsgPort)) {
				abmsg = msg->mn_Length;
				FreeVec(msg);
				code++;
			}

			/*
			 * If we got a at least one message, react depending on the
			 * argument of the last message :
			 *
			 * - if bit 0 of abmsg is set, bits 1 to 4 contain the id
			 *   of the window to display
			 * - else, abmsg is the address of ABackup screen and we
			 *   must check we use the same screen
			 *
			 * As Screen structures are allocated with AllocMem(), they
			 * are always longword aligned, which means bit 0 and 1 of
			 * screen addresses are always zero.
			 */

			if (code) {
				if (AND(abmsg,0x01)) {
					if (NOT Win) {
						NewID = abmsg >> 1;
						UpdateGadgets();
						return(APPEAR);
					}
				}
				else if (abmsg != (ULONG)Scr) return QUIT;
			}
		}

		// Drain IDCMP:
		if (AND(signals,winsig)) {
			while (imsg = GT_GetIMsg(Win->UserPort)) {
				class = imsg->Class;
				code  = imsg->Code;
				iaddr = imsg->IAddress;

				GT_ReplyIMsg(imsg);

				switch (class) {
					case IDCMP_REFRESHWINDOW:
						GT_BeginRefresh(Win);
						Render();
						GT_EndRefresh(Win,TRUE);
						break;

					case IDCMP_CLOSEWINDOW:
						return DISAPPEAR;

					case IDCMP_MOUSEMOVE:
						if (NewID != WIN_COMPRESS && gadID != GD_XpkMode) break;
					case IDCMP_GADGETUP:
						gadID = ((struct Gadget *)iaddr)->GadgetID;
						if (rc = HandleGadgets(gadID,code)) return(rc);
						break;

					case IDCMP_VANILLAKEY:
						if (rc = HandleKey(code)) return(rc);
						break;

					case IDCMP_RAWKEY:
						if (AGHandle && code == RAW_HELP)
							SendAmigaGuideCmd(AGHandle,NULL,AGA_Context,NewID,TAG_DONE);
						break;

					case IDCMP_MENUPICK:
						if (rc = HandleMenu(code)) return(rc);
						break;
				}
			}
		}
	}
}
//______________________________________________________________________________

__inline STATIC VOID
HandleAppMsg()
{
	struct AppMessage       *amsg;
	UBYTE   name[256];

	while (amsg = (struct AppMessage *)GetMsg(MsgPort)) {
		NameFromLock(amsg->am_ArgList->wa_Lock,name,256);
		AddPart(name,amsg->am_ArgList->wa_Name,256L);

		ReplyMsg((struct Message *)amsg);

		READPREFS(name);
		SetGadgets();
	}
}

//______________________________________________________________________________

STATIC BOOL
CheckOptions()
{
	if (NewID == WIN_BACKUP) {
		if (IS_BFL_TOFILE && (NOT PRF_BUPTO[0])) {
			DisplayBeep(Scr);
			ActivateGadget(Gads[GD_BackupArcFile],Win,NULL);
			return FALSE;
		}
		if (IS_BFL_TODEVICE) {
			ListToString(SelDevsList,PRF_BUPTO);
			if (NOT PRF_BUPTO[0]) strcpy(PRF_BUPTO,"DF0:");
		}
	}

	if (NewID == WIN_RESTORE) {
		if (IS_RFL_FROMFILE && (NOT PRF_RESFROM[0])) {
			DisplayBeep(Scr);
			ActivateGadget(Gads[GD_RestoreArcFile],Win,NULL);
			return FALSE;
		}
		if (IS_RFL_FROMDEVICE) {
			ListToString(SelDevsList,PRF_RESFROM);
			if (NOT PRF_RESFROM[0]) strcpy(PRF_RESFROM,"DF0:");
		}
	}

	return TRUE;
}

//______________________________________________________________________________

__inline STATIC BYTE
HandleGadgets (UWORD gadID,UWORD code)
{

	if (NewID != WIN_MAIN && (gadID == GD_Ok || gadID == GD_Cancel)) {
		if ( (gadID == GD_Ok) && (NOT CheckOptions()) ) return FALSE;
		NewID = WIN_MAIN;
		return((BYTE)(gadID == GD_Ok? SAVE: RESTORE));
	}
	else switch (NewID) {
		case WIN_MAIN    :      return(HandleMain(gadID,code));
		case WIN_BACKUP  :      HandleBackup(gadID,code);
							break;
		case WIN_RESTORE :      HandleRestore(gadID,code);
							break;
		case WIN_VERIFY  :      HandleVerify(gadID,code);
							break;
		case WIN_COMPRESS:      HandleCompress(gadID,code);
							break;
		case WIN_TAPE    :      HandleTape(gadID,code);
							break;
		case WIN_EXTERNAL:      HandleExternal(gadID,code);
							break;
		case WIN_GUI     :      HandleGUI(gadID,code);
							break;
		case WIN_MISC    :      HandleMisc(gadID,code);
							break;
	}
	return FALSE;
}
//______________________________________________________________________________

__inline STATIC BYTE
HandleKey (UWORD code)
{
	// if window is zoomed, forget about keyboard events:
	if (AND(Win->Flags,WFLG_ZOOMED)) return FALSE;

	if (NewID && (SHORT_CUT(MSG_OK)||SHORT_CUT(MSG_CANCEL)||code == 0x1B)){
		if (SHORT_CUT(MSG_OK) && (NOT CheckOptions()) ) return FALSE;
		NewID = WIN_MAIN;
		return((BYTE)(SHORT_CUT(MSG_OK)?SAVE:RESTORE));
	}
	else switch (NewID) {
		//________________________________________________________ Main options:

		case WIN_MAIN:
			// save to the prefs file and quit:
			if (SHORT_CUT(MSG_SAVE))
				return(HandleMain(GD_Save,NULL));
			// use the prefs and quit:
			else if (SHORT_CUT(MSG_USE))
				return(HandleMain(GD_Use,NULL));
			// quit without saving:
			else if (SHORT_CUT(MSG_CANCEL)||code == 0x1B) return DISAPPEAR;

			// open the backup options window:
			else if (SHORT_CUT(MSG_BACKUP))
				return(HandleMain(GD_Backup,NULL));
			// open the restore options window:
			else if (SHORT_CUT(MSG_RESTORE))
				return(HandleMain(GD_Restore,NULL));
			// open the verify options window:
			else if (SHORT_CUT(MSG_VERIFY))
				return(HandleMain(GD_Verify,NULL));
			// open the compression options window:
			else if (SHORT_CUT(MSG_COMPRESSION))
				return(HandleMain(GD_Compress,NULL));
			// open the tape options window:
			else if (SHORT_CUT(MSG_TAPE))
				return(HandleMain(GD_Tape,NULL));
			// open the GUI options window:
			else if (SHORT_CUT(MSG_GUI))
				return(HandleMain(GD_GUI,NULL));
			// open the external programs window:
			else if (SHORT_CUT(MSG_EXTERNAL_PROGS))
				return(HandleMain(GD_External,NULL));
			// open the miscellaneous options window:
			else if (SHORT_CUT(MSG_MISCELLANEOUS))
				return(HandleMain(GD_Misc,NULL));
			break;

		//______________________________________________________ Backup options:

		case WIN_BACKUP:
			//...
			// cycle forward/backward backup destination gadget:
			if (SHORT_CUT(MSG_BACKUP_TO)) {
				SetCycle(GD_BackupTo,CYDevs,MAX_ITM_DEVICES,LOWER_CUT(MSG_BACKUP_TO));
				HandleBackup(GD_BackupTo,CYDevs[1].ti_Data);
			}
			// activate the archive file string gadget:
			else if (IS_BFL_TOFILE && LOWER_CUT(MSG_ARCHIVE_FILE))
				ActivateGadget(Gads[GD_BackupArcFile],Win,NULL);
			// call a file requester to choose an archive file:
			else if (IS_BFL_TOFILE && UPPER_CUT(MSG_ARCHIVE_FILE))
				HandleBackup(GD_BackupArcFile,NULL);

			// increment the buffer size:
			else if (LOWER_CUT(MSG_BUFFER_SIZE)) {
				if (PRF_BUFSIZE == SLBuff[1].ti_Data);
				else SetGad(GD_BufferSize,GTSL_Level,++PRF_BUFSIZE);
			}
			else if (UPPER_CUT(MSG_BUFFER_SIZE)) {
				if (PRF_BUFSIZE) SetGad(GD_BufferSize,GTSL_Level,--PRF_BUFSIZE);
			}

			// activate the log file string gadget:
			else if (LOWER_CUT(MSG_LOG_FILE))
				ActivateGadget(Gads[GD_LogFile],Win,NULL);
			// call a file requester to choose the log file:
			else if (UPPER_CUT(MSG_LOG_FILE))
				HandleBackup(GD_LogFileLoad,NULL);

			// activate the default comment string gadget:
			else if (IS_BFL_ADDCOMMENT && SHORT_CUT(MSG_DEFAULT_COMMENT))
				ActivateGadget(Gads[GD_DefaultComment],Win,NULL);

			//...
			else if (SHORT_CUT(MSG_REPORT)) {
				HandleBackup(GD_BackupReport,NULL);
				SetGad(GD_BackupReport,GTCB_Checked,IS_BFL_REPORT);
			}

			//...
			else if (SHORT_CUT(MSG_BACKUP_VERIFY)) {
				HandleBackup(GD_BackupVerify,NULL);
				SetGad(GD_BackupVerify,GTCB_Checked,IS_BFL_VERIFY);
			}
			else if (SHORT_CUT(MSG_CHILD_TASK)) {
				HandleBackup(GD_UseChildTask,NULL);
				SetGad(GD_UseChildTask,GTCB_Checked,IS_BFL_CHILDTASK);
			}
			else if (SHORT_CUT(MSG_BACKUP_LINKS)) {
				HandleBackup(GD_BackupLinks,NULL);
				SetGad(GD_BackupLinks,GTCB_Checked,IS_BFL_LINKS);
			}
			else if (SHORT_CUT(MSG_ADD_COMMENT)) {
				HandleBackup(GD_AddComment,NULL);
				SetGad(GD_AddComment,GTCB_Checked,IS_BFL_ADDCOMMENT);
			}
			else if (SHORT_CUT(MSG_ADD_ICON)) {
				HandleBackup(GD_AddIcon,NULL);
				SetGad(GD_AddIcon,GTCB_Checked,IS_BFL_ADDICON);
			}
			else if (SHORT_CUT(MSG_COMPRESS)) {
				HandleBackup(GD_CompressData,NULL);
				SetGad(GD_CompressData,GTCB_Checked,IS_BFL_COMPRESS);
			}
			else if (SHORT_CUT(MSG_COMPRESS_CAT)) {
				HandleBackup(GD_CompressCatalog,NULL);
				SetGad(GD_CompressCatalog,GTCB_Checked,IS_BFL_CATCOMP);
			}
			else if (SHORT_CUT(MSG_ENCRYPT)) {
				HandleBackup(GD_Encrypt,NULL);
				SetGad(GD_Encrypt,GTCB_Checked,IS_BFL_ENCRYPT);
			}
			else if (SHORT_CUT(MSG_SET_ARCHIVE_BIT)) {
				HandleBackup(GD_SetArchiveBit,NULL);
				SetGad(GD_SetArchiveBit,GTCB_Checked,IS_BFL_SETABIT);
			}
			else if (SHORT_CUT(MSG_DUP_CATALOG)) {
				HandleBackup(GD_DuplicateCatalog,NULL);
				SetGad(GD_DuplicateCatalog,GTCB_Checked,IS_BFL_DUPCATALOG);
			}
			else if (SHORT_CUT(MSG_IGNORE_SKIPME)) {
				HandleBackup(GD_IgnoreSkipme,NULL);
				SetGad(GD_IgnoreSkipme,GTCB_Checked,IS_BFL_IGNSKIPME);
			}
			break;

		//_____________________________________________________ Restore options:

		case WIN_RESTORE:
			// cycle forward/backward restore source gadget:
			if (SHORT_CUT(MSG_RESTORE_FROM)) {
				SetCycle(GD_RestoreFrom,CYDevs,MAX_ITM_DEVICES,LOWER_CUT(MSG_RESTORE_FROM));
				HandleRestore(GD_RestoreFrom,CYDevs[1].ti_Data);
			}
			// activate the archive file string gadget:
			else if (IS_RFL_FROMFILE && LOWER_CUT(MSG_ARCHIVE_FILE))
				ActivateGadget(Gads[GD_RestoreArcFile],Win,NULL);
			// call a file requester to choose an archive file:
			else if (IS_RFL_FROMFILE && UPPER_CUT(MSG_ARCHIVE_FILE))
				HandleRestore(GD_RestoreArcFile,NULL);

			// activate the restore target string gadget:
			else if (LOWER_CUT(MSG_RESTORE_TO))
				ActivateGadget(Gads[GD_RestoreTo],Win,NULL);
			// call a file requester to choose the restore target:
			else if (UPPER_CUT(MSG_RESTORE_TO))
				HandleRestore(GD_RestoreToLoad,NULL);

			//...
			else if (SHORT_CUT(MSG_EXISTING_FILES)) {
				SetCycle(GD_ExistingFiles,CYExiF,MAX_ITM_EXISTING,LOWER_CUT(MSG_EXISTING_FILES));
				HandleRestore(GD_ExistingFiles,CYExiF[1].ti_Data);
			}
			//...
			else if (SHORT_CUT(MSG_BAD_FILES)) {
				SetCycle(GD_BadFiles,CYBadF,MAX_ITM_BADFILES,LOWER_CUT(MSG_BAD_FILES));
				HandleRestore(GD_BadFiles,CYBadF[1].ti_Data);
			}

			//...
			else if (SHORT_CUT(MSG_REPORT)) {
				HandleRestore(GD_RestoreReport,NULL);
				SetGad(GD_RestoreReport,GTCB_Checked,IS_RFL_REPORT);
			}

			//...
			else if (SHORT_CUT(MSG_TREE)) {
				HandleRestore(GD_RestoreTree,NULL);
				SetGad(GD_RestoreTree,GTCB_Checked,IS_RFL_DIRTREE);
			}
			else if (SHORT_CUT(MSG_RESTORE_DATE)) {
				HandleRestore(GD_RestoreDate,NULL);
				SetGad(GD_RestoreDate,GTCB_Checked,IS_RFL_DATE);
			}
			else if (SHORT_CUT(MSG_RESTORE_LINKS)) {
				HandleRestore(GD_RestoreLinks,NULL);
				SetGad(GD_RestoreLinks,GTCB_Checked,IS_RFL_LINKS);
			}
			else if (SHORT_CUT(MSG_EMPTY_DIRS)) {
				HandleRestore(GD_RestoreEmptyDirs,NULL);
				SetGad(GD_RestoreEmptyDirs,GTCB_Checked,IS_RFL_EMPTYDIRS);
			}
			else if (SHORT_CUT(MSG_USE_CAT_FILE)) {
				HandleRestore(GD_UseCatalogFile,NULL);
				SetGad(GD_UseCatalogFile,GTCB_Checked,IS_RFL_USECATFILE);
			}
			break;

		//______________________________________________________ Verify options:

		case WIN_VERIFY:
			//...
			if (SHORT_CUT(MSG_REPORT)) {
				HandleVerify(GD_VerifyReport,NULL);
				SetGad(GD_VerifyReport,GTCB_Checked,IS_VFL_REPORT);
			}

			//...
			else if (SHORT_CUT(MSG_COMPARE_DATA)) {
				HandleVerify(GD_CompareData,NULL);
				SetGad(GD_CompareData,GTCB_Checked,IS_VFL_COMPARE);
			}
			//...
			else if (SHORT_CUT(MSG_SELECT_FILES)) {
				HandleVerify(GD_SelectFiles,NULL);
				SetGad(GD_SelectFiles,GTCB_Checked,IS_VFL_SELECTIVE);
			}
			//...
			else if (SHORT_CUT(MSG_IGNORE_DATE)) {
				HandleVerify(GD_IgnoreFilesDate,NULL);
				SetGad(GD_IgnoreFilesDate,GTCB_Checked,IS_VFL_IGNOREDATE);
			}
			break;

		//_________________________________________________ Compression options:

		case WIN_COMPRESS:
			//...
			if (SHORT_CUT(MSG_COMPRESS_METHOD)) {
				SetCycle(GD_CompressMethod,CYComp,MAX_ITM_CMPTYPE-(XpkBase?0:1),LOWER_CUT(MSG_COMPRESS_METHOD));
				HandleCompress(GD_CompressMethod,CYComp[1].ti_Data);
			}
			else if (SHORT_CUT(MSG_FILTER))
				ActivateGadget(Gads[GD_FilterString],Win,NULL);
			else if (SHORT_CUT(MSG_DELETE))
				HandleCompress(GD_FilterDelete,NULL);
			//...
			else if (IS_XPKLIB && XpkBase) {
				if (LOWER_CUT(MSG_XPK_MODE)) {
					PRF_XPKMODE = XMInfo.Upto;
					if (XMInfo.Upto<100) PRF_XPKMODE++;

					SetGad(GD_XpkMode,GTSL_Level,PRF_XPKMODE);
					HandleCompress(GD_XpkMode,PRF_XPKMODE);
				}
				else if (UPPER_CUT(MSG_XPK_MODE)) {
					if (PRF_XPKMODE) {
						SetGad(GD_XpkMode,GTSL_Level,--PRF_XPKMODE);
						HandleCompress(GD_XpkMode,PRF_XPKMODE);
					}
				}
			/*
				else if (LOWER_CUT(MSG_XPK_LIBS)) {
					if (code < ???) {
						code++;
						UpdateTagData(GD_XpkLibs,GTLV_Top,code);
						SetGad (GD_XpkLibs,GTLV_Selected,code);
						HandleCompress(GD_XpkLibs,code);
					}
				}
				else if (UPPER_CUT(MSG_XPK_LIBS)) {
					if (code = GetTagData(GTLV_Selected,NULL,LVXpk)) {
						code--;
						UpdateTagData(GD_XpkLibs,GTLV_Top,code);
						SetGad (GD_XpkLibs,GTLV_Selected,code);
						HandleCompress(GD_XpkLibs,code);
					}
				}
			*/
			}
			else if (IS_EXTERNAL) {
				if (LOWER_CUT(MSG_EXTERNAL_COMP))
					ActivateGadget(Gads[GD_ExternalComp],Win,NULL);
				else if (UPPER_CUT(MSG_EXTERNAL_COMP))
					HandleCompress(GD_ExternalCompLoad,NULL);
				else if (LOWER_CUT(MSG_EXTERNAL_DECOMP))
					ActivateGadget(Gads[GD_ExternalDecomp],Win,NULL);
				else if (UPPER_CUT(MSG_EXTERNAL_DECOMP))
					HandleCompress(GD_ExternalDecompLoad,NULL);
			}
			break;

		//________________________________________________________ Tape options:

		case WIN_TAPE:
			// activate the device driver string gadget:
			if (LOWER_CUT(MSG_DEVICE_DRIVER))
				ActivateGadget(Gads[GD_DeviceDriver],Win,NULL);

			// activate the SCSI port integer gadget:
			else if (SHORT_CUT(MSG_SCSI_PORT))
				ActivateGadget(Gads[GD_SCSIPort],Win,NULL);
			// activate the block size integer gadget:
			else if (SHORT_CUT(MSG_BLOCK_SIZE))
				ActivateGadget(Gads[GD_BlockSize],Win,NULL);

			//...
			else if (SHORT_CUT(MSG_REWIND)) {
				HandleTape(GD_Rewind,NULL);
				SetGad(GD_Rewind,GTCB_Checked,IS_TFL_REWIND);
			}
			else if (SHORT_CUT(MSG_EJECT)) {
				HandleTape(GD_Eject,NULL);
				SetGad(GD_Eject,GTCB_Checked,IS_TFL_EJECT);
			}
			else if (SHORT_CUT(MSG_AUTO_RETENTION)) {
				HandleTape(GD_AutoRetention,NULL);
				SetGad(GD_AutoRetention,GTCB_Checked,IS_TFL_RETENTION);
			}
			else if (SHORT_CUT(MSG_FASTMEM_TBUFFER)) {
				HandleTape(GD_FastMemBuffer,NULL);
				SetGad(GD_FastMemBuffer,GTCB_Checked,IS_TFL_FASTBUFFER);
			}

			//...
			else if (SHORT_CUT(MSG_SCSI_INQUIRY))
				HandleTape(GD_SCSIInquiry,NULL);
			break;

		//_________________________________________________________ GUI options:

		case WIN_GUI:
			//...
			if (SHORT_CUT(MSG_SCREEN_TYPE)) {
				SetCycle(GD_ScreenType,CYScTp,MAX_ITM_SCRTYPE,LOWER_CUT(MSG_SCREEN_TYPE));
				HandleGUI(GD_ScreenType,CYScTp[1].ti_Data);
			}
			else if (IS_PUBLIC && SHORT_CUT(MSG_PUBSCREEN_NAME))
				ActivateGadget(Gads[GD_PubScreenName],Win,NULL);

			//...
			else if(LOWER_CUT(MSG_SCREENFONT_NAME))
				ActivateGadget(Gads[GD_ScrFontName],Win,NULL);
			else if (UPPER_CUT(MSG_SCREENFONT_NAME))
				HandleGUI(GD_ScrFontLoad,NULL);
			//...
			else if(LOWER_CUT(MSG_TEXTFONT_NAME))
				ActivateGadget(Gads[GD_TxtFontName],Win,NULL);
			else if (UPPER_CUT(MSG_TEXTFONT_NAME))
				HandleGUI(GD_TxtFontLoad,NULL);

			//...
			else if (SHORT_CUT(MSG_PALETTE))
				HandleGUI(GD_Palette,NULL);
			break;

		//___________________________________________ External Programs options:

		case WIN_EXTERNAL:
			//...
			if (LOWER_CUT(MSG_ASCII))
				ActivateGadget(Gads[GD_ExternalASCII],Win,NULL);
			else if (UPPER_CUT(MSG_ASCII))
				HandleExternal(GD_ExternalASCIILoad,NULL);

			//...
			else if (LOWER_CUT(MSG_ILBM))
				ActivateGadget(Gads[GD_ExternalILBM],Win,NULL);
			else if (UPPER_CUT(MSG_ILBM))
				HandleExternal(GD_ExternalILBMLoad,NULL);

			//...
			else if (LOWER_CUT(MSG_OTHERS))
				ActivateGadget(Gads[GD_ExternalOthers],Win,NULL);
			else if (UPPER_CUT(MSG_OTHERS))
				HandleExternal(GD_ExternalOthersLoad,NULL);

			//...
			else if (SHORT_CUT(MSG_ASYNCHRO)) {
				HandleExternal(GD_ExternalAsynchro,NULL);
				SetGad(GD_ExternalAsynchro,GTCB_Checked,IS_VISASYNCHRO);
			}
			else if (SHORT_CUT(MSG_CONFIRM)) {
				HandleExternal(GD_ExternalConfirm,NULL);
				SetGad(GD_ExternalConfirm,GTCB_Checked,IS_VISCONFIRM);
			}
			break;

		//_______________________________________________ Miscellaneous options:

		case WIN_MISC:
			// cycle forward/backward alert gadget:
			if (SHORT_CUT(MSG_ALERT)) {
				SetCycle(GD_Alert,CYAlrt,MAX_ITM_ALERT,LOWER_CUT(MSG_ALERT));
				HandleMisc(GD_Alert,CYAlrt[1].ti_Data);
			}

			// cycle forward/backward files size gadget:
			else if (SHORT_CUT(MSG_FILES_SIZE)) {
				SetCycle(GD_FilesSize,CYFSze,MAX_ITM_FILESSIZE,LOWER_CUT(MSG_FILES_SIZE));
				HandleMisc(GD_FilesSize,CYFSze[1].ti_Data);
			}

			// call a file requester to choose the temporary dir:
			else if (UPPER_CUT(MSG_TEMP_DIRECTORY))
				HandleMisc(GD_TempDirectoryLoad,NULL);
			// activate the temporary dir string gadget:
			else if (LOWER_CUT(MSG_TEMP_DIRECTORY))
				ActivateGadget(Gads[GD_TempDirectory],Win,NULL);

			// call a file requester to choose the default selection path:
			else if (UPPER_CUT(MSG_SELECTION_PATH))
				HandleMisc(GD_SelectionPathLoad,NULL);
			// activate the default selection path string gadget:
			else if (LOWER_CUT(MSG_SELECTION_PATH))
				ActivateGadget(Gads[GD_SelectionPath],Win,NULL);

			//...
			else if (SHORT_CUT(MSG_PRINT_LABELS)) {
				HandleMisc(GD_PrintLabels,NULL);
				SetGad(GD_PrintLabels,GTCB_Checked,IS_BFL_PRINTLABELS);
			}
			else if (IS_BFL_PRINTLABELS && SHORT_CUT(MSG_LABELS_LENGTH))
				ActivateGadget(Gads[GD_LabelsLength],Win,NULL);
			break;
	}
	return FALSE;
}
//______________________________________________________________________________

__inline STATIC BYTE
HandleMenu (UWORD code)
{
	UBYTE   item,name[512];

	name[0] = '\0';

	while (code != MENUNULL) {
		item = ITEMNUM(code);
		switch (MENUNUM(code)) {
			case MN_PROJECT:
				switch (item) {
					case MN_PROJECT_OPEN:
						if (LOADPREFS(name) && READPREFS(name)) {
							SetGadgets();
							CopyPrefs(SAVE);
						}
						break;

					case MN_PROJECT_SAVEAS:
						if (SAVEPREFS(name)) WRITEPREFS(name);
						break;

					case MN_PROJECT_ABOUT:
						About();
						break;

					case MN_PROJECT_HIDE:
						return DISAPPEAR;

					case MN_PROJECT_QUIT:
						return QUIT;
				}
				break;

			case MN_EDIT:
				switch (item) {
					case MN_EDIT_DEFAULT:
						CopyDefaults();
						break;

					case MN_EDIT_RESTORE:
						CopyPrefs(RESTORE);
						break;

					case MN_EDIT_LASTSAVED:
						if (READPREFS(_ARCNAME_)) break;
					default:
						return FALSE;
				}
				SetGadgets();
				break;

			case MN_SETTINGS:
				switch (item) {
					case MN_SETTINGS_CREATEICONS:
						FLIP(AddIcon);
						break;
				}
				break;
		}
		code = (ItemAddress(Menus,code))->NextSelect;
	}
	return FALSE;
}
//______________________________________________________________________________

STATIC BOOL
ShowWindow()
{
	if (Win) {
		if (AND(Win->Flags,WFLG_ZOOMED)) ZipWindow(Win);

		WindowToFront(Win);
		ActivateWindow(Win);

		return FALSE;
	}
	return TRUE;
}
//______________________________________________________________________________

__inline STATIC VOID
About()
{
	STRPTR  args[3];

	args[0] = PROGRAM;
	args[1] = GetStr(MSG_RIGHTS);
	args[2] = GetStr(MSG_TRANSLATION);

	Notify(MSG_PROJECT_ABOUT,"%s\n%s.\n\n%s",MSG_RESUME,args);
}

// Tab size: 4
