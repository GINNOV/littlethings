
        	*******************************************
	        *  Procalc - a calculator for programmers *
	        *******************************************


* Written   :	January 1992	Author 	   : Mick Seymour 		    *
* Assembler :   Devpac II	System     : 3M A590/A500 (1.3 & ARP)	    *
* 									    *
* NOTE      :	To convert the colour configuration amend the equates for   *
* 		"Black" and "White" and alter the binary picture files to   *
*		the 2.0 versions. As I don't have WB2, I have not tested    *
*		the effects on the title clock and gadgets, only allowed an *
*		alternative black/white combination.			    *
*									    *
* NOTE	    :   Using Devpac2 with O+ flag set on WB2.0 Amiga with 1.5 meg  *
*		CHIP mem causes some dangerous optimisations. Program Guru's*
*		when run. Have commented out this option, MM.		    *
*									    *
* 									    *
* BUGS	    :   A few of the first Procalc disks placed in public domain    *
*		had a bug in the shrink routine,(gadget memory being        *
*		freed, while the window and gadgets were still open)        *
*		Procalc now does the sensible thing and closes the window   *
*		first.							    *
* 									    *
* Macros:								    *
* 									    *
* CALL				JSR	_LVO\1(A6)		   	    *
*								    	    *
* CALLDOS/GFX/INT etc.		MOVE.l	_XXXBase(PC),A6			    *
*				CALL	\1				    *
* 									    *
* PUSH/PULL			MOVE.l	To/From stack			    *
* 									    *
* 									    *
Black		EQU      2	WB (2.n = 1)(1.n = 2)
White		EQU      1	WB (2.n = 2)(1.n = 1)

;		OPT		O+ 			Optimise
		OUTPUT		Ram:ProCalc		To ram: for test
		INCDIR		sys:INCLUDE/		My Logical (?) dir
		INCLUDE		Startup.asm		Opens libraries etc

Finis		MOVE.l		WindowHD(A5),A0		release memory
		CALLINT		CloseWindow		close window
NoWinOut	BSR		LoseMem			Free memory
		MOVE.l		BigText(A5),D1		and both fonts
		BSR.s		CloseFont		
		MOVE.l		SmallText(A5),D1
		BSR.s		CloseFont
		UNLK		A5			Release stack vars.
		BRA		Exit			and exit

CloseFont	TST.l		D1
		BEQ.s		.NoClose
		MOVE.l		D1,A1
		CALLGRAF	CloseFont
.NoClose	RTS		


Main		LINK		A5,#-256		Set volatile storage 
		LEA		-256(A5),A0		Get address
		MOVEQ		#127,D0			Length (in words) -1
.MemLoop	CLR.w		(A0)+			and clear block
		DBRA		D0,.MemLoop
		
		MOVEQ		#0,WorkStore		Clear D6
		MOVEQ		#0,Display		Clear D7
		LEA		StructWW2,A0		Open small window
		BSR		DoWindow		using subroutine
		LEA		Topaz9(PC),A0		Locate Topaz9
		CALLGRAF	OpenFont		
		MOVE.l		D0,BigText(A5)		
		LEA		Topaz8(PC),A0		Locate Topaz8
		CALL		OpenFont	
		MOVE.l		D0,SmallText(A5)
						
MainLoop	MOVEQ		#1,D1			Short delay in D1
		TST.w		NewY(A5)		Test for window size
		BNE.s		.ShortWait		NE short delay only
		MOVEQ		#8,D1			EQ longer delay as we
.ShortWait	CALLDOS		Delay			only have the
Retry		BSR		Timer			clock to service
		BSR		Messages		until msg received
		BEQ.s		MainLoop		if no msg - retry
CheckIn		MOVE.l		D0,A1	
		MOVE.l		im_Class(A1),D2		IDCMP class here
		MOVE.w		im_Code(A1),D3		Keycodes here
		CALL		ReplyMsg		Return msg
		
.Options	LEA		FirstButton(PC),A0	A0  = Ptr to list
		CMP.w		#CLOSEWINDOW,D2		msg = CloseWindow ?
		BEQ		Finis			YES - shut up shop
		CMP.w		#GADGETDOWN,D2		msg = gadget used ?
		BEQ.s		Selected		YES - do key routine
		CMP.l		#VANILLAKEY,D2		msg = key pressed ?
		BNE.s		Retry			No  - try again
			
.KeyPress	CMP.b		#'A',D3			If key = A-Z 
		BLT.s		.NonAlpha		convert to lower case
		CMP.b		#'Z',D3			else leave intact
		BGT.s		.NonAlpha
		OR.b		#$20,D3
.NonAlpha	LEA		FirstButton(PC),A0
		MOVEQ		#MAXGADS,D0		Check all keys
		CMP.b		#13,D3			in list
		BNE.s		.esc			unless key = RTN
		MOVEQ		#'=',D3
.esc		CMP.b		#27,D3			or key = ESC
		BEQ.s		DoShrink
		MOVE.w		Calcmode(PC),D1		68K or FFP ? 
.KeyLook	CMP.b		bn_KeyFloat(A0,D1),D3	match on key ?
		BEQ.s		Perform			YES - do function
		ADD.l		#bn_SIZEOF,A0		Next structure in A0
		DBRA		D0,.KeyLook
		BRA.s		Retry			No valid keys - retry
Selected	MOVE.l		GadMem(A5),D0		Extra gadgets ?
		BEQ.s		TryShrink		No  - only one to try
.GadCheck	MOVE.l		D0,A0			Next structure
		BCLR		#7,gg_Flags+1(A0)	Gadget selected ?
		BNE.s		Gad_Action		YES - do function
		MOVE.l		(A0),D0			No  - try next
		BNE.s		.GadCheck

TryShrink	BCLR		#7,Gad_Shrink+gg_Flags+1 
		BEQ		MainLoop		if SHRINK/EXPAND
DoShrink	BSR		Shrink			perform it
		BRA		MainLoop
Gad_Action	MOVE.l		gg_UserData(A0),A0	Set list ptr for gads
Perform		MOVE.l		A0,BtnMem(A5)		save list ptr 
		LEA		BDR1_In(PC),A1		A1  = small border
		TST.b		bn_BorderType(A0)	if (A0).b = zero
		BEQ.s		.Small			else ...
		LEA		BDR2_In(PC),A1		A1  = large border 
.Small		BSR.s		Buttons			Push button in
		MOVE.l		BtnMem(A5),A0		Retrieve ptr
		LEA		fp_OpSign(PC),A1	A1  = ptr for opsign
		MOVE.w		bn_Opcode(A0),D0	D0  = 68K opcode
		MOVE.w		Calcmode(PC),D2		D2  = byte offset
		MOVE.b		bn_CharFloat(A0,D2),D1	D1  = char (if any)
		ASL.w		#1,D2			D2  = word offset
		TST.b		D1			Don't overprint
		BEQ.s		.skipchar		if char = 0
		MOVE.b		D1,(A1,D2)		else set Operand sign

