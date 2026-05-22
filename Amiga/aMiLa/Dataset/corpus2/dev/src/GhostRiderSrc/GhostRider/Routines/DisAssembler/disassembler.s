;---------------T-------T---------------T------------------------------------T
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; This source is © Copyright 1992-1995, Jesper Skov.
; Read "GhostRiderSource.ReadMe" for a description of what you may do with
; this source!
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
; Please do not abuse! Thanks. Jesper
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»
;»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»

;-----------------------------------------------------------------------------;
;- Name	: Dis/Assembler
;- Description	: Dis/Assemble MC680x0/MC6888x/MC68851 commands.
;-----------------------------------------------------------------------------;
; After assembling, you should write a binary image from "s" to "e", named
; "gri:disassembler.bin".
;-----------------------------------------------------------------------------;
;- 270693.0002	Breakline flags moved to dynamic space (diff between ed/line)
;- 280693.0004	Length of command calculated (for use in upwardsdis).
;- 060793.0005	Moved move cmds to top of cmdtable for faster disassembly.
;- 270893.0005	Included in routine index.
;- 040993.0006	Assembler ignores breaklines.
;- 030194.0008	Fixed bug in CMP -> CMPI assembling.
;-	Fixed sub An,Am bug.
;- 160194.0009	Forced size of Z ([],Z) was not used. Fixed.
;-	([],*) Parseerrors at * was not handled. Fixed
;-	([],*) Special GetValueCall at * to fix "unbal. par." problem.
;- 010294.0013	Made DC.x Mnem# dynamic (may be incorrect?)
;-	Indented the ASCII of DC.w extra 16 bytes.
;- 030394.0014	Added missing %1 in the GetSD call in btst. (Bjørn Reese/DK)
;- 050394.0015	add/sub/cmp->xxxa.l only stored imm.w. Fixed.
;-       .0016	CMP checked I before A -> wrong cmpa. Fixed
;-	CMP->cmpa did not set size bits. Fixed
;-       .0017	ROL commands now allow n=1-8. (John Girvin/NI)
;-       .0018	Cache-registers was not handled correct by disassembler. Fixed
;-       .0019	Fixed cmp->cmpm.
;-       .0022	Removed bc-checking in disassembler. Changed to (no)ouput
;-	control for better performance.
;- 240394.0025	Added NotValidMnem-flag signalling a DC.W disassembly
;- 040494.0026	Fixed bug in NO-output mode (size not set).
;- 200794.0030	Fixed addq/subq #8=#0 bug.
;- 210794.0032	Now an external library. Fixed a few EAD_ea(b) -> (An) bugs.
;-       .0033	Now fully PC relative.
;-----------------------------------------------------------------------------;

LocalAssembly	set	1	;makes it possible to include
			;the source directly from the GR
			;source!

	IF	LocalAssembly

	section	NeedfulThings,code

b	equr	a5
	BASEREG	B,b

	incdir	include:
	include	hardware/custom.i
	include	hardware/dmabits.i
	include	hardware/intbits.i

	include	gr:includes/GRConstants.0003.s
	include	gr:includes/GRStructures.0001.s
	include	gr:includes/GRData.0016.s


Push            macro                           ;push all or selected regs
                ifc     all,\1                  ;on the stack
                movem.l d0-a6,-(a7)
                else
                movem.l \1,-(a7)
                endc
                endm

Pull            macro                           ;pull all or selected regs
                ifc     all,\1                  ;from the stack
                movem.l (a7)+,d0-a6
                else
                movem.l (a7)+,\1
                endc
                endm

grcall	MACRO
	jsr	_LVO\1(b)
	ENDM


;---- Macro used in the mnemonic table
mnem	macro
	dc.w	\2	;type number
.mnempos\@	dc.b	\1,0	;just the mnemonic name
.mnemsiz\@	dcb.b	10-[.mnemsiz\@-.mnempos\@],0
	dc.w	\3	;MASK
	dc.w	\4
	endm

mnemf	macro
	dc.w	\2	;type number
.mnempos\@	dc.b	\1,0	;just the mnemonic name
.mnemsiz\@	dcb.b	10-[.mnemsiz\@-.mnempos\@],0
	dc.w	\3	;MASK
	dc.w	\4
	dc.w	\5	;additional FPU-command ID word
	dc.w	\6
	endm

mnemfn	macro
	dc.w	\2	;type number
.mnempos\@	dc.b	\1,0	;just the mnemonic name
.mnemsiz\@	dcb.b	10-[.mnemsiz\@-.mnempos\@],0
	dc.w	$f200	;MASK
	dc.w	$ffc0
	dc.w	\3	;additional FPU-command ID word
	dc.w	\4
	endm

;---- Macro used in the assembler for testing size=w/l
CheckWL	macro
	beq.w	IllegalSize	;only w/l allowed
	cmp.b	#2,d7
	bgt.w	IllegalSize
	endm

	ENDC

	section	DisAssembler,code
s	bra.w	Assemble
	bra.w	DisAssemble

;-----------------------------------------------------------------------------;
;-----------------------------------------------------------------------------;
;-		M680x0/M6888x/M68851 Assembler	-;
;-----------------------------------------------------------------------------;
;- Input:	a0	- txt (address command)	-;
;- Output:	d0	- next address		-;
;-	d1	- error/ok		-;
;-----------------------------------------------------------------------------;
;-   (Date)	(BUG)	           BUGFIXES	-;
;-----------------------------------------------------------------------------;
;- 100493 -	Made ReadEA read .s/.d/.x/.p types (simple). Size in bds.	-;
;- 300493 -	Was overriding forced sizes. Now only auto when no forced.	-;
;-	In d16,An,Xn and AddBDSize	-;
;- 140593 -	Cache-types removed. Special checkroutine in assembler.	-;
;- 160593 -	Added PMOVE command, and recognice-routine for MMU registers.-;
;- 040993 -	Now ignores breaklines.		-;
;-----------------------------------------------------------------------------;

;Name	Bit	Type	Data
;-----------------------------------------------------------------------------;
dt0=	0	;Dn	cmd
dt1=	1	;An	cmd
dt2=	2	;(An)	cmd
dt3=	3	;(An)+	cmd
dt4=	4	;-(An)	cmd
dt5=	5	;(d16,An)	cmd,bd
dt6=	6	;(d8,An,Xn)	cmd,ext
dt7=	7	;(d,An,Xn)+	cmd,ext+
dt8=	8	;(d16,PC)	cmd,bd
dt9=	9	;(d8,PC,Xn)	cmd,ext
dt10=	10	;(d,PC,Xn)+	cmd,ext+
dt11=	11	;(xxxx).w	bd
dt12=	12	;(xxxx).l	bd
dt13=	13	;#data	bd
dt14=	14	;Regs	ext
dt15=	15	;
dt16=	16	;SR	(ext)
dt17=	17	;CCR	(ext)
dt18=	18	;USP	(ext)
dt19=	19	;SSP	(ext)
dt20=	20	;SP	(ext)
dt21=	21	;MultipleRegs	ext
dt22=	22	;cc offset	bd
dt23=	23	;EMPTY	N/A         ; used by shift-commands
dt24=	24	;Dn:Dm	cmd,ext
dt25=	25	;MMU register	ext (+cmd for bac/bad)
;dt26=	26	;dc	ext
;dt27=	27	;ic	ext
;dt28=	28	;bc	ext
dt29=	29	;FPx	cmd
dt30=	30	;FPc:FPs	cmd,ext
dt31=	31	;fmovem	ext

dt32=	32	;#3bits	bd	;d
dt33=	33	;{o:w}	cmd	;d
dt34=	34	;(Xn):(Xm)	cmd,ext	;d

alltypes=	%11111111111111

asa	equr	a2	;assemble address
cw	equr	d6	;command word (being build)
cm	equr	d5	;mask for ^

Assemble:	Push	d7/asa/a3/a4

;	bra.b	.fusk
.zapispaces	cmp.b	#' ',(a0)	;zap any leading spaces
	bne.b	.zapped
	addq.w	#1,a0
	bra.b	.zapispaces

.zapped	grcall	GetValueCall	;find assemble address
	bclr	#0,d0	;get even address
	move.l	d0,asa
	move.l	d0,AssembleStart(b)
	move.l	d0,MemoryAddress(b);so * is correct
	tst.l	d1	;exit if fail
	bne.w	AssemblePull

.fusk	move.l	AssembleStart(b),asa
	moveq	#NoAssembly,d1
.zapspaces	move.b	(a0)+,d0	;kill spaces
	beq.w	AssemblePull	;if end of list exit WITHOUT fail!
	cmp.b	#' ',d0	;(ends line-assembler)
	beq.b	.zapspaces
	subq.w	#1,a0

	moveq	#BreakAssembly,d1
	cmp.b	#'=',d0	;ignore breaklines
	beq.w	AssemblePull
	lea	MnemonicBuffer(b),a1;copy mnemonic with casefix
	moveq	#MaxMnemonicLen-1,d1
.GrabMnemonic	move.b	(a0)+,d0
	beq.b	.Grabbed	;if end of list
	cmp.b	#'0',d0
	blt.b	.Grabbed
	cmp.b	#'9',d0
	ble.b	.CaseLowered
	cmp.b	#'A',d0	;check A-Z
	blt.b	.Grabbed
	cmp.b	#'Z',d0
	bgt.b	.UpperCase
	or.b	#$20,d0
	bra.b	.CaseLowered
.UpperCase	cmp.b	#'a',d0	;check a-z
	blt.b	.Grabbed
	cmp.b	#'z',d0
	bgt.b	.Grabbed
.CaseLowered	move.b	d0,(a1)+
	dbra	d1,.GrabMnemonic
	addq.w	#1,a0	;to avoid following sub

.Grabbed	clr.b	(a1)
	subq.w	#1,a0

;now check for size offset
	move.w	#$8001,ForcedSize(b);set to default .w
	move.l	a0,a1
	move.b	(a1)+,d0
	cmp.b	#'.',d0	;then check for forced size
	bne.b	CheckMnemonic
	move.b	(a1)+,d0
	beq.w	UnexpectedEOL	;if end of list
	or.b	#$20,d0
	moveq	#%00,d1	;size=b
	cmp.b	#'b',d0
	beq.b	.forcesize
	moveq	#%01,d1	;size=w
	cmp.b	#'w',d0
	beq.b	.forcesize
	moveq	#%10,d1	;size=l
	cmp.b	#'l',d0
	beq.b	.forcesize
	moveq	#%11,d1	;size=single
	cmp.b	#'s',d0
	beq.b	.forcesize
	moveq	#%100,d1	;size=double
	cmp.b	#'d',d0
	beq.b	.forcesize
	moveq	#%101,d1	;size=extended
	cmp.b	#'x',d0
	beq.b	.forcesize
	moveq	#%110,d1	;size=packed
	cmp.b	#'p',d0
	bne.b	CheckMnemonic
.forcesize	move.l	a1,a0	;new size set-> skip .z
	move.w	d1,ForcedSize(b)

CheckMnemonic	lea	M68kMnemonics(pc),a3
	moveq	#0,d0
	lea	MnemonicBuffer(b),a1
	move.l	a1,d1
	moveq	#mn_SizeOf,d2

FindMnemonic	move.l	d1,a1	;scan name list
	tst.w	(a3)	;check mnemonic type (-1/-2=end/FPU)
	bmi.b	CheckFPU
	lea	mn_Name(a3),a4	;get to name
.findloop	move.b	(a4)+,d0	;if zero reached->found
;compare FROM list to be able to check Bcc,Scc etc. in bottom of list.
	beq.b	FoundMnemonic
	cmp.b	(a1)+,d0	;compare, if equ check next letter
	beq.b	.findloop
	add.w	d2,a3	;get to next entry in list
	bra.b	FindMnemonic	;and check next in list

CheckFPU	cmp.w	#-1,(a3)	;endmark=-1
	beq.w	IllegalMnemonic	;if not end, then mark for FPU table
	moveq	#mnf_SizeOf,d2	;change entry-size
	addq.w	#2,a3	;skip mark
	bra.b	FindMnemonic	;and go again

FoundMnemonic	;a3 is pointer to correct mnemonic-data
	move.w	mn_Bits(a3),cw;put def bits in word
	move.w	mn_Mask(a3),cm	;and get mask
	not.w	cm	;invert to get correct mask
	move.w	(a3),d0	;get offset
	move.w	mn_FPUID(a3),d4	;get FPUID. Only valid for FPU cmds

	move.w	mn_Bits+mn_SizeOf(a3),ShiftID(b);only usable for Shift!

	move.w	ForcedSize(b),d7;test size(flags are checked by sum fs)
	cmp.w	#fpun,d0	;if >= fpun reorder sizes. Else b/w/l
	blt.b	.checkbwl
	lea	SizeTable(pc),a3
	move.w	d7,d1
	and.w	#%111,d1	;skip def bit if there
	move.b	(a3,d1.w),d7	;get new size-bits
	or.w	#$4000,d7	;signal extended sizes
	move.w	d7,ForcedSize(b)
	bra.b	.goon

.checkbwl	cmp.b	#2,d7	;only b/w/l allowed for cpu cmds
	bgt.w	IllegalSize

.goon	lea	EADataS(b),a3	;source data
	lea	EADataD(b),a4	;dest data
	tst.w	d7
g	jmp	AssembleJmps(pc,d0.w)

SizeTable	dc.b	%110,%100,%000,%001,%101,%010,%011
	even

;w;
AssembleJmps	bra.w	PerMove	;this jmptable must match type-values!
	bra.w	EAToAn
	bra.w	EAToAn2
	bra.w	EAToAn3
	bra.w	MulMove
	bra.w	IToDn
	bra.w	EAToEA
	bra.w	IToEA
	bra.w	EADnEA
	bra.w	EADnEA2
	bra.w	DnIToEA
	bra.w	RegMem
	bra.w	I3ToEA
	bra.w	AnpAnp
	bra.w	cEAToDn
	bra.w	EAToDn
	bra.w	EAToRnCmp
	bra.w	EAToRn
	bra.w	EAToDnM
	bra.w	EAToDnLS
	bra.w	EAToDnLU
	bra.w	ccEA
	bra.w	DBcc
	bra.w	Bcc
	bra.w	None
	bra.w	EA
	bra.w	EA2
	bra.w	EA3
	bra.w	EA4
	bra.w	EA5
	bra.w	EA6
	bra.w	Shift
	bra.w	Dn
	bra.w	Dn2
	bra.w	Dn2B
	bra.w	LinkTyp
	bra.w	An
	bra.w	IData
	bra.w	TrapTyp
	bra.w	TVTyp
	bra.w	RxRy
	bra.w	DCTyp
	bra.w	DCBTyp
	bra.w	BitManipS
	bra.w	Bxx
	bra.w	Field
	bra.w	Field2
	bra.w	Field3
	bra.w	Imm3
	bra.w	Callm
	bra.w	DcDuEA	;cas2
	bra.w	CasTyp	;cas
	bra.w	LMove
	bra.w	PackTyp
	bra.w	ValTyp	;pvalid
	bra.w	I16	;rtd
	bra.w	XnTyp	;rtm
	bra.w	Cache
	bra.w	CacheAn
	bra.w	MovCTyp	;movec
	bra.w	MovSTyp	;moves
	bra.w	PBcc
	bra.w	PDBcc
	bra.w	PostAn
	bra.w	PFlusha3
	bra.w	PFTyp
	bra.w	PFSTyp
	bra.w	PFRTyp
	bra.w	PScc
	bra.w	FCEAR
	bra.w	FCEAW
	bra.w	PTrapTyp
	bra.w	FPUBcc
	bra.w	FPUDBcc
	bra.w	FPUScc
	bra.w	FPUNOP
	bra.w	FPUTRAPcc

	bra.w	FPUNormal
	bra.w	FPUSDNormal
	bra.w	FPUTST
	bra.w	FPUSCOS
	bra.w	FPUMOVECR
	bra.w	FPUMOVEM
	bra.w	FPUMOVE
	bra.w	FPUxMOVE
	bra.w	PMOVETYPE
	bra.w	PMOVEFDTYPE
	bra.w	PTESTType

;---- fixed - start
PerMove	CheckWL
	moveq	#%100001,d0	;Dn/(d,An)
	move.l	d0,d1
	bsr.w	GetSD
	moveq	#dt5,d2	;d16(An)
	moveq	#dt0,d3	;Dn
	cmp.w	d1,d3	;if d=Dn
	beq.b	.checkok	;ok
	exg	a3,a4
	exg	d0,d1	;else swap d/s
	or.w	#%0000000110000000,cw;and change direction
.checkok	cmp.w	d1,d3
	bne.w	IllegalAddress
	cmp.w	d0,d2
	bne.w	IllegalAddress
	move.w	EAD_bd+2(a3),d4	;get 16 bit offset
	move.w	EAD_cmd(a3),d0
	and.w	#%111,d0
	or.w	d0,cw
	move.w	EAD_cmd(a4),d0
	ror.w	#7,d0
	or.w	d0,cw

	cmp.b	#1,d7
	beq.b	.store
	or.w	#%0000000001000000,cw
.store	move.w	cw,(asa)+
	move.w	d4,(asa)+
	bra.w	AssembleExit

;---- cmpa
EAToAn	CheckWL
	move.w	d7,d1	;don't spoil d7
	and.w	#%10,d1
	asl.w	#7,d1
	or.w	d1,cw	;set size bit 8 (0=w/1=l)

EAToAnMain	move.l	#alltypes,d0
	moveq	#%10,d1	;dest only An
	bsr.w	GetSD
EAToAnMain2	move.w	EAD_cmd(a4),d0
	and.w	#%111,d0
	ror.w	#7,d0	;rol An to 11-9
	or.w	d0,cw

PutSEADataExit	or.w	EAD_cmd(a3),cw;or source EA to cw
	bra.w	FastPutSEA

EAToAn2	move.l	#%01111111100100,d0;get source mask
	moveq	#%10,d1	;dest = An
	bsr.w	GetSD	;get EA
	move.w	EAD_cmd(a4),d0	;get An number
	ror.w	#7,d0
	and.w	cm,d0
	or.w	d0,cw	;and add to command
	bra.b	PutSEADataExit

EAToAn3	CheckWL
	move.w	#%0011000000000000,d0;convert to correct size
	cmp.b	#%10,d7
	bne.b	.long
	move.w	#%0010000000000000,d0
.long	or.w	d0,cw	;or size to cmd
	bra.b	EAToAnMain	;do rest like EAToAn

MulMove	CheckWL
	and.w	#%10,d7
	asl.w	#5,d7
	or.w	d7,cw	;put size
	move.l	#%1000000001111111111111,d0
	move.l	d0,d1	;or'ed s+d
	bsr.w	GetSD
	moveq	#0,d2	;convert dt0/1 to list
	cmp.w	#dt1,d0
	beq.b	.regs
	cmp.w	#dt0,d0
	bne.b	.checkregdest
.regs	move.w	EAD_cmd(a3),d0
	bset	d0,d2
	move.w	d2,EAD_ext(a3)
	bra.b	.source

.checkregdest	cmp.w	#dt1,d1	;convert dt0/1 to list
	beq.b	.regd
	cmp.w	#dt0,d1
	bne.b	.oldcheck
.regd	move.w	EAD_cmd(a4),d1
	bset	d1,d2
	move.w	d2,EAD_ext(a4)
	bra.b	MulMoveMem2

.oldcheck	cmp.w	#dt21,d0	;to or from mem?
	bne.b	MulMoveMem	;branch if from mem
.source	move.l	#%1100011110100,d2
	btst	d1,d2
	beq.w	IllegalAddress	;check correct dest
	move.w	EAD_ext(a3),d0	;get reg-bits
	cmp.w	#dt4,d1	;if -(An) reverse order
	bne.b	.reverse
	moveq	#0,d2	;reverse the register order
	moveq	#15,d3
.revreg	add.w	d0,d0
	roxr.w	#1,d2
	dbra	d3,.revreg
	move.w	d2,d0
.reverse	or.w	EAD_cmd(a4),cw	;or dest EA
	move.w	cw,(asa)+	;put EA
	move.w	d0,(asa)+	;put reg mask
	bra.w	PutDEADataX

MulMoveMem	cmp.w	#dt21,d1
	bne.w	IllegalAddress
MulMoveMem2	move.l	#%01111111101100,d2;code for mem->regs
	btst	d0,d2
	beq.w	IllegalAddress
	or.w	#%10000000000,cw;change direction to mem->regs
	or.w	EAD_cmd(a3),cw	;or EA
	bsr.w	RecalcPC
	move.w	cw,(asa)+	;put cw
	move.w	EAD_ext(a4),(asa)+;put register mask
	pea	AssembleExit(pc)
	bra.w	PutSEAData

IToDn	move.l	#%10000000000000,d0;#,dn (for moveq)
	moveq	#1,d1
	bsr.w	GetSD
	move.w	EAD_cmd(a4),d0
	ror.w	#7,d0
	or.w	d0,cw	;or Dn number
	moveq	#EV_NUMBERTOOBIG,d1
	tst.b	EAD_bds(a3)
	bne.w	AssemblePull	;exit if value is too big
	move.b	EAD_bd+3(a3),cw	;put 8 bit data
	bra.w	None

;---- EA,EA from move!
EAToEA	moveq	#-1,d0	;get source and dest (no mask :(
	moveq	#-1,d1
	bsr.w	GetSD

	move.w	#%0100111001100000,cw;move USP bits
	cmp.w	#dt14,d0	;first check move USP/An
	bne.b	EAToEA000
	or.w	#%1000,cw	;change direction
	exg	a3,a4
EAToEAUSPAn	cmp.w	#$0800,EAD_ext(a4)
	bne.w	IllegalAddress
	move.w	EAD_cmd(a3),d0
	and.w	#%111,d0
	or.w	d0,cw
	bra.w	None

EAToEA000	cmp.w	#dt14,d1
	beq.b	EAToEAUSPAn

	cmp.w	#dt16,d0	;check SR,EA
	bne.b	EAToEA010
	move.w	#%0100000011000000,d2;sr,ea bits

EAToEA008	move.l	#%0001100011111101,d3;get mask of allowed dests
	btst	d1,d3	;and check if legal
	beq.w	IllegalAddress

;SetD1Dest
	move.w	EAD_cmd(a4),cw
	or.w	d2,cw	;add bits for move sr,ea
	move.l	a4,a3	;swap S&D
	bra.w	FastPutSEA

EAToEA010	cmp.w	#dt16,d1	;check EA,SR
	bne.b	EAToEA020
	move.w	#%0100011011000000,cw
EAToEA012	move.l	#%11111111111101,d2
	btst	d0,d2
	beq.w	IllegalAddress
	bra.w	PutSEADataExit

EAToEA020	cmp.w	#dt17,d0	;check CCR,EA
	bne.b	EAToEA030
	move.w	#%0100001011000000,d2;ccr,ea bits
	bra.b	EAToEA008

EAToEA030	cmp.w	#dt17,d1	;check ea,ccr
	bne.b	EAToEA040
	move.w	#%0100010011000000,cw
	bra.b	EAToEA012

EAToEA040	cmp.w	#dt1,d1	;check ea,An (movea) is not .b
	beq.b	.checkwl

	cmp.w	#dt1,d0	;check An,ea is not .b
	bne.b	EAToEA045
.checkwl	tst.b	d7
	CheckWL

EAToEA045	move.l	#%0001100011111111,d2
	btst	d1,d2	;check ok dest
	beq.w	IllegalAddress
	move.l	#alltypes,d2
	btst	d0,d2	;check ok source
	beq.w	IllegalAddress
	moveq	#%10,d2	;fix len
	cmp.b	#%01,d7
	bne.b	.checksizew
	moveq	#%11,d2
.checksizew	tst.b	d7
	bne.b	.checksizeb
	moveq	#%01,d2
.checksizeb	ror.w	#4,d2
	move.w	d2,cw	;move len!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	or.w	EAD_cmd(a3),cw
	move.w	EAD_cmd(a4),d1
	move.w	d1,d2	;fix dest
	asl.w	#3,d1
	ror.w	#7,d2
	or.w	d2,d1
	and.w	#%0000111111000000,d1
	or.w	d1,cw	;and or
FastPutSD	pea	AssembleExit(pc)
	pea	PutDEAData(pc)	;set dest data
	bra.w	FastPutSEANX	;put source data

;---- cmpi etc
IToEA	move.l	#%10000000000000,d0;i
	move.l	#%110001100011111101,d1;ea (norm+ccr/sr)
	bsr.w	GetSD
IToEACheck	cmp.w	#dt17,d1	;check ea,ccr
	bne.b	IToEA000
	moveq	#%00111100,d2
	moveq	#0,d7	;set byte size
CheckCCRSR	cmp.w	#%0000011000000000,cw;check for invalid types (addi)
	beq.w	IllegalAddress
	cmp.w	#%0000110000000000,cw;(cmpi)
	beq.w	IllegalAddress
	cmp.w	#%0000010000000000,cw;(subi)
	beq.w	IllegalAddress
	or.w	d2,cw
	bra.w	FastPutSEA

IToEA000	cmp.w	#dt16,d1	;check ea,sr
	bne.b	IToEA010
	moveq	#%01111100,d2
	moveq	#1,d7	;force word size
	bra.b	CheckCCRSR

IToEA010	move.w	d7,d0
	asl.w	#6,d0	;normal destination
	or.w	d0,cw	;or size
	or.w	EAD_cmd(a4),cw
	bra.b	FastPutSD

;this is for AND and OR
EADnEA	move.l	#%11111111111101,d0
	move.l	#%110001100011111101,d1;(include ccr/sr)
	bsr.w	GetSD
	move.l	#%1100011111100,d3;allowed dests
	cmp.w	#dt17,d1	;check ea,ccr
	bne.b	.EADnEA000
	cmp.w	#dt13,d0	;check ea=i
	bne.w	IllegalAddress
	moveq	#0,d7	;force bytesize
	cmp.w	#$c000,cw	;and/or?
	beq.b	.isand
	moveq	#%0000000000111100,cw;ori #,ccr bits
.FastPutSEA	bra.w	FastPutSEA

.isand	move.w	#%0000001000111100,cw;andi #,ccr bits
	bra.b	.FastPutSEA

.EADnEA000	cmp.w	#dt16,d1	;check ea,sr
	bne.b	EADnEA100
	cmp.w	#dt13,d0	;check ea=#
	bne.w	IllegalAddress
	moveq	#1,d7	;force word size
	cmp.w	#$c000,cw	;and/or?
	beq.b	.isand2
	moveq	#%0000000001111100,cw;ori #,sr bits
	bra.b	.FastPutSEA

.isand2	move.w	#%0000001001111100,cw;andi #,sr bits
	bra.b	.FastPutSEA

EADnEA100	move.l	#%11111111111101,d2
EADnEA101	move.w	d7,d4	;fix size
	asl.w	#6,d4
	or.w	d4,cw	;put size
	cmp.w	#dt0,d1	;what direction?
	bne.b	EADnEA120
	btst	d0,d2	;ea,Dn:check if source is ok
	beq.w	IllegalAddress
	move.w	EAD_cmd(a4),d1
	ror.w	#7,d1
	or.w	d1,cw	;set n
	bra.w	PutSEADataExit

EADnEA120	or.w	#%0000000100000000,cw;Dn,ea(change direction)
	btst	d1,d3	;check dest
	beq.w	IllegalAddress
	move.w	EAD_cmd(a3),d0
	ror.w	#7,d0
	or.w	d0,cw	;set n

FastPutDData	move.l	a4,a3
	or.w	EAD_cmd(a3),cw	;put dest's EA-data
	bra.w	FastPutSEA	;and fill in

;this for add/sub
EADnEA2	move.l	#alltypes,d0
	move.l	#%1100011111111,d1
	bsr.w	GetSD
	cmp.w	#dt1,d1	;check xxxa
	bne.b	EADnEA200
	tst.w	d7	;if An=dest skip bytesize
	beq.w	IllegalSize
EAToAnEntry	move.w	d7,d1	;don't screw up D7. Used when
	and.w	#%10,d1	;storing immediate data
	asl.w	#7,d1
	or.w	d1,cw	;set size bit 8 (0=w/1=l)
	or.w	#%11000000,cw
	bra.w	EAToAnMain2

EADnEA200	cmp.w	#dt13,d0	;check xxxi
	bne.b	EADnEA210
	cmp.w	#$d000,cw	;check add
	beq.b	.isadd
	move.w	#%0000010000000000,cw;set subi bits
	bra.w	IToEA010

.isadd	move.w	#%0000011000000000,cw;set addi bits
	bra.w	IToEA010	

EADnEA210	move.l	#%1100011111100,d3;allowed dests
	move.l	#%11111111111111,d2;allowed sources
	cmp.w	#dt1,d0	;check ok size for An
	bne.w	EADnEA101
	tst.w	d7
	beq.w	IllegalSize
	bra.w	EADnEA101

;---- used by eor Dn,EA
DnIToEA	move.l	#%10000000000001,d0;# & Dn only
	move.l	#%110001100011111101,d1
	bsr.w	GetSD
	cmp.w	#dt0,d0	;#/Dn?
	bne.b	DnIToEAI
	move.l	#%1100011111101,d3
	btst	d1,d3
	beq.w	IllegalAddress	;sr/ccr not allowed from Dn
	move.w	EAD_cmd(a3),d0
PutDDataSize	ror.w	#7,d0
	or.w	d0,cw	;or Dn #
	move.w	d7,d0
	asl.w	#6,d0
	or.w	d0,cw	;or size
	bra.w	FastPutDData

DnIToEAI	cmp.w	#dt17,d1	;ccr
	bne.b	DnIToEAI00
	moveq	#0,d7	;force .b
	move.w	#%0000101000111100,(asa)+
DnIToEAI05	move.w	EAD_bd+2(a3),(asa)+
	bra.w	AssembleExit	

DnIToEAI00	cmp.w	#dt16,d1	;sr
	bne.b	DnIToEAI10
	moveq	#%01,d7	;force word size
	move.w	#%0000101001111100,(asa)+
	bra.b	DnIToEAI05

DnIToEAI10	move.w	#%0000101000000000,cw;set bits
	bra.w	IToEA010	;and use code from and/or

;---- addx etc
RegMem	moveq	#%10001,d0
	move.l	d0,d1	;Dn/-(An)
	bsr.w	GetSD
	cmp.w	#(~%1111000111110000)&$ffff,cm;if abcd/sbcd check size
	bne.b	.onlybyte
	tst.w	d7
	bne.w	IllegalSize
.onlybyte	cmp.w	d0,d1
	bne.w	IllegalAddress	;must be same type
	cmp.w	#dt0,d0	;check type
	beq.b	DualRegs
	or.w	#%1000,cw	;change type to mem,mem
DualRegs	moveq	#%111,d2
	move.w	EAD_cmd(a3),d0
	move.w	EAD_cmd(a4),d1
	and.w	d2,d0
	and.w	d2,d1
	or.w	d0,cw	;or Ry
	ror.w	#7,d1
	or.w	d1,cw	;or Rx
	asl.w	#6,d7
	or.w	d7,cw	;or size
	bra.w	None

;---- used in subq/addq
I3ToEA	move.l	#%10000000000000,d0
	move.l	#%01100011111111,d1
	bsr.w	GetSD
	cmp.w	#dt1,d1
	bne.b	.notbyte	;if An byte not legal
	tst.b	d7
	beq.w	IllegalSize
.notbyte	move.l	EAD_bd(a3),d0
	move.l	d0,d2
	moveq	#%111,d3
	and.l	d3,d0	;mask off trash bits
	not.l	d3
	and.l	d3,d2	;check that only 3 bites are used
	bne.w	IllegalSize
	bra.w	PutDDataSize

AnpAnp	moveq	#%1000,d0
	move.l	d0,d1
	bsr.w	GetSD
	bra.b	DualRegs

;cmp
cEAToDn	move.l	#alltypes,d0
	move.l	#%110001111111111111,d1;also check cmpa/cmpm/cmpi
	bsr.w	GetSD

	cmp.w	#dt1,d1	;check cmpa
	bne.b	.notcmpa
	tst.b	d7	;if cmpa, only .w/l allowed
	beq.w	IllegalSize
	bra.w	EAToAnEntry	;get size fixed

.notcmpa	cmp.w	#dt13,d0	;check cmpi
	bne.b	.notimm
	move.w	#%0000110000000000,cw;change to cmpi CW
	bra.w	IToEACheck

.notimm	cmp.w	#dt3,d1	;check cmpm
	bne.b	.checkcmp
	cmp.w	d1,d0
	bne.w	IllegalAddress
	move.w	#%1011000100001000,cw;cmpm base pattern
	bra.w	DualRegs

.checkcmp	cmp.w	#dt0,d1	;check Dn is dest, else fail
	bne.w	IllegalAddress
	cmp.w	#dt13,d0	;check valid source
	bgt.w	IllegalAddress
	cmp.w	#dt1,d0	;check An is w/l
	bne.b	.checkbyte
	tst.b	d7
	beq.w	IllegalSize
