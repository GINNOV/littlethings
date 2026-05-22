;********************************
		opt p=68030,p=68882

_init:
		clr.l wb_msg
		sub.l a1,a1
		move.l 4,a6
		jsr -294(a6)
		move.l d0,a4
		tst.l $ac(a4)
		bne.s from_cli
		lea $5c(a4),a0
		move.l 4,a6
		jsr -384(a6)
		lea $5c(a4),a0
		move.l 4,a6
		jsr -372(a6)
		move.l d0,wb_msg
from_cli:
		move.l 4,a6
		lea intname,a1
		jsr -408(a6)
		move.l d0,intbase
		move.l d0,a6
		lea my_screen,a0
		jsr -198(a6)
		move.l d0,screenhd

		move.l screenhd,a5
		move.l $c0(a5),plane0
		add.l #850,plane0

wait_mouse:	btst #6,$bfe001
		bne.s wait_mouse

start:
		moveq #1,d0
		moveq #-1,d1
		move.l #1000000,d3
		moveq #1,d4
		bra.s loop
prim:
		movem.l d0,-(a7)

		bsr _zstring
		lea _z(pc),a1
		bsr _scan_text

		movem.l (a7)+,d0

		add.l #2,d0
		moveq #1,d1
		fmove.l d0,fp0
		fsqrt fp0 
		fmove.l fp0,d4
loop:
		cmp.l d3,d0
		bge.s ende
loop1:
		addq #2,d1
		move.l d0,d2
		cmp.l d4,d1
		bgt.s prim
		divu d1,d2
		swap d2
		tst.w d2
		bne.s loop1
keine_prim:
		add.l #2,d0
		moveq #1,d1
		fmove.l d0,fp0
		fsqrt fp0 
		fmove.l fp0,d4
		bra.s loop
ende:
		tst.l wb_msg
		beq.s _exit_cli
		move.l 4,a6
		jsr -132(a6)
		move.l wb_msg(pc),a1
		move.l 4,a6
		jsr -378(a6)
_exit_cli:
		move.l intbase,a6
		move.l screenhd,a0
		jsr -66(a6)
		move.l 4,a6
		move.l intbase,a1
		jsr -414(a6)
		rts

wb_msg:		dc.l 0
intbase:	dc.l 0
screenhd:	dc.l 0
plane0:		dc.l 0

intname:	dc.b "intuition.library",0
		even

my_screen:
a_x_pos:	dc.w 0
a_y_pos:	dc.w 0
width:		dc.w 320
heigth:		dc.w 256
depth:		dc.w 1
detail_pen:	dc.b 0
block_pen:	dc.b 1
view_modes:	dc.w 130
screen_type:	dc.w 15			;$0101
font:		dc.l 0
title:		dc.l 0
gadget:		dc.l 0
bitmap:		dc.l 0

		even
;*********************************************************
;*****  Zahl - String *** in - zzahl ** out - z		 *
;*** Aufruf:  
;***		move.l zahl,d0
;***		bsr zstring
;***		text #3,#8,#8,#z
;***		by KDM
;********************************************************
_zstring:
		move.l d0,_zzahl
_zstringpos:
		lea _z(pc),a0
		move.l a0,a1
		
		lea 1(a0),a0
		lea _zzahlminus(pc),a1
		add.l #1,_zzahl
_stringa:
		moveq #0,d6
		move.l (a1)+,d0
		move.l _zzahl,d4
		cmp.l #0,d0
		beq.s _stringende
_stringa2:
		addq #1,d6
		sub.l d0,d4
		cmp.l #0,d4		;kleiner gleich 0
		ble.s _stringa5		;dann nächste Subtrahent
		bra.s _stringa2
_stringa5:
		add.l d0,d4
		move.l d4,_zzahl
		add.l #47,d6
		move.b d6,(a0)+	
		bra.s _stringa
_stringende:
		lea _z(pc),a0
		move.b #"0",(a0)
		moveq #0,d0
_stringendeb:
		move.b (a0),d0
		cmp.b #"0",d0
		bne.s _stringebc
		move.b #" ",(a0)+
		bra.s _stringendeb	
_stringebc:
		lea _z(pc),a0
		move.l a0,a1
		moveq #0,d4
		moveq #0,d5
_stringende3:
		move.b (a0)+,d4
		cmp.b #" ",d4
		beq.s _stringende3
		subq #1,a0
_stringende4:
		move.b (a0),d5
		cmp.b #0,d5
		beq.s _stringende5
		move.b (a0)+,(a1)+
		bra.s _stringende4
_stringende5:
		move.b #0,(a1)
		rts
_zzahlminus:
		dc.l 1000000000
		dc.l 100000000
		dc.l 10000000
		dc.l 1000000
		dc.l 100000
		dc.l 10000
		dc.l 1000
		dc.l 100
		dc.l 10
		dc.l 1
		dc.l 0

