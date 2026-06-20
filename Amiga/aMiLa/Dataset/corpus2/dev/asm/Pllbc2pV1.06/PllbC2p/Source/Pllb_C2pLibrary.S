;	-	-	-	-	-	-	-	-	-

;			   >> PLLB-C2P V1.06 <<

;			  Written By Kevin Picone

;           (c) Copyright 1996 Kevin Picone of Underware Design.

;                          All Rights Reserved

;	-	-	-	-	-	-	-	-	-

;      PLEASE NOTE: The code hits the HARDWARE while using the Blitter
 
;	-	-	-	-	-	-	-	-	-

;	      This Source Cotains the Following MAIN Routines


;		* Pllb_Alloc_fast_buffers

;		* Pllb_DeAlloc_fast_buffers

;		* Pllb_C2p_Wait_blt

;		* Pllb_C2p_Process_Frame_Buffer

;		* Pllb_c2p_Init_BlitterResort_Table

;		* Pllb_C2p_blitter_resort_frame

;		* Pllb_C2p_init_precalc_tables

;		* Pllb_C2p_Routine_alignment_system


;	-	-	-	-	-	-	-	-	-


PllbVersion macro
		dc.b "V1.06 (10-8-1996)"
	endM


		rsreset

Pllb_C2P_Tag512k		rs.l 1
Pllb_C2P_Tag1024k		rs.l 1
Pllb_C2P_Tag1536k		rs.l 1
Pllb_C2P_Tag2048k		rs.l 1

		rsreset

Pllb_c2p_ColourDepth4Bit	rs.l 1		; set to 16 colours
Pllb_c2p_ColourDepth6Bit	rs.l 1		; set to 64 colours
Pllb_c2p_ColourDepth8Bit	rs.l 1		; set to 256 colours

		rsreset

Pllb_C2p_PIxelWidth1		rs.b 1
Pllb_C2p_PIxelWidth2		rs.b 1
Pllb_C2p_PIxelWidth4		rs.b 1

		rsreset

Pllb_C2p_Type_Normal			rs.b 1
Pllb_C2p_Type_Delta			rs.b 1
Pllb_C2p_Type_Nullskip			rs.b 1
Pllb_C2p_Type_DeltaNullskip		rs.b 1

Pllb_C2p_Type_Size			rs.b 1


		rsreset

Pllb_C2p_Not_Active		rs.b 1
Pllb_C2p_Active			rs.b 1



;	-	-	-	-	-	-	-	-	-


;	-	-	-	-	-	-	-	-	-



Pllb_C2p_DeltaNullSkip_buffer_pointer:	dc.l 0

Pllb_C2p_FastBuffer_PointerA:	dc.l 0		; pointer to precalc buf A
Pllb_C2p_FastBuffer_PointerB:	dc.l 0		
Pllb_C2p_FastBuffer_PointerC:	dc.l 0
Pllb_C2p_FastBuffer_PointerD:	dc.l 0


Pllb_C2p_Enabled_Flag:		dc.w Pllb_c2p_Not_Active

PllB_C2p_FastRam_BUfferSize:	dc.w 0

Pllb_C2p_ColourDepth:		dc.w Pllb_c2p_ColourDepth8bit

Pllb_C2p_PixelWidth:		dc.w pllb_c2p_pixelwidth1

Pllb_C2p_Conversion_Type:	dc.w pllb_c2p_type_Normal




;	-	-	-	-	-	-	-	-	-


;		     >> Allocate Fast Ram Buffers <<

;   This routine will attempt to allocate as many 512k buffers as possible
;   with a MAX of 4.

;  Inputs:  NONE

;  Returns: Sets 'Pllb_C2p_Active_Flag' upon either success or failure

;	-	-	-	-	-	-	-	-	-



Pllb_Alloc_fast_buffers:

	move.w #Pllb_c2p_Not_Active,Pllb_C2p_Enabled_Flag

	lea.l Pllb_C2p_FastBuffer_PointerA(pc),a5

	move.l #0,d6		; numb of blocks allocated

	moveq.l #4-1,d7

Pllb_Alloc_fast_buffers_lp:

	move.l $4.w,a6		
	move.l #(1024*512),d0		; buffer size
	moveq.l #$4,d1			; Memory type (FAST!)
	jsr -198(a6)			; err Alloc Mem ;)
			
	tst.l d0
	beq.b Pllb_Alloc_fast_buffers_Skip

		move.l d0,(a5)+

		addq.l #4,d6		; add another 512k bank

Pllb_Alloc_fast_buffers_Skip:

	dbf d7,Pllb_Alloc_fast_buffers_lp

	tst.w d6
	beq.b Pllb_Alloc_fast_buffers_Failed

		subq.l #4,d6

		move.w d6,PllB_C2p_FastRam_BUfferSize

		move.w #Pllb_c2p_Active,Pllb_C2p_Enabled_Flag

Pllb_Alloc_fast_buffers_Failed:


	rts









;	-	-	-	-	-	-	-	-	-

;		    >> De Allocate PLLB fast Ram buffers <<

;	-	-	-	-	-	-	-	-	-


Pllb_DeAlloc_fast_buffers:

	lea.l Pllb_C2p_FastBuffer_PointerA(pc),a5

	moveq.l #4-1,d7

Pllb_DeAlloc_fast_buffers_lp:

	move.l (a5)+,d0
	beq.b Pllb_DeAlloc_fast_buffers_CONT

	move.l $4.w,a6		
	move.l d0,a1
	move.l #(1024*512),d0		; buffer size
	jsr -210(a6)			; De-Alloc Mem ;)

Pllb_DeAlloc_fast_buffers_CONT:

	dbf d7,Pllb_DeAlloc_fast_buffers_lp


	rts



;	-	-	-	-	-	-	-	-	-

;		 	    >> Wait Blitter <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Wait_blt:
	 btst #14,$dff002
	 bne.b Pllb_C2p_Wait_blt
	rts






;	-	-	-	-	-	-	-	-	-

;			>> Pllb-C2P Frame Buffer <<

;	-	-	-	-	-	-	-	-	-

 
Pllb_C2p_Process_Frame_Buffer:

		tst.w Pllb_C2p_Enabled_Flag
		beq.b Pllb_C2p_process_frame_buffer_done

		moveq.l #0,d0
		lea.l Pllb_C2P_ColourDepthTables(pc),a0
		move.w Pllb_C2p_ColourDepth(pc),d0
		move.l (a0,d0.w),a0	

		move.w Pllb_C2p_Conversion_Type(pc),d0
		lsl.w #4,d0			
		add.l d0,a0

		move.w Pllb_C2p_PixelWidth(pc),d0

		mulu #16*Pllb_C2p_Type_Size,d0
		add.l d0,a0

		move.w PllB_C2p_FastRam_BUfferSize(pc),d0
		add.l d0,a0

		move.l (a0),a0
		jsr (a0)
	
		; Wait for Blitter, then call the *FIRST* shift bitplane
		; process, ** REMEMBER ** you'll have to do the rest !!!  ;) 
		
		bsr Pllb_c2p_wait_blt

		move.w #1,Pllb_C2p_blit_flag
		bra Pllb_C2p_blitter_resort_frame2

Pllb_C2p_process_frame_buffer_done:

		rts



Pllb_C2P_ColourDepthTables:

		dc.l  Pllb_c2p_4bit_routines
		dc.l  Pllb_c2p_6bit_routines
		dc.l  Pllb_c2p_8bit_routines


Pllb_c2p_8bit_routines:

		; 8bit pixelwidth1

	
		dc.l Pllb_C2p_8bit_512k_1by1
		dc.l Pllb_C2p_8bit_1Meg_1by1
		dc.l Pllb_C2p_8bit_1_5meg_1by1
		dc.l Pllb_C2p_8bit_2meg_1by1

		dc.l Pllb_C2p_Delta_8bit_512k_1by1
		dc.l Pllb_C2p_Delta_8bit_1meg_1by1
		dc.l Pllb_C2p_Delta_8bit_1_5meg_1by1
		dc.l Pllb_C2p_Delta_8bit_2meg_1by1

		dc.l Pllb_C2p_NullSkip_8bit_512k_1by1
		dc.l Pllb_C2p_NullSkip_8bit_1meg_1by1
		dc.l Pllb_C2p_NullSkip_8bit_1_5meg_1by1
		dc.l Pllb_C2p_NullSkip_8bit_2meg_1by1


		dc.l Pllb_C2p_DeltaNullSkip_8bit_512k_1by1
		dc.l Pllb_C2p_DeltaNullSkip_8bit_1meg_1by1
		dc.l Pllb_C2p_DeltaNullSkip_8bit_1_5meg_1by1
		dc.l Pllb_C2p_DeltaNullSkip_8bit_1_5meg_1by1

	

		; 8bit pixelwidth2


		dc.l Pllb_C2p_8bit_512k_2by1
		dc.l Pllb_C2p_8bit_1Meg_2by1
		dc.l Pllb_C2p_8bit_1Meg_2by1	
		dc.l Pllb_C2p_8bit_1Meg_2by1

		dc.l Pllb_C2p_DELTA_8bit_512k_2by1
		dc.l Pllb_C2p_DELTA_8bit_1Meg_2by1
		dc.l Pllb_C2p_DELTA_8bit_1Meg_2by1
		dc.l Pllb_C2p_DELTA_8bit_1Meg_2by1

		dc.l Pllb_C2p_NUllSkip_8bit_512k_2by1
		dc.l Pllb_C2p_NUllSkip_8bit_1Meg_2by1
		dc.l Pllb_C2p_NUllSkip_8bit_1Meg_2by1
		dc.l Pllb_C2p_NUllSkip_8bit_1Meg_2by1


		dc.l Pllb_C2p_DeltaNUllSkip_8bit_512k_2by1
		dc.l Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1
		dc.l Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1
		dc.l Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1



		; 8bit pixelwidth4

		dc.l Pllb_C2p_8bit_512k_4by1
		dc.l Pllb_C2p_8bit_512k_4by1
		dc.l Pllb_C2p_8bit_512k_4by1
		dc.l Pllb_C2p_8bit_512k_4by1

		dc.l Pllb_C2p_DELTA_8bit_512k_4by1
		dc.l Pllb_C2p_DELTA_8bit_512k_4by1
		dc.l Pllb_C2p_DELTA_8bit_512k_4by1
		dc.l Pllb_C2p_DELTA_8bit_512k_4by1

		dc.l Pllb_C2p_NULLSKIP_8bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_8bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_8bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_8bit_512k_4by1

		dc.l Pllb_C2p_DeltaNULLSKIP_8bit_512k_4by1
		dc.l Pllb_C2p_DeltaNULLSKIP_8bit_512k_4by1
		dc.l Pllb_C2p_DeltaNULLSKIP_8bit_512k_4by1
		dc.l Pllb_C2p_DeltaNULLSKIP_8bit_512k_4by1





Pllb_c2p_6bit_routines:

		; 6bit pixelwidth1
		
		dc.l Pllb_C2p_6bit_512k_1by1
		dc.l Pllb_C2p_6bit_1Meg_1by1
		dc.l Pllb_C2p_6bit_1_5meg_1by1
		dc.l Pllb_C2p_6bit_2meg_1by1

		dc.l Pllb_C2p_Delta_6bit_512k_1by1
		dc.l Pllb_C2p_Delta_6bit_1meg_1by1
		dc.l Pllb_C2p_Delta_6bit_1_5meg_1by1
		dc.l Pllb_C2p_Delta_6bit_2meg_1by1

		dc.l Pllb_C2p_NullSkip_6bit_512k_1by1
		dc.l Pllb_C2p_NullSkip_6bit_1meg_1by1
		dc.l Pllb_C2p_NullSkip_6bit_1_5meg_1by1
		dc.l Pllb_C2p_NullSkip_6bit_2meg_1by1


		dc.l Pllb_C2p_DeltaNullSkip_6bit_512k_1by1
		dc.l Pllb_C2p_DeltaNullSkip_6bit_1Meg_1by1
		dc.l Pllb_C2p_DeltaNullSkip_6bit_1_5Meg_1by1
		dc.l Pllb_C2p_DeltaNullSkip_6bit_1_5Meg_1by1



		; 6bit pixelwidth2

		dc.l Pllb_C2p_6bit_512k_2by1
		dc.l Pllb_C2p_6bit_1Meg_2by1
		dc.l Pllb_C2p_6bit_1Meg_2by1	
		dc.l Pllb_C2p_6bit_1Meg_2by1

		dc.l Pllb_C2p_DELTA_6bit_512k_2by1
		dc.l Pllb_C2p_DELTA_6bit_1Meg_2by1
		dc.l Pllb_C2p_DELTA_6bit_1Meg_2by1
		dc.l Pllb_C2p_DELTA_6bit_1Meg_2by1

		dc.l Pllb_C2p_NULLSKIP_6bit_512k_2by1
		dc.l Pllb_C2p_NULLSKIP_6bit_1Meg_2by1
		dc.l Pllb_C2p_NULLSKIP_6bit_1Meg_2by1
		dc.l Pllb_C2p_NULLSKIP_6bit_1Meg_2by1


		dc.l Pllb_C2p_DeltaNullSkip_6bit_512k_2by1
		dc.l Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1
		dc.l Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1
		dc.l Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1



		; 6bit pixelwidth4

		dc.l Pllb_C2p_6bit_512k_4by1
		dc.l Pllb_C2p_6bit_512k_4by1
		dc.l Pllb_C2p_6bit_512k_4by1
		dc.l Pllb_C2p_6bit_512k_4by1

		dc.l Pllb_C2p_DELTA_6bit_512k_4by1
		dc.l Pllb_C2p_DELTA_6bit_512k_4by1
		dc.l Pllb_C2p_DELTA_6bit_512k_4by1
		dc.l Pllb_C2p_DELTA_6bit_512k_4by1

		dc.l Pllb_C2p_NULLSKIP_6bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_6bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_6bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_6bit_512k_4by1

		dc.l Pllb_C2p_DeltaNullskip_6bit_512k_4by1
		dc.l Pllb_C2p_DeltaNullskip_6bit_512k_4by1
		dc.l Pllb_C2p_DeltaNullskip_6bit_512k_4by1
		dc.l Pllb_C2p_DeltaNullskip_6bit_512k_4by1



Pllb_C2P_4bit_Routines:

		; 4bit pixelwidth1
		
	
		dc.l Pllb_C2p_4bit_512K_1by1
		dc.l Pllb_C2p_4bit_512K_1by1
		dc.l Pllb_C2p_4bit_512K_1by1
		dc.l Pllb_C2p_4bit_512K_1by1
	
		dc.l Pllb_C2p_DELTA_4bit_512K_1by1
		dc.l Pllb_C2p_DELTA_4bit_512K_1by1
		dc.l Pllb_C2p_DELTA_4bit_512K_1by1
		dc.l Pllb_C2p_DELTA_4bit_512K_1by1

		dc.l Pllb_C2p_NULLSKIP_4bit_512K_1by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512K_1by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512K_1by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512K_1by1

		dc.l Pllb_C2p_DeltaNullSkip_4bit_512K_1by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512K_1by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512K_1by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512K_1by1



		; 4bit pixelwidth2
		
		dc.l Pllb_C2p_4bit_512k_2by1
		dc.l Pllb_C2p_4bit_512k_2by1
		dc.l Pllb_C2p_4bit_512k_2by1
		dc.l Pllb_C2p_4bit_512k_2by1

		dc.l Pllb_C2p_DELTA_4bit_512k_2by1
		dc.l Pllb_C2p_DELTA_4bit_512k_2by1
		dc.l Pllb_C2p_DELTA_4bit_512k_2by1
		dc.l Pllb_C2p_DELTA_4bit_512k_2by1

		dc.l Pllb_C2p_NULLSKIP_4bit_512k_2by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512k_2by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512k_2by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512k_2by1

		dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_2by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_2by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_2by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_2by1


		; 4bit pixelwidth4
	
		dc.l Pllb_C2p_4bit_512K_4by1
		dc.l Pllb_C2p_4bit_512K_4by1
		dc.l Pllb_C2p_4bit_512K_4by1
		dc.l Pllb_C2p_4bit_512K_4by1

		dc.l Pllb_C2p_DELTA_4bit_512k_4by1
		dc.l Pllb_C2p_DELTA_4bit_512k_4by1
		dc.l Pllb_C2p_DELTA_4bit_512k_4by1
		dc.l Pllb_C2p_DELTA_4bit_512k_4by1

		dc.l Pllb_C2p_NULLSKIP_4bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512k_4by1
		dc.l Pllb_C2p_NULLSKIP_4bit_512k_4by1

		dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_4by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_4by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_4by1
		dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_4by1




pllb_version:	

	dc.b "Pllbc2p "
	pllbversion
	dc.b "   Written & Design By Kevin Picone"
	

	even

;	-	-	-	-	-	-	-	-	-

;		      >> Init NORMAL c2p registers <<

;	-	-	-	-	-	-	-	-	-


Pllb_c2p_init_Normal_c2p_registers:

	move.l Pllb_C2P_Chunky_Frame_bufferA(pc),a0
	Move.l Pllb_C2p_Temp_Image_buffer(pc),a1
	bra.b Pllb_c2p_init_c2p_registers





;	-	-	-	-	-	-	-	-	-

;		      >> Init DELTA c2p registers <<

;	-	-	-	-	-	-	-	-	-

Pllb_c2p_init_DELTA_c2p_registers:
	move.l Pllb_C2P_Chunky_Frame_bufferB(pc),a0
	move.l Pllb_C2P_Chunky_Frame_bufferA(pc),a1
	bra.b Pllb_c2p_init_c2p_registers



Pllb_c2p_init_NULLSKIP_c2p_registers:

	move.l Pllb_C2P_Chunky_Frame_bufferA(pc),a0
	move.l a0,a1
	bra.b Pllb_c2p_init_c2p_registers



Pllb_c2p_init_DELTANULLSKIP_c2p_registers:

	move.l Pllb_C2P_Chunky_Frame_bufferA(pc),a0
	move.l a0,a1
	bsr.b Pllb_c2p_init_c2p_registers

	move.l Pllb_C2p_DeltaNullSkip_buffer_pointer(pc),a6

	rts




