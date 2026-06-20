 ;  DevPac 2.14 !!

SetVBI       = -30
InitVBOBs    = -36
OpenVScreen  = -42
CloseVScreen = -48
UseJoy       = -54
DoAnim       = -60
RotateX      = -66
RotateY      = -72
RotateZ      = -78
FreeVBOBs    = -84
AutoScaleOn  = -90
AutoScaleOff = -96
FreeJoy      = -102
SetColors    = -108

 move.l 4.w,a6
 lea    vecname(pc),a1
 jsr    -408(a6)            ; vector.library öffnen
 move.l d0,vecbase
 beq.s  end
 
 lea    NewVScreen(pc),a1
 move.l vecbase(pc),a6
 jsr    OpenVScreen(a6)     ; VScreen öffnen
 move.l d0,viewstruc
 
 move.l viewstruc(pc),a0
 lea    coltab(pc),a1
 jsr    SetColors(a6)       ; Farben setzen

 move.w NewVScreen+12(pc),d0
 jsr    AutoScaleOn(a6)     ; Entzerrung für evtl. höhere Auflösungen an
 
 move.l #rotpd+2,objectptr
 lea    anim(pc),a1
 jsr    SetVBI(a6)          ; VBI-Teil einbinden
 
 lea    World(pc),a1
 jsr    DoAnim(a6)          ; Animation laufen lassen

 jsr    CloseVScreen(a6)    ; VScreen schließen

 move.l 4.w,a6
 move.l vecbase(pc),a1
 jsr    -414(a6)            ; vector.library schließen

end:
 rts

vecbase   dc.l 0
viewstruc dc.l 0

NewVScreen:
 dc.w 0,0
 dc.w 320,256
 dc.w 3
 dc.b 0,0
 dc.w $00
 dc.l 0
 dc.l title

 dc.w 0
 dc.w 0,0
 dc.w 320,256
 dc.w 3
  
title: dc.b "vector.library   ©1991 by A. Lippert"
 even

World:
 dc.w 0,1
 dc.l object1

object1:
 dc.l rotpd
 dc.l rotad
 dc.l rotmv
 dc.w 0
 dc.w 0,0,-14500
 dc.w 0,0,0

rotpd:           ; Eckpunkt-Tabelle (wird vom VBI-teil vervollständigt)
 dc.w 6*8
 dc.w -30,192,0,0
 dcb.w 7*4
 dc.w -60,120,0,0
 dcb.w 7*4
 dc.w -192,24,0,0
 dcb.w 7*4
 dc.w -192,-24,0,0
 dcb.w 7*4
 dc.w -60,-120,0,0
 dcb.w 7*4
 dc.w -30,-192,0,0
 dcb.w 7*4
 
