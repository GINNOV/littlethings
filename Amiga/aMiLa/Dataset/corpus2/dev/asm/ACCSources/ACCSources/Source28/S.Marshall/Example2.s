***************************************************************************
*
*		Audio Example Playing A Sample One Or More
*		Times Using Audio Interrupts.
*		 
*		by Steve Marshall
*
***************************************************************************

		incdir		sys:include/
		include		hardware/intbits.i
		include		hardware/dmabits.i
		include		hardware/custom.i
		include		exec/exec_lib.i
		include		exec/nodes.i

Start
	lea		$Dff000,a5		;hardware base

;-------
	move.w		#DMAF_AUD0,dmacon(a5)	;stop audio 0 dma
	move.w		#INTF_AUD0,intreq(a5)	;clear interrupt
	
	moveq		#INTB_AUD0,d0		;int_Aud0
	lea		Aud_intserver,a1	;server struct
	CALLEXEC	SetIntVector		;add to server chain
	move.l		d0,OldVector		;save old vector (if any)

	move.w		#INTF_SETCLR!INTF_AUD0,intena(a5) ;enable audio 0 interrupts

; Write sample parameters into hardware registers

	lea		aud0(a5),a4
	move.w		#64,ac_vol(a4)		set volume
	move.w		#$12c,ac_per(a4)	set period
	move.l		#SMP1,(a4)		set new address
	move.w		#SMP1LEN,ac_len(a4)	set new length

	move.w		#1,Cycles		;set num times to play

; Enable channel 0 DMA to start the sound playing.

	move.w		#DMAF_SETCLR!DMAF_AUD0,dmacon(a5) ;start playing

;------	We can tell if the sample has completed by checking Cycles
;	If Cycles = -1 then the sample has  been completed.
;	We wouldn't normally wait around for it to finish
;	The audio dma switches off automatically, volume is set to 0

Wait
	tst.w		Cycles
	bpl.s		Wait

	move.w		#64,ac_vol(a4)		set volume
	move.w		#$12c,ac_per(a4)	set period
	move.w		#4,Cycles		;set num times to play

; Enable channel 0 DMA to start the sound playing.

	move.w		#DMAF_SETCLR!DMAF_AUD0,dmacon(a5) ;start playing

Wait2
	tst.w		Cycles
	bpl.s		Wait2


;------	All done - disable audio 0 interrupts

	move.w		#INTF_AUD0,intena(a5)	;disable audio 0 interrupts
	
	moveq		#INTB_AUD0,d0		;int_Aud0
	move.l		OldVector,a1		;old vector
	CALLEXEC	SetIntVector		;and restore it

	rts					;end of main prog

*****************************************************************************
;------	On entry a0 = $dff000
Aud_interrupt
	subq.w		#1,(a1)			;decrement counter
	bpl.s		.ignore			;ignore if not done

;------	Set volume to 0 to avoid click when dma stopped	
	move.w		#0,aud0+ac_vol(a0)	;set volume
	move.w		4(a1),dmacon(a0)	;stop audio 0 dma
	move.w		#1,aud0+ac_per(a0)	;set period

.ignore	
	move.w		2(a1),intreq(a0)	;clear interrupt
	rts					;quit

	
*****************************************************************************

		section		sounds,DATA_C

;------	structure used by SetIntVector()
Aud_intserver
	dc.l	0		;succ
	dc.l	0		;pred
	dc.b	NT_INTERRUPT	;type
	dc.b	0		;pri
	dc.l	AudName		;name
	dc.l	Cycles		;data
	dc.l	Aud_interrupt	;code	

AudName
	dc.b	'Audio Test',0
	EVEN
	
Cycles
	dc.w	0
	dc.w	INTF_AUD0
	dc.w	DMAF_AUD0
	
OldVector
	dc.l	0
		
SMP1		incbin		monobass	sample itself
SMP1LEN		equ		(*-SMP1)>>1	word length