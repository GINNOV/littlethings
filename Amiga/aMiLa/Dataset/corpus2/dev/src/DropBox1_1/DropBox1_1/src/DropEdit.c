/** DoRev Header ** Do not edit! **
*
* Name             :  DropEdit.c
* Copyright        :  Copyright 1993 Steve Anichini. All Rights Reserved.
* Creation date    :  26-Jun-93
* Translator       :  SAS/C 5.1b
*
* Date       Rev  Author               Comment
* ---------  ---  -------------------  ----------------------------------------
* 15-Jul-93    2  Steve Anichini       Added editing of pattern list
* 26-Jun-93    1  Steve Anichini       Split DropBox.c into DropBox.c and DropE
* 26-Jun-93    0  Steve Anichini       Dummy
*
*** DoRev End **/

#include "DropBox.h"
#include "window.h"

struct DBNode *curnode = NULL;
struct PatNode *curpat = NULL;
struct DBNode *Clip = NULL;
UWORD LastSelected = 0;

void UpdateGadgets()
{
	struct Gadget *temp = NULL;
	
	if(curnode)
	{
		temp = FindGad(GD_Dest);
				
		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTST_String, 
			(ULONG) curnode->db_Dest, TAG_END);
			
		temp = FindGad(GD_Command);
				
		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTST_String,
			(ULONG) curnode->db_Com, TAG_END);
			
		temp = FindGad(GD_Template);
			
		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTST_String,
			(ULONG) curnode->db_Template, TAG_END);

		temp = FindGad(GD_Suppress);

		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTCB_Checked,
			(ULONG) !(curnode->db_Flags & DFLG_SUPOUTPUT), TAG_END);

		temp = FindGad(GD_Create);

		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTCB_Checked,
			(ULONG) curnode->db_Flags & DFLG_CREATE, TAG_END);

	}
	else
	{
		temp = FindGad(GD_Dest);

		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTST_String,
			(ULONG) "", TAG_END);

		temp = FindGad(GD_Command);

		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTST_String,
			(ULONG) "", TAG_END);

		temp = FindGad(GD_Template);

		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTST_String,
			(ULONG) "", TAG_END);

		temp = FindGad(GD_Suppress);

		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTCB_Checked,
			(ULONG) FALSE, TAG_END);

		temp = FindGad(GD_Create);

		GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTCB_Checked,
			(ULONG) FALSE, TAG_END);
	}
}

void UpdateDB()
{
	if(curnode)
	{
		if(stricmp(curnode->db_Dest, GetString(FindGad(GD_Dest))))
			modified = TRUE;

		strcpy(curnode->db_Dest, GetString(FindGad(GD_Dest)));

		if(stricmp(curnode->db_Com, GetString(FindGad(GD_Command))))
			modified = TRUE;

		strcpy(curnode->db_Com, GetString(FindGad(GD_Command)));

		if(stricmp(curnode->db_Template, GetString(FindGad(GD_Template))))
			modified = TRUE;

		strcpy(curnode->db_Template, GetString(FindGad(GD_Template)));
	}
}

