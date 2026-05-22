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
#ifndef ABPREFS_GLOBALS_H
#define ABPREFS_GLOBALS_H
/*      ___________________

	ABackup Prefs
	globals.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 22-Sep-93
	Modified: 18-Jan-98
	___________________
*/

struct MinWindow {
    WORD			  mw_Width, mw_Height;
    WORD			  mw_Title;
    BYTE			  mw_GadCnt,mw_BoxCnt;
    struct MinGadget *mw_Gad;
    struct BBox 	 *mw_Box;
};

struct MinGadget {
    WORD			mg_LeftEdge, mg_TopEdge;
    WORD			mg_Width, mg_Height;
    UWORD       		mg_Type;
    WORD			mg_Text;
    ULONG       		mg_Flags;
    struct TagItem *mg_Tags;
};

struct BBox {
    WORD bb_LeftEdge, bb_TopEdge;
    WORD bb_Width, bb_Height;
    BOOL bb_Recessed;
};

#define MSG_VOID	(WORD)~0

GLOBAL ABPREFS  		*Prefs,*SavPrf;
GLOBAL XMINFO   		XMInfo;
GLOBAL struct Library   *XpkBase,*AmigaGuideBase;
GLOBAL struct MinList   *XpkMethodList,
						*XpkNameList,
						*CmpFilterList,
						*AllDevsList,
						*SelDevsList;
GLOBAL struct WBStartup *_WBenchMsg;
GLOBAL struct Screen    *Scr;
GLOBAL struct Window    *Win;
GLOBAL struct MinWindow MWin[];
GLOBAL struct AppWindow *AppWin;
GLOBAL struct MsgPort   *MsgPort;
GLOBAL struct Menu      	*Menus;
GLOBAL struct Gadget    *GList,**Gads;
GLOBAL struct MinGadget MGCompress[];
GLOBAL struct IClass    *GetFileClass,*GetDirClass,*GetElseClass;
GLOBAL struct _Object   *GetFileImage,*GetDirImage,*GetElseImage;
GLOBAL struct TextAttr  *Font;
GLOBAL struct Rectangle Offset;

GLOBAL struct LocaleBase	*LocaleBase;
GLOBAL struct Catalog   	*Catalog;

GLOBAL CxObj    		*Broker;
GLOBAL struct MsgPort   *BrokerMP;
GLOBAL struct MsgPort   *IPCMsgPort;

GLOBAL AMIGAGUIDECONTEXT AGHandle;
GLOBAL STRPTR NAGContext[];

GLOBAL struct TagItem   ASLFRTags[],ASLFOTags[],ASLSMTags[],GFBoxTags[],BBoxTags[];
GLOBAL struct TagItem   CYDevs[],LVDLst[],LVDevs[],STArcF[];
GLOBAL struct TagItem   SLBuff[],STLogF[],STDCom[],
						CBBRep[],CYBRTo[],CYBRTp[],CBVeri[],
						CBBLnk[],CBTask[],CBAddI[],CBAddC[],CBComp[],
						CBCCat[],CBCrpt[],CBABit[],CBDupC[],CBIgnS[];
GLOBAL struct TagItem   STRtTo[],
						CYExiF[],CYBadF[],
						CBRRep[],CYRRTo[],CYRRTp[],
						CBTree[],CBDate[],CBRLnk[],CBEmpt[],CBCatF[];
GLOBAL struct TagItem   CBVRep[],CYVRTo[],CYVRTp[],
						CBVCom[],CBVSel[],CBVIgD[];
GLOBAL struct TagItem   CYComp[],
						LVXpk[],SLXMod[],TXXMod[],TXXRat[],TXXPSp[],TXXUSp[],
						STComp[],STDcmp[],LVCFlt[];
GLOBAL struct TagItem   STDevD[],INScsi[],INBloc[],
						CBRwnd[],CBEjct[],CBARet[],CBFMTBuf[],
						BUScsi[];
GLOBAL struct TagItem   CYScTp[],STPbSc[],TXSMod[],STSFnt[],INSFnt[],STTFnt[],
						INTFnt[];
GLOBAL struct TagItem   CBAsyn[],CBConf[],STAsci[],STIlbm[],STOthr[];
GLOBAL struct TagItem   CYAlrt[],CYFSze[],STTemp[],STSele[],CBPrLb[],INLign[];

GLOBAL LONG     	*RArgs;
GLOBAL UWORD    FontX,FontY,Pattern[];
GLOBAL BYTE     	OldID,NewID,Aspect;
GLOBAL BOOL     	AddIcon,_EXECFROMABACKUP_;
GLOBAL APTR     	VInfo;
GLOBAL STRPTR   DevsLb[],RpToLb[],RpTpLb[],
				ExiFLb[],BadFLb[],CompLb[],
				ScTpLb[],AlrtLb[],FSzeLb[],
				_ENVNAME_,_ARCNAME_,_WBSCRNAME_,_HELPNAME_;

// Cycle gadgets maximum items (-1):
#define MAX_ITM_DEVICES 	2
#define MAX_ITM_REPTO   	1
#define MAX_ITM_REPTYPE 	1
#define MAX_ITM_EXISTING	4
#define MAX_ITM_BADFILES	2
#define MAX_ITM_CMPTYPE 	2
#define MAX_ITM_SCRTYPE 	2
#define MAX_ITM_ALERT   	3
#define MAX_ITM_FILESSIZE       3

#endif  // ABPREFS_GLOBALS_H
