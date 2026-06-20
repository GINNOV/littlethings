
; Fermeture du système AGS et de ses librairies.
		Lea.l		AmigaGSMain,a0
		Move.l		(a0),a6
		Jsr			-36(a6)			; AmigaGSQuit
;