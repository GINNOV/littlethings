; Simon Farrimond

; This is the editor I used to create the values on my blitted tiles example
; It's a bit rough but does the job, use your joystick to move the sprite
; around and the fire button to blit a tile, once finished press the
; right mouse button to save the data as: TILE_DATA if you don't blit
; any tiles then then the program will just exit without saving.
; To save the minimum tile is 1, the maximum tiles are 640. If you want
; to save more than 640 tiles than change the value in TILES_STORAGE.

            section TileDataEd,code_c
            opt c-
            include 'df1:include/custom.i' 
 
_LVOopenlibrary  = -552
_LVOcloselibrary = -414

_LVOopen  = -30
_LVOclose = -36
_LVOwrite = -48

            clr.l   0                
            lea     $dff000,a5
            move.l  4,a6

            move.w  #$01e0,dmacon(a5)  ; dma off 
            move.l  #BACKGROUND,d0     ; bitplane1 address
            move.l  #SPRITE,d1         ; sprite address
            move.w  d0,plane1L         ; load bitplane1 low 
            move.w  d1,spriteL         ; load sprite low
            swap    d0
            swap    d1
            move.w  d0,plane1H         ; load bitplane1 high
            move.w  d1,spriteH         ; load sprite low
            swap    d0
            add.l   #(40*256),d0       ; work out bitplane2 address
            move.w  d0,plane2L         ; load bitplane2 low
            swap    d0
            move.w  d0,plane2H          ; load bitplane2 high
            move.l  #copper1,cop1lc(a5) ; new copper1 address 
            clr.w   copjmp1(a5)
            move.w  #$83e0,dmacon(a5)   ; enable dma
            lea     TILES_STORAGE,a3    ; address to store screen pos data
WAIT1       cmp.b   #$12,vhposr(a5)     ; wait for vertical blanking
            bne     WAIT1 
            add.b   #1,delay            ; set up a delay to slow  down
            cmp.b   #50,delay           ; joystick movements
            bne     NO_READ
            clr.b   delay
            bsr     READ_JOY            ; branch to the main part  
NO_READ     btst    #6,$bfe001          ; check for left mouse button
            bne     WAIT1               ; being pressed

            move.l  #$ffffffff,(a3)     ; dummy value for check
            lea     TILES_STORAGE,a3    ; start address for data
            cmp.l   #$ffffffff,(a3)     ; is first value dummy check
            beq     NO_SAVE             ; yes, so dont save anything
LOOP        add.l   #4,file_size        ; size of file to save
            cmp.l   #$ffffffff,(a3)+    ; check for dummy value
            bne     LOOP 
            add.l   #4,file_size

            bsr     SAVE_DATA           ; save the data

NO_SAVE     clr.l   d0
            move.l  #gfx_lib,a1
            jsr     _LVOopenlibrary(a6)  ; open gfx lib for original
            move.l  d0,a1                ; copper list
            move.l  38(a1),cop1lc(a5)    ; load up system copper
            clr.w   copjmp1(a5)
            jsr     _LVOcloselibrary(a6) ; close gfx lib
            move.w  #$8020,dmacon(a5)    ; dma on
            rts                          ; end of program

READ_JOY    clr.l   d1                   ; clear for joy value
            clr.l   d2                   ; clear for joy value
            lea     SPRITE,a0            ; sprite address
            move.w  joy1dat(a5),d1       ; read joystick & store value
            btst    #1,d1                ; is it going right
            beq     NO_RIGHT             ; no
            add.b   #8,1(a0)             ; new horizontal sprite pos  
            add.l   #2,joy_value         ; new on screen position
            bra     TEST_FIRE            ; branch to test fire button
NO_RIGHT    btst    #9,d1                ; is it goin left
            beq     NO_LEFT              ; no
            sub.b   #8,1(a0)             ; new horizontal sprite pos
            sub.l   #2,joy_value         ; new on screen position
            bra     TEST_FIRE            ; branch to test fire button
NO_LEFT     move.w  d1,d2                ; make a copy of joystick value

; These next two logical operations need to be done in order to test the
; forward and back positions (obviously you dont have to use the same regs)

            lsr.w   #1,d2                ; shift d1 1 bit to the right           
            eor.w   d1,d2                ; exclusive or d1 with d2
            btst    #0,d2                ; is it going down
            beq     NO_BACK              ; no
            cmp.l   #((40*16)*15),joy_value ; test for screen value  
            bge     TEST_FIRE               ; too far
NO_WAIT     add.b   #16,(a0)     ; new sprite vertical start position
            add.b   #16,2(a0)    ; new sprite vertical stop position
            add.l   #(40*16),joy_value ; new on screen pos
            cmp.b   #$30,2(a0)         ; is vertical stop over $30
            bhi     NORM1              ; yes, so normal display
            move.b  #6,3(a0)           ; so sprite can be at the bottom
            bra     TEST_FIRE          ; of the screen
NORM1       move.b  #0,3(a0)
            bra     TEST_FIRE
