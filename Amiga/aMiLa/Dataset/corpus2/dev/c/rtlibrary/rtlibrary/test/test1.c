#if 0
echo gcc -O2 -Wall -nostdlib -s -o test1 test1.c -I../include -I../../agcc/include -I../../agcc/os-include -L../lib -lrt
gcc -O2 -Wall -nostdlib -s -o test1 test1.c -I../include -I../../include -I../../os-include -L../lib -lrt
exit
#endif
/*
 * $Id: test1.c $
 *
 * Author: Tomi Ollila <too@cs.hut.fi>
 *
 * Created: Wed Feb  1 00:46:16 1995 too
 * Last modified: Wed Feb  1 01:47:36 1995 too
 *
 * HISTORY 
 * $Log: $
 */

int start(void);

int begin()
{
  return start();
}

#include <proto/exec.h>
#include <rt_exec.h>
#include <proto/dos.h>
#include <rt_dos.h>

struct ExecBase * SysBase;
struct DosLibrary * DOSBase;

int run(struct RT * rt);

int start()
{
  struct RT * rt;
  int rv;
  
  SysBase = *(struct ExecBase **)4;

  unless (rt = rt_Create(100))
    return 20;

  rv = run(rt);

  rt_Delete(rt);
  return rv;
}

char * tststrs[] = {
  "line 0",
  "line 1",
  "line 2",
  "line 3",
  "line 4",
  "line 5",
  "line 6",
  "line 7"
};

void showRemoved(char * ptr)
{
  Printf("%s\n", ptr);
}

struct RTNode * addLine(struct RT * rt, char * ptr)
{
  Printf("adding *** %s\n", ptr);
  
  return rt_Add(rt, showRemoved, ptr);
}

int run(struct RT * rt)
{
  struct RTNode * sn;

  unless (rt_OpenLib(rt, &DOSBase, "dos.library", 37))
    return 20;
      
  
  addLine(rt, tststrs[0]);
  addLine(rt, tststrs[1]);
  addLine(rt, tststrs[2]);
  addLine(rt, tststrs[3]);
  sn = addLine(rt, tststrs[4]);
  addLine(rt, tststrs[5]);

  rt_RemNode(rt, sn);
  addLine(rt, tststrs[6]);
  addLine(rt, tststrs[7]);

  rt_RemData(rt, tststrs[1]);

  rt_RemSome(rt, tststrs[0], RTRF_REMTO|RTRF_DATA);

  sn = addLine(rt, tststrs[7]);

  addLine(rt, tststrs[6]);
  addLine(rt, tststrs[5]);
  addLine(rt, tststrs[4]);
  addLine(rt, tststrs[3]);
  addLine(rt, tststrs[2]);
  addLine(rt, tststrs[1]);

  rt_RemSome(rt, sn, RTRF_REMUNTIL|RTRF_NODE);
  Printf("end\n", 1);
  
  return 0;
}