.skipchar	MOVE.w		(A0,D2),D2		D2  = main-function
		LEA		Main(PC),A6		A6  = main
		JSR		(A6,D2)			perform function
		
		MOVE.l		BtnMem(A5),A0		A0  = list ptr
		MOVE.l		BtnMem(A5),OldBtn(A5)	As before test for
		LEA		BDR1_Out(PC),A1		button size
		TST.b		bn_BorderType(A0)
		BEQ.s		.Small2
		LEA		BDR2_Out(PC),A1
.Small2		BSR.s		Buttons			Push button in 
		BRA		Retry			and loop back

Buttons		MOVEQ		#0,D1			To simulate extend
		MOVE.w		bn_PosX(A0),D0		Set X offset
		MOVE.b		bn_PosY(A0),D1		Set y offset
		MOVE.l		PortWW(A5),A0		Fetch rastport
		MOVE.l		_IntuitionBase(PC),A6
		JMP		_LVODrawBorder(A6)

Messages	MOVE.l		WindowHD(A5),A0		A0 = Window
		MOVE.l		86(A0),A0		A0 = UserPort
		CALLEXEC	GetMsg			Read message
		TST.l		D0			and test D0
		RTS
		
LoseMem		MOVE.l		GadMem(A5),D1		Relase memory for
		BEQ.s		.NoMem			gadgets (if any)
		CLR.l		GadMem(A5)		and clear ptr
		MOVE.l		#MemSize,D0
		MOVE.l		D1,A1
		CALLEXEC	FreeMem
.NoMem		RTS
		


Shrink		MOVE.l		WindowHD(A5),A0		Window in A0
		MOVE.l		4(A0),WinPos(A5)	Save old positions
		CALLINT		CloseWindow		Close old window
		EOR.w		#$0303,TXT_Clock	Swop text colours
		NOT.w		NewY(A5)		Reverse size flag
		BEQ.s		.MakeSmall		and branch if small

.MakeBig	BSR		BuildGadgets		Make extra gadgets
		LEA		StructWW1,A0		A0 = large  screen
		LEA		StructWW2,A1		A1 = little screen 
		LEA		ShrinkText(PC),A2	"SHRINK" in (A2)
		BRA.s		.SetWindow		
		
.MakeSmall	BSR.s		LoseMem			Clear gadget memory
		LEA		StructWW2,A0		A0 = little screen 
		LEA		StructWW1,A1		A1 = large  screen
		LEA		ExpandText(PC),A2	"EXPAND" in (A3) 
		
.SetWindow	MOVE.l		WinPos(A5),(A1)		Old positions in
		LEA		TitleWW+1(PC),A1	old nw struct
		MOVEQ		#5,D0			Move 6 chars from
.Loop		MOVE.b		(A2)+,(A1)+		(A2) into title text
		DBRA		D0,.Loop

DoWindow	CALLINT		OpenWindow		Open new window
		MOVE.l		D0,WindowHD(A5)		Save and test
		BNE.s		.WinOK			If window fails ...
		BSR		AlertUser		Inform user
		BRA		NoWinOut		and then exit
		
.WinOK		MOVE.l		D0,A0			Else ...
		MOVE.l		50(A0),PortWW(A5)	Find rastport
		MOVEQ		#2,D0			Arrange priority over
		LEA		Gad_Shrink,A1		system gadgets then
		BCLR		#7,gg_Flags+1(A1)	clear select flag and
		CALL		AddGadget		add SHRINK gadget
		TST.w		NewY(A5)		Check window size
		BNE.s		CalcDraw		NE = draw picture
		RTS					else return

CalcDraw	MOVE.l		PortWW(A5),A0		A0 = rastport
		LEA		PixScreen,A1		A1 = pic structure
		MOVEQ		#0,D0			Offsets at zero
		MOVEQ		#0,D1
		CALLINT		DrawImage		Draw calculator
		BRA.s		Do_Display		and displays

Input		MOVE.l		Display,D1		D1 = Display
		MOVE.l		BitSwitch(PC),D3	D3 = mask
		AND.l		D3,D1			D1 = Display.b/.w/.l
		MOVE.w		D1,Divisor(A5)		Save D1(Lo)
		SWAP		D1			D1.w  = D1(Hi)
		MOVE.w		Base(PC),D5		D5 = Base
		MULU		D5,D1			D1.l = Display(Hi)*Base
		SWAP		D1			Check for Overflow
		TST.w		D1			in D1(Hi)
		BNE.s		Input_Error		
		MOVE.w		Divisor(A5),D2		D1.w = Display(Lo)
		MULU		D5,D2			D2.l = Disp(Lo)*Base
		ADD.l		D2,D0			Add our Input and
		BCS.s		Input_Error		check for overflow
		ADD.l		D1,D0			Combine results
		BCS.s		Input_Error		and check again
		SUB.l		D0,D3			against size(.b or.w)
		BCS.s		Input_Error		
Mixer		MOVE.l		BitSwitch(PC),D4	Fetch "AND" mask
		NOT.l		D4			and reverse
		AND.l		Display,D4		restrict size
		OR.l		D4,D0			D0 = result
		RTS
		
Input_Error	BSR		Beep			Alert user
		MOVE.l		Display,D0		Retain display
Input_Exit	RTS				

Do_PULL		MOVE.l		Store(A5),D0		Retreive store
		BRA.s		PULL_In			and branch ..

Do_Number	MOVEQ		#0,D1			Nil offset for list
		AND.l		#$FF,D0			Extend D0 no sign
		CMP.w		Base(PC),D0		D0 > Base ?
		BGE		Beep			Yes - beep and rtn
		TST.w		NewMode(A5)		Is it first number ?
		BNE.s		NextNum			No - goto input
PULL_In		MOVE.w		#1,NewMode(A5)		Input mode
		MOVE.l		Display,WorkStore	Save old display
.Replace	MOVE.l		D0,Display		Display = number
		BRA.s		Do_Display		show result and rtn

NextNum		BSR.s		Input			Perform input
		MOVE.l		D0,Display		Update display
	
Do_Display	TST.w		Calcmode		68k or FFP ?
		BEQ		ShowFFP			
		BSR		DrawBits		Draw binary bits
		MOVE.w		SizeMask(PC),D0		Mask in D0
		MOVE.w		#$4A00,ALT1		"TST.b" in ALT1
		ADD.w		D0,ALT1			Add size (0,.w,.l)
		MOVE.w		#$4400,ALT2		"NEG.b" in ALT2
		ADD.w		D0,ALT2			Add size (0,.w,.l)
		LEA		UnsignText(PC),A0	Set string ptr in A0 
		MOVE.l		Display,D0		and copy display
		BSR.s		StrConvert		then convert string
		MOVEQ		#'+',D1			D1 = "+"
		MOVE.l		Display,D0		Copy display and test
ALT1		TST.b		D0			modified sign test
		BPL.s		Plus			branch if positive 
