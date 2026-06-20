/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: layers.c                                */
/*    |< |                                                    */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/
/*  This defines the functions that replace the layer.library */
/* for creating a window system.  The layers provide for a    */
/* tree structure for creating a gui.                         */
/*  contents:                                                 */
/*    1. sending input.device events. (private)               */
/*    2. arbitrating layer control. (public/private)          */
/*    3. maintaining the layer hierarchy. (private)           */
/*    4. layer clipping maintenance. (private)                */
/*    5. mapping functions. (public)                          */
/*    6. creation/destruction operations. (public)            */
/*    7. layer modification. (public)                         */
/*    8. layer queries. (public)                              */
/*    9. graphics primitive stubs. (public)                   */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <exec/memory.h>
#include <devices/input.h>
#include <devices/inputevent.h>

#include <egs/egs.h>
#include <egs/egsblit.h>
#include <egs/proto/egsblit.h>
#include <egs/pragmas/egsblit_pragmas.h>

#include "layers.h"

struct G_GC gc_copy = G_SimpleGC(1,2);
extern struct Library *EGSBlitBase;

extern struct GarpBase *GarpBase;

/*
 * The first are functions for communication with
 * the input.device in order to propagate a layer
 * exposure event along the chain.
 */



/*
 *  The global variables.
 *
 * 
 * ioport -- This message port is used to receive confirmation
 *          of an event sent to the input.device.  For the time
 *          being, I've just taken a signal bit for my own use
 *          with no regard to how it should be handled.  So far
 *          it has worked, but I don't like it.
 *           Possible solutions are:
 *           a) Allocate one bit on the fly.
 *              .e.g.
 *              ioport->mp_SigTask = FindTask(0);
 *              ioport->mp_SigBit  = AllocSignal(ioport->mp_SigTask);
 *              ...
 *              FreeSignal(ioport->mp_SigTask,ioport->mp_SigBit);
 *
 *           b) I could find some signal that has been reserved for
 *              a library that I'm replacing.  Maybe the graphics.library
 *              or intuition.  I'm not sure what EGS does however.
 * 
 *           c) I could use the semaphore flag, since the task will
 *              not be on any waiting list for a semaphore.
 *
 *   ioreq -- This message is that actual access to the input.device.
 *           The product of the OpenDevice() call, this message is used
 *           to send IND_WRITEEVENT requests.
 *
 *   iolock -- This semaphore is just to arbitrate ownership of the 
 *            i/o junk.  Only one user at a time.
 *
 *
 *   The input events pointers.
 *    exposure - This is filled when the first exposure event is signaled.
 *               The event address is set to the stack where the 
 *               exposure array is to be filled.  If the stack has
 *               already been partially filled by a resize array, then
 *               this array is automatically terminated.
 *
 *    resize   - This pointer is filled when an resize event is indicated
 *               by the layer arrangement commands.  I should look into 
 *               these since I'm not sure if the first layer is included.
 *
 *    chain,last - This pointers maintain the first and last event in
 *                the event chain that will eventually be passed to the
 *                input.device.
 *
 *   NOTE: This whole thing could probably be simplified since there
 *         are a total of three events that can be sent at the moment.
 *         But since it works, I will leave it this way.
 *
 *  The exposure/resize arrays.
 *
 *   When layers become exposed, then they are placed into the exposure
 *   array which is passed to the input.device and all of its linked
 *   handlers. The format for the array mimics the tree structure of
 *   the layers, so that the layers can be redrawn in proper order.
 *   The format works as follows:
 *
 *     If a layer is exposed/resized, then the function signalexposure()
 *    is called with the layer as its argument.  The layer is immediately
 *    placed in the stack at stackptr and the pointer is incrmented.
 *     If the layer has any children, then it should call nestarray(). 
 *    This function places '1' into the stack and increments.  Since this
 *    value cannot be a pointer to an array, it is easily identified
 *    as a special tag.  The children then are placed in order onto the
 *    array if exposure occurs.  The children might have further branches
 *    indicated by '1'.
 *     When the end of the children list is reached. The function unnestarray()
 *    is called which places a '0' in the array.  This marker indicates
 *    that nesting is closed or if there has not been any nesting, then
 *    it serves to mark the end of the array.
 *
 *    Here's a little example of how it all works.
 *
 *    Layer A has two children B and C.  These layers in turn have
 *   children labeld, b1,b2,b3 for layer B and c1 for layer C.  If
 *   all of these layers are exposed, then the array will be as follows:
 * 
 *   array = { A, 1, B, 1, b1, b2, b3, 0, C, 1, c1, 0, 0, 0 }
 *
 *    The difference for a resize array is that the layer
 *   pointers are immediately followed by the new dimensions
 *   of the layers.
 *
 *   list of functions:
 *    nestarray()   -- marks that a new branch is being exposed.
 *    unnestarray() -- marks then end of layer branch.
 *    flusharray()  -- resets the array. used by lockio().
 *    terminatearray() -- places '0' on the current array to mark its end.
 *                        prepares nest counter for a new array.
 *
 *    signalevent()  - used by the following functions to link a new
 *                     event into the chain.
 *    signalexposure() - puts the layer on the stack.
 *    signalresize()   - puts the layer onto the stack.
 *
 */


int    nest;
ULONG  stack[1000],*stackptr;

struct MsgPort         *ioport;
struct IOStdReq        *ioreq=NULL;
struct SignalSemaphore iolock;
struct InputEvent      *chain,*last;
struct InputEvent      *exposure,*resize;




BOOL initevents( void )
{
  InitSemaphore(&iolock);

  /*
   * This function initializes the connection with
   * the input.device for announcing events for layers.
   *
   * First it creates the ioport, which is used by any
   * task which calls giraffe.library.  The proper signalling
   * is aquired when the task calls lockio().
   */
   

  if(ioport=(struct MsgPort *)AllocMem(sizeof(struct MsgPort),MEMF_PUBLIC|MEMF_CLEAR))
    {
      ioport->mp_Node.ln_Type = NT_MSGPORT;
      ioport->mp_Node.ln_Pri  = 0;
      ioport->mp_Node.ln_Name = Null;
      ioport->mp_Flags        = NULL;
      ioport->mp_SigBit       = 0;
      ioport->mp_SigTask      = Null;
      NewList(&(ioport->mp_MsgList));
	
      /*
       * The next step is to create the io request block
       * for communicating with the input.device.
       */
      if(ioreq=(struct IOStdReq *)AllocMem(sizeof(struct IOStdReq),MEMF_PUBLIC|MEMF_CLEAR))
	{
	  ioreq->io_Message.mn_Node.ln_Type = 0;
	  ioreq->io_Message.mn_Node.ln_Pri  = 0;
	  ioreq->io_Message.mn_Node.ln_Name = Null;
	  ioreq->io_Message.mn_ReplyPort    = ioport;
	  ioreq->io_Message.mn_Length       = sizeof(struct IOStdReq);
		
	  /*
	   * Finally, we can open the connection
	   * with the input.device.
	   */
	  if(!OpenDevice("input.device",Null,ioreq,0))
	    {
	      /*
	       * From now on the only
	       * message sent to the input.device
	       * is a request to pass an chain
	       * of events to all the input handlers.
	       */
	      ioreq->io_Length  = sizeof(struct InputEvent);
	      ioreq->io_Command = IND_WRITEEVENT;
	      
	      return(True);
	    }
	  FreeMem(ioreq,sizeof(struct IOStdReq));
	}
      FreeMem(ioport,sizeof(struct MsgPort));
    }
  return(Null);
}

void shutevents( void )
{
  /*
   * Close connection to the input.device and 
   * free the memory allocated for the
   * iorequest and ioport.
   */
  if(ioreq)
    {
      CloseDevice(ioreq);
      FreeMem(ioreq,sizeof(struct IOStdReq));
      FreeMem(ioport,sizeof(struct MsgPort));
    }
  return;
}

/*
 * Macros for creating an
 * event object.
 */

#define newievent() ((struct InputEvent *)allocobject(GT_InputEvent, \
					       sizeof(struct InputEvent)))
#define disposeievent(event) (freeobject(event))


/*
 * signalevent()
 *  This function maintains the event chain
 * until it is passed to the input.device.
 * It is called by signalexposure(), signalresize()
 * and by many layers functions as signalfocus().
 */

void signalevent( UBYTE class, APTR data )
/* set an event in the chain to signal a layer exposure. */
{
  /*
   * If chain is empty, then this is the
   * first event.
   */
  if(chain)
    { if(!(last->ie_NextEvent=newievent()))return;
      last=last->ie_NextEvent;
    }
  else if(!(chain=last=newievent()))return;

  /*
   * set the event type and
   * the data pointer.
   */
  last->ie_NextEvent = NULL;
  last->ie_Class     = class;
  last->ie_position.ie_addr = data;

  return;
}

/*
 * Add layer to the exposure array.
 */

void signalexposure( struct layer *layer )
{
  if(!exposure)
    { signalevent(IECLASS_EXPOSURE,(APTR)stackptr);
      exposure=last;
    }
  *(stackptr++) = (ULONG)layer;

  return;
}

/*
 * Add layer to the resize array.
 */

void signalresize( struct layer *layer, ULONG width, ULONG height )
{
  if(!resize)
    { signalevent(IECLASS_SIZELAYER,(APTR)stackptr);
      resize=last;
    }
  *(stackptr++) = (ULONG)layer;
  *(stackptr++) = width;
  *(stackptr++) = height;
  return;
}


/*
 * Mark the stack when
 * children of a layer are
 * being added.
 */

void nestarray( void )
{
  nest++;
  *(stackptr++)=1;
  return;
}

/*
 * Mark the end of one
 * branch of the layer tree.
 */

void unnestarray( void )
{
  nest--;
  if(*(stackptr-1)!=1)
    *(stackptr++)=NULL;
  else *(--stackptr)=NULL;
  return;
}

/*
 * Terminate any existing array, so
 * that another may be created.
 */

void terminatearray( void )
{
  while(nest)unnestarray();
  nest=1;  /* reset nest */
  return;
}

/*
 * Rest all the arrays when
 * someone new has taken
 * over the io.
 */

void flusharray( void )
{
  nest     = 1;
  exposure = NULL;
  resize   = NULL;
  stackptr = stack;

  return;
}


void lockio( void )
/* grab the input.device ioreq structure to signal layer exposure events. */
{
  if(!ioreq)initevents();

  /*
   * Grab hold of the iolock, then
   * reset the events.
   */
  ObtainSemaphore(&iolock);
  chain = last = NULL;
  flusharray();

  /*
   * Attach this task to the
   * io reply port.
   */
  ioport->mp_SigTask = (struct Task *)FindTask(NULL);
  ioport->mp_SigBit  = AllocSignal(ioport->mp_SigTask);

  return;
}

void unlockio( void )
/* signal any pending exposure events and release the ioreq. */
{ struct InputEvent *next;
  
  terminatearray();

  /*
   * I guess you have to send the events one
   * at a time.  So remove them from the list and
   * send to input.device.  When the message is
   * returned, then dispose of the event.
   */
  while(chain)
    {
      next=chain->ie_NextEvent;
      chain->ie_NextEvent = NULL;

      ioreq->io_Data=(APTR)chain;
      DoIO(ioreq);
      while(GetMsg(ioport));
      disposeievent(chain);

      chain=next;
    }

  /*
   * Detach the current task
   * from the ioport. Then release
   * everything for the next bum.
   */
  FreeSignal(ioport->mp_SigTask,ioport->mp_SigBit);
  ioport->mp_SigTask=NULL;
  ReleaseSemaphore(&iolock);

  return;
}

/*
 * This function is not actually used to my knowledge,
 * but I'll leave it in for the time being.
 */

void abortio( void )
/* signal any pending exposure events and release the ioreq. */
{ struct InputEvent *next;

  terminatearray();
  
  /*
   * Dispose of all events allocated.
   */
  while(chain)
    {
      next=chain->ie_NextEvent;
      chain->ie_NextEvent=NULL;
      disposeievent(chain);
      chain=next;
    }

  /*
   * Detach the current task from the
   * the ioport. Then release the iolock
   * for the next sucker.
   */
  FreeSignal(ioport->mp_SigTask,ioport->mp_SigBit);
  ioport->mp_SigTask=NULL;
  ReleaseSemaphore(&iolock);

  return;
}



    



/*
 * Layer resource arbitration functions.
 *
 *  Each layer has two semaphores.  One is shared by
 * all the layers in the tree and is used for both
 * shared and exclusive locks.  The other is shared only
 * by layers which share a cliplist.  That is, it is
 * created by a normal layer and used by all non-clipped
 * children.
 *
 *  When a given layer is locked, then it puts
 * a shared lock on the root semaphore, and an
 * exclusive lock on the local semaphore.  This 
 * allows simultaneous graphical tasks, but keeps
 * the tree from changing in any way.
 *
 *  If the tree needs to changed, then an exclusive
 * lock is put on the root semaphore and all other
 * access to the layers is automatically blocked.
 * I'm not sure if exec semaphores can already do
 * what mine do, but I've already forgotten why
 * I made my own in the first place. (It's not
 * because I wanted to.)
 *
 *
 * The functions for semaphores are:
 *  initlayerlock() -- used by openlayer() to prepare semaphores for use.
 *  queue()  -- When a semaphore is released, this function signals
 *             the next layer trying to get a lock.(if any)
 *  locklayer()    -- This function obtains a shared lock.  If the task
 *                    already has an exclusive lock, then it is auto-
 *                    matically promoted to the same.
 *  locklayers()   -- This function obtains an exclusive lock.  It must
 *                    not be used if a shared lock has already been 
 *                    obtained.
 *  unlocklayer()  -- Releases a shared lock.
 *  unlocklayers() -- Releases an exclusive lock.
 */

/*
 * WARNING!!  There is a potential for lock-up.
 *   it only requires to tasks.
 *      1) Task A gets a shared lock on the root.
 *      2) Task B requests an exclusive lock and now
 *         it has to wait.
 *      3) Task A tries to get another lock on the root
 *         and it has to wait, because Task B is already
 *         waiting in line.  So we need another list
 *         which maitains who has a shared lock. ARRGHH!!
 */

void initlayerlock( struct layerlock *lock )
{
  lock->usecount    = 0;
  lock->owner       = NULL;
  lock->next.client = NULL;
  lock->queue.first = lock->queue.last = NULL;
  lock->shared.first = lock->shared.last = NULL;
  return;
}

#define allocrequest() ((struct layerrequest *)alloc12())
#define freerequest(req) (free12((void *)(req)))

/* l = list, r = request, p = previous request. */
#define remrequest(l,r,p) if(p)    \
		            {      \
		              if(!((p)->next = (r)->next))   \
			      (l).last = last;               \
		            }                                \
		          else                               \
		            {                                \
		              if((r)->next)                  \
				(l).first = (r)->next;       \
		              else (l).first = (l).last = NULL; \
		            }                                   \



