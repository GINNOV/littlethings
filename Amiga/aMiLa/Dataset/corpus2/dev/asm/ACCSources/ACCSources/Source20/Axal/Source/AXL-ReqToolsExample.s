*****************************************
*  EXAMPLE OF REQTOOLS.LIBRARY BY AXAL  *
*****************************************

; NOTE: You will need to copy reqtools.library from the libs directory of
;ACC disc 20 into the libs directory of your system disc to run this
;program!


	opt	d+

	incdir sys:include/
	include	exec/types.i
	incdir	source:include/
	include	hooks.i
	include	tagitem.i
	include	reqtools.i
	include	reqtools_lib.i

*--------------------------------------


	moveq.l	#0,d0			any version
	lea	reqtoolsname(pc),a1	library to open
	move.l	$4.w,a6			execbase
	jsr	-552(a6)		open
	move.l	d0,reqtoolsbase		save base
	beq	quiterror1

*--------------------------------------

	move.l	reqtoolsbase(pc),a6	reqtools base
	moveq.l	#RT_FILEREQ,d0		file request
	move.l	#0,a0			null taglist
	jsr	_LVOrtAllocRequestA(a6)	alloc a request file
	move.l	d0,rt_filereqbase	save base
	beq	quiterror2		quit if 0

	move.l	rt_filereqbase(pc),a1	file request base
	lea	rt_filename(pc),a2	stuff for files
	lea	rt_windowtitle(pc),a3	window title
	move.l	#0,a0			null taglist
	jsr	_LVOrtFileRequestA(a6)	get a file request up
	tst.l	d0			was cancel pressed
	beq.s	quiterror3		branch if it was

	lea	rt_fullname(pc),a0	where to copy dir name
	move.l	rt_filereqbase(pc),a1	get my file request base
	move.l	rtfi_Dir(a1),a1		get address of dir name

	bsr.s	rt_copytobuff		copy it to main buffer

	cmpi.b	#":",-1(a0)		check for root dir
	beq.s	.rt_rootok		branch if there
	move.b	#"/",(a0)+		shift in a slash for dir
.rt_rootok
	lea	rt_filename(pc),a1	poin to  name of file
	bsr.s	rt_copytobuff		copy filename to main buffer
	move.b	#0,(a0)			null terminater

* YOU CAN NOW LOAD/SAVE THE FILE USING POWER PACKER LIBRARY OR
* ACC.LIBRARY OR YOUR OWN ROUTINES USING THE ZERO TERMINATED
* FILENAME IN:-
*                    RT_FULLNAME
*

*--------------------------------------
quiterror3
	move.l	rt_filereqbase(pc),a1	get address of my base
	jsr	_LVOrtFreeRequest(a6)	and free it

*--------------------------------------

quiterror2
	move.l	reqtoolsbase(pc),a1		lib to close
	move.l	$4.w,a6				execbase
	jsr	-414(a6)			close
quiterror1
	rts

*--------------------------------------

rt_copytobuff
	tst.b	(a1)			test null byte
	beq.s	.rt_loopend		branch if present
	move.b	(a1)+,(a0)+		copy new character
	bra.s	rt_copytobuff		continue until done
.rt_loopend
	rts

*--------------------------------------

reqtoolsname		dc.b	"reqtools.library",0
			even
rt_windowtitle		dc.b	"Select a file!!",0
			even
reqtoolsbase		dc.l	0
rt_filereqbase		dc.l	0
rt_filename		dcb.b	108
rt_fullname		dcb.b	216
		end


