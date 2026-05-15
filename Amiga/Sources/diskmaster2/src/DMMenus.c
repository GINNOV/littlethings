/* DiskMaster II  Menu module
**
** 2.5RC9
**
** 03-01-25 rri - Replace a strncpy() call by a CopyMem() call.
**
** 2.5RC10
**
** 03-03-15 rri - Simplified LayoutMenuItems() call in AddMenuItem()
**                to speed up startup.
**              - Added new function: DMLayoutMenus()
**              - Simplified LayoutMenus() call in AddMenu()
**                to speed up startup.
**              - Removed menu_off() / menu_on() calls from AddMenuCmd()
**
** 03-04-24 rri - Removed two end-of-line checks from AddMenuCmd()
**                Simplified AddMenuItem() - it is always fed with a
**                single command-line now...
**              - Initialised Vi to NULL, better safe than sorry...
**              - Added an additional sanity check to MyFreeMenus()...
**              - Fix: with 0-terminated command-line BARLABEL
**                did not work anymore.
**
** 2.5.23
**
** 03-05-30 rri - Removed a few GCC warnings.
**              - Introduced DMMAXWINDOWS.
**
** 2.5.26
**
** 03-08-31 rri - LibCreatePool() and LibDeletePool() are replaced by CreatePool()
**                and DeletePool() when compiling for OS4 now.
**
** 2.5.28
**
** 04-01-03 rri - Removed "g_memattrs" and replaced it's references with "MEMF_ANY | MEMF_CLEAR".
**              - Removed all comments from the top that were older
**                than a year (pre 2.5RC9)
**
** 2.5.31
**
** 04-10-12 rri - IntuitionBase and GfxBase are of type struct Library for OS4.
**
** 04-12-22 rri - Removed LibDeletePool() and LibCreatePool() -> DM2 goes V39+!
**
** 2.6
**
** 05-11-08 jjt - AddMenuCmd() - Added context help to the req.
**
** 2.7 b7
**
** 06-12-28 rri - Replaced Menu_TAttr with DMTextAttrs[DMFONTS_MENU].
**              - Modified menu_on() and menu_off() for use with a Window.class based window.
**
** 06-12-30 rri - Switched menu_on() and menu_off() back to use with Intuition based window.
**
**
*/

#include "DM.h"

#ifdef __amigaos4__ /* 2.5.31 rri */
extern struct Library *GfxBase;
extern struct Library *IntuitionBase;
#else
extern struct GfxBase *GfxBase;
extern struct IntuitionBase *IntuitionBase;
#endif

extern struct Library *GadToolsBase;
extern struct Screen *Screen;
extern struct DirWindow *DirWin[];

extern int  Abort;

extern UBYTE sbuff[],ActionBuf[];
extern UWORD Pens20[];
extern ULONG FLAGS; /* 2.5RC10 rri */

struct Menu *DMMenu=NULL; /* 2.5b10 rri */
//struct TextAttr Menu_TAttr;  /* 2.5RC2 jjt */
extern struct TextAttr DMTextAttrs[]; /* 2.7 rri */

extern struct TagItem    reqtags_Help[];  /* 2.6 jjt */

APTR Vi = NULL; /* 2.5RC10 rri */
APTR MenuPool = NULL; /* 2.5b10 rri */



