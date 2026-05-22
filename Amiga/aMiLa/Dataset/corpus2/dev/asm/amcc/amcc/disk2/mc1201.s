; mc1201.s	= ham.s
; from disk2/ham
; explanation in letter_12.pdf / p. 03
; from Mark Wrobel course letter 21			
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1201.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen_ham
; BEGIN>screen
; END>
; SEKA>j

start:						; comments from Mark Wrobel				
	move.w	#$4000,$dff09a	; INTENA  - disable all interrupts
	move.w	#$01a0,$dff096	; DMACON - disable bitplane, copper, sprite

	lea.l	screen(pc),a1	; move address of screen into a1
	move.l	#$dff180,a2		; move COLOR00 adress into a2
	moveq	#15,d0			; move 15 into d0 (loop counter)
colloop:					; begin loop that copy the 16 color palette
	move.w	(a1)+,(a2)+		; copy from screen into the color register
	dbra	d0,colloop		; if d0 >= 0 goto collop

	lea.l	bplcop+2(pc),a2 ; move address of bplcop + 2 + pc into a2
	add.w	#96,a1          ; point a1 to the first bitplane
	move.l	a1,d1           ; move a1 into d1
	moveq	#5,d0           ; move 5 into d0 (loop counter)
bplloop:					; Loop over 6 bitplanes and set bitplane pointers
	swap	d1
	move.w	d1,(a2)         ; set BPLxPTH in bplcop
	swap	d1
	move.w	d1,4(a2)        ; set BPLxPTL in bplcop
	addq.l	#8,a2           ; move to next bitplane pointers in bplcop
	add.l	#10240,d1       ; move d1 to point at the next bitplane
	dbra	d0,bplloop      ; if d0 >= 0 goto bplloop

	lea.l	copper(pc),a1   ; move address of copper into a1
	move.l	a1,$dff080      ; set COP1LCH and COP1LCL to address of a1

	move.w	#$8180,$dff096  ; DMACON - enable bitplane, copper

wait:
	btst	#6,$bfe001      ; busy wait until left mouse button is pressed
	bne.s	wait

	move.l	$04.w,a6        ; make a6 point to ExecBase of exec.library, which is also a struct
	move.l	156(a6),a6      ; IVBLIT points to GfxBase
	move.l	38(a6),$dff080  ; copinit ptr to copper start up list restore workbench copperlist 

	move.w	#$8020,$dff096  ; DMACON - enable sprite
	rts                     ; return from subroutine

copper:
	dc.w	$2001,$fffe		; wait for line $20
	dc.w	$0102,$0000		; move $0000 to $dff102 BPLCON1 scroll
	dc.w	$0104,$0000		; move $0000 to $dff104 BPLCON2 video
	dc.w	$0108,$0000		; move $0000 to $dff108 BPL1MOD modulus odd planes
	dc.w	$010a,$0000		; move $0000 to $dff10a BPL2MOD modulus even planes
	dc.w	$008e,$2c81		; move $2c81 to $dff08e DIWSTRT upper left corner ($81,$2c)
	;dc.w	$0090,$f4c1		; move $f4c1 to $dff090 DIWSTOP (enable PAL trick)
	dc.w	$0090,$38c1		; move $38c1 to $dff090 DIWSTOP (PAL trick) lower right corner ($1c1,$12c)
	dc.w	$0092,$0038		; move $0038 to $dff092 DDFSTRT data fetch start at $38
	dc.w	$0094,$00d0		; move $00d0 to $dff094 DDFSTOP data fetch stop at $d0

	dc.w	$2c01,$fffe		; wait for line $2c
	dc.w	$0100,$6a00		; move $6a00 to $dff100 BPLCON0 - use 6 bitplanes, HAM, enable color burst 

bplcop:
	dc.w	$00e0,$0000		; BPL1PTH
	dc.w	$00e2,$0000		; BPL1PTL
	dc.w	$00e4,$0000		; BPL2PTH
	dc.w	$00e6,$0000		; BPL2PTL
	dc.w	$00e8,$0000		; BPL3PTH
	dc.w	$00ea,$0000		; BPL3PTL
	dc.w	$00ec,$0000		; BPL4PTH
	dc.w	$00ee,$0000		; BPL4PTL
	dc.w	$00f0,$0000		; BPL5PTH
	dc.w	$00f2,$0000		; BPL5PTL
	dc.w	$00f4,$0000		; BPL6PTH
	dc.w	$00f6,$0000		; BPL6PTL

	dc.w	$ffdf,$fffe		; wait - enables waits > $ff vertical
	dc.w	$2c01,$fffe		; wait for lien - $2c is $12c 
	dc.w	$0100,$0a00		; move $0a00 to $dff100 BPLCON0 - HAM, enable color burst
	dc.w	$ffff,$fffe		; end of copper list

screen:
	blk.w	61568/2,0		; allocate (320*256 pixels * 6 bitplanes) / 8 + 128 bytes = 61.568 bytes 
	;incbin "screen_ham"		; for asmone
	end
