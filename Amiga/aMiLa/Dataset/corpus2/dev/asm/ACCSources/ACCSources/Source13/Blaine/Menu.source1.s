	section	Chip,Data_C
*						BLAINE EVANS
*						1,ERITH WAY
*						PONTYBODKIN
*						NR.MOLD
*						CLWYD
*						CH7 4TR
*						0352-771673

*	Fixed, M.Meany May 21 1991

         OPT C-,D+


	movem.l	d0-d7/a0-a6,-(SP)	;Save registers

	MOVE.L	A7,STACK_POINTER	SAVE STACK ADDRESS

        move.l	4.w,A6              	; Get EXEC-Base
        jsr     -132(A6)   	        ; Forbid Multitasking
       	move.l  4.w,A6    	        ; Get EXEC-Base
	moveq	#0,d0			; Libary no
	lea	Gfxname(pc),a1		; load gfx address
	jsr	-552(a6)		; open library
	move.l	d0,GfxBase		; store gfx address
       	move.l  4.w,A6    	        ; Get EXEC-Base
	moveq	#0,d0			; Dos version
	lea	Dosname(pc),a1		; load dos address
	jsr	-552(a6)		; open library
	move.l	d0,Dosbase		; store dos address
	moveq	#2,d1			; chip memory
	move.l	#(256*40)*2,d0		; screen size*2 planes
	jsr	-198(a6)		; allocate memory
	move.l	d0,PlaneAdr		; store address
	move.w	d0,Bpl0l		; low word
	swap d0				; swap
	move.w	d0,Bpl0h		; high word
	swap	d0
	add.l	#256*40,d0		; plane size (PAL Screen)
	move.w	d0,Bpl1l		; low word
	swap d0				; swap
	move.w	d0,Bpl1h		; high word
	swap	d0
	move.l	#Sprite,d0
	move.w	d0,Sp0l		; low word
	swap d0			; swap
	move.w	d0,Sp0h		; high word
	swap	d0

Graphics
	lea	Screen,a0		; screen graphics
	move.l	PlaneAdr,a1		; address
	move.w	#((256*40)*2)/4,d1	; no of times to loop-1
Gra_Loop
	move.l	(a0)+,(a1)+		; transfer a long word and increment
	dbra	d1,Gra_Loop		; loop till 0
	move.l	GfxBase,a1		; Gfx address 
	move.l	50(a1),Oldcop		; save old copperlist
	move.l	#Newcop,50(a1)		; insert new copperlist

Wait
	cmp.b	#255,$dff006
	bne	Wait
	Bsr	Sprite0
	Bsr	JoyTest
	Bsr	Fire
	Bsr	Bar
	Bra	Wait
   
Sprite0
	lea	sprites,a0		;CONTROL WORDS
	move.l	#Sprite,d0		;ADDRESS
	move.w	d0,6(a0)		;AND UPDATE COPPER
	swap	d0
	move.w	d0,2(a0)
	swap	d0	
	move.l	#Sprite,a0		;A0=SPRITE 0 ADDRESS
	move.w	#40,d7			;NO OF SPRITES-1
Move
	addq.b	#1,1(a0)		;ADD # TO HORIZONTAL POSITIONAL BYTE
	addq.b	#2,9(a0)
	addq.b	#3,17(a0)
	add.l	#24,a0			;LOCATE NEXT PAIR OF CO-ORDINATES
	dbf	d7,Move			;DECREMENT AND BRANCH WHEN =0
	rts
	
Joytest
	move.w	$DFF00c,d2		;joy value to d2
	move.w	d2,d1			; 
	lsr.w	#1,d1			; logocally shift right #1
	eor.w	d2,d1			; exclusively or with d1
try_down	
	btst	#0,d1			; bit 0 =down
	beq	try_up			; 
	move.b	#1,Value		; #1 to Value
	rts
try_up	
	btst	#8,d1			; bit 8 =up
	beq	no_move
	move.b	#-1,Value		; #-1 to Value
	rts
