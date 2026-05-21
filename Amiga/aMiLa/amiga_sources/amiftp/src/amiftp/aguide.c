/* RCS Id:  $Id: AGuide.c 1.798 1996/11/06 19:32:54 lilja Exp lilja $
   Locked version: $Revision: 1.798 $
*/

#include "AmiFTP.h"

STRPTR context[]=
{
    "MAIN",
    "MENUCONNECT",
    "MENUDISCONNECT",
    "MENURECONNECT",
    "MENUFTPCOMMAND",
    "MENUADDTOSITELIST",
    "MENURESETADT",
    "MENUICONIFY",
    "MENUABOUT",
    "MENUQUIT",
    "MENUTAGALL",
    "MENUUNTAGALL",
    "MENUPATTERNSELECT",
    "MENUTRANSFERMODE",
    "MENUCLEARCACHE",
    "MENUPARENT",
    "MENUPUT",
    "MENUGET",
    "MENUVIEW",
    "MENUVIEWREADME",
    "MENUCREATEDIR",
    "MENUDELETE",
    "MENURENAME",
    "MENUSORT",
    "MENUGLOBAL",
    "MENUSITELIST",
    "MENULOGWINDOW",
    "MENUSHOWDOTS",
    "MENUSHOWRECENT",
    "MENULOADSETTINGS",
    "MENUSAVESETTINGS",
    "MENUHOTLIST",
    "MAINWINDOW",
    "GLOBALPREFERENCES",
    "SITELIST",
    "SITECONFIGURATION",
    "TRANSFERWINDOW",
    "CONNECTWINDOW",
    "MAIN",
    NULL
};

int HandleAmigaGuide()
{
    struct AmigaGuideMsg *agm;

    if (AmigaGuideBase) {
	while (agm=GetAmigaGuideMsg(ag.ag_AmigaGuide)) {
	    switch (agm->agm_Type) {
	      case ActiveToolID:
		break;
	      case ToolCmdReplyID:
		if (agm->agm_Pri_Ret)
		  Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
		break;
	      case ShutdownMsgID:
		if (agm->agm_Pri_Ret)
		  Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
		break;
	      case ToolStatusID:
		if (agm->agm_Pri_Ret)
		  Printf("AmigaGuide error %s\n",GetAmigaGuideString(agm->agm_Sec_Ret));
		break;
	      default:
		break;
	    }
	    ReplyAmigaGuideMsg(agm);
	}
    }
    return 1;
}
extern ULONG AG_Signal;

int SendAGMessage(LONG ContextNumber)
{
    if (AmigaGuideBase) {
	if (!ag.ag_AmigaGuide) {
	    if (!(ag.ag_AmigaGuide=OpenAmigaGuideAsync(&ag.ag_NAG,NULL)))
	      return 0;
	    else {
		struct Msg *msg;
		AG_Signal=AmigaGuideSignal(ag.ag_AmigaGuide);
		Wait(AG_Signal);
		while (msg=GetAmigaGuideMsg(ag.ag_AmigaGuide))
		  ReplyAmigaGuideMsg(msg);
	    }
	}

	SendAmigaGuideCmd(ag.ag_AmigaGuide,NULL,
			  AGA_Context,ContextNumber,
			  TAG_DONE);
    }
    return 1;
}