rotad:             ; Flächen-Tabelle
 dc.w 2+8+8+8+8+8
 dc.w 8,7,0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,0*4
 dc.w 8,7,47*4,46*4,45*4,44*4,43*4,42*4,41*4,40*4,47*4

 dc.w 4,3,40*4,41*4,33*4,32*4,40*4,0,0,0,0
 dc.w 4,4,41*4,42*4,34*4,33*4,41*4,0,0,0,0
 dc.w 4,3,42*4,43*4,35*4,34*4,42*4,0,0,0,0
 dc.w 4,4,43*4,44*4,36*4,35*4,43*4,0,0,0,0
 dc.w 4,3,44*4,45*4,37*4,36*4,44*4,0,0,0,0
 dc.w 4,4,45*4,46*4,38*4,37*4,45*4,0,0,0,0
 dc.w 4,3,46*4,47*4,39*4,38*4,46*4,0,0,0,0
 dc.w 4,4,47*4,40*4,32*4,39*4,47*4,0,0,0,0

 dc.w 4,3,8*4,9*4,1*4,0*4,8*4,0,0,0,0
 dc.w 4,4,9*4,10*4,2*4,1*4,9*4,0,0,0,0
 dc.w 4,3,10*4,11*4,3*4,2*4,10*4,0,0,0,0
 dc.w 4,4,11*4,12*4,4*4,3*4,11*4,0,0,0,0
 dc.w 4,3,12*4,13*4,5*4,4*4,12*4,0,0,0,0
 dc.w 4,4,13*4,14*4,6*4,5*4,13*4,0,0,0,0
 dc.w 4,3,14*4,15*4,7*4,6*4,14*4,0,0,0,0
 dc.w 4,4,15*4,8*4,0*4,7*4,15*4,0,0,0,0

 dc.w 4,2,16*4,17*4,9*4,8*4,16*4,0,0,0,0
 dc.w 4,1,17*4,18*4,10*4,9*4,17*4,0,0,0,0
 dc.w 4,2,18*4,19*4,11*4,10*4,18*4,0,0,0,0
 dc.w 4,1,19*4,20*4,12*4,11*4,19*4,0,0,0,0
 dc.w 4,2,20*4,21*4,13*4,12*4,20*4,0,0,0,0
 dc.w 4,1,21*4,22*4,14*4,13*4,21*4,0,0,0,0
 dc.w 4,2,22*4,23*4,15*4,14*4,22*4,0,0,0,0
 dc.w 4,1,23*4,16*4,8*4,15*4,23*4,0,0,0,0

 dc.w 4,5,24*4,25*4,17*4,16*4,24*4,0,0,0,0
 dc.w 4,6,25*4,26*4,18*4,17*4,25*4,0,0,0,0
 dc.w 4,5,26*4,27*4,19*4,18*4,26*4,0,0,0,0
 dc.w 4,6,27*4,28*4,20*4,19*4,27*4,0,0,0,0
 dc.w 4,5,28*4,29*4,21*4,20*4,28*4,0,0,0,0
 dc.w 4,6,29*4,30*4,22*4,21*4,29*4,0,0,0,0
 dc.w 4,5,30*4,31*4,23*4,22*4,30*4,0,0,0,0
 dc.w 4,6,31*4,24*4,16*4,23*4,31*4,0,0,0,0

 dc.w 4,2,32*4,33*4,25*4,24*4,32*4,0,0,0,0
 dc.w 4,1,33*4,34*4,26*4,25*4,33*4,0,0,0,0
 dc.w 4,2,34*4,35*4,27*4,26*4,34*4,0,0,0,0
 dc.w 4,1,35*4,36*4,28*4,27*4,35*4,0,0,0,0
 dc.w 4,2,36*4,37*4,29*4,28*4,36*4,0,0,0,0
 dc.w 4,1,37*4,38*4,30*4,29*4,37*4,0,0,0,0
 dc.w 4,2,38*4,39*4,31*4,30*4,38*4,0,0,0,0
 dc.w 4,1,39*4,32*4,24*4,31*4,39*4,0,0,0,0


rotmv:                    ; Bewegungs-Tabelle
 dc.w 210, 0,0, 60, 2,1,0
 dc.w -3
 dc.w 90,  0,0,  0, 2,1,0
 dc.w -4,16
 dc.w 210, 0,0,-60, 2,1,0
 dc.w -1

coltab:                   ; Farb-Tabelle
 dc.w 0, 0,0,0
 dc.w 1, 0,10,0
 dc.w 2, 0,8,0
 dc.w 3, 0,0,12
 dc.w 4, 0,0,10
 dc.w 5, 10,0,10
 dc.w 6, 8,0,8
 dc.w 7, 0,0,15
 dc.w -1

anim:                      ; Hier werden die Rotationskörper erzeugt und mutiert
 movem.l d2-d7/a2-a5,-(a7)
 lea     rotptr(pc),a4
 lea     rotcnt(pc),a5
 move.l  objectptr(pc),a2
 cmp.l  #0,(a4)
 bne.s  norm
 lea    rottab+2(pc),a0
 move.l a0,(a4)
