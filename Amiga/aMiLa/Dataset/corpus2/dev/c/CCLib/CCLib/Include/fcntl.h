#ifndef FCNTL_H
#define FCNTL_H 1

#define O_RDONLY 0
#define O_WRONLY 1
#define O_RDWR	 (1<<1)
#define O_CREAT  (1<<8)
#define O_TRUNC  (1<<9)
#define O_EXCL	 (1<<10)
#define O_APPEND (1<<11)
#define O_CONRAW (1<<14)
#define O_STDIO  (1<<15)

#endif
