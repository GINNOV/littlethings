
* Exec Support Functions header file
* Needs exec.i and exec_lib.i included with it in any
* source using it.

*** Minor update, now use Devpac includes rather than Daves own.
*** M.Meany 10/3/90


* This file is PUBLIC DOMAIN.


* BUG REPORTS, USER'S OWN UPDATES : SEND ALL BUG REPORTS, WITH
* ALL THE USUAL INFORMATION (WHAT YOU CALLED, WITH WHAT PARAMETERS
* ETC, PLUS RELEVANT SMALL PORTION OF YOUR SOURCE WHERE THE BUG
* OCCURRED) TO:


*		Dave Edwards
*		232 Hale Road
*		WIDNES
*		Cheshire
*		WA8 8QA


* Contact above address also for the include file mentioned above, which
* are also Public Domain. If you want updated copy, provide a small jiffy
* bag or stiff envelope with a 1st class stamp & your address for return.
* Files will be returned on the disc you send.


* Function List:


* NewList(List, Type)
*	  A0	D0

* Port = CreatePort(Name, Pri)
* D0		   A0	D0

* DeletePort(Port)
*	     A0

* IOReq = CreateExtIO(Port, Size)
*  D0		     A0	  D0

* DeleteExtIO(IORequest)
*		A1

* BeginIO(IORequest)
*	    A1

* value = RandomValue(Seed)
*   D0		     D0




* NewList(list,type)
* a0 = list (to initialise)
* d0 = type

* NON-MODIFIABLE.

NewList		move.l	a0,(a0)		;lh_head points to lh_tail
		addq.l	#4,(a0)
		clr.l	4(a0)		;lh_tail = NULL
		move.l	a0,8(a0)		lh_tailpred points to lh_head

		move.b	d0,12(a0) ;list type

		rts



* port = CreatePort(Name,Pri)
* a0 = name
* d0 = pri
* returns d0 = port, NULL if couldn't do it

* d1/d7/a1 corrupt

* NON-MODIFIABLE.


CreatePort	movem.l	d0/a0,-(sp)	;save parameters
		moveq	#-1,d0
		CALLEXEC	AllocSignal	;get a signal bit
		tst.l	d0
		bmi.s	cp_error1
		move.l	d0,d7		;save signal bit

* got signal bit. Now create port structure.

		move.l	#MP_SIZE,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0
		beq.s	cp_error2	;couldn't create port struct!

* Here initialise port node structure.

		move.l	d0,a0
		movem.l	(sp)+,d0/d1	;get parms off stack
		move.l	d1,LN_NAME(a0)	;set name pointer
		move.b	d0,LN_PRI(a0)	;and priority

		move.b	#NT_MSGPORT,LN_TYPE(a0)	;ensure it's a message
						;port

* Here initialise rest of port.

		move.b	#PA_SIGNAL,MP_FLAGS(a0)	;signal if msg received
		move.b	d7,MP_SIGBIT(a0)		;signal bit here
		move.l	a0,-(sp)
		sub.l	a1,a1
		CALLEXEC	FindTask		;find THIS task
		move.l	(sp)+,a0
		move.l	d0,MP_SIGTASK(a0)	;signal THIS task if msg arrived

* Here, if public port, add to public port list, else
* initialise message list header.

		tst.l	LN_NAME(a0)	;got a name?
		beq.s	cp_private	;no

		move.l	a0,-(sp)
		move.l	a0,a1
		CALLEXEC	AddPort		;else add to public port list
		move.l	(sp)+,d0		;(which also NewList()s the
		rts			;mp_MsgList)

* Here initialise list header.

cp_private	lea	MP_MSGLIST(a0),a1	;ptr to list structure
		exg	a0,a1		;for now
		move.b	#NT_MESSAGE,d0	;type = message list
		bsr	NewList		;do it!

		move.l	a1,d0		;return ptr to port
		rts

* Here couldn't allocate. Release signal bit.

