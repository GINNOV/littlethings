#ifndef FIFO_H
#define FIFO_H

#include "fifo.h"
#include "fifo_pragmas.h"

#define FIFO_BUFSIZE 1024
#define FIFO_NAMELEN 32

struct fifoinfo
{
  char name[FIFO_NAMELEN];
  void *rfifo, *wfifo;
  long maxsend, skip;
  int flags;
  struct Message *rmsg, *wmsg;
  struct MsgPort *reply;
};

#define FIFO_MASTER 0x8000

extern struct Library *_FifoBase;
extern int _fifo_sig;
extern long _fifo_base;
extern long _fifo_offset;
extern int _fifo_ok;

void _init_fifo(void);
void _cleanup_fifo(void);

#endif
