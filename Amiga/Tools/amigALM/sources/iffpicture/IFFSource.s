        incdir  ":include/"

        include "exec/exec_lib.i"
        include "graphics/graphics_lib.i"
        include "intuition/intuition.i"
        include "intuition/intuitionbase.i"
        include "intuition/intuition_lib.i"

        lea     GfxName,a1
        move.l  #0,d0
        move.l  4,a6
        jsr     _LVOOpenLibrary(a6) ;or jsr -$228(a6)
        tst.l   d0
        beq     stop
        move.l  d0,GFXBase

        lea     IntuitionName,a1
        move.l  #0,d0
        move.l  4,a6
        jsr     _LVOOpenLibrary(a6) ;or jsr -$228(a6)
        tst.l   d0
        beq     stop
        move.l  d0,INTBase

IFFDisplay
        lea     picture,a0      ;or move.l picture,a0 if picture is a
                                ;pointer to the memory.
        cmpi.l  #'FORM',(a0)+   ;ILBM-picture must start with 'FORM'
        bne     stop
        move.l  (a0)+,Size      ;Number of bytes still to come
        cmpi.l  #'ILBM',(a0)+   ;Is it an InterLeaved BitMap file
        bne     stop
        sub.l   #4,Size         ;Size = Size - 'ILBM'

        move.l  a0,ChunkPos
ForEver
        move.l  ChunkPos,a0     ;Start of last Chunk
        add.l   ChSize,a0       ;Size of last Chunk
        move.l  a0,d0
        andi.l  #$0001,d0       ;If ChunkPos is odd then
        beq     ok
        adda.l  #1,a0           ;ChunkPos = ChunkPos + 1
ok      move.l  (a0)+,D0        ;Chunk Type
        move.l  (a0)+,ChSize    ;Chunk Size
        move.l  a0,ChunkPos
        move.l  ChSize,d1
        sub.l   d1,Size
        beq     stop
switch                          ;Switch (d0)
                                ; (For more info about switch see a C-Book)
cBMHD   cmp.l   #'BMHD',D0      ;Case 'BMHD' (Information about the picture)
        bne.s   cCMAP
        move.l  a0,BMHD         ;BMHD contains very important information
        bra.s   ForEver         ;Next Chunk

cCMAP   cmp.l   'CMAP',D0       ;case 'CMAP' (Color Information)
        bne.s   cCAMG
        move.l  ChSize,D4       ;For (d4=xx;d4<0;d4--) d4 = chunk-size

        divu    #$0003,D4       ;d4 = d4 / 3    (Number of colors)
        ext.l   d4
        cmpi.w  #32,d4          ;if number of colors > 32 then (HalfBrite)
        ble.s   colorok
        moveq.l #32,d4          ;number of colors = 32
colorok move.l  d4,colorno      ;Save number of colors
        subq.w  #1,D4           ;telt gemakkelijker
        lea     color,A3        ;color array of word type [32]

ColorL  move.b  (a0)+,D1
        lsl.w   #4,D1
        or.b    (a0)+,D1
        lsl.w   #4,D1
        or.b    (a0)+,D1
        lsr.w   #4,D1
        move.w  D1,(A3)+        ;Place color in color array
        dbf     D4,ColorL       ;Loop

        bra     ForEver         ;Next Chunk

cCAMG   cmp.l   #'CAMG',D0      ;case 'CAMG' (Commodore AMiGa)
        bne.s   cBODY           ;           (Contains info about ViewMode)
        move.l  (a0),d0
        lea     MyNewScreen,a3
        move.w  d0,ns_ViewModes(A3)     ;or move.w d0,$c(A3)
        bra     ForEver         ;Next Chunk

cBODY   cmp.l   #'BODY',D0      ;case 'BODY'    (BitPlane info)
        beq.s   BODYX
                                ;Skip all other Chunks
        bra     ForEver         ;einde switch

BODYX
        move.l  a0,a5           ;Save Pointer temporary in A5

        lea     MyNewScreen,a0
        move.l  BMHD,a3             ;The important Information
        move.w  0(a3),ns_Width(a0)  ;Width   (or move.w 0(a3),4(a0) )
        move.w  2(a3),ns_Height(a0) ;Height  (or move.w 2(a3),6(a0) )
        move.b  8(a3),ns_Depth+1(a0)    ;Depth (or move.w 8(a3),9(a0) )
        cmpi.w  #500,(A3)       ;If width > 500 then Hires else Lores
        ble.s   NoHires
        ori.w   #V_HIRES,ns_ViewModes(A0)   ;Hires (or ori.w #$8000,$c(a0) )
NoHires cmpi.w  #300,2(A3)  ;If Height > 300 then interlace else normal
        ble.s   NoLace
        ori.w   #V_LACE,ns_ViewModes(A0)    ;InterLace (ori #$4,$c(a0) )

NoLace  lea     MyNewScreen,a0
        move.l  INTBase,a6
        jsr     _LVOOpenScreen(a6)  ;or jsr -$c6(a6)
        tst.l   d0
        beq     stop
        move.l  d0,MyScreen

        move.l  MyScreen,a3         ;Set Colors
        lea     sc_ViewPort(a3),a0  ;or lea $2c(a3),a0
        lea     color,a1
        move.l  colorno,d0
        move.l  GFXBase,a6
        jsr     _LVOLoadRGB4(a6)    ;or jsr -$c0(a6)

        move.l  a5,a0               ;Pointer to CBODY

        move.l  MyScreen,A2
        move.l  BMHD,a3
        lea     192(A2),A6      ;BitMap pointer
        lea     184(a2),A2      ;ViewPort Pointer
        clr.l   D6
        move.w  (A2),D6         ;d6 = Width in bytes
        move.w  2(A3),D4        ;d4 = Height
        subq.w  #1,D4           ;So it's easy to use dbra d4,label
        moveq   #$00,D3

