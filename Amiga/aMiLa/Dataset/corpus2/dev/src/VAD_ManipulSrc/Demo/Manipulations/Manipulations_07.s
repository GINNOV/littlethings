

DEBUG			=	0

MAGIC_NUMBER		=	8
MAX_ALLOCS		=	20


LOAD_BLOCKS		=	$00		; ,blocks_number.w,mem_num.w
RUN_PART		=	$01		; ,mem_num.w,address.l
SYNCHRO_INIT		=	$02		; ,frame_wait.w
SYNCHRONIZED		=	$03
FREE_MEM		=	$04		; ,mem_num.w
STOP			=	$05
LOAD_MUSIC		=	$06
FREE_MUSIC		=	$07


Header			RSRESET
h_MemType		RS.L	1
h_CrunchSize		RS.L	1
h_Size			RS.L	1
Header_SIZEOF		RS.B	0


			INCDIR	"dh1:coding/Include/"
			INCLUDE	"dos/dos.i"
			INCLUDE	"dos/dos_lib.i"

			SECTION	Main,code

		        move.w	$dff07c,d0
			cmp.b	#$f8,d0
			bne.w	NotAGA

			move.l	4.w,a6
			sub.l	a1,a1
			jsr	_LVOFindTask(a6)
			move.l	d0,a0
			move.l	160(a0),CLIHandle

			move.l	4.w,a6
			lea	DOSName,a1
			moveq	#0,d0
			jsr	_LVOOpenLibrary(a6)
			move.l	d0,_DOSBase
			beq.w	Fail0

			move.l	4.w,a6
			move.l	#MEMF_PUBLIC+MEMF_LARGES,d1
			jsr	_LVOAvailMem(a6)

;			lea	txt+8,a0
;			moveq	#7,d7
;tloop
;			move.b	d0,d1
;			andi.b	#$0f,d1
;			cmpi.b	#10,d1
;			blt.b	tl0
;			addi.b	#65-48-10,d1
;tl0
;			addi.b	#48,d1
;			move.b	d1,-(a0)

;			lsr.l	#4,d0

;			dbra	d7,tloop

;			move.l	#txt,d2
;			moveq	#9,d3
;			bsr.w	DisplayText

;			rts


;txt			DC.B	'        ',10

			cmpi.l	#1600000,d0
			blt.w	Fail3


			move.l	_DOSBase,a6
			move.l	#DataFileName,d1
			move.l	#MODE_OLDFILE,d2
			jsr	_LVOOpen(a6)
			move.l	d0,FileHandle
			beq.w	Fail1

			INCDIR	"DEMO:"

			INCLUDE	"Misc/Custom.i"
			INCLUDE	"Shared/MainMacros.s"

; =============================================================================

			INCLUDE	"Misc/StartUp.s"

			move.l	#EmptyCprList,cop1lc+CUSTOM
			move.w	#0,copjmp1+CUSTOM

			move.w	#$0000,bplcon3+CUSTOM
			move.w	#$000,color+CUSTOM

			bsr.w	ClearSprites

			move.l	#EventList,ELPtr

MainLoop		move.l	ELPtr,a0
			move.w	(a0)+,d0
			move.l	a0,ELPtr
			cmpi.w	#STOP,d0
			beq.w	EndOfDemo

			cmpi.w	#RUN_PART,d0
			beq.w	RunPart

			cmpi.w	#LOAD_BLOCKS,d0
			beq.w	LoadBlocks

			cmpi.w	#FREE_MEM,d0
			beq.w	FreeMem

			cmpi.w	#SYNCHRO_INIT,d0
			beq.w	SynchroInit

			cmpi.w	#SYNCHRONIZED,d0
			beq.w	Synchronized

			cmpi.w	#LOAD_MUSIC,d0
			beq.w	LoadMusic

			cmpi.w	#FREE_MUSIC,d0
			beq.w	FreeMusic


			bra.w	MainLoop


SynchroInit		move.w	(a0)+,SynchroCntr
			move.l	a0,ELPtr
			bra.w	MainLoop

Synchronized		tst.w	SynchroCntr
			bne.b	Synchronized
			bra.w	MainLoop

RunPart			move.w	(a0)+,d0
			lsl.w	#2,d0
			move.l	(a0)+,a1
			move.l	a0,ELPtr
			lea	PtrArea,a0
			adda.w	d0,a0

			jsr	Disable_Int
			bsr.w	ClearSprites
			jsr	(a1)
			jsr	Enable_Int

			bra.w	MainLoop


