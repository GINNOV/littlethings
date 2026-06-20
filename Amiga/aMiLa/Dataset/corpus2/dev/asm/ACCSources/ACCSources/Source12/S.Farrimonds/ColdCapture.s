; Simon Farrimond
; This is an example of setting the cold capture vectors
; assemble the program, run it then do a warm reset

; On every reset you have to set the CoolCapture vector again
; on this example I don't set it again so when you reset for a second
; time the vectors should be clear.
; I've not kept resetting the vectors because if you wanted to clear
; them you'd have to switch the power off your computer.

    
          section Coldcap,code_c
          opt c-
          incdir  'df1:include/'
          include 'exec_lib.i'

; get enough memory to load program into and set cold capture
          move.l   4,a6
          move.l   #PROGRAM_END-PROGRAM,d0 ; size of program 
          move.l   #1,d1                   ; use chip memory
          jsr      _LVOallocmem(a6)        ; get the memory
          beq      ERROR                   ; an error
          move.l   d0,a1                   ; get address of memory to be used
          move.l   a1,42(a6)               ; enter address into coldcapture
          move.w   #PROGRAM_END-PROGRAM,d0 ; size of program for loop
          lea      PROGRAM,a0              ; program address
LOOP1     move.b   (a0)+,(a1)+             ; load program into memory
          dbra     d0,LOOP1   

; recalculate coldcapture checksum

          move.l   #0,d1                  
          lea      34(a6),a0
          move.w   #22,d0
LOOP2     add.w    (a0)+,d1
          dbra     d0,LOOP2
          not.w    d1
          move.w   d1,82(a6)
ERROR     rts



; This is the program that is jumped too when you reset
; It just sets up a 1 bit plane screen

PROGRAM:
          move.l   a5,resume      ; store register a5
          jsr      DISP           ; branch to program to execute
          move.l   resume,a5      ; put back contents of a5
          jmp      (a5)           ; continue reset routine


DISP    
          include 'df1:include/custom.i'

          move.l    4,a6
          lea       $dff000,a5

          jsr       _LVOforbid(a6)
          move.w    #$01e0,dmacon(a5)
          move.l    #PICCY,d0
          move.w    d0,plane1L
          swap      d0
          move.w    d0,plane1H
          move.l    #copper_list,cop1lc(a5)
          clr.w     copjmp1(a5)
          move.w    #$8380,dmacon(a5)
MOUSE     btst      #6,$bfe001
          bne       MOUSE
          move.l    #gfx_lib,a1
          jsr       _LVOopenlibrary(a6)
          move.l    d0,a1
          move.l    38(a1),cop1lc(a5)
          clr.w     copjmp1(a5)
          move.w    #$8060,dmacon(a5)
          jsr       _LVOpermit(a6) 
          rts

PROGRAM_END:

resume dc.l 0
copper_list dc.w $e0
plane1H     dc.w 0,$e2
plane1L     dc.w 0
            dc.w diwstrt,$2c81
            dc.w diwstop,$2cc1
            dc.w ddfstrt,$38
            dc.w ddfstop,$d0
            dc.w bplcon0,$1200
            dc.w $0180,0
            dc.w $0182,$ffff
            dc.w $ffff,$fffe

PICCY incbin 'df1:program_data/screen.raw'
   even
gfx_lib dc.b 'graphics.library',0


