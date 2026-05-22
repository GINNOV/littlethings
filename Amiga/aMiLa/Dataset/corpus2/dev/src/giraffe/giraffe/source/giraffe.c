/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: giraffe.c                               */
/*    |< |      created: June 14, 1995                        */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/resident.h>

#include "common.h"
#include "layers.h"
#include "giraffebase.h"
#include "giraffe_rev.h"


/*
 *
 */

/* library romtag strings defined by REVCO header file */
char giraffe_name[] = "giraffe.library";
char giraffe_id[]   = VSTRING;

/*
 * This external data is all present in 
 * giraffe.library.asm.
 *
 *  funcTable  -- This is the table of library function vectors.
 *                exec takes this array and makes the jump
 *                table below the library base pointer.
 *
 *  dataTable  -- ?
 *
 *  initRoutine -- This function is called during OpenLibrary() in
 *                 order for the library to start up. This function
 *                 eventually calls InitLibrary() located in this
 *                 file.
 */
extern void    (*funcTable[])();
extern UWORD   dataTable[];
struct Library *initRoutine();


/*
 * The autoinit structure for creating
 * the GiraffeBase structure.
 */
struct { 
  ULONG wilma;
  void (**betty)();
  UWORD *barney;
  struct Library *(*fred)();
} Init={sizeof(struct GiraffeBase),funcTable,dataTable,initRoutine};


/*
 * The ROMTAG structure for linking the
 * library into the system. This library is
 * setup for autoinitialization. 
 */

struct Resident library_tag={
  RTC_MATCHWORD,
  &library_tag,
  NULL,
  RTF_AUTOINIT,
  1,
  NT_LIBRARY,
  0,
  giraffe_name,
  VSTRING,
  (APTR)&Init
  };

/*
 *  External Pointers to Libraries                 
 *   The space for these pointers is
 *  allocated in giraffe.library.asm
 *  in the data segment.
 */

extern struct Library *UtilityBase,*GfxBase;
extern struct GiraffeBase *GiraffeBase;

/*
 * giraffe resource tracking lists and arbitration.
 *
 * resources  -- This array of lists maintains objects
 *               that have been free'd and may be used
 *               again. Before more memory is allocated,
 *               these lists are checked.
 *
 * inuse      -- These lists are similar to the resources
 *               lists, but they list objects that are 
 *               currently in use. If these lists are not
 *               empty when the library is closed, then
 *               an alert is sent to exec. This alert
 *               indicates that some lazy program has been
 *               at work.
 *
 * resource_lock -- This semaphore is simply for locking the
 *                  lists. This lock is obtained by allocobject()
 *                  and freeobject().
 */

struct MinList resources[GT_TOTAL];
struct MinList inuse[GT_TOTAL];
struct SignalSemaphore resource_lock;


void initmm( void );
void dumpmm( void );
void *alloc24( void );
void free24( void * );


BOOL InitLibrary( void )
/* initialization of library called during OpenLibrary() call */
{
  int i;

  initmm();

  /*
   * Prepare the resource lists and the
   * semaphore.
   */
  InitSemaphore(&resource_lock);
  for(i=0;i<GT_TOTAL;i++)
    { NewList(&resources[i]);
      GiraffeBase->resources[i]=&resources[i];
      NewList(&inuse[i]);
      GiraffeBase->inuse[i]=&inuse[i];
    }

  /*
   * Open all the libraries required to
   * use giraffe.library. These are:
   *   graphics.library -- any version for OpenFont().
   *   utility.library  -- any version so that I can use taglists.
   *
   * The graphics driver is a special case.
   * All library dependent functions have been
   * moved into driver.c/driver.h. This separation
   * will allow me to migrate to CyberGraphX if
   * that is ever to my advantage.
   */
  if(GfxBase=(struct Library *)OpenLibrary("graphics.library",0))
    {
      if(UtilityBase=(struct Library *)OpenLibrary("utility.library",0))
	{
	  if(opendriver())
	    {
	      init_font();

	      return(TRUE);
	    }
	  CloseLibrary(UtilityBase);
	}
      CloseLibrary(GfxBase);
    }
  return(False);
}

/*
 * Closing the library.
 *
 * free_resource_list()  -- This function frees any objects that
 *                          have not been free'd by an erran program.
 *                          If any are found, the it triggers a
 *                          recoverable alert so that the programmer
 *                          becomes aware of it.
 *
 * ShutDownGiraffe()    -- This function is complementary to InitLibrary().
 *                         It is called by exec during library expunge
 *                         to free all remaining resources.
 */