norm:
 move.l (a4),a3
 moveq  #5,d6
.llp:
 move.w (a2),d0    ; Kontur ...
 cmp.w  (a3),d0    ; ...
 beq.s  .okx       ; ...
 blt.s  .lowx      ; ...
 subq.w #2,(a2)
 bra.s  .okx
.lowx:
 addq.w #2,(a2)
.okx
 move.w 2(a2),d0
 cmp.w  2(a3),d0
 beq.s  .oky
 blt.s  .lowy
 subq.w #2,2(a2)
 bra.s  .oky
.lowy:
 addq.w #2,2(a2)
.oky
 lea    8*8(a2),a2
 addq.l #4,a3
 dbf    d6,.llp
 subq.w #1,(a5)
 bgt.s  .ok
 tst.w  (a3)+
 bge.s  .ok1
 lea    rottab+2(pc),a3
.ok1:
 move.w -2(a3),(a5)
 move.l a3,(a4)
.ok:
 bsr.s  dorot
.end
 movem.l (a7)+,d2-d7/a2-a5
 bra    endrm

dorot:                  ; Rotation
 lea    sintab(pc),a0
 lea    costab(pc),a1
 move.l objectptr(pc),a2
 moveq  #5,d6
 moveq  #15,d7
.roto:
 moveq  #7,d5
 moveq  #0,d4
 move.w (a2),d3
 move.w 2(a2),d1
.roti:
 move.w d3,d0
 move.w d3,d2
 muls   0(a1,d4.w),d0
 muls   0(a0,d4.w),d2
 asr.l  d7,d0
 asr.l  d7,d2
 movem.w d0-d2,(a2)
 addq.l #8,a2
 add.w  #90,d4
 dbf    d5,.roti
 dbf    d6,.roto
 rts

rotptr    dc.l 0
rotcnt    dc.w 0
objectptr dc.l 0

sintab	DC.W	0,$23B,$477,$6B2,$8ED,$B27,$D61,$F99
	DC.W	$11D0,$1405,$1639,$186C,$1A9C,$1CCA,$1EF7,$2120
	DC.W	$2347,$256C,$278D,$29AB,$2BC6,$2DDE,$2FF2,$3203
	DC.W	$340F,$3617,$381C,$3A1B,$3C17,$3E0D,$3FFF,$41EC
	DC.W	$43D3,$45B6,$4793,$496A,$4B3B,$4D07,$4ECD,$508C
	DC.W	$5246,$53F9,$55A5,$574B,$58E9,$5A81,$5C12,$5D9C
	DC.W	$5F1E,$6099,$620C,$6378,$64DC,$6638,$678D,$68D9
	DC.W	$6A1D,$6B58,$6C8C,$6DB6,$6ED9,$6FF2,$7103,$720B
	DC.W	$730A,$7400,$74EE,$75D2,$76AD,$777E,$7846,$7905
	DC.W	$79BB,$7A67,$7B09,$7BA2,$7C31,$7CB7,$7D32,$7DA4
	DC.W	$7E0D,$7E6B,$7EC0,$7F0A,$7F4B,$7F82,$7FAF,$7FD2
	DC.W	$7FEB,$7FFA