ALT2		NEG.l		D0			Modified negate
		MOVEQ		#'-',D1			Use "-"
Plus		MOVE.b		D1,Sign			set sign text then
		LEA		SignText(PC),A0		set string ptr in A0
		BSR.s		StrConvert		and convert to base

OSD		LEA		TextList_68k(PC),A0	Text ptr in A0
		BRA		TextOut			Print text and rtn

fp_Hexit	MOVE.l		Display,D0		Copy display and test
		BEQ		Ticks			If zero wait and rtn
		MOVE.w		Base,-(SP)		Save 68k base
		MOVE.w		#16,Base		and set to hex
		MOVEQ		#8,D4			Strlen = 9
		LEA		Inkeys(PC),A0		String ptr in A0
		BSR.s		Hexit			Use 68k hex routine
		MOVE.b		#'$',Inkeys		Add leading "$" 
		MOVE.w		(SP)+,Base		Retreive 68k base
		CLR.w		fp_Mode(A5)		Reset flags 
		CLR.w		fp_Flag(A5)		Passive + sums done
		MOVE.w		#'  ',EXP_Text		Blank exponent and
		MOVE.b		#' ',Sign		sign text
		BRA		Hexin			Show results and rtn

StrConvert	MOVEQ		#10,D4			Strlen=11 (for octal)
		AND.l		BitSwitch(PC),D0	Does anyone use it ??
Hexit		LEA		HexArray(PC),A1		A1 = 1,2, .. D,E etc.	
		PUSH		D4			Save strlen
.Loop		MOVE.b		#$20,(A0,D4)		Blank our string
		DBRA		D4,.Loop
		
		PULL		D4			Retreive strlen
StrLoop		BSR.s		BaseDivision		Get rightmost char
		MOVE.b		(A1,D1),(A0,D4)		and set
		TST.l		D0			At end ...
		DBEQ		D4,StrLoop		
		CLR.b		11(A0)			Add trailing zero
.AllSet		RTS														
	
DrawBits	LEA		BitList(PC),A4		(A4) = 68k bits
		BSR.s		ProBits			Draw binary pics
		MOVE.l		PortWW(A5),A0		Rastport in A0
		LEA		PIC_Base,A1		Pic in A1
		MOVEQ		#0,D0			No x offset
		MOVEQ		#0,D1			No y offset
		CALL		DrawImage		Draw picture
		RTS
			
FFP_Bits	LEA		FFP_BitList(PC),A4	(A4) = FFP bits
ProBits		MOVE.l		_IntuitionBase(PC),A6		set intuition lib
		MOVEQ		#31,D0			Do 32 bits
		PUSH		Display			Save display
BitLoop		PUSH		D0			Save D0
		LEA		ZeroPic,A0		Pic = "0"
		ASL.l		#1,Display		Unless MSB set
		BCC.s		.SetBitPic		then
		LEA		OnePic,A0		Pic = "1"
.SetBitPic	MOVE.l		A0,BitPtr		Set picture ptr
		MOVEQ		#0,D1			No y offset
		MOVE.w		(A4)+,D0		Fetch x offset
		MOVE.l		PortWW(A5),A0		Set rastport
		LEA		PicBit,A1		and  structure
		CALL		DrawImage		Draw bit picture
		PULL		D0			Restore D0
		DBRA		D0,BitLoop		Branch till done
		PULL		Display			Restore display 
		RTS					and rtn

BaseDivision	MOVE.l		D0,Divisor(A5)		Save number
		MOVE.w		Base(PC),D5		D5 = base (8,10,16)
		MOVEQ		#0,D0			Clear D0 to extend
		MOVE.w		Divisor(A5),D0		number(Hi)
		DIVU		D5,D0			D0 = number(Hi)/base 
		MOVE.l		D0,D1			Copy D0(Hi) to D1(Hi)
		SWAP		D0			Move qtnt to D0(Hi)
		MOVE.w		Divisor+2(A5),D1	D1 = D1 + number(Lo)
		DIVU		D5,D1			Rest of number/base
		MOVE.w		D1,D0			Combine results
		SWAP		D1			D1 = remainder
		RTS					D0 = INT (no.)/base

Delete		MOVE.l		Display,D0		Copy display
		AND.l		BitSwitch(PC),D0	and mask to size	
		BSR.s		BaseDivision		Lose right digit
		BSR		Mixer			and set
		MOVE.l		D0,Display		Update display
		BRA		Do_Display		Show result and rtn
		
		
NewBase		MOVE.w		Base(PC),D0		Fetch old base
		CMP.w		#8,D0			If octal ...
		BEQ.s		DecSet			make decimal 
		CMP.w		#16,D0			if hex ...
		BEQ.s		OctSet			make octal
		
HexSet		MOVE.w		#16,Base		Base = 16
		MOVE.l		#HexPic,BasePtr		Basepic = "HEX"
		BRA		Do_Display		Show result and rtn

OctSet		MOVE.w		#8,Base			Base = 8
		MOVE.l		#OctPic,BasePtr		Basepic = "OCT"
		BRA		Do_Display		Show result and rtn

DecSet		MOVE.w		#10,Base		Base = 10
		MOVE.l		#DecPic,BasePtr		Basepic = "DEC"
		BRA		Do_Display		Show result and rtn

DoEquals	MOVEQ		#0,D0			Ensure nil operand
OpMode		MOVE.w		#-1,Overflow(A5)	Reset overflow word
		MOVE.w		Operand(A5),D1		Fetch old operand
		MOVE.w		D0,Operand(A5)		Save new operand
		TST.w		NewMode(A5)		In newmode ?
		BEQ		Do_Display		Yes - exit 
		CLR.w		NewMode(A5)		Ensure newmode
		TST.w		D1			Old operand "=" ?
		BEQ		Do_Display		Yes - exit
		CMP.w		#Multiply,D1		Old operand MULU ?
		BNE.s		Do_Division		No - goto division
		BSR.s		OneSize			Perform MULU 
		MOVE.l		Display,D1		Test for overflow 
		AND.l		BitSwitch,D1		if size restricted
		CMP.l		D1,Display		to .b or .w
		BNE		Beep			
		RTS

Do_Division	CMP.w		#Division,D1		Old operand = DIVU ?
		BNE.s		.AllSizes		No - adjust sizes
		TST.w		Display			Make sure we cant 
		BEQ		Input_Error		divide by zero
		MOVE.w		D1,Action		Set code for
		BSR.s		Action			subroutine
		BSR		WordSet			Ensure word size
		BRA.s		OverTest		test,show and rtn
		
.AllSizes	ADD.w		SizeMask(PC),D1		Adjust size
OneSize		MOVE.w		D1,Action		and set code
		BSR.s		Action			and do it ...
		BSR		Do_Display		Show results and rtn

OverTest	TST.w		Overflow(A5)		Overflow ?
		BEQ		Beep			Yes - beep and rtn
		RTS					No  - rtn

