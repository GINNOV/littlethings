
#define MM_RUNLIB

#include "proto/exec.h"
#include "libraries/dos.h"
#include "memman.h"

void *MMBase ;
int signal ;
struct MMNode mynode ;
int amount ;


void
__asm __saveds __interrupt
raid(register __d0 int size, register __d1 int attrib, register __a0 struct Task *parent) {
   amount = size ;
   Signal(parent,signal) ;
   }

main() {
   int sig ;
   int mask ;

   mynode.GetRidFunc = raid ;
   mynode.GetRidData = FindTask(0) ;

   MMBase = OpenLibrary("memman.library",0) ;

   if (!MMBase) {
      printf("Unable to open memman library\n") ;
      exit (1) ;
      }

   signal = SIGBREAKF_CTRL_F ;

   sig = signal | SIGBREAKF_CTRL_C ;

   MMAddNode(&mynode) ;

   do  {
      mask = Wait(sig) ;
      printf("Rid Function called. %d bytes wanted\n",amount) ;
      } while (!(mask & SIGBREAKF_CTRL_C)) ;

   MMRemNode(&mynode) ;

   CloseLibrary(MMBase) ;
   }