struct Menu * AddMenu(UBYTE *name)
{
struct Menu *menu, *mptr = DMMenu;
LONG result;

struct NewMenu nm[2] =
 {
  { NM_TITLE, NULL, NULL, 0, 0, NULL },
  { NM_END,   NULL, NULL, 0, 0, NULL }
 };

name = SkipWhite(name);

result = 0; /* 2.5RC4 rri vbcc */
menu = NULL; /* 2.5b10 rri */

while(mptr != NULL)
 {
  if(Stricmp(name, mptr->MenuName) == 0) /* 2.5b7 rri */
   {
    return(mptr);
   }
  mptr = mptr->NextMenu;
 }

mptr = DMMenu;

if((nm[0].nm_Label = CloneStr(name,MenuPool))) /* 2.5.23 gcc rri */
 {
  menu = CreateMenus(nm,GTMN_FrontPen,Pens20[BARDETAILPEN],TAG_DONE);

  if(menu != NULL)
   {
    if(DMMenu != NULL)
     {
      while(mptr->NextMenu != NULL) /* add menu to end of list or... */
       {
        mptr = mptr->NextMenu;
       }
      mptr->NextMenu = menu;
     }
    else
     {
      DMMenu = menu; /* set it as first item */
     }

    if(Vi == NULL)
     {
      Vi = GetVisualInfoA(Screen, NULL);
     }

     /* 2.5RC10 rri */
    if(FLAGS&DMFLAG_BATCH)
     {
      /* simple layout, just to get the structure right, fast */
      result=LayoutMenus(menu, Vi, TAG_DONE);
     }
    else
     {
      result=DMLayoutMenus();
     }

    if (!result)
     {
      FreeMenus(menu);
      menu = NULL;
     }
   }
  if(menu == NULL || !result)
   {
    PoolFreeVec(nm[0].nm_Label); /* 2.5b10 rri */
   }
 }
return(menu);
}


VOID AddMenuItem(struct Menu *menu,UBYTE *name,UBYTE key,UBYTE *cmd) /* 2.5b10 rri */
{
struct NewMenu nm[2] =
 {
  { NM_ITEM,  NULL, NULL, 0, 0, NULL },
  { NM_END,   NULL, NULL, 0, 0, NULL }
 };
struct MenuItem *m;
struct MenuItem *mptr;
LONG result;

result=0; /* 2.5RC4 rri vbcc */

if(!cmd) /* 2.5RC10 rri */
 {
  nm[0].nm_Label    = NM_BARLABEL;   /* BARLABELs supported new in */
  nm[0].nm_UserData = NM_BARLABEL;
 }

else
 {
  if((nm[0].nm_Label = CloneStr(name,MenuPool))) /* 2.5.23 gcc rri */
   {
    if(key)
     {
      nm[0].nm_CommKey = &key;
     }

    cmd = SkipWhite(cmd);

    if(!(nm[0].nm_UserData = CloneStr(cmd,MenuPool))) /* 2.5RC10 rri */
     {
      PoolFreeVec(nm[0].nm_Label); /* 2.5b10 rri */
      nm[0].nm_Label = NULL;
     }
   }
 }

if(nm[0].nm_Label != NULL)
 {
  m = (struct MenuItem *) CreateMenus(nm,
       GTMN_FrontPen, Pens20[BARDETAILPEN], /* 2.5b7 rri */
       TAG_DONE);
  if(m != NULL)
   {
    if(menu->FirstItem != NULL)
     {
      mptr = menu->FirstItem;
      while(mptr->NextItem)
       {
        mptr = mptr->NextItem;
       }
      mptr->NextItem = m;
     }
    else
     {
      menu->FirstItem = m;
     }
    if(Vi == NULL)
     {
      Vi = GetVisualInfoA(Screen, NULL);
     }
    if(Vi != NULL)
     {
      /* simple layout, just to get the structure right, fast */
      result = LayoutMenuItems(m,Vi,TAG_DONE); /* 2.5RC10 rri */
     }
    if(!result)
     {
      FreeMenus((struct Menu *) m);
     }
   }
  if(m == NULL || !result)
   {
    if(nm[0].nm_Label != NM_BARLABEL)
     {
      PoolFreeVec(nm[0].nm_Label); /* 2.5b10 rri */
      PoolFreeVec(nm[0].nm_UserData); /* 2.5RC10 rri */
     }
   }
 }
}


VOID menu_on(VOID)
{
int i;

if(DMMenu != NULL)
 {
  for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
   {
    if(DirWin[i] != NULL)
     {
//      SetAttrs(DirWin[i]->dwwindow,WINDOW_MenuStrip, DMMenu, TAG_END); /* 2.7 rri */
      SetMenuStrip(DirWin[i]->Window,DMMenu);
     }
   }
 }
}


