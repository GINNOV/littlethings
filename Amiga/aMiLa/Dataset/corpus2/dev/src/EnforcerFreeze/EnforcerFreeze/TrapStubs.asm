	*****************************************************************
	*								*
	*   FILE							*
	*	$VER: TrapStubs.asm 1.0 (11.04.95)                      *
	*								*
	*   DESCRIPTION 						*
	*	A simple Stubs interface to call C functions from	*
	*	inside the Bus Error Trap ("segv")                      *
	*								*
	*   NOTES							*
	*	The most part of this Module was taken from		*
	*	"Enforcer/Enforcer.doc" by M.Sinz (only 68030 part is   *
	*	used and some of its parts have been commented out)	*
	*	See There for further notes.				*
	*								*
	*   HISTORY							*
	*	11-04-95 b_noll Created 				*
	*								*
	*****************************************************************
				    *
	INCLUDE "EXEC/EXECBASE.I"   * Needed for "ThisTask"
				    *
				    *
	xdef TrapData		    *
	xdef TrapVector 	    *
	xdef TrapVector040	    *
				    *
	xdef _TrapData		    *
	xdef @TrapData		    *
	xdef _TrapVector	    *
	xdef @TrapVector	    *
	xdef _TrapVector040	    *
	xdef @TrapVector040	    *
				    *
	xref _TrapCode		    * __asm __interrupt void TrapCode(void);
				    *
	section text,code	    * ok let's go ...
	;
	; The following code is inserted into the bus error vector.
	; Make sure you follow the VBR to find the vector.
	; Store the old vector in the address OldVector
	; Make sure you already have the single-step trap vector
	; installed before you install this.  Note that any extra
	; code you add in the comment area *MUST NOT* cause a bus
	; fault of any kind, including reading of location 4.
	;
	; This is the 68020 and 68030 version...
	;
	*****************************************************************
	*								*
	*	Variables are in CODE Area - Be Aware!!!!!!!!		*
	*	Resulting Executable MUST NOT be made Residentable	*
	*								*
	*****************************************************************
				    *
       TrapData:		    *
       @TrapData:		    * C Names for the data area
       _TrapData:		    *
	*****************************************************************

	*EnforcerHit:	 ds.l	 1			 ; Some private flag
	*MyTask:	 ds.l	 1			 ; Task under test
	MyExecBase:	ds.l	1			; The local copy
	OldVector:	ds.l	1			; One long word

	*****************************************************************
				    *
	OwnVector:	ds.l	1   * Our own C Routine ...
	InputTask:	ds.l	1   * Don't change its Priority!
	RecentTask:	ds.l	1   * This is the Task recently Hitting
	Active: 	ds.l	1   * Is Handler still active?
	CallingSSP:	ds.l	1   * Where did we start from?
				    *
			ds.l   32   * Some more Room for C variables usage
				    *
       TrapVector:		    *
       _TrapVector:		    * C Names for the code area
       @TrapVector:		    *
				    *
	NewVector:	cmp.l	#4,$10(sp)              ; 68020 and 68030
			beq.s	TraceSkip		; If AbsExecBase, OK
			;
			; Now, if you wish to only trap a specific task,
			; do the check at this point.  For example, a
			; simple single-task debugger would do something
			; like this:
			move.l	a0,-(sp)                ; Save this...
			move.l	MyExecBase(pc),a0       ; Get ExecBase...
			move.l	ThisTask(a0),a0         ; Get ThisTask
			*cmp.l	 MyTask(pc),a0           ; Are they the same?
			*move.l  (sp)+,a0                ; Restore A0 (no flags)
			*bne.s	 TraceSkip		 ; If not my task, skip
			;

	*****************************************************************
	*								*
	*		Stubs to call 'C' TraceCode                     *
	*		(It's just I hate Assembler)                    *
	*								*
	*****************************************************************
						*
		    cmp.l   InputTask(PC),A0    *** We mustn't touch
		    beq.s   TaskSkip		*   "input.device"
		    cmp.l   RecentTask(PC),A0   *   and we needn't touch
		    beq.s   TaskSkip		*   tasks, that are already
		    move.l  A0,RecentTask	*   marked Hitting
		    move.l  (SP)+,A0            *   (we expect that at least
		    bra.s   CallC		*   after the next Switch
	TaskSkip:   move.l  (SP)+,A0            *   this task is suspended
		    bra.s   TraceSkip		*   so we check only one task)
						*
	CallC:					*
		    move.l  A7,CallingSSP	*** Save Calling StackPtr
						*
		    movem.l A0-A1/D0-D1,-(SP)   *** Save Scratch Registers
		    move.l  Active(PC),D0       *   before calling C Function
		    beq.s   InActive		*
						*
	    IFD USE_OwnVector			*
		    move.l  OwnVector(PC),A0    *** Call C Function via
		    cmp.l   #0,A0		*   TrapData.OwnVector
		    beq.s   NoVector		*
		    jsr     (A0)                *
	    ELSE				*
		    bsr.w   _TrapCode		*** Call C Function directly
	    ENDC				*
						*
	InActive:				*
	NoVector:   movem.l (SP)+,A0-A1/D0-D1   *** Restore Regs
						*
	******************************************************************

			*bset.b  #7,(sp)                 ; Set trace bit...
			; If you have any other data to set, do it now...
			; Set as setting the EnforcerHit bit in your data...
			*addq.l  #1,EnforcerHit 	 ; Count the hit...

	TraceSkip:	move.l	OldVector(pc),-(sp)     ; Ready to return
			rts
	;
	; This is the 68040 version...
	;
	*****************************************************************
				    *
       TrapVector040:		    *
       _TrapVector040:		    * C Names for the code area
       @TrapVector040:		    *
				    *
	NewVector040:	cmp.l	#4,$14(sp)              ; 68040
			beq.s	TraceSkip040		; If AbsExecBase, OK
			;
			; Now, if you wish to only trap a specific task,
			; do the check at this point.  For example, a
			; simple single-task debugger would do something
			; like this:
			move.l	a0,-(sp)                ; Save this...
			move.l	MyExecBase(pc),a0       ; Get ExecBase...
			move.l	ThisTask(a0),a0         ; Get ThisTask
			*cmp.l	 MyTask(pc),a0           ; Are they the same?
			*move.l  (sp)+,a0                ; Restore A0 (no flags)
			*bne.s	 TraceSkip		 ; If not my task, skip
			;
	*****************************************************************
	*								*
	*	    This part has never been tested!!!!!!!!!		*
	*								*
	*****************************************************************
						*
		    cmp.l   InputTask(PC),A0    *** We mustn't touch
		    beq.s   TaskSkip40		*   "input.device"
		    cmp.l   RecentTask(PC),A0   *   and we needn't touch
		    beq.s   TaskSkip40		*   tasks, that are already
		    move.l  A0,RecentTask	*   marked Hitting
		    move.l  (SP)+,A0            *   (we expect that at least
		    bra.s   CallC40		*   after the next Switch
	TaskSkip40: move.l  (SP)+,A0            *   this task is suspended
		    bra.s   TraceSkip040	*   so we check only one task)
						*
	CallC40:				*
		    move.l  A7,CallingSSP	*** Save Calling StackPtr
						*
		    movem.l A0-A1/D0-D1,-(SP)   *** Save Scratch Registers
		    move.l  Active(PC),D0       *   before calling C Function
		    beq.s   InActive40		*
						*
	    IFD USE_OwnVector			*
		    move.l  OwnVector(PC),A0    *** Call C Function via
		    cmp.l   #0,A0		*   TrapData.OwnVector
		    beq.s   NoVector40		*
		    jsr     (A0)                *
	    ELSE				*
		    bsr.w   _TrapCode		*** Call C Function directly
	    ENDC				*
						*
	InActive40:				*
	NoVector40: movem.l (SP)+,A0-A1/D0-D1   *** Restore Regs
						*
	******************************************************************

			*bset.b  #7,(sp)                 ; Set trace bit...
			; If you have any other data to set, do it now...
			; Set as setting the EnforcerHit bit in your data...
			*addq.l  #1,EnforcerHit 	 : Count the hit...
			;
	TraceSkip040:	move.l	OldVector(pc),-(sp)     ; Ready to return
			rts


	*****************************************************************
				    *
				    * That's all folks ...
	END
