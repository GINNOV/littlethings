	OPT	C-,D+,O+

;P.KENT.
;RELOCATION EXAMPLE! FOR SYSTEM KILLER DEMOS ETC.
;RELOCATES INCLUDED FILE AT 'INC' TO MEMORY
;CAN BE SET TO RELOCATE TO ANYWHERE
;HANDLES *SOME* DEBUG/SYMBOL HUNKS 6/2/92 *NOT YET TESTED FULLY*

;BASED ON HUNK EXAMINATION PROGRAM IN THE SYSTEM PROGRAMMERS GUIDE,
;& THE COMMODORE LOADER EXAMPLE INCLUDED WITH ARGASM.

;IF YOU AREN'T FAMILIAR WITH HUNKS ETC. I ADVISE AGAINST USING THE
;CODE IN ITS PRESENT FORM! THIS CODE IS INTENDED TO BE USED
;FOR PRIVATE RELOCATION AFTER (SAY) DIRECT LOADING OF DATA FROM DISK DRIVES.
;IE. NO DOS AROUND!

HUNK_UNIT	=	$3E7
HUNK_NAME	=	$3E8
HUNK_CODE	=	$3E9
HUNK_DATA	=	$3EA
HUNK_BSS	=	$3EB
HUNK_RELOC32	=	$3EC
HUNK_RELOC16	=	$3ED
HUNK_RELOC8	=	$3EE
HUNK_EXT	=	$3EF
HUNK_SYMBOL	=	$3F0
HUNK_DEBUG	=	$3F1
HUNK_END	=	$3F2
HUNK_HEADER	=	$3F3
HUNK_OVERLAY	=	$3F5
HUNK_BREAK	=	$3F6

	MOVEM.L	A0-A6/D1-D7,-(A7)

	LEA	INC(PC),A0	; Find out relocated length of file.
	SUB.L	A1,A1
	BSR	Reloc
	MOVE.L	D0,D6		; Save length
	MOVEQ	#2,D1		; Chip memory
	MOVE.L	4.W,A6
	JSR	-198(A6)
	TST.L	D0
	BEQ.S	Quitfast	; No memory?
	
	MOVE.L	D0,D7	
	LEA	INC(PC),A0	; Source data
	MOVE.L  D0,A1		; Destination for relocated code (contiguous)
	BSR	Reloc
	TST.L	D0
	BNE.S	RelocFail
	JSR	8(A1)		; Run relocated program
RelocFail
	MOVE.L	D7,A1		; Memory to free.
	MOVE.L	D6,D0		; Length
	MOVE.L	4.W,A6
	JSR	-$D2(A6)	; Free it
Quitfast
	MOVEM.L	(A7)+,A0-A6/D1-D7
	MOVEQ	#0,D0
	RTS	
 
; RELOCATE file A0->A1,RETURN IN D0 D0=0 OK D1=-1 FAIL
; IF A1=0, NO RELOCATION TAKES PLACE BUT D0=LENGTH OF MEM REQD IS RETURNED,
; FOR RELOCATED FILE IN BYTES!
Reloc
	MOVEM.L	D1-D7/A0-A6,-(SP)
	MOVE.L	A1,A4
	MOVE.L	A1,A3
	MOVE.L	(A0)+,D0
	CMP.L	#HUNK_HEADER,D0		; Must start with a HUNK_HEADER
	BNE	RelocError

HunkName	MOVE.L	(A0)+,D0	; If its named, skip name
	BEQ.S	HunkOK
	ADD.L	D0,D0		; Have length, convert from BCPL, add to ptr
	ADD.L	D0,D0
	ADD.L	D0,A0
	BRA.S	HunkName
 
HunkOK	MOVE.L	(A0)+,D7
	MOVE.L	D7,D6		; Got num hunks...
	LSL.L	#3,D7		; 2 long words per hunk
	SUB.L	D7,SP
	ADDQ.W	#8,A0		; Skip first/last hunk nos
	MOVE.L	SP,A1
	MOVE.L	SP,A5
HunkSetUplp
	MOVE.L	(A0)+,D0	; Get hunk length
	ADD.L	D0,D0
	ADD.L	D0,D0
	MOVE.L	D0,(A1)+	; Length
	ADDQ.L	#8,A3		; Add segment header
	MOVE.L	A3,(A1)+	; Ptr
	ADD.L	D0,A3
	SUBQ.L	#1,D6
	BNE.S	HunkSetUplp

	CMP.L	#0,A4		; Are we goinb to reloc or suss length ?
	BNE.S	HunkDoIt
;Suss length - total hunk lengths in header longwords
	MOVE.L	D7,D0		; Zero count+8 bytes per hunk
HunkSumlp
	ADD.L	(SP)+,D0	; Add lengths etc.
	ADDQ.L	#4,SP		; Recover stack at same time!
	SUBQ.L	#8,D7
	BNE.S	HunkSumlp
	BRA	RelocOK