Pllb_c2p_init_c2p_registers:

	Move.l Pllb_C2p_Temp_Image_buffer(pc),a2

	move.l Pllb_C2p_FastBuffer_PointerA(pc),a3
	move.l Pllb_C2p_FastBuffer_PointerB(pc),a4
	move.l Pllb_C2p_FastBuffer_PointerC(pc),a5
	move.l Pllb_C2p_FastBuffer_PointerD(pc),a6

	move.l #$ff00ff00,d2
	move.w PLLB_C2P_ChunkyScreenSize(pc),d7
	subq.l #1,d7
	rts



;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 256colour Pllb-C2P <<

;			    Single pixel Width

;			    512k fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_8bit_512K_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a4,a5,a6 not used

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_8bit_512K_1by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	bra.b Pllb_C2p_8bit_512K_1by1_skip
	nop
	nop
	nop

Pllb_C2p_8bit_512K_1by1_lp:
	
	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+		; pipelined Write to Chipram

Pllb_C2p_8bit_512K_1by1_skip:

	swap d0
	lsl.l #3,d0

	move.l (a3,d0.l),d3
	move.l 4(a3,d0.l),d4

		lsl.l #2,d3
	lsl.l #3,d1
		lsl.l #2,d4

	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

		lsl.l #2,d3
		lsl.l #2,d4

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a3,d0.l),d3
	or.l 4(a3,d0.l),d4

		lsl.l #2,d3
		lsl.l #2,d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


; store 8 planar bytes


	; d0 = bytes ABCD


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	move.l (a3,d0.l),d5
	move.l 4(a3,d0.l),d6

		lsl.l #2,d5
	lsl.l #3,d1
		lsl.l #2,d6

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		lsl.l #2,d5
		lsl.l #2,d6
		
	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a3,d0.l),d5
	or.l 4(a3,d0.l),d6

		lsl.l #2,d5
	lsl.l #3,d1
		lsl.l #2,d6

	move.l d3,d0		

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

				; resort the planar bytes into words 

	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1

	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1

	move.l d3,(a1)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d4
	or.l d6,d4

	dbf d7,Pllb_C2p_8bit_512K_1by1_lp

	move.l d4,(a1)+		; output last long word
	rts


Pllb_C2p_8bit_512K_1by1_APend






;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 256colour Pllb-C2P <<

;			    Single pixel Width

;			    1meg fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_8bit_1Meg_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a5,a6 not used

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_8bit_1Meg_1by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	bra.b Pllb_C2p_8bit_1Meg_1by1_skip
	nop
	nop
	nop

Pllb_C2p_8bit_1Meg_1by1_lp:
	
	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+		; pipelined Write to Chipram

