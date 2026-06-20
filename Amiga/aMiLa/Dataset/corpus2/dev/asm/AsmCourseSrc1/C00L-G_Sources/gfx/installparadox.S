
****** paradox font installation routine - written by Cool-G *******
* use only with the font called font.paradox, this font was ripped *
* from a paradox intro, and rearranged by me. this routine will    *
* create a table with adresses, the offset in this table (long)    *
* corresponds with the ascii value (eg ascii 65 = 65*4(tabstart))  * 
********************************************************************

fdepth=			1
fheight=		16
fwidthW=		1
ftotwidthW=		1520/16
ftotheight=		16
fwidthB=		fwidthW*2
ftotwidthB=		ftotwidthW*2
fontpicsize=		ftotwidthB*ftotheight*fdepth


calcfontdata:
	clr.l	d2
	lea.l	letteraddr,a1		; tab with ptrs (to be calc'ed)
cfdl:	lea.l	lettertab(pc),a3	; chars in font as they occur
	move.l	#fontpic-2,d0
newchlp:addq.l	#2,d0			; d0 = pos in fontpic (1char = 2bytes)
	move.b	(a3)+,d3
	cmp.l	#endlettertab,a3
	bgt.s	nextch			; not found, skip
	cmp.b	d2,d3
	bne.s	newchlp
endnewch:
	move.l	d2,d3			
	asl.l	#2,d3			; make long (offset in tab)

	move.l	d0,(a1,d3)		; save address in tab
nextch:	addq.b	#1,d2			; next ascii
	cmp.w	#128,d2
	blt.s	cfdl
	rts

letteraddr:		ds.l	128		; the addresses of the font
		
fontpic:		incbin "font.paradox",fontpicsize

lettertab:
	dc.b	" !",34,"#$%&'()*+,-./0123456789:;<=>? abcdefghijklmnopqrstuvwxyz"
	dc.b	"[\]^_`ABCDEFGHIJKLMNOPQRSTUVW   XYZ"
	dc.b	0
endlettertab:
	even

