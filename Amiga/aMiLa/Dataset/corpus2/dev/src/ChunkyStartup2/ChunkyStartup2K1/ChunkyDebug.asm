;
; just a function to draw a 32bit value in hexadecimal
;  into a chunkyscreen with any bytesperrow.
; useful for debug !

; phxass ChunkyDebug.asm I=include: M=68030

    XDEF    _ShowInt
    XDEF    ShowInt

_ShowInt
ShowInt
        movem.l d0-d7/a0-a6,-(sp)
;d0 value
;a0 chunkyscreen
;d1 offset
;d2 modulo

        move.l  d2,d5
        sub.l   #8,d5

        add.l   d1,a0
        lea     hamfont,a1

        ;move.l #$00205f03,d0   d0=a afficher

        rol.l   #4,d0
        move.w  #7,d1
bcltps1:
        move.l  d0,d2
        and.l   #$f,d2
        lsl.l   #8,d2   ;1carac=256
        lea     (a1,d2.l),a2    ;a2=adresse carac
        move.l  a0,a3   ;ecran+carac

;--------------- a2 carac
        move.w  #7,d7
bcltps2:

        move.w  #7,d6
bcltps3:
        move.b  2(a2),(a3)+
        addq.l  #4,a2
        dbf.w   d6,bcltps3

        ;lea     312(a3),a3
        add.l   d5,a3
        dbf.w   d7,bcltps2
;---------------------------------
        add.l   #8,a0   ;prochain carac.
        rol.l   #4,d0
        dbf.w   d1,bcltps1
;------- abnormal
               movem.l (sp)+,d0-d7/a0-a6
        rts
  
;----------------------------------------
        even
hamfont:        incbin  hamfont

