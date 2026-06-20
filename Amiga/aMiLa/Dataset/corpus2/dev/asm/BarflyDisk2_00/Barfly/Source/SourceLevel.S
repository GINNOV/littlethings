	bopt	sa,c,sd

forbid=-132
permit=-138

test	MACRO
	add.l	d0,d0
	ENDM

main:
	moveq	#0,d0
	test
	move.l	4.w,a6
	jsr	forbid(a6)		;For testing in NON-Source areas
	jsr	hunk2
	jsr	permit(a6)
	rts

	code
hunk2:
	rts