int ShowWindow()
{
	struct Gadget *temp = NULL;

	if(!DropBoxWnd)
	{
		if(SetupScreen())
		{
			winsigflag = 0;

			return NO_WINDOW;
		}
		else
		{
			/* Set Save Icons State */
			DropBoxNewMenu[19].nm_Flags =
				(MainPrefs.gp_Flags&GFLG_SAVEICON)
				?(DropBoxNewMenu[19].nm_Flags|CHECKED)
				:(DropBoxNewMenu[19].nm_Flags&(~CHECKED));

			/* Set Auto Check State */
			DropBoxNewMenu[21].nm_Flags =
				(MainPrefs.gp_Flags&GFLG_CHECKCOM)
				?(DropBoxNewMenu[21].nm_Flags|CHECKED)
				:(DropBoxNewMenu[21].nm_Flags&(~CHECKED));

			/* Set Use Select State */
			DropBoxNewMenu[20].nm_Flags =
				(MainPrefs.gp_Flags&GFLG_SELECTWIN)
				?(DropBoxNewMenu[20].nm_Flags|CHECKED)
				:(DropBoxNewMenu[20].nm_Flags&(~CHECKED));

			if(OpenDropBoxWindow())
			{
				CloseDownScreen();

				winsigflag = 0;

				return NO_WINDOW;
			}
			else
			{
				DrawImage(DropBoxWnd->RPort, &logoimage, 319, 125);

				ModifyIDCMP(DropBoxWnd, DropBoxWnd->IDCMPFlags|IDCMP_VANILLAKEY);

				winsigflag = 1<<(DropBoxWnd->UserPort->mp_SigBit);

				curnode = NULL;
				curpat = NULL;
				temp = FindGad(GD_File_Types);

				GT_SetGadgetAttrs(temp, DropBoxWnd, NULL, GTLV_Labels,
					(ULONG) DataBase, TAG_END);

				UpdateGadgets();

				return NO_ERROR;
			}
		}
	}
	else
	{
		WindowToFront(DropBoxWnd);

		if(ActivateWindow(DropBoxWnd))
			DisplayBeep(NULL);
	}

	return NO_ERROR;
}

void HideWindow()
{
	if(DropBoxWnd)
	{
        DropBoxLeft = DropBoxWnd->LeftEdge;
		DropBoxTop  = DropBoxWnd->TopEdge;
		CleanWindow(DropBoxWnd);
		CloseDropBoxWindow();
	}

	if(Scr)
		CloseDownScreen();

	winsigflag = 0;
}

void SizeIOWindow()
{
	ULONG oldflags;
	struct Window *sizewnd = NULL;

	oldflags = DropBoxWnd->IDCMPFlags;
	ModifyIDCMP(DropBoxWnd, NULL);

	if(sizewnd = OpenWindowTags(NULL,
		WA_Left, MainPrefs.gp_IOLeft, WA_Top,  MainPrefs.gp_IOTop,
		WA_Width, max(MainPrefs.gp_IOWidth,80),
		WA_Height, max(MainPrefs.gp_IOHeight,40),
		WA_MinWidth, 80, WA_MinHeight, 40, WA_MaxWidth, ~0,WA_MaxHeight, ~0,
		WA_DragBar, TRUE, WA_CloseGadget, TRUE, WA_SmartRefresh, TRUE,
		WA_NoCareRefresh, TRUE, WA_IDCMP, IDCMP_CLOSEWINDOW,
		WA_Title, (ULONG) IOTITLE, WA_PubScreen, (ULONG) Scr,
		WA_AutoAdjust, TRUE, WA_SizeGadget, TRUE, WA_DepthGadget, TRUE,
		WA_Activate, TRUE, TAG_END))
	{
		struct IntuiMessage *msg;
		BOOL done = FALSE;

		while(!done)
		{
			WaitPort(sizewnd->UserPort);

			while(!done && (msg = (struct IntuiMessage *)
				GetMsg(sizewnd->UserPort)))
			{
				if(msg->Class = IDCMP_CLOSEWINDOW)
					done = TRUE;

				ReplyMsg((struct Message *)msg);
			}
		}

		MainPrefs.gp_IOLeft = sizewnd->LeftEdge;
		MainPrefs.gp_IOTop  = sizewnd->TopEdge;
		MainPrefs.gp_IOWidth = sizewnd->Width;
		MainPrefs.gp_IOHeight = sizewnd->Height;
		modified = TRUE;

		CloseWindow(sizewnd);
	}

	ModifyIDCMP(DropBoxWnd, oldflags);

}

