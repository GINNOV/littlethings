_init:
		sub.l a1,a1
		move.l 4.w,a6
		jsr -294(a6)
		move.l d0,a4
		tst.l $ac(a4)
		bne.s from_cli
		lea $5c(a4),a0
		move.l 4.w,a6
		jsr -384(a6)
		lea $5c(a4),a0
		move.l 4.w,a6
		jsr -372(a6)
		lea wb_msg(pc),a6
		move.l d0,(a6)
from_cli:
		lea dos_name(pc),a1
		move.l 4.w,a6
		jsr -408(a6)
		lea dos_name(pc),a6
		move.l d0,(a6)
		lea int_name(pc),a1
		move.l 4.w,a6
		jsr -408(a6)
		lea int_name(pc),a6
		move.l d0,(a6)
		lea window_def(pc),a0
		move.l int_name(pc),a6
		jsr -204(a6)
		lea windowhd(pc),a6
		move.l d0,(a6)
		beq close_int
loop:
		move.l windowhd(pc),a0
		move.l 86(a0),a0
		move.l 4.w,a6
		jsr -372(a6)			;getmsg
		tst.l d0
		bne.s close_wind
		lea leer(pc),a0
		move.l #"    ",2(a0)
		move.w #"  ",6(a0)

		move.l #"    ",10(a0)
		move.w #"  ",14(a0)
		move.b #0,15(a0)

		moveq #2,d1			;Chip
		lea leer+2(pc),a5
		bsr.s _zstring

		moveq #4,d1			;Fast
		lea leer+10(pc),a5
		bsr.s _zstring

		moveq #30,d0
		moveq #1,d1
		move.l windowhd(pc),a0
		move.l 50(a0),a0
		lea textst(pc),a1
		move.l int_name(pc),a6
		jsr -216(a6)

		move.l dos_name(pc),a6
		moveq #50,d1
		jsr -198(a6)
		bra.s loop
close_wind:
		move.l d0,a1
		move.l 4.w,a6
		jsr -378(a6)			;Antworten
		move.l int_name(pc),a6
		move.l windowhd(pc),a0
		jsr -72(a6)
close_int:
		move.l int_name(pc),a1
		move.l 4.w,a6
		jsr -414(a6)

		move.l dos_name(pc),a1
		move.l 4.w,a6
		jsr -414(a6)

		lea wb_msg(pc),a6
		tst.l (a6)
		beq.s _exit_cli
		move.l 4.w,a6
		jsr -132(a6)
		move.l wb_msg(pc),a1
		move.l 4.w,a6
		jsr -378(a6)
_exit_cli:
		moveq #0,d0
		rts
_zstring:
		move.l 4.w,a6
		jsr -216(a6)			;wieviel
		moveq #10,d1
		asr.l d1,d0			;in Kbytes(/1024)
		move.l a5,a0
		tst.l d0
		beq.s _zerozahl
		move.l a0,a2
		lea _zzahlminus(pc),a1
_zstring2:
		move.w (a1)+,d1
		beq.s _zstringende
		divu d1,d0
		add.b #"0",d0
		move.b d0,(a0)+
		swap d0
		and.l #$ffff,d0
		bra.s _zstring2
_zerozahl:
		move.b #"0",3(a0)
		rts
_zstringende:
		cmp.b #"0",(a2)
		beq.s _zstringende2
		rts
_zstringende2:
		move.b #" ",(a2)+
		bra.s _zstringende

_zzahlminus:
		dc.w 10000
		dc.w 1000
		dc.w 100
		dc.w 10
		dc.w 1
		dc.w 0

leer:		dc.b "C:      F:     ",0
		even

textst:
		dc.b 1,0
		dc.b 1,0
		dc.w 0			;x
		dc.w 0			;y
		dc.l 0
		dc.l leer		;string
		dc.l 0

wb_msg:		dc.l 0
windowhd:	dc.l 0
window_def:	dc.w 100,0		;x1,y1
		dc.w 202,10		;Breite,Höhe
		dc.b 0,1		;pen,paper
		dc.l 512		;IDCMP Flags: close
		dc.l 2+4+8		;Gadgets smart Refresh
		dc.l 0
		dc.l 0
		dc.l 0			;name
		dc.l 0
		dc.l 0
		dc.w 202,10		;min
		dc.w 202,10		;max
		dc.w 1			;screen typ (wbench)

dos_name:	dc.b "dos.library",0		;dos_base
int_name:	dc.b "intuition.library",0	;int_base