Pllb_C2p_8bit_1Meg_1by1_skip:

	swap d0
	lsl.l #3,d0

	move.l (a4,d0.l),d3
	move.l 4(a4,d0.l),d4

		lsl.l #2,d3
	lsl.l #3,d1
		lsl.l #2,d4

	or.l (a4,d1.l),d3
	or.l 4(a4,d1.l),d4

		lsl.l #2,d3
		lsl.l #2,d4

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d3
	or.l 4(a4,d0.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	move.l (a4,d0.l),d5
	move.l 4(a4,d0.l),d6

		lsl.l #2,d5
	lsl.l #3,d1
		lsl.l #2,d6

	or.l (a4,d1.l),d5
	or.l 4(a4,d1.l),d6

		lsl.l #2,d5
		lsl.l #2,d6
		
	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	lsl.l #3,d1

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1

	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1

	move.l d3,(a1)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d4
	or.l d6,d4

	dbf d7,Pllb_C2p_8bit_1Meg_1by1_lp

	move.l d4,(a1)+		; output last long word
	rts


Pllb_C2p_8bit_1Meg_1by1_APend







;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 256colour Pllb-C2P <<

;			    Single pixel Width

;			   1.5meg fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_8bit_1_5meg_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a6 table not used

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_8bit_1_5meg_1by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	bra.b Pllb_C2p_8bit_1_5meg_1by1_skip
	nop
	nop
	nop

Pllb_C2p_8bit_1_5meg_1by1_lp:
	
	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+		; pipelined Write to Chipram

Pllb_C2p_8bit_1_5meg_1by1_skip:

	swap d0
	lsl.l #3,d0

	move.l (a5,d0.l),d3
	move.l 4(a5,d0.l),d4

		lsl.l #2,d3
	lsl.l #3,d1
		lsl.l #2,d4

	or.l (a5,d1.l),d3
	or.l 4(a5,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d3
	or.l 4(a4,d0.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	move.l (a5,d0.l),d5
	move.l 4(a5,d0.l),d6

		lsl.l #2,d5
	lsl.l #3,d1
		lsl.l #2,d6

	or.l (a5,d1.l),d5
	or.l 4(a5,d1.l),d6

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	lsl.l #3,d1

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1

	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1

	move.l d3,(a1)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d4
	or.l d6,d4

	dbf d7,Pllb_C2p_8bit_1_5meg_1by1_lp

	move.l d4,(a1)+		; output last long word
	rts


Pllb_C2p_8bit_1_5meg_1by1_APend




;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 256colour Pllb-C2P <<

;			    Single pixel Width

;			   2meg fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_8bit_2meg_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers


	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_8bit_2meg_1by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	bra.b Pllb_C2p_8bit_2meg_1by1_skip
	nop
	nop
	nop

Pllb_C2p_8bit_2meg_1by1_lp:
	
	; d0 = bytes ABCD

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+		; pipelined Write to Chipram

Pllb_C2p_8bit_2meg_1by1_skip:

	swap d0
	lsl.l #3,d0

	move.l (a6,d0.l),d3
	move.l 4(a6,d0.l),d4

	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.l 4(a5,d1.l),d4

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d3
	or.l 4(a4,d0.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	move.l (a6,d0.l),d5
	move.l 4(a6,d0.l),d6

	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.l 4(a5,d1.l),d6


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1

	move.l d3,(a1)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d4
	or.l d6,d4

	dbf d7,Pllb_C2p_8bit_2meg_1by1_lp

	move.l d4,(a1)+		; output last long word
	rts


Pllb_C2p_8bit_2meg_1by1_APend




;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Delta_8bit_512k_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

				; a4,a5,a6 tables 	NOT USED!

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_Delta_8bit_512k_1by1_AP:

Pllb_C2p_Delta_8bit_512k_1by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d5
	move.l (a0)+,d6
	move.l (a0)+,d0

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_8bit_512k_1by1_cont4

	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_8bit_512k_1by1_cont3

	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_8bit_512k_1by1_cont2

	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_8bit_512k_1by1_cont1

		add.w #16,a2

		dbf d7,Pllb_C2p_Delta_8bit_512k_1by1_LP

	rts
	nop

Pllb_C2p_Delta_8bit_512k_1by1_cont4:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_512k_1by1_cont3:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_512k_1by1_cont2:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_512k_1by1_cont1:


	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

	lsl.l #2,d3
	lsl.l #2,d4


	clr.l d1
	move.w d5,d1	

	clr.w d5
	swap d5

	lsl.l #3,d5
	lsl.l #3,d1

	or.l (a3,d5.l),d3
	or.l 4(a3,d5.l),d4

		lsl.l #2,d3
		lsl.l #2,d4

	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


; store 8 planar bytes


	; d0 = bytes ABCD

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a3,d6.l),d5
	move.l 4(a3,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		lsl.l #2,d5
		lsl.l #2,d6


	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	lsl.l #3,d1

	or.l (a3,d0.l),d5
	or.l 4(a3,d0.l),d6

		lsl.l #2,d5
		lsl.l #2,d6

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	

	dbf d7,Pllb_C2p_Delta_8bit_512k_1by1_LP

	rts


Pllb_C2p_Delta_8bit_512k_1by1_APEND:





;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   1 Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Delta_8bit_1Meg_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	; a5,a6 tables 	NOT USED!

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_Delta_8bit_1Meg_1by1_AP:

Pllb_C2p_Delta_8bit_1Meg_1by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d5
	move.l (a0)+,d6
	move.l (a0)+,d0

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_8bit_1Meg_1by1_cont4

	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_8bit_1Meg_1by1_cont3

	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_8bit_1Meg_1by1_cont2

	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_8bit_1Meg_1by1_cont1

		add.w #16,a2

		dbf d7,Pllb_C2p_Delta_8bit_1Meg_1by1_LP

	rts
	nop

Pllb_C2p_Delta_8bit_1Meg_1by1_cont4:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_1Meg_1by1_cont3:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_1Meg_1by1_cont2:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_1Meg_1by1_cont1:

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4

	move.l (a4,d4.l),d3
	move.l 4(a4,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	lsl.l #3,d1
	or.l (a4,d1.l),d3
	or.l 4(a4,d1.l),d4

		lsl.l #2,d3
		lsl.l #2,d4


	clr.l d1

	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a4,d5.l),d3
	or.l 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a4,d6.l),d5
	move.l 4(a4,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6

	lsl.l #3,d1
	or.l (a4,d1.l),d5
	or.l 4(a4,d1.l),d6

		lsl.l #2,d5
		lsl.l #2,d6


	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6



	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	

	dbf d7,Pllb_C2p_Delta_8bit_1Meg_1by1_LP

	rts


Pllb_C2p_Delta_8bit_1meg_1by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   1.5meg fastram version

;	-	-	-	-	-	-	-	-	-



Pllb_C2p_Delta_8bit_1_5Meg_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	; a6 not USED!

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_8bit_1_5Meg_1by1_AP:

Pllb_C2p_Delta_8bit_1_5Meg_1by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d5
	move.l (a0)+,d6
	move.l (a0)+,d0


	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_8bit_1_5Meg_1by1_cont4

	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_8bit_1_5Meg_1by1_cont3

	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_8bit_1_5Meg_1by1_cont2

	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_8bit_1_5Meg_1by1_cont1

		add.w #16,a2

		dbf d7,Pllb_C2p_Delta_8bit_1_5Meg_1by1_LP

	rts
	nop


Pllb_C2p_Delta_8bit_1_5Meg_1by1_cont4:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_1_5Meg_1by1_cont3:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_1_5Meg_1by1_cont2:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_1_5Meg_1by1_cont1:

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4

	move.l (a5,d4.l),d3
	move.l 4(a5,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.l 4(a5,d1.l),d4

	clr.l d1

	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	or.l (a4,d5.l),d3
	or.l 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a5,d6.l),d5
	move.l 4(a5,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6

	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.l 4(a5,d1.l),d6

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6



	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	

	dbf d7,Pllb_C2p_Delta_8bit_1_5Meg_1by1_LP

	rts


Pllb_C2p_Delta_8bit_1_5meg_1by1_APEND:







;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   2Meg fastram version

;	-	-	-	-	-	-	-	-	-



Pllb_C2p_Delta_8bit_2meg_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_8bit_2meg_1by1_AP:

Pllb_C2p_Delta_8bit_2meg_1by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d5
	move.l (a0)+,d6
	move.l (a0)+,d0


	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_8bit_2meg_1by1_cont4

	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_8bit_2meg_1by1_cont3

	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_8bit_2meg_1by1_cont2

	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_8bit_2meg_1by1_cont1

		add.w #16,a2

		dbf d7,Pllb_C2p_Delta_8bit_2meg_1by1_LP

	rts
	nop


Pllb_C2p_Delta_8bit_2meg_1by1_cont4:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_2meg_1by1_cont3:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_2meg_1by1_cont2:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_2meg_1by1_cont1:


	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4

	move.l (a6,d4.l),d3
	move.l 4(a6,d4.l),d4

	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.l 4(a5,d1.l),d4

	clr.l d1


	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	or.l (a4,d5.l),d3
	or.l 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a6,d6.l),d5
	move.l 4(a6,d6.l),d6

	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.l 4(a5,d1.l),d6

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	

	dbf d7,Pllb_C2p_Delta_8bit_2meg_1by1_LP

	rts


Pllb_C2p_Delta_8bit_2meg_1by1_APEND:




;	-	-	-	-	-	-	-	-	-

;		    >> NULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NullSkip_8bit_512k_1by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a4,a5,d6 tables are NOT USED

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NullSkip_8bit_512k_1by1_AP:

Pllb_C2p_NullSkip_8bit_512k_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NullSkip_8bit_512k_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_NullSkip_8bit_512k_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_NullSkip_8bit_512k_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_NullSkip_8bit_512k_1by1_Cont1

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+
		
		dbf d7,Pllb_C2p_NullSkip_8bit_512k_1by1_LP

	rts
	nop


Pllb_C2p_NullSkip_8bit_512k_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_NullSkip_8bit_512k_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_NullSkip_8bit_512k_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_NullSkip_8bit_512k_1by1_Cont1:

		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	lsl.l #3,d1
	or.l (a3,d5.l),d3
	or.l 4(a3,d5.l),d4
		lsl.l #2,d3
		lsl.l #2,d4
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a3,d6.l),d5
	move.l 4(a3,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	lsl.l #3,d1

	or.l (a3,d0.l),d5
	or.l 4(a3,d0.l),d6

		lsl.l #2,d5
		lsl.l #2,d6

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_NullSkip_8bit_512k_1by1_LP

	rts


Pllb_C2p_NullSkip_8bit_512k_1by1_APEND:








;	-	-	-	-	-	-	-	-	-

;		    >> NULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   1meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NullSkip_8bit_1Meg_1by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a5,a6 	tables not used

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NullSkip_8bit_1Meg_1by1_AP:


Pllb_C2p_NullSkip_8bit_1Meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NullSkip_8bit_1Meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_NullSkip_8bit_1Meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_NullSkip_8bit_1Meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_NullSkip_8bit_1Meg_1by1_Cont1

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+
		
		dbf d7,Pllb_C2p_NullSkip_8bit_1Meg_1by1_LP

	rts
	nop


Pllb_C2p_NullSkip_8bit_1Meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_NullSkip_8bit_1Meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_NullSkip_8bit_1Meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_NullSkip_8bit_1Meg_1by1_Cont1:


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4

	; d0 = bytes ABCD

	lsl.l #3,d4
	lsl.l #3,d1
	move.l (a4,d4.l),d3
	move.l 4(a4,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	or.l (a4,d1.l),d3
	or.l 4(a4,d1.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	lsl.l #3,d1

	or.l (a4,d5.l),d3
	or.l 4(a4,d5.l),d4

	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a4,d6.l),d5
	move.l 4(a4,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


	or.l (a4,d1.l),d5
	or.l 4(a4,d1.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_NullSkip_8bit_1Meg_1by1_LP

	rts


Pllb_C2p_NullSkip_8bit_1meg_1by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		    >> NULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   1.5meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NullSkip_8bit_1_5Meg_1by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a6 not used

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_AP:


Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_Cont1

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+
		
		dbf d7,Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_LP

	rts
	nop


Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_Cont1:


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4

	lsl.l #3,d4


	move.l (a5,d4.l),d3
	move.l 4(a5,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.l 4(a5,d1.l),d4

	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	or.l (a4,d5.l),d3
	or.l 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a5,d6.l),d5
	move.l 4(a5,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.l 4(a5,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels



	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6
	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_NullSkip_8bit_1_5Meg_1by1_LP

	rts


Pllb_C2p_NullSkip_8bit_1_5meg_1by1_APEND:





;	-	-	-	-	-	-	-	-	-

;		    >> NULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   2meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NullSkip_8bit_2meg_1by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NullSkip_8bit_2meg_1by1_AP:


Pllb_C2p_NullSkip_8bit_2meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NullSkip_8bit_2meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_NullSkip_8bit_2meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_NullSkip_8bit_2meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_NullSkip_8bit_2meg_1by1_Cont1

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+
		
		dbf d7,Pllb_C2p_NullSkip_8bit_2meg_1by1_LP

	rts
	nop


Pllb_C2p_NullSkip_8bit_2meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_NullSkip_8bit_2meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_NullSkip_8bit_2meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_NullSkip_8bit_2meg_1by1_Cont1:


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4

	lsl.l #3,d4

	move.l (a6,d4.l),d3
	move.l 4(a6,d4.l),d4

	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.l 4(a5,d1.l),d4

	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	or.l (a4,d5.l),d3
	or.l 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a6,d6.l),d5
	move.l 4(a6,d6.l),d6

	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.l 4(a5,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels



	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_NullSkip_8bit_2meg_1by1_LP

	rts


Pllb_C2p_NullSkip_8bit_2meg_1by1_APEND:








;	-	-	-	-	-	-	-	-	-

;		>> DELTANULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_8bit_512k_1by1:

	bsr Pllb_c2p_init_DELTANULLSKIP_c2p_registers

	; a4,a5 tables are NOT USED


	move.l #16,a5

	; a6 = pointer to the second Frame Buffer.


	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_AP:

Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_Cont1

	tst.b (a6)
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_nodelta

		add.l a5,a2
		add.l a5,a1

		addq.l #1,a6
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_LP

	rts


Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_nodelta:

		clr.l (a2)+
		add.l a5,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+

		clr.b (a6)+
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_LP

	rts
	nop


Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_Cont1:

	clr.l (a1)+		; clear 4 chunky source pixels


	clr.l d1
	move.w d4,d1	
	clr.w d4


	st.b (a6)+		; Set DElta nullskip flag for this 16
				; pixels
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	lsl.l #3,d1
	or.l (a3,d5.l),d3
	or.l 4(a3,d5.l),d4
		lsl.l #2,d3
		lsl.l #2,d4
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a3,d6.l),d5
	move.l 4(a3,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	lsl.l #3,d1

	or.l (a3,d0.l),d5
	or.l 4(a3,d0.l),d6

		lsl.l #2,d5
		lsl.l #2,d6

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_LP

	rts


Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_APEND:










;	-	-	-	-	-	-	-	-	-

;		    >> DeltaNULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   1meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	; a5

	move.l #16,a5

	;a6='s pointer to the Compare cleared buffer

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_AP:


Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_Cont1


	tst.b (a6)
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_nodelta

		add.l a5,a1
		add.l a5,a2

		addq.l #1,a6
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_LP

	rts


Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_nodelta:

		clr.l (a2)+
		add.l a5,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+

		clr.b (a6)+
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_LP
	rts
	nop


Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_Cont1:


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4

		st.b (a6)+

	swap d4

	; d0 = bytes ABCD

	lsl.l #3,d4
	lsl.l #3,d1
	move.l (a4,d4.l),d3
	move.l 4(a4,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	or.l (a4,d1.l),d3
	or.l 4(a4,d1.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	lsl.l #3,d1

	or.l (a4,d5.l),d3
	or.l 4(a4,d5.l),d4

	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a4,d6.l),d5
	move.l 4(a4,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


	or.l (a4,d1.l),d5
	or.l 4(a4,d1.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1Meg_1by1_LP

	rts


Pllb_C2p_DeltaNullSkip_8bit_1meg_1by1_APEND:











;	-	-	-	-	-	-	-	-	-

;		 >> DELTANULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Single pixel Width

;			   1.5meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	; a6 not used

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_AP:


Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_Cont1


	moveq.l #16,d0

	tst.b (a6)
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_nodelta

		add.l d0,a1
		add.l d0,a2

		addq.l #1,a6
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_LP

	rts


Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_nodelta:

		clr.l (a2)+
		add.l d0,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+

		clr.b (a6)+
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_LP


	rts
	nop


Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_Cont1:


		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4


		st.b (a6)+
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a5,d4.l),d3
	move.l 4(a5,d4.l),d4
		lsl.l #2,d3
		lsl.l #2,d4


	or.l (a5,d1.l),d3
	or.l 4(a5,d1.l),d4

	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	or.l (a4,d5.l),d3
	or.l 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 chunky source pixels

	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a5,d6.l),d5
	move.l 4(a5,d6.l),d6
		lsl.l #2,d5
		lsl.l #2,d6


	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.l 4(a5,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels



	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.l 4(a4,d0.l),d6
	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

		clr.l (a1)+		; clear 4 chunky source pixels

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1_5Meg_1by1_LP

	rts


Pllb_C2p_DeltaNullSkip_8bit_1_5meg_1by1_APEND:











;	-	-	-	-	-	-	-	-	-

;		       >> Normal 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_8bit_512k_2by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_8bit_512k_2by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	nop
	nop
	nop
	bra.b Pllb_C2p_8bit_512k_2by1_Skip	

Pllb_C2p_8bit_512k_2by1_lp:

	
	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+	

Pllb_C2p_8bit_512k_2by1_Skip:


	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	move.l (a3,d0.l),d3
	move.l 4(a3,d0.l),d4

		lsl.l #4,d3
		lsl.l #4,d4


	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0

	lsl.l #3,d0

	lsl.l #3,d1

	move.l (a3,d0.l),d5
	move.l 4(a3,d0.l),d6

	lsl.l #4,d5
	lsl.l #4,d6

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


		move.l d3,(a1)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

	lsl.l #8,d4
	or.l d6,d4

	dbf d7,Pllb_C2p_8bit_512k_2by1_lp

	move.l d4,(a1)+		; write outstanding long word
	rts


Pllb_C2p_8bit_512k_2by1_APEnd:











;	-	-	-	-	-	-	-	-	-

;		       >> Normal 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   1meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_8bit_1meg_2by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_8bit_1meg_2by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	nop
	nop
	nop
	bra.b Pllb_C2p_8bit_1meg_2by1_Skip	

Pllb_C2p_8bit_1meg_2by1_lp:

	
	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+	

Pllb_C2p_8bit_1meg_2by1_Skip:


	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	move.l (a4,d0.l),d3
	move.l 4(a4,d0.l),d4


	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0

	lsl.l #3,d0

	lsl.l #3,d1

	move.l (a4,d0.l),d5
	move.l 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


		move.l d3,(a1)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

	lsl.l #8,d4
	or.l d6,d4

	dbf d7,Pllb_C2p_8bit_1meg_2by1_lp

	move.l d4,(a1)+		; write outstanding long word
	rts


Pllb_C2p_8bit_1meg_2by1_APEnd:




;	-	-	-	-	-	-	-	-	-


;		       >> DELTA 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Delta_8bit_512k_2by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_8bit_512k_2by1_AP:


Pllb_C2p_Delta_8bit_512k_2by1_lp:

	move.l (a0)+,d4
	move.l (a0)+,d6

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_8bit_512k_2by1_cont2
	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_8bit_512k_2by1_cont1

		add.w #16,a2
	
		dbf d7,Pllb_C2p_Delta_8bit_512k_2by1_lp

	rts
	nop


Pllb_C2p_Delta_8bit_512k_2by1_cont2:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_512k_2by1_cont1:

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a4,d4.l),d3
	move.l 4(a4,d4.l),d4

	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a4,d6.l),d5
	move.l 4(a4,d6.l),d6
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_Delta_8bit_512k_2by1_lp

	rts


Pllb_C2p_Delta_8bit_512k_2by1_APEND:




;	-	-	-	-	-	-	-	-	-

;		       >> DELTA 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   1meg fastram version

;	-	-	-	-	-	-	-	-	-



Pllb_C2p_Delta_8bit_1meg_2by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_8bit_1meg_2by1_AP:


Pllb_C2p_Delta_8bit_1meg_2by1_lp:

	move.l (a0)+,d4
	move.l (a0)+,d6

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_8bit_1meg_2by1_cont2
	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_8bit_1meg_2by1_cont1

		add.w #16,a2
	
		dbf d7,Pllb_C2p_Delta_8bit_1meg_2by1_lp

	rts
	nop


Pllb_C2p_Delta_8bit_1meg_2by1_cont2:

	addq.l #4,a1

Pllb_C2p_Delta_8bit_1meg_2by1_cont1:

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a4,d4.l),d3
	move.l 4(a4,d4.l),d4

	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a4,d6.l),d5
	move.l 4(a4,d6.l),d6
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_Delta_8bit_1meg_2by1_lp

	rts


Pllb_C2p_Delta_8bit_1meg_2by1_APEND:




;	-	-	-	-	-	-	-	-	-

;		   >> NULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NUllSkip_8bit_512k_2by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NUllSkip_8bit_512k_2by1_AP:


Pllb_C2p_NUllSkip_8bit_512k_2by1_Lp:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NUllSkip_8bit_512k_2by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_NUllSkip_8bit_512k_2by1_CONT1

		clr.l (a2)+
			addq.l #8,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+

		dbf d7,Pllb_C2p_NUllSkip_8bit_512k_2by1_Lp

	rts
	nop


Pllb_C2p_NUllSkip_8bit_512k_2by1_CONT2:

	move.l (a0)+,d6


Pllb_C2p_NUllSkip_8bit_512k_2by1_CONT1:

	clr.l (a1)+	; clear chunky pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4
		lsl.l #4,d3
		lsl.l #4,d4
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4



	clr.l (a1)+		; clear chunky pixels 


	; d0 = bytes ABCD


	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a3,d6.l),d5
	move.l 4(a3,d6.l),d6
		lsl.l #4,d5
		lsl.l #4,d6
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+

	dbf d7,Pllb_C2p_NUllSkip_8bit_512k_2by1_LP

	rts


Pllb_C2p_NUllSkip_8bit_512k_2by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		   >> NULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   1Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NUllSkip_8bit_1Meg_2by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NUllSkip_8bit_1Meg_2by1_AP:


Pllb_C2p_NUllSkip_8bit_1Meg_2by1_Lp:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NUllSkip_8bit_1Meg_2by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_NUllSkip_8bit_1Meg_2by1_CONT1

		clr.l (a2)+
			addq.l #8,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+


		dbf d7,Pllb_C2p_NUllSkip_8bit_1Meg_2by1_Lp

	rts
	nop


Pllb_C2p_NUllSkip_8bit_1Meg_2by1_CONT2:

	move.l (a0)+,d6


Pllb_C2p_NUllSkip_8bit_1Meg_2by1_CONT1:

	clr.l (a1)+	; clear chunky pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4
		lsl.l #4,d3
		lsl.l #4,d4
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4



	clr.l (a1)+		; clear chunky pixels 


	; d0 = bytes ABCD


	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a3,d6.l),d5
	move.l 4(a3,d6.l),d6
		lsl.l #4,d5
		lsl.l #4,d6
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+

	dbf d7,Pllb_C2p_NUllSkip_8bit_1Meg_2by1_LP

	rts


Pllb_C2p_NUllSkip_8bit_1Meg_2by1_APEND:










;	-	-	-	-	-	-	-	-	-

;		   >> DELTANULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_8bit_512k_2by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers


	move.l #16,a5

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


	

Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_AP:


Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_Lp:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_CONT1


	tst.b (a6)+
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_nodelta

		addq.l #8,a1
		add.l a5,a2
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_LP

	rts
	nop

Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_nodelta:


		clr.l (a2)+
			addq.l #8,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)

		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_Lp

	rts
	nop


Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_CONT2:

	move.l (a0)+,d6


Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_CONT1:

	clr.l (a1)+	; clear chunky pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4

		st.b (a6)+

	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4
		lsl.l #4,d3
		lsl.l #4,d4
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4



	clr.l (a1)+		; clear chunky pixels 


	; d0 = bytes ABCD


	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a3,d6.l),d5
	move.l 4(a3,d6.l),d6
		lsl.l #4,d5
		lsl.l #4,d6
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+



	dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_LP

	rts


Pllb_C2p_DeltaNullSkip_8bit_512k_2by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		   >> DeltaNullSkip/CLEAR 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   1Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	move.l #16,a5

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_AP:

toss:

Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_Lp:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_CONT1

	tst.b (a6)+
	bne.b Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_nodelta

		addq.l #8,a1
		add.l a5,a2
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_LP

	rts
	nop

Pllb_C2p_DeltaNullSkip_8bit_1meg_2by1_nodelta:


		clr.l (a2)+
			addq.l #8,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)

		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1meg_2by1_Lp

	rts
	nop





Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_CONT2:

	move.l (a0)+,d6


Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_CONT1:

	clr.l (a1)+	; clear chunky pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4

	st.b (a6)+


	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4
		lsl.l #4,d3
		lsl.l #4,d4
	or.l (a3,d1.l),d3
	or.l 4(a3,d1.l),d4



	clr.l (a1)+		; clear chunky pixels 


	; d0 = bytes ABCD


	clr.l d1

	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a3,d6.l),d5
	move.l 4(a3,d6.l),d6
		lsl.l #4,d5
		lsl.l #4,d6
	or.l (a3,d1.l),d5
	or.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+

	dbf d7,Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_LP

	rts


Pllb_C2p_DeltaNullSkip_8bit_1Meg_2by1_APEND:





;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;--------------------------4by1 NORMAL VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------


;	-	-	-	-	-	-	-	-	-

;		       >> Normal 256 colour Pllb-C2P <<

;			    QUAD pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_8bit_512k_4by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_8bit_512k_4by1_AP:


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	nop
	nop
	nop
	bra.b Pllb_C2p_8bit_512k_4by1_SKIP


Pllb_C2p_8bit_512k_4by1_lp:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	

	clr.w d0

		move.l d4,(a1)+		; write the last longword


Pllb_C2p_8bit_512k_4by1_SKIP:

	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	move.l (a3,d0.l),d3
	move.l 4(a3,d0.l),d4

	move.l (a3,d1.l),d5
	move.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


		move.l d3,(a1)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

	lsl.l #8,d4
	or.l d6,d4


	dbf d7,Pllb_C2p_8bit_512k_4by1_lp

	move.l d4,(a1)+		; write outstanding long word
	rts



Pllb_C2p_8bit_512k_4by1_APEND:






;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;--------------------------4by1 DELTA VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------


;	-	-	-	-	-	-	-	-	-

;		       >> DELTA 256 colour Pllb-C2P <<

;			    QUAD pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DELTA_8bit_512k_4by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DELTA_8bit_512k_4by1_AP:


Pllb_C2p_DELTA_8bit_512k_4by1_lp:

	move.l (a0)+,d4

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_DELTA_8bit_512k_4by1_CONT

		add.w #16,a2
	
		dbf d7,Pllb_C2p_DELTA_8bit_512k_4by1_lp
	rts
	nop


Pllb_C2p_DELTA_8bit_512k_4by1_CONT:

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4

	lsl.l #3,d1
	move.l (a3,d1.l),d5
	move.l 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	
	dbf d7,Pllb_C2p_DELTA_8bit_512k_4by1_lp

	rts


Pllb_C2p_DELTA_8bit_512k_4by1_APEND:




;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;--------------------------4by1 NULLSKIP VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------


;	-	-	-	-	-	-	-	-	-

;		  >> NULLSKIP/CLEAR 256 colour Pllb-C2P <<

;			    QUAD pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NULLSKIP_8bit_512k_4by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NULLSKIP_8bit_512k_4by1_AP:


Pllb_C2p_NULLSKIP_8bit_512k_4by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NULLSKIP_8bit_512k_4by1_CONT

		clr.l (a2)+
			addq.l #4,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+
		dbf d7,Pllb_C2p_NULLSKIP_8bit_512k_4by1_LP

	rts
	nop


Pllb_C2p_NULLSKIP_8bit_512k_4by1_CONT:


	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4

	move.l (a3,d1.l),d5
	move.l 4(a3,d1.l),d6


		clr.l (a1)+	; clear chunky

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2



	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	dbf d7,Pllb_C2p_NULLSKIP_8bit_512k_4by1_LP
	
	rts


Pllb_C2p_NULLSKIP_8bit_512k_4by1_APEND:










;	-	-	-	-	-	-	-	-	-

;		  >> DeltaNullSkip/CLEAR 256 colour Pllb-C2P <<

;			    QUAD pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_8bit_512k_4by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	move.l #16,a5	; constant 

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_AP:


Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_CONT

	tst.b (a6)+
	bne.b Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_nodelta


		addq.l #4,a1
		add.w a5,a2
		
		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_LP

	rts
	nop
	nop

Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_nodelta:

		clr.l (a2)+
			addq.l #4,a1
		clr.l (a2)+
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)

		dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_Lp

	rts
	nop


Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_CONT:

	st.b (a6)+		

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.l 4(a3,d4.l),d4

	move.l (a3,d1.l),d5
	move.l 4(a3,d1.l),d6


		clr.l (a1)+	; clear chunky

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3

		move.l d4,d0		

	or.l d5,d3

		move.l d6,d1


	move.l d3,(a2)+		; d3 = b1b2d1d2


	and.l d2,d0
	and.l d2,d1

	eor.l d0,d4
	eor.l d1,d6

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d4
	or.l d6,d4

	move.l d4,(a2)+
	dbf d7,Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_LP
	
	rts


Pllb_C2p_DeltaNullSkip_8bit_512k_4by1_APEND:












;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 64colour Pllb-C2P <<

;			    Single pixel Width

;			    512k fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_6bit_512k_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a4/a5/a6 table not used/needed

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_6bit_512k_1by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	bra.b Pllb_C2p_6bit_512k_1by1_skip
	nop
	nop
	nop

Pllb_C2p_6bit_512k_1by1_lp:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+

Pllb_C2p_6bit_512k_1by1_skip:

	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	move.l (a3,d0.l),d3
	move.w 4(a3,d0.l),d4

	lsl.l #2,d3
	lsl.w #2,d4


	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

	lsl.l #2,d3
	lsl.w #2,d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a3,d0.l),d3
	or.w 4(a3,d0.l),d4

	lsl.l #2,d3
	lsl.w #2,d4


	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1
	move.l (a3,d0.l),d5
	move.w 4(a3,d0.l),d6

	lsl.l #2,d5
	lsl.w #2,d6


	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	lsl.l #2,d5
	lsl.w #2,d6

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a3,d0.l),d5
	or.w 4(a3,d0.l),d6

	lsl.l #2,d5
	lsl.w #2,d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a1)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

	dbf d7,Pllb_C2p_6bit_512k_1by1_lp

	move.l d4,(a1)+		; write final 32bits

	rts


Pllb_C2p_6bit_512k_1by1_APEND:




;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 64colour Pllb-C2P <<

;			    Single pixel Width

;			    1meg fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_6bit_1Meg_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a5/a6 table not used/needed

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_6bit_1Meg_1by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	bra.b Pllb_C2p_6bit_1Meg_1by1_skip
	nop
	nop
	nop

Pllb_C2p_6bit_1Meg_1by1_lp:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+

Pllb_C2p_6bit_1Meg_1by1_skip:

	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	move.l (a4,d0.l),d3
	move.w 4(a4,d0.l),d4

	lsl.l #2,d3
	lsl.w #2,d4


	or.l (a4,d1.l),d3
	or.w 4(a4,d1.l),d4

	lsl.l #2,d3
	lsl.w #2,d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d3
	or.w 4(a4,d0.l),d4

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1
	move.l (a4,d0.l),d5
	move.w 4(a4,d0.l),d6

		lsl.l #2,d5
		lsl.w #2,d6

	or.l (a4,d1.l),d5
	or.w 4(a4,d1.l),d6

		lsl.l #2,d5
		lsl.w #2,d6

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a1)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

	dbf d7,Pllb_C2p_6bit_1Meg_1by1_lp

	move.l d4,(a1)+		; write final 32bits

	rts


Pllb_C2p_6bit_1Meg_1by1_APEND:







;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 64colour Pllb-C2P <<

;			    Single pixel Width

;			    1.5meg fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_6bit_1_5Meg_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a6 table not used/needed

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_6bit_1_5Meg_1by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	bra.b Pllb_C2p_6bit_1_5Meg_1by1_skip
	nop
	nop
	nop

Pllb_C2p_6bit_1_5Meg_1by1_lp:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+

Pllb_C2p_6bit_1_5Meg_1by1_skip:

	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	move.l (a5,d0.l),d3
	move.w 4(a5,d0.l),d4

	lsl.l #2,d3
	lsl.l #2,d4


	or.l (a5,d1.l),d3
	or.w 4(a5,d1.l),d4

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d3
	or.w 4(a4,d0.l),d4


	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1
	move.l (a5,d0.l),d5
	move.w 4(a5,d0.l),d6

		lsl.l #2,d5
		lsl.w #2,d6


	or.l (a5,d1.l),d5
	or.w 4(a5,d1.l),d6

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a1)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

	dbf d7,Pllb_C2p_6bit_1_5Meg_1by1_lp

	move.l d4,(a1)+		; write final 32bits

	rts


Pllb_C2p_6bit_1_5Meg_1by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 64colour Pllb-C2P <<

;			    Single pixel Width

;			    2meg fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_6bit_2Meg_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	blk.w 32,$4e71		; insert NOP's for routine alignment system


Pllb_C2p_6bit_2Meg_1by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	bra.b Pllb_C2p_6bit_2Meg_1by1_skip
	nop
	nop
	nop