no_move
	move.b	#0,Value		; none of above
	rts				; #0 to Value
Fire
	Btst	#$7,$bfe001		; Fire pressed
	beq	Fired			; yes branch
	rts				; else return
Fired
	bsr	Function_1		; branches to check each
	bsr	Function_2		; number
	bsr	Function_3
	bsr	Function_4
	bsr	Function_5
	bsr	Function_6
	rts
Function_1
	lea	Copper_Bar,a0		; 1st value in moving bar 
	cmp.b	#$5B,0(a0)		; check co-ordinates
	bls	Try_End			; <=co-ordinate try next co-ordinate
	rts		
Try_End
	lea	C_End,a0		; end of bar
	cmp.b	#$69,0(a0)		; >=co-ordinate
	bhs	Yes_1			; yes then branch
	rts
Yes_1
	move.l	#Com1,d2		; load program name 
	move.l	d2,com			; variable to store above
	bsr	Execute			; execute
	rts
Function_2
	lea	Copper_Bar,a0		; same for all menu items
	cmp.b	#$6B,0(a0)		; just simple co-ordinate
	bls	Try_End_2		; checking and loading name
	rts				; of program
Try_End_2
	lea	C_End,a0
	cmp.b	#$79,0(a0)
	bhs	Yes_2
	rts
Yes_2
	move.l	#Com2,d1
	move.l	d1,com
	bsr	Execute
	rts
Function_3
	lea	Copper_Bar,a0
	cmp.b	#$7B,0(a0)
	bls	Try_End_3
	rts
Try_End_3
	lea	C_End,a0
	cmp.b	#$89,0(a0)
	bhs	Yes_3
	rts
Yes_3
	move.l	#Com3,d1
	move.l	d1,com
	bsr	Execute
	rts
Function_4
	lea	Copper_Bar,a0
	cmp.b	#$8B,0(a0)
	bls	Try_End_4
	rts
Try_End_4
	lea	C_End,a0
	cmp.b	#$99,0(a0)
	bhs	Yes_4
	rts
Yes_4
	move.l	#Com4,d1
	move.l	d1,com
	bsr	Execute
	rts
Function_5
	lea	Copper_Bar,a0
	cmp.b	#$9a,0(a0)
	bls	Try_End_5
	rts
Try_End_5
	lea	C_End,a0
	cmp.b	#$a8,0(a0)
	bhs	Yes_5
	rts
Yes_5
	move.l	#Com5,d1
	move.l	d1,com
	bsr	Execute
	rts
Function_6
	lea	Copper_Bar,a0
	cmp.b	#$b0,0(a0)
	bls	Try_End_6
	rts
Try_End_6
	lea	C_End,a0
	cmp.b	#$be,0(a0)
	bhs	Yes_6
	rts
Yes_6
	move.l	#Com6,d1
	move.l	d1,com
	bsr	Execute
	rts
Execute
	move.l	4.w,a6			; exec base
	move.l	PlaneAdr,a1		; address
	move.l	#(256*40)*2,d0		; size of screen *2 planes
	jsr	-210(a6)
	move.l	4.w,a6			; exec base
	move.l	Gfxbase,a1
	move.l	Oldcop,50(a1)		; restore old copperlist 
	jsr	-414(a6)		; close gfx library
	move.l	4.w,a6
        jsr      -138(a6)            ; Permit Multitasking
	lea	Connam(pc),a1
	move.l	#1005,d0
	move.l	a1,d1
	move.l	d0,d2
	move.l	Dosbase,a6		; Dos address
	jsr	-30(a6)
	move.l	d0,Conhdle
	move.l	Dosbase,a6		; Dos address
	move.l	Com,d1			; Name of program
	move.l	#0,d2			; no input
	move.l	Conhdle,d3
	jsr	-222(a6)		; execute command/program
	move.l	Conhdle,d1		; close window
	move.l	Dosbase,a6		; dos address
	jsr	-36(a6)

	MOVE.L	STACK_POINTER,A7	RESTORE STACK

	movem.l	(SP)+,d0-d7/a0-a6	; re-load registers
	moveq	#0,d0			; exit
	rts

