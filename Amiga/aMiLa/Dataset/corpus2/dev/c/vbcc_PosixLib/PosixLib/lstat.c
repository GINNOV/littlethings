#pragma amiga-align
#include <dos/dos.h>
#ifdef __amigaos4__
#include <dos/dosextens.h>
#include <dos/obsolete.h>
#endif
#include <proto/dos.h>
#pragma default-align
#include <errno.h>
#include <string.h>
#include <limits.h>
#include "conv.h"
#include "fib2stat.h"


int lstat(const char *restrict path,struct stat *restrict sb)
{
  struct FileInfoBlock fib;  /* long-word aligned! */
  char buf[PATH_MAX];
  struct FileLock *fl;
  BPTR lock;
  LONG llen;
  char *cpath,*filepart;
  int c;

  cpath = __convert_path(path);
  filepart = FilePart(cpath);
  /* A directory path is never a softlink, do stat */
  if ((c = *filepart)==0)
    return stat(path, sb);

  *filepart = 0;
  if (lock = Lock((STRPTR)cpath,ACCESS_READ)) {
    *filepart = c;
    fl = BADDR(lock);

    /* ReadLink returns RES1 from ACTION_READ_LINK, not BOOL */
    llen = ReadLink(fl->fl_Task,lock,filepart,buf,PATH_MAX);
    if (llen == -1) {
      /* Not a valid link, do a regular stat */
      UnLock(lock);
      return stat(path, sb);
    }
    else if (llen != 2) {
      /* We can't lock the link directly since Lock will do a lookup */
      if (Examine(lock,&fib)) {
        while (ExNext(lock,&fib)) {
          if (strcasecmp(filepart,fib.fib_FileName)==0) {
            if (__fib2stat(&fib,sb)!=0 || fib.fib_DirEntryType!=ST_SOFTLINK)
              break;
            UnLock(lock);
            sb->st_size = __path_from_ados(buf,cpath,PATH_MAX) - 1;
            sb->st_blocks = (sb->st_size+sb->st_blksize-1)/sb->st_blksize;
            return 0;
          }
        }
      }
      if (IoErr()==ERROR_NO_MORE_ENTRIES)
        errno = ENOENT;
      else
        errno = EIO;
    }
    else
      errno = EIO;
    UnLock(lock);
  }
  else
    errno = ENOENT;
  return -1;
}