Action		TST.b		D0			OR ADD.b ETC....
		BVC.s		.InSize			Check overflow
		CLR.w		Overflow(A5)		Flag if overflow
.InSize		MOVE.l		WorkStore,Display	Work = disp = result
fp_nil		RTS

Direct		MOVE.w		bn_Opcode(A0),D0	D0 = opcode 
		ADD.w		SizeMask(PC),D0		Adjust size
		MOVE.w		D0,DirectOp		and set code
		NOP					NOP else pc fails
DirectOp	TST.b		D0			Code in here
		BRA		Do_Display		Show results and rtn 

Make_68K	LEA		ProPix,A0		(A0) = 68k picture
		BRA.s		SwopCalc		
Make_FFP	LEA		FFPPix,A0		(A0) = FFP picture
SwopCalc	MOVE.l		A0,CalcPtr		Set picture ptr
		MOVE.l		Display,D0		Save and swap both
		MOVE.l		WorkStore,D1		working registers
		MOVE.l		Old_Display(A5),Display
		MOVE.l		Old_WorkStore(A5),WorkStore
		MOVE.l		D0,Old_Display(A5)	On return all working 
		MOVE.l		D1,Old_WorkStore(A5)	regs are restored.
		EOR.w		#$01,Calcmode		Alternate calculator 
		BRA		CalcDraw		Draw pics & text etc.

ftoa		BCLR		#7,D0			Make D0 positive
		CLR.w		Exponent(A5)		No exponent - yet
		MOVE.l		A0,A4			Save string ptr
		MOVEQ		#7,D1			Blank out old
.Blankit	MOVE.b		#$20,(A0)+		string
		DBRA		D1,.Blankit
		MOVE.b		#$2E,(A0)		and set "."
		MOVE.l		_MathBase(PC),A6	Set math library
		MOVE.l		D0,Float(A5)		63.14159
		MOVE.l		#$98968058,D1		1 ^7
EXP_Loop	CALL		SPCmp
		BLT.s		SplitDigits
		ADDQ.w		#1,Exponent(A5)
		MOVE.l		Float(A5),D0
		MOVE.l		Ten(PC),D1
		CALL		SPDiv
		MOVE.l		D0,Float(A5)
		MOVE.l		Ten(PC),D1
		BRA.s		EXP_Loop

SplitDigits	MOVE.l		Float(A5),D0		D0  = 63.14159
		CALL		SPFloor			D0  = 63.0
		MOVE.l		D0,Integer(A5)		INT = 63.0
		MOVE.l		D0,D1			D1  = 63.0		
		MOVE.l		Float(A5),D0		D0  = 63.14159
		CALL		SPSub			D0  = (D0-D1)
		MOVE.l		D0,Remainder(A5)	REM = 00.14159
		MOVEQ		#7,D5
LeftDigits	MOVE.l		Integer(A5),D0		D0  = 63.0
		MOVE.l		Ten(PC),D1		D1  = 10.00
		CALL		SPDiv			D0  = 06.30(D0/D1)		
		CALL		SPFloor			D0  = 06.0
		MOVE.l		D0,NewNum(A5)		NEW = 06.00
		MOVE.l		Ten(PC),D1		D1  = 10.00
		CALL		SPMul			D0  = (D0*D1)
		MOVE.l		D0,D1			D1  = 60.00
		MOVE.l		Integer(A5),D0		D0  = 63.00
		CALL		SPSub			D0  = 03.00(D0-D1)
		CALL		SPFix			D0  = $03
		ADD.b		#$30,D0
		MOVE.b		D0,(A4,D5)
		DBRA		D5,NexNum
		BRA.s		NoRoom
NexNum		MOVE.l		NewNum(A5),Integer(A5)	INT = 06.00
		BNE.s		LeftDigits
		MOVEQ		#4,D4		
		MOVE.l		Remainder(A5),D0	D0  =.14159
RightDigit	MOVE.l		Ten(PC),D1		D1  = 10.0
		CALL		SPMul			D0  = 1.4159(D1*D0)
		MOVE.l		D0,Remainder(A5)	REM = 1.4159
		CALL		SPFloor			D0  = 1.0
		PUSH		D0
		CALL		SPFix			D0  = $01		
		ADD.b		#$30,D0			D0  = '1'
		BSR		fp_Insert
		PULL		D1			D1  = 1.0	
		MOVE.l		Remainder(A5),D0	D0  = 1.4159
		CALL		SPSub			D0  = 0.4159(D0-D1)
		SUBQ.w		#1,D4
		BMI.s		NoRoom
		TST.l		D0			
		DBEQ		D5,RightDigit
NoRoom		RTS

ShowFFP		TST.w		fp_Mode(A5)		Mode = passive ?
		BNE.s		ShowKey			Yes - no input
		MOVE.l		Display,D0		Copy display
		LEA		Inkeys(PC),A0		Leave str ptr in A0
		BSR		ftoa			convert it and show
ShowKey		BSR		SetExponent		exponent (if any)
		MOVE.l		Display,D0		Copy display again
		MOVE.b		#' ',Sign		Blank sign text
		BCLR		#7,D0			Clr sign bit and test
		BEQ.s		Hexin			if plus use "+"
		MOVE.b		#'-',Sign		if minus use "-"
Hexin		BSR		FFP_Bits		Show binary bits
fp_Refresh	LEA		TXT_FFP,A1		Text ptr to A1
		BRA		DoPrint			Print and rtn

fp_Negate	MOVE.l		Display,D0		Copy display and test
		BEQ		Ticks			if zero wait and rtn
		BCHG		#7,D0			else negate sign bit
		BRA		fp_Direct		Show results and rtn
fp_Pull		MOVE.l		fp_Store(A5),D0		Result = store
		BRA.s		fp_Direct		Show resuls and rtn
		
fp_CM		CLR.l		fp_Store(A5)		Clear store
		MOVE.b		#' ',M_Sign		Blank "M"
		LEA		TXT_MemBit(PC),A1	Just print " "
		BSR		DoPrint			then
		BRA		Ticks			wait and rtn

fp_LogNat	MOVE.l		Display,D0		Copy display and test
		BEQ		Ticks			if zero wait and rtn
		CALLMATHTRANS	SPLog			D0 = Log(D0)
		BRA.s		fp_Direct		Show results and rtn
		
fp_Pi		MOVE.l		#$C90FDB42,D0		D0 = Pi
		BRA.s		fp_Direct		Show results and rtn

fp_Square	MOVE.l		Display,D1		Copy display to D1
		MOVE.l		Display,D0		Copy display to D0
		CALLFFP		SPMul			D0 = (D0*D1)
fp_Overflow	CMP.l		#$FFFFFF7F,D0		Check for overflow
		BEQ		Beep			Yup - Beep and rtn
		BRA.s		fp_Direct		Show results and rtn
								
fp_Rec		MOVE.l		One(PC),D0		D0 = 1
		MOVE.l		Display,D1		Copy display and test
		BEQ		Beep			if zero beep and rtn
		CALLFFP		SPDiv			D0 = (1/D1)
		BRA.s		fp_Direct		Show results and rtn

