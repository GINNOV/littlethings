***
***      EQUALISER-NT-2.S
***      BY MARK FLEMANS
***      DATE 28.01.92
***

         SECTION kerry_atherton,CODE   ; FAST MEMORY IF POSSIBLE
         OPT C-

MAIN:    MOVEM.L A0-A6/D0-D7,-(SP)     ; SAVE REGISTERS
         MOVE.L  $4,A6                 ; GET EXEC-BASE
         JSR     -132(A6)              ; FORBID MULTITASKING

         MOVE.L  $4,A6                 ; GET EXEC-BASE
         MOVEQ   #$0,D0                ; ANY VERSION
         LEA     GFXNAM,A1             ; LIBRARY NAME
         JSR     -552(A6)              ; OPEN LIBRARY
         TST.L   D0                    ; TEST FOR ERRORS
         BEQ     OUT                   ; IF ERROR THEN EXIT
         MOVE.L  D0,GFXBSE             ; SAVE LIBRARY ADDRESS

         MOVE.W  #$0020,$DFF096        ; SPRITES OFF
         MOVE.L  GFXBSE,A0
         MOVE.L  $32(A0),OLDCLIST      ; SAVE OLD COPPERLIST
         MOVE.L  #CLIST,$32(A0)        ; INSERT NEW COPPERLIST

         MOVE.L  $6C,OLDINT            ; SAVE OLD LEVEL 3 IRQ
         MOVE.L  #NEWINT,$6C           ; INSERT NEW IRQ
         JSR     MT_INIT

.LOOP    BTST    #6,$BFE001            ; TEST FOR LEFT MOUSE BUTTON
         BNE     .LOOP                 ; IF NOT PRESSED THEN REPEAT

         JSR     MT_END
         MOVE.L  OLDINT,$6C            ; INSERT OLD IRQ

         MOVE.L  GFXBSE,A0
         MOVE.L  OLDCLIST,$32(A0)      ; RELOAD OLD COPPERLIST
         MOVE.W  #$8020,$DFF096        ; SPRITES ON

         MOVE.L  $4,A6                 ; GET EXEC-BASE
         MOVE.L  GFXBSE,A1             ; LIBRARY ADDRESS
         JSR     -414(A6)              ; CLOSE LIBRARY

         MOVE.L  $4,A6                 ; GET EXEC-BASE
         JSR     -138(A6)              ; PERMIT MULTITASKING

END:     MOVEM.L (SP)+,A0-A6/D0-D7     ; RELOAD REGISTERS
         MOVEQ   #$0,D0                ; NO CLI ERRORS
OUT:     RTS                           ; BYE

***

NEWINT:  MOVEM.L D0-D7/A0-A6,-(SP)
 	 JSR     MT_MUSIC
         BSR     MT_EQU
         MOVEM.L (SP)+,D0-D7/A0-A6
         DC.W    $4EF9
OLDINT:  DC.L    0

**

MT_EQU: MOVE.B  V1DAT,D0
        TST.B   D0                     ; TEST VOICE1 TIMER
        BNE     TT2                    ; OK, MISS IF NOT TIME
        MOVE.W  MT_VOICE1,D0
        TST.W   D0                     ; ARE WE TALKING ?
        BEQ     TEST2                  ; NO, OK NEXT VOICE
        MOVE.W  #$0800,BAR1A+6
        MOVE.W  #$0F00,BAR1B+6
        MOVE.W  #$0800,BAR1C+6         ; PUMP UP BAR1
        MOVE.B  #$7,V1DAT              ; RESET VOICE1 TIMER
TT2:    SUB.B   #1,V1DAT
TEST2:  MOVE.B  V2DAT,D0
        TST.B   D0                     ; TEST VOICE2 TIMER
        BNE     TT3                    ; OK, MISS IF NOT TIME
        MOVE.W  MT_VOICE2,D0
        TST.W   D0                     ; ARE WE TALKING ?
        BEQ     TEST3
        MOVE.W  #$0800,BAR2A+6
        MOVE.W  #$0F00,BAR2B+6
        MOVE.W  #$0800,BAR2C+6         ; PUMP UP BAR2
        MOVE.B  #$7,V2DAT              ; RESET VOICE2 TIMER
TT3:    SUB.B   #1,V2DAT
TEST3:  MOVE.B  V3DAT,D0
        TST.B   D0                     ; TEST VOICE3 TIMER
        BNE     TT4                    ; OK, MISS IF NOT TIME
        MOVE.W  MT_VOICE3,D0
        TST.W   D0                     ; ARE WE TALKING ?
        BEQ     TEST4
        MOVE.W  #$0800,BAR3A+6
        MOVE.W  #$0F00,BAR3B+6
        MOVE.W  #$0800,BAR3C+6         ; PUMP UP BAR3
        MOVE.B  #$7,V3DAT
