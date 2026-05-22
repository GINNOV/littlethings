; mc1205.s	= rotation.s
; from disk2/rotation
; explanation in letter_12.pdf / p. 07
; from Mark Wrobel course letter 35			
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1205.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen_rot
; BEGIN>screen
; END>
; SEKA>ri
; FILENAME>sin_rot
; BEGIN>sin
; END>
; SEKA>j	

start:						; comments from Mark Wrobel
    move.w	#$4000,$dff09a	; INTENA disable interrupts

    bsr	initcop             ; branch to subroutine initcop
    bsr	setcolor            ; branch to subroutine setcolor

    move.w	#$01a0,$dff096  ; DMACON clear bitplane, copper, blitter

    lea.l	copper(pc),a1   ; store copper pointer in a1
    move.l	a1,$dff080      ; set COP1LCH/COP1LCL to address of copper

    move.w	#$8180,$dff096  ; DMACON set bitplane, copper

main:
    lea.l	pos(pc),a1		; store pos pointer in a1
    addq.w	#7,(a1)			; increment pos 
                            ; larger step - higher rotation speed
    bsr	genrot              ; branch to subroutine genrot

bpos:                       ; beam position check
    move.l	$dff004,d0		; store VPOSR and VHPOSR value in d0 (move long)
    asr.l	#8,d0			; algorithmic shift right 8 places
    andi.w	#$1ff,d0		; keep v8,v7,...,v0 in d0
    cmp.w	#300,d0			; compare
    bne.s	bpos			; if d0 != 300 goto bpos

    bsr.s	genpt			; set bitplane pointers in copper list
    bsr.s	gencop			; set bitplane modulo values in copper list

    btst	#6,$bfe001		; test if left mouse button is pressed
    bne.s	main			; if not, then go to main

    move.l	4.w,a6          ; reestablish workbench
    move.l	156(a6),a6
    move.l	38(a6),a6
    move.l	a6,$dff080
    move.w	#$8020,$dff096
    rts

gencop:                     ; generate copper list
    lea.l	cop+6(pc),a1    ; store BPL1MOD data pointer in a1
    lea.l	gentab(pc),a2   ; store gentab pointer in a2
    move.w	#255,d0         ; set loop counter
gencoploop:                 ; loop over 256 lines and set modulus
    move.w	(a2),(a1)       ; set BPL1MOD in copper list
    addq.l	#4,a1           ; increment pointer 4 bytes
    move.w	(a2)+,(a1)      ; set BPL2MOD in copper list, increment pointer
    addq.l	#8,a1           ; increment pointer 8 bytes
    dbra	d0,gencoploop   ; if d0 >= 0 goto gencoploop
    rts                     ; return from subroutine

genpt:                      ; generate bitplane pointers in copper list
    lea.l	pos(pc),a1      ; store pos pointer in a1
    move.w	(a1),d1         ; store pos value in d1
    andi.w	#$7fe,d1        ; make d1 an even number <= 2046
    lea.l	screen+16(pc),a1; store pointer to first bitplane
    cmp.w	#1024,d1        ; have we reached negative sine numbers?
    ble.s	genpt2          ; if d1 <= 1024 (sine is positive) goto genpt2
    add.w	#10240,a1       ; increment screen pointer to next bitplane
genpt2:
    lea.l	bplcop(pc),a2   ; store bplcop pointer in a2
    move.l	a1,d1           ; store screen pointer in d1
    moveq	#2,d0           ; set loop counter 
bplcoploop:                 ; loop over 3 bitplanes
    swap	d1              ; swap screen pointer
    move.w	d1,2(a2)        ; set BPLxPTH
    swap	d1              ; swap screen pointer
    move.w	d1,6(a2)        ; set BPLxPTL
    addq.l	#8,a2           ; increment bplcop pointer to next entry
    add.l	#10240,d1       ; increment screen pointer to next bitplane
    dbra	d0,bplcoploop   ; if d0 >= 0 goto bplcoploop
    rts                     ; return from subroutine
pos:
    dc.w	0               ; position in sine table

