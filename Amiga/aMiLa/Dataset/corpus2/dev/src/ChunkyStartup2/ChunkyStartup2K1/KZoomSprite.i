;    /+===========================================================+/
;   //                                                           //
;  //           Modulo-free 8bit Zoom Sprite                    //
; //                                                           //
;/+===========================================================+/
; KZoomSprite.i
; ->krabob@online.fr<- (Vic Ferry) 01-02-2001
; 
; This routines support free-resolution screens+
; free-resolution texture+
; free rectangle clipping+
; coordinate-exchange.
; 16 bit shifted- fixed comas UV coordinates.
;
; phxass command line to make a .o:
;  phxass KZoomSprite.i I=include: M=68020

    ; all macros needed to create some structures.
 incdir include:
    include exec/types.i


 STRUCTURE ScreenRenderContext,0

        APTR src_ChunkyScreen
        LONG src_BytesModulo
        LONG src_ClipX1
        LONG src_ClipY1
        LONG src_ClipX2
        LONG src_ClipY2

 LABEL  src_SIZEOF

 STRUCTURE TextureContext,0

        APTR ttc_ChunkyTexture
        LONG ttc_BytesModulo
        LONG ttc_U1                     ;<<16
        LONG ttc_V1                     ;<<16
        LONG ttc_U2                     ;<<16
        LONG ttc_V2                     ;<<16

 LABEL  ttc_SIZEOF

;Following instructions -    fmul.s fp0,fp1
;                move.l d0,d2
;                move.l d1,d3
;                move.l d2,d4
;                add.l d5,d6
;                add.l d0,d1 - executes in 3 cycles !!!

; d0.l x1 Rectangle to fit on Chunky Screen.
; d1.l y1 
; d2.l x2
; d3.l y2

; a0.l Screen Render Context (Pointer)
; a1.l TextureContext (Pointer)

        XDEF    KZoomSprite8bit68K
        XDEF    _KZoomSprite8bit68K

                section ZoomSprite,code

KZoomSprite8bit68K
_KZoomSprite8bit68K
        movem.l d0-d7/a0-a6,-(sp)

; a2 kept for evt. table.

;  +---------------------------------------------+
; /             Prepare Height vectors          /
;+---------------------------------------------+

        move.l  d0,a4   ;X1,X2 kept
        move.l  d2,a5

        ;  +-------------------------------------+
        ; /     Swap if order Y is not right    /
        ;+-------------------------------------+
        ;d1 Y1
        ;d3 Y2
        move.l  ttc_V1(a1),d5   ;V1
        move.l  ttc_V2(a1),d6   ;V2

        cmp.l   d3,d1
        beq     .end            ; exit if 0 lines
        blt     .noswapY
        
                ; if Y1>Y2 swap values

                move.l  d1,d7
                move.l  d3,d1
                move.l  d7,d3

                move.l  d5,d7
                move.l  d6,d5
                move.l  d7,d6

                sub.l   #65536,d5   ;last pixel ->first is out (sub logic)
                sub.l   #65536,d6
.noswapY

; Here:
; d0: -
; d1: Y1
; d2: -
; d3: Y2
; d4: -
; d5: V1
; d6: V2
; d7:   -usually calculation-

; a0: RC
; a1: TXTC
; a2: kept for table
; a3: (will be chunky ptr)
; a4: X1
; a5: X2
        ;  +-------------------------------------+
        ; /     Clip Up                         /
        ;+-------------------------------------+

        move.l  src_ClipY1(a0),d4
        cmp.l   d4,d3
        ble     .end                    ;if out up, exit
        
        cmp.l   d1,d4                   ; have to be clipped or not ?
        ble     .noclip_up              ; >0 had to be clipped

                ;d5= V1 = ...
                ; a=(d4-d1) (>0)
                ; b=(d3-d1) (>0)
                ;Ub=(d6-d5)
                ;Ua=(Ub/b)*a
                ;d5 = d5(V1) + Ua

                
                ;060: scramble these 3*2...
                move.l  d4,d0   
                sub.l   d1,d0   ;d0=a (pixel.l)

                move.l  d3,d2           
                sub.l   d1,d2   ;d2=b (pixel.l)
                
                move.l  d6,d7   
                sub.l   d5,d7   ;d7.l=Ub<<16 (-+)


                divs.l  d2,d7   ;Ub/b   divs first because <<16
                muls.l  d0,d7   ;Ub/b*a
                
                add.l   d7,d5   ;V1 Clipped
                
                ;d1= Y1=ClipY1          
                move.l  d4,d1