void releaselock( struct layerlock *lock )
{
  struct layerrequest *request,*last;
  struct Task *task;

  lock->usecount--;

  /*
   * If this is a shared lock, then
   * search the list and drop the flag
   * count.
   */
  if(!lock->owner)
    {
      task = (struct Task *)FindTask(NULL);

      last = NULL;
      for(request=lock->shared.first;request;request=request->next)
	{
	  if(request->client==task)
	    {
	      /*
	       * Drop the flags.  If this
	       * value drops to zero, then
	       * remove this node from the
	       * list.
	       */
	      if(!(--request->flags))
		{
		  remrequest(lock->shared,request,last);
		  freerequest(request);
		}
	      break;
	    }
	  last = request;
	}
    }

  /*
   * If the usecount has reached zero then
   * the lock is undone, so we should check
   * for the next task that wants to
   * use it.
   */
  if(!lock->usecount)
    {
      /*
       * Be sure this
       * gets cleared.
       */
      lock->owner = NULL;

      if(lock->next.client)
	{
	  /*
	   * Signal the next task waiting
	   * on deck.
	   */
	  Signal(lock->next.client,SEMAPHORE_SIGNALF);
	  
	  if(!lock->next.flags)
	    {
	      lock->usecount = 1;
	      /*
	       * The lock is shared, so signal anyone
	       * else in the queue who wants a shared
	       * lock, until the list is empty or someone
	       * who wants an exclusive lock is found.
	       * Clear the ownership field to indicate a
	       * shared lock.
	       */

	      /*
	       * Create the list of shared owners.
	       */
	      if(request = allocrequest())
		{
		  request->next   = NULL;
		  request->client = lock->next.client;
		  request->flags  = 1;
		  lock->shared.first = lock->shared.last = request;
		}
	      else Alert(ALERT_SEMAPHORE_ERROR);
	       
	      while(request=lock->queue.first)
		{
		  /*
		   * remove the head of the 
		   * queue.
		   */
		  if(!(lock->queue.first = request->next))
		    lock->queue.last = NULL;
		  else
		    request->next = NULL;
		    
		  /*
		   * this request is for an exclusive lock, so
		   * break out of the loop.
		   */
		  if(request->flags)break;

		  /*
		   * Every request for a shared
		   * lock is granted.
		   */
		  lock->usecount++;
		  Signal(request->client,SEMAPHORE_SIGNALF);
		  
		  /*
		   * Link the request into
		   * the shared owner list.
		   */
		  request->flags = 1;
		  lock->shared.last->next = request;
		  lock->shared.last       = request;
		}
	    }
	  else
	    {
	      /*
	       * In this case the next request is for 
	       * an exclusive lock. So the first request
	       * in the queue will be placed on deck.
	       * Also, set lock->owner to indicate
	       * your exclusive rights.
	       */
	      lock->owner    = lock->next.client;
	      lock->usecount = lock->next.flags;
	      
	      /*
	       * Get the first node of the queue.
	       */
	      if(request = lock->queue.first)
	        {
	          if(!(lock->queue.first=request->next))
	            lock->queue.last = NULL;
	          else request->next=NULL;
	        }
	    }
	  
	  /*
	   * If request != NULL, then place that
	   * request on deck.  Otherwise, clear the
	   * ondeck circle.
	   */
	  if(request)
	    {
	      lock->next=*request;
	      freerequest(request);
	    }
	  else lock->next.client = NULL;
	}
    }
  return;
}

void obtainshared( struct layerlock *lock, struct task *task )
{
  struct layerrequest req,*request;

  if(lock->usecount)
    {
      /*
       * The semaphore has been locked.
       */
      if(!lock->owner)
	{
	  /*
	   * However, it is a shared lock.
	   *  Check to see if this task 
	   * is one of the owners.
	   */
	  
	  for(request = lock->shared.first;request;request=request->next)
	    {
	      if(request->client==task)
		{
		  request->flags++;
		  lock->usecount++;
		  return;
		}
	    }
    
	  /*
	   * Check if noone is waiting for an
	   * exclusive lock.  In this case we
	   * can just add this task to the
	   * shared owner list.
	   */
	  if(!lock->next.client)
	    {
	      if(request=allocrequest())
		{
		  request->next   = NULL;
		  request->client = task;
		  request->flags  = 1;

		  lock->usecount++;
		  lock->shared.last->next = request;
		  lock->shared.last       = request;
		  return;
		}
	      else Alert(ALERT_SEMAPHORE_ERROR);
		  
	    }
	  /*
	   * In this case, we'll create a 
	   * request that will be linked
	   * into the queue.
	   */
	}

      req.next   = NULL;
      req.client = task;
      req.flags  = 0;    /* indicates shared request. */

      if(lock->next.client)
	{
	  if(request=allocrequest())
	    {
	      *request = req;
	      if(lock->queue.last)
		{
		  lock->queue.last->next = request;
		  lock->queue.last       = request;
		}
	      else lock->queue.first = lock->queue.last = request;
	    }
	  else Alert(ALERT_SEMAPHORE_ERROR);
	}
      else lock->next = req;

      /*
       * We're now in the queue,
       * so wait here for the
       * results.
       */
      Wait(SEMAPHORE_SIGNALF);
      return;
    }

  /*
   * If there was no lock, then
   * we end up here.
   */
  if(request=allocrequest())
    {
      request->next   = NULL;
      request->client = task;
      request->flags  = 1;    /* indicates one lock. */

      lock->shared.first = lock->shared.last = request;
    }
  else Alert(ALERT_SEMAPHORE_ERROR);

  lock->usecount = 1;
  return;
}

void obtainexclusive( struct layerlock *lock, struct Task *task )
{
  struct layerrequest req;
  struct layerrequest *request,*last;

  /*
   * For debugging purposes.
   */
  if(lock->owner&&(!lock->usecount))Alert(ALERT_SEMAPHORE_ERROR);

  /*
   * Check to see to see if someone
   * already has a lock and it is not
   * you.
   */
  if(lock->usecount&&(lock->owner!=task))
    {
      /*
       * This is just for debugging until
       * I'm absolutely sure that these
       * functions are working properly.
       *  This guarantees that the lock doesn't
       * get into some kind of dead state.
       */
      if(!lock->shared.first)Alert(ALERT_SEMAPHORE_ERROR);

      /*
       * Prepare an exclusive
       * request block.  Flag indicates
       * exclusive and the # of requests
       * pending.
       */
      req.next   = NULL;
      req.client = task;
      req.flags  = 1;

      /*
       * Someone else already has control
       * of the lock.  Check if you already
       * have a shared lock.
       */
      if(!lock->owner)
	{
	  /*
	   * The layer is being shared.
	   *
	   * Check trivial case where task has
	   * the only shared lock.
	   */
	  if(lock->shared.first==lock->shared.last &&
	     lock->shared.first->client==task)
	    {
	      /*
	       * Make the lock into an exclusive 
	       * one.
	       */
	      lock->owner=task;
	      lock->usecount++;
	      freerequest(lock->shared.first);
	      lock->shared.first=lock->shared.last = NULL;
	      return;
	    }

	  /*
	   * In the not so trivial case.  First look
	   * through the list for this task.
	   */
	  
	  last = NULL;
	  for(request=lock->shared.first;request;request=request->next)
	    {
	      if(request->client==task)
		{
		  /*
		   * Need to remove this request and
		   * place it into the queue as an
		   * exclusive request for 'TWO' locks.
		   */
		  
		  if(last)
		    {
		      last->next=request->next;
		      if(!request->next)lock->shared.last=last;
		    }
		  else lock->shared.first = request->next;
		  
		  /*
		   * Okay, so the node has been removed,
		   * and flags contains the number of 
		   * locks that have been obtained.
		   *
		   *  This number will become the number of
		   * locks requested.
		   */
		  lock->usecount -= request->flags;
		  req.flags = request->flags+1;

		  freerequest(request);
		}
	      last = request;
	    }
	}
	     
      /*
       * Somebody already has it, so
       * put yourself in line.  If the line
       * is empty, then just put yourself
       * as the next owner.
       */
      if(lock->next.client)
	{
	  /*
	   * Someone is already waiting, so you'll
	   * have to add a node to the list.
	   */
	  if(request=allocrequest())
	    {
	      /*
	       * Copy the request that
	       * has already been
	       * generated.
	       */
	      *request = req;
	      
	      if(lock->queue.first)
	        {
	          lock->queue.last->next = request;
	          lock->queue.last       = request;
	        }
	      else lock->queue.first = lock->queue.last = request;  
	    }
	}
      else
	{
	  /*
	   * No one is waiting, so simply put
	   * yourself in the quick not user
	   * spot.
	   */
	  lock->next = req;
	}
	  
      /*
       * Wait your turn to own the
       * semaphore.
       */
      Wait(SEMAPHORE_SIGNALF);
      return;
    }

  /*
   * No waiting quicky service
   * goes this way.
   */
  lock->usecount++;
  lock->owner=task;

  return;
}

void locklayer( struct layer *layer )
/* lock an individual layer. */
{
  struct Task *task;


  Forbid();
  task=(struct Task *)FindTask(0);

  /*
   * First make sure that this
   * task does not already have an
   * on exclusive lock.
   */
  if(layer->root_lock->owner!=task)
    {
      /*
       * Obtaining a shared lock will freeze the
       * tree in its current state, but allows
       * others task to operate on other layers
       * in the tree.
       */
      obtainshared(layer->root_lock,task);
      obtainexclusive(layer->local_lock,task);
    }
  /* You already have an exclusive lock, so increment the usecount. */
  else layer->root_lock->usecount++;

  Permit();

  return;
}

void locklayers( struct layer *layer )
/* Lock all the layers in the tree. */
{
  struct Task *task;

  Forbid();

  /*
   * Obtain an exclusive lock on the tree
   * so that no other tasks can use the layers
   * in any way without poking at them
   * directly.
   */
  task=(struct Task *)FindTask(0);
  obtainexclusive(layer->root_lock,task);

  Permit();

  return;
}



void unlocklayer( struct layer *layer )
/* Release lock on layer. */
{
  struct Task *task;

  Forbid();

  task=(struct Task *)FindTask(0);

  /*
   * Normally a shared lock is put on the
   * root and an exclusive lock put on
   * the layer.
   *  But if the task already has an
   * exclusive lock, then the usecount
   * of the root is bumped and the
   * local lock is left untouched.
   *  So first we need to check if the
   * task has an exclusive lock or not.
   */
  if(layer->root_lock->owner!=task)
    {
      releaselock(layer->root_lock);
      releaselock(layer->local_lock);
    }
  /* don't check for zero unless people are going in wrong order */
  else releaselock(layer->root_lock);
    
  Permit();

  return;
}

void unlocklayers( struct layer *layer )
{
  Forbid();

  /*
   * Just release the exclusive lock put
   * on the root.
   */
  releaselock(layer->root_lock);

  Permit();
  return;
}


/*
 * layer tree management functions.
 *
 * addlayerhead()  -- adds a layer to the head of its list.
 * addlayertail()  -- adds a layer to the tail of its list.
 * insertlayer()   -- inserts a layer behind a sibling.
 * removelayer()   -- removes a layer from the list.  This function
 *                    assumes that the layer is being removed
 *                    permanently, so if the list is just being
 *                    rearranged, then use exec/Remove() instead.
 */

void addlayerhead( struct layer *layer, struct rootlayer *root )
{

  if(layer->parent)
    {
      /* Check if parent if the root. */
      if(root)
	{ 
	  /*
	   * The root layer has three kinds of chidren.
	   *  OVERLAY -- These are always in the front of the others.
	   *  NORMAL  -- These are in between the others.
	   *  BACKDROP -- These always get pushed to the back.
	   * So there are three lists which must be maintained.
	   */

	  if(isOVERLAY(layer))
	    {
	      AddHead(&root->children,layer);
	      if(!root->overlay)root->overlay=layer;
	    }
	  else
	    {
	      if(isBACKDROP(layer))
		{ 
		  if(root->backdrop)
		    AddHead(root->backdrop->prev,layer);
		  else
		    AddTail(&root->children,layer);
		  root->backdrop=layer;
		}
	      else
		{
		  if(root->overlay)
		    AddHead(root->overlay,layer);
		  else
		    AddHead(&layer->parent->children,layer);
		}
	    }
	}
      else AddHead(&layer->parent->children,layer);
    }
  return;
}

void addlayertail( struct layer *layer, struct rootlayer *root )
{
  if(layer->parent)
    {
      /* Check if parent is the root layer. */
      if(root)
	{
	  /*
	   * The root layer has three kinds of chidren.
	   *  OVERLAY -- These are always in the front of the others.
	   *  NORMAL  -- These are in between the others.
	   *  BACKDROP -- These always get pushed to the back.
	   * So there are three lists which must be maintained.
	   */

	  if(isOVERLAY(layer))
	    {
	      if(root->overlay)
		AddHead(root->overlay,layer);
	      else
		AddHead(&root->children,layer);
	      root->overlay = layer;
	    }
	  else
	    {
	      if(isBACKDROP(layer))
		{
		  AddTail(&root->children,layer);
		  if(!root->backdrop)root->backdrop=layer;
		}
	      else
		{
		  if(root->backdrop)
		    AddHead(root->backdrop->prev,layer);
		  else 
		    AddTail(&root->children,layer);
		}
	    }
	}
      else AddTail(&layer->parent->children,layer);
    }
  return;
}

void insertlayer( struct layer *layer, struct layer *target )
{
  Alert(ALERT_UNDER_CONSTRUCTION);
  return;
}


/*
 * NOTE: if the layer is to be removed temporarily, just use Remove()
 *       instead.
 */

void removelayer( struct layer *layer )
{
  struct layer *parent;
  struct rootlayer *root;

  /* Be careful of children of the root. */
  if(!layer->parent->parent)
    {
      root = (struct rootlayer *)layer->parent;
      if(root->backdrop==layer)
	root->backdrop = (layer->next->next?layer->next:NULL);
    }
  Remove(layer);

  /* When the link field of a vertical or horizontal group is used,
     then it must be cleared here.  Maybe the next major revision. */
  parent=layer->parent;

  /*
   * If the parent is waiting to delete
   * itself, then check if this layer was
   * the last child.
   */
  if(!parent->usecount)
    if(parent->children.tailpred==(struct layer *)&parent->children.head)
      {
	/*
	 * Repeat the process on the
	 * parent. 
	 */
	if(parent->parent)
	  { removelayer(parent);
	    parent->parent=NULL;
	  }

	/*
	 * One last obstacle to freeing
	 * the layer.
	 */
	if(!(parent->flags&LAYER_DELAY_DISPOSE))
	  freeobject(parent);
      }
  return;
}


/*
 * Hmmm.
 * refreshregion()    -- This clears the region clipped in the layer.
 *
 * clip()             -- This function is used when updating the clip
 *                       list to remove any area where clipped children are.
 *                       A parent cannot draw into these areas.
 *
 * updatelayer()      -- This updates a single layer's regions and clipilst.
 *
 * updatelayers()     -- This function uses updatelayer() to update an entire
 *                       branch of the layer tree. A given branch can be
 *                       skipped by passing its local root.
 *
 * updateroot()       -- This is a function specifically for updating the root
 *                       layer. It's probably obsolete by now.
 *
 * beginupdate()      -- This pushes the current cliplist and replaces it
 *                       with one that is limited to the damagelist.
 *
 * endupdate()        -- This function returns the layer to its normal state.
 *
 * bufferedrefresh()  -- This subroutine is for both refreshsuper() and 
 *                       refreshsmart().  It does the actual work of copying
 *                       a buffer to the screen.
 *
 * refreshsmart()     -- Refreshes the screen with a super bitmap.
 *
 * refreshsuper()     -- Refreshes the screen with a smart buffer.
 *
 * refresh()          -- This function refreshes a branch of the layer tree.
 *                       It can include a call to updatelayer() and one branch
 *                       of the tree can be skipped by passing the local 
 *                       root.
 *
 * refreshlayer()     -- Refreshes a layer and all of its children.
 *
 * refreshparent()    -- Goes back along the tree until it finds an
 *                       appropriate starting point for refresh. This
 *                       function call refresh() and takes arguments for
 *                       updates and skipping a branch of the tree.
 */