FreeMem			move.w	(a0)+,d4
			move.l	a0,ELPtr
			bsr.w	FreeAllMemory
			bra.w	MainLoop


LoadBlocks		move.w	(a0)+,TmpCntr
			move.w	(a0)+,AreaCntr
			move.l	a0,ELPtr

LoadLoop		move.l	_DOSBase,a6
			move.l	FileHandle,d1
			move.l	#HeaderBuffer,d2
			moveq	#Header_SIZEOF,d3
			jsr	_LVORead(a6)
			cmpi.l	#Header_SIZEOF,d0
			bne.w	Fail2

			addq.l	#MAGIC_NUMBER,HeaderBuffer+h_Size

			move.l	4.w,a6
			move.l	HeaderBuffer+h_Size,d0
			move.l	HeaderBuffer+h_MemType,d1
			jsr	_LVOAllocMem(a6)
			lea	PtrArea,a2
			move.w	AreaCntr,d4
			move.l	d0,(a2,d4.w*4)
			beq.w	Fail3
			lea	SizeArea,a3
			move.l	HeaderBuffer+h_Size,(a3,d4.w*4)

			addq.w	#1,AreaCntr

			move.l	_DOSBase,a6
			move.l	FileHandle,d1
			move.l	d0,d2
			move.l	HeaderBuffer+h_CrunchSize,d3
			jsr	_LVORead(a6)
			cmp.l	HeaderBuffer+h_CrunchSize,d0
			bne.w	Fail2

			move.l	(a2,d4.w*4),a0
			lea	MAGIC_NUMBER(a0),a1
			move.l	HeaderBuffer+h_CrunchSize,d0
			bsr.w	PP_Decrunch

			subq.w	#1,TmpCntr
			bne.w	LoadLoop

			bra.w	MainLoop


LoadMusic		move.l	_DOSBase,a6
			move.l	FileHandle,d1
			move.l	#HeaderBuffer,d2
			moveq	#Header_SIZEOF,d3
			jsr	_LVORead(a6)
			cmpi.l	#Header_SIZEOF,d0
			bne.w	Fail2

			addq.l	#MAGIC_NUMBER,HeaderBuffer+h_Size

			move.l	4.w,a6
			move.l	HeaderBuffer+h_Size,d0
			move.l	HeaderBuffer+h_MemType,d1
			jsr	_LVOAllocMem(a6)
			move.l	d0,P60_data
			beq.w	Fail3
			move.l	HeaderBuffer+h_Size,P60_size

			move.l	_DOSBase,a6
			move.l	FileHandle,d1
			move.l	d0,d2
			move.l	HeaderBuffer+h_CrunchSize,d3
			jsr	_LVORead(a6)
			cmp.l	HeaderBuffer+h_CrunchSize,d0
			bne.w	Fail21

			move.l	P60_data,a0
			lea	MAGIC_NUMBER(a0),a1
			move.l	HeaderBuffer+h_CrunchSize,d0
			bsr.w	PP_Decrunch

			bra.w	MainLoop


FreeMusic		movea.l	4.w,a6
			move.l	P60_data,a1
			move.l	P60_size,d0
			jsr	_LVOFreeMem(a6)

			bra.w	MainLoop

EndOfDemo

CleanUp3

CleanUp2
			move.l	_DOSBase,a6
			move.l	FileHandle,d1
			jsr	_LVOClose(a6)

CleanUp1
			move.l	4.w,a6
			move.l	_DOSBase,a1
			jsr	_LVOCloseLibrary(a6)

Fail0
			move.l	#Text0,d2
			move.l	#LenText0,d3
			bsr.w	DisplayText

			moveq	#0,d0
			rts

Fail3			; tekst: Use farmalloc() and Fuck Off

			bsr.w	Fail_m

			move.l	#Text3,d2
			move.l	#LenText3,d3
			bsr.w	DisplayText
			bra.b	CleanUp3

Fail2			; tekst: io error

			bsr.w	Fail_m

			move.l	#Text2,d2
			move.l	#LenText2,d3
			bsr.b	DisplayText
			bra.b	CleanUp2

Fail21			; tekst: io error

			bsr.w	Fail_m2

			move.l	#Text2,d2
			move.l	#LenText2,d3
			bsr.b	DisplayText
			bra.b	CleanUp2