Bar
	lea	Copper_Bar,a0		; address
	move.w	#14,d1			; no of lines-1
	move.b	Value,d0
Loop_Bar
	add.b	d0,0(a0)		; add/subtract to vertical byte
	add.w	#12,a0			; increase to next line
	dbra	d1,Loop_Bar		; loop until done
	rts
	even 
Oldcop	dc.l	0
SP	dc.l	0
Gfxname	dc.b	"graphics.library",0
	even
GfxBase	dc.l	0
Dosname	dc.b	"dos.library",0
	even
DosBase	dc.l	0

STACK_POINTER	DC.L	0

Com	dc.l	0
Com1	dc.b	"1",0		; name of executable programs
Com2	dc.b	"2",0		; ""
Com3	dc.b	"3",0
Com4	dc.b	"4",0
Com5	dc.b	"5",0
Com6	dc.b	"6",0
	even
Conhdle	dc.l	0
Connam	dc.b	"CON:0/0/640/256/Now Loading Your Choice.......",0
	even
Value	dc.b	0
	even
PlaneAdr	dc.l	0
Newcop  DC.W    $008E,$2C81,$0090,$2CC1		; Pal screen
        DC.W    $0092,$0038,$0094,$00D0
 	DC.W	$0100,%0010001000000000		; 2 bitplanes
	DC.W	$0102,%0000000000000000,$0104,%0000000000000000
        DC.W    $0108,$0000,$010A,$0000
Colors
	 DC.W   $0180,$0000,$0182,$0ff0
         DC.W   $0184,$0d00,$0186,$0fff
         DC.W   $0188,$00ff,$018A,$0ff0
         DC.W   $018C,$0840,$018E,$002f

         DC.W   $0190,$0FEE,$0192,$0CAA
         DC.W   $0194,$0B77,$0196,$0955
         DC.W   $0198,$0733,$019A,$0511
         DC.W   $019C,$03f0,$019E,$010f
         DC.W   $01A0,$0FAA,$01A2,$0fff
         DC.W   $01A4,$0822,$01A6,$0400
         DC.W   $01A8,$0000,$01AA,$0000
         DC.W   $01AC,$0000,$01AE,$0000
         DC.W   $01B0,$0000,$01B2,$0000
         DC.W   $01B4,$0000,$01B6,$0000
         DC.W   $01B8,$0000,$01BA,$0000
         DC.W   $01BC,$0000,$01BE,$0000
        
         DC.W   $00E0
Bpl0h    DC.W   $0000,$00E2
Bpl0l    DC.W   $0000,$00E4
Bpl1h    DC.W   $0000,$00E6
Bpl1l    DC.W   $0000,$00E8
Bpl2h    DC.W   $0000,$00EA
Bpl2l    DC.W   $0000,$00EC
Bpl3h    DC.W   $0000,$00EE
Bpl3l    DC.W   $0000,$00F0
Bpl4h    DC.W   $0000,$00F2
Bpl4l    DC.W   $0000,$00F4
Bpl5h    DC.W   $0000,$00F6
Bpl5l    DC.W   $0000

Sprites
        DC.W	$0120
SP0H	DC.W	$0000,$0122
SP0L	DC.W	$0000,$0124
SP1H	DC.W	$0000,$0126
SP1L	DC.W	$0000,$0128
SP2H	DC.W	$0000,$012A
SP2L	DC.W	$0000,$012C
SP3H	DC.W	$0000,$012E
SP3L	DC.W	$0000,$0130
SP4H	DC.W	$0000,$0132
SP4L	DC.W	$0000,$0134
SP5H	DC.W	$0000,$0136
SP5L	DC.W	$0000,$0138
SP6H	DC.W	$0000,$013A
SP6L	DC.W	$0000,$013C
SP7H	DC.W	$0000,$013E
SP7L	DC.W	$0000

