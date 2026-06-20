		opt p=68020,p=68882
		include "ram:makros_3"
_init:
		clr.l wb_msg
		sub.l a1,a1
		move.l 4,a6
		jsr -294(a6)
		move.l d0,a4
		move.l d0,task
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
		lea int_name(pc),a1
		moveq #0,d0
		move.l 4,a6
		jsr -408(a6)
		tst.l d0
		beq _exit
		move.l d0,intbase
		lea graf_name(pc),a1
		moveq #0,d0
		move.l 4,a6
		jsr -408(a6)
		tst.l d0
		beq close_int
		move.l d0,grafbase
		lea window_def(pc),a0
		move.l intbase,a6
		jsr -204(a6)
		tst.l d0
		beq close_graf
		move.l d0,windowhd
		move.l d0,a0
		lea menu_str(pc),a1
		move.l intbase,a6
		jsr -264(a6)			;setmenustrip
		move.b #1,_bild			;Anzeige an
		move.b #0,_disk			;nicht speichern
		move.l #0,anzahl
		get_mem #40000,#$10001
		move.l d0,zahlen
		beq close_wind2
_loop:
		move.l windowhd,a0
		move.l 86(a0),a0
		move.l 4,a6
		jsr -384(a6)			;waitPort

		move.l windowhd,a0
		move.l 86(a0),a0
		move.l 4,a6
		jsr -372(a6)			;getmsg
		move.l d0,message

		move.l d0,a1
		move.l 4,a6
		jsr -378(a6)			;antworten

		move.l message,a0
		move.l 20(a0),d0

		btst #9,d0			;close Gadget ?
		bne close_wind

		btst #8,d0
		bne menu
		bra _loop
prim0:
		print #1,#0,#16,#12,#pr_leer
		cmp.b #0,_bild
		bne.s prim0b
		print #1,#0,#16,#12,#pr_nobild
prim0b:
		move.l zahlen,a0
		moveq #1,d0
		moveq #-1,d1
		move.l limit,d3
		bra.s loop
prim:
		cmp.b #0,_bild
		beq.s prim2
		movem.l d0-d7/a0-a6,-(a7)
		bsr _zstring
		print #1,#0,#16,#12,#_z
		movem.l (a7)+,d0-d7/a0-a6
prim2:
		cmp.b #0,_disk
		beq.s prim3
		move.l d0,(a0)+
		add.l #4,anzahl
prim3:
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
		bgt prim
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
		print #1,#0,#16,#12,#pr_ready
		cmp.b #0,_disk
		beq.s ende2
		file_req "Zahlen_sichern...","ram:"
		cmp.l #-1,d0
		beq.s ende2			;ERROR
		cmp.l #1,d0
		beq.s ende2			;ABRUCH

		save #_file_name,zahlen,anzahl
ende2:
		bsr.s entprell
		bsr menu_on
		bra _loop
entprell:
		move.l windowhd,a0
		move.l 86(a0),a0
		move.l 4,a6
		jsr -372(a6)			;getmsg
		tst.l d0
		beq.s entprell2
		move.l d0,message
		move.l d0,a1
		move.l 4,a6
		jsr -378(a6)			;antworten
		bra.s entprell
entprell2:
		rts
close_wind:
		auto_request #t0,#t1,#t2,#0,#0,#200,#50
		cmp.l #0,d0
		beq _loop
		fre_mem #40000,zahlen
close_wind2:
		move.l windowhd,a0
		move.l intbase,a6
		jsr -54(a6)			;clearmenustrip

		move.l intbase,a6
		move.l windowhd,a0
		jsr -72(a6)
close_graf:
		move.l grafbase,a1
		move.l 4,a6
		jsr -414(a6)
close_int:
		move.l intbase,a1
		move.l 4,a6
		jsr -414(a6)
_exit:
		tst.l wb_msg
		beq.s _exit_cli
		move.l 4,a6
		jsr -132(a6)
		move.l wb_msg(pc),a1
		move.l 4,a6
		jsr -378(a6)
_exit_cli:
		moveq #0,d0
		rts
_zstring:
		move.l d0,_zzahl
		tst.l d0
		beq _zerozahl
_zstringpos:
		lea _z(pc),a0
		bsr.s _zstringclr
		addq #1,a0
		lea _zzahlminus(pc),a1
		add.l #1,_zzahl
