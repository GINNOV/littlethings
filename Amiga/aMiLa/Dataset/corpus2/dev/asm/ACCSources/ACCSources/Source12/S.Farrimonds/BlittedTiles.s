; Simon Farrimond

; This is another example using the blitter, it blits 16x16 pixel tiles
; onto the screen in different positions, it also uses a simple masking
; routine that gives the impression that the tiles are revolving.
; When you want to exit the program press the righ mouse button for a
; bit longer than usual.

            section BlitTiles,code_c
            opt c-
            include 'df1:include/custom.i'
 
_LVOopenlibrary  = -552
_LVOcloselibrary = -414

            lea     $dff000,a5
            move.l  4,a6

            move.w  #$01e0,dmacon(a5)   ; dma off
            move.l  #BACKGROUND,d0      ; bitplane1 address
            move.w  d0,plane1L          ; load bitplane1 low address
            swap    d0 
            move.w  d0,plane1H          ; load bitplane1 high address
            swap    d0 
            add.l   #(40*256),d0        ; bitplane2 address
            move.w  d0,plane2L          ; load bitplane2 low address
            swap    d0
            move.w  d0,plane2H          ; load bitplane2 high address
            move.l  #copper1,cop1lc(a5) ; load copper1 list
            clr.w   copjmp1(a5)
            move.w  #$83c0,dmacon(a5)
WAIT1       cmp.b   #$3d,vhposr(a5)     
            bne     WAIT1   
            tst.b   tiles_left          ; any tiles leftto blit?
            bne     NONE_LEFT
            add.b   #1,delay            ; delay so tiles aren't as fast 
            cmp.b   #20,delay
            bne     NONE_LEFT
            clr.b   delay
            bsr     BLIT_OPS            ; blit a tile
NONE_LEFT   btst    #6,$bfe001          ; test left mouse button
            bne     WAIT1
            clr.l   d0
            move.l  #gfx_lib,a1          
            jsr     _LVOopenlibrary(a6)  ; open gfx library
            move.l  d0,a1
            move.l  38(a1),cop1lc(a5)    ; get original copper list
            clr.w   copjmp1(a5) 
            jsr     _LVOcloselibrary(a6) ; close gfx library 
            move.w  #$8020,dmacon(a5)    ; dma on
            rts                          ; end of program
BLIT_OPS    clr.l   d1
            lea     TILE_SCREEN_DATA,a0  ; screen pos base address
            move.l  tile_pos,d0          ; current pointer
            move.l  (a0,d0),d1           ; get current screen pos
            cmp.l   #$ffffffff,d1        ; is it the dummy value?
            bne     SOME_LEFT            ; no
            not.b   tiles_left           ; yes, so none left
            rts
SOME_LEFT   move.l  d1,d0                ; safe copy of screen pos
            clr.l   d4
            clr.l   d2
SLIDE       cmp.b   #$3c,vhposr(a5)      ; smooth slide effect
            bne     SLIDE
            move.l  d0,d1                ; current screen pos
            add.l   #BACKGROUND,d1       ; add bitplane1 address 
            move.l  d1,a1                ; put it into an address reg
            move.l  #TILE,a0             ; tile data
            lea     mask_data,a3         ; A mask value base address
            move.w  (a3,d2),d4           ; get current mask using poointer d2
            bsr     BLIT_TILE            ; blitter operation
            add.l   #(40*256),a1         ; get bitplane2 address
            move.l  #TILE+32,a0          ; tile data for bitplane2
            bsr     BLIT_TILE            ; bitter operations
            add.l   #2,d2                ; new pointer value
            cmp.l   #54,d2               ; has tile revolved yet?
            bne     SLIDE
            add.l   #4,tile_pos          ; new screen pos
            rts

BLIT_TILE   move.l  a0,bltapt(a5)   ; source A
            move.l  a1,bltdpt(a5)   ; destination
            move.w  d4,bltafwm(a5)  ; A mask high
            move.w  d4,bltalwm(a5)  ; A mask low
            move.w  #0,bltcon1(a5)  
            move.w  #0,bltamod(a5)  ; A modulo
            move.w  #39,bltdmod(a5) ; destination modulo
            move.w  #%0000100111110000,bltcon0(a5) ; D=A minterm
            move.w  #(64*16)+1,bltsize(a5)      ; size = 16pixels x 16pixels
BLIT1       btst    #14,dmaconr(a5) 
            bne     BLIT1            ; wait for blitter to finish 
            rts

TILE_SCREEN_DATA incbin 'df1:program_data/tile_data'
TILE incbin 'df1:program_data/power_block.raw'
mask_data  dc.w 0,$180,$3c0,$7e0,$ff0,$1ff8,$3ffc,$7ffe,$ffff
           dc.w $ffff,$7ffe,$3ffc,$1ff8,$ff0,$7e0,$3c0,$180,0
           dc.w 0,$180,$3c0,$7e0,$ff0,$1ff8,$3ffc,$7ffe,$ffff

tile_pos   dc.l 0
tiles_left dc.b 0
delay      dc.b 0
gfx_lib dc.b 'graphics.library',0
  even
BACKGROUND  dcb.b (40*512),0

copper1 dc.w bplpt
plane1H dc.w 0,bplpt+2
plane1L dc.w 0,bplpt+4
plane2H dc.w 0,bplpt+6
plane2L dc.w 0
        dc.w ddfstrt,$38
        dc.w ddfstop,$d0
        dc.w diwstrt,$2c81
        dc.w diwstop,$2cc1
        dc.w bplcon0,$2200
        dc.w color,0
        dc.w color+2,$fc0
        dc.w color+4,$c80
        dc.w color+6,$750
        dc.w $ffff,$fffe



