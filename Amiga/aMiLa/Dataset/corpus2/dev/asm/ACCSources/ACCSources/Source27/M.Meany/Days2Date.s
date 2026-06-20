
; Written to check Date conversion routines.

		incdir		sys:include/
		include		exec/exec_lib.i
		include		libraries/dos_lib.i


Start		lea		dosname(pc),a1
		moveq.l		#0,d0
		CALLEXEC	OpenLibrary
		move.l		d0,_DOSBase
		beq		ErrorNoDos

		
		move.l		#DS,d1
		CALLDOS		DateStamp
		tst.l		d0
		beq		ErrorNoStamp		exit if no time set
		
		lea		DS(pc),a0
		lea		DateBuffer(pc),a1
		bsr.s		GetDate

		move.l		a1,a0
		bsr		GetDays
		
ErrorNoStamp	move.l		_DOSBase,a1
		CALLEXEC	CloseLibrary
		
ErrorNoDos	moveq.l		#0,d0
		rts

dosname		dc.b		'dos.library',0
		even
_DOSBase	dc.l		0

DS		ds.l		4

DateBuffer	ds.b		20

		*****************************************
		*    Routines to convert DateStamp()	*
		*  into useable values. M.Meany, 1992.	*
		*****************************************

; This routine will convert the day count returned by DateStamp() into the
;date proper so it can be used! MM.

; Entry		a0->DateStamp structure (initialised by a call to DateStamp())
;		a1->buffer for date string ( at least 12 bytes )

; Exit		buffer will be filled with date string in form dd-mmm-yyyy,
;		string will be NULL terminated.

; Corrupt	None

GetDate		movem.l		d0-d4/a0-a4/a6,-(sp)

; We want todays date, but today has not elapsed yet! Bump day count to
;accomodate this.

		move.l		(a0),d0			get days since 1:1:78
		addq.l		#1,d0			bump days

; To calculate the year, continualy subtract the days in a year from the
;days elapsed since 01-Jan-78. If there are less days left than there are in
;a year, the year has been found. Leap years must be accounted for.

		move.l		#1978,d1		set year

.YearLoop	cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days
		
		cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days

		cmp.l		#366,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#366,d0			dec days

		cmp.l		#365,d0
		ble.s		.GotYear
		
		addq.w		#1,d1			bump year
		sub.l		#365,d0			dec days

		bra.s		.YearLoop

; When we get here, d7 will hold the correct year and d0 the number of days
;into the year ... getting closer:

.GotYear	move.w		d1,-(sp)		year onto stack

		lea		DaysInMonth(pc),a0	a0->days array
		move.w		#28,10(a0)		default not leap
		
		divu		#4,d1			year / 4
		swap		d1			get remainder
		tst.w		d1			is leap year?
		bne.s		.MonthLoop		no so skip
		move.w		#29,10(a0)		else feb=29 days

; When we get here, the DaysInMonth will have been set to account for leap
;years which have 29 days in february as opposed to 28 days in a normal year.


.MonthLoop	move.l		a0,d2			addr of month name
		addq.l		#4,a0			bump
		move.w		(a0)+,d1		get days in month

		cmp.w		d1,d0			found month yet?
		ble.s		.GotMonth		yes, exit loop!
		
		sub.w		d1,d0			no, dec days
		bra.s		.MonthLoop		and loop
		
.GotMonth	move.l		d2,-(sp)		addr onto stack
		move.w		d0,-(sp)		days onto stack

		lea		DS_template(pc),a0	C format string
		move.l		a1,a3			output buffer
		move.l		sp,a1			data stream
		lea		.PutC(pc),a2		subroutine
		CALLEXEC	RawDoFmt		build date

		addq.l		#8,sp			flush stack
		movem.l		(sp)+,d0-d4/a0-a4/a6
		rts

; Subroutine called by RawDoFmt()

.PutC		move.b		d0,(a3)+		copy char
		rts

		****************************************

; Convert a date into days since 1st Jan 1978 as would be returned by the DOS
;function DateStamp(). This is the reverse function of my GetDate subroutine.

; Entry		a0->string to convert, must be valid for sensible return.
;		    dd-mmm-yyyy eg 03-jan-1991

; Exit		d0=days, 0 => error in date string

GetDays		move.l		d1,-(sp)		save
		move.l		d2,-(sp)
		move.l		a0,-(sp)

		bsr		StrToLong		get day of week
		move.l		d0,d2

		lea		DaysInMonth(pc),a1	a1->month data
		move.b		(a0)+,d0
		asl.w		#8,d0
		move.b		(a0)+,d0
		asl.l		#8,d0
		move.b		(a0)+,d0
		asl.l		#8,d0
		addq.l		#1,a0			step over '-' char
		
		moveq.l		#0,d1
.MonthLoop	cmp.l		(a1)+,d0		this month
		beq.s		.GotMonth		yep, exit loop
		add.w		(a1)+,d1		no, bump counter
		bra.s		.MonthLoop

.GotMonth	add.l		d1,d2
		bsr		StrToLong		get year
		
		sub.w		#1978,d0		no error check!

.YearLoop	tst.w		d0
		beq.s		.GotYear
		
		add.l		#365,d2			bump days
		subq.w		#1,d0
		beq.s		.GotYear		exit if there
		
		add.l		#365,d2			bump days
		subq.w		#1,d0
		beq.s		.GotYear		exit if there

		add.l		#366,d2			bump days (leap year)
		subq.w		#1,d0
		beq.s		.GotYear		exit if there

		add.l		#365,d2			bump days
		subq.w		#1,d0
		bne.s		.YearLoop		loop if not there

.GotYear	move.l		d2,d0			into d0
		
		move.l		(sp)+,a0		restore
		move.l		(sp)+,d2
		move.l		(sp)+,d1
		rts
		
		****************************************

; Entry		a0->string terminated by a char out of range '0' - '9'

; Exit		d0=value or 0 on conversion error
;		a0->byte after end of string

; Corrupt	d0,a0

StrToLong	move.l		d1,-(sp)		save
		move.l		d2,-(sp)

		moveq.l		#0,d0			clear these
		move.l		d0,d1

.CharLoop	move.b		(a0)+,d0
		sub.b		#'0',d0
		bmi.s		.GotWord
		cmpi.b		#10,d0
		bge.s		.GotWord

; Long word multiplication by 10. Faster than mulu and handles bigger numbers

		asl.l		#1,d1			num x2
		move.l		d1,d2
		asl.l		#1,d2			num x4
		add.l		d2,d1
		add.l		d2,d1

		add.l		d0,d1
		bra.s		.CharLoop

.GotWord	move.l		d1,d0
		move.l		(sp)+,d2		restore
		move.l		(sp)+,d1
		rts

		
DaysInMonth	dc.b		'j','a','n',0
		dc.w		31
		dc.b		'f','e','b',0
		dc.w		28
		dc.b		'm','a','r',0
		dc.w		31
		dc.b		'a','p','r',0
		dc.w		30
		dc.b		'm','a','y',0
		dc.w		31
		dc.b		'j','u','n',0
		dc.w		30
		dc.b		'j','u','l',0
		dc.w		31
		dc.b		'a','u','g',0
		dc.w		31
		dc.b		's','e','p',0
		dc.w		30
		dc.b		'o','c','t',0
		dc.w		31
		dc.b		'n','o','v',0
		dc.w		30
		dc.b		'd','e','c',0
		dc.w		31

DS_template	dc.b		'%02d:%s:%04d',0
		even

		****************************************
