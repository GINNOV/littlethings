
/****************************************************
 *                KNIGHTMEMORY.C
 *
 * Queue Management software for the land of Quboids
 *
 * Written by Kel & Billy 9-Apr-88
 *
 */

#include "header:knightlore.h"
#include "header:knightmemory.h"

#define FRONTOF(A,B) (A->fX<=B->nX || A->fY<=B->nY || A->fZ>=B->nZ)

struct KnightAtom *KnightList;
struct KnightAtom *FreeList;

void InsQue(head,elem)
struct SCH_queue *head,*elem;
{
#ifdef DEBUG
  printf("Inserting %s before %s\n",elem->ID,head->ID);
#endif
  elem->flink=head;
  elem->blink=head->blink;
  head->blink->flink=elem;
  head->blink=elem;
}

/*
 * Remove elem from the queue it resides in
 */
 
struct SCH_queue *RemQue(elem)
struct SCH_queue *elem;
{
  register struct SCH_queue *ftemp,
  	    	            *btemp;                
#ifdef DEBUG
  printf("Removing %s\n",elem->ID);
#endif
  ftemp=elem->flink;
  btemp=elem->blink;
  ftemp->blink=btemp;
  btemp->flink=ftemp;
  return elem;
}
void AllocateAtoms()
{
    struct KnightAtom *Knight;
    int i;
    FreeList=(struct KnightAtom *)AllocMem(sizeof(struct KnightAtom) *
                                              MAXATOMS,MEMF_CLEAR);
    Knight=FreeList->flink=FreeList->blink=FreeList;
    Knight->ID="Head Of Free List";
    Knight++;
    for(i=1;i<MAXATOMS;i++) {
      Knight->ID="NULL";
      InsQue(FreeList,Knight++);
    }
    KnightList=GetAnAtom();
    KnightList->ID="Head of Atom List";
    KnightList->flink=KnightList->blink=KnightList;
#ifdef DEBUG
    printf("\n\n\n\n\n\n\n\n Here we go !!!!!!!!\n");
#endif
} 
void FreeAtoms()
{
   if(FreeList) FreeMem(FreeList,sizeof(struct KnightAtom) * MAXATOMS);
}

/* Check Rectangles  */
int CheckRectangles(x1,y1,x2,y2,x3,y3,x4,y4)
int x1,y1,x2,y2,x3,y3,x4,y4;
{
   if(x2<x3 || y2<y3 || x4<x1 || y4<y1) return 0;
   return 1;
}


/* This wee funstion will take THE list of knightatoms
 * and a pointer to a member of that list and order
 * THAT ATOM in the list, relative to other atoms
 * which clash with it in the 2D domain (henceforth called Flat-Land)
 */

void PrimeList(elem)
struct KnightAtom *elem;
{
   register struct KnightAtom *Crnt,*Atom,*Temp,*Probe;

#ifdef DEBUG
   printf("Going in to Prime list with %s\n",elem->ID);
#endif
   Atom=elem;
   Atom->flink=Atom->blink=Atom;	/* Make atom a queue */
   Crnt=KnightList->blink;		/* Start at front */
   while(Crnt!=KnightList) {
      Temp=Crnt->blink;
#ifdef DEBUG
      printf("Comparing %s with %s\n",Atom->ID,Crnt->ID);
      printf("%s %2d %2d %2d\n",Atom->ID,Atom->fX,Atom->fY,Atom->fZ);
      printf("%s %2d %2d %2d\n",Crnt->ID,Crnt->nX,Crnt->nY,Crnt->nZ);
#endif
      if (CheckRectangles(Atom->Xl,Atom->Yt,Atom->Xr,Atom->Yb,
                          Crnt->Xl,Crnt->Yt,Crnt->Xr,Crnt->Yb)) {
         if(FRONTOF(Atom,Crnt)){
#ifdef DEBUG
            printf("%s is in front\n",Atom->ID);
#endif
            /* Atom is definitely in front */
            InsQue(Atom->flink,RemQue(Crnt));
         }
         else{
          /* Atom is behind */
#ifdef DEBUG
            printf("%s is in Behind \n",Atom->ID);
#endif
            (void)RemQue(Crnt);
            Crnt->flink=Crnt->blink=Crnt;
            InsQue(Atom,Crnt);
            Atom=Crnt;
         }
      }
      else {
#        ifdef DEBUG
            printf("No hit in flatland\n");
#        endif
         for(Probe=Atom->flink;Probe!=Atom;Probe=Probe->flink){
            if(FRONTOF(Crnt,Probe)){
               InsQue(Probe,RemQue(Crnt));
               break;
            }
         }
      }
      Crnt=Temp;
   }
   Atom->blink->flink=KnightList->flink;	/* Insert the queue Atom */
   KnightList->flink->blink=Atom->blink;	/* at head of KnightList */
   KnightList->flink=Atom;
   Atom->blink=KnightList;
#ifdef DEBUG
   printf("Coming out of Prime : ");
   for(Atom=KnightList->flink;Atom!=KnightList;Atom=Atom->flink){
      printf("%s -> ",Atom->ID);
   }
   printf("\n");
#endif
}
