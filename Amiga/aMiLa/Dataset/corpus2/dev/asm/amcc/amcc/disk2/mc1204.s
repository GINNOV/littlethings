; mc1204.s	= wave.s
; from disk2/wave
; explanation in letter_12.pdf / p. 06
; from Mark Wrobel course letter 37			
	
; SEKA>ks	; (optional)
; Sure? y
; SEKA>r
; FILENAME>mc1204.s
; SEKA>a
; OPTIONS>
; No errors
; SEKA>ri
; FILENAME>screen_wave
; BEGIN>screen
; END>
; SEKA>ri
; FILENAME>sin
; BEGIN>sin
; END>
; SEKA>j	

start:						; comments from Mark Wrobel
  move.w  #$4000,$dff09a	; INTENA disable interrupts
  move.w  #$01a0,$dff096	; DMACON disable bitplane, copper, and sprites

  lea.l   screen(pc),a1		; move screen address into a1
  move.l  #$dff180,a2		; move COLOR00 address into a2
  moveq   #3,d0				; initialize loop counter d0 to 3
colloop:					; color loop
  move.w  (a1)+,(a2)+		; copy from a1 (screen) to a2 (color table)
  dbra    d0,colloop		; if d0 > -1 goto colloop

  lea.l   bplcop+2(pc),a2	; move bplcop+2 address into a2
  move.l  a1,d1				; move a1 (first bitplane in screen) into d1
  moveq   #1,d0				; initialize loop counter d0 to 1
bplloop:					; bitplane loop
  swap    d1				; swap words of d1
  move.w  d1,(a2)			; set BPL1PTH to high 3 bits of bitplane address
  swap    d1				; swap words of d1
  move.w  d1,4(a2)			; set BPL1PTL to low 15 bits of bitplane address
  addq.l  #8,a2				; increment bplcop pointer with 8
  add.l   #10240,d1			; increment d1 to point at next bitplane in screen
  dbra    d0,bplloop		; if d0 > -1 goto bplloop

  bsr.s	initcop				; branch to subroutine initcop

  lea.l   copper(pc),a1		; move copper address into a1
  move.l  a1,$dff080		; move a1 into COP1LCH and COP1LCL

  move.w  #$8180,$dff096	; DNACON enable bitplane, copper

wait:						; busy wait for beam
  move.l  $dff004,d0		; move VPOSR and VHPOSR into d0
  asr.l   #8,d0				; shift right 8 places
  andi.w  #$1ff,d0			; keep first 9 bits vertical position of beam
  cmp.w   #280,d0			; is beam at line 280?
  bne.s   wait				; if not goto wait

  bsr.s   wave				; branch to subroutine wave

  btst    #6,$bfe001		; test left mouse button
  bne.s   wait				; if not pressed goto wait

  move.l  $04.w,a6			; make a6 point to ExecBase of exec.library
  move.l  156(a6),a6		; IVBLIT points to GfxBase
  move.l  38(a6),$dff080	; copinit ptr to copper start up list restore workbench copperlist

  move.w  #$8020,$dff096	; DMACON enable sprite
  rts						; return from subroutine

initcop:					; initialize copper list
  lea.l	  wavecop(pc),a1	; move wavecop address into a1
  move.w  #$4adf,d1			; move copper wait for vpos >= $4a and hpos >= $de
  move.w  #199,d0			; initilize loop counter d0 to 199
initcoploop:				; add waits to wavecop
  move.w  d1,(a1)+			; set wait - post incr. a1
  move.w  #$fffe,(a1)+		; set wait mask - post incr. a1
  move.l  #$01020000,(a1)+	; set BPLCON1 - post incr. a1
  add.w   #$100,d1			; increment scanline by 1
  dbra    d0,initcoploop	; if d0 > -1 goto initcooloop
  rts						; return from subroutine

cont:
  dc.w	0					; index into the sine table

wave:
  lea.l   cont(pc),a1       ; move cont address into a1
  move.w  (a1),d1           ; move cont value into d1
  addq.w  #2,(a1)           ; cont += 2
  andi.w  #$fe,d1           ; keep first word and allign it to an equal number
  lea.l   sin(pc),a1        ; move sin address into a1
  add.w   d1,a1             ; add the offset to the sine table
  lea.l   wavecop+6(pc),a2  ; move wavecop+6 into a2
  move.w  #199,d0           ; loop counter d0 = 199
waveloop:                   ; loop over 200 scanlines in copper
  move.w  (a1)+,(a2)        ; copy sine value to copper (set DFF102)
  addq.l  #8,a2             ; move to next scanline in copper
  dbra    d0,waveloop       ; if d0 > -1 goto waveloop
  rts                       ; return from subroutine

copper:
  dc.w	$2001,$fffe  ; wait for vpos >= $20 and hpos >= 0
  dc.w	$0104,$0000  ; move $0000 to $dff104 BPLCON2 video
  dc.w	$0108,$0000  ; move $0000 to $dff108 BPL1MOD modulus odd planes
  dc.w	$010a,$0000  ; move $0000 to $dff10a BPL2MOD modulus even planes
  dc.w	$008e,$2c81  ; move $2c81 to $dff08e DIWSTRT upper left corner ($81,$2c)
  ;dc.w	$0090,$f4c1  ; move $f4c1 to $dff090 DIWSTOP (enable PAL trick)
  dc.w	$0090,$38c1  ; move $38c1 to $dff090 DIWSTOP (PAL trick) lower right corner ($1c1,$12c)
  dc.w	$0092,$0038  ; move $0038 to $dff092 DDFSTRT data fetch start at $38
  dc.w	$0094,$00d0  ; move $00d0 to $dff094 DDFSTOP data fetch stop at $d0

  dc.w	$2c01,$fffe  ; wait for vpos >= $2c and hpos >= 0
  dc.w	$0100,$2200  ; BPLCON0 enable 2 bitplanes, enable color burst

bplcop:
  dc.w	$00e0,$0000  ; BPL1PTH (high bit 16-31)
  dc.w	$00e2,$0000  ; BPL1PTL (low  bit 0-15)
  dc.w	$00e4,$0000  ; BPL2PTH (high bit 16-31)
  dc.w	$00e6,$0000  ; BPL2PTL (low bit 0-15)

wavecop:
  blk.w	1600/2,0     ; allocate 800 words

  dc.w	$2c01,$fffe  ; wait for vpos >= $12c and hpos >= 0 (explained later)
  dc.w	$0100,$0200  ; BPLCON0 disable bitplane - older PAL chips.
  dc.w	$ffff,$fffe  ; wait indefinitely - until next vertical blanking

sin:
  blk.w	656/2,0

screen:
  blk.w	20488/2,0
	
	end
	