costab	DC.W    $7FFF,$7FFA,$7FEB,$7FD2,$7FAF,$7F82
	DC.W	$7F4B,$7F0A,$7EC0,$7E6B,$7E0D,$7DA4,$7D32,$7CB7
	DC.W	$7C31,$7BA2,$7B09,$7A67,$79BB,$7905,$7846,$777E
	DC.W	$76AD,$75D2,$74EE,$7400,$730A,$720B,$7103,$6FF2
	DC.W	$6ED9,$6DB6,$6C8B,$6B58,$6A1D,$68D9,$678D,$6638
	DC.W	$64DC,$6378,$620C,$6099,$5F1E,$5D9C,$5C12,$5A81
	DC.W	$58E9,$574B,$55A5,$53F9,$5246,$508C,$4ECD,$4D07
	DC.W	$4B3B,$496A,$4793,$45B6,$43D3,$41EC,$3FFF,$3E0D
	DC.W	$3C17,$3A1B,$381C,$3618,$340F,$3203,$2FF2,$2DDE
	DC.W	$2BC7,$29AB,$278D,$256C,$2347,$2120,$1EF7,$1CCB
	DC.W	$1A9C,$186C,$163A,$1406,$11D0,$F99,$D61,$B27
	DC.W	$8ED,$6B3,$477,$23C,0,$FDC5,$FB89,$F94E
	DC.W	$F713,$F4D9,$F2A0,$F067,$EE30,$EBFB,$E9C7,$E794
	DC.W	$E564,$E336,$E10A,$DEE0,$DCB9,$DA95,$D873,$D655
	DC.W	$D43A,$D222,$D00E,$CDFE,$CBF1,$C9E9,$C7E5,$C5E5
	DC.W	$C3EA,$C1F3,$C001,$BE14,$BC2D,$BA4B,$B86E,$B696
	DC.W	$B4C5,$B2F9,$B133,$AF74,$ADBB,$AC08,$AA5B,$A8B6
	DC.W	$A717,$A57F,$A3EE,$A264,$A0E2,$9F67,$9DF4,$9C88
	DC.W	$9B24,$99C8,$9874,$9728,$95E4,$94A8,$9375,$924A
	DC.W	$9128,$900E,$8EFD,$8DF5,$8CF6,$8C00,$8B13,$8A2E
	DC.W	$8954,$8882,$87BA,$86FB,$8645,$8599,$84F7,$845E
	DC.W	$83CF,$8349,$82CE,$825C,$81F3,$8195,$8140,$80F6
	DC.W	$80B5,$807E,$8051,$802E,$8015,$8006,$8001,$8006
	DC.W	$8015,$802E,$8051,$807E,$80B5,$80F6,$8140,$8195
	DC.W	$81F3,$825B,$82CD,$8349,$83CF,$845E,$84F7,$8599
	DC.W	$8645,$86FB,$87B9,$8882,$8953,$8A2E,$8B12,$8BFF
	DC.W	$8CF5,$8DF5,$8EFD,$900E,$9127,$9249,$9374,$94A7
	DC.W	$95E3,$9727,$9873,$99C7,$9B23,$9C87,$9DF3,$9F67
	DC.W	$A0E1,$A264,$A3ED,$A57E,$A716,$A8B5,$AA5B,$AC07
	DC.W	$ADBA,$AF73,$B133,$B2F8,$B4C4,$B696,$B86D,$BA4A
	DC.W	$BC2C,$BE14,$C000,$C1F2,$C3E9,$C5E4,$C7E4,$C9E8
	DC.W	$CBF0,$CDFD,$D00D,$D221,$D439,$D654,$D872,$DA94
	DC.W	$DCB8,$DEDF,$E109,$E335,$E563,$E794,$E9C6,$EBFA
	DC.W	$EE30,$F066,$F29F,$F4D8,$F712,$F94D,$FB88,$FDC4
sinend	DC.W	0,$23B,$477,$6B2,$8ED,$B27,$D61,$F99
	DC.W	$11D0,$1405,$1639,$186C,$1A9C,$1CCA,$1EF7,$2120
	DC.W	$2347,$256C,$278D,$29AB,$2BC6,$2DDE,$2FF2,$3203
	DC.W	$340F,$3617,$381C,$3A1B,$3C17,$3E0D,$3FFF,$41EC
	DC.W	$43D3,$45B6,$4793,$496A,$4B3B,$4D07,$4ECD,$508C
	DC.W	$5246,$53F9,$55A5,$574B,$58E9,$5A81,$5C12,$5D9C
	DC.W	$5F1E,$6099,$620C,$6378,$64DC,$6638,$678D,$68D9
	DC.W	$6A1D,$6B58,$6C8C,$6DB6,$6ED9,$6FF2,$7103,$720B
	DC.W	$730A,$7400,$74EE,$75D2,$76AD,$777E,$7846,$7905
	DC.W	$79BB,$7A67,$7B09,$7BA2,$7C31,$7CB7,$7D32,$7DA4
	DC.W	$7E0D,$7E6B,$7EC0,$7F0A,$7F4B,$7F82,$7FAF,$7FD2
	DC.W	$7FEB,$7FFA
