
         SECTION pink_floyd,CODE_C          ; Chip memory please

         OPT C-          ?                  ; No case restriction
Number	=	32-1
******************************************************************************
*   MAIN EXECUTE CODE
******************************************************************************

RM:      MOVEM.L   D0-D7/A0-A6,-(SP)        ; Save registers
         MOVE.L    SP,STAKPTR               ; Save stackpointer
         BSR       SLAY_OS                  ; Bye-bye AMIGADOS
         BSR       ERECT                    ; Get it up
         BSR       DOIT                     ; Have a good time
         BSR       REST_OS                  ; Hello AMIGADOS
         MOVE.L    STAKPTR,SP               ; Restore stackpointer
         MOVEM.L   (SP)+,D0-D7/A0-A6        ; Restore registers
         RTS                                ; See ya next time !!

******************************************************************************
*   SLAY_OS
******************************************************************************

SLAY_OS: MOVEQ.L   #0,D0                    ; Any version
         LEA       GFXNAM(PC),A1
         MOVE.L    4,A6
         JSR       -132(A6)                 ; Forbid Multitasking
         JSR       -552(A6)                 ; Open GFX library
         MOVE.L    D0,GFXBSE
         MOVE.L    D0,A0       
         MOVE.L    38(A0),SYSCOP            ; Store System Copperlist
         MOVE.W    $DFF01C,SYSINT           ; Store Interrupt Enable
         MOVE.W    #$7FFF,$DFF09A           ; Clear Interrupts
         MOVE.L    $6C,SAVLEV3              ; Store VB Interrupt
         MOVE.W    $DFF002,SYSDMA           ; Store DMA Controller
         MOVE.W    #$7FFF,$DFF096           ; Clear DMA
         MOVE.W    #$87C0,$DFF096           ; Enable DMA Channels
         RTS

******************************************************************************
*   REST_OS
******************************************************************************

REST_OS: MOVE.L    #$7FFF,$DFF09A           ; Clear Interrupts
         MOVE.L    SAVLEV3,$6C              ; Restore VB Interrupt
         MOVE.W    SYSINT,D0
         OR        #$C000,D0
         MOVE.W    D0,$DFF09A               ; Restore Interrupt Enable
         MOVE.W    #$7FFF,$DFF096           ; Clear DMA
         MOVE.W    SYSDMA,D0
         OR        #$8200,D0
         MOVE.W    D0,$DFF096               ; Restore DMA
         MOVE.L    SYSCOP,$DFF080           ; Restore System Copperlist
         CLR.L     $DFF088                  ; Start Copperlist
         MOVE.L    4,A6
         JSR       -138(A6)                 ; Permit Multitasking
         RTS

******************************************************************************
*   ERECT
******************************************************************************
ERECT:
	
	lea  	LOGO,a0
	lea	col,a1
	move.l	#Number,d4
loop:	move.w	(a0)+,(a1)+
	add.w	#2,a1
	dbra	d4,loop
	move.l	a0,d0
	  
         MOVE.W    D0,PL1L
         SWAP      D0
         MOVE.W    D0,PL1H
         SWAP      D0
        add.l	#91*40,D0
         MOVE.W    D0,PL2L
         SWAP      D0
         MOVE.W    D0,PL2H
         SWAP      D0
        add.l	#91*40,D0
         MOVE.W    D0,PL3L
         SWAP      D0
         MOVE.W    D0,PL3H
	SWAP	D0
        add.l	#91*40,D0
         MOVE.W    D0,PL4L
         SWAP      D0
         MOVE.W    D0,PL4H
         SWAP      D0
         add.l	#91*40,D0
         MOVE.W    D0,PL5L
         SWAP      D0
         MOVE.W    D0,PL5H
         SWAP      D0
         MOVE.L    #SCPLNE,D0               ; Define scroll plane
         MOVE.W    D0,SP1L
         SWAP      D0
         MOVE.W    D0,SP1H
         MOVE.L    #NEWCOP,$DFF080          ; Run new Copperlist
         CLR.L     $DFF088
         JSR       ST_INIT                  ; Define music
         RTS

******************************************************************************
*   DOIT
******************************************************************************

