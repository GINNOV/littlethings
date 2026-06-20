; **************************
; *                        *
; * AMIGA GAME STUDIO BETA *
; *                        *
; *------------------------*
; *                        *
; * Example de viewer pour *
; * des images iff/ilbm de *
; * 2 à 256 couleurs .     *
; *                        *
; **************************
;
; Fichier startup de AGS.
	Include	"AmigaGS:AmigaGS-Startup.s"
;
;
; VOTRE PROGRAMME COMMENCERA ICI !!!!!!!!
;
; Mise en place du copper AGA.
	LibCall		Display,Ags_Display
;
; On prend les valeurs IFF/ILBM
	Lea.l		Ilbm,a0
	LibCall		FxIlbm,IlbmXSize
	Lea.l		X,a0
	Move.l		d0,(a0)
;
	Lea.l		Ilbm,a0
	LibCall		FxIlbm,IlbmYSize
	Lea.l		Y,a0
	Move.l		d0,(a0)
;
	Lea.l		Ilbm,a0
	LibCall		FxIlbm,IlbmDepth
	Lea.l		Depth,a0
	Move.l		d0,(a0)
;
; Ouverture de l'ecran necessaire.
	Lea.l		X,a0
	Moveq.l		#0,d0			; Ecran 0
	Movem.l		(a0)+,d1/d2/d3	; X,Y,Depth.
	LibCall		Screens,Screen_Open

; On place l'ecran dans le display AmigaGS.
	Moveq.l		#0,d0
	LibCall		Screens,Screen_Base
	LibCall		Display,Ags_Screen
	Move.l		#256,d0
	LibCall		Display,YDisplaySize

; On va convertir l'image IFF/ILBM Dans l'ecran.
	Moveq.l		#0,d0
	LibCall		Screens,Screen_Base
	Lea.l		Ilbm,a1
	LibCall		FxIlbm,IlbmConvert

; Pour finir,On va placer la bonne palette de couleur.
	Lea.l		Ilbm,a0
	LibCall		FxIlbm,IlbmPalette	; ->A0=palette base
	Lea.l		CMAP,a1
	Move.l		a0,(a1)
	Lea.l		Depth,a1
	Move.l		(a1),d0	; D0=#bpls
	Lsl.w		#1,d0	
	Lea.l		DepthMask,a4
	Add.w		d0,a4
	Lea.l		Depth,a0
	clr.l		(a0)
;
; On redéfinit ??? couleurs selon le déssin.
	Lea.l		CMAP,a0
	Lea.l		Depth,a1
	Move.l		(a0),a3		; A3=Palette Pointer.
	Add.l		#4,a3
	Move.l		(a1),d0		; D0=Couleur en cours.
bcl2
	Clr.l		d1
	Move.b		(a3)+,d1	; D1=ROUGE.
	Clr.l		d2
	Move.b		(a3)+,d2	; D2=VERT.
	Clr.l		d3
	Move.b		(a3)+,d3	; D3=BLEU.
	LibCall		Display,Ags_SetColor
	Lea.l		Depth,a0
	Addq.l		#1,(a0)
	Move.l		(a0),d0		; D0=Prochaine couleur.
	Cmp.w		(a4),d0
	Blt.b		bcl2
;
	LibCall		AGSSystem,TasksOff

; On attend l'appui sur le bouton gauche de la souris.
; Après un déplacement du scrolling.
wlc
	Lea.l		Scroll,a0
	Clr.l		d1				; D1=YScroll=0
	Move.l		(a0),d0			; D1=XScroll
	Addq.l		#1,d0
;0<=XScroll<=319
	Cmp.l		#32000,d0
	Blt.b		w1d
	Sub.l		#32000,d0
w1d:
	Move.l		d0,(a0)
	Divu.l		#100,d0
	LibCall		Display,Screen_Offset



	LibCall		Joyport,Joy0Fire1State
	Tst.b		d0
	Beq.b		wlc


; On revient au workbench,on remet tout à 0 et on quitte.
_Fin1:
	LibCall		AGSSystem,TasksOn

	LibCall		Display,WB_Display
	ScreenClose	#0
	Moveq.l	#0,d0
	Rts

;
; Autres librairies définissables par l'utilisateur
;
X:		Dc.l	0
Y:		Dc.l	0
Depth:	Dc.l	0
CMAP:	Dc.l	0
DepthMask:
		Dc.w	0,2,4,8,16,32,64,128,256
Scroll:	Dc.l	0
Ilbm:
	Incbin	"AmigaGS:Samples/HScroll.lbm"