Pllb_C2p_6bit_2Meg_1by1_lp:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+

Pllb_C2p_6bit_2Meg_1by1_skip:

	swap d0
	lsl.l #3,d0

	move.l (a6,d0.l),d3
	move.w 4(a6,d0.l),d4

	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.w 4(a5,d1.l),d4

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d3
	or.w 4(a4,d0.l),d4

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	move.l (a6,d0.l),d5
	move.w 4(a6,d0.l),d6

	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.w 4(a5,d1.l),d6

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a1)+		; d3 = b1b2d1d2



	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

	dbf d7,Pllb_C2p_6bit_2Meg_1by1_lp

	move.l d4,(a1)+		; write final 32bits

	rts



Pllb_C2p_6bit_2Meg_1by1_APEND:



; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ------------------------------DELTA 6bit Version----------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------




;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-



Pllb_C2p_Delta_6bit_512k_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	; a5/ a6	tables are not needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_6bit_512k_1by1_AP:

Pllb_C2p_Delta_6bit_512k_1by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d5
	move.l (a0)+,d6
	move.l (a0)+,d0


	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_6bit_512k_1by1_Cont4
	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_6bit_512k_1by1_Cont3
	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_6bit_512k_1by1_Cont2
	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_6bit_512k_1by1_Cont1

		add.w #12,a2

		dbf d7,Pllb_C2p_Delta_6bit_512k_1by1_LP

	rts
;	nop


Pllb_C2p_Delta_6bit_512k_1by1_Cont4:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_512k_1by1_Cont3:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_512k_1by1_Cont2:
	addq.l #4,a1

Pllb_C2p_Delta_6bit_512k_1by1_Cont1:

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		lsl.l #2,d3
		lsl.w #2,d4

	clr.l d1
			;	move.l (a0)+,d0
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a3,d5.l),d3
	or.w 4(a3,d5.l),d4
		lsl.l #2,d3
		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a3,d6.l),d5
	move.w 4(a3,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6


	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6
  		lsl.l #2,d5
		lsl.w #2,d6


	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a3,d0.l),d5
	or.w 4(a3,d0.l),d6

		lsl.l #2,d5
		lsl.w #2,d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a2)+		; d3 = b1b2d1d2



	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	
		move.l d4,(a2)+		; d4 = f1f2e1e2

	dbf d7,Pllb_C2p_Delta_6bit_512k_1by1_LP
	rts

Pllb_C2p_Delta_6bit_512k_1by1_APEND:








;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   1Meg fastram version

;	-	-	-	-	-	-	-	-	-



Pllb_C2p_Delta_6bit_1Meg_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	; a5/ a6	tables are not needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_6bit_1Meg_1by1_AP:

Pllb_C2p_Delta_6bit_1Meg_1by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d5
	move.l (a0)+,d6
	move.l (a0)+,d0


	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_6bit_1Meg_1by1_Cont4
	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_6bit_1Meg_1by1_Cont3
	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_6bit_1Meg_1by1_Cont2
	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_6bit_1Meg_1by1_Cont1

		add.w #12,a2
	

		dbf d7,Pllb_C2p_Delta_6bit_1Meg_1by1_LP

	rts
;	nop


Pllb_C2p_Delta_6bit_1Meg_1by1_Cont4:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_1Meg_1by1_Cont3:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_1Meg_1by1_Cont2:
	addq.l #4,a1

Pllb_C2p_Delta_6bit_1Meg_1by1_Cont1:

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a4,d4.l),d3
	move.w 4(a4,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	or.l (a4,d1.l),d3
	or.w 4(a4,d1.l),d4

		lsl.l #2,d3
		lsl.w #2,d4

	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a4,d5.l),d3
	or.w 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a4,d6.l),d5
	move.w 4(a4,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6


	lsl.l #3,d1
	or.l (a4,d1.l),d5
	or.w 4(a4,d1.l),d6
  		lsl.l #2,d5
		lsl.w #2,d6


	clr.l d1
		;	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a2)+		; d3 = b1b2d1d2



	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	
		move.l d4,(a2)+		; d4 = f1f2e1e2


	dbf d7,Pllb_C2p_Delta_6bit_1Meg_1by1_LP
	rts


Pllb_C2p_Delta_6bit_1meg_1by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   1.5Meg fastram version

;	-	-	-	-	-	-	-	-	-



Pllb_C2p_Delta_6bit_1_5meg_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	; a6

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_6bit_1_5meg_1by1_AP:

Pllb_C2p_Delta_6bit_1_5meg_1by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d5
	move.l (a0)+,d6
	move.l (a0)+,d0


	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_6bit_1_5meg_1by1_Cont4
	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_6bit_1_5meg_1by1_Cont3
	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_6bit_1_5meg_1by1_Cont2
	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_6bit_1_5meg_1by1_Cont1

		add.w #12,a2
	

		dbf d7,Pllb_C2p_Delta_6bit_1_5meg_1by1_LP

	rts
;	nop


Pllb_C2p_Delta_6bit_1_5meg_1by1_Cont4:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_1_5meg_1by1_Cont3:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_1_5meg_1by1_Cont2:
	addq.l #4,a1

Pllb_C2p_Delta_6bit_1_5meg_1by1_Cont1:

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a5,d4.l),d3
	move.w 4(a5,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	or.l (a5,d1.l),d3
	or.w 4(a5,d1.l),d4

	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	lsl.l #3,d1

	or.l (a4,d5.l),d3
	or.w 4(a4,d5.l),d4

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a5,d6.l),d5
	move.w 4(a5,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6

	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.w 4(a5,d1.l),d6


	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a2)+		; d3 = b1b2d1d2



	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	
		move.l d4,(a2)+		; d4 = f1f2e1e2


	dbf d7,Pllb_C2p_Delta_6bit_1_5meg_1by1_LP
	rts


Pllb_C2p_Delta_6bit_1_5meg_1by1_APEND:







;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   2Meg fastram version

;	-	-	-	-	-	-	-	-	-



Pllb_C2p_Delta_6bit_2meg_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_6bit_2meg_1by1_AP:

Pllb_C2p_Delta_6bit_2meg_1by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d5
	move.l (a0)+,d6
	move.l (a0)+,d0


	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_6bit_2meg_1by1_Cont4
	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_6bit_2meg_1by1_Cont3
	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_6bit_2meg_1by1_Cont2
	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_6bit_2meg_1by1_Cont1

		add.w #12,a2
	

		dbf d7,Pllb_C2p_Delta_6bit_2meg_1by1_LP

	rts
	nop


Pllb_C2p_Delta_6bit_2meg_1by1_Cont4:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_2meg_1by1_Cont3:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_2meg_1by1_Cont2:
	addq.l #4,a1

Pllb_C2p_Delta_6bit_2meg_1by1_Cont1:

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4

	swap d4
	lsl.l #3,d4

	move.l (a6,d4.l),d3
	move.w 4(a6,d4.l),d4

;		lsl.l #2,d3
;		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.w 4(a5,d1.l),d4

;		lsl.l #2,d3
;		lsl.w #2,d4

	clr.l d1
			;	move.l (a0)+,d0
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a4,d5.l),d3
	or.w 4(a4,d5.l),d4
;		lsl.l #2,d3
;		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


; store 8 planar bytes


	; d0 = bytes ABCD


	clr.l d1
		;	move.l (a0)+,d0
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a6,d6.l),d5
	move.w 4(a6,d6.l),d6
;		lsl.l #2,d5
;		lsl.w #2,d6


	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.w 4(a5,d1.l),d6
  ;		lsl.l #2,d5
;		lsl.w #2,d6


	clr.l d1
		;	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

;		lsl.l #2,d5
;		lsl.w #2,d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a2)+		; d3 = b1b2d1d2



	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	
		move.l d4,(a2)+		; d4 = f1f2e1e2


	dbf d7,Pllb_C2p_Delta_6bit_2meg_1by1_LP
	rts


Pllb_C2p_Delta_6bit_2meg_1by1_APEND:








;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;----------------------------NULLSKIP VERSIONS------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		    >> NULLSKIP/CLEAR 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NullSkip_6bit_512k_1by1:


	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a4,a5,a6 tables are NOT USED

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NullSkip_6bit_512k_1by1_AP:


Pllb_C2p_NullSkip_6bit_512k_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NullSkip_6bit_512k_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_NullSkip_6bit_512k_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_NullSkip_6bit_512k_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_NullSkip_6bit_512k_1by1_Cont1

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+

		dbf d7,Pllb_C2p_NullSkip_6bit_512k_1by1_LP


	rts
	nop

Pllb_C2p_NullSkip_6bit_512k_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_NullSkip_6bit_512k_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_NullSkip_6bit_512k_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_NullSkip_6bit_512k_1by1_Cont1:

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4

	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	clr.l (a1)+		; clear 4 source chunky pixels


	clr.l d1
			;	move.l (a0)+,d0
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a3,d5.l),d3
	or.w 4(a3,d5.l),d4
		lsl.l #2,d3
		lsl.w #2,d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a3,d6.l),d5
	move.w 4(a3,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6
  		lsl.l #2,d5
		lsl.w #2,d6

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1
	or.l (a3,d0.l),d5
	or.w 4(a3,d0.l),d6

  		lsl.l #2,d5
		lsl.w #2,d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


		clr.l (a1)+		; clear 4 source chunky pixels



	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2

	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2

	dbf d7,Pllb_C2p_NullSkip_6bit_512k_1by1_LP
	rts


Pllb_C2p_NullSkip_6bit_512k_1by1_APEND:




;	-	-	-	-	-	-	-	-	-

;		    >> NULLSKIP/CLEAR 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   1Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NullSkip_6bit_1meg_1by1:


	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a5,a6 tables are NOT USED

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NullSkip_6bit_1meg_1by1_AP:


Pllb_C2p_NullSkip_6bit_1meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NullSkip_6bit_1meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_NullSkip_6bit_1meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_NullSkip_6bit_1meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_NullSkip_6bit_1meg_1by1_Cont1

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+
		dbf d7,Pllb_C2p_NullSkip_6bit_1meg_1by1_LP


	rts
	nop

Pllb_C2p_NullSkip_6bit_1meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_NullSkip_6bit_1meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_NullSkip_6bit_1meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_NullSkip_6bit_1meg_1by1_Cont1:

		clr.l (a1)+		; clear 4 source chunky pixels

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4

	move.l (a4,d4.l),d3
	move.w 4(a4,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a4,d1.l),d3
	or.w 4(a4,d1.l),d4

		lsl.l #2,d3
		lsl.w #2,d4

		clr.l (a1)+		; clear 4 source chunky pixels


	clr.l d1
			;	move.l (a0)+,d0
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a4,d5.l),d3
	or.w 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a4,d6.l),d5
	move.w 4(a4,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6


	lsl.l #3,d1
	or.l (a4,d1.l),d5
	or.w 4(a4,d1.l),d6
  		lsl.l #2,d5
		lsl.w #2,d6

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6



		clr.l (a1)+		; clear 4 source chunky pixels



	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2

	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2

	dbf d7,Pllb_C2p_NullSkip_6bit_1meg_1by1_LP
	rts


Pllb_C2p_NullSkip_6bit_1meg_1by1_APEND:





;	-	-	-	-	-	-	-	-	-

;		    >> NULLSKIP/CLEAR 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   1.5Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NullSkip_6bit_1_5meg_1by1:


	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a6 tables are NOT USED

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NullSkip_6bit_1_5meg_1by1_AP:


Pllb_C2p_NullSkip_6bit_1_5meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NullSkip_6bit_1_5meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_NullSkip_6bit_1_5meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_NullSkip_6bit_1_5meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_NullSkip_6bit_1_5meg_1by1_Cont1

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+


		dbf d7,Pllb_C2p_NullSkip_6bit_1_5meg_1by1_LP


	rts
	nop

Pllb_C2p_NullSkip_6bit_1_5meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_NullSkip_6bit_1_5meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_NullSkip_6bit_1_5meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_NullSkip_6bit_1_5meg_1by1_Cont1:

		clr.l (a1)+		; clear 4 source chunky pixels

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4

	move.l (a5,d4.l),d3
	move.w 4(a5,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.w 4(a5,d1.l),d4


		clr.l (a1)+		; clear 4 source chunky pixels


	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a4,d5.l),d3
	or.w 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a5,d6.l),d5
	move.w 4(a5,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6


	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.w 4(a5,d1.l),d6

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


		clr.l (a1)+		; clear 4 source chunky pixels


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		

		lsl.l #8,d3

	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a2)+		; d3 = b1b2d1d2



	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2

	dbf d7,Pllb_C2p_NullSkip_6bit_1_5meg_1by1_LP
	rts


Pllb_C2p_NullSkip_6bit_1_5meg_1by1_APEND:







;	-	-	-	-	-	-	-	-	-

;		    >> NULLSKIP/CLEAR 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   2Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NullSkip_6bit_2Meg_1by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a4,a5,d6 tables are NOT USED

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NullSkip_6bit_2Meg_1by1_AP:


Pllb_C2p_NullSkip_6bit_2Meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NullSkip_6bit_2Meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_NullSkip_6bit_2Meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_NullSkip_6bit_2Meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_NullSkip_6bit_2Meg_1by1_Cont1

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+
		dbf d7,Pllb_C2p_NullSkip_6bit_2Meg_1by1_LP


	rts
	nop

Pllb_C2p_NullSkip_6bit_2Meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_NullSkip_6bit_2Meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_NullSkip_6bit_2Meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_NullSkip_6bit_2Meg_1by1_Cont1:

		clr.l (a1)+		; clear 4 source chunky pixels


	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a6,d4.l),d3
	move.w 4(a6,d4.l),d4

	or.l (a5,d1.l),d3
	or.w 4(a5,d1.l),d4

		clr.l (a1)+		; clear 4 source chunky pixels


	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5
	lsl.l #3,d1

	or.l (a4,d5.l),d3
	or.w 4(a4,d5.l),d4

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a6,d6.l),d5
	move.w 4(a6,d6.l),d6

	or.l (a5,d1.l),d5
	or.w 4(a5,d1.l),d6
	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

		clr.l (a1)+		; clear 4 source chunky pixels

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a2)+		; d3 = b1b2d1d2



	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2

	dbf d7,Pllb_C2p_NullSkip_6bit_2Meg_1by1_LP
	rts


Pllb_C2p_NullSkip_6bit_2meg_1by1_APEND:












;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;------------------------DELTA NULLSKIP VERSIONS----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		    >> DeltaNullSkip/CLEAR 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_6bit_512k_1by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	move.l #16,a5

	; a4,a5,a6 tables are NOT USED

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_AP:


Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_Cont1

	tst.b (a6)+
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_nodelta

		add.l a5,a1
		add.w #12,a2

;		addq.l #1,a6		
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_LP
	rts


Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_nodelta:

		clr.l (a2)+
		add.l a5,a1
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)
		
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_LP

	rts
	nop

Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_Cont1:

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d4,d1	
	clr.w d4

		st.b (a6)+


	swap d4
	lsl.l #3,d4

	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	clr.l (a1)+		; clear 4 source chunky pixels


	clr.l d1
			;	move.l (a0)+,d0
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a3,d5.l),d3
	or.w 4(a3,d5.l),d4
		lsl.l #2,d3
		lsl.w #2,d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a3,d6.l),d5
	move.w 4(a3,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6
  		lsl.l #2,d5
		lsl.w #2,d6

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1
	or.l (a3,d0.l),d5
	or.w 4(a3,d0.l),d6

  		lsl.l #2,d5
		lsl.w #2,d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


		clr.l (a1)+		; clear 4 source chunky pixels



	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2

	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2

	dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_LP
	rts


Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_APEND:










;	-	-	-	-	-	-	-	-	-

;		    >> DeltaNullSkip/CLEAR 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   1Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	move.l #16,a5

	; a5,a6 tables are NOT USED

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_AP:


Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_Cont1


	tst.b (a6)+
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1Meg_1by1_nodelta

		add.l a5,a1
		add.w #12,a2
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1Meg_1by1_LP
	rts


Pllb_C2p_DeltaNullSkip_6bit_1Meg_1by1_nodelta:

		clr.l (a2)+
		add.l a5,a1
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)	
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1Meg_1by1_LP

	rts
	nop

Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_Cont1:

		clr.l (a1)+		; clear 4 source chunky pixels

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	

	clr.w d4

		st.b (a6)+

	swap d4
	lsl.l #3,d4

	move.l (a4,d4.l),d3
	move.w 4(a4,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a4,d1.l),d3
	or.w 4(a4,d1.l),d4

		lsl.l #2,d3
		lsl.w #2,d4

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
			;	move.l (a0)+,d0
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a4,d5.l),d3
	or.w 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a4,d6.l),d5
	move.w 4(a4,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6


	lsl.l #3,d1
	or.l (a4,d1.l),d5
	or.w 4(a4,d1.l),d6
  		lsl.l #2,d5
		lsl.w #2,d6

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


		clr.l (a1)+		; clear 4 source chunky pixels


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		


		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2

	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2

	dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_LP
	rts


Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_APEND:





;	-	-	-	-	-	-	-	-	-

;		    >> DeltaNullSkip/CLEAR 64 colour Pllb-C2P <<

;			    Single pixel Width

;			   1.5Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1:


	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	; a6 tables are NOT USED

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_AP:


Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_Cont4
	move.l (a0)+,d5
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_Cont3
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_Cont2
	move.l (a0)+,d0
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_Cont1

	tst.b (a6)+
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1_5Meg_1by1_nodelta

		add.w #16,a1
		add.w #12,a2
		
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1_5Meg_1by1_LP
	rts


Pllb_C2p_DeltaNullSkip_6bit_1_5Meg_1by1_nodelta:

		clr.l (a2)+
		add.w #16,a1
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)
		
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1_5Meg_1by1_LP


	rts
	nop

Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_Cont4:

	move.l (a0)+,d5

Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_Cont3:

	move.l (a0)+,d6

Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_Cont2:

	move.l (a0)+,d0

Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_Cont1:

		clr.l (a1)+		; clear 4 source chunky pixels

	; d0 = bytes ABCD

	clr.l d1
	move.w d4,d1	
	clr.w d4
		st.b (a6)+

	swap d4
	lsl.l #3,d4

	move.l (a5,d4.l),d3
	move.w 4(a5,d4.l),d4

		lsl.l #2,d3
		lsl.w #2,d4


	lsl.l #3,d1
	or.l (a5,d1.l),d3
	or.w 4(a5,d1.l),d4


		clr.l (a1)+		; clear 4 source chunky pixels


	clr.l d1
	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #3,d5

	or.l (a4,d5.l),d3
	or.w 4(a4,d5.l),d4

	lsl.l #3,d1
	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4

		clr.l (a1)+		; clear 4 source chunky pixels

	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a5,d6.l),d5
	move.w 4(a5,d6.l),d6
		lsl.l #2,d5
		lsl.w #2,d6


	lsl.l #3,d1
	or.l (a5,d1.l),d5
	or.w 4(a5,d1.l),d6

	clr.l d1
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0
	lsl.l #3,d1

	or.l (a4,d0.l),d5
	or.w 4(a4,d0.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


		clr.l (a1)+		; clear 4 source chunky pixels


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		

		lsl.l #8,d3

	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a2)+		; d3 = b1b2d1d2



	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2

	dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_LP
	rts


Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_APEND:










;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;--------------------------2by1 NORMAL VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------



;	-	-	-	-	-	-	-	-	-

;		       >> Normal 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_6bit_512k_2by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a4,a5,a6 not used

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_6bit_512k_2by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	nop
	nop
	nop
	bra.b Pllb_C2p_6bit_512k_2by1_Skip	

Pllb_C2p_6bit_512k_2by1_lp:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+		; write the last longword

Pllb_C2p_6bit_512k_2by1_SKIP:


	swap d0
	lsl.l #3,d0

	move.l (a3,d0.l),d3
	move.w 4(a3,d0.l),d4

		lsl.l #4,d3
		lsl.w #4,d4

	lsl.l #3,d1

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4



	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	move.l (a3,d0.l),d5
	move.w 4(a3,d0.l),d6

		lsl.l #4,d5
		lsl.w #4,d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2



		move.l d3,(a1)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	


	dbf d7,Pllb_C2p_6bit_512k_2by1_lp

	move.l d4,(a1)+		; write outstanding long word
	rts

Pllb_C2p_6bit_512k_2by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		       >> Normal 256 colour Pllb-C2P <<

;			    Double pixel Width

;			   1meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_6bit_1meg_2by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a5,a6 not needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_6bit_1meg_2by1_AP:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	nop
	nop
	nop
	bra.b Pllb_C2p_6bit_1meg_2by1_Skip	

Pllb_C2p_6bit_1meg_2by1_lp:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0

		move.l d4,(a1)+		; write the last longword

Pllb_C2p_6bit_1meg_2by1_SKIP:

	swap d0
	lsl.l #3,d0

	move.l (a4,d0.l),d3
	move.w 4(a4,d0.l),d4

	lsl.l #3,d1

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #3,d0

	move.l (a4,d0.l),d5
	move.w 4(a4,d0.l),d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2


		move.l d3,(a1)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

	dbf d7,Pllb_C2p_6bit_1meg_2by1_lp

		move.l d4,(a1)+		; write outstanding long word
	rts

Pllb_C2p_6bit_1Meg_2by1_APEND:






;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------2by1 DELTA VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------





;	-	-	-	-	-	-	-	-	-

;		       >> DELTA 64 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Delta_6bit_512k_2by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_6bit_512k_2by1_AP:


Pllb_C2p_Delta_6bit_512k_2by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d6

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_6bit_512k_2by1_Cont2

	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_6bit_512k_2by1_Cont1

		add.w #12,a2
	

		dbf d7,Pllb_C2p_Delta_6bit_512k_2by1_LP

	rts
	nop


Pllb_C2p_Delta_6bit_512k_2by1_Cont2:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_512k_2by1_Cont1:


	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

		lsl.l #4,d3
		lsl.w #4,d4


	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a3,d6.l),d5
	move.w 4(a3,d6.l),d6

		lsl.l #4,d5
		lsl.w #4,d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	
		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5

	dbf d7,Pllb_C2p_Delta_6bit_512k_2by1_LP

	rts


Pllb_C2p_Delta_6bit_512k_2by1_APEND:




;	-	-	-	-	-	-	-	-	-

;		       >> DELTA 64 colour Pllb-C2P <<

;			    Double pixel Width

;			   1Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Delta_6bit_1Meg_2by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_6bit_1Meg_2by1_AP:


Pllb_C2p_Delta_6bit_1Meg_2by1_LP:

	move.l (a0)+,d4
	move.l (a0)+,d6

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_6bit_1Meg_2by1_Cont2

	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_6bit_1Meg_2by1_Cont1

		add.w #12,a2
	

		dbf d7,Pllb_C2p_Delta_6bit_1Meg_2by1_LP

	rts
	nop


Pllb_C2p_Delta_6bit_1Meg_2by1_Cont2:

	addq.l #4,a1

Pllb_C2p_Delta_6bit_1Meg_2by1_Cont1:


	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a4,d4.l),d3
	move.w 4(a4,d4.l),d4

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4


	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6
	lsl.l #3,d1

	move.l (a4,d6.l),d5
	move.w 4(a4,d6.l),d6

	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	
		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5

	dbf d7,Pllb_C2p_Delta_6bit_1Meg_2by1_LP

	rts


Pllb_C2p_Delta_6bit_1Meg_2by1_APEND:









;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------2by1 NULLSKIP VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------


;	-	-	-	-	-	-	-	-	-

;		   >> NULLSKIP/CLEAR 64 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NUllSkip_6bit_512k_2by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NUllSkip_6bit_512k_2by1_AP:


Pllb_C2p_NUllSkip_6bit_512k_2by1_Lp:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NUllSkip_6bit_512k_2by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_NUllSkip_6bit_512k_2by1_CONT1

		clr.l (a2)+
		addq.l #8,a1
		clr.l (a2)+
		clr.l (a2)+

		dbf d7,Pllb_C2p_NUllSkip_6bit_512k_2by1_Lp


	rts
	nop


Pllb_C2p_NUllSkip_6bit_512k_2by1_CONT2:

	move.l (a0)+,d6


Pllb_C2p_NUllSkip_6bit_512k_2by1_CONT1:

	clr.l (a1)+	; clear 4 pixels of source chunky

	clr.l d1
	move.w d4,d1	

	clr.w d4

	swap d4
	lsl.l #3,d4

	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

		lsl.l #4,d3
		lsl.w #4,d4

	lsl.l #3,d1

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4



	clr.l (a1)+	; clear source chunky 4pixels



	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a3,d6.l),d5
	move.w 4(a3,d6.l),d6

		lsl.l #4,d5
		lsl.w #4,d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5


	dbf d7,Pllb_C2p_NUllSkip_6bit_512k_2by1_Lp

	rts


Pllb_C2p_NUllSkip_6bit_512k_2by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		   >> NULLSKIP/CLEAR 64 colour Pllb-C2P <<

;			    Double pixel Width

;			   1Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NUllSkip_6bit_1Meg_2by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NUllSkip_6bit_1Meg_2by1_AP:


Pllb_C2p_NUllSkip_6bit_1Meg_2by1_Lp:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NUllSkip_6bit_1Meg_2by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_NUllSkip_6bit_1Meg_2by1_CONT1

		clr.l (a2)+
		addq.l #8,a1
		clr.l (a2)+
		clr.l (a2)+
	
		dbf d7,Pllb_C2p_NUllSkip_6bit_1Meg_2by1_Lp

	rts
	nop


Pllb_C2p_NUllSkip_6bit_1Meg_2by1_CONT2:

	move.l (a0)+,d6


Pllb_C2p_NUllSkip_6bit_1Meg_2by1_CONT1:

	clr.l (a1)+	; clear 4 pixels of source chunky

	clr.l d1
	move.w d4,d1	

	clr.w d4

	swap d4
	lsl.l #3,d4

	move.l (a4,d4.l),d3
	move.w 4(a4,d4.l),d4

	lsl.l #3,d1

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4



	clr.l (a1)+	; clear source chunky 4pixels



	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a4,d6.l),d5
	move.w 4(a4,d6.l),d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5

	dbf d7,Pllb_C2p_NUllSkip_6bit_1Meg_2by1_Lp
	rts


Pllb_C2p_NUllSkip_6bit_1Meg_2by1_APEND:







;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;------------------------2by1 DELTA NULLSKIP VERSIONS-----------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------


;	-	-	-	-	-	-	-	-	-

;		   >> DeltaNullSkip/CLEAR 64 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_6bit_512k_2by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	move.l #12,a5

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_AP:


Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_Lp:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_CONT1

	tst.b (a6)+
	bne.w Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_nodelta


		addq.l #8,a1
		add.w a5,a2
		
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_LP

	rts
	nop

Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_nodelta:


		clr.l (a2)+
			addq.l #8,a1
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)

		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_Lp


	rts
	nop


Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_CONT2:

	move.l (a0)+,d6


Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_CONT1:

	clr.l (a1)+	; clear 4 pixels of source chunky

	clr.l d1
	move.w d4,d1	

	clr.w d4


		st.b (a6)+

	swap d4
	lsl.l #3,d4

	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

		lsl.l #4,d3
		lsl.w #4,d4

	lsl.l #3,d1

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4



	clr.l (a1)+	; clear source chunky 4pixels



	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a3,d6.l),d5
	move.w 4(a3,d6.l),d6

		lsl.l #4,d5
		lsl.w #4,d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5


	dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_Lp

	rts


Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		   >> DeltaNullSkip/CLEAR 64 colour Pllb-C2P <<

;			    Double pixel Width

;			   1Meg fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	move.l #12,a5

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_AP:


Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_Lp:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_CONT1




	tst.b (a6)+
	bne.w Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_nodelta


		addq.l #8,a1
		add.w a5,a2
		
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_LP

	rts
	nop

Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_nodelta:


		clr.l (a2)+
			addq.l #8,a1
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)

		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_Lp

	rts
	nop


Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_CONT2:

	move.l (a0)+,d6


Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_CONT1:

	clr.l (a1)+	; clear 4 pixels of source chunky

	clr.l d1
	move.w d4,d1	

	clr.w d4

		st.b (a6)+

	swap d4
	lsl.l #3,d4

	move.l (a4,d4.l),d3
	move.w 4(a4,d4.l),d4

	lsl.l #3,d1

	or.l (a3,d1.l),d3
	or.w 4(a3,d1.l),d4



	clr.l (a1)+	; clear source chunky 4pixels



	clr.l d1
	move.w d6,d1	
	clr.w d6
	swap d6
	lsl.l #3,d6

	move.l (a4,d6.l),d5
	move.w 4(a4,d6.l),d6

	lsl.l #3,d1
	or.l (a3,d1.l),d5
	or.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		

		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5

	dbf d7,Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_Lp
	rts


Pllb_C2p_DeltaNullSkip_6bit_1Meg_2by1_APEND:








;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;--------------------------4by1 NORMAL VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------


;	-	-	-	-	-	-	-	-	-

;		       >> Normal 64 colour Pllb-C2P <<

;			    QUAD pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_6bit_512k_4by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_6bit_512k_4by1_AP:


	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	
	clr.w d0
	nop
	nop
	nop
	bra.b Pllb_C2p_6bit_512k_4by1_SKIP


Pllb_C2p_6bit_512k_4by1_lp:

	clr.l d1
	move.l (a0)+,d0
	move.w d0,d1	

	clr.w d0

		move.l d4,(a1)+		; write the last longword


Pllb_C2p_6bit_512k_4by1_SKIP:


	swap d0
	lsl.l #3,d0

	move.l (a3,d0.l),d3
	move.w 4(a3,d0.l),d4

	lsl.l #3,d1

	move.l (a3,d1.l),d5
	move.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a1)+		
	
		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a1)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	
	dbf d7,Pllb_C2p_6bit_512k_4by1_lp

	move.l d4,(a1)+		; write outstanding long word
	rts


Pllb_C2p_6bit_512k_4by1_APEND:




;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;--------------------------4by1 DELTA VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------


;	-	-	-	-	-	-	-	-	-

;		       >> DELTA 64 colour Pllb-C2P <<

;			    QUAD pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DELTA_6bit_512k_4by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment

Pllb_C2p_DELTA_6bit_512k_4by1_AP:


Pllb_C2p_DELTA_6bit_512k_4by1_LP:

	move.l (a0)+,d4
	cmp.l (a1)+,d4
	bne.b Pllb_C2p_DELTA_6bit_512k_4by1_Cont

		add.w #12,a2
		dbf d7,Pllb_C2p_DELTA_6bit_512k_4by1_LP
	rts

Pllb_C2p_DELTA_6bit_512k_4by1_CONT:

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1
	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

	move.l (a3,d1.l),d5
	move.w 4(a3,d1.l),d6

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		
	
		lsl.l #8,d3


	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5


	dbf d7,Pllb_C2p_DELTA_6bit_512k_4by1_LP

	rts



Pllb_C2p_DELTA_6bit_512k_4by1_APEND:




;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;--------------------------4by1 NULLSKIP VERSIONS-----------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		       >> NULLSKIP/CLEAR 64 colour Pllb-C2P <<

;			    QUAD pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NULLSKIP_6bit_512k_4by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NULLSKIP_6bit_512k_4by1_AP:

Pllb_C2p_NULLSKIP_6bit_512k_4by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_NULLSKIP_6bit_512k_4by1_Cont

		clr.l (a2)+
		addq.l #4,a1
		clr.l (a2)+
		clr.l (a2)+


		dbf d7,Pllb_C2p_NULLSKIP_6bit_512k_4by1_LP

	rts
	nop

Pllb_C2p_NULLSKIP_6bit_512k_4by1_Cont:

	clr.l d1
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

	move.l (a3,d1.l),d5
	move.w 4(a3,d1.l),d6

	clr.l (a1)+

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		
	
		lsl.l #8,d3

	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5


		dbf d7,Pllb_C2p_NULLSKIP_6bit_512k_4by1_lp
	rts

Pllb_C2p_NULLSKIP_6bit_512k_4by1_APEND:












;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;-----------------------4by1 DELTA NULLSKIP VERSIONS------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		       >> DeltaNullSkip/CLEAR 64 colour Pllb-C2P <<

;			    QUAD pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_6bit_512k_4by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	move.l #12,a5

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_AP:

Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_LP:

	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_Cont


	tst.b (a6)+
	bne.b Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_nodelta


		addq.l #4,a1
		add.w a5,a2
		
		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_LP

	rts
	nop
	nop

Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_nodelta:


		clr.l (a2)+
			addq.l #4,a1
		clr.l (a2)+
		clr.l (a2)+

		clr.b -1(a6)

		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_Lp

	rts
	nop

Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_Cont:

	clr.l d1
	st.b (a6)+
	move.w d4,d1	
	clr.w d4
	swap d4
	lsl.l #3,d4
	lsl.l #3,d1

	move.l (a3,d4.l),d3
	move.w 4(a3,d4.l),d4

	move.l (a3,d1.l),d5
	move.w 4(a3,d1.l),d6

	clr.l (a1)+

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

		move.l d0,(a2)+		
	
		lsl.l #8,d3

	move.w d4,d0		;----e1f1
	swap d4			;e1f1----

		or.l d5,d3


	move.w d6,d4		;e1f1e2f2

		move.l d3,(a2)+		; d3 = b1b2d1d2


	rol.w #8,d4		;e1f1f2e2
	move.b d4,d0		;----e1e2
	lsl.l #8,d4		;f1f2e2--
	move.w d0,d4		;f1f2e1e2
	

		move.l d4,(a2)+		; d4 = f1f2e1e2	 planes 6,5


		dbf d7,Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_lp
	rts

Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_APEND:








;	-	-	-	-	-	-	-	-	-

;		       >> NORMAL 16colour Pllb-C2P <<

;			    Single pixel Width

;			    512k fastram version

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_4bit_512K_1by1:

	bsr Pllb_c2p_init_Normal_c2p_registers

	; a4,a5,a6 not used

	; init a4 to point to a3+256k

	move.l a3,a4
	add.l #4*$10000,a4
	
	blk.w 32,$4e71		; insert NOP's for routine alignment system

Pllb_C2p_4bit_512K_1by1_AP:


	move.l (a0)+,d0
	clr.l d1
	lsl.l #4,d0
	or.l (a0)+,d0

	bra.b Pllb_C2p_4bit_512K_1by1_skip
	nop
	nop
	nop

Pllb_C2p_4bit_512K_1by1_lp:
	
	move.l (a0)+,d0
	clr.l d1
	lsl.l #4,d0
	or.l (a0)+,d0

		move.l d3,(a1)+		; d3 = b1b2d1d2

Pllb_C2p_4bit_512K_1by1_Skip:

	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #2,d0

	move.l (a4,d0.l),d3
	lsl.l #2,d1
	or.l (a3,d1.l),d3


	move.l (a0)+,d0
	clr.l d1
	lsl.l #4,d0
	or.l (a0)+,d0

	move.w d0,d1	
	clr.w d0
	swap d0
	lsl.l #2,d0

	move.l (a4,d0.l),d5
	lsl.l #2,d1
	or.l (a3,d1.l),d5
 
	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d3
	or.l d5,d3


	dbf d7,Pllb_C2p_4bit_512K_1by1_lp

		move.l d3,(a1)+		; d3 = b1b2d1d2

	rts


Pllb_C2p_4bit_512K_1by1_APEND:






; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ------------------------------DELTA 4bit Version----------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		      >> DELTA 16 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Delta_4bit_512k_1by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	; a4/a5/a6	tables are NOT needed

	move.l a3,a4
	add.l #4*$10000,a4


	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_Delta_4bit_512k_1by1_AP:

Pllb_C2p_Delta_4bit_512k_1by1_LP:



	move.l (a0)+,d5
	move.l (a0)+,d4
	move.l (a0)+,d0
	move.l (a0)+,d6

	cmp.l (a1)+,d5
	bne.b Pllb_C2p_Delta_4bit_512k_1by1_Cont4

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_Delta_4bit_512k_1by1_Cont3

	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_4bit_512k_1by1_Cont2

	cmp.l (a1)+,d6
	bne.b Pllb_C2p_Delta_4bit_512k_1by1_Cont1

		addq.l #8,a2

		dbf d7,Pllb_C2p_Delta_4bit_512k_1by1_LP

	rts
	nop


Pllb_C2p_Delta_4bit_512k_1by1_Cont4:

	addq.l #4,a1