cosend

rottab:   ; Kontur-Infos
 dc.w 150
 dc.w -$a*3,$40*3
 dc.w -$14*3,$28*3
 dc.w -$40*3,$8*3
 dc.w -$40*3,-$8*3
 dc.w -$14*3,-$28*3
 dc.w -$a*3,-$40*3
 dc.w 150
 dc.w -$3a*3,$40*3
 dc.w -$24*3,$20*3
 dc.w -$10*3,$20*3
 dc.w -$10*3,-$20*3
 dc.w -$24*3,-$20*3
 dc.w -$3a*3,-$40*3
 dc.w 150
 dc.w -$a*3,$40*3
 dc.w -$34*3,$20*3
 dc.w -$10*3,$20*3
 dc.w -$10*3,-$20*3
 dc.w -$34*3,-$20*3
 dc.w -$a*3,-$40*3
 dc.w 150
 dc.w -$a*3,$28*3
 dc.w -$34*3,$8*3
 dc.w -$10*3,$8*3
 dc.w -$10*3,-$8*3
 dc.w -$34*3,-$8*3
 dc.w -$a*3,-$28*3
 dc.w 150
 dc.w -$a*3,$40*3
 dc.w -$14*3,$8*3
 dc.w -$40*3,$8*3
 dc.w -$40*3,-$8*3
 dc.w -$14*3,-$8*3
 dc.w -$a*3,-$40*3
 dc.w 150
 dc.w -$a*3,$40*3
 dc.w -$3c*3,$28*3
 dc.w -$50*3,$10*3
 dc.w -$50*3,-$10*3
 dc.w -$3c*3,-$28*3
 dc.w -$a*3,-$40*3
 dc.w 150
 dc.w -$a*3,$8*3
 dc.w -$3c*3,$28*3
 dc.w -$50*3,$10*3
 dc.w -$50*3,-$10*3
 dc.w -$3c*3,-$28*3
 dc.w -$a*3,-$8*3
 dc.w 150
 dc.w -$a*3,$40*3
 dc.w -$24*3,$30*3
 dc.w -$40*3,-$8*3
 dc.w -$10*3,-$10*3
 dc.w -$24*3,-$20*3
 dc.w -$a*3,-$40*3
 dc.w 150
 dc.w -$a*3,$40*3
 dc.w -$24*3,$20*3
 dc.w -$8*3,-$10*3
 dc.w -$20*3,-$10*3
 dc.w -$24*3,-$20*3
 dc.w -$a*3,-$40*3
 dc.w 150
 dc.w -$3a*3,$40*3
 dc.w -$24*3,$20*3
 dc.w -$20*3,$10*3
 dc.w -$8*3,$10*3
 dc.w -$c*3,-$20*3
 dc.w -$3a*3,-$40*3
 dc.w 150
 dc.w -$a*3,$10*3
 dc.w -$3c*3,$40*3
 dc.w -$20*3,$10*3
 dc.w -$8*3,$10*3
 dc.w -$c*3,-$30*3
 dc.w -$32*3,-$40*3
 dc.w 150
 dc.w -$a*3,$40*3
 dc.w -$44*3,$20*3
 dc.w -$8*3,$20*3
 dc.w -$20*3,-$10*3
 dc.w -$c*3,-$20*3
 dc.w -$a*3,-$40*3
 dc.w -1

endrm:
 rts


vecname dc.b "vector.library",0
gfxname dc.b "graphics.library",0
