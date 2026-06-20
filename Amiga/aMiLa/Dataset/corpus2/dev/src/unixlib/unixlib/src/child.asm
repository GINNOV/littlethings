	INCLUDE	"utility/tagitem.i"
	INCLUDE	"exec/tasks.i"
	INCLUDE	"exec/ports.i"

	XREF	_LVOPutMsg
	XREF	_LVOSystemTagList
	XREF	_LVOFreeMem
	XREF	_LVOFindPort
	XREF	_LVOFindTask
	XREF	_LVOAddHead
	XREF	__startup_port
	XREF	_LinkerDB
	XREF	_us

	XDEF	__child_startup
	XDEF	__child_startup_end

	csect	text,0,,2,2

	XREF	__child_command
	XREF	__child_command_len
	XREF	__child_door_name
	XREF	__child_door_name_len
	XREF	__child_exit
	XREF	_DOSBase
	XREF	_startup_message
	XREF	__child_entry

* Code executed by a child process. A new copy is created for each child.

__child_startup:
	movem.l	d2-d5/a2-a5,-(a7)
	
	lea	_LinkerDB,a4
	move.l	__child_command(a4),d4
	move.l	__child_command_len(a4),d5
	move.l	__child_exit(a4),a2
	move.l	_DOSBase(a4),a3
	move.l	__child_door_name(a4),a5
	move.l	__child_door_name_len(a4),d3

* Arrange for code to be freed on exit
	sub.l	a1,a1
	move.l	4,a6
	jsr	_LVOFindTask(a6)
	move.l	d0,a0
	lea	TC_MEMENTRY(a0),a0
	move.l	__child_entry(a4),a1
	jsr	_LVOAddHead(a6)
	
* Send startup message to parent	
	move.l	4,a6
	move.l	__startup_port,a0
	lea	_startup_message(a4),a1
	jsr	_LVOPutMsg(a6)

* From now on, parent may disappear.

* Start command
	move.l	a3,a6
	move.l	d4,d1
	lea	notags(pc),a0
	move.l	a0,d2
	jsr	_LVOSystemTagList(a6)
* Prepare result code
	lsl.l	#8,d0
	move.l	d0,24(a2)

* Send result to parent if he is still there
	move.l	a5,a1
	move.l	4,a6
	jsr	_LVOFindPort(a6)
	tst.l	d0
	beq.s	noemacs

	move.l	d0,a0
	move.l	a2,a1
	jsr	_LVOPutMsg(a6)
	bra.s	exit

noemacs:
* Free child_exit
	move.l	a2,a1
	moveq	#0,d0
	move.w	MN_LENGTH(a2),d0
	jsr	_LVOFreeMem(a6)

exit:
* Free port name
	move.l	a5,a1
	move.l	d3,d0
	jsr	_LVOFreeMem(a6)

* Free command
	move.l	d4,a1
	move.l	d5,d0
	jsr	_LVOFreeMem(a6)

	movem.l	(a7)+,d2-d5/a2-a5
	rts

notags	dc.l	TAG_DONE

__child_startup_end:

	end