void free_resource_list( void )
/* frees resource memory indicated by tracking. */
{ int i,j;
  struct object_header *obj;

  for(i=0;i<GT_TOTAL;i++)
    {
      /* The first are free'd resources */
      while(obj=(struct object_header *)RemHead(&resources[i]))
        freem(obj);

      /* These lists are for objects not properly free'd by
	 the client.  Recoverable alert is sent for debugging
	 purposes. */
      for(j=0;obj=(struct object_header *)RemHead(&inuse[i]);j++)
	freem(obj);
      if(j)Alert(ALERT_GIRAFFE|(i<<8)|j);
    }
  return;
}

void ShutDownGiraffe( void )
/* free all resources before library is removed from system. */
{
  free_resource_list();
  dumpmm();
  shutevents();
  closedriver();
  CloseLibrary(UtilityBase);
  CloseLibrary(GfxBase);
  return;
}


/*
 * Object allocation functions.
 *
 * allocobject() -- Used to create any one of the standard
 *                  objects for the library. These objects
 *                  have a header to identify them. (see common.h)
 *                  They also include a linked-list node for the
 *                  purpose of tracking their life-cycle.
 *
 * freeobject()  -- This attempts to release an object. If there
 *                  are only a few in the resource lists, then
 *                  it will link them in. If the pointer is bad
 *                  then the function triggers a recoverable alert
 *                  in order to inform the user.
 *
 * checkobject() -- This function is for checking the validity
 *                  of an object pointer. See common.h for 
 *                  specific information on how the header is
 *                  initialized.
 */


void *allocobject( UBYTE type, int size )
/* allocated a typed object of given size */
{
  struct object_header *obj;

  /*
   * Round up to the nearest long
   * size.
   */
  size=(size&(~3))+(size&3?4:0);

  /*
   * Gain exclusive rights to
   * the resource lists.
   */
  ObtainSemaphore(&resource_lock);

  /* 
   * First of all check the free resource lists.
   * Be sure to check that the size is correct.
   * In the case of layers objects, there
   * may be differences.
   */
  if(type&&type<=GT_TOTAL)
    {
      for(obj=(struct object_header *)resources[type].mlh_Head;obj->node.mln_Succ;obj=(struct object_header *)obj->node.mln_Succ)
	if(obj->size==size)
	  {
	    /*
	     * Transfer the object to the
	     * inuse list.
	     */
	    Remove(obj);
	    AddHead(&inuse[type],obj);
	    ReleaseSemaphore(&resource_lock);

	    /*
	     * Revalidate the object header.
	     */
	    obj->match=(USHORT)(obj+1);
	    return(obj+1);
	  }
    }
      
  /*
   * If no object was found in the
   * resource lists, then allocate a
   * new one from the free memory pool.
   */
  if(obj=(struct object_header *)allocm(sizeof(struct object_header)+size))
    {
      /*
       * Initialize and validate the
       * header.
       */
      obj->type=type;
      obj->size=size;
      obj->match=(USHORT)(obj+1);

      /*
       * Link the object into the appropriate
       * resource tracking list.
       */
      AddHead(&inuse[type],obj);
      ReleaseSemaphore(&resource_lock);

      return(obj+1);
    }

  /*
   * Allocation failed.
   * Should set off an unrecoverable
   * alert because some the functions
   * don't actually check for a 
   * NULL pointer.
   */
  ReleaseSemaphore(&resource_lock);
  return(NULL);
}

void freeobject( void *ptr )
/* place object into list of free objects */
{ struct object_header *obj;


  /*
   * Move the pointer to the object
   * header.
   */
  obj=((struct object_header *)ptr)-1;

  /*
   * Double check the validity 
   * of the pointer.
   */
  if(obj->match==(USHORT)(ptr))
    {
      ObtainSemaphore(&resource_lock);

      /*
       * Transfer the object to the
       * free'd resource list. Also,
       * invalidate the pointer as 
       * an object by placing NULL into
       * the match field. This keeps 
       * an errant program from using
       * this pointer if it has forgotten
       * that it has been dropped.
       */
      obj->match=NULL;
      Remove(obj);
      if(obj->type&&obj->type<=GT_TOTAL)AddHead(&resources[obj->type],obj);
      else freem(obj); 

      ReleaseSemaphore(&resource_lock);
    }
  else Alert(ALERT_BAD_OBJECT);

  return;
}

