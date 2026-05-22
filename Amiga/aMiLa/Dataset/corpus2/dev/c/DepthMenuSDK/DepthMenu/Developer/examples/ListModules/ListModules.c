#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/depthmenu.h>

struct DosLibrary *DOSBase;
struct DepthMenuBase *DepthMenuBase;
struct DM_ModuleNode *node;
struct DM_Module *mod;

void main(void)
{
 if(DOSBase=(struct DosLibrary *)OpenLibrary("dos.library",39))
 {
  Printf("ListModules 1.0  Copyright (c) 2002 Arkadiusz [Yak] Wahlig\n\n");

  if(DepthMenuBase=(struct DepthMenuBase *)OpenLibrary("depthmenu.library",3))
  {
        // list of modules can be accessed through depthmenu.library base

   node=(struct DM_ModuleNode *)DepthMenuBase->Modules->mlh_Head;

   while(node->Node.ln_Succ)
   {
    mod=node->Module;

    Printf("%s\n"
           "    Requiered API version: %ld\n"
           "    Priority: %ld\n"
           "    Type: %s\n"
           "    Path: %s\n\n",mod->IDString,mod->APIVersion,mod->Priority,mod->SegList?"static":"dynamic",mod->ModulePath?mod->ModulePath:(STRPTR)"<not apply>");

    node=(struct DM_ModuleNode *)node->Node.ln_Succ;
   }

   CloseLibrary((struct Library *)DepthMenuBase);
  }
  else Printf("DepthMenu too old or is not running (can't open depthmenu.library V3)!\n");

  CloseLibrary((struct Library *)DOSBase);
 }
}

