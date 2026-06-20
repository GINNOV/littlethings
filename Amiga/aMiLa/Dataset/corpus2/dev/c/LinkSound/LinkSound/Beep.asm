        opt L+
; For Devpac and blink

custom          equ $dff000
aud1lc          equ $b0
aud1len         equ $b4
aud1per         equ $b6
aud1vol         equ $b8
aud0lc          equ $a0
aud0len         equ $a4
aud0per         equ $a6
aud0vol         equ $a8
dmacon          equ $96
adkcon          equ $9e
intreq	        equ $9C
intreqr	        equ $1E


OpenLibrary     equ -552
CloseLibrary    equ -414
Delay           equ -198

        XDEF    _beep
_beep:
        movem.l d0/d1/a0/a1/a2/a5/a6,-(sp)
        move.l  4,a6
        lea     dosname(pc),a1
        moveq   #0,d0
        jsr     OpenLibrary(a6)
        tst.l   d0
        beq     back
        lea     DOSBase(pc),a0
        move.l  d0,(a0)

        lea     per(pc),a2
        move.l  #custom,a5
        move.w  #600,(a2)
        jsr     play(pc)
        move.w  #1200,(a2)
        jsr     play(pc)
        move.w  #600,(a2)
        jsr     play(pc)

        move.l  4,a6
        move.l  DOSBase(pc),a1
        jsr     CloseLibrary(a6)
back:
        movem.l (sp)+,d0/d1/a0/a1/a2/a5/a6
        rts

play:
        move.w  #$0003,dmacon(a5)               ;clear audio 0+1 DMA-Kanal
        move.l  #ALsquare,aud0lc(a5)
        move.w  #ALsquaresize/2,aud0len(a5)
        move.w  #64,aud0vol(a5)
        move.w  per(pc),aud0per(a5)

        move.l  #ALsquare,aud1lc(a5)
        move.w  #ALsquaresize/2,aud1len(a5)
        move.w  #64,aud1vol(a5)
        move.w  per(pc),aud1per(a5)

        move.w  #$00ff,adkcon(a5)               ;Modulation off

        move.w  #$8203,dmacon(a5)               ;channel 0+1 on
        move.l  DOSBase(pc),a6
        move.l  #5,d1
        jsr     Delay(a6)
        move.w  #$0003,dmacon(a5)               ;channel 0+1 off
        rts

DOSBase         ds.l    1
per             ds.w    1
dosname         dc.b	'dos.library',0
                cnop    0,2

        SECTION customdata,DATA_C
ALsquare:
        dc.b    0,30
        dc.b    60,95
        dc.b    127,95
        dc.b    60,30
        dc.b    0,-30
        dc.b    -60,-95
        dc.b    -127,-95
        dc.b    -60,-30
ALsquaresize equ *-ALsquare
        END