cp_error2	move.l	d7,d0
		CALLEXEC	FreeSignal

* Here couldn't get a signal so quit NOW.

cp_error1	movem.l	(sp)+,d0/a0
		moveq	#0,d0		;signal no port exists!

		rts


* DeletePort(Port)
* a0 = port

* a1 corrupt

* NON-MODIFIABLE.


DeletePort	move.l	a0,-(sp)
		tst.l	LN_NAME(a0)	;public port?
		beq.s	dp_private	;no

		move.l	a0,a1
		CALLEXEC	RemPort		;remove port

* here make it difficult to re-use the port.

dp_private	move.l	(sp)+,a0
		moveq	#-1,d0
		move.l	d0,MP_SIGTASK(a0)
		move.l	d0,MP_MSGLIST(a0)

* Now free the signal.

		moveq	#0,d0
		move.b	MP_SIGBIT(a0),d0
		CALLEXEC	FreeSignal

* Now free the port structure.

		move.l	a0,a1
		move.l	#MP_SIZE,d0
		CALLEXEC	FreeMem

		rts


* IOReq=CreateExtIO(Port,Size)
* a0 = port
* d0 = size of IOReq to create
*	(e.g., iotd_sizeof for a
*	trackdisk.device IOreq)

* return d0=IOReq or NULL if couldn't do it

* Usage:call CreatePort() first to get a port
* to link to the IORequest. Then call this
* function to get the IORequest, passing the
* port pointer in a0.

CreateExtIO	movem.l	d0/a0,-(sp)	;save parameters

* Allocate the memory for the IORequest

		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0
		beq.s	cei_error1
		move.l	d0,a1		;pointer to IORequest

		movem.l	(sp)+,d0/a0	;recover port & size

		move.b	#NT_MESSAGE,LN_TYPE(a1)
		move.l	a0,MN_REPLYPORT(a1)	;set port pointer

;		sub.l	#mn_sizeof,d0	;leave this in for upgrades!

		move.w	d0,MN_LENGTH(a1)		;and struct size

		move.l	a1,d0		;return argument
		rts

* Here couldn't get memory for IORequest, so bye

cei_error1	movem.l	(sp)+,d0/a0
		moveq	#0,d0
		rts


* DeleteExtIO(IORequest)

* a1 = IORequest

* Deletes an IORequest structure formed by CreateExtIO()
* uses mn_Length field to determine how much memory to
* deallocate

* d0/a1 corrupt


DeleteExtIO	move.l	a1,-(sp)
		CALLEXEC	WaitIO		;ensure no pending requests!
		move.l	(sp)+,a1

		move.l	MN_LENGTH(a1),d0

;		add.l	#mn_sizeof,d0	;keep this for now!

		CALLEXEC	FreeMem

		rts


* BeginIO(IORequest)

* a1 = IORequest

* Pass IORequest directly to the BEGINIO vector of the
* device structure. Works exactly like SendIO() but it
* does not clear the io_Flags field first. Does not
* wait for the I/O to complete.

* a0 corrupt

* NON-MODIFIABLE

BeginIO		move.l	IO_DEVICE(a1),a0	;get device structure ptr
		jsr	-30(a0)		;execute BEGINIO routine
		rts			;and back


* value = RandomValue(seed)

* d0 = seed
* returns d0 = value

* generate a pseudo-random number (not strictly
* an Exec support function, but many want it, so
* here it is)

* d1/a0 corrupt

* Usage:make up some initial value of your own, the seed.
* Call RandomValue() on it, and SAVE it for future calls
* using this value as the new seed for the next call.
* Repeat this procedure for all calls.

* NON_MODIFIABLE


RandomValue	rol.l	d0,d0		;scramble bits
		move.l	d0,d1
		and.l	#$7fffe,d1	;create random ptr to CHIP RAM
		move.l	d1,a0
		add.l	(a0),d0		;add onto scrambled bits
		rts
		