void *checkobject( void *ptr, UBYTE type )
/* type check an object. send recoverable alert if failed */
{
  struct object_header *obj;

  /*
   * Check the validity of an object pointer.
   * Return the pointer if it is okay,
   * otherwise trigger a recoveralbe alert
   * and pass NULL.
   */
  obj=((struct object_header *)ptr)-1;
  if((obj->match!=(USHORT)(ptr))||(obj->type!=type))
    { Alert(ALERT_GIRAFFE|(type<<8));
      return(NULL);
    }
  return(ptr);
}



/* memory management will go here. */

  struct tag {
    struct tag *match;
    int size;
  }*tag;

void *allocm( int size )
{
  size += sizeof(struct tag);
  if(tag=(struct tag *)AllocMem(size,MEMF_PUBLIC|MEMF_CLEAR))
    {
      tag->match = tag;
      tag->size  = size;
      return tag+1;
    }
  return NULL;
}

void freem( void *ptr )
{
  struct tag *tag;

  tag = ((struct tag *)ptr)-1;
  if(tag==tag->match)
    FreeMem(tag,tag->size);
  return;
}

/*
 * Global variables for quick node allocation.
 * 
 * root12/root24 -- Giraffe begins with blocks allocated
 *                  for 12 and 24 byte nodes.  Each block
 *                  can provide 1000 or 500 nodes.  More
 *                  blocks are added as needed.
 *
 * hblock12p/hblock24p  -- These pointers indicate the current
 *                         block for allocating nodes.  It will
 *                         always be the first in the list with
 *                         a free node.
 */

struct heap_block root12,root24,*hblock12p,*hblock24p;

/*
 * The memory management functions.
 *
 * initmm()      -- Prepares the structures during library
 *                  creation.  Starts with one block for
 *                  each node size.
 * dumpmm()      -- Run during library expunge.  This frees
 *                  all resources.  Any nodes not accounted 
 *                  for will result in a recoverable Alert
 *                  message.
 * alloc12()/free12()  -- Quickly allocates and frees 12 bytes.
 *                        These are used for region rectangle
 *                        nodes.
 * alloc24()/free24()  -- Same as the previous two.  These are 
 *                        used for clipping rectangles and 
 *                        nodes in layer semaphores.
 */

void initmm( void )
{
  int i;
  for(i=0;i<BLOCK_SIZE_BYTES/24;i++)
    {
      root12.array[6*i]   = BLOCK_FREE;
      root12.array[6*i+3] = BLOCK_FREE;
      root24.array[6*i]   = BLOCK_FREE;
    }
  root12.free = BLOCK_SIZE_BYTES/12;
  root24.free = BLOCK_SIZE_BYTES/24;
  root12.heapp = &(root12.array[0]);
  root24.heapp = &(root24.array[0]);
  root12.next = root24.next = NULL;

  hblock12p = &root12;
  hblock24p = &root24;

  return;
}

void dumpmm( void )
{
  struct heap_block *hblock,*next;

  if(root12.free!=(BLOCK_SIZE_BYTES/12))Alert(ALERT_MEMORY_LEAK);
  for(hblock=root12.next;hblock;hblock=next)
    {
      next = hblock->next;
      if(hblock->free!=(BLOCK_SIZE_BYTES/12))Alert(ALERT_MEMORY_LEAK);
      freem(hblock);
    }

  if(root24.free!=(BLOCK_SIZE_BYTES/24))Alert(ALERT_MEMORY_LEAK);
  for(hblock=root24.next;hblock;hblock=next)
    {
      next = hblock->next;
      if(hblock->free!=(BLOCK_SIZE_BYTES/24))Alert(ALERT_MEMORY_LEAK);
      freem(hblock);
    }

  return;
}

