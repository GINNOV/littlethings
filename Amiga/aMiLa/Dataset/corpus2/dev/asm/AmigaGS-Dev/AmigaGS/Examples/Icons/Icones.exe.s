; **************************
; *                        *
; * AMIGA GAME STUDIO BETA *
; *                        *
; *------------------------*
; *                        *
; * Example d'ICONES 16col *
; *                        *
; **************************
;
; Fichier startup de AGS.
	Include	"AmigaGS:AmigaGS-Startup.s"
;
;
; VOTRE PROGRAMME COMMENCERA ICI !!!!!!!!
;
; On charge les icones pour les voir.
	Lea.l		IcName,a0
	LibCall		Icons,LoadIcons

;
	Wait 1,6000000

; Mise en place du copper AGA.
	LibCall		Display,Ags_Display
;
; Ouverture de l'ecran necessaire.
	Moveq.l		#0,d0			; Ecran 0
	Move.l		#320,d1
	Move.l		#256,d2
	Move.l		#8,d3
	LibCall		Screens,Screen_Open

; On place l'ecran dans le display AmigaGS.
	Moveq.l		#0,d0
	LibCall		Screens,Screen_Base
	LibCall		Display,Ags_Screen

; On redéfinit les couleurs.
	SetColor	#$00,#$00,#$00,#$00
	SetColor	#$01,#$33,#$00,#$00
	SetColor	#$02,#$55,#$00,#$00
	SetColor	#$03,#$77,#$33,#$00
	SetColor	#$04,#$99,#$66,#$33
	SetColor	#$05,#$BB,#$99,#$77
	SetColor	#$06,#$DD,#$CC,#$BB
	SetColor	#$07,#$FF,#$FF,#$FF

;
	LibCall		AGSSystem,TasksOff
;
; On attend l'appui sur le bouton gauche de la souris.
;
wlc
	Lea.l		XPOS,a0
	Movem.l		(a0)+,d0/d1/d2
	Add.l		#16,d0
	Cmp.l		#320,d0
	Blt.b		w2a
	Moveq.l		#0,d0
	Add.l		#16,d1
	Add.l		#1,d2
	Cmp.l		#11,d2
	Blt.b		w2a
	Move.l		#1,d2
w2a:
	Cmp.l		#192,d1
	Blt.b		w2b
	Moveq.l		#0,d0
	Moveq.l		#0,d1
	Lea.l		ICON1,a1	
	Move.l		(a1),d3
	Add.l		#1,d3
	Cmp.l		#11,d3
	Blt.l		w2a2
	Clr.l		d3
w2a2:
	Move.l		d3,(a1)
	Move.l		d3,d2
w2b:
	Add.l		#1,d2
	Cmp.l		#11,d2
	Blt.b		w2c
	Moveq.l		#1,d2
w2c:
	Lea.l		XPOS,a0
	Movem.l		d0/d1/d2,(a0)
	LibCall		Icons,PasteIcon
;
	LibCall		Joyport,Joy0Fire1State
	Tst.b		d0
	Beq.w		wlc

; On revient au workbench,on remet tout à 0 et on quitte.
_Fin1:
	LibCall		Icons,EraseIcons
	LibCall		Display,WB_Display
	ScreenClose	#0
	Moveq.l	#0,d0

	LibCall		AGSSystem,TasksOn

	Include	"AmigaGS:AmigaGS-EndStartup.s"

	Rts

;
; Autres librairies définissables par l'utilisateur
;
IcName:
	Dc.b	"AmigaGS:Samples/Icones.FC1"
	EVEN
XPOS:		Dc.l	0
YPOS:		Dc.l	0
CURICON:	Dc.l	1
ICON1:		Dc.l	1