_zzahl:		dc.l 0
_z:		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
_zvor:		dc.b 0
		even


_scan_text:
		lea _space(pc),a2
		move.l plane0,a0
_zscan_text2:
		move.b (a1)+,d7		;Buchstabe hohlen
		beq.s _zende		;wenn 0 dann Ende
		and.l #255,d7
_ztext_print2:
		move.b (0,a2,d7*8),(a0)
		move.b (1,a2,d7*8),40(a0)
		move.b (2,a2,d7*8),80(a0)
		move.b (3,a2,d7*8),120(a0)
		move.b (4,a2,d7*8),160(a0)
		move.b (5,a2,d7*8),200(a0)
		move.b (6,a2,d7*8),240(a0)
		move.b (7,a2,d7*8),280(a0)

		add.w #1,a0
		bra.s _zscan_text2

_zende:
		rts

;***************************************
;Zeichensatz Tabelle
; , = Amiga Zeichen
;die Nullen muessen UNBEDINGT bleiben, da sonst die falschen Zeichen
;ermittelt werden

_space:		
		dc.l 0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0

		dc.l 0,0

		dc.b %00011000
		dc.b %00011000
		dc.b %00011000
		dc.b %00011000
		dc.b %00011000
		dc.b %00000000
		dc.b %00011000
		dc.b %00000000

		dc.l 0,0

		dc.b %01101100
		dc.b %01101100
		dc.b %11111110
		dc.b %01101100
		dc.b %11111110
		dc.b %01101100
		dc.b %01101100
		dc.b %00000000

		dc.l 0,0,0,0,0,0,0,0

		dc.b %00001100
		dc.b %00011000
		dc.b %00110000
		dc.b %00110000
		dc.b %00110000
		dc.b %00011000
		dc.b %00001100
		dc.b %00000000

		dc.b %00110000
		dc.b %00011000
		dc.b %00001100
		dc.b %00001100
		dc.b %00001100
		dc.b %00011000
		dc.b %00110000
		dc.b %00000000

		dc.l 0,0

		dc.b %00000000
		dc.b %00011000
		dc.b %00011000
		dc.b %01111110
		dc.b %00011000
		dc.b %00011000
		dc.b %00000000
		dc.b %00000000

		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00011000
		dc.b %00011000
		dc.b %00110000

		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %01111110
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000

		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00000000
		dc.b %00011000
		dc.b %00011000
		dc.b %00000000

		dc.b %00000110
		dc.b %00001100
		dc.b %00011000
		dc.b %00110000
		dc.b %01100000
		dc.b %11000000
		dc.b %10000000
		dc.b %00000000

		dc.b %01111100
		dc.b %11000110
		dc.b %11001110
		dc.b %11010110
		dc.b %11100110
		dc.b %11000110
		dc.b %01111100
		dc.b %00000000

		dc.b %00011000
		dc.b %00111000
		dc.b %00011000
		dc.b %00011000
		dc.b %00011000
		dc.b %00011000
		dc.b %01111110
		dc.b %00000000

		dc.b %00111100
		dc.b %01100110
		dc.b %00000110
		dc.b %00111100
		dc.b %01100000
		dc.b %01100110
		dc.b %01111110
		dc.b %00000000

		dc.b %00111100
		dc.b %01100110
		dc.b %00000110
		dc.b %00011100
		dc.b %00000110
		dc.b %01100110
		dc.b %00111100
		dc.b %00000000

		dc.b %00011100
		dc.b %00111100
		dc.b %01101100
		dc.b %11001100
		dc.b %11111110
		dc.b %00001100
		dc.b %00011110
		dc.b %00000000

		dc.b %01111110
		dc.b %01100010
		dc.b %01100000
		dc.b %01111100
		dc.b %00000110
		dc.b %01100110
		dc.b %00111100
		dc.b %00000000

		dc.b %00111100
		dc.b %01100110
		dc.b %01100000
		dc.b %01111100
		dc.b %01100110
		dc.b %01100110
		dc.b %00111100
		dc.b %00000000

		dc.b %01111110
		dc.b %01100110
		dc.b %00000110
		dc.b %00001100
		dc.b %00011000
		dc.b %00011000
		dc.b %00011000
		dc.b %00000000

		dc.b %00111100
		dc.b %01100110
		dc.b %01100110
		dc.b %00111100
		dc.b %01100110
		dc.b %01100110
		dc.b %00111100
		dc.b %00000000

		dc.b %00111100
		dc.b %01100110
		dc.b %01100110
		dc.b %00111110
		dc.b %00000110
		dc.b %01100110
		dc.b %00111100
		dc.b %00000000