Copper_Bar
	DC.W	$2931,$FFFE,$0180,$0000,$0186,$0fff
	DC.W	$3031,$FFFE,$0180,$0300,$0186,$0f0f
	DC.W	$3131,$FFFE,$0180,$0500,$0186,$0f0f
	DC.W	$3231,$FFFE,$0180,$0700,$0186,$0f0f
	DC.W	$3331,$FFFE,$0180,$0900,$0186,$0f0f
	DC.W	$3431,$FFFE,$0180,$0B00,$0186,$0f0f
	DC.W	$3531,$FFFE,$0180,$0D00,$0186,$0f0f
	DC.W	$3631,$FFFE,$0180,$0F00,$0186,$0f0f
	DC.W	$3731,$FFFE,$0180,$0D00,$0186,$0f0f
	DC.W	$3831,$FFFE,$0180,$0B00,$0186,$0f0f
	DC.W	$3931,$FFFE,$0180,$0900,$0186,$0f0f
	DC.W	$3A31,$FFFE,$0180,$0700,$0186,$0f0f
	DC.W	$3b31,$FFFE,$0180,$0500,$0186,$0f0f
	DC.W	$3c31,$FFFE,$0180,$0300,$0186,$0f0f
C_End	DC.W	$3d31,$FFFE,$0180,$0000,$0186,$0fff
        DC.W      $FFFF,$FFFE


	even
