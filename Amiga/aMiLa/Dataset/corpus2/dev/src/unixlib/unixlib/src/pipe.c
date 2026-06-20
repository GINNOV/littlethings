#include "amiga.h"
#include "files.h"
#include "fifofd.h"
#include "signals.h"
#include <sys/filio.h>
#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include <stdio.h>
#include <exec/memory.h>
#include <amiga/ioctl.h>

/* The pipe system call, using fifo: */

static struct MsgPort *create_fifo_port(void)
{
  struct MsgPort *port = AllocMem(sizeof(*port), MEMF_CLEAR | MEMF_PUBLIC);

  if (!port) return 0;
  port->mp_Node.ln_Type = NT_MSGPORT;
  port->mp_Flags = PA_SIGNAL;
  port->mp_SigBit = _fifo_sig;
  port->mp_SigTask = _us;
  NewList(&port->mp_MsgList);

  return port;
}

static void delete_fifo_port(struct MsgPort *port)
{
  FreeMem(port, sizeof(*port));
}

static void free_fifo(struct fifoinfo *fi)
{
  if (fi->rfifo) CloseFifo(fi->rfifo, 0);
  if (fi->wfifo) CloseFifo(fi->wfifo, FIFOF_EOF);
  if (fi->rmsg) free(fi->rmsg);
  if (fi->wmsg) free(fi->wmsg);
  delete_fifo_port(fi->reply);
  free(fi);
}

/* Code for fd's describing fifos */

static ULONG fifo_select_start(void *userinfo, int rd, int wr)
{
  struct fifoinfo *fi = userinfo;

  if (rd) RequestFifo(fi->rfifo, fi->rmsg, FREQ_RPEND);
  if (wr) RequestFifo(fi->wfifo, fi->wmsg, FREQ_WAVAIL);
  return 1UL << _fifo_sig;
}

static void fifo_select_poll(void *userinfo, int *rd, int *wr)
{
  struct fifoinfo *fi = userinfo;
  int rabort = *rd, wabort = *wr;
  struct Message *msg;

  while (msg = GetMsg(fi->reply)) 
    {
      if (msg == fi->rmsg) rabort = 0;
      else if (msg == fi->wmsg) wabort = 0;
    }
  if (rabort)
    {
      *rd = 0;
      RequestFifo(fi->rfifo, fi->rmsg, FREQ_ABORT);
    }
  if (wabort)
    {
      *wr = 0;
      RequestFifo(fi->wfifo, fi->wmsg, FREQ_ABORT);
    }
  while (rabort || wabort)
    {
      while (!(msg = GetMsg(fi->reply))) Wait(1UL << _fifo_sig);
      if (msg == fi->rmsg) rabort = 0;
      else if (msg == fi->wmsg) wabort = 0;
    }
  /* Clear any signals we may have left behind */
  SetSignal(0, 1UL << _fifo_sig);
}

/* Using 4.2BSD style semantics, with reads from fifo's returning immediately when
   data is available, and blocking for empty fifo's only when O_NDELAY was not
   specified on open */

static int fifo_read(void *userinfo, void *buffer, unsigned int length)
{
  struct fifoinfo *fi = userinfo;
  char *chars;
  long ready;

  while (!(ready = ReadFifo(fi->rfifo, &chars, fi->skip)))
    {
      ULONG sigs;

      fi->skip = 0;
      if (fi->flags & O_NDELAY)
	{
	  errno = EWOULDBLOCK;
	  return -1;
	}
      Delay(1);			/* Perversely, this improves the performance */
      RequestFifo(fi->rfifo, fi->rmsg, FREQ_RPEND);
      sigs = _wait_signals(1L << fi->reply->mp_SigBit);
      RequestFifo(fi->rfifo, fi->rmsg, FREQ_ABORT);
      while (!GetMsg(fi->reply)) Wait(1UL << _fifo_sig);

      _handle_signals(sigs);
    }
  if (ready == -1) ready = 0;
  if (ready > length) ready = length;
  memcpy(buffer, chars, ready);
  fi->skip = ready;

  return (int)ready;
}