_stringa:
		moveq #0,d2
		move.l (a1)+,d0
		move.l _zzahl,d1
		cmp.l #0,d0
		beq.s _stringende
_stringa2:
		addq #1,d2
		sub.l d0,d1
		cmp.l #0,d1		;kleiner gleich 0
		ble.s _stringa5		;dann nächste Subtrahent
		bra.s _stringa2
_stringa5:
		add.l d0,d1
		move.l d1,_zzahl
		add.l #47,d2
		move.b d2,(a0)+	
		bra.s _stringa
_zstringclr:
		move.l a0,a1
		moveq #14,d0
_zstringclr2:
		move.b #0,(a1)+
		dbra d0,_zstringclr2		
		rts
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
		moveq #0,d1
		moveq #0,d3
_stringende3:
		move.b (a0)+,d1
		cmp.b #" ",d1
		beq.s _stringende3
		subq #1,a0
_stringende4:
		move.b (a0),d3
		cmp.b #0,d3
		beq.s _stringende5
		move.b (a0)+,(a1)+
		bra.s _stringende4
_stringende5:
		move.b #0,(a1)
		rts
_zerozahl:
		lea _z(pc),a0
		bsr.s _zstringclr
		move.b #"0",(a0)+
		move.b #0,(a0)
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
_z:		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;16

_xcoord:	dc.w 0
pr_leer:	dc.b "          ",0
pr_nobild:	dc.b "Ich rechne",0
pr_ready:	dc.b "  Fertig !",0
		even

menu:
		move.l message,a0
		move.w $18(a0),d0
		cmp.w #$ffff,d0
		beq _loop			;kein menupunkt gewaehlt
		move.w d0,d7
		move.w d7,d6
		and.l #$ffff,d6
		and.l #$ffff,d7
		lsr #7,d7
		lsr #4,d7
		lsl #2,d7
		move.w d6,d5
		and.l #%00000000000000000000011111100000,d6
		lsr #3,d6
		and.l #%00000000000000000000000000011111,d5
		lsl #2,d5
		move.l #tab,d4
		add.l d5,d4
		move.l d4,a4
		move.l (a4),d4
		add.l d6,d4
		move.l d4,a4
		move.l (a4),a4
		jmp (a4)

tab:		dc.l tabmenu0,0
tabmenu0:	dc.l bis_10000,bis_100000,bis_1000000,ausgabe,pri,close_wind

ausgabe:	move.l #ausgabe_tab,d4
		add.l d7,d4
		move.l d4,a4
		move.l (a4),a4
		jmp (a4)

ausgabe_tab:	dc.l disk,bild

pri:		move.l #pri_tab,d4
		add.l d7,d4
		move.l d4,a4
		move.l (a4),a4
		jmp (a4)

pri_tab:	dc.l pri_5,pri0,pri5

bis_10000:
		move.l #10000,limit
		bsr menu_off
		bra prim0
bis_100000:
		move.l #100000,limit
		bsr menu_off
		bra prim0
bis_1000000:
		move.l #1000000,limit
		bsr menu_off
		bra prim0
pri_5:
		move.l 4,a6
		jsr -132(a6)
		move.l task,a1
		move.b #-20,d0
		move.l 4,a6
		jsr -300(a6)
		move.l 4,a6
		jsr -138(a6)
		bra _loop
pri0:
		move.l 4,a6
		jsr -132(a6)
		move.l task,a1
		moveq #0,d0
		move.l 4,a6
		jsr -300(a6)
		move.l 4,a6
		jsr -138(a6)
		bra _loop
pri5:
		move.l 4,a6
		jsr -132(a6)
		move.l task,a1
		move.b #20,d0
		move.l 4,a6
		jsr -300(a6)
		move.l 4,a6
		jsr -138(a6)
		bra _loop

disk:
		eor.b #1,_disk
		bra _loop
bild:
		eor.b #1,_bild
		bra _loop
menu_off:
		moveq #0,d4
aus1:		moveq #0,d3
aus11:		moveq #0,d5
		move.l d3,d2
		lsl.l #5,d2
aus12:		move.l d5,d0
		lsl.l #7,d0
		lsl.l #4,d0
		add.l d2,d0
		add.l d4,d0
		move.l windowhd,a0
		move.l intbase,a6
		jsr -180(a6)
		add.l #1,d5
		cmp.l subitems,d5
		bne.s aus12
		add.l #1,d3
		cmp.l items,d3
		bne.s aus11
		add.l #1,d4
		cmp.l menus,d4
		bne.s aus1
		rts
