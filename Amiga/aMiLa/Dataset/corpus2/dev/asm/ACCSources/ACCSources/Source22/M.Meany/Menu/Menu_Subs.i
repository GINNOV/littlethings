
; Routine that deals with selection gadget

; 23 Jan 92. Windows IDCMP now disabled while subroutine is executed.
;	     Sends screen to back when executing a program.

; Entry		a5->gadget structure 

GotSelection	move.l		window.ptr,a0		a0->window
		move.l		#RAWKEY,d0		disable gadgets
		CALLINT		ModifyIDCMP		do it!

		moveq.l		#0,d0
		move.w		gg_GadgetID(a5),d0
		move.l		TopEntry,a0
		tst.w		d0
		beq.s		.located

.loop		tst.l		nd_Succ(a0)
		beq		.done
		move.l		nd_Succ(a0),a0
		subq.l		#1,d0
		bne.s		.loop

.located	move.l		nd_Data(a0),a0		a0->text line
		move.l		4(a0),a0		a0->command

		cmpi.b		#'M',(a0)+		new menu ?
		bne.s		.check_print

		bsr		Load
		bsr		BuildList
		move.l		dir,a0		a0->start of list
		move.l		nd_Succ(a0),a0	a0->1st entry
		bsr		BuildDisplay	set up gadget text
		move.l		window.rp,a0	a0->windows RastPort
		lea		BoxText,a1	a1->image 
		moveq.l		#0,d0		X offset
		moveq.l		#0,d1		Y offset
		CALLINT		PrintIText	draw screen
		bra		.done

.check_print	cmpi.b		#'R',-1(a0)		display a text file ?
		bne.s		.check_view
		jsr		ShowFile
		bra		.done

.check_view	cmpi.b		#'V',-1(a0)		view ILBM pic
		bne.s		.check_play
		jsr		ViewILBM
		bra		.done

.check_play	cmpi.b		#'P',-1(a0)		play NT module
		bne.s		.check_splay
		jsr		PlayFile
		bra		.done

.check_splay	cmpi.b		#'p',-1(a0)		stop NT module
		bne.s		.check_run
		jsr		StopPlaying
		bra		.done

.check_run	cmpi.b		#'E',-1(a0)		run a program ?
		bne.s		.check_quit
		move.l		a0,-(sp)
		move.l		screen.ptr,a0
		CALLINT		ScreenToBack
		move.l		(sp)+,a0
		move.l		a0,d1
		moveq.l		#0,d2
		move.l		d2,d3
		CALLDOS		Execute
		move.l		screen.ptr,a0
		CALLINT		ScreenToFront
		bra		.done

.check_quit	cmpi.b		#'Q',-1(a0)		quit ?
		bne.s		.done
		jsr		StopPlaying		make sure no music
		move.l		#CLOSEWINDOW,d2
		rts

.done		move.l		window.ptr,a0
		move.l		#GADGETUP!GADGETDOWN!RAWKEY,d0
		CALLINT		ModifyIDCMP
		
		moveq.l		#0,d2
		rts

; The following lines of code are for debugging only. If DEBUG=1 then
;all external subroutines are defined here and just cause a return. This
;allows the main code to be tested without linking with other modules.

		IFNE		DEBUG			only for debugging

ShowFile	rts
PlayFile	rts
StopPlaying	rts
ViewILBM	rts

		ENDC