.checkbyte	asl.w	#6,d7
	or.w	d7,cw	;or size
EAToDnMain	move.w	EAD_cmd(a4),d1
	ror.w	#7,d1
	or.w	d1,cw	;or Dn #
	bra.w	PutSEADataExit

;---- chk
EAToDn	CheckWL
	cmp.b	#1,d7
	bne.b	.word
	bset	#7,cw
.word	move.l	#%11111111111101,d0
	moveq	#1,d1
	bsr.w	GetSD
	bra.b	EAToDnMain

;---- chk2,cmp2
EAToRnCmp	moveq	#0,d2
	bra.b	EAToRnMain

EAToRn	move.w	#$0800,d2
EAToRnMain	move.w	d2,EAD_ext(a4)	;temp storage
	and.w	#%11,d7
	ror.w	#7,d7
	or.w	d7,cw
	move.l	#%1111111100100,d0
	moveq	#%11,d1
	bsr.w	GetSD
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+
	move.w	EAD_cmd(a4),d0
	ror.w	#4,d0
	or.w	EAD_ext(a4),d0	;get chk2/cmp2 bit from storage
	move.w	d0,(asa)+
	bsr.w	RecalcPC
	bra.w	PutSEADataX

;---- mulu/muls/divu/divs
EAToDnM	CheckWL
	move.l	#1<<dt24+1,d1
	move.l	#%11111111111101,d0
	bsr.w	GetSD
	cmp.b	#2,d7	;.l, use special code
	beq.b	.long

	move.w	EAD_cmd(a4),d0	;.w = simple code
	ror.w	#7,d0
	or.w	d0,cw
	bra.w	PutSEADataExit

.long	move.l	#$0800,d2
EAToDnMainM	cmp.w	#%1000000111000000,cw;fix command type
	beq.b	.divs
	cmp.w	#%1000000011000000,cw
	bne.b	.divu
	moveq	#0,d2
.divs	move.w	#%0100110001000000,cw
	bra.b	.cwok

.divu	cmp.w	#%1100000111000000,cw
	beq.b	.mulu
.muls	cmp.w	#%1100000011000000,cw
	bne.b	.cwok
	moveq	#0,d2
.mulu	move.w	#%0100110000000000,cw

.cwok	move.w	EAD_cmd(a4),d0
	swap	d2	;test divsl/divul
	cmp.w	#dt24,d1
	bne.b	.makedouble
	move.w	EAD_ext(a4),d1
;	exg	d0,d1
	tst.w	d2	;xxxl signal with <>0
	bne.b	.ok
	bset	#10,d0
	bra.b	.ok

.makedouble	move.w	d0,d1	;if not double, make same

.ok	swap	d2
;	rem
;	tst.w	d2
;	beq.b	.nocheck
;	cmp.b	d0,d1	;check dq<>dr, else fail
;	beq.w	IllegalAddress
;	erem
.nocheck	ror.w	#4,d1	;put dq and dr numbers
	or.w	d1,d0
	or.w	d2,d0
	or.w	EAD_cmd(a3),cw
	move.w	d0,GetSDBuff(b)	;hang in there!
	bsr.w	RecalcPC
	move.w	cw,(asa)+	;store cmd
	move.w	GetSDBuff(b),(asa)+;+ext word
	pea	AssembleExit(pc)
	bra.w	PutEAData	;and what else is needed

;---- divul/divsl
EAToDnLS	move.w	#$0800,d2
	bra.b	EAToDnLMain

EAToDnLU	moveq	#0,d2
EAToDnLMain	cmp.b	#2,d7
	bne.w	IllegalSize
	move.l	#1<<dt24+1,d1
	move.l	#%11111111111101,d0
	move.w	d2,GetSDBuff(b)
	bsr.w	GetSD
	moveq	#-1,d2	;signal xxxl command
	move.w	GetSDBuff(b),d2
	bra.w	EAToDnMainM

ccEA	bsr.w	Getcc
	tst.b	d7	;only .b
	bne.w	IllegalSize
	or.w	d1,cw	;or type to cw
	bsr.w	ReadEASource	;get EA
	move.l	#%1100011111101,d1
	btst	d0,d1
	beq.w	IllegalAddress
	bra.w	PutSEADataExit

DBcc	bsr.w	Getcc	;don't care bout size!
	tst.w	d2
	beq.b	.ok
	tst.w	d1
	bne.b	.checkra	;check ra
	move.w	#%100000000,d1
	bra.b	.ok
.checkra	cmp.w	#%100000000,d1
	beq.w	IllegalAddress	;check sr=fail

.ok	or.w	d1,cw
	moveq	#1,d0
	move.l	#1<<dt22,d1
	bsr.w	GetSD
	moveq	#EV_NUMBERTOOBIG,d1
	cmp.b	#2,EAD_bds(a4)	;if long offset, error
	beq.w	AssemblePull
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+	;put cw
	move.w	EAD_bd+2(a4),(asa)+;put 16 bit offset
	bra.w	AssembleExit

;xx = sr/ra
Bcc	bsr.w	Getcc
	or.w	d1,cw	;or cc type
Bxx	move.l	#1<<dt22,d0
	moveq	#0,d1
	bsr.w	GetSD
	moveq	#EV_NUMBERTOOBIG,d1
	move.b	EAD_bds(a3),d2
	cmp.b	d2,d7
	bmi.w	AssemblePull
	move.l	EAD_bd(a3),d0
;	bclr	#0,d0	;make sure offset is even (LET 'IM AV IT)
	tst.w	d7
	bmi.b	.optimize
	tst.b	d7
	bne.b	.testword
.BccByte	move.b	d0,cw
	move.w	cw,(asa)+
	tst.b	d0
	bne.b	.noextra
	clr.w	(asa)+
.noextra	bra.w	AssembleExit

.testword	cmp.b	#1,d7
	bne.b	.long
.BccWord	move.w	cw,(asa)+
	move.w	d0,(asa)+
	bra.b	.noextra

.optimize	tst.b	d2	;store what's needed
	beq.b	.BccByte
	cmp.b	#1,d2
	beq.b	.BccWord

.long	move.b	#-1,cw
	move.w	cw,(asa)+
	move.l	d0,(asa)+
	bra.b	.noextra

;--used by swap
Dn	bsr.w	ReadEASource
	cmp.b	#dt0,d0
	bne.w	IllegalAddress
	or.w	EAD_cmd(a3),cw
	bra.w	None

;---- used by EXT
Dn2	CheckWL
	cmp.b	#1,d7
	beq.b	.changesize
	or.w	#%1000000,cw	;or .l flag to cw
.changesize	bra.b	Dn

;---- used by EXTB
Dn2B	cmp.b	#2,d7
	bne.w	IllegalAddress
	bra.b	Dn

LinkTyp	CheckWL
	tst.w	ForcedSize(b)	;if def, set to long for #read
	bpl.b	.ok
	move.b	#2,ForcedSize+1(b)
.ok	moveq	#%10,d0	;An
	move.l	#%10000000000000,d1;#
	bsr.w	GetSD
	move.w	EAD_cmd(a3),d0
	and.w	#%111,d0
	or.w	d0,cw	;or An #
	moveq	#EV_NUMBERTOOBIG,d1
	tst.w	d7
	bpl.b	.noauto
	move.b	EAD_bds(a4),d7	;if auto, get bds
.noauto	cmp.b	#2,d7
	bne.b	Test16Bit
	move.w	#%0100100000001000,cw;bits for long
	or.w	d0,cw	;get An# again
	cmp.b	#2,EAD_bds(a4)
	bgt.w	AssemblePull
	move.w	cw,(asa)+
	move.l	EAD_bd(a4),(asa)+
	bra.w	AssembleExit

Test16Bit	cmp.b	#1,EAD_bds(a4)
	bgt.w	DataTooLarge
	move.w	cw,(asa)+
	move.w	EAD_bd+2(a4),(asa)+
	bra.w	AssembleExit

;-- used by unlk
An	bsr.w	ReadEASource
	cmp.b	#dt1,d0
	bne.w	IllegalAddress
	move.w	EAD_cmd(a3),d0
	and.w	cm,d0
	or.w	d0,cw	;set An #
	bra.w	None

;--used by stop
IData	bsr.w	ReadEADest
	cmp.b	#dt13,d0
	bne.w	IllegalAddress
	bra.b	Test16Bit

;used by trapv (check trapvc/s)
TVTyp	move.b	(a1),d0
	beq.w	None
	cmp.b	#' ',d0
	beq.w	None
	subq.w	#1,a1

;--used by trap
TrapTyp	move.b	(a1),d0
	beq.b	IData2
	cmp.b	#' ',d0	;test for normal TRAP
	beq.b	IData2

;TRAPcc code
	move.w	#%0101000011111000,cw;set new cmdcode
	bsr.w	Getcc
	tst.w	d2	;test if ra/sr
	bne.w	IllegalAddress
	or.w	d1,cw
	bsr.w	ReadEASource
	cmp.b	#dt23,d0	;EA?
	bne.b	.checkimm
	or.w	#%100,cw
	bra.w	None

.checkimm	cmp.w	#dt13,d0
	bne.w	IllegalAddress
	move.b	EAD_bds(a3),d7
	cmp.b	#2,d7
	bne.b	.checkword
	or.w	#%011,cw
	move.w	cw,(asa)+
	move.l	EAD_bd(a3),(asa)+
	bra.w	AssembleExit

.checkword	cmp.b	#1,d7
	bne.w	IllegalAddress
	cmp.b	#2,EAD_bds(a3)
	beq.w	DataTooLarge
	or.w	#%010,cw
	move.w	cw,(asa)+
	move.w	EAD_bd+2(a3),(asa)+
	bra.w	AssembleExit

;TRAP code
IData2	bsr.w	ReadEASource
	cmp.b	#dt13,d0
	bne.w	IllegalAddress
	move.l	EAD_bd(a3),d0
	cmp.l	#$f,d0
	bgt.w	IllegalSize
	and.w	cm,d0
	or.w	d0,cw
	bra.w	None

;--used by exg
RxRy	moveq	#%11,d0
	move.l	d0,d1
	bsr.w	GetSD
	move.w	EAD_cmd(a3),d3
	move.w	EAD_cmd(a4),d4
	move.w	#%10001000,d2	;An,Dn
	cmp.w	#dt0,d0	;Dx,??
	bne.b	.RxRy000
	cmp.w	#dt0,d1
	bne.b	RxRy100
	moveq	#%01000000,d2	;Dy,Dx?
	bra.b	RxRy100

.swapxy	exg	d3,d4
	bra.b	RxRy100

.RxRy000	cmp.w	#dt0,d1
	beq.b	.swapxy
	moveq	#%1001000,d2	;Ax,Ay

RxRy100	or.w	d2,cw
	moveq	#%111,d2	;mask numbers
	and.w	d2,d3
	and.w	d2,d4
	ror.w	#7,d3	;right pos
	or.w	d3,cw	;or x and y
	or.w	d4,cw
	bra.w	None

;-- DC.z Value
DCTyp	bsr.w	ReadEASource
	move.l	EAD_bd(a3),d0
	moveq	#-1,d2
	move.l	d0,d1
	tst.b	d7
	bne.b	.DCWord
	clr.b	d2
	and.l	d2,d1
	beq.b	.byteok
	cmp.l	d2,d1
	bne.w	DataTooLarge	
.byteok	move.b	d0,(asa)+
	addq.w	#1,asa	;insert extra byte to get EVEN *8-)
	bra.b	.exit

.DCWord	cmp.b	#1,d7
	bne.b	.DCLong
	clr.w	d2
	and.l	d2,d1
	beq.b	.wordok
	cmp.l	d2,d1
	bne.w	DataTooLarge
.wordok	move.w	d0,(asa)+
	bra.b	.exit

.DCLong	move.l	d0,(asa)+
.exit	bra.w	AssembleExit

;-- DCB.z Amount,Value
DCBTyp	move.l	#%1100000000000,d2
	move.l	d2,d3
	bsr.w	GetSD
	move.l	EAD_bd(a3),d0
	bmi.w	IllegalSize	;if amount is neg
	beq.w	IllegalSize	;^ zero
	move.l	EAD_bd(a4),d1
	tst.b	d7
	bne.b	.DCBWord
	move.l	d0,d7
.putbytes	move.b	d1,(asa)+
	subq.l	#1,d0
	bne.b	.putbytes
	ror.w	#1,d7	;test for align
	bcc.b	.exit
	addq.w	#1,asa
.exit	bra.w	AssembleExit

.DCBWord	cmp.b	#1,d7
	bne.b	.DCBLong
.putwords	move.w	d1,(asa)+
	subq.l	#1,d0
	bne.b	.putwords
	bra.b	.exit

.DCBLong	move.l	d1,(asa)+
	subq.l	#1,d0
	bne.b	.DCBLong
	bra.b	.exit

;-- used by jxx&pea
EA	move.l	#%01111111100100,d0
EAMain	moveq	#0,d1
	bsr.w	GetSD
	bra.w	PutSEADataExit

;-- used by clr,neg,negx,not
EA2	moveq	#0,d1
	move.b	d7,d1	;put size
	asl.w	#6,d1
	or.w	d1,cw
EA2Main	move.l	#%1100011111101,d0
	bra.b	EAMain

;--used by tas & nbcd
EA3	tst.b	d7
	bne.w	IllegalSize
	bra.b	EA2Main

;-- used by tst
EA4	moveq	#0,d1
	move.b	d7,d1	;put size
	asl.w	#6,d1
	or.w	d1,cw
	move.l	#alltypes,d0
	bra.b	EAMain

;-- used by cpRestore
EA5	bsr.w	ReadEASource
	move.l	#%1111111101100,d1;pc also allowed
EA5Main	btst	d0,d1
	beq.w	IllegalAddress
	or.w	EAD_cmd(a3),cw
	bra.w	FastPutSEA

;-- used by cpSave
EA6	bsr.w	ReadEASource
	move.l	#%1100011110100,d1
	bra.b	EA5Main

;-- the shift commands use this routine
Shift	move.l	#%11100011111101,d0;or'ed allowed sources
	move.l	#1+1<<dt23,d1;only Dn/" " allowed Dest
	bsr.w	GetSD
	cmp.w	#dt0,d1	;check shift type
	bne.b	ShiftEA

	and.w	#%1111000100000000,cw;mask off trash
	move.w	ShiftID(b),d2	;get signatur bits from NEXT
	and.w	#%11000,d2
	or.w	d2,cw	;or signature bits
	and.w	#%11,d7
	asl.w	#6,d7	;set size
	or.w	d7,cw

	cmp.w	#dt0,d0	;check Dx,Dy
	bne.b	ShiftI	;else fail
	or.w	#%100000,cw	;set i/r=1(r)
	move.w	EAD_cmd(a3),d0
ShiftMain	move.w	EAD_cmd(a4),d1
	or.w	d1,cw	;set dest reg
	ror.w	#7,d0
	or.w	d0,cw	;set s reg
	bra.w	None

ShiftI	cmp.w	#dt13,d0	;check #
	bne.w	IllegalAddress
	move.l	EAD_bd(a3),d0	;n=1-8 allowed
	bmi.w	IllegalSize
	beq.w	IllegalSize
	moveq	#9,d3
	cmp.l	d3,d0
	bge.w	IllegalSize
	moveq	#%111,d2
	and.w	d2,d0	;mask trash off (bit 4 if n=8)
	bra.b	ShiftMain

ShiftEA	cmp.w	#dt13,d0	;fail if #
	beq.w	IllegalAddress
	and.w	#%1111111111000000,cw;mask of trash
	bra.w	PutSEADataExit

BitManipS	move.l	#%10000000000001,d0;Dn+# allowed
	move.l	#%01100011111101,d1
	move.w	cw,d2
	and.w	#%11000000,d2
	bne.b	.btstcheck	;btst is special
	move.w	#%11111111111101,d1
.btstcheck	bsr.w	GetSD
	cmp.w	#dt0,d0
	bne.b	.static
	and.w	#%1111000011000000,cw
	or.w	#%0000000100000000,cw;convert cw to dynamic
	move.w	EAD_cmd(a3),d0
	ror.w	#7,d0	;put Dn
	or.w	d0,cw
	bra.w	FastPutDData	;and then put dest

.static	cmp.w	#dt13,d1	;#,# not allowed
	beq.w	IllegalAddress

	tst.b	EAD_bds(a3)	;check # if only .b
	bne.w	IllegalSize

	exg	a3,a4
	bsr.b	RecalcPC
	exg	a3,a4
	or.w	EAD_cmd(a4),cw
	move.w	cw,(asa)+	;store cmd
	move.w	EAD_bd+2(a3),d0
	and.w	#$ff,d0	;mask off shit
	move.w	d0,(asa)+	;then the # value

	bra.w	PutDEADataX	;and finaly any any EA data

;recalculate PC for source-pc types (btst, movem, mulxx.l,fxx)
;problem: if size exceeded:change type!
RecalcPC	move.w	EAD_type(a3),d0	;recalculate pc
	cmp.w	#dt8,d0
	bne.b	.checkd16
	move.w	EAD_bd+2(a3),d0
	ext.l	d0
	subq.l	#2,d0
	move.w	d0,EAD_bd+2(a3)
	bsr.w	CheckSize
	cmp.b	#2,d0
	beq.w	DataTooLargeP
	bra.b	.ok

.checkd16	cmp.w	#dt9,d0
	bne.b	.checkd8
	move.b	EAD_ext+1(a3),d0
	ext.w	d0
	ext.l	d0
	subq.l	#2,d0
	move.b	d0,EAD_ext+1(a3)
	bsr.w	CheckSize
	tst.b	d0
	bne.w	DataTooLargeP
	bra.b	.ok

.checkd8	cmp.w	#dt10,d0
	bne.b	.ok
	move.w	EAD_ext(a3),d1
	btst	#7,d1
	bne.b	.ok	;no calc if supressed (zpc)
	btst	#5,d1
	beq.b	.ok	;if no bds
	move.l	EAD_bd(a3),d0
	btst	#4,d1
	bne.b	.noext
	ext.l	d0
.noext	subq.l	#2,d0
	move.l	d0,EAD_bd(a3)
	bsr.w	CheckSize
	move.b	d0,EAD_bds(a3)	;set new bds ;;need to do force check;;

.ok	rts

;---- bitfield
Field	bsr.w	ReadEASource	;get EA
	move.l	#%1100011100101,d1
	btst	d0,d1
	beq.w	IllegalAddress
	bsr.w	GetBitField	;get bitfield
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+
	move.w	d0,(asa)+
	pea	AssembleExit(pc)
	bra.w	PutEAData

Field2	bsr.w	ReadEASource	;get EA
	move.l	#%1111111100101,d1
	btst	d0,d1
	beq.w	IllegalAddress
	bsr.w	GetBitField	;get bitfield
	moveq	#EV_DESTINATIONNEEDED,d1
	cmp.b	#',',(a0)+	;get destin register
	bne.w	AssemblePull
	move.b	(a0)+,d1
	or.b	#$20,d1
	cmp.b	#'d',d1
	bne.w	IllegalAddress
	moveq	#0,d1
	move.b	(a0)+,d1
	sub.b	#'0',d1
	bmi.w	IllegalAddress
	cmp.b	#7,d1
	bgt.w	IllegalAddress
Field2Entry	ror.w	#4,d1
	or.w	d1,d0
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+
	move.w	d0,(asa)+
	pea	AssembleExit(pc)
	bra.w	PutEAData

Field3	moveq	#1,d0
	move.l	#%1100011100101,d1
	bsr.w	GetSD
	bsr.w	GetBitField
	move.w	EAD_cmd(a3),d1
	move.l	a4,a3	;swap d/s
	bra.b	Field2Entry

;---- bkpt - 3 bits #
Imm3	bsr.w	ReadEASource
	cmp.w	#dt13,d0
	bne.w	IllegalAddress
	move.l	EAD_bd(a3),d0	;check datavalue 0-7
	bmi.w	DataTooLarge
	cmp.l	#7,d0
	bgt.w	DataTooLarge
	or.w	d0,cw
	bra.w	None

;---- Callm
Callm	move.l	#1<<dt13,d0
	move.l	#%1111111100100,d1
	bsr.w	GetSD
	move.l	EAD_bd(a3),d1
	move.l	d1,d0
	and.l	#$ffffff00,d0
	bne.w	DataTooLarge
	or.w	EAD_cmd(a4),cw
	move.w	cw,(asa)+
	move.w	d1,(asa)+
	bra.w	PutDEADataX

;---- cas
CasTyp	addq.w	#1,d7
	and.w	#%11,d7
	ror.w	#7,d7
	or.w	d7,cw	;add size
	moveq	#1,d0	;get u and c register
	moveq	#1,d1
	bsr.w	GetSD
	move.w	EAD_cmd(a4),d2
	asl.w	#6,d2
	or.w	EAD_cmd(a3),d2	;prepare "ext" word
	cmp.b	#',',(a0)+
	bne.w	IllegalAddress
	bsr.w	ReadEASource	;get EA
	move.l	#%1100011111100,d1;check if valid
	btst	d0,d1
	beq.w	IllegalAddress
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+
	move.w	d2,(asa)+
	bra.w	PutSEADataX

;---- cas2
DcDuEA	CheckWL
	addq.w	#1,d7
	and.w	#%11,d7
	ror.w	#7,d7
	or.w	d7,cw
	move.l	#1<<dt24,d0
	move.l	d0,d1
	bsr.w	GetSD
	move.w	EAD_cmd(a3),d3
	move.w	EAD_ext(a3),d4
	move.w	EAD_cmd(a4),d0
	asl.w	#6,d0
	or.w	d0,d3
	move.w	EAD_ext(a4),d0
	asl.w	#6,d0
	or.w	d0,d4
	cmp.b	#',',(a0)+
	bne.w	IllegalAddress
	bsr.b	.GetRegAD
	or.w	d0,d3
	cmp.b	#':',(a0)+
	bne.w	IllegalAddress
	bsr.b	.GetRegAD
	or.w	d0,d4
	move.w	cw,(asa)+
	move.w	d3,(asa)+
	move.w	d4,(asa)+
	bra.w	AssembleExit

.GetRegAD	cmp.b	#'(',(a0)+	;get (Xn) to D0
	bne.w	IllegalAddressP
	moveq	#0,d0
	move.b	(a0)+,d1
	or.b	#$20,d1
	cmp.b	#'d',d1
	beq.b	.ok
	cmp.b	#'a',d1
	bne.w	IllegalAddressP
	moveq	#%1000,d0
.ok	move.b	(a0)+,d1
	sub.b	#'0',d1
	bmi.w	IllegalAddressP
	cmp.b	#7,d1
	bgt.w	IllegalAddressP
	or.w	d1,d0
	cmp.b	#')',(a0)+
	bne.w	IllegalAddressP
	ror.w	#4,d0
	rts

;---- Move16
LMove	move.l	#%1000000001100,d0
	move.l	d0,d1
	bsr.w	GetSD
	moveq	#%1100,d2
	cmp.w	#dt12,d0
	bne.b	.testdabs
	moveq	#%1000,d3	;xxxx.l,?
.modeok	btst	d1,d2
	beq.w	IllegalAddress
	cmp.w	#dt3,d1
	beq.b	.add
	bset	#4,d3
.add	or.w	d3,cw
	move.w	EAD_cmd(a4),d3
	and.w	#%111,d3
	or.w	d3,cw
	move.w	cw,(asa)+
	move.l	EAD_bd(a3),(asa)+
	bra.w	AssembleExit

.testdabs	cmp.w	#dt12,d1
	bne.b	.checkboth
	exg	d0,d1	;?,xxxx.l
	exg	a3,a4	;swap s/d and use same code
	moveq	#0,d3
	bra.b	.modeok

.checkboth	cmp.w	#dt3,d0
	bne.w	IllegalAddress
	cmp.w	d0,d1
	bne.w	IllegalAddress
	move.w	EAD_cmd(a3),d0	;(an)+,(am)+
	and.w	#%111,d0
	or.w	#%1111011000100000,d0
	move.w	d0,(asa)+
	move.w	EAD_cmd(a4),cw
	ror.w	#4,cw
	and.w	#$f000,cw
	bra.w	None

;---- pack
PackTyp	moveq	#%10001,d0
	moveq	#%10001,d1
PackMain	bsr.w	GetSD
	cmp.w	d0,d1
	bne.w	IllegalAddress
	cmp.w	#dt0,d0
	beq.b	.reg
	bset	#3,cw	;mark mem operation
.reg	move.w	EAD_cmd(a3),d0
	and.w	#%111,d0
	or.w	d0,cw
	move.w	EAD_cmd(a4),d0
	and.w	#%111,d0
	ror.w	#7,d0
	or.w	d0,cw
	cmp.b	#',',(a0)+
	bne.w	IllegalAddress
	bsr.w	ReadEASource
	cmp.b	#dt13,d0
	bne.w	IllegalAddress
	cmp.b	#2,EAD_bds(a3)
	beq.w	DataTooLarge
	move.w	cw,(asa)+	;put cw
	move.w	EAD_bd+2(a3),(asa)+;put adjustment
	bra.w	AssembleExit

	rem	;why was this one made?
;---- unpack
UnPackTyp	moveq	#%100001,d0
	moveq	#%100001,d1
	bra.b	PackMain
	erem

;---- pvalid
ValTyp	cmp.b	#' ',(a0)
	bne.b	.spacefree
	addq.w	#1,a0
	bra.b	ValTyp

.spacefree	move.b	(a0),d0
	or.b	#$20,d0
	move.l	#%1100011100100,d2;allowed dests
	cmp.b	#'v',d0
	bne.b	.checkreg
	addq.w	#1,a0
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0)+,d0
	or.w	#$2020,d0
	cmp.w	#'al',d0
	bne.w	IllegalAddress	
	cmp.b	#',',(a0)+
	bne.w	IllegalAddress
	bsr.w	ReadEADest
	btst	d0,d2
	beq.w	IllegalAddress
	move.w	#%0010100000000000,d2;VAL-identifier
.exit	or.w	EAD_cmd(a4),cw
	move.w	cw,(asa)+
	move.w	d2,(asa)+
	bra.w	PutSEADataX

.checkreg	moveq	#%10,d0
	move.l	d2,d1
	bsr.w	GetSD
	move.w	EAD_cmd(a3),d2
	and.w	#%111,d2
	or.w	#%0010110000000000,d2
	bra.b	.exit

;---- rtd
I16	bsr.w	ReadEASource
	cmp.w	#dt13,d0
	bne.w	IllegalAddress
	cmp.b	#2,EAD_bds(a3)
	beq.w	DataTooLarge
	move.w	cw,(asa)+
	move.w	EAD_bd+2(a3),(asa)+
	bra.w	AssembleExit

;---- rtm
XnTyp	bsr.w	ReadEASource
	moveq	#%11,d1
	btst	d0,d1
	beq.w	IllegalAddress
	or.w	EAD_cmd(a3),cw
	bra.w	None

;---- cinv
Cache	bsr.b	CheckCache
	clr.w	EAD_cmd(a4)	;make sure =0
CacheMain	asl.w	#6,d0
	or.w	d0,cw	;and put'em
	move.w	EAD_cmd(a4),d0
	and.w	#%111,d0
	or.w	d0,cw
	bra.w	None

CacheAn	bsr.b	CheckCache
	cmp.b	#',',(a0)+
	bne.w	IllegalAddress
	move.w	d0,d3
	bsr.w	ReadEADest
	cmp.w	#dt2,d0
	bne.w	IllegalAddress
	move.w	d3,d0
	bra.b	CacheMain

;get cache-type
CheckCache	move.b	(a0)+,d1
	beq.b	.error
	cmp.b	#' ',d1
	beq.b	CheckCache
	asl.w	#8,d1
	move.b	(a0)+,d1
	or.w	#$2020,d1
	moveq	#0,d0
	cmp.w	#'nc',d1
	beq.b	.ok
	moveq	#1,d0
	cmp.w	#'dc',d1
	beq.b	.ok
	moveq	#2,d0
	cmp.w	#'ic',d1
	beq.b	.ok
	cmp.w	#'bc',d1
	bne.b	.error
	moveq	#3,d0
.ok	rts

.error	addq.w	#4,a7
	bra.w	IllegalAddress


;---- movec
MovCTyp	move.l	#%11+1<<dt14,d0
	move.l	d0,d1
	bsr.w	GetSD
	cmp.w	d0,d1
	beq.w	IllegalAddress
	cmp.w	#dt14,d0
	beq.b	.sourcereg
	bset	#0,cw
	exg	a3,a4
.sourcereg	move.w	EAD_cmd(a4),d0
	ror.w	#4,d0
	or.w	EAD_ext(a3),d0
	move.w	cw,(asa)+
	move.w	d0,(asa)+
	bra.w	AssembleExit

;---- moves
MovSTyp	move.l	#%1100011111111111,d0
	move.l	d0,d1
	bsr.w	GetSD
	moveq	#0,d3
	moveq	#dt1,d2
	cmp.w	d2,d0
	bgt.b	.toreg
	exg	a3,a4	;source is Reg
	exg	d0,d1	;swap
	bset	#11,d3	;and change direction
.toreg	cmp.w	d2,d0
	ble.w	IllegalAddress	;then source must be bigger'n 0/1
	cmp.w	d2,d1
	bgt.w	IllegalAddress	;and dest must be 0/1
	move.w	EAD_cmd(a4),d0
	ror.w	#4,d0
	or.w	d0,d3
	and.w	#%11,d7
	asl.w	#6,d7
	or.w	d7,cw
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+
	move.w	d3,(asa)+
	bra.w	PutSEADataX

;---- pbcc
PBcc	bsr.w	Getpcc
	or.w	d0,cw
	move.l	#1<<dt22,d0
	moveq	#0,d1
	bsr.w	GetSD
	moveq	#EV_NUMBERTOOBIG,d1
	move.b	EAD_bds(a3),d2
	cmp.b	d2,d7
	bmi.w	AssemblePull
	move.l	EAD_bd(a3),d0
	cmp.b	#2,d7
	bne.b	.setword
	bset	#6,cw
	move.w	cw,(asa)+	;store long
	move.l	d0,(asa)+
	bra.w	AssembleExit

.setword	move.w	cw,(asa)+
	move.w	d0,(asa)+
	bra.w	AssembleExit

;---- pdbcc
PDBcc	bsr.w	Getpcc
	move.w	d0,GetSDBuff(b);store data
	moveq	#1,d0
	move.l	#1<<dt22,d1
	bsr.w	GetSD
	bsr.w	RecalcCC
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+
	move.w	GetSDBuff(b),(asa)+;store cc
	move.w	EAD_bd+2(a4),(asa)+
	bra.w	AssembleExit

;---- PScc
PScc	bsr.w	Getpcc
	cmp.w	#$8001,d7
	beq.b	.ok
	tst.b	d7
	bne.w	IllegalSize
.ok	move.w	d0,d3
	bsr.w	ReadEASource
	move.l	#%1100011111101,d1
	btst	d0,d1
	beq.w	IllegalAddress
	bra.b	PutSFCData

;---- (An)
PostAn	bsr.w	ReadEASource
	cmp.w	#dt2,d0
	bne.w	IllegalAddress
	move.w	EAD_cmd(a3),d0
	and.w	#%111,d0
	or.w	d0,cw
	bra.w	None

;---- pflusha for '030 and mmu
PFlusha3	move.w	cw,(asa)+
	move.w	#%0010010000000000,(asa)+
	bra.w	AssembleExit