genrot:                     ; generate rotation table
    lea.l	pos(pc),a1      ; store pos pointer in a1
    move.w	(a1),d1         ; store pos value in d1
    andi.w	#$7fe,d1        ; make d1 and even number <= 2046
    cmp.w	#1024,d1        ; have we reached negative sine numbers?
    bgt.s	type2           ; if d1 > 1024 (sine is negative) goto type2
    lea.l	sin(pc),a1      ; store sin pointer in a1
    moveq	#0,d2           ; clear d2 (alternative to clr.l)
    move.w	(a1,d1.w),d2    ; store data from sin table in d2
    move.l	d2,d3           ; store sin data in d3 
    move.l	d2,d5           ; store sin data in d5
    lsr.w	#8,d2           ; keep sine value of sin data in d2
    andi.w	#255,d5         ; keep offset value of sin data in d5
    lsl.w	#8,d5           ; logical shift left d5 by 8 bits
    move.w	#256,d1         ; move #256 into d1
    sub.w	d2,d1           ; subtract sine value from d1
    lsr.w	#1,d1           ; divide d1 by 2
    add.w	d1,d2           ; add d1 to sine value in d2
    moveq	#0,d0           ; clear loop counter d0
    lea.l	gentab(pc),a1   ; store gentab pointer in a1
loop1:                      ; loop d1 times
    cmp.w	d0,d1           ; compare loop counter d0 to number of loops d1
    beq.s	loop1ok         ; if equal exit loop by goto loop1ok
    move.w	#-40,(a1)+      ; insert -40 into gentab and increment pointer
    addq.w	#1,d0           ; increment loop counter d0
    bra.s	loop1           ; branch always to loop1
loop1ok:
    moveq	#0,d4           ; clear d4
    sub.l	d5,d4           ; subtract first byte of sine data
    moveq	#0,d5           ; clear d5
loop2:                      ; loop d2-d1 times (squeezed image loop)
    cmp.w	d0,d2           ; compare loop counter d0 with d2
    beq.s	loop3           ; if equal goto loop3
    addq.w	#1,d0           ; increment loop counter d0
    moveq	#-1,d6          ; set d6 to -1
loop2x:                     ; inner loop - determine lines to sample
    add.l	d3,d4           ; add d3 to d4
    move.l	d4,d7           ; move sine value into d7
    swap	d7              ; swap words of d7
    addq.w	#1,d6           ; increment d6 - the line to sample
    cmp.w	d5,d7           ; compare d5 with d7
    ble.s	loop2x          ; if d5 <= d7 goto loop2x
    move.w	d7,d5           ; move d7 to d5
    mulu	#40,d6          ; multiply d6 with 40 - image width in bytes
    move.w	d6,(a1)+        ; insert d6 into gentab and increment pointer
    bra.s	loop2           ; branch always to loop2
loop3:                      ; loop 256-d0 times
    cmp.w	#256,d0         ; compare loop counter d0 to #256
    beq.s	loop3ok         ; if equal exit loop by goto loop3ok 
    move.w	#-40,(a1)+      ; write -40 into gentab
    addq.w	#1,d0           ; increment loop counter d0
    bra.s	loop3           ; branch always to loop3
loop3ok:
    rts                     ; return from subroutine
type2:                      ; generate rotation table - negative sine 
    lea.l	sin(pc),a1      ; won't repeat almost identical comments here
    moveq	#0,d2
    move.w	(a1,d1.w),d2
    move.l	d2,d3
    move.l	d2,d5
    lsr.w	#8,d2
    andi.w	#255,d5
    lsl.w	#8,d5
    move.w	#256,d1
    sub.w	d2,d1
    lsr.w	#1,d1
    add.w	d1,d2
    moveq	#0,d0
    lea.l	gentab(pc),a1
loop1b:
    cmp.w	d0,d1
    beq.s	loop1okb
    move.w	#-40,(a1)+
    addq.w	#1,d0
    bra.s	loop1b
loop1okb:
    moveq	#0,d4
    sub.l	d5,d4
    moveq	#0,d5
loop2b:
    cmp.w	d0,d2
    beq.s	loop3b
    addq.w	#1,d0
    moveq	#1,d6
loop2bx:
    add.l	d3,d4
    move.l	d4,d7
    swap	d7
    addq.w	#1,d6
    cmp.w	d5,d7
    ble.s	loop2bx
    move.w	d7,d5
    muls	#-40,d6
    move.w	d6,(a1)+
    bra.s	loop2b