Pllb_C2p_Delta_4bit_512k_1by1_Cont3:

	addq.l #4,a1

Pllb_C2p_Delta_4bit_512k_1by1_Cont2:

	addq.l #4,a1

Pllb_C2p_Delta_4bit_512k_1by1_Cont1:

	lsl.l #4,d5
	clr.l d1
	or.l d4,d5

	move.w d5,d1	
	clr.w d5
	swap d5
	lsl.l #2,d5
	lsl.l #2,d1

	move.l (a4,d5.l),d3
	or.l (a3,d1.l),d3


	lsl.l #4,d0
	clr.l d1

	or.l d6,d0
	move.w d0,d1	

	clr.w d0
	swap d0

	lsl.l #2,d0
	lsl.l #2,d1
	move.l (a4,d0.l),d5
	or.l (a3,d1.l),d5
 
	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1

	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3
	or.l d5,d3

	move.l d3,(a2)+		; d3 = b1b2d1d2


	dbf d7,Pllb_C2p_Delta_4bit_512k_1by1_lp

	rts


Pllb_C2p_Delta_4bit_512k_1by1_APEND:


; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ---------------------------NULLSKIP 4bit Version----------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		  >> NULLSKIP/CLEAR 16 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NULLSKIP_4bit_512k_1by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a4/a5/a6	tables are NOT needed

	move.l a3,a4
	add.l #4*$10000,a4

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment

Pllb_C2p_NULLSKIP_4bit_512k_1by1_AP:

Pllb_C2p_NULLSKIP_4bit_512k_1by1_LP:

	move.l (a0)+,d5
	bne.b Pllb_C2p_NULLSKIP_4bit_512k_1by1_CONT4
	move.l (a0)+,d4
	bne.b Pllb_C2p_NULLSKIP_4bit_512k_1by1_CONT3
	move.l (a0)+,d0
	bne.b Pllb_C2p_NULLSKIP_4bit_512k_1by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_NULLSKIP_4bit_512k_1by1_CONT1

		clr.l (a2)+

		add.w #16,a1

		clr.l (a2)+

		dbf d7,Pllb_C2p_NULLSKIP_4bit_512k_1by1_LP
	

		rts
		nop


Pllb_C2p_NULLSKIP_4bit_512k_1by1_CONT4:

	move.l (a0)+,d4

Pllb_C2p_NULLSKIP_4bit_512k_1by1_CONT3:

	move.l (a0)+,d0

Pllb_C2p_NULLSKIP_4bit_512k_1by1_CONT2:

	move.l (a0)+,d6

Pllb_C2p_NULLSKIP_4bit_512k_1by1_CONT1:

		clr.l (a1)+		; clear source chunky 4 pixels


	lsl.l #4,d5
	clr.l d1
	or.l d4,d5
	move.w d5,d1	

		clr.l (a1)+		; clear source chunky 4 pixels

	clr.w d5
	swap d5
	lsl.l #2,d5
	lsl.l #2,d1

	move.l (a4,d5.l),d3
	or.l (a3,d1.l),d3


		clr.l (a1)+		; clear source chunky 4 pixels

	lsl.l #4,d0
	clr.l d1
	or.l d6,d0
	move.w d0,d1	

		clr.l (a1)+		; clear source chunky 4 pixels

	clr.w d0
	swap d0
	lsl.l #2,d0
	lsl.l #2,d1

	move.l (a4,d0.l),d5
	or.l (a3,d1.l),d5
 

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1

	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3
	or.l d5,d3

	move.l d3,(a2)+		; d3 = b1b2d1d2



	dbf d7,Pllb_C2p_NULLSKIP_4bit_512k_1by1_LP
	rts


Pllb_C2p_NULLSKIP_4bit_512k_1by1_APEND:









; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; -------------------------DELTA NULLSKIP 4bit Version------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		  >> DeltaNullSkip/CLEAR 16 colour Pllb-C2P <<

;			    Single pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_4bit_512k_1by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	; a4/a5/a6	tables are NOT needed

	move.l a3,a4
	add.l #4*$10000,a4

	move.l #16,a5


	blk.w 32,$4e71		; insert NOP's to ensure routine alignment

Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_AP:

Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_LP:

	move.l (a0)+,d5
	bne.b Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_CONT4
	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_CONT3
	move.l (a0)+,d0
	bne.b Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_CONT2
	move.l (a0)+,d6
	bne.b Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_CONT1


	tst.b (a6)
	bne.b Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_nodelta

		add.l a5,a1
		add.l #8,a2
		
		addq.l #1,a6		
		dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_LP
	rts

Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_nodelta:

		clr.l (a2)+
		add.l a5,a1
		clr.l (a2)+
		clr.b (a6)+
		
		dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_LP
	
		rts
		nop


Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_CONT4:

	move.l (a0)+,d4

Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_CONT3:

	move.l (a0)+,d0

Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_CONT2:

	move.l (a0)+,d6

Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_CONT1:

		st.b (a6)+

	lsl.l #4,d5
	clr.l d1
	or.l d4,d5
	move.w d5,d1	

		clr.l (a1)+		; clear source chunky 4 pixels

	clr.w d5
	swap d5
	lsl.l #2,d5
	lsl.l #2,d1

	move.l (a4,d5.l),d3
	or.l (a3,d1.l),d3


		clr.l (a1)+		; clear source chunky 4 pixels

	lsl.l #4,d0
	clr.l d1
	or.l d6,d0
	move.w d0,d1	

		clr.l (a1)+		; clear source chunky 4 pixels

	clr.w d0
	swap d0
	lsl.l #2,d0
	lsl.l #2,d1

	move.l (a4,d0.l),d5
	or.l (a3,d1.l),d5
 


		clr.l (a1)+		; clear source chunky 4 pixels

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1

	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3
	or.l d5,d3

	move.l d3,(a2)+		; d3 = b1b2d1d2



	dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_LP
	rts


Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_APEND:






; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ------------------------------NORMAL 4bit Version---------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		         >> 16 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_4bit_512k_2by1:

	bsr Pllb_c2p_init_NORMAL_c2p_registers

	; a4/a5/a6	tables are NOT needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_4bit_512k_2by1_AP:

	move.l (a0)+,d0
	move.l (a0)+,d4
	move.w d0,d1
	move.w d4,d6
	nop
	nop
	nop
	bra.b Pllb_C2p_4bit_512k_2by1_SKIP

Pllb_C2p_4bit_512k_2by1_LP:

	move.l (a0)+,d0
	move.l (a0)+,d4
	move.w d0,d1
	move.w d4,d6
		move.l d3,(a1)+		; d3 = b1b2d1d2


Pllb_C2p_4bit_512k_2by1_SKIP:


	clr.w d0
		clr.w d4
	swap d0
		swap d4

	lsl.w #4,d0
	lsl.w #4,d4

	or.w d1,d0
	or.w d6,d4

	lsl.l #2,d0
	lsl.l #2,d4

	move.l (a3,d0.l),d3
	move.l (a3,d4.l),d5


	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a1)+		

	lsl.l #8,d3
	or.l d5,d3


	dbf d7,Pllb_C2p_4bit_512k_2by1_LP

		move.l d3,(a1)+		; d3 = b1b2d1d2
	rts

Pllb_C2p_4bit_512k_2by1_APEND:









; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ------------------------------DELTA 4bit Version---------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		        >> DELTA 16 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DELTA_4bit_512k_2by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	; a4/a5/a6	tables are NOT needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DELTA_4bit_512k_2by1_AP:

Pllb_C2p_DELTA_4bit_512k_2by1_LP:

	move.l (a0)+,d5
	move.l (a0)+,d4

	cmp.l (a1)+,d5
	bne.b Pllb_C2p_DELTA_4bit_512k_2by1_cont2

	cmp.l (a1)+,d4
	bne.b Pllb_C2p_DELTA_4bit_512k_2by1_cont1

		addq.l #8,a2
	

		dbf d7,Pllb_C2p_DELTA_4bit_512k_2by1_LP

		rts

Pllb_C2p_DELTA_4bit_512k_2by1_cont2:

	addq.l #4,a1
	nop

Pllb_C2p_DELTA_4bit_512k_2by1_cont1:

	move.w d5,d1
	move.w d4,d3
	clr.w d4
	clr.w d5
	swap d5
	swap d4

	lsl.w #4,d5
 	lsl.w #4,d4
	or.w d1,d5
	or.w d3,d4
	lsl.l #2,d5
	lsl.l #2,d4
	move.l (a3,d5.l),d3
	move.l (a3,d4.l),d5

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3
	or.l d5,d3

	move.l d3,(a2)+		; d3 = b1b2d1d2


	dbf d7,Pllb_C2p_DELTA_4bit_512k_2by1_LP
	rts


Pllb_C2p_DELTA_4bit_512k_2by1_APEND:









; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------NULLSKIP 4bit Version---------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		     >> NULLSKIP/ClEAR 16 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NULLSKIP_4bit_512k_2by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a4/a5/a6	tables are NOT needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment



Pllb_C2p_NULLSKIP_4bit_512k_2by1_AP:

Pllb_C2p_NULLSKIP_4bit_512k_2by1_LP:

	move.l (a0)+,d5
	bne.b Pllb_C2p_NULLSKIP_4bit_512k_2by1_Cont2
	move.l (a0)+,d4
	bne.b Pllb_C2p_NULLSKIP_4bit_512k_2by1_Cont1

		clr.l (a2)+
		addq.l #8,a1
		clr.l (a2)+
		dbf d7,Pllb_C2p_NULLSKIP_4bit_512k_2by1_LP
	rts
	nop


Pllb_C2p_NULLSKIP_4bit_512k_2by1_Cont2:

	move.l (a0)+,d4

Pllb_C2p_NULLSKIP_4bit_512k_2by1_Cont1:
	
		clr.l (a1)+		; clear 4 chunky pixels


	move.w d5,d1
	move.w d4,d3
	clr.w d4
	clr.w d5
	swap d5
	swap d4


		clr.l (a1)+		; clear 4 chunky pixels


	lsl.w #4,d5
 	lsl.w #4,d4
	or.w d1,d5
	or.w d3,d4
	lsl.l #2,d5
	lsl.l #2,d4
	move.l (a3,d5.l),d3
	move.l (a3,d4.l),d5

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3
	or.l d5,d3

	move.l d3,(a2)+		; d3 = b1b2d1d2

	dbf d7,Pllb_C2p_NULLSKIP_4bit_512k_2by1_lp

	rts


Pllb_C2p_NULLSKIP_4bit_512k_2by1_APEND:









; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ------------------------DELTA NULLSKIP 4bit Version-------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		     >> DeltaNullSkip/ClEAR 16 colour Pllb-C2P <<

;			    Double pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_4bit_512k_2by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	; a4/a5/a6	tables are NOT needed


	move.l #8,a5

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment



Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_AP:

Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_LP:

	move.l (a0)+,d5
	bne.b Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_Cont2
	move.l (a0)+,d4
	bne.b Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_Cont1


	tst.b (a6)
	bne.w Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_nodelta

		add.l a5,a1
		addq.l #8,a2
		
		addq.l #1,a6		
		dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_LP
	rts

Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_nodelta:

		clr.l (a2)+
		add.l a5,a1
		clr.l (a2)+
		clr.b (a6)+
		
		dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_LP


	rts
	nop


Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_Cont2:

	move.l (a0)+,d4

Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_Cont1:
	
		st.b (a6)+


	move.w d5,d1
	move.w d4,d3
	clr.w d4
	clr.w d5
	swap d5
	swap d4


		clr.l (a1)+		; clear 4 chunky pixels


	lsl.w #4,d5
 	lsl.w #4,d4
	or.w d1,d5
	or.w d3,d4
	lsl.l #2,d5
	lsl.l #2,d4
	move.l (a3,d5.l),d3
	move.l (a3,d4.l),d5



		clr.l (a1)+		; clear 4 chunky pixels

	move.l d3,d0		
	move.l d5,d1

	and.l d2,d0
	and.l d2,d1

	eor.l d0,d3
	eor.l d1,d5

	lsr.l #8,d1
	or.l d1,d0		; d0 = A1a2c1c2

	move.l d0,(a2)+		

	lsl.l #8,d3
	or.l d5,d3

	move.l d3,(a2)+		; d3 = b1b2d1d2

	dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_lp

	rts


Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_APEND:









; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ------------------------------NORMAL 4bit Version---------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------
; ----------------------------------------------------------------------------

;	-	-	-	-	-	-	-	-	-

;		         >> 16 colour Pllb-C2P <<

;			    Quad pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_4bit_512k_4by1:

	bsr Pllb_c2p_init_NORMAL_c2p_registers

	; a4/a5/a6	tables are NOT needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_4bit_512k_4by1_AP:

Pllb_C2p_4bit_512k_4by1_LP:

	move.l (a0)+,d0
	move.w d0,d1
		clr.w d0
	lsl.b #4,d1
		swap d0
	lsr.w #4,d1
		lsl.b #4,d0
	lsl.w #4,d0
	move.b d1,d0
	lsl.l #3,d0
	move.l (a3,d0.l),(a1)+
	move.l 4(a3,d0.l),(a1)+

	dbf d7,Pllb_C2p_4bit_512k_4by1_LP
	rts


Pllb_C2p_4bit_512k_4by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		        >> DELTA 16 colour Pllb-C2P <<

;			    Quad pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Delta_4bit_512k_4by1:

	bsr Pllb_c2p_init_DELTA_c2p_registers

	; a4/a5/a6	tables are NOT needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment

Pllb_C2p_Delta_4bit_512k_4by1_AP:


Pllb_C2p_Delta_4bit_512k_4by1_LP:


	move.l (a0)+,d0

	cmp.l (a1)+,d0
	bne.b Pllb_C2p_Delta_4bit_512k_4by1_Cont

		addq.l #8,a2

		dbf d7,Pllb_C2p_Delta_4bit_512k_4by1_LP	
	rts
	
Pllb_C2p_Delta_4bit_512k_4by1_Cont:

		move.w d0,d1
			clr.w d0
		lsl.b #4,d1
			swap d0
		lsr.w #4,d1
			lsl.b #4,d0
		lsl.w #4,d0
		move.b d1,d0	
		lsl.l #3,d0
		move.l (a3,d0.l),(a2)+
		move.l 4(a3,d0.l),(a2)+


		dbf d7,Pllb_C2p_Delta_4bit_512k_4by1_LP	

	rts

Pllb_C2p_Delta_4bit_512k_4by1_APEND:






;	-	-	-	-	-	-	-	-	-

;		   >> NULLSKIP/CLEAR 16 colour Pllb-C2P <<

;			    Quad pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_NULLSKIP_4bit_512k_4by1:

	bsr Pllb_c2p_init_NULLSKIP_c2p_registers

	; a4/a5/a6	tables are NOT needed

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_NULLSKIP_4bit_512k_4by1_AP:

Pllb_C2p_NULLSKIP_4bit_512k_4by1_LP:

	move.l (a0)+,d0
	bne.b Pllb_C2p_NULLSKIP_4bit_512k_4by1_CONT

		clr.l (a2)+
	
			addq.l #4,a1
	
		clr.l (a2)+

		dbf d7,Pllb_C2p_NULLSKIP_4bit_512k_4by1_LP
	rts

Pllb_C2p_NULLSKIP_4bit_512k_4by1_Cont:

			clr.l (a1)+

		move.w d0,d1
			clr.w d0
		lsl.b #4,d1
			swap d0
		lsr.w #4,d1
			lsl.b #4,d0
		lsl.w #4,d0
		move.b d1,d0	
		lsl.l #3,d0
		move.l (a3,d0.l),(a2)+
		move.l 4(a3,d0.l),(a2)+


	dbf d7,Pllb_C2p_NULLSKIP_4bit_512k_4by1_LP

	rts


Pllb_C2p_NULLSKIP_4bit_512k_4by1_APEND:








;	-	-	-	-	-	-	-	-	-

;		   >> DELTANULLSKIP/CLEAR 16 colour Pllb-C2P <<

;			    Quad pixel Width

;			   512k fastram version

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_DeltaNullSkip_4bit_512k_4by1:

	bsr Pllb_c2p_init_DeltaNullSkip_c2p_registers

	; a4/a5/a6	tables are NOT needed

	move.l #4,a5

	blk.w 32,$4e71		; insert NOP's to ensure routine alignment


Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_AP:

Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_LP:

	move.l (a0)+,d0
	bne.b Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_CONT


	tst.b (a6)
	bne.w Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_nodelta

		add.l a5,a1

		addq.l #8,a2
		
		addq.l #1,a6		
		dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_LP
	rts

Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_nodelta:

		clr.l (a2)+
		add.l a5,a1
		clr.l (a2)+
		clr.b (a6)+
		
		dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_LP

	rts


Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_Cont:

			clr.l (a1)+

		move.w d0,d1
			clr.w d0
		lsl.b #4,d1
			swap d0
		lsr.w #4,d1
			lsl.b #4,d0

			st.b (a6)+

		lsl.w #4,d0
		move.b d1,d0	
		lsl.l #3,d0
		move.l (a3,d0.l),(a2)+
		move.l 4(a3,d0.l),(a2)+


	dbf d7,Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_LP

	rts


Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_APEND:







;	-	-	-	-	-	-	-	-	-


;		 >> Handle The Blitter Bitplane Copy/Resorting <<


;	-	-	-	-	-	-	-	-	-


Pllb_c2p_Init_BlitterResort_Table:

	tst.w Pllb_C2p_Enabled_Flag
	beq.b Pllb_c2p_Init_BlitterResort_Table_DONE

		lea.l Pllb_c2p_Init_blitterResort_colourdepth(pc),a0
		move.w Pllb_C2p_ColourDepth(pc),d0
		move.l (a0,d0.w),a0	
		jmp (a0)

Pllb_c2p_Init_BlitterResort_Table_DONE:
	rts


Pllb_c2p_Init_blitterResort_colourdepth:

	dc.l Pllb_c2p_Init_16colour_blitter
	dc.l Pllb_c2p_Init_64colour_blitter
	dc.l Pllb_c2p_Init_256colour_blitter