VOID menu_off(VOID)
{
int i;

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  if(DirWin[i] != NULL)
   {
//    SetAttrs(DirWin[i]->dwwindow,WINDOW_MenuStrip, NULL, TAG_END); /* 2.7 rri */
    ClearMenuStrip(DirWin[i]->Window);
   }
 }
}


LONG DMLayoutMenus(VOID) /* 2.5RC10 rri */
{
LONG result=0;

menu_off();

if(Vi == NULL)
 {
  Vi = GetVisualInfoA(Screen, NULL);
 }

if (Vi && DMMenu)
 {
  result=LayoutMenus(DMMenu, Vi, GTMN_NewLookMenus, TRUE,
                                 GTMN_TextAttr, &DMTextAttrs[DMFONTS_MENU], /* 2.7 rri */
                                 TAG_DONE);
  menu_on();
 }
return(result);
}


VOID AddMenuCmd(UBYTE *buf) /* 2.5b10 rri */
{
struct Menu *menu;
UBYTE *ptr,k;

if(!MenuPool) /* 2.5b10 rri */
 {
  /* 2.5.31 rri */
  if(!(MenuPool=CreatePool(MEMF_ANY | MEMF_CLEAR, 25600, 256))) /* 2.5.28 rri */
   {
    return;
   }
 }

if(!buf || *buf == 0)
 {
  buf = ActionBuf;
  *buf = 0;

  reqtags_Help[0].ti_Data = (LONG) "AddMenuCmd";  /* 2.6 jjt */
  if(!DMReqTagList(msgReqAddMenu, buf, 256, reqtags_Help))  /* 2.5b13 rri */ /* 2.6 jjt */
   {
    return;
   }
 }

ptr = sbuff;

while(*buf && *buf != ',') /* 2.5RC10 rri */
 {
  *ptr++=(*buf++); /* get the name of the menu */ /* 2.5b10 rri */
 }

*ptr = 0;

if((menu=AddMenu(sbuff))) /* continue if menu could be created */ /* 2.5.23 gcc rri */
 {
  if(*buf==',') /* continue if it wasn`t the end of the line */
   {
    ptr = sbuff;
    buf++; /* skip "," */

    if(*buf == ' ')
     {
      buf++; /* skip first space in item-name */
     }

    while( *buf && *buf != ',') /* 2.5RC10 rri */
     {
      *ptr++ = *buf++; /* get the name of the menu-item */
     }

    if(*buf == ',')
     {
      *ptr = 0;
      if(Stricmp(sbuff,"BARLABEL") == 0) /* 2.5RC10 rri */
       {
        AddMenuItem(menu, sbuff, 0, 0);
        return;
       }

      buf++; /* skip "," */
      k = 0;
      buf = SkipWhite(buf);

      if(*buf && buf[1] == ',') /* buffer valid & argument only 1 char? */
       {
        k = (*buf); /* yes, so this must be a key to press...strange... */ /* 2.5b10 rri */
        buf += 2; /* skip menu shortcut argument */
            /* bug: "test, test, a , " won`t work... */
       }

      buf = SkipWhite(buf);

      if(*buf)
       { /* still not reached the end of the line? */
        AddMenuItem(menu, sbuff, k, buf); /* so take all the rest as menu-command */
       }
     }
   }
 }
}


VOID MyFreeMenus(VOID) /* 2.5b10 rri */
{
struct Menu *mptr,*mptr2;
struct MenuItem *mptr3,*mptr4;

/* this goes down the whole menu-structure freeing each entry individually */

for(mptr = DMMenu; mptr;mptr=mptr2)
 {
  for(mptr3 = mptr->FirstItem;mptr3;mptr3 = mptr4)
   {
    mptr4 = mptr3->NextItem;
    FreeMenus((struct Menu*) mptr3);
   }
  mptr2 = mptr->NextMenu;
  if(mptr) FreeMenus(mptr); /* 2.5RC10 rri */
 }

DMMenu = NULL;

if(Vi)
 {
  FreeVisualInfo(Vi);
  Vi = NULL;
 }

if(MenuPool)
 {
  /* 2.5.31 rri */
  DeletePool(MenuPool);  /* 2.5RC4 rri vbcc */
  MenuPool=NULL;
 }
}