DOIT:    CMPI.B    #$F0,$DFF006             ; Wait for Verticle Blank 
         BNE       DOIT
         BSR       ST_MUSIC
         BSR       SCROLLY 
         move.w	st_aud3temp,d0
         move.w	d0,flash
         move.w	st_aud3temp,d0
         move.b	d0,flash2
         move.w	st_aud4temp,d0
         move.w	d0,flash3
         move.w	st_aud1temp,d0
         move.w	d0,flash4
         move.w	st_aud2temp,d0
         move.b	d0,flash5
         
         BTST      #6,$BFE001               ; Is LMB pressed ?
         BNE       DOIT               
         BSR       ST_END                   ; Stop music
         RTS

******************************************************************************
*   SCROLL
******************************************************************************

SCROLLY:	move.b	#0,vbcount
	 move.l    #SCPLNE+40,src
         move.l    #SCPLNE,dst
         BTST      #10,$DFF016              ; Is RMB pressed ?
         Bne       mark                     ; Ok, no scroll
         sub.w     #1,COUNT
         move.l    #SCPLNE,src
mark     ADD.W     #1,COUNT                 ; Increase text count
         CMP.W     #12,COUNT                ; Is it 12
         BNE       SCROLL                   ; Scroll text up
         MOVE.W    #0,COUNT
PL1:     MOVE.L    TEXTPTR,A0
         CMP.B     #0,(A0)                  ; Is it at an end
         BNE       LINEOK                   ; No, display line
         MOVE.L    #TEXT,TEXTPTR            ; Reset text pointer
         BRA       PL1
LINEOK:  LEA       WHERE,A1                 ; Get destination
         MOVEQ     #39,D1                   ; Number of characters
LP1:     MOVEQ     #0,D0
         MOVE.B    (A0)+,D0
         SUB.B     #32,D0                   ; Find value
         MULU      #8,D0                    ; Calculate offset
         LEA       CHARS(PC),A2
         ADD.L     D0,A2                    ; Calculate font position
         MOVEQ     #7,D2                    ; Font is 8 bytes
         MOVE.L    A1,A3
LP2:     MOVE.B    (A2)+,(A3)               ; Store byte in destination
         ADD.L     #40,A3                   ; Next line
         DBRA      D2,LP2                   ; Finish character
         ADDQ.L    #1,A1                    ; Next letter
         DBRA      D1,LP1                   ; Finish line
         MOVE.L    A0,TEXTPTR               ; Store new pointer
SCROLL:  BTST      #14,$DFF002              ; Wait for Blitter
         BNE       SCROLL
         MOVE.L    src,$DFF050       ; Destination
         MOVE.L    #SCPLNE,$DFF054          ; Source
         CLR.L     $DFF064
         MOVE.W    #-1,$DFF044
         MOVE.W    #$9F0,$DFF040            ; Sort of blit
         CLR.L     $DFF042
         MOVE.W    #20+64*198,$DFF058       ; Size to blit
END:     RTS

******************************************************************************
*   NEW COPPERLIST
******************************************************************************

NEWCOP:dc.w	$0001,$fffe
	  DC.W      $008E,$2C81
         DC.W      $0090,$2CC1
         DC.W      $0092,$0038
         DC.W      $0094,$00D0
         DC.W      $0108,$0000,$010A,$0000
        dc.w       $180

col:	DC.W	$0,$182,$0,$184,$0,$186,$0,$188,$0,$18A,$0,$18C,$0,$18E,$0
	DC.W	$190,$0,$192,$0,$194,$0,$196,$0,$198,$0,$19A,$0,$19C,$0,$19E,$0
	DC.W	$1A0,$0,$1A2,$0,$1A4,$0,$1A6,$0,$1A8,$0,$1AA,$0,$1AC,$0,$1AE,$0
	DC.W	$1B0,$0,$1B2,$0,$1B4,$0,$1B6,$0,$1B8,$0,$1BA,$0,$1BC,$0,$1BE,$0
        dc.w       $0100,$5200
        dc.w       $194
flash	dc.w	$0000
	dc.w	$196
flash2	dc.w	$0000

          dc.w      $190
flash3	dc.w	$0000
	dc.w	$192
flash4	dc.w	$0000
	dc.w	$19a
flash5	dc.w	$0000	

         DC.W      $00E0
PL1H:    DC.W      $0000,$00E2
PL1L:    DC.W      $0000,$00E4   
PL2H:    DC.W      $0000,$00E6
PL2L:    DC.W      $0000,$00E8
PL3H:    DC.W      $0000,$00EA
PL3L:    DC.W      $0000,$00EC
PL4H:    DC.W      $0000,$00EE
PL4L:    DC.W      $0000,$00f0
PL5H:    DC.W      $0000,$00f2
PL5L:    DC.W      $0000
         dc.w	$8601,$fffe
         dc.w	$180,$0
         DC.W      $00E0