.noclip_up
        ;  +-------------------------------------+
        ; /     Clip Down                       /
        ;+-------------------------------------+

        move.l  src_ClipY2(a0),d4
        cmp.l   d4,d1
        bge     .end                    ;if out down, exit

        cmp.l   d3,d4
        bge     .noclip_down

                move.l  d3,d0
                sub.l   d4,d0   ;d0=a

                move.l  d3,d2
                sub.l   d1,d2   ;d2=b

                move.l  d6,d7
                sub.l   d5,d7   ;Ub

                divs.l  d2,d7
                muls.l  d0,d7   ;a

                sub.l   d7,d6   ;V2-a ... V2 Clipped

                ;d3=ClipY2
                move.l  d4,d3
.noclip_down
        ;  +-----------------------------------------------------+
        ; /     Set Screen Pointer to Y line & find vector      /
        ;+-----------------------------------------------------+

        sub.l   d1,d3           ;d3=Height to render.

        sub.l   d5,d6           ;(V2-V1)<<16
        divs.l  d3,d6           ;texture Height vector
        subq.l  #1,d3           ;to use with dbf.w


        move.l  src_ChunkyScreen(a0),a3
        move.l  src_BytesModulo(a0),d0
        mulu.l  d0,d1           
        add.l   d1,a3           ;a3 point the line to render.
        ;d1 is freed.

        


;  +---------------------------------------------+
; /             Prepare Width vectors           /
;+---------------------------------------------+

        move.l  a4,a6
        move.l  a5,d1

        move.l  d5,a4
        move.l  d6,a5


; Here:
; d0: -
; d1: X2
; d2: -
; d3: Y lenght to render.
; d4: -Clip
; d5: -U1
; d6: -U2
; d7: -

; a0: RC
; a1: TXTC
; a2: Kept for table
; a3: Chunky ptr
; a4: V Start <<16
; a5: V Vector <<16
; a6: X1

        ;  +-------------------------------------+
        ; /     Swap if order X is not right    /
        ;+-------------------------------------+
        ;d0 X1
        ;d1 X2

        move.l  ttc_U1(a1),d5   ;U1
        move.l  ttc_U2(a1),d6   ;U2

        cmp.l   d1,a6
        beq     .end            ; exit if 0 lines
        blt     .noswapX
        
                ; if X1>X2 swap values

                move.l  a6,d7
                move.l  d1,a6
                move.l  d7,d1

                move.l  d5,d7
                move.l  d6,d5
                move.l  d7,d6

                sub.l   #65536,d5   ;last pixel ->first is out (sub logic)
                sub.l   #65536,d6
.noswapX

        ;  +-------------------------------------+
        ; /     Clip Left                       /
        ;+-------------------------------------+

        move.l  src_ClipX1(a0),d4
        cmp.l   d4,d1
        ble     .end                    ;if out up, exit
        
        cmp.l   a6,d4                   ; have to be clipped or not ?
        ble     .noclip_left            ; >0 had to be clipped

                ;d5= V1 = ...
                ; a=(d4-a6) (>0)
                ; b=(d1-a6) (>0)
                ;Ub=(d6-d5)
                ;Ua=(Ub/b)*a
                ;d5 = d5(U1) + Ua

                
                ;060: scramble these 3*2...
                move.l  d4,d0
                sub.l   a6,d0   ;d0=a (pixel.l)

                move.l  d1,d2
                sub.l   a6,d2   ;d2=b (pixel.l)
                
                move.l  d6,d7
                sub.l   d5,d7   ;d7.l=Ub<<16 (-+)


                divs.l  d2,d7   ;Ub/b   divs first because <<16
                muls.l  d0,d7   ;Ub/b*a
                
                add.l   d7,d5   ;U1 Clipped
                
                ;a6= Y1=ClipY1          
                move.l  d4,a6
