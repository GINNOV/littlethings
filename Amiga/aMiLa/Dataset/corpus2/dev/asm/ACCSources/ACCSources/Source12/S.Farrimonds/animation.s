; Simon Farrimnond
; This is just a simple animation routine using the blitter

            section qwerty,code_c
            opt c-
            include 'df1:include/custom.i'
 
_LVOopenlibrary  = -552
_LVOcloselibrary = -414

            lea     $dff000,a5
            move.l  4,a6

            move.w  #$01e0,dmacon(a5)
            move.l  #BACKGROUND,d0
            move.l  d0,screen_pos
            add.l   #(40*100)+19,screen_pos
            move.w  d0,plane1L
            swap    d0
            move.w  d0,plane1H
            move.l  #copper1,cop1lc(a5)
            clr.w   copjmp1(a5)
            move.w  #$83c0,dmacon(a5)
            move.l  #ANIMS,d0
            move.l  d0,current_blit_pos
            add.l   #36,current_blit_pos
            bsr     BLITTER_OPS
WAIT1       cmp.b   #$ff,vhposr(a5)   ; wait for vertical blanking
            bne     WAIT1
WAIT2       cmp.b   #$fe,vhposr(a5)   ; wait again (to slow animation down)
            bne     WAIT2
            tst.b   end_reached       ; all frames animated?
            bne     MOUSE             ; yes,
            bsr     BLITTER_OPS       ; no, animate another frame
            add.b   #1,anim_count  
            cmp.b   #53,anim_count    ; all 53 frames done yet?
            bne     MOUSE             ; no
            not.b   end_reached       ; yes
MOUSE       btst    #6,$bfe001        ; test for right mouse button
            bne     WAIT1
            not.b   end_reached       ; reset counter ready for another run 
            clr.b   anim_count
            clr.l   d0
            move.l  #gfx_lib,a1       
            jsr     _LVOopenlibrary(a6)
            move.l  d0,a1
            move.l  38(a1),cop1lc(a5)
            clr.w   copjmp1(a5)
            jsr     _LVOcloselibrary(a6)
            move.w  #$8020,dmacon(a5)
            rts

BLITTER_OPS move.l  current_blit_pos,bltApt(a5) ; address to get data
            move.l  screen_pos,bltDpt(a5)       ; where to blit it
            move.l  #$ffffffff,bltAfwm(a5)      ; source A mask
            move.w  #0,bltcon1(a5) 
            move.w  #33,bltAmod(a5)                ; source A modulo
            move.w  #37,bltDmod(a5)                ; destination modulo
            move.w  #%0000100111110000,bltcon0(a5) ; D=A
            move.w  #(64*40)+2,bltsize(a5)         ; size to blit X32,
                                                   ; Y40 pixels
BLIT        btst    #14,dmaconr(a5)                ; blitter finished?
            bne     BLIT
            add.l   #4,current_blit_pos            ; next frame position
            add.b   #1,horizontal_count
            cmp.b   #9,horizontal_count            ; 9 frames per line
            beq     NEXT_LINE
            rts
NEXT_LINE   add.l   #(36*40),current_blit_pos      ; position of next line
            clr.b   horizontal_count
            rts




end_reached dc.b 0  
anim_count  dc.b 0
current_blit_pos dc.l 0
screen_pos       dc.l 0
horizontal_count dc.b 0
gfx_lib dc.b 'graphics.library',0
  even
ANIMS     incbin 'df1:program_data/animation.raw'
BACKGROUND dcb.b (40*256),0

copper1 dc.w $e0
plane1H dc.w 0,$e2
plane1L dc.w 0
        dc.w ddfstrt,$38
        dc.w ddfstop,$d0
        dc.w diwstrt,$2c81
        dc.w diwstop,$2cc1
        dc.w bplcon0,$1200
        dc.w color,0
        dc.w color+2,$fff
        dc.w $ffff,$fffe