HunkDoIt
	MOVE.L	D7,D6
HunkProcLp
	MOVE.L	(A0)+,D0	; Get hunk type
	BSR.S	IDPROC_HUNK
	BNE.S	HunkProcLp
	BRA	RelocDone

IdProc_Hunk
	CMP.W	#HUNK_UNIT,D0
	BEQ	HunkSkip
	CMP.W	#HUNK_NAME,D0
	BEQ	HunkSkip
	CMP.W	#HUNK_CODE,D0
	BEQ	HunkCode
	CMP.W	#HUNK_DATA,D0
	BEQ	HunkCode
	CMP.W	#HUNK_BSS,D0
	BEQ	HunkBSS
	CMP.W	#HUNK_RELOC32,D0
	BEQ	HunkReloc

	CMP.W	#HUNK_SYMBOL,D0	; Implemented 6/2/92
	BEQ	HunkSymb
	CMP.W	#HUNK_DEBUG,D0	; 6/2/92
	BEQ	HunkSkip

	CMP.W	#HUNK_END,D0	; EOF
	BEQ	HunkEnd
	BRA	HunkFin	 	; ID has failed! Must be EXT/16/8/RELOC16
				; or something not in exe files!


HunkCode	MOVE.L	(A0)+,D0	; Get length
	MOVE.L	(A5),D1			; Get length II
	MOVE.L	4(A5),A6
HunkCodelp	MOVE.L	(A0)+,(A6)+	; Copy though
	SUBQ.L	#4,D1
	SUBQ.L	#1,D0
	BNE.S	HunkCodelp
	TST.L	D1			; If length mismatch, wipe rest
	BEQ.S	HunkCodeOk
HunkCodelp2	CLR.L	(A6)+
	SUBQ.L	#4,D1
	BNE.S	HunkCodelp2
HunkCodeOk	MOVEQ.L	#1,D0
	RTS	
 
HunkReloc	MOVE.L	(A0)+,D0	; Get no of relocs
	BEQ.S	HunkRelocFIn
	MOVE.L	(A0)+,D1		; Get hunk
	LSL.L	#3,D1
	MOVE.L	8(SP,D1.L),D3		; get hunk base
	MOVE.L	4(A5),A6
HunReloclp	MOVE.L	(A0)+,D2	; Get offset
	ADD.L	D3,0(A6,D2.L)
	SUBQ.L	#1,D0
	BNE.S	HunReloclp
	BRA.S	HunkReloc
HunkRelocFIn	MOVEQ.L	#1,D0
	RTS	

HunkBSS	MOVE.L	(A0)+,D0		; Get length
	MOVE.L	4(A5),A6		; Get start
HunkBSSlp	CLR.L	(A6)+		; Wipe d0 long words
	SUBQ.L	#1,D0
	BNE.S	HunkBSSlp
	MOVEQ.L	#1,D0
	RTS	
 
HunkSkip	MOVE.L	(A0)+,D0	; Get length, add to file ptr
	ADD.L	D0,D0
	ADD.L	D0,D0
	ADD.L	D0,A0
	MOVEQ.L	#1,D0
	RTS	

HunkSymb
	MOVE.L	(A0)+,D0		; Flush symbol name
	LSL.L	#2,D0
	LEA	(A0,D0.L),A0
	TST.L	D0
	BEQ.S	DoneSym
	ADDQ.L	#4,A0			; Flush symbol value
	BRA.S	hunkSymb
DoneSym
	MOVEQ	#1,D0
	RTS		


HunkFin	MOVEQ.L	#0,D0
	RTS	
HunkEnd	ADDQ.W	#8,A5
	SUBQ.L	#8,D6
	RTS	
 
RelocDone


FixSegs			; Put in segment headers also recovering stack

	MOVE.L	(SP)+,D0	; Length
	MOVE.L	(SP)+,A0	; Ptr
	ADDQ.L	#8,D0		; Length incldues header info
	MOVE.L	D0,-8(A0)	; Punch out segment length


	MOVE.L	4(SP),D1	; Next Ptr	
	SUBQ.L	#4,D1		; Ptrs point to each other NOT actual CODE/DATA
	LSR.L	#2,D1		; Make BCPL
	MOVE.L	D1,-4(A0)	; Put in next ptr
	SUBQ.L	#8,D7		; d7=8*numsegs
	BNE.S	FixSegs
	CLR.L	-4(A0)	; When finished, clear last 'next ptr'  since this
			; will be garbage from stack

	MOVEQ.L	#0,D0
	BRA.S	RelocOK
 
RelocError	MOVEQ.L	#-1,D0
RelocOK	MOVEM.L	(SP)+,D1-D7/A0-A6
	RTS	
INC	INCBIN Source:p.kent/POLY6	<------ Program name here 
INC_LEN	=	*-INC