.noclip_left
        ;  +-------------------------------------+
        ; /     Clip Right                      /
        ;+-------------------------------------+

        move.l  src_ClipX2(a0),d4
        cmp.l   d4,a6
        bge     .end                    ;if out down, exit

        cmp.l   d1,d4
        bge     .noclip_right

                move.l  d1,d0
                sub.l   d4,d0   ;d0=a

                move.l  d1,d2
                sub.l   a6,d2   ;d2=b

                move.l  d6,d7
                sub.l   d5,d7   ;Ub

                divs.l  d2,d7
                muls.l  d0,d7   ;a

                sub.l   d7,d6   ;V2-a ... V2 Clipped

                ;d1=ClipY2
                move.l  d4,d1
.noclip_right


        ;  +-----------------------------------------------------+
        ; /     Set Screen Pointer to X pixel & find vector     /
        ;+-----------------------------------------------------+


        add.l   a6,a3   ;chunky start x,Y first pixel
        sub.l   a6,d1   ;X2-X1 >0 d1=nb of pixel in width.

        sub.l   d5,d6   ;U delta <<16
        divs.l  d1,d6   ;texture Width vector
        swap    d5      ; addx trick for U vect
        swap    d6      

        move.l  src_BytesModulo(a0),d0
        sub.l   d1,d0


        subq.l  #1,d1   ;d1 original width length for loop - a6 freed


        move.l  ttc_ChunkyTexture(a1),a0        ;no more need for RC.
        move.l  ttc_BytesModulo(a1),a1  

; Here:
; d0: screen modulo - drawn width
; d1: X length to render(orig)
; d2: X length to render(dbf).
; d3: Y lenght to render.
; d4: - (things)
; d5: -U Start <<16     swaped(orig)
; d6: -U Vector <<16    swaped
; d7: -U Start <<16     swaped(scan)


; a0: Chunky Texture Start.
; a1: Texture modulo
; a2: Kept for table
; a3: Chunky ptr of line.
; a4: V Start <<16
; a5: V Vector <<16
; a6: Chunky Texture "at the line"


;  +---------------------------------------------+
; /     Height Loop                             /
;+---------------------------------------------+
.loop_height
                ; find line on texture -> a6
                move.l  a0,a6
                move.l  a4,d4   ;V<<16
                swap    d4      ;V.w

                move.l  a1,d7   ;texture modulo
                muls.w  d7,d4   ;d4.l= V*txtmodulo
                add.l   d4,a6           
                                
                ; reset U scan
                move.l  d5,d7           
;;;;;;;;;;      add.l   #0,d7   ;set "x" to 0. was optimlized by phxass.
                andi    #$00f,ccr
                

                ; reset width loop.
                move.w  d1,d2           
;  +---------------------------------------------+
; /             Width Loop                      /
;+---------------------------------------------+
.loop_width
                
                        move.b  (a6,d7.w),d4
                        beq.b   .noprint
                        move.b  d4,(a3)
.noprint
                        addx.l  d6,d7   ;U vector
                        addq.l  #1,a3   ;miraculously doesnt reset "x".

                dbf.w   d2,.loop_width
;  +---------------------------------------------+
; /             End Width Loop                  /
;+---------------------------------------------+

                add.l   d0,a3   ; + rest of lines

                ;+ V vector
                add.l   a5,a4

        dbf.w   d3,.loop_height
;  +---------------------------------------------+
; /     End of Height Loop                      /
;+---------------------------------------------+
.end:
        movem.l (sp)+,d0-d7/a0-a6
        rts
;    /+===========================================================+/
;   //                                                           //
;  //                   End                                     //
; //                                                           //
;/+===========================================================+/





