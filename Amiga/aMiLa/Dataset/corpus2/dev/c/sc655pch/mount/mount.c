/* Copyright (c) 1994 Doug Walker, Raleigh, NC */
/* All Rights Reserved. */

#include <dos/dos.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <string.h>

#include "mount.h"

#define SysBase (*(struct ExecBase **)4)
#define V37 (SysBase->LibNode.lib_Version > 36)

/* Dismount a volume */
/* Note: does not free the memory associated with the volume! */
int DisMount(struct DeviceList *volume)
{
   struct DosInfo *info;
   struct RootNode *root;
   struct DeviceList *tmpdl;
   long *tmpl;

   /* Check for any outstanding locks; if present, can't dismount */
   if(volume == NULL || volume->dl_Lock != NULL) return -1;

   if(V37)
   {
      RemDosEntry((struct DosList *)volume);
      FreeDosEntry((struct DosList *)volume);
      return 0;
   }
   else
   {
      /* No AmigaDOS 2.0.  Locate the volume on the list and remove it. */
      root   = (struct RootNode   *)DOSBase->dl_Root;
      info   = (struct DosInfo    *)BADDR(root->rn_Info);
      tmpdl  = (struct DeviceList *)BADDR(info->di_DevInfo);

      Forbid();

      if (volume == tmpdl)
      {
         info->di_DevInfo = volume->dl_Next;
      }
      else
      {
         while (tmpdl != NULL &&
            (struct DeviceList *)(BADDR(tmpdl->dl_Next)) != volume)
         {
            tmpdl = (struct DeviceList *)BADDR(tmpdl->dl_Next);
         }

         /* if we found it then take it out of the chain */
         if (tmpdl != NULL)
            tmpdl->dl_Next = volume->dl_Next;
      }
      Permit();
   }

   /* We stored the length of the memory block just in front of the volume */
   /* pointer.                                                             */
   tmpl = ((long *)volume)-1;
   FreeMem(tmpl, *tmpl);

   return 0;
}

/* Mount a volume with the given name; route all handler */
/* messages to the given port.                           */
struct DeviceList *Mount(char *name, struct MsgPort *port)
{
   struct DeviceList *volume;
   struct DosInfo *info;
   struct RootNode *root;
   struct DosList *dlist;
   char work[257];  /* Max BCPL string is 255 + length byte + null terminator */
   int len;

   if(name == NULL || port == NULL) return NULL;

   if(V37)
   {
      while(1)
      {
         dlist = AttemptLockDosList(LDF_VOLUMES|LDF_WRITE);
         /* Account for DOS bug in V39 which may cause AttemptLockDosList */
         /* to return 1 instead of NULL                                   */
         if(dlist != NULL && dlist != (struct DosList *)1)
            break;
         /* Can't lock the DOS list.  Wait a second and try again. */
         Delay(50);
      }
      volume = (struct DeviceList *)FindDosEntry(dlist, name, LDF_VOLUMES);
      if(volume) RemDosEntry((struct DosList *)volume);
      UnLockDosList(LDF_VOLUMES|LDF_WRITE);

      if(!volume && !(volume = (struct DeviceList *)MakeDosEntry(name, DLT_VOLUME)))
      {
         return NULL;
      }
      /* Continued below */
   }
   else  /* Earlier than V37 */
   {
      /* Need to make the name into a BCPL string */
      len = strlen(name);
      if(len > 255) return NULL;
      len += 2;  /* Account for null terminator and BCPL length byte */
      strcpy(work+1, name);
      work[0] = len-2;
      name = work;

      root   = (struct RootNode   *)DOSBase->dl_Root;
      info   = (struct DosInfo    *)BADDR(root->rn_Info);
      volume = (struct DeviceList *)BADDR(info->di_DevInfo);

      Forbid();

      while (volume != NULL)
      {
         if(volume->dl_Type == DLT_VOLUME                           &&
            !memcmp(name, (char *)BADDR(volume->dl_Name), len-1)    &&
            volume->dl_VolumeDate.ds_Days   == 0L                   &&
            volume->dl_VolumeDate.ds_Minute == 0L                   &&
            volume->dl_VolumeDate.ds_Tick   == 0L)
         {
            break;
         }
         volume = (struct DeviceList *)BADDR(volume->dl_Next);
      }

      Permit();

      /* OK, now did we find it? */
      if (volume == NULL)
      {
         /* No such volume is known to the system, so we will just have to    */
         /* allocate a node to put everything on.  Allocate some extra space  */
         /* after the volume node to hold the name.                           */
         /* This can happen under V37 only, due to the logic above            */
         volume = (struct DeviceList *)AllocMem(sizeof(struct DeviceList)+len+4, 0L);

         if(volume == NULL) return NULL;

         /* Save the allocated length before the real allocation's start */
         *((long *)volume) = sizeof(struct DeviceList)+len+4;
         volume = (struct DeviceList *)(((char *)volume)+4);

         /* We can get to the name by adding 1 to volume, thanks to C's pointer */
         /* arithmetic.                                                         */
         strcpy((char *)(volume + 1), name);
         volume->dl_Name = (BSTR)MKBADDR((volume + 1));
         volume->dl_Type = DLT_VOLUME;
      }
   }

   /* Common code between V37 and !V37 */
   /* Give the volume a default date... of course, you can change it later */
   volume->dl_VolumeDate.ds_Days   = 3800L;
   volume->dl_VolumeDate.ds_Minute =
   volume->dl_VolumeDate.ds_Tick   = 0L;
   volume->dl_Lock = NULL;

   /* Now we can own the volume by giving it our msgport */
   volume->dl_Task = port;
   volume->dl_DiskType = ID_DOS_DISK;

   if(!V37)
   {
      Forbid();
      volume->dl_Next = info->di_DevInfo;
      info->di_DevInfo = MKBADDR(volume);
      Permit();
   }
   else
   {
      while(1)
      {
         dlist = AttemptLockDosList(LDF_VOLUMES|LDF_WRITE);
         /* Account for DOS bug in V39 which may cause AttemptLockDosList */
         /* to return 1 instead of NULL                                   */
         if(dlist != NULL && dlist != (struct DosList *)1)
            break;
         /* Oops, can't lock DOS list.  Wait 1 second and retry. */
         Delay(50);
      }
      AddDosEntry((struct DosList *)volume);
      UnLockDosList(LDF_VOLUMES|LDF_WRITE);
   }
   return volume;
}