Pllb_c2p_Init_16colour_blitter:

	clr.w Pllb_C2p_blit_Flag	
	move.w #4,Pllb_C2p_blit_Bitplane_Max
	clr.w Pllb_C2p_blit_Bitplane

	move.w PLLB_C2P_BitPLane_Size(pc),Pllb_C2p_blit_PlaneSize

	bsr Pllb_C2P_GetScreenSize
	move.w d0,Pllb_C2p_blit_PlaneSize2

	move.w #8-2,Pllb_C2p_blit_Blit_AModulo
	clr.w Pllb_C2p_blit_Blit_DModulo

	lea.l Pllb_C2p_blit_Source_Offset_Table(pc),a0
	lea.l Pllb_c2p_8bitplane_offset_table(pc),a1
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	rts


Pllb_c2p_Init_64colour_blitter:
	clr.w Pllb_C2p_blit_Flag	
	move.w #6,Pllb_C2p_blit_Bitplane_Max
	clr.w Pllb_C2p_blit_Bitplane

	move.w PLLB_C2P_BitPLane_Size(pc),Pllb_C2p_blit_PlaneSize


	bsr Pllb_C2P_GetScreenSize
	move.w d0,Pllb_C2p_blit_PlaneSize2

	move.w #12-2,Pllb_C2p_blit_Blit_AModulo
	clr.w Pllb_C2p_blit_Blit_DModulo

	lea.l Pllb_C2p_blit_Source_Offset_Table(pc),a0
	lea.l Pllb_c2p_6bitplane_offset_table(pc),a1

	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	rts




Pllb_c2p_Init_256colour_blitter:

	clr.w Pllb_C2p_blit_Flag	
	move.w #8,Pllb_C2p_blit_Bitplane_Max
	clr.w Pllb_C2p_blit_Bitplane

	move.w PLLB_C2P_BitPLane_Size(pc),Pllb_C2p_blit_PlaneSize

	bsr Pllb_C2P_GetScreenSize
	move.w d0,Pllb_C2p_blit_PlaneSize2
	move.w #16-2,Pllb_C2p_blit_Blit_AModulo
	clr.w Pllb_C2p_blit_Blit_DModulo

	lea.l Pllb_C2p_blit_Source_Offset_Table(pc),a0
	lea.l Pllb_c2p_8bitplane_offset_table(pc),a1
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	rts


Pllb_c2p_8bitplane_offset_table:	dc.w 0,4,2,6,8,12,10,14
Pllb_c2p_6bitplane_offset_table:	dc.w 0,4,2,6,10,8,0,0


;	-	-	-	-	-	-	-	-	-

;		   >> PLLB_C2P Screen sizes in pixels <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2P_GetScreenSize:

	moveq.l #0,d0
	move.w  PLLB_C2P_ChunkyScreenWidth(pc),d0
	lsr.l #4,d0					; divu d0 by 16	 
	mulu  PLLB_C2P_ChunkyScreenHeight(pc),d0
	move.w d0,PLLB_C2P_ChunkyScreenSize
	rts
	



PLLB_C2P_ChunkyScreenWidth:	dc.w 0	; ChunkyScreen width in pixels
PLLB_C2P_ChunkyScreenHeight:	dc.w 0	; ChunkyScreen_Height in pixels
PLLB_C2P_ChunkyScreenSize:	dc.w 0	; (screen width/16)*screenheight


PLLB_C2P_BitPLane_Size:		dc.w 0



Pllb_C2p_blit_Flag:		  dc.w 0
Pllb_C2p_blit_Bitplane_Max:	  dc.w 8	; Max Numb of bitplanes
Pllb_C2p_blit_Bitplane:		  dc.w 0
Pllb_C2p_blit_PlaneSize:	  dc.w 40*255   ; Width in Byte * height !!
Pllb_C2p_blit_PlaneSize2:	  dc.w 20*255   ; Width in words * height !!
Pllb_C2p_blit_Blit_AModulo:	  dc.w (16-2)	; SRC modulo 
Pllb_C2p_blit_Blit_DModulo:	  dc.w 0        ; Dest Modulo
Pllb_C2p_blit_Source_Offset_Table:	  dc.w 0,4,2,6,8,12,10,14

Pllb_C2P_Temp_Image_buffer:	dc.l 0		; Buffer Must Be CHIPRAM
Pllb_C2P_Display_Frame_buffer:	dc.l 0

Pllb_C2P_Chunky_Frame_bufferA:	dc.l 0
Pllb_C2P_Chunky_Frame_bufferB	dc.l 0




Pllb_C2p_blitter_resort_frame:

	tst.w Pllb_C2p_blit_flag			; Check if C2P flag is set
	beq.w Pllb_C2p_blitter_resort_frame_done

		btst #14,$dff002		; check if blitter active
		bne.b Pllb_C2p_blitter_resort_frame_done

Pllb_C2p_blitter_resort_frame2:

	movem.l d0/a0/a1/a6,-(a7)

	moveq.l #0,d0
	
	Move.l Pllb_C2p_Temp_Image_buffer,a0
	move.w Pllb_C2p_blit_Bitplane(pc),d0
	lsl.w #1,d0
	move.w Pllb_C2p_blit_source_offset_table(pc,d0),d0

	add.l d0,a0


	move.l Pllb_C2P_Display_Frame_buffer(pc),a1
	move.w Pllb_C2p_blit_PlaneSize(pc),d0	
	mulu Pllb_C2p_blit_Bitplane(pc),d0		; d1 = bitplanesize * bitplane 
	add.l d0,a1

	lea.l $dff040,a6		; a6 ='s hardware base

	move.l #$09f00000,(a6)+		; set miniterm and enable channels A&D
	move.l #$ffffffff,(a6)+		; set end of line masks	
	move.l Pllb_C2p_blit_Blit_AModulo(pc),$64-$48(a6)


	move.l a0,$50-$48(a6)
	move.l a1,$54-$48(a6)
	move.w Pllb_C2p_blit_PlaneSize2(pc),$5c-$48(a6)	; Height
	move.w #1,$5e-$48(a6)				; width

	lea.l Pllb_C2p_blit_Bitplane_max(pc),a0
	move.w (a0)+,d0

	addq.w #1,(a0)

	cmp.w (a0),d0
	bne.b Pllb_C2p_blitter_resort_frame_done2	

		clr.w (a0)		;reset Bitplane counter
		clr.w Pllb_C2p_blit_flag

Pllb_C2p_blitter_resort_frame_done2:

	movem.l (a7)+,d0/a0/a1/a6

Pllb_C2p_blitter_resort_frame_done:

	rts













;	-	-	-	-	-	-	-	-	-

;			>> PLLB-C2P init Precalc Tables <<

;	-	-	-	-	-	-	-	-	-





Pllb_C2p_init_precalc_tables:

		tst.w Pllb_C2p_Enabled_Flag
		beq.b Pllb_C2p_init_precalc_tables_Done

		moveq.l #0,d0
		lea.l Pllb_C2p_Init_ColourDepthArray(pc),a0
		move.w Pllb_C2p_ColourDepth(pc),d0
		move.l (a0,d0.w),a0	

		move.w Pllb_C2p_PixelWidth(pc),d0
		mulu #16,d0
		add.l d0,a0

		move.w PllB_C2p_FastRam_BUfferSize(pc),d0
		add.l d0,a0

		move.l (a0),a0
		jsr (a0)

Pllb_C2p_init_precalc_tables_Done:

	rts


Pllb_C2p_Init_ColourDepthArray:

	dc.l Pllb_C2p_init_4bit_tables_array
	dc.l Pllb_C2p_init_8bit_tables_array	;6bit tables, the same as 8bit
	dc.l Pllb_C2p_init_8bit_tables_array


Pllb_C2p_init_4bit_tables_array:

	; 4bit single pixel width

	dc.l Pllb_C2p_init_4Bit_1by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_1by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_1by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_1by1_512k_tables

	; 4bit double pixel width

	dc.l Pllb_C2p_init_4Bit_2by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_2by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_2by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_2by1_512k_tables

	; 4bit Quad pixel width

	dc.l Pllb_C2p_init_4Bit_4by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_4by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_4by1_512k_tables
	dc.l Pllb_C2p_init_4Bit_4by1_512k_tables




Pllb_C2p_init_8bit_tables_array:

	; 8bit single pixel width

	dc.l Pllb_C2p_init_8Bit_1by1_512k_tables
	dc.l Pllb_C2p_init_8Bit_1by1_1Meg_tables
	dc.l Pllb_C2p_init_8Bit_1by1_1_5Meg_tables
	dc.l Pllb_C2p_init_8Bit_1by1_2Meg_tables

	; 8bit double pixel width

	dc.l Pllb_C2p_init_8Bit_2by1_512k_tables
	dc.l Pllb_C2p_init_8Bit_2by1_1meg_tables
	dc.l Pllb_C2p_init_8Bit_2by1_1meg_tables
	dc.l Pllb_C2p_init_8Bit_2by1_1meg_tables

	; 8bit quad pixel width

	dc.l Pllb_C2p_init_8Bit_4by1_512k_tables
	dc.l Pllb_C2p_init_8Bit_4by1_512k_tables
	dc.l Pllb_C2p_init_8Bit_4by1_512k_tables
	dc.l Pllb_C2p_init_8Bit_4by1_512k_tables



;	-	-	-	-	-	-	-	-	-





Pllb_C2p_init_8bit_pixelwidth2:

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a0

	moveq.l #0,d0

	move.w #255,d7

Pllb_C2p_init_8bit_pixelwidth2_LP:


	move.l d0,d1


	move.l d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsr.l #1,d1

	move.l d2,d3		; merge (double bits)
	lsl.l #1,d2
	or.l d3,d2
	move.l d2,(a0)+


	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsr.l #1,d1

	move.l d2,d3		; merge (double bits)
	lsl.l #1,d2
	or.l d3,d2
	move.l d2,(a0)+

	addq.l #1,d0
	dbf d7,Pllb_C2p_init_8bit_pixelwidth2_LP

	rts
	












Pllb_C2p_init_8bit_pixelwidth1:


	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a0


	moveq.l #0,d0

	move.w #255,d7

Pllb_C2p_init_8bit_pixelwidth1_lp:

	move.l d0,d1

	move.l d1,d2
	and.b #1,d2
	move.b d2,(a0)+
	lsr.l #1,d1

	move.l d1,d2
	and.b #1,d2
	move.b d2,(a0)+
	lsr.l #1,d1

	move.l d1,d2
	and.b #1,d2
	move.b d2,(a0)+
	lsr.l #1,d1

	move.l d1,d2
	and.b #1,d2
	move.b d2,(a0)+
	lsr.l #1,d1

	move.l d1,d2
	and.b #1,d2
	move.b d2,(a0)+
	lsr.l #1,d1

	move.l d1,d2
	and.b #1,d2
	move.b d2,(a0)+
	lsr.l #1,d1

	move.l d1,d2
	and.b #1,d2
	move.b d2,(a0)+
	lsr.l #1,d1
	move.b d1,(a0)+

	addq.l #1,d0
	dbf d7,Pllb_C2p_init_8bit_pixelwidth1_lp
	rts
	








Pllb_C2p_init_8bit_pixelwidth4:

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a0

	moveq.l #0,d0

	move.w #255,d7

Pllb_C2p_init_8bit_pixelwidth4_lp:

	move.l d0,d1

	move.l d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsr.l #1,d1

	move.l d2,d3		; merge (double bits)
	lsl.l #1,d2
	or.l d3,d2
	lsl.l #1,d2
	or.l d3,d2
	lsl.l #1,d2
	or.l d3,d2
	move.l d2,(a0)+


	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2
	and.b #1,d2
	lsl.l #8,d2
	lsr.l #1,d1

	move.b d1,d2

	move.l d2,d3		; Quad merge the bits
	lsl.l #1,d2
	or.l d3,d2
	lsl.l #1,d2
	or.l d3,d2
	lsl.l #1,d2
	or.l d3,d2
	move.l d2,(a0)+

	addq.l #1,d0
	dbf d7,Pllb_C2p_init_8bit_pixelwidth4_lp

	rts
	




;	-	-	-	-	-	-	-	-	-



Pllb_c2p_init_registers:

	move.l Pllb_C2p_FastBuffer_PointerA(pc),a0
	move.l Pllb_C2p_FastBuffer_PointerB(pc),a3
	move.l Pllb_C2p_FastBuffer_PointerC(pc),a4
	move.l Pllb_C2p_FastBuffer_PointerD(pc),a5

	move.l a0,d0
	add.l a3,d0	
	add.l a4,d0	
	add.l a5,d0	

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a1

	move.w #255,d7
	rts


Pllb_c2p_init_failed_no_fastram:

	move.w #Pllb_c2p_Not_Active,Pllb_C2p_Enabled_Flag


	rts


;	-	-	-	-	-	-	-	-	-

;		         >> PLLB_C2p Init 8bit tables <<

;		      Normal Single Pixel width init routine

;			     >> 512k version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_8Bit_1by1_512k_tables:


	bsr Pllb_C2p_init_8bit_pixelwidth1

	bsr Pllb_c2p_init_registers


	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_8Bit_1by1_512k_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #1,d0
	lsl.l #1,d1
	
	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2


	move.w #255,d6

Pllb_C2p_init_8Bit_1by1_512k_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3
		or.l d0,d2
		or.l d1,d3
		move.l d2,(a0)+		
		move.l d3,(a0)+		

		dbf d6,Pllb_C2p_init_8Bit_1by1_512k_tables_xlp
 
	dbf d7,Pllb_C2p_init_8Bit_1by1_512k_tables_ylp
 	rts
	



;	-	-	-	-	-	-	-	-	-

;		          >> PLLB_C2p Init tables <<

;		      Normal Single Pixel width init routine

;			     >> 1meg version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_8Bit_1by1_1Meg_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth1

	bsr Pllb_c2p_init_registers


	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_8Bit_1by1_1Meg_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #1,d0
	lsl.l #1,d1
	

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2


	move.w #255,d6

Pllb_C2p_init_8Bit_1by1_1Meg_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3
		or.l d0,d2
		or.l d1,d3
		move.l d2,(a0)+		
		move.l d3,(a0)+		
		lsl.l #2,d2
		lsl.l #2,d3
		move.l d2,(a3)+		
		move.l d3,(a3)+		

		dbf d6,Pllb_C2p_init_8Bit_1by1_1Meg_tables_xlp
 
	dbf d7,Pllb_C2p_init_8Bit_1by1_1meg_tables_ylp
 	rts
	




;	-	-	-	-	-	-	-	-	-

;		          >> PLLB_C2p Init tables <<

;		      Normal Single Pixel width init routine

;			     >> 1_5meg version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_8Bit_1by1_1_5meg_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth1

	bsr Pllb_c2p_init_registers

	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_8Bit_1by1_1_5meg_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #1,d0
	lsl.l #1,d1
	
	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2

	move.w #255,d6

Pllb_C2p_init_8Bit_1by1_1_5meg_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3
		or.l d0,d2
		or.l d1,d3
		move.l d2,(a0)+		
		move.l d3,(a0)+		
		lsl.l #2,d2
		lsl.l #2,d3
		move.l d2,(a3)+		
		move.l d3,(a3)+		
		lsl.l #2,d2
		lsl.l #2,d3
		move.l d2,(a4)+		
		move.l d3,(a4)+		

		dbf d6,Pllb_C2p_init_8Bit_1by1_1_5meg_tables_xlp
 
	dbf d7,Pllb_C2p_init_8Bit_1by1_1_5meg_tables_ylp
 	rts
	











;	-	-	-	-	-	-	-	-	-

;		          >> PLLB_C2p Init tables <<

;		      Normal Single Pixel width init routine

;			     >> 2meg version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_8Bit_1by1_2meg_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth1

	bsr Pllb_c2p_init_registers

	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_8Bit_1by1_2meg_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #1,d0
	lsl.l #1,d1
	
	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2

	move.w #255,d6

Pllb_C2p_init_8Bit_1by1_2meg_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3
		or.l d0,d2
		or.l d1,d3
		move.l d2,(a0)+		
		move.l d3,(a0)+		
		lsl.l #2,d2
		lsl.l #2,d3
		move.l d2,(a3)+		
		move.l d3,(a3)+		
		lsl.l #2,d2
		lsl.l #2,d3
		move.l d2,(a4)+		
		move.l d3,(a4)+		
		lsl.l #2,d2
		lsl.l #2,d3
		move.l d2,(a5)+		
		move.l d3,(a5)+		

		dbf d6,Pllb_C2p_init_8Bit_1by1_2meg_tables_xlp
 
	dbf d7,Pllb_C2p_init_8bit_1by1_2meg_tables_ylp
 	rts
	





;	-	-	-	-	-	-	-	-	-

;		          >> PLLB_C2p Init tables <<

;		              DOUBLE Pixel width

;			     >> 512k version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_8Bit_2by1_512k_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth2

	bsr Pllb_c2p_init_registers

	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_8Bit_2by1_512k_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #2,d0
	lsl.l #2,d1

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2

	move.w #255,d6

Pllb_C2p_init_8Bit_2by1_512k_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3

		or.l d0,d2
		or.l d1,d3
		move.l d2,(a0)+		
		move.l d3,(a0)+		

		lsl.l #4,d2
		lsl.l #4,d3
		move.l d2,(a3)+		
		move.l d3,(a3)+		
		

		dbf d6,Pllb_C2p_init_8Bit_2by1_512k_tables_xlp

	dbf d7,Pllb_C2p_init_8Bit_2by1_512k_tables_ylp
	rts
	










;	-	-	-	-	-	-	-	-	-

;		          >> PLLB_C2p Init tables <<

;		              DOUBLE Pixel width

;			     >> 1meg version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_8Bit_2by1_1meg_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth2

	bsr Pllb_c2p_init_registers

	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_8Bit_2by1_1meg_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #2,d0
	lsl.l #2,d1

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2

	move.w #255,d6

Pllb_C2p_init_8Bit_2by1_1meg_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3

		or.l d0,d2
		or.l d1,d3
		move.l d2,(a0)+		
		move.l d3,(a0)+		

		lsl.l #4,d2
		lsl.l #4,d3
		move.l d2,(a3)+		
		move.l d3,(a3)+		
		

		dbf d6,Pllb_C2p_init_8Bit_2by1_1meg_tables_xlp

	
	dbf d7,Pllb_C2p_init_8Bit_2by1_1meg_tables_ylp

	rts
	


;	-	-	-	-	-	-	-	-	-

;		          >> PLLB_C2p Init tables <<

;		              DOUBLE Pixel width