Fail1			; tekst: file not found

			move.l	#Text1,d2
			move.l	#LenText1,d3
			bsr.b	DisplayText
			bra.b	CleanUp1

NotAGA			; not AGA chipset

			move.l	#Text4,d2
			move.l	#LenText4,d3
			bsr.b	DisplayText
			moveq	#0,d0
			rts


Fail_m			tst.l	P60_size
			beq.b	Fail_m0

			jsr	MUSIC_STOP

Fail_m2			movea.l	4.w,a6
			move.l	P60_data,a1
			move.l	P60_size,d0
			jsr	_LVOFreeMem(a6)

Fail_m0			rts


FreeAllMemory		
			lea	PtrArea,a2
			lea	SizeArea,a3

			move.l	4.w,a6
			move.l	(a2,d4.w*4),a1
			move.l	(a3,d4.w*4),d0
			jsr	_LVOFreeMem(a6)

			rts


; d2.l			pointer to text
; d3.l			length of text

DisplayText		move.l	_DOSBase,a6
			move.l	CLIHandle,d1
			jsr	_LVOWrite(a6)
			rts


ClearSprites		lea	spr+CUSTOM,a4
			moveq	#7,d7
ClearSpritesLoop	move.w	#0,(a4)			; sd_pos=0
			move.w	#0,sd_dataB(a4)
			move.w	#0,sd_dataa(a4)
			addq.w	#sd_SIZEOF,a4
			dbra	d7,ClearSpritesLoop
NoneCode
			rts

			INCLUDE	"Manipulations/PP_Decrunch.s"


			SECTION	MainData0,data

_DOSBase		DC.L	0
FileHandle		DC.L	0
CLIHandle		DC.L	0
ELPtr			DC.L	0
TmpCntr			DC.W	0
SynchroCntr		DC.W	0
IntFlag			DC.W	0
UserInt			DC.L	NoneCode

P60_data		DC.L	0
P60_size		DC.L	0

DOSName			DC.B	"dos.library",0
DataFileName		DC.B	"Manipulations.data",0

Text0			DC.B	10,10
			DC.B	"------------------------------------------------------------",10
			DC.B	"                MANIPULATIONS The Demo '95",10
			DC.B	" was created by Venus Art Entertainment to iNTEL OUTSIDE II",10
			DC.B	"------------------------------------------------------------",10,10
			DC.B	" Platne kopiowanie tego dema moze byc szkodliwe dla zdrowia.",10,10
			DC.B	"                       Minister Zdrowia i Opieki Spolecznej.",10
Text1			DC.B	"File Manipulations.data not found!",10
			DC.B	"Make you MANIPULATIONS drawer as current.",10
Text2			DC.B	"Sorry! IO error!",10
Text3			DC.B	"Not enought memory (required 10 Meg FastRAM :-)",10
			DC.B	"If have only 2 Meg RAM then disable unnecessary HD partition.",10
Text4			DC.B	"Sorry! This demo need AGA chipset!",10
Text_end
LenText0		=	Text1-Text0
LenText1		=	Text2-Text1
LenText2		=	Text3-Text2
LenText3		=	Text4-Text3
LenText4		=	Text_end-Text4

			CNOP	0,2
