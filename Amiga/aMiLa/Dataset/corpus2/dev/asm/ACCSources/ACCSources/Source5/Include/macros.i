display_mem	macro
	move.w	#'M.',reg_data
	move.w	\1,d6
	bsr	display_reg
	endm

display_d0	macro
	move.w	#'D0',reg_data
	move.w	d0,d6
	bsr	display_reg
	endm

display_d1	macro
	move.w	#'D1',reg_data
	move.w	d1,d6
	bsr	display_reg
	endm
	
display_d2	macro
	move.w	#'D2',reg_data
	move.w	d2,d6
	bsr	display_reg
	endm
	
display_d3	macro
	move.w	#'D3',reg_data
	move.w	d3,d6
	bsr	display_reg
	endm
	
display_d4	macro
	move.w	#'D4',reg_data
	move.w	d4,d6
	bsr	display_reg
	endm
	
display_d5	macro
	move.w	#'D5',reg_data
	move.w	d5,d6
	bsr	display_reg
	endm
	
display_d6	macro
	move.w	#'D6',reg_data
	bsr	display_reg
	endm
	
display_d7	macro
	move.w	#'D7',reg_data
	move.w	d7,d6
	bsr	display_reg
	endm