fp_Root		MOVE.l		Display,D0		Copy display and test
		BEQ		Beep			if zero beep and rtn
		BTST		#7,D0			If minus ...
		BNE		Beep			beep and rtn
		CALLMATHTRANS	SPSqrt			D0 = squareroot(D0)
fp_Direct	CLR.w		fp_Mode(A5)		Passive mode
		CLR.w		fp_Flag(A5)		Sums done
fp_Back		MOVE.l		D0,Display		Display = result
		BRA		ShowFFP			Perform update 

fp_Integer	MOVE.l		Display,D0		Copy display to D0
		CALLFFP		SPFloor			D0 = INT(D0)
		BRA.s		fp_Direct		Show results and rtn
		
fp_Sine		MOVE.l		Display,D0		Copy display to D0
		CALLMATHTRANS	SPSin			D0 = Sine(D0)
		BRA.s		fp_Direct		Show results and rtn

fp_Cosine	MOVE.l		Display,D0		Copy display to D0
		CALLMATHTRANS	SPCos			D0 = Cosine(D0)
		BRA.s		fp_Overflow		Show results and rtn

fp_Tangent	MOVE.l		Display,D0		Copy display to D0
		CALLMATHTRANS	SPTan			D0 = Tangent(D0)
		BRA.s		fp_Direct		Show results and rtn

fp_Log		MOVE.l		Display,D0		Copy display and test
		BEQ.s		fp_Back			if zero exit
		BTST		#7,D0			Check polarity
		BNE.s		fp_Back			if Minus exit
		CALLMATHTRANS	SPLog10			D0 = Log10(D0)
		BRA.s		fp_Direct		Show results and rtn

fp_RND		MOVE.l		One(PC),D1		D1 = 1
		MOVEQ		#0,D0			Clear all D0 to
		MOVE.w		Random(A5),D0		extend old random
		ROR.w		#5,D0			Rotate a bit
		EOR.w		#$97AB,D0		change a few bits
		ADD.w		Micros+2(A5),D0		and add time, then
		MOVE.w		D0,Random(A5)		save new random
		SWAP		D0			Switch Hi & Lo
		OR.l		D1,D0			Or with "1"
		CALLFFP		SPSub			then subtract "1"
		BRA		fp_Direct		Show results and rtn

fp_Insert	MOVEM.l		A0-A1/D1-D2,-(SP)	Save registers ...
		LEA		Inkeys+1(PC),A0		A0 & A1 as byte spaced
		LEA		Inkeys(PC),A1		text ptrs
		MOVEQ		#8,D1			D1 & D2 set for
		MOVEQ		#8,D2			two loops
		CMP.b		#' ',(A1)		Is string full ?
		BNE.s		.Done			Yes - can't insert
.NineLoop	CMP.b		#'.',(A1,D2)		Look for period
		BEQ.s		.InsertLoop		
		DBRA		D2,.NineLoop		If no period ...
		CMP.b		#' ',1(A1)		restrict size by one
		BNE.s		.Done
.InsertLoop	MOVE.b		(A0)+,(A1)+		Move string back
		DBRA		D1,.InsertLoop
		MOVE.b		D0,-1(A1)		and insert char
.Done		MOVEM.l		(SP)+,A0-A1/D1-D2	Restore regs and
		RTS					rtn

fp_Totalise	AND.l		#$FF,D0			Extend D0 no sign
		SUB.b		#$30,D0			Convert Ascii to int
		CALL		SPFlt			Convert int to ffp
		PUSH		D0			Save float
		MOVE.l		Display,D0		Copy display to D0
		MOVE.l		Ten(PC),D1		Copy "10" to D1
		CALL		SPMul			D0 = (Display*10)
		PULL		D1			D1 = float
		CALL		SPAdd			D0 = D0+float
		MOVE.l		D0,Display		Update display
		RTS

atof		MOVE.l		_MathBase(PC),A6	Set math library
		LEA		Inkeys(PC),A4		Set string ptr
		MOVEQ		#0,Display		and clear regs.
		MOVEQ		#0,D5

.Blanks		CMP.b		#' ',(A4)+		Lose leading
		BEQ.s		.Blanks			spaces
		SUBQ.l		#1,A4			A4 back to char

LeftLoop	MOVE.b		(A4)+,D0		Get character
		BEQ.s		atof_Done		if zero string done
		CMP.b		#'.',D0			if "." do decimals
		BEQ.s		RightHalf
		BSR.s		fp_Totalise		Bump up number
		BRA.s		LeftLoop		and loop till done

RightHalf	MOVE.l		Display,D4		Save display
		MOVEQ		#0,Display		and clear it
RightLoop	MOVE.b		(A4)+,D0		Get character
		BEQ.s		.Combine		if zero string done
		ADDQ.w		#1,D5			INC decimal position
		BSR.s		fp_Totalise		Bump up number
		BRA.s		RightLoop		And loop till done
		
.Combine	MOVEQ		#0,D0			Clear D0 for add ?
		SUBQ.w		#1,D5			if no decimals
		BMI.s		atof_Add		else ..
		MOVE.l		Display,D0		copy display to D0
.PointLoop	MOVE.l		Ten(PC),D1		D1 = "10"
		CALL		SPDiv			Divide by decimal
		DBRA		D5,.PointLoop		position in D5
atof_Add	MOVE.l		D4,D1			Add Left and right
		CALL		SPAdd			with result in D0
		MOVE.l		D0,Display		and display
atof_Done	RTS

fp_00		CMP.w		#'  ',Inkeys		Room for two chars ?
		BNE		Ticks			No - wait and rtn
		TST.w		fp_Point(A5)		If we have a period		
		BNE.s		.FoundPoint		OK else ...
		CMP.b		#' ',Inkeys+2		room for one more ?
		BNE		Ticks			No - wait and return
.FoundPoint	MOVEQ		#'0',D0			Number = 0
		BSR.s		fp_Num_In		Perform input
		MOVEQ		#'0',D0			And again
		BSR.s		fp_Num_In		Convert ascii then
		BRA.s		fp_Keys			Show results and rtn		

fp_Number	MOVEQ		#0,D0			Extend D0
		MOVE.b		bn_Opcode(A0),D0	Get number (0-9)
		BSR.s		fp_Num_In		Convert and
		BRA.s		fp_Keys			Show results and rtn

fp_Num_In	TST.w		fp_Mode(A5)		In input Mode ?
		BNE.s		.OK			Yes - branch
		MOVE.w		#1,fp_Mode(A5)		Ensure input mode
		CLR.w		fp_Point(A5)		No period
		CLR.w		fp_Flag(A5)		Sums done 
		MOVEQ		#8,D1			Blank out 
		LEA		Inkeys(PC),A1		Inkeys text ready
.Loop		MOVE.b		#' ',(A1)+		to receive input
		DBRA		D1,.Loop
				