static int fifo_write(void *userinfo, void *buffer, unsigned int length)
{
  struct fifoinfo *fi = userinfo;
  long cansend, written;

  if (length == 0)		/* Send EOF */
    {
      char *fname, sname[FIFO_NAMELEN + 2], mname[FIFO_NAMELEN + 2];

      /* Send EOF */
      CloseFifo(fi->wfifo, FIFOF_EOF);
      /* And reopen fifo */
      /* Docs say that this clears EOF flag, maybe we should wait a bit ? */
      /* The writer is the "master" in fifo: terms */
      strcpy(mname, fi->name); strcat(mname, "_m");
      strcpy(sname, fi->name); strcat(sname, "_s");

      fname = !(fi->flags & FI_READ) || (fi->flags & FIFO_MASTER) ? mname : sname;
      fi->wfifo = OpenFifo(fname, FIFO_BUFSIZE, FIFOF_NORMAL | FIFOF_NBIO |
			   FIFOF_WRITE | FIFOF_RREQUIRED);
      if (fi->wfifo)
	{
	  fi->maxsend = BufSizeFifo(fi->wfifo) / 2;
	  return 0;
	}
      /* We're in trouble. From now on, all writes will fail */
    }
  else if (fi->wfifo)
    {
      cansend = fi->maxsend;
      if (cansend > length) cansend = length;
      while ((written = WriteFifo(fi->wfifo, buffer, cansend)) == 0)
	{
	  ULONG sigs;

	  if (fi->flags & O_NDELAY)
	    {
	      errno = EWOULDBLOCK;
	      return -1;
	    }
	  RequestFifo(fi->wfifo, fi->wmsg, FREQ_WAVAIL);
	  sigs = _wait_signals(1L << fi->reply->mp_SigBit);
	  RequestFifo(fi->wfifo, fi->wmsg, FREQ_ABORT);
	  while (!GetMsg(fi->reply)) Wait(1UL << _fifo_sig);
	  _handle_signals(sigs);
	}
      if (written >= 0) return (int)written;
    }
  /* Some problem has occured */
  _sig_dispatch(SIGPIPE);
  errno = EPIPE;
  return -1;
}

static int fifo_lseek(void *userinfo, long rpos, int mode)
{
  errno = ESPIPE;
  return -1;
}

static int fifo_close(void *userinfo, int internal)
{
  struct fifoinfo *fi = userinfo;

  free_fifo(fi);
  return 0;
}

static int fifo_ioctl(void *userinfo, int request, void *data)
{
  struct fifoinfo *fi = userinfo;

  switch (request)
    {
    case FIONBIO:
      if (*(int *)data) fi->flags |= O_NDELAY;
      else fi->flags &= ~O_NDELAY;
      return 0;
    case _AMIGA_GET_FH: {
      BPTR *fh = data;
      char name[FIFO_NAMELEN + 12];

      /* Get an AmigaDOS fifo: onto the same fifo in the same role */
      if ((fi->flags & (FI_READ | FI_WRITE)) == (FI_READ | FI_WRITE))
	_sprintf(name, "fifo:%s/rwesK%s",
		 fi->name, fi->flags & FIFO_MASTER ? "m" : "");
      else if (fi->flags & FI_READ) _sprintf(name, "fifo:%s/r", fi->name);
      else _sprintf(name, "fifo:%s/mweK", fi->name);
      *fh = Open(name, MODE_OLDFILE);

      if (*fh) return 0;
      ERROR;
    }
    case _AMIGA_FREE_FH: {
      BPTR *fh = data;

      if (*fh) Close(*fh);
      return 0;
    }
    default: errno = EINVAL; return -1;
    }
}