SP1H:    DC.W      $0000,$00E2
SP1L:    DC.W      $0000
         DC.W      $5A09,$FFFE,$0100,$1200
         
         DC.W      $6C09,$FFFE,$0182,$0000
         DC.W      $8E09,$FFFE,$0182,$0111
         DC.W      $9009,$FFFE,$0182,$0222
         DC.W      $9209,$FFFE,$0182,$0333
         DC.W      $9409,$FFFE,$0182,$0444
         DC.W      $9609,$FFFE,$0182,$0555
         DC.W      $9809,$FFFE,$0182,$0666
         DC.W      $9A09,$FFFE,$0182,$0777
         DC.W      $9C09,$FFFE,$0182,$0888
         DC.W      $9E09,$FFFE,$0182,$0999
         DC.W      $a009,$FFFE,$0182,$0AAA
         DC.W      $a209,$FFFE,$0182,$0BBB
         DC.W      $a409,$FFFE,$0182,$0CCC
         DC.W      $a609,$FFFE,$0182,$0DDD
         DC.W      $a809,$FFFE,$0182,$0EEE
         	
         	
         ;DC.W      $EA09,$FFFE,$0182,$0eee
         ;DC.W      $EC09,$FFFE,$0182,$0ddd
         ;DC.W      $EE09,$FFFE,$0182,$0ccc
         ;DC.W      $F009,$FFFE,$0182,$0bbb
         DC.W      $F209,$FFFE,$0182,$0eee
         DC.W      $F409,$FFFE,$0182,$0ddd
         DC.W      $F609,$FFFE,$0182,$0ccc
         DC.W      $F809,$FFFE,$0182,$0bbb
         DC.W      $FA09,$FFFE,$0182,$0aaa
         DC.W      $FC09,$FFFE,$0182,$0999
         DC.W      $FE09,$FFFE,$0182,$0888
         DC.W      $FF99,$FFFE,$ffdd,$FFFE  ; PAL Enable
         DC.W      $0209,$FFFE,$0182,$0777
         DC.W      $0409,$FFFE,$0182,$0666
         DC.W      $0609,$FFFE,$0182,$0555
        ; DC.W      $0809,$FFFE,$0182,$0000
       	dc.w	$0a09,$fffe,$108,-39,$10a,-39,$182,$0555
         
        
         DC.W      $FFFF,$FFFE

******************************************************************************
*   CHARACTER SET DATA
******************************************************************************

