
*****	Title		exec_eg1
*****	Function	scans TaskWait list and displays name of all tasks in
*****			it.
*****			
*****	Size		
*****	Author		Mark Meany
*****	Date Started	14 March 92	
*****	This Revision	
*****	Notes		
*****			

		include		start.i
		include		exec/execbase.i

; Stop multitasking

Main		CALLEXEC	Forbid			multitasking OFF

; locate list header

		move.l		$4.w,a6			a6->execbase
		lea		TaskWait(a6),a1		a1->head node

; step through list displaying name of entries

.loop		TSTNODE		a1,a1			a1->next node
		beq		.done			exit if end
		move.l		LN_NAME(a1),a0		a0->node name
		bsr		PrintNL			print name
		bra		.loop			and loop back

; enable multitasking and exit

.done		CALLEXEC	Permit			multitasking ON
		rts					exit