Sprite
	dc.w    $307A,$3100,$1000,$0000,$3220,$3300,$1000,$0000
	dc.w    $34C0,$3500,$1000,$0000,$3650,$3700,$1000,$0000
	dc.w    $3842,$3900,$1000,$0000,$3A6D,$3B00,$1000,$0000
	dc.w    $3CA2,$3D00,$1000,$0000,$3E9C,$3F00,$1000,$0000
	dc.w    $40DA,$4100,$1000,$0000,$4243,$4300,$1000,$0000
	dc.w    $445A,$4500,$1000,$0000,$4615,$4700,$1000,$0000
	dc.w    $4845,$4900,$1000,$0000,$4A68,$4B00,$1000,$0000
	dc.w    $4CB8,$4D00,$1000,$0000,$4EB4,$4F00,$1000,$0000
	dc.w    $5082,$5100,$1000,$0000,$5292,$5300,$1000,$0000
	dc.w    $54D0,$5500,$1000,$0000,$56D3,$5700,$1000,$0000
	dc.w    $58F0,$5900,$1000,$0000,$5A6A,$5B00,$1000,$0000
	dc.w    $5CA5,$5D00,$1000,$0000,$5E46,$5F00,$1000,$0000
	dc.w    $606A,$6100,$1000,$0000,$62A0,$6300,$1000,$0000
	dc.w    $64D7,$6500,$1000,$0000,$667C,$6700,$1000,$0000
	dc.w    $68C4,$6900,$1000,$0000,$6AC0,$6B00,$1000,$0000
	dc.w    $6C4A,$6D00,$1000,$0000,$6EDA,$6F00,$1000,$0000
	dc.w    $70D7,$7100,$1000,$0000,$7243,$7300,$1000,$0000
	dc.w    $74A2,$7500,$1000,$0000,$7699,$7700,$1000,$0000
	dc.w    $7872,$7900,$1000,$0000,$7A77,$7B00,$1000,$0000
	dc.w    $7CC2,$7D00,$1000,$0000,$7E56,$7F00,$1000,$0000
	dc.w    $805A,$8100,$1000,$0000,$82CC,$8300,$1000,$0000
	dc.w    $848F,$8500,$1000,$0000,$8688,$8700,$1000,$0000
	dc.w    $88B9,$8900,$1000,$0000,$8AAF,$8B00,$1000,$0000
	dc.w    $8C48,$8D00,$1000,$0000,$8E68,$8F00,$1000,$0000
	dc.w    $90DF,$9100,$1000,$0000,$924F,$9300,$1000,$0000
	dc.w    $9424,$9500,$1000,$0000,$96D7,$9700,$1000,$0000
	dc.w    $9859,$9900,$1000,$0000,$9A4F,$9B00,$1000,$0000
	dc.w    $9C4A,$9D00,$1000,$0000,$9E5C,$9F00,$1000,$0000
	dc.w    $A046,$A100,$1000,$0000,$A2A6,$A300,$1000,$0000
	dc.w    $A423,$A500,$1000,$0000,$A6FA,$A700,$1000,$0000
	dc.w    $A86C,$A900,$1000,$0000,$AA44,$AB00,$1000,$0000
	dc.w    $AC88,$AD00,$1000,$0000,$AE9A,$AF00,$1000,$0000
	dc.w    $B06C,$B100,$1000,$0000,$B2D4,$B300,$1000,$0000
	dc.w    $B42A,$B500,$1000,$0000,$B636,$B700,$1000,$0000
	dc.w    $B875,$B900,$1000,$0000,$BA89,$BB00,$1000,$0000
	dc.w    $BC45,$BD00,$1000,$0000,$BE24,$BF00,$1000,$0000
	dc.w    $C0A3,$C100,$1000,$0000,$C29D,$C300,$1000,$0000		
	dc.w    $C43F,$C500,$1000,$0000,$C634,$C700,$1000,$0000		
	dc.w    $C87C,$C900,$1000,$0000,$CA1D,$CB00,$1000,$0000		
	dc.w    $CC6B,$CD00,$1000,$0000,$CEAC,$CF00,$1000,$0000		
	dc.w    $D0CF,$D100,$1000,$0000,$D2FF,$D300,$1000,$0000		
	dc.w    $D4A5,$D500,$1000,$0000,$D6D6,$D700,$1000,$0000		
	dc.w    $D8EF,$D900,$1000,$0000,$DAE1,$DB00,$1000,$0000		
	dc.w    $DCD9,$DD00,$1000,$0000,$DEA6,$DF00,$1000,$0000		
	dc.w    $E055,$E100,$1000,$0000,$E237,$E300,$1000,$0000		
	dc.w    $E47D,$E500,$1000,$0000,$E62E,$E700,$1000,$0000		
	dc.w    $E8AF,$E900,$1000,$0000,$EA46,$EB00,$1000,$0000
	dc.w	$EC65,$ED00,$1000,$0000,$EE87,$EF00,$1000,$0000
	dc.w	$F0D4,$F100,$1000,$0000,$F2F5,$F300,$1000,$0000
	dc.w	$F4FA,$F500,$1000,$0000,$F62C,$F700,$1000,$0000
	dc.w	$F84D,$F900,$1000,$0000,$FAAC,$FB00,$1000,$0000
	dc.w	$FCB2,$FD00,$1000,$0000,$FE9A,$FF00,$1000,$0000
	dc.w	$009A,$0106,$1000,$0000,$02DF,$0306,$1000,$0000
	dc.w	$0446,$0506,$1000,$0000,$0688,$0706,$1000,$0000
	dc.w	$0899,$0906,$1000,$0000,$0ADD,$0B06,$1000,$0000
	dc.w	$0CEE,$0D06,$1000,$0000,$0EFF,$0F06,$1000,$0000
	dc.w	$10CD,$1106,$1000,$0000,$1267,$1306,$1000,$0000
	dc.w	$1443,$1506,$1000,$0000,$1664,$1706,$1000,$0000
	dc.w	$1823,$1906,$1000,$0000,$1A6D,$1B06,$1000,$0000
	dc.w	$1C4F,$1D06,$1000,$0000,$1E5F,$1F06,$1000,$0000
	dc.w	$2055,$2106,$1000,$0000,$2267,$2306,$1000,$0000
	dc.w	$2445,$2506,$1000,$0000,$2623,$2706,$1000,$0000
	dc.w	$2834,$2906,$1000,$0000,$2AF0,$2B06,$1000,$0000
	dc.w	$2CBC,$2D06,$1000,$0000
SpriteE	dc.w 	$0000,$0000
	Even
Screen	incbin	 "source:bitmaps/menu.raw_3"
	End
