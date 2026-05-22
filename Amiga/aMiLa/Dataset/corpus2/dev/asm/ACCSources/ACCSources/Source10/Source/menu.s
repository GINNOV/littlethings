** CODE    : MENU
** AUTHOR  : RAISTLIN
** NOTES   :I wrote for my compilation disks. Change the colours in prefs
;	  to BLACK, YELLOW, BLUE, WHITE. For best effects

init
	move.l	4,a6		;open dos library
	moveq.l	#0,d0
	lea	dosname(pc),a1
	jsr	-408(a6)
	move.l	d0,dosbase

	move.l	dosbase,a6
	jsr	-60(a6)		;get cli handle
	move.l	d0,conhandle	;save it
	move.l	dosbase,a6
	move.l	conhandle,d1	;cli-handle in d1
	move.l	#text,d2		;address of text in d2
	move.l	#textend-text,d3	;length of text in d3
	jsr	-48(a6)		;write text.

	move.l	4,a6
	move.l	dosbase,a1	;close library
	jsr	-414(a6)
wait	btst	#6,$bfe001	;test remove when
	bne	wait		;assembling to disk
	rts	
;variables

dosname	dc.b	'dos.library',0
	even
dosbase	dc.l	0
	even
conhandle	dc.l	0
	even
text	
	dc.b	$0a,$0a
	dc.b	$9b,"0;32;40m",'DATE',$9b,"1;31;40m",' : ',$9b,"1;33;40m",'2:2:91',$0a
	dc.b	$9b,"0;32;40m",'TIME',$9b,"1;31;40m",' : ',$9b,"1;33;40m",'00:20:40',$0a,$0a
	dc.b	$9b,"1;32;40m"
	dc.b	'                 DRAGON MASTERS PRESENT A DEMO MEGA COMPACT!',$0a
	dc.b	$9b,"1;31;40m"
	dc.b	'                ---------------------------------------------',$0a
	dc.b	$0a,$0a
	dc.b	$9b,"3;32;40m",'                 F1',$9b,"3;31;40m",'.............',$9b,"3;33;40m",'BOYS IN BLUE',$9b,"3;31;40m",'..........',$9b,"3;32;40m",'SAE',$0a,$0a                    
	dc.b	$9b,"3;32;40m",'                 F2',$9b,"3;31;40m",'...............',$9b,"3;33;40m",'POIPOI',$9b,"3;31;40m",'..............',$9b,"3;32;40m",'TomSoft',$0a,$0a                   
	dc.b	$9b,"3;32;40m",'                 F3',$9b,"3;31;40m",'.............',$9b,"3;33;40m",'DIRTY MINDED',$9b,"3;31;40m",'..........',$9b,"3;32;40m",'erm?',$0a,$0a
	dc.b	$9b,"3;32;40m",'                 F4',$9b,"3;31;40m",'...............',$9b,"3;33;40m",'IMPACT!',$9b,"3;31;40m",'.............',$9b,"3;32;40m",'Impact',$0a,$0a,$0A

	dc.b	$9b,"3;32;40m",'                  Hope you enjoy this little collection',$0a,$0a	
	dc.b	$9b,"3;33;40m",'          This intro is in assembler & was written by Raistlin!',$0a
	dc.b	$9b,"1;31;40m",'GREETS TO:-',$0a
	dc.b	$9b,"1;32;40m"
	dc.b	'         Quartex, Defjam, CCS, ACC, Trilogy, SAE, NBS, All BANANA BEASTS',$0a
	dc.b	'         Thanks to Magnetic Fields for using such a cool selection screen!',$0a
	dc.b	$9b,"1;31;40m",'              WATCH OUT FOR OUR NEXT DEMO!!!',$0a,$0a
	dc.b	$9b,"1;31;40m"
	dc.b	'       						Raistlin......(Enjoy)',$0a
textend
