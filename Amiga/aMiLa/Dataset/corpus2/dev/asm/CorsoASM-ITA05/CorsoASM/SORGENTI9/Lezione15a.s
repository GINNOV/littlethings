
; Lezione15a.s		Sfumatura copper AGA con utilizzo della palette 24bit.
;			Sotto si nota la differenza con quella a 12bit.

	SECTION	AgaRulez,CODE

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; Salva Copperlist Etc.
*****************************************************************************

		;5432109876543210
DMASET	EQU	%1000001010000000	; copper DMA

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:
	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
	move.l	#CopList,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Fmode azzerato, burst normale
	move.w	#$c00,$106(a5)		; BPLCON3 resettato
	move.w	#$11,$10c(a5)		; BPLCON4 resettato

LOOP:
	BTST	#6,$BFE001
	BNE.S	LOOP
	RTS

;*****************************************************************************
;*				COPPERLIST				     *
;*****************************************************************************

	section	coppera,data_C

COPLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod
	dc.w	$100,$201	; no bitplanes (bit 1 abilitato, pero'!)

	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$005	; Color0 - nibble alti
				; (I nibble bassi li lasciamo a zero...)

	dc.w	$5f07,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$010	; Color0 - nibble bassi

	dc.w	$6007,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$030	; Color0 - nibble bassi

	dc.w	$6107,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$050	; Color0 - nibble bassi

	dc.w	$6207,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$070	; Color0 - nibble bassi

	dc.w	$6307,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$090	; Color0 - nibble bassi

	dc.w	$6407,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0b0	; Color0 - nibble bassi

	dc.w	$6507,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0d0	; Color0 - nibble bassi

	dc.w	$6607,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0f0	; Color0 - nibble bassi

	dc.w	$6707,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$010	; Color0 - nibble bassi

	dc.w	$6807,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$030	; Color0 - nibble bassi

	dc.w	$6907,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$050	; Color0 - nibble bassi

	dc.w	$6a07,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$070	; Color0 - nibble bassi

	dc.w	$6b07,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$090	; Color0 - nibble bassi

	dc.w	$6c07,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0b0	; Color0 - nibble bassi

	dc.w	$6d07,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0d0	; Color0 - nibble bassi

	dc.w	$6e07,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0f0	; Color0 - nibble bassi

	dc.w	$6f07,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$010	; Color0 - nibble bassi

	dc.w	$7007,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$030	; Color0 - nibble bassi

	dc.w	$7107,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$050	; Color0 - nibble bassi

	dc.w	$7207,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$070	; Color0 - nibble bassi

	dc.w	$7307,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$090	; Color0 - nibble bassi

	dc.w	$7407,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0b0	; Color0 - nibble bassi

	dc.w	$7507,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0d0	; Color0 - nibble bassi

	dc.w	$7607,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$0f0	; Color0 - nibble bassi

	dc.w	$7707,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$030	; Color0 - nibble alti
	dc.w	$106,$e00	; SELEZIONA NIBBLE BASSI
	dc.w	$180,$010	; Color0 - nibble bassi

; Ora mettiamo a confronto con la palette "standard" ECS/OCS:

	dc.w	$7907,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$000	; Color0 - nibble alti

	dc.w	$8007,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$010	; Color0 - nibble alti

	dc.w	$8807,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$020	; Color0 - nibble alti

	dc.w	$9007,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$030	; Color0 - nibble alti

	dc.w	$9807,$fffe	; Wait
	dc.w	$106,$c00	; SELEZIONA NIBBLE ALTI
	dc.w	$180,$005	; Color0 - nibble alti

	dc.w	$FFFF,$FFFE	; Fine della copperlist

	end

Si nota la differenza, vero?? AGA rulez!
Se notate, la sfumatura segue questo andamento:

  Diviso per nibble	  Originale a 24 bit

	  RGB	rgb		  RrGgBb
	$0000,$0000	-> ossia $000000
	$0000,$0010	-> ossia $000100
	$0000,$0030	-> ossia $000300
	$0000,$0050	-> ossia $000500
	$0000,$0070	-> ossia $000700
	$0000,$0090	-> ossia $000900
	$0000,$00B0	-> ossia $000b00
	$0000,$00D0	-> ossia $000d00
	$0000,$00F0	-> ossia $000f00
	$0010,$0010	-> ossia $001100
	$0010,$0030	-> ossia $001300
	$0010,$0050	-> ossia $001500
	$0010,$0070	-> ossia $001700
	$0010,$0090	-> ossia $001900
	$0010,$00B0	-> ossia $001b00
	$0010,$00D0	-> ossia $001d00
	$0010,$00F0	-> ossia $001f00
	$0020,$0010	-> ossia $002100
	$0020,$0030	-> ossia $002300
	$0020,$0050	-> ossia $002500
	$0020,$0070	-> ossia $002700
	$0020,$0090	-> ossia $002900
	$0020,$00B0	-> ossia $002b00
	$0020,$00D0	-> ossia $002d00
	$0020,$00F0	-> ossia $002f00
	$0030,$0010	-> ossia $003100
	...

Fare una sfumatura AGA e' lungo manualmente, conviene farsi una routine che
le crei!