CHARS:	

	dc.b	$00,$00,$00,$00,$00,$00,$00,$00	; Space
	dc.b	$00,$10,$10,$10,$10,$00,$10,$00	; !
	dc.b	$00,$24,$24,$00,$00,$00,$00,$00	; "
	dc.b	$00,$24,$7e,$24,$24,$7e,$24,$00	; #
	dc.b	$00,$08,$3e,$28,$3e,$0a,$3e,$08	; $
	dc.b	$00,$62,$64,$08,$10,$26,$46,$00	; %
	dc.b	$00,$10,$28,$10,$2a,$44,$3a,$00	; &
	dc.b	$00,$08,$10,$00,$00,$00,$00,$00	; '
	dc.b	$04,$08,$08,$08,$08,$08,$04,$00	; (
	dc.b	$00,$20,$10,$10,$10,$10,$20,$00	; )
	dc.b	$00,$00,$14,$08,$3e,$08,$14,$00	; *
	dc.b	$00,$00,$08,$08,$3e,$08,$08,$00	; +
	dc.b	$00,$00,$00,$00,$00,$08,$08,$10	; ,
	dc.b	$00,$00,$00,$00,$3e,$00,$00,$00	; -
	dc.b	$00,$00,$00,$00,$00,$18,$18,$00	; .
	dc.b	$00,$00,$02,$04,$08,$10,$20,$00	; /
	dc.b	$00,$3c,$46,$4a,$52,$62,$3c,$00	; 0
	dc.b	$00,$18,$28,$08,$08,$08,$3e,$00	; 1
	dc.b	$00,$3c,$42,$02,$3c,$40,$7e,$00	; 2
	dc.b	$00,$3c,$42,$0c,$02,$42,$3c,$00	; 3
	dc.b	$00,$08,$18,$28,$48,$7e,$08,$00	; 4
	dc.b	$00,$7e,$40,$7c,$02,$42,$3c,$00	; 5
	dc.b	$00,$3c,$40,$7c,$42,$42,$3c,$00	; 6
	dc.b	$00,$7e,$02,$04,$08,$10,$10,$00	; 7
	dc.b	$00,$3c,$42,$3c,$42,$42,$3c,$00	; 8
	dc.b	$00,$3c,$42,$42,$3e,$02,$3c,$00	; 9
	dc.b	$00,$00,$10,$00,$00,$00,$10,$00	; :
	dc.b	$00,$00,$10,$00,$00,$10,$10,$20	; ;
	dc.b	$00,$00,$04,$08,$10,$08,$04,$00	; <
	dc.b	$00,$00,$00,$3e,$00,$3e,$00,$00	; =
	dc.b	$00,$00,$10,$08,$04,$08,$10,$00	; >
	dc.b	$00,$3c,$42,$04,$08,$00,$08,$00	; ?
	dc.b	$00,$3c,$4a,$56,$5e,$40,$3c,$00	; @
	dc.b	$00,$3c,$42,$42,$7e,$42,$42,$00	; A
	dc.b	$00,$7c,$42,$7c,$42,$42,$7c,$00	; B
	dc.b	$00,$3c,$42,$40,$40,$42,$3c,$00	; C
	dc.b	$00,$78,$44,$42,$42,$44,$78,$00	; D
	dc.b	$00,$7e,$40,$7c,$40,$40,$7e,$00	; E
	dc.b	$00,$7e,$40,$7c,$40,$40,$40,$00	; F
	dc.b	$00,$3c,$42,$40,$4e,$42,$3c,$00	; G
	dc.b	$00,$42,$42,$7e,$42,$42,$42,$00	; H
	dc.b	$00,$3e,$08,$08,$08,$08,$3e,$00	; I
	dc.b	$00,$02,$02,$02,$42,$42,$3c,$00	; J
	dc.b	$00,$44,$48,$70,$48,$44,$42,$00	; K
	dc.b	$00,$40,$40,$40,$40,$40,$7e,$00	; L
	dc.b	$00,$42,$66,$5a,$42,$42,$42,$00	; M
	dc.b	$00,$42,$62,$52,$4a,$46,$42,$00	; N
	dc.b	$00,$3c,$42,$42,$42,$42,$3c,$00	; O
	dc.b	$00,$7c,$42,$42,$7c,$40,$40,$00	; P
	dc.b	$00,$3c,$42,$42,$52,$4a,$3c,$00	; Q
	dc.b	$00,$7c,$42,$42,$7c,$44,$42,$00	; R
	dc.b	$00,$3c,$40,$3c,$02,$42,$3c,$00	; S
	dc.b	$00,$fe,$10,$10,$10,$10,$10,$00	; T
	dc.b	$00,$42,$42,$42,$42,$42,$3c,$00	; U
	dc.b	$00,$42,$42,$42,$42,$24,$18,$00	; V
	dc.b	$00,$42,$42,$42,$42,$5a,$24,$00	; W
	dc.b	$00,$42,$24,$18,$18,$24,$42,$00	; X
	dc.b	$00,$82,$44,$28,$10,$10,$10,$00	; Y
	dc.b	$00,$7e,$04,$08,$10,$20,$7e,$00	; Z
	dc.b	$00,$0e,$08,$08,$08,$08,$0e,$00	; [
	dc.b	$00,$00,$40,$20,$10,$08,$04,$00	; \
	dc.b	$00,$70,$10,$10,$10,$10,$70,$00	; ]
	dc.b	$00,$10,$38,$54,$10,$10,$10,$00	; ^
	dc.b	$00,$00,$00,$00,$00,$00,$00,$ff	; _
	dc.b	$00,$1c,$22,$78,$20,$20,$7e,$00	; 
	dc.b	$00,$00,$38,$04,$3c,$44,$3c,$00	; a
	dc.b	$00,$20,$20,$3c,$22,$22,$3c,$00	; b
	dc.b	$00,$00,$1c,$20,$20,$20,$1c,$00	; c
	dc.b	$00,$04,$04,$3c,$44,$44,$3c,$00	; d
	dc.b	$00,$00,$38,$44,$78,$40,$3c,$00	; e
	dc.b	$00,$0c,$10,$18,$10,$10,$10,$00	; f
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$38	; g
	dc.b	$00,$40,$40,$78,$44,$44,$44,$00	; h
	dc.b	$00,$10,$00,$30,$10,$10,$38,$00	; i
	dc.b	$00,$04,$00,$04,$04,$04,$24,$18	; j
	dc.b	$00,$20,$28,$30,$30,$28,$24,$00	; k
	dc.b	$00,$10,$10,$10,$10,$10,$0c,$00	; l
	dc.b	$00,$00,$68,$54,$54,$54,$54,$00	; m
	dc.b	$00,$00,$78,$44,$44,$44,$44,$00	; n
	dc.b	$00,$00,$38,$44,$44,$44,$38,$00	; o
	dc.b	$00,$00,$78,$44,$44,$78,$40,$40	; p
	dc.b	$00,$00,$3c,$44,$44,$3c,$04,$06	; q
	dc.b	$00,$00,$1c,$20,$20,$20,$20,$00	; r
	dc.b	$00,$00,$38,$40,$38,$04,$78,$00	; s
	dc.b	$00,$10,$38,$10,$10,$10,$0c,$00	; t
	dc.b	$00,$00,$44,$44,$44,$44,$38,$00	; u
	dc.b	$00,$00,$44,$44,$28,$28,$10,$00	; v
	dc.b	$00,$00,$44,$54,$54,$54,$28,$00	; w
	dc.b	$00,$00,$44,$28,$10,$28,$44,$00	; x
	dc.b	$00,$00,$44,$44,$44,$3c,$04,$38	; y
	dc.b	$00,$00,$7c,$08,$10,$20,$7c,$00	; z
	dc.b	$00,$0e,$08,$30,$08,$08,$0e,$00	; {
	dc.b	$00,$08,$08,$08,$08,$08,$08,$00	; |
	dc.b	$00,$70,$10,$0c,$10,$10,$70,$00	; }
	dc.b	$00,$14,$28,$00,$00,$00,$00,$00	; ~		
		



