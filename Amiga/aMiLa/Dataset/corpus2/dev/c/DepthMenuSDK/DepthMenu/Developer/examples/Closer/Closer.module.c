/*
** Closer.module.c 1.0
**
** Copyright © 2002 Arkadiusz [Yak] Wahlig
**
** This is a working example of how to change titles and add items.
** It adds an "Close" item to all windows with close gadget. Additionaly
** it adds window dimensions enclosed in round brackets at end of
** every window title in menu.
**
** After compiling and linking put it in DepthMenu's Modules drawer
** and have fun ;-).
*/

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/depthmenu.h>
#include <libraries/gadtools.h>

// version string
// --------------
UBYTE version[]="$VER: Closer.module 1.0 (18.11.2002) Arkadiusz [Yak] Wahlig";

// definitions
// -----------
extern ULONG moduletags[];
extern struct Hook hook_Setup;
extern struct Hook hook_Cleanup;
extern struct Hook hook_WindowAttrs;
extern struct Hook hook_WindowItems;
extern struct Hook hook_ItemsHandler;

// library bases
// -------------
struct DosLibrary *DOSBase;
struct DepthMenuBase *DepthMenuBase;

// module interface stuff
// ----------------------
struct DM_Module dmmodule=
{
 DM_MATCHWORD,
 &dmmodule,
 DM_APIVERSION,
 0,
 "Closer.module 1.0 (18-11-2002) Arkadiusz [Yak] Wahlig",
 (struct TagItem *)&moduletags,
 NULL,
 NULL
};

ULONG moduletags[]=
{
 DM_Get_SysBase,(ULONG)&SysBase,
 DM_Get_DOSBase,(ULONG)&DOSBase,
 DM_Get_DepthMenuBase,(ULONG)&DepthMenuBase,
 DM_Get_SetupHook,(ULONG)&hook_Setup,
 DM_Get_CleanupHook,(ULONG)&hook_Cleanup,
 DM_Hook_WindowAttrs,(ULONG)&hook_WindowAttrs,
 DM_Hook_WindowItems,(ULONG)&hook_WindowItems,
 DM_Hook_ItemsHandler,(ULONG)&hook_ItemsHandler,
 TAG_DONE
};

// global variables
// ----------------

APTR menu;
UBYTE buf[32];

struct NewMenu newmenu[]=
{
 {NM_TITLE,"Close",NULL,0,0,NULL},
 {NM_END,NULL,NULL,0,0,NULL}
};

// module hooks
// ------------
BOOL __saveds entry_Setup(void)
{
      // try to create items from NewMenu structures table
 if(menu=DM_CreateItemsNewMenuA(newmenu,NULL)) return(TRUE);  // success
 else return(FALSE);                                          // fail
}
struct Hook hook_Setup={NULL,NULL,(HOOKFUNC)entry_Setup,NULL,NULL};

BOOL __saveds entry_Cleanup(void)
{
      // DepthMenu want us to remove ourself so we have to free the items
      // created in setup hook
 DM_FreeItems(menu);
 return(TRUE);
}
struct Hook hook_Cleanup={NULL,NULL,(HOOKFUNC)entry_Cleanup,NULL,NULL};

BOOL ASM __saveds entry_WindowAttrs(REG(a2,struct Window *window),REG(a1,struct DM_AttrsMessage *msg))
{
      // fill buf with window dimensions
 sprintf(buf," (%ld/%ld)",window->Width,window->Height);
 msg->TitleTail=buf;       // add buf at end of the title
                           // (buf will be copied so we can overwrite it in next hook call)
 return(TRUE);             // confirm changes
}
struct Hook hook_WindowAttrs={NULL,NULL,(HOOKFUNC)entry_WindowAttrs,NULL,NULL};

BOOL ASM __saveds entry_WindowItems(REG(a2,struct Window *window),REG(a1,struct DM_ItemsMessage *msg))
{
 if(window->Flags&WFLG_CLOSEGADGET)   // is there a close gadget?
 {
  msg->Items=menu;                    // insert items (created in setup hook)

  msg->Reusable=TRUE;                 // we may be using these items again so we have to tell
                                      // DepthMenu not to free them!

  return(TRUE);                       // confirm changes
 }
 else return(FALSE);                  // cancel changes
}
struct Hook hook_WindowItems={NULL,NULL,(HOOKFUNC)entry_WindowItems,NULL,NULL};

void ASM __saveds entry_ItemsHandler(REG(a2,struct Window *window),REG(a1,struct DM_ItemsHandlerMessage *message))
{
 struct MsgPort *port;
 struct IntuiMessage *msg;

 if(port=CreateMsgPort())                            // creating message port
 {
  // creating faked intuimessage to send to window we want to close

  if(msg=AllocVec(sizeof(struct ExtIntuiMessage),MEMF_ANY|MEMF_CLEAR|MEMF_PUBLIC))
  {
   msg->ExecMessage.mn_ReplyPort=port;
   msg->ExecMessage.mn_Length=sizeof(struct ExtIntuiMessage);
   msg->Class=IDCMP_CLOSEWINDOW;
   msg->Qualifier=IEQUALIFIER_RELATIVEMOUSE;
   msg->IDCMPWindow=window;

   PutMsg(window->UserPort,(struct Message *)msg);   // sending message to window's user port
   WaitPort(port);                                   // waiting for reply
   GetMsg(port);                                     // removing reply message from port
   FreeVec(msg);                                     // freeing faked message
  }
  DeleteMsgPort(port);                               // freeing message port
 }
}
struct Hook hook_ItemsHandler={NULL,NULL,(HOOKFUNC)entry_ItemsHandler,NULL,NULL};

