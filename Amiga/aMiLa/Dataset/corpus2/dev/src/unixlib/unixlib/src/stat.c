#include "amiga.h"
#include "dir_data.h"
#include <utility/tagitem.h>
#include <sys/stat.h>
#include <string.h>

static int attach (char *dest, int dlen, char *dirname, char *name)
{
  char *dirnamep = dirname;
  
  while (*dirnamep && --dlen > 0)
    *dest++ = *dirnamep++;
  /* Add '/' if `dirname' doesn't already end with it. */
  if (dirnamep > dirname && dirnamep[-1] != '/' && dirnamep[-1] != ':' && --dlen > 0)
    *dest++ = '/';
  
  while (*name && --dlen > 0)
    *dest++ = *name++;
  *dest = 0;
  
  return dlen > 0;
}

static struct FileInfoBlock fakefib;
static char last_name[256];

int stat(char *name, struct stat *sbuf)
{
  struct FileInfoBlock *fib = 0;
  BPTR lock = 0;
  int ret;
  
  chkabort();
  /* See if we want information on the last file returned from readdir */
  if (last_info && last_info->cdir == _get_cd() &&
      attach(last_name, 255, last_info->dirname, last_entry->entry.d_name) &&
      strcmp(last_name, name) == 0)
    {
      /* We do ! Fake a fib */
      
      fakefib.fib_DiskKey = last_entry->entry.d_ino;
      fakefib.fib_NumBlocks = last_entry->numblocks;
      fakefib.fib_Size = last_entry->size;
      fakefib.fib_Date = last_entry->date;
      fakefib.fib_DirEntryType = last_entry->type;
      fakefib.fib_Protection = last_entry->protection;
      
      _fibstat(&fakefib, 0, sbuf);
      ret = 0;
    }	
  else if ((fib = AllocDosObjectTags(DOS_FIB, TAG_END)) &&
	   (lock = Lock(name, ACCESS_READ)) &&
	   Examine(lock, fib))
    {
      BPTR parent = ParentDir(lock);
      int isroot = !parent;
      
      if (parent) UnLock(parent);
      _fibstat(fib, isroot, sbuf);
      ret = 0;
    }
  else
    {
      ret = -1;
      errno = convert_oserr(IoErr());
    }
  if (lock) UnLock(lock);
  if (fib) FreeDosObject(DOS_FIB, fib);
  return ret;
}
