
*****	Title		test3.s
*****	Function	Checks a number of macros :-)
*****			OPENDOS, CASESTR, CLEANUP, PUTSTR.
*****			
*****	Size		734 bytes
*****	Author		Mark Meany
*****	Date Started	July 92
*****	This Revision	
*****	Notes		
*****			

		incdir		source:include/
		include		marks/mm_macros.i

Start		OPENDOS

		CASESTR		#CMD3,#Table

		CASESTR		#Dummy,#Table

		CLEANUP		

; Subroutines required by action table

GoNorth		PUTSTR		#CMD1
		bsr		DoLf
		rts

GoSouth		PUTSTR		#CMD2
		bsr		DoLf
		rts

GoEast		PUTSTR		#CMD3
		bsr		DoLf
		rts

GoWest		PUTSTR		#CMD4
		bsr		DoLf
		rts

NoGo		PUTSTR		#ErrMsg
		bsr		DoLf
		rts

DoLf		PUTSTR		#LineFeed
		rts

		include		marks/mm_subs.i

; Action table as required by CASESTR

Table		dc.l		CMD1,GoNorth
		dc.l		CMD2,GoSouth
		dc.l		CMD3,GoEast
		dc.l		CMD4,GoWest
		dc.l		0,NoGo

; Recognised Commands

CMD1		dc.b		'North',0
		even
CMD2		dc.b		'South',0
		even
CMD3		dc.b		'East',0
		even
CMD4		dc.b		'West',0
		even

; other strings

ErrMsg		dc.b		'What?',0
		even
Dummy		dc.b		'Up',0
		even
LineFeed	dc.b		$0a,0
		even