******************************************************************************
*   TEXT MESSAGE
******************************************************************************

*                             1         2         3        0
*                  *1234567890123456789012345678901234567894*

TEXT:   
	DC.B      "         D I S O R G A N I Z E D        "
	DC.B      "                                        "
         DC.B      "                C R I M E               "
         DC.B      "                                        "
         DC.B      "                   O F                  "
         DC.B      "                                        "
         DC.B      "          C U M B R I A   U . K         "
         DC.B      "                                        "
         DC.B      "                 PRESENT                "
         DC.B      "                                        "
         DC.B      "                   YET                  "
         DC.B      "                                        "
         DC.B      "                 ANOTHER                "
         DC.B      "                                        "
         DC.B      "         C O M P A C T - D I S K        "
         DC.B      "                                        "
         DC.B      "                                        "
         DC.B      "   *********************************    "
         DC.B      "                                        "
         DC.B      "                                        "
         DC.B      "   ADDITIONAL CODE, GRAPHIX AND MUZIK   "
         DC.B      "                                        "
         DC.B      "                   BY                   "
         DC.B      "                                        "
         DC.B      "             M E G A B A S S            "
         DC.B      "                                        "
         DC.B      "     ( ORIGINAL MUZIK BY KRAFTWERK )    "
         DC.B      "                                        "
         DC.B      "   *********************************    "
         DC.B      "                                        "
         DC.B      0



******************************************************************************
*   VARIABLE STORE
******************************************************************************

STAKPTR: DC.L      $0000
GFXNAM:  DC.B      "graphics.library",0
         EVEN
src      dc.l      $0000
dst      dc.l      $0000
GFXBSE:  DC.L      $0000
SYSCOP:  DC.L      $0000
SYSINT:  DC.W      $0000
SAVLEV3: DC.L      $0000
SYSDMA:  DC.W      $0000
COUNT:   DC.W      $0000
COUNT2:  DC.W      $0000
         EVEN
LOGO:    INCBIN    "workdisk:bitmaps/4-bp-2.raw"
         EVEN
TEXTPTR: DC.L      TEXT
BLANK:   DCB.B     40*10,0
SCPLNE:  DCB.B     40*190,0
WHERE:   DCB.B     40*10,0
vbcount	dc.b	0

******************************************************************************
*   MUSIC PLAYER ROUTINE
******************************************************************************
		
