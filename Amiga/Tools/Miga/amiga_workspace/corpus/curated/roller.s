    SECTION code,CODE_C

start:
        ; Save system state
        move.l  4.w,a6              ; ExecBase
        jsr     -132(a6)            ; Forbid()

        bsr	makeroll		; build copper list first!

        ; Take over the copper
        lea     coplist,a0
        move.l  a0,$dff080          ; COP1LC - write copper list address
        move.w  d0,$dff088          ; COPJMP1 - restart copper

        ; Wait for left mouse button
.wait:
        btst    #6,$bfe001          ; left mouse button
        bne     .wait

        ; Restore system
        move.l  4.w,a6
        jsr     -138(a6)            ; Permit()
        rts

makeroll:
        lea     roller,a0
        moveq   #12,d0

.loop:
        moveq   #0,d1

        moveq   #14,d2
.roll1:
        move.w  #$180,(a0)+
        move.w  d1,(a0)+
        addi.w  #$100,d1
        dbra    d2,.roll1
        move.w  #$180,(a0)+
        move.w  d1,(a0)+

        moveq   #14,d2
.roll2:
        move.w  #$180,(a0)+
        subi.w  #$100,d1
        move.w  d1,(a0)+
        dbra    d2,.roll2

        moveq   #14,d2
.roll3:
        move.w  #$180,(a0)+
        addq.w  #1,d1
        move.w  d1,(a0)+
        dbra    d2,.roll3

        moveq   #13,d2
.roll4:
        move.w  #$180,(a0)+
        subq.w  #1,d1
        move.w  d1,(a0)+
        dbra    d2,.roll4

        dbra    d0,.loop
        rts

        SECTION data,DATA_C

coplist:
        dc.w    $8e,$2c81,$90,$2cc1,$92,$38,$94,$d0
        dc.w    $100,0
        dc.w    $180,0
        dc.w    $2c3f,$fffe
roller:
        ds.w    60*13*2
        dc.w    $180,0
        dc.l    -2

        END