.OK		CMP.b		#$2E,D0			Is char a period
		BNE.s		.Number			No - must be a number
		LEA		Inkeys(PC),A1		Yes - do we already have
		MOVEQ		#8,D1			a period ?
.Loop2		CMP.b		#$2E,(A1)+
		BEQ.s		NoPoint			Yes - ignore input
		DBRA		D1,.Loop2
		MOVE.w		#1,fp_Point(A5)		No - flag period
.Number		BRA		fp_Insert		and insert

fp_Delete	TST.w		fp_Mode(A5)		In passive mode ?
		BEQ		Ticks			Yes wait and rtn
		LEA		Inkeys-1(PC),A0		Set string ptr
		MOVEQ		#8,D0			and move chars forward
.Loop		MOVE.b		(A0,D0),1(A0,D0)		
		DBRA		D0,.Loop
		MOVE.b		#' ',1(A0)		Insert leading space
		CMP.b		#' ',9(A0)		If string empty ..
		BEQ.s		fp_CE			use default zero
fp_Keys		BSR		atof			else convert ascii
NoPoint		MOVEQ		#0,D0			Clear D0 for update
		BRA		ShowKey			Show results and rtn

fp_Clear	MOVEQ		#0,Display		Clear display
		MOVEQ		#0,WorkStore		workstore, and
		CLR.l		K_Store(A5)		constant
		MOVE.b		#' ',K_Sign		Blank "K"
		CLR.w		fp_Operand(A5)		Old operand = "="
		
fp_CE		LEA		Inkeys(PC),A0		Set string ptr
		MOVEQ		#7,D0			and blank all text
.CE_Loop	MOVE.b		#' ',(A0,D0)
		DBRA		D0,.CE_Loop
		MOVE.b		#'0',8(A0)		Add trailing zero
		CLR.w		fp_Mode(A5)		Passive Mode
		CLR.w		fp_Flag(A5)		No Sums to do
		MOVEQ		#0,D0			Clear D0 for update
		BRA		ShowKey			Show results and rtn
									
fp_Perm		MOVE.l		Display,D0		Copy display and test
		BEQ		Ticks			if zero wait and rtn
		BTST		#7,D0			Test fp sign bit
		BNE		Beep			if minus beep and rtn
		CALLFFP		SPFloor			D0 = INT(D0)
		CMP.l		D0,Display		If display not integer
		BNE		Beep			beep and exit
		CALL		SPFix			D0 = 68000 integer 
		CMP.l		#20,D0			D0 >20 ?
		BGT		Beep			Too big beep and rtn
		MOVE.l		D0,D5			Use D0 as loop ctr
		SUBQ.w		#1,D5			and decrement
		MOVEQ		#0,D4			Clear D4 for 1st loop
		MOVE.l		One(PC),Display		Display = "1"
.Permutate	MOVE.l		D4,D0			Copy D4 »» D0
		MOVE.l		One(PC),D1		D1 = "1"
		CALL		SPAdd			D0 = (D0+"1")
		MOVE.l		D0,D4			Copy D0 »» D4
		MOVE.l		Display,D1		D1 = Display
		CALL		SPMul			D0 = (Display*D0)
		MOVE.l		D0,Display		Result in Display
		DBRA		D5,.Permutate		
		BRA		fp_Direct		Show results and rtn

fp_MemMinus	BSR.s		fp_Equals		Do sums
		MOVE.l		Display,D0		Copy display and test
		BNE.s		.NonMt			if zero exit
		RTS
.NonMt		BCHG		#7,D0			Negate D0
		BRA.s		fp_MemStore		Add and rtn

fp_Push		MOVE.l		Display,D0		Copy display
		BSR.s		fp_MoveMem		Set "M"
		BRA		Ticks			Wait and rtn

fp_MemPlus	BSR.s		fp_Equals		Do sums
		MOVE.l		Display,D0		Copy display
fp_MemStore	MOVE.l		fp_Store(A5),D1		Fetch store
		CALLFFP		SPAdd			D0 =(display+store)
fp_MoveMem	MOVEQ		#'M',D1			D1 = "M"
		MOVE.l		D0,fp_Store(A5)		Save new store
		BNE.s		.SetMem			unless zero then
		MOVEQ		#' ',D1			D1 = " "
.SetMem		MOVE.b		D1,M_Sign		Set "M"
		LEA		TXT_MemBit(PC),A1	Print "M"
		BRA		DoPrint			and rtn

fp_Equals	MOVE.l		K_Store(A5),D0		Copy constant & test
		BEQ.s		fp_Constant		if zero bypass K sums
		MOVE.w		K_Operand(A5),fp_Operand(A5)
		MOVE.l		Display,WorkStore	Save old display
		MOVE.l		D0,Display		and copy
		CLR.w		fp_Flag(A5)		Sums to do
		MOVEQ		#0,D0			but operand = "="
		BRA.s		fp_Constant		show results etc.
		
fp_Modulo	MOVE.w		#-1,D0			'C' type modulo
		BRA.s		fp_Function		Flag offset & branch

fp_Divide	MOVE.w		#_LVOSPDiv,D0		Set offset in D0
		BRA.s		fp_Function		and branch to sums

fp_Times	MOVE.w		#_LVOSPMul,D0		Set offset in D0
		BRA.s		fp_Function		and branch to sums

fp_Minus	MOVE.w		#_LVOSPSub,D0		Set offset in D0
		BSR		fp_Perplex		Check for % mode
		BRA.s		fp_Function		and branch to sums
		
fp_Plus		MOVE.w		#_LVOSPAdd,D0		Set offset in D0
		BSR		fp_Perplex		Check for % mode

fp_Function	MOVE.b		#' ',K_Sign		Blank "K"
		CLR.l		K_Store(A5)		Clear store
		CMP.l		OldBtn(A5),A0		Same button twice ?
		BNE.s		fp_Constant		No  - skip constant
		MOVE.b		#'K',K_Sign		Yes - set "K"
		MOVE.L		WorkStore,K_Store(A5)	Copy workstore to K
		MOVE.w		D0,K_Operand(A5)	and save operand

fp_Constant	TST.w		fp_Flag(A5)		Are sums done ?
		BNE.s		.No_Sums		Yes - don't repeat
		BSR.s		fp_Sums			Do arithmetic
.No_Sums	MOVE.w		D0,fp_Operand(A5)	Save new operand
		BRA		ShowFFP			Show results and rtn

fp_Sums		PUSH		D0			Save new operand
		MOVE.l		_MathBase(PC),A6	Set math library
		MOVE.w		fp_Operand(A5),D2	D2 = offset
		BEQ.s		.Sums_Done		zero = "="
		CMP.w		#_LVOSPDiv,D2		Is it division ?
		BNE.s		.no_Divide		No - skip zero test
		TST.l		Display			If zero then
		BEQ.s		.Sums_Done		skip divide
		
