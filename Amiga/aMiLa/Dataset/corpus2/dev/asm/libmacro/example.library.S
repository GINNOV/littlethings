;##############################################################################
;
; $VER: example.library 1.1 (13.4.1995)  Rudla Kudla
;
;##############################################################################

		INCDIR	"INCLUDES:"
		INCLUDE	"exec/types.i"
		INCLUDE	"exec/macros.i"
		INCLUDE	"exec/exec_lib.i"
		INCLUDE	"exec/libraries.i"
		INCLUDE	"kudlar/library.i"

;======	Declare library base structure (that extra long after LIB_SIZE is
;	used to store library segment, see init and close) and count it's
;	size.

		STRUCTURE ExampleBase,LIB_SIZE+4

		;Here insert declarations of your own variables

		LABEL	ex_SIZEOF


;======	Define library header and declare function names

		LIBRARY	example,1,0,5.3.1995,ex_SIZEOF
		;	name,version,revision,date,librarybase size

		LIBRARY	FUNCTIONS
		LIBRARY	OpenLib,CloseLib,ExpungeLib,ExtFuncLib

		;Here insert your library functions names (as shown on
		;UserAdd, UserSub and UserMul). LIBRARY macro can be followed
		;with upto 9 names of functions.

		LIBRARY	UserAdd,UserSub
		LIBRARY	UserMul

;======	Following functions are required. They are used when openning or
;	closing library. You can however modify them as you wish.

		LIBRARY	CODE

		LIBRARY	Init
		exg	a0,d0
		move.l	d0,LIB_SIZE(a0)
		exg	a0,d0

		;You will probably want to make some initializations here.
		;Remember, that you must return all registers (including
		;d0-d1/a0-a1) unchanged.

		rts


		LIBRARY	OpenLib	
		add.w	#1,LIB_OPENCNT(a6)
		bclr	#LIBB_DELEXP,LIB_FLAGS(a6)
		move.l	a6,d0
		rts

		LIBRARY	CloseLib
		subq.w	#1,LIB_OPENCNT(a6)
		bne.b	ExtFuncLib
		btst	#LIBB_DELEXP,LIB_FLAGS(a6)
		beq.b	ExtFuncLib

		LIBRARY	ExpungeLib
		movem.l	d2/a5/a6,-(sp)
		tst.w	LIB_OPENCNT(a6)
		bne.b	.still_openned

		;On this place free all resources which has been
		;allocated in init part. a6 contain library base.

		move.l	LIB_SIZE(a6),d2
		move.l	a6,a5
		move.l	4.w,a6
		move.l	a5,a1
		JSRLIB	Remove
		move.l	a5,a1
		moveq	#0,d0
		move.w	LIB_NEGSIZE(a5),d0
		sub.w	d0,a1
		add.w	LIB_POSSIZE(a5),d0
		JSRLIB	FreeMem
		move.l	d2,d0
		movem.l	(sp)+,d2/a5/a6
		rts

.still_openned
		bset	#LIBB_DELEXP,LIB_FLAGS(a6)

		LIBRARY	ExtFuncLib
		moveq	#0,d0
		rts

;======	Now follows code for all declared library specific functions.

		LIBRARY	UserAdd
		add.l	d1,d0
		rts

		LIBRARY	UserSub
		sub.l	d1,d0
		rts

		LIBRARY	UserMul
		mulu	d1,d0
		rts
		
		LIBRARY	END