LineL   moveq   #$00,D5
        move.b  8(A3),D5        ;# bitplanes
        move.l  A6,A2

BitPlaneL
        dbf     D5,NextBP       ;All Bitplanes used of current line?
        cmpi.b  #$01,9(A3)
        bne.s   zz
        tst.w   D4
        beq.s   zz
        move.l  #$00fe0000,A1   ;????
        moveq   #$00,D5
        bra.s   xx
zz      add.l   D6,D3
        dbf     D4,LineL    ;Are all lines displayed, no LineLoop
        bra.s   CheckOS     ;Goto CheckOverScan

NextBP  move.l  (A2)+,A1    ;Next Bitplane
        adda.l  D3,A1
xx      move.w  D6,D2
        tst.b   10(A3)      ;Compression ?
        bne.s   Comp        ;Yes
        subq.w  #1,D2
yy3     move.b  (A0)+,(A1)+
        dbf     D2,yy3
        bra.s   BitPlaneL

while2
Comp    tst.w   D2          ;Is this line ready?
        beq.s   BitPlaneL   ;Next BitplaneLine
        moveq   #$00,D1     ;Clear d1
        move.b  (A0)+,D1    ;Get BitPlane info
        bmi.s   Crunch      ;Crunched ?

        sub.w   D1,D2       ;No, copy the next D1 bytes to the screen
        subq.w  #1,D2
yy1     move.b  (A0)+,(A1)+
        dbf     D1,yy1
        bra.s   while2

Crunch  cmp.b   #$80,D1     ;If D1 == $80 then do nothing
        beq.s   while2
        neg.b   D1
        sub.w   D1,D2
        subq.w  #1,D2
        move.b  (A0)+,D0    ;Copy D0 D1 times to the screen
yy2     move.b  D0,(A1)+    ;a1 = BitPlane Pointer
        dbf     D1,yy2
        bra.s   while2      ;Next information about the current line

CheckOS                     ;Check OverScan
        move.l  BMHD,a3
        cmpi.w  #352,(a3)
        beq.s   OverScan
        cmpi.w  #704,(a3)
        bne.s   NoOverScan
OverScan
        move.l  INTBase,a3
        move.l  868(a3),a3          ;IntuitionBase->Preferences
        subi.b  #16,pf_ViewXOffset(a3)      ;or subi.b #16,$76(a3)
        subi.b  #17,pf_ViewYOffset(a3)      ;or subi.b #17,$77(a3)
        move.l  a3,a0
        move.l #$e8,d0
        moveq.l #1,d1
        move.l  INTBase,a6
        jsr     _LVOSetPrefs(a6)            ;or jsr -$144(a6)
NoOverScan
        move.l  MyScreen,a0
        clr.l   d0
        move.l  #-600,d1
        move.l  INTBase,a6
        jsr     _LVOMoveScreen(a6)          ;or jsr -$a2(a6)


main    btst    #$06,$bfe001    ;Wait for left mouse button
        bne.s   main

        move.l  BMHD,a3
        cmpi.w  #352,(a3)
        beq.s   OverScan2
        cmpi.w  #704,(a3)
        bne.s   NoOverScan2
OverScan2                   ;Turn OverScan Off
        move.l  INTBase,a3
        move.l  868(a3),a3  ;IntuitionBase->Preferences
        addi.b  #16,pf_ViewXOffset(a3)  ;or addi.b #16,$76(a3)
          addi.b  #17,pf_ViewYOffset(a3)  ;or addi.b #17,$77(a3)
        move.l  a3,a0
        move.l #$e8,d0
        moveq.l #1,d1
        move.l  INTBase,a6
        jsr     _LVOSetPrefs(a6)        ;or jsr -$144(a6)
NoOverScan2

stop
        move.l  MyScreen,a0
        cmpa.l  #0,a0
        beq.s   CloseGFX
        move.l  INTBase,a6          ;Close Screen
        jsr     _LVOCloseScreen(a6) ;or jsr -$42(a6)

CloseGFX            ;Close Graphics.library
        move.l  GFXBase,a1
        cmpa.l  #0,a1
        beq.s   CloseINT
        move.l  4,a6
        jsr     _LVOCloseLibrary(a6)    ;or jsr -$19e(a6)

CloseINT            ;Close Intuition.library
        move.l  INTBase,a1
        cmpa.l  #0,a1
        beq.s   End
        move.l  4,a6
        jsr     _LVOCloseLibrary(a6)    ;or jsr -$19e(a6)
End

        clr.l   d0      ;Clear Return Value
        rts

GfxName dc.b    'graphics.library',0
IntuitionName
        dc.b    'intuition.library',0
        even
color   dcb.w   32
colorno dc.l    0

MyNewScreen
        dc.w    0,600       ;left, top
        dc.w    320,256     ;width, height
        dc.w    2           ;Depth
        dc.b    0,1         ;pens
        dc.w    0           ;ViewModes (is standing in CAMG)
        dc.w    15
        dc.l    0           ;font
        dc.l    0           ;title
        dc.l    0           ;gadgets
        dc.l    0           ;BitMap

GFXBase dc.l    0           ;struct GfxBase *GfxBase
INTBase
        dc.l    0           ;struct IntuitionBase *IntuitionBase
MyScreen
        dc.l    0           ;Struct Screen *Screen
BMHD    dc.l    0
ChSize  dc.l    0
Size    dc.l    0
ChunkPos
        dc.l    0

        section "Picture",data
picture incbin	DH0:Picture/WaterMan