NO_BACK     btst    #8,d2               ; is it going up
            beq     TEST_FIRE           ; the following are the same as
            cmp.l   #(40*16),joy_value  ; going down but in reverse
            ble     TEST_FIRE
            sub.b   #16,(a0)
            sub.b   #16,2(a0)
            sub.l   #(40*16),joy_value
            cmp.b   #$30,2(a0)
            bhi     NORM2
            move.b  #6,3(a0)
            bra     TEST_FIRE
NORM2       move.b  #0,3(a0)
          
TEST_FIRE   btst    #7,$bfe001     ; has the fire button been pressed? 
            beq     FIRE_PRESS     ; yes
NOTHING     rts                    ; no, so return

FIRE_PRESS  move.l  a3,a4          ; copy address
            sub.l   #4,a4          ; same address - 4 bytes
            move.l  (a4),d0 
            cmp.l   joy_value,d0    ; is it the same value being saved
            bne     BLIT_OPS        ; no so save it   
            rts                     ; yes, return
BLIT_OPS    move.l  joy_value,(a3)+ ; save screen position in memory
            clr.l   d1
            move.l  joy_value,d1    ; current screen position
            add.l   #BACKGROUND,d1  ; add bitplane1 
            move.l  d1,a1           ; save address
            move.l  #TILE,a0        ; tile data address
            bsr     BLIT_TILE       ; bit bitplane1 onto screen
            add.l   #(40*256),a1    ; add bitplane2 address
            move.l  #TILE+32,a0     ; new tile data
            bsr     BLIT_TILE       ; blit bitplane2 onto screen
            rts  

BLIT_TILE   move.l  a0,bltapt(a5)   ; source A
            move.l  a1,bltdpt(a5)   ; destination
            move.l  #$ffffffff,bltafwm(a5) ; source A mask
            move.w  #0,bltcon1(a5)       
            move.w  #0,bltamod(a5)  ; source A modulo
            move.w  #39,bltdmod(a5) ; destination modulo 
            move.w  #%0000100111110000,bltcon0(a5) ; D=A minterm
            move.w  #(64*16)+1,bltsize(a5) ; size = 16pixels x 16pixels 
BLIT1       btst    #14,dmaconr(a5)        ; wait for bitter to finish
            bne     BLIT1
            rts


SAVE_DATA   clr.l   d0
            move.l  #dos_lib,a1
            jsr     _LVOopenlibrary(a6)  ; open dos library for the use
            move.l  d0,a6                ; of the dos functions
            beq     ERROR
            move.l  #1005,d2             ; file already exists
            move.l  #file_name,d1        ; file name to save as
            jsr     _LVOopen(a6)         ; open it
            move.l  d0,file_handle       ; file handle
            move.l  d0,d1                ; file to write
            move.l  #TILES_STORAGE,d2    ; start address of data to save
            move.l  file_size,d3         ; file size
            jsr     _LVOwrite(a6)        ; write data to disk
            move.l  file_handle,d1       ; file to close
            jsr     _LVOclose(a6)        ; close file
            move.l  a6,a1
            move.l  4,a6
            jsr     _LVOcloselibrary(a6) ; close dos library
ERROR       rts



delay       dc.b 0
joy_value   dc.l 0
file_size   dc.l 0
file_handle dc.l 0
file_name   dc.b 'df1:program_data/tile_data',0
  even 
TILE incbin 'df1:program_data/box.raw'
gfx_lib dc.b 'graphics.library',0
  even
dos_lib dc.b 'dos.library',0
  even
BACKGROUND    dcb.b (40*512),0
              dc.l  $ffffffff
TILES_STORAGE dcb.b (640*32),0

copper1 dc.w bplpt
plane1H dc.w 0,bplpt+2
plane1L dc.w 0,bplpt+4
plane2H dc.w 0,bplpt+6
plane2L dc.w 0,sprpt
spriteH dc.w 0,sprpt+2
spriteL dc.w 0
        dc.w ddfstrt,$38
        dc.w ddfstop,$d0
        dc.w diwstrt,$2c81
        dc.w diwstop,$2cc1
        dc.w bplcon0,$2200
        dc.w bplcon2,$24
        dc.w color,$002
        dc.w color+2,$299
        dc.w color+4,$222
        dc.w color+6,$2ec    
        dc.w color+34,$0f0
        dc.w sprpt+4,0,sprpt+6,0
        dc.w sprpt+8,0,sprpt+10,0
        dc.w sprpt+12,0,sprpt+14,0
        dc.w sprpt+16,0,sprpt+18,0
        dc.w sprpt+20,0,sprpt+22,0
        dc.w sprpt+24,0,sprpt+26,0
        dc.w sprpt+28,0,sprpt+30,0
        dc.w $ffff,$fffe

SPRITE  dc.w $3040,$3800     
        dc.w %0000111111110000,0000000000000000
        dc.w %0000111111110000,0000000000000000
        dc.w %0000111111110000,0000000000000000
        dc.w %0000111111110000,0000000000000000
        dc.w %0000111111110000,0000000000000000
        dc.w %0000111111110000,0000000000000000
        dc.w %0000111111110000,0000000000000000
        dc.w %0000111111110000,0000000000000000
        dc.w 0000,0000