void refreshregion( struct layer *layer, struct region *region )
/* Clear a region into a layer. */
{
  struct layer *index,*i2;
  struct rrectangle *rrectp;

  /*
   * The region will be modified, so
   * increase the usecount now.
   */
  if(region)
    useregion(region);
  else
    region = useregion(layer->local);

  if(region->rectangles)
    {
      /*
       * Search back through the tree for the
       * first buffer. either smart refresh or root.
       */
      for(index=layer;index->parent&&isSIMPLE(layer);index=index->parent);

      /*
       * If it is a smart/super refresh
       * layer, then go through this loop.
       */
      while(index->parent)
	{
	  if(isSUPER(index))
	    {
	      for(rrectp=region->rectangles;rrectp;rrectp=rrectp->next)
		EB_RectangleFill(index->refresh.super.bitmap,0,
			       rrectp->bounds.min.coor.x 
			        - index->refresh.super.bounds.min.coor.x,
			       rrectp->bounds.min.coor.y
			        - index->refresh.super.bounds.min.coor.y,
			       rectwidth(rrectp->bounds),
			       rectheight(rrectp->bounds),NULL);

	      /* clip the region to the layer bounds for the next buffers. */
	      region = andrectregion(region,&layer->bounds);
	    }
	  else /* smart refresh layer. */
	    for(rrectp=region->rectangles;rrectp;rrectp=rrectp->next)
	      EB_RectangleFill(index->refresh.smart.buffer,0,
			       rrectp->bounds.min.coor.x-index->bounds.min.coor.x,
			       rrectp->bounds.min.coor.y-index->bounds.min.coor.y,
			       rectwidth(rrectp->bounds),
			       rectheight(rrectp->bounds),NULL);

	  /*
	   * Update the layer for the next buffer.
	   * 1) clip away layers with higher priority.
	   * 2) then AND with the parent's region. That
	   *     region is inherited back to the last buffer.
	   */
	  for(i2=index->prev;i2->prev;i2=i2->prev)
	    if(i2->visibility&&isCLIPPED(i2))
	      region = clearrectregion(region,&i2->bounds);
	  region = andregionregion(region,index->parent->region);
	  if(!region->rectangles)break;

	  /*
	   * Find the next buffer to be cleared.
	   */
	  for(index=index->parent;index->parent&&isSIMPLE(index);index=index->parent);
	}

      /*
       * If the loop has been surpassed, then we
       * must have made it to the root layer.  So
       * now go throught the rectangle list and
       * clear it.
       */
      for(rrectp=region->rectangles;rrectp;rrectp=rrectp->next)
	EB_RectangleFill(index->bitmap,0,rrectp->bounds.min.coor.x,
		                         rrectp->bounds.min.coor.y,
		                         rectwidth(rrectp->bounds),
			                 rectheight(rrectp->bounds),NULL);
    }

  /*
   * Since we're done with the region,
   * dispose of it.  This matches the useregion()
   * call at the beginning of the function.
   */
  disposeregion(region);

  return;
}

struct region *clip( struct region *region, struct layer *layer )
/* remove bounds of any clipped children in preparation of 
   updating the cliplist. Recursive function. */
{
  struct layer *index;

  /*
   * The layer must be visible and not a hotspot.
   * A hotspot is neither clipped nor does it have
   * any children to search.
   */
  if(layer->visibility&&isNOTHOTSPOT(layer))
    {
      /*
       * If the layer is clipped, then remove bounds
       * from the region.  Otherwise, continue searching
       * throught the children.
       */
      if(isCLIPPED(layer))
	region = clearrectregion(region,&layer->bounds);
      else 
	for(index=layer->children.head;index->next;index=index->next)
	  region = clip(region,index);
    }
  return region;
}



void updatelayer( struct layer *layer )
/* Update the regions and cliplist of a layer. */
{
  struct rectangle bounds;
  struct layer *index;

  /*
   * The three kinds of layers to update:
   *  A) A HOTSPOT layer:
   *                       This only requires the visibility region for comparing with
   *                      mouse movement and the cliplist.  Since the cliplist
   *                      does not change, it just needs to copy the parent's
   *                      visibility.
   *
   *  B) A NOCLIP layer:
   *                       This layer type is similar to the hotspot
   *                      but because it has children it must pass
   *                      along the 'local' and 'region' regions.
   *
   *  C) A NORMAL layer:
   *                       This layer regenerates all the layers and 
   *                      appropriate comments can be found in the code.
   */
  
  if(layer->visibility)
    {
      disposeregion(layer->visibility);
      
      if(isHOTSPOT(layer))
	{
	  /*
	   * Hotspot just takes it parents visibility.
	   */
	  layer->visibility = useregion(layer->parent->visibility);
	}
      else
	{
	  
	  disposeregion(layer->region);
	  disposeregion(layer->local);
	  
	  if(!isCLIPPED(layer))
	    {
	      /*
	       * A noclip layer inherits its regions from
	       * its parent.  Same with the cliplist.
	       */
	      layer->region     = useregion(layer->parent->region);
	      layer->local      = useregion(layer->parent->local);
	      layer->visibility = useregion(layer->parent->visibility);
	    }
	  else
	    {
	      /*
	       * update a layer with total clipping.  Once
	       * last contingency is if it is the root layer.
	       * This layer is easiest to update.
	       */
	      
	      if(layer->parent)
		{
		  /* 
		   * The first thing the layer does is check if
		   * it is a SMART refresh layer.  If yes, then
		   * also check to see if a buffer has been 
		   * allocated.
		   */
		  if(isSMART(layer)&&(!layer->refresh.smart.buffer))
		    {
		      layer->refresh.smart.buffer = g_AllocBitMap(rectwidth(layer->bounds),
								  rectheight(layer->bounds),
								  g_Depth(layer->bitmap),
								  layer->bitmap);
		      /* clear the bitmap. */
		      g_Rectangle(layer->refresh.smart.buffer,0,0,0,layer->refresh.smart.buffer->Width,layer->refresh.smart.buffer->Height);
		      
		      layer->flags |= LAYER_BUFFER_INVALID;
		    }
		  
		  /*
		   *  Now we can generate the regions that define where
		   *  the layer is clipped.
		   *   These regions are:
		   *     .local  -- clipping for the most recent buffer from
		   *                a parent.
		   *     .region -- clipping for most recent buffer.  If the
		   *                layer is a SMART refresh, then its
		   *                just the bounds.
		   *     .visibility -- clipping for the root layer bitmap.
		   *
		   *
		   *  But first, we need to determine the rectangular boundary
		   *  of the layer.  If it is a superlayer then use the virtual
		   *  bounds, otherwise, use the real boundary.
		   */
		  if(isSUPER(layer))bounds = layer->refresh.super.bounds;
		  else bounds = layer->bounds;
		  
		  /* 
		   * Generate the local layer.  Take the hard boundary, then
		   * remove any siblings with a higher priority.
		   * Finally, fit within the region of its parent.
		   */
		  layer->local = newregion(&layer->bounds);
		  for(index=layer->prev;index->prev;index=index->prev)
		    if(index->visibility&&isCLIPPED(index))
		      layer->local = clearrectregion(layer->local,&index->bounds);
		  layer->local = andregionregion(layer->local,layer->parent->region);
		  
		  /*
		   *  If the layer has its own buffer to draw into, then
		   *  the region is the boundary of the buffer, otherwise
		   *  just copy the local region.
		   */
		  if(isBUFFERED(layer))layer->region = newregion(&bounds);
		  else layer->region= useregion(layer->local);
		  
		  /* 
		   *  For the visibility, first check if the local region
		   *  will do, otherwise AND it with the parent's visibility.
		   */
		  for(index=layer->parent;index->parent&&isSIMPLE(index);index=index->parent);
		  if(index->parent)
		    layer->visibility=andregionregion(useregion(layer->local),layer->parent->visibility);
		  else
		    layer->visibility = useregion(layer->local);
		   
		}
	      else
		{
		  /*
		   * If we're here, then the layer must be
		   * the root.  Then all the regions are
		   * the same.
		   */
		  layer->local = newregion(&layer->bounds);
		  layer->region = useregion(layer->local);
		  layer->visibility = useregion(layer->local);
		}
	      /*
	       *  Finally, once all of the regions have been updated, the
	       *  cliplist may be revised.  see "clip.c" for the code.
	       */
	      updatecliplist(layer);
	    }
	}
    }
  return;
}

void updatelayers( struct layer *layer, struct layer *except )
/* update a branch of the layer tree. */
{
  struct layer *index;
  
  /*
   * Layer must be visible to be
   * updated.
   */
  if(layer->visibility)
    {
      updatelayer(layer);

      /*
       * now update all the chidlren
       * except for the branch given
       * by the 'except' argument as a
       * local root.
       */
      if(isNOTHOTSPOT(layer))
	for(index=layer->children.head;index->next;index=index->next)
	  if(index!=except)updatelayers(index,except);
    }
  return;
}




BOOL beginupdate( struct layer *layer )
/* Set the layer clipping to damagelist and lock for refresh. */
{

  /*
   *  First, we lock the layer.  This lock is only 
   *  removed if for some reason there is no point
   *  in updating. (e.g. damagelist=NULL)  Otherwise,
   *  it will be released when endupdate() is called.
   */
  locklayer(layer);

  if(layer->visibility)
    {
      if(isCLIPPED(layer))
	{
	  if(layer->damagelist->rectangles)
	    {
	      /*
	       *  If there is a damagelist, then push the cliplist
	       *  and set approprite flag.  Erase the damagelist.
	       */

	      layer->clip = pushcliplist(layer->clip,layer->damagelist);
	      layer->flags |= LAYER_REFRESHING;
	      layer->damagelist = clearregion(layer->damagelist);
	      return TRUE;
	    }
	}
      else
	{
	  /*
	   * If the layer is not clipped, then it has no
	   * damage list.  It inherits from its parent which
	   * is already updating.  That is if the programmer has
	   * properly parsed the exposure array.  Anyway,
	   * check that the parent is indeed updating.
	   */
	  if(layer->parent->flags&LAYER_REFRESHING)
	    {
	      layer->flags |= LAYER_REFRESHING;
	      layer->clip = usecliplist(layer->parent->clip);
	      return TRUE;
	    }
	}
    }
  
  /*
   * Layer does not need to update,
   * so we can release the lock.
   */
  unlocklayer(layer);

  return  FALSE;
}


void endupdate( struct layer *layer )
/* restore a layer to its normal clipping state. */
{
  /*
   * First make sure that the layer is 
   * actually in the midst of updating.
   * Then, clear the flag and restore the
   * cliplist.
   * Release the lock on the layer when done.
   */

  if(layer->flags & LAYER_REFRESHING)
    {
      layer->flags &= ~LAYER_REFRESHING;
      layer->flags &= ~LAYER_BUFFER_INVALID;
      layer->clip = popcliplist(layer->clip);
      unlocklayer(layer);
    }
  return;
}

void bufferedrefresh( struct layer *layer, struct region *damage, BitMapPtr source, union point xy )
/* Refresh the layer using the 'source' buffer given. */
{
  union point origin;
  struct layer *index,*i2;
  BitMapPtr bitmap;
  struct rrectangle *rrectp;

  g_Message {
    g_CopyMsg;
  }g_EndMessage;

  g_CopyMsgPrep(source);

  /*
   *  This function is similar in format to refreshregion().  It
   *  goes back through the layer tree and when it finds a 
   *  bitmap, it copies the source into its damaged region.
   *   So, first thing to do is get that first bitmap.
   */
  for(index=layer->parent;index->parent&&isSIMPLE(index);index=index->parent);
  
  /*
   *  As long as the bitmap is not the
   *  root, then repeat this loop.
   */
  while(damage->rectangles&&index->parent)
    { 
      /*
       * We need the origin of the destination.
       * This value depends on whether it is a 
       * superbitmap or a smart refresh layer.
       */
      if(isSUPER(index))
	{ bitmap    = index->refresh.super.bitmap;
	  origin.xy = index->refresh.super.bounds.min.xy;
	}
      else /* smart refresh. */
	{ bitmap    = index->refresh.smart.buffer;
	  origin.xy = index->bounds.min.xy;
	}
      
      /*
       * Now, loop through the damagelist and
       * copy the bitmap into it.
       */
      for(rrectp=damage->rectangles;rrectp;rrectp=rrectp->next)
	g_Copy(bitmap,rrectp->bounds.min.coor.x-origin.coor.x,
	              rrectp->bounds.min.coor.y-origin.coor.y,
	              rectwidth(rrectp->bounds),
	              rectheight(rrectp->bounds),
	              source,
	              rrectp->bounds.min.coor.x - xy.coor.x,
		      rrectp->bounds.min.coor.y - xy.coor.y);
	        
/*
 * For some reason, the method is
 * not working properly, so remove
 * temporarily.
	g_CopyMsgSend(bitmap,rrectp->bounds.min.coor.x-origin.coor.x,
		             rrectp->bounds.min.coor.y-origin.coor.y,
		             rectwidth(rrectp->bounds),
		             rectheight(rrectp->bounds),
		             rrectp->bounds.min.coor.x - xy.coor.x,
		             rrectp->bounds.min.coor.y - xy.coor.y);
 */

      /*
       * Now, I must update the damagelist
       * to the next buffer.
       */
      if(isSUPER(index))
	damage=andrectregion(damage,&index->bounds);
      for(i2=index->prev;i2->prev;i2=i2->prev)
	if(i2->visibility&&isCLIPPED(i2))
	  damage=clearrectregion(damage,&i2->bounds);
      damage=andregionregion(damage,index->parent->region);
    }
  
  /*
   *  If we get here, then we must have reached
   *  the root layer.  Copy the bitmap into it.
   */
  for(rrectp=damage->rectangles;rrectp;rrectp=rrectp->next)
    g_Copy(index->bitmap,rrectp->bounds.min.coor.x,
	                rrectp->bounds.min.coor.y,
	                rectwidth(rrectp->bounds),
	                rectheight(rrectp->bounds),
	                source,
	                rrectp->bounds.min.coor.x - xy.coor.x,
		        rrectp->bounds.min.coor.y - xy.coor.y);
	        
/*
 * For some reason, the method is
 * not working properly, so remove
 * temporarily.
    g_CopyMsgSend(index->bitmap,rrectp->bounds.min.coor.x,
		                rrectp->bounds.min.coor.y,
		                rectwidth(rrectp->bounds),
		                rectheight(rrectp->bounds),
		                rrectp->bounds.min.coor.x - xy.coor.x,
		                rrectp->bounds.min.coor.y - xy.coor.y);
 */

  disposeregion(damage);
  
  return;
}

void refreshsmart( struct layer *layer, struct region *damage )
/* Refresh the damagelist of a smart refresh layer. */
{
  struct layer *index;

  if(layer->visibility&&damage->rectangles)
    {
      /*
       * First of all, prepare the
       * damagelist by clipping to parts
       * appropriate for the parent's bitmap.
       */
      for(index=layer->prev;index->prev;index=index->prev)
	if(index->visibility&&isCLIPPED(index))
	  damage = clearrectregion(damage,&index->bounds);
      damage = andregionregion(damage,layer->parent->region);
      
      /*
       * If there is anything left, then
       * call bufferedrefresh().
       */
      if(damage->rectangles)
	bufferedrefresh(layer,damage,layer->refresh.smart.buffer,layer->bounds.min);
    }
  return;
}

void refreshsuper( struct layer *layer, struct region *damage )
/* Refresh the damaged region of a superbitmap layer. */
{
  struct layer *index;

  if(layer->visibility&&damage->rectangles)
    {
      /*
       * Clip the damagelist to the
       * parent's bitmap.
       */
      damage = andrectregion(damage,&layer->bounds);
      for(index=layer->prev;index->prev;index=index->prev)
	if(index->visibility&&isCLIPPED(index))
	  damage=clearrectregion(damage,&index->bounds);
      damage = andregionregion(damage,layer->parent->region);

	/*
	 * If there is anything left, then
	 * call bufferedrefresh() to do the
	 * actual work.
	 */
      if(layer->damagelist->rectangles)
	bufferedrefresh(layer,damage,layer->refresh.super.bitmap,layer->refresh.super.bounds.min);
    }
  return;
}



void refresh( struct layer *layer, struct region *damage, 
	     struct layer *except, BOOL UPDATE )