ST_init: lea	Module,a0		* Initialise Music
	 add.l	#$03b8,a0
	 moveq	#$7f,d0
	 moveq	#0,d1
ST_init1 
	move.l	d1,d2
	subq.w	#1,d0
ST_init2 
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	ST_init1
	dbf	d0,ST_init2
	addq.b	#1,d2

ST_init3 
	lea	Module,a0
	lea	ST_sample1(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$438,d2
	add.l	a0,d2
	moveq	#$1e,d0
ST_init4 
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,ST_init4

	lea	ST_sample1(PC),a0
	moveq	#0,d0
ST_clear 
	move.l	(a0,d0.w),a1
	clr.l	(a1)
	addq.w	#4,d0
	cmp.w	#$7c,d0
	bne.s	ST_clear

	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	ST_partnrplay
	clr.l	ST_partnote
	clr.l	ST_partpoint

	move.b	Module+$3b6,ST_maxpart+1
	rts

* call 'ST_end' to switch the sound off

ST_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

* the playroutine - call this every frame

ST_music 
	addq.w	#1,ST_counter
ST_cool cmp.w	#6,ST_counter
	bne.s	ST_notsix
	clr.w	ST_counter
	bra	ST_rout2

ST_notsix 
	lea	ST_aud1temp(PC),a6
	tst.b	3(a6)
	beq.s	ST_arp1
	lea	$dff0a0,a5		
	bsr.s	ST_arprout
ST_arp1 lea	ST_aud2temp(PC),a6
	tst.b	3(a6)
	beq.s	ST_arp2
	lea	$dff0b0,a5
	bsr.s	ST_arprout
ST_arp2 lea	ST_aud3temp(PC),a6
	tst.b	3(a6)
	beq.s	ST_arp3
	lea	$dff0c0,a5
	bsr.s	ST_arprout
ST_arp3 lea	ST_aud4temp(PC),a6
	tst.b	3(a6)
	beq.s	ST_arp4
	lea	$dff0d0,a5
	bra.s	ST_arprout
ST_arp4 rts

ST_arprout 
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq	ST_arpegrt
	cmp.b	#$01,d0
	beq.s	ST_portup
	cmp.b	#$02,d0
	beq.s	ST_portdwn
	cmp.b	#$0a,d0
	beq.s	ST_volslide
	rts

ST_portup 
	moveq	#0,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	ST_ok1
	move.w	#$71,22(a6)
ST_ok1 	move.w	22(a6),6(a5)
	rts

ST_portdwn 
	moveq	#0,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$538,22(a6)
	bmi.s	ST_ok2
	move.w	#$538,22(a6)
ST_ok2 	move.w	22(a6),6(a5)
	rts

ST_volslide 
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	ST_voldwn
	add.w	d0,18(a6)
	cmp.w	#64,18(a6)
	bmi.s	ST_ok3
	move.w	#64,18(a6)
ST_ok3 	move.w	18(a6),8(a5)
	rts
ST_voldwn 
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	sub.w	d0,18(a6)
	bpl.s	ST_ok4
	clr.w	18(a6)
ST_ok4 	move.w	18(a6),8(a5)
	rts

ST_arpegrt 
	move.w	ST_counter(PC),d0
	cmp.w	#1,d0
	beq.s	ST_loop2
	cmp.w	#2,d0
	beq.s	ST_loop3
	cmp.w	#3,d0
	beq.s	ST_loop4
	cmp.w	#4,d0
	beq.s	ST_loop2
	cmp.w	#5,d0
	beq.s	ST_loop3
	rts

ST_loop2 
	moveq	#0,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	ST_cont
ST_loop3 
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	ST_cont
ST_loop4 
	move.w	16(a6),d2
	bra.s	ST_endpart
ST_cont 
	add.w	d0,d0
	moveq	#0,d1
	move.w	16(a6),d1
	and.w	#$fff,d1
	lea	ST_arpeggio(PC),a0
ST_loop5 
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	ST_endpart
	addq.l	#2,a0
	bra.s	ST_loop5
ST_endpart 
	move.w	d2,6(a5)
	rts

ST_rout2 
	lea	Module,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$3b8,a2
	add.l	#$43c,a0
	move.l	ST_partnrplay(PC),d0
	moveq	#0,d1
	move.b	(a2,d0),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.l	ST_partnote(PC),d1
	move.l	d1,ST_partpoint
	clr.w	ST_dmacon

	lea	$dff0a0,a5
	lea	ST_aud1temp(PC),a6
	bsr	ST_playit
	lea	$dff0b0,a5
	lea	ST_aud2temp(PC),a6
	bsr	ST_playit
	lea	$dff0c0,a5
	lea	ST_aud3temp(PC),a6
	bsr	ST_playit
	lea	$dff0d0,a5
	lea	ST_aud4temp(PC),a6
	bsr	ST_playit
	move.w	#$01f4,d0
ST_rls 	dbf	d0,ST_rls

	move.w	#$8000,d0
	or.w	ST_dmacon,d0
	move.w	d0,$dff096

	lea	ST_aud4temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	ST_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
ST_voice3 
	lea	ST_aud3temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	ST_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
ST_voice2 
	lea	ST_aud2temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	ST_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
ST_voice1 
	lea	ST_aud1temp(PC),a6
	cmp.w	#1,14(a6)
	bne.s	ST_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
ST_voice0 
	move.l	ST_partnote(PC),d0
	add.l	#$10,d0
	move.l	d0,ST_partnote
	cmp.l	#$400,d0
	bne.s	ST_stop
ST_higher 
	clr.l	ST_partnote
	addq.l	#1,ST_partnrplay
	moveq	#0,d0
	move.w	ST_maxpart(PC),d0
	move.l	ST_partnrplay(PC),d1
	cmp.l	d0,d1
	bne.s	ST_stop
	clr.l	ST_partnrplay
	
ST_stop tst.w	ST_status
	beq.s	ST_stop2
	clr.w	ST_status
	bra.s	ST_higher
ST_stop2 
	rts

ST_playit 
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2

	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	ST_nosamplechange

	moveq	#0,d3
	lea	ST_samples(PC),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4.l),8(a6)
	move.w	2(a3,d4.l),18(a6)
	move.w	4(a3,d4.l),d3
	tst.w	d3
	beq.s	ST_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),8(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
	bra.s	ST_nosamplechange

ST_displace 
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4.l),14(a6)
	move.w	18(a6),8(a5)