;---- pflush type ('030 + mmu)
PFTyp	move.w	#%0011000000000000,d3
PFTypMain	move.l	#%11<<dt13!1,d0
	move.l	#1<<dt13,d1
	bsr.w	GetSD

	bsr.b	CheckFC

	move.l	EAD_bd(a4),d0	;get mask
	bmi.w	DataTooLarge
	cmp.l	#%1111,d0
	bgt.w	DataTooLarge
	asl.w	#5,d0
	or.w	d0,d3

	cmp.b	#',',(a0)	;check for EA
	beq.b	.addEA
	move.w	cw,(asa)+
	move.w	d3,(asa)+
	bra.w	AssembleExit

.addEA	addq.w	#1,a0
	bsr.w	ReadEASource	;get EA
	move.l	#%1100011100100,d1
	btst	d0,d1	;check type
	beq.w	IllegalAddress
	bset	#11,d3
PutSFCData	or.w	EAD_cmd(a3),cw
PutSFCData2	move.w	cw,(asa)+
	move.w	d3,(asa)+
	bra.w	PutSEADataX

;---- Check function code
;-- Have FC data in source when calling
;--move.l	#%11<<dt13!1,d0
;-- I/O	d3 = FC-register
;----
CheckFC	cmp.w	#dt13,d0
	bne.b	.wasimm
	move.l	EAD_bd(a3),d0	;check #xxx
	bmi.w	DataTooLargeP
	cmp.l	#%1111,d0	;only 4 bits
	bgt.w	DataTooLargeP
	or.w	d0,d3
	bset	#4,d3
	bra.b	.ok

.wasimm	cmp.w	#dt0,d0	;check Dn
	bne.b	.wasdata
	bset	#3,d3
	or.w	EAD_cmd(a3),d3
	bra.b	.ok

.wasdata	move.w	EAD_ext(a3),d0	;check sfc/dfc
	cmp.w	#1,d0
	bgt.w	IllegalAddressP
	or.w	d0,d3
.ok	rts

;---- pflushs
PFSTyp	move.w	#%0011010000000000,d3
	bra.w	PFTypMain

;---- pflushr
PFRTyp	bsr.w	ReadEASource
	move.l	#%11111111111100,d1
	btst	d0,d1
	beq.w	IllegalAddress
	bsr.w	RecalcPC
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+
	move.w	#%1010000000000000,(asa)+
	bra.w	PutSEADataX

;---- ploadw
FCEAW	move.w	#%0010000000000000,d3
	bra.b	FCEAMain

;---- ploadl
FCEAR	move.w	#%0010001000000000,d3

;---- function code to EA
FCEAMain	move.l	#%11<<dt13!1,d0
	move.l	#%1100011100100,d1
	bsr.w	GetSD
	bsr.w	CheckFC
	move.l	a4,a3	;put dest data
	bra.w	PutSFCData

;---- ptrapcc
PTrapTyp	bsr.w	Getpcc
cpTrapMain	move.w	d0,d3
	move.l	a0,a1
.testimm	cmp.b	#' ',(a1)+	;is there any imm?
	beq.b	.testimm
	cmp.b	#'#',-1(a1)
	beq.b	.checkimm
	or.w	#%100,cw	;no imm data
	move.w	cw,(asa)+
	move.w	d3,(asa)+
	bra.w	AssembleExit

.checkimm	tst.b	d7	;not byte!
	beq.w	IllegalSize
	bsr.w	ReadEASource
	cmp.w	#dt13,d0	;get imm
	bne.w	IllegalAddress
	cmp.b	EAD_bds(a3),d7
	blt.w	DataTooLarge
	move.w	d7,d0
	addq.b	#1,d0
	and.w	#%11,d0
	or.w	d0,cw
	bra.w	PutSFCData2

;-----------------------------------------------------------------------------;
;-		       Support for FPU
;-----------------------------------------------------------------------------;

FPUSDNormal	move.l	#1<<dt29,d1	;dest needed!
	bra.b	FPUNormalMain

;---- <ea>,FPn / FPm,FPn / FPn (ID data in d4!)
FPUNormal	move.l	#1<<dt29+1<<dt23,d1
FPUNormalMain	move.l	#%11111111111101+1<<dt29,d0
	bsr.w	GetSD
	cmp.w	#dt29,d0
	bne.b	FPUEAFPn
	move.w	EAD_cmd(a3),d0
	ror.w	#6,d0
	or.w	d0,d4	;or source
	ror.w	#3,d0	;prepare for dest
	cmp.w	#dt23,d1	;also dest?
	beq.b	FPUnodest
FPUNORMEXIT	move.w	EAD_cmd(a4),d0
	asl.w	#7,d0
FPUnodest	or.w	d0,d4
	move.w	cw,(asa)+
	move.w	d4,(asa)+
	bra.w	AssembleExit

FPUEAFPn	bset	#14,d4
	tst.w	EAD_type(a3)	;check Dn is b/w/l/s
	bne.b	.ok
	cmp.b	#%001,d7
	blt.b	.ok
	cmp.b	#%100,d7
	beq.b	.ok
	cmp.b	#%110,d7
	bne.w	IllegalSize
.ok	move.w	d7,d0
	and.w	#%111,d0
	ror.w	#6,d0
	or.w	d0,d4
	move.w	EAD_cmd(a4),d0
	asl.w	#7,d0
	or.w	d0,d4
	move.w	d4,d3

	bsr.w	RecalcPC
	bra.w	PutSFCData

;---- FPUBcc command
FPUBcc	bsr.w	Getfcc
	or.w	d0,cw
	cmp.b	#1,d7	;only .w/.l
	blt.w	IllegalSize
	beq.b	.word
	bset	#6,cw	;mark long operation
.word	moveq	#0,d1
	move.l	#1<<dt22,d0	;get address
	bsr.w	GetSD
	cmp.b	EAD_bds(a3),d7	;fail if offset too big for size
	bmi.w	DataTooLarge
	move.w	cw,(asa)+
	cmp.b	#1,d7
	bne.b	.long
	move.w	EAD_bd+2(a3),(asa)+;store 16b
	bra.w	AssembleExit

.long	move.l	EAD_bd(a3),(asa)+;store 32b
	bra.w	AssembleExit

;---- FPUDBcc
FPUDBcc	bsr.w	Getfcc	;get cc
	move.w	d0,d3
	moveq	#1,d0	;get countreg and offset
	move.l	#1<<dt22,d1
	bsr.w	GetSD
	bsr.b	RecalcCC
	cmp.b	#2,EAD_bds(a4)	;check not long
	beq.w	DataTooLarge
	or.w	EAD_cmd(a3),cw
	move.w	cw,(asa)+	;store data
	move.w	d3,(asa)+
	move.w	EAD_bd+2(a4),(asa)+
	bra.w	AssembleExit

RecalcCC	move.l	EAD_bd(a4),d0	;recalculate CC offset
	subq.l	#2,d0
	move.l	d0,EAD_bd(a4)
	bsr.w	CheckSize
	move.b	d0,EAD_bds(a4)
	cmp.b	#2,d0
	beq.w	DataTooLargeP
	rts

;---- FPU Scc
FPUScc	bsr.w	Getfcc
	move.w	d0,d3
	tst.w	d7
	bmi.b	.defok
	bne.w	IllegalSize
.defok	move.l	#%1100011111101,d0
	moveq	#0,d1
	bsr.w	GetSD
	bra.w	PutSFCData	;store EA data
;---- FNOP
FPUNOP	move.w	cw,(asa)+
	clr.w	(asa)+
	bra.w	AssembleExit

;---- FTRAPcc
FPUTRAPcc	bsr.w	Getfcc
	bra.w	cpTrapMain	;use PTRAPcc code

;---- FTST
FPUTST	moveq	#0,d1
	move.l	#%11111111111101+1<<dt29,d0
	bsr.w	GetSD
	cmp.w	#dt29,d0
	beq.b	FPUFPs

FPUCheckEA	bset	#14,d4
	move.w	EAD_cmd(a3),d0
	or.w	d0,cw
	and.w	#%111000,d0
	bne.b	.ok
	cmp.b	#%001,d7
	blt.b	.ok
	cmp.b	#%100,d7
	beq.b	.ok
	cmp.b	#%110,d7
	bne.w	IllegalSize
.ok	and.w	#%111,d7
	ror.w	#6,d7
	or.w	d7,d4
	move.w	cw,(asa)+
	move.w	d4,(asa)+
	bra.w	PutSEADataX

;---- FSINCOS
FPUSCOS	move.l	#%11111111111101+1<<dt29,d0
	move.l	#1<<dt30,d1
	bsr.w	GetSD
	or.w	EAD_cmd(a4),d4
	move.w	EAD_ext(a4),d1
	asl.w	#7,d1
	or.w	d1,d4
	cmp.w	#dt29,d0
	bne.w	FPUEAFPn
FPUFPs	move.w	EAD_cmd(a3),d0
	ror.w	#6,d0
STOREFPU	or.w	d0,d4
	move.w	cw,(asa)+
	move.w	d4,(asa)+
	bra.w	AssembleExit

;---- fmovecr
FPUMOVECR	moveq	#0,d7	;fake size to byte!
	move.l	#1<<dt13,d0
	move.l	#1<<dt29,d1
	bsr.w	GetSD
	move.l	EAD_bd(a3),d0
	bsr.w	CheckSize	;cannot check bdssize coz' of forced!
	tst.b	d0
	bne.w	DataTooLarge
	move.w	EAD_cmd(a4),d0
	asl.w	#7,d0
	or.w	d0,d4
	move.w	EAD_bd+2(a3),d0
	and.w	#%1111111,d0
	bra.b	STOREFPU

;---- fmovem
FPUMOVEM	move.l	#%10100000000000000111111111111111,d0;bugger! :-)
	move.l	#%10100000000000000101100011111111,d1
	bsr.w	GetSD
	cmp.w	#dt14,d0
	beq.w	.cregssource
	cmp.w	#dt14,d1
	beq.w	.cregsdest
	move.l	#%1100011110100,d2
	move.l	#%1111111101100,d3
	cmp.w	#dt29,d0	;fpn,ea
	bne.b	.checkms
	move.w	EAD_cmd(a3),d0
	moveq	#0,d7
	bset	d0,d7
	move.w	d7,EAD_ext(a3)	;convert to list-type
	bra.b	.ok1

.checkms	cmp.w	#dt31,d0	;<list>,ea
	bne.b	.fpumsource
.ok1	btst	d1,d2
	beq.w	IllegalAddress
	bset	#13,d4
	exg	a3,a4
	bra.b	.listexit

.fpumsource	cmp.w	#dt29,d1	;fpn,ea
	bne.b	.checkmd
	move.w	EAD_cmd(a4),d1
	moveq	#0,d7
	bset	d1,d7
	move.w	d7,EAD_ext(a4)	;convert to list-type
	bra.b	.ok2

.checkmd	cmp.w	#dt31,d1	;ea,<list>
	bne.b	.fpumdest
.ok2	btst	d0,d3
	beq.w	IllegalAddress
	bset	#12,d4
.listexit	or.w	EAD_ext(a4),d4
	move.w	d4,d3
	bra.w	PutSFCData

.fpumdest	cmp.w	#dt0,d0
	bne.b	.dynsource
	btst	d1,d2
	beq.w	IllegalAddress
	exg	a4,a3
	bset	#11,d4
	bset	#13,d4
.dynexit	move.w	EAD_cmd(a4),d0
	asl.w	#3,d0
	or.w	d0,d4
	bra.b	.listexit

.dynsource	cmp.w	#dt0,d1
	bne.w	IllegalAddress
	btst	d0,d3
	beq.w	IllegalAddress
	or.w	#%1100000000000,d4
	bra.b	.dynexit

;-- fpucontrol registers
.cregssource	bset	#13,d4
	move.l	#%1100011111111,d2
	exg	a3,a4
	exg	d0,d1
	bra.b	.cregmain

.cregsdest	move.l	#%11111111111111,d2
.cregmain	and.w	#%1010000000000000,d4;fix bits to fmovem cr
	btst	d0,d2
	beq.w	IllegalAddress
	move.w	EAD_ext(a4),d1
	or.w	d1,d4
	cmp.w	#dt1,d0
	bgt.b	.nosizecheck
	cmp.w	#'fc',EAD_cmd(a4);check only one reg is selected
	bne.w	IllegalAddress	;fail if not
	cmp.w	#dt1,d0	;An?
	bne.b	.nosizecheck
	btst	#10,d1	;if An, check fpiar!
	beq.w	IllegalAddress
.nosizecheck	bra.w	.listexit
	
;---- FMOVE
FPUMOVE	move.l	#%1100011111111+1<<dt14+1<<dt29,d1
FPUMOVEMain	move.l	#%11111111111111+1<<dt14+1<<dt29,d0
	bsr.w	GetSD
	cmp.w	#dt14,d0
	beq.w	.fpucrs
	cmp.w	#dt14,d1
	beq.w	.fpucrd
	cmp.w	#dt29,d1
	beq.w	CheckFPUD
	cmp.w	#dt29,d0
	bne.w	IllegalAddress
	move.l	#%1100011111101,d2
	btst	d1,d2
	beq.w	IllegalAddress
	exg	a3,a4
	move.w	EAD_cmd(a4),d0
	asl.w	#7,d0
	or.w	d0,d4
	or.w	#%0110000000000000,d4
	cmp.b	#'{',(a0)	;check static/dynamic k-factor
	bne.w	FPUCheckEA
	addq.w	#1,a0
	move.b	(a0)+,d0
	cmp.b	#'#',d0
	bne.b	.kimm
	grcall	GetValueCall
	bmi.w	SyntaxError
	and.w	#%1111111,d0
	or.w	d0,d4
	moveq	#%011,d7
	bra.w	FPUCheckEA
	
.kimm	or.b	#$20,d0
	cmp.b	#'d',d0
	bne.w	IllegalAddress
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.w	IllegalAddress
	cmp.b	#7,d0
	bgt.w	IllegalAddress
	asl.w	#4,d0
	or.b	d0,d4
	moveq	#%111,d7
	bra.w	FPUCheckEA

.fpucrs	bset	#13,d4
	exg	a3,a4
	exg	d0,d1
.fpucrd	cmp.w	#'fc',EAD_cmd(a3)
	bne.w	IllegalAddress	;check only one reg
	move.w	EAD_ext(a3),d1
	and.w	#%111,d1
	cmp.w	#dt1,d0
	bne.b	.checkan
	cmp.w	#1,d1	;if fpiar, it's ok,else fail!
	bne.w	IllegalAddress
.checkan	ror.w	#6,d1
	or.w	d1,d4
	or.w	#$8000,d4	;fix ext word to cr-type move
	move.w	d4,d3
	bra.w	PutSFCData

;---- fpu is dest. also used by '040 fmove
CheckFPUD	cmp.w	#dt29,d0
	bne.b	.checkea
	move.w	EAD_ext(a3),d0
	ror.w	#6,d0
	or.w	d0,d4
	bra.w	FPUNORMEXIT

.checkea	move.l	#%11111111111101,d1
	btst	d0,d1
	beq.w	IllegalAddress
	bra.w	FPUEAFPn


FPUxMOVE	move.l	#1<<dt29,d1	;only d=fpn allowed!
	bra.w	FPUMOVEMain

;---- PMOVE!
PMOVETYPE	moveq	#0,d2
PMOVETYPEMain	bsr.w	GetPMOVERegs
	bpl.w	.regtomem
	bsr.w	ReadEASource
	cmp.w	#1<<dt13,d0
	bgt.w	IllegalAddress
	moveq	#EV_DESTINATIONNEEDED,d1
	cmp.b	#',',(a0)+
	bne.w	AssemblePull
	bsr.w	GetPMOVERegs
	bmi.w	IllegalAddress
	move.w	d1,EAD_ext(a4)

.pmovmain	cmp.w	#7,d0
	bgt.b	.lowregs
	or.w	#$4000,d2
	btst	#8,d2	;fd-type?
	beq.b	.notfd
	btst	#2,d0	;only 0/2/3 allowed in fd-mode
	bne.w	IllegalAddress
	cmp.w	#1,d0
	beq.w	IllegalAddress

.notfd	btst	#2,d0	;check size for crp/srp/drp
	bne.b	.ok
	tst.b	d0
	beq.b	.ok
	move.w	EAD_type(a3),d1
	btst	#9,d2
	beq.b	.dest
	move.w	EAD_type(a4),d1
.dest	cmp.w	#dt1,d1
	ble.w	IllegalAddress
	bra.b	.ok

.lowregs	cmp.w	#9,d0
	bgt.b	.srregs
	btst	#8,d2
	bne.w	IllegalAddress	;not allowed in fd
	or.w	#$6000,d2
	bra.b	.ok1bit

.srregs	cmp.w	#11,d0
	bgt.b	.ittregs
	or.w	#$0800,d2
	move.l	#%1100011100100,d3
	move.w	EAD_type(a3),d1
	btst	#9,d2
	beq.b	.dest2
	move.w	EAD_type(a4),d1
.dest2	btst	d1,d3	;check address is ok
	beq.w	IllegalAddress
	bra.b	.ok1bit

.ittregs	btst	#8,d2
	bne.w	IllegalAddress	;not allowed in fd
	or.w	#$7000,d2
	asl.w	#2,d1
	or.w	d1,d2

.ok1bit	and.w	#1,d0
.ok	ror.w	#6,d0
	or.w	d0,d2
	move.w	d2,d3
	btst	#9,d2
	beq.w	PutSFCData
	or.w	EAD_cmd(a4),cw
	move.w	cw,(asa)+
	move.w	d3,(asa)+
	bra.w	PutDEADataX

.regtomem	moveq	#EV_DESTINATIONNEEDED,d1
	cmp.b	#',',(a0)+
	bne.w	AssemblePull
	move.w	d0,EAD_cmd(a3)
	move.w	d1,EAD_ext(a3)
	bsr.w	ReadEADest
	move.l	#%1100011111111,d1
	btst	d0,d1
	beq.w	IllegalAddress
	move.w	EAD_cmd(a3),d0
	move.w	EAD_ext(a3),d1
	or.w	#$0200,d2	;flag direction
	bra.w	.pmovmain

;flag fdtype
PMOVEFDTYPE	move.w	#$0100,d2
	bra.w	PMOVETYPEMain


;---- Get MMU register
;- Output:	d0	- type/-1 if not recognized
;-	d1	- bac/bad number
;----
GetPMOVERegs	cmp.b	#' ',(a0)+
	beq.b	GetPMOVERegs
	subq.w	#1,a0

	lea	PMOVETYPES(pc),a1
	move.b	(a0)+,d0
	beq.b	.error
	asl.w	#8,d0
	move.b	(a0)+,d0
	beq.b	.error
	and.w	#$dfdf,d0
.checkfirst	cmp.w	(a1),d0
	beq.b	.found
.next	addq.w	#8,a1
	tst.w	(a1)
	bne.b	.checkfirst
	subq.w	#2,a0	;fix read
	moveq	#-1,d0	;not found
	rts

.error	addq.w	#4,a7	;kill caller
	bra.w	UnexpectedEOL

.found	moveq	#0,d4
.checkrest	move.b	(a0,d4.w),d3
	move.b	2(a1,d4.w),d1
	cmp.b	#$20,d1
	beq.b	.exit
	cmp.b	#'9',d3
	ble.b	.nocasefix
	and.b	#$df,d3
.nocasefix	cmp.b	d1,d3
	bne.b	.next
	addq.w	#1,d4
	bra.b	.checkrest

.exit	add.w	d4,a0
	moveq	#0,d0
	move.b	6(a1),d0	;get type
	cmp.w	#12,d0
	blt.b	.nonumcheck
	moveq	#0,d1
	move.b	(a0)+,d1
	sub.b	#'0',d1
	bmi.b	.error
	cmp.b	#7,d1
	bgt.b	.error
.nonumcheck	moveq	#0,d4	;make !minus
	rts

;---- ptest	;mmu and '030 have different FC-sizes!
PTESTType	bsr.w	ReadEASource
	cmp.w	#dt2,d0
	bne.b	.weird
	move.w	EAD_cmd(a3),d0
	and.w	#%111,d0
	or.w	d0,cw
	bra.b	None

.weird	move.l	#%11<<dt13!1,d1
	btst	d0,d1
	beq.w	IllegalAddress
	move.w	#$8000,d3
	btst	#5,cw
	beq.b	.write
	bset	#9,d3
.write	move.w	#$f000,cw
	bsr.w	CheckFC
	move.w	d3,GetSDBuff(b)
	cmp.b	#',',(a0)+
	bne.b	IllegalAddress
	move.l	#%1100011100100,d0
	move.l	#1<<dt13,d1
	bsr.w	GetSD
	move.w	EAD_bd+2(a4),d0
	and.w	#%111,d0
	ror.w	#6,d0
	or.w	d0,GetSDBuff(b)
	moveq	#0,d3
	cmp.b	#',',(a0)+
	bne.b	.addan
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'a',d0
	bne.b	IllegalAddress
	move.b	(a0)+,d3
	moveq	#EV_ILLEGALREGNUM,d1
	sub.b	#'0',d3
	bmi.b	AssemblePull
	cmp.b	#7,d3
	bgt.b	AssemblePull
	or.w	#%1000,d3
	asl.w	#5,d3
.addan	or.w	GetSDBuff(b),d3
	bra.w	PutSFCData

;-- used by all functions without s/d
None	move.w	cw,(asa)+	;just put cw

AssembleExit	moveq	#EV_OK,d1	;return ok!

AssemblePull	move.l	asa,d0	;return current address
	Pull	d7/asa/a3/a4
	rts

AssemblePullP	addq.w	#4,a7	;used in GetSD->return error val from
	bra.b	AssemblePull	;getval

DataTooLargeP	addq.w	#4,a7
DataTooLarge	moveq	#EV_NUMBERTOOBIG,d1
	bra.b	AssemblePull

IllegalMnemonicP addq.w	#4,a7	;skip address on stack
IllegalMnemonic	moveq	#EV_ILLEGALMNEMONIC,d1;if unknown mnemonic name
	bra.b	AssemblePull

IllegalSizeP	addq.w	#4,a7	;skip address on stack
IllegalSize	moveq	#EV_ILLEGALSIZE,d1;if forced size (b/w/l) is illegal
	bra.b	AssemblePull

IllegalAddressP	addq.w	#4,a7	;skip address on stack
IllegalAddress	moveq	#EV_ILLEGALADDRESSINGMODE,d1;if illegal addressing mode
	bra.b	AssemblePull

UnexpectedEOL	moveq	#EV_UNEXPECTEDEOL,d1
	bra.b	AssemblePull

SyntaxErrorP	addq.w	#4,a7
SyntaxError	moveq	#EV_SYNTAXERROR,d1
	bra.b	AssemblePull

;---- Get bitfield
GetBitField	cmp.b	#'{',(a0)+
	bne.w	.error
	moveq	#0,d2
	move.b	(a0),d0	;find offset -type
	or.b	#$20,d0
	cmp.b	#'d',d0
	bne.b	.onumber
	bset	#11,d2	;mark datareg
	addq.w	#1,a0
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.b	.error
	cmp.b	#7,d0
	bgt.b	.error
.puto	asl.w	#6,d0
	or.w	d0,d2

	cmp.b	#':',(a0)+
	bne.b	.error
	move.b	(a0),d0	;find width-type
	or.b	#$20,d0
	cmp.b	#'d',d0
	bne.b	.wnumber
	bset	#5,d2	;mark datareg
	addq.w	#1,a0
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.b	.error
	cmp.b	#7,d0
	bgt.b	.error
	bra.b	.fix

.wnumber	grcall	GetValueCall	;get value
	bmi.b	.errorx
	cmp.w	#1,d0	;check correct number
	blt.b	.error
	cmp.w	#32,d0
	bgt.b	.error
	bne.b	.fix
	moveq	#0,d0
.fix	or.w	d2,d0
	cmp.b	#'}',(a0)+	;{}
	bne.b	.error
	rts

.onumber	grcall	GetValueCall	;get value
	bmi.b	.errorx
	tst.w	d0	;check correct number
	bmi.b	.error
	cmp.w	#31,d0
	bgt.b	.error
	bra.b	.puto

.error	moveq	#EV_ILLEGALBITFIELD,d1
.errorx	addq.w	#4,a7
	bra.w	AssemblePull


;---- Get FPU cc type and size
;-- Input:	a0	- inputstring
;-- Output:	d0	- type
;--	d7	- size
;----
Getfcc	move.l	a2,-(a7)
	moveq	#3,d2
.loop	move.b	(a1)+,d0	;get cc
	or.b	#$20,d0
	cmp.b	#'a',d0
	blt.b	.oops
	cmp.b	#'z',d0
	bgt.b	.oops
	asl.l	#8,d1
	move.b	d0,d1
	dbra	d2,.loop
	bra.b	.ok

.oops	subq.w	#1,a1	;correct read
.fill	asl.l	#8,d1	;fill with spaces
	move.b	#$20,d1
	dbra	d2,.fill
.ok	lea	fccTypes(pc),a2
	moveq	#32-1,d0
.compareloop	cmp.l	(a2)+,d1
	beq.b	.found
	addq.w	#2,a2	;skip bits
	dbra	d0,.compareloop
	bra.b	GetccError

.found	move.w	(a2),d0
	bra.b	ccCheckSize

;---- Get PMMU cc type and size
;-- Input:	a0	- pointer to input string
;-- Output:	a0	- new pointer
;--	d0	- cc type (6 bit, %000000-%001111)
;--	d7	- size
;----
Getpcc	Push	a2
	lea	pccTypes(pc),a2	;scan list for cc types
	move.b	(a1)+,d0
	asl.w	#8,d0
	move.b	(a1)+,d0
	or.w	#$2020,d0
	moveq	#16-1,d1
.findcc	cmp.w	(a2)+,d0
	beq.b	.found
	dbra	d1,.findcc
	bra.b	GetccError

.found	moveq	#16-1,d0	;calculate type
	sub.w	d1,d0
ccCheckSize	rem
	move.w	#$8001,d7	;default=w
	cmp.b	#'.',(a0)	;and check for size
	bne.b	.gettingsize
	addq.w	#1,a0
	move.b	(a0)+,d1
	or.b	#$20,d1
	cmp.b	#'w',d1
	beq.b	.gettingsize
	moveq	#%10,d7
	cmp.b	#'l',d1
	beq.b	.gettingsize
	moveq	#0,d7
	cmp.b	#'b',d1
	beq.b	.gettingsize
	addq	#8,a7	;correct stack before quitting
	bra.w	IllegalSize
	erem
.gettingsize	Pull	a2
	rts

;---- Get cc type and size
;-- Input:	A0	- Pointer to input string
;-- Output:	A0	- New pointer
;--	D1	- cc Type (0-15)
;--	D7	- size
;--	d2	- 0 if 0/1=f/t of 1 if 0/1 =ra/sr
;----
Getcc	Push	a2
	moveq	#0,d2
	move.b	(a1)+,d0
	beq.b	GetccErrorEOL
	moveq	#0,d1	;set type =T
	or.b	#$20,d0
	cmp.b	#'t',d0
	beq.b	GetccFound
	moveq	#1,d1	;set type =F
	cmp.b	#'f',d0
	beq.b	GetccFound
	asl.w	#8,d0
	move.b	(a1)+,d0
	beq.b	GetccErrorEOL
	or.b	#$20,d0
	lea	ccTypes(pc),a2
	moveq	#0,d1	;start from BRA
.findcc	cmp.w	(a2)+,d0
	beq.b	.checktyp
	addq.w	#1,d1	;check next 14 types
	cmp.w	#$10,d1
	bne.b	.findcc
	bra.b	GetccError

.checktyp	cmp.w	#1,d1
	bgt.b	GetccFound
	moveq	#1,d2	;only flag if bra/bsr

GetccFound
	rem		;why is this implemented?
			;supported in mnem-reader!!!!!!
	moveq	#0,d7	;set def size to byte
	cmp.b	#'.',(a0)
	bne.b	GetccExit
	addq.w	#1,a0
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'b',d0
	beq.b	GetccExit	;check size .b
	moveq	#1,d7	;set size=1
	cmp.b	#'w',d0
	beq.b	GetccExit
	moveq	#2,d7
	cmp.b	#'l',d0	;check long (see above!)
	bne.b	GetccZError
	erem

GetccExit	asl.w	#8,d1	;put type in right pos
	Pull	a2
	rts

GetccError	addq.w	#8,a7	;unknown menmonic (pull A2 AND old PC)
	moveq	#EV_ILLEGALCC,d1
	bra.w	AssemblePull

GetccZError	addq.w	#8,a7	;size error! (pull A2 AND old PC)
	bra.w	IllegalSize

GetccErrorEOL	addq.w	#8,a7	;unexpected EOL (pull A2 AND old PC)
	bra.w	UnexpectedEOL

;---- fixed ---- start --------------------------------------------------------
PutDEADataX	pea	AssembleExit(pc)
PutDEAData	lea	EADataD(b),a3
	bra.b	PutEAData

PutSEADataX	pea	AssembleExit(pc)
PutSEAData	lea	EADataS(b),a3
	bra.b	PutEAData

;---- no code between this and PutSEAData!
FastPutSEA	pea	AssembleExit(pc);and last data if any...
FastPutSEANX	move.w	cw,(asa)+	;store cw

;---- Put needed data to (asa) according to EA-type
;-- Input:	d0	- EA type
;--	d7	- size if type = #xxxx
;----
PutEAData	move.w	EAD_type(a3),d0	;get type
	cmp.w	#dt5,d0	;check for types, that only need ext/w
	beq.b	.PutWord
	cmp.w	#dt6,d0
	beq.b	.PutExt
	cmp.w	#dt8,d0
	beq.b	.PutWord
	cmp.w	#dt9,d0
	beq.b	.PutExt
	cmp.w	#dt14,d0
	beq.b	.PutExt
	cmp.w	#dt7,d0
	beq.b	.PutComplex
	cmp.w	#dt10,d0
	beq.b	.PutComplex
	cmp.w	#dt11,d0
	bne.b	.checklong
.PutWord	move.w	EAD_bd+2(a3),(asa)+;put word
	rts

.checklong	cmp.w	#dt12,d0
	bne.b	.checkimm
.PutLong	move.l	EAD_bd(a3),(asa)+;put long
.exit	rts

.checkimm	cmp.b	#dt13,d0
	bne.b	.exit
	btst	#14,d7
	bne.b	.extra
	cmp.b	#%10,d7	;long
	beq.b	.PutLong
	bra.b	.PutWord

.extra	cmp.b	#%001,d7
	ble.b	.PutLong
	cmp.b	#%100,d7
	beq.b	.PutWord
	cmp.b	#%110,d7
	beq.b	.PutWord
	cmp.b	#%101,d7	;double
	beq.b	.PutDouble
	move.l	EAD_extra(a3),(asa)+
.PutDouble	move.l	EAD_bd(a3),(asa)+
	move.l	EAD_od(a3),(asa)+
	rts



.PutComplex	move.w	EAD_ext(a3),d0
	btst	#8,d0
	bne.b	.checkbdod	;only scale special
.PutExt	move.w	EAD_ext(a3),(asa)+
	rts

.checkbdod	move.w	d0,(asa)+	;store bd data if any
	btst	#5,d0
	beq.b	.nobd
	move.l	EAD_bd(a3),d1
	btst	#4,d0
	beq.b	.bdword
	move.l	d1,(asa)+
	bra.b	.nobd
.bdword	move.w	d1,(asa)+

.nobd	btst	#1,d0	;store od data if any
	beq.b	.nood
	move.l	EAD_od(a3),d1
	btst	#0,d0
	beq.b	.odword
	move.l	d1,(asa)+
.nood	rts

.odword	move.w	d1,(asa)+
	rts

;---- Get source and destination
;-- Input:	d0	- Allowed sources
;--	d1	- Allowed dests
;-- Output:	In EADataS and EADataD structures
;--	d0	- Source-type
;--	d1	- Dest-type
;----
GetSD:	move.l	d0,SourceMask(b);store masks
	move.l	d1,DestMask(b)
	bsr.w	ReadEASource	;get source
	bmi.w	AssemblePullP
	move.l	SourceMask(b),d2
	btst	d0,d2	;check if allowed
	bne.b	.checkcc1
	move.l	a0,-(a7)
	lea	EADataS(b),a0
	bsr.b	.CheckCCOffset
	move.l	(a7)+,a0
.checkcc1	move.l	DestMask(b),d0
	beq.b	.nodest
	moveq	#EV_DESTINATIONNEEDED,d1
	cmp.b	#',',(a0)	;check separator
	beq.b	.getdest
	btst	#dt23,d0	;if none, check if legal (shift)
	beq.w	AssemblePullP
	bra.b	.nodest

.getdest	addq.w	#1,a0
	bsr.b	ReadEADest	;get dest
	bmi.w	AssemblePullP
	move.l	DestMask(b),d2	;check if allowed
	btst	d0,d2
	bne.b	.checkcc2
	move.l	a0,-(a7)
	lea	EADataD(b),a0
	bsr.b	.CheckCCOffset
	move.l	(a7)+,a0
.checkcc2	move.w	d0,d1
.nodest	move.w	EAD_type+EADataS(b),d0
	move.w	ForcedSize(b),d7;old code needs size in d7
	rts

.CheckCCOffset	btst	#dt22,d2
	beq.b	.fail
	cmp.b	#dt12,d0
	beq.b	.ok
	cmp.b	#dt11,d0
	beq.b	.ok
.fail	addq.w	#8,a7	;if not absolute, exit with illegaladd
	bra.w	IllegalAddressP
.ok	move.l	EAD_bd(a0),d0
	subq.l	#2,d0
	sub.l	asa,d0	;find pc-relative offset
	move.l	d0,EAD_bd(a0)
	bsr.w	CheckSize	;and figure size
	move.b	d0,EAD_bds(a0)
	rts

;---- Read Effective Address from (a0)
;-- Input:	a0	- Input
;-- Output:	a0	- Pointer to first unknown
;--	d0	- type
;--	d1	- 0=ok, else error number
;--	EAField	- data for type
;----
ReadEAStack	reg	d2-d7/a2

ReadEADest	Push	ReadEAStack
	lea	EADataD(b),a2
	bra.b	ReadEAEntry

ReadEASource	Push	ReadEAStack
	lea	EADataS(b),a2
ReadEAEntry
.fixspaces	cmp.b	#' ',(a0)
	bne.b	.clearspaces
	addq.w	#1,a0
	tst.b	(a0)
	bne.b	.fixspaces
	moveq	#dt23,d7
	bra.w	ReadEAExit

.clearspaces	clr.l	EAD_bd(a2)	;clear for (0)(An,Xn)
	st.b	EAD_bds(a2)	;mark to ID use (prevent d(d,pc))
	move.b	(a0)+,d0
	cmp.b	#'#',d0
	beq.w	EAImmediate
	cmp.b	#'(',d0
	beq.w	EALeftPar
	cmp.b	#'-',d0
	beq.w	EACheckPreDec
	move.b	d0,d1
	or.b	#$20,d1
	cmp.b	#'a',d1
	blt.w	EACheckValue
	cmp.b	#'z',d1
	bgt.w	EACheckValue

;---- Check register names
	moveq	#0,d0
	move.b	(a0)+,d0
	moveq	#0,d7	;set type=Dn
	cmp.b	#'d',d1	;check Dn
	bne.b	.CheckDn
	moveq	#0,d6	;no bits for Dn
.CheckNumber	cmp.b	#'-',(a0)	;check for multiple register-type
	beq.w	CheckMultiple
	cmp.b	#'/',(a0)
	beq.w	CheckMultiple

	cmp.b	#'0',d0	;check number 0-7
	blt.w	.CheckRegs
	cmp.b	#'7',d0
	bgt.w	.CheckRegs
	sub.b	#'0',d0
	or.b	d6,d0
	move.w	d0,(a2)	;EAD_cmd

	tst.w	d6	;if Dn check for :Dm
	bne.w	ReadEAExit

	cmp.b	#':',(a0)
	bne.w	ReadEAExit
	addq.w	#1,a0	;Dn:Dm
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'d',d0
	bne.w	ReadEAErrorS
	moveq	#EV_ILLEGALREGNUM,d1
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.w	ReadEAError
	cmp.b	#7,d0
	bgt.w	ReadEAError
	moveq	#dt24,d7
	move.w	d0,EAD_ext(a2)	;write secondary to ext
	bra.w	ReadEAExit

.CheckDn	moveq	#1,d7	;set type=An
	moveq	#%001000,d6	;pattern for An
	cmp.b	#'a',d1	;check An
	beq.b	.CheckNumber

	cmp.b	#'f',d1	;check FPx
	bne.b	.CheckRegs
	move.b	d0,d2
	or.b	#$20,d2
	cmp.b	#'p',d2
	bne.b	.CheckRegs
	moveq	#0,d2
	move.b	(a0),d2
	sub.b	#'0',d2	;check number 0-7
	blt.b	.CheckRegs
	cmp.b	#7,d2
	bgt.b	.CheckRegs
	addq.w	#1,a0
	move.w	d2,EAD_cmd(a2)
	moveq	#dt29,d7
	move.b	(a0),d0
	cmp.b	#'-',d0
	beq.w	FPUMultiple
	cmp.b	#'/',d0
	beq.w	FPUMultiple
	cmp.b	#':',d0	;check FPc:FPs
	bne.w	ReadEAExit
	addq.w	#1,a0
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0)+,d0
	or.w	#$2020,d0
	cmp.w	#'fp',d0
	bne.b	.unknown
	moveq	#0,d0
	move.b	(a0)+,d0
	sub.w	#'0',d0
	bmi.b	.unknown
	cmp.w	#7,d0
	bgt.b	.unknown
	moveq	#dt30,d7
	move.w	d0,EAD_ext(a2)
	bra.w	ReadEAExit

