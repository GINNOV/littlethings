; These hardware register names correspond directly
; to those which can be found in the Amiga System
; Programmer's Guide by Abacus

; Custom chip registers

INTENA	= $9A	; Interrupt enable register (write)
DMACON	= $96	; DMA-Control register (write)
DMACONR	= $2	; DMA-Control register (read)
COLOR00	= $180	; Color palette register
VHPOSR	= $6	; Beam position (read)
VPOSR	= $4	; Beam position Vertical high bit (read)
; Copper registers

COP1LC	= $80	; Address of 1st Copper-List
COP2LC	= $84	; Address of 2nd Copper-List
COPJMP1	= $88	; Jump to Copper-List 1
COPJMP2	= $8A	; Jump to Copper-List 2

; Bitplane registers

BPLCON0	= $100	; Bitplane control register 0
BPLCON1	= $102	; 1 (Scroll value)
BPLCON2	= $104	; 2 (Sprite <> Playfield Priority)
BPL1PTH	= $0E0	; Pointer to 1st bitplane
BPL1PTL	= $0E2	;
BPL1MOD	= $108	; Modulo value for odd bitplanes
BPL2MOD	= $10A	; Modulo value for even bitplanes
DIWSTRT	= $08E	; Start of screen window
DIWSTOP	= $090	; End of screen window
DDFSTRT	= $092	; Bitplane DMA start
DDFSTOP	= $094	; Bitplane DMA stop

; Blitter registers

BLTCON0	= $40
BLTCON1	= $42
BLTCPTH	= $48
BLTCPTL	= $4A
BLTBPTH	= $4C
BLTBPTL	= $4E
BLTAPTH	= $50
BLTAPTL	= $52
BLTDPTH	= $54
BLTDPTL	= $56
BLTCMOD	= $60
BLTBMOD	= $62
BLTAMOD	= $64
BLTDMOD	= $66
BLTSIZE	= $58
BLTCDAT	= $70
BLTBDAT	= $72
BLTADAT	= $74
BLTAFWM	= $44
BLTALWM	= $46

; CIA-A Port register A (Mouse key)

CIAAPRA	= $BFE001

; Exec Library Base offsets

Execbase		= 4
OpenLibrary	= -552
OldOpenLibrary	= -408
CloseLibrary	= -414
Forbid		= -132
Permit		= -138
Disable		= -120
Enable		= -126
SuperState	= -150
UserState	= -156
AllocMem	= -198
FreeMem		= -210
Public		= 1
ColdCapture	= 42
CoolCapture	= 46
SoftVer		= 34
ChkSum		= 82
; Graphics library Base offsets

OwnBlitter	= -30-426
DisownBlitter	= -30-432

; Graphics base

StartList	= 38


