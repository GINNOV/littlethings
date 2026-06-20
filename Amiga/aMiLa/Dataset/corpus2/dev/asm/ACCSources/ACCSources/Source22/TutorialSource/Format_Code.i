

* TABS SET TO 9 !!!!


* Disc Formatting code.
* Includes several functions ripped off
* from exec_support.i.


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
		bmi	cp_error1
		move.l	d0,d7		;save signal bit


* got signal bit. Now create port structure.


		move.l	#mp_sizeof,d0
		move.l	#MEMF_PUBLIC+MEMF_CLEAR,d1
		CALLEXEC	AllocMem
		tst.l	d0
		beq.s	cp_error2	;couldn't create port struct!


* Here initialise port node structure.


		move.l	d0,a0
		movem.l	(sp)+,d0/d1	;get parms off stack
		move.l	d1,ln_Name(a0)	;set name pointer
		move.b	d0,ln_Pri(a0)	;and priority

		move.b	#NT_MSGPORT,ln_Type(a0)	;ensure it's a message
						;port

* Here initialise rest of port.


		move.b	#PA_SIGNAL,mp_Flags(a0)	;signal if msg received
		move.b	d7,mp_SigBit(a0)		;signal bit here
		move.l	a0,-(sp)
		sub.l	a1,a1
		CALLEXEC	FindTask		;find THIS task
		move.l	(sp)+,a0
		move.l	d0,mp_SigTask(a0)	;signal THIS task if msg arrived


* Here, if public port, add to public port list, else
* initialise message list header.


		tst.l	ln_Name(a0)	;got a name?
		beq.s	cp_private	;no

		move.l	a0,-(sp)
		move.l	a0,a1
		CALLEXEC	AddPort		;else add to public port list
		move.l	(sp)+,d0		;(which also NewList()s the
		rts			;mp_MsgList)


* Here initialise list header for a private port.


cp_private	lea	mp_MsgList(a0),a1	;ptr to list structure
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
		tst.l	ln_Name(a0)	;public port?
		beq.s	dp_private	;no

		move.l	a0,a1
		CALLEXEC	RemPort		;remove port


* here make it difficult to re-use the port.


dp_private	move.l	(sp)+,a0
		moveq	#-1,d0
		move.l	d0,mp_SigTask(a0)
		move.l	d0,mp_MsgList(a0)


* Now free the signal.


		moveq	#0,d0
		move.b	mp_SigBit(a0),d0
		CALLEXEC	FreeSignal


* Now free the port structure.


		move.l	a0,a1
		move.l	#mp_sizeof,d0
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

		move.b	#NT_MESSAGE,ln_Type(a1)
		move.l	a0,mn_ReplyPort(a1)	;set port pointer

;		sub.l	#mn_sizeof,d0	;leave this in for upgrades!

		move.w	d0,mn_Length(a1)		;and struct size

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


DeleteExtIO	nop

;		move.l	a1,-(sp)
;		CALLEXEC	WaitIO		;ensure no pending requests!
;		move.l	(sp)+,a1

		moveq	#0,d0
		move.w	mn_Length(a1),d0

;		add.l	#mn_sizeof,d0	;keep this for now!

		CALLEXEC	FreeMem

		rts


* THIS IS THE MAIN FORMAT CODE. IT REQUIRES THE FOLLOWING VARIABLES
* TO EXIST, REFERENCED OFF A6 VIA GENAM RS DEFINITIONS:

* fmt_port(a6)		: LONG
* fmt_ioreq(a6)		: LONG
* fmt_trbuf(a6)		: LONG
* fmt_offset(a6)		: LONG
* disc_error(a6)		: WORD

* PRIOR TO CALLING, THE PROGRAMMER MUST WRITE CODE TO INFORM THE USER TO
* INSERT A DISC, PRESS RETURN/LEFT MOUSE BUTTON ETC, AND THEN CALL THIS
* ROUTINE. AFTER CALLING, THE PROGRAMMER MUST SUPPLY A DISC ERROR HANDLING
* ROUTINE TO INFORM USER OF ANYTHING THAT WENT WRONG. SEE CODE BELOW FOR
* CURRENT ERROR CODES.


* DoFormat(a6)
* a6 = ptr to main program variables

* d0-d2/d7/a0-a2 corrupt


DoFormat		lea	fmt_pname(pc),a0	;pointer to port name
		moveq	#10,d0		;priority
		bsr	CreatePort	;get a port
		move.l	d0,fmt_port(a6)	;save pointer
		bne.s	DoFmt_1		;and skip if it exists

		moveq	#13,d0		;can't create port error
		bra	DoFmt_7

DoFmt_1		move.l	d0,a0		;ptr to port
		moveq	#iotd_sizeof,d0	;size of ioreq
		bsr	CreateExtIO	;build it
		move.l	d0,fmt_ioreq(a6)	;save ptr
		bne.s	DoFmt_2		;and skip if all's well

		moveq	#14,d0		;can't create ioreq error
		bra	DoFmt_7

