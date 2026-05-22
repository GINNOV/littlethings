/* Copyright (c) 1994 Doug Walker, Raleigh, NC */
/* All Rights Reserved. */
#include <dos/dos.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <proto/exec.h>
#include <proto/dos.h>

/* Dismount a volume */
void DisMount(struct DeviceList *volume)
{

   /* Check for any outstanding locks; if present, can't dismount */
   if(volume == NULL || volume->dl_Lock != NULL) return;

   RemDosEntry((struct DosList *)volume);
   FreeDosEntry((struct DosList *)volume);
}

/* Mount a volume with the given name; route all handler */
/* messages to the given port.                           */
struct DeviceList *Mount(char *name, struct MsgPort *port)
{
   struct DeviceList *volume;
   struct DosList *dlist;

   if(name == NULL || port == NULL) return NULL;

   while(!(dlist = AttemptLockDosList(LDF_VOLUMES|LDF_WRITE)))
   {
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

   /* Give the volume a default date... of course, you can change it later */
   volume->dl_VolumeDate.ds_Days   = 3800L;
   volume->dl_VolumeDate.ds_Minute =
   volume->dl_VolumeDate.ds_Tick   = 0L;
   volume->dl_Lock = NULL;

   /* Now we can own the volume by giving it our task id */
   volume->dl_Task = port;
   volume->dl_DiskType = ID_DOS_DISK;

   while(!(dlist = AttemptLockDosList(LDF_VOLUMES|LDF_WRITE)))
   {
      /* Oops, can't lock DOS list.  Wait 1 second and retry. */
      Delay(50);
   }
   AddDosEntry((struct DosList *)volume);
   UnLockDosList(LDF_VOLUMES|LDF_WRITE);
   return volume;
}