/* Perform the appropriate actions to refresh a region of a layer. */
{
  struct layer *index;

  if(!layer->visibility)return;

  /*
   * The option is there to 
   * update the layer first.
   */
  if(UPDATE)updatelayer(layer);


  /*
   * If the damage region is a NULL pointer, then
   * the entire layer must be refreshed.  Otherwise,
   * we need to make our own copy and make sure
   * that it fits within the bounds of the layer.
   */
  if(damage)
    {
      switch(LAYER_TYPE(layer))
	{
	case LAYER_TYPE_NORMAL:
	  damage = andregionregion(useregion(damage),
				   (layer->flags&LAYER_BUFFER_INVALID?layer->region:layer->local));
	  break;
	case LAYER_TYPE_BOUNDED:
	  damage = andrectregion(useregion(damage),&layer->bounds);
	  break;
	default:
	  damage = useregion(damage);
	  break;
	}
      
      if(!damage->rectangles)
	{ 
	  /*
	   * Here's a problem, even if the damagelist
	   * is NULL, the cliplist still needs to be
	   * updated.
	   */
	  for(index=layer->children.head;index->next;index=index->next)
	    if(index!=except)updatelayers(index,except);

	  /*
	   * Okay, now it's okay to release
	   * the region and leave.
	   */
	  disposeregion(damage);
	  return;
	}
    }


  switch(LAYER_REFRESH_TYPE(layer))
    {
    case LAYER_REFRESH_SUPER:
      if(layer->flags&LAYER_BUFFER_INVALID)
	{
	  /*
	   * If the layer's superbitmap is
	   * damaged, then we need to send
	   * an exposure event, so that the
	   * program can fix it.  There's
	   * no space allocated for a stack.
	   */
	  if(!damage)
	    {
	      /*
	       * If NULL was passed for damage,
	       * then that means to refresh the
	       * whole frickin' layer.  Otherwise,
	       * just include the damage to the
	       * damagelist.
	       */
	      disposeregion(layer->damagelist);
	      layer->damagelist = useregion(layer->region);
	    }
	  else layer->damagelist = orregionregion(layer->damagelist,damage);
	  
	  /*
	   * Build the exposure array
	   * for this layer and all of its
	   * children.
	   */
	  signalexposure(layer);
	  nestarray();
	  for(index=layer->children.head;index->next;index=index->next)
	    if(index!=except)refresh(index,damage,except,UPDATE);
	  unnestarray();
	}
      else refreshsuper(layer,useregion(damage?damage:layer->local));
      break;

    case LAYER_REFRESH_SMART:
      if(layer->flags&LAYER_BUFFER_INVALID)
	{
	  /*
	   *  If the buffer is not up to date for some reason,
	   *  then the layer reverts to a simple refresh model.
	   *  Execute the refresh stack, if there is one, or
	   *  add the layer to the expsoure array.
	   */
	  if(layer->refresh.smart.stack)
	    {
	      /*
	       * fix only the portion of the clip
	       * list with the damaged region. Then
	       * have all your children do the same.
	       */
	      
	      /*
	       * NOTE: We don't have to check if the layer does not
	       * clipped, because a smart refresh layer must be clipped.
	       */
	      if(damage)
	        layer->clip = pushcliplist(layer->clip,damage);
	      beginstack(layer,layer->refresh.smart.stack,0,0);
	      for(index=layer->children.head;index->next;index=index->next)
		if(index!=except)refresh(index,damage,except,UPDATE);
	      layer->clip = popcliplist(layer->clip);
	    }
	  else
	    {
	      /*
	       * Add the damage to the damagelist and
	       * fill the exposure array.  If the damage
	       * region is a NULL pointer, then refresh
	       * the entire layer.
	       */
	      if(!damage)
		{ disposeregion(layer->damagelist);
		  layer->damagelist=useregion(layer->region);
		}
	      else layer->damagelist = orregionregion(layer->damagelist,damage);
	      signalexposure(layer);
	      nestarray();
	      for(index=layer->children.head;index->next;index=index->next)
		if(index!=except)refresh(index,damage,except,UPDATE);
	      unnestarray();
	    }
	}
      else refreshsmart(layer,useregion(damage?damage:layer->local));
      break;

    default: /* simple or noclip. */
    
    	/*
    	 * A simple refresh layer can have a stack object
    	 * linked to it to do all of the refreshing here
    	 * rather than wasting time by sending messages
    	 * to the input.device.
    	 */
      if(layer->refresh.simple.stack)
	{
	   /*
	    *  First, limit the cliplist to the damaged region.
	    * Be careful if the layer is clipped or not.
	    * NOTE: if damage is a NULL pointer, then there will
	    * be no change in the cliplist at all.
	    */
	  if(damage)
	    {
	      if(isCLIPPED(layer))
		layer->clip=pushcliplist(layer->clip,damage);
	      else 
		layer->clip = usecliplist(layer->parent->clip);
	    }
	  beginstack(layer,layer->refresh.simple.stack,0,0);
	  for(index=layer->children.head;index->next;index=index->next)
	    if(index!=except)refresh(index,damage,except,UPDATE);
	    
	  /*
	   * Restore the cliplist when we're done.
	   */
	  layer->clip=popcliplist(layer->clip);
	}
      else
	{
	  /*
	   * If there is no stack, then push the layer
	   * onto the exposure array.
	   */
	  if(isCLIPPED(layer))
	    {
	      if(!damage)
		{
		  disposeregion(layer->damagelist);
		  layer->damagelist = useregion(layer->region);
		}
	      else layer->damagelist = orregionregion(layer->damagelist,damage);

	    }
	    
	  signalexposure(layer);
	  nestarray();
	  for(index=layer->children.head;index->next;index=index->next)
	    if(index!=except)refresh(index,damage,except,UPDATE);
	  unnestarray();

	}
      break;
    } /* switch(REFRESH_TYPE) */

  /*
   * Dispose of the region that we
   * created at the
   * beginning.
   */

  if(damage)
    disposeregion(damage);

  return;
}

void refreshlayer( struct layer *layer, struct region *damage )
/* refresh the layer and all of its children within the damaged region. */
{
  /*
   * First off all, if this layer is to be
   * refreshed in simple mode, then first
   * clear the background.
   */
  updatelayers(layer,NULL);
  if(isSIMPLE(layer)||(layer->flags&LAYER_BUFFER_INVALID))
    refreshregion(layer,damage);
    
  /*
   * let refresh() do all the work.  Last
   * arguments indicate that all children are
   * to be included and that the layers
   * should be updated before refreshing.
   */
  refresh(layer,damage,NULL,NULL);
  return;
}

/*
 * NOTE: This is the entry point for G_RefreshLayer().
 * It is loaded with damage=NULL,except=NULL,UPDATE=NULL.
 */

void refreshparent( struct layer *layer, struct region *damage, struct layer *except, BOOL UPDATE )
/* refresh the layer tree starting with the first clipped parent. */
{
  /*
   * If this layer is not clipped, then
   * recursively search up towards the tree
   * root for one that is.
   */
  if(isCLIPPED(layer))
    {
      /*
       * I've gotta update the layer before I call refreshregion().
       * This will lead to the layer being updated
       * a second time, when I call refresh().  This
       * waste should be fixed.
       */
      if(UPDATE)updatelayer(layer);

    	/*
    	 * Clear the region only if we're in
    	 * simple refresh mode.
    	 */
      if(isSIMPLE(layer)||(layer->flags&LAYER_BUFFER_INVALID))
	refreshregion(layer,(damage?damage:layer->region));
	
      /*
       * let refresh() do all the work. It updates
       * all the layers (if UPDATE==TRUE) before refreshing
       * and only skips the branch indicated by 'except'
       */
      refresh(layer,damage,except,UPDATE);
    }
  else
    {
      /*
       * If the layer is bounded, the stop for a
       * moment to limit the damaged area.  This will
       * allow only a portion of the layers to be
       * refreshed without having to create a completely
       * clipped layer.
       */
      if(isBOUNDED(layer))
	{
	  if(damage)damage = andrectregion(damage,&layer->bounds);
	  else damage = newregion(&layer->bounds);
	  refreshparent(layer->parent,damage,except,UPDATE);
	  disposeregion(damage);
	}
      else refreshparent(layer->parent,damage,except,UPDATE);
    }

  return;
}

/*
 * Unlike the layers.library, giraffe layers are only 
 * part of the screen when they are explicitly mapped.
 * This allows for the objects to be created even
 * when they are no needed, and then popped onto the
 * screen.
 *
 * The functions that do the work are:
 *   map()
 *   mapchild()
 *   maplayer()
 *   unmapchild()
 *   unmap()
 *   unmaplayer()
 */

void map(  struct layer *layer )
{
  struct layer *index,*i2;

  /*
   * Only map if the layer's parent
   * is visible.
   */
  if(layer->parent->visibility)
    {
      /*
       * Arrange the layers.  If the layer is arranged
       * by its parent, then all of its siblings will
       * have to be arranged and a greater effect on
       * the screen is the result.
       */
      if(layer->parent->flags&LAYER_ARRANGE_MASK)
	index=arrangelayer(layer->parent,0,0);
      else index = arrangelayer(layer,0,0);

      /*
       * index is the first layer in the tree up from layer,
       * which was affected by the arrangement.  That is,
       * its bounds have been changed.
       */
      if((index!=layer)||(!isCLIPPED(layer)))
	{
	  /*
	   * So now, two things can happed.
	   * a) index is a clipped layer and the cliplist
	   *    of its parents has changed.  In this case,
	   *    update its parents and refresh index.
	   * b) index is not clipped so, we need to find
	   *    a layer that is and refresh it entirely.
	   */
	  for(i2=index->parent;isNOCLIP(i2);i2=i2->parent);
	  if(isCLIPPED(index))
	    {
	      updatelayers(i2,index);
	      refreshlayer(index,NULL);
	    }
	  else refreshparent(i2,NULL,NULL,TRUE);
	}
      else
	{
	  /*
	   * In the case that the layer is not arranged
	   * by its parent and it is clipped, then we first
	   * must update the cliplist of the parent,
	   * then we can refresh just this layer.
	   */
	  for(index=layer->parent;isNOCLIP(index);index=index->parent);
	  updatelayers(index,layer);
	  
	  refreshlayer(layer,NULL);
	}
      /*
       * Because a new layer has been mapped,
       * the focus of the mouse pointer may have
       * changed. Tell any servers that care by
       * means of a input.device event.
       */
      signalevent(IECLASS_CHECK_FOCUS,NULL);
    }
  else
    {
      /*
       * If the parent has not been mapped,
       * then do so recursively.  First give
       * the layer some dummy pointers.
       */
      layer->parent->region = 
	layer->parent->local = 
	  layer->parent->visibility = 
	    layer->parent->damagelist = useregion4(layer->region);
      map(layer->parent);
    }
  return;
}



void mapchild( struct layer *layer )
/* prepare a child for mapping to the screen. */
{
  struct layer *index;

  /*
   * If you don't want a layer to be 
   * mapped unless you explicitly pass
   * it to maplayer(), then you'll need
   * to pass a tag to set LAYER_DELAY_MAP.
   * 
   * Otherwise, when a layer is mapped all
   * of its children are also.
   */
  if(!(layer->flags&LAYER_DELAY_MAP))
    {
      /*
       * Copy the blank region your parent.
       * And map any children further down
       * the layer tree.
       *
       * Keep in mind. Not all layers have all
       * the regions or children for that matter.
       */
      layer->visibility = useregion(layer->parent->region);
      if(!isHOTSPOT(layer))
	{
	  layer->local = layer->region = useregion2(layer->parent->region);
	  if(isCLIPPED(layer))
	    layer->damagelist = useregion(layer->parent->region);
	  
	  for(index=layer->children.head;index->next;index=index->next)
	    mapchild(index);
	} 
      
    }
  return;
}

BOOL maplayer( struct layer *layer )
     /* Entry point for G_MapLayer() call. */
{
  struct layer *index;
  
  /*
   * Lock all the layers while the tree
   * is being modified.  Prepare the
   * ioport for a message to the input.device.
   */
  lockio();
  locklayers(layer);
  
  if((!layer->visibility)&&layer->parent)
    {
      
      /*
       * First initialize all the layers regions
       * Note that not all layers types 
       * have all the regions.
       */
      layer->visibility = newregion(NULL);
      if(!isHOTSPOT(layer))
	{
	  layer->region = layer->local = useregion2(layer->visibility);
	  
	  if(isCLIPPED(layer))
	    layer->damagelist = useregion(layer->visibility);
	  
	  /*
	   * If the layer has
	   * children, then map them.
	   */
	  for(index=layer->children.head;index->next;index=index->next)mapchild(index);
	}  
      /*
       * Call map() to do the arrangement
       * and refreshing of the screen.
       */
      map(layer);
    }      
  unlocklayers(layer);
  unlockio();
      
  return(TRUE);
}

void unmapchild( struct layer *layer )
/* make the layer and its children transparent. */
{
  struct layer *index;
  
  if(layer->visibility)
    {
      if(layer->visibility)disposeregion(layer->visibility);
      layer->visibility = NULL;

	if(!isHOTSPOT(layer))
	{
	  /*
	   * HOTSPOTS have only the visibility.
	   */
	  if(layer->local)disposeregion(layer->local);
	  if(layer->region)disposeregion(layer->region);
	  layer->local = layer->region = NULL;
      
	  if(isCLIPPED(layer))
	    {
	      /*
	       * clipped layers also have the damagelist and
	       * they control the cliplist.
	       */
	      if(layer->damagelist)disposeregion(layer->damagelist);
	      layer->damagelist = Null;
         
	      erasecliplist(layer->clip);
          
	      /*
	       * If the layer has a smart refresh buffer
	       * then get rid of it right now.
	       */
	      if(isSMART(layer)&&layer->refresh.smart.buffer)
		{
		  g_FreeBitMap(layer->refresh.smart.buffer);
		  layer->refresh.smart.buffer = NULL;
		}
	    }
	  
	  /*
	   * Now unmap all of the children.
	   */
	  for(index=layer->children.head;index->next;index=index->next)unmapchild(index);
	}
    }
  return;
}



void unmap( struct layer *layer )
/* make the layer and its children transparent. */
{struct region *old;
  struct layer *index;
  
  if(layer->visibility)
    {
      /*
       * Save this region for
       * use in creating a damagelist.
       */
      old = useregion(layer->local);

      /*
       * Get rid of the layers regions
       */
      unmapchild(layer);

       /*
        * If the layer was arranged by its parent,
        * then a new layout must be calculated.
        */
      if(layer->parent)
	{
	  if(layer->parent->flags&LAYER_ARRANGE_MASK)
	    index=arrangelayer(layer->parent,0,0);
	  else index = NULL;

	  /*
	   * Finally, if the layer is not arranged and
	   * it is clipped, then refresh only the region
	   * where it was visible.
	   *  Otherwise, find a clipped parent refresh it
	   * entirely.
	   *  Oh, by the way, the layers must be updated also
	   * since removal of any clipped layers affects the cliplist
	   * of their parent.
	   */
	  if((!index)&&(isCLIPPED(layer)))
	    refreshparent(layer->parent,old,NULL,TRUE);
	  else refreshparent((index?index:layer->parent),NULL,NULL,TRUE);

	}
      /*
       * Get rid of this region and
       * send an event to anyone who cares
       * that the layer under the mouse
       * might not be the same anymore.
       */
      disposeregion(old);
      signalevent(IECLASS_CHECK_FOCUS,NULL);
    }
  return;
}

void unmaplayer( struct layer *layer )
/* make the layer and its children transparent. */
{

  /*
   * Reserve the ioport to send
   * messages to the input.device.
   * Also, lock the layer tree while
   * this maintenance is performed.
   */
  lockio();
  locklayers(layer);

  /*
   * All the actual work is done by
   * unmap().
   */
  unmap(layer);

  unlocklayers(layer);
  unlockio();

  return;
}


BOOL poplayer( struct layer *layer )
{
  lockio();
  locklayers(layer);

  if((!layer->visibility)&&layer->parent&&layer->parent->visibility)
    {
      if(isCLIPPED(layer))
	{
	  

	  unlockio();
	  return TRUE;
	}
    }
  unlocklayers(layer);
  unlockio();
  return FALSE;
}

