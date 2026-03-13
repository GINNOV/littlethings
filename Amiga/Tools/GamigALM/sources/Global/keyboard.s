
*****************************************************************************
;       AMIGA Keyboard Routine
*****************************************************************************

;code:  	Fabrice deveaux / Ordilogic Systems
;release:	1.2

;----------------------------------------------------------------------------



; keyboard initialisation
; ------------------------

	move.l	#keyboard_int,$68
	move	#%1100000000001000,intena+custom
	clr.b	icr+ciaa                     ;turn all 8520 A interupt off
	lea	ciab,a1                      ;init 8520 B
	move.b	#%10001000,icr(a1)           ;serial port int enable
	move.b	#%00010111,icr(a1)           ;turn off all other
	clr.b	tadrh+ciab                   ;timer a = 4 (serial rate in emit mode
	move.b	#4,tadrl+ciab                ;             for keyboard handshacke)
	clr.b	cra(a1)                      ;init ctrl reg A




loop	bra	loop






; keyboard interuption
; --------------------

keyboard_int
	movem.l	d0/d1/a0/a1,-(sp)
	rclr	d0
 	move.b	sdr+ciab,d0       		;d0 key code
 	st	sdr+ciab                   ;put 1 on serial port
	move.b	#%01010001,cra+ciab        ;turn serial port in out

	btst	#0,d0
	bne	key_down
	st	keyup_flag+1
	bra	keyb_end
key_down
	lsr	#1,d0
	eor	#$7f,d0
	move.b	d0,key+1
keyb_end
	tst.b	icr+ciab		;clear int bit
	moveq	#1,d0
	and	vpos+custom,d0
	lsl	#8,d0
	move.b	vhpos+custom,d0
keyb_wait1                                      	;wait 1rst raster line
	moveq	#1,d1
	and	vpos+custom,d1
	lsl	#8,d1
	move.b	vhpos+custom,d1
	cmp	d1,d0
	beq	keyb_wait1
keyb_wait2				;wait 2nd raster line
	moveq	#1,d0
	and	vpos+custom,d0
	lsl	#8,d0
	move.b	vhpos+custom,d0
	cmp	d1,d0
	beq.s   keyb_wait2

	clr.b	cra+ciab		;turn serial port in entry

	move	#%0000000000001000,intreq+custom
	movem.l	(sp)+,d0/d1/a0/a1
 	rte

key
	ds.w	1	;last key down value.
keyup_flag
	ds.w	1	;flag set if a keyup comme