TT4:    SUB.B   #1,V3DAT
TEST4:  MOVE.B  V4DAT,D0
        TST.B   D0                     ; TEST VOICE4 TIMER
        BNE     TT5                    ; OK, MIS IF NOT TIME
        MOVE.W  MT_VOICE4,D0
        TST.W   D0                     ; ARE WE TALKING ?
        BEQ     FADE1
        MOVE.W  #$0800,BAR4A+6
        MOVE.W  #$0F00,BAR4B+6
        MOVE.W  #$0800,BAR4C+6         ; PUMP UP BAR4
        MOVE.B  #$7,V4DAT
TT5:    SUB.B   #1,V4DAT
FADE1:  CMP.W   #$0,BAR1B+6            ; AM A FLAT ?
        BEQ     FADE1A                 ; YES, OK NEXT BITS
        SUB.W   #$0100,BAR1B+6
FADE1A: CMP.W   #$0,BAR1A+6            ; ARE WE FLAT ?
        BEQ     FADE2                  ; YES, OK NEXT BAR
        SUB.W   #$0100,BAR1A+6
        SUB.W   #$0100,BAR1C+6
FADE2:  CMP.W   #$0,BAR2B+6
        BEQ     FADE2A
        SUB.W   #$0100,BAR2B+6
FADE2A: CMP.W   #$0,BAR2A+6
        BEQ     FADE3
        SUB.W   #$0100,BAR2A+6
        SUB.W   #$0100,BAR2C+6
FADE3:  CMP.W   #$0,BAR3B+6
        BEQ     FADE3A
        SUB.W   #$0100,BAR3B+6
FADE3A: CMP.W   #$0,BAR3A+6
        BEQ     FADE4
        SUB.W   #$0100,BAR3A+6
        SUB.W   #$0100,BAR3C+6
FADE4:  CMP.W   #$0,BAR4B+6
        BEQ     FADE4A
        SUB.W   #$0100,BAR4B+6
FADE4A: CMP.W   #$0,BAR4A+6
        BEQ     EQUOUT
        SUB.W   #$0100,BAR4A+6
        SUB.W   #$0100,BAR4C+6
EQUOUT: RTS

**

OLDCLIST:DC.L    0
MEMADDR: DC.L    0
GFXBSE:  DC.L    0
GFXNAM:  DC.B    "graphics.library",0
V1DAT:   DC.B    0
V2DAT:   DC.B    0
V3DAT:   DC.B    0
V4DAT:   DC.B    0

         SECTION chip,CODE_C

CLIST:   DC.W    $008E,$2C81,$0090,$2CC1
         DC.W    $0092,$0038,$0094,$00D0
         DC.W    $0108,$0000,$010A,$0000
         DC.W    $0100,$0000,$0182,$0000
         DC.W    $0201,$FFFE,$0180,$0000
         DC.W    $6001,$FFFE,$0180,$0000
         DC.W    $0182,$0000,$0184,$0000
BAR1A    DC.W    $7109,$FFFE,$0180,$0000
BAR1B:   DC.W    $7209,$FFFE,$0180,$0000
BAR1C:   DC.W    $7309,$FFFE,$0180,$0000
         DC.W    $7409,$FFFE,$0180,$0000
BAR2A:   DC.W    $8109,$FFFE,$0180,$0000
BAR2B:   DC.W    $8209,$FFFE,$0180,$0000
BAR2C:   DC.W    $8309,$FFFE,$0180,$0000
         DC.W    $8409,$FFFE,$0180,$0000
BAR3A:   DC.W    $9009,$FFFE,$0180,$0000
BAR3B:   DC.W    $9109,$FFFE,$0180,$0000
BAR3C:   DC.W    $9209,$FFFE,$0180,$0000
         DC.W    $9309,$FFFE,$0180,$0000
BAR4A:   DC.W    $A109,$FFFE,$0180,$0000
BAR4B:   DC.W    $A209,$FFFE,$0180,$0000
BAR4C:   DC.W    $A309,$FFFE,$0180,$0000
         DC.W    $A409,$FFFE,$0180,$0000
         DC.W    $FFFF,$FFFE

;нннннннннннннннннннннннннннннннннннннн
;н   NoisetrackerV1.0 replayroutine   н
;н Mahoney & Kaktus - HALLONSOFT 1989 н
;нннннннннннннннннннннннннннннннннннннн

mt_init	lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,$bfe001
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	move.b	$3(a6),d0
	and.b	#$1,d0
	asl.b	#$1,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts

mt_sin:
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0

mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0
mt_data		incbin	"source:MODULES/mod.music"
**+ mt_data		incbin	"DH0:SOURCE/MODULES/mod.enolugay"