ST_nosamplechange 
	move.w	(a6),d0
	and.w	#$fff,d0
	tst.w	d0
	beq.s	ST_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),d0
	and.w	#$fff,d0
	move.w	d0,6(a5)
	move.w	20(a6),d0
	or.w	d0,ST_dmacon

ST_retrout 
	tst.w	(a6)
	beq.s	ST_nonewper
	move.w	(a6),22(a6)

ST_nonewper 
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$0b,d0
	beq.s	ST_posjmp
	cmp.b	#$0c,d0
	beq.s	ST_setvol
	cmp.b	#$0d,d0
	beq.s	ST_break
	cmp.b	#$0e,d0
	beq.s	ST_setfil
	cmp.b	#$0f,d0
	beq.s	ST_setspeed
	rts

ST_posjmp 
	not.w	ST_status
	moveq	#0,d0
	move.b	3(a6),d0
	subq.b	#1,d0
	move.l	d0,ST_partnrplay
	rts

ST_setvol 
	move.b	3(a6),8(a5)
	rts

ST_break 
	not.w	ST_status
	rts

ST_setfil 
	moveq	#0,d0
	move.b	3(a6),d0
	and.b	#1,d0
	rol.b	#1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

ST_setspeed 
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	ST_back
	clr.w	ST_counter
	move.b	d0,ST_cool+3
ST_back rts

ST_aud1temp 
	dcb.w	10,0
	dc.w	1
	dcb.w	2,0
ST_aud2temp 
	dcb.w	10,0
	dc.w	2
	dcb.w	2,0
ST_aud3temp 
	dcb.w	10,0
	dc.w	4
	dcb.w	2,0
ST_aud4temp 
	dcb.w	10,0
	dc.w	8
	dcb.w	2,0

ST_partnote 	dc.l	0
ST_partnrplay 	dc.l	0
ST_counter 	dc.w	0
ST_partpoint 	dc.l	0
ST_samples 	dc.l	0
ST_sample1 	dcb.l	31,0
ST_maxpart 	dc.w	0
ST_dmacon 	dc.w	0
ST_status 	dc.w	0

ST_arpeggio 
	dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000

Module 	incbin	"workdisk:modules/mod.music"

******************************************************************************
*   END OF SOURCE
******************************************************************************