/*
 * Functions for creating/destroying layers.
 *
 * openrootlayer() -- The first call made to giraffe.library.  Adds a 
 *                    clipping hierarchy to an EGS bitmap.
 * openlayer()     -- This function is used to create another
 *                    layer in the hierarchy. You must pass its parent.
 * closelayer()    -- When you're done, use this function to release the
 *                    resources of a layer.
 * uselayer()      -- In a multi-tasking environment, two task may use the
 *                    same layer.  Use this function to guaratee that the
 *                    layer pointer will remain valid, even if the 
 *                    creator calls closelayer().
 * droplayer()     -- When a task that has reserved a layer using uselayer(),
 *                    is done, it must call droplayer().
 * hashlayer()     -- This function is used to fill the hash_id field of a layer.
 *                    This id is used to refer to other layers in the tree
 *                    without wasting space.
 * disownlayer()   -- Mark a layer to be disposed by its parent.  Calling this
 *                    function is equivalent to calling closelayer(), so the
 *                    pointer is no longer valid unless you've called uselayer().
 *                    This function allows an entire branch of the layer tree to
 *                    be closed by closing its local root.
 * ownlayer()      -- Attempt to gain ownership rights to a layer.  If the pointer
 *                    is returned, then you become responsible for calling closelayer().
 * lock()/unlock() -- This pair of functions is used by closelayer() to not only
 *                    lock the entire layer tree, but also to set a flag which 
 *                    postpones the actual destrcution of the layer pointer until
 *                    unlock() is called.
 * close()         -- This function does the actual work in freeing all the resources of
 *                    a layer. It is used recursively on the tree.
 * closeroot()     -- This is a special form of close() that deals with the special
 *                    issues in closing a root layer.                   
 */

struct TagItem nil_tag = {TAG_END, 0};

struct layer *openrootlayer( BitMapPtr bitmap, struct TagItem *tags )
/* open a root layer to match the size of the bitmap. */
{
  struct rootlayer *root;

  if(!tags)tags=&nil_tag;

  /*
   * Allocate a layer with the additional space
   * for root layer information. (e.g. the root semaphore)
   */
  if(root=(struct rootlayer *)allocobject(GT_Layer,sizeof(struct rootlayer)))
    {
      /*
       * Set the usecount to 1 and prepare a
       * hash_id.
       */
      root->usecount = 1;
      root->hash_id = (((ulong)root)>>24)^(((ulong)root)>>16)^
	                (((ulong)root)>>8) ^(((ulong)root));

	  /*
	   * prepare the list of children for
	   * the joyful bounty to come.
	   */
      NewList(&root->children);

      /*
       * Set the bounds to match the bitmap.
       */
      root->bitmap=bitmap;
      root->bounds.min.coor.x = 0;
      root->bounds.min.coor.y = 0;
      root->bounds.max.coor.x = bitmap->Width-1;
      root->bounds.max.coor.y = bitmap->Height-1;
      root->parent=Null;

      /*
       * Automatically map the root
       * layer.
       */
      root->region     = newregion(&root->bounds);
      root->visibility = useregion(root->region);
      root->local      = useregion(root->region);
      root->damagelist = newregion(NULL);



      root->clip = newcliplist();
      updatecliplist((struct layer *)root);

      
      /*
       * Parsing of the taglist should
       * go here.
       */
      root->flags = NULL;

      /*
       * Prepare all of the semaphores
       */
      initlayerlock(&root->lock);
      initlayerlock(&root->other_lock);

      root->local_lock=&root->lock;
      root->root_lock=&root->other_lock;
    }
  return((struct layer *)root);
}


void hashlayer( struct layer *parent, struct layer *layer )
/* prepare a unique hash identifier for the layer. */
{
  struct layer *start,*index;

  layer->hash_id = (((ulong)layer)>>24)^(((ulong)layer)>>16)^
                     (((ulong)layer)>>8) ^(((ulong)layer));

  if(!parent)return;

  /*
   * Make sure that the id
   * is unique for this level
   * layer tree.
   */
  start = (struct layer *)(&parent->children);

  do
    {
      /*
       * hash id 0 is reserved for NULL layer.
       */
      if(!layer->hash_id)layer->hash_id = 1;

      /*
       * search siblings for same id.
       */
      for(index=parent->children.head;index->next;index=index->next)
	{
	  /*
	   * of course it will match with itself
	   * so avoid that mistake.
	   */
	  if(layer!=index)
	    if(index->hash_id==layer->hash_id)
	      {
	      	/*
	      	 * If a match was found,
	      	 *  then reset the index to the 
	      	 * beginning of the list.
	      	 */
		layer->hash_id += 1;
		index = (struct layer *)&parent->children;
	      }
	}
    } while(!layer->hash_id);
  return;
}


struct layer *openlayer( struct layer *parent, struct TagItem *tags )
/* open a layer and add to the hierarchy. */
{
  struct layer *layer;
  struct layer *n;
  unsigned long w,h;
  
  if(!tags)tags=&nil_tag;


  if(!parent)return(Null);
  if(isHOTSPOT(parent))return NULL;

  locklayers(parent);
  
  if(layer=(struct layer *)allocobject(GT_Layer,sizeof(struct layer)))
    {
      layer->usecount = 1;
      layer->flags = (GetTagData(LA_NOCLIP,FALSE,tags)?LAYER_TYPE_NOCLIP:LAYER_TYPE_NORMAL);
      hashlayer(parent,layer);
      layer->user_id = GetTagData(LA_USER_ID,0,tags);

      layer->parent=parent;
      addlayerhead(layer,(struct rootlayer *)(parent->parent?NULL:parent));
      
      /* be sure to invalidate the arrangement of the layer. */
      layer->flags |= LAYER_SIZE_INVALID;
      layer->bounds.min.xy = 0;
      layer->bounds.max.xy = 0;



      /*
       * Handle everything to do with arrange
       * by the layers parent.
       */
      layer->spacing.left=GetTagData(LA_SPACING_LEFT,0,tags);
      layer->spacing.top=GetTagData(LA_SPACING_TOP,0,tags);
      layer->spacing.right=GetTagData(LA_SPACING_RIGHT,0,tags);
      layer->spacing.bottom=GetTagData(LA_SPACING_BOTTOM,0,tags);
	  
      layer->minwidth  = GetTagData(LA_MINIMUM_WIDTH,1,tags);
      layer->minheight = GetTagData(LA_MINIMUM_HEIGHT,1,tags);

      switch(layer->parent->flags&LAYER_ARRANGE_MASK)
	{
	case LAYER_ARRANGE_VERTICAL:
	case LAYER_ARRANGE_HORIZONTAL:
	  /* NOTE YOU"LL HAVE TO CHANGE removelayer() */
	  layer->layout.groups.link=NULL; /* deal with later. */

	  layer->bounds.min.xy = parent->bounds.min.xy;
	  if(layer->bounds.max.coor.x = GetTagData(LA_WIDTH,0,tags))
	    {
	      layer->bounds.max.coor.x += layer->bounds.min.coor.x-1;
	      layer->flags |= LAYER_FIXED_WIDTH;
	    }

	  if(layer->bounds.max.coor.y = GetTagData(LA_HEIGHT,0,tags))
	    {
	      layer->bounds.max.coor.y += layer->bounds.min.coor.y-1;
	      layer->flags |= LAYER_FIXED_HEIGHT;
	    }

	  /* get layer weight. */
	  if(layer->flags&LAYER_FIXED_WIDTH)layer->layout.groups.hweight=0;
	  else layer->layout.groups.hweight=GetTagData(LA_WEIGHT_HORIZONTAL,1,tags);
	  if(layer->flags&LAYER_FIXED_HEIGHT)layer->layout.groups.vweight=0;
	  else layer->layout.groups.vweight=GetTagData(LA_WEIGHT_VERTICAL,1,tags);
	  
	  break;

	case LAYER_ARRANGE_RELATIVE:
	  layer->layout.neighbors.toleft   = 
	    layer->layout.neighbors.totop    = 
	      layer->layout.neighbors.toright  = 
		layer->layout.neighbors.tobottom = NULL;

	  if(n=(struct layer *)GetTagData(LA_TOLEFT,NULL,tags))
	    if(checkobject(n,GT_Layer))layer->layout.neighbors.toleft = n->hash_id;
	  if(n=(struct layer *)GetTagData(LA_TOTOP,NULL,tags))
	    if(checkobject(n,GT_Layer))layer->layout.neighbors.totop = n->hash_id;
	  if(n=(struct layer *)GetTagData(LA_TORIGHT,NULL,tags))
	    if(checkobject(n,GT_Layer))layer->layout.neighbors.toright = n->hash_id;
	  if(n=(struct layer *)GetTagData(LA_TOBOTTOM,NULL,tags))
	    if(checkobject(n,GT_Layer))layer->layout.neighbors.tobottom = n->hash_id;

	  /* check for a fixed width. */
	  if(layer->bounds.max.coor.x=GetTagData(LA_WIDTH,0,tags))
	    { 
	      layer->bounds.max.coor.x--;
	      layer->flags |= LAYER_FIXED_WIDTH;
	      layer->flags |= (GetTagData(LA_LOCK_RIGHT,FALSE,tags)?LAYER_LOCK_RIGHT:NULL);
	    }
	  
	  /* do the same for the minimum height. */
	  /* note that LA_HEIGHT/LA_MINIMUM_HEIGHT are mutually
	     exclusive. */
	  if(layer->bounds.max.coor.y=GetTagData(LA_HEIGHT,0,tags))
	    { 
	      layer->bounds.max.coor.y--;
	      layer->flags |= LAYER_FIXED_HEIGHT;
	      layer->flags |= (GetTagData(LA_LOCK_BOTTOM,FALSE,tags)?LAYER_LOCK_BOTTOM:NULL);
	    }

	  break;

	default:
	  layer->bounds.min.coor.x = GetTagData(LA_LEFT,0,tags) +
	                              parent->bounds.min.coor.x; 
	  layer->bounds.min.coor.y = GetTagData(LA_TOP,0,tags) +
	                              parent->bounds.min.coor.y;
	  if(w=GetTagData(LA_WIDTH,0,tags))
	    layer->bounds.max.coor.x = layer->bounds.min.coor.x + (w-1);
	  else 
	    layer->bounds.max.coor.x = parent->bounds.max.coor.x;

	  if(h=GetTagData(LA_HEIGHT,0,tags))
	    layer->bounds.max.coor.y = layer->bounds.min.coor.y + (h-1);
	}                   



      /* determine if the layer will have grouped children. */
      layer->flags|= (GetTagData(LA_ARRANGE_VERTICAL,FALSE,tags)?LAYER_ARRANGE_VERTICAL:NULL)|
	(GetTagData(LA_ARRANGE_HORIZONTAL,FALSE,tags)?LAYER_ARRANGE_HORIZONTAL:NULL)|
	  (GetTagData(LA_ARRANGE_RELATIVE,FALSE,tags)?LAYER_ARRANGE_RELATIVE:NULL);


      switch(layer->flags&LAYER_ARRANGE_MASK)
	{
	case LAYER_ARRANGE_VERTICAL:
	case LAYER_ARRANGE_HORIZONTAL:
	  /* if yes, then the get all the margins. */
	  /* NOTE: setting the minimum dimensions is a kludge
	     to avoid any problems if a group is created without
	     any margins or children. */

	  break;
	  
	case LAYER_ARRANGE_RELATIVE:
	  /* If the layer is not a group, then it might be
	     a simple rectangle object, so the dimensions
	     can be forced. */

	  break;
	}

      /*
       * Refresh
       */
      layer->refresh.simple.stack = NULL;
	  
      


      layer->bitmap=parent->bitmap;


      layer->visibility = Null;
      if(!isCLIPPED(layer))
	{
	  layer->local_lock = parent->local_lock;
	  layer->clip       = usecliplist(parent->clip);
	}
      else
	{
	  initlayerlock(&layer->lock);
	  layer->local_lock = &layer->lock;
	  layer->clip       = newcliplist();
	}
      layer->root_lock=parent->root_lock;

      if(!isHOTSPOT(layer))
	{
	  layer->local = layer->region = NULL;
	  NewList(&layer->children);
	  
	  layer->margins.left   = GetTagData(LA_MARGIN_LEFT,0,tags);
	  layer->margins.top    = GetTagData(LA_MARGIN_TOP,0,tags);
	  layer->margins.right  = GetTagData(LA_MARGIN_RIGHT,0,tags);
	  layer->margins.bottom = GetTagData(LA_MARGIN_BOTTOM,0,tags);

	  /* NO STACKS FOR THE MOMENT. */
	  layer->refresh.simple.stack = NULL;

	  if(isCLIPPED(layer))
	    {
	      layer->flags |= (GetTagData(LA_REFRESH_SMART,FALSE,tags)?LAYER_REFRESH_SMART:NULL);

	      if(layer->refresh.super.bitmap = (BitMapPtr)GetTagData(LA_REFRESH_SUPER,NULL,tags))
		{
		  layer->flags |= LAYER_REFRESH_SUPER;
		  layer->refresh.super.bounds.min.xy = 0;
		  layer->refresh.super.bounds.max.coor.x = 
		    layer->refresh.super.bitmap->Width -1;
		  layer->refresh.super.bounds.max.coor.y =
		    layer->refresh.super.bitmap->Height -1;
		}
	      layer->damagelist = NULL;
	    }
	}

    }
  unlocklayers(parent);

  return(layer);
}

struct layer *uselayer( struct layer *layer )
/* preserve the layer by incrementing its usecount. */
{
  layer->usecount++;
  return layer;
}

struct layer *droplayer( struct layer *layer )
/* release the layer for destruction. */
{

  if(!(--layer->usecount))
    {
      /*
       * If the usecount reaches zero and the
       * layer is not held from destruction,
       * then free its resources.
       *
       *  The LAYER_DELAY_DISPOSE is set for the
       * the lowest layer that is being closed.  that
       * is the layer that you passed to closelayer().
       * This is because this layer has been locked.
       * It will be free'd in the unlock() funciton.
       */
      if(!(layer->flags&LAYER_DELAY_DISPOSE))
	{
	  if(layer->children.tailpred==(struct layer *)&layer->children)
	    { if(layer->parent)
		{ removelayer(layer);
		  layer->parent=NULL;
		}
	      freeobject(layer);
	      return(NULL);
	    }
	}
    }
  return(layer);
}

struct layer *disownlayer( struct layer *layer )
/* set the layer for automatic disposal with its parent. */
{
  /*
   * Before the layer can be set for automatic disposal it
   * needs to pass the following criteria:
   *  1. it has not already been marked previously.
   *     (actually, this would indicate poor programming and 
   *      should send an exec/Alert() message.
   *  2. it has a parent that can dispose of it.
   *  3. the layer and its parent have not already been closed. 
   *      That is why I check if the cliplist is still there.
   */
  if((!(layer->flags&LAYER_AUTOCLOSE)) &&
     layer->parent &&
     layer->parent->clip &&
     layer->clip)
    {
      layer->flags |= LAYER_AUTOCLOSE;
      return(layer);
    }
  return NULL;
}

struct layer *ownlayer( struct layer *layer )
/* gain owner priveleges to a layer marked for destruction. */
{
  /*
   * If the layer is marked for autodisposal
   * and it has not been closed already,
   * then clear the flag and pass back.
   */
  locklayer(layer);
   
  if(layer->flags&LAYER_AUTOCLOSE &&
     layer->clip)
    {
      layer->flags &= ~LAYER_AUTOCLOSE;
      unlocklayer(layer);
      return(layer);
    }
  unlocklayer(layer);
  return(NULL);
}

void lock( struct layer *layer )
/* locking used by closelayer(). */
{
  /*
   * First lock the layer and
   * set flag to keep droplayer()
   * from disposing of the layer.
   */
  locklayers(layer);
  layer->flags |= LAYER_DELAY_DISPOSE;
  return;
}

void unlock( struct layer *layer )
/* unlocklayer function used by closelayer(). */
{

  /*
   * Clear the flag just
   * in case the layer is
   * still not to be destroyed
   * within this function.
   */
  layer->flags &= ~LAYER_DELAY_DISPOSE;

   /*
    * The following are required to
    * dispose of a layer.
    *  1. the usecount must be zero.
    *  2. the layer cannot have any children.
    */
  if((!layer->usecount)&&(layer->children.tailpred==(struct layer *)&layer->children))
    { 
      /*
       * What to do:
       *  1. if the layer is not root, then remove ti
       *      from its parent's list.  Use removelayer()
       *      because the parent might be disposed of as a
       *      result.
       *  2. unlock the layer tree before the pointer is
       *      destroyed.
       *  3. release the object for future use.
       */
      if(layer->parent)
	removelayer(layer);
      unlocklayers(layer);
      freeobject(layer);
    }
  else unlocklayers(layer);

  return;
}

