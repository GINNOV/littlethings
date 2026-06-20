#include <Orion.h>
#include <graphics/gfx.h>

/* Example1: This example allocates some memory and 'forgets'
**           to free it.
*/

void main(void){
VOID *pool;
VOID *mem;

   AllocVec(100,MEMF_CLEAR);        //Various allocations will be left behind
   AllocMem(200,MEMF_CHIP);
   AllocBitMap(50,10,2,BMF_CLEAR,0);
   pool=CreatePool(MEMF_ANY,800,150);
   AllocPooled(pool,140);
   AllocPooled(pool,110);
   AllocPooled(pool,120);

   AllocVec(0,MEMF_ANY);      //Allocating 0 Size

   mem=AllocMem(69,MEMF_ANY);
   FreeMem(mem,42);           //Freeing the wrong size
}