;			     >> 512k version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_8Bit_4by1_512k_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth4

	bsr Pllb_c2p_init_registers

	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_8Bit_4by1_512k_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #4,d0
	lsl.l #4,d1

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2


	move.w #255,d6

Pllb_C2p_init_8Bit_4by1_512k_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3
		or.l d0,d2
		or.l d1,d3
		move.l d2,(a0)+		
		move.l d3,(a0)+		

		dbf d6,Pllb_C2p_init_8Bit_4by1_512k_tables_xlp

	dbf d7,Pllb_C2p_init_8Bit_4by1_512k_tables_ylp

	rts
	





;	-	-	-	-	-	-	-	-	-

;		         >> PLLB_C2p Init 4bit tables <<

;		         QUAD Pixel width init routine

;			     >> 512k version <<

;	-	-	-	-	-	-	-	-	-

Pllb_C2p_init_4Bit_4by1_512k_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth4

	bsr Pllb_c2p_init_registers

	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_4Bit_4by1_512k_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #4,d1
	or.l d0,d1

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2

	move.w #255,d6

Pllb_C2p_init_4Bit_4by1_512k_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3

		lsl.l #4,d3
		or.l d2,d3

		move.l d1,d2

		move.l d1,(a0)		
		move.l d3,4(a0)

		move.b (a0),d2
		lsl.l #8,d2
		move.b 4(a0),d2
		swap d2
		move.b 2(a0),d2
		lsl.w #8,d2
		move.b 6(a0),d2

		move.b 1(a0),d3
		lsl.l #8,d3
		move.b 5(a0),d3
		swap d3
		move.b 3(a0),d3
		lsl.w #8,d3
		move.b 7(a0),d3
	
		move.l d2,(a0)+		
		move.l d3,(a0)+

		dbf d6,Pllb_C2p_init_4Bit_4by1_512k_tables_xlp

	dbf d7,Pllb_C2p_init_4Bit_4by1_512k_tables_ylp
	rts
	




;	-	-	-	-	-	-	-	-	-

;		         >> PLLB_C2p Init 4bit tables <<

;		         DOUBLE Pixel width init routine

;			     >> 512k version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_4Bit_2by1_512k_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth2

	bsr Pllb_c2p_init_registers

	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


Pllb_C2p_init_4Bit_2by1_512k_tables_ylp:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #4,d1
	or.l d0,d1
	lsl.l #2,d1
	
	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2

	move.w #255,d6

Pllb_C2p_init_4Bit_2by1_512k_tables_xlp:

		move.l (a2)+,d2
		move.l (a2)+,d3

		lsl.l #4,d3
		or.l d2,d3

		or.l d1,d3
		move.l d3,(a0)+		

	
		dbf d6,Pllb_C2p_init_4Bit_2by1_512k_tables_xlp

	dbf d7,Pllb_C2p_init_4Bit_2by1_512k_tables_ylp

	rts
	







;	-	-	-	-	-	-	-	-	-

;		         >> PLLB_C2p Init 4bit tables <<

;		      Normal Single Pixel width init routine

;			     >> 512k version <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_init_4Bit_1by1_512k_tables:

	bsr Pllb_C2p_init_8bit_pixelwidth1

	bsr Pllb_c2p_init_registers

	tst.l d0
	beq Pllb_c2p_init_failed_no_fastram


	move.l a0,a3
	add.l #4*$10000,a3

Pllb_C2p_init_4Bit_1by1_512k_tables_YLP:

	move.l (a1)+,d0
	move.l (a1)+,d1

	lsl.l #4,d1
	or.l d0,d1
	lsl.l #1,d1

	lea.l Pllb_C2p_Temp_Comb_buffer(pc),a2

	move.w #255,d6


Pllb_C2p_init_4Bit_1by1_512k_tables_XLP:

		move.l (a2)+,d2
		move.l (a2)+,d3

		lsl.l #4,d3
		or.l d2,d3

		or.l d1,d3
		move.l d3,(a0)+		

		lsl.l #2,d3
		move.l d3,(a3)+		


		dbf d6,Pllb_C2p_init_4Bit_1by1_512k_tables_xLP


	dbf d7,Pllb_C2p_init_4Bit_1by1_512k_tables_YLP
	rts
	








;	-	-	-	-	-	-	-	-	-

;	            >> PLLB-C2P Routine Alignment System <<

;	-	-	-	-	-	-	-	-	-


Pllb_C2p_Routine_alignment_system:

	lea.l Pllb_C2P_Routine_Alignment_System_Table(pc),a0

	move.w (a0)+,d7

Pllb_C2P_Routine_Alignment_system_lp:

	move.l (a0)+,a1		; base address of routine

	move.l a1,d0
	and.l #$fffffff0,d0
	move.l d0,a2

	move.l (a0)+,d6
	subq.w #1,d6

Pllb_C2P_Routine_Alignment_system_Copylp:

		move.b (a1)+,(a2)+		

		dbf d6,Pllb_C2P_Routine_Alignment_system_Copylp

	dbf d7,Pllb_C2P_Routine_Alignment_system_lp

	rts



Pllb_C2P_Routine_Alignment_system_table:

 dc.w ((Pllb_C2P_Routine_Alignment_system_table_end-Pllb_C2P_Routine_Alignment_system_table_Start)/8)-1

Pllb_C2P_Routine_Alignment_system_table_Start

	; 8 bit c2ps

	dc.l Pllb_C2p_8bit_512K_1by1_AP
	dc.l Pllb_C2p_8bit_512k_1by1_APend-Pllb_C2p_8bit_512k_1by1_AP
	dc.l Pllb_C2p_8bit_1meg_1by1_AP
	dc.l Pllb_C2p_8bit_1meg_1by1_APend-Pllb_C2p_8bit_1meg_1by1_AP
	dc.l Pllb_C2p_8bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_8bit_1_5meg_1by1_APend-Pllb_C2p_8bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_8bit_2meg_1by1_AP
	dc.l Pllb_C2p_8bit_2meg_1by1_APend-Pllb_C2p_8bit_2meg_1by1_AP

	; delta versions

	dc.l Pllb_C2p_Delta_8bit_512k_1by1_AP
	dc.l Pllb_C2p_Delta_8bit_512k_1by1_APend-Pllb_C2p_Delta_8bit_512k_1by1_AP
	dc.l Pllb_C2p_Delta_8bit_1meg_1by1_AP
	dc.l Pllb_C2p_Delta_8bit_1meg_1by1_APend-Pllb_C2p_Delta_8bit_1meg_1by1_AP
	dc.l Pllb_C2p_Delta_8bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_Delta_8bit_1_5meg_1by1_APend-Pllb_C2p_Delta_8bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_Delta_8bit_2meg_1by1_AP
	dc.l Pllb_C2p_Delta_8bit_2meg_1by1_APend-Pllb_C2p_Delta_8bit_2meg_1by1_AP


	; null skip version

	dc.l Pllb_C2p_NullSkip_8bit_512k_1by1_AP
	dc.l Pllb_C2p_NullSkip_8bit_512k_1by1_APend-Pllb_C2p_NullSkip_8bit_512k_1by1_AP
	dc.l Pllb_C2p_NullSkip_8bit_1meg_1by1_AP
	dc.l Pllb_C2p_NullSkip_8bit_1meg_1by1_APend-Pllb_C2p_NullSkip_8bit_1meg_1by1_AP
	dc.l Pllb_C2p_NullSkip_8bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_NullSkip_8bit_1_5meg_1by1_APend-Pllb_C2p_NullSkip_8bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_NullSkip_8bit_2meg_1by1_AP
	dc.l Pllb_C2p_NullSkip_8bit_2meg_1by1_APend-Pllb_C2p_NullSkip_8bit_2meg_1by1_AP





	; null skip version

	dc.l Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_APend-Pllb_C2p_DeltaNullSkip_8bit_512k_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8bit_1meg_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8bit_1meg_1by1_APend-Pllb_C2p_DeltaNullSkip_8bit_1meg_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8bit_1_5meg_1by1_APend-Pllb_C2p_DeltaNullSkip_8bit_1_5meg_1by1_AP


	; 8bit 2by1 modes Normal

	dc.l Pllb_C2p_8bit_512K_2by1_AP
	dc.l Pllb_C2p_8bit_512k_2by1_APend-Pllb_C2p_8bit_512k_2by1_AP
	dc.l Pllb_C2p_8bit_1meg_2by1_AP
	dc.l Pllb_C2p_8bit_1meg_2by1_APend-Pllb_C2p_8bit_1meg_2by1_AP

	; 8bit 2by1 modes Delta

	dc.l Pllb_C2p_Delta_8bit_512K_2by1_AP
	dc.l Pllb_C2p_Delta_8Bit_512k_2by1_APend-Pllb_C2p_Delta_8Bit_512k_2by1_AP
	dc.l Pllb_C2p_Delta_8Bit_1meg_2by1_AP
	dc.l Pllb_C2p_Delta_8Bit_1meg_2by1_APend-Pllb_C2p_Delta_8bit_1meg_2by1_AP

	; 8bit 2by1 modes Nullskip

	dc.l Pllb_C2p_NullSkip_8bit_512K_2by1_AP
	dc.l Pllb_C2p_NullSkip_8Bit_512k_2by1_APend-Pllb_C2p_NullSkip_8Bit_512k_2by1_AP
	dc.l Pllb_C2p_NullSkip_8Bit_1meg_2by1_AP
	dc.l Pllb_C2p_NullSkip_8Bit_1meg_2by1_APend-Pllb_C2p_NullSkip_8bit_1meg_2by1_AP

	; 8bit 2by1 modes DeltaNullSkip

	dc.l Pllb_C2p_DeltaNullSkip_8bit_512K_2by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8Bit_512k_2by1_APend-Pllb_C2p_DeltaNullSkip_8Bit_512k_2by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8Bit_1meg_2by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8Bit_1meg_2by1_APend-Pllb_C2p_DeltaNullSkip_8bit_1meg_2by1_AP



	; 8bit 4by1 modes Normal

	dc.l Pllb_C2p_8bit_512K_4by1_AP
	dc.l Pllb_C2p_8bit_512k_4by1_APend-Pllb_C2p_8bit_512k_4by1_AP
	; 8bit 4by1 modes Delta
	dc.l Pllb_C2p_Delta_8bit_512K_4by1_AP
	dc.l Pllb_C2p_Delta_8Bit_512k_4by1_APend-Pllb_C2p_Delta_8Bit_512k_4by1_AP

	; 8bit 4by1 modes Nillskip
	dc.l Pllb_C2p_NullSkip_8bit_512K_4by1_AP
	dc.l Pllb_C2p_NullSkip_8Bit_512k_4by1_APend-Pllb_C2p_NullSkip_8Bit_512k_4by1_AP


	; 8bit 4by1 modes DeltaNullSkip
	dc.l Pllb_C2p_DeltaNullSkip_8bit_512K_4by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_8Bit_512k_4by1_APend-Pllb_C2p_DeltaNullSkip_8Bit_512k_4by1_AP



	; 6 bit C2p's	1by1
	

	dc.l Pllb_C2p_6bit_512K_1by1_AP
	dc.l Pllb_C2p_6bit_512k_1by1_APend-Pllb_C2p_6bit_512k_1by1_AP
	dc.l Pllb_C2p_6bit_1meg_1by1_AP
	dc.l Pllb_C2p_6bit_1meg_1by1_APend-Pllb_C2p_6bit_1meg_1by1_AP
	dc.l Pllb_C2p_6bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_6bit_1_5meg_1by1_APend-Pllb_C2p_6bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_6bit_2meg_1by1_AP
	dc.l Pllb_C2p_6bit_2meg_1by1_APend-Pllb_C2p_6bit_2meg_1by1_AP


	; delta versions

	dc.l Pllb_C2p_Delta_6bit_512k_1by1_AP
	dc.l Pllb_C2p_Delta_6bit_512k_1by1_APend-Pllb_C2p_Delta_6bit_512k_1by1_AP
	dc.l Pllb_C2p_Delta_6bit_1meg_1by1_AP
	dc.l Pllb_C2p_Delta_6bit_1meg_1by1_APend-Pllb_C2p_Delta_6bit_1meg_1by1_AP
	dc.l Pllb_C2p_Delta_6bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_Delta_6bit_1_5meg_1by1_APend-Pllb_C2p_Delta_6bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_Delta_6bit_2meg_1by1_AP
	dc.l Pllb_C2p_Delta_6bit_2meg_1by1_APend-Pllb_C2p_Delta_6bit_2meg_1by1_AP

	; Nullskip versions

	dc.l Pllb_C2p_Nullskip_6bit_512k_1by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_512k_1by1_APend-Pllb_C2p_Nullskip_6bit_512k_1by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_1meg_1by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_1meg_1by1_APend-Pllb_C2p_Nullskip_6bit_1meg_1by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_1_5meg_1by1_APend-Pllb_C2p_Nullskip_6bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_2meg_1by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_2meg_1by1_APend-Pllb_C2p_Nullskip_6bit_2meg_1by1_AP


	; DeltaNullSkip versions

	dc.l Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_APend-Pllb_C2p_DeltaNullSkip_6bit_512k_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_APend-Pllb_C2p_DeltaNullSkip_6bit_1meg_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_APend-Pllb_C2p_DeltaNullSkip_6bit_1_5meg_1by1_AP





	; 6 bit C2p's	2by1
	
	dc.l Pllb_C2p_6bit_512K_2by1_AP
	dc.l Pllb_C2p_6bit_512k_2by1_APend-Pllb_C2p_6bit_512k_2by1_AP
	dc.l Pllb_C2p_6bit_1meg_2by1_AP
	dc.l Pllb_C2p_6bit_1meg_2by1_APend-Pllb_C2p_6bit_1meg_2by1_AP

	; delta versions

	dc.l Pllb_C2p_Delta_6bit_512k_2by1_AP
	dc.l Pllb_C2p_Delta_6bit_512k_2by1_APend-Pllb_C2p_Delta_6bit_512k_2by1_AP
	dc.l Pllb_C2p_Delta_6bit_1meg_2by1_AP
	dc.l Pllb_C2p_Delta_6bit_1meg_2by1_APend-Pllb_C2p_Delta_6bit_1meg_2by1_AP

	; nullskip
	dc.l Pllb_C2p_Nullskip_6bit_512k_2by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_512k_2by1_APend-Pllb_C2p_Nullskip_6bit_512k_2by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_1meg_2by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_1meg_2by1_APend-Pllb_C2p_Nullskip_6bit_1meg_2by1_AP




	; DeltaNullSkip
	dc.l Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_APend-Pllb_C2p_DeltaNullSkip_6bit_512k_2by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_1meg_2by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_1meg_2by1_APend-Pllb_C2p_DeltaNullSkip_6bit_1meg_2by1_AP




	; 6 bit C2p's	4by1
	
	dc.l Pllb_C2p_6bit_512K_4by1_AP
	dc.l Pllb_C2p_6bit_512k_4by1_APend-Pllb_C2p_6bit_512k_4by1_AP
	; delta versions

	dc.l Pllb_C2p_Delta_6bit_512k_4by1_AP
	dc.l Pllb_C2p_Delta_6bit_512k_4by1_APend-Pllb_C2p_Delta_6bit_512k_4by1_AP

	; nullskip
	dc.l Pllb_C2p_Nullskip_6bit_512k_4by1_AP
	dc.l Pllb_C2p_Nullskip_6bit_512k_4by1_APend-Pllb_C2p_Nullskip_6bit_512k_4by1_AP

	; DeltaNullSkip
	dc.l Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_APend-Pllb_C2p_DeltaNullSkip_6bit_512k_4by1_AP


	; 4 bit C2p's	1by1
	
	dc.l Pllb_C2p_4bit_512K_1by1_AP
	dc.l Pllb_C2p_4bit_512k_1by1_APend-Pllb_C2p_4bit_512k_1by1_AP
	dc.l Pllb_C2p_Delta_4bit_512k_1by1_AP
	dc.l Pllb_C2p_Delta_4bit_512k_1by1_APend-Pllb_C2p_Delta_4bit_512k_1by1_AP
	dc.l Pllb_C2p_Nullskip_4bit_512k_1by1_AP
	dc.l Pllb_C2p_Nullskip_4bit_512k_1by1_APend-Pllb_C2p_Nullskip_4bit_512k_1by1_AP


	dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_APend-Pllb_C2p_DeltaNullSkip_4bit_512k_1by1_AP

	; 4 bit C2p's	2by1

	dc.l Pllb_C2p_4bit_512K_2by1_AP
	dc.l Pllb_C2p_4bit_512k_2by1_APend-Pllb_C2p_4bit_512k_2by1_AP
	dc.l Pllb_C2p_Delta_4bit_512k_2by1_AP
	dc.l Pllb_C2p_Delta_4bit_512k_2by1_APend-Pllb_C2p_Delta_4bit_512k_2by1_AP
	dc.l Pllb_C2p_Nullskip_4bit_512k_2by1_AP
	dc.l Pllb_C2p_Nullskip_4bit_512k_2by1_APend-Pllb_C2p_Nullskip_4bit_512k_2by1_AP

	dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_APend-Pllb_C2p_DeltaNullSkip_4bit_512k_2by1_AP


	; 6 bit C2p's	4by1

	dc.l Pllb_C2p_4bit_512K_4by1_AP
	dc.l Pllb_C2p_4bit_512k_4by1_APend-Pllb_C2p_4bit_512k_4by1_AP
	dc.l Pllb_C2p_Delta_4bit_512k_4by1_AP
	dc.l Pllb_C2p_Delta_4bit_512k_4by1_APend-Pllb_C2p_Delta_4bit_512k_4by1_AP
	dc.l Pllb_C2p_Nullskip_4bit_512k_4by1_AP
	dc.l Pllb_C2p_Nullskip_4bit_512k_4by1_APend-Pllb_C2p_Nullskip_4bit_512k_4by1_AP

	dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_AP
	dc.l Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_APend-Pllb_C2p_DeltaNullSkip_4bit_512k_4by1_AP



Pllb_C2P_Routine_Alignment_system_table_end:


Pllb_C2p_Temp_Comb_buffer:

	blk.b 256*8,0




;	-	-	-	-	-	-	-	-	-

;			>> End of PLLB-C2P Stuff <<

;	-	-	-	-	-	-	-	-	-

