
	        	***************
		        * Startup.asm *
		        ***************


* some startup code to make a Workbench execute look like the CLI
* based loosely on RKM Vol 1 page 4-36
* adapted for procalc Jan 1992
		
		IFND		EXEC_EXEC_I
		INCLUDE		exec/exec.i
		INCLUDE		Exec/Exec_Lib.i
		ENDC
		IFND		LIBRARIES_DOSEXTENS_I
		INCLUDE		libraries/dosextens.i
		ENDC

		INCLUDE		Intuition/Intuition_Lib.i
		INCLUDE		Intuition/Intuition.i
		INCLUDE		Graphics/Graphics_Lib.I
		INCLUDE		Libraries/Dos_Lib.i
		INCLUDE		Math/Mathffp_Lib.i
		INCLUDE		Math/MathTrans_Lib.i

PUSH		MACRO
		MOVE.l		\1,-(SP)
		ENDM

PULL		MACRO
		MOVE.l		(SP)+,\1
		ENDM

CALL		MACRO
		JSR		_LVO\1(A6)
		ENDM

;		This section to use fastmem if poss.

		SECTION		MainProgram,Code


_Start_Up	MOVE.l		A7,_Stack
		MOVEM.l		D0/A0,-(SP)		save initial values
		SUB.l		A1,A1
		CALLEXEC 	FindTask		find us
		MOVE.l		D0,A4
		TST.l		pr_CLI(A4)
		BNE.s		.FromCLI

.fromWB		LEA		pr_MsgPort(A4),A0
		CALLEXEC 	WaitPort		wait for a message
		LEA		pr_MsgPort(A4),A0
		CALLEXEC 	GetMsg			then get it
		MOVE.l		D0,_ReturnMsg		save it for later reply

.FromCLI	MOVEM.l		(SP)+,D0/A0		restore
		
		LEA		_DosName(PC),A1
		BSR.s		OpenLib
		MOVE.l		D0,_DOSBase
		
		LEA		_IntName(PC),A1
		BSR.s		OpenLib
		MOVE.l		D0,_IntuitionBase
		
		LEA		_GfxName(PC),A1
		BSR.s		OpenLib
		MOVE.l		D0,_GfxBase
		
		LEA		_MathName(PC),A1
		BSR.s		OpenLib
		MOVE.l		D0,_MathBase
		
		LEA		_TransName(PC),A1
		BSR.s		OpenLib
		MOVE.l		D0,_MathTransBase

		BSR		Main
		
Exit		MOVE.l		_Stack(PC),A7
		MOVE.l		_DOSBase(PC),D0
		BSR.s		CloseLib
		MOVE.l		_IntuitionBase(PC),D0
		BSR.s		CloseLib
		MOVE.l		_GfxBase(PC),D0
		BSR.s		CloseLib
		MOVE.l		_MathTransBase(PC),D0
		BSR.s		CloseLib
		MOVE.l		_MathBase(PC),D0
		BSR.s		CloseLib
		
		TST.l		_ReturnMsg
		BEQ.s		.DosExit
		CALLEXEC	Forbid
		MOVE.l		_ReturnMsg(PC),a1
		CALLEXEC	ReplyMsg
.DosExit	MOVEQ		#0,D0
		RTS
		
OpenLib		MOVEQ		#0,D0
		CALLEXEC	OpenLibrary
		TST.l		D0
		BEQ.s		Exit
		RTS

CloseLib	TST.l		D0
		BEQ.s		EmptyLib
		MOVE.l		D0,A1
		CALLEXEC	CloseLibrary
EmptyLib	RTS
		

;		VARIABLES

_DOSBase	DC.l		0
_GfxBase	DC.l		0
_IntuitionBase	DC.l		0
_MathBase	DC.l		0
_MathTransBase  DC.l		0		
_ReturnMsg	DC.l			0
_Stack		DC.l			0
		
_DosName	DC.b		'dos.library',0
_GfxName	DC.b		'graphics.library',0
_IntName	DC.b		'intuition.library',0
_MathName	DC.b		'mathffp.library',0
_TransName	DC.b		'mathtrans.library',0


		RSSET		-256
				
;		LONGS
HighMem		RS.b   0
String		RS.l   1
Integer		RS.l   1
Float	        RS.l   1
Remainder	RS.l   1
NewNum		RS.l   1
GadMem		RS.l   1
BtnMem		RS.l   1
OldBtn		RS.l   1
WindowHD	RS.l   1
Divisor		RS.l   1
PortWW		RS.l   1
Old_WorkStore	RS.l   1
Old_Display	RS.l   1
fp_Store	RS.l   1
K_Store		RS.l   1
Store		RS.l   1
Micros		RS.l   1
TimSeconds	RS.l   1
OldSeconds	RS.l   1
BigText		RS.l   1
SmallText	RS.l   1
TextSize	RS.l   1
WinPos		RS.l   1

;		WORDS
Operand		RS.w   1
fp_Operand	RS.w   1   
K_Operand	RS.w   1   
Exponent	RS.w   1
Random		RS.w   1
Overflow	RS.w   1
fp_Flag		RS.w   1
fp_Mode		RS.w   1
fp_PerSums	RS.w   1
fp_Point	RS.w   1
NewMode		RS.w   1
NewY		RS.w   1
Hours		RS.w   1
Minutes		RS.w   1
TextColour	RS.w   1
Dummy		RS.w   1


;		DEFINES


XSet		EQU     -4
YSet		EQU      7
Txt9		EQU    $80
HalfDay		EQU  43200
HeightWW	EQU    112
Multiply	EQU  $CCC7
Division	EQU  $8CC7
MAXGADS		EQU     42
Border1		EQU	 0
Border2		EQU	-1
WorkStore	EQUR	D6
Display		EQUR	D7
MemSize		EQU   MAXGADS*gg_SIZEOF

DMA		EQU		$DFF096
ADC		EQU		$DFF09E-DMA
HiTable		EQU		$DFF0A0-DMA
LenTable	EQU		HiTable+4
ReadRate	EQU		HiTable+6
Volume		EQU		HiTable+8		

	
