; Hardware sprite logo: installs sprite 0 and moves it with a small sine path.
; The sprite data ends with a zero control pair, which is mandatory.
            SECTION    Code,CODE,CHIP
            XDEF       _Start
_Start:
            lea        $dff000,a6
            lea        Sprite0(pc),a0
            move.l     a0,$120(a6)          ; SPR0PTH/L
            move.w     #$8220,$96(a6)       ; DMAEN + SPRITE DMA
            lea        YPath(pc),a1
            moveq      #31,d7
.frame:
            bsr        WaitVBlank
            move.b     (a1)+,Sprite0        ; VSTART
            move.b     Sprite0(pc),d0
            add.b      #32,d0
            move.b     d0,Sprite0+2         ; VSTOP
            dbra       d7,.frame
            rts

WaitVBlank:
            cmp.b      #$ff,$06(a6)
            bne.s      WaitVBlank
.leave:
            cmp.b      #$ff,$06(a6)
            beq.s      .leave
            rts

YPath:
            dc.b       $40,$44,$48,$4c,$50,$54,$58,$5b
            dc.b       $5e,$60,$62,$63,$64,$63,$62,$60
            dc.b       $5e,$5b,$58,$54,$50,$4c,$48,$44
            dc.b       $40,$3c,$38,$36,$34,$33,$34,$36

Sprite0:
            dc.b       $40,$80,$60,$00       ; VSTART/HSTART, VSTOP/control
            dc.w       %0001100000011000,%0011110000111100
            dc.w       %0111111001111110,%1111111111111111
            dc.w       %1110011111100111,%1100001111000011
            dc.w       %1101101111011011,%1111111111111111
            dc.w       0,0
