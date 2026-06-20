/*
 *	File:					Menu.c
 *	Description:	A set of functions to manipulate menus.
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef	MENUFUNCTIONS_C
#define	MENUFUNCTIONS_C

/*** DEFINES *************************************************************************/
#define every_node	node=list->lh_Head;node->ln_Succ;node=node->ln_Succ

/*** FUNCTIONS ***********************************************************************/
__asm __saveds struct MenuItem *egFindMenuItem(	register __a0 struct Menu *mymenu,
																								register __d0 ULONG idcmp)
{
	register struct Menu			*menu;
	register struct MenuItem	*item, *sub;

#ifdef MYDEBUG_H
	DebugOut("egFindMenuItem");
#endif

	for(menu=mymenu; menu!=NULL; menu=menu->NextMenu)
		for(item=menu->FirstItem; item!=NULL; item=item->NextItem)
		{
			for(sub=item->SubItem; sub!=NULL; sub=sub->NextItem)
				if(GTMENUITEM_USERDATA(sub)==(APTR)idcmp)
					return sub;
			if(GTMENUITEM_USERDATA(item)==(APTR)idcmp)
				return item;
		}
	return NULL;
}

__asm __saveds BYTE egIsMenuItemChecked(register __a0 struct Menu *menu,
																				register __d0 ULONG idcmp)
{
	register struct MenuItem	*item=egFindMenuItem(menu, idcmp);

#ifdef MYDEBUG_H
	DebugOut("egIsMenu_ItemChecked");
#endif

	if(item)
		if(ISBITSET(item->Flags, CHECKED))
			return TRUE;
	return FALSE;
}

__asm __saveds void egSetMenuBitA(register __a0 struct Window	*window,
																	register __a1 struct Menu		*menu,
																	register __d0 ULONG					bit,
																	register __d1 ULONG					*array)
{
#ifdef MYDEBUG_H
	DebugOut("egSetMenuBitA");
#endif


	if(menu)
	{
		register struct MenuItem	*item;
		register int	i=0;

		if(window)
			ClearMenuStrip(window);

		while(array[i])
			if(item=egFindMenuItem(menu, array[i++]))
				IFTRUESETBIT(array[i++], item->Flags, bit);

		if(window)
			ResetMenuStrip(window, menu);
	}
}
/*
__asm __saveds void egSetMenuItem(register __a0 struct NewMenu	*menuitem,
																	register __d0 UBYTE						type,
																	register __a1 STRPTR					label,
																	register __d1 UWORD						flags,
																	register __d2 LONG						exclude,
																	register __a2 APTR						userdata)
{
	if(label==NM_BARLABEL)
	{
		menuitem->nm_Label	=label;
		menuitem->nm_CommKey=NULL;
	}
	else if(*label!=' ' && *(label+1)=='\0')
	{
		menuitem->nm_Label	=label+2;
		menuitem->nm_CommKey=label;
	}
	else
	{
		menuitem->nm_Label	=label;
		menuitem->nm_CommKey=NULL;
	}
	menuitem->nm_Type					=type;
	menuitem->nm_Flags				=flags;
	menuitem->nm_MutualExclude=exclude;
	menuitem->nm_UserData			=userdata;
}					
*/

#define	EG_MENUBORDER	20

__asm __saveds void egMakeHelpMenu(	register __a0 struct Menu		*menu,
																		register __a1 struct Screen	*screen)
{
	if(menu)
	{
		register struct Menu *m=menu;
		register struct MenuItem *item;
		register UWORD itemwidth=0;

		while(m->NextMenu)
			m=m->NextMenu;

		m->LeftEdge=screen->Width-TextLength(&(screen->RastPort), m->MenuName, StrLen(m->MenuName))-EG_MENUBORDER;

		for(item=m->FirstItem; item; item=item->NextItem)
			itemwidth=MAX(itemwidth, item->Width);

		for(item=m->FirstItem; item; item=item->NextItem)
			item->LeftEdge-=itemwidth-m->Width;
	}
}

__asm __saveds struct Menu *egCreateMenuA(register __a0 int *menudata)
{
	register struct Menu		*menu=NULL;
	register ULONG					i=0L, num, count=0L;

	while(menudata[i]!=NM_END)
	{
		if(menudata[i]==EG_LIST | menudata[i]==EG_SUBLIST)
			count+=egCountList((struct List *)menudata[i+1]);
		i+=5;
	}

	if(num=i/5+count)
	{
		register struct NewMenu *newmenu;

		if(newmenu=(struct NewMenu *)AllocVec(sizeof(struct NewMenu)*(num+1), MEMF_CLEAR))
		{
			register ULONG item=0L;

			i=0L;
			while(menudata[i]!=NM_END)
			{
				if(menudata[i]==NM_IGNORE)
					i+=4;
				else if(menudata[i]==EG_LIST | menudata[i]==EG_SUBLIST)
				{
					register struct Node	*node;
					UBYTE									type		=(menudata[i]==EG_LIST ? NM_ITEM:NM_SUB);
					register struct List	*list		=(struct List *)menudata[++i];
					UWORD 								flags		=(UWORD)menudata[++i];
					LONG									mx			=(LONG)menudata[++i];
					register ULONG				base		=(ULONG)menudata[++i];

					if(list)
						for(every_node)
						{
							newmenu[item].nm_Type					=type;
							newmenu[item].nm_Label				=node->ln_Name;
							newmenu[item].nm_Flags				=flags;
							newmenu[item].nm_MutualExclude=mx;
							newmenu[item].nm_UserData			=(APTR)(base++);
							++item;
						}
				}
				else
				{
					register STRPTR label;

					newmenu[item].nm_Type	=(UBYTE)menudata[i++];

					label=(STRPTR)menudata[i];

					if(menudata[i]!=(int)NM_BARLABEL && *(label+1)=='\0')
					{
						newmenu[item].nm_Label		=(STRPTR)label+2;
						newmenu[item].nm_CommKey	=(STRPTR)label;
					}
					else
					{
						newmenu[item].nm_Label		=(STRPTR)label;
						newmenu[item].nm_CommKey	=(STRPTR)NULL;
					}
					newmenu[item].nm_Flags				=(UWORD)menudata[++i];
					newmenu[item].nm_MutualExclude=(LONG)menudata[++i];
					newmenu[item].nm_UserData			=(APTR)menudata[++i];
					++item;
				}
				++i;
			}
			menu=CreateMenus(newmenu, TAG_END);
			FreeVec(newmenu);
		}
	}
	return menu;
}
#endif
