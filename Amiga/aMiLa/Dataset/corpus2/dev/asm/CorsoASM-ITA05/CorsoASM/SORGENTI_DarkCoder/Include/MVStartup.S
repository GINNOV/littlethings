************************************
*       /\/\                       *
*      /    \                      *
*     / /\/\ \ O R B_I D           *
*    / /    \ \   / /              *
*   / /    __\ \ / /               *
*   ¯¯     \ \¯¯/ / I S I O N S    *
*           \ \/ /                 *
*            \  /                  *
*             \/                   *
*     Feel the DEATH inside!       *
************************************

* Simple startup for Infamia

	include	include/custom.i
	include	include/exec_lib.i
	include	include/graphics_lib.i

***********************
*   Codice generale   *
***********************

custom = $dff000

StartUp:
	move.l	$4.w,a6

	btst	#0,$129(a6)		; setta flag se c'e` 68010
	sne	FlagCpu			; o superiore

	beq.s	.done			; se 68000 non legge VBR
	lea	supercode(pc),a5
	jsr	_LVOSupervisor(a6)	; altrimenti leggi VBR
.done

	jsr	_LVODisable(a6)

	lea	GfxName(pc),a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	move.l	a6,a4
	move.l	d0,a6

	move.l	34(a6),-(a7)		; gb_Actiview
	move.l	d0,-(a7)

	jsr	_LVOOwnBlitter(a6)
	jsr	_LVOWaitBlit(a6)

	sub.l	a1,a1
	jsr	_LVOLoadView(a6)
	jsr	_LVOWaitTOF(a6)
	jsr	_LVOWaitTOF(a6)

	lea	custom,a5
.wait	move.l	vposr(a5),d0
	lsr.l	#8,d0
	and	#$1FF,d0
	cmp	#$132,d0
	bne.s	.wait

	move	intenar(a5),-(a7)
	move	#$7fff,intena(a5)
	move	dmaconr(a5),-(a7)
	move	#$7fff,dmacon(a5)
	move	adkconr(a5),-(a7)
	move	#$7fff,adkcon(a5)

; salva il vettore int. livello 3 dell'OS
	move.l	StoreVBR(pc),a0
	move.l	$6c(a0),-(a7)

; aga-reset
	move	#0,fmode(a5)
	move.w	#$0c00,bplcon3(a5)
	move	#$0011,bplcon4(a5)

	bsr	Start

; A5=$dff000
Uscita
	move	#$7fff,d2
	move	d2,intena(a5)	; blocca interrupt

; ripristina vettore int. livello 3 dell'OS
	move.l	StoreVBR(pc),a0
	move.l	(a7)+,$6c(a0)


.wait	move.l	vposr(a5),d0
	lsr.l	#8,d0
	and	#$1FF,d0
	cmp	#$132,d0
	bne.s	.wait

	move	#$8000,d1
	move	(a7)+,d0
	or	d1,d0
	move	d2,adkcon(a5)
	move	d0,adkcon(a5)

.waitblit
	btst	#6,dmaconr(a5)		; niente test preliminare
	bne.s	.waitblit		; si tratta di un bug OCS

	move	d2,dmacon(a5)
	move	(a7)+,d0
	or	d1,d0
	move	d0,dmacon(a5)

	move	d2,intreq(a5)
	move	(a7)+,d0
	or	d1,d0
	move	d0,intena(a5)

	move.l	(a7)+,a6
	move.l	(a7)+,a1
	jsr	_LVOLoadView(a6)

	move.l	38(a6),cop1lc(a5)	; legge gb_copinit

	jsr	_LVODisownBlitter(a6)

	move.l	a6,a1
	move.l	$4.w,a6
	jsr	_LVOCloseLibrary(a6)

	jsr	_LVOEnable(a6)

	moveq	#0,d0
	rts

**************************
* Routine che legge il VBR 
* e lo memorizza in
* StoreVBR

	cnop	0,4
SuperCode:
	movec	VBR,a0
	move.l	a0,StoreVBR
	rte

* dati
StoreVBR	dc.l	0		; contenuto registro VBR
GfxName	dc.b	'graphics.library',0	; nome GFX library
FlagCpu	dc.b	0			; se settato cpu 68010 o superiore


