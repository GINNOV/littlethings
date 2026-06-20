
; Uses two macros to initialise and start a copper list.


		incdir		Source:Include/
		include		hardware.i
		include		Marks/Hardware/HW_Macros.i
		include		Marks/Hardware/HW_start.i

; Intialise copper list

Main		COPBPLC		CopPlanes,Screen,256*320/8,4
		STARTCOP	#CopList

; Enable copper and bitplane DMA

		move.w		#SETIT!DMAEN!COPEN!BPLEN,DMACON(a5)

; Wait for LMB

mouse		btst		#6,CIAAPRA
		bne.s		mouse
		
; All done so exit

		rts

		****************************
		section		coper,DATA_C
		****************************
		
CopList		CMOVE		DIWSTRT,$2c81		bpl initialisation
		CMOVE		DIWSTOP,$2cc1
		CMOVE		DDFSTRT,$0038
		CMOVE		DDFSTOP,$00d0
		CMOVE		BPLCON0,$4200
		CMOVE		BPLCON1,$0000
		CMOVE		BPL1MOD,$0000
		CMOVE		BPL2MOD,$0000
		CWAIT		0,20			wait for line 20
		
CopPlanes	CMOVE		BPL1PTH,0		bpl pointers
		CMOVE		BPL1PTL,0
		CMOVE		BPL2PTH,0
		CMOVE		BPL2PTL,0
		CMOVE		BPL3PTH,0
		CMOVE		BPL3PTL,0
		CMOVE		BPL4PTH,0
		CMOVE		BPL4PTL,0

		ds.w		16*2			space for colours

		CEND					end of list

Screen		incbin		Source:M.Meany/Gfx/screen.bm
