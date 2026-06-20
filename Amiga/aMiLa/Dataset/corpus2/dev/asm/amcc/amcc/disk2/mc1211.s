; mc1211.s	= stars.s
; from disk2/stars
; explanation in letter_12.pdf / p. 13
; from Mark Wrobel course letter 36			
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1211.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>acc
; BEGIN>acc
; END>
; SEKA>ri
; FILENAME>sin_stars
; BEGIN>sin
; END>
; SEKA>ri
; FILENAME>stars
; BEGIN>stars
; END>
; SEKA>j

start:						; comments from Mark Wrobel
    move.w	#$4000,$dff09a  ; INTENA disable interrupts
    move.w	#$01a0,$dff096  ; DMACON disable bitplanes, blitter, and sprites
    
    lea.l	screen(pc),a1   ; store screen address in a1
    lea.l	bplcop(pc),a2   ; store bplcop address in a2

; start set screen address via copper list
    move.l	a1,d1           ; move screen address into d1
    move.w	d1,6(a2)        ; set BPL1PTH via the copper
    swap	d1              ; swap words in d1
    move.w	d1,2(a2)        ; set BPL1PTL via the copper
; end set screen address via copper list

    lea.l	copper(pc),a1   ; store copper address in a1
    move.l	a1,$dff080      ; set COP1LCH and COP1LCL
    
    move.w	#$8180,$dff096  ; DMACON enable bitplanes and copper

wait:
    move.l	$dff004,d0      ; read VPOSR and VHPOSR store in d0
    asr.l	#8,d0           ; right shift 8 places 
    andi.w	#$1ff,d0        ; keep 9 least significant bits, so
                            ; that d0 contains vertical beam position
    bne.s	wait            ; if vertical beam is not 0 goto wait                                

    bsr.s	clear           ; branch to subroutine clear
    bsr	    star			; branch to subroutine star
    bsr.s	rotate          ; branch to subroutine rotate
    bsr.s	swapscr         ; branch to subroutine swapscr

    btst	#6,$bfe001      ; test left mouse button
    bne.s	wait            ; if not pressed goto wait

; start restore workbench copper
    move.l	4.w,a6          ; move ExecBase of exec.library into a6
    move.l	156(a6),a6      ; IVBLIT points to GfxBase
    move.l	38(a6),$dff080  ; copinit ptr to copper start up list 
                                ; restore workbench copperlist 
; end restore workbench copper

    move.w	#$8020,$dff096  ; DMACON - enable sprite
    rts                     ; exit program

scr:                        ; screeen counter
    dc.w	0

; swap screens using the copper
swapscr:
    lea.l	scr(pc),a1      ; store scr address in a1
    addq.w	#1,(a1)         ; add 1 to scr value
    move.w	(a1),d1         ; move scr value into d1
    andi.w	#1,d1           ; keep first bit of d1
    mulu	#10240,d1       ; multiply d1 with a 320x256 bitplane
    lea.l	screen(pc),a1   ; store screen address in a1
    lea.l	bplcop(pc),a2   ; store bplcop address in a2
    add.l	a1,d1           ; add screen address to bitplane offset
    move.w	d1,6(a2)        ; set BPL1PTH via the copper
    swap	d1              ; swap words in d1
    move.w	d1,2(a2)        ; set PBL1PTL via the copper
    rts                     ; return from subroutine

; sets the rotation speed of the starfield
rotate:
    lea.l	stars(pc),a1    ; store stars address in a1
    move.w	#255,d0         ; initialize counter d0
rotloop:
    addq.w	#3,(a1)         ; increment value pointed to by a1 with 3
							; (rotation speed - change direction use subq.w)
    addq.l	#4,a1           ; add 4 to address pointer i.e. next value
    dbra	d0,rotloop      ; if counter > -1 goto rotloop
    rts                     ; return from subroutine

; clear the screen using the blitter
clear:
    btst	#6,$dff002          ; DMACONR test if blitter is enabled 
    bne.s	clear               ; if blitter not enabled goto clear
                                ; this is a wait for blitter to finish

    lea.l	screen(pc),a1       ; store screen address in a1
    lea.l	scr(pc),a2          ; store scr address in a2
    move.w	(a2),d1             ; move scr counter value into d1
    not.w	d1                  ; invert d1
    andi.w	#1,d1               ; keep first bit - d1 is either 0 or 1
    mulu	#10240,d1           ; multiply d1 with a 320x256 bitplane
    add.l	d1,a1               ; add the bitplane offset to screen address
    move.l	a1,$dff054          ; set BLTDPTH / BLTDPTL to address a1 
    clr.w	$dff066             ; clear BLTDMOD
    move.l	#$01000000,$dff040  ; set BLTCON0 and BLTCON1 with use D=0
    move.w	#$4014,$dff058      ; BLTSIZE,height=256,width=20 words (320px)
