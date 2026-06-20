/*
** ShowHooks.c 1.0
**
** Copyright © 2002 Arkadiusz [Yak] Wahlig
**
** This example program creates a dynamic module which shows when
** the hooks are called by displaying their names in output window.
**
** After compiling and linking simply run it and follow on-screen instructions.
*/

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/depthmenu.h>

// version string
// --------------
UBYTE version[]="$VER: ShowHooks.module 1.0 (18.11.2002) Arkadiusz [Yak] Wahlig";

// definitions
// -----------
extern struct DM_Module dmmodule;
extern ULONG moduletags[];
extern struct Hook hook_Setup;
extern struct Hook hook_Cleanup;
extern struct Hook hook_ScreenAttrs;
extern struct Hook hook_WindowAttrs;
extern struct Hook hook_ScreenItems;
extern struct Hook hook_WindowItems;
extern struct Hook hook_ScreenSelected;
extern struct Hook hook_WindowSelected;

// libraries bases
// ---------------
struct DosLibrary *DOSBase;
struct DepthMenuBase *DepthMenuBase;

// main function
// -------------
void main(void)
{
 if(DOSBase=(struct DosLibrary *)OpenLibrary("dos.library",0))
 {
  Printf("ShowHooks 1.0  Copyright (c) 2002 Arkadiusz [Yak] Wahlig\n\n");

  if(DepthMenuBase=(struct DepthMenuBase *)OpenLibrary("depthmenu.library",DM_APIVERSION))
  {
   if(!DM_AddModule(&dmmodule))
   {
    UBYTE a;

    Printf(">> Dynamic module installed, if everything went OK you should\n"
           ">> see a message from setup hook above this text. Now you can open\n"
           ">> some DepthMenu menus and watch messages appearing in DepthMenu's\n"
           ">> output window. You can also open DepthMenu's about window (default\n"
           ">> shortcut is CTRL+ALT+D) to see if ShowHooks.module appears in the\n"
           ">> modules list. If you want to remove the module simply press ENTER\n"
           ">> in this window... ");

    Flush(Output());
    Read(Input(),&a,1);

    DM_RemModule(&dmmodule);
   }
   else Printf(">> SetupHook failed!\n");

   CloseLibrary((struct Library *)DepthMenuBase);
  }
  else Printf(">> DepthMenu too old or is not running (failed to open depthmenu.library V%ld)!\n",DM_APIVERSION);

  CloseLibrary((struct Library *)DOSBase);
 }
}

// module interface stuff
// ----------------------
struct DM_Module dmmodule=
{
 DM_MATCHWORD,
 &dmmodule,
 DM_APIVERSION,
 0,
 "ShowHooks.module 1.0  Dynamic example module!",
 (struct TagItem *)&moduletags,
 NULL,
 NULL
};

ULONG moduletags[]=
{
 DM_Get_SysBase,(ULONG)&SysBase,
 DM_Get_DOSBase,(ULONG)&DOSBase,
 DM_Hook_Setup,(ULONG)&hook_Setup,
 DM_Hook_Cleanup,(ULONG)&hook_Cleanup,
 DM_Hook_ScreenAttrs,(ULONG)&hook_ScreenAttrs,
 DM_Hook_WindowAttrs,(ULONG)&hook_WindowAttrs,
 DM_Hook_ScreenItems,(ULONG)&hook_ScreenItems,
 DM_Hook_WindowItems,(ULONG)&hook_WindowItems,
 DM_Hook_ScreenSelected,(ULONG)&hook_ScreenSelected,
 DM_Hook_WindowSelected,(ULONG)&hook_WindowSelected,
 TAG_DONE
};

// module hooks
// ------------
BOOL __saveds entry_Setup(void)
{
 Printf("HOOK: Setup\n");
 return(TRUE);
}
struct Hook hook_Setup={NULL,NULL,(HOOKFUNC)entry_Setup,NULL,NULL};

BOOL __saveds entry_Cleanup(void)
{
 Printf("HOOK: Cleanup\n");
 return(TRUE);
}
struct Hook hook_Cleanup={NULL,NULL,(HOOKFUNC)entry_Cleanup,NULL,NULL};

BOOL ASM __saveds entry_ScreenAttrs(REG(a2,struct Screen *screen),REG(a1,struct DM_AttrsMessage *msg))
{
 Printf("HOOK: ScreenAttrs, Title='%s'\n",screen->Title);
 return(FALSE);
}
struct Hook hook_ScreenAttrs={NULL,NULL,(HOOKFUNC)entry_ScreenAttrs,NULL,NULL};

BOOL ASM __saveds entry_WindowAttrs(REG(a2,struct Window *window),REG(a1,struct DM_AttrsMessage *msg))
{
 Printf("HOOK: WindowAttrs, Title='%s', Owner='%s'\n",window->Title,msg->ProcessName);
 return(FALSE);
}
struct Hook hook_WindowAttrs={NULL,NULL,(HOOKFUNC)entry_WindowAttrs,NULL,NULL};

BOOL ASM __saveds entry_ScreenItems(REG(a2,struct Screen *screen),REG(a1,struct DM_ItemsMessage *msg))
{
 Printf("HOOK: ScreenItems, Title='%s'\n",screen->Title);
 return(FALSE);
}
struct Hook hook_ScreenItems={NULL,NULL,(HOOKFUNC)entry_ScreenItems,NULL,NULL};

BOOL ASM __saveds entry_WindowItems(REG(a2,struct Window *window),REG(a1,struct DM_ItemsMessage *msg))
{
 Printf("HOOK: WindowItems, Title='%s', Owner='%s'\n",window->Title,msg->ProcessName);
 return(FALSE);
}
struct Hook hook_WindowItems={NULL,NULL,(HOOKFUNC)entry_WindowItems,NULL,NULL};

BOOL ASM __saveds entry_ScreenSelected(REG(a2,struct Screen *screen))
{
 Printf("HOOK: ScreenSelected, Title='%s'\n",screen->Title);
 return(FALSE);
}
struct Hook hook_ScreenSelected={NULL,NULL,(HOOKFUNC)entry_ScreenSelected,NULL,NULL};

BOOL ASM __saveds entry_WindowSelected(REG(a2,struct Window *window),REG(a1,struct DM_SelectedMessage *msg))
{
 Printf("HOOK: WindowSelected, Title='%s', Owner='%s'\n",window->Title,msg->ProcessName);
 return(FALSE);
}
struct Hook hook_WindowSelected={NULL,NULL,(HOOKFUNC)entry_WindowSelected,NULL,NULL};

