
*****************************************************************************

; Name			: IntroSharedData.i
; Coded by		: Antiriad (Jonathan Bennett <jon@autoitscript.com)
; Description		: Resources that need to be shared between parts.
; Date last edited	: 24/05/2019

; CPU Required		: MC68000 or better
; ChipSet Required	: OCS or better
				
*****************************************************************************


*****************************************************************************

	SECTION	IntroSharedDataCode,CODE	;Code section in Public memory

*****************************************************************************

*** Screen Definitions ***

;The visible screen area and back buffer. This must be bigger than the 
; front and back screen buffers required for all the routines. 
; textwall routine = 320x178x5 = 35600
; Vectors = 320*256*3 = 30720
Screen_Width		=	320
Screen_ByteWidth	=	Screen_Width/8		;Bytes
Screen_WordWidth	=	Screen_ByteWidth/2	;Words
Screen_Height		=	178			;Lines
Screen_NumPlanes	=	5
Screen_Size		=	Screen_ByteWidth*Screen_Height
Screen_TotalSize	=	Screen_Size*Screen_NumPlanes

;Antiriad logo
AntLogo_Width		=	320	
AntLogo_ByteWidth	=	AntLogo_Width/8		;Bytes
AntLogo_WordWidth	=	AntLogo_ByteWidth/2	;Words
AntLogo_Height		=	4			;Lines
AntLogo_NumPlanes	=	1
AntLogo_Size		=	AntLogo_ByteWidth*AntLogo_Height
AntLogo_TotalSize	=	AntLogo_Size*AntLogo_NumPlanes

;Some routines have a scratch buffer. Eg SineScroller and Vector
; This must be big enough to cope with all the routines
; Complex vector routine uses a 320x256x1 buffer
Scratch_Width		=	320
Scratch_ByteWidth	=	Scratch_Width/8		;Bytes
Scratch_WordWidth	=	Scratch_ByteWidth/2	;Words
Scratch_Height		=	256	;Lines
Scratch_NumPlanes	=	1
Scratch_Size		=	Scratch_ByteWidth*Scratch_Height
Scratch_TotalSize	=	Scratch_Size*Scratch_NumPlanes

*****************************************************************************

;Music replay source code

	IFNE	Music
usecode	=$9456	;$9456
		;-1 default. CHANGE! to the USE hexcode from P61con for a big 
		;CPU-time gain! (See module usecodes at end of source)
		;Multiple songs, single playroutine? Just "OR" the 
		;usecodes together!
P61mode	=2	;1=cia, 2=vblank

	EVEN
MusicPlayer:
	INCLUDE	"Music/P6112-Play.i"
	ENDC


*****************************************************************************
*****************************************************************************
*****************************************************************************

;	SECTION	IntroSharedPublicData,DATA

*****************************************************************************
	


*****************************************************************************
*****************************************************************************
*****************************************************************************

;	SECTION	IntroSharedDataChip,DATA_C	;Data Chip data section - screens etc

*****************************************************************************


*****************************************************************************
*****************************************************************************
*****************************************************************************

	IFNE	Music
	SECTION	IntroSharedDataChipMusic,DATA_C	;Music module in chip

*****************************************************************************

	CNOP	0,8			;64 bit alignment
MusicModule:
	INCBIN	"music/P61.Antiriad_10_2.0.9456"
	ENDC

					
*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	IntroSharedDataChip1Bss,BSS_C	;BSS Chip data section - screens etc

*****************************************************************************

	CNOP 0,8	; 64 bit alignment for AA
Screen_Buffer	ds.b	Screen_TotalSize

	CNOP 0,8	; 64 bit alignment for AA
Work_Buffer	ds.b	Screen_TotalSize


*****************************************************************************
*****************************************************************************
*****************************************************************************

	SECTION	IntroSharedDataChip2Bss,BSS_C	;BSS Chip data section - screens etc

*****************************************************************************

	CNOP 0,8	; 64 bit alignment for AA
Scratch_Buffer	ds.b	Scratch_TotalSize	; Used as offscreen work area by vectorinc/sinus scroller routine

	CNOP 0,8	; 64 bit alignment for AA
AntLogo_Buffer	ds.b	AntLogo_TotalSize

*****************************************************************************