.CheckRegs	lea	EARegList(pc),a1
	moveq	#~$20,d5
	and.w	d5,d1
.CheckRegsLoop	cmp.b	(a1),d1	;check first letter
	beq.b	.CheckRegsRest
.CheckNextReg	addq.w	#8,a1
	tst.b	(a1)
	bne.b	.CheckRegsLoop
.unknown	moveq	#EV_UNKNOWNDATATYPE,d1
	bra.w	ReadEAError

.CheckRegsRest	moveq	#0,d2	;check rest of registername
.CheckRegsLoop2	addq.w	#1,d2
	move.b	(a1,d2.w),d4
	cmp.b	#$20,d4	;space ends
	beq.b	.RegFound
	move.b	-2(a0,d2.w),d3
	cmp.b	#'0',d3
	blt.b	.CheckNextReg
	cmp.b	#'9',d3
	ble.b	.nofix
	and.b	d5,d3	;fix case
.nofix	cmp.b	d3,d4
	bne.b	.CheckNextReg
	bra.b	.CheckRegsLoop2

.RegFound	subq.w	#2,d2
	add.w	d2,a0
	moveq	#dt14,d7	;set type = register
	clr.w	EAD_ext(a2)	;fix for FPUCR
	move.w	6(a1),d0
	bpl.b	.checkingfpucr;if negative, fpucr -> check for multiple
	move.w	#'fc',EAD_cmd(a2);mark FPUCR
.checkfpucrloop	and.w	#%111,d0
	ror.w	#6,d0
	or.w	d0,EAD_ext(a2)
	cmp.b	#'/',(a0)	;check for more regs
	bne.b	ReadEAExit
	addq.w	#1,a0
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0)+,d0
	or.w	#$2020,d0
	cmp.w	#'fp',d0
	bne.b	.unknown
	lea	FPUCRegs(pc),a1
	moveq	#0,d0
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0)+,d0
	and.w	#$dfdf,d0
	cmp.w	2(a1),d0
	beq.b	.regok
	addq.w	#8,a1
	cmp.w	2(a1),d0
	beq.b	.regok
	swap	d0
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	#$20,d0
	and.w	#$dfff,d0
	addq.w	#8,a1
	cmp.l	2(a1),d0
	bne.w	.unknown
.regok	move.w	6(a1),d0
	move.w	#'fm',EAD_cmd(a2);mark multiple cr-regs
	bra.b	.checkfpucrloop

.checkingfpucr	move.w	d0,EAD_ext(a2);put data
	cmp.w	#$0800,d0
	bge.b	ReadEAExit
	cmp.w	#$0010,d0
	blt.b	ReadEAExit
	move.w	d0,d7	;if $10< REG < $800 use as type!
;	bra.b	ReadEAExit

ReadEAExit	move.l	d7,d0
	move.w	d0,EAD_type(a2)
	Pull	ReadEAStack
	moveq	#0,d1
	rts

ReadEAErrorN	moveq	#EV_NUMBERTOOBIG,d1
	bra.b	ReadEAError

ReadEAErrorS	moveq	#EV_SYNTAXERROR,d1
ReadEAError	Pull	ReadEAStack
	tst.w	d1
	rts

;---- check fmovem-type
FPUMultiple	subq.w	#3,a0	;correct pre-fetch
	moveq	#0,d2
.CheckMulLoop	bsr.b	.GetNum	;get number (D0=0,A7=15)
	bset	d3,d2
.CheckEA94	move.b	(a0)+,d0	;more regs?
	cmp.b	#'/',d0	;get single if /
	beq.b	.CheckMulLoop
	cmp.b	#'-',d0	;if not -, exit
	bne.b	.multipleexit
	move.w	d3,d6	;else save old value
	bsr.b	.GetNum	;and get new
	moveq	#EV_WRONGREGORDER,d1
	cmp.w	d6,d3	;if prev>curr
	bmi.b	ReadEAError	;error
.CheckEA96	bset	d6,d2	;set flag
	cmp.w	d6,d3	;prev=curr?
	beq.b	.CheckEA94	;if yes, check for more regs
	addq.w	#1,d6	;else inc prev
	bra.b	.CheckEA96	;and set next flag

.multipleexit	subq.w	#1,a0
	move.w	d2,EAD_ext(a2)	;store in ext-word
	moveq	#dt31,d7	;multipleregs-type
	bra.b	ReadEAExit

;return number for fmovem-type fp0=0,fp7=7
.GetNum	moveq	#EV_UNKNOWNDATATYPE,d1
	moveq	#0,d3	;set number-base
	move.b	(a0)+,d0
	asl.w	#8,d0
	move.b	(a0)+,d0
	or.w	#$2020,d0
	cmp.w	#'fp',d0
	bne.b	.GetNumE
	moveq	#EV_ILLEGALREGNUM,d1
	move.b	(a0)+,d3	;get value
	sub.b	#'0',d3
	bmi.b	.GetNumE
	cmp.b	#7,d3
	bgt.b	.GetNumE
	rts

.GetNumE	addq.w	#4,a7	;skip caller and exit
	bra.b	ReadEAError

;---- check movem-type
CheckMultiple	subq.w	#2,a0	;correct pre-fetch
	moveq	#0,d2
.CheckMulLoop	bsr.b	.GetNum	;get number (D0=0,A7=15)
	bset	d3,d2
.CheckEA94	move.b	(a0)+,d0	;more regs?
	cmp.b	#'/',d0	;get single if /
	beq.b	.CheckMulLoop
	cmp.b	#'-',d0	;if not -, exit
	bne.b	.multipleexit
	move.w	d3,d6	;else save old value
	bsr.b	.GetNum	;and get new
	moveq	#EV_WRONGREGORDER,d1
	cmp.w	d6,d3	;if prev>curr
	bmi.w	ReadEAError	;error
.CheckEA96	bset	d6,d2	;set flag
	cmp.w	d6,d3	;prev=curr?
	beq.b	.CheckEA94	;if yes, check for more regs
	addq.w	#1,d6	;else inc prev
	bra.b	.CheckEA96	;and set next flag

.multipleexit	subq.w	#1,a0
	move.w	d2,EAD_ext(a2)	;store in ext-word
	moveq	#dt21,d7	;multipleregs-type
	bra.w	ReadEAExit

;return number for movem-type D0=0,A7=15
.GetNum	moveq	#EV_UNKNOWNDATATYPE,d1
	moveq	#0,d3	;set number-base
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'d',d0	;according to type (0 if Dn)
	beq.b	.doff
	moveq	#8,d3
	cmp.b	#'a',d0	;8 if An
	bne.b	.GetNumE
.doff	moveq	#EV_ILLEGALREGNUM,d1
	move.b	(a0)+,d0	;get value
	sub.b	#'0',d0
	bmi.b	.GetNumE
	cmp.b	#7,d0
	bgt.b	.GetNumE
	add.b	d0,d3	;and add to get number
	rts

.GetNumE	addq.w	#4,a7	;skip caller and exit
	bra.w	ReadEAError

;---- Get register number (0-7) or jump to error-handler (number to d0)
GetRegNum	moveq	#0,d0	;get n to d0
	move.b	(a0)+,d0
	sub.w	#'0',d0
	bmi.b	.Error
	cmp.w	#7,d0
	bgt.b	.Error
	rts

.Error	addq.w	#4,a7	;skip caller
	moveq	#EV_ILLEGALREGNUM,d1
	bra.w	ReadEAError

;---- Get index register with size and scale
GetIndex	moveq	#0,d5
	moveq	#EV_ILLEGALINDEX,d1
	move.b	(a0)+,d0
	or.b	#$20,d0
	move.w	#$0800,d5	;check Xn type and number (.l default)
	cmp.b	#'d',d0
	beq.b	.data
	move.w	#$8800,d5
	cmp.b	#'a',d0
	bne.b	GIError
.data	moveq	#EV_ILLEGALREGNUM,d1
	moveq	#0,d0	;get n to d0
	move.b	(a0)+,d0
	sub.w	#'0',d0
	bmi.b	GIError
	cmp.w	#7,d0
	bgt.b	GIError
	ror.w	#4,d0
	or.w	d0,d5
	cmp.b	#'.',(a0)	;check userdefined size
	bne.b	GIcheckscale
	addq.w	#1,a0
CheckSizeScale	moveq	#EV_ILLEGALSIZE,d1
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'l',d0	;if W the bit is correct
	beq.b	GIcheckscale
	cmp.b	#'w',d0
	bne.b	GIError
	bclr	#11,d5	;change Xn size to long
GIcheckscale	cmp.b	#'*',(a0)	;check scale
	bne.b	GIcheckend
	addq.w	#1,a0
CheckScale	moveq	#EV_INVALIDSCALE,d1
	move.b	(a0)+,d0
	sub.b	#'1',d0	;check 1
	bmi.b	GIError
	cmp.b	#1,d0	;check 1+2
	ble.b	.ok
	subq.b	#1,d0	;check 4
	cmp.b	#2,d0
	beq.b	.ok
	cmp.b	#6,d0	;check 8
	bne.b	GIError
	moveq	#3,d0
.ok	add.w	d0,d0	;roll to bit 9-10
	asl.w	#8,d0	;and or the scale size
	or.w	d0,d5

GIcheckend	rts

GIError	addq.w	#4,a7	;skip caller
	bra.w	ReadEAError

;---- Check offset size (and forced size)
;-- Input:	d0	-	offset
;-- Output:	d0	-	size (0/1/2 = b/w/l)
;----
;-- Clears caller from stack and jumps to error-routine if wrong size-letter
;----
GetBDSize	moveq	#3,d0	;set def size to >long, and flag def
	cmp.b	#'.',(a0)	;check forced size
	bne.b	.COSExitC
	move.w	d1,d2	;check if number fits in forced size
	moveq	#0,d0
	addq.w	#1,a0
	move.b	(a0)+,d1
	or.b	#$20,d1
	cmp.b	#'b',d1
	beq.b	.COSExitC
	moveq	#1,d0	;check word
	cmp.b	#'w',d1
	beq.b	.COSExitC
	moveq	#2,d0	;check long
	cmp.b	#'l',d1
	beq.b	.COSExitC
	moveq	#EV_ILLEGALSIZE,d1
	addq.w	#4,a7	;clear caller from stack
	bra.w	ReadEAError	;and blow the horn

.COSExitC	move.b	d0,ForcedBDS(b)
	rts

;---- Check size (b-l)
CheckSize	moveq	#2,d1	;start with long
	swap	d0
	move.w	#$ff00,d2
	tst.w	d0
	bmi.b	.testminus
	bne.b	.checked	;if hi-word used->long
	swap	d0
	moveq	#1,d1	;word
	and.w	d2,d0
	bne.b	.checked
	moveq	#0,d1	;use byte
	bra.b	.checked

.testminus	not.w	d0
	bne.b	.checked	;if l-bits used, continue
	swap	d0
	tst.w	d0
	bpl.b	.checked	;if .w not neg, long needed
	moveq	#1,d1	;set word
	tst.b	d0
	bpl.b	.checked	;if .b not neg, .w needed
	and.w	d2,d0	;else check if .w bits are used
	cmp.w	d2,d0
	bne.b	.checked	;w-bits->word
	moveq	#0,d1	;else byte

.checked	move.l	d1,d0	;return size in D0
	rts

;---- OR bd-size to d5, store in ext and return
AddBDSize	moveq	#0,d0
	move.b	EAD_bds(a2),d0
	bpl.b	.checkbyte
	or.w	#%010000,d5	;no bd
	bra.b	.done

.checkbyte	bne.b	.byte
	moveq	#1,d0
.byte
	move.b	ForcedBDS(b),d1	;check forced size
	cmp.b	#3,d1
	beq.b	.autook
	move.b	d1,d0

.autook	addq.w	#1,d0
	asl.w	#4,d0
	or.b	d0,d5	;or bd size
.done	move.w	d5,EAD_ext(a2)
	bra.w	ReadEAExit

;---- Check value
EACheckValue	subq.w	#1,a0	;fix prefetch
	grcall	GetValueCall	;get value
	bmi.w	ReadEAError
	move.l	d0,EAD_bd(a2)
	bsr.b	CheckSize
	move.b	d0,EAD_bds(a2)
	bsr.w	GetBDSize	;no check - depends on pc/abs

	moveq	#0,d3
	cmp.b	#'(',(a0)+
	beq.w	EALeftPar
	subq.w	#1,a0

EAAbsolute	moveq	#EV_ILLEGALSIZE,d1
	move.b	ForcedBDS(b),d2
	beq.w	ReadEAError	;(xxxx).b not allowed
	moveq	#1,d0
	tst.w	EAD_bd(a2)
	beq.b	.bdisword	;is word if top=0!
	moveq	#2,d0
	cmp.b	d0,d2
	bmi.w	ReadEAErrorN	;error if forced>auto
.bdisword	cmp.b	#3,d2
	beq.b	.useauto
	move.b	d2,d0

.useauto	move.w	#%111000,EAD_cmd(a2)
	moveq	#dt11,d7	;set (xxxx).w
	cmp.b	#1,d0
	ble.w	ReadEAExit	;le also gets 0 (=.b)
	move.w	#%111001,EAD_cmd(a2)
	moveq	#dt12,d7	;set (xxxx).l
	bra.w	ReadEAExit

;---- check immediate
EAImmediate	move.w	#%111100,EAD_cmd(a2);set imm datatype
	btst	#14,d7
	bne.b	.checkgross
	move.b	ForcedSize+1(b),d7;get forced size
.immmax32	grcall	GetValueCall	;get immediate address
	bmi.w	ReadEAError
	move.l	d0,EAD_bd(a2)
	bsr.w	CheckSize
	move.b	d0,EAD_bds(a2)
	cmp.b	d7,d0
	bhi.w	ReadEAErrorN	;check if data is too big
	moveq	#dt13,d7	;check imm-size for moveq,addq etc
	bra.w	ReadEAExit

;check .s.d.x.p types
.checkgross	moveq	#24,d0	;get 3 longs (x+p)
	move.b	#%100,EAD_bds(a2)
	cmp.b	#%010,d7
	beq.b	.getgross
	cmp.b	#%011,d7
	beq.b	.getgross
	move.b	#%11,EAD_bds(a2)
	moveq	#16,d0	;get 2 longs (d)
	cmp.b	#%101,d7
	beq.b	.getgross
	move.l	a0,-(a7)
	and.w	#%1111,d7
	lea	SizeTable2(pc),a0
	move.b	(a0,d7.w),d7	;get .x size converted to 0/1/2
	move.l	(a7)+,a0
	bra.b	.immmax32

.getgross	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	cmp.b	#'$',(a0)
	bne.b	.noinit
	addq.w	#1,a0
.noinit	move.w	d4,-(a7)
.getgrossloop	move.b	(a0)+,d4
	cmp.b	#'0',d4
	blt.b	.gotten
	cmp.b	#'9',d4
	ble.b	.number
	or.b	#$20,d4
	cmp.b	#'a',d4
	blt.b	.gotten
	cmp.b	#'f',d4
	bgt.b	.gotten
	sub.b	#'a'-10-'0',d4
.number	sub.b	#'0',d4
	moveq	#3,d7	;roll 4 bits
.rollem	asl.l	#1,d3
	roxl.l	#1,d2
	roxl.l	#1,d1
	dbra	d7,.rollem
	or.b	d4,d3
	subq.w	#1,d0
	tst.w	d0
	bpl.b	.getgrossloop
	move.w	(a7)+,d4
	bra.w	ReadEAErrorN

.gotten	subq.w	#1,a0
	move.l	d1,EAD_extra(a2)
	move.l	d2,EAD_bd(a2)
	move.l	d3,EAD_od(a2)
	moveq	#dt13,d7
	move.w	(a7)+,d4
	bra.w	ReadEAExit

;---- check pre-decrement
EACheckPreDec	cmp.b	#'(',(a0)
	bne.w	EACheckValue
	addq.w	#1,a0
	moveq	#EV_ILLEGALADDRESSINGMODE,d1
	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'a',d0
	bne.w	ReadEAError
	moveq	#EV_ILLEGALREGNUM,d1
	moveq	#0,d0
	move.b	(a0)+,d0
	sub.b	#'0',d0
	bmi.w	ReadEAError
	cmp.b	#7,d0
	bgt.w	ReadEAError
	or.b	#%100000,d0
	cmp.b	#')',(a0)+
	bne.w	ReadEAErrorS
	move.w	d0,EAD_cmd(a2)
	moveq	#4,d7
	bra.w	ReadEAExit

;---- head of main check
;-- b '(all modes)'
EALeftPar	move.b	(a0)+,d0
	cmp.b	#'[',d0	;quick check for start of ([ EA
	beq.w	EALeftSquare
	moveq	#0,d3	;flag offset outside par
