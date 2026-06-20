/*
 * menus.c
 * =======
 * Menu utility functions.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include <exec/memory.h>

#include <proto/exec.h>
#include <proto/gadtools.h>
#include <proto/intuition.h>

#include "apputil.h"


struct Menu *CreateLocMenusA(struct NewMenu *newMenu, APTR vi,
			     struct TagItem *tagList) {
  LONG i;
  struct NewMenu *nm;
  struct Menu *menu;

  for (i = 0; newMenu[i++].nm_Type != NM_END; ) {
  }

  nm = AllocVec(i * sizeof *nm, MEMF_PUBLIC);
  if (nm == NULL) {
    return NULL;
  }

  while (i--) {
    nm[i] = newMenu[i];
    if (nm[i].nm_Label != NM_BARLABEL) {
      nm[i].nm_CommKey = GetLocString((ULONG)nm[i].nm_Label);
      nm[i].nm_Label = nm[i].nm_CommKey + 2;
      if (nm[i].nm_CommKey[0] == ' ') {
	nm[i].nm_CommKey = NULL;
      }
    }
  }

  menu = CreateMenusA(nm, tagList);
  if (menu != NULL) {
    if (!LayoutMenus(menu, vi, GTMN_NewLookMenus, TRUE, TAG_DONE)) {
      FreeMenus(menu);
      menu = NULL;
    }
  }

  FreeVec(nm);

  return menu;
}


struct Menu *CreateLocMenus(struct NewMenu *newMenu, APTR vi,
			    ULONG tag, ...) {
  return CreateLocMenusA(newMenu, vi, (struct TagItem *)&tag);
}


VOID ProcessMenuEvents(struct Window *win, UWORD menuNum) {
  struct MenuItem *menuItem;
  APTR userData;

  while (menuNum != MENUNULL) {
    menuItem = ItemAddress(win->MenuStrip, (ULONG)menuNum);
    userData = GTMENUITEM_USERDATA(menuItem);
    if (userData != NULL) {
      if (menuItem->Flags & CHECKIT) {
	(*(CheckedMenuAction)userData)(menuItem->Flags & CHECKED);
      } else {
	(*(MenuAction)userData)();
      }
    }

    menuNum = menuItem->NextSelect;
  }
}
