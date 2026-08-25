* -------------------------------------------------------------------------
* Example CH21-3.s Flashing assembler patch (written with Devpac)
* -------------------------------------------------------------------------
                        include exec/types.i

                        include exec/exec_lib.i        

                        include exec/interrupts.i

                        include hardware/intbits.i

                        include graphics/graphics_lib.i 


DELAY                   EQU      8

PRIORITY                EQU      0

                        XDEF    _FlashOn

                        XDEF    _FlashOff

                        XREF    _GfxBase

                        XREF    _g_viewport_p

                        XREF    _colourtable


* -------------------------------------------------------------------------

* Preserve a6, get colours and then set up the interrupt server node

* before adding to existing vertical blanking jobs. Structure is already 

* defined in include files, so we can use the pre-calculated offsets...


_FlashOn:               movem.l         a6,-(a7)        ;preserve

                        move.l          #_colourtable,a1

                        move.w          14(a1),d0       ;get colour

                        move.w          d0,d1           ;copy colour

                        andi.w          #$0F00,d1       ;isolate red

                        lsr.w           #8,d1

                        move.b          d1,red

                        move.b          d0,d1           ;copy colour

                        andi.b          #$00F0,d1       ;isolate green

                        lsr.b           #4,d1

                        move.b          d1,green

                        move.b          d0,d1           ;copy colour

                        andi.b          #$000F,d1       ;isolate blue

                        move.b          d1,blue

                        move.l          #server_node,a1 ;base address

                        move.b          #NT_INTERRUPT,LN_TYPE(a1)

                        move.b          #PRIORITY,LN_PRI(a1)

                        move.l          #_colourtable,IS_DATA(a1)

                        move.l          #FLASH_CODE,IS_CODE(a1)

                        moveq.l         #INTB_VERTB,d0  ;server node already in a1

                        CALLEXEC        AddIntServer    ;install

                        movem.l         (a7)+,a6        ;restore 

                        rts                             :quit

* -------------------------------------------------------------------------

                        cnop            0,4

_FlashOff:              movem.l         a6,-(a7)        ;preserve

                        move.l          #server_node,a1

                        moveq.l         #INTB_VERTB,d0

                        CALLEXEC        RemIntServer  

                        movem.l         (a7)+,a6        ;restore 

                        rts                             ;quit

* -------------------------------------------------------------------------

FLASH_CODE:             movem.l         d2-d3/a6,-(a7)  ;preserve registers

                        subq.b          #1,count

                        bne             FC1             

                        move.b          #DELAY,count

                        bchg            #0,switch       ;alternate value

                        beq             CLEAR_REG


SET_REG:                move.b          red,d1          ;prepare colours

                        move.b          green,d2        ;for RGB4() call

                        move.b          blue,d3 

                        bra             FC0

CLEAR_REG:              clr             d1              ;clear colours

                        clr             d2              ;for RGB4() call

                        clr             d3

FC0:                    move.l          #7,d0           ;colour reg 7

                        move.l          _g_viewport_p,a0

                        CALLGRAF        SetRGB4         ;reset colour


FC1:                    movem.l         (a7)+,d2-d3/a6  ;restore registers

                        moveq.l         #0,d0           ;set Z flag

                        rts

* -------------------------------------------------------------------------

server_node             ds.l            IS_SIZE         ;static declaration

count                   dc.b            DELAY

red                     ds.b            1               ;space for storing

green                   ds.b            1               ;separated colour 

blue                    ds.b            1               ;values

switch                  ds.b            1               ;boolean flash switch

* -------------------------------------------------------------------------