void close( struct layer *layer )
/* free resources allocated for a layer. */
{
  struct layer *index;
  struct layer *next;

  /*
   * Get the next layer in the
   * list before the layer
   * becomes invalid.
   */
  next = layer->next;

  /* 
   * first, unmap the layer
   * and all of its children.
   */
  if(layer->visibility)unmap(layer);

  /*
   * Get rid of the cliplist.  This action
   * marks the layer as officially closed.
   * If the cliplist is already gone, then
   * the layer has been closed once already
   * and we should end here.
   */
  if(layer->clip)
    { 
      disposecliplist(layer->clip); 
      layer->clip=NULL;

    /* 
     * if there are any children, then close them
     * also.  They will have their usecount lowered
     * only if the are marked LAYER_AUTOCLOSE.
     */
    if(layer->children.tailpred!=(struct layer *)&layer->children)
      for(index=layer->children.head;index->next;index=next)
        { next = index->next;
      
        /*
         * If they have not already been closed then do so.
         * If they are marked as autoclose, then drop the
         * usecount automatically.  If their not autoclose,
         * then it is the responsibility of the owner to
         * call autoclose even though all that will happen
         * is that the usecount will be dropped.
         */
	    if(index->clip)
	      { close(index);
	        if(index->flags&LAYER_AUTOCLOSE)droplayer(index);
	      }
        }
    }
  return;
}

void closeroot( struct rootlayer *root )
/* a call to close a root should only be done when everything
is guaranteed finished. */
{

  /* now deal with the normal part of layer */
  if(root->visibility)unmap((struct layer *)root);
  
  /*
   * If there are any children left,
   * then someone has been a naughty programmer
   * and not properly disposed of all layers.
   * send an Alert()
   */
   
   /*
    * Actually, this requirement can probably be lifted.
    * as long as all of the layers are closed
    * by the time the library is closed.  That is
    * checked by the resource lists.
    */
  if(root->children.tailpred!=(struct layer *)&root->children)
    Alert(ALERT_REMAINING_CHILDREN);

  if(root->clip)
    {
      disposecliplist(root->clip);
      root->clip=NULL;
    }

  return;
}

void closelayer( struct layer *layer )
/* free resources allocated for a layer. */
{
  lockio();
  lock(layer);

  /* go to the next level */
  if(!layer->parent)
    {
      /*
       * This is a root layer and
       * must be closed in a special manner.?
       */
      if(layer->clip)
	closeroot((struct rootlayer *)layer);
      droplayer(layer);
      unlock(layer);

      unlockio();
      return;
    }

  /*
   * If the layer has not been closed before then
   * do so.  Then lower the usecount and
   * unlock.
   */
  if(layer->clip)close(layer);
  droplayer(layer);
  unlock(layer);

  unlockio();

  return;
}


/*
 * These are all the functions for depth arranging layers
 * are changing the order that they appear in a horizontal
 * or vertical group.
 *
 * push()         -- pushes a layer to the back of the list.
 * pull()         -- pulls a layer to the front of the list.
 * pushlayer()    -- the entry point for G_PushLayer(). It uses
 *                   push() to do the dirty work after it checks
 *                   if the layer can be pushed at all.
 * pulllayer()    -- similar to pushlayer(), but uses pull().
 * cyclelayer()   -- This pulls a layer to the front, unless it is
 *                   already there.  In this case it pushes it
 *                   to the back. It uses both push() and pull().
 * shufflelayer() -- This function puts a layer behind another.
 *                   It does not actually work as of (Nov.21,1995).
 */

void push( struct layer *layer, struct rootlayer *root )
{
  struct region *old;
  struct layer *stop,*index;

  /*
   * If this layer is the first of the
   * backdrop layers, then move that honor
   * to the next in line.  Of course,
   * this only applies if the parent
   * is root.
   */
  if(root&&(root->backdrop==layer))
    root->backdrop = layer->next;
    
  /*
   * take the layer out of the list temporarily
   * and immediately place it back in. addlayertail()
   * handles all the bother of having a root.
   */
  stop = layer->next;
  Remove(layer);
  addlayertail(layer,root);

  /*
   * Now we must deal with
   * any changes that might take
   * place to the screen.
   */
  if(layer->visibility)
    {
     /*
      * If the layer belongs to a group, then
      * the order has been changed and the
      * layout must be recalculated.
      */
      if(layer->parent->flags&LAYER_ARRANGE_MASK)
  	    index=arrangelayer(layer->parent,0,0);
      else index = NULL;

      /*
       * As for refreshing there are
       * two possibilities.
       * 1. if a group had to be rearranged or
       *    if the layer has no clipping of its own
       *    then we must refresh an appropriate parent.
       * 2. if the layer has its own clipping
       *    and is not a member of a group, then
       *    we simply have to refresh all sibling
       *    layers we may have been exposed as
       *    a result of this operation.
       */
      if(index||(!isCLIPPED(layer)))
	{
	  if(!index)index=layer->parent;
	  while(isNOCLIP(index))index=index->parent;
	  refreshparent(index,NULL,NULL,TRUE);
	}
      else
	{
	  /*
	   * Calculate the region left
	   * exposed by the layer.  Then 
	   * refresh all layers that may be
	   * exposed. (NOTE: only clipped layers
	   * since other layers inherit from
	   * the parent which cannot draw into 
	   * the bounds of the layer.
	   */
	  old = useregion(layer->local);
	  updatelayer(layer);
	  old = clearregionregion(old,layer->local);

	  refreshlayer(layer,old);

	  for(index=stop;index!=layer;index=index->next)
	    if(isCLIPPED(index))refresh(index,old,NULL,TRUE);

	  disposeregion(old);
	}
	
	/*
	 * Finally, send a message to the input.device
	 * that the focus may have changed.
	 */
	 signalevent(IECLASS_CHECK_FOCUS,NULL);
    }
  return;
}

void pull( struct layer *layer, struct rootlayer *root )
/* bring a layer to the head of its list and refresh the screen. */
{
  struct region *old,*damage;
  struct layer *stop,*index;
  
  /*
   * if the layer is an overlay and at
   * the back of its peers, then when 
   * we are done, it will be at the
   * front.
   */
  if(root&&root->overlay==layer)
    root->overlay = layer->prev;
    
  /*
   * remove the layer from the list and
   * immediately place at the head.  The
   * bother of overlays/backdrops is
   * all handled neatly within addlayerhead().
   */
  stop = layer->prev;
  Remove(layer);
  addlayerhead(layer,root);

  /*
   * If the layer was visible, then the
   * screen will have to be refreshed.
   */
  if(layer->visibility)
    {
      /*
       * if the layer is a member of a group,
       * then changing the order requires that
       * the layout be recalculated.
       */
      if(layer->parent->flags&LAYER_ARRANGE_MASK)
	index=arrangelayer(layer->parent,0,0);
      else index = (isCLIPPED(layer)?NULL:layer->parent);

     /*
      * index will be non-zero in two cases:
      * 1) the layer is a member of a group and index
      *    is the parent layer.
      * 2) the layer is not clipped and a parent must be 
      *    refreshed in its place.
      */
      if(index)
	{
	  
	  /*
	   * Find a layer that is clipped and then
	   * refresh it.
	   */ 
	  while(isNOCLIP(index))index=index->parent;
	  refreshparent(index,NULL,NULL,TRUE);
	}
      else
	{
	  /*
	   * In this case, the layer might have
	   * a new portion exposed. After updating
	   * the layer, create the damage region
	   * and all refresh.
	   */
	  old = useregion(layer->local);
	  updatelayer(layer);
	  damage = clearregionregion(useregion(layer->local),old);
	  refreshlayer(layer,damage);
	  
	  disposeregion(old);
	  disposeregion(damage);
	  
	  /*
	   * update any siblings
	   * that might have been
	   * covered up by this operation.
	   */
	  for(index=stop;index!=layer;index=index->prev)
	    if(isCLIPPED(index))updatelayers(index,NULL);
	}

	/*
	 * Finally, send a message to the input.device
	 * that the focus may have changed.
	 */
	 signalevent(IECLASS_CHECK_FOCUS,NULL);
    }
  return;
}



void pushlayer( struct layer *layer )
/* push the layer to the back of its stack. */
{
  struct rootlayer *root;

  lockio();
  locklayers(layer);

  /*
   * The layer should only be pushed, if there
   * is another layer to be pushed behind.
   * In the case of a root layer, we must deal
   * with both backdrops and overlays.
   */
  if(layer->parent&&layer->next->next)
    {
      if(!layer->parent->parent)
	{
	  root=(struct rootlayer *)layer->parent;
	  if(layer!=root->overlay && layer->next!=root->backdrop)push(layer,root);
	}
      else push(layer,NULL);
    }
  unlocklayers(layer);
  unlockio();

  return;
}

void pulllayer( struct layer *layer )
/* pull the layer to the front of the stack. */
{
  struct rootlayer *root;

  lockio();
  locklayers(layer);

  /*
   * The layer should only be pulled if it
   * will actually change the order of the list.
   * If the layer's parent is root, then we
   * must deal with backdrops and overlays.
   *
   * Be careful of some bozo trying to
   * pull the root layer.
   */
  if(layer->parent&&layer->prev->prev)
    {
      if(!layer->parent->parent)
	{
	  root=(struct rootlayer *)layer->parent;
	  if(root->backdrop!=layer && layer->prev!=root->overlay)pull(layer,root);
	}
      else pull(layer,NULL);
    }

  unlocklayers(layer);
  unlockio();

  return;
}

void cyclelayer( struct layer *layer )
/* pull the layer to the front of the stack. */
{
  struct rootlayer *root;

  lockio();
  locklayers(layer);

  
  if(layer->parent)
    {
      if(!layer->parent->parent)
	{ 
	  /*
	   * lots of tests here.
	   *  the layer is pulled if
	   *    1. it has another layer before it.
	   *    2. AND that previous layer is not the last of the overlays.
	   *    3. AND the layer is not the first of the backdrops.
	   *
	   *  the layer is pushed if
	   *    0. it is not pulled.
	   *    1. AND there is a layer behind it.
	   *    2. AND the next layer is not the first of the backdrops.
	   *    3. AND the layer is not the last of the overlays.
	   */
	  root=(struct rootlayer *)layer->parent;
	  if(layer->prev->prev && layer!=root->backdrop && layer->prev!=root->overlay)pull(layer,root);
	  else if(layer->next->next && layer!=root->overlay && layer->next!=root->backdrop)push(layer,root);
	}
      else
	{
	  /*
	   * If the layer is in the front, then pull it. Otherwise
	   * push it. Assuming of course that the layer is not
	   * the only member of the list.
	   */
	  if(layer->prev->prev)pull(layer,NULL);
	  else if(layer->next->next)push(layer,NULL);
	}
    }

  unlocklayers(layer);
  unlockio();

  return;
}



void shufflelayer( struct layer *layer, struct layer *target )
/* reshuffle the order of a layer stack. */
{
  /*
   * I'm just so lazy I've not written this
   * one yet.
   */
  return;
}


/*
 * Functions for changing the layers bounds.
 *
 * movechild()      -- This function move the bounds of a child.
 *                     It will also update the layer if asked nicely.
 *                     This function is used by many of the others.
 *
 * movelayer()      -- This function is the entry point for G_MoveLayer()
 *                     If the layer is not arranged, it will move
 *                     the upper left corner to the point specified.
 *
 * dosomething()
 *
 * movesizelayer()  -- This function changes the bounds of the layer
 *                     
 * sizelayer()      -- This function uses movesizelayer to change the
 *                     dimensions of the layer.
 */
 
void movechild( struct layer *layer, int dx, int dy, BOOL UPDATE )
/* translates the bounds of the layer. */
{
  struct layer *index;

  /*
   *  Move the bounds of the rectangle.
   */
  moverectangle(layer->bounds,dx,dy);

  /*
   * If the layer was mapped, then
   * it is possible to update the layer.
   */
  if(layer->visibility&&UPDATE)updatelayer(layer);
    
    /*
     * Pass the message along to all
     * of the layer's children. Note the
     * a hotspot layer has no children.
     */
    if(!isHOTSPOT(layer))
      for(index=layer->children.head;index->next;index=index->next)movechild(index,dx,dy,UPDATE);

  return;
}

void movelayer( struct layer *layer, int left, int top )
/* Move the upper-left corner of the layer to left,top. */
{
  int dx,dy;
  struct layer *index;
  struct region *old,*temp,*damage,*new;
  union point origin;
  BitMapPtr bitmap;

  lockio();
  locklayers(layer);

  /*
   * The layer must have a parent and
   * it cannot be arranged by its parent
   * in any way.
   */
  if(layer->parent&&(!(layer->parent->flags&LAYER_ARRANGE_MASK)))
    {
      /*
       * calculate the distance traveled
       * and then change the bounds.
       */
      dx = left-(layer->bounds.min.coor.x-layer->parent->bounds.min.coor.x);
      dy = top-(layer->bounds.min.coor.y-layer->parent->bounds.min.coor.y);
      moverectangle(layer->bounds,dx,dy);
      
      /*
       * If the layer was mapped, then we'll
       * have to update the display.
       */
      if(layer->visibility)
	{
	  /*
	   * If the layer was clipped, then we can update
	   * just where it was moved to and from.  If it
	   * was not clipped, then simly refresh its
	   * parent completely.
	   */
	  if(isCLIPPED(layer))
	    {
	      /* 
	       * Determine the region uncovered
	       * by the movement of the layer.
	       */
	      damage = clearrectregion(useregion(layer->local),&layer->bounds);
	      old = useregion(layer->local);
	      old = moveregion(old,dx,dy);
	      
	      /* 
	       * Update the layer's regions and
	       * cliplist.  The previous portion of
	       * the damagelist must be moved along
	       * with the layer.
	       */
	      updatelayer(layer);
	      moveregion(layer->damagelist,dx,dy);
	      
	      /*
	       * Move all of the children.
	       */
	      for(index=layer->children.head;index->next;index=index->next)
		movechild(index,dx,dy,TRUE);
	      
	      /*
	       * Determine the damage.
	       * 
	       *  If the layer was buffered, then all that
	       * we have to do is refresh using the buffer.
	       * If the layer was simple, then copy as much
	       * as we can of what was previously on the
	       * screen and the rest becomes the
	       * damaged area.
	       */
	      for(index=layer->parent;index->parent&&isBUFFERED(index);index=index->parent);
	      switch(LAYER_REFRESH_TYPE(layer))
		{
		case LAYER_REFRESH_SMART:
		  refreshsmart(layer,layer->local);
		  break;
		case LAYER_REFRESH_SUPER:
		  refreshsuper(layer,layer->local);
		  break;
		default: /* simple refresh. */
		  
		  /*
		   * Find the first buffer up the
		   * layer tree. This bitmap will contain
		   * the most complete picture of the layer.
		   * Use this bitmap as the source for blitting.
		   */
		  switch(LAYER_REFRESH_TYPE(index))
		    {
		    case LAYER_REFRESH_SUPER:
		      bitmap    = index->refresh.super.bitmap;
		      origin.xy = index->refresh.super.bounds.min.xy;
		      break;
		      
		    case LAYER_REFRESH_SMART:
		      bitmap    = index->refresh.smart.buffer;
		      origin.xy = layer->bounds.min.xy;
		      break;
		      
		    default:  /* The root layer. */
		      bitmap    = index->bitmap;
		      origin.xy = 0;
		      break;
		    }
		  /*
		   * To save some space for redundant code,
		   * I'll use bufferedrefresh() with some hacked
		   * up arguments.
		   *  bufferedrefresh() will copy a bitmap into the
		   * bitmaps of the layer's parent through the
		   * damagelist. So, the steps required are:
		   * 1. save the current damagelist.
		   * 2. make a temporary one. This damagelist consists
		   *    of all the space in which the old exposed area
		   *    can be copied into. We'll need to sort this
		   *    because the first bitmap found by bufferedrefresh()
		   *    will be the one we're passing. After that it
		   *    does no matter what happens to the region.
		   * 3. create some fake origin shifted by the
		   *    amount we've moved the layer.
		   * 4. now we can call bufferedrefresh().
		   * 5. restore the damagelist.
		   */
		  temp = layer->damagelist;
		  layer->damagelist = andregionregion(useregion(old),layer->region);
		  sortregion(layer->damagelist,dx,dy);
		  origin.coor.x = dx;
		  origin.coor.y = dy;
		  bufferedrefresh(layer,layer->damagelist,bitmap,origin);
		  disposeregion(layer->damagelist);
		  layer->damagelist = temp;
		  
		  /*
		   * The newly exposed areas are those that were
		   * not copied from the old region.
		   * Call refresh() to fix those parts.
		   */
		  new = clearregionregion(useregion(layer->region),old);
		  refreshlayer(layer,new);
		  disposeregion(new);
		  break; 
		}
	      
	      /*
	       * Finally, we must refresh the areas left
	       * exposed by the movement of the layer.
	       */
	      refreshparent(index,damage,layer,TRUE);
	      
	      /*
	       * Everything is now complete. 
	       */
	      disposeregion(old);
	      disposeregion(damage);
	    }
	  else /* If the layer is not clipped, then refresh parent. */
	    {
	      /*
	       * Move the children, but
	       * wait to udpate until we've
	       * done so to the layer's 
	       * parent.
	       */
	      if(!isHOTSPOT(layer))
	        for(index=layer->children.head;index->next;index=index->next)
		  movechild(index,dx,dy,FALSE);
	      /*
	       * Refresh the parent and
	       * perform updating on all
	       * children, including
	       * this layer.
	       */
	      refreshparent(layer->parent,NULL,NULL,TRUE);
	    }
	}
      else
	{ /* The layer is not visible. */
	  if(!isHOTSPOT(layer))
	    for(index=layer->children.head;index->next;index=index->next)
	      movechild(index,dx,dy,FALSE);
	}
    }
  unlocklayers(layer);
  unlockio();
  
  return;
}