void SelectPat(struct PatNode *nd)
{
	curpat = nd;

	if(curpat && curnode)
	{
		LastSelected = NT_PATNODE;

		GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd, NULL,
			GTLV_Selected,
			(ULONG) PtrToOrd((struct Node *)curpat, curnode->db_Pats),
			TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Pattern), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Pat_Del), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Pat_Ins), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);

		if(curpat != (struct PatNode *) curnode->db_Pats->lh_Head)
			OnMenu(DropBoxWnd, FULLMENUNUM(1,4,0));
		else
			OffMenu(DropBoxWnd, FULLMENUNUM(1,4,0));
		if(curpat != (struct PatNode *) curnode->db_Pats->lh_TailPred)
			OnMenu(DropBoxWnd, FULLMENUNUM(1,5,0));
		else
			OffMenu(DropBoxWnd, FULLMENUNUM(1,5,0));

	}
	else
	{
		if(curnode)
		{
			LastSelected = NT_DBNODE;

			if(curnode != (struct DBNode *) DataBase->lh_Head)
				OnMenu(DropBoxWnd, FULLMENUNUM(1,4,0));
			else
				OffMenu(DropBoxWnd, FULLMENUNUM(1,4,0));
			if(curnode != (struct DBNode *) DataBase->lh_TailPred)
				OnMenu(DropBoxWnd, FULLMENUNUM(1,5,0));
			else
				OffMenu(DropBoxWnd, FULLMENUNUM(1,5,0));
		}

		GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd, NULL,
			GTLV_Selected, (ULONG) ~0,TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Pattern), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Pat_Del), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Pat_Ins), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
	}
}

void Select(struct DBNode *nd)
{
	curnode = nd;
	UpdateGadgets();

	if(curnode)
	{
		LastSelected = NT_DBNODE;

		GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd, NULL,
			GTLV_Labels, (ULONG) curnode->db_Pats, TAG_END);

		SelectPat(NULL);

		GT_SetGadgetAttrs(FindGad(GD_Pat_Add), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_File_Types),DropBoxWnd, NULL,
			GTLV_Selected, (ULONG) PtrToOrd((struct Node *)curnode,DataBase),
			TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Delete), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Insert), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Name), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Pat_Add), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Dest), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		/* GT_SetGadgetAttrs(FindGad(GD_DestGet), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END); Doesn't Support */
		GT_SetGadgetAttrs(FindGad(GD_Command), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		/* GT_SetGadgetAttrs(FindGad(GD_ComGet), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END); Doesn't support */
		GT_SetGadgetAttrs(FindGad(GD_Template), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Suppress), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Create), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) FALSE, TAG_END);

		if(curnode != (struct DBNode *) DataBase->lh_Head)
			OnMenu(DropBoxWnd, FULLMENUNUM(1,4,0));
		else
			OffMenu(DropBoxWnd, FULLMENUNUM(1,4,0));

		if(curnode != (struct DBNode *) DataBase->lh_TailPred)
			OnMenu(DropBoxWnd, FULLMENUNUM(1,5,0));
		else
			OffMenu(DropBoxWnd, FULLMENUNUM(1,5,0));

		OnMenu(DropBoxWnd, FULLMENUNUM(1, 0, 0));
		OnMenu(DropBoxWnd, FULLMENUNUM(1, 1, 0));
		if(Clip)
			OnMenu(DropBoxWnd, FULLMENUNUM(1,2,0));
		else
			OffMenu(DropBoxWnd, FULLMENUNUM(1,2,0));
	}
	else
	{
		LastSelected = 0;

		SelectPat(NULL);

		GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd, NULL,
			GTLV_Labels, (ULONG) NULL, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Delete), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Insert), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Name), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Name), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Pat_Add), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Dest), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		/*GT_SetGadgetAttrs(FindGad(GD_DestGet), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);*/
		GT_SetGadgetAttrs(FindGad(GD_Command), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
/*		GT_SetGadgetAttrs(FindGad(GD_ComGet), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);*/
		GT_SetGadgetAttrs(FindGad(GD_Template), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Suppress), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_Create), DropBoxWnd, NULL,
			GA_Disabled, (ULONG) TRUE, TAG_END);
		GT_SetGadgetAttrs(FindGad(GD_File_Types),
			DropBoxWnd, NULL, GTLV_Selected, (ULONG) ~0, TAG_END);
		OffMenu(DropBoxWnd, FULLMENUNUM(1, 4, 0));
		OffMenu(DropBoxWnd, FULLMENUNUM(1, 5, 0));
		OffMenu(DropBoxWnd, FULLMENUNUM(1, 0, 0));
		OffMenu(DropBoxWnd, FULLMENUNUM(1, 1, 0));
		OffMenu(DropBoxWnd, FULLMENUNUM(1, 2, 0));
	}
}