menu_on:
		moveq #0,d4
an1:		moveq #0,d3
an11:		moveq #0,d5
		move.l d3,d2
		lsl.l #5,d2
an12:		move.l d5,d0
		lsl.l #7,d0
		lsl.l #4,d0
		add.l d2,d0
		add.l d4,d0
		move.l windowhd,a0
		move.l intbase,a6
		jsr -192(a6)
		add.l #1,d5
		cmp.l subitems,d5
		bne.s an12
		add.l #1,d3
		cmp.l items,d3
		bne.s an11
		add.l #1,d4
		cmp.l menus,d4
		bne.s an1
		rts
subitems:	dc.l 5+1
items:		dc.l 6+1
menus:		dc.l 1

;********************** Menu Struktur *******************
;menu next,x,y,breite,waehlbar,text,untermenu
;sub_menu next,x,y,breite,flag,text,key,untermenu
menu_str:	menu 0,0,0,64,1,pr_titel0,menu00
menu00:		     sub_menu menu01,0,0,104,$52,t_menu00,0,0
menu01:		     sub_menu menu02,0,10,104,$52,t_menu01,0,0
menu02:		     sub_menu menu03,0,20,104,$52,t_menu02,0,0
menu03:		     sub_menu menu04,0,30,104,$52,t_menu03,0,menu030
menu030:		 sub_menu menu031,45,5,116,$53+8,t_menu030,0,0
menu031:		 sub_menu 0,45,15,116,$153+8,t_menu031,0,0
menu04:		     sub_menu menu05,0,40,104,$52,t_menu04,0,menu040
menu040:		 sub_menu menu041,45,5,32,$52,t_menu040,0,0
menu041:		 sub_menu menu042,45,15,32,$52,t_menu041,0,0
menu042:		 sub_menu 0,45,25,32,$52,t_menu042,0,0
menu05:		     sub_menu 0,0,50,104,$56,t_menu05,"Q",0

t_menu00:	itext pr_menu00
t_menu01:	itext pr_menu01
t_menu02:	itext pr_menu02
t_menu03:	itext pr_menu03
t_menu030:	itext pr_menu030
t_menu031:	itext pr_menu031
t_menu04:	itext pr_menu04
t_menu040:	itext pr_menu040
t_menu041:	itext pr_menu041
t_menu042:	itext pr_menu042
t_menu05:	itext pr_menu05

pr_titel0:	dc.b "Projekt",0
pr_menu00:	dc.b " bis 10000",0
pr_menu01:	dc.b " bis 100000",0
pr_menu02:	dc.b " bis 1000000",0
pr_menu03:	dc.b " Ausgabe...",0
pr_menu030:	dc.b "    Diskette",0
pr_menu031:	dc.b "    Bildschirm",0
pr_menu04:	dc.b " Prioritaet",0
pr_menu040:	dc.b " -20",0
pr_menu041:	dc.b "  0",0
pr_menu042:	dc.b "  20",0
pr_menu05:	dc.b " Quit  ",0

		even

zahlen:		dc.l 0
anzahl:		dc.l 0
task:		dc.l 0
limit:		dc.l 10000
message:	dc.l 0
wb_msg:		dc.l 0
intbase:	dc.l 0
grafbase:	dc.l 0
windowhd:	dc.l 0
window_def:	dc.w 100,0		;x1,y1
		dc.w 197,22		;Breite,Höhe
		dc.b 0,1		;pen,paper
		dc.l 512+256		;IDCMP :close+Menu
		dc.l 2+4+8		;Gadgets smart Refresh
		dc.l 0
		dc.l 0
		dc.l title		;name
		dc.l 0
		dc.l 0
		dc.w 197,22		;min
		dc.w 197,22		;max
		dc.w 1			;screen typ

t0:		dc.b "Programm verlassen ?",0
t1:		dc.b "OK",0
t2:		dc.b "Nein",0

int_name:	dc.b "intuition.library",0
graf_name:	dc.b "graphics.library",0
title:		dc.b "Prim Zahlen FPU",0
_disk:		dc.b 0
_bild:		dc.b 0
		even
		include "ram:befehle3"