void refreshbounds( struct layer *layer, int dx, int dy )
/* Perform a refresh of the screen after the layer bounds have changed. */
{
  struct region *temp;
  struct layer *index;

  /*
   * This function is a subroutine to both
   * movesizelayer() and sizelayer(). It handles
   * refreshing the screen after the
   * bounds of a layer have been changed.
   */
   
  /*
   * If the layer is arranged by its parent,
   * then its sibling might have been affected
   * by the change.  In this case the
   * refreshing is handled by the parent.
   * Note: if the layer does not clip at its
   * bounds, then the parent should refresh also,
   */
  if((!isCLIPPED(layer)) || (layer->parent->flags&LAYER_ARRANGE_MASK))
    {
      /*
       * If arranged by its parent, then
       * call for a general arrangement.
       * Otherwise, just arrange the layer's 
       * children.  The amount that the layer's
       * origin has moved is passed as dx,dy.
       */
      if(layer->parent->flags&LAYER_ARRANGE_MASK)
	index=arrangelayer(layer->parent,0,0);
      else index=arrangelayer(layer,dx,dy);

      /*
       * Find an appropriate layer
       * and begin the refresh. Include
       * all the layers and an update.
       */
      while(!isCLIPPED(index))index=index->parent;
      refreshparent(index,NULL,NULL,TRUE);
    }
  else
    {
      /*
       * If the layer is clipped, then we
       * must refresh:
       * 1) It's bounds.  pass NULL for the
       *    damage in order to refresh the
       *    entire layer.
       * 2) Whatever was exposed by
       *    the layer, that should be
       *    sent to the parent for
       *    refresh.
       */
       
       /*
        * calculate region exposed by the 
        * operation: temp.  Note that
        * while the bounds have been updated
        * the regions are still old.
        */
      temp = clearrectregion(useregion(layer->local),&layer->bounds);
      
      /*
       * Arrange the layer's children and
       * refresh its bounds entirely.
       */
      arrangelayer(layer,dx,dy);
      refreshlayer(layer,NULL);
      
      /*
       * Now find an appropriate layer up
       * the tree and refresh 'temp'.  Get
       * rid of the region when we're done.
       */
      for(index=layer->parent;isNOCLIP(index);index=index->parent);
      refreshparent(index,temp,layer,TRUE);
      disposeregion(temp);
    }
  return;
}


void movesizelayer( struct layer *layer, int left, int top, ulong width, ulong height )
/* Change the frame of the layer. */
{
  int dx,dy;

  lockio();
  locklayers(layer);

  /*
   * You can only perform this operation
   * if the layer is not arranged by its
   * parent.  (It also needs a parent)
   */
  if(layer->parent&&(!(layer->parent->flags&LAYER_ARRANGE_MASK)))
    {
      /*
       * Determine how much the layer has moved.
       */
      dx = left - (layer->bounds.min.coor.x-layer->parent->bounds.min.coor.x);
      dy = top  - (layer->bounds.min.coor.y-layer->parent->bounds.min.coor.y);
      
      /*
       * Guarantee that there has been
       * some change before actually calling
       * subroutine to do the work.
       */
      if(dx||dy||(width!=rectwidth(layer->bounds))||(height!=rectheight(layer->bounds)))
	{
	  /*
	   * Change the bounds before
	   * refreshing.
	   */
	  layer->bounds.max.coor.x = (width-1) + (layer->bounds.min.coor.x+=dx);
	  layer->bounds.max.coor.y = (height-1) + (layer->bounds.min.coor.y+=dy);
	  
	  /*
	   * If the layer is mapped, then we'll
	   * need to refresh the screen.
	   */
	  if(layer->visibility)refreshbounds(layer,dx,dy);
	}
    }
  unlocklayers(layer);
  unlockio();

  return;
}

void sizelayer( struct layer *layer, ulong width, ulong height )
/* Change the dimensions of a layer. */
{
  lockio();
  locklayers(layer);
  
  /*
   * This function works similarly to movesizelayer(),
   * but it can still be done even if the layer is arranged.
   * However, the layer must have a fixed dimension if
   * that is the case.
   */
  if(layer->parent)
    {
      /*
       * Calling this function will automatically make a layer
       * have fixed dimensions.       
       */
      if(layer->parent->flags&LAYER_ARRANGE_MASK)
	{
	  /*
	   * Passing a size of 0 indicates
	   * that there should be no
	   * change.
	   */
	  if(width)
	    layer->flags |= LAYER_FIXED_WIDTH;
	  if(height)
	    layer->flags |= LAYER_FIXED_HEIGHT;
        }
      
      /*
       * Now check if there are any changes
       * in the layer before refreshing.
       */     
      if((width&&(width!=rectwidth(layer->bounds))) || 
	 (height&&(height!=rectheight(layer->bounds))))
	{
	  /*
	   * Change the bounds and then
	   * all subroutine to refresh
	   * the screen. (if mapped)
	   */
	  layer->bounds.max.coor.x = (width-1)  + layer->bounds.min.coor.x;
	  layer->bounds.max.coor.y = (height-1) + layer->bounds.min.coor.y;
	  
	  /*
	   * If the layer is mapped, then we'll need to
	   * refresh the screen.
	   */
	  if(layer->visibility)refreshbounds(layer,0,0);
	}
    }
  unlocklayers(layer);
  unlockio();
  
  return;
}


void scrolllayer( struct layer *layer, int dx, int dy )
/* Scroll the interior of a layer. */
{
  ulong adx,ady;
  ulong width,height;
  union point origin;
  struct rectangle rect;
  struct layer *index;
  struct region *temp,*shift,*damage;
  BitMapPtr bitmap;

  /*
   * Make sure that there is a change.
   */
  if(!(dx|dy))return;

  lockio();
  locklayers(layer);
  
  /*
   * This can only be done if the layer
   * has a virtual boundary or if the
   * children of the layer are not arranged.
   */
  if(isSUPER(layer)||(!(layer->flags&LAYER_ARRANGE_MASK)))
    {
      /* 
       * Update all the appropriate regions
       * and bounds.
       *  1. if the layer has virtual bounds, then move
       *     those and the region that matches it.
       *  2. if the layer is clipped, then move the damagelist.
       *      Ooops, I've moved that farther down, after
       *      I've checked for mapping.
       *  3. move and update all the children.
       */
      if(isSUPER(layer))
	{
	  moverectangle(layer->refresh.super.bounds,dx,dy);
	  if(layer->region)moveregion(layer->region,dx,dy);
	}

      if(!isHOTSPOT(layer))
        for(index=layer->children.head;index->next;index=index->next)
	  movechild(index,dx,dy,TRUE);
      
      /*
       * Now, if the layer is mapped, then we'll
       * need to refresh the screen.
       */
      if(layer->visibility)
	{
	  if(isCLIPPED(layer))
	    {
	      /*
	       * Move the damagelist along with
	       * us.
	       */
	      moveregion(layer->damagelist,dx,dy);
	    
	    
	      /*
	       * How do we refresh the screen?
	       *
	       * 1. A superbitmap layer just needs to
	       *    copy the bitmap onto the screen. I 
	       *    should also clear the margins.
	       *
	       * 2. A smart refresh layer will first 
	       *    shift its bitmap, then copy it to
	       *    the screen.  Then the blank area
	       *    will be refreshed like a simple 
	       *    refresh.
	       *
	       * 3. A simple refresh will copy what is 
	       *    available. This is similar to
	       *    the code in movelayer().  The refresh
	       *    the rest.
	       */
	      switch(LAYER_REFRESH_TYPE(layer))
		{
		case LAYER_REFRESH_SUPER:
		  refreshsuper(layer,layer->local);
		  break;
		case LAYER_REFRESH_SMART:
		  /*
		   * Determine the absolute value
		   * of the shift. If its wider
		   * than the buffer, then just
		   * clear it.
		   */
		  adx = (dx<0?-dx:dx);
		  ady = (dy<0?-dy:dy);
		  
		  width  = rectwidth(layer->bounds);
		  height = rectheight(layer->bounds);
		  if((adx<width)&&(ady<height))
		    {
		      /*
		       * Well a portion of the
		       * buffer is still okay, so
		       * shift it and
		       * then copy it to
		       * the screen.
		       */
		      g_Copy(layer->refresh.smart.buffer,(dx<0?0:adx),
			                                 (dy<0?0:ady),
			                                 width-adx,height-ady,
			                                 layer->refresh.smart.buffer,
			                                 (dx>0?0:adx),
			                                 (dy>0?0:ady));
		      refreshsmart(layer,layer->local);
		    }
		  /*
		   * The rest is done as a simple refresh.
		   * 1. mark the buffer as incomplete.
		   * 2. determine the damaged region.
		   * 3. call refresh().
		   */
		  layer->flags |= LAYER_BUFFER_INVALID;
		  rect = layer->bounds;
		  damage = newregion(&rect);
		  moverectangle(rect,dx,dy);
		  damage = clearrectregion(damage,&rect);
		  refreshlayer(layer,damage);
		  disposeregion(damage);
		  break;
		  
		default: /* A simple refresh layer. */
		  /*
		   * In the case of a simple refresh layer
		   * we'll try to copy all of what is available
		   * and then refresh the remainder. So first
		   * of all we need what can be copied into.
		   *
		   *  We'll put this region into the damagelist
		   * for the time being.
		   */
		  temp = layer->damagelist;
		  shift = moveregion(useregion(layer->region),dx,dy);
		  layer->damagelist = andregionregion(useregion(shift),layer->region);

		  if(layer->damagelist->rectangles)
		    {
		      /*
		       * Now we'll find the first buffer up the
		       * layer tree and use this a source to
		       * copy what we can.
		       */
		      for(index=layer->parent;index->parent&& isSIMPLE(index);index=index->parent);
		      switch(LAYER_REFRESH_TYPE(index))
			{
			case LAYER_REFRESH_SUPER:
			  bitmap    = index->refresh.super.bitmap;
			  origin.xy = index->refresh.super.bounds.min.xy;
			  break;
			case LAYER_REFRESH_SMART:
			  bitmap    = index->refresh.smart.buffer;
			  origin.xy = index->bounds.min.xy;
			  break;
			default: /* root bitmap */
			  bitmap    = index->bitmap;
			  origin.xy = 0;
			  break;
			}

		      /*
		       * The actual copying will be done by
		       * bufferedrefresh(). This function is normally
		       * used by smartrefresh() and superrefresh().
		       * Here, I'll hack up some arguments to get
		       * it to use the bitmap as the source.
		       */
		      sortregion(layer->damagelist,dx,dy);
		      origin.coor.x -= dx;
		      origin.coor.y -= dy;
		      bufferedrefresh(layer,layer->damagelist,bitmap,origin);

		      /*
		       * Now, restore the previous
		       * damagelist.
		       */
		      disposeregion(layer->damagelist);
		      layer->damagelist = temp;
		    }
		  /*
		   * Determine the damaged area.
		   *  This region is the local region minus
		   * the shifted region.
		   */
		  damage = clearregionregion(useregion(layer->local),shift);
		  refreshlayer(layer,damage); /* ,FALSE); */
		  disposeregion(shift);
		  disposeregion(damage);
		  break;
		}
	    }
	  else /* no clipping layers? Just refresh the parent. */
	    refreshparent(layer->parent,NULL,NULL,TRUE);
	}
    }
  return;
}


struct layer *searchlayers( struct layer *layer, union point *xy )
/* Searches the layer tree for layer under the point. */
{
  struct layer *index,*child;

  /*
   * Layer must be visibile.
   */
  if(layer->visibility)
    {
      /*
       * Check the bounds as a first
       * test.
       */
      if((xy->coor.x>=layer->bounds.min.coor.x)&&
	 (xy->coor.y>=layer->bounds.min.coor.y)&&
	 (xy->coor.x<=layer->bounds.max.coor.x)&&
	 (xy->coor.y<=layer->bounds.max.coor.y))
	{
	  /*
	   * This one is okay, so continue the search
	   * through the layer's children.
	   */
	  if(!isHOTSPOT(layer))
	    for(index=layer->children.head;index->next;index=index->next)
	      if(child=searchlayers(index,xy))return(child);

	  /*
	   * No appropriate child was found, so 
	   * return the layer.
	   */	  
	  return(layer);
	}
    }
  /*
   * The point did not fall within the
   * bounds of the layer, so return
   * NULL.
   */
  return(Null);
}

struct layer *whichlayer( struct layer *layer, union point *xy )
/* Return pointer to layer under the point xy. */
{
  struct rrectangle *rrectp;
  struct layer *foo,*root;

  if(!layer)return(NULL);

  locklayers(layer);
  
  /*
   * First, we have to start at a clipped layer.
   */
  for(foo=layer;!isCLIPPED(foo);foo=foo->parent);

  /*
   * Search the branch starting with foo
   * for a the topmost layer under xy.
   */
  if(foo=(struct layer *)searchlayers(foo,xy))
    {
      /*
       * Double check that the point
       * is truly within the
       * visibility of the layer.
       * Otherwise, we'll need to start at
       * the root layer.
       */
      for(rrectp=foo->visibility->rectangles;rrectp;rrectp=rrectp->next)
	if((xy->coor.x>=rrectp->bounds.min.coor.x)&&
	   (xy->coor.x<=rrectp->bounds.max.coor.x)&&
	   (xy->coor.y>=rrectp->bounds.min.coor.y)&&
	   (xy->coor.y<=rrectp->bounds.max.coor.y))break;
	  
	  /*
	   * If a region rectangle was found, then
	   * this layer truly is the one underneath
	   * the point xy.
	   */
      if(rrectp)
	{
	  /*
	   * Last things to do:
	   *  1. use the layer pointer so that it remains valid.
	   *  2. translate the coordinates to the 
	   *     reference frame of the layer.
	   *  3. eat the layer that was passed
	   *     in as sacrifice.
	   */
	  uselayer(foo);
	  xy->coor.x -= foo->bounds.min.coor.x;
	  xy->coor.y -= foo->bounds.min.coor.y;
	  unlocklayers(layer);
	  droplayer(layer);
	  return(foo);
	}
	  /*
	   * The search was a bust, so we'll 
	   * set it NULL and start from the root.
	   */
      foo = NULL;
    }
  /* get the root layer. */
  for(root=layer;root->parent;root=root->parent);
  
  /*
   * If the layer passed was the root then
   * don't even bother.
   */
  if(root!=layer)
    foo=(struct layer *)searchlayers(root,xy);
  
  /*
   * Again, if the result was positive this
   * time, then use the pointer and
   * translate the coordinates.
   */
  if(foo)
    { uselayer(foo);
      xy->coor.x -= foo->bounds.min.coor.x;
      xy->coor.y -= foo->bounds.min.coor.y;
    }
    
  unlocklayers(layer);
  droplayer(layer);
  return(foo);
}


