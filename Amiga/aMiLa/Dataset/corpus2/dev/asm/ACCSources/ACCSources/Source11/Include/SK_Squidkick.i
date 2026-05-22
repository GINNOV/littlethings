;SQUIDKICK macros ; Simon Knipe ; v1.0

;	CHECKFORKEY	specific Squidkick macro to set needed flags and
;			addresses when a key is pressed from the main
;			menu, then print the correct page of information.
;	FILE		Automatically creates labels for included text.

************************************************************** MISC ***
;Purpose: specific Squidkick macro to set needed flags and addresses
;		when a key is pressed from the main menu, then print
;		the correct page of information

;To call: CHECKFORKEY AsciiValue,BranchIfNot,FilenameBelongingToKey,
;		Filename2BelongingToKey,NumberOfPages,TitleText

CHECKFORKEY MACRO
		cmp.b		#\1,d1		check for ascii value
		bne		\2		no then branch

		move.l		windowhd,a0	window adr
		lea		\6,a1		new titlebar text adr
		lea		wnamemenu,a2	new screen name
		MAKECALL intbase,setwindowtitles

		lea		\3,a2		load filename 1st colour
		lea		\4,a3		load filename 2nd colour
		move.l		#\3end,fileend
		move.l		#\3,file		save file adr
		move.l		#\4end,file2end
		move.l		#\4,file2		save file adr 2

		move.b		#\5+48,pages	page number + ascii offset
		move.b		#49,pageno	set to page 1

		bsr		printpage	print 1st page belonging
		ENDM				to key pressed
************************************************************** MISC ***
;Purpose: Automatically creates labels for included text files on my
;		work disc.
;To call: FILE ShortFileName	(eg: "menu" = "programs:sk/sk_menu")

FILE MACRO
\1
		incbin		programs:SK/SK_\1
\1end
		ENDM
