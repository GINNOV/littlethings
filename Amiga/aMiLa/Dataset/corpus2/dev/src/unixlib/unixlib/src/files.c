#include "amiga.h"
#include "files.h"
#include <string.h>

/* Unix low-level IO emulation */
/* --------------------------- */

/* First, fd definition & allocation */

static struct fileinfo *files;
static int max_files;
#define FILE_STEP 10		/* Nb of file descriptors to allocate at once */

int _alloc_fd(void *userinfo, int flags,
  ULONG (*select_start)(void *userinfo, int rd, int wr),
  void (*select_poll)(void *userinfo, int *rd, int *wr),
  int (*read)(void *userinfo, void *buffer, unsigned int length),
  int (*write)(void *userinfo, void *buffer, unsigned int length),
  int (*lseek)(void *userinfo, long rpos, int mode),
  int (*close)(void *userinfo, int internal),
  int (*ioctl)(void *userinfo, int request, void *data)
)
{
  int fd;

  for (fd = 0; fd < max_files; fd++)
      if (!files[fd].userinfo)
	{
	  files[fd].userinfo = (void *)1;
	  break;
	}
  if (fd == max_files)
    {
      struct fileinfo *newfiles;
      int i;

      /* Increase files array by FILE_STEP */
      max_files += FILE_STEP;
      newfiles = (struct fileinfo *)malloc(max_files * sizeof(struct fileinfo));
      if (!newfiles)
	{
	  errno = ENOMEM;
	  return -1;
	}
      memcpy(newfiles, files, (max_files - FILE_STEP) * sizeof(struct fileinfo));
      if (files) free(files);
      files = newfiles;
      for (i = max_files - FILE_STEP; i < max_files; i++) files[i].userinfo = 0;
    }
  files[fd].userinfo = userinfo;
  files[fd].flags = flags;
  files[fd].select_start = select_start;
  files[fd].select_poll = select_poll;
  files[fd].read = read;
  files[fd].write = write;
  files[fd].lseek = lseek;
  files[fd].close = close;
  files[fd].ioctl = ioctl;
  return fd;
}

void _free_fd(int fd)
{
  if (0 <= fd && fd < max_files) files[fd].userinfo = 0;
}

struct fileinfo *_find_fd(int fd)
{
  if (0 <= fd && fd < max_files && files[fd].userinfo) return &files[fd];
  errno = EBADF;
  return 0;
}

int _last_fd(void) { return max_files; }