void *alloc24( void )
{
  int i;
  void *ptr;
  ulong *search;

  ObtainSemaphore(&resource_lock);

  /*
   * First, get the pointer to a free
   * 12 byte block, then immediately
   * queue up the next one.
   */

  if(!hblock24p->free)
    {
      /*
       * First check any other blocks in the
       * list.
       */
      while(hblock24p->next)
	{
	  hblock24p = hblock24p->next;
	  if(hblock24p->free)break;
	}

      if(!(hblock24p->next||hblock24p->free))
	{
	  /*
	   * The block has been emptied, so
	   * allocated a new one and link
	   * into the list.
	   */

	  if(hblock24p->next = allocm(sizeof(struct heap_block)))
	    { 
	      hblock24p        = hblock24p->next;
	      hblock24p->free  = (BLOCK_SIZE_BYTES/24);
	      hblock24p->heapp =  &hblock24p->array[0];
	      for(i=0;i<BLOCK_SIZE;i+=6)hblock24p->array[i] = BLOCK_FREE;
	    }
	}
      else Alert(ALERT_NOMEMORY);
    }

  hblock24p->free--;
  ptr=(void *)(search=hblock24p->heapp);
  for(search = hblock24p->heapp+6;*search!=BLOCK_FREE;search+=6);
  hblock24p->heapp = search;

  ReleaseSemaphore(&resource_lock);

  return ptr;
}

void free24( void *ptr )
{
  int REPLACE = TRUE;
  int offset;
  struct heap_block *hblockp;

  ObtainSemaphore(&resource_lock);

  /*
   * Find the block to which
   * this pointer belongs.
   */
  for(hblockp=&root24;hblockp;hblockp=hblockp->next)
    {
      if(hblockp==hblock24p)REPLACE=FALSE;

      offset = ((int)ptr) - ((int)(&(hblockp->array[0])));
      if(offset>=0 && offset<BLOCK_SIZE_BYTES)
	{
	  *((ulong *)ptr) = BLOCK_FREE;
	  hblockp->free++;
	  if(((int)ptr)<((int)hblockp->heapp))hblockp->heapp=(ulong *)ptr;
	  if(REPLACE&&hblockp->free>MINIMUM_BLOCKS)hblock24p=hblockp;
	  break;
	}
    }
  if(!hblockp)Alert(ALERT_BAD_POINTER24);

  ReleaseSemaphore(&resource_lock);

  return;
}

void *alloc12( void )
{
  int i;
  void *ptr;
  ulong *search;

  ObtainSemaphore(&resource_lock);

  /*
   * First, get the pointer to a free
   * 12 byte block, then immediately
   * queue up the next one.
   */

  if(!hblock12p->free)
    {
      /*
       * First check any other blocks in the
       * list.
       */
      while(hblock12p->next)
	{
	  hblock12p = hblock12p->next;
	  if(hblock12p->free)break;
	}

      if((!hblock12p->next)&&(!hblock12p->free))
	{
	  /*
	   * The block has been emptied, so
	   * allocated a new one and link
	   * into the list.
	   */

	  if(hblock12p->next = allocm(sizeof(struct heap_block)))
	    {
	      hblock12p = hblock12p->next;
	      hblock12p->free = (BLOCK_SIZE_BYTES/12);
	      hblock12p->heapp = &hblock12p->array[0];
	      for(i=0;i<BLOCK_SIZE;i+=3)hblock12p->array[i] = BLOCK_FREE;
	    }
	}
      else Alert(ALERT_NOMEMORY);
    }

  hblock12p->free--;
  ptr=(void *)(search=hblock12p->heapp);
  for(search = hblock12p->heapp+3;*search!=BLOCK_FREE;search+=3);
  hblock12p->heapp = search;

  ReleaseSemaphore(&resource_lock);
  return ptr;
}

void free12( void *ptr )
{
  int REPLACE = TRUE;
  int offset;
  struct heap_block *hblockp;

  ObtainSemaphore(&resource_lock);

  /*
   * Find the block to which
   * this pointer belongs.
   */
  for(hblockp=&root12;hblockp;hblockp=hblockp->next)
    {
      if(hblockp==hblock12p)REPLACE=FALSE;

      offset = ((int)ptr) - ((int)(hblockp->array));
      if(offset>=0 && offset<BLOCK_SIZE_BYTES)
	{
	  *((ulong *)ptr) = BLOCK_FREE;
	  hblockp->free++;
	  if(((int)ptr)<((int)hblockp->heapp))hblockp->heapp=(ulong *)ptr;
	  if(REPLACE&&hblockp->free>MINIMUM_BLOCKS)hblock12p=hblockp;
	  break;
	}
    }
  if(!hblockp)Alert(ALERT_BAD_POINTER12);

  ReleaseSemaphore(&resource_lock);

  return;
}


/* giraffe.c */





