/** DoRev Header ** Do not edit! **
*
* Name   !         :  DropBox.c
* Copyrigit        :  Copyright 1993 Steve Anichini. All Rights Reserved.
* Creation date    :  11-Jun-93
* Translator       :  SAS/C 5.1b
*
* Date       Rev  Author               Comment
* ---------  ---  -------------------  ----------------------------------------
* 26-Jun-93    4  Steve Anichini       Split DropBox.c into DropBox.c and DropE
* 21-Jun-93    3  Steve Anichini       Added support for underscore in gadgets.
* 21-Jun-93    2  Steve Anichini       First Release.
* 12-Jun-93    1  Steve Anichini       Beta Release 1.0
* 11-Jun-93    0  Steve Anichini       None.
*
*** DoRev End **/


#include "DropBox.h"
#include "window.h"

#ifdef LATTICE
int CXBRK(void) { return(0);}
int chkabort(void) { return(0);}
#endif

struct Library *IFFParseBase;
struct Library *IconBase;
struct Library *WorkbenchBase;
struct Library *CxBase;
struct Library *GadToolsBase;
struct Library *UtilityBase;
struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase *GfxBase = NULL;

struct DiskObject *dobj = NULL;
struct MsgPort *myport = NULL, *brokerport = NULL;
struct AppIcon *appicon = NULL;
struct AppMenuItem *appitem = NULL;
CxObj *broker, *filter, *sender;

struct NewBroker mybroker =
{
	NB_VERSION,
	NULL,
	NULL,
	NULL,
	0,
	COF_SHOW_HIDE,
	NULL,
	0,
};

ULONG cxsigflag, apsigflag, winsigflag = 0;
BOOL end_flag = FALSE;
BOOL FirstSave = TRUE;
UBYTE **ttypes;
BOOL modified = FALSE;

struct GenPref MainPrefs =
{
	GPRF_VERSION,
	0,
	GFLG_NONE,
	0,50,
	640,100,
	{0,0,0}
};
	
/* Globals for SAS/C cback.o */
long _stack = 5120;
char *_procname = "DropBox";
long _priority = 0;
long _BackGroundIO = 0;

void InitLibraries()
{
	if(!(IntuitionBase = (struct IntuitionBase *)
			OpenLibrary("intuition.library", DEF_LOWEST_REV)))
		leave(NO_INTUILIB);
		
	if(!(GfxBase = (struct GfxBase *)
			OpenLibrary("graphics.library", DEF_LOWEST_REV)))
		leave(NO_GFXLIB);
		
	if(!(GadToolsBase = OpenLibrary("gadtools.library", DEF_LOWEST_REV)))
		leave(NO_GADLIB);
	
	if(!(UtilityBase = OpenLibrary("utility.library", DEF_LOWEST_REV)))
		leave(NO_UTILLIB);
			
	if(!(IconBase = OpenLibrary("icon.library", DEF_LOWEST_REV)))
		leave(NO_ICONLIB);
	
	if(!(WorkbenchBase = OpenLibrary("workbench.library", DEF_LOWEST_REV)))
		leave(NO_WORKLIB);

	if(!(CxBase = OpenLibrary("commodities.library", DEF_LOWEST_REV)))
		leave(NO_CXLIB);
}
	
void InitCX(int argc, char **argv)
{
	UBYTE *hotkey;
	
	/* Commodities Stuff */
	if(!(brokerport = CreateMsgPort()))
		leave(NO_PORT);
	
	mybroker.nb_Port = brokerport;
	cxsigflag = 1 << brokerport->mp_SigBit;
	
	/* Parse Args */
	ttypes = (UBYTE **) ArgArrayInit(argc, argv);
	
	mybroker.nb_Pri = (BYTE) ArgInt(ttypes, "CX_PRIORITY", 0);
	mybroker.nb_Name = NAME;
	mybroker.nb_Title = TITLE;
	mybroker.nb_Descr = DESC;
	
	hotkey = (UBYTE *) ArgString(ttypes, "HOTKEY", THEHOTKEY);
	 
	if(!(broker = CxBroker(&mybroker, NULL)))
		leave(NO_BROKER);
	
	if(!(filter = CxFilter(hotkey)))
		leave(NO_FILTER);
		
	AttachCxObj(broker, filter);

	if(!(sender = CxSender(brokerport, EVT_HOTKEY)))
		leave(NO_SENDER);
		
	AttachCxObj(filter, sender);
	
	if(CxObjError(filter))
		leave(NO_FILTER);
}

