Start

ChkForm	dc.b	"FORM"
	dc.l	End-ILBM		; Form Length (From ILBM to END)

ILBM	dc.b	"ILBM"			; InterLeaved BitMap File
	dc.b	"BMHD"			; BitMap Header
	dc.l	20			; Chunk length
	dc.w	320			; WOG, Width of graphics
	dc.w	256			; HOG, Width of graphics
	dc.w	0			; X Pos of graphics
	dc.w	0			; Y Pos of graphics
	dc.b	5			; Number of bitplanes
	dc.b	0			; Masking, 0 = No Masking
	dc.b	0			; Data compression,
					; 0 = no compression
					; 1 = Byte run 1 algorithms
	dc.b	0			; Padding
	dc.w	0			; Transparent colour
	dc.b	10			; X Aspect
	dc.b	11			; Y Aspect
	dc.w	320			; WOSP, Width of source page
	dc.w	256			; HOSP, Height of source page

CMAP	dc.b	"CMAP"			; ColourMap
	dc.l	96			; Chunk Length

	dc.b	$00,$00,$00,$F0,$F0,$F0,$E0,$F0,$F0,$D0,$E0,$F0
	dc.b	$C0,$D0,$F0,$B0,$C0,$F0,$A0,$B0,$E0,$90,$A0,$D0
	dc.b	$80,$90,$C0,$70,$80,$B0,$60,$70,$B0,$50,$70,$B0
	dc.b	$40,$60,$A0,$30,$60,$90,$20,$60,$80,$10,$60,$70
	dc.b	$00,$50,$60,$00,$40,$50,$00,$30,$40,$40,$30,$50
	dc.b	$50,$40,$60,$60,$50,$70,$70,$60,$80,$80,$70,$90
	dc.b	$90,$80,$A0,$A0,$90,$B0,$B0,$A0,$C0,$C0,$B0,$D0
	dc.b	$D0,$C0,$E0,$00,$20,$30,$40,$70,$90,$90,$C0,$F0

CAMG	dc.b	"CAMG"			; Commodore Amiga View Port Mode
	dc.l	4
	dc.l	$4000			; Lo-Res Picture

BODY	dc.b	"BODY"
	dc.l	End-BdyStrt
BdyStrt	incbin	"DH1:IFFPicture/Picture.raw"
End