static int alloc_fifo(char *name, int reader, int writer, int master)
{
  struct fifoinfo *fi;
  int fd;
  struct MsgPort *reply = 0;
  struct Message *rmsg = 0, *wmsg = 0;

  if ((fi = (struct fifoinfo *)malloc(sizeof(struct fifoinfo))) &&
      (reply = create_fifo_port()) &&
      (rmsg = (struct Message *)malloc(sizeof(struct Message))) &&
      (wmsg = (struct Message *)malloc(sizeof(struct Message))))
    {
      rmsg->mn_Node.ln_Type = NT_MESSAGE;
      rmsg->mn_ReplyPort = reply;
      rmsg->mn_Length = sizeof(*rmsg);
      wmsg->mn_Node.ln_Type = NT_MESSAGE;
      wmsg->mn_ReplyPort = reply;
      wmsg->mn_Length = sizeof(*wmsg);
      fi->reply = reply;
      fi->rmsg = rmsg;
      fi->wmsg = wmsg;
      fi->rfifo = fi->wfifo = 0;

      fi->flags = 0;
      if (reader) fi->flags |= FI_READ;
      if (writer) fi->flags |= FI_WRITE;
      fd = _alloc_fd(fi, fi->flags, fifo_select_start, fifo_select_poll, fifo_read,
		     fifo_write, fifo_lseek, fifo_close, fifo_ioctl);
      if (fd)
	{
	  char *fname, sname[FIFO_NAMELEN + 2], mname[FIFO_NAMELEN + 2];

	  if (master) fi->flags |= FIFO_MASTER;
	  strcpy(fi->name, name);
	  /* The writer is the "master" in fifo: terms */
	  strcpy(mname, fi->name); strcat(mname, "_m");
	  strcpy(sname, fi->name); strcat(sname, "_s");

	  if (reader)
	    {
	      fname = !writer || !master ? mname : sname;
	      fi->rfifo = OpenFifo(fname, FIFO_BUFSIZE, FIFOF_NORMAL | FIFOF_NBIO |
				   FIFOF_READ);
	    }
	  if (writer)
	    {
	      fname = !reader || master ? mname : sname;
	      fi->wfifo = OpenFifo(fname, FIFO_BUFSIZE, FIFOF_NORMAL | FIFOF_NBIO |
				   FIFOF_WRITE | FIFOF_RREQUIRED);
	    }
	  if ((fi->rfifo || !reader) && (fi->wfifo || !writer))
	    {
	      if (fi->wfifo) fi->maxsend = BufSizeFifo(fi->wfifo) / 2;
	      fi->skip = 0;
	      return fd;
	    }
	  if (fi->rfifo) CloseFifo(fi->rfifo, 0);
	  if (fi->wfifo) CloseFifo(fi->wfifo, 0);
	}
      if (fd >= 0) _free_fd(fd);
    }
  if (rmsg) free(rmsg);
  if (wmsg) free(wmsg);
  if (reply) delete_fifo_port(reply);
  if (fi) free(fi);
  return -1;
}

int pipe(int fd[2])
{
  char name[FIFO_NAMELEN];
  struct fileinfo *f0;

  chkabort();
  if (!_fifo_ok)
    {
      errno = ENXIO;
      return -1;
    }

  _sprintf(name, "uxfifo.%lx", _fifo_base + _fifo_offset++);

  if ((fd[0] = alloc_fifo(name, TRUE, FALSE, FALSE)) >= 0)
    if ((fd[1] = alloc_fifo(name, FALSE, TRUE, FALSE)) >= 0) return 0;
    else
      {
	if (f0 = _find_fd(fd[0])) free_fifo(f0->userinfo);
	_free_fd(fd[0]);
      }
  return -1;
}

int socketpair(int domain, int type, int protocol, int sv[2])
{
  char name[FIFO_NAMELEN];
  struct fileinfo *f0;

  chkabort();
  if (!_fifo_ok)
    {
      errno = ENXIO;
      return -1;
    }

  _sprintf(name, "uxfifo.%lx", _fifo_base + _fifo_offset++);

  if ((sv[0] = alloc_fifo(name, TRUE, TRUE, TRUE)) >= 0)
    if ((sv[1] = alloc_fifo(name, TRUE, TRUE, FALSE)) >= 0) return 0;
    else
      {
	if (f0 = _find_fd(sv[0])) free_fifo(f0->userinfo);
	_free_fd(sv[0]);
      }
  return -1;
}
