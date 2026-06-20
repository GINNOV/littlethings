#ifndef FILES_H
#define FILES_H

struct fileinfo {
  int flags;
  void *userinfo;
  unsigned long (*select_start)(void *userinfo, int rd, int wr);
  void (*select_poll)(void *userinfo, int *rd, int *wr);
  int (*read)(void *userinfo, void *buffer, unsigned int length);
  int (*write)(void *userinfo, void *buffer, unsigned int length);
  int (*lseek)(void *userinfo, long rpos, int mode);
  int (*close)(void *userinfo, int internal);
  int (*ioctl)(void *userinfo, int request, void *data);
};

/* FI_READ & WRITE replace O_RDONLY, WRONLY & RDWR. Other flags are left untouched */
#define FI_READ 1
#define FI_WRITE 2

int _alloc_fd(void *userinfo, int flags,
  unsigned long (*select_start)(void *userinfo, int rd, int wr),
  void (*select_poll)(void *userinfo, int *rd, int *wr),
  int (*read)(void *userinfo, void *buffer, unsigned int length),
  int (*write)(void *userinfo, void *buffer, unsigned int length),
  int (*lseek)(void *userinfo, long rpos, int mode),
  int (*close)(void *userinfo, int internal),
  int (*ioctl)(void *userinfo, int request, void *data)
);

void _free_fd(int fd);

struct fileinfo *_find_fd(int fd);
int _last_fd(void);

#endif