cl2:
    btst	#6,$dff002          ; DMACONR, test if blitter is enabled
    bne.s	cl2                 ; if blitter not enabled goto cl2
                                ; this is a wait for blitter to finish
    rts                         ; return from subroutine

; draw stars and update their radial distance
star:
    lea.l	screen(pc),a0   ; store screen address in a0
    lea.l	scr(pc),a1      ; store scr address in a1
    move.w	(a1),d1         ; move scr value into d1
    not.w	d1              ; invert d1
    andi.w	#1,d1           ; keep first bit
    mulu	#10240,d1       ; multiply d1 with size of a 320x256 bitplane
    add.l	d1,a0           ; add bitplane offset to screen address
    lea.l	sin(pc),a1      ; store sin table address in a1
    lea.l	sin+512(pc),a2  ; store cos table address in a2
    lea.l	stars(pc),a3    ; store stars table address in a3
    lea.l	acc(pc),a4      ; store acc table address in a4
    move.w	#255,d7         ; initialize loop counter d7
starloop:
    move.w	(a3)+,d2        ; d2 = star.angle, a3 = star.dist
    andi.w	#$7fe,d2        ; star.angle offset must be even
    move.w	(a1,d2.w),d0    ; d0 = sin(star.angle)
    move.w	(a2,d2.w),d1    ; d1 = cos(star.angle) 
    addq.w	#4,(a3)         ; star.dist += 4
    move.w	(a3)+,d2        ; d2 = star.dist, a3 = star.angle
    andi.w	#$03fe,d2       ; star.dist offset must be even
    muls	(a4,d2.w),d0    ; d0 = acc(star.dist) * d0
    swap	d0              ; swap words in d0
    add.w	#160,d0         ; add 160 to d0
    muls	(a4,d2.w),d1    ; d1 = acc(star.dist) * d1
    swap	d1              ; swap words in d1
    add.w	#128,d1         ; add 128 to d1
    lsl.w	#3,d1           ; divide d1 with 32
    move.w	d1,d3           ; move d1 into d3
    lsl.w	#2,d3           ; divide d3 with 8
    add.w	d3,d1           ; add d3 to d1 (d1=40*d1=32*d1+8*d1)
    move.w	d0,d2           ; move d0 into d2
    lsr.w	#3,d0           ; divide d0 with 8
    add.w	d1,d0           ; add d1 to d0 - offset from screen in bytes
    not.b	d2              ; invert d2 - find bit number to set
    bset	d2,(a0,d0.w)    ; set bit number d2 at address of screen + d0
    dbra	d7,starloop     ; if d7 > -1 goto starloop
    rts                     ; return from subroutine

copper:
    dc.w	$2001,$fffe		; wait($01,$20)
    dc.w	$0102,$0000		; BPLCON1 set to $0
    dc.w	$0104,$0000		; BPLCON2 set to $0
    dc.w	$0108,$0000		; BPL1MOD set to $0
    dc.w	$010a,$0000		; BPL2MOD set to $0
    dc.w	$008e,$2c81		; DIWSTRT top right corner ($81,$2c)
    dc.w	$0090,$f4c1		; DIWSTOP enable PAL trick
    dc.w	$0090,$38c1		; DIWSTOP buttom left corner ($1c1,$12c)
    dc.w	$0092,$0038		; DDFSTRT data fetch start at $38
    dc.w	$0094,$00d0		; DDFSTOP data fetch stop at $d0
    dc.w	$0180,$0000		; COLOR00 black background
    dc.w	$0182,$0f8f		; COLOR01 light-magenta star color

    dc.w	$2c01,$fffe		; wait($01,$2c)
    dc.w	$0100,$1200		; BPLCON0 enable 1 bitplane, color burst

bplcop:
    dc.w	$00e0,$0000		; BPL1PTH set by start and swapscr
    dc.w	$00e2,$0000		; BPL1PTL set by start and swapscr

    dc.w	$ffdf,$fffe		; wait($df,$ff) enable wait > $ff horiz
    dc.w	$2c01,$fffe		; wait($01,$12c)
    dc.w	$0100,$0200		; move to BPLCON0 disable bitplane
                            ; needed to support older PAL chips.
    dc.w	$ffff,$fffe		; end of copper

stars:
    blk.l	256,0			; allocate 256 entries of star angles and postions
	;incbin "stars"
sin:
    blk.w	1280,0			; allocate 1280 entries of sine data
	;incbin "sin_stars"
acc:
    blk.w	512,0
	;incbin "acc"
screen:
    blk.w	10240,0

	end