.no_Divide	MOVE.l		WorkStore,D0		copy workstore
		MOVE.l		Display,D1		and display
		CMP.w		#-1,D2			Check for "%"
		BEQ.s		.Modulo_Sums		Yes - do percentages
		JSR		(A6,D2)			No  - do normal sums
		BRA.s		.Save_Result		Skip % function

.Modulo_Sums	TST.l		D1			If display zero
		BEQ.s		.Sums_Done		skip % sums
		CALL		SPDiv			D0 = (D1/D0)
		CALL		SPFloor			D0 = INT(D1/D0)
		MOVE.l		Display,D1		D1 = display
		CALL		SPMul			D0 = (INT(D1/D0))*D1)
		MOVE.l		D0,D1			D1 = D0 (result)
		MOVE.l		WorkStore,D0		D0 = workstore
		CALL		SPSub			D1 = (D1-D0)
.Save_Result	MOVE.l		D0,Display		Update display
.Sums_Done	MOVE.l		Display,WorkStore	and workstore
		CLR.w		fp_Mode(A5)		Sums done
		MOVE.w		#-1,fp_Flag(A5)		Flag input mode
		PULL		D0			Restore new operand
		RTS		
		
fp_Percent	MOVE.b		#' ',K_Sign		Clear "K"
		CLR.l		K_Store(A5)		and store
		TST.l		Display			If display zero
		BEQ		Ticks			wait and rtn
		MOVE.w		fp_Operand(A5),D5	Get new operand 
		CMP.w		#_LVOSPAdd,D5		Is it Add ?
		BEQ.s		fp_Add_And_Sub		Yes - Do it
		CMP.w		#_LVOSPSub,D5		Is it Subtract ?
		BEQ.s		fp_Add_And_Sub		Yes - Do it
		CMP.w		#_LVOSPDiv,D5		Is it Divide ?
		BEQ.s		fp_Mul_And_Div		Yes - Do it
		CMP.w		#_LVOSPMul,D5		Is it Multiply ?
		BNE		Ticks			No  - wait and rtn
		MOVE.w		#-1,fp_PerSums(A5)	Flag % done

fp_Mul_And_Div	BSR.s		fp_PerForm		D0 % sums
		CLR.w		fp_Operand(A5)		New operand = "="
		BRA		fp_Direct		Show results and rtn

fp_Add_And_Sub	MOVE.w		#_LVOSPMul,D5		Set operand to "*"
		BSR.s		fp_PerForm		D0 % sums
		MOVE.w		fp_Operand(A5),D5	fetch operand
		CLR.w		fp_Operand(A5)		and set to "="
		MOVE.l		WorkStore,D0		Copy workstore 
		MOVE.l		Display,D1		and display
		JSR		(A6,D5)			Do original sum
		MOVE.l		D0,Display		Save result
		BRA		fp_Direct		Show results and rtn

fp_PerForm	MOVE.l		Display,D0		Copy display
		MOVE.l		#$C8000047,D1		D1 = "100"
		CALLFFP		SPDiv			D0 = (D0/100)
		MOVE.l		D0,D1			result to D1
		MOVE.l		WorkStore,D0		Copy workstore
		JSR		(A6,D5)			Do actual % sum
		MOVE.l		D0,Display		Save result
		RTS					Show results and rtn

fp_Perplex	TST.w		fp_PerSums(A5)		% sums already done ? 
		BEQ.s		.exit			Yes - skip it
		MOVE.w		D0,fp_Operand(A5)	Save old operand
		MOVEQ		#0,D0			New operand = "="
		CLR.w		fp_PerSums(A5)		% sums done
.exit		RTS

DoClear		MOVEQ		#0,WorkStore		Clear workstore
		CLR.w		Operand(A5)		Old operand = "="
		CLR.w		NewMode(A5)		Passive mode
DoCE		MOVE.l		BitSwitch(PC),D1	Clear display with
		NOT.l		D1			and mask for 
		AND.l		Display,D1		word and byte size
		MOVE.l		D1,Display		set display
		BRA		Do_Display		Show results and rtn
				
DoSwap		SWAP		Display			Do the swap
		BRA		Do_Display		Show results and rtn
				
NewSize		MOVE.w		SizeMask(PC),D0		Fetch size
		BEQ.s		WordSet			If byte make word
		CMP.w		#$40,D0			If word make long
		BEQ.s		LongSet
		
ByteSet		CLR.w		SizeMask		Opcode mask = 0
		MOVE.b		#'b',SizeText		Set ".b"
		MOVE.l		#$FF,BitSwitch		Byte size AND mask
		BRA		Do_Display		Show results and rtn
		
WordSet		MOVE.w		#$40,SizeMask		Opcode mask = $40
		MOVE.b		#'w',SizeText		Set ".w"
		MOVE.l		#$FFFF,BitSwitch	Word size AND mask
		BRA		Do_Display		Show results and rtn
		
LongSet		MOVE.w		#$80,SizeMask		Opcode mask = $80
		MOVE.b		#'l',SizeText		Set ".l"
		MOVE.l		#-1,BitSwitch		Long size AND mask 
		BRA		Do_Display		Show results and rtn	

Extend		MOVE.l		BitSwitch(PC),D0	If already long
		BMI		Input_Error		Extend not possible
		TST.w		D0			If byte size
		BPL.s		.ByteSize		extend to word 
.WordSize	EXT.L		Display			else extend to .l
		BRA.s		LongSet			and branch
.ByteSize	EXT.w		Display			Byte size here
		BRA.s		WordSet			and branch	

DoPush		MOVE.l		Display,Store(A5)	Save this display

Ticks		BSR		Messages		Any messages ?
		BNE.s		SaveTime		Yes - no wait
		MOVEQ		#2,D1			Short delay in D1
		MOVE.l		_DOSBase(PC),A6		and use DOS Delay
		JMP		_LVODelay(A6)		the rtn
				
Beep		LEA		DMA,A0			Not strictly legal
		MOVE.l		#Tone1,HiTable(A0)	but setting regs
		MOVE.w		#8,LenTable(A0)		directly easier than
		MOVE.w		#125,ReadRate(A0)	using audio.device
		MOVE.w  	#65,Volume(A0)
		MOVE.w          #$8201,(A0)
		
		MOVE.l		#40000,D1		Poss to use
.Loop		DBRA		D1,.Loop		Dos Delay here
		MOVE.w		#$01,(A0)		but only short wait
SaveTime	RTS

Timer		LEA		TimSeconds(A5),A0	Set A0 & A1
		LEA		Micros(A5),A1		For intuition
		CALLINT		CurrentTime		time
		MOVE.l		TimSeconds(A5),D1	D1 = new seconds
		CMP.l		OldSeconds(A5),D1	Only update if it
		BEQ.s		SaveTime		is a new second
		MOVE.l		D1,OldSeconds(A5)		

		MOVEQ		#0,D0			Clear D0
		DIVU		#HalfDay,D1		Divide Secs by 12Hrs
		LSR.w		#1,D1			Check If odd answer
		BCC.s		.Morning		and reduce to days
		MOVE.w		#HalfDay,D0		Put 12Hrs in D0 if Pm