void HandleGadget(struct Gadget *gad, UWORD code)
{
	struct DBNode *temp = NULL;
	struct PatNode *temp2 = NULL;
	ULONG err = 0;
	char tc[DEFLEN];

	if(gad == FindGad(GD_File_Types))
	{
		UpdateDB();
		Select((struct DBNode *)OrdToPtr(code,DataBase));
	}

	if(gad == FindGad(GD_Pat_View))
		if(curnode)
			SelectPat((struct PatNode *)OrdToPtr(code,curnode->db_Pats));

	if(gad == FindGad(GD_Add))
		if(temp = (struct DBNode *) NewNode(NT_DBNODE))
		{
			UpdateDB();

			GT_SetGadgetAttrs(FindGad(GD_File_Types),
				DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);

			AddNode((struct Node *)temp, DataBase);

			GT_SetGadgetAttrs(FindGad(GD_File_Types), DropBoxWnd, NULL, GTLV_Labels,
				(ULONG) DataBase, TAG_END);

			Select(temp);
			ActivateGadget(FindGad(GD_Name), DropBoxWnd, NULL);

			modified = TRUE;
		}
		else
			DisplayErr(NO_MEM);

	if(gad == FindGad(GD_Pat_Add))
		if(curnode)
			if(temp2 = (struct PatNode *) NewNode(NT_PATNODE))
			{
				GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd, NULL, 
					GTLV_Labels, (ULONG) ~0, TAG_END);
					
				AddNode((struct Node *)temp2, curnode->db_Pats);
				
				GT_SetGadgetAttrs(FindGad(GD_Pat_View),DropBoxWnd, NULL, 
					GTLV_Labels, (ULONG) curnode->db_Pats, TAG_END);  
					
				SelectPat(temp2);
				ActivateGadget(FindGad(GD_Pattern), DropBoxWnd, NULL);
				
				modified = TRUE;
			}
			else
				DisplayErr(NO_MEM);
		
	if(gad == FindGad(GD_Insert))
		if(temp = (struct DBNode *) NewNode(NT_DBNODE))
		{
			UpdateDB();
			
			GT_SetGadgetAttrs(FindGad(GD_File_Types), 
				DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
				
			InsertNode((struct Node *)temp, (struct Node *)curnode,DataBase);

			GT_SetGadgetAttrs(FindGad(GD_File_Types), DropBoxWnd, NULL, GTLV_Labels, 
				(ULONG) DataBase, TAG_END);
						
			Select(temp);
			ActivateGadget(FindGad(GD_Name), DropBoxWnd, NULL);
			
			modified = TRUE;
		}
		else
			DisplayErr(NO_MEM);

	if(gad == FindGad(GD_Pat_Ins))
		if(curnode)
			if(temp2 = (struct PatNode *) NewNode(NT_PATNODE))
			{
				GT_SetGadgetAttrs(FindGad(GD_Pat_View), 
					DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
				
				InsertNode((struct Node *)temp2, 
					(struct Node *)curpat,curnode->db_Pats);

				GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd, NULL, 
					GTLV_Labels, (ULONG) curnode->db_Pats, TAG_END);
						
				SelectPat(temp2);
				ActivateGadget(FindGad(GD_Pattern), DropBoxWnd, NULL);
			
				modified = TRUE;
			}
			else
				DisplayErr(NO_MEM);
								
	if(gad == FindGad(GD_Delete))
		if(curnode)
		{
			GT_SetGadgetAttrs(FindGad(GD_File_Types), 
				DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
			
			temp = curnode;
			if((struct Node *) temp == DataBase->lh_Head)
				curnode = (struct DBNode *) temp->db_Nd.ln_Succ;
			else
				curnode = (struct DBNode *) temp->db_Nd.ln_Pred;
			if(temp = (struct DBNode *)RemoveNode((struct Node *)temp,DataBase))
				FreeNode((struct Node *)temp);
			
			if(IsEmpty(DataBase))
				curnode = NULL;
						
			GT_SetGadgetAttrs(FindGad(GD_File_Types),
				DropBoxWnd, NULL, GTLV_Labels, (ULONG) DataBase, TAG_END);

			Select(curnode);

			modified = TRUE;
		}

	if(gad == FindGad(GD_Pat_Del))
		if(curnode)
			if(curpat)
			{
				GT_SetGadgetAttrs(FindGad(GD_Pat_View),DropBoxWnd,
					NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
					
				temp2 = curpat;
				
				if((struct Node *) temp2 == curnode->db_Pats->lh_Head)
					curpat = (struct PatNode *) temp2->pat_Nd.ln_Succ;
				else
					curpat = (struct PatNode *) temp2->pat_Nd.ln_Pred;
					
				if(temp2 = (struct PatNode *)RemoveNode((struct Node *)temp2,
					curnode->db_Pats))
					FreeNode((struct Node *)temp2);
					
				if(IsEmpty(curnode->db_Pats))
					curpat = NULL;
					
				GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd,
					NULL, GTLV_Labels, (ULONG) curnode->db_Pats, TAG_END);
					
				SelectPat(curpat);
				
				modified = TRUE;
			}
			
	if(gad == FindGad(GD_Sort))
	{
		GT_SetGadgetAttrs(FindGad(GD_File_Types),
			DropBoxWnd, NULL, GTLV_Labels, (ULONG) NULL, TAG_END);
						
		if(err = Sort(&DataBase))
			DisplayErr(err);

		GT_SetGadgetAttrs(FindGad(GD_File_Types),
			DropBoxWnd, NULL, GTLV_Labels, (ULONG) DataBase, TAG_END);

		Select(NULL);

		modified = TRUE;
	}
						
	if(gad == FindGad(GD_Name))
		if(curnode)
		{
			GT_SetGadgetAttrs(FindGad(GD_File_Types),
				DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
						
			if(stricmp(curnode->db_Name, GetString(gad)))
				modified = TRUE;
				
			strcpy(curnode->db_Name, GetString(gad));
			
			GT_SetGadgetAttrs(FindGad(GD_File_Types),
				DropBoxWnd, NULL, GTLV_Labels, (ULONG) DataBase, TAG_END);
		}
						
	if(gad == FindGad(GD_Pattern))
		if(curpat && curnode)
		{
			GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd, NULL,
				GTLV_Labels, (ULONG) ~0, TAG_END);
				
			if(stricmp(curpat->pat_Str, GetString(gad)))
				modified = TRUE;
			
			strcpy(curpat->pat_Str, GetString(gad));
			
			GT_SetGadgetAttrs(FindGad(GD_Pat_View), DropBoxWnd, NULL,
				GTLV_Labels, (ULONG) curnode->db_Pats, TAG_END);
		}
		
	if(gad == FindGad(GD_Dest))
		if(curnode)
		{
			if(stricmp(curnode->db_Dest, GetString(gad)))
				modified = TRUE;

			strcpy(curnode->db_Dest, GetString(gad));
		}
		
	if(gad == FindGad(GD_DestGet))
	{
		strcpy(tc, GetString(FindGad(GD_Dest)));
		GetDest(tc);
		
		if(stricmp(tc, GetString(FindGad(GD_Dest))))
			modified = TRUE;
			
		GT_SetGadgetAttrs(FindGad(GD_Dest), DropBoxWnd, NULL,
			GTST_String, (ULONG) tc, TAG_END);
		
		UpdateDB();
	}
	
	if(gad == FindGad(GD_ComGet))
	{
		strcpy(tc, GetString(FindGad(GD_Command)));
		GetCom(tc);
		
		if(stricmp(tc, GetString(FindGad(GD_Command))))
			modified = TRUE;
			
		GT_SetGadgetAttrs(FindGad(GD_Command), DropBoxWnd, NULL,
			GTST_String, (ULONG) tc, TAG_END);
		UpdateDB();
	}

	if(gad == FindGad(GD_Command))
		if(curnode)
			if(stricmp(curnode->db_Com, GetString(gad)))
			{
				modified = TRUE;
				strcpy(curnode->db_Com, GetString(gad));
			}

	if(gad == FindGad(GD_Template))
		if(curnode)
			if(stricmp(curnode->db_Template, GetString(gad)))
			{
				char com[DEFLEN*2];
				struct WBArg targ;
				struct Process *myproc;

				modified = TRUE;
				strcpy(curnode->db_Template, GetString(gad));

				if(MainPrefs.gp_Flags & GFLG_CHECKCOM)
				{
					myproc = (struct Process *) FindTask(NULL);

					targ.wa_Lock = myproc->pr_CurrentDir;
					targ.wa_Name = "Bob";


                    if(err = CreateCommand(curnode, &targ, com))
					{
						DisplayErr(err);
						ActivateGadget(gad, DropBoxWnd, NULL);
					}

                }

			}

	if(gad == FindGad(GD_Suppress))
		if(curnode)
		{
			curnode->db_Flags = ToggleFlag(curnode->db_Flags,DFLG_SUPOUTPUT);
			modified = TRUE;
		}

	if(gad == FindGad(GD_Create))
		if(curnode)
		{
			curnode->db_Flags = ToggleFlag(curnode->db_Flags, DFLG_CREATE);
			modified = TRUE;
		}
}

void DisplayAbout()
{
	struct EasyStruct about =
	{
		sizeof(struct EasyStruct),
		0,
		NULL,
		NULL,
		NULL
	};

	about.es_Title = ABOUT;
	about.es_TextFormat = TEXTFORMAT;
	about.es_GadgetFormat = GADGETFORMAT;

	EasyRequest(DropBoxWnd, &about, 0);

}

BOOL DisplayNewWarning()
{
	struct EasyStruct new =
	{
		sizeof(struct EasyStruct),
		0,
		NULL,
		NULL,
		NULL
	};

	new.es_Title = NEW;
	new.es_TextFormat = NEWTEXTFORMAT;
	new.es_GadgetFormat = NEWGADGETFORMAT;

	return EasyRequest(DropBoxWnd, &new, 0);
}

BOOL HandleMenu(ULONG menunum, ULONG itemnum, ULONG subnum)
{
	struct DBNode *temp = NULL;
	struct PatNode *temp2 = NULL;
	ULONG err;
	BOOL hide = FALSE;

	switch(menunum)
	{
		case 0:
			switch(itemnum)
			{
				case 0: /* New */
					if(DisplayNewWarning())
					{
						GT_SetGadgetAttrs(FindGad(GD_File_Types),
							DropBoxWnd, NULL, GTLV_Labels, NULL, TAG_END);

						CleanDB();
						InitDB();
						InitIO(NULL, NULL, NULL);

						modified = FALSE;
						FirstSave = TRUE;

						GT_SetGadgetAttrs(FindGad(GD_File_Types), DropBoxWnd, NULL, GTLV_Labels,
							(ULONG) DataBase, TAG_END);

						Select(NULL);
					}
					break;

				case 2: /* Open */
					if(modified)
						modified = !Safe(DropBoxWnd);

					if(!modified)
					{
						GT_SetGadgetAttrs(FindGad(GD_File_Types),
							DropBoxWnd, NULL, GTLV_Labels, NULL, TAG_END);

						FirstSave = FALSE;

						ClearMenuStrip(DropBoxWnd);

						PrefIO(FALSE);

						ResetMenuStrip(DropBoxWnd, DropBoxMenus);

						GT_SetGadgetAttrs(FindGad(GD_File_Types), DropBoxWnd, NULL, GTLV_Labels,
							(ULONG) DataBase, TAG_END);

						Select(NULL);
					}
					break;

				case 3: /* Save */
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
					break;
						
				case 4: /* Save as... */
					if(FirstSave)
						FirstSave = FALSE;
					PrefIO(TRUE);
					break;
								
				case 6: /* About */
					DisplayAbout();
					break;
							
				case 8: /* Hide */
					hide = TRUE;
					break;
									
				case 9: /* Quit */
					if(modified)
					{
						if(Safe(DropBoxWnd))
						{
							hide = TRUE;
							end_flag = TRUE;
						}
					}
					else
					{
						hide = TRUE;
						end_flag = TRUE;
					}
					break;
			} /* Project Menu Switch */
			break;
							
		case 1: /* Edit Menu */
			switch(itemnum)
			{
				case 0: /* Cut */
					if(curnode)
					{
						FreeNode((struct Node *)Clip);
						Clip = NULL;
						
						GT_SetGadgetAttrs(FindGad(GD_File_Types),
							DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
						
						Clip = curnode;
						if((struct Node *) Clip == DataBase->lh_Head)
							curnode = (struct DBNode *) Clip->db_Nd.ln_Succ;
						else
							curnode = (struct DBNode *) Clip->db_Nd.ln_Pred;
							
						Clip = (struct DBNode *)RemoveNode((struct Node *)Clip,DataBase);
							
						if(IsEmpty(DataBase))
							curnode = NULL;
				
						GT_SetGadgetAttrs(FindGad(GD_File_Types),
							DropBoxWnd, NULL, GTLV_Labels, (ULONG) DataBase, TAG_END);
							
						Select(curnode);
								
						OnMenu(DropBoxWnd, FULLMENUNUM(1,2,0));
									
						modified = TRUE;
					}
					break;
								
				case 1: /* Copy */
					if(curnode)
					{
						if(Clip)
							FreeNode((struct Node *)Clip);
						Clip = NULL;
							
						if(Clip = (struct DBNode *)NewNode(NT_DBNODE))
						{ 
							CopyDBNode(Clip, curnode);
							OnMenu(DropBoxWnd, FULLMENUNUM(1,2,0));
						}
						else
							DisplayErr(NO_MEM);
					}
					break;
					
				case 2: /* Paste */
					if(curnode)
					{
						GT_SetGadgetAttrs(FindGad(GD_File_Types),
							DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
							
						CopyDBNode(curnode, Clip);
						
						GT_SetGadgetAttrs(FindGad(GD_File_Types),
							DropBoxWnd, NULL, GTLV_Labels, (ULONG) DataBase, TAG_END);
						UpdateGadgets();
						
						modified = TRUE;
					}
					break;
								
				case 4: /* Up */
					if(LastSelected == NT_DBNODE)
					{
						if(curnode && (curnode != (struct DBNode *) DataBase->lh_Head))
						{
							GT_SetGadgetAttrs(FindGad(GD_File_Types),
								DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
			
							temp = (struct DBNode *)curnode->db_Nd.ln_Pred;
							RemoveNode((struct Node *)curnode, DataBase);
							InsertNode((struct Node *)curnode, (struct Node *)temp,DataBase);
	
							GT_SetGadgetAttrs(FindGad(GD_File_Types),
								DropBoxWnd, NULL, GTLV_Labels, (ULONG) DataBase, TAG_END);
			
							Select(curnode);
		
							modified = TRUE;
						}
					}
					else
						if(LastSelected == NT_PATNODE)
						if(curnode)
							if(curpat && (curpat != (struct PatNode *) curnode->db_Pats->lh_Head))
							{
								GT_SetGadgetAttrs(FindGad(GD_Pat_View),
									DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, 
									TAG_END);
			
								temp2 = (struct PatNode *)
									curpat->pat_Nd.ln_Pred;
							
								RemoveNode((struct Node *)curpat, 
									curnode->db_Pats);
								InsertNode((struct Node *)curpat, 
									(struct Node *)temp2,curnode->db_Pats);
	
								GT_SetGadgetAttrs(FindGad(GD_Pat_View),
									DropBoxWnd, NULL, GTLV_Labels, 
									(ULONG) curnode->db_Pats, TAG_END);
			
								SelectPat(curpat);
		
								modified = TRUE;
							}
					break;
								
				case 5: /* Down */
					if(LastSelected == NT_DBNODE)
					{
						if(curnode && (curnode != (struct DBNode *) DataBase->lh_TailPred))
						{
							GT_SetGadgetAttrs(FindGad(GD_File_Types),
								DropBoxWnd, NULL, GTLV_Labels, (ULONG) ~0, TAG_END);
				
							temp = (struct DBNode *)curnode->db_Nd.ln_Succ;
							RemoveNode((struct Node *)curnode,DataBase);
							Insert(DataBase, (struct Node *)curnode,(struct Node *) temp);
			
							GT_SetGadgetAttrs(FindGad(GD_File_Types),
								DropBoxWnd, NULL, GTLV_Labels, (ULONG) DataBase, TAG_END);
		
							Select(curnode);
		
							modified = TRUE;	
						}
					}
					else
						if(LastSelected == NT_PATNODE)
							if(curnode)
								if(curpat && (curpat != (struct PatNode *) 
									curnode->db_Pats->lh_TailPred))
								{
									GT_SetGadgetAttrs(FindGad(GD_Pat_View),
										DropBoxWnd, NULL, GTLV_Labels, 
										(ULONG) ~0, TAG_END);
				
									temp2 = (struct PatNode *)
										curpat->pat_Nd.ln_Succ;
									RemoveNode((struct Node *)curpat,
										curnode->db_Pats);
									Insert(curnode->db_Pats, 
										(struct Node *)curpat,
										(struct Node *) temp2);
			
									GT_SetGadgetAttrs(FindGad(GD_Pat_View),
										DropBoxWnd, NULL, GTLV_Labels, 
										(ULONG) curnode->db_Pats, TAG_END);
		
									SelectPat(curpat);
		
									modified = TRUE;	
								}
					break;
					
			} /* Edit Menu Switch */
			break;
			
		case 2: /* Options Menu */
			switch(itemnum)
			{
				case 0: /* Save Icons */
					MainPrefs.gp_Flags = 
						StatusCheck(GetItem(DropBoxMenus, 2, 0),
							MainPrefs.gp_Flags, GFLG_SAVEICON);
					modified = TRUE;
					break;
					
				case 1: /* Use Select Window */
					MainPrefs.gp_Flags =
						StatusCheck(GetItem(DropBoxMenus, 2,1),
							MainPrefs.gp_Flags, GFLG_SELECTWIN);
					modified = TRUE;
					break;
							
				case 2: /* Auto-Check */
					MainPrefs.gp_Flags = 
						StatusCheck(GetItem(DropBoxMenus,2,2),
							MainPrefs.gp_Flags, GFLG_CHECKCOM); 
					modified = TRUE;
					break;
				
				case 4: /* Size input/output window */
					SizeIOWindow();
					break;
					
			}
			break;
				
	} /* Menu Switch */
	
	return hide;
}

void HandleIntuiMsg()
{
	struct IntuiMessage *imsg = NULL;
	struct Gadget *gad = NULL;
	ULONG class;
	UWORD code, index;
	BOOL hide = FALSE;
	char temp[2];
	
	temp[1] = '\0';
	
	while(imsg = GT_GetIMsg(DropBoxWnd->UserPort))
	{
		gad = (struct Gadget *) imsg->IAddress;
		class = imsg->Class;
		code = imsg->Code;
		
		GT_ReplyIMsg(imsg);
		
		switch(class)
		{
			case IDCMP_VANILLAKEY:
				temp[0] = (UBYTE)code;
				for(index = 0; index < GLU_NUM; index++)
					if(!strnicmp(temp,(char *) glu[index].gl_Key,1))
					{
						HandleGadget(FindGad(glu[index].gl_Gad),0);
						break;
					}
				break;
				
			case IDCMP_GADGETDOWN:
			case IDCMP_GADGETUP:
				HandleGadget(gad, code);
				break;
				
			case IDCMP_CLOSEWINDOW:
				hide = TRUE;
				break;
			
			case IDCMP_REFRESHWINDOW:
				GT_BeginRefresh(DropBoxWnd);
				DrawImage(DropBoxWnd->RPort, &logoimage, 319, 125);
				GT_EndRefresh(DropBoxWnd, TRUE);
				break;
		
			case IDCMP_MENUPICK:
				if(code != MENUNULL)
					hide = HandleMenu(MENUNUM(code),ITEMNUM(code),SUBNUM(code));
		}
	}
	if(hide)
		HideWindow();
}
