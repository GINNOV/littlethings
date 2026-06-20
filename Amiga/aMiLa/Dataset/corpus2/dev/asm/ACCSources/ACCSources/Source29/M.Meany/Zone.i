

; Zone checking subroutine. We will want to monitor the position of the mouse
;when a button is being pressed, ie where on the screen is it. This routine
;relies on a table of 'zones', defined by the top left and bottom right
;corner of an imaginary rectangle. Supply an x,y coordinate and this routine
;will return a zone number if the mouse is within one, or zero otherwise.
;Look at this as laymans gadgets:-)

; If zones overlap at the position supplied, only the first is reported.

;The routine can also be used in hardware bashing programs to simulate
;gadgets on any display, it does not rely on mouse, joystick or sprites!

; Entry		d0=x
;		d1=y
;		a0->Zone Table

; Exit		d0=zone number, 0 if not in a zone.

; Corrupt	d0-d2

_GetZone	move.l		a0,-(sp)		save

		moveq.l		#1,d2			first zone

; See if x is within limits

.loop		cmp.w		(a0),d0			check lower limit
		blt.s		.NextZone		out of bounds!
		
		cmp.w		4(a0),d0		check upper limit
		bgt.s		.NextZone		out of bounds

; X is ok, check y

		cmp.w		2(a0),d1		check lower limit
		blt.s		.NextZone		out of bounds
		
		cmp.w		6(a0),d1		check upper limit
		bgt.s		.NextZone		out of bounds

; The coordinate supplied is within bounds, exit now!

		move.l		d2,d0			set return code
		bra.s		.Done			and exit

; Step through zone table. Last entry has an x,y coordinate of -1.

.NextZone	addq.l		#8,a0			bump to next zone
		addq.w		#1,d2			bump zone ID
		cmpi.l		#-1,(a0)		end of table?
		bne.s		.loop			no, keep checking

; The coordinate supplied was not in any of the zones, return error!

		moveq.l		#0,d0			signal not in a zone
		
.Done		move.l		(sp)+,a0		restore
		rts

; Below is a an example zone table. It must consist of word (x,y) pairs.

;ZoneTable	dc.w		10,10,50,20		zone 1
;		dc.w		100,20,200,100		zone 2
;		dc.w		10,10,20,50		zone 3 (overlaps 1)
;		dc.l		-1			end of table!
		