EventList		
			DC.W	LOAD_BLOCKS,1,0		; load TPolska data
			DC.W	LOAD_MUSIC		; load music data

			DC.W	RUN_PART,0
			DC.L	TerazPolska		; Teraz Polska

			DC.W	FREE_MEM,0

			DC.W	SYNCHRO_INIT,70
			DC.W	LOAD_BLOCKS,1,0		; load Introduction data

			DC.W	RUN_PART,0
			DC.L	MUSIC_START		; music start

			DC.W	SYNCHRONIZED

			DC.W	RUN_PART,0
			DC.L	Introduction		; Introduction
			DC.W	FREE_MEM,0

			DC.W	SYNCHRO_INIT,50
			DC.W	LOAD_BLOCKS,1,0		; load Rage data
			DC.W	SYNCHRONIZED

			DC.W	RUN_PART,0
			DC.L	Rage			; Rage
			DC.W	FREE_MEM,0

			DC.W	SYNCHRO_INIT,50
			DC.W	LOAD_BLOCKS,1,0		; load ComancheText data
			DC.W	SYNCHRONIZED

			DC.W	RUN_PART,0
			DC.L	ComancheText1		; first text

			DC.W	SYNCHRO_INIT,9*50+25	; tak, tak 9.5 sec!
			DC.W	LOAD_BLOCKS,1,1		; load Comanche data

			DC.W	RUN_PART,0
			DC.L	ComancheText2		; second text

			DC.W	LOAD_BLOCKS,1,2		; load Comanche data

			DC.W	SYNCHRONIZED

			DC.W	RUN_PART,0
			DC.L	ComancheText3		; fade out
			DC.W	FREE_MEM,0

			DC.W	SYNCHRO_INIT,33*50+20
			DC.W	RUN_PART,1
			DC.L	ComancheMax		; Comanche Maximum...

			DC.W	FREE_MEM,1
			DC.W	FREE_MEM,2

			DC.W	SYNCHRO_INIT,50*5
			DC.W	LOAD_BLOCKS,1,1		; load TunnelLogo data
			DC.W	RUN_PART,1
			DC.L	TunnelLogo		; TunnelLogo

			DC.W	LOAD_BLOCKS,1,0		; load Tunnel data

			DC.W	SYNCHRONIZED
			DC.W	RUN_PART,1
			DC.L	TunnelLogoOut		; TunnelLogoOut
			DC.W	FREE_MEM,1

			DC.W	SYNCHRO_INIT,50*20
			DC.W	RUN_PART,0
			DC.L	Tunnel			; Tunnel
			DC.W	FREE_MEM,0

			DC.W	LOAD_BLOCKS,2,0		; load DoomPic data
			DC.W	RUN_PART,0
			DC.L	DoomPicture		; DoomPicture
			DC.W	FREE_MEM,0
			DC.W	FREE_MEM,1

			DC.W	LOAD_BLOCKS,2,0		; load WaveTwirl data
			DC.W	RUN_PART,0
			DC.L	WaveTwirl		; Wave and twirl
			DC.W	FREE_MEM,0
			DC.W	FREE_MEM,1

			DC.W	LOAD_BLOCKS,1,0		; load Greetz data
			DC.W	RUN_PART,0
			DC.L	Greetz			; Greetz
			DC.W	FREE_MEM,0

			DC.W	LOAD_BLOCKS,3,0		; load GTFace data
			DC.W	RUN_PART,0
			DC.L	GTFace			; GTFace
			DC.W	FREE_MEM,1
			DC.W	FREE_MEM,2
			DC.W	SYNCHRO_INIT,50*5
			DC.W	LOAD_BLOCKS,1,1		; load GTFace data
			DC.W	SYNCHRONIZED
			DC.W	RUN_PART,1
			DC.L	GTFace2			; GTFace2
			DC.W	FREE_MEM,0
			DC.W	FREE_MEM,1

			DC.W	LOAD_BLOCKS,2,0		; load Credits data
			DC.W	RUN_PART,0
			DC.L	Credits			; Credits
			DC.W	FREE_MEM,0
			DC.W	FREE_MEM,1

;			DC.W	RUN_PART,0		; now in Credits
;			DC.L	MUSIC_STOP		; music stop

			DC.W	FREE_MUSIC

			DC.W	STOP			; end


			SECTION	MainData1,bss_c

			CNOP	0,2
HeaderBuffer		DCB.B	Header_SIZEOF


			SECTION	MainData2,bss

			CNOP	0,2
AreaCntr		DCB.W	1
PtrArea			DCB.L	MAX_ALLOCS
SizeArea		DCB.L	MAX_ALLOCS


			SECTION	MainData3,data_c

EmptyCprList		DC.L	-2


			INCLUDE	"TerazPolska/TPolska3m.s"
			INCLUDE	"Music/MusicPlay_01.s"
			INCLUDE	"Introduction/Introduction_10m.s"
			INCLUDE	"Rage/Rage5m.s"
			INCLUDE	"Comanche/ComancheText_02m.s"
			INCLUDE	"Comanche/Comanche_15m.s"
			INCLUDE	"Tunnel/TunnelLogo_01m.s"
			INCLUDE	"Tunnel/Tunnel_10m.s"
			INCLUDE	"DoomPicture/DoomPicture_01m.s"
			INCLUDE	"WaveTwirl/WT_10m.s"
			INCLUDE	"Greetz/Greetz_02m.s"
			INCLUDE	"GTFace/GTFace_06m.s"
			INCLUDE	"Credits/Credits_03m.s"

			INCLUDE	"Shared/MainShared.s"

			END