DoFmt_2		lea	trd_name(pc),a0	;trackdisk device
		moveq	#0,d0		;unit 0
		move.l	fmt_ioreq(a6),a1
		moveq	#0,d1

		CALLEXEC	OpenDevice	;have we got it?
		tst.l	d0
		beq.s	DoFmt_3		;yes

		moveq	#15,d0		;can't open device error
		bra	DoFmt_7

DoFmt_3		move.l	#512*22,d0
		move.l	#MEMF_CHIP,d1	;allocate track buffer
		CALLEXEC	AllocMem
		move.l	d0,fmt_trbuf(a6)	;got one?
		bne.s	DoFmt_4		;skip if so

		moveq	#-1,d0		;can't alloc trackbuf error
		bra	DoFmt_7

DoFmt_4		move.l	d0,a0		;ptr to track buf
		move.l	#512*22/4,d0	;no of longwords
		move.l	#"DOS ",d1
		clr.b	d1		;initialising data

DoFmt_5		move.l	d1,(a0)+		;pre-create track data
		addq.b	#1,d1		;to write to disc
		subq.l	#1,d0
		bne.s	DoFmt_5

DoFmt_4b		move.l	fmt_ioreq(a6),a1
		move.w	#14,io_Command(a1)	;get change stat
		CALLEXEC	DoIO

		move.l	fmt_ioreq(a6),a1	;wait until a disc is
		tst.l	ioext_Actual(a1)	;in the drive
		bne.s	DoFmt_4b

		move.l	fmt_ioreq(a6),a1
		move.w	#13,io_Command(a1)	;get change num
		CALLEXEC	DoIO

		move.l	fmt_ioreq(a6),a1
		move.l	ioext_Actual(a1),d7	;this is change num
		addq.l	#2,d7			;look for this

DoFmt_4a		move.l	fmt_ioreq(a6),a1
		move.w	#13,io_Command(a1)	;get change num
		CALLEXEC	DoIO

		move.l	fmt_ioreq(a6),a1
		move.l	ioext_Actual(a1),d0	;changed disc?
		cmp.l	d7,d0
		bcs.s	DoFmt_4a		;loop back until changed

		CALLEXEC	Forbid		;disable multitasking

		moveq	#0,d0
		move.l	d0,fmt_offset(a6)

		move.l	fmt_ioreq(a6),a1
		move.w	#9,io_Command(a1)		;TD_MOTOR
		moveq	#1,d0			;turn it on
		move.l	d0,ioext_Length(a1)

		CALLEXEC	DoIO		;wait for completion

		move.l	#512*22,d7	;no of bytes in a track
		moveq	#80,d6		;no of tracks to do

DoFmt_6		move.l	fmt_ioreq(a6),a1
		move.l	fmt_trbuf(a6),d0
		move.l	fmt_offset(a6),d1
		move.l	d1,ioext_Offset(a1)
		move.l	d0,ioext_Data(a1)		;ptr to buffer
		move.l	d7,ioext_Length(a1)	;do a whole track
		move.w	#11,io_Command(a1)	;TD_FORMAT

		CALLEXEC	DoIO			;execute it

		add.l	d7,fmt_offset(a6)

		subq.l	#1,d6		;done all tracks?
		bne.s	DoFmt_6		;loop back if not

		move.w	#128,d0		;prepare to create the
		move.l	fmt_trbuf(a6),a0	;Root Block (Block 880)
		move.l	a0,a1

		moveq	#2,d1
		move.l	d1,(a0)+		;type T.SHORT

		clr.l	(a0)+
		clr.l	(a0)+
		moveq	#$48,d1
		move.l	d1,(a0)+		;HT SIZE

		clr.l	(a0)+
		clr.l	(a0)+

		moveq	#78-6,d2		;clear hash table
DoFmt_6a		clr.l	(a0)+
		subq.w	#1,d2
		bne.s	DoFmt_6a

		moveq	#1,d1
		move.l	d1,(a0)+		;BM Flag
		move.l	#881,(a0)+	;BM Pages

		moveq	#108-80,d2	;clear remainder of
DoFmt_6b		clr.l	(a0)+		;BM pages
		subq.w	#1,d2		;and creation date
		bne.s	DoFmt_6b

		move.l	#$0943726F,(a0)+	;BCPL string: 9,"Cro"
		move.l	#$7373776F,(a0)+	;"sswo"
		move.l	#$72640000,(a0)+	;"rd",0,0

		moveq	#127-111,d2	;clear remainder of
DoFmt_6c		clr.l	(a0)+		;root block
		subq.w	#1,d2
		bne.s	DoFmt_6c

		moveq	#1,d1
		move.l	d1,(a0)+		;Sec. Type = 1

		move.l	a1,a0		;ptr to start of Block 880

		move.w	d0,d1		;no of longwords (128)
		moveq	#0,d2		;initial checksum

