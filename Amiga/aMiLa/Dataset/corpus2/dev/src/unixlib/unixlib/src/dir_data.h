#ifndef DIR_DATA_H
#define DIR_DATA_H

#include <sys/dir.h>

typedef struct
{
  char *dirname;
  BPTR cdir;
  struct FileInfoBlock fib;
  struct idirect *files, *pos;
  int seeked;
} iDIR;

struct idirect
{
  struct idirect *next;
  /* Info needed for stat */
  long numblocks;
  long size;
  struct DateStamp date;
  long type;
  long protection;
  struct direct entry;
};

extern iDIR *last_info;
extern struct idirect *last_entry;

BPTR _get_cd(void);

#endif