.checkaddpc	move.b	d0,d1
	or.b	#$20,d1
	cmp.b	#'a',d1	;check (An
	beq.b	EACheckAddress
	cmp.b	#'d',d1
	beq.w	EACheckData	;check (Dn !
	cmp.b	#'p',d1	;check (pc
	beq.w	EACheckPC
	cmp.b	#'z',d1	;check zpc
	beq.w	EACheckZPC
	moveq	#EV_ONLYONEBDALLOWED,d1
	tst.b	EAD_bds(a2)
	bpl.w	ReadEAError	;fail if bd used
	subq.w	#1,a0	;else one back
	grcall	GetValueCall	;and get offset
	bmi.w	ReadEAError
	move.l	d0,EAD_bd(a2)
	bsr.w	CheckSize	;+size
	move.b	d0,EAD_bds(a2)
	bsr.w	GetBDSize	;no check here! depends on pc/abs!

	move.b	(a0)+,d0
	cmp.b	#',',d0	;check for (d,
	bne.b	.checkabsolute
	move.b	(a0)+,d0
	moveq	#1,d3	;flag offset inside par!
	bra.b	.checkaddpc

;-- b '(xxxx).s'
.checkabsolute	cmp.b	#')',d0	;check (xxxx).s
	bne.w	ReadEAErrorS
	bsr.w	GetBDSize
	bra.w	EAAbsolute

;-- e '(xxxx).s'
EACheckAddress	bsr.w	GetRegNum	;check (An
	move.w	d0,d6
	move.b	(a0)+,d0
	cmp.b	#')',d0
	bne.b	.CheckExt	;(allow (An,Xn))
	move.b	EAD_bds(a2),d0
	bpl.b	.CheckComplex	;if bd, check d(An)
	moveq	#%010000,d2	;data for (An)
	moveq	#dt2,d7
	cmp.b	#'+',(a0)	;check (An)+
	bne.b	.simple
	addq.w	#1,a0
	moveq	#%011000,d2	;data for (An)+
	moveq	#dt3,d7
.simple	or.w	d6,d2
	move.w	d2,EAD_cmd(a2)
	bra.w	ReadEAExit

.CheckComplex	moveq	#EV_ILLEGALADDRESSINGMODE,d1
	cmp.b	#2,d0	;check d(An) NOT d32
	beq.w	ReadEAError
	moveq	#%101000,d2
	moveq	#5,d7
	bra.b	.simple

.CheckExt	move.w	d6,d5	;prepare for funny modes
	ror.w	#4,d5
	and.w	#$f000,d5
	or.w	#$8980,d5

	cmp.b	#'.',d0	;check (An.s*sc)
	bne.b	.checksize
	bsr.w	CheckSizeScale
.done	move.b	(a0)+,d0
	cmp.b	#')',d0
	beq.w	AddBDSize
	bra.w	ReadEAErrorS

.checksize	cmp.b	#'*',d0
	bne.b	.checkscale
	bsr.w	CheckScale
	bra.b	.done

.checkscale	cmp.b	#',',d0	;check (An,Xn.s*sc)
	bne.w	ReadEAErrorS	;(An.s,Xn will be accepted!, but .w ignored)
	or.w	#%110000,d6
	move.w	d6,EAD_cmd(a2)

	bsr.w	GetIndex

	move.b	(a0)+,d0	;check end )
	cmp.b	#')',d0
	bne.w	ReadEAErrorS

	move.b	ForcedBDS(b),d0
	cmp.b	#3,d0
	bne.b	.getautosize
	move.b	EAD_bds(a2),d0	;if no offset, size=b
.getautosize	tst.b	d0
	bmi.b	.byteoffset
	bne.b	.longoffset
.byteoffset	moveq	#6,d7
	move.b	EAD_bd+3(a2),d5	;put the 8 offset bits in the word
	move.w	d5,d0
	and.w	#%11000000000,d0
	beq.b	.simplecpu
.addressexit	moveq	#7,d7	;set '020+ mode
.simplecpu	move.w	d5,EAD_ext(a2)	;write word
	bra.w	ReadEAExit	;and return

.longoffset	bset	#8,d5	;set ext bit
	move.b	EAD_bds(a2),d0
	bne.b	.bytetoword
	moveq	#1,d0
.bytetoword	addq.b	#1,d0	;change size-type
	asl.b	#4,d0
	or.b	d0,d5	;and put in word
	bra.b	.addressexit

;---- check d(Dn,...
EACheckData	subq.w	#1,a0
	bsr.w	GetIndex
	cmp.b	#')',(a0)+
	bne.w	ReadEAErrorS
	move.w	#%110000,EAD_cmd(a2);is this needed elsewhere?
	or.w	#$0180,d5
	moveq	#7,d7
	bra.w	AddBDSize

;---- Check ZPC
EACheckZPC	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'p',d0
	bne.w	ReadEAErrorS

	move.w	#$0080,d4	;suppress base-register (pc)
	bra.b	EACheckPCII

;---- Check (d,pc(,Xn.s*sc))
EACheckPC	moveq	#0,d4
EACheckPCII	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'c',d0
	bne.w	ReadEAErrorS
	tst.w	d4
	bne.b	.nodisplacement	;skip PC-calculation if ZPC
	tst.b	EAD_bds(a2)
	bmi.b	.nodisplacement
	move.w	#%111011,EAD_cmd(a2)
	move.l	EAD_bd(a2),d0	;get offset converted to PC-relative
	move.l	AssembleStart(b),d1
	addq.l	#2,d1
	sub.l	d1,d0
	move.l	d0,EAD_bd(a2)
	bsr.w	CheckSize
;	move.b	d0,EAD_bds(a2)
	move.b	ForcedBDS(b),d1
	cmp.b	d0,d1
	bmi.w	ReadEAErrorN	;fail if offset to big for forced size
	cmp.b	#3,d1
	beq.b	.setbdsize	;use auto if default
	move.b	d1,d0	;else use forced
.setbdsize	move.b	d0,EAD_bds(a2)
.nodisplacement	moveq	#10,d7	;set def to '020+ pc-type
	move.b	(a0)+,d0
	cmp.b	#',',d0	;check for index
	beq.b	.IndexedPC
	cmp.b	#')',d0
	bne.w	ReadEAErrorS
	move.w	#%0000000101110000,d2;set code for d32(pc)
	moveq	#EV_ILLEGALADDRESSINGMODE,d1
	move.b	EAD_bds(a2),d0	;fix byte offsets to word
	bmi.w	ReadEAError	;(pc) not allowed (but ([pc]) is!)
	bne.b	.bytetoword
	moveq	#1,d0
.bytetoword	cmp.b	#1,d0	;offset in word?
	bne.b	.putlongpc
	tst.w	d4
	bne.b	.checkzpc

	tst.w	d3	;check for (add.w,pc)
	bne.b	.PCSuppIndex

	move.w	#%111010,EAD_cmd(a2);set normal d16(pc)
	moveq	#dt8,d7
	bra.w	ReadEAExit

.PCSuppIndex	move.w	#%101100000,d5	;special for (add.w,pc)
	bra.w	AddBDSize

.checkzpc	bclr	#4,d2	;fix size to word

.putlongpc	bset	#8,d2
	or.w	d4,d2	;or (ZPC-flag)
	move.w	d2,EAD_ext(a2)	;set code for d32(pc)
	bra.w	ReadEAExit

.IndexedPC	bsr.w	GetIndex
	cmp.b	#')',(a0)+
	bne.w	ReadEAErrorS
	bset	#8,d5
	or.w	d4,d5	;or (ZPC-flag)
	tst.b	EAD_bds(a2)
	bne.w	AddBDSize	;if -/w/l store extra offset
	move.w	d5,d0	;check scale
	and.w	#%11000000000,d0
	bne.b	.complexcpu
	moveq	#dt9,d7	;if byte AND 0 scale set d8(pc,xn) type
.complexcpu	move.b	EAD_bd+3(a2),d5	;set d8 (takes care of ZPC-flag too)
.pcdone	bclr	#8,d5
	move.w	d5,EAD_ext(a2)
	bra.w	ReadEAExit

;---- Read ([
EALeftSquare	st.b	EAD_ods(a2)	;prepare for action!
	moveq	#EV_ILLEGALADDRESSINGMODE,d1
	tst.b	EAD_bds(a2)
	bpl.w	ReadEAError
	moveq	#-1,d5
.LeftStart	move.b	(a0)+,d0
.LeftStartII	cmp.b	#']',d0	;check for end ]
	bne.b	.NotEnded
	move.w	#%110000,EAD_cmd(a2)
	move.w	#$84,d4	;suppress base-reg
	move.b	(a0)+,d0
	moveq	#7,d7
	bra.w	EAReadEXTLoop

.NotEnded	or.b	#$20,d0
	cmp.b	#'d',d0
	beq.b	.Index
	cmp.b	#'a',d0
	bne.b	.checkAIndex
	move.b	1(a0),d1
	cmp.b	#',',d1	;if An, it must be basereg
	beq.w	.BaseRegister
	cmp.b	#'.',d1
	beq.b	.Index	;if forced size = index
	cmp.b	#'*',d1
	beq.b	.Index	;if scale = index
	bra.w	.BaseRegister	;if not index => base

.checkAIndex	moveq	#0,d4	;no suppress
	cmp.b	#'p',d0	;PC
	beq.b	.PCCheck
	move.w	#$80,d4	;suppress
	cmp.b	#'z',d0	;ZPC
	beq.b	.ZPCCheck

	moveq	#EV_ONLYONEBDALLOWED,d1
	tst.b	EAD_bds(a2)
	bpl.w	ReadEAError
	subq.w	#1,a0	;else one back
	grcall	GetValueCall	;and get offset
	bmi.w	ReadEAError
	move.l	d0,EAD_bd(a2)
	bsr.w	CheckSize	;+size
	addq.b	#1,d0
	cmp.b	#1,d0
	bne.b	.extraforbyte	;fix .b to .w
	addq.b	#1,d0
.extraforbyte	move.b	d0,EAD_bds(a2)
	bsr.w	GetBDSize	;get forced
	move.b	(a0)+,d0
	cmp.b	#',',d0
	beq.w	.LeftStart
	bra.w	.LeftStartII	;and run through again

.Index	subq.w	#1,a0
	bsr.w	GetIndex	;get index data
	moveq	#EV_ILLEGALADDRESSINGMODE,d1
	cmp.b	#']',(a0)+	;check end-square
	bne.w	ReadEAError
	move.w	#%110000,EAD_cmd(a2)
	move.w	#$80,d4	;suppress base register
	move.b	(a0)+,d0
	moveq	#7,d7
	bra.w	EAReadEXTLoop

.ZPCCheck	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'p',d0
	bne.w	ReadEAErrorS
.PCCheck	move.b	(a0)+,d0
	or.b	#$20,d0
	cmp.b	#'c',d0
	bne.w	ReadEAErrorS
	tst.b	EAD_bds(a2)
	bmi.b	.nobd
	move.l	EAD_bd(a2),d0
	tst.w	d4
	bne.b	.nopccalc	;skip pc-calculation if zpc
	sub.l	AssembleStart(b),d0
	subq.l	#2,d0
	move.l	d0,EAD_bd(a2)
.nopccalc	bsr.w	CheckSize
	move.b	ForcedBDS(b),d1
	cmp.b	d0,d1
	bmi.w	ReadEAErrorN
	cmp.b	#3,d1
	beq.b	.ok	;autosize if default
	move.b	d1,d0	;else set forced

.ok	addq.b	#1,d0
	cmp.b	#1,d0
	bne.b	.extraforbyte2	;fix .b to .w
	addq.b	#1,d0
.extraforbyte2	move.b	d0,EAD_bds(a2)
.nobd	move.w	#%111011,EAD_cmd(a2);set PC cmd
	moveq	#10,d7
	bra.b	EAReadEXT

.BaseRegister	bsr.w	GetRegNum
	or.w	#%110000,d0
	move.w	d0,EAD_cmd(a2)	;store base-register number
	moveq	#0,d4	;no basereg suppression
	moveq	#7,d7
;	bra.b	EAReadEXT

;---- Read extended modes of '020+
;-- Input: d4	- BRS if needed
;--	cmdtype in EAD_cmd
;----
EAReadEXT	moveq	#-1,d5	;if d5>0, index read
	or.w	#%100,d4	;flag postindexed
	move.b	(a0)+,d0
	cmp.b	#',',d0
	bne.b	.GetIndex
	bsr.w	GetIndex	;get index-data
	move.b	(a0)+,d0
	bclr	#2,d4	;clear postindexed
.GetIndex	moveq	#EV_ILLEGALADDRESSINGMODE,d1
	cmp.b	#']',d0
	bne.w	ReadEAError
	move.b	(a0)+,d0
EAReadEXTLoop	cmp.b	#')',d0
	beq.b	.BRReady
	cmp.b	#',',d0
	bne.w	ReadEAErrorS

	move.b	(a0),d0	;check for index
	or.b	#$20,d0
	cmp.b	#'a',d0
	beq.b	.Index
	cmp.b	#'d',d0
	beq.b	.Index
	moveq	#EV_ONLYONEODALLOWED,d1
	tst.b	EAD_ods(a2)	;if not index, get od (if not used)
	bpl.w	ReadEAError

	grcall	AssemGetValueC	;Special call. Will ignore last )
	bmi.w	ReadEAError

	move.l	d0,EAD_od(a2)
	bsr.w	CheckSize
	move.b	d0,EAD_ods(a2)
	bsr.w	GetBDSize	;use same code
	cmp.b	EAD_ods(a2),d0
	bmi.w	ReadEAErrorN

	cmp.b	#3,d0
	beq.b	.usedefault
	move.b	d0,EAD_ods(a2)	;set forced size (160194);;

.usedefault	move.b	(a0)+,d0
	cmp.b	#')',d0
	beq.b	.BRReady
	bra.b	EAReadEXTLoop

.Index	moveq	#EV_ONLYONEINDEX,d1
	tst.l	d5	;index already read?
	bpl.w	ReadEAError
	bsr.w	GetIndex
	move.b	(a0)+,d0
	bra.b	EAReadEXTLoop

.BRReady	tst.l	d5	;index register used?
	bpl.b	.used
	move.w	#%101000000,d5	;else set IRS
	bclr	#2,d4	;AND clear postindexed
.used	move.b	EAD_ods(a2),d0
	bpl.b	.checkbyte
	or.w	#%001,d5	;no od
	bra.b	.done

.checkbyte	bne.b	.byte
	moveq	#1,d0
.byte	addq.w	#1,d0
	or.b	d0,d5	;or od size
.done	or.w	d4,d5	;[or BRS-flag (BRS NOT set here!)]
	move.b	EAD_bds(a2),d0
	bpl.b	.ok
	moveq	#1,d0	;flag no bd
.ok	asl.w	#4,d0
	or.b	d0,d5	;or flags for bds
	
	bset	#8,d5	;flag extented mode
	move.w	d5,EAD_ext(a2)
	bra.w	ReadEAExit

;-- e '(all modes)'

;-----------------------------------------------------------------------------;
;- END - END - END - END - M680x0/M6888x/M68851 Assembler - END - END - END	-;
;-----------------------------------------------------------------------------;

;-----------------------------------------------------------------------------;
;-----------------------------------------------------------------------------;
;-	       M680x0/M6888x/M68851 Disassembler	-;
;-----------------------------------------------------------------------------;
;-----------------------------------------------------------------------------;
;- Input:	A0 -	Pointer to mem to disassemble from	-;
;-	D0 -	Print to buffer? (false/true)	-;
;-	D1 -	Max disassembled command length.	-;
;- Output:	D0 -	Flags: de_Double/de_Break. Check ea-address with 	-;
;-		EAD_eavalid in EADataS & EADataD.
;-	D1 -	#lines		-;
;-	DumpBuffer contains 0-terminated text.	-;
;-	if -1, print rest on new line.	-;
;-----------------------------------------------------------------------------;
;-		            History	-;
;-----------------------------------------------------------------------------;
;- 180493 -	Supports full Motorola CPU/FPU/MMU serie! (- pmove/ptest)	-;
;- 140593 -	Added pmove.		-;
;- 160593 -	Added ptest.		-;
;- 190593 -	Added check for max dis length. Input in D1 (inc ,...!)	-;
;-	Added check for breakline. Now flag at return like double l.	-;
;- 240693 -	DC.W type returned cmdlength fail. (bc neg)	-;
;-----------------------------------------------------------------------------;
DisStack	reg	d2-a4/a6	;use a6 for index

dsa	equr	a0	;disassemble address
;cw	equr	d6	;command word (being disected)

DTableIndex	dc.w	DTable0-DisAssemble
	dc.w	DTable1-DisAssemble
	dc.w	DTable2-DisAssemble
	dc.w	DTable3-DisAssemble
	dc.w	DTable4-DisAssemble
	dc.w	DTable5-DisAssemble
	dc.w	DTable6-DisAssemble
	dc.w	DTable7-DisAssemble
	dc.w	DTable8-DisAssemble
	dc.w	DTable9-DisAssemble
	dc.w	DTableA-DisAssemble
	dc.w	DTableB-DisAssemble
	dc.w	DTableC-DisAssemble
	dc.w	DTableD-DisAssemble
	dc.w	DTableE-DisAssemble
	dc.w	DTableF-DisAssemble

DisAssemble:	clr.b	NotValidMnem(b)	;clr disassemblefail flag
	move.w	d1,MaxDisLen(b)
	clr.l	DestPointer(b)
	move.l	a0,d1	;align address
	bclr	#0,d1
	move.l	d1,a0
	Push	DisStack
	move.w	d0,d7	;print/noprint flag
	move.w	(dsa)+,cw
	move.l	dsa,AssembleStart(b)
	move.w	cw,d3
	rol.w	#5,d3
	moveq	#%11110,d4
	and.w	d4,d3
	lea	DisAssemble(pc),a6
	add.w	DTableIndex(pc,d3.w),a6;pointer to table
	cmp.w	d4,d3	;a $Fxxx command?
	bne.b	.checkID
	btst	#11,cw	;a correct command must have bit 11=0
	beq.b	.checkID
	lea	DTableFExit(pc),a6;if not, get a DC.W
.checkID

DisassemLoop	lea	mb(pc),a2
	move.w	(a6)+,d4
	add.w	d4,a2	;get index

	move.w	mn_Bits(a2),d0	;get bits 'n' mask
	move.w	mn_Mask(a2),d1
	move.w	cw,d2	;check with value
	and.w	d1,d2
	cmp.w	d2,d0
	beq.b	FoundMatch
TryNext	addq.w	#1,d3	;count mnemonic number up
	bra.b	DisassemLoop

FoundMatch	moveq	#2,d3
	cmp.w	#mlong-mb,d4	;crossed border?
	bmi.b	.checkextra
	sub.w	#mlong-mb,d4
	move.w	(dsa),d0	;if so do premliminary checking
	and.w	mn_FPUMask(a2),d0
	cmp.w	mn_FPUID(a2),d0
	bne.b	TryNext
	move.w	(dsa)+,d0	;get ID word
	moveq	#4,d3	;and according length

.checkextra	move.b	d3,CmdLength(b)
	move.w	d4,MnemOffset(b)
	move.b	d3,MnemType(b)

	Push	dsa/a2
	move.w	d0,d4	;ID word for FPU cmds

	lea	DumpBuffer(b),a1
	move.w	(a2),d0	;get type
	lea	EADataS(b),a3
	lea	EADataD(b),a4
	clr.b	EAD_eavalid(a3)	;flag invalid addresses
	clr.b	EAD_eavalid(a4)

	jmp	DisAssembleJmps(pc,d0.w);and jump

DisassemNext	Pull	dsa/a2	;get pre-call values and check next
	bra.w	TryNext

;w;
DisAssembleJmps	bra.w	dpermove
	bra.w	deatoan
	bra.w	deatoan2
	bra.w	deatoan3
	bra.w	dmulmove
	bra.w	ditodn
	bra.w	deatoea
	bra.w	ditoea
	bra.w	deadnea
	bra.w	deadnea2
	bra.w	ddnitoea
	bra.w	dregmem
	bra.w	di3toea
	bra.w	danpanp
	bra.w	dceatodn
	bra.w	deatodn
	bra.w	deatorn	;\
	bra.w	deatorn	;/ checks second word!
	bra.w	deatodnm
	bra.w	deatodnl	;\
	bra.w	deatodnl	;/u/s specific only needed in ass
	bra.w	dccea
	bra.w	ddbcc
	bra.w	dabcc
	bra.w	dnone
	bra.w	dea
	bra.w	dea2
	bra.w	dea3
	bra.w	dea4
	bra.w	dea5
	bra.w	dea6
	bra.w	dshift
	bra.w	ddn
	bra.w	ddn2
	bra.w	ddn2B
	bra.w	dlinktyp
	bra.w	dan
	bra.w	didata
	bra.w	didata2	;normal trap
	bra.w	dnone	;fix for trapv (coz of assembler)
	bra.w	drxry
	bra.w	ddctyp	;\dcb.x entry
	bra.w	ddctyp	;/
	bra.w	dbitmanips
	bra.w	dabcc	;implemented here
	bra.w	dfield
	bra.w	dfield2
	bra.w	dfield3
	bra.w	dimm3
	bra.w	dcallm
	bra.w	ddcduea
	bra.w	dcastyp
	bra.w	dlmove
	bra.w	dpacktyp
	bra.w	dvaltyp
	bra.w	di16
	bra.w	dxntyp
	bra.w	dcachean
	bra.w	dcachean
	bra.w	dmovc
	bra.w	dmovs
	bra.w	dpbcc
	bra.w	dpdbcc
	bra.w	dpostan
	bra.w	dpflushfix;other flushtypes are checked in
	bra.w	dpflushfix
	bra.w	dpflushfix
	bra.w	dpfrtyp
	bra.w	dpscc
	bra.w	dfcear
	bra.w	dfcear	;linked ^
	bra.w	dpttyp
	bra.w	dfpubcc
	bra.w	dfpudbcc
	bra.w	dfpuscc
	bra.w	dfpunop
	bra.w	dfputrap
	bra.w	dfpun
	bra.w	dfpunsd
	bra.w	dfputst
	bra.w	dfpuscos
	bra.w	dfpucr
	bra.w	dfpumm
	bra.w	dfpum
	bra.w	dfpum	;same as ^. diff in fmove FPx,ea below

	bra.w	dpmovetype0
	bra.w	dpmovetype4	;fd

	bra.w	dpostan	;ptest (An)
	bra.w	dptesttypeW	;ptest weird

	bra.w	dpmovetype1
	bra.w	dpmovetype2
	bra.w	dpmovetype3

	bra.w	dtrapcc
	bra.w	dlmoved
	bra.w	deatodnl2
	bra.w	dlinktyp2
	bra.w	dbitmanip

	bra.w	dfpummc
	bra.w	dfpumtm
	bra.w	deatosr
	bra.w	dantousp
	bra.w	ditosr
	bra.w	ditoccr
	bra.w	dshift2

DisAssemExit	move.l	dsa,MemoryAddress(b)
	tst.w	d7	;check if stuff below is needed
	beq.b	DisAssemPull
	clr.b	(a1)+	;clear last char=end of text....

	moveq	#0,d0	;prepare flags

	moveq	#1,d1	;count lines
	move.l	DestPointer(b),d2
	beq.b	.checkbreak

	move.l	a1,d3
	lea	DumpBuffer(b),a2;check if split is needed
	sub.l	a2,d3
	sub.w	MaxDisLen(b),d3
	bmi.b	.checkbreak

	lea	6(a1),a2
.copyloop	move.b	-(a1),-(a2)
	cmp.l	a1,d2
	bne.b	.copyloop

	move.b	#'.',(a1)+	;set extra text
	move.b	#'.',(a1)+
	move.b	#-1,(a1)+
	move.b	#'.',(a1)+
	move.b	#'.',(a1)+
	move.b	#',',(a1)+

	bset	#de_Double,d0	;flag doubleline!
	addq.w	#1,d1

.checkbreak	move.b	DisBreaks(b),d3;get pref mask
	beq.b	.nobreak

	moveq	#0,d4
	move.w	MnemOffset(b),d4

	moveq	#16,d2	;length of mnem macro
	moveq	#0,d5
	cmp.b	#2,MnemType(b)	;2=CPU/4=FPU
	beq.b	.lenok
	moveq	#20,d2	;length of mnemf macro
	move.w	#DMnemBreak,d5	;This may cause problems if not
.lenok	divu	d2,d4	;properly updated! (if macro changes)
	add.w	d5,d4

	lea	DisBreakTab(pc),a0;check for breakline
	and.b	(a0,d4.w),d3
	beq.b	.nobreak	;no breakline here

	bset	#de_Break,d0	;mark breakline
	addq.w	#1,d1
.nobreak
DisAssemPull	addq.w	#8,a7	;get NEXT values off stack
	Pull	DisStack
	rts

;All SIMPLE commands
dnone	bsr.w	DAPrintMnemonicNZ
	clr.b	-1(a1)
	bra.w	DisAssemExit

;MOVEP
dpermove	moveq	#1,d0
	btst	#6,cw
	beq.b	.word
	moveq	#2,d0
.word	bsr.w	DAPrintMnemonic
	move.w	cw,d0
	rol.w	#7,d0
	and.w	#%111,d0
	move.w	d0,EAD_cmd(a3)
	moveq	#dt0,d0
	move.w	cw,d1
	and.w	#%111,d1
	move.w	d1,EAD_cmd(a4)
	move.w	(dsa)+,EAD_bd+2(a4)
	moveq	#dt5,d1
	btst	#7,cw
	bne.b	.reverse
	exg	d0,d1
	exg	a3,a4
.reverse	moveq	#2,d5
	bra.w	DAPrintSDL

;STOP
didata	bsr.w	DAPrintMnemonicNZ
	move.w	(dsa)+,EAD_bd+2(a3)
DAPrintIExit	move.b	#1,EAD_bds(a3)
	moveq	#dt13,d0
	moveq	#-1,d1
	moveq	#2,d5
	bra.w	DAPrintSDL

;TRAP
didata2	bsr.w	DAPrintMnemonicNZ
	and.w	#$f,cw	;print trapvector
	move.w	cw,EAD_bd+2(a3)
	bra.b	DAPrintIExit

;TRAPcc
dtrapcc	move.w	cw,d0
	and.w	#%111,d0
	cmp.w	#%010,d0
	beq.b	.word
	cmp.w	#%011,d0
	beq.b	.long
	cmp.w	#%100,d0
	bne.w	DisassemNext
	moveq	#-1,d2	;not sr/ra
	moveq	#-1,d0	;no size
	bsr.w	DAPrintMnemcc
	bra.w	DisAssemExit

.word	moveq	#2,d1
	moveq	#%01,d0
	bra.b	.size
.long	moveq	#4,d1
	moveq	#%10,d0
.size	moveq	#-1,d2
	bsr.w	DAPrintMnemcc
	moveq	#-1,d1	;no dest
	move.b	DisSize(b),d0
	move.b	d0,EAD_bds(a3)
	cmp.b	#%10,d0
	beq.b	.lang
	move.w	(dsa)+,d0
	bra.b	.ok

.lang	move.l	(dsa)+,d0
.ok	move.l	d0,EAD_bd(a3)
	moveq	#dt13,d0
	bra.w	DAPrintSD

;MOVEA
deatoan3	moveq	#1,d0	;.w
	btst	#12,cw
	bne.b	.sizeok	;(281192 was beq)
	moveq	#2,d0	;.l
.sizeok	bsr.w	DAPrintMnemonic
	move.w	cw,d1
	rol.w	#7,d1
	and.w	#%111,d1
	move.w	d1,EAD_cmd(a4)
	moveq	#dt1,d1
	move.l	#alltypes,d0
;	moveq	#0,d5

;---- convert EA pattern to 
;- Input:	d0 - mask of allowed sources
;-	d5 - size
;----
DAEASourceN	moveq	#0,d5
DAEASource	lea	EADataS(b),a2
	bsr.b	DAConvertEA
	move.l	d4,d0
	bra.w	DAPrintSDL

;---- convert EA pattern to 
;- Input:	d1 - mask of allowed dests
;-	d5 - size
;----
DAEADestN	moveq	#0,d5
DAEADest	exg	d0,d1
	lea	EADataD(b),a2
	bsr.b	DAConvertEA
	move.l	d4,d0
	exg	d0,d1
	bra.w	DAPrintSDL

;---- convert EA pattern to 
;- Input:	d0 - cw of source
;-	d1 - mask of allowed sources
;-	d2 - cw of dest
;-	d3 - mask of allowed dest
;-	d5 - size
;----
DAEASourceDest	Push	d2/d3
	move.l	d0,cw
	move.l	d1,d0
	lea	EADataS(b),a2
	moveq	#2*4,d4
	bsr.b	DAConvertEAS
	Pull	d2/d3
	move.l	d4,-(a7)	;sourcetype
	move.l	d2,cw
	move.l	d3,d0
	lea	EADataD(b),a2
	moveq	#4,d4
	bsr.b	DAConvertEAS
	move.l	d4,d1
	move.l	(a7)+,d0
	bra.w	DAPrintSDL

;---- Will convert EA of cw to printable data (in a2)
;-- Input:	d0	- mask of allowed EAs
;-	d4	- size of stack-kill if error!
;--	a2	- structure to be build in
;-- Output:	d4	- type
;----
DAConvertEA	moveq	#0,d4
DAConvertEAS	move.l	d1,-(a7)
	addq.w	#8,d4
	move.l	d4,d1
	move.w	cw,d3
	move.w	cw,d4
	lsr.w	#3,d3
	moveq	#%111,d2
	and.w	d2,d3
	cmp.w	d2,d3
	bne.w	.extended	;.extended handles register modes
	and.w	d2,d4
	cmp.w	#%100,d4	;fail if %101-%111
	bgt.b	.DisassemNext
	cmp.w	#%001,d4
	bgt.b	.checkingabs
	moveq	#dt11,d2	;check absolute types (%000+%001)
	add.w	d2,d4
	cmp.w	d2,d4
	beq.b	.word
	move.l	(dsa)+,d3	;abs.l
	moveq	#%10,d2
	addq.w	#4,d5	;size
.setbdexit	move.l	d3,EAD_bd(a2)
	move.b	d2,EAD_bds(a2)

	st.b	EAD_eavalid(a2)	;set ea
	move.l	d3,EAD_ea(a2)

.checklength	btst	d4,d0	;check if addressing is ok
	beq.b	.DisassemNext
	move.l	(a7)+,d1
	rts

.DisassemNext	add.w	d1,a7	;skip stack-data
	bra.w	DisassemNext

.word	addq.w	#2,d5	;abs .w
	moveq	#%01,d2
	moveq	#0,d3	;clear top word
	move.w	(dsa)+,d3
	bra.b	.setbdexit

.checkingabs	cmp.w	#%100,d4
	bne.b	.checkingimm
	moveq	#dt13,d4	;immediate data
	move.b	DisSize(b),d3
	move.b	d3,EAD_bds(a2)
	cmp.b	#%01,d3
	bgt.b	.gettingw
	addq.w	#2,d5	;get #.b/.w
	moveq	#0,d3
	move.w	(dsa)+,d3

	tst.b	EAD_bds(a2)	;no ea if .b
	beq.b	.noea

	st.b	EAD_eavalid(a2)	;set ea
	move.l	d3,EAD_ea(a2)

.noea	move.w	d3,EAD_bd+2(a2)
	bra.b	.checklength

.gettingw	cmp.b	#%11,d3
	bgt.b	.gettingl
	move.l	(dsa)+,d3
	st.b	EAD_eavalid(a2)	;set ea
	move.l	d3,EAD_ea(a2)
	move.l	d3,EAD_bd(a2)	;get #.l
	addq.w	#4,d5
	bra.b	.checklength

.gettingl	cmp.w	#%100,d3
	bgt.b	.gettingd
	addq.w	#8,d5	;get #.d
.next	move.l	(dsa)+,EAD_bd(a2)
	move.l	(dsa)+,EAD_od(a2)
	bra.b	.checklength

.gettingd	move.l	(dsa)+,EAD_extra(a2);get #.x
	add.w	#12,d5
	bra.b	.next

.checkingimm	move.w	cw,EAD_cmd(a2)	;store cmd word (bit checked by dt7)
	cmp.w	#%010,d4	;check for xtended
	bne.b	.pcd16
	moveq	#dt8,d4	;16bit pc
	move.w	(dsa)+,d2
	addq.w	#2,d5
.converted	ext.l	d2
	subq.l	#2,d2
	add.l	dsa,d2

	st.b	EAD_eavalid(a2)	;set ea
	move.l	d2,EAD_ea(a2)

	move.l	d2,EAD_bd(a2)	;convert to abs
	bra.w	.checklength

.checkd8pci	move.w	d3,d2	;8bit pc
	ext.w	d2
	bra.b	.converted

.pcd16	moveq	#dt9,d4
.checkxtended	move.w	(dsa)+,d3
	move.w	d3,EAD_ext(a2)
	addq.w	#2,d5
	btst	#8,d3
	beq.b	.checkd8pci
	btst	#3,d3
	bne.w	.DisassemNext	;bit 3 of ext must equ 0!
	addq.w	#1,d4
	move.w	d3,d2
	and.w	#%110000,d2
	beq.w	.DisassemNext	;not allowed
	cmp.w	#%100000,d2
	blt.b	.checkod
	bne.b	.longbd
	addq.w	#2,d5
	move.w	(dsa)+,d2
	ext.l	d2
	bra.b	.putbd

.longbd	addq.w	#4,d5
	move.l	(dsa)+,d2
.putbd	cmp.w	#dt9,d4
	blt.b	.notpc
	btst	#7,d3
	bne.b	.notpc	;if suppressed
	move.l	d0,-(a7)
	move.l	dsa,d0
	sub.l	AssembleStart(b),d0;convert to abs ;pc;
	cmp.w	#4,d0
	ble.b	.okay2
	moveq	#4,d0	;is max
.okay2	sub.l	d0,d2
	add.l	dsa,d2
	move.l	(a7)+,d0

.notpc	move.l	d2,EAD_bd(a2)

	st.b	EAD_eavalid(a2)	;set ea
	move.l	d2,EAD_ea(a2)

.checkod	move.w	d3,d2
	and.w	#%1000111,d2
	cmp.w	#%0000100,d2	;not allowed
	beq.w	.DisassemNext
	and.w	#%1000100,d2
	cmp.w	#%1000100,d2	;not allowed
	beq.w	.DisassemNext
	and.w	#%11,d3
	cmp.w	#%10,d3
	blt.b	.checkedod
	bne.b	.odlong
	move.w	(dsa)+,EAD_od+2(a2)
	addq.w	#2,d5
	bra.b	.checkedod

.odlong	move.l	(dsa)+,EAD_od(a2)
	addq.w	#4,d5

.checkedod	bra.w	.checklength

.extended	move.w	cw,EAD_cmd(a2)
	move.l	d3,d4
	cmp.w	#dt5,d4	;first 5 needs no fix
	blt.w	.checklength
	bne.b	.checkxtended2
	addq.w	#2,d5	;d16(an)
	move.w	(dsa)+,EAD_bd+2(a2)
	bra.w	.checklength

.checkxtended2	moveq	#dt6,d4	;d8(An,Xn)
	bra.w	.checkxtended
;---- end of DAConvertEA

;MOVEM
dmulmove	moveq	#1,d0
	btst	#6,cw
	beq.b	.long
	moveq	#%10,d0
.long	bsr.w	DAPrintMnemonic
	moveq	#2,d5
	move.w	(dsa)+,d2
	beq.w	DisassemNext
	btst	#10,cw
	beq.b	.regtomem
	clr.w	EAD_cmd(a4)
	move.w	d2,EAD_ext(a4)
	moveq	#dt21,d1
	move.l	#%1111111101100,d0
	bra.w	DAEASource

.regtomem	move.w	d2,EAD_ext(a3)
	clr.w	EAD_cmd(a3)
	move.w	cw,d2
	and.w	#%111000,d2
	cmp.w	#%100000,d2	;if dec change mode
	bne.b	.changemode
	move.w	#1,EAD_cmd(a3)
.changemode	moveq	#dt21,d0
	move.l	#%1100011110100,d1
	bra.w	DAEADest

;MOVEQ
ditodn	bsr.w	DAPrintMnemonicNZ
	clr.b	DisSize(b)
	move.w	cw,d1
	and.w	#$ff,d1
	move.w	d1,EAD_bd+2(a3)
	clr.b	EAD_bds(a3)
	moveq	#dt13,d0
	rol.w	#7,cw
	and.w	#%111,cw
	move.w	cw,EAD_cmd(a4)
	moveq	#dt0,d1
	bra.w	DAPrintSD

;move ea,xxr and xxr,ea
deatosr	moveq	#1,d0
	bsr.w	DAPrintMnemonic
	moveq	#dt16,d1	;set cr
	move.w	cw,d0
	and.w	#%11000000000,d0
	beq.b	.fromxxr
	cmp.w	#%11000000000,d0;xxrtoea?
	beq.b	.toxxr
	moveq	#dt17,d1	;set CCR
	cmp.w	#%01000000000,d0
	beq.b	.fromxxr

.toxxr	move.l	#%11111111111101,d0;ea,xxr
	bra.w	DAEASourceN

.fromxxr	move.l	d1,d0	;xxr,ea
	move.l	#%1100011111101,d1
	bra.w	DAEADestN

;MOVE AN,USP
dantousp	bsr.w	DAPrintMnemonicNZ
	move.w	cw,d0
	and.w	#%111,d0
	move.w	d0,EAD_cmd(a3)	;ok to store both - usp don't use it
	move.w	d0,EAD_cmd(a4)
	moveq	#dt1,d0
	moveq	#dt18,d1
	btst	#3,cw
	beq.b	.otherdir
	exg	d0,d1
.otherdir	bra.w	DAPrintSD

;move
deatoea	move.w	cw,d1
	and.w	#%11000000000000,d1
	moveq	#0,d0
	cmp.w	#%01000000000000,d1
	beq.b	.geton
	moveq	#1,d0
	cmp.w	#%11000000000000,d1
	beq.b	.geton
	cmp.w	#%10000000000000,d1
	bne.w	DisassemNext
	moveq	#%10,d0
.geton	bsr.w	DAPrintMnemonic
	move.w	cw,d0	;source
	move.w	cw,d2	;dest
	lsr.w	#3,d2
	and.w	#%111000,d2
	move.w	cw,d3
	rol.w	#7,d3
	and.w	#%111,d3
	or.w	d3,d2
	move.w	d0,d3
	and.w	#%111000,d3
	cmp.w	#%001000,d3	;check for An not byte
	bne.b	.checkbyte
	tst.b	DisSize(b)
	beq.w	DisassemNext
.checkbyte	move.l	#alltypes,d1
	move.l	#%1100011111101,d3
	bra.w	DAEASourceDest

;andi,ori,eori,cmpi,subi,addi
ditoea	bsr.w	DAPrintMnemonic6
	moveq	#%111100,d0	;set source=#
	move.l	#1<<[dt13],d1
	move.w	cw,d2
	move.l	#%1100011111101,d3
	bra.w	DAEASourceDest
;or,and
deadnea	bsr.w	DAPrintMnemonic6
	move.l	#%11111111111101,d3
DAEADnEAMain	move.l	#%01100011111100,d1
	move.w	cw,d2
	rol.w	#7,d2
	and.w	#%111,d2
	btst	#8,cw
	beq.b	.DAEADest
	move.w	d2,EAD_cmd(a3)
	moveq	#dt0,d0
	bra.w	DAEADest

.DAEADest	move.w	d2,EAD_cmd(a4)
	moveq	#dt0,d1
	move.l	d3,d0
	bra.w	DAEASource

;eori,andi,ori #,sr
ditosr	moveq	#1,d0
	moveq	#dt16,d1
ditosrmain	move.l	d1,-(a7)
	move.b	d0,EAD_bds(a3)
	bsr.w	DAPrintMnemonic
	move.w	(dsa)+,EAD_bd+2(a3)
	moveq	#dt13,d0
	move.l	(a7)+,d1
	moveq	#2,d5
	bra.w	DAPrintSDL

;eori,andi,ori #,ccr
ditoccr	moveq	#0,d0
	moveq	#dt17,d1
	bra.b	ditosrmain

;EOR
ddnitoea	bsr.w	DAPrintMnemonic6
	move.w	cw,d0
	rol.w	#7,d0
	and.w	#%111,d0
	move.w	d0,EAD_cmd(a3)
	moveq	#dt0,d0
	move.l	#%1100011111101,d1
	bra.w	DAEADest

;ADDA,CMPA,SUBA
deatoan	moveq	#1,d0
	btst	#8,cw
	beq.b	.size
	moveq	#%10,d0
.size	bsr.w	DAPrintMnemonic
	move.l	#alltypes,d0
DAEAToAnMain	move.w	cw,d1
	rol.w	#7,d1
	move.w	d1,EAD_cmd(a4)
	moveq	#dt1,d1
	bra.w	DAEASourceN

;LEA
deatoan2	moveq	#%10,d0
	bsr.w	DAPrintMnemonic
	move.l	#%01111111100100,d0
	bra.b	DAEAToAnMain

;ADD,SUB
deadnea2	bsr.w	DAPrintMnemonic6
	move.l	#alltypes,d3
	move.w	cw,d0
	and.w	#%111000,d0	;check for An.b
	cmp.w	#%001000,d0
	bne.w	DAEADnEAMain
	tst.b	DisSize(b)
	beq.w	DisassemNext	;wrong size!
	bra.w	DAEADnEAMain

;ADDX,SUBX ABCD,SBCD
dregmem	bsr.w	DAPrintMnemonic6
	cmp.w	#%1111000111110000,mn_Mask(a2);check for abcd/sbcd
	bne.b	.checksize	;and check size if needed
	tst.b	DisSize(b)	;(I DONT LIKE THIS METHOD!)
	bne.w	DisassemNext
.checksize	move.w	cw,EAD_cmd(a3)
	move.w	cw,d3
	rol.w	#7,d3
	move.w	d3,EAD_cmd(a4)
	moveq	#dt0,d0	;set type
	btst	#3,cw
	beq.b	.ok
	moveq	#dt4,d0
.ok	move.l	d0,d1
	bra.w	DAPrintSD

;ADDQ, SUBQ
di3toea	bsr.w	DAPrintMnemonic6
	move.w	cw,d0
	and.w	#%111000,d0	;check An.b
	cmp.w	#%001000,d0
	bne.b	.sizecheck
	tst.b	DisSize(b)
	beq.w	DisassemNext
.sizecheck	move.w	cw,d1
	rol.w	#7,d1
	and.w	#%111,d1
	bne.b	.NULL2EIGHT
	moveq	#8,d1
.NULL2EIGHT	move.w	d1,EAD_bd+2(a3)
	clr.b	EAD_bds(a3)
	moveq	#dt13,d0
	move.l	#%1100011111111,d1
	bra.w	DAEADestN

;CMPM
danpanp	bsr.w	DAPrintMnemonic6
	move.w	cw,EAD_cmd(a3)	;set y
	rol.w	#7,cw
	move.w	cw,EAD_cmd(a4)	;set x
	moveq	#dt3,d0
	moveq	#dt3,d1
	bra.w	DAPrintSD

;CMP
dceatodn	bsr.w	DAPrintMnemonic6
	move.w	cw,d2
	rol.w	#7,d2
	move.w	d2,EAD_cmd(a4)
	move.w	#dt0,d1
	move.w	cw,d3
	and.w	#%111000,d3	;check An.b
	cmp.w	#%001000,d3
	bne.b	.checksize
	tst.b	DisSize(b)
	beq.w	DisassemNext
.checksize	move.l	#alltypes,d0
	bra.w	DAEASourceN

;CHK
deatodn	moveq	#1,d0
	btst	#7,cw
	bne.b	deatodnmain
	moveq	#%10,d0
deatodnmain	bsr.w	DAPrintMnemonic
	move.w	cw,d2	;(281192 S'n'D was swapped)
	rol.w	#7,d2
	move.w	d2,EAD_cmd(a4)
	moveq	#dt0,d1
	move.l	#%11111111111101,d0
	bra.w	DAEASourceN
;Scc
dccea	moveq	#0,d0
	bsr.w	DAPrintMnemcc
	moveq	#-1,d1	;no dest
	move.l	#%1100011111101,d0
	bra.w	DAEASourceN

;DBcc
ddbcc	moveq	#-1,d0
	moveq	#1,d2	;print dbra, not dbf
	bsr.w	DAPrintMnemccS
	moveq	#2,d5
ddbccmain	move.w	cw,EAD_cmd(a3)
	move.w	#dt0,d0
	move.l	dsa,d2
	move.w	(dsa)+,d3
	ext.l	d3
	add.l	d2,d3
	move.l	d3,EAD_bd(a4)

	st.b	EAD_eavalid(a4)	;set ea
	move.l	d3,EAD_ea(a4)

	move.b	#%10,EAD_bds(a4)
	moveq	#dt12,d1
	swap	d3
	tst.w	d3
	bne.b	.zp
	moveq	#dt11,d1
.zp	bra.w	DAPrintSDL

;Bcc
dabcc	moveq	#1,d0	;.w
	tst.b	cw
	beq.b	.byte
	moveq	#2,d0	;.l
	cmp.b	#-1,cw
	beq.b	.byte
	moveq	#0,d0	
.byte	moveq	#-1,d2	;check for bra/bsr
	bsr.w	DAPrintMnemccS
dbccmain	move.l	dsa,d1
	moveq	#0,d5
	moveq	#0,d0
	move.b	cw,d0
	beq.b	.word
	cmp.b	#-1,d0
	bne.b	.byte2
	move.l	(dsa)+,d0	;.l
	moveq	#4,d5
	bra.b	.ok

.word	move.w	(dsa)+,d0	;.w
	ext.l	d0
	moveq	#2,d5
	bra.b	.ok

.byte2	ext.w	d0
	ext.l	d0

.ok	add.l	d0,d1

	st.b	EAD_eavalid(a3)	;set ea
	move.l	d1,EAD_ea(a3)

	move.l	d1,EAD_bd(a3)
	moveq	#dt12,d0
	swap	d1	;test for .w address
	tst.w	d1
	bne.b	.zp
	moveq	#dt11,d0
.zp	moveq	#-1,d1
	bra.w	DAPrintSDL

;JMP,JSR,PEA	
dea	moveq	#-1,d0
	bsr.w	DAPrintMnemonic
	move.l	#%01111111100100,d0
	moveq	#-1,d1
	bra.w	DAEASourceN

;NEG,NEGX,NOT,CLR
dea2	bsr.w	DAPrintMnemonic6
dea2Main	move.l	#%1100011111101,d0
dea2Main2	moveq	#-1,d1
	bra.w	DAEASourceN
;TAS,NBCD
dea3	moveq	#0,d0
	bsr.w	DAPrintMnemonic
	bra.b	dea2Main

;tst
dea4	bsr.w	DAPrintMnemonic6
	move.l	#alltypes,d0
	bra.b	dea2Main2
;prestore
dea5	bsr.w	DAPrintMnemonicNZ
	move.l	#%01111111101100,d0
	bra.b	dea2Main2

dea6	bsr.w	DAPrintMnemonicNZ
	move.l	#%1100011110100,d0
	bra.b	dea2Main2

;-- shift <ea>
dshift	moveq	#1,d0	;shift <ea> is word only!
	bsr.w	DAPrintMnemonic
	moveq	#-1,d1
	move.l	#%1100011111100,d0
	bra.w	DAEASourceN

;shift #/Dn,Dm
dshift2	bsr.w	DAPrintMnemonic6
	move.w	cw,EAD_cmd(a4)
	moveq	#dt0,d1
	move.w	cw,d0
	rol.w	#7,d0
	btst	#5,cw
	beq.b	.count
	move.w	d0,EAD_cmd(a3)
	moveq	#dt0,d0
	bra.w	DAPrintSD

.count	and.w	#%111,d0
	bne.b	.setn8	;if NULL-> n=8
	moveq	#8,d0
.setn8	move.w	d0,EAD_bd+2(a3)
	clr.b	EAD_bds(a3)
	moveq	#dt32,d0	;set #(3 bit)
	bra.w	DAPrintSD
;SWAP
ddn	moveq	#-1,d0
DADnMain	bsr.w	DAPrintMnemonic
	moveq	#-1,d1
	move.w	cw,EAD_cmd(a3)
	moveq	#dt0,d0
	bra.w	DAPrintSD
;EXT
ddn2	moveq	#1,d0
	btst	#6,cw
	beq.b	DADnMain
	moveq	#%10,d0
	bra.b	DADnMain

;extb
ddn2B	moveq	#2,d0
	bra.b	DADnMain

;LINK
dlinktyp	move.w	(dsa)+,EAD_bd+2(a4)
	move.b	#1,EAD_bds(a4)
	moveq	#2,d5
	moveq	#1,d0
dlinktypmain	bsr.w	DAPrintMnemonic
	move.w	cw,EAD_cmd(a3)
	moveq	#dt1,d0
	moveq	#dt13,d1
	bra.w	DAPrintSDL

;link.l
dlinktyp2	move.l	(dsa)+,EAD_bd(a4)
	move.b	#2,EAD_bds(a4)
	moveq	#4,d5
	moveq	#2,d0
	bra.b	dlinktypmain

;UNLK
dan	moveq	#-1,d0
	bsr.w	DAPrintMnemonic
	move.w	cw,EAD_cmd(a3)
	moveq	#dt1,d0
	moveq	#-1,d1
	bra.w	DAPrintSD

;EXG
drxry	moveq	#-1,d0
	bsr.w	DAPrintMnemonic
	move.w	cw,d0
	rol.w	#7,d0
	move.w	d0,EAD_cmd(a3)
	move.w	cw,EAD_cmd(a4)
	moveq	#dt0,d0
	moveq	#dt0,d1
	and.w	#%11001000,cw
	cmp.w	#%01000000,cw
	beq.b	.regs
	moveq	#dt1,d1
	cmp.w	#%10001000,cw
	beq.b	.regs
	moveq	#dt1,d0
.regs	bra.w	DAPrintSD

;simple DC.W
ddctyp	st.b	NotValidMnem(b)	;signal not OK disassemble
	subq.w	#2,dsa	;fix extra FPU read!
	subq.b	#2,CmdLength(b)

	move.b	#2,MnemType(b)

	moveq	#1,d0
	bsr.w	DAPrintMnemonic
	move.b	#'$',(a1)+
	move.w	cw,d0
	moveq	#3,d1
	exg	a0,a1
	grcall	PrintHex
	exg	a0,a1
	move.b	pr_PrintASCII(b),d0
	beq.b	.noascii
	move.w	d3,-(a7)	;print ASCII
	moveq	#15+2,d3
.indent	move.b	#' ',(a1)+	;extra indent
	dbra	d3,.indent
	move.b	#';',-2(a1)
	move.b	pr_NonASCII(b),d3
	move.b	#"'",(a1)+
	move.w	cw,d0
	move.w	cw,d1
	lsr.w	#8,d1
	and.w	#$ff,d0
	and.w	#$ff,d1
	cmp.b	#' ',d0
	blt.b	.force
	cmp.b	#$7f,d0
	blt.b	.ok
.force	move.b	d3,d0
.ok	cmp.b	#' ',d1
	blt.b	.force2
	cmp.b	#$7f,d1
	blt.b	.ok2
.force2	move.b	d3,d1
.ok2	move.b	d1,(a1)+
	move.b	d0,(a1)+
	move.b	#"'",(a1)+
	move.w	(a7)+,d3
.noascii	clr.b	(a1)
	bra.w	DisAssemExit

;Bxxx #n,
dbitmanips	moveq	#-1,d0	;always byte (even tho ,Dn is long)
	bsr.w	DAPrintMnemonic
	move.w	(dsa)+,EAD_bd+2(a3)
	clr.b	EAD_bds(a3)
	moveq	#dt13,d0
	moveq	#2,d5
DABitManipMain	move.w	cw,d2
	move.l	#%1100011111101,d1;set allowed dest
	and.w	#%11000000,d2	;according to bxxx type
	bne.b	.btst
	move.l	#%01111111111101,d1
	cmp.w	#dt0,d0
	bne.b	.btst
	move.l	#%11111111111101,d1
.btst	bra.w	DAEADest

;Bxxx Dn,
dbitmanip	moveq	#-1,d0
	bsr.w	DAPrintMnemonic
	moveq	#0,d5
	move.w	cw,d0
	rol.w	#7,d0
	move.w	d0,EAD_cmd(a3)
	moveq	#dt0,d0
	bra.b	DABitManipMain

;rtd
di16	bsr.w	DAPrintMnemonicNZ
	moveq	#2,d5
	moveq	#-1,d1
	move.w	(dsa)+,EAD_bd+2(a3)
	move.b	#%10,EAD_bds(a3)
	moveq	#dt13,d0
	bra.w	DAPrintSDL
;rtm
dxntyp	bsr.w	DAPrintMnemonicNZ
	moveq	#-1,d1
	move.w	cw,EAD_cmd(a3)
	moveq	#dt0,d0
	and.w	#%1000,cw
	beq.b	.datareg
	moveq	#dt1,d0
.datareg	bra.w	DAPrintSD

;moves
dmovs	bsr.w	DAPrintMnemonic6
	move.w	(dsa)+,d2
	move.w	d2,d1
	and.w	#$7ff,d1
	bne.w	DisassemNext
	rol.w	#4,d2
	moveq	#dt0,d1
	btst	#3,d2
	beq.b	.ok
	moveq	#dt1,d1
.ok	move.l	#%1100011111100,d0
	moveq	#2,d5
	tst.w	d2
	bpl.b	.fromea
	move.w	d2,EAD_cmd(a3)
	bra.w	DAEADest

.fromea	move.w	d2,EAD_cmd(a4)
	exg	d0,d1
	bra.w	DAEASource

;move16 normal
dlmove	moveq	#4,d5
	moveq	#dt2,d0
	move.w	cw,d2
	moveq	#dt12,d1
	move.l	(dsa)+,d3
	btst	#4,cw
	beq.b	.modeok
	moveq	#dt3,d0
.modeok	btst	#3,cw
	beq.b	.dirok
	exg	d0,d1
	move.w	d2,EAD_cmd(a4)
	move.l	d3,EAD_bd(a3)
	bra.b	.done
.dirok	move.w	d2,EAD_cmd(a3)
	move.l	d3,EAD_bd(a4)
.done	
	bra.b	lmovedx

;move16 (ax)+,(ay)+
dlmoved	moveq	#2,d5
	move.w	cw,EAD_cmd(a3)
	move.w	(dsa)+,d0
	move.w	d0,d1
	and.w	#$8fff,d1	;check bits in ext word are ok
	cmp.w	#$8000,d1
	bne.w	DisassemNext
	rol.w	#4,d0
	move.w	d0,EAD_cmd(a4)
	moveq	#dt3,d0
	moveq	#dt3,d1
lmovedx	Push	d0/d1
	bsr.w	DAPrintMnemonicNZ
	Pull	d0/d1
	bra.w	DAPrintSDL
;movec
dmovc	bsr.w	DAPrintMnemonicNZ
	moveq	#2,d5
	move.w	(dsa)+,d2
	move.w	d2,d1
	rol.w	#4,d2
	move.w	d2,EAD_cmd(a3)
	moveq	#dt0,d0
	btst	#3,d2
	beq.b	.datareg
	moveq	#dt1,d0
.datareg	lea	EARegList+6(pc),a4
	moveq	#16-1,d3	;check 16 allowed types
	and.w	#$fff,d1
.findtype	cmp.w	(a4),d1
	beq.b	.found
	addq.w	#8,a4
	dbra	d3,.findtype
	bra.w	DisassemNext	;not found

.found	subq.w	#6,a4	;poi to reg-name
	moveq	#dt14,d1

	btst	#0,cw
	bne.b	.changedir
	exg	d0,d1
	exg	a3,a4
.changedir	bra.w	DAPrintSDL


;divs ('000)
deatodnm	moveq	#1,d0
	bra.w	deatodnmain

;divsl/divul
deatodnl	move.w	(dsa)+,d4
	lea	divuldat(pc),a2
	move.w	d4,d5
	and.w	#%1000101111111000,d5
	beq.b	.divultype
	cmp.w	#%0000100000000000,d5
	bne.w	DisassemNext
	lea	divsldat(pc),a2
.divultype	btst	#10,d4
	beq.b	.ltype
	add.w	#mn_SizeOf,a2	;get to next name if size=64bit
.ltype	moveq	#%10,d0
	bsr.w	DAPrintMnemonic
	moveq	#2,d5
	move.w	d4,EAD_cmd(a4)
	rol.w	#4,d4
	move.w	d4,EAD_ext(a4)
	moveq	#dt24,d1
	move.l	#%11111111111101,d0
	bra.w	DAEASource

;mulu/muls.l
deatodnl2	move.w	(dsa)+,d4
	move.w	d4,d5
	and.w	#%1000100000000000,d5
	beq.b	.mulu
	cmp.w	#%0000100000000000,d5
	bne.w	DisassemNext
	add.w	#mn_SizeOf,a2	;get to muls if needed
.mulu	moveq	#%10,d0
	bsr.w	DAPrintMnemonic
	moveq	#2,d5
	move.w	d4,d3
	rol.w	#4,d3
	moveq	#dt0,d1
	btst	#10,d4
	bne.b	.64bit
	move.w	d3,EAD_cmd(a4)
	bra.b	.ok

.64bit	moveq	#dt24,d1
	move.w	d3,EAD_ext(a4)
	move.w	d4,EAD_cmd(a4)

.ok	move.l	#%11111111111101,d0
	bra.w	DAEASource

;simple bitfield type
dfield	move.w	(dsa),d0
	and.w	#$f000,d0
	bne.w	DisassemNext
	bsr.w	DAPrintMnemonicNZ
dbftypmain	bsr.b	dbftype
	move.l	d4,d0
;	asl.w	#2,d0
	bsr.w	CallSDTab
	move.w	EAD_bitfield(b),EAD_ext(a3)
	moveq	#-1,d1
	moveq	#dt33,d0
	bra.w	DAPrintSD

;bitfield,Dn
dfield2	bsr.w	DAPrintMnemonicNZ
	bsr.b	dbftype
	move.l	d4,d0
;	asl.w	#2,d0
	bsr.w	CallSDTab
	move.w	EAD_bitfield(b),d0;get additional data
	bmi.w	DisassemNext
	move.w	d0,EAD_ext(a3)
	rol.w	#4,d0
	move.w	d0,EAD_cmd(a4)
	moveq	#dt0,d1
	moveq	#dt33,d0
	bra.w	DAPrintSD

;Dn,bitfield
dfield3	bsr.w	DAPrintMnemonicNZ
	move.w	(dsa),d0
	bmi.w	DisassemNext
	rol.w	#4,d0
	move.w	d0,EAD_cmd(a3)
	bsr.w	DAPrintdt0	;get sourcereg printed
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	bra.b	dbftypmain

dbftype	move.w	(dsa)+,EAD_bitfield(b);simple storage
	move.l	#%1100011100101,d0
	move.l	a3,a2	;build in source
	moveq	#2,d5
	bra.w	DAConvertEA

;bkpt
dimm3	bsr.w	DAPrintMnemonicNZ
	and.w	#%111,cw
	add.b	#'0',cw
	move.b	#'#',(a1)+
	move.b	cw,(a1)+
	bra.w	DisAssemExit
;callm
dcallm	bsr.w	DAPrintMnemonicNZ
	move.w	(dsa)+,d0
	move.w	d0,EAD_bd+2(a3)
	and.w	#$ff00,d0
	bne.w	DisassemNext
	clr.b	EAD_bds(a3)
	moveq	#dt13,d0
	moveq	#2,d5
	move.l	#%1111111100100,d1
	bra.w	DAEADest

;cas
dcastyp	move.w	cw,d0
	rol.w	#7,d0
	and.w	#%11,d0
	subq.w	#1,d0
	bmi.w	DisassemNext
	bsr.w	DAPrintMnemonic
	move.w	(dsa)+,d1
	move.w	d1,EAD_cmd(a3)	;get first printed
	bsr.w	DAPrintdt0
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	ror.w	#6,d1
	move.w	d1,EAD_cmd(a3)
	moveq	#dt0,d0
	move.l	#%1100011111100,d1
	moveq	#2,d5
	bra.w	DAEADest

;cas2
ddcduea	moveq	#%01,d0
	btst	#9,cw
	beq.b	.word
	moveq	#%10,d0
.word	bsr.w	DAPrintMnemonic
	move.w	(dsa)+,d0
	move.w	d0,EAD_cmd(a3)
	move.w	d0,EAD_cmd(a4)
	move.w	(dsa)+,EAD_ext(a3)
	bsr.w	DAPrintdt24	;print c1-types
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	move.w	EAD_cmd(a4),d0
	ror.w	#6,d0
	move.w	d0,EAD_cmd(a3)
	ror.w	#6,d0
	move.w	d0,EAD_cmd(a4)
	move.w	EAD_ext(a3),d0
	ror.w	#6,d0
	move.w	d0,EAD_ext(a3)
	ror.w	#6,d0
	move.w	d0,EAD_ext(a4)
	moveq	#dt24,d0
	moveq	#dt34,d1
	moveq	#4,d5
	bra.w	DAPrintSDL

;pack
dpacktyp	bsr.w	DAPrintMnemonicNZ
	move.w	cw,EAD_cmd(a3)
	btst	#3,cw
	beq.b	.data
	bsr.w	DAPrintdt4
	bra.b	.ok

.data	bsr.w	DAPrintdt0
.ok	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	move.w	cw,d0
	rol.w	#7,d0
	move.w	d0,EAD_cmd(a3)
	move.w	(dsa)+,EAD_bd+2(a4)
	move.b	#1,EAD_bds(a4)
	moveq	#dt13,d1
	moveq	#dt0,d0
	btst	#3,cw
	beq.b	.data2
	moveq	#dt4,d0
.data2	moveq	#2,d5
	bra.w	DAPrintSDL


;entry with poi to cmp2 (but also code for chk2)
deatorn	move.w	(dsa)+,d5
	move.w	d5,d0
	and.w	#$0fff,d0
	beq.b	.cmp2
	cmp.w	#$0800,d0
	bne.w	DisassemNext
	lea	chk2dat(pc),a2	;check to chk2-data
.cmp2	move.w	cw,d0
	rol.w	#7,d0
	and.w	#%11,d0
	cmp.w	#%11,d0
	beq.w	DisassemNext
	bsr.w	DAPrintMnemonic
	rol.w	#4,d5
	move.w	d5,EAD_cmd(a4)
	moveq	#dt0,d1
	btst	#3,d5
	beq.b	.ok
	moveq	#dt1,d1
.ok	moveq	#2,d5
	move.l	#%1111111100100,d0
	bra.w	DAEASource

;cinvl/cinvp
dcachean	bsr.w	DAPrintMnemonicNZ
	move.w	cw,d0
	lsr.w	#5,d0
	and.w	#%110,d0
	move.l	a0,-(a7)
	lea	DACacheNames(pc,d0.w),a0
;	lea	(a0,d0.w),a0
	move.b	(a0)+,(a1)+
	move.b	(a0),(a1)+
	move.l	(a7)+,a0
	move.w	cw,d0
	and.w	#%11000,d0
	cmp.w	#%11000,d0
	beq.w	DisAssemExit
	move.b	#',',(a1)+
	moveq	#-1,d1
	moveq	#dt2,d0
	move.w	cw,EAD_cmd(a3)
	bra.w	DAPrintSD

DACacheNames	dc.b	'NC'
	dc.b	'DC'
	dc.b	'IC'
	dc.b	'BC'

;PScc
dpscc	lea	DAPrintMnempcc(pc),a3
dpsccmain	move.w	(dsa)+,d2
	moveq	#0,d0
	jsr	(a3)
	lea	EADataS(b),a3
	move.l	#%1100011111101,d0
	moveq	#-1,d1
	moveq	#2,d5
	bra.w	DAEASource
;PBcc
dpbcc	lea	DAPrintMnempcc(pc),a3
dpbccmain	move.w	cw,d2
	moveq	#1,d0
	btst	#6,cw
	beq.b	.word
	moveq	#2,d0
.word	jsr	(a3)
	lea	EADataS(b),a3
	moveq	#-1,d0
	btst	#6,cw
	bne.b	.long
	moveq	#0,d0
.long	move.w	d0,cw
	bra.w	dbccmain

;PDBcc
dpdbcc	lea	DAPrintMnempcc(pc),a3
dpdbccmain	moveq	#-1,d0
	move.w	(dsa)+,d2	;causing error! address++
	jsr	(a3)
	lea	EADataS(b),a3
	moveq	#4,d5
	bra.w	ddbccmain

;pflushn/pflush ('040)
dpostan	bsr.w	DAPrintMnemonicNZ
	move.w	cw,EAD_cmd(a3)
	bsr.w	DAPrintdt2
	bra.w	DisAssemExit

;skip next pflush-types
dpflushfix	lea	pflushdat(pc),a2
	bra.w	DisassemNext

;plush types
dpfrtyp	move.w	(dsa)+,d0	;check pflush-type
	moveq	#2,d5
	cmp.w	#$a000,d0
	bne.b	.dpflushr
	bsr.w	DAPrintMnemonicNZ
	move.l	#%11111111111100,d0;pflushr
	moveq	#-1,d1
	bra.w	DAEASource

.dpflushr	move.w	d0,d5	;temp storage
	cmp.w	#%0010010000000000,d0
	bne.b	.dpflusha
	lea	pflushadat(pc),a2
	bsr.w	DAPrintMnemonicNZ
	addq.b	#2,CmdLength(b)
	bra.w	DisAssemExit

.dpflusha	and.w	#%1111001000000000,d5
	cmp.w	#%0011000000000000,d5
	bne.w	DisassemNext
	lea	pflushdat(pc),a2
	btst	#10,d0
	beq.b	.ok
	lea	pflushsdat(pc),a2
.ok	move.w	d0,d5
	bsr.w	DAPrintMnemonicNZ
	bsr.b	dprintfc
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	ror.w	#5,d1
	and.w	#%1111,d1
	move.w	d1,EAD_bd+2(a3)
	move.b	#1,EAD_bds(a3)
	moveq	#dt13,d0
	moveq	#2,d5
	btst	#11,d0
	bne.b	.plusea
	moveq	#-1,d1
	bra.w	DAPrintSDL

.plusea	move.l	#%1100011100100,d1;also print ea
	bra.w	DAEADest

;print fc type - input in d5
dprintfc	move.w	d5,d1
	btst	#4,d5
	beq.b	.regs
	move.b	#'#',(a1)+
	move.b	#'$',(a1)+	;value
	and.w	#%1111,d5
	cmp.b	#9,d5
	ble.b	.nolet
	addq.w	#7,d5	;fix to A-F
.nolet	add.b	#'0',d5
	move.b	d5,(a1)+
	rts

.regs	btst	#3,d5
	beq.b	.fcregs
	move.w	d5,EAD_cmd(a3)	;Dn
	bra.w	DAPrintdt0

.fcregs	and.w	#%111,d5
	cmp.w	#%001,d5
	bgt.b	.quit
	asl.w	#3,d5
	move.l	a3,-(a7)	;SFC/DFC
	lea	EARegList(pc),a3
	add.w	d5,a3
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
	move.b	(a3)+,(a1)+
	move.l	(a7)+,a3
	rts

.quit	addq.w	#4,a7	;skip caller
	bra.w	DisassemNext

;pload
dfcear	move.w	(dsa)+,d0
	move.w	d0,d5
	and.w	#%1111111111100000,d0
	cmp.w	#%0010001000000000,d0
	beq.b	.read
	lea	ploadwdat(pc),a2
	cmp.w	#%0010000000000000,d0
	bne.w	DisassemNext
.read	bsr.w	DAPrintMnemonicNZ
	bsr.b	dprintfc
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	moveq	#2,d5
	moveq	#-1,d1
	move.l	#%1100011100100,d0
	bra.w	DAEASource

;pvalid
dvaltyp	move.w	(dsa)+,d0
	moveq	#2,d5
	cmp.w	#%0010100000000000,d0
	beq.b	.val
	move.w	d0,EAD_cmd(a3)
	and.w	#~%111,d0
	cmp.w	#%0010110000000000,d0
	bne.w	DisassemNext
	bsr.w	DAPrintMnemonicNZ
	moveq	#dt1,d0
	move.l	#%1100011100100,d1
	bra.w	DAEADest

.val	bsr.w	DAPrintMnemonicNZ
	move.b	#'V',(a1)+
	move.b	#'A',(a1)+
	move.b	#'L',(a1)+
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	moveq	#-1,d1
	move.l	#%1100011100100,d0
	bra.w	DAEASource
;ptrap
dpttyp	move.w	(dsa)+,d2
	move.w	d2,d0
	and.w	#~%111111,d0
	bne.w	DisassemNext
	lea	DAPrintMnempcc(pc),a3
dpttypmain	moveq	#-1,d0
	move.w	cw,d1
	and.w	#%111,d1
	cmp.w	#%100,d1
	beq.b	.ok
	moveq	#1,d0
	cmp.w	#%010,d1
	beq.b	.ok
	moveq	#2,d0
	cmp.w	#%011,d1
	bne.w	DisassemNext
.ok	jsr	(a3)
	lea	EADataS(b),a3
	addq.b	#2,CmdLength(b)
	tst.w	d0
	bmi.w	DisAssemExit
	move.b	d0,EAD_bds(a3)
	cmp.w	#2,d0
	beq.b	.long
	move.w	(dsa)+,EAD_bd+2(a3)
	moveq	#2,d5
.go	moveq	#dt13,d0
	moveq	#-1,d1
	bra.w	DAPrintSD

.long	moveq	#4,d5
	move.l	(dsa)+,EAD_bd(a3)
	bra.b	.go

;fnop
dfpunop	tst.w	(dsa)+
	bne.w	DisassemNext
	bsr.w	DAPrintMnemonicNZ
	addq.b	#2,CmdLength(b)
	bra.w	DisAssemExit

;FTRAPcc
dfputrap	move.w	(dsa)+,d2
	move.w	d2,d0
	and.w	#%1111111111100000,d0
	bne.w	DisassemNext
	lea	DAPrintMnemfcc(pc),a3
	bra.b	dpttypmain

;FBcc
dfpubcc	subq.w	#2,dsa	;correct fetch (coz now in menmf)
	lea	DAPrintMnemfcc(pc),a3
	bra.w	dpbccmain

;FDBcc
dfpudbcc	lea	DAPrintMnemfcc(pc),a3
	bra.w	dpdbccmain

;FScc
dfpuscc	subq.w	#2,dsa	;correct fetch (coz now in mnemf!)
	lea	DAPrintMnemfcc(pc),a3
	bra.w	dpsccmain

;FMOVECR
dfpucr	moveq	#5,d0
	bsr.w	DAPrintMnemonic
	move.w	d4,d0
	and.w	#%1111111,d0
	move.w	d0,EAD_bd+2(a3)
	clr.b	EAD_bds(a3)
	moveq	#dt13,d0
	ror.w	#7,d4
	move.w	d4,EAD_cmd(a4)
	moveq	#dt29,d1
	bra.w	DAPrintSD

;normal fpu command - dest not required
dfpun	moveq	#0,d5
dfpunmain	bsr.w	DAPrintFMnemonic
	btst	#14,d4
	bne.b	.useea
	move.w	cw,d0
	and.w	#%111111,d0	;check EA is all 0s
	bne.w	DisassemNext
	move.w	d4,d0
	rol.w	#6,d0
	ror.w	#7,d4
	moveq	#%111,d1
	and.w	d1,d0
	and.w	d1,d4
	moveq	#dt29,d1
	tst.w	d5
	bmi.b	.tworegs	;no single if d5 is neg
	cmp.w	d0,d4
	bne.b	.tworegs
	moveq	#-1,d1
.tworegs	move.w	d0,EAD_cmd(a3)
	move.w	d4,EAD_cmd(a4)
	moveq	#dt29,d0
	bra.w	DAPrintSD

.useea	ror.w	#7,d4
	move.w	d4,EAD_cmd(a4)
	moveq	#dt29,d1
dfpunmain2	move.w	cw,d0
	and.w	#%111000,d0
	bne.b	.checkdsize
	cmp.b	#3,DisSize(b)	;next if size of Dn is >.S
	bgt.w	DisassemNext
.checkdsize	move.l	#%11111111111101,d0
	bra.w	DAEASourceN

;FPU normal - destination required
dfpunsd	moveq	#-1,d5	;mark dest IS needed in printout
	bra.b	dfpunmain

;FTST
dfputst	bsr.w	DAPrintFMnemonic
	moveq	#-1,d1
	btst	#14,d4
	bne.b	dfpunmain2
	move.w	cw,d0
	and.w	#%111111,d0	;check EA is 0s
	bne.w	DisassemNext
	rol.w	#6,d4
	move.w	d4,EAD_cmd(a3)
	moveq	#dt29,d0
	bra.w	DAPrintSD

;FSINCOS
dfpuscos	bsr.w	DAPrintFMnemonic
	move.w	cw,EAD_cmd(a4)
	move.w	d4,d0
	ror.w	#7,d0
	move.w	d0,EAD_ext(a4)
	moveq	#dt30,d1
	btst	#14,d4
	bne.b	dfpunmain2
	rol.w	#6,d4
	move.w	d4,EAD_cmd(a3)
	moveq	#dt29,d0
	bra.w	DAPrintSD

;fmovem (#13=!#12)
dfpumm	moveq	#5,d0
	bsr.w	DAPrintMnemonic
	move.w	d4,d0
	moveq	#dt31,d1
	moveq	#EAD_ext,d2
	btst	#11,d4
	beq.b	.static
	ror.w	#4,d0
	moveq	#dt0,d1
	moveq	#EAD_cmd,d2
.static	btst	#13,d4
	bne.b	.dest
	clr.w	EAD_cmd(a4)
	move.w	d0,(a4,d2.w)
	move.l	#%1111111101100,d0
	bra.w	DAEASourceN

.dest	move.w	#-1,EAD_cmd(a3)
	move.w	d0,(a3,d2.w)
	move.l	#%1100011110100,d0
	exg	d0,d1
	bra.w	DAEADestN

;fmovemc
dfpummc	moveq	#2,d0
	bsr.w	DAPrintMnemonic
	move.w	d4,d1
	and.w	#%1110000000000,d1
	beq.w	DisassemNext	;if no regs chosen
	move.w	cw,d0
	and.w	#%111000,d0
	bne.b	.checksingle
	cmp.w	#%0010000000000,d1;check only one reg is used
	beq.b	.ok
	cmp.w	#%0100000000000,d1
	beq.b	.ok
	cmp.w	#%1000000000000,d1
	beq.b	.ok
	bra.w	DisassemNext

.checksingle	cmp.w	#%001000,d0	;An?
	bne.b	.ok
	cmp.w	#%0010000000000,d1
	bne.w	DisassemNext	;fail if not fpiar

.ok	btst	#13,d4
	beq.b	.tofpu
	move.w	d1,EAD_cmd(a3)
	moveq	#dt15,d0
	move.l	#%1100011111111,d1
	bra.w	DAEADestN

.tofpu	move.w	d1,EAD_cmd(a4)
	moveq	#dt15,d1
	move.l	#%11111111111111,d0
	bra.w	DAEASourceN


;fmovecr	
dfpummcr	moveq	#5,d0
	bsr.w	DAPrintMnemonic
	move.w	d4,d0
	and.w	#%1111111,d0
	move.w	d0,EAD_bd+2(a3)
	clr.b	EAD_bds(a3)
	moveq	#dt13,d0
	ror.w	#7,d4
	move.w	d4,EAD_cmd(a4)
	moveq	#29,d1
	bra.w	DAPrintSD

;fmove/fxmove
dfpum	move.w	d4,d0
	ror.w	#7,d0
	move.w	d0,EAD_cmd(a4)
	btst	#14,d4	;print size?
	bne.b	.printlen
	move.w	cw,d0
	and.w	#%111111,d0
	bne.w	DisassemNext
	moveq	#5,d0
	bsr.w	DAPrintMnemonic
	move.w	d4,d0
	rol.w	#6,d0
	move.w	d0,EAD_cmd(a3)
	moveq	#dt29,d0
	moveq	#dt29,d1
	bra.w	DAPrintSD

.printlen	bsr.w	DAPrintFMnemonic
	moveq	#dt29,d1
	bra.w	dfpunmain2


;fmove fpx,<ea>
dfpumtm	move.w	d4,d0
	ror.w	#7,d0
	move.w	d0,EAD_cmd(a3)
	moveq	#0,d1
	and.w	#%111000,d0
	cmp.w	#%011000,d0
	bne.b	.mark
	moveq	#-2,d1
.mark	cmp.w	#%111000,d0
	bne.b	.dynk
	bclr	#12,d4	;fix to normal .P
	moveq	#-1,d1	;-1=register
.dynk	move.b	d1,EAD_bds(a3)	;notice this signal to dt35!
	move.w	d4,EAD_ext(a3)

	movem.l	d4/a2,-(a7)
	move.l	a4,a2
	move.l	#%1100011111101,d0
	bsr.w	DAConvertEA	
	move.w	d4,d3
	movem.l	(a7)+,d4/a2

	bsr.w	DAPrintFMnemonic

	move.w	cw,d0	;if Dn, check b/w/l/s
	and.w	#%111000,d0
	bne.b	.checkdnsize
	cmp.b	#3,DisSize(b)
	bgt.w	DisassemNext

.checkdnsize	bsr.w	DAPrintdt29

	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	exg	a4,a3
	move.w	d3,d0
	bsr.w	CallSDTab	;get dest printed

	move.w	EAD_bds(a4),d0
	beq.b	.noextra
	move.b	#'{',(a1)+
	move.w	EAD_ext(a4),d1
	cmp.b	#-1,d0
	beq.b	.dynamic
	and.w	#%1111111,d1
	move.w	d1,EAD_bd+2(a3)
	clr.b	EAD_bds(a3)
	bsr.w	DAPrintdt13
	bra.b	.done

.dynamic	ror.w	#4,d1
	move.w	d1,EAD_cmd(a3)
	bsr.w	DAPrintdt0

.done	move.b	#'}',(a1)+
.noextra	bra.w	DisAssemExit


;PMOVE type 0
dpmovetype0	move.w	d4,d0
	rol.w	#6,d0
	and.w	#%111,d0	;check size
	beq.b	dpmovetypemain
	btst	#2,d0
	bne.b	dpmovetypemain
	move.w	cw,d1
	and.w	#%111000,d1
	cmp.w	#%001000,d1
	ble.w	DisassemNext
dpmovetypemain	btst	#8,d4
	bne.b	dpmovetypemain2
	move.l	#%11111111111111,d2
	move.l	#%01100011111111,d3
dpmovetypemain2	move.w	d0,EAD_ext(a4)
	move.l	a1,-(a7)	;get size from list
	lea	PMOVETYPES+7(pc),a1
	asl.w	#3,d0
	move.b	(a1,d0.w),d0
	move.l	(a7)+,a1
	bsr.w	DAPrintMnemonic	;print mnem

	moveq	#dt25,d1
	move.l	d2,d0
	btst	#9,d4
	beq.w	DAEASourceN
	move.l	d3,d1
	moveq	#dt25,d0
	move.w	EAD_ext(a4),EAD_ext(a3);move data over
	move.w	EAD_cmd(a4),EAD_cmd(a3)
	bra.w	DAEADestN

;pmove mmusr/psr/pcsr
dpmovetype1	moveq	#8,d0
dpmovetype1main	btst	#10,d4
	beq.b	dpmovetypemain
	addq.w	#1,d0
	bra.b	dpmovetypemain

;pmove badX/bacX
dpmovetype3	move.w	d4,d0
	lsr.w	#2,d0
	and.w	#%111,d0
	move.w	d0,EAD_cmd(a4)
	moveq	#12,d0
	bra.b	dpmovetype1main

;pmove/fd tt0/tt1 (only '030)
dpmovetype2	moveq	#10,d0
	move.l	#%1100011100100,d2
	move.l	d2,d3
	btst	#10,d4
	beq.b	dpmovetypemain2
	moveq	#11,d0
	bra.b   dpmovetypemain2

;pmovefd srp/crp/tc (only '030)
dpmovetype4	move.l	#%1100011100100,d2
	move.l	d2,d3
	move.w	d4,d0
	and.w	#%1110000000000,d0
	beq.w	dpmovetype0
	and.w	#%1100000000000,d0
	cmp.w	#%0100000000000,d0
	beq.w	dpmovetype0
	bra.w	DisassemNext

;ptest <WEIRD>
dptesttypeW	move.w	d4,d0
	and.w	#%11100000,d0	;must = 0
	lsr.w	#5,d0
	move.w	d0,EAD_cmd(a4)
	move.w	#dt1,EAD_type(a4)
	btst	#8,d4
	bne.b	.checkrest0
	tst.w	d0
	bne.w	DisassemNext
	move.w	#-1,EAD_type(a4)
.checkrest0	move.w	d4,d5
	bsr.w	DAPrintMnemonicNZ
	bsr.w	dprintfc
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	move.w	d4,GetSDBuff(b)
	moveq	#2,d5	;should it be 0?
	lea	EADataS(b),a2
	bsr.w	DAConvertEA
	move.l	#%1100011100100,d0
	btst	d4,d0
	beq.w	DisassemNext
	move.w	d4,d0
;	asl.w	#2,d0
	bsr.b	CallSDTab	;get EA printed
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	moveq	#dt13,d0
	move.w	GetSDBuff(b),d1
	move.w	d1,d2
	rol.w	#6,d1
	and.w	#%111,d1
	move.w	d1,EAD_bd+2(a3)
	clr.b	EAD_bds(a3)
	move.w	EAD_type(a4),d1
;	bra.b	DAPrintSDL

;---- test length before printing
DAPrintSDL	add.b	d5,CmdLength(b)

;----- Print SD to buffer
;-- d0/d1	- types (data in EAD-structures)
;-- a3/a4	- poi to registername in type dt14
;-----
DAPrintSD	tst.w	d7	;produce output?
	beq.w	DisAssemExit
	Push	d0-d3	;save for column 5/6 printer!
	move.w	d1,-(a7)
	asl.w	#2,d0
	jsr	DAPrintSDTab(pc,d0.w)
	moveq	#0,d0
	move.w	(a7)+,d0
	bmi.b	.DANoDest
	move.b	#',',(a1)+
	move.l	a1,DestPointer(b)
	move.l	a4,a3
	asl.w	#2,d0
	jsr	DAPrintSDTab(pc,d0.w)
.DANoDest	Pull	d0-d3
	moveq	#-1,d7	;reset output flag
	bra.w	DisAssemExit

CallSDTab	asl.w	#2,d0
	jmp	DAPrintSDTab(pc,d0.w);get it printed

;w;
DAPrintSDTab	bra.w	DAPrintdt0
	bra.w	DAPrintdt1
	bra.w	DAPrintdt2
	bra.w	DAPrintdt3
	bra.w	DAPrintdt4
	bra.w	DAPrintdt5
	bra.w	DAPrintdt6
	bra.w	DAPrintdt7
	bra.w	DAPrintdt8
	bra.w	DAPrintdt9
	bra.w	DAPrintdt7	;!
	bra.w	DAPrintdt11
	bra.w	DAPrintdt12
	bra.w	DAPrintdt13
	bra.w	DAPrintdt14
	bra.w	DAPrintdt15	;print fpucr regs
	bra.w	DAPrintdt16
	bra.w	DAPrintdt17
	bra.w	DAPrintdt18
	bra.w	DAPrintdt19
	bra.w	DAPrintdt20
	bra.w	DAPrintdt21
	bra.w	DAPrintdt22	;N/A
	bra.w	DAPrintdt23	;N/A
	bra.w	DAPrintdt24
	bra.w	DAPrintdt25
	bra.w	DAPrintdt26	;N/A
	bra.w	DAPrintdt27	;N/A
	bra.w	DAPrintdt28	;N/A
	bra.w	DAPrintdt29
	bra.w	DAPrintdt30
	bra.w	DAPrintdt31

	bra.w	DAPrintdt32
	bra.w	DAPrintdt33
	bra.w	DAPrintdt34

DAPrintdt0	moveq	#'D',d4	;print Dn
DAPrintType100	move.b	d4,(a1)+	;(do the Xn printing)
DAPrintType101	move.w	EAD_cmd(a3),d0
	and.w	#%111,d0
	add.b	#'0',d0
	move.b	d0,(a1)+
DAPrintdt22
DAPrintdt23
DAPrintdt26
DAPrintdt27
DAPrintdt28

	rts

;MMU registers
DAPrintdt25	lea	PMOVETYPES(pc),a2
	moveq	#0,d0
	move.w	EAD_ext(a3),d0
	asl.w	#3,d0
	lea	(a2,d0.w),a2
.copyloop	move.b	(a2)+,(a1)+
	cmp.b	#' ',(a2)
	bne.b	.copyloop
	cmp.w	#8*12,d0
	blt.b	.exit
	move.w	EAD_cmd(a3),d0	;add number if bad/bac
	add.b	#'0',d0
	move.b	d0,(a1)+
.exit	rts

;fpucr registers
DAPrintdt15	move.w	EAD_cmd(a3),d0
	lea	FPUCRegs(pc),a2
	moveq	#0,d1
	btst	#12,d0
	beq.b	.notused
	bsr.w	DAPrintText
	moveq	#'/',d1
.notused	lea	FPUCRegs+8(pc),a2
	btst	#11,d0
	beq.b	.notused2
	tst.b	d1
	beq.b	.none
	move.b	d1,(a1)+
.none	bsr.w	DAPrintText
	moveq	#'/',d1
.notused2	lea	FPUCRegs+16(pc),a2
	btst	#10,d0
	beq.b	.notused3
	tst.b	d1
	beq.b	.none2
	move.b	d1,(a1)+
.none2	bra.w	DAPrintText
.notused3	rts

DAPrintdt30	bsr.b	DAPrintdt29	;FPc:FPs
	move.w	EAD_ext(a3),EAD_cmd(a3)
	move.b	#':',(a1)+

DAPrintdt29	move.b	#'F',(a1)+	;fpx
	move.b	#'P',(a1)+
	bra.w	DAPrintType101


DAPrintdt1	moveq	#'A',d4	;An
	bra.w	DAPrintType100

;Dn:Dm
DAPrintdt24	bsr.w	DAPrintdt0
	move.w	EAD_ext(a3),EAD_cmd(a3)
	move.b	#':',(a1)+
	bra.w	DAPrintdt0

DAPrintdt2	move.b	#'(',(a1)+	;(An)
	moveq	#'A',d4
	bsr.w	DAPrintType100
	move.b	#')',(a1)+
	rts

DAPrintdt3	bsr.b	DAPrintdt2	;(An)+
	move.b	#'+',(a1)+
	rts

DAPrintdt4	move.b	#'-',(a1)+	;-(An)
	bra.b	DAPrintdt2

DAPrintdt5	move.w	EAD_bd+2(a3),d1
	bsr.b	DAPrintOW
	subq.w	#2,a1	;skip .W
	bra.b	DAPrintdt2	;do (An) after d16

DAPrintOW	move.b	pr_NegOffsets(b),d0
	beq.b	DAPrintD16	;should offset be sign-fixed?
	tst.w	d1	;yes, test sign
	bpl.b	DAPrintD16
	neg.w	d1	;if neg, negate and put -
	move.b	#'-',(a1)+
DAPrintD16	moveq	#3,d5	;start with 4 digits
DAPrintD	move.b	pr_LeadingZeros(b),d0;zap leading zeros?
	beq.b	.zapped
.zapem	move.w	d1,d4
	and.w	#$f000,d4	;test for digit
	bne.b	.zapped
	asl.w	#4,d1	;if none rol
	subq.w	#1,d5	;and skip digit (until 1 digit)
	bne.b	.zapem

.zapped	move.b	#'$',(a1)+
.printd16loop	rol.w	#4,d1	;print the offset
	move.w	d1,d4
	and.w	#$f,d4
	add.b	#'0',d4
	cmp.b	#'9',d4
	ble.b	.fix
	addq.w	#7,d4	;fix to A-F
.fix	move.b	d4,(a1)+
	dbra	d5,.printd16loop
	move.b	#'.',(a1)+
	move.b	#'W',(a1)+
	rts

DAPrintdt11	moveq	#0,d1
	move.w	EAD_bd+2(a3),d1

	move.l	d1,EAD_ea(a3)
	st.b	EAD_eavalid(a3)

	bra.b	DAPrintD16

;-- only for old d8/An-mode (and scale type?)
DAPrintdt6	move.b	EAD_ext+1(a3),d1
	move.b	pr_NegOffsets(b),d0;D8(An,Xn)
	beq.b	.fixsign	;should offset be sign-fixed?
	tst.b	d1	;yes, test sign
	bpl.b	.fixsign
	neg.b	d1	;if neg, negate and put -
	move.b	#'-',(a1)+
.fixsign	move.b	#'$',(a1)+
	move.b	d1,d4	;print D8
	lsr.b	#4,d1
	and.b	#$f,d1
	bne.b	.testzap
	move.b	pr_LeadingZeros(b),d0;zap leading zero?
	beq.b	.zapfirst
.testzap	add.b	#'0',d1
	cmp.b	#'9'+1,d1
	blt.b	.let
	addq.w	#7,d1	;fix to A-Z
.let	move.b	d1,(a1)+
.zapfirst	and.b	#$f,d4
	add.b	#'0',d4
	cmp.b	#'9'+1,d4
	blt.b	.let2
	addq.w	#7,d4	;fix to A-Z
.let2	move.b	d4,(a1)+
	bsr.w	DAPrintdt2	;print (An)
DAPrintXn	move.b	#',',-1(a1)	;replace ) with ,
DAPrintXnNC	moveq	#'A',d4	;determine X type (A/D)
	move.w	EAD_ext(a3),d0
	move.w	d0,d1
	bmi.b	.findX
	moveq	#'D',d4
.findX	rol.w	#4,d0	;and print Xn (BUGFIX 271192 ror)
	move.b	d4,(a1)+	;(do the Xn printing)
;	move.w	EAD_cmd(a3),d0
	and.w	#%111,d0
	add.b	#'0',d0
	move.b	d0,(a1)+
	move.b	#'.',(a1)+	;add size to that,
	moveq	#'W',d0
	btst	#11,d1
	beq.b	.findZ
	moveq	#'L',d0
.findZ	move.b	d0,(a1)+	;and we're finished

	and.w	#%11000000000,d1;print scale-factor
	beq.b	.noscale
	rol.w	#7,d1
	moveq	#'0',d0
	bset	d1,d0
	move.b	#'*',(a1)+
	move.b	d0,(a1)+

.noscale	move.b	#')',(a1)+
	rts

;---- for all the '020+ modes (also PC) (print inside par!)
DAPrintdt7	move.b	#'(',(a1)+
	moveq	#0,d6	;mark no []
	moveq	#0,d7	;mark no previous data (no , needed)
	move.w	EAD_ext(a3),d2
	move.w	d2,d0
	and.w	#%111,d0
	beq.b	.simple
	moveq	#-1,d6
	move.b	#'[',(a1)+
.simple			;fix PC offset here!
	move.w	EAD_cmd(a3),d0	;kinda nau
	btst	#3,d0
	beq.b	.nopcfix
	btst	#7,d2
	bne.b	.nopcfix	;not if zpc
	btst	#4,d2	;not if .w
	beq.b	.nopcfix
	subq.l	#2,EAD_bd(a3)	;fix wrong pc offset
.nopcfix	bsr.w	DAPrintBD
	move.w	EAD_cmd(a3),d0
	btst	#7,d2
	bne.b	.checkzpc
.fakepc	tst.w	d7
	beq.b	.nobaseset
	move.b	#',',(a1)+
.nobaseset	moveq	#-1,d7	;mark basereg
	btst	#3,d0	;tst An/PC
	bne.b	.setpc
	move.b	#'A',(a1)+
	and.w	#%111,d0
	add.b	#'0',d0
	move.b	d0,(a1)+
	bra.b	.baseregset

.setpc	move.b	#'P',(a1)+
	move.b	#'C',(a1)+
	bra.b	.baseregset

.checkzpc	btst	#3,d0	;check PC
	beq.b	.baseregset	;suppressed An-type!
	tst.w	d7
	beq.b	.nocom
	move.b	#',',(a1)+
.nocom	move.b	#'Z',(a1)+	;set ZPC
	moveq	#-1,d7
	bra.b	.setpc

.baseregset	tst.w	d6
	beq.b	.notcomplex
	btst	#2,d2
	beq.b	.notcomplex
	move.b	#']',(a1)+
	moveq	#0,d6	;flag ] is set
	moveq	#-1,d7

.notcomplex	btst	#6,d2	;test index
	bne.b	.noindex
	tst.w	d7
	beq.b	.noprev
	move.b	#',',(a1)+
.noprev	bsr.w	DAPrintXnNC
	moveq	#-1,d7
	subq.w	#1,a1	;skip )

.noindex	tst.w	d6
	beq.b	.notcomplex2
	move.b	#']',(a1)+
	moveq	#-1,d7	;mark , needed before od

.notcomplex2	bsr.b	DAPrintOD
	move.b	#')',(a1)+
	rts

DAPrintBD	move.w	EAD_ext(a3),d0
	ror.w	#4,d0
	move.l	EAD_bd(a3),d1

	move.l	d1,EAD_ea(a3)	;store ea
	st.b	EAD_eavalid(a3)

	bra.b	DAPrintOffset

DAPrintOD	move.w	EAD_ext(a3),d0
	move.l	EAD_od(a3),d1
	bclr.b	#3,EAD_cmd+1(a3);force An-type-prevents pc.w print...

DAPrintOffset	and.w	#%11,d0	;check size
	subq.w	#2,d0
	bpl.b	.printoffset	;illegal/no size
	rts

.printoffset	tst.w	d7
	beq.b	.noprev
	move.b	#',',(a1)+	;set , if needed!
.noprev	moveq	#-1,d7

	tst.w	d0	;word?
	bne.b	DAPrintOL

	btst	#3,EAD_cmd+1(a3);if PC, print long+write .w
	beq.w	DAPrintOW	;DAPrintOD clears this bit!
	bsr.b	DAPrintOL
	move.b	#'W',-1(a1)
	rts


DAPrintOL	move.b	pr_NegOffsets(b),d0
	beq.b	DAPrintD32	;should offset be sign-fixed?
	tst.l	d1	;yes, test sign
	bpl.b	DAPrintD32
	neg.l	d1	;if neg, negate and put -
	move.b	#'-',(a1)+
DAPrintD32	move.b	#'$',(a1)+
DAPrintD32N	moveq	#7,d5
	move.b	pr_LeadingZeros(b),d0;zap leading zeros?
	beq.b	DAPrintD32N2
.zapem	move.l	d1,d4
	and.l	#$f0000000,d4	;test for digit
	bne.b	DAPrintD32N2
	asl.l	#4,d1	;if none rol
	subq.w	#1,d5	;and skip digit (until 1 digit)
	bne.b	.zapem
DAPrintD32N2
.printd32loop	rol.l	#4,d1	;print the offset
	move.w	d1,d4
	and.w	#$f,d4
	add.b	#'0',d4
	cmp.b	#'9',d4
	ble.b	.fix
	addq.w	#7,d4	;fix to A-F
.fix	move.b	d4,(a1)+
	dbra	d5,.printd32loop
	move.b	#'.',(a1)+
	move.b	#'L',(a1)+
	rts

;(xxxx).l
DAPrintdt12	move.l	EAD_bd(a3),d1

	move.l	d1,EAD_ea(a3)	;set as valid ea
	st.b	EAD_eavalid(a3)

	bra.b	DAPrintD32

DAPrintdt9	bsr.b	DAPrintdt8
	move.b	#'B',-5(a1)
	bra.w	DAPrintXn	;xx(pc,Xn)

;-- calculated address in bd
DAPrintdt8	move.l	EAD_bd(a3),d1

	move.l	d1,EAD_ea(a3)
	st.b	EAD_eavalid(a3)

	bsr.b	DAPrintD32	;xxxx(pc) (271192, called Type8)
	move.b	#'W',-1(a1)
	move.b	#'(',(a1)+
	move.b	#'P',(a1)+
	move.b	#'C',(a1)+
	move.b	#')',(a1)+
	rts

;bds=size (also special fpu sizes!)
DAPrintdt13	move.b	#'#',(a1)+	;#xxxx
	move.l	EAD_bd(a3),d1
	move.b	EAD_bds(a3),d0
	cmp.b	#%01,d0
	ble.b	.findsize
	pea	.exit(pc)
	moveq	#0,d2	;flag for empty first long(s)
	cmp.b	#%100,d0	;also print long for .s
	blt.w	DAPrintD32
;check new sizes
	beq.b	.doublelong

	move.l	EAD_extra(a3),d1;get first long
	beq.b	.doublelong
	bsr.w	DAPrintD32	;get 1st printed
	subq.w	#2,a1
	moveq	#1,d2

.doublelong	move.l	EAD_bd(a3),d1
	tst.w	d2	;data written?
	bne.b	.checkdata
	tst.l	d1	;if not test if bits in next long
	beq.b	.nodata
	bsr.w	DAPrintD32
	subq.w	#2,a1
	moveq	#1,d2
	bra.b	.nodata

.checkdata	moveq	#7,d5
	bsr.w	DAPrintD32N2	;no skipping if number is printed
	subq.w	#2,a1

.nodata	move.l	EAD_od(a3),d1
	tst.w	d2
	bne.b	.checklast
	bra.w	DAPrintD32

.checklast	moveq	#7,d5
	bra.w	DAPrintD32N2

.findsize	beq.b	.word
	beq.w	DAPrintD16	;print word
	moveq	#1,d5
	asl.w	#8,d1	;put byte data in correct place(271192)
	bsr.w	DAPrintD	;print byte
	bra.b	.exit

.word	bsr.w	DAPrintD16
.exit	subq.w	#2,a1
	rts

DAPrintdt14	move.l	a3,a2	;beware! Fail if a3 is reset at entry!
	bra.b	DAPrintText

DAPrintdt17	lea	DATextCCR(pc),a2
DAPrintText	move.b	(a2)+,(a1)+
	cmp.b	#' ',(a2)
	bne.b	DAPrintText
	rts

DAPrintdt16	lea	DATextSR(pc),a2
	bra.b	DAPrintText

DAPrintdt20	lea	DATextUSP+1(pc),a2
	bra.b	DAPrintText

DAPrintdt18	lea	DATextUSP(pc),a2
	bra.b	DAPrintText

DAPrintdt19	lea	DATextSSP(pc),a2
	bra.b	DAPrintText

;d1 should contain 0=norm 1=predec mode
DAPrintdt21	move.w	EAD_ext(a3),d0	;reglist
	move.w	EAD_cmd(a3),d1
	moveq	#16,d2	;run through 17 times!
	moveq	#'D',d3
	move.l	d7,-(a7)
	moveq	#0,d7
DAPrintListMain	moveq	#'0',d4
	moveq	#0,d5
	moveq	#0,d6
.movemloop	tst.w	d1
	bne.b	.decrement
	lsr.w	#1,d0

.checkon	bcc.b	.nothing	;bit set?
	tst.w	d5	;any prev type?
	bne.b	.inserie
	move.b	#'/',(a1)+
	tst.b	d6
	bne.b	.firsttime
	subq.w	#1,a1	;zap '-'
	moveq	#1,d6	;only first entry!
.firsttime	move.b	d3,(a1)+
	tst.b	d7
	beq.b	.nostore
	move.b	d7,(a1)+
.nostore
	move.b	d4,(a1)+
	moveq	#1,d5	;flag start of serie
	bra.b	.geton

.inserie	moveq	#-1,d5	;mark unprinted regs
	bra.b	.geton

.decrement	add.w	d0,d0	;lsl.w #1,d0
	bra.b	.checkon

.nothing	tst.w	d5	;serie started?
	bpl.b	.getonzap
	move.b	#'-',(a1)+
	move.b	d3,(a1)+
	tst.b	d7
	beq.b	.nostore2
	move.b	d7,(a1)+
.nostore2
	move.b	d4,d6
	subq.b	#1,d6
	cmp.b	#'0',d6
	bge.b	.ok
	tst.w	d2	;check for last iteration
	beq.b	.mustbea
	move.b	#'D',-1(a1)	;set if last was D and not A
.mustbea	moveq	#'7',d6
.ok	move.b	d6,(a1)+
.getonzap	moveq	#0,d5	;flag no serie

.geton	addq.b	#1,d4
	cmp.b	#'8',d4
	bne.b	.changetype
	moveq	#'0',d4
	cmp.w	#'F',d3
	beq.b	.changetype
	moveq	#'A',d3
.changetype	dbra	d2,.movemloop
	move.l	(a7)+,d7
	rts

;---- fpu registerlist (list in d0)
DAPrintdt31	move.w	EAD_ext(a3),d0
	move.w	EAD_cmd(a3),d1
	beq.b	.reverse
	asl.w	#8,d0
.reverse	moveq	#'F',d3
	move.l	d7,-(a7)
	moveq	#'P',d7
	moveq	#8,d2
	bra.w	DAPrintListMain

;print 3 bit immediate
DAPrintdt32	move.b	#'#',(a1)+
	move.w	EAD_bd+2(a3),d1
	add.b	#'0',d1
	move.b	d1,(a1)+
	rts

;{offset:width}
DAPrintdt33	move.b	#'{',(a1)+
	moveq	#0,d1
	move.w	EAD_ext(a3),d0
	ror.w	#6,d0
	bsr.b	DAPrintdt33a
	move.b	#':',(a1)+
	moveq	#-1,d1
	move.w	EAD_ext(a3),d0
	bsr.b	DAPrintdt33a
	move.b	#'}',(a1)+
	rts

DAPrintdt33a	btst	#5,d0	;print dn/#5bit
	beq.b	DAPrintimm5
	move.w	d0,EAD_cmd(a3)
	bra.w	DAPrintdt0

DAPrintimm5	and.l	#%11111,d0	;print immidiate 5-bit data.
	tst.w	d1
	beq.b	.ok
	tst.w	d0
	bne.b	.ok
	moveq	#32,d0	;if width, 0=32
.ok	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,(a1)+
	swap	d0
	add.b	#'0',d0
	move.b	d0,(a1)+
	rts

;(Xn):(Xm)
DAPrintdt34	move.b	#'(',(a1)+
	move.w	EAD_cmd(a3),d0
	btst	#4,d0
	beq.b	.data
	bsr.w	DAPrintdt1
	bra.b	.ok
.data	bsr.w	DAPrintdt0
.ok	move.b	#')',(a1)+
	move.b	#':',(a1)+
	move.b	#'(',(a1)+
	move.w	EAD_ext(a3),d0
	move.w	d0,EAD_cmd(a3)
	pea	.lastpar(pc)
	btst	#4,d0
	beq.w	DAPrintdt0
	bra.w	DAPrintdt1

.lastpar	move.b	#')',(a1)+
	rts


;print with size from 6-7
DAPrintMnemonic6
	move.w	cw,d0
	lsr.w	#6,d0
	and.w	#%11,d0
	cmp.w	#%11,d0
	bne.b	DAPrintMnemonic	;check that size is correct
	addq.w	#4,a7	;if wrong skip caller
	bra.w	DisassemNext	;and goto next

DAPrintFMnemonic
	btst	#14,d4
	bne.b	.findsize
	moveq	#5,d0
	bra.b	DAPrintMnemonic

.findsize	move.w	d4,d0
	rol.w	#6,d0
	and.w	#%111,d0
	move.b	SizeTable2(pc,d0.w),d0
	bpl.b	DAPrintMnemonic

.ill	addq.w	#4,a7
	bra.w	DisassemNext

SizeTable2	dc.b	2,3,5,6,1,4,0,-1

;print without size
DAPrintMnemonicNZ
	moveq	#-1,d0	;no size
;---- Print mnemonic name
DAPrintMnemonic	move.b	d0,DisSize(b)	;save size for use later
	tst.w	d7	;produce output?
	bne.b	.dooutput
	rts

.dooutput	moveq	#DisColTab-1,d1
	move.l	a4,-(a7)
	lea	mn_Name(a2),a4
.putmnemonicnam	move.b	(a4)+,(a1)+
	beq.b	.done
	dbra	d1,.putmnemonicnam
	addq.w	#1,a1
	moveq	#0,d1
.done	move.l	(a7)+,a4
	subq.w	#1,a1
	move.w	d1,-(a7)	;save for tab
PrintSize	tst.w	d0
	bmi.b	.nosize
	move.b	SizeTable3(pc,d0.w),d1
.size	move.b	#'.',(a1)+
	move.b	d1,(a1)+
	subq.w	#2,(a7)	;sub 2 from len
.nosize
	move.w	(a7)+,d1
.tab	move.b	#' ',(a1)+
	dbra	d1,.tab
	rts

SizeTable3	dc.b	'bwlsdxp '

;---- Print Xcc.z menmonics
;-- input:	d0=size
;--	d2=-1 if skip bra/bsr =1 if DBcc call
;----
DAPrintMnemcc	moveq	#0,d2	;skip the bra/bsr checker
DAPrintMnemccS	tst.w	d7	;produce output?
	bne.b	.dooutput
	rts

.dooutput	moveq	#DisColTab-1,d1
	move.l	a4,-(a7)
	lea	mn_Name(a2),a4
.putmnemonicnam	move.b	(a4)+,(a1)+
	beq.b	.done
	dbra	d1,.putmnemonicnam
	addq.w	#1,a1
.done	subq.w	#1,a1
	move.l	(a7)+,a4
	move.w	d1,-(a7)	;save for tab

	move.w	cw,d1
	lsr.w	#8,d1
	and.w	#%1111,d1
	tst.w	d2
	bpl.b	.nocheck
	cmp.w	#1,d1	;check for bra/bsr (written out!)
	ble.b	.noset
.nocheck	tst.w	d2
	beq.b	.notdbcc
	cmp.w	#1,d1	;if dbcc ra is ok for f
	beq.b	.dbra
.notdbcc	moveq	#'f',d2
	cmp.w	#1,d1	;else check for t/f
	bgt.b	.dbcc
	beq.b	.t
	moveq	#'t',d2	;print t/f
.t	move.b	d2,(a1)+
	subq.w	#1,(a7)
	bra.b	PrintSize

.dbra	moveq	#0,d1

.dbcc	add.w	d1,d1
	move.l	a4,-(a7)
	lea	ccTypes(pc),a4
	add.w	d1,a4
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.l	(a7)+,a4
	subq.w	#2,(a7)	;extra bytes written
.noset	bra.w	PrintSize

;cc in d2
DAPrintMnempcc	tst.w	d7	;produce output?
	bne.b	.dooutput
	rts

.dooutput	move.l	a4,-(a7)
	moveq	#DisColTab-1-2,d1
	lea	mn_Name(a2),a4
.putmnemonicnam	move.b	(a4)+,(a1)+
	beq.b	.done
	dbra	d1,.putmnemonicnam
	addq.w	#1,a1
.done	subq.w	#1,a1
	and.w	#%1111,d2
	lea	pccTypes(pc),a4
	add.w	d2,d2
	move.w	(a4,d2.w),d2

	move.l	(a7)+,a4
	move.w	d1,-(a7)	;save for tab

	move.b	d2,1(a1)
	ror.w	#8,d2
	move.b	d2,(a1)
	addq.w	#2,a1
	bra.w	PrintSize

;cc in d2
DAPrintMnemfcc	tst.w	d7	;produce output?
	bne.b	.dooutput
	rts

.dooutput	move.l	a4,-(a7)
	moveq	#DisColTab-1,d1
	lea	mn_Name(a2),a4
.putmnemonicnam	move.b	(a4)+,(a1)+
	beq.b	.done
	dbra	d1,.putmnemonicnam
	addq.w	#1,a1
.done	subq.w	#1,a1
	and.w	#%11111,d2
	lea	fccTypes(pc),a4
	mulu.w	#6,d2
	move.l	(a4,d2.w),d2

	move.l	(a7)+,a4

	moveq	#3,d3
.putccloop	rol.l	#8,d2
	cmp.b	#' ',d2
	beq.b	.end
	move.b	d2,(a1)+
	subq.w	#1,d1
	dbra	d3,.putccloop

.end	move.w	d1,-(a7)	;save for tab
	bra.w	PrintSize


;-----------------------------------------------------------------------------;
;- END - END - END - END- M680x0/M6888x/M68851 Diassembler - END - END - END	-;
;-----------------------------------------------------------------------------;

;	dc.b	MnemonicLen
;	dc.b	'Mnemonic'

	rsreset		;define encoding types
;	rs.w	2	;coz bra.w $xxxx.l takes 4 bytes
;	any changes to this table must also be changed in the jumptable
permove	rs.w	2
eatoan	rs.w	2
eatoan2	rs.w	2	;used by lea
eatoan3	rs.w	2	;used by movea
mulmove	rs.w	2
itodn	rs.w	2	;8 bits
eatoea	rs.w	2
itoea	rs.w	2	;also check ccr...
eadnea	rs.w	2	;ea to dn / dn to ea (or/and)
eadnea2	rs.w	2	;ea to dn / dn to ea (add/sub)
dnitoea	rs.w	2	;eor
regmem	rs.w	2	;dx,dy/-(ax),-(ay)
i3toea	rs.w	2	;3 i bits
anpanp	rs.w	2	;(Ax)+,(Ay)+
ceatodn	rs.w	2	;cmp
eatodn	rs.w	2	;chk
eatorncmp	rs.w	2	;cmp2
eatorn	rs.w	2	;chk2
eatodnm	rs.w	2	;divu/mulu
eatodnls	rs.w	2	;divsl
eatodnlu	rs.w	2	;divul
ccea	rs.w	2	;Scc <ea>
dbcc	rs.w	2	;DBcc Dn,<address>
bcc	rs.w	2	;Bcc <address>
none	rs.w	2	;no source/dest
ea	rs.w	2
ea2	rs.w	2
ea3	rs.w	2
ea4	rs.w	2
ea5	rs.w	2	;cpRestore
ea6	rs.w	2	;cpSave
shift	rs.w	2
dn	rs.w	2
dn2	rs.w	2
dn2B	rs.w	2	;extb
linktyp	rs.w	2
an	rs.w	2
idata	rs.w	2
traptyp	rs.w	2	;trap
tvtyp	rs.w	2	;trapv - special check needed in ass
rxry	rs.w	2	;exg
dctyp	rs.w	2	;dc.z
dcbtyp	rs.w	2	;dcb.z
bitms	rs.w	2	;for static data
bxx	rs.w	2
field	rs.w	2
field2	rs.w	2
field3	rs.w	2
imm3	rs.w	2	;bkpt
callmt	rs.w	2	;callm
dcduea	rs.w	2	;cas
castyp	rs.w	2	;cas2
lmove	rs.w	2	;move16
packtyp	rs.w	2	;pack
valtyp	rs.w	2	;pvalid
i16	rs.w	2	;rtd
xntyp	rs.w	2	;rtm
cache	rs.w	2	;<caches>
cachean	rs.w	2	;<caches>,(An)
movc	rs.w	2	;movec
movs	rs.w	2	;moves
pbcc	rs.w	2
pdbcc	rs.w	2
postan	rs.w	2	;(An)
pfatyp	rs.w	2
pftyp	rs.w	2	;pflush
pfstyp	rs.w	2	;pflushs
pfrtyp	rs.w	2	;pflushr
pscc	rs.w	2	;pscc
fcear	rs.w	2	;FC to EA (read)
fceaw	rs.w	2	;FC to EA (write)
pttyp	rs.w	2	;ptrapcc
fpubcc	rs.w	2	;FPUBcc
fpudbcc	rs.w	2	;FPUDBcc
fpuscc	rs.w	2	;FPUScc
fpunop	rs.w	2	;FNOP
fputrap	rs.w	2	;FTRAPcc
fpun	rs.w	2	;FPU normal (ea,fpn/fpn,fpm/fpn)
fpunsd	rs.w	2	;FPU s&d normal (ea,fpn/fpm,fpn)
fputst	rs.w	2	;FTST
fpuscos	rs.w	2	;FSINCOS
fpucr	rs.w	2	;FMOVECR
fpumm	rs.w	2	;FMOVEM (regs & cr)
fpum	rs.w	2	;FMOVE
fpumea	rs.w	2	;FxMOVE
pmovtp0	rs.w	2	;PMOVE type 0
pmovtp4	rs.w	2	;PMOVE type 4 (FD)
ptsttp1	rs.w	2	;PTEST (An)

ptsttp0	rs.w	2	;PTEST weird EA	;d

pmovtp1	rs.w	2	;PMOVE type 1	;d
pmovtp2	rs.w	2	;PMOVE type 2	;d
pmovtp3	rs.w	2	;PMOVE type 3	;d

trapcd	rs.w	2	;TRAPcc	d
lmoved	rs.w	2	;move16	d
eatodnl2	rs.w	2	;mulu/muls.l	d
linktyp2	rs.w	2	;link.l	d
bitm	rs.w	2	;reg-bitmanipulation	d

fpummc	rs.w	2	;FMOVEM cr	d
fpumtm	rs.w	2	;fmove fpx,<ea>	d
eatosr	rs.w	2	;ONLY DISASSEMBLE
antousp	rs.w	2	;ONLY DISASSEMBLE
itosr	rs.w	2	;ONLY DISASSEMBLE
itoccr	rs.w	2	;ONLY DISASSEMBLE
shift2	rs.w	2	;ONLY DISASSEMBLE

; cpXXX instructions NOT included!

DTableF	dc.w	m000-mb	;coprocessor
	dc.w	m001-mb
	dc.w	m022-mb
	dc.w	m023-mb
	dc.w	m024-mb
	dc.w	m025-mb
	dc.w	m121-mb
	dc.w	m122-mb
	dc.w	m123-mb
	dc.w	m124-mb
	dc.w	m125-mb
	dc.w	m126-mb
	dc.w	m127-mb
	dc.w	m128-mb
	dc.w	m129-mb
	dc.w	m130-mb
	dc.w	m131-mb
	dc.w	m132-mb
	dc.w	m133-mb
	dc.w	m134-mb
	dc.w	m135-mb
	dc.w	m136-mb
	dc.w	m137-mb
	dc.w	m138-mb
	dc.w	m139-mb
	dc.w	m140-mb
	dc.w	m141-mb
	dc.w	m142-mb
	dc.w	m143-mb
	dc.w	m144-mb
	dc.w	m145-mb
	dc.w	m148-mb
	dc.w	m151-mb,m152-mb,m153-mb,m154-mb,m155-mb
	dc.w	m156-mb,m157-mb,m158-mb,m159-mb,m160-mb
	dc.w	m161-mb,m162-mb,m163-mb,m164-mb,m165-mb
	dc.w	m166-mb,m167-mb,m168-mb,m169-mb,m170-mb
	dc.w	m171-mb,m172-mb,m173-mb,m174-mb,m175-mb
	dc.w	m176-mb,m177-mb,m178-mb,m179-mb,m180-mb
	dc.w	m181-mb,m182-mb,m183-mb,m184-mb,m185-mb
	dc.w	m186-mb,m187-mb,m188-mb,m189-mb,m190-mb
	dc.w	m191-mb,m192-mb,m193-mb,m194-mb,m195-mb
	dc.w	m196-mb,m197-mb,m198-mb,m199-mb,m200-mb
	dc.w	m201-mb,m202-mb,m203-mb,m204-mb,m205-mb
	dc.w	m206-mb,m207-mb,m208-mb,m209-mb,m210-mb
	dc.w	m211-mb,m212-mb,m213-mb,m214-mb,m215-mb
	dc.w	m216-mb,m217-mb
DTableFExit	dc.w	m219-mb

DTableE	dc.w	m059-mb	;shift/rotate/bitfield
	dc.w	m060-mb
	dc.w	m061-mb
	dc.w	m062-mb
	dc.w	m063-mb
	dc.w	m064-mb
	dc.w	m065-mb
	dc.w	m066-mb
	dc.w	m067-mb
	dc.w	m068-mb
	dc.w	m069-mb
	dc.w	m070-mb
	dc.w	m071-mb
	dc.w	m072-mb
	dc.w	m073-mb
	dc.w	m074-mb
	dc.w	m107-mb
	dc.w	m108-mb
	dc.w	m109-mb
	dc.w	m110-mb
	dc.w	m111-mb
	dc.w	m112-mb
	dc.w	m113-mb
	dc.w	m114-mb
	dc.w	m219-mb

DTableD	dc.w	m039-mb	;add/addx
	dc.w	m040-mb
	dc.w	m042-mb
	dc.w	m219-mb

DTableC	dc.w	m033-mb	;and/mul/abcd/exg
	dc.w	m089-mb
	dc.w	m091-mb
	dc.w	m097-mb
	dc.w	m098-mb
	dc.w	m219-mb

DTableB	dc.w	m037-mb	;cmp/eor
	dc.w	m050-mb
	dc.w	m051-mb
	dc.w	m052-mb
DTableA	dc.w	m219-mb	;ALine !!

DTable9	dc.w	m044-mb	;sub/subx
	dc.w	m045-mb
	dc.w	m047-mb
	dc.w	m219-mb

DTable8	dc.w	m029-mb	;or/div/sbdc
	dc.w	m086-mb
	dc.w	m088-mb
	dc.w	m096-mb
	dc.w	m119-mb
	dc.w	m120-mb
	dc.w	m219-mb

DTable7	dc.w	m006-mb	;moveq
	dc.w	m219-mb

DTable6	dc.w	m053-mb	;Bcc/bsr/bra
	dc.w	m054-mb
	dc.w	m150-mb
	dc.w	m219-mb

DTable5	dc.w	m019-mb	;addq/subq/Scc/DBcc/Trap
	dc.w	m041-mb
	dc.w	m046-mb
	dc.w	m146-mb
	dc.w	m149-mb
	dc.w	m219-mb

DTable4	dc.w	m002-mb	;miscellaneous
	dc.w	m003-mb
	dc.w	m008-mb
	dc.w	m009-mb
	dc.w	m010-mb
	dc.w	m011-mb
	dc.w	m012-mb
	dc.w	m013-mb
	dc.w	m015-mb
	dc.w	m016-mb
	dc.w	m017-mb
	dc.w	m018-mb
	dc.w	m020-mb
	dc.w	m021-mb
	dc.w	m055-mb
	dc.w	m056-mb
	dc.w	m057-mb
	dc.w	m058-mb
	dc.w	m075-mb
	dc.w	m077-mb
	dc.w	m078-mb
	dc.w	m079-mb
	dc.w	m080-mb
	dc.w	m081-mb
	dc.w	m082-mb
	dc.w	m083-mb
	dc.w	m084-mb
	dc.w	m085-mb
	dc.w	m087-mb
	dc.w	m090-mb
	dc.w	m092-mb
	dc.w	m093-mb
	dc.w	m094-mb
	dc.w	m095-mb
	dc.w	m115-mb
	dc.w	m147-mb
	dc.w	m219-mb

DTable2
DTable3	dc.w	m005-mb	;movea/move.w/l
DTable1	dc.w	m007-mb	;move.b
	dc.w	m219-mb

DTable0	dc.w	m004-mb	;movep/bitmanipulation/immediate
	dc.w	m007-mb
	dc.w	m014-mb
	dc.w	m026-mb
	dc.w	m027-mb
	dc.w	m028-mb
	dc.w	m030-mb
	dc.w	m031-mb
	dc.w	m032-mb
	dc.w	m034-mb
	dc.w	m035-mb
	dc.w	m036-mb
	dc.w	m038-mb
	dc.w	m043-mb
	dc.w	m048-mb
	dc.w	m049-mb
	dc.w	m076-mb
	dc.w	m099-mb
	dc.w	m100-mb
	dc.w	m101-mb
	dc.w	m102-mb
	dc.w	m103-mb
	dc.w	m104-mb
	dc.w	m105-mb
	dc.w	m106-mb
	dc.w	m116-mb
	dc.w	m117-mb
	dc.w	m118-mb
	dc.w	m219-mb

M68kMnemonics
CPUStart
mb	;mbase
m000	mnem	'move16',lmove,	%1111011000000000,%1111111111100000
m001	mnem	'move16',lmoved,%1111011000100000,%1111111111111000;dis
m002	mnem	'movec',movc,	%0100111001111010,$fffe
m003	mnem	'movem',mulmove,%0100100010000000,%1111101110000000
m004	mnem	'movep',permove,%0000000100001000,%1111000100111000
m005	mnem	'movea',eatoan3,%0010000001000000,%1110000111000000
m006	mnem	'moveq',itodn,	%0111000000000000,%1111000100000000
m007	mnem	'move',eatoea,	%0000000000000000,%1100000000000000
m008	mnem	'move',antousp,	%0100111001100000,%1111111111110000;dis
m009	mnem	'move',eatosr,	%0100000011000000,%1111100111000000;dis

m010	mnem	'rte',none,	%0100111001110011,$ffff
m011	mnem	'rts',none,	%0100111001110101,$ffff
m012	mnem	'rtr',none,	%0100111001110111,$ffff
m013	mnem	'rtd',i16,	%0100111001110100,$ffff
m014	mnem	'rtm',xntyp,	%0000011011000000,$fff0

m015	mnem	'illegal',none,	%0100101011111100,$ffff
m016	mnem	'trapv',tvtyp,	%0100111001110110,$ffff
m017	mnem	'stop',idata,	%0100111001110010,$ffff
m018	mnem	'trap',traptyp,	%0100111001000000,$fff0
m019	mnem	'trap',trapcd,	%0101000011111000,%1111000011111000;dis

m020	mnem	'reset',none,	%0100111001110000,$ffff
m021	mnem	'nop',none,	%0100111001110001,$ffff
m022	mnem	'pflushan4',none,%1111010100010000,$ffff
m023	mnem	'pflusha4',none,%1111010100011000,$ffff
m024	mnem	'ptestw',ptsttp1,%1111010101001000,%1111111111111000
m025	mnem	'ptestr',ptsttp1,%1111010101101000,%1111111111111000
m026	mnem	'ori',itoea,	%0000000000000000,$ff00
m027	mnem	'ori',itosr,	%0000000001111100,$ffff;dis
m028	mnem	'ori',itoccr,	%0000000000111100,$ffff;dis
m029	mnem	'or',eadnea,	%1000000000000000,$f000
m030	mnem	'andi',itoea,	%0000001000000000,$ff00
m031	mnem	'andi',itosr,	%0000001001111100,$ffff;dis
m032	mnem	'andi',itoccr,	%0000001000111100,$ffff;dis
m033	mnem	'and',eadnea,	%1100000000000000,$f000
m034	mnem	'eori',itoea,	%0000101000000000,$ff00
m035	mnem	'eori',itosr,	%0000101001111100,$ffff;dis
m036	mnem	'eori',itoccr,	%0000101000111100,$ffff;dis
m037	mnem	'eor',dnitoea,	%1011000100000000,%1111000100000000
m038	mnem	'addi',itoea,	%0000011000000000,$ff00
m039	mnem	'adda',eatoan,	%1101000011000000,%1111000011000000
m040	mnem	'addx',regmem,	%1101000100000000,%1111000100110000
m041	mnem	'addq',i3toea,	%0101000000000000,%1111000100000000
m042	mnem	'add',eadnea2,	%1101000000000000,$f000
m043	mnem	'subi',itoea,	%0000010000000000,$ff00
m044	mnem	'suba',eatoan,	%1001000011000000,%1111000011000000
m045	mnem	'subx',regmem,	%1001000100000000,%1111000100110000
m046	mnem	'subq',i3toea,	%0101000100000000,%1111000100000000
m047	mnem	'sub',eadnea2,	%1001000000000000,$f000
m048	mnem	'cmpi',itoea,	%0000110000000000,$ff00
m049	mnem	'cmp2',eatorncmp,%0000000011000000,%1111100111000000
m050	mnem	'cmpm',anpanp,	%1011000100001000,%1111000100111000
m051	mnem	'cmpa',eatoan,	%1011000011000000,%1111000011000000
m052	mnem	'cmp',ceatodn,	%1011000000000000,$f000

m053	mnem	'bra',bxx,	%0110000000000000,$ff00
m054	mnem	'bsr',bxx,	%0110000100000000,$ff00
m055	mnem	'jsr',ea,	%0100111010000000,%1111111111000000
m056	mnem	'jmp',ea,	%0100111011000000,%1111111111000000

m057	mnem	'lea',eatoan2,	%0100000111000000,%1111000111000000
m058	mnem	'pea',ea,	%0100100001000000,%1111111111000000
m059	mnem	'lsr',shift,	%1110001011000000,%1111111111000000
m060	mnem	'lsr',shift2,	%1110000000001000,%1111000100011000;dis
m061	mnem	'lsl',shift,	%1110001111000000,%1111111111000000
m062	mnem	'lsl',shift2,	%1110000100001000,%1111000100011000;dis
m063	mnem	'asr',shift,	%1110000011000000,%1111111111000000
m064	mnem	'asr',shift2,	%1110000000000000,%1111000100011000;dis
m065	mnem	'asl',shift,	%1110000111000000,%1111111111000000
m066	mnem	'asl',shift2,	%1110000100000000,%1111000100011000;dis
m067	mnem	'ror',shift,	%1110011011000000,%1111111111000000
m068	mnem	'ror',shift2,	%1110000000011000,%1111000100011000;dis
m069	mnem	'rol',shift,	%1110011111000000,%1111111111000000
m070	mnem	'rol',shift2,	%1110000100011000,%1111000100011000;dis
m071	mnem	'roxr',shift,	%1110010011000000,%1111111111000000
m072	mnem	'roxr',shift2,	%1110000000010000,%1111000100011000;dis
m073	mnem	'roxl',shift,	%1110010111000000,%1111111111000000
m074	mnem	'roxl',shift2,	%1110000100010000,%1111000100011000;dis
m075	mnem	'clr',ea2,	%0100001000000000,%1111111100000000
chk2dat
m076	mnem	'chk2',eatorn,	%0000000011000000,%1111100111000000
m077	mnem	'chk',eatodn,	%0100000100000000,%1111000101000000
m078	mnem	'negx',ea2,	%0100000000000000,$ff00
m079	mnem	'neg',ea2,	%0100010000000000,$ff00
m080	mnem	'not',ea2,	%0100011000000000,$ff00
m081	mnem	'swap',dn,	%0100100001000000,%1111111111111000
m082	mnem	'tst',ea4,	%0100101000000000,$ff00
m083	mnem	'extb',dn2B,	%0100100111000000,%1111111111111000
m084	mnem	'ext',dn2,	%0100100010000000,%1111111110111000
divuldat
m085	mnem	'divul',eatodnlu,%0100110001000000,%1111111111000000
m086	mnem	'divu',eatodnm,	%1000000011000000,%1111000111000000;^
divsldat
m087	mnem	'divsl',eatodnls,%0100110001000000,%1111111111000000
m088	mnem	'divs',eatodnm,	%1000000111000000,%1111000111000000;^
m089	mnem	'mulu',eatodnm,	%1100000011000000,%1111000111000000
m090	mnem	'mulu',eatodnl2,%0100110000000000,%1111111111000000;dis (also muls)
m091	mnem	'muls',eatodnm,	%1100000111000000,%1111000111000000;^
m092	mnem	'link',linktyp,	%0100111001010000,%1111111111111000
m093	mnem	'link',linktyp2,%0100100000001000,%1111111111111000;dis
m094	mnem	'unlk',an,	%0100111001011000,%1111111111111000
m095	mnem	'nbcd',ea3,	%0100100000000000,%1111111111000000
m096	mnem	'sbcd',regmem,	%1000000100000000,%1111000111110000
m097	mnem	'abcd',regmem,	%1100000100000000,%1111000111110000
m098	mnem	'exg',rxry,	%1100000100000000,%1111000100110000
m099	mnem	'bchg',bitms,	%0000100001000000,%1111111111000000;s
m100	mnem	'bclr',bitms,	%0000100010000000,%1111111111000000;s
m101	mnem	'bset',bitms,	%0000100011000000,%1111111111000000;s
m102	mnem	'btst',bitms,	%0000100000000000,%1111111111000000;s
m103	mnem	'bchg',bitm,	%0000000101000000,%1111000111000000;dis
m104	mnem	'bclr',bitm,	%0000000110000000,%1111000111000000;dis
m105	mnem	'bset',bitm,	%0000000111000000,%1111000111000000;dis
m106	mnem	'btst',bitm,	%0000000100000000,%1111000111000000;dis
;'010+
m107	mnem	'bfchg',field,	%1110101011000000,%1111111111000000
m108	mnem	'bfclr',field,	%1110110011000000,%1111111111000000
m109	mnem	'bfexts',field2,%1110101111000000,%1111111111000000
m110	mnem	'bfextu',field2,%1110100111000000,%1111111111000000
m111	mnem	'bfffo',field2,	%1110110111000000,%1111111111000000
m112	mnem	'bfins',field3,	%1110111111000000,%1111111111000000
m113	mnem	'bfset',field,	%1110111011000000,%1111111111000000
m114	mnem	'bftst',field,	%1110100011000000,%1111111111000000

m115	mnem	'bkpt',imm3,	%0100100001001000,%1111111111111000

m116	mnem	'callm',callmt,	%0000011011000000,%1111111111000000

m117	mnem	'cas2',dcduea,	%0000110011111100,%1111110111111111
m118	mnem	'cas',castyp,	%0000100011000000,%1111100111000000
m119	mnem	'pack',packtyp,	%1000000101000000,%1111000111110000
m120	mnem	'unpk',packtyp,	%1000000110000000,%1111000111110000
m121	mnem	'cinvl',cachean,%1111010000001000,%1111111100111000
m122	mnem	'cinvp',cachean,%1111010000010000,%1111111100111000
m123	mnem	'cinva',cache,	%1111010000011000,%1111111100111000
m124	mnem	'cpushl',cachean,%1111010000101000,%1111111100111000
m125	mnem	'cpushp',cachean,%1111010000110000,%1111111100111000
m126	mnem	'cpusha',cache,	%1111010000111000,%1111111100111000
m127	mnem	'prestore',ea5,	%1111000101000000,%1111111111000000
m128	mnem	'psave',ea6,	%1111000100000000,%1111111111000000
m129	mnem	'ps',pscc,	%1111000001000000,%1111111111000000

m130	mnem	'pb',pbcc,	%1111000010000000,%1111111110000000
m131	mnem	'pdb',pdbcc,	%1111000001001000,%1111111111111000

m132	mnem	'pflushn4',postan,%1111010100000000,%1111111111111000
m133	mnem	'pflush4',postan,%1111010100001000,%1111111111111000

m134	mnem	'pflushr',pfrtyp,%1111000000000000,%1111111111000000
pflushadat
m135	mnem	'pflusha',pfatyp,%1111000000000000,%1111111111000000
pflushsdat
m136	mnem	'pflushs',pfstyp,%1111000000000000,%1111111111000000
pflushdat
m137	mnem	'pflush',pftyp,	%1111000000000000,%1111111111000000

m138	mnem	'ploadr',fcear,%1111000000000000,%1111111111000000
ploadwdat
m139	mnem	'ploadw',fceaw,%1111000000000000,%1111111111000000

;MMU
m140	mnem	'pvalid',valtyp,%1111000000000000,%1111111111000000

m141	mnem	'ptrap',pttyp,%1111000001111000,%1111111111111000
m142	mnem	'ftrap',fputrap,%1111001001111000,%1111111111111000

m143	mnem	'frestore',ea5,	%1111001101000000,%1111111111000000
m144	mnem	'fsave',ea6,	%1111001100000000,%1111111111000000
m145	mnem	'fnop',fpunop,	%1111001010000000,%1111111111111111
m146	mnem	's',ccea,	%0101000011000000,%1111000011000000
m147	mnem	'tas',ea3,	%0100101011000000,%1111111111000000

m148	mnem	'fdb',fpudbcc,	%1111001001001000,%1111111111111000
m149	mnem	'db',dbcc,	%0101000011001000,%1111000011111000
m150	mnem	'b',bcc,	%0110000000000000,$f000
CPUEnd
	dc.w	-2
FPUStart
mlong	;mark start of long structures
DMnemBreak=151	;offset of command below!!!!!
m151	mnemf	'fmovecr',fpucr,$f200,$ffff,%0101110000000000,%1111110000000000
m152	mnemfn	'fabs',fpun,	%0000000000011000,%1010000001111111
m153	mnemfn	'fsabs',fpun,	%0000000001011000,%1010000001111111
m154	mnemfn	'fdabs',fpun,	%0000000001011100,%1010000001111111
m155	mnemfn	'fcosh',fpun,	%0000000000011001,%1010000001111111
m156	mnemfn	'fcos',fpun,	%0000000000011101,%1010000001111111
m157	mnemfn	'facos',fpun,	%0000000000011100,%1010000001111111
m158	mnemfn	'fsincos',fpuscos,%0000000000110000,%1010000001111000
m159	mnemfn	'fsinh',fpun,	%0000000000000010,%1010000001111111
m160	mnemfn	'fsin',fpun,	%0000000000001110,%1010000001111111

m161	mnemfn	'fasin',fpun,	%0000000000001100,%1010000001111111
m162	mnemfn	'ftanh',fpun,	%0000000000001001,%1010000001111111
m163	mnemfn	'ftan',fpun,	%0000000000001111,%1010000001111111
m164	mnemfn	'fatanh',fpun,	%0000000000001101,%1010000001111111
m165	mnemfn	'fatan',fpun,	%0000000000001010,%1010000001111111
m166	mnemfn	'fetox',fpun,	%0000000000010000,%1010000001111111
m167	mnemfn	'fgetexp',fpun,	%0000000000011110,%1010000001111111
m168	mnemfn	'fgetman',fpun,	%0000000000011111,%1010000001111111
m169	mnemfn	'fintrz',fpun,	%0000000000000011,%1010000001111111
m170	mnemfn	'fint',fpun,	%0000000000000001,%1010000001111111

m171	mnemfn	'flog10',fpun,	%0000000000010101,%1010000001111111
m172	mnemfn	'flog2',fpun,	%0000000000010110,%1010000001111111
m173	mnemfn	'flognp1',fpun,	%0000000000000110,%1010000001111111
m174	mnemfn	'flogn',fpun,	%0000000000010100,%1010000001111111
m175	mnemfn	'fneg',fpun,	%0000000000011010,%1010000001111111
m176	mnemfn	'fsneg',fpun,	%0000000001011010,%1010000001111111
m177	mnemfn	'fdneg',fpun,	%0000000001011110,%1010000001111111
m178	mnemfn	'fsqrt',fpun,	%0000000000000100,%1010000001111111
m179	mnemfn	'fssqrt',fpun,	%0000000001000001,%1010000001111111
m180	mnemfn	'fdsqrt',fpun,	%0000000001000101,%1010000001111111

m181	mnemfn	'ftentoex',fpun,%0000000000010010,%1010000001111111
m182	mnemfn	'ftwotoex',fpun,%0000000000010001,%1010000001111111
m183	mnemfn	'fadd',fpunsd,	%0000000000100010,%1010000001111111
m184	mnemfn	'fsadd',fpunsd,	%0000000001100010,%1010000001111111
m185	mnemfn	'fdadd',fpunsd,	%0000000001100110,%1010000001111111
m186	mnemfn	'fsub',fpunsd,	%0000000000101000,%1010000001111111
m187	mnemfn	'fssub',fpunsd,	%0000000001101000,%1010000001111111
m188	mnemfn	'fdsub',fpunsd,	%0000000001101100,%1010000001111111
m189	mnemfn	'fcmp',fpunsd,	%0000000000111000,%1010000001111111
m190	mnemfn	'fdiv',fpunsd,	%0000000000100000,%1010000001111111

m191	mnemfn	'fsdiv',fpunsd,	%0000000001100000,%1010000001111111
m192	mnemfn	'fddiv',fpunsd,	%0000000001100100,%1010000001111111
m193	mnemfn	'fmod',fpunsd,	%0000000000100001,%1010000001111111
m194	mnemfn	'fmul',fpunsd,	%0000000000100011,%1010000001111111
m195	mnemfn	'fsmul',fpunsd,	%0000000001100011,%1010000001111111
m196	mnemfn	'fdmul',fpunsd,	%0000000001100111,%1010000001111111
m197	mnemfn	'frem',fpunsd,	%0000000000100101,%1010000001111111
m198	mnemfn	'fscale',fpunsd,%0000000000100110,%1010000001111111
m199	mnemfn	'fsgldiv',fpunsd,%0000000000100100,%1010000001111111
m200	mnemfn	'fsglmul',fpunsd,%0000000000100111,%1010000001111111

m201	mnemfn	'ftst',fputst,	%0000000000111010,%1010001111111111
m202	mnemfn	'fmovem',fpumm,	%1100000000000000,%1100011100000000
m203	mnemfn	'fmovem',fpummc,%1000000000000000,%1100001111111111;dis(cr)
m204	mnemfn	'fsmove',fpumea,%0000000001000000,%1010000001111111
m205	mnemfn	'fdmove',fpumea,%0000000001000100,%1010000001111111
m206	mnemfn	'fmove',fpum,	%0000000000000000,%1010000001111111
m207	mnemfn	'fmove',fpumtm,	%0110000000000000,%1110000000000000
m208	mnemf	'pmovefd',pmovtp4,$f000,$ffc0,$4100,$f1ff
m209	mnemf	'pmovefd',pmovtp2,$f000,$ffc0,$0900,$f9ff;dis/code ok!
m210	mnemf	'pmove',pmovtp0,$f000,$ffc0,%0100000000000000,%1110000111111111

m211	mnemf	'pmove',pmovtp1,$f000,$ffc0,%0110000000000000,%1111100111111111
m212	mnemf	'pmove',pmovtp2,$f000,$ffc0,%0000100000000000,%1111100111111111
m213	mnemf	'pmove',pmovtp3,$f000,$ffc0,%0111000000000000,%1111100111100011
m214	mnemf	'ptestr',ptsttp0,$f000,$ffc0,$8200,$e200;d
m215	mnemf	'ptestw',ptsttp0,$f000,$ffc0,$8000,$e200;d
m216	mnemf	'fs',fpuscc,$f240,$ffc0,0,%1111111111000000

m217	mnemf	'fb',fpubcc,$f280,$ff80,0,0

dcdat
m218	mnemf	'dcb',dcbtyp,	0,0,0,0
DCPos
m219	mnemf	'dc',dctyp,	0,0,0,0;MUST follow DCB. DisAssem adds size

	dc.w	-1	;end of list (type -1)

DBNum=(CPUEnd-CPUStart)/$10+(DCPos-FPUStart)/$14+1 ; +1 ??????

ccTypes	dc.w	'ra'
	dc.w	'sr'
	dc.w	'hi'
	dc.w	'ls'
	dc.w	'cc'
	dc.w	'cs'
	dc.w	'ne'
	dc.w	'eq'
	dc.w	'vc'
	dc.w	'vs'
	dc.w	'pl'
	dc.w	'mi'
	dc.w	'ge'
	dc.w	'lt'
	dc.w	'gt'
	dc.w	'le'

pccTypes	dc.w	'bs'
	dc.w	'bc'
	dc.w	'ls'
	dc.w	'lc'
	dc.w	'ss'
	dc.w	'sc'
	dc.w	'as'
	dc.w	'ac'
	dc.w	'ws'
	dc.w	'wc'
	dc.w	'is'
	dc.w	'ic'
	dc.w	'gs'
	dc.w	'gc'
	dc.w	'cs'
	dc.w	'cc'

fcc	macro
	dc.l	\1
	dc.w	\2
	endm

fccTypes	fcc	'f   ',%000000
	fcc	'eq  ',%000001
	fcc	'ogt ',%000010
	fcc	'oge ',%000011
	fcc	'olt ',%000100
	fcc	'ole ',%000101
	fcc	'ogl ',%000110
	fcc	'or  ',%000111
	fcc	'un  ',%001000
	fcc	'ueq ',%001001
	fcc	'ugt ',%001010
	fcc	'uge ',%001011
	fcc	'ult ',%001100
	fcc	'ule ',%001101
	fcc	'ne  ',%001110
	fcc	't   ',%001111
	fcc	'sf  ',%010000
	fcc	'seq ',%010001
	fcc	'gt  ',%010010
	fcc	'ge  ',%010011
	fcc	'lt  ',%010100
	fcc	'le  ',%010101
	fcc	'gl  ',%010110
	fcc	'gle ',%010111
	fcc	'ngle',%011000
	fcc	'ngl ',%011001
	fcc	'nle ',%011010
	fcc	'nlt ',%011011
	fcc	'nge ',%011100
	fcc	'ngt ',%011101
	fcc	'sne ',%011110
	fcc	'st  ',%011111

;macro for register definitions
RLEntry	macro
	dc.b	\2	;register name
	dc.w	\1	;value assigned to register
	endm

EARegList	RLEntry	$000,'SFC   '
	RLEntry	$001,'DFC   '
	RLEntry	$002,'CACR  '
	RLEntry	$003,'TC    '
	RLEntry	$004,'ITT0  '
	RLEntry	$005,'ITT1  '
	RLEntry	$006,'DTT0  '
	RLEntry	$007,'DTT1  '
DATextUSP	RLEntry	$800,'USP   '
	RLEntry	$801,'VBR   '
	RLEntry	$802,'CAAR  '
	RLEntry	$803,'MSP   '
	RLEntry	$804,'ISP   '
	RLEntry	$805,'MMUSR '
	RLEntry	$806,'URP   '
	RLEntry	$807,'SRP   '

	RLEntry	dt20,'SP    '
DATextSSP	RLEntry	dt19,'SSP   '
DATextCCR	RLEntry	dt17,'CCR   '
DATextSR	RLEntry	dt16,'SR    '

FPUCRegs	RLEntry	$8004,'FPCR  '
	RLEntry	$8002,'FPSR  '
	RLEntry	$8001,'FPIAR '

	dc.w	0

;macro for MMU register definitions
PMEntry	macro
	dc.b	\3	;register name
	dc.b	\1	;value assigned to register
	dc.b	\2	;size of register
	endm

PMOVETYPES	PMEntry	0,2,'TC    '
	PMEntry	1,4,'DRP   '
	PMEntry	2,4,'SRP   '
	PMEntry	3,4,'CRP   '
	PMEntry	4,0,'CAL   '
	PMEntry	5,0,'VAL   '
	PMEntry	6,0,'SCC   '
	PMEntry	7,1,'AC    '

	PMEntry	8,1,'PSR   '
	PMEntry	9,1,'PCSR  '
	PMEntry	10,2,'TT0   '
	PMEntry	11,2,'TT1   '
	PMEntry	12,1,'BAD   '	;extra data in cmd!
	PMEntry	13,1,'BAC   '	;extra data in cmd!
	PMEntry	8,1,'MMUSR '	;also allow usage of MMUSR for PSR!

	dc.w	0


	even
TUC=	1	; uncoditionally branch (jmp/bra)
TCB=	2	; conditionally branch (bcc/dbcc)
TE=	4	; exception (illegal/trap)
TR=	8	; return from subtask (rtx)
TS=	16	; call to subroutines (bsr, jsr)
TD=	32	; data words

DisBreakTab	dcb.b	10,0
	dcb.b	5,TR
	dcb.b	5,TE
	dcb.b	43-10,0
	dc.b	TUC,TS,TS,TUC
	dcb.b	58,0
	dc.b	TE,TS
	dcb.b	13,0
	dc.b	TCB,TCB
	dcb.b	9,0
	dc.b	TE,TE
	dcb.b	5,0
	dcb.b	3,TCB
	dcb.b	66,0
	dc.b	TCB
	dcb.b	2,TD

	even
;-----------------------------------------------------------------------------;
;-----------------------------------------------------------------------------;
e