void InitIcons()
{
	UBYTE *menu;
	
	if(!(dobj = GetDiskObjectNew("DropBox")))
		leave(NO_ICON);

	dobj->do_Type = NULL;
	
	if(!(myport = CreateMsgPort()))
		leave(NO_PORT);
	
	apsigflag = 1 << myport->mp_SigBit;
	
	dobj->do_CurrentX = ArgInt(ttypes, "ICON_X", NO_ICON_POSITION);
	dobj->do_CurrentY = ArgInt(ttypes, "ICON_Y", NO_ICON_POSITION);
	
	if(!(appicon = AddAppIconA(0, 0, NAME,
			myport, NULL, dobj, NULL)))
		leave(NO_APPICON);

	menu = (UBYTE *) ArgString(ttypes, "APPMENU", "YES");
	if(!stricmp(menu, "YES"))
	{
		if(!(appitem = AddAppMenuItemA(1, 0, "DropBox...", myport,
				NULL)))
		leave(NO_APPITEM);
	}

	ActivateCxObj(broker, 1);
}

void initialize(int argc, char **argv)
{
	ULONG err = 0;
	UBYTE *popup;
	UBYTE *file, *dir = NULL, buf[DEFLEN];
	UBYTE *temp = NULL;
	struct DimensionInfo dinfo;
	LONG x, y;
	LONG pri;

	InitLibraries(); /* Open all required libraries */
	InitCX(argc, argv); 		 /* Add us!to the commodities broker list */

	pri = ArgInt(ttypes, "TASK_PRI",0); /* Get task priority tool type */
	if(pri)
		SetTaskPri(FindTask(NULL), pri);

	file = (UBYTE *) ArgString(ttypes, "PREFS", NULL);
	if(file)
	{
		strcpy(buf, file);
		temp = PathPart(buf);
		*temp = '\0';
		dir = buf;
		file = FilePart(file);
	}

	InitIO(file, dir, NULL); /* Init the filenames */
	if(err = JustLoad())
	{
		DisplayErr(err);
		CleanDB();
		InitDB();
	}
	else
		FirstSave = FALSE;
	InitIcons();

	if(!SetupScreen()) /* Set windows to be centered */
	{
		if(GetDisplayInfoData(NULL,(UBYTE *)&dinfo,
			sizeof(struct DimensionInfo),DTAG_DIMS,
			GetVPModeID(&(Scr->ViewPort))))
		{
			x = dinfo.Nominal.MaxX - dinfo.Nominal.MinX;
			y = dinfo.Nominal.MaxY - dinfo.Nominal.MinY;
			DropBoxLeft = (x- DropBoxWidth)/2;
			DropBoxTop = (y - DropBoxHeight)/2;
			SelectLeft = (x - SelectWidth)/2;
			SelectTop  = (y - SelectTop)/2;
		}

		CloseDownScreen();
	}

	popup = (UBYTE *) ArgString(ttypes, "CX_POPUP", "NO");
	if(!strnicmp(popup, "YES", 3))
		ShowWindow();
}

void CleanWindow(struct Window *win)
{
	struct IntuiMessage *imsg = NULL;

	while(imsg = GT_GetIMsg(win->UserPort))
		GT_ReplyIMsg(imsg);
}

void CleanApp()
{
	struct AppMessage *msg = NULL;
	
	while(msg = (struct AppMessage *)GetMsg(myport))
		ReplyMsg((struct Message *)msg);
}

struct MenuItem *GetItem(struct Menu *menu, UWORD mnum, UWORD inum)
{
	register struct MenuItem *temp = NULL;
	
	while(mnum && menu)
	{
	 	menu = menu->NextMenu;
		mnum--;
	}
	
	if(menu)
	{
		temp = menu->FirstItem;
		
		while(inum && temp)
		{
			temp = temp->NextItem;
			inum--;
		}
	}
	
	return temp;
}

void ExtractExt(char *ext, char *src, UWORD length)
{
	char *temp, *file;
	
	if(file = FilePart(src))
	{
		temp = strrchr(file, '.');
		if(temp)
		{
			strncpy(ext, "#?", length);
			strncat(ext, temp, length);
		}
		else
			strncpy(ext, "", length);
	}
	else
		strncpy(ext, "", length);	
}

