* written for kuma-seka ages ago, works fine and
* can be optimized for special cases...
* the line is (x0,y0)-(x1,y1) = (d0,d1)-(d2,d3) ...
* Remember that you must have DFF000 in a6 and
* The screen start address in a0.
* Only a1-a7 and d7 is left unchanged.
*    __   .
*  /( |( )|\/ '(|)
* /  )|(|\|/\   |)

Screen_widht=40 ;40 bytes wide screen...
fill_lines:     ;(a6=$dff000, a0=start of bitplane to draw in)

        cmp.w   d1,d3
        beq.s   noline
        ble.s   lin1
        exg     d1,d3
        exg     d0,d2
lin1:
	sub.w   d2,d0
        move.w  d2,d5
        asr.w   #3,d2
        ext.l   d2
        sub.w   d3,d1
        muls    #Screen_Widht,d3        ;can be optimized here..
        add.l   d2,d3
        add.l   d3,a0
        and.w   #$f,d5
        move.w  d5,d2
        eor.b   #$f,d5
        ror.w   #4,d2
        or.w    #$0b4a,d2
        swap    d2
        tst.w   d0
        bmi.s   lin2
        cmp.w   d0,d1
        ble.s   lin3
        move.w  #$41,d2
        exg     d1,d0
        bra.s   lin6
lin3:   move.w  #$51,d2
        bra.s   lin6
lin2:   neg.w   d0
        cmp.w   d0,d1
        ble.s   lin4
        move.w  #$49,d2
        exg     d1,d0
        bra.s   lin6
lin4:   move.w  #$55,d2
lin6:   asl.w   #1,d1
        move.w  d1,d4
        move.w  d1,d3
        sub.w   d0,d3
        ble.s   lin5
        and.w   #$ffbf,d2
lin5:   move.w  d3,d1
        sub.w   d0,d3
        or.w    #2,d2
        lsl.w   #6,d0
        add.w   #$42,d0
bltwt:  btst    #6,2(a6)
        bne.s   bltwt
        bchg    d5,(a0)
        move.l  d2,$40(a6)
        move.l  #-1,$44(a6)
        move.l  a0,$48(a6)
        move.w  d1,$52(a6)
        move.l  a0,$54(a6)
        move.w  #Screen_Widht,$60(a6)   ;width
        move.w  d4,$62(a6)
        move.w  d3,$64(a6)
        move.w  #Screen_Widht,$66(a6)   ;width
        move.l  #-$8000,$72(a6)
        move.w  d0,$58(a6)
noline: rts