.Morning	CLR.w		D1			Get remainder and
		SWAP		D1			extend without sign
		ADD.l		D1,D0			Add Am or Pm
		
		DIVU		#3600,D0		Split hours
		MOVE.w		D0,Hours(A5)		Save
		CLR.w		D0

		SWAP		D0			Get Remainder
		DIVU		#60,D0			Split minutes
		MOVE.w		D0,Minutes(A5)		Save

		SWAP		D0			Seconds in D0.w
		LEA		TimText+8(PC),A0	Set text address
		BSR.s		DeciMate		and Convert

		MOVE.w		Hours(A5),D0		Hours in D0.w
		LEA		TimText+1(PC),A0	Update text address
		BSR.s		DeciMate		and convert 

.DoMins		MOVE.w		Minutes(A5),D0		Same procedure for 
		LEA		TimText+4(PC),A0	minutes
		BSR.s		DeciMate		Convert to ascii

.Reprint	LEA		TXT_Clock(PC),A1	(A1) = time text

DoPrint		MOVE.l		PortWW(A5),A0		rastport in A0
		MOVEQ		#0,D0			No x offset
		MOVEQ		#0,D1			No y offset
		MOVE.l		_IntuitionBase(PC),A6	Set intuition
		JMP		_LVOPrintIText(A6)	Jump to routine

SetExponent	LEA		EXP_Text(PC),A0		(A0) = text ptr
		MOVE.w		Exponent(A5),D0		Fetch exponent
		CLR.w		Exponent(A5)		and clear
		TST.w		D0			Test for equality
		BNE.s		DeciMate		If non zero convert
		MOVE.w		#$2020,(A0)		else blank text
		RTS					and rtn

DeciMate	AND.l		#$FFFF,D0		Extend D0 No Sign
		DIVU		#10,D0			Divide by 10 and add 
		BSR.s		Digit			#$30 then do the
		SWAP		D0			remainder as well
Digit		ADD.b		#$30,D0			Make ascii
		MOVE.b		D0,(A0)+		set byte in string
		RTS					and rtn

TextOut		MOVE.l		A0,A4			Copy text ptr
		MOVE.l		_GfxBase(PC),A6		Set gfx base
		MOVE.w		#-1,TextColour(A5)	Ensure new colour
		CLR.l		TextSize(A5)		Ensure new text size
		
TextLoop	MOVE.l		SmallText(A5),A0	Topaz8 in A0 
		TST.b		nt_Colour(A4)		Test size on sign bit
		BPL.s		.Small			If plus use Topaz8
		MOVE.l		BigText(A5),A0		else use Topaz9
.Small		CMP.l		TextSize(A5),A0		Same size ?
		BEQ.s		.SizeOK			Yes - skip
		MOVE.l		A0,TextSize(A5)		Save this text size
		BEQ.s		.SizeOK			Skip if font error
		MOVE.l		PortWW(A5),A1		Rastport to a1
		CALL		SetFont			and set font
.SizeOK		MOVE.b		nt_Colour(A4),D0	Fetch f/g colour
		AND.l		#31,D0			Lose sign bit
		CMP.w		TextColour(A5),D0	Same colour ?
		BEQ.s		.SameColour		Yes - skip
		MOVE.w		D0,TextColour(A5)	Save this f/g colour
		MOVE.l		PortWW(A5),A1		Rastport in A1
		CALL		SetAPen			and set pen
		
.SameColour	MOVEQ		#0,D1			Clear for extend
		MOVE.l		PortWW(A5),A1		Rastport in A1
		MOVE.w		nt_LeftEdge(A4),D0	X offset
		MOVE.b		nt_BaseEdge(A4),D1	Y offset
		CALL		Move			Set position
		MOVE.w		(A4),D0			Offset from Main
		LEA		Main(PC),A0		Main in A0
		LEA		(A0,D0.w),A0		A0 = Text Position
		MOVE.l		A0,A1			Copy text ptr
		MOVEQ		#42,D0			Set limit in D0
.Counter	TST.b		(A1)+			Find end of string
		DBEQ		D0,.Counter		
		NEG.w		D0			Negate and add to D0
		ADD.w		#42,D0			To compute strlen
		MOVE.l		PortWW(A5),A1		Rastport to A1
		CALL		Text			and print text
		ADDQ.l		#nt_SIZEOF,A4		A4 = next structure
		TST.w		(A4)			All done ?
		BNE.s		TextLoop		No - Loop back until
		RTS					finished

BuildGadgets	MOVEM.l		A0-4/D0-5,-(SP)		Save registers
		MOVE.l		#MemSize,D0		Alloacte memory for
		MOVE.l		#MEMF_CHIP!MEMF_CLEAR,D1
		CALLEXEC	AllocMem		extra gadgets.
		MOVE.l		D0,GadMem(A5)		Set ptr and
		MOVE.l		D0,FirstGadget		test
		BEQ.s		Mem_Error		Alert user if no mem

		LEA		FirstButton(PC),A0	Gadget list in A0
		MOVEQ		#41,D1			D0 42 gadgets
.Repeat		MOVE.l		D0,A1			A1 = this gadget
		ADD.l		#gg_SIZEOF,D0		D0 = next gadget		
		MOVE.l		D0,(A1)			Set it
		MOVE.w		bn_PosX(A0),gg_LeftEdge(A1)	X offset
		MOVE.b		bn_PosY(A0),gg_TopEdge+1(A1)	Y offset
		MOVE.w		#37,gg_Width(A1)	Set width
		MOVE.w		#9,gg_Height(A1)	Set height
		MOVE.w		#GADGHNONE,gg_Flags(A1) Set flags
		MOVE.w		#$102,gg_Activation(A1) Set activation
		MOVE.w		#BOOLGADGET,gg_GadgetType(A1)
		MOVE.l		A0,gg_UserData(A1)	Userdata = ButtonList
		TST.b		bn_BorderType(A0)	Test for border size
		BEQ.s		.Small			zero = small
		MOVE.w		#77,gg_Width(A1)	else large border
.Small		ADD.l		#bn_SIZEOF,A0		Get next button
		DBRA		D1,.Repeat		Loop till done
		CLR.l		(A1)			Clear last gadget
		MOVEM.l		(SP)+,A0-4/D0-5		Restore registers
		RTS					and rtn

Mem_Error	BSR.s		AlertUser
		BRA		Finis			and gracefull exit

AlertUser	MOVEQ		#RECOVERY_ALERT,D0	Alert No.
		MOVEQ		#36,D1			Alert Height
		LEA		MemAlert(PC),A0		Alert String
		CALLINT		DisplayAlert		Tell user no memory
		RTS
		
		INCLUDE		Procalc.vars

		SECTION		BothPics,Code_C
ProPix		INCBIN		Pic68k_1.bin		Set Colours 1 or 2
FFPPix		INCBIN		PicFFP_1.bin		For WB 1.n or 2.n
		
			
