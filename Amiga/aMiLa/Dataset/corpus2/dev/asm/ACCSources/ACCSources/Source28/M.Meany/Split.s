
; Creating a multi-playfield display.

		incdir		Source:include/
		include		hardware.i
		include		marks/hardware/HW_Macros.i
		include		marks/hardware/HW_Start.i

; use macro to stuff bitplane pointers and colours into copper list for the
;first display window

Main		COPBPLC		TopCopBpls,scrn1,(640/8)*256,2

; use macro to stuff bitplane pointers and colours into copper list for the
;second display window

		COPBPLC		BotCopBpls,scrn2,(320/8)*256,2

; set address of list and strobe copper
		
		STARTCOP	#MyCop

; enable copper DMA

		move.w		#SETIT!DMAEN!COPEN!BPLEN,DMACON(a5)

; wait for LMB

mouse		btst		#6,CIAAPRA
		bne.s		mouse

; scroll bottom playfield down 100 lines. Note that copper interrupt is used
;to syncronise the scroll :-)

		moveq.l		#100,d0		counter
				
loop		move.w		INTREQR(a5),d1		wait for copper
		and.w		#COPER,d1		interrupt
		beq.s		loop
		move.w		#COPER,INTREQ(a5)	clear interrupt
		
		not.w		toggle			slow things down
		beq.s		loop
		
		addq.b		#1,pl1			down 1 line
		addq.b		#1,pl2
		subq.w		#1,d0			dec counter
		bne.s		loop			loop > 0

; wait for LMB again

mouse1		btst		#6,CIAAPRA
		bne.s		mouse1

; scroll bottom display window back up again

		moveq.l		#100,d0		counter
				
loop2		move.w		INTREQR(a5),d1		wait for copper
		and.w		#COPER,d1		interrupt
		beq.s		loop2
		move.w		#COPER,INTREQ(a5)	clear interrupt
		
		not.w		toggle			slow things down
		beq.s		loop2
		
		subq.b		#1,pl1			up 1 line
		subq.b		#1,pl2
		subq.w		#1,d0			dec counter
		bne.s		loop2			loop >0

		rts					all done, exit!

; This toggle is used to ensure scrolling is done one line every two frames

toggle		dc.w		0

		section		copper,DATA_C

; Copper List for split display.

; 1st section, HiRes

MyCop		CWAIT		0,43		line above start point
		CMOVE		DIWSTRT,$2c81	start at 129,44
;		CMOVE		DIWSTOP,$4ec1
		CMOVE		DDFSTRT,$003c	hires
		CMOVE		DDFSTOP,$00d4
		CMOVE		BPLCON0,$a200	2 bit planes
		CMOVE		BPLCON1,$0000	no scrroll
		CMOVE		BPLCON2,$0000	ignore priority
		CMOVE		BPL1MOD,$0000
		CMOVE		BPL2MOD,$0000

TopCopBpls	CMOVE		BPL1PTH,0
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0
		CMOVE		BPL2PTL,0
		
		ds.w		4*2
		
pl1		CWAIT		0,80		line above start point
		dc.w		DIWSTRT
pl2		dc.w		$5181		start at 129,81
		CMOVE		DIWSTOP,$38c1
		CMOVE		DDFSTRT,$0038	lores
		CMOVE		DDFSTOP,$00d0
		CMOVE		BPLCON0,$2200	2 bit planes
		CMOVE		BPLCON1,$0000	no scrroll
		CMOVE		BPLCON2,$0000	ignore priority

BotCopBpls	CMOVE		BPL1PTH,0
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0
		CMOVE		BPL2PTL,0
		
		ds.w		4*2
		
		CMOVE		INTREQ,SETIT!COPER	copper interrupt
		
		CEND

; The raw data gfx

scrn1		incbin		Gfx/hi.bm		640x256x2

scrn2		incbin		Gfx/lo.bm		320x256x2

		end
	