DoFmt_6d		add.l	(a0)+,d2		;compute checksum
		subq.w	#1,d1		;for Root Block
		bne.s	DoFmt_6d

		neg.l	d2
		move.l	d2,20(a1)	;create checksum

		move.l	a0,a2		;copy ptr to bitmap block

		clr.l	(a0)+		;checksum for now
		moveq	#-1,d2		;bitmap block values
		moveq	#55,d1		;no. of entries

DoFmt_6e		move.l	d2,(a0)+		;create bitmap
		subq.w	#1,d1		;for the disc
		bne.s	DoFmt_6e

		moveq	#128-56,d1

DoFmt_6f		clr.l	(a0)+		;clear remaining bitmap blocks
		subq.w	#1,d1
		bne.s	DoFmt_6f

		move.l	112(a2),d1	;make blocks 880, 881
		bclr	#15,d1		;NOT free, all others
		bclr	#14,d1		;free
		move.l	d1,112(a2)

		move.l	a2,a0
		move.w	#128,d1
		moveq	#0,d2

DoFmt_6g		add.l	(a0)+,d2		;create bitmap block
		subq.w	#1,d1		;checksum
		bne.s	DoFmt_6g

		neg.l	d2
		move.l	d2,(a2)		;this is it


* Once new Root block and bitmap block have been set up, write them out
* to the disc.


		move.l	a1,d1
		move.l	fmt_ioreq(a6),a1
		move.l	d1,ioext_Data(a1)
		move.l	#512*22,ioext_Length(a1)
		move.l	#880*512,ioext_Offset(a1)
		move.w	#11,io_Command(a1)
		CALLEXEC	DoIO


* Now set up the Boot block (Block 0).


		move.l	fmt_trbuf(a6),a0	;point to buffer
		move.l	a0,a1
		move.w	#256,d0		;number of long words
		move.l	#"DOS ",d1
		clr.b	d1		;DOS type marker

DoFmt_6h		move.l	d1,(a0)+		;make bootblock
		subq.w	#1,d0
		bne.s	DoFmt_6h

		move.l	a1,a0
		move.l	#880,8(a0)	;set Root Block pointer

		move.l	#256,d0		;no of longs in 2 sectors
		moveq	#0,d0		;initial checksum

DoFmt_6i		add.l	(a0)+,d1		;compute base checksum
		subq.l	#1,d0
		bne.s	DoFmt_6i

		addq.l	#1,d1		;convert checksum
		neg.l	d1
		move.l	d1,4(a1)		;store this value

		move.l	a1,d1
		move.l	fmt_ioreq(a6),a1
		move.l	d1,ioext_Data(a1)
		move.l	#512*22,ioext_Length(a1)
		move.l	#0,ioext_Offset(a1)
		move.w	#11,io_Command(a1)
		CALLEXEC	DoIO

		move.l	fmt_ioreq(a6),a1
		move.w	#9,io_Command(a1)		;TD_MOTOR
		moveq	#0,d0			;turn it off
		move.l	d0,ioext_Length(a1)

		CALLEXEC	DoIO		;wait for completion

		CALLEXEC	Permit		;allow multitasking


* Here put in your own code to inform the user that formatting
* went well. Don't forget to leave the moveq #0,d0 alone-this is the
* final disc error code!


		moveq	#0,d0	;signal all went well

DoFmt_7		move.w	d0,disc_error(a6)		;save error code

		move.l	fmt_ioreq(a6),d0
		beq.s	DoFmt_8
		cmp.w	#15,disc_error(a6)	;couldn't open device?
		beq.s	DoFmt_7a			;skip if so

		move.l	d0,a1
		CALLEXEC	CloseDevice

DoFmt_7a		move.l	fmt_ioreq(a6),d0	;couldn't get IORequest?
		beq.s	DoFmt_8		;skip if so
		move.l	d0,a1
		bsr	DeleteExtIO	;else deallocate it

DoFmt_8		move.l	fmt_port(a6),d0	;coudn't get message port?
		beq.s	DoFmt_9		;skip if so
		move.l	d0,a0
		bsr	DeletePort	;else deallocate it

DoFmt_9		move.w	disc_error(a6),d0	;get disc error code


* Here pop in your own code to report disc access errors, based upon
* the error code in disc_error(a6). If this value is zero, then
* no error occurred.

* Since this code comes from another application, and various error
* codes are already assigned for other purposes, the following are
* valid in this code:

* 13 : couldn't allocate message port

* 14 : couldn't create IORequest structure

* 15 : couldn't open TrackDisk device

* -1 : general memory allocation error (couldn't get buffers etc)

* Feel free to change them if you have a different allocation scheme for
* disc error codes!


		rts


* Names used by the format code.


fmt_pname	dc.b	"My Format Port",0

trd_name		dc.b	"trackdisk.device",0

		even