boolean layerrelative( struct layer *layer, union point *xy )
/* Translate point xy from global to layer coordinates. */
{
  locklayer(layer);

  /*
   * Make sure that the
   * coordinates are valid.
   */
  if(layer->visibility && (layer->flags&LAYER_BOUNDS_VALID))
    {
      xy->coor.x -= layer->bounds.min.coor.x;
      xy->coor.y -= layer->bounds.min.coor.y;
      unlocklayer(layer);
      return(True);
    }
  unlocklayer(layer);

  return(False);
}


		



/*
 * layer query functions 
 *
 * These are functions provided by the library to 
 * get information from the layers that is
 * strictly not available directly because layers
 * are private structures.
 *
 * getlayerid()      - Gets user defined id number for the layer.
 *
 * getlayerhead()    - Gets the first child in the layers list.
 *
 * getlayertail()    - Gets the last child in the layers list.
 *
 * getlayernext()    - Gets the next layer immediately following
 *                     the layer.
 *
 * getlayerprev()    - Gets the layer immediately preceding the
 *                     layer.
 *
 * getlayerbitmap()  - Gets the layers bitmap.  That is, the first 
 *                     bitmap be the root or a smart refresh
 *                     buffer that is found.
 * 
 * getroot()         - Gets the root layer.
 *
 * getrootbitmap()   - Gets the roots bitmap.
 *
 * getlayerbounds()  - Gets the layer bounds either relative to
 *                     its parent or in the global coordinates
 *                     of the root.
 *
 * getlayerframe()   - Fills a frame structure with the position
 *                     and size of the layer relative to its
 *                     parent's origin or in the root's coordinates.
 *
 * getlayersize()    - Returns the dimensions of the layer. returns 0
 *                     if the layer is not mapped.
 *
 * getlayerorigin()  - Gets the origin of the layer relative to
 *                     its parent or in the root's coordinates.
 *
 * getlayerminimum() - Gets the minimum size of the layer.
 *
 * getlayerparent()  - returns the layer's parent.
 *
 * NOTE:   The functions getlayernext() and getlayerprev() are useful
 *         for going through the list of the layer's children.
 *         To increase their usefulness, they also eat the layer passed,
 *         to avoid any ugly uselayer()/droplayer() mess. An example
 *         of their use is the following.
 *           for(child=G_GetLayerHead(layer);child;child=G_GetLayerNext(child))
 *             { ... 
 *                do whatever.
 *               ...
 *             }
 *         When we're done, there's no need to call droplayer() unless you've
 *         prematurely broken out of the loop.
 *
 * NOTE#2: The other functions which return geometrical information 
 *         about the layer will only work if the layer is mapped.
 *         Otherwise the layer's bounds are not valid. These functions
 *         have a way of returning a bad value or boolean.
 */

unsigned char getlayerid( struct layer *layer )
{
  return layer->user_id;
}

struct layer *getlayerhead( struct layer *layer )
/* returns the first of the layer's children. */
{
  struct layer *child;
 
  locklayer(layer);
  
  if((!isHOTSPOT(layer) && layer->children.tailpred!=(struct layer *)&layer->children))
    child = uselayer(layer->children.head);
  else child = NULL;
  
  unlocklayer(layer);
  droplayer(layer);

  return(child);
}

struct layer *getlayertail( struct layer *layer )
/* returns the last of the layer's children. */
{
  struct layer *child;
  
  locklayer(layer);
  
  if((!isHOTSPOT(layer) && layer->children.tailpred!=(struct layer *)&layer->children))
    child = uselayer(layer->children.tailpred);
  else child = NULL;
  
  unlocklayer(layer);
  droplayer(layer);
  
  return(NULL);
}

struct layer *getlayernext( struct layer *layer )
/* Get the layer immediately following the layer. */
{
  struct layer *next;
  
  locklayer(layer);
  if(layer->next->next)
    next = uselayer(layer->next);
  else next = NULL;
  
  unlocklayer(layer);
  droplayer(layer);
  
  return(NULL);
}

struct layer *getlayerprev( struct layer *layer )
/* Get the layer immediately preceding the layer. */
{
  struct layer *prev;
  
  locklayer(layer);
  
  if(layer->prev->prev)
    prev = uselayer(layer->prev);
  else prev = NULL;
  
  unlocklayer(layer);
  droplayer(layer);
  
  return(NULL);
}


ulong getlayersize( struct layer *layer )
/* return the size of a */
{
  union point size;

  locklayer(layer);

  size.coor.x = layer->bounds.max.coor.x - layer->bounds.min.coor.x +1;
  size.coor.y = layer->bounds.max.coor.y - layer->bounds.min.coor.y +1;

  unlocklayer(layer);
  return size.xy;
}


boolean getlayerorigin( struct layer *layer, union point *xy, int global )
{
  locklayer(layer);

  if(layer->flags&LAYER_BOUNDS_VALID)
    {
      if(global||(!layer->parent))*xy=layer->bounds.min;
      else
	{ xy->coor.x = layer->bounds.min.coor.x-layer->parent->bounds.min.coor.x;
	  xy->coor.y = layer->bounds.min.coor.y-layer->parent->bounds.min.coor.y;
	}
      unlocklayer(layer);
      return(True);
    }

  unlocklayer(layer);
  return(False);
}

boolean getlayerframe( struct layer *layer, struct frame *frame, int global )
{
  locklayer(layer);

  if(layer->flags&LAYER_BOUNDS_VALID)
    {
      frame->size.coor.x = rectwidth(layer->bounds);
      frame->size.coor.y = rectheight(layer->bounds);

      if(global||(!layer->parent))frame->origin=layer->bounds.min;
      else
	{ frame->origin.coor.x = layer->bounds.min.coor.x-layer->parent->bounds.min.coor.x;
	  frame->origin.coor.y = layer->bounds.min.coor.y-layer->parent->bounds.min.coor.y;
	}
      unlocklayer(layer);

      return(True);
    }

  unlocklayer(layer);
  return(False);
}


boolean getlayerbounds( struct layer *layer, struct rectangle *bounds )
{
  locklayer(layer);
  
  if(layer->flags&LAYER_BOUNDS_VALID)
    {
      *bounds=layer->bounds;
      unlocklayer(layer);
      return(True);
    }

  unlocklayer(layer);
  return(False);
}

ulong getlayerminimum( struct layer *layer )
{
  union point size;


  locklayer(layer);

  if(layer->flags&LAYER_MIN_VALID)
    {
      size.coor.x = layer->minwidth;
      size.coor.y = layer->minheight;
      unlocklayer(layer);
      return(size.xy);
    }
  unlocklayer(layer);
  return(0);
}

struct layer *getlayerparent( struct layer *layer )
{
  return layer->parent?uselayer(layer->parent):NULL;
}

E_EBitMapPtr getlayerbitmap( struct layer *layer )
{
  return(layer->bitmap);
}

/*
 * layer primitive functions.
 */
boolean copygc( struct layer *layer, struct G_GC *gc, struct G_GC *gcc, struct rectangle *area )
{
  struct rectangle rect;
  struct layer *index;

  *gcc=*gc;

  for(index=layer;!isCLIPPED(index);index=index->parent)
    if(isBOUNDED(index))
      {
	if(gc->Area)
	  {
	    rect = *gc->Area;
	    moverectangle(rect,layer->bounds.min.coor.x,layer->bounds.min.coor.y);
	    if(!cliprectangle(&rect,&index->bounds,area))return FALSE;
	  }
	else area = &index->bounds;
	
	gcc->Area = area;
	return TRUE;
      }

  if(gc->Area)
    {
      area->min.coor.x = gc->Area->min.coor.x+layer->bounds.min.coor.x;
      area->min.coor.y = gc->Area->min.coor.y+layer->bounds.min.coor.y;
      area->max.coor.x = gc->Area->max.coor.x+layer->bounds.min.coor.x;
      area->max.coor.y = gc->Area->max.coor.y+layer->bounds.min.coor.y;
      gcc->Area=area;
    }
  else gcc->Area=NULL;

  return TRUE;
}

void lpixel(struct layer *layer, struct G_GC *gc, int x, int y)
{
  struct G_GC gcc;
  struct rectangle area;

  locklayer(layer);

  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      {
	x+=layer->bounds.min.coor.x;
	y+=layer->bounds.min.coor.y;
      
	pixel(layer->clip,0,&gcc,x,y);
      }
  unlocklayer(layer);

  return;
}

void lline( struct layer *layer, struct G_GC *gc, int x1, int y1, int x2, int y2 )
{
  struct G_GC gcc;
  struct rectangle area;

  locklayer(layer);

  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      {

	x1+=layer->bounds.min.coor.x;
	y1+=layer->bounds.min.coor.y;
	x2+=layer->bounds.min.coor.x;
	y2+=layer->bounds.min.coor.y;
      
	line(layer->clip,NULL,&gcc,x1,y1,x2,y2);
      }
  unlocklayer(layer);
  return;
}

void lrectangle( struct layer *layer, struct G_GC *gc, int left, int top, ulong width, ulong height )
{
  struct G_GC gcc;
  struct rectangle area;

  locklayer(layer);
  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      {

	left += layer->bounds.min.coor.x;
	top  += layer->bounds.min.coor.y;
      
	rectangle(layer->clip,NULL,&gcc,left,top,width,height);
      }
  unlocklayer(layer);
  return;
}

void lrectanglefill( struct layer *layer, struct G_GC *gc, int left, int top, ulong width, ulong height )
{
  struct G_GC gcc;
  struct rectangle area;

  locklayer(layer);
  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      {
	left += layer->bounds.min.coor.x;
	top  += layer->bounds.min.coor.y;
      
	rectanglefill(layer->clip,NULL,&gcc,left,top,width,height);
      }

  unlocklayer(layer);
  return;
}

void lpolygon( struct layer *layer, struct G_GC *gc, union point *xy, int count )
{
  struct G_GC gcc;
  struct rectangle area;

  int	i;
  
  locklayer(layer);
  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      {
	for(i=0;i<count;i++)
	  { xy[i].coor.x = xy[i].coor.x + layer->bounds.min.coor.x;
	    xy[i].coor.y = xy[i].coor.y + layer->bounds.min.coor.y;
	  }
	
	polygon(layer->clip,NULL,&gcc,xy,count);
	  
	for(i=0;i<count;i++)
	  { xy[i].coor.x = xy[i].coor.x - layer->bounds.min.coor.x;
	    xy[i].coor.y = xy[i].coor.y - layer->bounds.min.coor.y;
	  }
	  
      }

  unlocklayer(layer);
  return;
}

void larc( struct layer *layer, struct G_GC *gc, int x, int y, ulong width, ulong height, int ang1, int ang2 )
{
  struct G_GC gcc;
  struct rectangle area;

  locklayer(layer);

  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      arc(layer->clip,NULL,&gcc,x+layer->bounds.min.coor.x,y+layer->bounds.min.coor.y,width,height,ang1,ang2);

  unlocklayer(layer);
  return;
}


void lwedge( struct layer *layer, struct G_GC *gc, int x, int y, ulong width, ulong height, int ang1, int ang2 )
{
  struct G_GC gcc;
  struct rectangle area;

  locklayer(layer);

  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      wedge(layer->clip,NULL,&gcc,x+layer->bounds.min.coor.x,y+layer->bounds.min.coor.y,width,height,ang1,ang2);

  unlocklayer(layer);
  
  return;
}




void lblit( struct layer *layer, struct G_GC *gc, int left, int top, ulong width, ulong height, E_EBitMapPtr source, int srcx, int srcy )
{
  struct G_GC gcc;
  struct rectangle area;

  locklayer(layer);

  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      blit(layer->clip,NULL,&gcc,left+layer->bounds.min.coor.x,top+layer->bounds.min.coor.y,width,height,source,srcx,srcy);

  unlocklayer(layer);
  
  return;
}

void lblitmask( struct layer *layer, struct G_GC *gc, int left, int top, ulong width, ulong height, E_EBitMapPtr source, int srcx, int srcy, E_EBitMapPtr mask, int mskx, int msky )
{
  struct G_GC gcc;
  struct rectangle area;


  locklayer(layer);

  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      blitmask(layer->clip,NULL,&gcc,left+layer->bounds.min.coor.x,top+layer->bounds.min.coor.y,width,height,source,srcx,srcy,mask,mskx,msky);

  unlocklayer(layer);
  return;
}

void lblitscale( struct layer *layer, struct G_GC *gc, int left, int top, ulong width, ulong height, E_EBitMapPtr source, int srcx, int srcy, ulong srcwidth, ulong srcheight )
{
/*  struct G_GC gcc;
  struct rectangle area; */

  locklayer(layer);

/*  if(layer->visibility)
      if(copygc(layer,gc,&gcc,&area))
	blitscale(layer->clip,NULL,&gcc,left+layer->bounds.min.coor.x,top+layer->bounds.min.coor.y,width,height,source,srcx,srcy,srcwidth,srcheight);
 */

  unlocklayer(layer);
  return;
}

void lblitline( struct layer *layer, struct G_GC *gc, int x, int y, ulong width, ulong *source, int left, int modulo)
{
/*  struct G_GC gcc;
  struct rectangle area; */

  locklayer(layer);

/*
  if(layer->visibility)
      if(copygc(layer,gc,&gcc,&area))
    blitline(layer->clip,NULL,&gcc,x+layer->bounds.min.coor.x,y+layer->bounds.min.coor.y,width,source,left,modulo);
*/

  unlocklayer(layer);
  return;
}


void ltemplate( struct layer *layer, struct G_GC *gc, int left, int top, ulong width, ulong height, E_EBitMapPtr source, int srcX, int srcY )
{
  struct G_GC gcc;
  struct rectangle area;

  locklayer(layer);

  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      template(layer->clip,NULL,&gcc,left+layer->bounds.min.coor.x,top+layer->bounds.min.coor.y,width,height,source,srcX,srcY);

  unlocklayer(layer);
  return;
}

void ltemplatescale( struct layer *layer, struct G_GC *gc, int left, int top, ulong width, ulong height, E_EBitMapPtr source, int srcx, int srcy, ulong srcwidth, ulong srcheight )
{
/*  struct G_GC gcc;
  struct rectangle area; */

  locklayer(layer);

/*
  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      templatescale(layer->clip,NULL,&gcc,left+layer->bounds.min.coor.x,top+layer->bounds.min.coor.y,width,height,source,srcx,srcy,srcwidth,srcheight);
*/

  unlocklayer(layer);
  return;
}

void ltemplateline( struct layer *layer, struct G_GC *gc, int x, int y, ulong width, ulong *source, int left, int modulo)
{
/*  struct G_GC gcc;
  struct rectangle area; */

  locklayer(layer);

/*
  if(layer->visibility)
    if(copygc(layer,gc,&gcc,&area))
      templateline(layer->clip,NULL,&gcc,x+layer->bounds.min.coor.x,y+layer->bounds.min.coor.y,width,source,left,modulo);
*/

  unlocklayer(layer);
  return;
}

/* layers.c */
