* demo program
* does not check any fails! 

		mc68020
		
		incdir include:
		include ims.i
		include display_aga.i

		section _code_,code

start:		MOpenIntuition
		MOpenGfx
		MOpenDos
		move.l _IntuitionAbsBase,__intuition
		move.l _GfxAbsBase,__gfx
		move.l #$00021800,d0		;lores,ham8
		jsr __agaopendisplay

		MAlloc #320*256*4, #0		;24 bit chunky buffer
		move.l d0,base

		MAlloc #320*256, #0		;buffer for picture conversion
		move.l d0,temp

*	LOAD THE RED PART OF PICTURE

;rsection
		leastr "PROGDIR:pix.r",a0
		move.l a0,d1
		move.l #1005,d2
		MDosCall Open
		push.l d0
		move.l d0,d1
		move.l temp,d2
		move.l #320*256*4,d3
		MDosCall Read
		pop.l d1
		MDosCall Close
		move.l temp,a0
		move.l base,a1
		move.l #320*256-1,d1
loop1		move.b (a0)+,d0
		move.b d0,(a1)
		addq.l #4,a1
		dec.l d1
		bpl loop1
		
*		LOAD THE GREEN PART OF PICTURE
;gsection
		leastr "PROGDIR:pix.g",a0
		move.l a0,d1
		move.l #1005,d2
		MDosCall Open
		push.l d0
		move.l d0,d1
		move.l temp,d2
		move.l #81919,d3
		MDosCall Read
		pop.l d1
		MDosCall Close
		move.l temp,a0
		move.l base,a1
		move.l #320*256-1,d1
loop2		move.b (a0)+,d0
		inc.l a1
		move.b d0,(a1)
		addq.l #3,a1
		dec.l d1
		bpl loop2

*		LOAD THE BLUE PART OF PICTURE
;bsection
		leastr "PROGDIR:pix.b",a0
		move.l a0,d1
		move.l #1005,d2
		MDosCall Open
		push.l d0
		move.l d0,d1
		move.l temp,d2
		move.l #320*256*4,d3
		MDosCall Read
		pop.l d1
		MDosCall Close
		move.l temp,a0
		move.l base,a1
		move.l #320*256-1,d1
loop3		move.b (a0)+,d0
		addq.l #2,a1
		move.b d0,(a1)
		addq.l #2,a1
		dec.l d1
		bpl loop3

* WAVES 	===============================

		move.b #3,__rendermode
		move.b #10,__mainpri

mainloop	move.l base,a0
		lea table1,a4
		move.w #127,d4
waveloop	lea line,a1
		move.w #159,d6
		clr.w d5		
wavelineloop	move.b (a4),d2	;distance
		clr.w d3
		move.b d2,d3
		add.b redphase,d3 ;pos in sine table
		clr.w d7
		move.b (a0)+,d7	 ;data RED
		move.b (sinetable.l,d3.w),d5
		mulu.w d5,d7
		asr.w #8,d7
		move.b d7,(a1)+  ;RED is DONE

		move.b d2,d3
		add.b greenphase,d3
		add.b d3,d3	;higher frequency
		clr.w d7
		move.b (a0)+,d7	 ;data GREEN
		move.b (sinetable.l,d3.w),d5
		mulu.w d5,d7
		asr.w #8,d7
		move.b d7,(a1)+

		move.b d2,d3
		add.b bluephase,d3
		asl.b #2,d3
		clr.w d7
		move.b (a0)+,d7
		move.b (sinetable.l,d3.w),d5
		mulu.w d5,d7
		asr.w #8,d7
		move.b d7,(a1)+

		inc.l a1
		addq #2,a4
		
		addq #5,a0	;2x?
		dbra d6,wavelineloop

		push.w d4
		push.l a0
		push.l a4
		move.l #line,__psource
		jsr __agac2p
		pop.l a4
		pop.l a0
		pop.w d4
		add.l #320*4,a0
		add.l #320,a4
		dbra d4,waveloop


;hotovo
		jsr __agavblchangebuffer
		addq.b #3,redphase
		inc.b greenphase
		addq.b #6,bluephase
		btst #6,$bfe001
		bne mainloop
		
		MFree base
		MFree temp

		jsr __agaclosedisplay
		MCloseIntuition
		MCloseGfx
		MCloseDos
		MExit2Dos 0

		section _data_,data

		include data.i
		
base		   dc.l 0
temp		   dc.l 0
redphase	   dc.b 0
greenphase	   dc.b 0
bluephase	   dc.b 0
		   dc.b 0	
line		   dcb.l 320	
table1		   incbin "p:table1"
sinetable	   incbin "p:sinetable"