loop3b:
    cmp.w	#256,d0
    beq.s	loop3okb
    move.w	#-40,(a1)+
    addq.w	#1,d0
    bra.s	loop3b
loop3okb:
    rts

initcop:                        ; construct copper list
    lea.l	cop(pc),a1			; store address of cop into a1
    move.l	a1,a2				; store copy of a1 in a2
    move.w	#255,d0				; set loop counter d0 to 255
    moveq	#$2c,d1				; set d1 to $2c i.e first line to wait for
initcoploop:
    move.b	d1,(a1)+            ; set byte to d1
    move.b	#$01,(a1)+          ; set byte to $01 -> $xx01 = wait
    move.w	#$fffe,(a1)+        ; set wait mask -> dc.w $xx01,$fffe
    move.l	#$01080000,(a1)+    ; BPL1MOD
    move.l	#$010a0000,(a1)+    ; BPL2MOD
    addq.w	#1,d1               ; increment line to wait for
    dbra	d0,initcoploop      ; if d0 >= 0 goto initcoploop
    move.w	#$ffdf,2544(a2)     ; enables waits > $ff vertical (2544=212*12)
    rts                         ; return from subroutine

setcolor:                       ; set colors via copper list
    lea.l	screen(pc),a1		; store address of screen in a1
    lea.l	colcop+2(pc),a2		; store address of colorcop + 2 in a2
    moveq	#7,d0				; set loop counter d0
colorloop:
    move.w	(a1)+,(a2)			; copy color from screen to colorcop
    addq.l	#4,a2				; go to next color entry in colorcop
    dbra	d0,colorloop		; if d0 >= 0 goto colorloop
    rts                         ; return from subroutine

copper:
    dc.w	$2001,$fffe			; wait for line #32
    dc.w	$0100,$0200			; BPLCON0 disable bitplanes
    dc.w	$008e,$2c81			; DIWSTRT top right corner ($81,$2c)
    dc.w	$0090,$f4c1			; DIWSTOP enable PAL trick
    dc.w	$0090,$38c1			; DIWSTOP buttom left corner ($1c1,$12c)
    dc.w	$0092,$0038			; DDFSTRT
    dc.w	$0094,$00d0			; DDFSTOP
    dc.w	$0102,$0000			; BPLCON1 (scroll)
    dc.w	$0104,$0000			; BPLCON2 (video)
    dc.w	$0108,$0000			; BPL1MOD
    dc.w	$010a,$0000			; BPL2MOD

colcop:
    dc.w	$0180,$0000			; COLOR00
    dc.w	$0182,$0000			; COLOR01
    dc.w	$0184,$0000			; COLOR02
    dc.w	$0186,$0000			; COLOR03
    dc.w	$0188,$0000			; COLOR04
    dc.w	$018a,$0000			; COLOR05
    dc.w	$018c,$0000			; COLOR06
    dc.w	$018e,$0000			; COLOR07

    dc.w	$2b01,$fffe			; wait for line #43 ($2B)

bplcop:
    dc.w	$00e0,$0000			; BPL1PTH
    dc.w	$00e2,$0000			; BPL1PTL
    dc.w	$00e4,$0000			; BPL2PTH
    dc.w	$00e6,$0000			; BPL2PTL
    dc.w	$00e8,$0000			; BPL3PTH
    dc.w	$00ea,$0000			; BPL3PTL

    dc.w	$0100,$3200			; BPLCON0 enable bitplanes

cop:
    blk.w	1536,0				; allocate 1536 words (256 * 6w)

    dc.w	$2c01,$fffe			; wait for line $12c (waits > $ff enabled)
    dc.w	$0100,$0200			; BPLCON0 disable bitplanes
    dc.w	$ffff,$fffe			; end of copper list

gentab:							; generated table
    blk.w	256,0				; store bitplane modulo values foreach screen line 

sin:							; sine and offset data
    blk.w	1024,0				; allocate 1024 words and set to 0
	;incbin "screen_rot"
screen:							; image data (320*256*3)/16+8
    blk.w	15388,0				; allocate 15388 words and set to 0
	;incbin "sin_rot"

	end