void NewEntry(char *name)
{
	BOOL ans = FALSE;
	int error = 0;
	struct DBNode *temp;
	struct PatNode *ptemp;
	char ext[DEFLEN];
	
	struct EasyStruct new =
	{
		sizeof(struct EasyStruct),
		0,
		NULL,
		NULL,
		NULL
	};

	new.es_Title = ENTRY;
	new.es_TextFormat = ENTRYTEXTFORMAT;
	new.es_GadgetFormat = ENTRYGADGETFORMAT;
	
	ans = EasyRequest(DropBoxWnd, &new, 0);
		
	if(ans)
	{
		if(!DropBoxWnd)
			error = ShowWindow();

		if(!error)
		{
			if((temp = (struct DBNode *) NewNode(NT_DBNODE)) &&
			   (ptemp = (struct PatNode *) NewNode(NT_PATNODE)))
			{
				UpdateDB();
			
				GT_SetGadgetAttrs(DropBoxGadgets[GD_File_Types], 
					DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
					
				AddNode((struct Node *)temp,DataBase);
				
				GT_SetGadgetAttrs(DropBoxGadgets[GD_File_Types], DropBoxWnd, NULL, 
					GTLV_Labels, (ULONG) DataBase, TAG_END);	
				
				ExtractExt(ext,name, DEFLEN);
				FillPatNode(ptemp, ext, PFLG_NOFLAG);
				AddNode((struct Node *)ptemp, temp->db_Pats);
				
				UpdateDB();
				Select(temp);
				ActivateGadget(DropBoxGadgets[GD_Name], DropBoxWnd, NULL);
				
				modified = TRUE;
			
			}
			else
				DisplayErr(NO_MEM);
		}
		else
			DisplayErr(NO_WINDOW);		
	}
}

struct DBNode *PutUpSelection(struct List *found)
{
	ULONG oldflags;
	BOOL hide = FALSE, ok = FALSE;
	struct IntuiMessage *msg;
	struct Gadget *gad = NULL;
	ULONG class;
	UWORD code, select = 0;
	
	if(!Scr)
		if(SetupScreen())
			return (struct DBNode *)found->lh_Head;
	
	if(OpenSelectWindow())
	{
		if(!DropBoxWnd)
			CloseDownScreen();
			
		return (struct DBNode *)found->lh_Head;
	}
	
	if(DropBoxWnd)
	{
		oldflags = DropBoxWnd->IDCMPFlags;
		ModifyIDCMP(DropBoxWnd, NULL);
	}
		
	GT_SetGadgetAttrs(SelectGadgets[GD_SelectGad], SelectWnd, NULL, 
		GTLV_Labels, (ULONG) found, TAG_END);

	GT_SetGadgetAttrs(SelectGadgets[GD_SelectGad], SelectWnd, NULL,
		GTLV_Selected, select, TAG_END);
		
	while(!hide)
	{
		WaitPort(SelectWnd->UserPort);
		
		while(msg = GT_GetIMsg(SelectWnd->UserPort))
		{
			gad = (struct Gadget *) msg->IAddress;
			class = msg->Class;
			code = msg->Code;
			
			GT_ReplyIMsg(msg);
			
			switch(class)
			{
				case IDCMP_GADGETDOWN:
				case IDCMP_GADGETUP:
					if(gad == SelectGadgets[GD_Cancel])
					{
						hide = TRUE;
						ok = FALSE;
					}
					else
						if(gad == SelectGadgets[GD_Ok])
						{
							hide = TRUE;
							ok = TRUE;
						}
						else
							if(gad == SelectGadgets[GD_SelectGad])
								select = code;
					break;
				
				case IDCMP_REFRESHWINDOW:
					GT_BeginRefresh(SelectWnd);
					GT_EndRefresh(SelectWnd, TRUE);
					break;
			}
		}	
	}
	
	CloseSelectWindow();
	
	if(DropBoxWnd)
		ModifyIDCMP(DropBoxWnd, oldflags);

	if(ok)
		return (struct DBNode *) OrdToPtr(select, found);
	else
		return NULL;
}
 	
void ExecuteCommand(struct AppMessage *appmsg)
{
	char com[DEFLEN*2];
	struct DBNode *node = NULL;
	struct List *fnodes = NULL;
	BPTR con;
	register int i;
	ULONG err = NO_ERROR;
	
	for(i = 0; i < appmsg->am_NumArgs; i++)
		if(fnodes = FindDBNode(appmsg->am_ArgList[i].wa_Name))
		{
			if((MainPrefs.gp_Flags&GFLG_SELECTWIN)
				&& (CountNodes(fnodes) > 1))
				node = PutUpSelection(fnodes);
			else
				node = (struct DBNode *)fnodes->lh_Head;
			
			if(node)
			{
				if(err = CreateCommand(node, &appmsg->am_ArgList[i], com))
					DisplayErr(err);
				else
				{	
					char constr[DEFLEN];

					if(node->db_Flags & DFLG_SUPOUTPUT)
						strcat(com, " <nil: >nil: ");

					if(node->db_Flags & DFLG_CREATE)
					{
						struct DiskObject *dj;
						char dir[DEFLEN], *st;
						BPTR lock;

						lock = NULL;

						strcpy(dir, node->db_Dest);
						AddPart(dir, appmsg->am_ArgList[i].wa_Name,DEFLEN);
						st = strrchr(dir, '.');
						if(st)
							*st = '\0';
						lock = Lock(dir, ACCESS_READ);

						if(!lock)
							lock = CreateDir(dir);

						if(!lock)
							DisplayErr(NO_CREATEDIR);
						else
						{
							dj = NULL;

							if(MainPrefs.gp_Flags & GFLG_SAVEICON)
								if(dj = GetDefDiskObject(WBDRAWER))
								{
									PutDiskObject(dir, dj);
									FreeDiskObject(dj);
								}

							UnLock(lock);
						}
					}

					sprintf(constr, "CON:%d/%d/%d/%d/DropBox Output/SIMPLE",
						MainPrefs.gp_IOLeft, MainPrefs.gp_IOTop,
						max(MainPrefs.gp_IOWidth,80),
						max(MainPrefs.gp_IOHeight, 40));

					if(!(node->db_Flags & DFLG_SUPOUTPUT))
					{
						if(con = Open(constr, MODE_OLDFILE))
						{
							if(SystemTags(com, SYS_Input, (ULONG) con,
								SYS_Output, (ULONG) con, TAG_DONE))
								DisplayErr(STAGS_FAIL);
							Close(con);
						}
						else
							if(SystemTags(com,TAG_DONE))
								DisplayErr(STAGS_FAIL);
					}
					else
						if(SystemTags(com,TAG_DONE))
							DisplayErr(STAGS_FAIL);

				} // End else/CreateCommand()
			} // end If(node)

			CleanList(fnodes);
		}
		else
			NewEntry(appmsg->am_ArgList[i].wa_Name);
}

BOOL Safe(struct Window *wnd)
{
	LONG err = 0;

	struct EasyStruct safe =
	{
		sizeof(struct EasyStruct),
		0,
		NULL,
		NULL,
		NULL
	};
	
	safe.es_Title = SAFE;
	safe.es_TextFormat = SAFETEXTFORMAT;
	safe.es_GadgetFormat = SAFEGADGETFORMAT;
	
	switch(EasyRequest(wnd, &safe, 0))
	{
		case 0:
			return FALSE;
			
		case 1:
			return TRUE;
			
		case 2:
			if(FirstSave)
			{
				FirstSave = FALSE;
				PrefIO(TRUE);
			}
			else
				if(err = JustSave())
					DisplayErr(err);
				else
					modified = FALSE;
			return !modified;
	}
}

void HandleAppMsg()
{
	struct AppMessage *appmsg = NULL;
	
	while(appmsg = (struct AppMessage *)
			GetMsg(myport))
	{
		switch(appmsg->am_ID)
		{
			case APPICON:
				if(!appmsg->am_NumArgs)
					ShowWindow();
				else
					ExecuteCommand(appmsg);
				break;
			
			case APPMENU:
				ShowWindow();
				break;
		
			default:
				break;
		}
		
		ReplyMsg((struct Message *) appmsg);
	}
}

void HandleCxMsg()
{
	CxMsg *msg;
	ULONG msgid, msgtype;
	
	while(msg = (CxMsg *) GetMsg(brokerport))
	{
		msgid = CxMsgID(msg);
		msgtype = CxMsgType(msg);
		ReplyMsg((struct Message *) msg);
		
		switch(msgtype)
		{
			case CXM_IEVENT:
				switch(msgid)
				{
					case EVT_HOTKEY:
						ShowWindow();
						break;
		
					default:
						break;
				}
				break;
				
			case CXM_COMMAND:
				switch(msgid)
				{
					case CXCMD_APPEAR:
						ShowWindow();
						break;
					
					case CXCMD_DISAPPEAR:
						HideWindow();
						break;
						
					case CXCMD_DISABLE:
						ActivateCxObj(broker, 0);
						break;
					
					case CXCMD_ENABLE:
						ActivateCxObj(broker, 1);
						break;
						
					case CXCMD_KILL:
						if(modified)
						{
							if(Safe(DropBoxWnd))
								end_flag = TRUE;	
						}
						else
							end_flag = TRUE;
						break;
							
					default:
						break;
				}
		}
	}		
}
	
void loop()
{
	ULONG sigrcvd;
	
	sigrcvd = Wait(apsigflag|cxsigflag|winsigflag);
					
	if(sigrcvd&apsigflag)
		HandleAppMsg();
			
	if(sigrcvd&cxsigflag)
		HandleCxMsg();
		
	if((sigrcvd&winsigflag) && DropBoxWnd)
		HandleIntuiMsg();									
}

void CleanCX()
{
	struct AppMessage *appmsg = NULL;

	if(broker)
		DeleteCxObjAll(broker);
	
	if(appitem)
		RemoveAppMenuItem(appitem);
		
	if(appicon)
		RemoveAppIcon(appicon);
	
	if(brokerport)
	{
		while(appmsg=(struct AppMessage *)GetMsg(brokerport))
			ReplyMsg((struct Message *)appmsg);
		
		DeletePort(brokerport);
	}
	
	if(myport)
	{
		while(appmsg=(struct AppMessage *)GetMsg(myport))
			ReplyMsg((struct Message *)appmsg);
	
		DeleteMsgPort(myport);
	}
	
	if(dobj)
		FreeDiskObject(dobj);
	
	ArgArrayDone();
}
	
void CleanLibraries()
{
	if(CxBase)
		CloseLibrary(CxBase);
		
	if(WorkbenchBase)
		CloseLibrary(WorkbenchBase);
	
	if(IconBase)
		CloseLibrary(IconBase);

	if(GadToolsBase)
		CloseLibrary(GadToolsBase);
		
	if(GfxBase)
		CloseLibrary((struct Library *)GfxBase);
	
	if(IntuitionBase)
		CloseLibrary((struct Library *)IntuitionBase);
}

void leave(ULONG err)
{
	
	if(err)
		DisplayErr(err);
	
	if(Clip)
		FreeNode((struct Node *)Clip);
		
	if(DropBoxWnd)
	{
		CleanWindow(DropBoxWnd);
		CloseDropBoxWindow();
	}
	
	if(Scr)
		CloseDownScreen();
	
	CleanDB();
	CleanCX();
	CleanLibraries();
	
	OpenWorkBench();

	exit(err);
}

void DisplayErr(ULONG err)
{
	struct EasyStruct Errstruct = 
	{
		sizeof(struct EasyStruct),
		0,
		"DropBox Warning!",
		"Error:\n  %s\nDos Error:\n  %s",
		"OK"
	};
	
	struct AlertMessage MyAlert[] =
	{
		{0,14, "                            DropBox                        ", 0xFF},
		{0,24, "                             Alert                         ", 0xFF},
		{80,34,"                                                           ", 0x00}
	};
	LONG DosErr = 0;
	register WORD i;
	WORD temp;
	char Buffer[100];
	BOOL usealert = FALSE;
	
	DosErr = IoErr();
	if(DropBoxWnd)
	{
		DisplayBeep(Scr);
		if(DosErr <= 0)
		{
			Errstruct.es_TextFormat = (UBYTE *)"Error:\n  %s";
			(void)EasyRequest(DropBoxWnd, &Errstruct,NULL, error[err]);
		}
		else
		{
			Fault(DosErr, NULL, Buffer, 100);
			EasyRequest(DropBoxWnd, &Errstruct,NULL, error[err],
									 Buffer);
		}
	}
	else
	{
		if(!IntuitionBase)
		{
			if(IntuitionBase = (struct IntuitionBase *)
										OpenLibrary("intuition.library", 33))
				usealert = TRUE;
		}
		else
		{
			DisplayBeep(NULL);
			if(DosErr <= 0)
			{
				Errstruct.es_TextFormat = (UBYTE *)"Error:\n  %s";
				(void)EasyRequest(NULL, &Errstruct,NULL, error[err]);
			}
			else
			{
				Fault(DosErr, NULL, Buffer, 100);
				EasyRequest(NULL, &Errstruct,NULL, error[err],
									 Buffer);
			}
		}
								
		if(usealert)
		{
			strcpy(MyAlert[2].AlertText, error[err]);
			if((temp = strlen(MyAlert[2].AlertText)) < 59)
				for(i =0; i < 59-temp; i++)
					strcat(MyAlert[2].AlertText, " ");
			DisplayAlert(RECOVERY_ALERT, (UBYTE *) &MyAlert, 40);
		}
	
	}	
}

void main(int argc, char **argv)
{
	
	initialize(argc, argv);
	
	while(!end_flag)
		loop();
	
	leave(NO_ERROR);
}

